import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mechconnect/user/complaint.dart';
import 'package:mechconnect/user/feedback.dart';
import 'package:mechconnect/user/home.dart';
import 'package:mechconnect/user/register.dart';

class Report extends StatefulWidget {
  final String? sid;
  final double? latitude;
  final double? longitude;
  final String serviceid;

  Report({
    super.key,
    required this.sid,
    required this.latitude,
    required this.longitude,
    required this.serviceid,
  });

  @override
  State<Report> createState() => _ReportState();
}

class _ReportState extends State<Report> {
  TextEditingController reportController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  File? image;
  final ImagePicker picker = ImagePicker();

  List<Map<String, dynamic>> vehicles = []; // Store vehicle objects
  String? selectedVehicleId; // Store selected vehicle _id

  // Pick image using camera
  Future<void> pickImage() async {
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.camera,
    );
    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
      });
    }
  }

  // Fetch vehicles from API
  Future<void> getVehicles(BuildContext context) async {
    try {
      final response = await dio.get('$baseurl/api/vehicle/$obid');

      print(response.data);

      if (response.statusCode == 200) {
        setState(() {
          vehicles = List<Map<String, dynamic>>.from(response.data["data"] ?? []);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to fetch vehicles")),
        );
      }
    } catch (e) {
      print("❌ Error fetching vehicles: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  // Post complaint/report
  Future<void> postComplaint(BuildContext context) async {
    try {
      final formData = FormData.fromMap({
        'type': 'servicecenter',
        'userId':obid,
        'problemDiscription': reportController.text,
        'serviceCenterId': widget.sid,
        'vehicleId': selectedVehicleId, // send vehicle _id
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
          reportController.clear();
          image = null;
          selectedVehicleId = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Report submitted successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submission failed')),
        );
      }
    } catch (e) {
      print("❌ Submission error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error submitting report")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    getVehicles(context);
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
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Pick Image
                InkWell(
                  onTap: pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: image != null ? FileImage(image!) : null,
                    child: image == null ? Icon(Icons.camera_alt) : null,
                  ),
                ),
                SizedBox(height: 20),

                // Vehicle Dropdown
                DropdownButtonFormField<String>(
                  value: selectedVehicleId,
                  decoration: InputDecoration(
                    labelText: "Select Vehicle",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items: vehicles.map((vehicle) {
                    String displayName =
                        "${vehicle['brand']} ${vehicle['model']} - ${vehicle['vehicleNumber']}";
                    return DropdownMenuItem<String>(
                      value: vehicle['_id'], // cast to String
                      child: Text(displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedVehicleId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please select a vehicle";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // Problem Description
                TextFormField(
                  controller: reportController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter your details";
                    }
                    return null;
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
                    if (formKey.currentState!.validate()) {
                      postComplaint(context);
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
                      MaterialPageRoute(
                        builder: (context) =>
                            Complaint(serviceid: widget.serviceid),
                      ),
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
                      MaterialPageRoute(
                        builder: (context) =>
                            Feedbackpage(serviceid: widget.serviceid),
                      ),
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
