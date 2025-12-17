import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mechconnect/user/register.dart';
import 'package:mechconnect/user/report.dart';

class Viewservicecenter extends StatefulWidget {
  const Viewservicecenter({super.key});

  @override
  State<Viewservicecenter> createState() => _ViewservicecenterState();
}

class _ViewservicecenterState extends State<Viewservicecenter> {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
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

                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              Report(sid: service[index]['_id'],latitude: userLat,longitude: userLng,serviceid: service[index]['_id'],),
                        ),
                      );
                    },
                    child: Card(
                      child: ListTile(
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 20,
                        ),
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
                                  color: Colors.green),
                            ),
                          ],
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
