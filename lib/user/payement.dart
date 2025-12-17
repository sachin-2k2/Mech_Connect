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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment successful! 🎉')),
        );
        setState(() {
          widget.booking['bill']['paid'] = true; // update UI immediately
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed. Please try again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
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
    final serviceCharge = booking['bill']?['serviceCharge'] ?? 0;
    final totalAmount = booking['bill']?['totalAmount'] ?? 0;
    final replacedProducts = booking['replacedProducts'] as List<dynamic>? ?? [];
    final paid = booking['bill']?['paid'] ?? false;

    return Scaffold(
      appBar: AppBar(title: Text('Payment Details')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Booking Info
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Booking ID: ${booking['_id']}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 8),
                  Text('Problem: ${booking['problemDescription'] ?? 'N/A'}'),
                  SizedBox(height: 8),
                  Text('Service Center: ${booking['serviceCenterId']?['centerName'] ?? 'N/A'}'),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),

          // Replaced Products
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Replaced Products', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 8),
                  if (replacedProducts.isNotEmpty)
                    ...replacedProducts.map((product) {
                      final name = product['name'] ?? '';
                      final price = product['price'] ?? 0;
                      final quantity = product['quantity'] ?? 0;
                      return Text('$name - ₹$price x $quantity');
                    }).toList()
                  else
                    Text('No products replaced'),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),

          // Payment Summary
          Card(
            color: Colors.grey[100],
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Service Charge'),
                      Text('₹$serviceCharge'),
                    ],
                  ),
                  SizedBox(height: 8),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('₹$totalAmount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 30),

          // Pay Now or Payment Completed
          Center(
            child: paid
                ? Container(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Payment Completed',
                      style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  )
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(200, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _isLoading ? null : postPayment,
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Pay Now', style: TextStyle(fontSize: 16)),
                  ),
          ),
        ],
      ),
    );
  }
}
