import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mechconnect/mechanic/bill.dart';
import 'package:mechconnect/mechanic/home.dart';
import 'package:mechconnect/service/home.dart';
import 'package:mechconnect/user/register.dart';

class Assignedtask extends StatefulWidget {
  Assignedtask({super.key});

  @override
  State<Assignedtask> createState() => _AssignedtaskState();
}

class _AssignedtaskState extends State<Assignedtask> {
  List<dynamic> TASK = [];
  String? currentSharingTaskId;
  bool isLoading = false;

  // Location stream for live updates
  StreamSubscription<Position>? positionStream;
  bool sharingLocation = false;

  // Fetch assigned tasks
  Future<void> get_tasks(BuildContext context) async {
    try {
      setState(() {
        isLoading = true;
      });
      
      final response = await dio.get('$baseurl/api/booking/mechanic/$mobid');
      print(response.data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          TASK = response.data["data"] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        _showSnackBar('Failed to load tasks');
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
      _showSnackBar('Error: $e');
    }
  }

  // Send live location to server
  void startSharingLocation(String taskId) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackBar('Please enable location services');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackBar('Location permission denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnackBar('Location permissions are permanently denied');
      return;
    }

    setState(() {
      currentSharingTaskId = taskId;
      sharingLocation = true;
    });

    positionStream = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((Position position) async {
      print('Lat: ${position.latitude}, Lng: ${position.longitude}');

      // Send location to backend
      try {
        await dio.put(
          '$baseurl/api/booking/mechanic/livelocation/$taskId',
          data: {
            'lat': position.latitude.toString(),
            'lng': position.longitude.toString(),
          },
        );
      } catch (e) {
        print('Error sending location: $e');
      }
    });

    _showSnackBar('Live location sharing started');
  }

  // Stop sharing location
  void stopSharingLocation() {
    positionStream?.cancel();
    setState(() {
      sharingLocation = false;
      currentSharingTaskId = null;
    });
    _showSnackBar('Live location sharing stopped');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.grey.shade800,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'assigned':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  void initState() {
    super.initState();
    get_tasks(context);
  }

  @override
  void dispose() {
    positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Assigned Tasks",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.lightBlueAccent,
        centerTitle: true,
        elevation: 2,
        actions: [
          if (sharingLocation)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: Colors.white, size: 20),
                  SizedBox(width: 4),
                  Text(
                    "Sharing",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      backgroundColor: Colors.grey.shade50,
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
                    strokeWidth: 2.5,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Loading Tasks...",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : TASK.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.assignment_turned_in,
                        size: 80,
                        color: Colors.grey.shade300,
                      ),
                      SizedBox(height: 16),
                      Text(
                        "No Tasks Assigned",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "You will see assigned tasks here",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => get_tasks(context),
                        icon: Icon(Icons.refresh, size: 20),
                        label: Text("Refresh"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlueAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => get_tasks(context),
                  color: Colors.lightBlueAccent,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: TASK.length,
                    itemBuilder: (context, index) {
                      final task = TASK[index];
                      final user = task["userId"] ?? {};
                      final userName = user["name"] ?? "Unknown User";
                      final userPhone = user["phone"]?.toString() ?? "N/A";
                      final problem = task["problemDescription"] ?? "No Description";
                      final loc = task["userLocation"] ?? {};
                      final lat = loc["lat"]?.toString() ?? "-";
                      final lng = loc["lng"]?.toString() ?? "-";
                      final taskId = task['_id'];
                      final isSharingThisTask = sharingLocation && currentSharingTaskId == taskId;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Task ID and Status
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.lightBlueAccent.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        "Task #${index + 1}",
                                        style: TextStyle(
                                          color: Colors.lightBlueAccent,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    if (isSharingThisTask)
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade50,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.green.shade200),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.location_on,
                                              size: 14,
                                              color: Colors.green,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              "Sharing",
                                              style: TextStyle(
                                                color: Colors.green,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),

                                SizedBox(height: 12),

                                // Problem Description
                                Text(
                                  problem,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade800,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                SizedBox(height: 16),

                                // User Information
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.person,
                                            size: 16,
                                            color: Colors.grey.shade600,
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              userName,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey.shade800,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.phone,
                                            size: 16,
                                            color: Colors.grey.shade600,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            userPhone,
                                            style: TextStyle(
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 16),

                                // Location Information
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.blue.shade100),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.location_pin,
                                        size: 20,
                                        color: Colors.blue.shade700,
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Service Location",
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.blue.shade700,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              "Lat: $lat, Lng: $lng",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.blue.shade800,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 16),

                                // Action Buttons
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          if (isSharingThisTask) {
                                            stopSharingLocation();
                                          } else {
                                            if (sharingLocation) {
                                              stopSharingLocation();
                                            }
                                            startSharingLocation(taskId);
                                          }
                                        },
                                        icon: Icon(
                                          isSharingThisTask
                                              ? Icons.location_off
                                              : Icons.location_on,
                                          size: 20,
                                        ),
                                        label: Text(
                                          isSharingThisTask
                                              ? "Stop Sharing"
                                              : "Share Location",
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isSharingThisTask
                                              ? Colors.red.shade50
                                              : Colors.green.shade50,
                                          foregroundColor: isSharingThisTask
                                              ? Colors.red
                                              : Colors.green,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            side: BorderSide(
                                              color: isSharingThisTask
                                                  ? Colors.red.shade200
                                                  : Colors.green.shade200,
                                            ),
                                          ),
                                          padding: EdgeInsets.symmetric(vertical: 12),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          if (sharingLocation) {
                                            stopSharingLocation();
                                          }
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  BillPage(taskid: taskId),
                                            ),
                                          );
                                        },
                                        icon: Icon(
                                          Icons.check_circle,
                                          size: 20,
                                        ),
                                        label: Text("Complete"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.lightBlueAccent,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          padding: EdgeInsets.symmetric(vertical: 12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}