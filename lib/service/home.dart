import 'package:flutter/material.dart';
import 'package:mechconnect/service/add.dart';
import 'package:mechconnect/service/mymechanics.dart';
import 'package:mechconnect/service/payementhistory.dart';
import 'package:mechconnect/service/viewcomplaint.dart';
import 'package:mechconnect/service/viewfeedback.dart';   
import 'package:mechconnect/service/viewrequest.dart';
import 'package:mechconnect/service/viewstatus.dart';
import 'package:mechconnect/user/login.dart';
import 'package:mechconnect/user/register.dart';

class homeservice extends StatefulWidget {
  @override
  State<homeservice> createState() => _homeserviceState();
}

class _homeserviceState extends State<homeservice> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Color(0xFFF5F7FA),
        fontFamily: 'Inter', 
      ),
      home: HomeScreen(),
    );
  }
}

Map<String, dynamic> srdata = {};
String? sobid;

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = true;

  Future<void> get_shome(context) async {
    try {
      final response = await dio.get('$baseurl/api/service-center/home/$loginid');
      print(response.data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          srdata = response.data["data"]; // Extract "data"
          sobid = response.data['data']['_id'];
          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load data'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    get_shome(context);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Color(0xFFF5F7FA),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.blue.shade700),
              SizedBox(height: 20),
              Text(
                "Loading your service center...",
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),

      // ------------------------- APP BAR -------------------------
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.settings_outlined, color: Colors.blue.shade700),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Mech Connect",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
            Text(
              "Service Center Dashboard",
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.business,
              color: Colors.green.shade700,
              size: 22,
            ),
          ),
          SizedBox(width: 10),
        ],
      ),

      // ------------------------- BODY -------------------------
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card with Service Center Info
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.green.shade900, Colors.green.shade700],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Welcome to,",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              srdata['centerName'] ?? 'Service Center',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(
                                  Icons.email_outlined,
                                  size: 14,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                                SizedBox(width: 6),
                                Text(
                                  srdata['email'] ?? 'No email',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.phone_outlined,
                                  size: 14,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                                SizedBox(width: 6),
                                Text(
                                  srdata['phone'] ?? 'No phone',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.business_center,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildCenterStat(
                          icon: Icons.location_on,
                          label: "Location",
                          value: "Available",
                        ),
                        Container(
                          height: 30,
                          width: 1,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        _buildCenterStat(
                          icon: Icons.star,
                          label: "Rating",
                          value: srdata['rating']?['average'] != null
                              ? "${srdata['rating']['average']} ⭐"
                              : "New",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 25),

            // Quick Actions Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Service Center Management",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade900,
                  ),
                ),
               
              ],
            ),

            SizedBox(height: 20),

            // Action Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: [
                // Manage Requests
                _buildActionCard(
                  title: "Manage Request",
                  subtitle: "View & manage requests",
                  icon: Icons.list_alt,
                  color: Colors.blue,
                  iconBackground: Colors.blue.shade50,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Viewrequest()),
                    );
                  },
                ),

                // My Mechanics
                _buildActionCard(
                  title: "My Mechanics",
                  subtitle: "Manage mechanics team",
                  icon: Icons.engineering,
                  color: Colors.purple,
                  iconBackground: Colors.purple.shade50,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Mechanics()),
                    );
                  },
                ),

                // Add Personnel
                _buildActionCard(
                  title: "Add Personnel",
                  subtitle: "Add new team members",
                  icon: Icons.person_add,
                  color: Colors.teal,
                  iconBackground: Colors.teal.shade50,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Add()),
                    );
                  },
                ),

                // View Complaints
                _buildActionCard(
                  title: "View Complaints",
                  subtitle: "Customer complaints",
                  icon: Icons.chat_bubble_outline,
                  color: Colors.orange,
                  iconBackground: Colors.orange.shade50,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Viewcomplaint()),
                    );
                  },
                ),

                // // Update Status
                // _buildActionCard(
                //   title: "Update Status",
                //   subtitle: "Service status updates",
                //   icon: Icons.access_time,
                //   color: Colors.deepOrange,
                //   iconBackground: Colors.deepOrange.shade50,
                //   onTap: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(builder: (context) => Viewstatus()),
                //     );
                //   },
                // ),

                // Payment History
                _buildActionCard(
                  title: "Payment History",
                  subtitle: "View all transactions",
                  icon: Icons.payment,
                  color: Colors.green,
                  iconBackground: Colors.green.shade50,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PaymentHistory()),
                    );
                  },
                ),

                // Feedback
                _buildActionCard(
                  title: "Feedback",
                  subtitle: "Customer reviews",
                  icon: Icons.star,
                  color: Colors.amber,
                  iconBackground: Colors.amber.shade50,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ViewFeedback()),
                    );
                  },
                ),

                // Log Out
                _buildActionCard(
                  title: "Log Out",
                  subtitle: "Sign out from account",
                  icon: Icons.logout,
                  color: Colors.red,
                  iconBackground: Colors.red.shade50,
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Login()),
                    );
                  },
                ),
              ],
            ),

            SizedBox(height: 30),

            // Quick Stats Card
          
            SizedBox(height: 25),

            // Service Center Information Card
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
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Center Information",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade900,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          "Active",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  _buildInfoRow(
                    icon: Icons.business,
                    title: "Center Name",
                    value: srdata['centerName'] ?? 'Not Available',
                  ),
                  _buildInfoRow(
                    icon: Icons.email,
                    title: "Email",
                    value: srdata['email'] ?? 'Not Available',
                  ),
                  _buildInfoRow(
                    icon: Icons.phone,
                    title: "Phone",
                    value: srdata['phone'] ?? 'Not Available',
                  ),
                  _buildInfoRow(
                    icon: Icons.location_on,
                    title: "Location",
                    value: "Lat: ${srdata['location']?['lat']?.toStringAsFixed(4) ?? '0'}, Lng: ${srdata['location']?['lng']?.toStringAsFixed(4) ?? '0'}",
                    isLong: true,
                  ),
                  _buildInfoRow(
                    icon: Icons.vpn_key,
                    title: "Center ID",
                    value: srdata['_id'] != null
                        ? srdata['_id'].toString()
                        : 'Not Available',
                    isLong: true,
                  ),
                ],
              ),
            ),

            SizedBox(height: 40),

            // Footer Note
            Center(
              child: Text(
                "Professional Auto Service Management System",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Helper Widgets
  Widget _buildCenterStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.white),
            SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color iconBackground,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
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
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: iconBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 26, color: color),
              ),
              SizedBox(height: 15),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade900,
                ),
              ),
              SizedBox(height: 5),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatOption({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.3), width: 2),
          ),
          child: Icon(icon, size: 24, color: color),
        ),
        SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.green.shade900,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    bool isLong = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: Colors.green.shade700),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                SizedBox(height: 2),
                isLong
                    ? SelectableText(
                        value,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.green.shade900,
                        ),
                      )
                    : Text(
                        value,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.green.shade900,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}