import 'package:flutter/material.dart';

class Viewpayment extends StatelessWidget {
  Viewpayment({super.key});
  List<dynamic> Payment = [
    {"name": "hina", "type": "pickup", "issue": "issue1", "amount": 500},
    {"name": "lubin", "type": "mechanic", "issue": "issue2", "amount": 100},
  ];

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
