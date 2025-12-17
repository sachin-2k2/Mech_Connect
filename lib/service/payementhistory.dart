import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:mechconnect/service/home.dart';
import 'package:mechconnect/user/register.dart';

class PaymentHistory extends StatefulWidget {
  const PaymentHistory({super.key});

  @override
  State<PaymentHistory> createState() => _PaymentHistoryState();
}

class _PaymentHistoryState extends State<PaymentHistory> {

  List paymentHistory = [];
  bool isLoading = true;

  Future<void> getPaymentHistory() async {
    try {
      final response = await dio.get(
        '$baseurl/api/booking/paymenthistory/$sobid',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          paymentHistory = response.data['data'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch payment history')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
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
        title: Text('Payment History'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : paymentHistory.isEmpty
              ? Center(child: Text('No payment history found'))
              : ListView.builder(
                  itemCount: paymentHistory.length,
                  itemBuilder: (context, index) {
                    final payment = paymentHistory[index]['bill'];
                    final user = paymentHistory[index]['userId'];

                    return Card(
                      margin: EdgeInsets.all(10),
                      child: ListTile(
                        title: Text('User: ${user['name']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Phone: ${user['phone']}'),
                            Text('Email: ${user['email']}'),
                            Text('Service Charge: \$${payment['serviceCharge']}'),
                            Text('Total Amount: \$${payment['totalAmount']}'),
                            Text('Paid: ${payment['paid'] ? 'Yes' : 'No'}'),
                           
                          ],
                        ),
                        trailing: payment['paid']
                            ? Icon(Icons.check_circle, color: Colors.green)
                            : Icon(Icons.cancel, color: Colors.red),
                      ),
                    );
                  },
                ),
    );
  }
}
