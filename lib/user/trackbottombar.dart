import 'package:flutter/material.dart';
import 'package:mechconnect/user/trackingM.dart';
import 'package:mechconnect/user/trackingP.dart';

class Trackingbottom extends StatefulWidget {
  const Trackingbottom({super.key});

  @override
  State<Trackingbottom> createState() => _TrackingbottomState();
}

class _TrackingbottomState extends State<Trackingbottom> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    TrackingPage(),
    TrackingPagep(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.build),
            label: 'Mechanic',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: 'Pickup',
          ),
        ],
      ),
    );
  }
}
