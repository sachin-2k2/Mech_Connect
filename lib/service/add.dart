// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart';
// import 'package:mechconnect/mechanic/home.dart';
// import 'package:mechconnect/service/home.dart';
// import 'package:mechconnect/user/register.dart'; // make sure this has your Dio instance & baseurl

// class Add extends StatefulWidget {
//   const Add({super.key});

//   @override
//   State<Add> createState() => _AddState();
// }

// class _AddState extends State<Add> {
//   List<dynamic> mechanicItems = [];
//   List<dynamic> pickupItems = [];

//   bool isLoadingMechanic = true;
//   bool isLoadingPickup = true;

//   // Track request status per item
//   Map<String, String> mechanicRequestStatus = {};
//   Map<String, String> pickupRequestStatus = {};

//   @override
//   void initState() {
//     super.initState();
//     fetchMechanicData();
//     fetchPickupData();
//   }

//   // ----------------------------
//   // FETCH MECHANIC DATA
//   // ----------------------------
//   Future<void> fetchMechanicData() async {
//     try {
//       final response = await dio.get(
//         '$baseurl/api/mechanic/viewmechanic/$sobid',
//       );
//       print(response.data);
//       if (response.statusCode == 200) {
//         setState(() {
//           mechanicItems = response.data["data"] ?? [];
//           isLoadingMechanic = false;
//         });
//       }
//     } catch (e) {
//       print("Error fetching mechanic data: $e");
//       setState(() {
//         isLoadingMechanic = false;
//       });
//     }
//   }

//   // ----------------------------
//   // FETCH PICKUP DATA
//   // ----------------------------
//   Future<void> fetchPickupData() async {
//     try {
//       final response = await dio.get('$baseurl/api/user/pickups');
//       if (response.statusCode == 200) {
//         setState(() {
//           pickupItems = response.data["data"] ?? [];
//           isLoadingPickup = false;
//         });
//       }
//     } catch (e) {
//       print("Error fetching pickup data: $e");
//       setState(() {
//         isLoadingPickup = false;
//       });
//     }
//   }

