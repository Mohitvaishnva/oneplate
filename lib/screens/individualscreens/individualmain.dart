import 'package:flutter/material.dart';
import 'individualhome.dart';
import 'createindividual.dart';
import 'donatehistory.dart';
import 'individualprofile.dart';

class IndividualMainScreen extends StatefulWidget {
  const IndividualMainScreen({super.key});

  @override
  State<IndividualMainScreen> createState() => _IndividualMainScreenState();
}

class _IndividualMainScreenState extends State<IndividualMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const IndividualHomeScreen(),
    const CreateIndividualDonationScreen(),
    const IndividualDonateHistoryScreen(),
    const IndividualProfileScreen(),
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
        selectedItemColor: const Color(0xFF6C63FF),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Donate',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}