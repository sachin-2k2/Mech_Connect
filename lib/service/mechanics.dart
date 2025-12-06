import 'package:flutter/material.dart';
import 'package:mechconnect/user/report.dart';

class Assign extends StatelessWidget {
  Assign({super.key});
  List<dynamic> Service = [
    {
      " name": "theertha Mechanic",
      "contact": 2345678,
      "email": "fgohj@gmail.com",
    },
    {
      " name": "isha Mechanic",
      "contact": 23458,
      "email": "fghj@gmail.com",
    },
    {
      " name": "hina Mechanic",
      "contact": 345678,
      "email": "fgj@gmail.com",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mechanic assign "),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: Service.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Card(
                    child: ListTile(
                      trailing: TextButton(
                        onPressed: () {},
                        child: Text(
                          "Assign",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 43, 66, 108),
                        ),
                      ),
                      title: Text(Service[index][" name"]),
                      subtitle: Column(
                        children: [
                          Text(Service[index]["contact"].toString()),
                          Text(Service[index]["email"]),
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
