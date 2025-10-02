import 'package:flutter/material.dart';
import '../../firebaseconfig.dart';
import 'donate.dart';

class HotelHomeScreen extends StatefulWidget {
  const HotelHomeScreen({super.key});

  @override
  State<HotelHomeScreen> createState() => _HotelHomeScreenState();
}

class _HotelHomeScreenState extends State<HotelHomeScreen> {
  List<Map<String, dynamic>> donationRequests = [];
  bool isLoading = true;
  int totalDonations = 0;

  String _safeStringConversion(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is Map) return ''; // Return empty string for Map values
    return value.toString();
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      print('Loading donation requests...'); // Debug log
      print('Current user: ${getCurrentUserId()}'); // Debug log
      print('User authenticated: ${isUserAuthenticated()}'); // Debug log
      
      // Load donation requests
      final requestsSnapshot = await dbRef.child(DatabasePaths.donationRequests).get();
      print('Requests snapshot exists: ${requestsSnapshot.exists}'); // Debug log
      
      if (requestsSnapshot.exists) {
        print('Raw requests data: ${requestsSnapshot.value}'); // Debug log
        final requestsData = requestsSnapshot.value as Map<Object?, Object?>;
        List<Map<String, dynamic>> requests = [];
        
        print('Processing ${requestsData.length} requests'); // Debug log
        
        requestsData.forEach((key, value) {
          try {
            print('Processing request key: $key, value: $value'); // Debug log
            final request = Map<String, dynamic>.from(value as Map<Object?, Object?>);
            request['id'] = (key is String) ? key : key.toString();
            
            print('Request isActive: ${request['isActive']}'); // Debug log
            
            // Only add active requests
            if (request['isActive'] == true) {
              requests.add(request);
              print('Added active request: ${request['ngoName']}'); // Debug log
            }
          } catch (e) {
            print('Error processing request: $e');
            // Skip this entry if casting fails
          }
        });
        
        // Sort by creation date (newest first)
        requests.sort((a, b) {
          final aTime = a['createdAt'] ?? 0;
          final bTime = b['createdAt'] ?? 0;
          try {
            return (bTime as int).compareTo(aTime as int);
          } catch (e) {
            return 0;
          }
        });
        
        print('Total active requests found: ${requests.length}'); // Debug log
        
        setState(() {
          donationRequests = requests;
        });
        
        print('Updated state with ${donationRequests.length} requests'); // Debug log
      } else {
        print('No donation requests found in database'); // Debug log
      }

      // Load total donations count for current hotel
      final userId = getCurrentUserId();
      if (userId != null) {
        final donationsSnapshot = await dbRef.child(DatabasePaths.donations)
            .orderByChild('donorId')
            .equalTo(userId)
            .get();
        
        if (donationsSnapshot.exists) {
          final donationsData = donationsSnapshot.value as Map<Object?, Object?>;
          setState(() {
            totalDonations = donationsData.length;
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
            // Header
            Container(
              height: 140,
              decoration: const BoxDecoration(
                color: Color(0xFF6C63FF),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'HOTEL DASHBOARD',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Share your extra food with NGOs',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: _loadData,
                          icon: const Icon(
                            Icons.refresh,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.volunteer_activism,
                                  color: Colors.white,
                                  size: 22,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  totalDonations.toString(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const Text(
                                  'Donations',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.food_bank,
                                  color: Colors.white,
                                  size: 22,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  donationRequests.length.toString(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const Text(
                                  'Requests',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white70,
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

            // Search bar section
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
                    Icons.food_bank,
                    color: Color(0xFF6C63FF),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'NGO FOOD REQUESTS',
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

            // NGO Requests List
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadData,
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : donationRequests.isEmpty
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
                                    Icons.food_bank,
                                    size: 50,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'No food requests available',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'NGO requests will appear here',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: donationRequests.length,
                            itemBuilder: (context, index) {
                              final request = donationRequests[index];
                              return GestureDetector(
                                onTap: () {
                                  // Navigate to donate screen
                                  print('Tapped on: ${_safeStringConversion(request['ngoName'])}');
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DonateScreen(request: request),
                                    ),
                                  );
                                },
                                child: Container(
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
                                    child: Row(
                                      children: [
                                        // Left side icon
                                        Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
                                            color: const Color(0xFF6C63FF),
                                          ),
                                          child: const Icon(
                                            Icons.volunteer_activism,
                                            color: Colors.white,
                                            size: 30,
                                          ),
                                        ),
                                        const SizedBox(width: 15),
                                        // Content
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _safeStringConversion(request['ngoName']).isNotEmpty
                                                    ? _safeStringConversion(request['ngoName'])
                                                    : 'Unknown NGO',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 3,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: _safeStringConversion(request['foodType']) == 'Veg'
                                                          ? Colors.green
                                                          : _safeStringConversion(request['foodType']) == 'Non-Veg'
                                                              ? Colors.red
                                                              : Colors.orange,
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    child: Text(
                                                      _safeStringConversion(request['foodType']).isNotEmpty
                                                          ? _safeStringConversion(request['foodType'])
                                                          : 'Both',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                _safeStringConversion(request['description']).isNotEmpty
                                                    ? _safeStringConversion(request['description'])
                                                    : 'Looking for food donations',
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black54,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        // Right side View button
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
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
                                                  fontSize: 12,
                                                ),
                                              ),
                                              SizedBox(width: 4),
                                              Icon(
                                                Icons.arrow_forward_ios,
                                                color: Color(0xFF6C63FF),
                                                size: 12,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
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