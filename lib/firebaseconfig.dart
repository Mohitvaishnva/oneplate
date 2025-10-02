import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Global Firebase Database Reference
final DatabaseReference dbRef = FirebaseDatabase.instance.ref();

// Global Firebase Auth Reference
final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

// Helper function to get current user ID
String? getCurrentUserId() {
  return firebaseAuth.currentUser?.uid;
}

// Helper function to check if user is authenticated
bool isUserAuthenticated() {
  return firebaseAuth.currentUser != null;
}

// Database path constants
class DatabasePaths {
  static const String users = 'users';
  static const String ngos = 'ngos';
  static const String hotels = 'hotels';
  static const String individuals = 'individuals';
  static const String donationRequests = 'donation_requests';
  static const String donations = 'donations';
}