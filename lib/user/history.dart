import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:mechconnect/user/home.dart';
import 'package:mechconnect/user/payement.dart';
import 'package:mechconnect/user/register.dart';

List<dynamic> history = [];

class BookingHistory extends StatefulWidget {
  const BookingHistory({super.key});

  @override
  State<BookingHistory> createState() => _BookingHistoryState();
}

class _BookingHistoryState extends State<BookingHistory> {

  Future<void> getHistory(BuildContext context) async {
    try {
      final response = await dio.get('$baseurl/api/booking/user/$obid');
      print(response.data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          history = response.data["data"];
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('History fetched successfully')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to fetch history')));
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
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
      appBar: AppBar(title: Text('Booking History')),
      body: history.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final booking = history[index];
                final problem = booking['problemDescription'] ?? 'No description';
                final bill = booking['bill'] ?? {};
                final paid = bill['paid'] ?? false;
                final totalAmount = bill['totalAmount'] ?? 0;
                final serviceCenterName =
                    booking['serviceCenterId']?['centerName'] ?? 'Unknown Center';

                // Get status from mechanic requests
                String status = 'Unknown';
                Color statusColor = Colors.orange;
                if (booking['mechanicId'] != null &&
                    booking['mechanicId']['requests'] != null &&
                    booking['mechanicId']['requests'].isNotEmpty) {
                  status = booking['mechanicId']['requests'][0]['status'] ?? 'Unknown';
                  if (status.toLowerCase() == 'accepted') {
                    statusColor = Colors.green;
                  } else {
                    statusColor = Colors.orange;
                  }
                }

                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    leading: Icon(Icons.build),
                    title: Text(problem),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        Text('Status: ',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          status,
                          style: TextStyle(
                              color: statusColor, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text('Service Center: $serviceCenterName'),
                        Text('Total Amount: ₹$totalAmount'),
                      ],
                    ),
                    trailing: paid
                        ? Text(
                            'Paid',
                            style: TextStyle(
                                color: Colors.green, fontWeight: FontWeight.bold),
                          )
                        : ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PaymentPage(
                                    booking: booking,
                                    bookingid: booking['_id'],
                                  ),
                                ),
                              );
                            },
                            child: Text('Pay Now'),
                          ),
                  ),
                );
              },
            ),
    );
  }
}
