import 'package:flutter/material.dart';
import 'package:mechconnect/user/register.dart';

class Pickups extends StatefulWidget {
  String bid;
  Pickups({super.key, required this.bid});

  @override
  State<Pickups> createState() => _PickupsState();
}

class _PickupsState extends State<Pickups> {
  List<dynamic> pickupItems = [];
  bool isLoading = true;

  Future<void> fetchPickupData() async {
    try {
      final response = await dio.get('$baseurl/api/user/pickups');
      debugPrint(response.data.toString());

      if (response.statusCode == 200) {
        setState(() {
          pickupItems = response.data["data"] ?? [];
          isLoading = false;
        });
      }
    } catch (e) {
      isLoading = false;
      debugPrint("Error fetching pickup data: $e");
      setState(() {});
    }
  }

  Future<void> bookpickup(String id) async {
    try {
      final response = await dio.put(
        '$baseurl/api/booking/assignpickup/${widget.bid}',
        data: {'pickupPartnerId': id},
      );
      debugPrint(response.data.toString());

      if (response.statusCode == 200) {}
    } catch (e) {
      isLoading = false;
      debugPrint("Error fetching pickup data: $e");
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPickupData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pickup assign",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : pickupItems.isEmpty
          ? const Center(child: Text("No pickups available"))
          : ListView.builder(
              itemCount: pickupItems.length,
              itemBuilder: (context, index) {
                final item = pickupItems[index];

                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Card(
                    elevation: 4,
                    child: ListTile(
                      title: Text(
                        item["name"] ?? "No Name",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Phone: ${item["phone"] ?? "N/A"}"),
                          Text("Email: ${item["email"] ?? "N/A"}"),
                          Text("Vehicle: ${item["vehicleNumber"] ?? "N/A"}"),
                        ],
                      ),
                      trailing: TextButton(
                        onPressed: () {
                          bookpickup(pickupItems[index]['_id']);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            43,
                            66,
                            108,
                          ),
                        ),
                        child: const Text(
                          "Assign",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
