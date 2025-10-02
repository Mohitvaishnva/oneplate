import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import '../../models/user_models.dart' as models;
import '../../utils/database_enums.dart';
import 'ngomain.dart';

class RegisterNGOScreen extends StatefulWidget {
  const RegisterNGOScreen({super.key});

  @override
  State<RegisterNGOScreen> createState() => _RegisterNGOScreenState();
}

class _RegisterNGOScreenState extends State<RegisterNGOScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ownerNameController = TextEditingController();
  final _ngoNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _areaCoveredController = TextEditingController();
  final _licenseController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _ownerNameController.dispose();
    _ngoNameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _areaCoveredController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Create Firebase Auth user
      var result = await FirebaseService.signUpWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (result.success && result.user != null) {
        // Create User object
        final user = models.User(
          uid: FirebaseService.currentUserId!,
          email: _emailController.text.trim(),
          userType: UserType.ngo,
          name: _ownerNameController.text.trim(),
          phone: _phoneController.text.trim(),
          address: models.Address(
            street: _addressController.text.trim(),
            city: _cityController.text.trim(),
            state: _stateController.text.trim(),
            zipCode: _zipCodeController.text.trim(),
          ),
          createdAt: DateTime.now(),
        );

        // Create NGO object
        final ngo = models.NGO(
          uid: FirebaseService.currentUserId!,
          name: _ngoNameController.text.trim(),
          registrationNumber: _licenseController.text.trim(),
          focusAreas: ['Food Distribution'],
          servingAreas: [_areaCoveredController.text.trim()],
          capacity: 100,
          operatingHours: models.OperatingHours(
            open: '08:00',
            close: '20:00',
          ),
          verified: false,
          status: UserStatus.active,
        );

        // Save both User and NGO to database
        try {
          await FirebaseService.saveUser(user);
          await FirebaseService.saveNGO(ngo);
          
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('NGO registered successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const NGOMainScreen()),
          );
        } catch (e) {
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Registration failed: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ?? 'Registration failed. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3142)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Register Your NGO',
          style: TextStyle(
            color: Color(0xFF2D3142),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Header Section
                Column(
                  children: [
                    // NGO Logo Container
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            offset: const Offset(0, 5),
                            blurRadius: 15,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.volunteer_activism,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    const Text(
                      'Help Communities',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF9A9A9A),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Form Section
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        offset: const Offset(0, 2),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildModernTextField(
                              controller: _ownerNameController,
                              label: 'NGO Owner Name',
                              hint: 'Enter owner\'s full name',
                              icon: Icons.person_outlined,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter owner name';
                                }
                                return null;
                              },
                            ),
                            
                            const SizedBox(height: 20),
                            
                            _buildModernTextField(
                              controller: _ngoNameController,
                              label: 'NGO Name',
                              hint: 'Enter NGO organization name',
                              icon: Icons.business_outlined,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter NGO name';
                                }
                                return null;
                              },
                            ),
                            
                            const SizedBox(height: 20),
                            
                            _buildModernTextField(
                              controller: _emailController,
                              label: 'Email Address',
                              hint: 'Enter your email',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter email';
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            
                            const SizedBox(height: 20),
                            
                            _buildModernTextField(
                              controller: _passwordController,
                              label: 'Password',
                              hint: 'Enter your password',
                              icon: Icons.lock_outlined,
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            
                            const SizedBox(height: 20),
                            
                            _buildModernTextField(
                              controller: _phoneController,
                              label: 'Phone Number',
                              hint: 'Enter your phone number',
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter phone number';
                                }
                                return null;
                              },
                            ),
                            
                            const SizedBox(height: 20),
                            
                            _buildModernTextField(
                              controller: _addressController,
                              label: 'NGO Address',
                              hint: 'Enter complete address',
                              icon: Icons.location_on_outlined,
                              maxLines: 3,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter NGO address';
                                }
                                return null;
                              },
                            ),
                            
                            const SizedBox(height: 20),
                            
                            Row(
                              children: [
                                Expanded(
                                  child: _buildModernTextField(
                                    controller: _cityController,
                                    label: 'City',
                                    hint: 'Enter city',
                                    icon: Icons.location_city_outlined,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Enter city';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildModernTextField(
                                    controller: _stateController,
                                    label: 'State',
                                    hint: 'Enter state',
                                    icon: Icons.map_outlined,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Enter state';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 20),
                            
                            Row(
                              children: [
                                Expanded(
                                  child: _buildModernTextField(
                                    controller: _zipCodeController,
                                    label: 'ZIP Code',
                                    hint: 'Enter ZIP code',
                                    icon: Icons.local_post_office_outlined,
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Enter ZIP';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildModernTextField(
                                    controller: _licenseController,
                                    label: 'Registration Number',
                                    hint: 'Enter reg. number',
                                    icon: Icons.card_membership_outlined,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Enter registration';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 20),
                            
                            _buildModernTextField(
                              controller: _areaCoveredController,
                              label: 'Area Covered',
                              hint: 'Enter service areas',
                              icon: Icons.map_outlined,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter area covered';
                                }
                                return null;
                              },
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // Register Button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _register,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6C63FF),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  disabledBackgroundColor: const Color(0xFF6C63FF).withOpacity(0.6),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : const Text(
                                        'Register NGO',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Already have account
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Already have an account? ",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF9A9A9A),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text(
                                    'Sign In',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF6C63FF),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
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
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Color(0xFF0F172A),
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF6C63FF),
          size: 20,
        ),
        labelStyle: const TextStyle(
          color: Color(0xFF9A9A9A),
          fontSize: 14,
        ),
        hintStyle: const TextStyle(
          color: Color(0xFF9A9A9A),
          fontSize: 14,
        ),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF6C63FF),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      validator: validator,
    );
  }
}