import 'package:flutter/material.dart';
import 'package:mechconnect/mechanic/assignedtask.dart';
import 'package:mechconnect/mechanic/history.dart';
import 'package:mechconnect/mechanic/servicecenters.dart';
import 'package:mechconnect/user/login.dart';
import 'package:mechconnect/user/register.dart';

class Homemechanic extends StatefulWidget {
  const Homemechanic({super.key});

  @override
  State<Homemechanic> createState() => _HomemechanicState();
}

Map<String, dynamic> mdata = {};
String? mobid;

class _HomemechanicState extends State<Homemechanic> {
  bool isLoading = true;

  Future<void> get_mhome(context) async {
    try {
      final response = await dio.get('$baseurl/api/mechanic/home/$loginid');
      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          mdata = response.data["data"] ?? {};
          mobid = response.data['data']['_id'];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load profile'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Logout"),
        content: Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Login()),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text("Log Out", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    get_mhome(context);
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
              Colors.green.shade900,
              Colors.green.shade700,
              Colors.green.shade400,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // HEADER
              Container(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(Icons.handyman, color: Colors.white),
                    ),
                    SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Mechanic",
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        Text(
                          "Professional Vehicle Services",
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9)),
                        ),
                      ],
                    )
                  ],
                ),
              ),

              /// WHITE BODY
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: Colors.green.shade700,
                          ),
                        )
                      : SingleChildScrollView(
                          physics: BouncingScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                // PROFILE CARD
                                Container(
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 15,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Your Profile",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green.shade900,
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      _buildProfileInfo(
                                          icon: Icons.person,
                                          label: "Name",
                                          value:
                                              mdata['mechanicName'] ?? 'N/A'),
                                      _buildProfileInfo(
                                          icon: Icons.email,
                                          label: "Email",
                                          value: mdata['email'] ?? 'N/A'),
                                      _buildProfileInfo(
                                          icon: Icons.phone,
                                          label: "Phone",
                                          value: mdata['phone'] ?? 'N/A'),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 30),

                                Text(
                                  "Quick Actions",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),

                                SizedBox(height: 20),

                                GridView.count(
                                  crossAxisCount: 2,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  crossAxisSpacing: 15,
                                  mainAxisSpacing: 15,
                                  childAspectRatio: 1.2,
                                  children: [
                                    _buildActionCard(
                                      icon: Icons.task_alt,
                                      title: "Assigned Tasks",
                                      subtitle: "View tasks",
                                      color: Colors.blue,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => Assignedtask()),
                                        );
                                      },
                                    ),
                                    _buildActionCard(
                                      icon: Icons.business,
                                      title: "Service Centers",
                                      subtitle: "View centers",
                                      color: Colors.orange,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  Viewservicecentermech()),
                                        );
                                      },
                                    ),
                                    _buildActionCard(
                                      icon: Icons.history,
                                      title: "History",
                                      subtitle: "Past services",
                                      color: Colors.purple,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => MechHistory()),
                                        );
                                      },
                                    ),
                                    _buildActionCard(
                                      icon: Icons.logout,
                                      title: "Logout",
                                      subtitle: "Sign out",
                                      color: Colors.red,
                                      onTap: () {
                                        _showLogoutConfirmationDialog(context);
                                      },
                                    ),
                                  ],
                                ),

                                SizedBox(height: 30),
                              ],
                            ),
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

  Widget _buildProfileInfo(
      {required IconData icon,
      required String label,
      required String value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20),
          SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12)),
              Text(value,
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
      {required IconData icon,
      required String title,
      required String subtitle,
      required Color color,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 30),
            SizedBox(height: 10),
            Text(title,
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
