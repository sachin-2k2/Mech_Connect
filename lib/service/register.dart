import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mechconnect/user/login.dart';
import 'package:mechconnect/user/register.dart';

class Registerservice extends StatefulWidget {
  Registerservice({super.key});

  @override
  State<Registerservice> createState() => _RegisterserviceState();
}

class _RegisterserviceState extends State<Registerservice> {
  final TextEditingController Name = TextEditingController();
  final TextEditingController Contact = TextEditingController();
  final TextEditingController Email = TextEditingController();
  final TextEditingController Password = TextEditingController();
  final TextEditingController ConfirmPassword = TextEditingController();
  final TextEditingController img = TextEditingController(
    text: "Upload your certificate",
  );

  final formKey = GlobalKey<FormState>();

  bool visible = true;
  bool visible1 = true;
  bool isLoading = false;
  bool isFetchingLocation = false;

  File? image;
  final ImagePicker picker = ImagePicker();

  double? userLat;
  double? userLong;

  // ----------------------- PICK IMAGE -----------------------
  Future<void> pickImage() async {
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
        img.text = pickedFile.name;
      });
    }
  }

  // ----------------------- GET LOCATION -----------------------
  Future<void> getCurrentLocation() async {
    setState(() {
      isFetchingLocation = true;
    });

    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return Future.error("Location services are OFF");
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
          return Future.error("Location permissions denied");
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Location permissions permanently denied"),
            backgroundColor: Colors.red,
          ),
        );
        return Future.error("Location permissions permanently denied");
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        userLat = position.latitude;
        userLong = position.longitude;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Location captured successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      print("📍 Latitude: $userLat, Longitude: $userLong");
    } catch (e) {
      print("❌ Location error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to fetch location: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isFetchingLocation = false;
      });
    }
  }

  // ----------------------- API REQUEST -----------------------
  Future<void> postReg(context) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      final formData = FormData.fromMap({
        'password': Password.text,
        'centerName': Name.text,
        'phone': Contact.text,
        'email': Email.text,
        'location': {'lat': userLat.toString(), 'lng': userLong.toString()},
        'img': await MultipartFile.fromFile(
          image!.path,
          filename: image!.path.split('/').last,
        ),
      });

      final response = await dio.post(
        "$baseurl/api/service-center/register",
        data: formData,
      );

      print(response.data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Registration Successful!"),
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
            content: Text("Registration Failed. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("❌ Error: $e");
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

  // ----------------------- INIT -----------------------
  @override
  void initState() {
    super.initState();
    getCurrentLocation(); // Fetches location automatically
  }

  // ----------------------- WIDGET UI -----------------------
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
                  // Header Section
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
                                "Register Service Center",
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
                          "Join our network of trusted service centers",
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
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Icon
                            Center(
                              child: Container(
                                padding: EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.orange.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.business,
                                  size: 40,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ),
                            SizedBox(height: 20),

                            // Service Center Name Field
                            _buildInputField(
                              controller: Name,
                              label: "Service Center Name",
                              icon: Icons.business,
                              validator: (value) =>
                                  value!.isEmpty ? "Enter service center name" : null,
                            ),
                            SizedBox(height: 20),

                            // Contact Field
                            _buildInputField(
                              controller: Contact,
                              label: "Phone Number",
                              icon: Icons.phone,
                              validator: (value) =>
                                  value!.isEmpty ? "Enter contact number" : null,
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
                                if (value!.isEmpty) return "Enter a password";
                                if (value.length < 8)
                                  return "Password must be 8 characters";
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
                              validator: (value) =>
                                  value != Password.text ? "Passwords do not match" : null,
                            ),
                            SizedBox(height: 25),

                            // Certificate Upload Section
                            Text(
                              "Upload Business Certificate",
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
                                          hintText: "Upload your certificate",
                                          hintStyle: TextStyle(color: Colors.grey),
                                        ),
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    Container(
                                      height: 40,
                                      width: 120,
                                      child: ElevatedButton(
                                        onPressed: pickImage,
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
                                      "Certificate uploaded",
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
                                  color: userLat != null ? Colors.blue : Colors.grey.shade300,
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
                                          "Service Center Location",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blue[900],
                                          ),
                                        ),
                                        Container(
                                          height: 35,
                                          child: ElevatedButton(
                                            onPressed: getCurrentLocation,
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
                                                        userLat == null ? "Get Location" : "Update",
                                                        style: TextStyle(
                                                          fontSize: 10,
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
                                    if (userLat != null && userLong != null)
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
                                            "Lat: ${userLat!.toStringAsFixed(6)}, Lng: ${userLong!.toStringAsFixed(6)}",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      )
                                    else
                                      Text(
                                        "Location is being fetched...",
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
                                    : () {
                                        if (formKey.currentState!.validate()) {
                                          if (image == null) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text("Please upload your certificate"),
                                                backgroundColor: Colors.orange,
                                              ),
                                            );
                                          } else if (userLat == null || userLong == null) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text("Please wait for location to be fetched"),
                                                backgroundColor: Colors.orange,
                                              ),
                                            );
                                          } else {
                                            postReg(context);
                                          }
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange.shade700,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 5,
                                  shadowColor: Colors.orange.shade300,
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
                                            Icons.business,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            "REGISTER SERVICE CENTER",
                                            style: TextStyle(
                                              fontSize: 14,
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
                                    MaterialPageRoute(builder: (_) => Login()),
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
                      "Get access to mechanic referrals, customer bookings, and business analytics",
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