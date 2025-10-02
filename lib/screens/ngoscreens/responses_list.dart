import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import '../../models/donation_models.dart';
import '../../utils/database_enums.dart';

class NGOResponsesListScreen extends StatefulWidget {
  const NGOResponsesListScreen({super.key});

  @override
  State<NGOResponsesListScreen> createState() => _NGOResponsesListScreenState();
}

class _NGOResponsesListScreenState extends State<NGOResponsesListScreen> {
  List<Donation> donations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDonations();
  }

  Future<void> _loadDonations() async {
    try {
      final allDonations = await FirebaseService.getAllDonations();
      // Filter donations that are responses to this NGO's requests
      // For now, showing all donations - you may want to filter by NGO ID
      setState(() {
        donations = allDonations;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading donations: $e'),
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
        title: const Text('Donation Responses'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : donations.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey),
                      SizedBox(height: 20),
                      Text(
                        'No responses yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Donors who accept your requests will appear here',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadDonations,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: donations.length,
                    itemBuilder: (context, index) {
                      final donation = donations[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.green.shade100,
                                    child: Icon(
                                      donation.donorType.name == 'hotel' 
                                          ? Icons.hotel 
                                          : Icons.person,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          donation.donorName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          donation.donorType.toString().split('.').last.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(donation.status),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      donation.status.toString().split('.').last.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow('Food Type:', donation.foodType),
                              _buildInfoRow('Quantity:', donation.quantity),
                              if (donation.description.isNotEmpty)
                                _buildInfoRow('Notes:', donation.description),
                              _buildInfoRow('Contact:', donation.contactNumber),
                              const SizedBox(height: 8),
                              Text(
                                'Created: ${_formatDate(donation.createdAt)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(DonationStatus status) {
    switch (status) {
      case DonationStatus.available:
        return Colors.green;
      case DonationStatus.reserved:
        return Colors.orange;
      case DonationStatus.completed:
        return Colors.blue;
      case DonationStatus.expired:
        return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}