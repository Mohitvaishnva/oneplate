import 'package:flutter/material.dart';
import 'individualhome.dart';
import 'donatehistory.dart';
import 'individualprofile.dart';
import 'response.dart';

class IndividualMainScreen extends StatefulWidget {
  const IndividualMainScreen({super.key});

  @override
  State<IndividualMainScreen> createState() => _IndividualMainScreenState();
}

class _IndividualMainScreenState extends State<IndividualMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const IndividualHomeScreen(),
    const IndividualDonateHistoryScreen(),
    const IndividualProfileScreen(),
    const IndividualResponseScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Response',
          ),
        ],
      ),
    );
  }
}