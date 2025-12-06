import 'package:flutter/material.dart';
import 'package:mechconnect/user/report.dart';

class Viewfeedback extends StatelessWidget {
  Viewfeedback({super.key});
  List<dynamic> feedback = [
    {"name": "user1", "feedback": "good", "rating": "4 star"},
    {"name": "user2", "feedback": "excellent", "rating": "5 star"},
    {"name": "user3", "feedback": "not bad", "rating": "3 star"},
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
              itemCount: feedback.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Card(
                    child: ListTile(
                      title: Text(feedback[index]["name"]),
                      subtitle: Column(
                        children: [
                          Text(feedback[index]["feedback"]),
                          Text(feedback[index]["rating"]),
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
