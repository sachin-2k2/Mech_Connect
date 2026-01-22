// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart';
// import 'package:mechconnect/service/home.dart';
// import 'package:mechconnect/user/register.dart';

// class PaymentHistory extends StatefulWidget {
//   const PaymentHistory({super.key});

//   @override
//   State<PaymentHistory> createState() => _PaymentHistoryState();
// }

// class _PaymentHistoryState extends State<PaymentHistory> {

//   List paymentHistory = [];
//   bool isLoading = true;

//   Future<void> getPaymentHistory() async {
//     try {
//       final response = await dio.get(
//         '$baseurl/api/booking/paymenthistory/$sobid',
//       );

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         setState(() {
//           paymentHistory = response.data['data'] ?? [];
//           isLoading = false;
//         });
//       } else {
//         setState(() {
//           isLoading = false;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to fetch payment history')),
//         );
//       }
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     getPaymentHistory();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Payment History'),
//       ),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : paymentHistory.isEmpty
//               ? Center(child: Text('No payment history found'))
//               : ListView.builder(
//                   itemCount: paymentHistory.length,
//                   itemBuilder: (context, index) {
//                     final payment = paymentHistory[index]['bill'];
//                     final user = paymentHistory[index]['userId'];

//                     return Card(
//                       margin: EdgeInsets.all(10),
//                       child: ListTile(
//                         title: Text('User: ${user['name']}'),
//                         subtitle: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text('Phone: ${user['phone']}'),
//                             Text('Email: ${user['email']}'),
//                             Text('Service Charge: \$${payment['serviceCharge']}'),
//                             Text('Total Amount: \$${payment['totalAmount']}'),
//                             Text('Paid: ${payment['paid'] ? 'Yes' : 'No'}'),
                           
//                           ],
//                         ),
//                         trailing: payment['paid']
//                             ? Icon(Icons.check_circle, color: Colors.green)
//                             : Icon(Icons.cancel, color: Colors.red),
//                       ),
//                     );
//                   },
//                 ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:mechconnect/service/home.dart';
import 'package:mechconnect/user/register.dart';
import 'package:intl/intl.dart';

class PaymentHistory extends StatefulWidget {
  const PaymentHistory({super.key});

  @override
  State<PaymentHistory> createState() => _PaymentHistoryState();
}

class _PaymentHistoryState extends State<PaymentHistory> {
  List paymentHistory = [];
  bool isLoading = true;
  double totalRevenue = 0;
  int paidCount = 0;

  Future<void> getPaymentHistory() async {
    try {
      final response = await dio.get(
        '$baseurl/api/booking/paymenthistory/$sobid',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? [];
        
        // Calculate statistics
        double revenue = 0;
        int paid = 0;
        
        for (var item in data) {
          final bill = item['bill'];
          if (bill != null && bill['totalAmount'] != null) {
            revenue += bill['totalAmount'].toDouble();
            if (bill['paid'] == true) {
              paid++;
            }
          }
        }
        
        setState(() {
          paymentHistory = data;
          totalRevenue = revenue;
          paidCount = paid;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        _showSnackBar('Failed to fetch payment history');
      }
    } catch (e) {
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
      return DateFormat('MMM dd, yyyy · hh:mm a').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(amount);
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
                    "Payment Overview",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "${paymentHistory.length} total payments",
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
                  Icons.attach_money_rounded,
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
                    _formatCurrency(totalRevenue),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Total Revenue",
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
                    "$paidCount",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Paid",
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
                    "${paymentHistory.length - paidCount}",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Pending",
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

  Widget _buildPaymentStatus(bool isPaid) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isPaid ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPaid ? Colors.green.shade200 : Colors.orange.shade200,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPaid ? Icons.check_circle : Icons.pending,
            size: 14,
            color: isPaid ? Colors.green : Colors.orange,
          ),
          SizedBox(width: 4),
          Text(
            isPaid ? "Paid" : "Pending",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isPaid ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getPaymentHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Payment History",
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
                    "Loading payment history...",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : paymentHistory.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.payments_outlined,
                        size: 80,
                        color: Colors.grey.shade300,
                      ),
                      SizedBox(height: 16),
                      Text(
                        "No Payment History",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Payment records will appear here",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => getPaymentHistory(),
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
                  onRefresh: () => getPaymentHistory(),
                  color: Colors.lightBlueAccent,
                  child: Column(
                    children: [
                      // Stats Overview Card
                      _buildStatsCard(),

                      // Payments List
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.only(bottom: 16),
                          itemCount: paymentHistory.length,
                          itemBuilder: (context, index) {
                            final payment = paymentHistory[index]['bill'];
                            final user = paymentHistory[index]['userId'];
                            final userName = user['name'] ?? 'Unknown User';
                            final userPhone = user['phone']?.toString() ?? 'N/A';
                            final userEmail = user['email'] ?? 'N/A';
                            final serviceCharge = payment['serviceCharge']?.toDouble() ?? 0.0;
                            final totalAmount = payment['totalAmount']?.toDouble() ?? 0.0;
                            final isPaid = payment['paid'] == true;
                            final createdAt = payment['createdAt']?.toString() ?? '';

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
                                      // Header with user info and status
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
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
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  "Payment #${index + 1}",
                                                  style: TextStyle(
                                                    color: Colors.grey.shade600,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          _buildPaymentStatus(isPaid),
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
                                                    userPhone,
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
                                                    userEmail,
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

                                      // Payment Details
                                      Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.blue.shade100),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Service Charge",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  _formatCurrency(serviceCharge),
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.grey.shade800,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              height: 40,
                                              width: 1,
                                              color: Colors.grey.shade300,
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  "Total Amount",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  _formatCurrency(totalAmount),
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w800,
                                                    color: Colors.lightBlueAccent,
                                                  ),
                                                ),
                                              ],
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