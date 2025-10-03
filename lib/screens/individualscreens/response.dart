import 'package:flutter/material.dart';
import '../../firebaseconfig.dart';

class IndividualResponseScreen extends StatefulWidget {
  const IndividualResponseScreen({super.key});

  @override
  State<IndividualResponseScreen> createState() => _IndividualResponseScreenState();
}

class _IndividualResponseScreenState extends State<IndividualResponseScreen> {
  List<Map<String, dynamic>> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      isLoading = true;
    });

    try {
      final currentUserId = getCurrentUserId();
      if (currentUserId != null) {
        // Fetch notifications for NGO responses/acceptances
        final notificationsSnapshot = await dbRef
            .child('notifications')
            .orderByChild('donorId')
            .equalTo(currentUserId)
            .get();

        if (notificationsSnapshot.exists) {
          final notificationsData = notificationsSnapshot.value as Map<Object?, Object?>;
          List<Map<String, dynamic>> loadedNotifications = [];

          for (var entry in notificationsData.entries) {
            try {
              final notification = Map<String, dynamic>.from(entry.value as Map<Object?, Object?>);
              notification['id'] = entry.key.toString();
              
              // Only show donation acceptance notifications for individual donors
              if (notification['donorType'] == 'individual' && 
                  notification['type'] == 'donation_accepted') {
                
                // Fetch additional donation details if needed
                final donationId = notification['donationId'];
                if (donationId != null) {
                  final donationSnapshot = await dbRef
                      .child('donations')
                      .child(donationId)
                      .get();
                  
                  if (donationSnapshot.exists) {
                    final donationData = Map<String, dynamic>.from(donationSnapshot.value as Map<Object?, Object?>);
                    notification['donationDetails'] = donationData;
                  }
                }
                
                loadedNotifications.add(notification);
              }
            } catch (e) {
              print('Error processing notification: $e');
              // Skip invalid notifications
            }
          }

          // Sort by timestamp (newest first)
          loadedNotifications.sort((a, b) {
            final aTime = a['timestamp'] ?? 0;
            final bTime = b['timestamp'] ?? 0;
            return (bTime as int).compareTo(aTime as int);
          });

          setState(() {
            notifications = loadedNotifications;
          });
        }
      }
    } catch (e) {
      print('Error loading notifications: $e');
      // Handle error
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Unknown date';
    try {
      final date = DateTime.fromMillisecondsSinceEpoch(
        timestamp is int ? timestamp : int.parse(timestamp.toString())
      );
      return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Unknown date';
    }
  }

  String _getStatusText(String? status) {
    switch (status?.toLowerCase()) {
      case 'accepted':
        return 'Awaiting pickup';
      case 'picked_up':
        return 'Picked up successfully';
      case 'completed':
        return 'Donation completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Processing';
    }
  }

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
                  'NGO RESPONSES',
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
              child: RefreshIndicator(
                onRefresh: _loadNotifications,
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : notifications.isEmpty
                        ? Center(
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
                                    Icons.chat_bubble_outline,
                                    size: 60,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 30),
                                const Text(
                                  'No responses yet',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 40),
                                  child: Text(
                                    'NGOs who accept your donations will appear here',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(20),
                            itemCount: notifications.length,
                            itemBuilder: (context, index) {
                              final notification = notifications[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 15),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF6C63FF),
                                              borderRadius: BorderRadius.circular(25),
                                            ),
                                            child: const Icon(
                                              Icons.volunteer_activism,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  notification['ngoName'] ?? 'NGO',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  notification['message'] ?? 'Accepted your donation',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                                if (notification['donationTitle'] != null) ...[
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'Donation: ${notification['donationTitle']}',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.black45,
                                                      fontStyle: FontStyle.italic,
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.green.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Text(
                                              'ACCEPTED',
                                              style: TextStyle(
                                                color: Colors.green,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.restaurant_menu,
                                            size: 16,
                                            color: Color(0xFF6C63FF),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${notification['foodType'] ?? 'Food'} • ${notification['quantity'] ?? 'N/A'} servings',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.access_time,
                                            size: 16,
                                            color: Color(0xFF6C63FF),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Accepted: ${_formatDate(notification['timestamp'])}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Add pickup status if available
                                      if (notification['donationDetails'] != null) ...[
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.info_outline,
                                                size: 16,
                                                color: Colors.blue,
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  'Status: ${_getStatusText(notification['donationDetails']['status'])}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.blue,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}