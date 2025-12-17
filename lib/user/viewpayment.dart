import 'package:flutter/material.dart';
import 'package:mechconnect/user/register.dart';

class Viewpayment extends StatefulWidget {
  Viewpayment({super.key});

  @override
  State<Viewpayment> createState() => _ViewpaymentState();
}

class _ViewpaymentState extends State<Viewpayment> {
  List<dynamic> Payment = [];

  Future<void> get_bill(context) async {
    try {
      final response = await dio.get('$baseurl/api/user/home/');
      print(response.data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          Payment = response.data["data"]; // Extract "data"
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(' successful')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(' failed')));
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    get_bill(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Payment details",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: ListView.builder(
        itemCount: Payment.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              subtitle: Column(
                children: [
                  Text(Payment[index]["type"]),

                  Text(Payment[index]["name"]),
                  Text(Payment[index]["issue"]),
                  Text(Payment[index]["amount"].toString()),
                ],
              ),
              trailing: TextButton(
                onPressed: () {},
                child: Text(
                  "Payment",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
