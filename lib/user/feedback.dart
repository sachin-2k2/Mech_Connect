import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class Feedbackpage extends StatefulWidget {
  Feedbackpage({super.key});

  @override
  State<Feedbackpage> createState() => _FeedbackpageState();
}

class _FeedbackpageState extends State<Feedbackpage> {
  TextEditingController feedback = TextEditingController();

  final formkey = GlobalKey<FormState>();

  double rating = 3;

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
                itemPadding: EdgeInsetsGeometry.symmetric(horizontal: 2),
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
                  if (value == null||value.isEmpty) {
                    return "Enter your feedback";
                  }
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
                    "feedback submitted";
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
