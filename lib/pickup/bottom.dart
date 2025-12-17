import 'package:flutter/material.dart';
import 'package:mechconnect/mechanic/assignedtask.dart';
import 'package:mechconnect/pickup/assignedtask.dart';
import 'package:mechconnect/pickup/taskfromcervicecenter.dart';

// Dummy pages for demonstration



class BottomNavigationPage extends StatefulWidget {
  const BottomNavigationPage({super.key});

  @override
  State<BottomNavigationPage> createState() => _BottomNavigationPageState();
}

class _BottomNavigationPageState extends State<BottomNavigationPage> {
  int _currentIndex = 0;

  // List of pages to display
  final List<Widget> _pages = [
    Assignedtaskpicks(),
    Assignedtaskpicksservice(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], // Show selected page
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Change page
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: 'Freelancer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.miscellaneous_services),
            label: 'Service Center',
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BottomNavigationPage(),
    ),
  );
}
