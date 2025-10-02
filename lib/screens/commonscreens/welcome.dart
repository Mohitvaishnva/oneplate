import 'package:flutter/material.dart';
import '../ngoscreens/registerngo.dart';
import '../hotelscreens/hotelregister.dart';
import '../individualscreens/individualregister.dart';
import 'login.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              
              // Logo Section
              Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.restaurant_menu,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  const Text(
                    'OnePlate',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  const Text(
                    'Connecting Hearts, Sharing Meals',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF9A9A9A),
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              
              const Spacer(),
              
              // Buttons Section
              Column(
                children: [
                  // NGO Button
                  _buildUserTypeButton(
                    context: context,
                    text: 'Continue as NGO',
                    icon: Icons.volunteer_activism,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterNGOScreen(),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Hotel Button
                  _buildUserTypeButton(
                    context: context,
                    text: 'Continue as Hotel',
                    icon: Icons.hotel,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HotelRegisterScreen(),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Individual Button
                  _buildUserTypeButton(
                    context: context,
                    text: 'Continue as Individual',
                    icon: Icons.person,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const IndividualRegisterScreen(),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Login Button
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF6C63FF),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 24,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.login,
                                color: Color(0xFF6C63FF),
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Already have an account? Login',
                                style: TextStyle(
                                  color: Color(0xFF6C63FF),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserTypeButton({
    required BuildContext context,
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6C63FF),
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}