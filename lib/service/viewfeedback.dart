// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart';
// import 'package:mechconnect/service/home.dart';
// import 'package:mechconnect/user/register.dart';

// class ViewFeedback extends StatefulWidget {
//   const ViewFeedback({super.key});

//   @override
//   State<ViewFeedback> createState() => _ViewFeedbackState();
// }

// class _ViewFeedbackState extends State<ViewFeedback> {
//   List<dynamic> feedback = [];

//   @override
//   void initState() {
//     super.initState();
//     getFeedback();
//   }

//   Future<void> getFeedback() async {
//     try {
//       final response = await dio.get('$baseurl/api/rating/service-center/$sobid');

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         setState(() {
//           feedback = response.data["data"] ?? [];
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Failed to load feedbacks')),
//         );
//       }
//     } catch (e) {
//       print(e);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Feedbacks"),
//         backgroundColor: Colors.lightBlueAccent,
//       ),
//       body: feedback.isEmpty
//           ? const Center(child: CircularProgressIndicator())
//           : ListView.builder(
//               itemCount: feedback.length,
//               itemBuilder: (context, index) {
//                 final item = feedback[index];
//                 final userName = item["userId"]?["name"] ?? 'No Name';
//                 final review = item["review"] ?? 'No Review';
//                 final rating = item["rating"]?.toString() ?? '0';

//                 return Padding(
//                   padding: const EdgeInsets.all(10.0),
//                   child: Card(
//                     elevation: 3,
//                     child: ListTile(
//                       title: Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
//                       subtitle: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const SizedBox(height: 5),
//                           Text(review),
//                           const SizedBox(height: 5),
//                           Text('Rating: $rating'),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:mechconnect/service/home.dart';
import 'package:mechconnect/user/register.dart';
import 'package:intl/intl.dart';

class ViewFeedback extends StatefulWidget {
  const ViewFeedback({super.key});

  @override
  State<ViewFeedback> createState() => _ViewFeedbackState();
}

class _ViewFeedbackState extends State<ViewFeedback> {
  List<dynamic> feedback = [];
  bool isLoading = true;
  double averageRating = 0.0;
  int totalFeedbacks = 0;

  @override
  void initState() {
    super.initState();
    getFeedback();
  }

  Future<void> getFeedback() async {
    try {
      setState(() {
        isLoading = true;
      });

      final response = await dio.get('$baseurl/api/rating/service-center/$sobid');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data["data"] ?? [];
        
        // Calculate statistics
        double totalRating = 0.0;
        for (var item in data) {
          final rating = item["rating"]?.toDouble() ?? 0.0;
          totalRating += rating;
        }
        
        double avgRating = data.isNotEmpty ? totalRating / data.length : 0.0;
        
        setState(() {
          feedback = data;
          averageRating = avgRating;
          totalFeedbacks = data.length;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        _showSnackBar('Failed to load feedbacks');
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

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateString.length > 10 ? dateString.substring(0, 10) : dateString;
    }
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating.floor() ? Icons.star : 
                 (index < rating.ceil() ? Icons.star_half : Icons.star_border),
          color: Colors.amber,
          size: 16,
        );
      }),
    );
  }

  Widget _buildRatingBadge(double rating) {
    Color getRatingColor(double rating) {
      if (rating >= 4.0) return Colors.green;
      if (rating >= 3.0) return Colors.orange;
      return Colors.red;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: getRatingColor(rating).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: getRatingColor(rating).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            rating >= 4.0 ? Icons.emoji_emotions :
                   rating >= 3.0 ? Icons.sentiment_satisfied :
                   Icons.sentiment_dissatisfied,
            size: 14,
            color: getRatingColor(rating),
          ),
          SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: getRatingColor(rating),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.lightBlueAccent, Colors.blue.shade600],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Customer Feedback",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "$totalFeedbacks total reviews",
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
                  Icons.reviews,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    averageRating.toStringAsFixed(1),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4),
                  _buildRatingStars(averageRating),
                  SizedBox(height: 4),
                  Text(
                    "Average Rating",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Container(
                height: 40,
                width: 1,
                color: Colors.white.withOpacity(0.3),
              ),
              Column(
                children: [
                  Text(
                    "$totalFeedbacks",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4),
                  Icon(
                    Icons.message,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Total Reviews",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Customer Feedback",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.lightBlueAccent,
        centerTitle: true,
        elevation: 2,
      ),
      backgroundColor: Colors.grey.shade50,
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
                    "Loading feedback...",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : feedback.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.reviews,
                        size: 80,
                        color: Colors.grey.shade300,
                      ),
                      SizedBox(height: 16),
                      Text(
                        "No Feedback Yet",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Customer feedback will appear here",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => getFeedback(),
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
                  onRefresh: () => getFeedback(),
                  color: Colors.lightBlueAccent,
                  child: Column(
                    children: [
                      // Stats Overview Card
                      _buildStatsCard(),

                      // Feedback List
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.only(bottom: 16),
                          itemCount: feedback.length,
                          itemBuilder: (context, index) {
                            final item = feedback[index];
                            final userName = item["userId"]?["name"] ?? 'No Name';
                            final userPhone = item["userId"]?["phone"]?.toString() ?? 'N/A';
                            final review = item["review"] ?? 'No Review';
                            final rating = item["rating"]?.toDouble() ?? 0.0;
                            final createdAt = item["createdAt"]?.toString() ?? '';

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
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Header with user info and rating
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 40,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    color: Colors.lightBlueAccent.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                  child: Center(
                                                    child: Icon(
                                                      Icons.person,
                                                      color: Colors.lightBlueAccent,
                                                      size: 20,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        userName,
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.w700,
                                                          fontSize: 16,
                                                          color: Colors.grey.shade800,
                                                        ),
                                                        maxLines: 2,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                      SizedBox(height: 2),
                                                      Text(
                                                        "Review #${index + 1}",
                                                        style: TextStyle(
                                                          color: Colors.grey.shade600,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          _buildRatingBadge(rating),
                                        ],
                                      ),

                                      SizedBox(height: 12),

                                      // Rating Stars
                                      _buildRatingStars(rating),

                                      SizedBox(height: 16),

                                      // Review Content
                                      Container(
                                        padding: EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.shade50,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.amber.shade100),
                                        ),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Icon(
                                              Icons.format_quote,
                                              color: Colors.amber,
                                              size: 24,
                                            ),
                                            SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                review,
                                                style: TextStyle(
                                                  color: Colors.grey.shade700,
                                                  fontSize: 14,
                                                  fontStyle: FontStyle.italic,
                                                  height: 1.5,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      SizedBox(height: 12),

                                      // Contact Information (if available)
                                      if (userPhone != 'N/A')
                                        Container(
                                          padding: EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade50,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.phone,
                                                size: 16,
                                                color: Colors.grey.shade600,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                userPhone,
                                                style: TextStyle(
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                      SizedBox(height: 12),

                                      // Timestamp
                                      if (createdAt.isNotEmpty)
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_today,
                                              size: 14,
                                              color: Colors.grey.shade500,
                                            ),
                                            SizedBox(width: 6),
                                            Text(
                                              _formatDate(createdAt),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}