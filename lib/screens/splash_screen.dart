import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'commonscreens/login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Set status bar to transparent
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    
    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Create simple scale animation for popup effect
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    // Create fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    // Start animation
    _animationController.forward();
    
    // Navigate to login screen after 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Welcome text at top
                    const Text(
                      'Welcome to',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w300,
                        color: Color(0xFFBEAE9A),
                        letterSpacing: 1,
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Logo - reduced size to crop out unwanted bottom elements
                    Container(
                      width: 200,
                      height: 200,
                      child: ClipOval(
                        child: Image.asset(
                          'lib/images/splash.png',
                          fit: BoxFit.cover,
                          alignment: Alignment(0.0, -0.5), // Crop more from bottom to remove unwanted elements
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback to show the design from your image
                            return Container(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Plate circle
                                  Container(
                                    width: 220,
                                    height: 220,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFFBEAE9A),
                                      border: Border.all(
                                        color: const Color(0xFF8B4513),
                                        width: 6,
                                      ),
                                    ),
                                  ),
                                  // Fork and knife crossed
                                  Transform.rotate(
                                    angle: 0.785398, // 45 degrees
                                    child: const Icon(
                                      Icons.restaurant,
                                      size: 100,
                                      color: Color(0xFF8B4513),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 60),
                    
                    // Tagline - now more prominent without competing with "One Plate"
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        'Don\'t dump it, one plate it feed a smile, not the trash',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFBEAE9A),
                          letterSpacing: 1,
                          height: 1.5,
                        ),
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
}