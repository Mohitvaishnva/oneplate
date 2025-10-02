import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/firebase_service.dart';
import '../../models/donation_models.dart' as models;
import '../../utils/database_enums.dart';
import '../../utils/app_theme.dart';

class CreateDonateScreen extends StatefulWidget {
  const CreateDonateScreen({super.key});

  @override
  State<CreateDonateScreen> createState() => _CreateDonateScreenState();
}

class _CreateDonateScreenState extends State<CreateDonateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  
  String _selectedFoodType = 'Cooked Food';
  DateTime? _madeTime;
  DateTime? _expiryTime;
  bool _isSubmitting = false;
  
  final List<String> _foodTypes = [
    'Cooked Food',
    'Raw Ingredients', 
    'Packaged Food',
    'Beverages',
    'Bakery Items',
    'Fruits & Vegetables',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context, bool isMadeTime) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: isMadeTime ? DateTime.now().subtract(const Duration(hours: 24)) : DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 7)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryPurple,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.darkGrey,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: AppColors.primaryPurple,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: AppColors.darkGrey,
              ),
            ),
            child: child!,
          );
        },
      );

      if (time != null) {
        final DateTime selectedDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          time.hour,
          time.minute,
        );

        setState(() {
          if (isMadeTime) {
            _madeTime = selectedDateTime;
          } else {
            _expiryTime = selectedDateTime;
          }
        });
      }
    }
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Select date & time';
    
    final now = DateTime.now();
    final difference = dateTime.difference(now);
    
    if (difference.inDays == 0) {
      return 'Today at ${TimeOfDay.fromDateTime(dateTime).format(context)}';
    } else if (difference.inDays == 1) {
      return 'Tomorrow at ${TimeOfDay.fromDateTime(dateTime).format(context)}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${TimeOfDay.fromDateTime(dateTime).format(context)}';
    }
  }

  Future<void> _submitDonation() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_madeTime == null) {
      _showErrorSnackBar('Please select when the food was made');
      return;
    }
    
    if (_expiryTime == null) {
      _showErrorSnackBar('Please select the expiry time');
      return;
    }
    
    if (_expiryTime!.isBefore(_madeTime!)) {
      _showErrorSnackBar('Expiry time cannot be before the made time');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final userId = FirebaseService.currentUserId;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Get hotel details from Firebase service
      final hotel = await FirebaseService.getHotel(userId);
      if (hotel == null) {
        throw Exception('Hotel profile not found');
      }

      // Create donation using new model
      final donation = models.Donation(
        id: '', // Will be set by Firebase service
        donorId: userId,
        donorType: UserType.hotel,
        donorName: hotel.name,
        title: _selectedFoodType,
        description: _descriptionController.text.trim(),
        foodType: _selectedFoodType,
        quantity: _quantityController.text.trim(),
        expiryTime: _expiryTime!,
        createdAt: DateTime.now(),
        location: models.Location(
          latitude: 0.0, // TODO: Get actual coordinates
          longitude: 0.0,
          address: _locationController.text.trim().isNotEmpty 
              ? _locationController.text.trim() 
              : hotel.name,
        ),
        status: DonationStatus.available,
        dietaryInfo: models.DietaryInfo(
          vegetarian: _selectedFoodType.toLowerCase().contains('veg'),
        ),
        contactNumber: FirebaseService.currentUser?.phoneNumber ?? '',
      );

      // Save to Firebase using service
      await FirebaseService.saveDonation(donation);
      
      // Show success dialog
      _showSuccessDialog();
      
    } catch (e) {
      _showErrorSnackBar('Failed to create donation: ${e.toString()}');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.medium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFF6C63FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Donation Created!',
              style: AppTextStyles.heading3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Your food donation has been successfully created and is now available for NGOs to request.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.darkGrey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _resetForm();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppBorderRadius.medium,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
                child: Text(
                  'Create Another',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.small),
      ),
    );
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _quantityController.clear();
    _descriptionController.clear();
    _locationController.clear();
    setState(() {
      _selectedFoodType = 'Cooked Food';
      _madeTime = null;
      _expiryTime = null;
    });
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
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: const BoxDecoration(
                color: Color(0xFF6C63FF),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: AppBorderRadius.medium,
                    ),
                    child: const Icon(
                      Icons.restaurant_menu,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create Donation',
                          style: AppTextStyles.heading2.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Share your food with the community',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Form Content
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F5),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                              // Food Type Selection
                              _buildSectionTitle('Food Type'),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: AppBorderRadius.medium,
                                  boxShadow: AppShadows.soft,
                                ),
                                child: DropdownButtonFormField<String>(
                                  value: _selectedFoodType,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    prefixIcon: Icon(Icons.fastfood_outlined, color: AppColors.primaryPurple),
                                  ),
                                  items: _foodTypes.map((type) {
                                    return DropdownMenuItem(
                                      value: type,
                                      child: Text(type, style: AppTextStyles.bodyMedium),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedFoodType = value!;
                                    });
                                  },
                                ),
                              ),

                              const SizedBox(height: AppSpacing.lg),

                              // Quantity
                              _buildSectionTitle('Quantity'),
                              _buildTextField(
                                controller: _quantityController,
                                hint: 'Enter number of people this can serve',
                                icon: Icons.people_outline,
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the quantity';
                                  }
                                  final quantity = int.tryParse(value);
                                  if (quantity == null || quantity <= 0) {
                                    return 'Please enter a valid positive number';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: AppSpacing.lg),

                              // Description
                              _buildSectionTitle('Description'),
                              _buildTextField(
                                controller: _descriptionController,
                                hint: 'Describe the food (optional)',
                                icon: Icons.description_outlined,
                                maxLines: 3,
                              ),

                              const SizedBox(height: AppSpacing.lg),

                              // Pickup Location
                              _buildSectionTitle('Pickup Location'),
                              _buildTextField(
                                controller: _locationController,
                                hint: 'Enter pickup location (optional - defaults to hotel address)',
                                icon: Icons.location_on_outlined,
                                maxLines: 2,
                              ),

                              const SizedBox(height: AppSpacing.lg),

                              // Made Time
                              _buildSectionTitle('When was the food made?'),
                              _buildDateTimeSelector(
                                label: _formatDateTime(_madeTime),
                                icon: Icons.schedule_outlined,
                                onTap: () => _selectDateTime(context, true),
                              ),

                              const SizedBox(height: AppSpacing.lg),

                              // Expiry Time
                              _buildSectionTitle('When does it expire?'),
                              _buildDateTimeSelector(
                                label: _formatDateTime(_expiryTime),
                                icon: Icons.timer_outlined,
                                onTap: () => _selectDateTime(context, false),
                                isExpiry: true,
                              ),

                              const SizedBox(height: AppSpacing.xl),

                              // Submit Button
                              Container(
                                height: 55,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6C63FF),
                                  borderRadius: AppBorderRadius.medium,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF6C63FF).withOpacity(0.3),
                                      spreadRadius: 1,
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: AppBorderRadius.medium,
                                    onTap: _isSubmitting ? null : _submitDonation,
                                    child: Center(
                                      child: _isSubmitting
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              ),
                                            )
                                          : Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.volunteer_activism,
                                                  color: Colors.white,
                                                  size: 24,
                                                ),
                                                const SizedBox(width: AppSpacing.sm),
                                                Text(
                                                  'Create Donation',
                                                  style: AppTextStyles.bodyLarge.copyWith(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: AppSpacing.lg),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        title,
        style: AppTextStyles.heading3.copyWith(
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppBorderRadius.medium,
        boxShadow: AppShadows.soft,
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        maxLines: maxLines,
        style: AppTextStyles.bodyMedium,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.darkGrey,
          ),
          prefixIcon: Icon(icon, color: AppColors.primaryPurple),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(AppSpacing.md),
        ),
      ),
    );
  }

  Widget _buildDateTimeSelector({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool isExpiry = false,
  }) {
    final isSelected = label != 'Select date & time';
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppBorderRadius.medium,
        boxShadow: AppShadows.soft,
        border: isExpiry && isSelected && _expiryTime != null && _madeTime != null && _expiryTime!.isBefore(_madeTime!)
            ? Border.all(color: Colors.red, width: 1.5)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppBorderRadius.medium,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? AppColors.primaryPurple : AppColors.darkGrey,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isSelected ? AppColors.darkGrey : AppColors.darkGrey.withOpacity(0.6),
                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.darkGrey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}