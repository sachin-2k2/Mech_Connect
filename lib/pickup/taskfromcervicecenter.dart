import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mechconnect/pickup/home.dart';
import 'package:mechconnect/user/register.dart';

class Assignedtaskpicksservice extends StatefulWidget {
  const Assignedtaskpicksservice({super.key});

  @override
  State<Assignedtaskpicksservice> createState() =>
      _AssignedtaskpicksserviceState();
}

class _AssignedtaskpicksserviceState extends State<Assignedtaskpicksservice> {
  List<dynamic> allReq = [];
  List<dynamic> filteredReq = [];

  Position? currentPosition;
  StreamSubscription<Position>? positionStream;

  String? activeTaskId;

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
      final response = await dio.get('$baseurl/api/booking/pickup/$pobid');
      if (response.statusCode == 200 || response.statusCode == 201) {
        allReq = response.data["data"] ?? [];
        await getCurrentLocationOnce();
        filterTasksByDistance();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // ============================
  // GET LOCATION ONCE
  // ============================
  Future<void> getCurrentLocationOnce() async {
    if (!await Geolocator.isLocationServiceEnabled()) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever)
      return;

    currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // ============================
  // START LIVE TRACKING
  // ============================
  void startTrackingLocation(String taskId) {
    stopTrackingLocation();
    activeTaskId = taskId;

    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    positionStream = Geolocator.getPositionStream(locationSettings: settings)
        .listen((position) {
          currentPosition = position;
          updateStatusWithLocation(
            taskId,
            "tracking",
            position.latitude,
            position.longitude,
          );
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
  // UPDATE STATUS + LOCATION
  // ============================
  Future<void> updateStatusWithLocation(
    String taskId,
    String status,
    double lat,
    double lng,
  ) async {
    try {
      await dio.put(
        '$baseurl/api/booking/mechanic/livelocation/$taskId',
        data: {
          "lat": lat, "lng": lng,
        },
      );
    } catch (e) {
      debugPrint("Location update error: $e");
    }
  }

  // ============================
  // FILTER TASKS BY DISTANCE
  // ============================
  void filterTasksByDistance({double maxDistanceKm = 10}) {
    if (currentPosition == null) return;

    filteredReq = allReq.where((task) {
      final loc = task["userLocation"];
      if (loc == null) return false;

      final distance = Geolocator.distanceBetween(
        currentPosition!.latitude,
        currentPosition!.longitude,
        loc["lat"],
        loc["lng"],
      );

      return distance / 1000 <= maxDistanceKm;
    }).toList();

    setState(() {});
  }

  String getDistance(double lat, double lng) {
    if (currentPosition == null) return "-";
    final meters = Geolocator.distanceBetween(
      currentPosition!.latitude,
      currentPosition!.longitude,
      lat,
      lng,
    );
    return (meters / 1000).toStringAsFixed(2);
  }

  // ============================
  // UI
  // ============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Nearby Tasks",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : filteredReq.isEmpty
          ? const Center(child: Text("No nearby tasks"))
          : ListView.builder(
              itemCount: filteredReq.length,
              itemBuilder: (context, index) {
                final task = filteredReq[index];
                final user = task["userId"];
                final location = task["userLocation"];
                final vehicle = task["vehicleId"];

                final lat = location?["lat"] ?? 0.0;
                final lng = location?["lng"] ?? 0.0;

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(
                      "${vehicle?["brand"] ?? ""} ${vehicle?["model"] ?? ""}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Text("Vehicle Type: ${vehicle?["vehicleType"]}"),
                        Text("Fuel: ${vehicle?["fuelType"]}"),
                        Text("Year: ${vehicle?["year"]}"),
                        Text("Vehicle No: ${vehicle?["vehicleNumber"] ?? "-"}"),
                        const Divider(),
                        Text(
                          lat != 0
                              ? "Pickup: ${getDistance(lat, lng)} km away"
                              : "Pickup location unavailable",
                        ),
                        Text("User: ${user?["name"] ?? "N/A"}"),
                        Text("Phone: ${user?["phone"] ?? "N/A"}"),
                        Text("Status: ${task["status"]}"),
                        const SizedBox(height: 10),

                        /// 🔘 BUTTONS
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: task["status"] == "assigned"
                              ? [
                                  ElevatedButton(
                                    onPressed: activeTaskId != null
                                        ? null
                                        : () async {
                                            setState(() {
                                              task["status"] = "tracking";
                                            });

                                            await updateStatusWithLocation(
                                              task["_id"],
                                              "tracking",
                                              currentPosition!.latitude,
                                              currentPosition!.longitude,
                                            );

                                            startTrackingLocation(task["_id"]);
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                    ),
                                    child: const Text(
                                      "Send Location",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ]
                              : task["status"] == "tracking"
                              ? [
                                  ElevatedButton(
                                    onPressed: () async {
                                      stopTrackingLocation();

                                      setState(() {
                                        task["status"] = "completed";
                                      });

                                      await updateStatusWithLocation(
                                        task["_id"],
                                        "completed",
                                        currentPosition!.latitude,
                                        currentPosition!.longitude,
                                      );

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Task completed successfully",
                                          ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                    ),
                                    child: const Text(
                                      "Complete",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ]
                              : [],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
