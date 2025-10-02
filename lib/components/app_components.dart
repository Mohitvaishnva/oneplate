import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class GradientButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final double? width;
  final double? height;
  final IconData? icon;
  final bool isLoading;
  final bool isEnabled;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
    this.height,
    this.icon,
    this.isLoading = false,
    this.isEnabled = true,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.isEnabled && !widget.isLoading) {
      _animationController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.isEnabled && !widget.isLoading) {
      _animationController.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.isEnabled && !widget.isLoading) {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.isEnabled && !widget.isLoading ? widget.onPressed : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.width ?? double.infinity,
              height: widget.height ?? 56,
              decoration: BoxDecoration(
                gradient: widget.isEnabled 
                    ? AppGradients.primary 
                    : LinearGradient(
                        colors: [Colors.grey.shade400, Colors.grey.shade500],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: AppBorderRadius.medium,
                boxShadow: widget.isEnabled ? AppShadows.medium : [],
              ),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  alignment: Alignment.center,
                  child: widget.isLoading
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
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.icon != null) ...[
                              Icon(
                                widget.icon,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                            ],
                            Text(
                              widget.text,
                              style: AppTextStyles.buttonText,
                            ),
                          ],
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Custom App Bar with Gradient
class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;

  const GradientAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppGradients.primary,
      ),
      child: AppBar(
        title: Text(title, style: AppTextStyles.heading3.copyWith(color: Colors.white)),
        centerTitle: centerTitle,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: leading,
        actions: actions,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// Beautiful Card Component
class AppCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.margin,
    this.padding,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _elevationAnimation = Tween<double>(
      begin: 0,
      end: 8,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _elevationAnimation,
      builder: (context, child) {
        return Container(
          margin: widget.margin ?? const EdgeInsets.symmetric(
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
              onHover: (isHovering) {
                if (isHovering) {
                  _animationController.forward();
                } else {
                  _animationController.reverse();
                }
              },
              child: Padding(
                padding: widget.padding ?? const EdgeInsets.all(AppSpacing.md),
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }
}

// Custom Search Bar
class AppSearchBar extends StatefulWidget {
  final String hintText;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final TextEditingController? controller;

  const AppSearchBar({
    super.key,
    this.hintText = 'Search...',
    this.onChanged,
    this.onSubmitted,
    this.controller,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.dispose();
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
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppBorderRadius.large,
              boxShadow: AppShadows.soft,
            ),
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              decoration: InputDecoration(
                hintText: widget.hintText,
                prefixIcon: const Icon(Icons.search, color: AppColors.darkGrey),
                border: OutlineInputBorder(
                  borderRadius: AppBorderRadius.large,
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}