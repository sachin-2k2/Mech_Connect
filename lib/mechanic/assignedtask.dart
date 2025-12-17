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

  // Location stream for live updates
  StreamSubscription<Position>? positionStream;
  bool sharingLocation = false;

  // Fetch assigned tasks
  Future<void> get_tasks(BuildContext context) async {
    try {
      final response = await dio.get('$baseurl/api/booking/mechanic/$mobid');
      print(response.data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          TASK = response.data["data"] ?? [];
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Tasks loaded successfully')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load tasks')));
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // Send live location to server
  void startSharingLocation(String taskId) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Enable location services')));
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Location permission denied')));
        return;
      }
    }

    positionStream =
        Geolocator.getPositionStream(
          locationSettings: LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 5,
          ),
        ).listen((Position position) async {
          print('Lat: ${position.latitude}, Lng: ${position.longitude}');

          // Send location to backend
          await dio.put(
            '$baseurl/api/booking/mechanic/livelocation/$taskId',
            data: {
              'lat': position.latitude.toString(),
              'lng': position.longitude.toString(),
            },
          );
        });

    setState(() {
      sharingLocation = true;
    });
  }

  // Stop sharing location
  void stopSharingLocation() {
    positionStream?.cancel();
    setState(() {
      sharingLocation = false;
    });
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
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: TASK.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: TASK.length,
              itemBuilder: (context, index) {
                final task = TASK[index];
                final user = task["userId"] ?? {};
                final userName = user["name"] ?? "N/A";
                final userPhone = user["phone"]?.toString() ?? "N/A";

                final loc = task["userLocation"] ?? {};
                final lat = loc["lat"]?.toString() ?? "-";
                final lng = loc["lng"]?.toString() ?? "-";

                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task["problemDescription"] ?? "No Description",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text("User: $userName"),
                          Text("Phone: $userPhone"),
                          Text("Location: LAT $lat, LNG $lng"),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Share Location button
                              TextButton(
                                onPressed: () {
                                  if (sharingLocation) {
                                    stopSharingLocation();
                                  } else {
                                    startSharingLocation(task['_id']);
                                  }
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: sharingLocation
                                      ? Colors.red
                                      : Colors.green,
                                ),
                                child: Text(
                                  sharingLocation
                                      ? "Stop Sharing"
                                      : "Share Location",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              // Complete button
                              // Complete button
                              TextButton(
                                onPressed: () {
                                  // Stop sharing location first
                                  if (sharingLocation) {
                                    stopSharingLocation();
                                  }

                                  // Then navigate to BillPage
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          BillPage(taskid: task['_id']),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                ),
                                child: Text(
                                  "Complete",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
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
    );
  }
}
