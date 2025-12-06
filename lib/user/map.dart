import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MechanicTrackingScreen extends StatefulWidget {
  final String mechanicName;
  final String mechanicPhone;

  const MechanicTrackingScreen({
    super.key,
    required this.mechanicName,
    required this.mechanicPhone,
  });

  @override
  State<MechanicTrackingScreen> createState() => _MechanicTrackingScreenState();
}

class _MechanicTrackingScreenState extends State<MechanicTrackingScreen> {
  Completer<GoogleMapController> _controller = Completer();

  // Example positions (replace with real-time data)
  LatLng customerLocation = LatLng(37.4219983, -122.084); // Example GPS
  LatLng mechanicLocation = LatLng(37.427961, -122.085749); // Example GPS

  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    _initMarkers();
  }

  void _initMarkers() {
    markers = {
      Marker(
        markerId: const MarkerId("customer"),
        position: customerLocation,
        infoWindow: const InfoWindow(title: "Your Location"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
      Marker(
        markerId: const MarkerId("mechanic"),
        position: mechanicLocation,
        infoWindow: InfoWindow(title: widget.mechanicName),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };
  }

  // This function will be triggered whenever you receive new mechanic coordinates
  void updateMechanicLocation(LatLng newPosition) async {
    setState(() {
      mechanicLocation = newPosition;
      _initMarkers();
    });

    final controller = await _controller.future;

    controller.animateCamera(CameraUpdate.newLatLng(newPosition));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: customerLocation,
              zoom: 14,
            ),
            markers: markers,
            onMapCreated: (controller) => _controller.complete(controller),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
          ),

          // ===== BOTTOM STATUS CARD =====
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(blurRadius: 10, color: Colors.black26),
                ],
                borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Mechanic is on the way",
                    style: TextStyle(
                      fontSize: 20, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.redAccent,
                        child: Text(
                          widget.mechanicName[0],
                          style: const TextStyle(
                              color: Colors.white, fontSize: 22),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.mechanicName,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          const Text("Arriving in ~12 min"),
                        ],
                      ),
                      const Spacer(),

                      // Call button
                      IconButton(
                        icon: const Icon(Icons.phone, color: Colors.green),
                        onPressed: () {
                          // Implement phone launch
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
