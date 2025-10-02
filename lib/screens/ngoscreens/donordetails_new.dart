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
              donorName: widget.donation['donorName'] ?? 'Unknown Donor',
              donorPhone: widget.donation['donorPhone'] ?? 'No phone provided',
              donorType: widget.donation['donorType'] ?? 'Unknown',
              donationDetails: {
                'foodType': widget.donation['foodType'] ?? '',
                'quantity': widget.donation['quantity']?.toString() ?? '0',
                'notes': widget.donation['notes'] ?? '',
                'donationDate': widget.donation['donationDate'] ?? '',
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
                      icon: const Icon(Icons.arrow_back, color: Colors.black87),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF8B5CF6),
                            Color(0xFF7C3AED),
                          ],
                        ),
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
                              color: Colors.black87,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            'Review donor information',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
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
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                                ),
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
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildInfoRow('Donor Type', widget.donation['donorType'] ?? 'Unknown'),
                        _buildInfoRow('Food Type', widget.donation['foodType'] ?? 'Unknown'),
                        _buildInfoRow('Quantity', '${widget.donation['quantity'] ?? 0} people'),
                        _buildInfoRow('Status', widget.donation['status'] ?? 'pending'),
                        if (widget.donation['notes'] != null && widget.donation['notes'].isNotEmpty)
                          _buildInfoRow('Notes', widget.donation['notes']),
                        _buildInfoRow('Donation Date', widget.donation['donationDate'] ?? 'Unknown'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Action Buttons
                if (widget.donation['status'] == 'pending')
                  Column(
                    children: [
                      // Accept Button with Response
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: isLoading ? null : _acceptAndSendResponse,
                          icon: isLoading 
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.check_circle_outline),
                          label: Text(
                            isLoading ? 'Processing...' : 'Accept & Send Response',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7C3AED),
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Decline Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: isLoading ? null : _rejectDonation,
                          icon: const Icon(Icons.cancel_outlined),
                          label: const Text(
                            'Decline',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey.shade600,
                            side: BorderSide(color: Colors.grey.shade400),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                
                if (widget.donation['status'] == 'accepted')
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _completeDonation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C3AED),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
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
                          : const Text(
                              'Mark as Completed',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black54,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}