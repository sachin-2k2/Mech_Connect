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
  bool isLoading = true;
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
      setState(() {
        isLoading = true;
      });
      
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
          isLoading = false;
        });

        _showSnackBar('Found ${nearbyCenters.length} nearby service centers');
      } else {
        setState(() {
          isLoading = false;
        });
        _showSnackBar('Failed to fetch service centers');
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
      _showSnackBar('Error: $e');
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

        _showSnackBar('Request sent successfully!');
      } else {
        _showSnackBar('Request failed');
      }
    } catch (e) {
      print("❌ error: $e");
      _showSnackBar('Error sending request');
    }
  }

  // ---------------- CHECK REQUEST STATUS ----------------
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
    switch (status) {
      case 'accepted':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      case 'none':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'accepted':
        return 'Accepted';
      case 'pending':
        return 'Requested';
      case 'rejected':
        return 'Rejected';
      case 'none':
        return 'Request to Join';
      default:
        return 'Request';
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'accepted':
        return Icons.check_circle;
      case 'pending':
        return Icons.hourglass_empty;
      case 'rejected':
        return Icons.cancel;
      case 'none':
        return Icons.send;
      default:
        return Icons.info;
    }
  }

  Widget _buildDistanceChip(double distanceInMeters) {
    final distanceKm = distanceInMeters / 1000;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: distanceKm <= 5 
            ? Colors.green.shade50 
            : distanceKm <= 10 
                ? Colors.orange.shade50 
                : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: distanceKm <= 5 
              ? Colors.green.shade200 
              : distanceKm <= 10 
                  ? Colors.orange.shade200 
                  : Colors.red.shade200,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_on,
            size: 14,
            color: distanceKm <= 5 
                ? Colors.green 
                : distanceKm <= 10 
                    ? Colors.orange 
                    : Colors.red,
          ),
          SizedBox(width: 4),
          Text(
            '${distanceKm.toStringAsFixed(1)} km',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: distanceKm <= 5 
                  ? Colors.green 
                  : distanceKm <= 10 
                      ? Colors.orange 
                      : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    get_center(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Nearby Service Centers",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.lightBlueAccent,
        centerTitle: true,
        elevation: 2,
      ),
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
                    "Finding nearby service centers...",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : service.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_off,
                        size: 80,
                        color: Colors.grey.shade300,
                      ),
                      SizedBox(height: 16),
                      Text(
                        "No Service Centers Nearby",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "No service centers found within 15km radius",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => get_center(context),
                        icon: Icon(Icons.refresh, size: 20),
                        label: Text("Search Again"),
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
                  onRefresh: () => get_center(context),
                  color: Colors.lightBlueAccent,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: service.length,
                    itemBuilder: (context, index) {
                      final center = service[index];
                      final location = center['location'];
                      final status = center['requestStatus'] ?? 'none';
                      final distance = center['distance'] ?? 0.0;
                      final centerName = center['centerName'] ?? "No Name";
                      final phone = center['phone'] ?? 'N/A';
                      final email = center['email'] ?? 'N/A';

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
                                // Header with name and distance
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        centerName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 17,
                                          color: Colors.grey.shade800,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    _buildDistanceChip(distance),
                                  ],
                                ),

                                SizedBox(height: 12),

                                // Contact Information
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
                                            Icons.phone,
                                            size: 16,
                                            color: Colors.grey.shade600,
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              phone,
                                              style: TextStyle(
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.email,
                                            size: 16,
                                            color: Colors.grey.shade600,
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              email,
                                              style: TextStyle(
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 12),

                                // Location Coordinates
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
                                              "Location Coordinates",
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.blue.shade700,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              "Lat: ${location['lat'].toStringAsFixed(4)}, Lng: ${location['lng'].toStringAsFixed(4)}",
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

                                // Request Button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: status == 'pending' || status == 'accepted'
                                        ? null
                                        : () {
                                            post_req(context, center['_id'], index);
                                          },
                                    icon: Icon(
                                      _getStatusIcon(status),
                                      size: 20,
                                    ),
                                    label: Text(_getStatusText(status)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: status == 'accepted'
                                          ? Colors.green.shade50
                                          : status == 'pending'
                                              ? Colors.orange.shade50
                                              : status == 'rejected'
                                                  ? Colors.red.shade50
                                                  : Colors.lightBlueAccent,
                                      foregroundColor: status == 'accepted'
                                          ? Colors.green
                                          : status == 'pending'
                                              ? Colors.orange
                                              : status == 'rejected'
                                                  ? Colors.red
                                                  : Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(
                                          color: status == 'accepted'
                                              ? Colors.green.shade200
                                              : status == 'pending'
                                                  ? Colors.orange.shade200
                                                  : status == 'rejected'
                                                      ? Colors.red.shade200
                                                      : Colors.transparent,
                                        ),
                                      ),
                                      padding: EdgeInsets.symmetric(vertical: 14),
                                      disabledBackgroundColor: Colors.grey.shade100,
                                      disabledForegroundColor: Colors.grey.shade400,
                                    ),
                                  ),
                                ),

                                // Additional status message
                                if (status == 'accepted')
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      "✓ You are part of this service center",
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
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