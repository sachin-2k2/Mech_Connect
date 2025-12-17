import 'package:flutter/material.dart';
import 'package:mechconnect/service/home.dart';
import 'package:mechconnect/service/sendreply.dart';
import 'package:mechconnect/user/register.dart';

class Viewcomplaint extends StatefulWidget {
  Viewcomplaint({super.key});

  @override
  State<Viewcomplaint> createState() => _ViewcomplaintState();
}

class _ViewcomplaintState extends State<Viewcomplaint> {
  List<dynamic> complaints = [];

  Future<void> get_complaint(context) async {
    try {
      final response = await dio.get(
        '$baseurl/api/complaints/servicecenter/$sobid',
      );

      print(response.data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        complaints = response.data["data"];
        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load complaints')),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // ********** SEND REPLY FUNCTION **********
  Future<void> sendReply(String complaintId, String reply) async {
    try {
      final response = await dio.put(
        '$baseurl/api/complaints/reply/$complaintId',
        data: {"reply": reply},
      );

      print("Reply sent: ${response.data}");
    } catch (e) {
      print("Error sending reply: $e");
    }
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
        title: Text("Complaints"),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: complaints.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: complaints.length,
              itemBuilder: (context, index) {
                final item = complaints[index];
                final hasReply = item["reply"] != null &&
                    item["reply"].toString().trim().isNotEmpty;

                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Card(
                    child: ListTile(
                      title: Text(item["userId"]["name"]),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item["message"]),
                          if (hasReply)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                "Reply: ${item["reply"]}",
                                style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),

                      // ********** REPLY BUTTON OR "REPLIED" LABEL **********
                      trailing: hasReply
                          ? Text(
                              "Replied",
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : TextButton(
                              onPressed: () {
                                TextEditingController replyController =
                                    TextEditingController();

                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text("Send Reply"),
                                      content: TextField(
                                        controller: replyController,
                                        maxLines: 4,
                                        decoration: InputDecoration(
                                          hintText: "Type your reply...",
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text("Cancel"),
                                        ),
                                        ElevatedButton(
                                          onPressed: () async {
                                            String reply = replyController.text.trim();

                                            if (reply.isEmpty) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text("Reply cannot be empty"),
                                                ),
                                              );
                                              return;
                                            }

                                            await sendReply(item["_id"], reply);

                                            Navigator.pop(context);

                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text("Reply sent successfully")),
                                            );

                                            // Refresh list
                                            get_complaint(context);
                                          },
                                          child: Text("Send"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                              child: Text(
                                "Send reply",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
