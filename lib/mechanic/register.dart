import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mechconnect/user/login.dart';
import 'package:mechconnect/user/register.dart';

class Registermechanic extends StatefulWidget {
  Registermechanic({super.key});

  @override
  State<Registermechanic> createState() => _RegistermechanicState();
}

class _RegistermechanicState extends State<Registermechanic> {
  // ---------------- Controllers ----------------
  final TextEditingController Name = TextEditingController();
  final TextEditingController Contact = TextEditingController();
  final TextEditingController Email = TextEditingController();
  final TextEditingController Password = TextEditingController();
  final TextEditingController ConfirmPassword = TextEditingController();
  final TextEditingController image = TextEditingController(
    text: 'Upload your certificate',
  );

  final formKey = GlobalKey<FormState>();
  bool visible = true;
  bool visible1 = true;

  // ---------------- Image Pick ----------------
  File? pickedfile;
  final ImagePicker picker = ImagePicker();

  Future<void> selectedimage() async {
    XFile? selectimage = await picker.pickImage(source: ImageSource.gallery);

    if (selectimage != null) {
      setState(() {
        pickedfile = File(selectimage.path);
        image.text = selectimage.name;
      });
    }
  }

  // ---------------- Register API ----------------
  Future<void> post_reg(context) async {
    try {
      final formData = FormData.fromMap({
        'password': Password.text,
        'mechanicName': Name.text,
        'phone': Contact.text,
        'email': Email.text,
        'img': await MultipartFile.fromFile(
          pickedfile!.path,
          filename: pickedfile!.path.split('/').last,
        ),
      });

      final Dio dio = Dio();
      final response = await dio.post(
        '$baseurl/api/mechanic/register',
        data: formData,
      );

      print(response.data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Registration successful')));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Registration failed')));
      }
    } catch (e) {
      print("❌ Registration error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // ---------------- Init ----------------
  @override
  void initState() {
    super.initState();
    // fetch location automatically
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Register Mechanic"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // ---------------- NAME ----------------
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

                // ---------------- CONTACT ----------------
                TextFormField(
                  controller: Contact,
                  validator: (value) =>
                      value!.isEmpty ? "Enter contact number" : null,
                  decoration: InputDecoration(
                    label: Text("Contact"),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),

                // ---------------- EMAIL ----------------
                TextFormField(
                  controller: Email,
                  validator: (value) {
                    if (value!.isEmpty) return "Enter email";
                    if (!value.contains("@") || !value.endsWith("@gmail.com")) {
                      return "Enter valid Gmail address";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    label: Text("Email"),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),

                // ---------------- PASSWORD ----------------
                TextFormField(
                  controller: Password,
                  obscureText: visible,
                  validator: (value) {
                    if (value!.isEmpty) return "Enter password";
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

                // ---------------- CONFIRM PASSWORD ----------------
                TextFormField(
                  controller: ConfirmPassword,
                  obscureText: visible1,
                  validator: (value) =>
                      value != Password.text ? "Passwords don't match" : null,
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

                // ---------------- IMAGE UPLOAD ----------------
                TextFormField(
                  controller: image,
                  readOnly: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    suffixIcon: TextButton(
                      onPressed: selectedimage,
                      child: Text("Upload Image"),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // ---------------- REGISTER BUTTON ----------------
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      if (pickedfile == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Upload your certificate")),
                        );
                      } else {
                        post_reg(context);
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
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // ---------------- LOGIN REDIRECT ----------------
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
