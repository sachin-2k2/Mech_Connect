import 'package:flutter/material.dart';
import 'package:mechconnect/mechanic/bill.dart';


class Assignedtask extends StatefulWidget {
  Assignedtask({super.key});

  @override
  State<Assignedtask> createState() => _AssignedtaskState();
}

class _AssignedtaskState extends State<Assignedtask> {
  List<dynamic> TASK = [
    {
      "issue": "hina issue ",
      "location": "kattangal",
      "user": "user1",
      "date": "13-08-25",
      "accepted": false,
    },
    {
      "issue": "theertha issue ",
      "location": "kannur",
      "user": "user2",
      "date": "15-08-25",
      "accepted": false,
    }, 
    {
      "issue": "isha issue ",
      "location": "kollam",
      "user": "user3",
      "date": "19-06-25",
      "accepted": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Assigned tasks ",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: TASK.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: InkWell(
                    onTap: () {},
                    child: Card(
                      child: ListTile(
                        title: Text(TASK[index]["issue"]),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(TASK[index]["location"]),
                            Text(TASK[index]["user"]),
                            Text(TASK[index]["date"]),

                            // -------------------------
                            // CONDITION HERE 👇
                            // -------------------------
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: TASK[index]["accepted"] == false
                                  ? [
                                      /// ACCEPT BUTTON
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            TASK[index]["accepted"] = true;
                                          });
                                        },
                                        style: TextButton.styleFrom(
                                          backgroundColor: Color.fromARGB(
                                            195,
                                            76,
                                            175,
                                            79,
                                          ),
                                        ),
                                        child: Text(
                                          "Accept",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),

                                      SizedBox(width: 10),

                                      /// REJECT BUTTON
                                      TextButton(
                                        onPressed: () {},
                                        style: TextButton.styleFrom(
                                          backgroundColor: Color.fromARGB(
                                            196,
                                            244,
                                            67,
                                            54,
                                          ),
                                        ),
                                        child: Text(
                                          "Reject",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ]
                                  : [
                                      /// MECHANIC BUTTON
                                      TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => BillPage(),
                                            ),
                                          );
                                        },
                                        style: TextButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                        ),
                                        child: Text(
                                          "Complete",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),

                                      SizedBox(width: 10),
                                    ],
                            ),
                          ],
                        ),
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
