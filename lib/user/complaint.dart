import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
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
  List<dynamic> replay = [];



  // ---------------- POST COMPLAINT ----------------
  Future<void> post_complaint(context) async {
    try {
      final response = await dio.post(
        '$baseurl/api/complaints/create',
        data: {
          'message': complaint.text,
          'userId': obid,
          'serviceCenterId': widget.serviceid,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Complaint submitted!')),
        );
        complaint.clear();
        get_replay(); // Refresh complaint list
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // ---------------- GET REPLIES ----------------
  Future<void> get_replay() async {
    try {
      final response = await dio.get(
        '$baseurl/api/complaints/user/$obid',
      );

      if (response.statusCode == 200) {
        setState(() {
          replay = response.data['data']; // <-- save API data
        });
      }
    } catch (e) {
      print("Error fetching replies: $e");
    }
  }

  @override
  void initState() {
    super.initState();

    /// Avoid calling context-dependent functions here
    WidgetsBinding.instance.addPostFrameCallback((_) {
      get_replay();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Complaint",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.lightBlueAccent,
      ),

      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: formkey,
          child: Column(
            children: [

              // ---------------- Complaint Text Field ----------------
              TextFormField(
                controller: complaint,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter a complaint";
                  }
                  return null;
                },
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: "Enter your complaint",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              SizedBox(height: 20),

              // ---------------- Submit Button ----------------
              ElevatedButton(
                onPressed: () {
                  if (formkey.currentState!.validate()) {
                    post_complaint(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Submit",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),

              SizedBox(height: 20),

              // ---------------- Display Replies ----------------
              Expanded(
                child: replay.isEmpty
                    ? Center(child: Text("No replies yet"))
                    : ListView.builder(
                        itemCount: replay.length,
                        itemBuilder: (context, index) {
                          final item = replay[index];
                          return Card(
                            child: ListTile(
                              title: Text("Your Complaint: ${item['message']}"),
                              subtitle: Text(
                                item['reply'] == null || item['reply'].isEmpty
                                    ? "No reply yet"
                                    : "Reply: ${item['reply']}",
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
    );
  }
}
