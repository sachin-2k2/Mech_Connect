import 'package:flutter/material.dart';
import 'package:mechconnect/service/sendreply.dart';


class Viewcomplaint extends StatelessWidget {
  Viewcomplaint({super.key});
  List<dynamic> Service = [
    {"name": "theertha complaint", "location": "kattangal"},
    {"name": "isha complaint", "location": "kannur"},
    {"name": "hina complaint", "location": "kollam"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Complaints"),
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
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Sendreply(),
                            ),
                          );
                        },
                        child: Text(
                          "Send reply",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                      ),
                  
                      title: Text(Service[index]["name"]),
                      subtitle: Column(
                        children: [Text(Service[index]["location"])],
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
