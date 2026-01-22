import 'dart:math';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:mechconnect/user/home.dart';
import 'package:mechconnect/user/map.dart';
import 'package:mechconnect/user/register.dart';

class TrackingPage extends StatefulWidget {
  const TrackingPage({super.key});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  bool isLoading = true;
  bool hasError = false;

  List<dynamic> history = [];

  @override
  void initState() {
    super.initState();
    getHistory();
  }

  @override
  void dispose() {
    super.dispose();
    // No timers or listeners here, but if you add them, cancel here
  }

  Future<void> getHistory() async {
    try {
      if (!mounted) return;
      setState(() {
        isLoading = true;
        hasError = false;
      });

      final response = await dio.get('$baseurl/api/booking/user/$obid');
      print(response.data);

      if (response.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          history = response.data['data'] ?? [];
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  // ================= DISTANCE CALCULATION =================
  double _deg2rad(double deg) => deg * (pi / 180);

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371; // KM
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Tracking"),
        backgroundColor: Colors.blue.shade700,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
          ? const Center(child: Text("Failed to load data"))
          : history.isEmpty
          ? const Center(child: Text("No Active Booking"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final booking = history[index];
                print(booking); // debug: check structure

                final liveLocation = booking['liveLocation'];
                final userLocation = booking['userLocation'];

                if (liveLocation == null || userLocation == null) {
                  return const SizedBox.shrink();
                }

                final userLat = userLocation['lat'];
                final userLng = userLocation['lng'];

                // Mechanic
                final mechanic = booking['mechanicId'];
                final mechanicName = mechanic?['mechanicName']; // fixed key
                final mechanicLocation = mechanic?['location'];
                final String bookingid=booking['_id'];

                // Service Center where mechanic is working
                final serviceCenter = booking['serviceCenterId'];
                final centerName = serviceCenter?['centerName'];
                final centerLocation = serviceCenter?['location'];

                // Safe distance calculation
                double distance(
                  double? lat1,
                  double? lon1,
                  double? lat2,
                  double? lon2,
                ) {
                  if (lat1 == null ||
                      lon1 == null ||
                      lat2 == null ||
                      lon2 == null) {
                    return 0.0;
                  }
                  return _calculateDistance(lat1, lon1, lat2, lon2);
                }

                // Only show mechanic if exists
                if (mechanic != null && mechanicName != null) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mechanic Name
                        Row(
                          children: [
                            const Icon(Icons.person, color: Colors.blue),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                mechanicName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Service Center under mechanic
                        if (serviceCenter != null && centerName != null)
                          Row(
                            children: [
                              const Icon(
                                Icons.business,
                                color: Colors.green,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "$centerName (working here)",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),

                        const SizedBox(height: 10),

                        // Distance
                        Text(
                          "${distance(userLat, userLng, mechanicLocation?['lat'], mechanicLocation?['lng']).toStringAsFixed(2)} km away",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // TRACK BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MechanicTrackingScreen(
                                    passid: bookingid,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.map),
                            label: const Text("TRACK"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
    );
  }
}
