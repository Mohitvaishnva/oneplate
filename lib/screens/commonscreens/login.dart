import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import '../../utils/database_enums.dart';
import '../ngoscreens/ngomain.dart';
import '../hotelscreens/hotelmain.dart';
import '../individualscreens/individualmain.dart';
import 'welcome.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      var result = await FirebaseService.signInWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      setState(() {
        _isLoading = false;
      });

      if (result.success && result.user != null) {
        // Check user type and navigate accordingly
        await _navigateBasedOnUserType(result.user!.uid);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Login failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _navigateBasedOnUserType(String userId) async {
    try {
      // Get user data first to determine type
      var user = await FirebaseService.getUser(userId);
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User data not found. Please register first.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      print('User type: ${user.userType}');

      // Navigate based on user type
      switch (user.userType) {
        case UserType.ngo:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const NGOMainScreen()),
          );
          break;
        case UserType.hotel:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HotelMainScreen()),
          );
          break;
        case UserType.individual:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const IndividualMainScreen()),
          );
          break;
        default:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unknown user type. Please contact support.'),
              backgroundColor: Colors.red,
            ),
          );
      }
    } catch (e) {
      print('Navigation error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error determining user type: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _forgotPassword() async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email address first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    bool success = await FirebaseService.sendPasswordResetEmail(_emailController.text.trim());
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent! Check your inbox.'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send password reset email. Please check your email address.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                
                // Logo and Title
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.restaurant,
                          size: 50,
                          color: Color(0xFF6C63FF),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      const Text(
                        'Welcome Back',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3142),
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      const Text(
                        'Sign in to continue helping the community',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF9A9A9A),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 48),
                
                // Form Section
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          hintText: 'Enter your email',
                          prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF6C63FF)),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter your password',
                          prefixIcon: const Icon(Icons.lock_outlined, color: Color(0xFF6C63FF)),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: Colors.grey,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _forgotPassword,
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Color(0xFF6C63FF),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Login Button
                      SizedBox(
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C63FF),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            disabledBackgroundColor: const Color(0xFF6C63FF).withOpacity(0.6),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Don't have account
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account? ",
                            style: TextStyle(
                              color: Color(0xFF9A9A9A),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                            ),
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Color(0xFF6C63FF),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
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
}