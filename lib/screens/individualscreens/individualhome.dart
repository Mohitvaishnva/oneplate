import 'package:flutter/material.dart';
import '../../firebaseconfig.dart';
import '../hotelscreens/ngodetails.dart';

class IndividualHomeScreen extends StatefulWidget {
  const IndividualHomeScreen({super.key});

  @override
  State<IndividualHomeScreen> createState() => _IndividualHomeScreenState();
}

class _IndividualHomeScreenState extends State<IndividualHomeScreen> {
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
      // Load donation requests
      final requestsSnapshot = await dbRef.child(DatabasePaths.donationRequests).get();
      if (requestsSnapshot.exists) {
        final requestsData = requestsSnapshot.value as Map<Object?, Object?>;
        List<Map<String, dynamic>> requests = [];
        
        requestsData.forEach((key, value) {
          try {
            final request = Map<String, dynamic>.from(value as Map<Object?, Object?>);
            request['id'] = (key is String) ? key : key.toString();
            
            // Only add active requests
            if (request['isActive'] == true) {
              requests.add(request);
            }
          } catch (e) {
            print('Error processing request: $e');
            // Skip this entry if casting fails
          }
        });
        
        setState(() {
          donationRequests = requests;
        });
      }

      // Load total donations count for current individual
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
            // Header with gradient
            Container(
              height: 200,
              decoration: const BoxDecoration(
                color: Color(0xFFB19CD9), // Same light purple as hotel screen
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'INDIVIDUAL DASHBOARD',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
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
                                  Icons.volunteer_activism,
                                  color: Colors.green,
                                  size: 30,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  totalDonations.toString(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                const Text(
                                  'My Donations',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
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
                                  Icons.food_bank,
                                  color: Colors.orange,
                                  size: 30,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  donationRequests.length.toString(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                                const Text(
                                  'Available Requests',
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
                    color: Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'NGO DONATION REQUESTS NEARBY',
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

            // Donation Requests List
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      child: donationRequests.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.no_food,
                                    size: 80,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'No donation requests available',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
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
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.green.withOpacity(0.8),
                                            Colors.teal.withOpacity(0.9),
                                          ],
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: const Icon(
                                          Icons.volunteer_activism,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                    title: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _safeStringConversion(request['ngoName']).isNotEmpty
                                              ? _safeStringConversion(request['ngoName'])
                                              : 'Unknown NGO',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: Colors.black87,
                                          ),
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
                                            Text(
                                              'Nearby Location',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14,
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
                                          Text(
                                            _safeStringConversion(request['description']).isNotEmpty
                                                ? _safeStringConversion(request['description'])
                                                : 'Food assistance needed',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black54,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.green,
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  _safeStringConversion(request['foodType']).isNotEmpty
                                                      ? _safeStringConversion(request['foodType'])
                                                      : 'Both',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const Spacer(),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 6,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.green.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: const Text(
                                                  'View',
                                                  style: TextStyle(
                                                    color: Colors.green,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
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
                                          builder: (context) => NGODetailsScreen(
                                            request: request,
                                          ),
                                        ),
                                      );
                                    },
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