import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mechconnect/user/register.dart';
import 'package:mechconnect/user/req_pickup.dart'; // for dio, baseurl

class Pickup extends StatefulWidget {
  Pickup({super.key});

  @override
  State<Pickup> createState() => _PickupState();
}

class _PickupState extends State<Pickup> {
  List<dynamic> pickups = [];
  bool isLoading = true;

  double? userLat;
  double? userLng;

  // Track requested pickups
  Set<String> requestedPartners = {};

  // Get user location
  Future<void> getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position position = await Geolocator.getCurrentPosition();
    userLat = position.latitude;
    userLng = position.longitude;
  }

  // Fetch pickups
  Future<void> get_pickup(context) async {
    try {
      await getUserLocation(); // Ensure location is available

      final response = await dio.get('$baseurl/api/user/pickups');
      print(response.data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        List<dynamic> pickupList = response.data["data"];

        // Compute distances
        for (var p in pickupList) {
          double pickupLat = p["location"]["lat"];
          double pickupLng = p["location"]["lng"];

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
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed')));
      }
    } catch (e) {
      print(e);
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
    }
  }

  @override
  void initState() {
    super.initState();
    get_pickup(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pickup details",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : pickups.isEmpty
          ? const Center(child: Text("No Pickup Partners Found"))
          : ListView.builder(
              itemCount: pickups.length,
              itemBuilder: (context, index) {
                final p = pickups[index];
                final isRequested = requestedPartners.contains(p["_id"]);

                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Card(
                    color: const Color.fromARGB(97, 196, 208, 215),
                    child: ListTile(
                      title: Text(
                        p["name"],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Phone: ${p['phone']}"),
                          Text("Email: ${p['email']}"),
                          Text("Vehicle No: ${p['vehicleNumber']}"),
                          Text(
                            p["distance"] == null
                                ? "Distance: calculating..."
                                : "Distance: ${(p["distance"]! / 1000).toStringAsFixed(2)} km",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      trailing: TextButton(
                        onPressed: isRequested
                            ? null
                            : () => handleRequest(p["_id"]),
                        style: TextButton.styleFrom(
                          backgroundColor: isRequested
                              ? Colors.grey
                              : Colors.white,
                        ),
                        child: Text(
                          isRequested ? "Requested" : "Request",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isRequested
                                ? Colors.white
                                : const Color.fromARGB(255, 3, 31, 55),
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
