import 'package:flutter/material.dart';
import '../../firebaseconfig.dart';
import 'donordetails.dart';

class NGOHomeScreen extends StatefulWidget {
  const NGOHomeScreen({super.key});

  @override
  State<NGOHomeScreen> createState() => _NGOHomeScreenState();
}

class _NGOHomeScreenState extends State<NGOHomeScreen> {
  List<Map<String, dynamic>> donations = [];
  List<Map<String, dynamic>> myRequests = [];
  bool isLoading = true;
  int totalDonors = 0;
  int totalDeliveries = 0;
  int pendingDeliveries = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  String _safeStringConversion(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is Map) return value.toString();
    return value.toString();
  }

  String _safeStringWithFallback(dynamic value, String fallback) {
    final result = _safeStringConversion(value);
    return result.isEmpty ? fallback : result;
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Unknown date';
    try {
      final date = DateTime.fromMillisecondsSinceEpoch(
        timestamp is int ? timestamp : int.parse(timestamp.toString())
      );
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inDays < 1) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return 'Unknown date';
    }
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return '';
    try {
      final date = DateTime.fromMillisecondsSinceEpoch(
        timestamp is int ? timestamp : int.parse(timestamp.toString())
      );
      final hour = date.hour > 12 ? date.hour - 12 : date.hour;
      final period = date.hour >= 12 ? 'PM' : 'AM';
      return '${hour == 0 ? 12 : hour}:${date.minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      return '';
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final userId = getCurrentUserId();
      if (userId != null) {
        // Load available donations from hotels/individuals
        final donationsSnapshot = await dbRef.child(DatabasePaths.donations)
            .orderByChild('status')
            .equalTo('available')
            .get();
        
        if (donationsSnapshot.exists) {
          final donationsData = donationsSnapshot.value as Map<Object?, Object?>;
          List<Map<String, dynamic>> donationsList = [];
          
          // Process each donation and fetch donor details
          for (var entry in donationsData.entries) {
            try {
              final key = entry.key;
              final value = entry.value;
              final donation = Map<String, dynamic>.from(value as Map<Object?, Object?>);
              donation['id'] = (key is String) ? key : key.toString();
              
              // Fetch donor information from users database
              final donorId = donation['donorId'];
              if (donorId != null) {
                final donorSnapshot = await dbRef.child(DatabasePaths.users).child(donorId.toString()).get();
                if (donorSnapshot.exists) {
                  final donorData = Map<String, dynamic>.from(donorSnapshot.value as Map<Object?, Object?>);
                  // Add donor details to donation
                  donation['donorName'] = donorData['name'] ?? donorData['hotelName'] ?? donorData['ngoName'] ?? 'Anonymous Donor';
                  donation['donorPhone'] = donorData['phone'] ?? donorData['phoneNumber'] ?? '';
                  donation['donorEmail'] = donorData['email'] ?? '';
                  donation['donorAddress'] = donorData['address'] ?? '';
                  donation['donorUserType'] = donorData['userType'] ?? 'unknown';
                }
                
                // Also check hotel/individual specific tables for more details
                if (donation['donorUserType'] == 'hotel') {
                  final hotelSnapshot = await dbRef.child(DatabasePaths.hotels).child(donorId.toString()).get();
                  if (hotelSnapshot.exists) {
                    final hotelData = Map<String, dynamic>.from(hotelSnapshot.value as Map<Object?, Object?>);
                    donation['donorName'] = hotelData['name'] ?? donation['donorName'];
                    donation['cuisine'] = hotelData['cuisine'] ?? [];
                    donation['verified'] = hotelData['verified'] ?? false;
                  }
                } else if (donation['donorUserType'] == 'individual') {
                  final individualSnapshot = await dbRef.child(DatabasePaths.individuals).child(donorId.toString()).get();
                  if (individualSnapshot.exists) {
                    final individualData = Map<String, dynamic>.from(individualSnapshot.value as Map<Object?, Object?>);
                    donation['donorName'] = individualData['name'] ?? donation['donorName'];
                  }
                }
              }
              
              donationsList.add(donation);
            } catch (e) {
              print('Error processing donation: $e');
              // Skip this entry if there's an error
            }
          }
          
          // Sort by timestamp (newest first)
          donationsList.sort((a, b) {
            final aTime = (a['timestamp'] ?? 0).toString();
            final bTime = (b['timestamp'] ?? 0).toString();
            try {
              return int.parse(bTime).compareTo(int.parse(aTime));
            } catch (e) {
              return 0;
            }
          });
          
          setState(() {
            donations = donationsList;
            // Calculate statistics
            totalDonors = donations.map((d) => d['donorId']).toSet().length;
            totalDeliveries = 0; // NGOs can't see completed deliveries of others
            pendingDeliveries = donations.length;
          });
        }

        // Load my donation requests
        final requestsSnapshot = await dbRef.child(DatabasePaths.donationRequests)
            .orderByChild('ngoId')
            .equalTo(userId)
            .get();
        
        if (requestsSnapshot.exists) {
          final requestsData = requestsSnapshot.value as Map<Object?, Object?>;
          List<Map<String, dynamic>> requestsList = [];
          
          requestsData.forEach((key, value) {
            try {
              final request = Map<String, dynamic>.from(value as Map<Object?, Object?>);
              request['id'] = (key is String) ? key : key.toString();
              requestsList.add(request);
            } catch (e) {
              print('Error processing request: $e');
              // Skip this entry if casting fails
            }
          });
          
          setState(() {
            myRequests = requestsList;
          });
        }
      }
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Header with statistics
            Container(
              height: 280,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'NGO DASHBOARD',
                          style: TextStyle(
                            color: Color(0xFF2D3142),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: _loadData,
                          icon: const Icon(
                            Icons.refresh,
                            color: Color(0xFF6C63FF),
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.95),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.fastfood,
                                      color: Colors.orange,
                                      size: 30,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      pendingDeliveries.toString(),
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange,
                                      ),
                                    ),
                                    const Text(
                                      'Available',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.95),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.people,
                                      color: Color(0xFF6C63FF),
                                      size: 30,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      totalDonors.toString(),
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF6C63FF),
                                      ),
                                    ),
                                    const Text(
                                      'Donors',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.95),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today,
                                      color: Colors.green,
                                      size: 30,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      donations.where((d) {
                                        final timestamp = d['timestamp'] ?? 0;
                                        final donationTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
                                        final weekAgo = DateTime.now().subtract(const Duration(days: 7));
                                        return donationTime.isAfter(weekAgo);
                                      }).length.toString(),
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                    const Text(
                                      'This Week',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Search bar
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'SEARCH',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.search,
                    color: Colors.grey,
                    size: 24,
                  ),
                ],
              ),
            ),

            // Section title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    color: Color(0xFF6C63FF),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'FOOD DONATIONS AVAILABLE NEARBY',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // Donations List
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF6C63FF),
                      ),
                    )
                  : donations.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6C63FF),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.no_food,
                                  size: 50,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'No donations available',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Donations will appear here when\ndonors create food offerings',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: donations.length,
                          itemBuilder: (context, index) {
                            final donation = donations[index];
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
                              child: ListTile(
                                        contentPadding: const EdgeInsets.all(20),
                                leading: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: const Color(0xFF6C63FF),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.restaurant_menu,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                      if (donation['quantity'] != null)
                                        Text(
                                          '${donation['quantity']}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                        title: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    _safeStringWithFallback(donation['donorName'], 'Unknown Donor'),
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 18,
                                                      color: Colors.black87,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                if (donation['verified'] == true)
                                                  const Icon(
                                                    Icons.verified,
                                                    color: Colors.blue,
                                                    size: 16,
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.access_time,
                                                  color: Colors.grey,
                                                  size: 14,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  _formatDate(donation['timestamp']),
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                if (_formatTime(donation['timestamp']).isNotEmpty) ...[
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    _formatTime(donation['timestamp']),
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                            const SizedBox(height: 5),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.location_on,
                                                  color: Colors.grey,
                                                  size: 16,
                                                ),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    _safeStringWithFallback(donation['location'], '') != '' ? 
                                                              _safeStringWithFallback(donation['location'], '') : 
                                                              _safeStringWithFallback(donation['donorAddress'], 'Location not specified'),
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 14,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        subtitle: Container(
                                          margin: const EdgeInsets.only(top: 10),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              if (_safeStringConversion(donation['description']).isNotEmpty)
                                                Text(
                                                  _safeStringConversion(donation['description']),
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black54,
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              const SizedBox(height: 8),
                                              Wrap(
                                                spacing: 8,
                                                runSpacing: 8,
                                                crossAxisAlignment: WrapCrossAlignment.center,
                                                children: [
                                                  // Food Type Badge
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: _safeStringWithFallback(donation['foodType'], 'Both') == 'Veg'
                                                          ? Colors.green
                                                          : _safeStringWithFallback(donation['foodType'], 'Both') == 'Non-Veg'
                                                              ? Colors.red
                                                              : Colors.orange,
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          _safeStringWithFallback(donation['foodType'], 'Both') == 'Veg'
                                                              ? Icons.eco
                                                              : Icons.restaurant,
                                                          color: Colors.white,
                                                          size: 12,
                                                        ),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          _safeStringWithFallback(donation['foodType'], 'Both'),
                                                          style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 11,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  // Status Badge
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.green.withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(12),
                                                      border: Border.all(color: Colors.green, width: 1),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Container(
                                                          width: 6,
                                                          height: 6,
                                                          decoration: const BoxDecoration(
                                                            color: Colors.green,
                                                            shape: BoxShape.circle,
                                                          ),
                                                        ),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          _safeStringWithFallback(donation['status'], 'Available'),
                                                          style: const TextStyle(
                                                            color: Colors.green,
                                                            fontSize: 11,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  // View Button
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 5,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFF6C63FF).withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                    child: const Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          'View',
                                                          style: TextStyle(
                                                            color: Color(0xFF6C63FF),
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 11,
                                                          ),
                                                        ),
                                                        SizedBox(width: 3),
                                                        Icon(
                                                          Icons.arrow_forward_ios,
                                                          color: Color(0xFF6C63FF),
                                                          size: 10,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DonorDetailsScreen(donation: donation),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}