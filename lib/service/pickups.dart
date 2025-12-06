import 'package:flutter/material.dart';

class Pickups extends StatelessWidget {
  Pickups({super.key});
  List<dynamic> Pickup = [
    {"Name": "miras", "Phone number": 98765432, "Email id": "hjk@gmail.com"},
    {"Name": "Sachin", "Phone number": 8765432, "Email id": "jk@gmail.com"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Pickup assign",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: Pickup.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Card(
                    child: ListTile(
                      title: Text(
                        Pickup[index]["Name"],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      trailing: TextButton(
                        onPressed: () {},
                        child: Text(
                          "Assign",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            43,
                            66,
                            108,
                          ),
                        ),
                      ),
                      subtitle: Column(
                        children: [
                          Text(Pickup[index]["Phone number"].toString()),
                          Text(Pickup[index]["Email id"]),
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
