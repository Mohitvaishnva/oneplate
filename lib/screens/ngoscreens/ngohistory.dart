import 'package:flutter/material.dart';

class NGOHistoryScreen extends StatelessWidget {
  const NGOHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.history,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Donation History',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Track your completed donations',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 40),
              
              // Empty State
              Expanded(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            color: Color(0xFF6C63FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.history,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'No donation history yet',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Completed donations will appear here.\nStart by creating a food request!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Navigate to create donation screen
                            // DefaultTabController.of(context).animateTo(2);
                          },
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text('Create Request'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C63FF),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}