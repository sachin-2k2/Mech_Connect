import 'package:flutter/material.dart';
import 'package:mechconnect/service/home.dart';
import 'package:mechconnect/service/mechanics.dart';
import 'package:mechconnect/service/pickups.dart';
import 'package:mechconnect/user/register.dart';

class Viewrequest extends StatefulWidget {
  Viewrequest({super.key});

  @override
  State<Viewrequest> createState() => _ViewrequestState();
}

class _ViewrequestState extends State<Viewrequest> {
  List<dynamic> requests = [];

  Future<void> get_requests(context) async {
    try {
      final response = await dio.get(
        '$baseurl/api/booking/servicecenter/$sobid',
      );

      print(response.data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          requests = response.data["data"];

          // add local flag
          for (var r in requests) {
            r["accepted"] = false;
          }
        });

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Successful')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed')));
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  void initState() {
    super.initState();
    get_requests(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "View Request",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.lightBlueAccent,
      ),

      body: requests.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final req = requests[index];
                final userLoc = req["userLocation"];
                final imageUrl = "$baseurl/${req['problemImage']}";

                return Padding(
                  padding: const EdgeInsets.all(10),
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // =============== PROBLEM IMAGE ===============
                          req["problemImage"] != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    imageUrl,
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Container(
                                  height: 150,
                                  color: Colors.grey[300],
                                  child: Center(
                                      child: Text("No Image Uploaded")),
                                ),

                          SizedBox(height: 10),

                          // ISSUE
                          Text(
                            req["problemDescription"] ?? "No issue",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 5),

                          // USER LOCATION
                          Text(
                            "User Location: LAT ${userLoc["lat"]}, LNG ${userLoc["lng"]}",
                            style: TextStyle(color: Colors.black87),
                          ),

                          SizedBox(height: 10),

                          // ================== BUTTONS ==================
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: req["accepted"] == false
                                ? [
                                    // ACCEPT BUTTON
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          req["accepted"] = true;
                                        });
                                      },
                                      style: TextButton.styleFrom(
                                          backgroundColor: Colors.green),
                                      child: Text(
                                        "Accept",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),

                                    SizedBox(width: 10),

                                    // REJECT BUTTON
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          req["accepted"] = "rejected";
                                        });
                                      },
                                      style: TextButton.styleFrom(
                                          backgroundColor: Colors.red),
                                      child: Text(
                                        "Reject",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ]
                                : req["accepted"] == "rejected"
                                    ? [
                                        Text(
                                          "Rejected",
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      ]
                                    : [
                                        // MECHANIC BUTTON
                                        TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => Assign(),
                                              ),
                                            );
                                          },
                                          style: TextButton.styleFrom(
                                              backgroundColor: Colors.blue),
                                          child: Text(
                                            "Mechanic",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),

                                        SizedBox(width: 10),

                                        // PICK UP BUTTON
                                        TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    Pickups(),
                                              ),
                                            );
                                          },
                                          style: TextButton.styleFrom(
                                              backgroundColor: Colors.orange),
                                          child: Text(
                                            "Pick Up",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
