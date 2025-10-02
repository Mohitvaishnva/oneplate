import 'package:flutter/material.dart';
import 'hotelhome.dart';
import 'createdonation.dart';
import 'donatehistory.dart';
import 'hotelprofile.dart';
import 'response.dart';

class HotelMainScreen extends StatefulWidget {
  const HotelMainScreen({super.key});

  @override
  State<HotelMainScreen> createState() => _HotelMainScreenState();
}

class _HotelMainScreenState extends State<HotelMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HotelHomeScreen(),
    const CreateDonateScreen(),
    const DonateHistoryScreen(),
    const HotelProfileScreen(),
    const HotelResponseScreen(),
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
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacity(0.6),
        elevation: 8,
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
            icon: Icon(Icons.add_circle_outline),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Response',
          ),
        ],
      ),
    );
  }
}