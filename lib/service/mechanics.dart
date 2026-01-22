import 'package:flutter/material.dart';
import 'package:mechconnect/mechanic/home.dart';
import 'package:mechconnect/service/home.dart';
import 'package:mechconnect/user/register.dart';
import 'package:mechconnect/user/report.dart';

class Assign extends StatefulWidget {
  String bid;
  Assign({super.key, required this.bid});

  @override
  State<Assign> createState() => _AssignState();
}

class _AssignState extends State<Assign> {
  List<dynamic> mechanics = [];
  bool isLoading = true;
  String? selectedMechanicId;

  Future<void> getMyMechanics(context) async {
    try {
      setState(() {
        isLoading = true;
      });

      final response = await dio.get(
        '$baseurl/api/mechanic/mymechanics/$sobid',
      );

      print(response.data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          mechanics = response.data["data"] ?? [];
          isLoading = false;
        });

        _showSnackBar('${mechanics.length} mechanics loaded');
      } else {
        setState(() {
          isLoading = false;
        });
        _showSnackBar('Failed to load mechanics');
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
      _showSnackBar('Error: $e');
    }
  }

  Future<void> Assignmech(context, String id, String mid, String mechanicName) async {
    try {
      setState(() {
        selectedMechanicId = mid;
      });

      final response = await dio.put(
        "$baseurl/api/booking/servicecenter/assign/$id",
        data: {'mechanicId': mid},
      );

      print(response.data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackBar('Assigned to $mechanicName successfully');
        Future.delayed(Duration(milliseconds: 1500), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => homeservice()),
          );
        });
      } else {
        setState(() {
          selectedMechanicId = null;
        });
        _showSnackBar('Assignment failed');
      }
    } catch (e) {
      print(e);
      setState(() {
        selectedMechanicId = null;
      });
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

  @override
  void initState() {
    super.initState();
    getMyMechanics(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Assign Mechanic",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.lightBlueAccent,
        centerTitle: true,
        elevation: 2,
      ),
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
                    "Loading mechanics...",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : mechanics.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.engineering,
                        size: 80,
                        color: Colors.grey.shade300,
                      ),
                      SizedBox(height: 16),
                      Text(
                        "No Mechanics Available",
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
                          "You don't have any mechanics in your service center yet",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => getMyMechanics(context),
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
              : Column(
                  children: [
                    // Header
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
                              "Select a mechanic to assign this task",
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
                              "${mechanics.length} available",
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

                    // Mechanics List
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => getMyMechanics(context),
                        color: Colors.lightBlueAccent,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: mechanics.length,
                          itemBuilder: (context, index) {
                            final mechanic = mechanics[index];
                            final mechanicId = mechanic['_id'];
                            final mechanicName =
                                mechanic["mechanicName"] ?? "No Name";
                            final phone = mechanic["phone"]?.toString() ?? "N/A";
                            final email = mechanic["email"] ?? 'N/A';
                            final isSelected = selectedMechanicId == mechanicId;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
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
                                    color: isSelected
                                        ? Colors.lightBlueAccent
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Mechanic Name and Badge
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 40,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    color: Colors.lightBlueAccent
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  child: Icon(
                                                    Icons.engineering,
                                                    size: 20,
                                                    color:
                                                        Colors.lightBlueAccent,
                                                  ),
                                                ),
                                                SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    mechanicName,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 16,
                                                      color:
                                                          Colors.grey.shade800,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.blueGrey.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              "Mech #${index + 1}",
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.blueGrey,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      SizedBox(height: 16),

                                      // Contact Information
                                      Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade50,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                                      color:
                                                          Colors.grey.shade700,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 8),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
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
                                                      color:
                                                          Colors.grey.shade700,
                                                    ),
                                                  ),
                                                ),
                                              ],
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
                                                  Assignmech(
                                                    context,
                                                    widget.bid,
                                                    mechanicId,
                                                    mechanicName,
                                                  );
                                                },
                                          icon: Icon(
                                            isSelected
                                                ? Icons.check_circle
                                                : Icons.assignment_turned_in,
                                            size: 20,
                                          ),
                                          label: Text(
                                            isSelected
                                                ? "Assigned"
                                                : "Assign This Mechanic",
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: isSelected
                                                ? Colors.green.shade50
                                                : Colors.lightBlueAccent,
                                            foregroundColor: isSelected
                                                ? Colors.green
                                                : Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              side: BorderSide(
                                                color: isSelected
                                                    ? Colors.green.shade200
                                                    : Colors.transparent,
                                              ),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              vertical: 14,
                                            ),
                                            disabledBackgroundColor:
                                                Colors.grey.shade100,
                                            disabledForegroundColor:
                                                Colors.grey.shade400,
                                          ),
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
                    ),
                  ],
                ),
    );
  }
}