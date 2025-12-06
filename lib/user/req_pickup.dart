import 'package:flutter/material.dart';
import 'package:mechconnect/user/home.dart';
import 'package:mechconnect/user/register.dart'; // dio, baseurl

class RequestPickupPage extends StatefulWidget {
  final String partnerId; // pickup partner _id
  final double userLat;
  final double userLng;

  const RequestPickupPage({
    super.key,
    required this.partnerId,
    required this.userLat,
    required this.userLng,
  });

  @override
  State<RequestPickupPage> createState() => _RequestPickupPageState();
}

class _RequestPickupPageState extends State<RequestPickupPage> {
  TextEditingController destinationCtrl = TextEditingController();
  String? vehicleType;

  List<String> vehicleOptions = [
    "Two Wheeler",
    "Four Wheeler",
    "Heavy Vehicle",
  ];

  bool isSubmitting = false; // optional loading state

  Future<void> submitRequest() async {
    if (destinationCtrl.text.isEmpty || vehicleType == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Please fill all fields")));
      return;
    }

    try {
      setState(() => isSubmitting = true);

      final response = await dio.post(
        '$baseurl/api/user/pickupbook',
        data: {
          'userId': obid, // assuming `obid` is defined in register.dart
          "pickupAgentId": widget.partnerId,
          'userLocation': {"lat": widget.userLat, "lng": widget.userLng},
          "dropLocation": destinationCtrl.text,
          "vehicletype": vehicleType,
        },
      );

      setState(() => isSubmitting = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Request Sent Successfully!")));

        Navigator.pop(context, true); // <-- return true to parent
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to send request")));
      }
    } catch (e) {
      setState(() => isSubmitting = false);
      print(e);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pickup Request"),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            // Destination Field
            TextFormField(
              controller: destinationCtrl,
              decoration: InputDecoration(
                labelText: "Destination",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),

            // Vehicle Type Dropdown
            DropdownButtonFormField(
              value: vehicleType,
              decoration: InputDecoration(
                labelText: "Vehicle Type",
                border: OutlineInputBorder(),
              ),
              items: vehicleOptions
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => vehicleType = v),
            ),
            SizedBox(height: 30),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : submitRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent,
                ),
                child: isSubmitting
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        "Submit Request",
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
