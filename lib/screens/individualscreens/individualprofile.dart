import 'package:flutter/material.dart';
import '../../firebaseconfig.dart';
import '../../services/firebase_service.dart';
import '../commonscreens/login.dart';

class IndividualProfileScreen extends StatefulWidget {
  const IndividualProfileScreen({super.key});

  @override
  State<IndividualProfileScreen> createState() => _IndividualProfileScreenState();
}

class _IndividualProfileScreenState extends State<IndividualProfileScreen> {
  Map<String, dynamic>? individualData;
  bool isLoading = true;
  bool isEditing = false;
  
  // Controllers for editing
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadIndividualData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadIndividualData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final userId = getCurrentUserId();
      if (userId != null) {
        final snapshot = await dbRef.child(DatabasePaths.individuals).child(userId).get();
        if (snapshot.exists) {
          final data = Map<String, dynamic>.from(snapshot.value as Map);
          setState(() {
            individualData = data;
            // Populate controllers for editing
            _nameController.text = data['name'] ?? '';
            _addressController.text = data['address'] ?? '';
            _phoneController.text = data['phoneNumber'] ?? '';
          });
        }
      }
    } catch (e) {
      print('Error loading Individual data: $e');
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
          ...individualData!,
          'name': _nameController.text.trim(),
          'address': _addressController.text.trim(),
          'phoneNumber': _phoneController.text.trim(),
          'updatedAt': DateTime.now().toIso8601String(),
        };

        // Update both users and individuals collections
        await dbRef.child(DatabasePaths.users).child(userId).update(updatedData);
        await dbRef.child(DatabasePaths.individuals).child(userId).update(updatedData);

        setState(() {
          individualData = updatedData;
          isEditing = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green,
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
        title: const Text('My Profile'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          if (!isEditing && individualData != null)
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
          : individualData == null
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
                  backgroundColor: Colors.green,
                  radius: 50,
                  child: Text(
                    (individualData!['name'] ?? 'U')[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  individualData!['name'] ?? 'Unknown User',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Individual Donor',
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
          _buildDetailCard('Email', individualData!['email'] ?? 'N/A', Icons.email),
          const SizedBox(height: 16),
          _buildDetailCard('Phone Number', individualData!['phoneNumber'] ?? 'N/A', Icons.phone),
          const SizedBox(height: 16),
          _buildDetailCard('Address', individualData!['address'] ?? 'N/A', Icons.location_on),
          
          const SizedBox(height: 32),
          
          // Donation Stats
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Donation Statistics',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.volunteer_activism, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        'Total Donations: ${individualData!['totalDonations'] ?? 0}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.people, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        'People Helped: ${individualData!['peopleHelped'] ?? 0}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
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
                    'Member since: ${_formatDate(individualData!['createdAt'])}',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  if (individualData!['updatedAt'] != null)
                    Text(
                      'Last updated: ${_formatDate(individualData!['updatedAt'])}',
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
            // Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
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
                  return 'Please enter your address';
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
                  return 'Please enter your phone number';
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
                        _nameController.text = individualData!['name'] ?? '';
                        _addressController.text = individualData!['address'] ?? '';
                        _phoneController.text = individualData!['phoneNumber'] ?? '';
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
                      backgroundColor: Colors.green,
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
            Icon(icon, color: Colors.green),
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