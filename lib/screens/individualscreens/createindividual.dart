import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/firebase_service.dart';
import '../../utils/database_enums.dart';
import '../../models/donation_models.dart';
import 'individualmain.dart';

class CreateIndividualDonationScreen extends StatefulWidget {
  const CreateIndividualDonationScreen({super.key});

  @override
  State<CreateIndividualDonationScreen> createState() => _CreateIndividualDonationScreenState();
}

class _CreateIndividualDonationScreenState extends State<CreateIndividualDonationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _foodTypeController = TextEditingController();
  final _quantityController = TextEditingController();
  final _contactController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  File? _selectedImage;
  bool _isLoading = false;
  DateTime _selectedExpiryTime = DateTime.now().add(const Duration(hours: 4));

  @override
  void dispose() {
    _foodTypeController.dispose();
    _quantityController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _selectExpiryTime() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _selectedExpiryTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 7)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6C63FF),
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null && mounted) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedExpiryTime),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF6C63FF),
              ),
            ),
            child: child!,
          );
        },
      );

      if (time != null) {
        setState(() {
          _selectedExpiryTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _createDonation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get current user info
      final currentUser = FirebaseService.currentUser;
      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      final userInfo = await FirebaseService.getUser(currentUser.uid);
      if (userInfo == null) {
        throw Exception('User information not found');
      }

      // Create the donation object
      final donation = Donation(
        id: '', // Will be set by Firebase
        donorId: currentUser.uid,
        donorType: UserType.individual,
        donorName: userInfo.name,
        title: _foodTypeController.text.trim(),
        description: _descriptionController.text.trim(),
        foodType: _foodTypeController.text.trim(),
        quantity: _quantityController.text.trim(),
        expiryTime: _selectedExpiryTime,
        createdAt: DateTime.now(),
        location: Location(
          latitude: 0.0, // Default values - can be enhanced with GPS
          longitude: 0.0,
          address: _addressController.text.trim(),
        ),
        status: DonationStatus.available,
        dietaryInfo: DietaryInfo(), // Default dietary info
        pickupInstructions: _descriptionController.text.trim(),
        contactNumber: _contactController.text.trim(),
        priority: PriorityLevel.medium,
        tags: [],
        images: [],
      );

      await FirebaseService.saveDonation(donation);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Donation posted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate back to IndividualMainScreen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const IndividualMainScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error posting donation: $e'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Create Donation'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.volunteer_activism,
                      size: 48,
                      color: Color(0xFF6C63FF),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Share Your Food',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Help others by donating your excess food',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Form Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Food Type
                    _buildFormField(
                      controller: _foodTypeController,
                      label: 'Food Type',
                      icon: Icons.restaurant,
                      hint: 'e.g., Rice, Curry, Bread',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter food type';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Quantity
                    _buildFormField(
                      controller: _quantityController,
                      label: 'Quantity',
                      icon: Icons.scale,
                      hint: 'e.g., 5 plates, 2 kg',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter quantity';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Contact Number
                    _buildFormField(
                      controller: _contactController,
                      label: 'Contact Number',
                      icon: Icons.phone,
                      hint: 'Your phone number',
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter contact number';
                        }
                        if (value.trim().length < 10) {
                          return 'Please enter a valid contact number';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Address
                    _buildFormField(
                      controller: _addressController,
                      label: 'Pickup Address',
                      icon: Icons.location_on,
                      hint: 'Where can NGOs collect the food?',
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter pickup address';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Expiry Time
                    _buildDateTimeField(),

                    const SizedBox(height: 20),

                    // Description
                    _buildFormField(
                      controller: _descriptionController,
                      label: 'Additional Notes (Optional)',
                      icon: Icons.note,
                      hint: 'Any special instructions or details',
                      maxLines: 3,
                    ),

                    const SizedBox(height: 20),

                    // Image Selection
                    _buildImageSelector(),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Submit Button
              Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF5A52E0)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C63FF).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createDonation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Posting...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      : const Text(
                          'Post Donation',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFF6C63FF)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Until',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectExpiryTime,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[50],
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule, color: Color(0xFF6C63FF)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${_selectedExpiryTime.day}/${_selectedExpiryTime.month}/${_selectedExpiryTime.year} at ${_selectedExpiryTime.hour.toString().padLeft(2, '0')}:${_selectedExpiryTime.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Food Image (Optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickImage,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[50],
            ),
            child: _selectedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _selectedImage!,
                      width: double.infinity,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo,
                          size: 32,
                          color: Color(0xFF6C63FF),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap to add food image',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}