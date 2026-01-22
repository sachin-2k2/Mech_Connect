// import 'package:flutter/material.dart';
// import 'package:mechconnect/user/register.dart';

// class Pickups extends StatefulWidget {
//   String bid;
//   Pickups({super.key, required this.bid});

//   @override
//   State<Pickups> createState() => _PickupsState();
// }

// class _PickupsState extends State<Pickups> {
//   List<dynamic> pickupItems = [];
//   bool isLoading = true;

//   Future<void> fetchPickupData() async {
//     try {
//       final response = await dio.get('$baseurl/api/user/pickups');
//       debugPrint(response.data.toString());

//       if (response.statusCode == 200) {
//         setState(() {
//           pickupItems = response.data["data"] ?? [];
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       isLoading = false;
//       debugPrint("Error fetching pickup data: $e");
//       setState(() {});
//     }
//   }

//   Future<void> bookpickup(String id) async {
//     try {
//       final response = await dio.put(
//         '$baseurl/api/booking/assignpickup/${widget.bid}',
//         data: {'pickupPartnerId': id},
//       );
//       debugPrint(response.data.toString());

//       if (response.statusCode == 200) {}
//     } catch (e) {
//       isLoading = false;
//       debugPrint("Error fetching pickup data: $e");
//       setState(() {});
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     fetchPickupData();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "Pickup assign",
//           style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
//         ),
//         backgroundColor: Colors.lightBlueAccent,
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : pickupItems.isEmpty
//           ? const Center(child: Text("No pickups available"))
//           : ListView.builder(
//               itemCount: pickupItems.length,
//               itemBuilder: (context, index) {
//                 final item = pickupItems[index];

//                 return Padding(
//                   padding: const EdgeInsets.all(10.0),
//                   child: Card(
//                     elevation: 4,
//                     child: ListTile(
//                       title: Text(
//                         item["name"] ?? "No Name",
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 20,
//                         ),
//                       ),
//                       subtitle: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text("Phone: ${item["phone"] ?? "N/A"}"),
//                           Text("Email: ${item["email"] ?? "N/A"}"),
//                           Text("Vehicle: ${item["vehicleNumber"] ?? "N/A"}"),
//                         ],
//                       ),
//                       trailing: TextButton(
//                         onPressed: () {
//                           bookpickup(pickupItems[index]['_id']);
//                         },
//                         style: TextButton.styleFrom(
//                           backgroundColor: const Color.fromARGB(
//                             255,
//                             43,
//                             66,
//                             108,
//                           ),
//                         ),
//                         child: const Text(
//                           "Assign",
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }
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
  String? selectedPickupId;

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

  Future<void> bookpickup(String id, String name) async {
    try {
      setState(() {
        selectedPickupId = id;
      });

      final response = await dio.put(
        '$baseurl/api/booking/assignpickup/${widget.bid}',
        data: {'pickupPartnerId': id},
      );
      debugPrint(response.data.toString());

      if (response.statusCode == 200) {
        _showSnackBar('Assigned to $name successfully');
        // Optionally navigate back after a delay
        Future.delayed(Duration(milliseconds: 1500), () {
          Navigator.pop(context, true); // Return success
        });
      } else {
        setState(() {
          selectedPickupId = null;
        });
        _showSnackBar('Assignment failed');
      }
    } catch (e) {
      setState(() {
        selectedPickupId = null;
      });
      debugPrint("Error assigning pickup: $e");
      _showSnackBar('Error: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.grey.shade800,
      ),
    );
  }

  Widget _buildVehicleBadge(String vehicleNumber) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurple.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.directions_car,
            size: 14,
            color: Colors.deepPurple,
          ),
          SizedBox(width: 4),
          Text(
            vehicleNumber,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.deepPurple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickupCard(Map<String, dynamic> item, int index) {
    final name = item["name"] ?? "No Name";
    final phone = item["phone"] ?? "N/A";
    final email = item["email"] ?? "N/A";
    final vehicleNumber = item["vehicleNumber"] ?? "N/A";
    final pickupId = item['_id'];
    final isSelected = selectedPickupId == pickupId;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected ? Colors.lightBlueAccent : Colors.transparent,
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with name and vehicle badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.lightBlueAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.local_shipping,
                              color: Colors.lightBlueAccent,
                              size: 24,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: Colors.grey.shade800,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Pickup Partner #${index + 1}",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildVehicleBadge(vehicleNumber),
                ],
              ),

              SizedBox(height: 16),

              // Contact Information
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.phone,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            phone,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.email,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            email,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16),

              // Availability Badge (if available in API)
              if (item["isAvailable"] != null)
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: item["isAvailable"] == true
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: item["isAvailable"] == true
                          ? Colors.green.shade200
                          : Colors.red.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: item["isAvailable"] == true
                              ? Colors.green
                              : Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        item["isAvailable"] == true ? "Available Now" : "Currently Busy",
                        style: TextStyle(
                          fontSize: 14,
                          color: item["isAvailable"] == true
                              ? Colors.green.shade800
                              : Colors.red.shade800,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

              SizedBox(height: 16),

              // Assign Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isSelected
                      ? null
                      : () {
                          bookpickup(pickupId, name);
                        },
                  icon: Icon(
                    isSelected ? Icons.check_circle : Icons.assignment_turned_in,
                    size: 20,
                  ),
                  label: Text(
                    isSelected ? "Assigned" : "Assign This Partner",
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected
                        ? Colors.green.shade50
                        : Colors.lightBlueAccent,
                    foregroundColor: isSelected
                        ? Colors.green
                        : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected
                            ? Colors.green.shade200
                            : Colors.transparent,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14),
                    disabledBackgroundColor: Colors.grey.shade100,
                    disabledForegroundColor: Colors.grey.shade400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
          "Assign Pickup Partner",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.lightBlueAccent,
        centerTitle: true,
        elevation: 2,
      ),
      backgroundColor: Colors.grey.shade50,
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
                    strokeWidth: 2.5,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Loading pickup partners...",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : pickupItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.local_shipping,
                        size: 80,
                        color: Colors.grey.shade300,
                      ),
                      SizedBox(height: 16),
                      Text(
                        "No Pickup Partners Available",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Text(
                          "There are no pickup partners available at the moment",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => fetchPickupData(),
                        icon: Icon(Icons.refresh, size: 20),
                        label: Text("Refresh"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlueAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => fetchPickupData(),
                  color: Colors.lightBlueAccent,
                  child: Column(
                    children: [
                      // Header Info
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.lightBlueAccent.withOpacity(0.1),
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.lightBlueAccent.withOpacity(0.2),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.lightBlueAccent,
                              size: 20,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Select a pickup partner to assign this task",
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.lightBlueAccent.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "${pickupItems.length} available",
                                style: TextStyle(
                                  color: Colors.lightBlueAccent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Pickup Partners List
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.only(bottom: 16),
                          itemCount: pickupItems.length,
                          itemBuilder: (context, index) {
                            return _buildPickupCard(pickupItems[index], index);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}