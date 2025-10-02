import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class DonationCard extends StatefulWidget {
  final String donorName;
  final String foodType;
  final String quantity;
  final String location;
  final String? donorImage;
  final String time;
  final String? expiryTime;
  final String? description;
  final VoidCallback onTap;
  final int index;

  const DonationCard({
    super.key,
    required this.donorName,
    required this.foodType,
    required this.quantity,
    required this.location,
    this.donorImage,
    required this.time,
    this.expiryTime,
    this.description,
    required this.onTap,
    this.index = 0,
  });

  @override
  State<DonationCard> createState() => _DonationCardState();
}

class _DonationCardState extends State<DonationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    _elevationAnimation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppBorderRadius.medium,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08 + (_elevationAnimation.value * 0.04)),
                  blurRadius: 10 + _elevationAnimation.value,
                  offset: Offset(0, 4 + (_elevationAnimation.value / 2)),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: AppBorderRadius.medium,
                onTap: widget.onTap,
                onTapDown: (_) => _controller.forward(),
                onTapUp: (_) => _controller.reverse(),
                onTapCancel: () => _controller.reverse(),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      // Donor Image
                      Hero(
                        tag: 'donor_${widget.donorName}_${widget.index}',
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: AppGradients.primary,
                            shape: BoxShape.circle,
                            boxShadow: AppShadows.soft,
                          ),
                          child: widget.donorImage != null
                              ? ClipOval(
                                  child: Image.network(
                                    widget.donorImage!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return _buildDefaultAvatar();
                                    },
                                  ),
                                )
                              : _buildDefaultAvatar(),
                        ),
                      ),
                      
                      const SizedBox(width: AppSpacing.md),
                      
                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Donor Name
                            Text(
                              widget.donorName,
                              style: AppTextStyles.heading3,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            
                            const SizedBox(height: AppSpacing.xs),
                            
                            // Food Type and Quantity
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: AppGradients.primary,
                                    borderRadius: AppBorderRadius.small,
                                  ),
                                  child: Text(
                                    widget.foodType,
                                    style: AppTextStyles.caption.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Text(
                                    widget.quantity,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: AppSpacing.xs),
                            
                            // Location and Time
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: AppColors.darkGrey,
                                ),
                                const SizedBox(width: 2),
                                Expanded(
                                  child: Text(
                                    widget.location,
                                    style: AppTextStyles.bodySmall,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Icon(
                                  Icons.schedule,
                                  size: 14,
                                  color: AppColors.darkGrey,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  widget.time,
                                  style: AppTextStyles.bodySmall,
                                ),
                              ],
                            ),
                            
                            if (widget.expiryTime != null) ...[
                              const SizedBox(height: AppSpacing.xs),
                              Row(
                                children: [
                                  Icon(
                                    Icons.timer,
                                    size: 14,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    'Expires: ${widget.expiryTime}',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            
                            if (widget.description != null && widget.description!.isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                widget.description!,
                                style: AppTextStyles.bodySmall.copyWith(
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      
                      // Arrow Icon
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          gradient: AppGradients.subtle,
                          borderRadius: AppBorderRadius.small,
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: AppColors.darkGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppGradients.primary,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          widget.donorName.isNotEmpty ? widget.donorName[0].toUpperCase() : 'D',
          style: AppTextStyles.heading3.copyWith(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
      ),
    );
  }
}

// NGO Request Card for Hotels/Individuals
class NGORequestCard extends StatefulWidget {
  final String ngoName;
  final String foodNeeded;
  final String foodType;
  final String location;
  final String? ngoImage;
  final String time;
  final VoidCallback onTap;
  final int index;

  const NGORequestCard({
    super.key,
    required this.ngoName,
    required this.foodNeeded,
    required this.foodType,
    required this.location,
    this.ngoImage,
    required this.time,
    required this.onTap,
    this.index = 0,
  });

  @override
  State<NGORequestCard> createState() => _NGORequestCardState();
}

class _NGORequestCardState extends State<NGORequestCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppBorderRadius.medium,
              boxShadow: AppShadows.soft,
              border: Border.all(
                color: AppColors.primaryPurple.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: AppBorderRadius.medium,
                onTap: widget.onTap,
                onTapDown: (_) => _controller.forward(),
                onTapUp: (_) => _controller.reverse(),
                onTapCancel: () => _controller.reverse(),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        children: [
                          // NGO Avatar
                          Hero(
                            tag: 'ngo_${widget.ngoName}_${widget.index}',
                            child: Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                gradient: AppGradients.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  widget.ngoName.isNotEmpty 
                                      ? widget.ngoName[0].toUpperCase() 
                                      : 'N',
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: AppSpacing.md),
                          
                          // NGO Name and Time
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.ngoName,
                                  style: AppTextStyles.heading3.copyWith(fontSize: 16),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  widget.time,
                                  style: AppTextStyles.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          
                          // Food Type Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: AppGradients.primary,
                              borderRadius: AppBorderRadius.small,
                            ),
                            child: Text(
                              widget.foodType,
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: AppSpacing.md),
                      
                      // Food Needed
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          gradient: AppGradients.subtle,
                          borderRadius: AppBorderRadius.small,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Food Needed',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkGrey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.foodNeeded,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: AppSpacing.sm),
                      
                      // Location
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: AppColors.darkGrey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.location,
                              style: AppTextStyles.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          
                          // View Details Button
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              gradient: AppGradients.primary,
                              borderRadius: AppBorderRadius.small,
                            ),
                            child: Text(
                              'View Details',
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}