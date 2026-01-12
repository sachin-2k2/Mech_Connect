import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:mechconnect/user/register.dart';

class PaymentPage extends StatefulWidget {
  final String bookingid;
  final Map<String, dynamic> booking;

  PaymentPage({super.key, required this.booking, required this.bookingid});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool _isLoading = false;
  bool _paymentSuccess = false;

  Future<void> postPayment() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await dio.put(
        '$baseurl/api/booking/${widget.bookingid}/paymentstatus',
        data: {'paid': true},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _paymentSuccess = true;
          widget.booking['bill']['paid'] = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text('Payment Successful! 🎉'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );

        // Optional: Navigate back after successful payment
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pop(context, true);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    final serviceCharge = booking['bill']?['serviceCharge']?.toDouble() ?? 0.0;
    final totalAmount = booking['bill']?['totalAmount']?.toDouble() ?? 0.0;
    final replacedProducts =
        booking['replacedProducts'] as List<dynamic>? ?? [];
    final paid = booking['bill']?['paid'] ?? false || _paymentSuccess;
    final partsAmount = totalAmount - serviceCharge;

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
                            "Payment",
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
                      "Complete your payment for service booking",
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
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Booking Summary Card
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.receipt_long,
                                    color: Colors.blue.shade700,
                                    size: 22,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    "Booking Summary",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue.shade900,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 15),
                              _buildInfoRow(
                                icon: Icons.confirmation_number,
                                label: "Booking ID",
                                value: widget.bookingid.substring(0, 8),
                              ),
                              _buildInfoRow(
                                icon: Icons.build_circle,
                                label: "Service Center",
                                value:
                                    booking['serviceCenterId']?['centerName'] ??
                                    'N/A',
                              ),
                              _buildInfoRow(
                                icon: Icons.description,
                                label: "Issue",
                                value: booking['problemDescription'] ?? 'N/A',
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 25),

                        // Parts Replaced Section
                        if (replacedProducts.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Parts Replaced",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                              SizedBox(height: 10),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    for (var product in replacedProducts)
                                      Container(
                                        padding: EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom:
                                                product != replacedProducts.last
                                                ? BorderSide(
                                                    color: Colors.grey.shade100,
                                                  )
                                                : BorderSide.none,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: Colors.blue.shade50,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.settings,
                                                color: Colors.blue.shade700,
                                                size: 20,
                                              ),
                                            ),
                                            SizedBox(width: 15),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    product['name']
                                                            ?.toString() ??
                                                        'Part',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          Colors.blue.shade900,
                                                    ),
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    "₹${(product['price'] ?? 0).toStringAsFixed(2)} × ${product['quantity'] ?? 1} units",
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color:
                                                          Colors.grey.shade600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Text(
                                              "₹${((product['price'] ?? 0) * (product['quantity'] ?? 1)).toStringAsFixed(2)}",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.green.shade700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 25),
                            ],
                          ),

                        // Payment Breakdown
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.blue.shade100,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                "Payment Breakdown",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                              SizedBox(height: 20),
                              _buildAmountRow(
                                label: "Service Charge",
                                amount: serviceCharge,
                                isHighlighted: false,
                              ),
                              if (replacedProducts.isNotEmpty)
                                _buildAmountRow(
                                  label: "Parts Replacement",
                                  amount: partsAmount,
                                  isHighlighted: false,
                                ),
                              SizedBox(height: 10),
                              Divider(height: 1, color: Colors.blue.shade200),
                              SizedBox(height: 10),
                              _buildAmountRow(
                                label: "Total Amount",
                                amount: totalAmount,
                                isHighlighted: true,
                                isTotal: true,
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 30),

                        // Payment Status
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: paid
                                ? Colors.green.shade50
                                : Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: paid
                                  ? Colors.green.shade100
                                  : Colors.orange.shade100,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                paid ? Icons.check_circle : Icons.payment,
                                color: paid
                                    ? Colors.green.shade700
                                    : Colors.orange.shade700,
                                size: 28,
                              ),
                              SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      paid
                                          ? "Payment Completed"
                                          : "Payment Pending",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: paid
                                            ? Colors.green.shade900
                                            : Colors.orange.shade900,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      paid
                                          ? "Your payment has been successfully processed"
                                          : "Complete your payment to confirm service",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: paid
                                            ? Colors.green.shade700
                                            : Colors.orange.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 40),

                        // Pay Now Button (if not paid)
                        if (!paid)
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : postPayment,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade700,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 5,
                                shadowColor: Colors.blue.shade300,
                              ),
                              child: _isLoading
                                  ? SizedBox(
                                      height: 25,
                                      width: 25,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.payment,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          "PAY NOW - ₹${totalAmount.toStringAsFixed(2)}",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            letterSpacing: 1.1,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),

                        SizedBox(height: 20),

                        // Secure Payment Note
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.security,
                                color: Colors.blue.shade700,
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "Your payment is secure and encrypted. All transactions are protected.",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ],
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

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: maxLines > 1
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue.shade900,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow({
    required String label,
    required double amount,
    bool isHighlighted = false,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
              color: isHighlighted
                  ? Colors.blue.shade900
                  : Colors.grey.shade700,
            ),
          ),
          Text(
            "₹${amount.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: isTotal ? 22 : 16,
              fontWeight: FontWeight.w600,
              color: isTotal ? Colors.green.shade700 : Colors.blue.shade900,
            ),
          ),
        ],
      ),
    );
  }
}
