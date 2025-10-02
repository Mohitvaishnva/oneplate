import 'package:flutter/material.dart';

class NGOResponseScreen extends StatefulWidget {
  final String donorName;
  final String donorPhone;
  final String donorType;
  final Map<String, String> donationDetails;

  const NGOResponseScreen({
    super.key,
    required this.donorName,
    required this.donorPhone,
    required this.donorType,
    required this.donationDetails,
  });

  @override
  State<NGOResponseScreen> createState() => _NGOResponseScreenState();
}

class _NGOResponseScreenState extends State<NGOResponseScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donation Response'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Success Message
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Donation Response Received!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'A donor has responded to your request',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Donor Information
            const Text(
              'Donor Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Name:', widget.donorName),
                    _buildInfoRow('Phone:', widget.donorPhone),
                    _buildInfoRow('Type:', widget.donorType.toUpperCase()),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Donation Details
            const Text(
              'Donation Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Food Type:', widget.donationDetails['foodType'] ?? ''),
                    _buildInfoRow('Quantity:', widget.donationDetails['quantity'] ?? ''),
                    if (widget.donationDetails['notes']?.isNotEmpty == true)
                      _buildInfoRow('Notes:', widget.donationDetails['notes'] ?? ''),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _callDonor(),
                    icon: const Icon(Icons.phone),
                    label: const Text('Call Donor'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _callDonor() {
    // TODO: Implement phone call functionality
    // You can use url_launcher package to make phone calls
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Call ${widget.donorPhone}'),
        backgroundColor: Colors.green,
      ),
    );
  }
}