//   // ----------------------------
//   // POST REQUEST FOR MECHANIC
//   // ----------------------------
//   Future<void> post_reqmech(
//     BuildContext context,
//     String mechanicId,
//     String reqid,
//     String status,
//   ) async {
//     try {
//       final response = await dio.post(
//         '$baseurl/api/mechanic/respond/$mechanicId',
//         data: {'requestId': reqid, 'action': status},
//       );

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         setState(() {
//           mechanicRequestStatus[mechanicId] = 'Requested';
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Request sent successfully')),
//         );
//       } else {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text('Request failed')));
//       }
//     } catch (e) {
//       print("❌ error: $e");
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error: $e')));
//     }
//   }

//   // ----------------------------
//   // POST REQUEST FOR PICKUP
//   // ----------------------------
//   Future<void> post_reqpic(BuildContext context, String pickupId) async {
//     try {
//       final response = await dio.post(
//         '$baseurl/api/mechanic/request',
//         data: {'mechanicId': pickupId},
//       );

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         setState(() {
//           pickupRequestStatus[pickupId] = 'Requested';
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Request sent successfully')),
//         );
//       } else {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text('Request failed')));
//       }
//     } catch (e) {
//       print("❌ error: $e");
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error: $e')));
//     }
//   }

//   // ----------------------------
//   // BUILD LIST WIDGET
//   // ----------------------------
//   Widget buildList(List<dynamic> items, bool isLoading, bool isMechanic) {
//     if (isLoading) return Center(child: CircularProgressIndicator());
//     if (items.isEmpty) return Center(child: Text("No requests available"));

//     return ListView.builder(
//       itemCount: items.length,
//       itemBuilder: (context, index) {
//         var item = items[index];
//         String id = item['_id'];

//         String name = isMechanic
//             ? item["mechanicName"] ?? "N/A"
//             : item["name"] ?? "N/A";
//         String phone = item["phone"] ?? "-";
//         String email = item["email"] ?? "-";
//         String location = isMechanic
//             ? "N/A"
//             : (item["location"] != null
//                   ? "Lat: ${item["location"]["lat"]}, Lng: ${item["location"]["lng"]}"
//                   : "N/A");
//         String vehicle = isMechanic
//             ? "-"
//             : (item["vehicleNumber"]?.toString() ?? "-");
//         String certificate = item["certificateImg"] ?? "-";

//         String status = isMechanic
//             ? mechanicRequestStatus[id] ?? "Accept"
//             : pickupRequestStatus[id] ?? "Accept";

//         return Padding(
//           padding: const EdgeInsets.all(10.0),
//           child: Card(
//             child: ListTile(
//               title: Text(name),
//               subtitle: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text("Contact: $phone"),
//                   Text("Email: $email"),
//                   if (!isMechanic) Text("Vehicle: $vehicle"),
//                   if (!isMechanic) Text("Location: $location"),
//                   Text("Certificate: $certificate"),
//                   SizedBox(height: 10),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       TextButton(
//                         onPressed: status == "Requested"
//                             ? null
//                             : () {
//                                 if (isMechanic) {
//                                   post_reqmech(
//                                     context,
//                                     mechanicItems[index]['_id'],
//                                     mechanicItems[index]['requests'][0]['_id'],
//                                     'accept',
//                                   );
//                                 } else {
//                                   post_reqpic(
//                                     context,
//                                     pickupItems[index]['_id'],
//                                   );
//                                 }
//                               },
//                         child: Text(
//                           status,
//                           style: TextStyle(color: Colors.white),
//                         ),
//                         style: TextButton.styleFrom(
//                           backgroundColor: status == "Requested"
//                               ? Colors.grey
//                               : Colors.green,
//                         ),
//                       ),
//                       SizedBox(width: 10),
//                       TextButton(
//                         onPressed: () {
//                           ScaffoldMessenger.of(
//                             context,
//                           ).showSnackBar(SnackBar(content: Text("Rejected")));
//                           setState(() {
//                             if (isMechanic) {
//                               mechanicRequestStatus[id] = "Accept";
//                             } else {
//                               pickupRequestStatus[id] = "Accept";
//                             }
//                           });
//                         },
//                         child: Text(
//                           "Reject",
//                           style: TextStyle(color: Colors.white),
//                         ),
//                         style: TextButton.styleFrom(
//                           backgroundColor: Colors.red,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // ----------------------------
//   // BUILD UI
//   // ----------------------------
//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 2,
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text("Request Details"),
//           backgroundColor: Colors.lightBlueAccent,
//           bottom: TabBar(
//             tabs: [
//               Tab(text: "Mechanic"),
//               Tab(text: "Pickup"),
//             ],
//           ),
//         ),
//         body: TabBarView(
//           children: [
//             buildList(mechanicItems, isLoadingMechanic, true),
//             buildList(pickupItems, isLoadingPickup, false),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:mechconnect/mechanic/home.dart';
import 'package:mechconnect/service/home.dart';
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
      final response = await dio.get(
        '$baseurl/api/mechanic/viewmechanic/$sobid',
      );
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
  // POST REQUEST FOR MECHANIC
  // ----------------------------
  Future<void> post_reqmech(
    BuildContext context,
    String mechanicId,
    String reqid,
    String status,
    int index,
  ) async {
    try {
      final response = await dio.post(
        '$baseurl/api/mechanic/respond/$mechanicId',
        data: {'requestId': reqid, 'action': status},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          // Update the status in the item
          for (var req in mechanicItems[index]['requests']) {
            if (req['_id'] == reqid) {
              req['status'] = status == 'accept' ? 'accepted' : 'rejected';
              break;
            }
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Request ${status == 'accept' ? 'accepted' : 'rejected'} successfully'),
            backgroundColor: status == 'accept' ? Colors.green : Colors.orange,
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Request failed')));
      }
    } catch (e) {
      print("❌ error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // ----------------------------
  // POST REQUEST FOR PICKUP
  // ----------------------------
  Future<void> post_reqpic(BuildContext context, String pickupId, int index) async {
    try {
      final response = await dio.post(
        '$baseurl/api/mechanic/request',
        data: {'mechanicId': pickupId},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          // Update the status for pickup
          pickupItems[index]['requestStatus'] = 'pending';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request sent successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Request failed')));
      }
    } catch (e) {
      print("❌ error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // Helper function to get current request status for this service center
  String _getRequestStatus(dynamic item, bool isMechanic) {
    if (isMechanic) {
      // For mechanics, check the requests array for the current service center
      if (item['requests'] != null && item['requests'].isNotEmpty) {
        for (var request in item['requests']) {
          if (request['serviceCenterId'] == sobid) {
            return request['status'] ?? 'none'; // 'accepted', 'rejected', 'pending', or 'none'
          }
        }
      }
      return 'none'; // No request found for this service center
    } else {
      // For pickups, use requestStatus field
      return item['requestStatus'] ?? 'none';
    }
  }

  // Helper to get the request ID for this service center
  String? _getRequestId(dynamic item) {
    if (item['requests'] != null && item['requests'].isNotEmpty) {
      for (var request in item['requests']) {
        if (request['serviceCenterId'] == sobid) {
          return request['_id'];
        }
      }
    }
    return null;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      case 'pending':
        return 'Pending';
      case 'none':
        return 'No Request';
      default:
        return 'Unknown';
    }
  }

  // ----------------------------
  // BUILD LIST WIDGET
  // ----------------------------
  Widget buildList(List<dynamic> items, bool isLoading, bool isMechanic) {
    if (isLoading) return Center(child: CircularProgressIndicator());
    if (items.isEmpty) return Center(child: Text("No requests available"));

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        var item = items[index];
        String id = item['_id'];

        String name = isMechanic
            ? item["mechanicName"] ?? "N/A"
            : item["name"] ?? "N/A";
        String phone = item["phone"] ?? "-";
        String email = item["email"] ?? "-";
        String location = isMechanic
            ? "N/A"
            : (item["location"] != null
                  ? "Lat: ${item["location"]["lat"]}, Lng: ${item["location"]["lng"]}"
                  : "N/A");
        String vehicle = isMechanic
            ? "-"
            : (item["vehicleNumber"]?.toString() ?? "-");
        String certificate = item["certificateImg"] ?? "-";

        String status = _getRequestStatus(item, isMechanic);
        bool isAccepted = status == 'accepted';
        bool isRejected = status == 'rejected';
        bool isPending = status == 'pending';
        bool isNone = status == 'none';
        
        // Show Accept/Reject buttons only when status is "pending"
        bool showButtons = isPending;

        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Status Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _getStatusColor(status).withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          _getStatusText(status).toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _getStatusColor(status),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 12),

                  // Contact Info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("📞 $phone"),
                      SizedBox(height: 4),
                      Text("📧 $email"),
                      if (!isMechanic) SizedBox(height: 4),
                      if (!isMechanic) Text("🚗 $vehicle"),
                      if (!isMechanic) SizedBox(height: 4),
                      if (!isMechanic) Text("📍 $location"),
                      SizedBox(height: 4),
                      Text(
                        "Certificate: ${certificate.split('/').last}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  // Accept/Reject Buttons (ONLY SHOW WHEN STATUS IS "pending")
                  if (showButtons)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Action Required",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                if (isMechanic) {
                                  String? requestId = _getRequestId(item);
                                  if (requestId != null) {
                                    post_reqmech(
                                      context,
                                      id,
                                      requestId,
                                      'accept',
                                      index,
                                    );
                                  }
                                } else {
                                  // For pickup - this should not happen as pickups don't have pending status
                                  post_reqpic(context, id, index);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              ),
                              child: Text('Accept'),
                            ),
                            SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {
                                if (isMechanic) {
                                  String? requestId = _getRequestId(item);
                                  if (requestId != null) {
                                    post_reqmech(
                                      context,
                                      id,
                                      requestId,
                                      'reject',
                                      index,
                                    );
                                  }
                                } else {
                                  // For pickup - this should not happen as pickups don't have pending status
                                  setState(() {
                                    pickupItems[index]['requestStatus'] = 'rejected';
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Rejected"),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              ),
                              child: Text('Reject'),
                            ),
                          ],
                        ),
                      ],
                    ),

                  // Status message for accepted/rejected
                  if (isAccepted || isRejected)
                    Container(
                      padding: EdgeInsets.all(12),
                      margin: EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: isAccepted
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isAccepted
                              ? Colors.green.shade200
                              : Colors.red.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isAccepted
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: isAccepted
                                ? Colors.green
                                : Colors.red,
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              isAccepted
                                  ? "This request has been accepted"
                                  : "This request has been rejected",
                              style: TextStyle(
                                color: isAccepted
                                    ? Colors.green.shade800
                                    : Colors.red.shade800,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Message for no request (none)
                  if (isNone)
                    Container(
                      padding: EdgeInsets.all(12),
                      margin: EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.blue.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info,
                            color: Colors.blue,
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "No request from this ${isMechanic ? 'mechanic' : 'pickup'}",
                              style: TextStyle(
                                color: Colors.blue.shade800,
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
          title: Text(
            "Request Details",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.lightBlueAccent,
          centerTitle: true,
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelStyle: TextStyle(fontWeight: FontWeight.w600),
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