import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mechconnect/pickup/home.dart';
import 'package:mechconnect/user/register.dart';
import 'package:intl/intl.dart';

class Assignedtaskpicksservice extends StatefulWidget {
  const Assignedtaskpicksservice({super.key});

  @override
  State<Assignedtaskpicksservice> createState() =>
      _AssignedtaskpicksserviceState();
}

class _AssignedtaskpicksserviceState extends State<Assignedtaskpicksservice> {
  List<dynamic> allReq = [];
  List<dynamic> filteredReq = [];
  bool isLoading = true;
  bool isTracking = false;

  Position? currentPosition;
  StreamSubscription<Position>? positionStream;
  String? activeTaskId;

  @override
  void initState() {
    super.initState();
    _initializeLocationAndTasks();
  }

  @override
  void dispose() {
    stopTrackingLocation();
    super.dispose();
  }

  Future<void> _initializeLocationAndTasks() async {
    await getCurrentLocationOnce();
    await get_req();
  }

  // ============================
  // FETCH TASKS
  // ============================
  Future<void> get_req() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await dio.get('$baseurl/api/booking/pickup/$pobid');

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          allReq = response.data["data"] ?? [];
          filterTasksByDistance();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error fetching tasks: $e");
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error loading tasks: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================
  // GET LOCATION ONCE
  // ============================
  Future<void> getCurrentLocationOnce() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      print("📍 Initial location fetched");
    } catch (e) {
      print("Location error: $e");
    }
  }

  // ============================
  // START LIVE TRACKING
  // ============================
  void startTrackingLocation(String taskId) {
    stopTrackingLocation();

    activeTaskId = taskId;
    isTracking = true;

    print("📍 Starting live location tracking for task: $taskId");

    const LocationSettings settings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 10,
    );

    positionStream = Geolocator.getPositionStream(locationSettings: settings)
        .listen((Position position) {
      currentPosition = position;
      print("📍 Location update: ${position.latitude}, ${position.longitude}");

      if (activeTaskId != null) {
        updateStatusWithLocation(
          activeTaskId!,
          "tracking",
          position.latitude,
          position.longitude,
        );
      }
    }, onError: (error) {
      print("❌ Location stream error: $error");
    });

    setState(() {});
  }

  // ============================
  // STOP TRACKING
  // ============================
  void stopTrackingLocation() {
    if (positionStream != null) {
      positionStream!.cancel();
      positionStream = null;
    }
    activeTaskId = null;
    isTracking = false;
    setState(() {});
    print("🛑 Stopped live location tracking");
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
        data: {"lat": lat, "lng": lng},
      );
      print("✅ Location sent to server - Status: $status");
    } catch (e) {
      print("❌ Location update error: $e");
    }
  }

  // ============================
  // FILTER TASKS BY DISTANCE
  // ============================
  void filterTasksByDistance({double maxDistanceKm = 50}) {
    if (currentPosition == null) {
      filteredReq = allReq;
      return;
    }

    filteredReq = allReq.where((task) {
      final loc = task["userLocation"];
      if (loc == null) return true;

      final distance = Geolocator.distanceBetween(
        currentPosition!.latitude,
        currentPosition!.longitude,
        loc["lat"]?.toDouble() ?? 0.0,
        loc["lng"]?.toDouble() ?? 0.0,
      );

      return distance / 1000 <= maxDistanceKm;
    }).toList();

    setState(() {});
  }

  String getDistance(double lat, double lng) {
    if (currentPosition == null) return "Calculating...";
    final meters = Geolocator.distanceBetween(
      currentPosition!.latitude,
      currentPosition!.longitude,
      lat,
      lng,
    );
    return "${(meters / 1000).toStringAsFixed(1)} km";
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'tracking':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'assigned':
        return Colors.blue;
      case 'pending':
        return Colors.grey;
      default:
        return Colors.purple;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'tracking':
        return Icons.location_on;
      case 'completed':
        return Icons.check_circle;
      case 'assigned':
        return Icons.assignment_turned_in;
      case 'pending':
        return Icons.access_time;
      default:
        return Icons.help_outline;
    }
  }

  String _formatDate(String dateString) {
    try {
      if (dateString.isEmpty) return "Today";
      final dateTime = DateTime.parse(dateString);
      return DateFormat('MMM dd, hh:mm a').format(dateTime);
    } catch (e) {
      return "Today";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.orange.shade900,
              Colors.orange.shade700,
              Colors.orange.shade400,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Service Pickups",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                "Manage vehicle pickup for service",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    if (currentPosition != null)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          "Your location: ${currentPosition!.latitude.toStringAsFixed(5)}, ${currentPosition!.longitude.toStringAsFixed(5)}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Tracking Indicator
              if (isTracking && activeTaskId != null)
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    border: Border.all(color: Colors.orange.shade100),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_on, color: Colors.orange, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Live location sharing ACTIVE - Sharing your real-time location",
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        onPressed: stopTrackingLocation,
                        icon: Icon(Icons.stop, color: Colors.red, size: 20),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),

              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: isLoading
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                color: Colors.orange.shade700,
                              ),
                              SizedBox(height: 20),
                              Text(
                                "Loading pickup tasks...",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              // Summary Card
                              Container(
                                padding: EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: Colors.orange.shade100,
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.local_shipping,
                                          color: Colors.orange.shade700,
                                          size: 20,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          "${filteredReq.length} Pickup Tasks",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.orange.shade900,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            size: 14,
                                            color: Colors.green.shade700,
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            "50 km radius",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.green.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20),

                              // Tasks List
                              Expanded(
                                child: filteredReq.isEmpty
                                    ? Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.local_shipping_outlined,
                                              size: 80,
                                              color: Colors.grey.shade300,
                                            ),
                                            SizedBox(height: 20),
                                            Text(
                                              "No Pickup Tasks",
                                              style: TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey.shade500,
                                              ),
                                            ),
                                            SizedBox(height: 10),
                                            Text(
                                              "No vehicles assigned for service pickup",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey.shade400,
                                              ),
                                            ),
                                            SizedBox(height: 30),
                                            ElevatedButton(
                                              onPressed: get_req,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.orange.shade700,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(15),
                                                ),
                                              ),
                                              child: Text("Refresh Tasks"),
                                            ),
                                          ],
                                        ),
                                      )
                                    : ListView.builder(
                                        itemCount: filteredReq.length,
                                        itemBuilder: (context, index) {
                                          final task = filteredReq[index];
                                          final user = task["userId"];
                                          final vehicle = task["vehicleId"];
                                          final location = task["userLocation"];
                                          final isActiveTask = activeTaskId == task["_id"];

                                          final lat = location?["lat"]?.toDouble() ?? 0.0;
                                          final lng = location?["lng"]?.toDouble() ?? 0.0;

                                          return Container(
                                            margin: EdgeInsets.only(bottom: 15),
                                            decoration: BoxDecoration(
                                              color: isActiveTask
                                                  ? Colors.orange.shade50
                                                  : Colors.white,
                                              borderRadius: BorderRadius.circular(20),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(
                                                      isActiveTask ? 0.1 : 0.05),
                                                  blurRadius: 15,
                                                  spreadRadius: 2,
                                                ),
                                              ],
                                              border: Border.all(
                                                color: isActiveTask
                                                    ? Colors.orange.shade200
                                                    : Colors.grey.shade200,
                                                width: isActiveTask ? 2 : 1,
                                              ),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(20),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  // Header with Status
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Container(
                                                        padding: EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                          vertical: 6,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          color: _getStatusColor(
                                                                  task["status"])
                                                              .withOpacity(0.1),
                                                          borderRadius:
                                                              BorderRadius.circular(10),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              _getStatusIcon(
                                                                  task["status"]),
                                                              size: 14,
                                                              color: _getStatusColor(
                                                                  task["status"]),
                                                            ),
                                                            SizedBox(width: 6),
                                                            Text(
                                                              task["status"]
                                                                  .toString()
                                                                  .toUpperCase(),
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight.w600,
                                                                color: _getStatusColor(
                                                                    task["status"]),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Text(
                                                        _formatDate(task["createdAt"] ?? ""),
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey.shade600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 15),

                                                  // Vehicle Info
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: 50,
                                                        height: 50,
                                                        decoration: BoxDecoration(
                                                          color: Colors.orange.shade50,
                                                          shape: BoxShape.circle,
                                                        ),
                                                        child: Icon(
                                                          vehicle?["vehicleType"] ==
                                                                  "Two Wheeler"
                                                              ? Icons.two_wheeler
                                                              : vehicle?["vehicleType"] ==
                                                                      "Heavy Vehicle"
                                                                  ? Icons.local_shipping
                                                                  : Icons.directions_car,
                                                          color: Colors.orange.shade700,
                                                          size: 26,
                                                        ),
                                                      ),
                                                      SizedBox(width: 15),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              "${vehicle?["brand"] ?? ""} ${vehicle?["model"] ?? ""}",
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight.w600,
                                                                color: Colors.orange
                                                                    .shade900,
                                                              ),
                                                            ),
                                                            SizedBox(height: 4),
                                                            Text(
                                                              vehicle?["vehicleNumber"] ??
                                                                  "No Plate",
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                color: Colors.grey.shade600,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 15),

                                                  // Vehicle Details
                                                  Container(
                                                    padding: EdgeInsets.all(12),
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey.shade50,
                                                      borderRadius:
                                                          BorderRadius.circular(12),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.directions_car,
                                                          size: 20,
                                                          color: Colors.grey.shade600,
                                                        ),
                                                        SizedBox(width: 10),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                "Vehicle Details",
                                                                style: TextStyle(
                                                                  fontSize: 12,
                                                                  color:
                                                                      Colors.grey.shade600,
                                                                ),
                                                              ),
                                                              SizedBox(height: 4),
                                                              Row(
                                                                children: [
                                                                  Container(
                                                                    padding: EdgeInsets
                                                                        .symmetric(
                                                                      horizontal: 8,
                                                                      vertical: 4,
                                                                    ),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Colors
                                                                          .blue.shade50,
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .circular(6),
                                                                    ),
                                                                    child: Text(
                                                                      vehicle?["vehicleType"] ??
                                                                          "N/A",
                                                                      style: TextStyle(
                                                                        fontSize: 11,
                                                                        color: Colors
                                                                            .blue.shade700,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(width: 8),
                                                                  Container(
                                                                    padding: EdgeInsets
                                                                        .symmetric(
                                                                      horizontal: 8,
                                                                      vertical: 4,
                                                                    ),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Colors
                                                                          .green.shade50,
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .circular(6),
                                                                    ),
                                                                    child: Text(
                                                                      vehicle?["fuelType"] ??
                                                                          "N/A",
                                                                      style: TextStyle(
                                                                        fontSize: 11,
                                                                        color: Colors
                                                                            .green.shade700,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(width: 8),
                                                                  Container(
                                                                    padding: EdgeInsets
                                                                        .symmetric(
                                                                      horizontal: 8,
                                                                      vertical: 4,
                                                                    ),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Colors
                                                                          .purple.shade50,
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .circular(6),
                                                                    ),
                                                                    child: Text(
                                                                      "Year: ${vehicle?["year"] ?? "N/A"}",
                                                                      style: TextStyle(
                                                                        fontSize: 11,
                                                                        color: Colors
                                                                            .purple.shade700,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(height: 15),

                                                  // Distance and Customer Info
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Container(
                                                          padding: EdgeInsets.all(12),
                                                          decoration: BoxDecoration(
                                                            color: Colors.blue.shade50,
                                                            borderRadius:
                                                                BorderRadius.circular(12),
                                                          ),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                "Pickup Distance",
                                                                style: TextStyle(
                                                                  fontSize: 12,
                                                                  color:
                                                                      Colors.grey.shade600,
                                                                ),
                                                              ),
                                                              Text(
                                                                getDistance(lat, lng),
                                                                style: TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight.w600,
                                                                  color: Colors
                                                                      .green.shade700,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 10),
                                                      Expanded(
                                                        child: Container(
                                                          padding: EdgeInsets.all(12),
                                                          decoration: BoxDecoration(
                                                            color: Colors.purple.shade50,
                                                            borderRadius:
                                                                BorderRadius.circular(12),
                                                          ),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                "Customer",
                                                                style: TextStyle(
                                                                  fontSize: 12,
                                                                  color:
                                                                      Colors.grey.shade600,
                                                                ),
                                                              ),
                                                              Text(
                                                                user?["name"] ?? "N/A",
                                                                style: TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight.w500,
                                                                  color: Colors
                                                                      .purple.shade900,
                                                                ),
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow.ellipsis,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 15),

                                                  // Contact Info
                                                  _buildInfoRow(
                                                    icon: Icons.phone,
                                                    label: "Contact",
                                                    value: user?["phone"] ?? "N/A",
                                                  ),
                                                  _buildInfoRow(
                                                    icon: Icons.location_on,
                                                    label: "Pickup Address",
                                                    value: "User's Location",
                                                    maxLines: 1,
                                                  ),
                                                  SizedBox(height: 20),

                                                  // Action Buttons
                                                  if (task["status"] == "assigned")
                                                    SizedBox(
                                                      width: double.infinity,
                                                      height: 45,
                                                      child: ElevatedButton(
                                                        onPressed: isTracking
                                                            ? null
                                                            : () async {
                                                                setState(() {
                                                                  task["status"] =
                                                                      "tracking";
                                                                });
                                                                await updateStatusWithLocation(
                                                                  task["_id"],
                                                                  "tracking",
                                                                  currentPosition!
                                                                      .latitude,
                                                                  currentPosition!
                                                                      .longitude,
                                                                );
                                                                startTrackingLocation(
                                                                    task["_id"]);
                                                              },
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.orange.shade700,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(12),
                                                          ),
                                                          elevation: 3,
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment.center,
                                                          children: [
                                                            Icon(
                                                              Icons.location_on,
                                                              color: Colors.white,
                                                              size: 20,
                                                            ),
                                                            SizedBox(width: 10),
                                                            Text(
                                                              "START LIVE TRACKING",
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight.bold,
                                                                color: Colors.white,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  else if (task["status"] == "tracking")
                                                    SizedBox(
                                                      width: double.infinity,
                                                      height: 45,
                                                      child: ElevatedButton(
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
                                                          ScaffoldMessenger.of(context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                  "Pickup completed successfully!"),
                                                              backgroundColor:
                                                                  Colors.green,
                                                            ),
                                                          );
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.green.shade700,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(12),
                                                          ),
                                                          elevation: 3,
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment.center,
                                                          children: [
                                                            Icon(
                                                              Icons.check_circle,
                                                              color: Colors.white,
                                                              size: 20,
                                                            ),
                                                            SizedBox(width: 10),
                                                            Text(
                                                              "MARK AS COMPLETED",
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight.bold,
                                                                color: Colors.white,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.grey.shade600,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.orange.shade900,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}