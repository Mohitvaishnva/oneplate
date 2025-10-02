import 'package:flutter/material.dart';
import '../../firebaseconfig.dart';
import '../../services/firebase_service.dart';
import '../commonscreens/login.dart';

class HotelProfileScreen extends StatefulWidget {
  const HotelProfileScreen({super.key});

  @override
  State<HotelProfileScreen> createState() => _HotelProfileScreenState();
}

class _HotelProfileScreenState extends State<HotelProfileScreen> {
  Map<String, dynamic>? hotelData;
  bool isLoading = true;
  bool isEditing = false;
  
  // Controllers for editing
  final _ownerNameController = TextEditingController();
  final _hotelNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadHotelData();
  }

  @override
  void dispose() {
    _ownerNameController.dispose();
    _hotelNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadHotelData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final userId = getCurrentUserId();
      if (userId != null) {
        final snapshot = await dbRef.child(DatabasePaths.hotels).child(userId).get();
        if (snapshot.exists) {
          final data = Map<String, dynamic>.from(snapshot.value as Map);
          setState(() {
            hotelData = data;
            // Populate controllers for editing
            _ownerNameController.text = data['ownerName'] ?? '';
            _hotelNameController.text = data['hotelName'] ?? '';
            _addressController.text = data['address'] ?? '';
            _phoneController.text = data['phoneNumber'] ?? '';
          });
        }
      }
    } catch (e) {
      print('Error loading Hotel data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      isLoading = true;
    });

    try {
      final userId = getCurrentUserId();
      if (userId != null) {
        final updatedData = {
          ...hotelData!,
          'ownerName': _ownerNameController.text.trim(),
          'hotelName': _hotelNameController.text.trim(),
          'address': _addressController.text.trim(),
          'phoneNumber': _phoneController.text.trim(),
          'updatedAt': DateTime.now().toIso8601String(),
        };

        // Update both users and hotels collections
        await dbRef.child(DatabasePaths.users).child(userId).update(updatedData);
        await dbRef.child(DatabasePaths.hotels).child(userId).update(updatedData);

        setState(() {
          hotelData = updatedData;
          isEditing = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Color(0xFF6C63FF),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      await FirebaseService.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hotel Profile'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        actions: [
          if (!isEditing && hotelData != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  isEditing = true;
                });
              },
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hotelData == null
              ? const Center(
                  child: Text(
                    'No profile data found',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: isEditing ? _buildEditForm() : _buildProfileView(),
                ),
    );
  }

  Widget _buildProfileView() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF6C63FF),
                  radius: 50,
                  child: Text(
                    (hotelData!['hotelName'] ?? 'H')[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  hotelData!['hotelName'] ?? 'Unknown Hotel',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Hotel Partner',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          // Profile Details
          _buildDetailCard('Owner Name', hotelData!['ownerName'] ?? 'N/A', Icons.person),
          const SizedBox(height: 16),
          _buildDetailCard('Email', hotelData!['email'] ?? 'N/A', Icons.email),
          const SizedBox(height: 16),
          _buildDetailCard('Phone Number', hotelData!['phoneNumber'] ?? 'N/A', Icons.phone),
          const SizedBox(height: 16),
          _buildDetailCard('Address', hotelData!['address'] ?? 'N/A', Icons.location_on),
          
          const SizedBox(height: 32),
          
          // Account Info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Account Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Member since: ${_formatDate(hotelData!['createdAt'])}',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  if (hotelData!['updatedAt'] != null)
                    Text(
                      'Last updated: ${_formatDate(hotelData!['updatedAt'])}',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Owner Name
            TextFormField(
              controller: _ownerNameController,
              decoration: const InputDecoration(
                labelText: 'Owner Name',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter owner name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Hotel Name
            TextFormField(
              controller: _hotelNameController,
              decoration: const InputDecoration(
                labelText: 'Hotel Name',
                prefixIcon: Icon(Icons.business),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter hotel name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Address
            TextFormField(
              controller: _addressController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Address',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Phone Number
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        isEditing = false;
                        // Reset controllers
                        _ownerNameController.text = hotelData!['ownerName'] ?? '';
                        _hotelNameController.text = hotelData!['hotelName'] ?? '';
                        _addressController.text = hotelData!['address'] ?? '';
                        _phoneController.text = hotelData!['phoneNumber'] ?? '';
                      });
                    },
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF6C63FF)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }
}