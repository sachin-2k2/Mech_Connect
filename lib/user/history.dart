import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:mechconnect/user/home.dart';
import 'package:mechconnect/user/payement.dart';
import 'package:mechconnect/user/register.dart';
import 'package:intl/intl.dart';

List<dynamic> history = [];

class BookingHistory extends StatefulWidget {
  const BookingHistory({super.key});

  @override
  State<BookingHistory> createState() => _BookingHistoryState();
}

class _BookingHistoryState extends State<BookingHistory> {
  bool isLoading = true;
  bool hasError = false;

  Future<void> getHistory(BuildContext context) async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final response = await dio.get('$baseurl/api/booking/user/$obid');
      print(response.data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          history = response.data["data"] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          hasError = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to fetch history'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
        hasError = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDate(String dateString) {
    try {
      if (dateString.isEmpty) return "Unknown";
      final dateTime = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
    } catch (e) {
      return "Unknown";
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      case 'in progress':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Icons.check_circle;
      case 'completed':
        return Icons.done_all;
      case 'rejected':
        return Icons.cancel;
      case 'pending':
        return Icons.access_time;
      case 'in progress':
        return Icons.build;
      default:
        return Icons.help_outline;
    }
  }

  @override
  void initState() {
    super.initState();
    getHistory(context);
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
              Colors.blue.shade900,
              Colors.blue.shade700,
              Colors.blue.shade400,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Booking History",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Track all your service bookings and payments",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: isLoading
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                color: Colors.blue.shade700,
                              ),
                              SizedBox(height: 20),
                              Text(
                                "Loading your bookings...",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : hasError
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 60,
                                    color: Colors.grey.shade400,
                                  ),
                                  SizedBox(height: 20),
                                  Text(
                                    "Failed to load bookings",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  ElevatedButton(
                                    onPressed: () => getHistory(context),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue.shade700,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      "Try Again",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : history.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.history_outlined,
                                        size: 80,
                                        color: Colors.grey.shade300,
                                      ),
                                      SizedBox(height: 20),
                                      Text(
                                        "No Booking History",
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        "Your service bookings will appear here",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    children: [
                                      // Summary Card
                                      Container(
                                        padding: EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius: BorderRadius.circular(15),
                                          border: Border.all(
                                            color: Colors.blue.shade100,
                                            width: 2,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.history,
                                                  color: Colors.blue.shade700,
                                                  size: 20,
                                                ),
                                                SizedBox(width: 10),
                                                Text(
                                                  "${history.length} Total Bookings",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.blue.shade900,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            IconButton(
                                              onPressed: () => getHistory(context),
                                              icon: Icon(
                                                Icons.refresh,
                                                color: Colors.blue.shade700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 20),

                                      // Bookings List
                                      Expanded(
                                        child: ListView.builder(
                                          itemCount: history.length,
                                          itemBuilder: (context, index) {
                                            final booking = history[index];
                                            final problem = booking[
                                                    'problemDescription'] ??
                                                'No description';
                                            final bill = booking['bill'] ?? {};
                                            final paid = bill['paid'] ?? false;
                                            final totalAmount =
                                                bill['totalAmount']?.toDouble() ?? 0.0;
                                            final serviceCenterName = booking[
                                                    'serviceCenterId']?[
                                                'centerName'] ??
                                                'Unknown Center';

                                            // Get status
                                            String status = 'Pending';
                                            if (booking['mechanicId'] != null &&
                                                booking['mechanicId']['requests'] !=
                                                    null &&
                                                booking['mechanicId']['requests']
                                                    .isNotEmpty) {
                                              status = booking['mechanicId']
                                                      ['requests'][0]['status'] ??
                                                  'Pending';
                                            }

                                            final statusColor =
                                                _getStatusColor(status);
                                            final statusIcon =
                                                _getStatusIcon(status);

                                            return Container(
                                              margin: EdgeInsets.only(bottom: 15),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.08),
                                                    blurRadius: 15,
                                                    spreadRadius: 2,
                                                  ),
                                                ],
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(20),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // Header with Status
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Container(
                                                          padding:
                                                              EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 6,
                                                          ),
                                                          decoration: BoxDecoration(
                                                            color: statusColor
                                                                .withOpacity(0.1),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(10),
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                statusIcon,
                                                                size: 14,
                                                                color: statusColor,
                                                              ),
                                                              SizedBox(width: 6),
                                                              Text(
                                                                status.toUpperCase(),
                                                                style: TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: statusColor,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Text(
                                                          _formatDate(booking[
                                                                  'createdAt'] ??
                                                              ""),
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                Colors.grey.shade600,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 15),

                                                    // Service Center
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.business,
                                                          size: 18,
                                                          color:
                                                              Colors.blue.shade700,
                                                        ),
                                                        SizedBox(width: 10),
                                                        Expanded(
                                                          child: Text(
                                                            serviceCenterName,
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight.w600,
                                                              color: Colors
                                                                  .blue.shade900,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 15),

                                                    // Problem Description
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          "Issue Description",
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Colors
                                                                .blue.shade900,
                                                          ),
                                                        ),
                                                        SizedBox(height: 8),
                                                        Container(
                                                          width: double.infinity,
                                                          padding:
                                                              EdgeInsets.all(12),
                                                          decoration: BoxDecoration(
                                                            color:
                                                                Colors.grey.shade50,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(10),
                                                          ),
                                                          child: Text(
                                                            problem,
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              color: Colors
                                                                  .grey.shade700,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 15),

                                                    // Amount and Payment Status
                                                    Container(
                                                      padding: EdgeInsets.all(12),
                                                      decoration: BoxDecoration(
                                                        color: Colors.blue.shade50,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                12),
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                "Total Amount",
                                                                style: TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .grey
                                                                      .shade600,
                                                                ),
                                                              ),
                                                              SizedBox(height: 4),
                                                              Text(
                                                                "₹${totalAmount.toStringAsFixed(2)}",
                                                                style: TextStyle(
                                                                  fontSize: 20,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .blue
                                                                      .shade900,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Container(
                                                            padding:
                                                                EdgeInsets.symmetric(
                                                              horizontal: 16,
                                                              vertical: 8,
                                                            ),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: paid
                                                                  ? Colors
                                                                      .green
                                                                      .shade50
                                                                  : Colors
                                                                      .orange
                                                                      .shade50,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(10),
                                                              border: Border.all(
                                                                color: paid
                                                                    ? Colors.green
                                                                        .shade100
                                                                    : Colors.orange
                                                                        .shade100,
                                                              ),
                                                            ),
                                                            child: Row(
                                                              children: [
                                                                Icon(
                                                                  paid
                                                                      ? Icons
                                                                          .check_circle
                                                                      : Icons
                                                                          .payment,
                                                                  size: 16,
                                                                  color: paid
                                                                      ? Colors.green
                                                                      : Colors
                                                                          .orange,
                                                                ),
                                                                SizedBox(width: 6),
                                                                Text(
                                                                  paid
                                                                      ? "PAID"
                                                                      : "PENDING",
                                                                  style: TextStyle(
                                                                    fontSize: 13,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: paid
                                                                        ? Colors
                                                                            .green
                                                                            .shade700
                                                                        : Colors
                                                                            .orange
                                                                            .shade700,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(height: 20),

                                                    // Pay Now Button (if not paid)
                                                    if (!paid)
                                                      SizedBox(
                                                        width: double.infinity,
                                                        height: 45,
                                                        child: ElevatedButton(
                                                          onPressed: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        PaymentPage(
                                                                  booking: booking,
                                                                  bookingid: booking[
                                                                      '_id'],
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            backgroundColor:
                                                                Colors.blue
                                                                    .shade700,
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12),
                                                            ),
                                                            elevation: 3,
                                                          ),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Icon(
                                                                Icons.payment,
                                                                color:
                                                                    Colors.white,
                                                                size: 20,
                                                              ),
                                                              SizedBox(width: 10),
                                                              Text(
                                                                "PAY NOW",
                                                                style: TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                  ],
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}