// import 'package:flutter/material.dart';
// import 'package:mechconnect/service/home.dart';
// import 'package:mechconnect/service/mechanics.dart';
// import 'package:mechconnect/service/pickups.dart';
// import 'package:mechconnect/user/register.dart';

// class Viewrequest extends StatefulWidget {
//   const Viewrequest({super.key});

//   @override
//   State<Viewrequest> createState() => _ViewrequestState();
// }

// class _ViewrequestState extends State<Viewrequest> {
//   List<dynamic> requests = [];

//   Future<void> get_requests(BuildContext context) async {
//     try {
//       final response = await dio.get(
//         '$baseurl/api/booking/servicecenter/$sobid',
//       );
//       print(response.data);
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         setState(() {
//           requests = response.data["data"];

//           // Local UI state
//           for (var r in requests) {
//             r["accepted"] = false;
//           }
//         });
//       }
//     } catch (e) {
//       debugPrint(e.toString());
//     }
//   }

//   Future<void> post_status(
//     BuildContext context,
//     String id,
//     String status,
//   ) async {
//     try {
//       await dio.put(
//         '$baseurl/api/booking/$id/status',
//         data: {'status': status},
//       );
//     } catch (e) {
//       debugPrint(e.toString());
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     get_requests(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "View Request",
//           style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
//         ),
//         backgroundColor: Colors.lightBlueAccent,
//       ),
//       body: requests.isEmpty
//           ? const Center(child: CircularProgressIndicator())
//           : ListView.builder(
//               itemCount: requests.length,
//               itemBuilder: (context, index) {
//                 final req = requests[index];
//                 final vehicle = req["vehicleId"];
//                 final userLoc = req["userLocation"];
//                 final imageUrl = "$baseurl/${req['problemImage']}";

//                 return Padding(
//                   padding: const EdgeInsets.all(10),
//                   child: Card(
//                     elevation: 4,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(12),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // ================= IMAGE =================
//                           if (req["problemImage"] != null)
//                             ClipRRect(
//                               borderRadius: BorderRadius.circular(10),
//                               child: Image.network(
//                                 imageUrl,
//                                 height: 200,
//                                 width: double.infinity,
//                                 fit: BoxFit.cover,
//                               ),
//                             )
//                           else
//                             Container(
//                               height: 150,
//                               color: Colors.grey[300],
//                               child: const Center(
//                                 child: Text("No Image Uploaded"),
//                               ),
//                             ),

//                           const SizedBox(height: 10),

//                           // ================= ISSUE =================
//                           Text(
//                             req["problemDescription"] ?? "No issue",
//                             style: const TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),

//                           const SizedBox(height: 6),

//                           // ================= LOCATION =================
//                           Text(
//                             "LAT: ${userLoc["lat"]}, LNG: ${userLoc["lng"]}",
//                           ),

//                           const Divider(height: 20),

//                           // ================= VEHICLE DETAILS =================
//                           if (vehicle != null) ...[
//                             const Text(
//                               "Vehicle Details",
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.blue,
//                               ),
//                             ),
//                             const SizedBox(height: 6),
//                             Row(
//                               children: [
//                                 const Icon(Icons.motorcycle),
//                                 const SizedBox(width: 6),
//                                 Text(
//                                   "${vehicle["brand"]} ${vehicle["model"]}",
//                                   style: const TextStyle(
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             Text("Year : ${vehicle["year"]}"),
//                             Text("Vehicle No : ${vehicle["vehicleNumber"]}"),
//                             Text("Fuel : ${vehicle["fuelType"]}"),
//                             Text("Type : ${vehicle["vehicleType"]}"),
//                           ],

//                           const SizedBox(height: 12),

//                           // ================= ACTION BUTTONS =================
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.end,
//                             children: [
//                               if (req["accepted"] == false) ...[
//                                 TextButton(
//                                   onPressed: () {
//                                     setState(() {
//                                       req["accepted"] = true;
//                                     });
//                                     post_status(
//                                       context,
//                                       req['_id'],
//                                       'accepted',
//                                     );
//                                   },
//                                   style: TextButton.styleFrom(
//                                     backgroundColor: Colors.green,
//                                   ),
//                                   child: const Text(
//                                     "Accept",
//                                     style: TextStyle(color: Colors.white),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 10),
//                                 TextButton(
//                                   onPressed: () {
//                                     setState(() {
//                                       req["accepted"] = "rejected";
//                                     });
//                                     post_status(
//                                       context,
//                                       req['_id'],
//                                       'rejected',
//                                     );
//                                   },
//                                   style: TextButton.styleFrom(
//                                     backgroundColor: Colors.red,
//                                   ),
//                                   child: const Text(
//                                     "Reject",
//                                     style: TextStyle(color: Colors.white),
//                                   ),
//                                 ),
//                               ],

//                               if (req["accepted"] == "rejected") ...[
//                                 const Text(
//                                   "Rejected",
//                                   style: TextStyle(
//                                     color: Colors.red,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ],

//                               if (req["accepted"] == true) ...[
//                                 TextButton(
//                                   onPressed: () {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (_) => Assign(bid: req['_id']),
//                                       ),
//                                     );
//                                   },
//                                   style: TextButton.styleFrom(
//                                     backgroundColor: Colors.blue,
//                                   ),
//                                   child: const Text(
//                                     "Mechanic",
//                                     style: TextStyle(color: Colors.white),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 10),
//                                 TextButton(
//                                   onPressed: () {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (_) =>
//                                             Pickups(bid: req['_id']),
//                                       ),
//                                     );
//                                   },
//                                   style: TextButton.styleFrom(
//                                     backgroundColor: Colors.orange,
//                                   ),
//                                   child: const Text(
//                                     "Pick Up",
//                                     style: TextStyle(color: Colors.white),
//                                   ),
//                                 ),
//                               ],
//                             ],
//                           ),
//                         ],
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
  bool isLoading = true;

  Future<void> get_requests(BuildContext context) async {
    try {
      setState(() => isLoading = true);
      final response = await dio.get(
        '$baseurl/api/booking/servicecenter/$sobid',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          requests = response.data["data"] ?? [];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        _showSnackBar('Failed to load requests');
      }
    } catch (e) {
      debugPrint(e.toString());
      setState(() => isLoading = false);
      _showSnackBar('Error: $e');
    }
  }

  Future<void> post_status(
      BuildContext context, String id, String status) async {
    try {
      final response = await dio.put(
        '$baseurl/api/booking/$id/status',
        data: {'status': status},
      );

      if (response.statusCode == 200) {
        // Find and update the request status locally
        setState(() {
          final index = requests.indexWhere((req) => req['_id'] == id);
          if (index != -1) {
            requests[index]['status'] = status;
            // If status is accepted, set accepted flag to true
            if (status == 'accepted') {
              requests[index]['accepted'] = true;
            }
          }
        });
        
        _showSnackBar('Request $status successfully');
      }
    } catch (e) {
      debugPrint(e.toString());
      _showSnackBar('Error updating status');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.grey.shade800,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status?.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'assigned':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status?.toLowerCase()) {
      case 'accepted':
        return "Accepted";
      case 'rejected':
        return "Rejected";
      case 'assigned':
        return "Assigned";
      case 'pending':
        return "Pending";
      default:
        return "New Request";
    }
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getStatusColor(status).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status == 'accepted'
                ? Icons.check_circle
                : status == 'rejected'
                    ? Icons.cancel
                    : status == 'assigned'
                        ? Icons.assignment_turned_in
                        : Icons.pending,
            size: 14,
            color: _getStatusColor(status),
          ),
          SizedBox(width: 4),
          Text(
            _getStatusText(status).toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _getStatusColor(status),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleInfo(Map<String, dynamic> vehicle) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Vehicle Details",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8),
          if (vehicle["brand"] != null || vehicle["model"] != null)
            Text(
              "${vehicle["brand"] ?? ""} ${vehicle["model"] ?? ""}".trim(),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
          if (vehicle["vehicleNumber"] != null)
            Text(
              "Number: ${vehicle["vehicleNumber"]}",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          if (vehicle["year"] != null)
            Text(
              "Year: ${vehicle["year"]}",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          if (vehicle["fuelType"] != null)
            Text(
              "Fuel: ${vehicle["fuelType"]}",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          if (vehicle["vehicleType"] != null)
            Text(
              "Type: ${vehicle["vehicleType"]}",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
        ],
      ),
    );
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
          "Service Requests",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.lightBlueAccent,
        centerTitle: true,
      ),
      backgroundColor: Colors.grey.shade50,
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
              ),
            )
          : requests.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.request_quote,
                        size: 80,
                        color: Colors.grey.shade300,
                      ),
                      SizedBox(height: 16),
                      Text(
                        "No Service Requests",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Service requests will appear here",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => get_requests(context),
                  color: Colors.lightBlueAccent,
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final req = requests[index];
                      final vehicle = req["vehicleId"] ?? {};
                      final userLoc = req["userLocation"] ?? {};
                      final imageUrl = req["problemImage"] != null
                          ? "$baseurl/${req['problemImage']}"
                          : null;
                      final currentStatus = req["status"]?.toString() ?? "pending";
                      final isAccepted = currentStatus == "accepted";
                      final isRejected = currentStatus == "rejected";
                      final isAssigned = currentStatus == "assigned" || 
                                         (req["mechanicId"] != null && req["mechanicId"]["_id"] != null) ||
                                         (req["pickupPartnerId"] != null && req["pickupPartnerId"]["_id"] != null);
                      final isPending = currentStatus == "pending" && !isAssigned;

                      return Container(
                        margin: EdgeInsets.only(bottom: 20),
                        child: Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// HEADER with Request Number and Status
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.lightBlueAccent
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        "Request #${index + 1}",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.lightBlueAccent,
                                        ),
                                      ),
                                    ),
                                    _buildStatusBadge(
                                      isAssigned ? "assigned" : currentStatus,
                                    ),
                                  ],
                                ),

                                SizedBox(height: 16),

                                /// IMAGE
                                if (imageUrl != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      imageUrl,
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (BuildContext context,
                                          Widget child,
                                          ImageChunkEvent? loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Container(
                                          height: 200,
                                          width: double.infinity,
                                          color: Colors.grey.shade100,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          height: 200,
                                          width: double.infinity,
                                          color: Colors.grey.shade100,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.error,
                                                  color: Colors.grey.shade400),
                                              SizedBox(height: 8),
                                              Text(
                                                'Failed to load image',
                                                style: TextStyle(
                                                  color: Colors.grey.shade500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                                if (imageUrl == null)
                                  Container(
                                    height: 150,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.no_photography,
                                          size: 40,
                                          color: Colors.grey.shade400,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          "No Image Uploaded",
                                          style: TextStyle(
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                SizedBox(height: 16),

                                /// PROBLEM DESCRIPTION
                                Text(
                                  "Problem Description",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  req["problemDescription"] ??
                                      "No description provided",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey.shade800,
                                    height: 1.4,
                                  ),
                                ),

                                SizedBox(height: 16),

                                /// LOCATION
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Colors.blue.shade100),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.location_pin,
                                        size: 20,
                                        color: Colors.blue.shade700,
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Service Location",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.blue.shade700,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              "Lat: ${userLoc["lat"]?.toStringAsFixed(6) ?? "-"}, "
                                              "Lng: ${userLoc["lng"]?.toStringAsFixed(6) ?? "-"}",
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.blue.shade800,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 16),

                                /// VEHICLE INFORMATION
                                _buildVehicleInfo(vehicle),

                                SizedBox(height: 20),

                                /// ✅ ACCEPT/REJECT BUTTONS (ONLY SHOW FOR PENDING STATUS)
                                if (isPending)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Action Required",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: () {
                                                post_status(
                                                    context, req['_id'], 'accepted');
                                              },
                                              icon: Icon(Icons.check_circle,
                                                  size: 20),
                                              label: Text("Accept",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600)),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 14),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: () {
                                                post_status(
                                                    context, req['_id'], 'rejected');
                                              },
                                              icon: Icon(Icons.cancel,
                                                  size: 20),
                                              label: Text("Reject",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600)),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 14),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                /// ✅ MECHANIC/PICKUP BUTTONS (ONLY SHOW FOR ACCEPTED STATUS)
                                if (isAccepted && !isAssigned)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Assign Service",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        Assign(bid: req['_id']),
                                                  ),
                                                ).then((_) {
                                                  // Refresh after returning from assignment
                                                  get_requests(context);
                                                });
                                              },
                                              icon: Icon(Icons.person,
                                                  size: 20),
                                              label: Text("Assign Mechanic",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600)),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.blue,
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 14),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        Pickups(bid: req['_id']),
                                                  ),
                                                ).then((_) {
                                                  // Refresh after returning from assignment
                                                  get_requests(context);
                                                });
                                              },
                                              icon: Icon(Icons.local_shipping,
                                                  size: 20),
                                              label: Text("Assign Pickup",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600)),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.orange,
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 14),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                /// ✅ ASSIGNED STATUS MESSAGE
                                if (isAssigned)
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.blue.shade200,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.assignment_turned_in,
                                          color: Colors.blue,
                                          size: 20,
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Service Assigned",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.blue.shade800,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              if (req["mechanicId"] != null &&
                                                  req["mechanicId"]["_id"] !=
                                                      null)
                                                Text(
                                                  "Mechanic: ${req["mechanicId"]["mechanicName"] ?? "N/A"}",
                                                  style: TextStyle(
                                                    color:
                                                        Colors.blue.shade700,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              if (req["pickupPartnerId"] !=
                                                      null &&
                                                  req["pickupPartnerId"]
                                                          ["_id"] !=
                                                      null)
                                                Text(
                                                  "Pickup Partner: ${req["pickupPartnerId"]["name"] ?? "N/A"}",
                                                  style: TextStyle(
                                                    color:
                                                        Colors.blue.shade700,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                /// ✅ REJECTED STATUS MESSAGE
                                if (isRejected)
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.red.shade200,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.cancel,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            "This request has been rejected",
                                            style: TextStyle(
                                              color: Colors.red.shade800,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
} 