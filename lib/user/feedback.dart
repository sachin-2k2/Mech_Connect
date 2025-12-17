import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:mechconnect/user/home.dart';
import 'package:mechconnect/user/register.dart';

class Feedbackpage extends StatefulWidget {
  final String serviceid;
  Feedbackpage({super.key, required this.serviceid});

  @override
  State<Feedbackpage> createState() => _FeedbackpageState();
}

class _FeedbackpageState extends State<Feedbackpage> {
  TextEditingController feedback = TextEditingController();
  final formkey = GlobalKey<FormState>();

  double rating = 3;

  Future<void> post_feedback(context) async {
    try {
      final response = await dio.post(
        '$baseurl/api/rating/add',
        data: {
          'review': feedback.text,
          'userId': obid,
          'serviceCenterId': widget.serviceid,
          'rating': rating,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Feedback submitted!')));

        // 🔹 Reset fields after submission
        feedback.clear();
        setState(() {
          rating = 3; // Reset star rating
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Feedback & Rating",
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
              RatingBar.builder(
                initialRating: rating,
                minRating: 1,
                direction: Axis.horizontal,
                itemCount: 5,
                itemSize: 40,
                itemPadding: EdgeInsets.symmetric(horizontal: 2),
                itemBuilder: (context, index) =>
                    Icon(Icons.star, color: Colors.yellow),
                onRatingUpdate: (_rating) {
                  setState(() {
                    rating = _rating;
                  });
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                maxLines: 5,
                controller: feedback,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter your feedback";
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: "Enter your feedback",
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (formkey.currentState!.validate()) {
                    post_feedback(context);
                  }
                },
                child: Text(
                  "Submit",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
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
