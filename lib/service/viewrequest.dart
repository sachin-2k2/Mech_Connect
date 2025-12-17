import 'package:flutter/material.dart';
import 'package:mechconnect/service/home.dart';
import 'package:mechconnect/service/mechanics.dart';
import 'package:mechconnect/service/pickups.dart';
import 'package:mechconnect/user/register.dart';

class Viewrequest extends StatefulWidget {
  const Viewrequest({super.key});

  @override
  State<Viewrequest> createState() => _ViewrequestState();
}

class _ViewrequestState extends State<Viewrequest> {
  List<dynamic> requests = [];

  Future<void> get_requests(BuildContext context) async {
    try {
      final response = await dio.get(
        '$baseurl/api/booking/servicecenter/$sobid',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          requests = response.data["data"];

          // Local UI state
          for (var r in requests) {
            r["accepted"] = false;
          }
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> post_status(
      BuildContext context, String id, String status) async {
    try {
      await dio.put(
        '$baseurl/api/booking/$id/status',
        data: {'status': status},
      );
    } catch (e) {
      debugPrint(e.toString());
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
        title: const Text(
          "View Request",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: requests.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final req = requests[index];
                final vehicle = req["vehicleId"];
                final userLoc = req["userLocation"];
                final imageUrl = "$baseurl/${req['problemImage']}";

                return Padding(
                  padding: const EdgeInsets.all(10),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ================= IMAGE =================
                          if (req["problemImage"] != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                imageUrl,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            )
                          else
                            Container(
                              height: 150,
                              color: Colors.grey[300],
                              child: const Center(
                                child: Text("No Image Uploaded"),
                              ),
                            ),

                          const SizedBox(height: 10),

                          // ================= ISSUE =================
                          Text(
                            req["problemDescription"] ?? "No issue",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 6),

                          // ================= LOCATION =================
                          Text(
                            "LAT: ${userLoc["lat"]}, LNG: ${userLoc["lng"]}",
                          ),

                          const Divider(height: 20),

                          // ================= VEHICLE DETAILS =================
                          if (vehicle != null) ...[
                            const Text(
                              "Vehicle Details",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.motorcycle),
                                const SizedBox(width: 6),
                                Text(
                                  "${vehicle["brand"]} ${vehicle["model"]}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Text("Year : ${vehicle["year"]}"),
                            Text("Vehicle No : ${vehicle["vehicleNumber"]}"),
                            Text("Fuel : ${vehicle["fuelType"]}"),
                            Text("Type : ${vehicle["vehicleType"]}"),
                          ],

                          const SizedBox(height: 12),

                          // ================= ACTION BUTTONS =================
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (req["accepted"] == false) ...[
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      req["accepted"] = true;
                                    });
                                    post_status(
                                        context, req['_id'], 'accepted');
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                  child: const Text(
                                    "Accept",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      req["accepted"] = "rejected";
                                    });
                                    post_status(
                                        context, req['_id'], 'rejected');
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: const Text(
                                    "Reject",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],

                              if (req["accepted"] == "rejected") ...[
                                const Text(
                                  "Rejected",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],

                              if (req["accepted"] == true) ...[
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            Assign(bid: req['_id']),
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                  ),
                                  child: const Text(
                                    "Mechanic",
                                    style:
                                        TextStyle(color: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            Pickups(bid: req['_id']),
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                  ),
                                  child: const Text(
                                    "Pick Up",
                                    style:
                                        TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
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
