import 'package:firebase_auth/firebase_auth.dart';

class AuthResult {
  final bool success;
  final User? user;
  final String? error;

  AuthResult({
    required this.success,
    this.user,
    this.error,
  });

  @override
  String toString() {
    if (success) {
      return 'AuthResult(success: true, user: ${user?.email})';
    } else {
      return 'AuthResult(success: false, error: $error)';
    }
  }
}