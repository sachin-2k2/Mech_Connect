import 'package:flutter/material.dart';
import 'package:mechconnect/mechanic/home.dart';
import 'package:mechconnect/mechanic/register.dart';
import 'package:mechconnect/pickup/home.dart';
import 'package:mechconnect/pickup/register.dart';
import 'package:mechconnect/service/home.dart';
import 'package:mechconnect/service/register.dart';
import 'package:mechconnect/user/home.dart';
import 'package:mechconnect/user/register.dart';

class Login extends StatefulWidget {
  Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

String? loginid;

class _LoginState extends State<Login> {
  TextEditingController Username = TextEditingController();

  TextEditingController password = TextEditingController();

  final formkey = GlobalKey<FormState>();

  String? role;

  bool visible = true;
  void show() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("who you are ?"),
        content: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Registerservice()),
                  );
                },
                child: Text(
                  "Service center",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue.withOpacity(0.15),
                  minimumSize: Size(double.infinity, 40),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Registermechanic()),
                  );
                },
                child: Text(
                  "Mechanic",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue.withOpacity(0.15),
                  minimumSize: Size(double.infinity, 40),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Registerpickup()),
                  );
                },
                child: Text(
                  "Pickup",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue.withOpacity(0.15),
                  minimumSize: Size(double.infinity, 40),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Register()),
                  );
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue.withOpacity(0.15),
                  minimumSize: Size(double.infinity, 40),
                ),
                child: Text(
                  "User",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> post_login(context) async {
    try {
      final response = await dio.post(
        '$baseurl/api/login/',
        data: {'email': Username.text, 'password': password.text},
      );
      print(response.data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        loginid = response.data['id'];
        role = response.data['role'];

        if (role == 'user') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreenusr()),
          );
        } else if (role == 'service_center') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => homeservice()),
          );
        } else if (role == 'mechanic') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Homemechanic()),
          );
        } else if (role == 'pickup_partner') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Homemepickup()),
          );
        }
        else{
          
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('user role invalid')));
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Login successful')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Login failed')));
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login Page"), backgroundColor: Colors.blue),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: formkey,
          child: Column(
            children: [
              TextFormField(
                controller: Username,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter a valid username";
                  }
                },
                decoration: InputDecoration(
                  label: Text("Username"),
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
                controller: password,
                validator: (value) {
                  if (value == null) {
                    return "Enter a password";
                  } else if (value.length < 8) {
                    return "password must be 8 character";
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
              ElevatedButton(
                onPressed: () {
                  if (formkey.currentState!.validate()) {
                    post_login(context);
                  }
                },
                child: Text(
                  "Login",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: Size(150, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't Have An Account ?"),
                  TextButton(
                    onPressed: () {
                      show();
                    },
                    child: Text(
                      "Register",
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
