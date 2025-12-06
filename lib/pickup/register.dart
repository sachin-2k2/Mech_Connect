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
  }

  /// ------------ POST REGISTER API ----------------
  Future<void> post_reg(context) async {
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Registration successful')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Registration failed')));
      }
    } catch (e) {
      print("❌ Registration error: $e");
    }
  }

  /// -------------- UI -----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register"), backgroundColor: Colors.blue),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: formkey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: Name,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter your name ";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    label: Text("Name"),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 10),

                TextFormField(
                  controller: Contact,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter your contact";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    label: Text("Contact"),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 10),

                TextFormField(
                  controller: Email,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter your Email";
                    } else if (!value.contains("@") ||
                        !value.endsWith("@gmail.com")) {
                      return "Enter a valid email ";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    label: Text("Email"),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                TextFormField(
                  controller: vehicle,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter your vehicle no ";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    label: Text("Vehicle No."),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                TextFormField(
                  controller: Password,
                  validator: (value) {
                    if (value == null) {
                      return "Enter a password";
                    } else if (value.length < 8) {
                      return "Password must be 8 characters";
                    }
                    return null;
                  },
                  obscureText: visible,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          visible = !visible;
                        });
                      },
                      icon: Icon(
                        visible
                            ? Icons.visibility_off_rounded
                            : Icons.visibility,
                      ),
                    ),
                    label: Text("Password"),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                TextFormField(
                  controller: ConfirmPassword,
                  validator: (value) {
                    if (value != Password.text) {
                      return "Password doesn't match";
                    }
                    return null;
                  },
                  obscureText: visible1,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          visible1 = !visible1;
                        });
                      },
                      icon: Icon(
                        visible1
                            ? Icons.visibility_off_rounded
                            : Icons.visibility,
                      ),
                    ),
                    label: Text("Confirm Password"),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                /// -------- IMAGE UPLOAD ------------
                TextFormField(
                  controller: img,
                  readOnly: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 15, 10),
                      child: TextButton(
                        onPressed: () {
                          pickimage();
                        },
                        child: Text('Upload image'),
                        style: TextButton.styleFrom(
                          backgroundColor: Color.fromARGB(134, 158, 158, 158),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                /// -------- SUBMIT BUTTON ------------
                ElevatedButton(
                  onPressed: () async {
                    if (formkey.currentState!.validate()) {
                      if (image != null) {
                        await getLocation();

                        if (latitude != null && longitude != null) {
                          post_reg(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Unable to fetch location")),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Upload your permit")),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: Size(200, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    "Sign up",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already Have An Account? "),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Login()),
                        );
                      },
                      child: Text(
                        "Login",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
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
