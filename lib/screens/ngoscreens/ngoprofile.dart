import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../firebaseconfig.dart';
import '../../services/firebase_service.dart';
import '../commonscreens/login.dart';

class NGOProfileScreen extends StatefulWidget {
  const NGOProfileScreen({super.key});

  @override
  State<NGOProfileScreen> createState() => _NGOProfileScreenState();
}

class _NGOProfileScreenState extends State<NGOProfileScreen> {
  Map<String, dynamic>? ngoData;
  bool isLoading = true;
  bool isEditing = false;
  File? _profileImage;
  final _imagePicker = ImagePicker();
  
  // Controllers for editing
  final _ownerNameController = TextEditingController();
  final _ngoNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _areaCoveredController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadNGOData();
  }

  String _safeStringConversion(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is Map) return ''; // Return empty string for Map values
    return value.toString();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _ownerNameController.dispose();
    _ngoNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _areaCoveredController.dispose();
    super.dispose();
  }

  Future<void> _loadNGOData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final userId = getCurrentUserId();
      if (userId != null) {
        final snapshot = await dbRef.child(DatabasePaths.ngos).child(userId).get();
        if (snapshot.exists) {
          final data = Map<String, dynamic>.from(snapshot.value as Map<Object?, Object?>);
          setState(() {
            ngoData = data;
            // Populate controllers for editing with safe string conversion
            _ownerNameController.text = _safeStringConversion(data['ownerName']);
            _ngoNameController.text = _safeStringConversion(data['ngoName']);
            _addressController.text = _safeStringConversion(data['address']);
            _phoneController.text = _safeStringConversion(data['phoneNumber']);
            _areaCoveredController.text = _safeStringConversion(data['areaCovered']);
          });
        }
      }
    } catch (e) {
      print('Error loading NGO data: $e');
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
        String? profileImageUrl = _safeStringConversion(ngoData!['profileImageUrl']);
        
        // TODO: Upload profile image to Firebase Storage if _profileImage is not null
        // This requires Firebase Storage setup. For now, we'll save the local path
        // In production, you should upload to Firebase Storage and get the download URL
        if (_profileImage != null) {
          // Placeholder: In production, upload to Firebase Storage here
          // Example:
          // final storageRef = FirebaseStorage.instance.ref().child('profile_images/$userId.jpg');
          // final uploadTask = await storageRef.putFile(_profileImage!);
          // profileImageUrl = await uploadTask.ref.getDownloadURL();
          
          // For now, just show a message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Note: Image upload requires Firebase Storage setup'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
        
        final updatedData = {
          ...ngoData!,
          'ownerName': _ownerNameController.text.trim(),
          'ngoName': _ngoNameController.text.trim(),
          'address': _addressController.text.trim(),
          'phoneNumber': _phoneController.text.trim(),
          'areaCovered': _areaCoveredController.text.trim(),
          'updatedAt': DateTime.now().toIso8601String(),
          if (profileImageUrl.isNotEmpty) 'profileImageUrl': profileImageUrl,
        };

        // Update both users and ngos collections
        await dbRef.child(DatabasePaths.users).child(userId).update(updatedData);
        await dbRef.child(DatabasePaths.ngos).child(userId).update(updatedData);

        setState(() {
          ngoData = updatedData;
          isEditing = false;
          _profileImage = null; // Clear the selected image
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
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'NGO Profile',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF6C63FF),
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          if (!isEditing && ngoData != null)
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
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(0xFF6C63FF),
                ),
              ),
            )
          : ngoData == null
              ? const Center(
                  child: Text(
                    'No profile data found',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(24.0),
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
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF6C63FF),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF6C63FF),
                          ),
                          child: ClipOval(
                            child: _profileImage != null
                                ? Image.file(
                                    _profileImage!,
                                    fit: BoxFit.cover,
                                    width: 100,
                                    height: 100,
                                  )
                                : (_safeStringConversion(ngoData!['profileImageUrl']).isNotEmpty
                                    ? Image.network(
                                        _safeStringConversion(ngoData!['profileImageUrl']),
                                        fit: BoxFit.cover,
                                        width: 100,
                                        height: 100,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Center(
                                            child: Text(
                                              _safeStringConversion(ngoData!['ngoName']).isNotEmpty ? _safeStringConversion(ngoData!['ngoName'])[0].toUpperCase() : 'N',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 32,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                    : Center(
                                        child: Text(
                                          _safeStringConversion(ngoData!['ngoName']).isNotEmpty ? _safeStringConversion(ngoData!['ngoName'])[0].toUpperCase() : 'N',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )),
                          ),
                        ),
                      ),
                    ),
                    if (isEditing)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFF6C63FF),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _safeStringConversion(ngoData!['ngoName']).isNotEmpty ? _safeStringConversion(ngoData!['ngoName']) : 'Unknown NGO',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'NGO Organization',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                if (isEditing && _profileImage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'New photo selected',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6C63FF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          // Profile Details
                    _buildDetailCard('Owner Name', _safeStringConversion(ngoData!['ownerName']).isNotEmpty ? _safeStringConversion(ngoData!['ownerName']) : 'N/A', Icons.person),
          const SizedBox(height: 16),
          _buildDetailCard('Email', _safeStringConversion(ngoData!['email']).isNotEmpty ? _safeStringConversion(ngoData!['email']) : 'N/A', Icons.email),
          const SizedBox(height: 16),
          _buildDetailCard('Phone Number', _safeStringConversion(ngoData!['phoneNumber']).isNotEmpty ? _safeStringConversion(ngoData!['phoneNumber']) : 'N/A', Icons.phone),
          const SizedBox(height: 16),
          _buildDetailCard('Address', _safeStringConversion(ngoData!['address']).isNotEmpty ? _safeStringConversion(ngoData!['address']) : 'N/A', Icons.location_on),
          const SizedBox(height: 16),
          _buildDetailCard('Area Covered', _safeStringConversion(ngoData!['areaCovered']).isNotEmpty ? _safeStringConversion(ngoData!['areaCovered']) : 'N/A', Icons.map),
          
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
                    'Member since: ${_formatDate(ngoData!['createdAt'])}',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  if (ngoData!['updatedAt'] != null)
                    Text(
                      'Last updated: ${_formatDate(ngoData!['updatedAt'])}',
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
            
            // NGO Name
            TextFormField(
              controller: _ngoNameController,
              decoration: const InputDecoration(
                labelText: 'NGO Name',
                prefixIcon: Icon(Icons.business),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter NGO name';
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
            const SizedBox(height: 16),
            
            // Area Covered
            TextFormField(
              controller: _areaCoveredController,
              decoration: const InputDecoration(
                labelText: 'Area Covered',
                prefixIcon: Icon(Icons.map),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter area covered';
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
                        _profileImage = null; // Clear selected image
                        // Reset controllers
                        _ownerNameController.text = _safeStringConversion(ngoData!['ownerName']);
                        _ngoNameController.text = _safeStringConversion(ngoData!['ngoName']);
                        _addressController.text = _safeStringConversion(ngoData!['address']);
                        _phoneController.text = _safeStringConversion(ngoData!['phoneNumber']);
                        _areaCoveredController.text = _safeStringConversion(ngoData!['areaCovered']);
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
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget _buildDetailCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
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
                  value.toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic dateInput) {
    if (dateInput == null) return 'Unknown';
    try {
      final dateString = dateInput.toString();
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }
}