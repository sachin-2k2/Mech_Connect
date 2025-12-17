import 'package:flutter/material.dart';
import 'package:mechconnect/mechanic/home.dart';
import 'package:mechconnect/service/home.dart';
import 'package:mechconnect/user/register.dart';
import 'package:mechconnect/user/report.dart';

class Assign extends StatefulWidget {
  String bid;
  Assign({super.key, required this.bid});

  @override
  State<Assign> createState() => _AssignState();
}

class _AssignState extends State<Assign> {
  List<dynamic> mechanics = [];

  Future<void> getMyMechanics(context) async {
    try {
      final response = await dio.get(
        '$baseurl/api/mechanic/mymechanics/$sobid',
      );

      print(response.data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          mechanics = response.data["data"];
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Loaded successfully')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load data')));
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> Assignmech(context, String id, String mid) async {
    try {
      final response = await dio.put(
        "$baseurl/api/booking/servicecenter/assign/$id",
        data: {'mechanicId': mid},
      );

      print(response.data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('successfull')));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => homeservice()),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed')));
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
    super.initState();
    getMyMechanics(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mechanic Assign"),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: mechanics.length,
              itemBuilder: (context, index) {
                final mechanic = mechanics[index];

                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Card(
                    child: ListTile(
                      trailing: TextButton(
                        onPressed: () {
                          Assignmech(context, widget.bid, mechanic['_id']);
                        },
                        child: Text(
                          "Assign",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 43, 66, 108),
                        ),
                      ),
                      title: Text(mechanic["mechanicName"] ?? "No Name"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Phone: ${mechanic["phone"].toString()}"),
                          Text("Email: ${mechanic["email"] ?? 'N/A'}"),
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
    );
  }
}
