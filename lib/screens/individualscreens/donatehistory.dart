import 'package:flutter/material.dart';

class IndividualDonateHistoryScreen extends StatelessWidget {
  const IndividualDonateHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donation History'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 80, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              'No donation history yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}