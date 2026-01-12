import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:mechconnect/user/home.dart';
import 'package:mechconnect/user/register.dart';

class Complaint extends StatefulWidget {
  final String serviceid;
  Complaint({super.key, required this.serviceid});

  @override
  State<Complaint> createState() => _ComplaintState();
}

class _ComplaintState extends State<Complaint> {
  TextEditingController complaint = TextEditingController();
  final formkey = GlobalKey<FormState>();
  List<dynamic> complaints = [];
  bool isLoading = true;
  bool isSubmitting = false;

  // ---------------- POST COMPLAINT ----------------
  Future<void> post_complaint() async {
    if (isSubmitting || complaint.text.trim().isEmpty) return;

    setState(() {
      isSubmitting = true;
    });

    try {
      final response = await dio.post(
        '$baseurl/api/complaints/create',
        data: {
          'message': complaint.text.trim(),
          'userId': obid,
          'serviceCenterId': widget.serviceid,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Complaint submitted successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        complaint.clear();
        await get_replay(); // Refresh complaint list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit complaint'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Error posting complaint: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  // ---------------- GET REPLIES ----------------
  Future<void> get_replay() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await dio.get('$baseurl/api/complaints/user/$obid');
      print(response.data);
      
      if (response.statusCode == 200) {
        setState(() {
          complaints = response.data['data'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error fetching complaints: $e");
      setState(() => isLoading = false);
    }
  }

  String _formatDate(String dateString) {
    try {
      if (dateString.isEmpty) return "Unknown";
      final dateTime = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
    } catch (e) {
      return "Unknown";
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      get_replay();
    });
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
                            "Complaints",
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
                      "Share your concerns with service centers",
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
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        // Complaint Form Card
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                            border: Border.all(
                              color: Colors.blue.shade100,
                              width: 1,
                            ),
                          ),
                          child: Form(
                            key: formkey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Submit New Complaint",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade900,
                                  ),
                                ),
                                SizedBox(height: 15),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: TextFormField(
                                    controller: complaint,
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return "Please describe your complaint";
                                      }
                                      return null;
                                    },
                                    maxLines: 4,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.all(15),
                                      hintText:
                                          "Describe your issue with the service...",
                                      hintStyle: TextStyle(
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                SizedBox(height: 20),
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: isSubmitting
                                        ? null
                                        : () {
                                            if (formkey.currentState!.validate()) {
                                              post_complaint();
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue.shade700,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 5,
                                    ),
                                    child: isSubmitting
                                        ? SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.report_problem,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                              SizedBox(width: 10),
                                              Text(
                                                "SUBMIT COMPLAINT",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 25),

                        // Complaint History Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Complaint History",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900,
                              ),
                            ),
                            IconButton(
                              onPressed: get_replay,
                              icon: Icon(
                                Icons.refresh,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),

                        // Complaint List
                        Expanded(
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
                                        "Loading complaints...",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : complaints.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.chat_bubble_outline,
                                            size: 80,
                                            color: Colors.grey.shade300,
                                          ),
                                          SizedBox(height: 20),
                                          Text(
                                            "No Complaints Yet",
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            "Your complaints will appear here",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: complaints.length,
                                      itemBuilder: (context, index) {
                                        final item = complaints[index];
                                        final hasReply =
                                            item['reply'] != null &&
                                                item['reply'].isNotEmpty;

                                        return Container(
                                          margin: EdgeInsets.only(bottom: 15),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                color:
                                                    Colors.black.withOpacity(0.05),
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
                                                // Status and Date
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Container(
                                                      padding: EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 6,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: hasReply
                                                            ? Colors.green.shade50
                                                            : Colors.orange
                                                                .shade50,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                10),
                                                      ),
                                                      child: Text(
                                                        hasReply
                                                            ? "REPLIED"
                                                            : "PENDING",
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: hasReply
                                                              ? Colors.green
                                                                  .shade700
                                                              : Colors.orange
                                                                  .shade700,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      _formatDate(
                                                          item['createdAt']),
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey
                                                            .shade600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 15),

                                                // Your Complaint
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.person,
                                                          size: 16,
                                                          color: Colors.blue
                                                              .shade700,
                                                        ),
                                                        SizedBox(width: 8),
                                                        Text(
                                                          "Your Complaint",
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Colors.blue
                                                                .shade900,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 8),
                                                    Container(
                                                      width: double.infinity,
                                                      padding:
                                                          EdgeInsets.all(15),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Colors.blue.shade50,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      child: Text(
                                                        item['message'] ??
                                                            "No message",
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors
                                                              .blue.shade900,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 20),

                                                // Service Center Reply
                                                if (hasReply)
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            Icons.business,
                                                            size: 16,
                                                            color: Colors.green
                                                                .shade700,
                                                          ),
                                                          SizedBox(width: 8),
                                                          Text(
                                                            "Service Center Reply",
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight.w600,
                                                              color: Colors
                                                                  .green.shade900,
                                                            ),
                                                          ),
                                                          if (item['replyAt'] !=
                                                              null)
                                                            SizedBox(width: 10),
                                                          if (item['replyAt'] !=
                                                              null)
                                                            Text(
                                                              "• ${_formatDate(item['replyAt'])}",
                                                              style: TextStyle(
                                                                fontSize: 11,
                                                                color: Colors
                                                                    .grey
                                                                    .shade500,
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 8),
                                                      Container(
                                                        width: double.infinity,
                                                        padding:
                                                            EdgeInsets.all(15),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors
                                                              .green.shade50,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                        child: Text(
                                                          item['reply'],
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors
                                                                .green.shade900,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                else
                                                  Container(
                                                    padding: EdgeInsets.all(15),
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey.shade50,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.access_time,
                                                          size: 18,
                                                          color: Colors
                                                              .grey.shade600,
                                                        ),
                                                        SizedBox(width: 10),
                                                        Expanded(
                                                          child: Text(
                                                            "Awaiting response from service center",
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              color: Colors
                                                                  .grey.shade600,
                                                              fontStyle:
                                                                  FontStyle
                                                                      .italic,
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
}