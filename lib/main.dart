import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/firebase_config.dart';
import 'screens/commonscreens/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseConfig.android, // Use appropriate config based on platform
  );
  runApp(const OnePlateApp());
}

class OnePlateApp extends StatelessWidget {
  const OnePlateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OnePlate - Food Donation App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}


