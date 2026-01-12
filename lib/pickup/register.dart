import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

import 'package:mechconnect/user/login.dart';
import 'package:mechconnect/user/register.dart';

class Registerpickup extends StatefulWidget {
  Registerpickup({super.key});

  @override
  State<Registerpickup> createState() => _RegisterpickupState();
}

class _RegisterpickupState extends State<Registerpickup> {
  TextEditingController Name = TextEditingController();
  TextEditingController Contact = TextEditingController();
  TextEditingController Email = TextEditingController();
  TextEditingController Password = TextEditingController();
  TextEditingController ConfirmPassword = TextEditingController();
  TextEditingController vehicle = TextEditingController();
  TextEditingController img = TextEditingController(text: 'Upload permit');

  final formkey = GlobalKey<FormState>();
  bool visible = true;
  bool visible1 = true;
  bool isLoading = false;
  bool isFetchingLocation = false;

  File? image;
  final ImagePicker picker = ImagePicker();

  double? latitude;
  double? longitude;

  /// ------------ PICK IMAGE ----------------
  Future<void> pickimage() async {
    final XFile? pickedfile = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedfile != null) {
      setState(() {
        image = File(pickedfile.path);
        img.text = pickedfile.name;
      });
    }
  }

  /// ------------ GET USER LOCATION ----------------
  Future<void> getLocation() async {
    setState(() {
      isFetchingLocation = true;
    });

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

      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        latitude = pos.latitude;
        longitude = pos.longitude;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Location fetched successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print("Location error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to fetch location"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isFetchingLocation = false;
      });
    }
  }

  /// ------------ POST REGISTER API ----------------
  Future<void> post_reg(context) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      final formData = FormData.fromMap({
        'password': Password.text,
        'name': Name.text,
        'phone': Contact.text,
        'email': Email.text,
        'vehicleNumber': vehicle.text,
        'location': {'lat': latitude.toString(), 'lng': longitude.toString()},
        'img': await MultipartFile.fromFile(
          image!.path,
          filename: image!.path.split('/').last,
        ),
      });

      final response = await dio.post(
        '$baseurl/api/pickup/register',
        data: formData,
      );

      print(response.data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration successful!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("❌ Registration error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// -------------- UI -----------------
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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
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
                                "Join as Pickup Partner",
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
                          "Transport vehicles safely and earn with us",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // Registration Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 25,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Form(
                        key: formkey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Icon
                            Center(
                              child: Container(
                                padding: EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Colors.purple.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.purple.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.directions_car,
                                  size: 40,
                                  color: Colors.purple.shade700,
                                ),
                              ),
                            ),
                            SizedBox(height: 20),

                            // Name Field
                            _buildInputField(
                              controller: Name,
                              label: "Full Name",
                              icon: Icons.person,
                              validator: (value) => value!.isEmpty ? "Enter your name" : null,
                            ),
                            SizedBox(height: 20),

                            // Contact Field
                            _buildInputField(
                              controller: Contact,
                              label: "Phone Number",
                              icon: Icons.phone,
                              validator: (value) => value!.isEmpty ? "Enter contact number" : null,
                              keyboardType: TextInputType.phone,
                            ),
                            SizedBox(height: 20),

                            // Email Field
                            _buildInputField(
                              controller: Email,
                              label: "Email Address",
                              icon: Icons.email,
                              validator: (value) {
                                if (value!.isEmpty) return "Enter your email";
                                if (!value.contains("@") || !value.endsWith("@gmail.com")) {
                                  return "Enter valid Gmail address";
                                }
                                return null;
                              },
                              keyboardType: TextInputType.emailAddress,
                            ),
                            SizedBox(height: 20),

                            // Vehicle Number Field
                            _buildInputField(
                              controller: vehicle,
                              label: "Vehicle Number",
                              icon: Icons.confirmation_number,
                              validator: (value) => value!.isEmpty ? "Enter your vehicle number" : null,
                            ),
                            SizedBox(height: 20),

                            // Password Field
                            _buildPasswordField(
                              controller: Password,
                              label: "Password",
                              visible: visible,
                              onToggle: () {
                                setState(() {
                                  visible = !visible;
                                });
                              },
                              validator: (value) {
                                if (value == null) return "Enter a password";
                                if (value.length < 8) return "Password must be 8 characters";
                                return null;
                              },
                            ),
                            SizedBox(height: 20),

                            // Confirm Password Field
                            _buildPasswordField(
                              controller: ConfirmPassword,
                              label: "Confirm Password",
                              visible: visible1,
                              onToggle: () {
                                setState(() {
                                  visible1 = !visible1;
                                });
                              },
                              validator: (value) {
                                if (value != Password.text) return "Passwords don't match";
                                return null;
                              },
                            ),
                            SizedBox(height: 25),

                            // Permit Upload Section
                            Text(
                              "Upload Driving Permit",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue[900],
                              ),
                            ),
                            SizedBox(height: 10),
                            
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: image != null ? Colors.green : Colors.grey.shade300,
                                  width: 2,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: img,
                                        readOnly: true,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: "Upload your permit",
                                          hintStyle: TextStyle(color: Colors.grey),
                                        ),
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    Container(
                                      height: 40,
                                      width: 120,
                                      child: ElevatedButton(
                                        onPressed: pickimage,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue[900],
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          padding: EdgeInsets.symmetric(horizontal: 15),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.upload,
                                              size: 18,
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: 5),
                                            Text(
                                              "Upload",
                                              style: TextStyle(
                                                fontSize: 14,
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
                            ),
                            
                            if (image != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 18,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "Permit uploaded",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            SizedBox(height: 25),

                            // Location Section
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: latitude != null ? Colors.blue : Colors.grey.shade300,
                                  width: 2,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Location",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blue[900],
                                          ),
                                        ),
                                        Container(
                                          height: 35,
                                          child: ElevatedButton(
                                            onPressed: getLocation,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blue[900],
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              padding: EdgeInsets.symmetric(horizontal: 15),
                                            ),
                                            child: isFetchingLocation
                                                ? SizedBox(
                                                    height: 15,
                                                    width: 15,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Colors.white,
                                                    ),
                                                  )
                                                : Row(
                                                    children: [
                                                      Icon(
                                                        Icons.location_on,
                                                        size: 16,
                                                        color: Colors.white,
                                                      ),
                                                      SizedBox(width: 5),
                                                      Text(
                                                        "Get Location",
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    if (latitude != null && longitude != null)
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.check_circle,
                                                color: Colors.blue,
                                                size: 16,
                                              ),
                                              SizedBox(width: 5),
                                              Text(
                                                "Location captured",
                                                style: TextStyle(
                                                  color: Colors.blue.shade700,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            "Lat: ${latitude!.toStringAsFixed(6)}, Lng: ${longitude!.toStringAsFixed(6)}",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      )
                                    else
                                      Text(
                                        "Tap 'Get Location' to capture your current location",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            
                            SizedBox(height: 35),

                            // Register Button
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () async {
                                        if (formkey.currentState!.validate()) {
                                          if (image == null) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text("Please upload your permit"),
                                                backgroundColor: Colors.orange,
                                              ),
                                            );
                                          } else if (latitude == null || longitude == null) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text("Please fetch your location"),
                                                backgroundColor: Colors.orange,
                                              ),
                                            );
                                          } else {
                                            post_reg(context);
                                          }
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple.shade700,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 5,
                                  shadowColor: Colors.purple.shade300,
                                ),
                                child: isLoading
                                    ? SizedBox(
                                        height: 25,
                                        width: 25,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.directions_car,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            "JOIN AS PICKUP PARTNER",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              letterSpacing: 1.1,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                            
                            SizedBox(height: 25),

                            // Divider
                            Row(
                              children: [
                                Expanded(child: Divider(color: Colors.grey.shade300)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 15),
                                  child: Text(
                                    "Already have account?",
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ),
                                Expanded(child: Divider(color: Colors.grey.shade300)),
                              ],
                            ),
                            
                            SizedBox(height: 25),

                            // Login Button
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => Login()),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.blue.shade700, width: 2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  backgroundColor: Colors.white,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.login, color: Colors.blue.shade700),
                                    SizedBox(width: 10),
                                    Text(
                                      "SIGN IN INSTEAD",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            SizedBox(height: 20),

                            // Terms & Privacy
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                "By registering, you agree to our Terms of Service and Privacy Policy",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 30),

                  // Footer Note
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Earn competitive rates for transporting vehicles safely to service centers",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper Widgets
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            border: InputBorder.none,
            labelText: label,
            labelStyle: TextStyle(color: Colors.blue[900]),
            prefixIcon: Icon(icon, color: Colors.blue),
          ),
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool visible,
    required VoidCallback onToggle,
    required String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: TextFormField(
          controller: controller,
          obscureText: visible,
          validator: validator,
          decoration: InputDecoration(
            border: InputBorder.none,
            labelText: label,
            labelStyle: TextStyle(color: Colors.blue[900]),
            prefixIcon: Icon(Icons.lock, color: Colors.blue),
            suffixIcon: IconButton(
              onPressed: onToggle,
              icon: Icon(
                visible ? Icons.visibility_off : Icons.visibility,
                color: Colors.blue,
              ),
            ),
          ),
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}