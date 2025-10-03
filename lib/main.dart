import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/firebase_config.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Use platform-specific Firebase configuration
  FirebaseOptions firebaseOptions;
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    firebaseOptions = FirebaseConfig.ios;
  } else if (defaultTargetPlatform == TargetPlatform.android) {
    firebaseOptions = FirebaseConfig.android;
  } else {
    firebaseOptions = FirebaseConfig.web;
  }
  
  await Firebase.initializeApp(options: firebaseOptions);
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
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
      // Additional debug settings to ensure no overlays
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
    );
  }
}


