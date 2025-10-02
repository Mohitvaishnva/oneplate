import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import '../../models/donation_models.dart' as models;
import '../../utils/database_enums.dart';
import '../ngoscreens/response.dart';

class IndividualDonateScreen extends StatefulWidget {
  final Map<String, dynamic> request;
  
  const IndividualDonateScreen({super.key, required this.request});

  @override
  State<IndividualDonateScreen> createState() => _IndividualDonateScreenState();
}

class _IndividualDonateScreenState extends State<IndividualDonateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _selectedFoodType = 'Cooked Food';
  bool _isSubmitting = false;
  
  String _safeStringConversion(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is Map) return ''; // Return empty string for Map values
    return value.toString();
  }
  
  final List<String> _foodTypes = [
    'Cooked Food',
    'Raw Ingredients',
    'Packaged Food',
    'Beverages',
    'Other'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Make Donation'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // NGO Info Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Donating to: ${_safeStringConversion(widget.request['ngoName']).isNotEmpty ? _safeStringConversion(widget.request['ngoName']) : 'Unknown NGO'}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'People to feed: ${_safeStringConversion(widget.request['peopleCount']).isNotEmpty ? _safeStringConversion(widget.request['peopleCount']) : 'Not specified'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Location: ${_safeStringConversion(widget.request['address']).isNotEmpty ? _safeStringConversion(widget.request['address']) : 'No address'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Donation Form
              const Text(
                'Donation Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Food Type Dropdown
              DropdownButtonFormField<String>(
                value: _selectedFoodType,
                decoration: const InputDecoration(
                  labelText: 'Food Type',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.food_bank),
                ),
                items: _foodTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedFoodType = newValue!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a food type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Quantity Field
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity (number of people you can feed)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.people),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter quantity';
                  }
                  final quantity = int.tryParse(value);
                  if (quantity == null || quantity <= 0) {
                    return 'Please enter a valid quantity';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Notes Field
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Additional Notes (optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitDonation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Confirm Donation',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitDonation() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isSubmitting = true;
    });

    try {
      final userId = FirebaseService.currentUserId;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Get donor information
      final user = await FirebaseService.getCurrentUser();
      if (user == null) {
        throw Exception('User data not found');
      }

      // Determine donor type
      UserType donorType = user.userType;
      String donorName = user.name;
      String donorPhone = user.phone;

      // Create donation using new model
      final donation = models.Donation(
        id: '', // Will be set by Firebase service
        donorId: userId,
        donorType: donorType,
        donorName: donorName,
        title: 'Response to ${_safeStringConversion(widget.request['ngoName']).isNotEmpty ? _safeStringConversion(widget.request['ngoName']) : 'NGO'} request',
        description: _notesController.text.trim(),
        foodType: _selectedFoodType,
        quantity: _quantityController.text.trim(),
        expiryTime: DateTime.now().add(const Duration(hours: 4)), // Default 4 hours
        createdAt: DateTime.now(),
        location: models.Location(
          latitude: 0.0, // TODO: Get actual coordinates
          longitude: 0.0,
          address: _safeStringConversion(widget.request['address']).isNotEmpty ? _safeStringConversion(widget.request['address']) : 'Unknown location',
        ),
        status: DonationStatus.available,
        dietaryInfo: models.DietaryInfo(),
        contactNumber: donorPhone,
      );

      // Save donation to Firebase
      await FirebaseService.saveDonation(donation);

      // TODO: Remove this request from active requests
      // This would require updating the request status or removing it
      // await FirebaseService.updateDonationRequest(widget.request['id'], {'status': 'fulfilled'});

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Donation submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate to response screen with donor details
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => NGOResponseScreen(
              donorName: donorName,
              donorPhone: donorPhone,
              donorType: donorType.value,
              donationDetails: {
                'foodType': _selectedFoodType,
                'quantity': _quantityController.text.trim(),
                'notes': _notesController.text.trim(),
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting donation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}