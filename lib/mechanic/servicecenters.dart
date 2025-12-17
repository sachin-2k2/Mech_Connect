import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mechconnect/mechanic/home.dart';
import 'package:mechconnect/user/register.dart';

class Viewservicecentermech extends StatefulWidget {
  const Viewservicecentermech({super.key});

  @override
  State<Viewservicecentermech> createState() => _ViewservicecentermechState();
}

class _ViewservicecentermechState extends State<Viewservicecentermech> {
  List service = [];

  double? userLat;
  double? userLng;

  // ---------------- USER LOCATION ----------------
  Future<void> getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location service is disabled';
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permission denied';
      }
    }

    final position = await Geolocator.getCurrentPosition();

    setState(() {
      userLat = position.latitude;
      userLng = position.longitude;
    });
  }

  // ---------------- FETCH & FILTER CENTER ----------------
  Future<void> get_center(context) async {
    try {
      await getUserLocation(); // get user location first

      final response = await dio.get('$baseurl/api/user/service-center');
      print(response.data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        List allCenters = response.data["data"];

        List nearbyCenters = [];

        for (var center in allCenters) {
          var location = center['location'];
          double centerLat = location['lat'];
          double centerLng = location['lng'];

          double distance = Geolocator.distanceBetween(
            userLat!,
            userLng!,
            centerLat,
            centerLng,
          );

          // Filter only 15 km radius
          if (distance <= 15000) {
            center['distance'] = distance;

            // Add a requestStatus field if not present
            center['requestStatus'] ??= 'none'; // none, pending, accepted, rejected

            nearbyCenters.add(center);
          }
        }

        nearbyCenters.sort((a, b) => a['distance'].compareTo(b['distance']));

        setState(() {
          service = nearbyCenters;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nearby service centers fetched')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch service centers')),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // ---------------- POST REQUEST ----------------
  Future<void> post_req(context, String id, int index) async {
    try {
      final response = await dio.post('$baseurl/api/mechanic/request', data: {
        'mechanicId': mobid,
        'serviceCenterId': id,
      });

      print(response.data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          // Change status to pending
          service[index]['requestStatus'] = 'pending';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request sent successfully')),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Request failed')));
      }
    } catch (e) {
      print("❌ error: $e");
    }
  }

  // ---------------- CHECK REQUEST STATUS ----------------
  // This should be called periodically or on page load to update statuses from API
  Future<void> update_request_status() async {
    try {
      final response = await dio.get('$baseurl/api/mechanic/requests/$mobid');
      if (response.statusCode == 200) {
        List requests = response.data['data'];
        setState(() {
          for (var center in service) {
            final req = requests.firstWhere(
              (r) => r['serviceCenterId'] == center['_id'],
              orElse: () => null,
            );
            if (req != null) {
              center['requestStatus'] = req['status']; // pending, accepted, rejected
            } else {
              center['requestStatus'] = 'none';
            }
          }
        });
      }
    } catch (e) {
      print("Error updating request status: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    get_center(context);

    // Optional: update request status every 10 seconds
    // Timer.periodic(Duration(seconds: 10), (_) => update_request_status());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nearby Service Centers"),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: service.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: service.length,
              itemBuilder: (context, index) {
                final center = service[index];
                final location = center['location'];
                final status = center['requestStatus'] ?? 'none';

                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Card(
                    child: ListTile(
                      title: Text(center['centerName'] ?? "No Name"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Phone: ${center['phone'] ?? 'N/A'}"),
                          Text("Email: ${center['email'] ?? 'N/A'}"),
                          Text(
                            "Location: Lat ${location['lat']}, Lng ${location['lng']}",
                          ),
                          Text(
                            "Distance: ${(center['distance'] / 1000).toStringAsFixed(2)} km",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      trailing: status == 'accepted'
                          ? null
                          : TextButton(
                              onPressed: status == 'pending'
                                  ? null
                                  : () {
                                      post_req(context, center['_id'], index);
                                    },
                              child: Text(
                                status == 'none' || status == 'rejected'
                                    ? 'Request'
                                    : 'Requested',
                                style: TextStyle(
                                  color: status == 'pending'
                                      ? Colors.grey
                                      : Colors.blue,
                                ),
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
