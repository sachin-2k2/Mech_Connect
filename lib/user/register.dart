import 'package:flutter/material.dart';
import 'package:mechconnect/user/login.dart';
import 'package:dio/dio.dart';


class Register extends StatefulWidget {
  Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}
final baseurl = 'http://192.168.1.119:5000';
Dio dio = Dio();
class _RegisterState extends State<Register> {
  TextEditingController Name = TextEditingController();

  TextEditingController Contact = TextEditingController();

  TextEditingController Email = TextEditingController();
  TextEditingController Password = TextEditingController();
  TextEditingController ConfirmPassword = TextEditingController();

  final formkey = GlobalKey<FormState>();
  bool visible = true;
  bool visible1= true;


    Future<void> post_reg(context) async {

    try {
      final response = await dio.post(
        '$baseurl/api/user/register',
        data: {
          'username': Email.text,
          'password': Password.text,
          'name': Name.text,
          'phone': Contact.text,
          'email': Email.text,
        },
      );

      print(response.data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful')),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Registration failed')));
      }
    } catch (e) {
      print("❌ Registration error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register"), backgroundColor: Colors.blue),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: formkey,
          child: Column(
            children: [
              TextFormField(
                controller: Name,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter your name ";
                  }
                },
                decoration: InputDecoration(
                  label: Text("Name"),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
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
                },
                decoration: InputDecoration(
                  label: Text("Contact"),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
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
                },
                decoration: InputDecoration(
                  label: Text("Email"),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
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
                    return "password must be 8 characters";
                  }
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
                      visible ? Icons.visibility_off_rounded : Icons.visibility,
                    ),
                  ),
                  label: Text("Password"),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: ConfirmPassword,
                validator: (value) {
                  if (value != Password.text) {
                    return "password doesn't match";
                  }
                },obscureText: visible1,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        visible1 = !visible1;
                      });
                    },
                    icon: Icon(
                      visible1? Icons.visibility_off_rounded : Icons.visibility,
                    ),
                  ),
                  label: Text("Confirm Password"),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (formkey.currentState!.validate()) {
                  post_reg(context);
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
                  "Sign in",
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
                  Text("Already Have An Acoount ? "),
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
    );
  }
}
