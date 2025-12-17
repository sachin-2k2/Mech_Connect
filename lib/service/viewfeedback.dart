import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:mechconnect/service/home.dart';
import 'package:mechconnect/user/register.dart';

class ViewFeedback extends StatefulWidget {
  const ViewFeedback({super.key});

  @override
  State<ViewFeedback> createState() => _ViewFeedbackState();
}

class _ViewFeedbackState extends State<ViewFeedback> {
  List<dynamic> feedback = [];

  @override
  void initState() {
    super.initState();
    getFeedback();
  }

  Future<void> getFeedback() async {
    try {
      final response = await dio.get('$baseurl/api/rating/service-center/$sobid');

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          feedback = response.data["data"] ?? [];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load feedbacks')),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Feedbacks"),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: feedback.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: feedback.length,
              itemBuilder: (context, index) {
                final item = feedback[index];
                final userName = item["userId"]?["name"] ?? 'No Name';
                final review = item["review"] ?? 'No Review';
                final rating = item["rating"]?.toString() ?? '0';

                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Card(
                    elevation: 3,
                    child: ListTile(
                      title: Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 5),
                          Text(review),
                          const SizedBox(height: 5),
                          Text('Rating: $rating'),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
