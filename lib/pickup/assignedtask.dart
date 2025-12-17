import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mechconnect/pickup/home.dart';
import 'package:mechconnect/user/register.dart';

class Assignedtaskpicks extends StatefulWidget {
  const Assignedtaskpicks({super.key});

  @override
  State<Assignedtaskpicks> createState() => _AssignedtaskpicksState();
}

class _AssignedtaskpicksState extends State<Assignedtaskpicks> {
  List<dynamic> allReq = [];
  List<dynamic> filteredReq = [];

  Position? currentPosition;
  StreamSubscription<Position>? positionStream;

  String? activeTaskId; // Track which task is currently being tracked

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

      if (response.statusCode == 200) {
        allReq = response.data["data"] ?? [];
        await getCurrentLocationOnce();
        filterTasksByDistance();
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // ============================
  // GET LOCATION ONCE
  // ============================
  Future<void> getCurrentLocationOnce() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) return;

    currentPosition =
        await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  // ============================
  // START LIVE TRACKING
  // ============================
  void startTrackingLocation(String taskId) {
    // Stop any existing tracking first
    stopTrackingLocation();

    // Set the active task ID
    activeTaskId = taskId;

    print("🚗 Starting live location tracking for task: $taskId");

    // Location settings for the stream
    const LocationSettings settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // Send update every 5 meters movement
    );

    // Start listening to location updates
    positionStream = Geolocator.getPositionStream(locationSettings: settings)
        .listen((Position position) {
      // Update current position
      currentPosition = position;
      
      print("📍 Location update - Lat: ${position.latitude}, Lng: ${position.longitude}");

      // Send location to server for the active task
      if (activeTaskId != null) {
        updateStatusWithLocation(
          activeTaskId!,
          "accepted", // Status remains "accepted" during tracking
          position.latitude,
          position.longitude,
        );
      }
    }, onError: (error) {
      print("❌ Location stream error: $error");
    });
  }

  // ============================
  // STOP TRACKING
  // ============================
  void stopTrackingLocation() {
    if (positionStream != null) {
      positionStream!.cancel();
      positionStream = null;
      print("🛑 Stopped live location tracking for task: $activeTaskId");
    }
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
      print("📡 Sending location to server - Task: $taskId, Status: $status");
      
      await dio.put(
        '$baseurl/api/pickup/status/$taskId',
        data: {
          "status": status,
          "agentLocation": {
            "lat": lat,
            "lng": lng,
          }
        },
      );
      
      print("✅ Location sent successfully");
    } catch (e) {
      print("❌ Location update error: $e");
    }
  }

  // ============================
  // FILTER BY DISTANCE
  // ============================
  void filterTasksByDistance({double maxDistanceKm = 10}) {
    if (currentPosition == null) return;

    filteredReq = allReq.where((task) {
      final loc = task["userLocation"];
      if (loc == null) return false;

      double distance = Geolocator.distanceBetween(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Nearby Tasks",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.lightBlueAccent,
        // Show which task is being tracked
        actions: [
          if (activeTaskId != null)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: Colors.white, size: 20),
                  SizedBox(width: 5),
                  Text(
                    "Tracking",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : filteredReq.isEmpty
              ? const Center(child: Text("No nearby tasks"))
              : Column(
                  children: [
                    // Show active tracking info
                    if (activeTaskId != null)
                      Container(
                        padding: EdgeInsets.all(10),
                        color: Colors.green[50],
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.location_on, color: Colors.green),
                            SizedBox(width: 10),
                            Text(
                              "Live location sharing ACTIVE",
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredReq.length,
                        itemBuilder: (context, index) {
                          final task = filteredReq[index];
                          final user = task["userId"];
                          final location = task["userLocation"];

                          final lat = location?["lat"] ?? 0.0;
                          final lng = location?["lng"] ?? 0.0;

                          // Check if this task is currently being tracked
                          bool isTrackingThisTask = activeTaskId == task["_id"];

                          return Card(
                            margin: const EdgeInsets.all(10),
                            color: isTrackingThisTask ? Colors.blue[50] : Colors.white,
                            elevation: isTrackingThisTask ? 4 : 1,
                            child: ListTile(
                              title: Text(
                                "Vehicle: ${task["vehicletype"]}",
                                style: TextStyle(
                                  fontWeight: isTrackingThisTask 
                                      ? FontWeight.bold 
                                      : FontWeight.normal,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lat != 0
                                        ? "Pickup: ${getDistance(lat, lng)} km away"
                                        : "Pickup location unavailable",
                                  ),
                                  Text("Drop: ${task["dropLocation"]}"),
                                  Text("User: ${user?["name"] ?? "N/A"}"),
                                  Text("Phone: ${user?["phone"] ?? "N/A"}"),
                                  Row(
                                    children: [
                                      Text("Status: ${task["status"]}"),
                                      if (isTrackingThisTask)
                                        Row(
                                          children: [
                                            SizedBox(width: 10),
                                            Icon(Icons.location_on, 
                                                color: Colors.green, size: 16),
                                            Text(
                                              " Tracking",
                                              style: TextStyle(
                                                color: Colors.green,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: task["status"] == "pending"
                                        ? [
                                            // ACCEPT BUTTON
                                            ElevatedButton(
                                              onPressed: activeTaskId != null
                                                  ? null // Disable if already tracking another task
                                                  : () async {
                                                      setState(() {
                                                        task["status"] = "accepted";
                                                      });

                                                      // Send initial accept location
                                                      await updateStatusWithLocation(
                                                        task["_id"],
                                                        "accepted",
                                                        currentPosition!.latitude,
                                                        currentPosition!.longitude,
                                                      );

                                                      // Start continuous tracking
                                                      startTrackingLocation(task["_id"]);
                                                    },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                disabledBackgroundColor: Colors.grey,
                                              ),
                                              child: const Text(
                                                "Accept",
                                                style: TextStyle(color: Colors.white),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            // REJECT BUTTON
                                            ElevatedButton(
                                              onPressed: () async {
                                                stopTrackingLocation();
                                                setState(() {
                                                  task["status"] = "rejected";
                                                });
                                                await updateStatusWithLocation(
                                                  task["_id"],
                                                  "rejected",
                                                  currentPosition!.latitude,
                                                  currentPosition!.longitude,
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                              ),
                                              child: const Text(
                                                "Reject",
                                                style: TextStyle(color: Colors.white),
                                              ),
                                            ),
                                          ]
                                        : task["status"] == "accepted"
                                            ? [
                                                // COMPLETE BUTTON
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    // Stop live tracking
                                                    stopTrackingLocation();
                                                    
                                                    setState(() {
                                                      task["status"] = "completed";
                                                    });
                                                    
                                                    // Send final location with completed status
                                                    await updateStatusWithLocation(
                                                      task["_id"],
                                                      "completed",
                                                      currentPosition!.latitude,
                                                      currentPosition!.longitude,
                                                    );
                                                    
                                                    // Show confirmation
                                                    ScaffoldMessenger.of(context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          "Task completed! Location tracking stopped.",
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
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}