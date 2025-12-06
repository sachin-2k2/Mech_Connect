import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mechconnect/pickup/home.dart';
import 'package:mechconnect/user/register.dart';

class Assignedtaskpicks extends StatefulWidget {
  Assignedtaskpicks({super.key});

  @override
  State<Assignedtaskpicks> createState() => _AssignedtaskpicksState();
}

class _AssignedtaskpicksState extends State<Assignedtaskpicks> {
  List<dynamic> allReq = []; // all tasks from API
  List<dynamic> filteredReq = []; // tasks filtered by distance
  Position? currentPosition;

  StreamSubscription<Position>? positionStream;
  String? activeTaskId; // track which task is currently accepted


  @override
  void initState() {
    super.initState();
    get_req(context);
  }

  @override
  void dispose() {
    stopTrackingLocation();
    super.dispose();
  }

  // ============================
  // FETCH TASKS
  // ============================
  Future<void> get_req(BuildContext context) async {
    try {
      final response = await dio.get('$baseurl/api/pickup/agent/$pobid');
      print(response.data);

      if (response.statusCode == 200) {
        allReq = response.data["data"] ?? [];
        await getCurrentLocationOnce();
        filterTasksByDistance();
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Failed to fetch tasks")));
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // ============================
  // GET CURRENT LOCATION ONCE
  // ============================
  Future<void> getCurrentLocationOnce() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    currentPosition =
        await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  // ============================
  // START LIVE LOCATION STREAM
  // ============================
  void startTrackingLocation(String taskId) {
    stopTrackingLocation(); // stop previous stream if any
    activeTaskId = taskId;

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // update every 5 meters
    );

    positionStream = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      setState(() {
        currentPosition = position;
      });

      // Send live location to API
      if (activeTaskId != null) {
        updateStatusWithLocation(activeTaskId!, "accepted", position.latitude, position.longitude);
      }
    });
  }

  // ============================
  // STOP TRACKING
  // ============================
  void stopTrackingLocation() {
    positionStream?.cancel();
    positionStream = null;
    activeTaskId = null;
  }

  // ============================
  // UPDATE TASK STATUS WITH LOCATION
  // ============================
  Future<void> updateStatusWithLocation(
      String taskId, String status, double latitude, double longitude) async {
    try {
      final response = await dio.put(
        '$baseurl/api/pickup/status/$taskId',
        data: {
          'status': status,
         'agentLocation':{
           'lat': latitude,
          'lng': longitude,
         }
        },
      );

      if (response.statusCode == 200) {
        print('Status & location updated successfully');
      } else {
        print('Failed to update status & location');
      }
    } catch (e) {
      print('Error updating status & location: $e');
    }
  }

  // ============================
  // FILTER TASKS BY DISTANCE
  // ============================
  void filterTasksByDistance({double maxDistanceKm = 10}) {
    if (currentPosition == null) return;

    filteredReq = allReq.where((task) {
      var location = task["userLocation"];
      if (location == null) return false;

      double distanceInMeters = Geolocator.distanceBetween(
        currentPosition!.latitude,
        currentPosition!.longitude,
        location["lat"],
        location["lng"],
      );

      return distanceInMeters / 1000 <= maxDistanceKm;
    }).toList();

    setState(() {});
  }

  // ============================
  // CALCULATE DISTANCE
  // ============================
  String getDistance(double lat, double lng) {
    if (currentPosition == null) return "-";
    double distanceInMeters = Geolocator.distanceBetween(
      currentPosition!.latitude,
      currentPosition!.longitude,
      lat,
      lng,
    );
    return (distanceInMeters / 1000).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Nearby Tasks",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: currentPosition == null
          ? Center(child: CircularProgressIndicator())
          : filteredReq.isEmpty
              ? Center(child: Text("No nearby tasks"))
              : ListView.builder(
                  itemCount: filteredReq.length,
                  itemBuilder: (context, index) {
                    var task = filteredReq[index];
                    var user = task["userId"];
                    var location = task["userLocation"];
                    double pickupLat = location?["lat"] ?? 0.0;
                    double pickupLng = location?["lng"] ?? 0.0;
                    String distance = (pickupLat != 0.0 && pickupLng != 0.0)
                        ? getDistance(pickupLat, pickupLng)
                        : "-";

                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: InkWell(
                        onTap: () {},
                        child: Card(
                          child: ListTile(
                            title: Text("Vehicle: ${task["vehicletype"]}"),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pickupLat != 0.0 && pickupLng != 0.0
                                      ? "Pickup: $pickupLat, $pickupLng (${distance} km away)"
                                      : "Pickup location not available",
                                ),
                                Text("Drop: ${task["dropLocation"]}"),
                                Text("User: ${user?["name"] ?? "N/A"}"),
                                Text("Phone: ${user?["phone"] ?? "N/A"}"),
                                Text("Status: ${task["status"]}"),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: task["status"] == "pending"
                                      ? [
                                          // Accept button starts live tracking
                                          TextButton(
                                            onPressed: () {
                                              setState(() {
                                                task["status"] = "accepted";
                                              });
                                              startTrackingLocation(task["_id"]);
                                            },
                                            style: TextButton.styleFrom(
                                              backgroundColor:
                                                  Color.fromARGB(195, 76, 175, 79),
                                            ),
                                            child: Text(
                                              "Accept",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          TextButton(
                                            onPressed: () async {
                                              setState(() {
                                                task["status"] = "rejected";
                                              });
                                              stopTrackingLocation();
                                              await updateStatusWithLocation(
                                                  task["_id"],
                                                  "rejected",
                                                  currentPosition?.latitude ?? 0.0,
                                                  currentPosition?.longitude ?? 0.0);
                                            },
                                            style: TextButton.styleFrom(
                                              backgroundColor:
                                                  Color.fromARGB(196, 244, 67, 54),
                                            ),
                                            child: Text(
                                              "Reject",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ]
                                      : task["status"] == "accepted"
                                          ? [
                                              TextButton(
                                                onPressed: () async {
                                                  setState(() {
                                                    task["status"] = "completed";
                                                  });
                                                  stopTrackingLocation();
                                                  await updateStatusWithLocation(
                                                      task["_id"],
                                                      "completed",
                                                      currentPosition?.latitude ?? 0.0,
                                                      currentPosition?.longitude ?? 0.0);
                                                },
                                                style: TextButton.styleFrom(
                                                    backgroundColor: Colors.blue),
                                                child: Text(
                                                  "Complete",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                            ]
                                          : [],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
