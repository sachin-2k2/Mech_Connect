import 'package:flutter/material.dart';
import 'package:mechconnect/user/report.dart';

class Viewstatus extends StatelessWidget {
  Viewstatus({super.key});
  List<dynamic> STATUS = [
    {
      "name": "user1",
      "mechname":"Mech-theertha",
      "issues":"issue1",
      "status":"completed"
     
    },
    {
      "name": "user2",
      "mechname":"Mech-hina",
      "issues":"issue2",
      "status":"completed"
     
    },
    {
      "name": "user3",
      "mechname":"Mech-isha",
      "issues":"issue3",
      "status":"completed"
     
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Status"),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: STATUS.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Card(
                    child: ListTile(
                     
                      title: Text(STATUS[index]["name"]),
                      subtitle: Column(
                        children: [
                          Text(STATUS[index]["issues"]),
                          Text(STATUS[index]["status"]),
                          Text(STATUS[index]["mechname"]),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
