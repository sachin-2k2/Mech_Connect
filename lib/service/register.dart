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
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error("Location services are OFF");
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error("Location permissions denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error("Location permissions permanently denied");
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      userLat = position.latitude;
      userLong = position.longitude;
    });

    print("📍 Latitude: $userLat, Longitude: $userLong");
  }

  // ----------------------- API REQUEST -----------------------
  Future<void> postReg(context) async {
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Registration Successful")));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Registration Failed")));
      }
    } catch (e) {
      print("❌ Error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
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
      appBar: AppBar(title: Text("Register"), backgroundColor: Colors.blue),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // ------------------- NAME --------------------
                TextFormField(
                  controller: Name,
                  validator: (value) =>
                      value!.isEmpty ? "Enter your name" : null,
                  decoration: InputDecoration(
                    label: Text("Name"),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),

                // ------------------- CONTACT --------------------
                TextFormField(
                  controller: Contact,
                  validator: (value) =>
                      value!.isEmpty ? "Enter your contact" : null,
                  decoration: InputDecoration(
                    label: Text("Contact"),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),

                // ------------------- EMAIL --------------------
                TextFormField(
                  controller: Email,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter your email";
                    } else if (!value.contains("@") ||
                        !value.endsWith("@gmail.com")) {
                      return "Enter a valid Gmail address";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    label: Text("Email"),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),

                // ------------------- PASSWORD --------------------
                TextFormField(
                  controller: Password,
                  obscureText: visible,
                  validator: (value) {
                    if (value!.isEmpty) return "Enter a password";
                    if (value.length < 8)
                      return "Password must be 8 characters";
                    return null;
                  },
                  decoration: InputDecoration(
                    label: Text("Password"),
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        visible ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          visible = !visible;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // ------------------- CONFIRM PASSWORD --------------------
                TextFormField(
                  controller: ConfirmPassword,
                  obscureText: visible1,
                  validator: (value) =>
                      value != Password.text ? "Passwords do not match" : null,
                  decoration: InputDecoration(
                    label: Text("Confirm Password"),
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        visible1 ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          visible1 = !visible1;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // ------------------- IMAGE UPLOAD --------------------
                TextFormField(
                  controller: img,
                  readOnly: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    suffixIcon: TextButton(
                      onPressed: pickImage,
                      child: Text("Upload Image"),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // ------------------- SUBMIT BUTTON --------------------
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      if (image == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Upload your certificate")),
                        );
                      } else if (userLat == null || userLong == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Fetching location...")),
                        );
                      } else {
                        postReg(context); // API CALL
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: Size(200, 50),
                  ),
                  child: Text(
                    "Sign Up",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // ------------------- LOGIN REDIRECT --------------------
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account? "),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => Login()),
                        );
                      },
                      child: Text(
                        "Login",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
