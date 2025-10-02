import 'package:flutter/material.dart';
import '../../firebaseconfig.dart';
import '../../services/firebase_service.dart';
import '../../models/donation_request.dart';

class CreateDonationScreen extends StatefulWidget {
  const CreateDonationScreen({super.key});

  @override
  State<CreateDonationScreen> createState() => _CreateDonationScreenState();
}

class _CreateDonationScreenState extends State<CreateDonationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _foodNeededController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _selectedFoodType = 'Veg';
  bool _isLoading = false;
  String _ngoName = '';

  @override
  void initState() {
    super.initState();
    _loadNGOData();
  }

  @override
  void dispose() {
    _foodNeededController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadNGOData() async {
    try {
      final userId = FirebaseService.currentUserId;
      print('Loading NGO data for user ID: $userId');
      
      if (userId != null) {
        final ngo = await FirebaseService.getNGO(userId);
        print('NGO data retrieved: $ngo');
        
        if (ngo != null && mounted) {
          setState(() {
            _ngoName = ngo.name.isEmpty ? 'Unknown NGO' : ngo.name;
          });
          print('NGO name set to: $_ngoName');
        } else {
          print('NGO data is null or widget not mounted');
          if (mounted) {
            setState(() {
              _ngoName = 'Unknown NGO';
            });
          }
        }
      } else {
        print('User ID is null');
        if (mounted) {
          setState(() {
            _ngoName = 'Unknown NGO';
          });
        }
      }
    } catch (e) {
      print('Error loading NGO data: $e');
      print('Error type: ${e.runtimeType}');
      if (mounted) {
        setState(() {
          _ngoName = 'Unknown NGO';
        });
      }
    }
  }

  Future<void> _createDonationRequest() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final userId = getCurrentUserId();
        if (userId == null) {
          throw Exception('User not authenticated');
        }

        // Debug: Check authentication
        print('Current user ID: $userId');
        print('User authenticated: ${isUserAuthenticated()}');
        print('Firebase Auth user: ${firebaseAuth.currentUser?.email}');
        print('Firebase Auth UID: ${firebaseAuth.currentUser?.uid}');

        // Generate unique ID for the donation request
        final requestId = dbRef.child(DatabasePaths.donationRequests).push().key!;
        print('Generated request ID: $requestId');

        // Create DonationRequest object
        final donationRequest = DonationRequest(
          id: requestId,
          ngoId: userId,
          ngoName: _ngoName,
          description: '${_foodNeededController.text.trim()}${_notesController.text.isNotEmpty ? ' - ${_notesController.text.trim()}' : ''}',
          foodType: _selectedFoodType,
          createdAt: DateTime.now(),
          isActive: true,
        );

        print('Donation request data: ${donationRequest.toJson()}');

        // Write to database
        print('Writing to path: ${DatabasePaths.donationRequests}/$requestId');
        await dbRef.child(DatabasePaths.donationRequests).child(requestId).set(donationRequest.toJson());
        
        print('Database write successful!');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Donation request created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Clear form
          _foodNeededController.clear();
          _notesController.clear();
          setState(() {
            _selectedFoodType = 'Veg';
          });
        }
      } catch (e) {
        print('Error details: $e'); // Debug log
        print('Error type: ${e.runtimeType}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error creating request: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3142)),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6C63FF),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.add_circle,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Create Food Request',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3142),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Let donors know what food assistance you need',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF9A9A9A),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),
                
                // Form Section
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                  child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Request Details',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            // NGO Name (Auto-filled)
                            _buildModernTextField(
                              initialValue: _ngoName,
                              label: 'NGO Name',
                              icon: Icons.business,
                              enabled: false,
                            ),
                            const SizedBox(height: 20),
                            
                            // Food Needed
                            _buildModernTextField(
                              controller: _foodNeededController,
                              label: 'Food Needed (e.g., 100 plates)',
                              icon: Icons.restaurant,
                              hintText: 'Enter quantity and type of food needed',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please specify food needed';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            
                            // Food Type Selection
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: DropdownButtonFormField<String>(
                                value: _selectedFoodType,
                                dropdownColor: Colors.white,
                                style: const TextStyle(color: Colors.black87),
                                decoration: InputDecoration(
                                  labelText: 'Food Type',
                                  labelStyle: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.restaurant_menu,
                                    color: Color(0xFF6C63FF),
                                    size: 20,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                ),
                                items: ['Veg', 'Non-Veg', 'Both'].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: const TextStyle(color: Colors.black87),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedFoodType = newValue!;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            // Notes
                            _buildModernTextField(
                              controller: _notesController,
                              label: 'Additional Notes (Optional)',
                              icon: Icons.note,
                              hintText: 'Any specific requirements or details',
                              maxLines: 3,
                            ),
                            const SizedBox(height: 32),
                            
                            // Create Request Button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _createDonationRequest,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6C63FF),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      )
                                    : const Text(
                                        'Create Food Request',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    TextEditingController? controller,
    String? initialValue,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool obscureText = false,
    bool enabled = true,
    String? hintText,
    int? maxLines,
  }) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      enabled: enabled,
      maxLines: maxLines ?? 1,
      style: TextStyle(
        color: enabled ? Colors.black87 : Colors.black45,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        labelStyle: TextStyle(
          color: enabled ? const Color(0xFF6C63FF) : Colors.black45,
          fontSize: 14,
        ),
        hintStyle: const TextStyle(
          color: Colors.black38,
          fontSize: 14,
        ),
        prefixIcon: Icon(
          icon,
          color: enabled ? const Color(0xFF6C63FF) : Colors.black45,
          size: 20,
        ),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        errorStyle: const TextStyle(
          color: Colors.redAccent,
          fontSize: 12,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}