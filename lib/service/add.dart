import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:mechconnect/user/register.dart'; // make sure this has your Dio instance & baseurl

class Add extends StatefulWidget {
  const Add({super.key});

  @override
  State<Add> createState() => _AddState();
}

class _AddState extends State<Add> {
  List<dynamic> mechanicItems = [];
  List<dynamic> pickupItems = [];

  bool isLoadingMechanic = true;
  bool isLoadingPickup = true;

  @override
  void initState() {
    super.initState();
    fetchMechanicData();
    fetchPickupData();
  }

  // ----------------------------
  // FETCH MECHANIC DATA
  // ----------------------------
  Future<void> fetchMechanicData() async {
    try {
      final response = await dio.get('$baseurl/api/mechanic/all');
      print(response.data);
      if (response.statusCode == 200) {
        setState(() {
          mechanicItems = response.data["data"] ?? [];
          isLoadingMechanic = false;
        });
      }
    } catch (e) {
      print("Error fetching mechanic data: $e");
      setState(() {
        isLoadingMechanic = false;
      });
    }
  }

  // ----------------------------
  // FETCH PICKUP DATA
  // ----------------------------
  Future<void> fetchPickupData() async {
    try {
      final response = await dio.get('$baseurl/api/user/pickups');
      print(response.data);
      if (response.statusCode == 200) {
        setState(() {
          pickupItems = response.data["data"] ?? [];
          isLoadingPickup = false;
        });
      }
    } catch (e) {
      print("Error fetching pickup data: $e");
      setState(() {
        isLoadingPickup = false;
      });
    }
  }

  // ----------------------------
  // BUILD LIST WIDGET
  // ----------------------------
  Widget buildList(List<dynamic> items, bool isLoading, bool isMechanic) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (items.isEmpty) {
      return Center(child: Text("No requests available"));
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        var item = items[index];

        String name = isMechanic ? item["mechanicName"] ?? "N/A" : item["name"] ?? "N/A";
        String phone = item["phone"] ?? "-";
        String email = item["email"] ?? "-";
        String location = isMechanic
            ? "N/A"
            : (item["location"] != null
                ? "Lat: ${item["location"]["lat"]}, Lng: ${item["location"]["lng"]}"
                : "N/A");
        String vehicle = isMechanic ? "-" : (item["vehicleNumber"]?.toString() ?? "-");
        String certificate = item["certificateImg"] ?? "-";

        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Card(
            child: ListTile(
              title: Text(name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Contact: $phone"),
                  Text("Email: $email"),
                  if (!isMechanic) Text("Vehicle: $vehicle"),
                  if (!isMechanic) Text("Location: $location"),
                  Text("Certificate: $certificate"),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          // TODO: handle Accept action
                        },
                        child: Text(
                          "Accept",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                      SizedBox(width: 10),
                      TextButton(
                        onPressed: () {
                          // TODO: handle Reject action
                        },
                        child: Text(
                          "Reject",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.red,
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
    );
  }

  // ----------------------------
  // BUILD UI
  // ----------------------------
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Request Details"),
          backgroundColor: Colors.lightBlueAccent,
          bottom: TabBar(
            tabs: [
              Tab(text: "Mechanic"),
              Tab(text: "Pickup"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            buildList(mechanicItems, isLoadingMechanic, true),
            buildList(pickupItems, isLoadingPickup, false),
          ],
        ),
      ),
    );
  }
}
