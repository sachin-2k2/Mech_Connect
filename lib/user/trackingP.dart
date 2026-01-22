import 'dart:math';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:mechconnect/user/home.dart';
import 'package:mechconnect/user/map.dart';
import 'package:mechconnect/user/register.dart';

class TrackingPagep extends StatefulWidget {
  const TrackingPagep({super.key});

  @override
  State<TrackingPagep> createState() => _TrackingPagepState();
}

class _TrackingPagepState extends State<TrackingPagep> {
  bool isLoading = true;
  bool hasError = false;
  List<dynamic> history = [];

  @override
  void initState() {
    super.initState();
    getHistory();
  }

  Future<void> getHistory() async {
    try {
      if (!mounted) return;
      setState(() {
        isLoading = true;
        hasError = false;
      });

      final response = await Dio().get(
          '$baseurl/api/pickup/userpickup/$obid'); // replace dio with your instance

      if (response.statusCode == 200) {
        if (!mounted) return;

        // Filter bookings to only include those with agentLocation
        final bookingsWithAgent = (response.data['data'] as List<dynamic>)
            .where((b) => b['agentLocation'] != null)
            .toList();

        setState(() {
          history = bookingsWithAgent;
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

    final a = sin(dLat / 2) * sin(dLat / 2) +
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

                        final agentLocation = booking['agentLocation'];
                        if (agentLocation == null) {
                          return const SizedBox.shrink();
                        }

                        final userLocation = booking['userLocation'];
                        if (userLocation == null) return const SizedBox.shrink();

                        final userLat = userLocation['lat'];
                        final userLng = userLocation['lng'];

                        // Agent info
                        final agent = booking['pickupAgentId'];
                        final agentName = agent?['name'];
                        final agentLoc = agent?['location'];
                        final String bookingId = booking['_id'];

                        // Distance calculation
                        double distance(double? lat1, double? lon1, double? lat2,
                            double? lon2) {
                          if (lat1 == null ||
                              lon1 == null ||
                              lat2 == null ||
                              lon2 == null) {
                            return 0.0;
                          }
                          return _calculateDistance(lat1, lon1, lat2, lon2);
                        }

                        if (agent != null && agentName != null) {
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
                                // Agent Name
                                Row(
                                  children: [
                                    const Icon(Icons.person, color: Colors.blue),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        agentName,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                // Distance
                                Text(
                                  "${distance(userLat, userLng, agentLoc?['lat'], agentLoc?['lng']).toStringAsFixed(2)} km away",
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
                                          builder: (context) =>
                                              MechanicTrackingScreen(
                                            passid: bookingId,
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
