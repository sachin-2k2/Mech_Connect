import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mechconnect/user/complaint.dart';
import 'package:mechconnect/user/feedback.dart';
import 'package:mechconnect/user/register.dart';

class Report extends StatefulWidget {
  String? sid;
  double? latitude;
  double? longitude;
  Report({super.key, required this.sid, required this.latitude, required this.longitude});

  @override
  State<Report> createState() => _ReportState();
}

class _ReportState extends State<Report> {
  TextEditingController report = TextEditingController();
  final formkey = GlobalKey<FormState>();
  File? image;
  final ImagePicker picker = ImagePicker();

  String? selectedVehicle;

  // Sample vehicles list
  List<String> vehicles = [
    "Honda City - KA01AB1234",
    "Toyota Corolla - KA02CD5678",
    "Suzuki Swift - KA03EF9012",
  ];

  Future<void> pickimage() async {
    final XFile? pickedfile = await picker.pickImage(
      source: ImageSource.camera,
    );
    if (pickedfile != null) {
      setState(() {
        image = File(pickedfile.path);
      });
    }
  }

  Future<void> post_com(context) async {
    try {
      final formData = FormData.fromMap({
        'type': 'servicecenter',
        'problemDiscription': report.text,
        'serviceCenterId': widget.sid,
        // 'userId': obid,
        'vehicle': selectedVehicle, // Added selected vehicle
        'userLocation': {
          'lat': widget.latitude.toString(),
          'lng': widget.longitude.toString(),
        },
        'img': image != null
            ? await MultipartFile.fromFile(
                image!.path,
                filename: image!.path.split('/').last,
              )
            : null,
      });

      final response = await dio.post(
        '$baseurl/api/booking/create',
        data: formData,
      );

      print(response.data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          report.clear();
          image = null;
          selectedVehicle = null;
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Registration failed')));
      }
    } catch (e) {
      print("❌ Registration error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Report"),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: formkey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Pick Image
                InkWell(
                  onTap: pickimage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: image != null ? FileImage(image!) : null,
                    child: image == null ? Icon(Icons.camera) : null,
                  ),
                ),
                SizedBox(height: 20),

                // Vehicle Dropdown
                DropdownButtonFormField<String>(
                  value: selectedVehicle,
                  decoration: InputDecoration(
                    labelText: "Select Vehicle",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items: vehicles
                      .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedVehicle = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please select a vehicle";
                    }
                  },
                ),
                SizedBox(height: 20),

                // Problem Description
                TextFormField(
                  controller: report,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter your details";
                    }
                  },
                  maxLines: 10,
                  decoration: InputDecoration(
                    hintText: "Enter your issues",
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Send Button
                ElevatedButton(
                  onPressed: () {
                    if (formkey.currentState!.validate()) {
                      post_com(context);
                    }
                  },
                  child: Text(
                    "Send",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Complaint Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Complaint()),
                    );
                  },
                  child: Text(
                    "Complaint",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Feedback Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Feedbackpage()),
                    );
                  },
                  child: Text(
                    "Feedback",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
