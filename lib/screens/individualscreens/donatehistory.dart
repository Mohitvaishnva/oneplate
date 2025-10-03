import 'package:flutter/material.dart';
import '../../firebaseconfig.dart';

class IndividualDonateHistoryScreen extends StatefulWidget {
  const IndividualDonateHistoryScreen({super.key});

  @override
  State<IndividualDonateHistoryScreen> createState() => _IndividualDonateHistoryScreenState();
}

class _IndividualDonateHistoryScreenState extends State<IndividualDonateHistoryScreen>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> donationHistory = [];
  bool isLoading = true;
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadDonationHistory();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadDonationHistory() async {
    if (!mounted) return;
    
    setState(() {
      isLoading = true;
    });

    try {
      final userId = getCurrentUserId();
      if (userId != null && mounted) {
        final donationsSnapshot = await dbRef
            .child(DatabasePaths.donations)
            .orderByChild('donorId')
            .equalTo(userId)
            .get();

        if (donationsSnapshot.exists && mounted) {
          final donationsData = donationsSnapshot.value as Map<Object?, Object?>;
          List<Map<String, dynamic>> history = [];

          donationsData.forEach((key, value) {
            try {
              final donation = Map<String, dynamic>.from(value as Map<Object?, Object?>);
              donation['id'] = (key is String) ? key : key.toString();
              history.add(donation);
            } catch (e) {
              print('Error processing donation: $e');
            }
          });

          // Sort by creation time (newest first)
          history.sort((a, b) {
            final aTime = a['createdAt'] ?? a['timestamp'] ?? '';
            final bTime = b['createdAt'] ?? b['timestamp'] ?? '';
            return bTime.toString().compareTo(aTime.toString());
          });

          if (mounted) {
            setState(() {
              donationHistory = history;
            });
          }
        }
      }
    } catch (e) {
      print('Error loading donation history: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return 'Unknown date';
    
    try {
      DateTime date;
      if (dateValue is String) {
        if (dateValue.contains('T')) {
          date = DateTime.parse(dateValue);
        } else {
          // Handle timestamp as string
          final timestamp = int.tryParse(dateValue);
          if (timestamp != null) {
            date = DateTime.fromMillisecondsSinceEpoch(timestamp);
          } else {
            return 'Unknown date';
          }
        }
      } else if (dateValue is int) {
        date = DateTime.fromMillisecondsSinceEpoch(dateValue);
      } else {
        return 'Unknown date';
      }
      
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown date';
    }
  }

  String _formatTime(dynamic dateValue) {
    if (dateValue == null) return '';
    
    try {
      DateTime date;
      if (dateValue is String) {
        if (dateValue.contains('T')) {
          date = DateTime.parse(dateValue);
        } else {
          final timestamp = int.tryParse(dateValue);
          if (timestamp != null) {
            date = DateTime.fromMillisecondsSinceEpoch(timestamp);
          } else {
            return '';
          }
        }
      } else if (dateValue is int) {
        date = DateTime.fromMillisecondsSinceEpoch(dateValue);
      } else {
        return '';
      }
      
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }

  String _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'available':
        return '0xFF10B981'; // Green
      case 'accepted':
        return '0xFF6C63FF'; // Purple
      case 'completed':
        return '0xFF059669'; // Dark Green
      case 'cancelled':
        return '0xFFEF4444'; // Red
      default:
        return '0xFF6B7280'; // Grey
    }
  }

  String _getStatusText(String? status) {
    switch (status?.toLowerCase()) {
      case 'available':
        return 'Available';
      case 'accepted':
        return 'Accepted';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Donation History',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              // Header Stats
              Container(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C63FF).withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6C63FF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.volunteer_activism,
                          color: Color(0xFF6C63FF),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${donationHistory.length} Total Donations',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Your contribution history',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Donations List
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF6C63FF),
                        ),
                      )
                    : RefreshIndicator(
                        color: const Color(0xFF6C63FF),
                        onRefresh: _loadDonationHistory,
                        child: donationHistory.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.history,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No donations yet',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Start making a difference by creating your first donation',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[500],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                itemCount: donationHistory.length,
                                itemBuilder: (context, index) {
                                  final donation = donationHistory[index];
                                  return _buildDonationCard(donation, index);
                                },
                              ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDonationCard(Map<String, dynamic> donation, int index) {
    final status = donation['status'] ?? 'unknown';
    final statusColor = Color(int.parse(_getStatusColor(status)));
    
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          donation['title'] ?? donation['foodType'] ?? 'Food Donation',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _getStatusText(status),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Details
                  if (donation['description'] != null && donation['description'].toString().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        donation['description'].toString(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  
                  // Quantity and Date Row
                  Row(
                    children: [
                      if (donation['quantity'] != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Qty: ${donation['quantity']}',
                            style: const TextStyle(
                              color: Color(0xFF10B981),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      const Spacer(),
                      Text(
                        _formatDate(donation['createdAt'] ?? donation['timestamp']),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                      if (_formatTime(donation['createdAt'] ?? donation['timestamp']).isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(
                          _formatTime(donation['createdAt'] ?? donation['timestamp']),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}