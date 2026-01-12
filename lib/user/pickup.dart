import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mechconnect/user/register.dart';
import 'package:mechconnect/user/req_pickup.dart';

class Pickup extends StatefulWidget {
  Pickup({super.key});

  @override
  State<Pickup> createState() => _PickupState();
}

class _PickupState extends State<Pickup> {
  List<dynamic> pickups = [];
  bool isLoading = true;
  bool isLocationLoading = true;

  double? userLat;
  double? userLng;

  // Track requested pickups
  Set<String> requestedPartners = {};

  // Get user location
  Future<void> getUserLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Location permission denied"),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      setState(() {
        userLat = position.latitude;
        userLng = position.longitude;
        isLocationLoading = false;
      });
    } catch (e) {
      print("Location error: $e");
      setState(() => isLocationLoading = false);
    }
  }

  // Fetch pickups
  Future<void> get_pickup() async {
    setState(() {
      isLoading = true;
    });

    try {
      await getUserLocation(); // Ensure location is available

      final response = await dio.get('$baseurl/api/user/pickups');
      print(response.data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        List<dynamic> pickupList = response.data["data"] ?? [];

        // Compute distances
        for (var p in pickupList) {
          double pickupLat = p["location"]["lat"]?.toDouble() ?? 0.0;
          double pickupLng = p["location"]["lng"]?.toDouble() ?? 0.0;

          double distance = 0;

          if (userLat != null && userLng != null) {
            distance = Geolocator.distanceBetween(
              userLat!,
              userLng!,
              pickupLat,
              pickupLng,
            );
          }

          p["distance"] = distance;
        }

        // Sort by nearest
        pickupList.sort((a, b) => a["distance"].compareTo(b["distance"]));

        setState(() {
          pickups = pickupList;
          isLoading = false;
        });

        if (pickupList.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Found ${pickupList.length} pickup partners nearby"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to fetch pickup partners'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print(e);
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Navigate and handle request
  Future<void> handleRequest(String partnerId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RequestPickupPage(
          partnerId: partnerId,
          userLat: userLat ?? 0.0,
          userLng: userLng ?? 0.0,
        ),
      ),
    );

    // If request was successful, mark as requested
    if (result == true) {
      setState(() {
        requestedPartners.add(partnerId);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✅ Pickup request sent successfully!"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    get_pickup();
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
                            "Vehicle Pickup",
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
                      "Find nearby pickup partners for your vehicle",
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
                                "Finding pickup partners near you...",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              if (isLocationLoading)
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    "Fetching your location...",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        )
                      : pickups.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.directions_car_outlined,
                                    size: 80,
                                    color: Colors.grey.shade300,
                                  ),
                                  SizedBox(height: 20),
                                  Text(
                                    "No Pickup Partners Found",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "Try again later or expand search area",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                  SizedBox(height: 30),
                                  ElevatedButton(
                                    onPressed: get_pickup,
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
                                              Icons.car_rental,
                                              color: Colors.blue.shade700,
                                              size: 20,
                                            ),
                                            SizedBox(width: 10),
                                            Text(
                                              "${pickups.length} Pickup Partners",
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
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.location_on,
                                                size: 14,
                                                color: Colors.green.shade700,
                                              ),
                                              SizedBox(width: 5),
                                              Text(
                                                "Nearest first",
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

                                  // Pickup Partners List
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: pickups.length,
                                      itemBuilder: (context, index) {
                                        final p = pickups[index];
                                        final isRequested = requestedPartners.contains(p["_id"]);
                                        double distanceKm = (p["distance"] ?? 0) / 1000;

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
                                          child: Padding(
                                            padding: const EdgeInsets.all(20),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                // Name and Status
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        p["name"] ?? "Unknown",
                                                        style: TextStyle(
                                                          fontSize: 20,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.blue.shade900,
                                                        ),
                                                      ),
                                                    ),
                                                    if (isRequested)
                                                      Container(
                                                        padding: EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                          vertical: 6,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          color: Colors.green.shade50,
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              Icons.check_circle,
                                                              size: 14,
                                                              color: Colors.green.shade700,
                                                            ),
                                                            SizedBox(width: 5),
                                                            Text(
                                                              "Requested",
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
                                                SizedBox(height: 15),

                                                // Contact Info
                                                _buildInfoRow(
                                                  icon: Icons.phone,
                                                  text: p["phone"] ?? "Not Available",
                                                ),
                                                _buildInfoRow(
                                                  icon: Icons.email,
                                                  text: p["email"] ?? "Not Available",
                                                ),
                                                _buildInfoRow(
                                                  icon: Icons.confirmation_number,
                                                  text: "Vehicle: ${p["vehicleNumber"] ?? "N/A"}",
                                                ),
                                                SizedBox(height: 15),

                                                // Distance Card
                                                Container(
                                                  padding: EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue.shade50,
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.location_on,
                                                        size: 20,
                                                        color: Colors.blue.shade700,
                                                      ),
                                                      SizedBox(width: 10),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              "Distance",
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color: Colors.grey.shade600,
                                                              ),
                                                            ),
                                                            Text(
                                                              distanceKm > 0
                                                                  ? "${distanceKm.toStringAsFixed(1)} km away"
                                                                  : "Distance calculating...",
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight: FontWeight.w600,
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

                                                // Request Button
                                                SizedBox(
                                                  width: double.infinity,
                                                  height: 45,
                                                  child: ElevatedButton(
                                                    onPressed: isRequested
                                                        ? null
                                                        : () => handleRequest(p["_id"]),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: isRequested
                                                          ? Colors.grey
                                                          : Colors.blue.shade700,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      elevation: isRequested ? 0 : 3,
                                                    ),
                                                    child: isRequested
                                                        ? Row(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Icon(
                                                                Icons.check_circle,
                                                                size: 18,
                                                                color: Colors.white,
                                                              ),
                                                              SizedBox(width: 10),
                                                              Text(
                                                                "REQUEST SENT",
                                                                style: TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight: FontWeight.w600,
                                                                  color: Colors.white,
                                                                ),
                                                              ),
                                                            ],
                                                          )
                                                        : Row(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Icon(
                                                                Icons.directions_car,
                                                                size: 18,
                                                                color: Colors.white,
                                                              ),
                                                              SizedBox(width: 10),
                                                              Text(
                                                                "REQUEST PICKUP",
                                                                style: TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight: FontWeight.w600,
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