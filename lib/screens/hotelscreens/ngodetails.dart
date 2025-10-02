import 'package:flutter/material.dart';
import 'donate.dart';

class NGODetailsScreen extends StatelessWidget {
  final Map<String, dynamic> request;
  
  const NGODetailsScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NGO Details'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // NGO Information Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.green,
                          radius: 30,
                          child: Text(
                            (request['ngoName'] ?? 'N')[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                request['ngoName'] ?? 'Unknown NGO',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'NGO Organization',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Food Request Details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Food Request Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Description
                    Text(
                      'Description:',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      request['description'] ?? 'No description available',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    
                    // Food Type
                    Row(
                      children: [
                        Text(
                          'Food Type: ',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                        Icon(
                          (request['foodType'] ?? '') == 'Veg' ? Icons.eco :
                          (request['foodType'] ?? '') == 'Non-Veg' ? Icons.restaurant :
                          Icons.restaurant_menu,
                          size: 20,
                          color: (request['foodType'] ?? '') == 'Veg' ? Colors.green :
                                 (request['foodType'] ?? '') == 'Non-Veg' ? Colors.red :
                                 Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          request['foodType'] ?? 'Mixed',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: (request['foodType'] ?? '') == 'Veg' ? Colors.green :
                                   (request['foodType'] ?? '') == 'Non-Veg' ? Colors.red :
                                   Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Created Date
                    Text(
                      'Request Date: ${_formatDateTime(request['createdAt'])}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            
            // Send Donation Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DonateScreen(request: request),
                    ),
                  );
                },
                icon: const Icon(Icons.volunteer_activism),
                label: const Text(
                  'Send Donation',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(dynamic dateTime) {
    if (dateTime == null) return 'Unknown date';
    
    // Handle both DateTime objects and timestamp strings
    DateTime date;
    if (dateTime is String) {
      try {
        date = DateTime.parse(dateTime);
      } catch (e) {
        return 'Invalid date';
      }
    } else if (dateTime is DateTime) {
      date = dateTime;
    } else {
      return 'Unknown date format';
    }
    
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}