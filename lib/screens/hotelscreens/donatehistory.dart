import 'package:flutter/material.dart';

class DonateHistoryScreen extends StatefulWidget {
  const DonateHistoryScreen({super.key});

  @override
  State<DonateHistoryScreen> createState() => _DonateHistoryScreenState();
}

class _DonateHistoryScreenState extends State<DonateHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              height: 120,
              decoration: const BoxDecoration(
                color: Color(0xFF6C63FF),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              child: const Center(
                child: Text(
                  'DONATION HISTORY',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
            
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6C63FF).withOpacity(0.3),
                            spreadRadius: 5,
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.history,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'No donation history yet',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your donations will appear here',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Action button
                    Container(
                      width: 200,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6C63FF).withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to create donation
                          Navigator.of(context).pushNamed('/create-donation');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_circle_outline, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Start Donating',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}