import 'package:flutter/material.dart';
import '../../firebaseconfig.dart';
import 'response.dart';

class DonorDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> donation;
  
  const DonorDetailsScreen({super.key, required this.donation});

  @override
  State<DonorDetailsScreen> createState() => _DonorDetailsScreenState();
}

class _DonorDetailsScreenState extends State<DonorDetailsScreen> {
  bool isLoading = false;

  String _safeStringConversion(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is Map) return ''; // Return empty string for Map values
    return value.toString();
  }

  String _getDonorName() {
    // Try different name fields
    final donorName = _safeStringConversion(widget.donation['donorName']);
    if (donorName.isNotEmpty && donorName != 'Anonymous Donor') {
      return donorName;
    }
    
    // Check for hotel/individual specific names
    final hotelName = _safeStringConversion(widget.donation['hotelName']);
    if (hotelName.isNotEmpty) return hotelName;
    
    final individualName = _safeStringConversion(widget.donation['individualName']);
    if (individualName.isNotEmpty) return individualName;
    
    return 'Anonymous Donor';
  }

  String _getDonorType() {
    final userType = _safeStringConversion(widget.donation['donorUserType']);
    if (userType.isNotEmpty && userType != 'unknown') {
      return userType.toUpperCase();
    }
    
    final type = _safeStringConversion(widget.donation['userType']);
    if (type.isNotEmpty) {
      return type.toUpperCase();
    }
    
    return 'UNKNOWN';
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Unknown date';
    try {
      final date = DateTime.fromMillisecondsSinceEpoch(
        timestamp is int ? timestamp : int.parse(timestamp.toString())
      );
      return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Unknown date';
    }
  }

  Future<void> _completeDonation() async {
    setState(() {
      isLoading = true;
    });

    try {
      await dbRef.child(DatabasePaths.donations)
          .child(widget.donation['id'])
          .update({'status': 'completed'});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Donation marked as completed!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error completing donation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _rejectDonation() async {
    setState(() {
      isLoading = true;
    });

    try {
      await dbRef.child(DatabasePaths.donations)
          .child(widget.donation['id'])
          .update({'status': 'rejected'});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Donation declined'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error declining donation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _acceptAndSendResponse() async {
    setState(() {
      isLoading = true;
    });

    try {
      // First accept the donation
      await dbRef.child(DatabasePaths.donations)
          .child(widget.donation['id'])
          .update({'status': 'accepted'});

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Donation accepted successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to response screen with donor details
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => NGOResponseScreen(
              donorName: _safeStringConversion(widget.donation['donorName']).isNotEmpty 
                  ? _safeStringConversion(widget.donation['donorName']) 
                  : 'Unknown Donor',
              donorPhone: _safeStringConversion(widget.donation['donorPhone']).isNotEmpty 
                  ? _safeStringConversion(widget.donation['donorPhone']) 
                  : 'No phone provided',
              donorType: _safeStringConversion(widget.donation['donorType']).isNotEmpty 
                  ? _safeStringConversion(widget.donation['donorType']) 
                  : 'Unknown',
              donationDetails: {
                'foodType': _safeStringConversion(widget.donation['foodType']),
                'quantity': _safeStringConversion(widget.donation['quantity']).isNotEmpty 
                    ? _safeStringConversion(widget.donation['quantity']) 
                    : '0',
                'notes': _safeStringConversion(widget.donation['notes']),
                'donationDate': _safeStringConversion(widget.donation['donationDate']),
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error accepting donation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
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
                        Icons.volunteer_activism,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Donation Details',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3142),
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            'Review donor information',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF9A9A9A),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Donor Information Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6C63FF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Donor Information',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2D3142),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildInfoRow('Donor Name', _getDonorName(), Icons.person),
                        _buildInfoRow('Donor Type', _getDonorType(), Icons.category),
                        if (_safeStringConversion(widget.donation['donorPhone']).isNotEmpty)
                          _buildInfoRow('Contact', _safeStringConversion(widget.donation['donorPhone']), Icons.phone),
                        if (_safeStringConversion(widget.donation['donorEmail']).isNotEmpty)
                          _buildInfoRow('Email', _safeStringConversion(widget.donation['donorEmail']), Icons.email),
                        if (_safeStringConversion(widget.donation['donorAddress']).isNotEmpty)
                          _buildInfoRow('Address', _safeStringConversion(widget.donation['donorAddress']), Icons.location_on),
                        const Divider(height: 32),
                        _buildInfoRow('Food Type', _safeStringConversion(widget.donation['foodType']).isNotEmpty ? _safeStringConversion(widget.donation['foodType']) : 'Unknown', Icons.restaurant_menu),
                        _buildInfoRow('Quantity', '${widget.donation['quantity'] ?? 'Not specified'} ${widget.donation['quantity'] != null ? 'servings' : ''}', Icons.fastfood),
                        if (_safeStringConversion(widget.donation['description']).isNotEmpty)
                          _buildInfoRow('Description', _safeStringConversion(widget.donation['description']), Icons.description),
                        _buildInfoRow('Status', _safeStringConversion(widget.donation['status']).isNotEmpty ? _safeStringConversion(widget.donation['status']).toUpperCase() : 'PENDING', Icons.info),
                        if (widget.donation['notes'] != null && _safeStringConversion(widget.donation['notes']).isNotEmpty)
                          _buildInfoRow('Notes', _safeStringConversion(widget.donation['notes']), Icons.note),
                        _buildInfoRow('Posted', _formatDate(widget.donation['timestamp']), Icons.access_time),
                        if (_safeStringConversion(widget.donation['location']).isNotEmpty)
                          _buildInfoRow('Pickup Location', _safeStringConversion(widget.donation['location']), Icons.place),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                  
                // Action Buttons
                if (widget.donation['status'] == 'pending' || widget.donation['status'] == 'available')
                  Column(
                    children: [
                      // Accept Button with Response
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _acceptAndSendResponse,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C63FF),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading 
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
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle_outline, size: 20),
                                    SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        'Accept Donation',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Decline Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton(
                          onPressed: isLoading ? null : _rejectDonation,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey.shade600,
                            side: BorderSide(color: Colors.grey.shade400),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.cancel_outlined, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Decline',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                if (widget.donation['status'] == 'accepted')
                  Column(
                    children: [
                      // Status indicator
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6C63FF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF6C63FF).withOpacity(0.3),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              color: Color(0xFF6C63FF),
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Accepted - Confirm pickup',
                                style: TextStyle(
                                  color: Color(0xFF6C63FF),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Confirm Order Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _completeDonation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C63FF),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading 
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
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.done_all, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'Confirm Order',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),

                if (widget.donation['status'] == 'completed')
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.green.withOpacity(0.5)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 24),
                        SizedBox(width: 12),
                        Text(
                          'Donation Completed',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: const Color(0xFF6C63FF),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF9A9A9A),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF2D3142),
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
}