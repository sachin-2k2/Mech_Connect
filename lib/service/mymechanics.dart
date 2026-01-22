import 'package:flutter/material.dart';
import 'package:mechconnect/service/home.dart';
import 'package:mechconnect/user/register.dart';
import 'package:mechconnect/user/report.dart';

class Mechanics extends StatefulWidget {
  Mechanics({super.key});

  @override
  State<Mechanics> createState() => _MechanicsState();
}

class _MechanicsState extends State<Mechanics> {
  List<dynamic> mechanics = [];
  bool isLoading = true;

  Future<void> getMyMechanics(context) async {
    try {
      setState(() {
        isLoading = true;
      });

      final response =
          await dio.get('$baseurl/api/mechanic/mymechanics/$sobid');

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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.grey.shade800,
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.lightBlueAccent,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.lightBlueAccent.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "My Mechanics",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Total ${mechanics.length} mechanics",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(
              Icons.engineering,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMechanicCard(Map<String, dynamic> mechanic, int index) {
    final mechanicName = mechanic["mechanicName"] ?? "No Name";
    final phone = mechanic["phone"]?.toString() ?? "N/A";
    final email = mechanic["email"] ?? 'N/A';

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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mechanic Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.lightBlueAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Icon(
                    Icons.engineering,
                    color: Colors.lightBlueAccent,
                    size: 24,
                  ),
                ),
              ),
              SizedBox(width: 16),

              // Mechanic Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            mechanicName,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Colors.grey.shade800,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey.shade50,
                            borderRadius: BorderRadius.circular(12),
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
                    SizedBox(height: 12),

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

                    SizedBox(height: 12),

                    // Availability Badge (if available in API)
                    if (mechanic["isAvailable"] != null)
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: mechanic["isAvailable"] == true
                                  ? Colors.green
                                  : Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          SizedBox(width: 6),
                          Text(
                            mechanic["isAvailable"] == true
                                ? "Available"
                                : "Busy",
                            style: TextStyle(
                              fontSize: 12,
                              color: mechanic["isAvailable"] == true
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                  ],
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
    getMyMechanics(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Mechanics",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.lightBlueAccent,
        centerTitle: true,
        elevation: 2,
        actions: [
          IconButton(
            onPressed: () => getMyMechanics(context),
            icon: Icon(Icons.refresh),
            tooltip: "Refresh",
          ),
        ],
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
                        "No Mechanics Found",
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
              : RefreshIndicator(
                  onRefresh: () => getMyMechanics(context),
                  color: Colors.lightBlueAccent,
                  child: Column(
                    children: [
                      // Stats Card
                      _buildStatsCard(),

                      // Mechanics List
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.only(bottom: 16),
                          itemCount: mechanics.length,
                          itemBuilder: (context, index) {
                            return _buildMechanicCard(mechanics[index], index);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}