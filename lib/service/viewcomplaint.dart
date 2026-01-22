// import 'package:flutter/material.dart';
// import 'package:mechconnect/service/home.dart';
// import 'package:mechconnect/service/sendreply.dart';
// import 'package:mechconnect/user/register.dart';

// class Viewcomplaint extends StatefulWidget {
//   Viewcomplaint({super.key});

//   @override
//   State<Viewcomplaint> createState() => _ViewcomplaintState();
// }

// class _ViewcomplaintState extends State<Viewcomplaint> {
//   List<dynamic> complaints = [];

//   Future<void> get_complaint(context) async {
//     try {
//       final response = await dio.get(
//         '$baseurl/api/complaints/servicecenter/$sobid',
//       );

//       print(response.data);

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         complaints = response.data["data"];
//         setState(() {});
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load complaints')),
//         );
//       }
//     } catch (e) {
//       print(e);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//     }
//   }

//   // ********** SEND REPLY FUNCTION **********
//   Future<void> sendReply(String complaintId, String reply) async {
//     try {
//       final response = await dio.put(
//         '$baseurl/api/complaints/reply/$complaintId',
//         data: {"reply": reply},
//       );

//       print("Reply sent: ${response.data}");
//     } catch (e) {
//       print("Error sending reply: $e");
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     get_complaint(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Complaints"),
//         backgroundColor: Colors.lightBlueAccent,
//       ),
//       body: complaints.isEmpty
//           ? Center(child: CircularProgressIndicator())
//           : ListView.builder(
//               itemCount: complaints.length,
//               itemBuilder: (context, index) {
//                 final item = complaints[index];
//                 final hasReply = item["reply"] != null &&
//                     item["reply"].toString().trim().isNotEmpty;

//                 return Padding(
//                   padding: const EdgeInsets.all(10.0),
//                   child: Card(
//                     child: ListTile(
//                       title: Text(item["userId"]["name"]),
//                       subtitle: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(item["message"]),
//                           if (hasReply)
//                             Padding(
//                               padding: const EdgeInsets.only(top: 8.0),
//                               child: Text(
//                                 "Reply: ${item["reply"]}",
//                                 style: TextStyle(
//                                     color: Colors.green,
//                                     fontWeight: FontWeight.bold),
//                               ),
//                             ),
//                         ],
//                       ),

//                       // ********** REPLY BUTTON OR "REPLIED" LABEL **********
//                       trailing: hasReply
//                           ? Text(
//                               "Replied",
//                               style: TextStyle(
//                                 color: Colors.green,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             )
//                           : TextButton(
//                               onPressed: () {
//                                 TextEditingController replyController =
//                                     TextEditingController();

//                                 showDialog(
//                                   context: context,
//                                   builder: (context) {
//                                     return AlertDialog(
//                                       title: Text("Send Reply"),
//                                       content: TextField(
//                                         controller: replyController,
//                                         maxLines: 4,
//                                         decoration: InputDecoration(
//                                           hintText: "Type your reply...",
//                                           border: OutlineInputBorder(),
//                                         ),
//                                       ),
//                                       actions: [
//                                         TextButton(
//                                           onPressed: () {
//                                             Navigator.pop(context);
//                                           },
//                                           child: Text("Cancel"),
//                                         ),
//                                         ElevatedButton(
//                                           onPressed: () async {
//                                             String reply = replyController.text.trim();

//                                             if (reply.isEmpty) {
//                                               ScaffoldMessenger.of(context).showSnackBar(
//                                                 SnackBar(
//                                                   content: Text("Reply cannot be empty"),
//                                                 ),
//                                               );
//                                               return;
//                                             }

//                                             await sendReply(item["_id"], reply);

//                                             Navigator.pop(context);

//                                             ScaffoldMessenger.of(context).showSnackBar(
//                                               SnackBar(content: Text("Reply sent successfully")),
//                                             );

//                                             // Refresh list
//                                             get_complaint(context);
//                                           },
//                                           child: Text("Send"),
//                                         ),
//                                       ],
//                                     );
//                                   },
//                                 );
//                               },
//                               style: TextButton.styleFrom(
//                                 backgroundColor: Colors.blue,
//                               ),
//                               child: Text(
//                                 "Send reply",
//                                 style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.white),
//                               ),
//                             ),
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
import 'package:mechconnect/service/sendreply.dart';
import 'package:mechconnect/user/register.dart';
import 'package:intl/intl.dart';

class Viewcomplaint extends StatefulWidget {
  Viewcomplaint({super.key});

  @override
  State<Viewcomplaint> createState() => _ViewcomplaintState();
}

class _ViewcomplaintState extends State<Viewcomplaint> {
  List<dynamic> complaints = [];
  bool isLoading = true;

  Future<void> get_complaint(context) async {
    try {
      setState(() {
        isLoading = true;
      });

      final response = await dio.get(
        '$baseurl/api/complaints/servicecenter/$sobid',
      );

      print(response.data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          complaints = response.data["data"] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        _showSnackBar('Failed to load complaints');
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
      _showSnackBar('Error: $e');
    }
  }

  // ********** SEND REPLY FUNCTION **********
  Future<bool> sendReply(String complaintId, String reply, int index) async {
    try {
      final response = await dio.put(
        '$baseurl/api/complaints/reply/$complaintId',
        data: {"reply": reply},
      );

      print("Reply sent: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          complaints[index]["reply"] = reply;
          complaints[index]["repliedAt"] = DateTime.now().toIso8601String();
        });
        _showSnackBar('Reply sent successfully');
        return true;
      } else {
        _showSnackBar('Failed to send reply');
        return false;
      }
    } catch (e) {
      print("Error sending reply: $e");
      _showSnackBar('Error: $e');
      return false;
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

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy · hh:mm a').format(date);
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildStatusBadge(bool hasReply) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: hasReply ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasReply ? Colors.green.shade200 : Colors.orange.shade200,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasReply ? Icons.check_circle : Icons.pending,
            size: 14,
            color: hasReply ? Colors.green : Colors.orange,
          ),
          SizedBox(width: 4),
          Text(
            hasReply ? "Replied" : "Pending",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: hasReply ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  void _showReplyDialog(BuildContext context, int index) {
    final item = complaints[index];
    final TextEditingController replyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: BoxConstraints(maxWidth: 500),
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.lightBlueAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.reply,
                        color: Colors.lightBlueAccent,
                        size: 22,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Reply to Complaint",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16),

                // Complaint Preview
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "From: ${item["userId"]["name"]}",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        item["message"],
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // Reply Field
                Text(
                  "Your Reply",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: replyController,
                    maxLines: 5,
                    maxLength: 500,
                    style: TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: "Type your reply here...",
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.lightBlueAccent,
                          width: 2,
                        ),
                      ),
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                ),

                SizedBox(height: 24),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async {
                        String reply = replyController.text.trim();

                        if (reply.isEmpty) {
                          _showSnackBar("Reply cannot be empty");
                          return;
                        }

                        bool success = await sendReply(
                            item["_id"], reply, index);

                        if (success) {
                          Navigator.pop(context);
                        }
                      },
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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.send, size: 18),
                          SizedBox(width: 8),
                          Text(
                            "Send Reply",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildComplaintCard(Map<String, dynamic> item, int index) {
    final userName = item["userId"]["name"] ?? "Unknown User";
    final message = item["message"] ?? "";
    final hasReply = item["reply"] != null &&
        item["reply"].toString().trim().isNotEmpty;
    final reply = item["reply"] ?? "";
    final createdAt = item["createdAt"]?.toString() ?? "";
    final repliedAt = item["repliedAt"]?.toString() ?? "";

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
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with user and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.lightBlueAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.person,
                              color: Colors.lightBlueAccent,
                              size: 20,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "Complaint #${index + 1}",
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
                  _buildStatusBadge(hasReply),
                ],
              ),

              SizedBox(height: 16),

              // Complaint Message
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.report_problem,
                          size: 18,
                          color: Colors.red,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Complaint",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      message,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Timestamp
              if (createdAt.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      SizedBox(width: 6),
                      Text(
                        _formatDate(createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

              // Reply Section
              if (hasReply) ...[
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade100),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.reply,
                            size: 18,
                            color: Colors.green,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Your Reply",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        reply,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                if (repliedAt.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 14,
                          color: Colors.green,
                        ),
                        SizedBox(width: 6),
                        Text(
                          "Replied on ${_formatDate(repliedAt)}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],

              SizedBox(height: 16),

              // Action Button
              if (!hasReply)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showReplyDialog(context, index);
                    },
                    icon: Icon(Icons.reply, size: 18),
                    label: Text("Reply to Complaint"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14),
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
    get_complaint(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Complaints",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
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
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
                    strokeWidth: 2.5,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Loading complaints...",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : complaints.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox,
                        size: 80,
                        color: Colors.grey.shade300,
                      ),
                      SizedBox(height: 16),
                      Text(
                        "No Complaints",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "All complaints will appear here",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => get_complaint(context),
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
                  onRefresh: () => get_complaint(context),
                  color: Colors.lightBlueAccent,
                  child: Column(
                    children: [
                      // Stats Header
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
                              Icons.report,
                              color: Colors.lightBlueAccent,
                              size: 20,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Customer Complaints",
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
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
                                "${complaints.length} total",
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

                      // Complaints List
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.only(bottom: 16),
                          itemCount: complaints.length,
                          itemBuilder: (context, index) {
                            return _buildComplaintCard(complaints[index], index);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}