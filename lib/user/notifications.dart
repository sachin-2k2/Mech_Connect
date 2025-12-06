import 'package:flutter/material.dart';
import 'package:mechconnect/user/home.dart';
import 'package:mechconnect/user/register.dart';

class Notifications extends StatefulWidget {
  Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  List<dynamic> Notification = [
    {"service center": "theertha", "status": "your request accepted","Date":"13-08-25"},
    {"service center": "hina", "status": "your request rejected","Date":"03-09-25"},
  ];

Map<String, dynamic> notification = {};

   Future<void> get_name(context) async {
    try {
      final response = await dio.get('$baseurl/api/user/home/$obid');
      print(response.data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          notification = response.data["data"]; // Extract "data"
         
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Notifications",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: Notification.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(trailing: Text(Notification[index]["Date"]),
                      title: Text(Notification[index]["service center"]),
                      subtitle: Column(
                        children: [
                          Text(Notification[index]["status"]),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
