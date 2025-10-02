import 'package:flutter/material.dart';
import 'ngohome.dart';
import 'ngohistory.dart';
import 'createdonation.dart';
import 'ngoprofile.dart';

class NGOMainScreen extends StatefulWidget {
  const NGOMainScreen({super.key});

  @override
  State<NGOMainScreen> createState() => _NGOMainScreenState();
}

class _NGOMainScreenState extends State<NGOMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const NGOHomeScreen(),
    const NGOHistoryScreen(),
    const CreateDonationScreen(),
    const NGOProfileScreen(),
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
        backgroundColor: const Color(0xFF6C63FF),
        elevation: 8,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacity(0.6),
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 11,
        ),
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
            icon: Icon(Icons.add_circle),
            label: 'Request',
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