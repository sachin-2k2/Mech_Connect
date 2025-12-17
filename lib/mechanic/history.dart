import 'package:flutter/material.dart';
import 'package:mechconnect/mechanic/home.dart';
import 'package:mechconnect/user/home.dart';
import 'package:mechconnect/user/register.dart'; // for dio, baseurl

class Viewvehicle extends StatefulWidget {
  Viewvehicle({super.key});

  @override
  State<Viewvehicle> createState() => _ViewvehicleState();
}

class _ViewvehicleState extends State<Viewvehicle> {
  List<dynamic> history = [];
  bool isLoading = true;

  Future<void> get_vehicle(context) async {
    try {
      final response = await dio.get('$baseurl/api/vehicle/$mobid');

      print(response.data);

      if (response.statusCode == 200) {
        setState(() {
          history = response.data["data"] ?? [];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to fetch vehicles")));
      }
    } catch (e) {
      print(e);
      setState(() => isLoading = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // ============================
  //     DELETE VEHICLE
  // ============================
  Future<void> dlt_vehicle(context, String id) async {
    try {
      final response = await dio.delete('$baseurl/api/vehicle/$id');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Vehicle deleted successfully")));

        get_vehicle(context); // refresh list
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to delete vehicle")));
      }
    } catch (e) {
      print("Delete error: $e");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  void initState() {
    super.initState();
    get_vehicle(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Vehicle Details"),
        backgroundColor: Colors.lightBlueAccent,
      ),

      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : history.isEmpty
          ? Center(
              child: Text(
                "No Vehicles Found",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
          : ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final v = history[index];

                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Card(
                    color: const Color.fromARGB(105, 158, 158, 158),
                    child: ListTile(
                      title: Text(
                        v["vehicleNumber"] ?? "",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Brand: ${v["brand"] ?? ""}"),
                          Text("Model: ${v["model"] ?? ""}"),
                          Text("Fuel: ${v["fuelType"] ?? ""}"),
                          Text("Year: ${v["year"] ?? ""}"),
                        ],
                      ),

                      trailing: IconButton(
                        onPressed: () {
                          dlt_vehicle(context, v["_id"]);
                        },
                        icon: Icon(Icons.delete, color: Colors.red),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
