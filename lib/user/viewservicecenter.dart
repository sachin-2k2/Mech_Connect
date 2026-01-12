import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'package:mechconnect/user/register.dart';
import 'package:mechconnect/user/report.dart';

class Viewservicecenter extends StatefulWidget {
  const Viewservicecenter({super.key});

  @override
  State<Viewservicecenter> createState() => _ViewservicecenterState();
}

class _ViewservicecenterState extends State<Viewservicecenter> {
  List service = [];
  bool isLoading = true;
  bool isLocationLoading = true;

  double? userLat;
  double? userLng;

  final double maxDistance = 15000; // 15 km radius
  final double minRating = 0; // Minimum rating filter

  // ---------------- USER LOCATION ----------------
  Future<void> getUserLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        throw 'Location service is disabled';
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permission denied';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions permanently denied';
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        userLat = position.latitude;
        userLng = position.longitude;
        isLocationLoading = false;
      });
    } catch (e) {
      print("Location error: $e");
      setState(() {
        isLocationLoading = false;
      });
      // You might want to show a snackbar or handle this error
    }
  }

  // ---------------- FETCH & FILTER CENTER ----------------
  Future<void> get_center(context) async {
    setState(() {
      isLoading = true;
    });

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

          // Get average rating safely
          double averageRating = 0;
          if (center['rating'] != null && center['rating']['average'] != null) {
            averageRating = center['rating']['average'].toDouble();
          }

          // Filter by distance AND rating
          if (distance <= maxDistance && averageRating >= minRating) {
            center['distance'] = distance;
            nearbyCenters.add(center);
          }
        }

        // Sort by distance
        nearbyCenters.sort((a, b) => a['distance'].compareTo(b['distance']));

        setState(() {
          service = nearbyCenters;
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Found ${nearbyCenters.length} service centers nearby'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to fetch service centers'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    get_center(context);
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
              Colors.blue.shade900,
              Colors.blue.shade700,
              Colors.blue.shade400,
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
                          child: Text(
                            "Nearby Service Centers",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Find trusted service centers near you",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    if (userLat != null && userLng != null)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          "Your location: ${userLat!.toStringAsFixed(5)}, ${userLng!.toStringAsFixed(5)}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
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
                                color: Colors.blue.shade700,
                              ),
                              SizedBox(height: 20),
                              Text(
                                "Finding service centers near you...",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              SizedBox(height: 10),
                              if (isLocationLoading)
                                Text(
                                  "Fetching your location...",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade500,
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
                                    Icons.business_outlined,
                                    size: 80,
                                    color: Colors.grey.shade300,
                                  ),
                                  SizedBox(height: 20),
                                  Text(
                                    "No Service Centers Found",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "Try expanding your search radius",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                  SizedBox(height: 30),
                                  ElevatedButton(
                                    onPressed: () => get_center(context),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue.shade700,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 30,
                                        vertical: 15,
                                      ),
                                    ),
                                    child: Text(
                                      "Refresh",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
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
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: Colors.blue.shade100,
                                        width: 2,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.business,
                                              color: Colors.blue.shade700,
                                              size: 20,
                                            ),
                                            SizedBox(width: 10),
                                            Text(
                                              "${service.length} Centers Nearby",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.blue.shade900,
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
                                          child: Text(
                                            "Within ${(maxDistance / 1000).toStringAsFixed(0)} km",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.green.shade700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 20),

                                  // Service Centers List
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: service.length,
                                      itemBuilder: (context, index) {
                                        final center = service[index];
                                        final location = center['location'];
                                        double distanceKm =
                                            (center['distance'] / 1000);

                                        // Display rating safely
                                        double averageRating = 0;
                                        int ratingCount = 0;
                                        if (center['rating'] != null) {
                                          averageRating = center['rating']
                                                      ['average'] !=
                                                  null
                                              ? center['rating']['average']
                                                  .toDouble()
                                              : 0;
                                          ratingCount = center['rating']
                                                      ['count'] !=
                                                  null
                                              ? center['rating']['count']
                                              : 0;
                                        }

                                        return Container(
                                          margin: EdgeInsets.only(bottom: 15),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.08),
                                                blurRadius: 15,
                                                spreadRadius: 2,
                                              ),
                                            ],
                                          ),
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => Report(
                                                    sid: center['_id'],
                                                    latitude: userLat,
                                                    longitude: userLng,
                                                    serviceid: center['_id'],
                                                  ),
                                                ),
                                              );
                                            },
                                            borderRadius: BorderRadius.circular(20),
                                            child: Padding(
                                              padding: const EdgeInsets.all(20),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // Center Name and Rating
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              center['centerName'] ??
                                                                  "No Name",
                                                              style: TextStyle(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight.bold,
                                                                color: Colors
                                                                    .blue.shade900,
                                                              ),
                                                            ),
                                                            SizedBox(height: 5),
                                                            if (center['ownerName'] !=
                                                                null)
                                                              Text(
                                                                "Owner: ${center['ownerName']}",
                                                                style: TextStyle(
                                                                  fontSize: 13,
                                                                  color: Colors
                                                                      .grey.shade600,
                                                                ),
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                      // Rating Badge
                                                      Container(
                                                        padding: EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 8),
                                                        decoration: BoxDecoration(
                                                          color: averageRating >= 4
                                                              ? Colors.green.shade50
                                                              : averageRating >= 3
                                                                  ? Colors
                                                                      .orange.shade50
                                                                  : Colors.red.shade50,
                                                          borderRadius:
                                                              BorderRadius.circular(10),
                                                          border: Border.all(
                                                            color: averageRating >= 4
                                                                ? Colors.green.shade100
                                                                : averageRating >= 3
                                                                    ? Colors
                                                                        .orange
                                                                        .shade100
                                                                    : Colors
                                                                        .red.shade100,
                                                            width: 1,
                                                          ),
                                                        ),
                                                        child: Column(
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Icon(
                                                                  Icons.star,
                                                                  size: 16,
                                                                  color: Colors
                                                                      .orange.shade700,
                                                                ),
                                                                SizedBox(width: 4),
                                                                Text(
                                                                  averageRating
                                                                      .toStringAsFixed(
                                                                          1),
                                                                  style: TextStyle(
                                                                    fontSize: 16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .blue.shade900,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(height: 2),
                                                            Text(
                                                              "$ratingCount review${ratingCount != 1 ? 's' : ''}",
                                                              style: TextStyle(
                                                                fontSize: 10,
                                                                color:
                                                                    Colors.grey.shade600,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 15),

                                                  // Contact Info
                                                  _buildInfoRow(
                                                    icon: Icons.phone,
                                                    text:
                                                        center['phone'] ?? 'Not Available',
                                                  ),
                                                  _buildInfoRow(
                                                    icon: Icons.email,
                                                    text:
                                                        center['email'] ?? 'Not Available',
                                                  ),
                                                  SizedBox(height: 15),

                                                  // Distance and Location
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Container(
                                                          padding: EdgeInsets.all(10),
                                                          decoration: BoxDecoration(
                                                            color: Colors.blue.shade50,
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                    10),
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                Icons.location_on,
                                                                size: 16,
                                                                color:
                                                                    Colors.blue.shade700,
                                                              ),
                                                              SizedBox(width: 8),
                                                              Expanded(
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      "Distance",
                                                                      style: TextStyle(
                                                                        fontSize: 12,
                                                                        color: Colors
                                                                            .grey
                                                                            .shade600,
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      "${distanceKm.toStringAsFixed(1)} km away",
                                                                      style: TextStyle(
                                                                        fontSize: 14,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w600,
                                                                        color: Colors
                                                                            .green
                                                                            .shade700,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 10),
                                                      Expanded(
                                                        child: Container(
                                                          padding: EdgeInsets.all(10),
                                                          decoration: BoxDecoration(
                                                            color: Colors.grey.shade50,
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                    10),
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                Icons.pin_drop,
                                                                size: 16,
                                                                color: Colors
                                                                    .grey.shade600,
                                                              ),
                                                              SizedBox(width: 8),
                                                              Expanded(
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      "Coordinates",
                                                                      style: TextStyle(
                                                                        fontSize: 12,
                                                                        color: Colors
                                                                            .grey
                                                                            .shade600,
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      "${location['lat'].toStringAsFixed(5)}, ${location['lng'].toStringAsFixed(5)}",
                                                                      style: TextStyle(
                                                                        fontSize: 11,
                                                                        color: Colors
                                                                            .grey
                                                                            .shade700,
                                                                      ),
                                                                      maxLines: 1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 15),

                                                  // View Details Button
                                                  Container(
                                                    width: double.infinity,
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                Report(
                                                              sid: center['_id'],
                                                              latitude: userLat,
                                                              longitude: userLng,
                                                              serviceid: center['_id'],
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.blue.shade700,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(12),
                                                        ),
                                                        padding: EdgeInsets.symmetric(
                                                            vertical: 12),
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment.center,
                                                        children: [
                                                          Text(
                                                            "Book Service",
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight.w600,
                                                              color: Colors.white,
                                                            ),
                                                          ),
                                                          SizedBox(width: 10),
                                                          Icon(
                                                            Icons.arrow_forward,
                                                            size: 20,
                                                            color: Colors.white,
                                                          ),
                                                        ],
                                                      ),
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
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.grey.shade600,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}