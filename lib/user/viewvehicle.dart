import 'package:flutter/material.dart';
import 'package:mechconnect/user/home.dart';
import 'package:mechconnect/user/register.dart'; // for dio, baseurl, obid

class Viewvehicle extends StatefulWidget {
  Viewvehicle({super.key});

  @override
  State<Viewvehicle> createState() => _ViewvehicleState();
}

class _ViewvehicleState extends State<Viewvehicle> {
  List<dynamic> vehicles = [];
  bool isLoading = true;
  bool deleting = false;
  String? deletingId;

  // ============================
  //     FETCH VEHICLES
  // ============================
  Future<void> get_vehicle(context) async {
    try {
      final response = await dio.get('$baseurl/api/vehicle/$obid');

      print(response.data);

      if (response.statusCode == 200) {
        setState(() {
          vehicles = response.data["data"] ?? [];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to fetch vehicles"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print(e);
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================
  //     DELETE VEHICLE
  // ============================
  Future<void> dlt_vehicle(context, String id) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Delete"),
        content: Text("Are you sure you want to delete this vehicle?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() {
                deleting = true;
                deletingId = id;
              });

              try {
                final response = await dio.delete('$baseurl/api/vehicle/$id');

                if (response.statusCode == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("🚗 Vehicle deleted successfully"),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );

                  await get_vehicle(context); // refresh list
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Failed to delete vehicle"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                print("Delete error: $e");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Error: $e"),
                    backgroundColor: Colors.red,
                  ),
                );
              } finally {
                setState(() {
                  deleting = false;
                  deletingId = null;
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    get_vehicle(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade900,
              Colors.blue.shade700,
              Colors.blue.shade400,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "My Vehicles",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Manage your registered vehicles",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: isLoading
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                color: Colors.blue.shade700,
                              ),
                              SizedBox(height: 20),
                              Text(
                                "Loading your vehicles...",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : vehicles.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.directions_car_outlined,
                                    size: 80,
                                    color: Colors.grey.shade300,
                                  ),
                                  SizedBox(height: 20),
                                  Text(
                                    "No Vehicles Found",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "Add your first vehicle to get started",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                  SizedBox(height: 30),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue.shade700,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 30,
                                        vertical: 15,
                                      ),
                                    ),
                                    child: Text(
                                      "Add Vehicle",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  // Vehicle Count
                                  Container(
                                    padding: EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: Colors.blue.shade100,
                                        width: 2,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.directions_car,
                                          color: Colors.blue.shade700,
                                          size: 20,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          "${vehicles.length} Vehicle${vehicles.length > 1 ? 's' : ''} Registered",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blue.shade900,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 20),

                                  // Vehicles List
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: vehicles.length,
                                      itemBuilder: (context, index) {
                                        final v = vehicles[index];
                                        final isDeleting =
                                            deleting && deletingId == v["_id"];

                                        return Container(
                                          margin: EdgeInsets.only(bottom: 15),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.08),
                                                blurRadius: 15,
                                                spreadRadius: 2,
                                              ),
                                            ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(20),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Vehicle Number and Delete Button Row
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            v["vehicleNumber"] ?? "",
                                                            style: TextStyle(
                                                              fontSize: 22,
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                              color:
                                                                  Colors.blue.shade900,
                                                            ),
                                                          ),
                                                          SizedBox(height: 8),
                                                        ],
                                                      ),
                                                    ),
                                                    // Delete Button
                                                    Container(
                                                      width: 40,
                                                      height: 40,
                                                      decoration: BoxDecoration(
                                                        color: Colors.red.shade50,
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color: Colors.red.shade100,
                                                          width: 2,
                                                        ),
                                                      ),
                                                      child: isDeleting
                                                          ? Center(
                                                              child: SizedBox(
                                                                width: 20,
                                                                height: 20,
                                                                child:
                                                                    CircularProgressIndicator(
                                                                  strokeWidth: 2,
                                                                  color: Colors.red,
                                                                ),
                                                              ),
                                                            )
                                                          : IconButton(
                                                              onPressed: () =>
                                                                  dlt_vehicle(
                                                                      context, v["_id"]),
                                                              icon: Icon(
                                                                Icons.delete_outline,
                                                                size: 20,
                                                                color:
                                                                    Colors.red.shade700,
                                                              ),
                                                              padding: EdgeInsets.zero,
                                                            ),
                                                    ),
                                                  ],
                                                ),
                                                
                                                // Vehicle Type Badge
                                                SizedBox(height: 10),
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.green.shade50,
                                                    borderRadius:
                                                        BorderRadius.circular(10),
                                                  ),
                                                  child: Text(
                                                    v["vehicleType"] ?? "Vehicle",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w500,
                                                      color: Colors.green.shade700,
                                                    ),
                                                  ),
                                                ),
                                                
                                                SizedBox(height: 20),

                                                // Details Grid - Fixed with proper sizing
                                                SizedBox(
                                                  height: 220, // Fixed height to prevent overflow
                                                  child: GridView.count(
                                                    crossAxisCount: 2,
                                                    shrinkWrap: true,
                                                    physics:
                                                        NeverScrollableScrollPhysics(),
                                                    childAspectRatio: 1.5, // Adjusted aspect ratio
                                                    crossAxisSpacing: 10,
                                                    mainAxisSpacing: 10,
                                                    children: [
                                                      _buildDetailItem(
                                                        icon: Icons.branding_watermark,
                                                        label: "Brand",
                                                        value: v["brand"] ?? "",
                                                      ),
                                                      _buildDetailItem(
                                                        icon: Icons.model_training,
                                                        label: "Model",
                                                        value: v["model"] ?? "",
                                                      ),
                                                      _buildDetailItem(
                                                        icon: Icons.local_gas_station,
                                                        label: "Fuel Type",
                                                        value: v["fuelType"] ?? "",
                                                      ),
                                                      _buildDetailItem(
                                                        icon: Icons.calendar_today,
                                                        label: "Year",
                                                        value: v["year"]?.toString() ??
                                                            "",
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(height: 15),

                                                // Registration Date
                                                Container(
                                                  padding: EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade50,
                                                    borderRadius:
                                                        BorderRadius.circular(10),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.date_range,
                                                        size: 16,
                                                        color: Colors.grey.shade600,
                                                      ),
                                                      SizedBox(width: 8),
                                                      Expanded(
                                                        child: Text(
                                                          "Registered: ${_formatDate(v["createdAt"] ?? "")}",
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            color: Colors.grey.shade600,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: Colors.blue.shade700,
              ),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 26), // Align with icon
            child: Text(
              value.isNotEmpty ? value : "Not specified",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade900,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      if (dateString.isEmpty) return "Unknown";
      final dateTime = DateTime.parse(dateString);
      return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
    } catch (e) {
      return "Unknown";
    }
  }
}