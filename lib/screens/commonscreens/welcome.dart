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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/images/welcome.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Column(
              children: [
                const SizedBox(height: 30),
                
                // Welcome to text
                const Text(
                  'Welcome to',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF8B4513),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                
                const SizedBox(height: 15),
                
                // Logo only - larger size
                Center(
                  child: Container(
                    width: 150,
                    height: 150,
                    child: Image.asset(
                      'lib/images/onelogo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF4CAF50),
                              width: 4,
                            ),
                          ),
                          child: const Icon(
                            Icons.restaurant,
                            color: Color(0xFFFF9800),
                            size: 80,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Select Your Service text
                const Text(
                  'Select Your Service',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF8B4513),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                
                const SizedBox(height: 25),                // Three service options with normal images
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // NGO Option
                      Flexible(
                        flex: 1,
                        child: _buildServiceOption(
                          context: context,
                          imagePath: 'lib/images/log1.png',
                          title: 'NGO',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterNGOScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      const SizedBox(width: 15),
                      
                      // Hotels/Restro Option
                      Flexible(
                        flex: 1,
                        child: _buildServiceOption(
                          context: context,
                          imagePath: 'lib/images/log3.png',
                          title: 'Hotels/Restro',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HotelRegisterScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      const SizedBox(width: 15),
                      
                      // Individual Option
                      Flexible(
                        flex: 1,
                        child: _buildServiceOption(
                          context: context,
                          imagePath: 'lib/images/log2.png',
                          title: 'Individual',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const IndividualRegisterScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Already have account login button
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.login,
                              color: Color(0xFF6C63FF),
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Already have an account? Login',
                                style: TextStyle(
                                  color: Color(0xFF6C63FF),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceOption({
    required BuildContext context,
    required String imagePath,
    required String title,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image with slight shadow
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: AspectRatio(
                aspectRatio: 1.0,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.image,
                        color: Colors.grey,
                        size: 40,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Title below image
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3142),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}