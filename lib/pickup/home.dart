import 'package:flutter/material.dart';
import 'package:mechconnect/mechanic/assignedtask.dart';
import 'package:mechconnect/pickup/assignedtask.dart';
import 'package:mechconnect/pickup/bottom.dart';
import 'package:mechconnect/user/login.dart';
import 'package:mechconnect/user/register.dart';

class Homemepickup extends StatefulWidget {
  const Homemepickup({super.key});

  @override
  State<Homemepickup> createState() => _HomemepickupState();
}

Map<String, dynamic> pdata = {};
String? pobid;

class _HomemepickupState extends State<Homemepickup> {
  Future<void> get_phome(context) async {
    try {
      final response = await dio.get('$baseurl/api/pickup/home/$loginid');
      print(response.data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          pdata = response.data["data"]; // Extract "data"
          pobid = response.data['data']['_id'];
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(' successful')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(' failed')));
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    get_phome(context);
    print('log id ${loginid}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffe6eef3),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BottomNavigationPage(),
                    ),
                  );
                },
                icon: Icon(Icons.task_alt, color: Colors.blue),
                label: Text(
                  "ASSIGNED TASK",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue.withOpacity(0.15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  minimumSize: Size(double.infinity, 80),
                ),
              ),
              SizedBox(height: 20),
              TextButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Login()),
                  );
                },
                icon: Icon(Icons.logout_outlined, color: Colors.blue),
                label: Text(
                  "LOG OUT",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue.withOpacity(0.15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  minimumSize: Size(double.infinity, 80),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
