import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/user_models.dart' as models;
import '../models/donation_models.dart';
import '../utils/database_paths.dart';
import '../utils/database_enums.dart';

class AuthResult {
  final bool success;
  final User? user;
  final String? error;

  AuthResult({required this.success, this.user, this.error});
}

class FirebaseService {
  static final DatabaseReference _database = FirebaseDatabase.instance.ref();
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Authentication Methods
  static User? get currentUser => _auth.currentUser;
  static String? get currentUserId => _auth.currentUser?.uid;

  static Future<bool> isAuthenticated() async {
    return _auth.currentUser != null;
  }

  static Future<AuthResult> signUpWithEmailPassword(String email, String password) async {
    try {
      if (!_isValidEmail(email)) {
        return AuthResult(success: false, error: 'Please enter a valid email address');
      }

      final passwordError = _validatePassword(password);
      if (passwordError != null) {
        return AuthResult(success: false, error: passwordError);
      }

      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return AuthResult(success: true, user: result.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, error: _getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult(success: false, error: 'An unexpected error occurred. Please try again.');
    }
  }

  static Future<AuthResult> signInWithEmailPassword(String email, String password) async {
    try {
      if (!_isValidEmail(email)) {
        return AuthResult(success: false, error: 'Please enter a valid email address');
      }

      if (password.isEmpty) {
        return AuthResult(success: false, error: 'Please enter your password');
      }

      // Add debug info
      print('Attempting Firebase auth for: $email');
      
      // Use signInWithEmailAndPassword directly without extra settings
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      print('Firebase auth successful for: $email');
      return AuthResult(success: true, user: result.user);
      
    } on FirebaseAuthException catch (e) {
      print('Firebase auth error: ${e.code} - ${e.message}');
      return AuthResult(success: false, error: _getAuthErrorMessage(e.code));
    } catch (e) {
      print('General auth error: $e');
      return AuthResult(success: false, error: 'Login failed. Please check your connection and try again.');
    }
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }

  static Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      return false;
    }
  }

  static String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed login attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'timeout':
        return 'Request timeout. Please try again.';
      case 'invalid-credential':
        return 'Invalid credentials. Please check your email and password.';
      default:
        return 'Authentication failed. Please check your connection and try again.';
    }
  }

  static bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static String? _validatePassword(String password) {
    if (password.isEmpty) {
      return 'Please enter a password';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  // User Management
  static Future<void> saveUser(models.User user) async {
    if (!await isAuthenticated()) throw Exception('User not authenticated');
    
    try {
      print('Saving user: ${user.toJson()}');
      await _database.child(DatabasePaths.userPath(user.uid)).set(user.toJson());
      print('User saved successfully');
    } catch (e) {
      print('Error saving user: $e');
      throw Exception('Failed to save user: $e');
    }
  }

  static Future<models.User?> getUser(String uid) async {
    if (!await isAuthenticated()) throw Exception('User not authenticated');
    
    try {
      final snapshot = await _database.child(DatabasePaths.userPath(uid)).get();
      if (snapshot.exists && snapshot.value != null) {
        // Debug print to see what we're getting
        print('Raw user data: ${snapshot.value}');
        print('Data type: ${snapshot.value.runtimeType}');
        
        // Ensure we have a Map
        if (snapshot.value is Map) {
          final userData = Map<String, dynamic>.from(snapshot.value as Map<Object?, Object?>);
          return models.User.fromJson(userData, uid);
        } else {
          print('Error: Expected Map but got ${snapshot.value.runtimeType}');
          return null;
        }
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      throw Exception('Failed to get user data: $e');
    }
  }

  static Future<models.User?> getCurrentUser() async {
    if (currentUserId == null) return null;
    return await getUser(currentUserId!);
  }

  // Hotel Management
  static Future<void> saveHotel(models.Hotel hotel) async {
    if (!await isAuthenticated()) throw Exception('User not authenticated');
    
    await _database.child(DatabasePaths.hotelPath(hotel.uid)).set(hotel.toJson());
  }

  static Future<models.Hotel?> getHotel(String uid) async {
    if (!await isAuthenticated()) throw Exception('User not authenticated');
    
    final snapshot = await _database.child(DatabasePaths.hotelPath(uid)).get();
    if (snapshot.exists) {
      return models.Hotel.fromJson(Map<String, dynamic>.from(snapshot.value as Map<Object?, Object?>), uid);
    }
    return null;
  }

  static Future<List<models.Hotel>> getAllHotels() async {
    if (!await isAuthenticated()) throw Exception('User not authenticated');
    
    final snapshot = await _database.child(DatabasePaths.hotels).get();
    if (!snapshot.exists) return [];
    
    final hotels = <models.Hotel>[];
    final data = Map<String, dynamic>.from(snapshot.value as Map<Object?, Object?>);
    
    for (final entry in data.entries) {
      hotels.add(models.Hotel.fromJson(Map<String, dynamic>.from(entry.value as Map<Object?, Object?>), entry.key));
    }
    
    return hotels;
  }

  // NGO Management
  static Future<void> saveNGO(models.NGO ngo) async {
    if (!await isAuthenticated()) throw Exception('User not authenticated');
    
    await _database.child(DatabasePaths.ngoPath(ngo.uid)).set(ngo.toJson());
  }

  static Future<models.NGO?> getNGO(String uid) async {
    if (!await isAuthenticated()) throw Exception('User not authenticated');
    
    final snapshot = await _database.child(DatabasePaths.ngoPath(uid)).get();
    if (snapshot.exists) {
      return models.NGO.fromJson(Map<String, dynamic>.from(snapshot.value as Map<Object?, Object?>), uid);
    }
    return null;
  }

  static Future<List<models.NGO>> getAllNGOs() async {
    if (!await isAuthenticated()) throw Exception('User not authenticated');
    
    final snapshot = await _database.child(DatabasePaths.ngos).get();
    if (!snapshot.exists) return [];
    
    final ngos = <models.NGO>[];
    final data = Map<String, dynamic>.from(snapshot.value as Map<Object?, Object?>);
    
    for (final entry in data.entries) {
      ngos.add(models.NGO.fromJson(Map<String, dynamic>.from(entry.value as Map<Object?, Object?>), entry.key));
    }
    
    return ngos;
  }

  // Individual Management
  static Future<void> saveIndividual(models.Individual individual) async {
    if (!await isAuthenticated()) throw Exception('User not authenticated');
    
    await _database.child(DatabasePaths.individualPath(individual.uid)).set(individual.toJson());
  }

  static Future<models.Individual?> getIndividual(String uid) async {
    if (!await isAuthenticated()) throw Exception('User not authenticated');
    
    final snapshot = await _database.child(DatabasePaths.individualPath(uid)).get();
    if (snapshot.exists) {
      return models.Individual.fromJson(Map<String, dynamic>.from(snapshot.value as Map<Object?, Object?>), uid);
    }
    return null;
  }

  // Donation Management
  static Future<String> saveDonation(Donation donation) async {
    if (!await isAuthenticated()) throw Exception('User not authenticated');
    
    final ref = _database.child(DatabasePaths.donations).push();
    await ref.set(donation.toJson());
    return ref.key!;
  }

  static Future<void> updateDonation(String donationId, Map<String, dynamic> updates) async {
    if (!await isAuthenticated()) throw Exception('User not authenticated');
    
    await _database.child(DatabasePaths.donationPath(donationId)).update(updates);
  }

  static Future<Donation?> getDonation(String donationId) async {
    if (!await isAuthenticated()) throw Exception('User not authenticated');
    
    final snapshot = await _database.child(DatabasePaths.donationPath(donationId)).get();
    if (snapshot.exists) {
      return Donation.fromJson(Map<String, dynamic>.from(snapshot.value as Map), donationId);
    }
    return null;
  }

  static Future<List<Donation>> getAllDonations() async {
    if (!await isAuthenticated()) throw Exception('User not authenticated');
    
    final snapshot = await _database.child(DatabasePaths.donations).get();
    if (!snapshot.exists) return [];
    
    final donations = <Donation>[];
    
    // Handle the snapshot data more safely
    final data = snapshot.value;
    if (data == null) return [];
    
    // Convert to Map safely
    Map<String, dynamic> donationsMap;
    if (data is Map<Object?, Object?>) {
      donationsMap = Map<String, dynamic>.from(data);
    } else {
      return [];
    }
    
    for (final entry in donationsMap.entries) {
      try {
        // Safely convert each donation entry
        Map<String, dynamic> donationData;
        if (entry.value is Map<Object?, Object?>) {
          donationData = Map<String, dynamic>.from(entry.value as Map<Object?, Object?>);
        } else {
          continue; // Skip this entry if it's not a map
        }
        
        donations.add(Donation.fromJson(donationData, entry.key));
      } catch (e) {
        print('Error parsing donation ${entry.key}: $e');
        // Skip this donation and continue with others
        continue;
      }
    }
    
    // Sort by creation time (newest first)
    donations.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return donations;
  }

  static Future<List<Donation>> getAvailableDonations() async {
    if (!await isAuthenticated()) throw Exception('User not authenticated');
    
    final now = DateTime.now();
    final snapshot = await _database
        .child(DatabasePaths.donations)
        .orderByChild('status')
        .equalTo('available')
        .get();
    
    if (!snapshot.exists) return [];
    
    final donations = <Donation>[];
    
    // Handle the snapshot data more safely
    final data = snapshot.value;
    if (data == null) return [];
    
    // Convert to Map safely
    Map<String, dynamic> donationsMap;
    if (data is Map<Object?, Object?>) {
      donationsMap = Map<String, dynamic>.from(data);
    } else {
      return [];
    }
    
    for (final entry in donationsMap.entries) {
      try {
        // Safely convert each donation entry
        Map<String, dynamic> donationData;
        if (entry.value is Map<Object?, Object?>) {
          donationData = Map<String, dynamic>.from(entry.value as Map<Object?, Object?>);
        } else {
          continue; // Skip this entry if it's not a map
        }
        
        final donation = Donation.fromJson(donationData, entry.key);
        // Filter out expired donations
        if (donation.expiryTime.isAfter(now)) {
          donations.add(donation);
        }
      } catch (e) {
        print('Error parsing available donation ${entry.key}: $e');
        // Skip this donation and continue with others
        continue;
      }
    }
    
    // Sort by expiry time (soonest first)
    donations.sort((a, b) => a.expiryTime.compareTo(b.expiryTime));
    return donations;
  }

  static Future<List<Donation>> getDonationsByDonor(String donorId) async {
    if (!await isAuthenticated()) throw Exception('User not authenticated');
    
    final snapshot = await _database
        .child(DatabasePaths.donations)
        .orderByChild('donorId')
        .equalTo(donorId)
        .get();
    
    if (!snapshot.exists) return [];
    
    final donations = <Donation>[];
    final data = Map<String, dynamic>.from(snapshot.value as Map);
    
    for (final entry in data.entries) {
      donations.add(Donation.fromJson(Map<String, dynamic>.from(entry.value), entry.key));
    }
    
    // Sort by creation time (newest first)
    donations.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return donations;
  }

  // Donation Request Management
  static Future<String> saveDonationRequest(DonationRequest request) async {
    if (!await isAuthenticated()) throw Exception('User not authenticated');
    
    final ref = _database.child(DatabasePaths.donationRequests).push();
    await ref.set(request.toJson());
    return ref.key!;
  }

  static Future<void> updateDonationRequest(String requestId, Map<String, dynamic> updates) async {
    if (!await isAuthenticated()) throw Exception('User not authenticated');
    
    await _database.child(DatabasePaths.donationRequestPath(requestId)).update(updates);
  }

  static Future<List<DonationRequest>> getDonationRequestsForDonor(String donorId) async {
    if (!await isAuthenticated()) throw Exception('User not authenticated');
    
    final snapshot = await _database
        .child(DatabasePaths.donationRequests)
        .orderByChild('donorId')
        .equalTo(donorId)
        .get();
    
    if (!snapshot.exists) return [];
    
    final requests = <DonationRequest>[];
    final data = Map<String, dynamic>.from(snapshot.value as Map);
    
    for (final entry in data.entries) {
      requests.add(DonationRequest.fromJson(Map<String, dynamic>.from(entry.value), entry.key));
    }
    
    // Sort by request time (newest first)
    requests.sort((a, b) => b.requestTime.compareTo(a.requestTime));
    return requests;
  }

  static Future<List<DonationRequest>> getDonationRequestsByRequester(String requesterId) async {
    if (!await isAuthenticated()) throw Exception('User not authenticated');
    
    final snapshot = await _database
        .child(DatabasePaths.donationRequests)
        .orderByChild('requesterId')
        .equalTo(requesterId)
        .get();
    
    if (!snapshot.exists) return [];
    
    final requests = <DonationRequest>[];
    final data = Map<String, dynamic>.from(snapshot.value as Map);
    
    for (final entry in data.entries) {
      requests.add(DonationRequest.fromJson(Map<String, dynamic>.from(entry.value), entry.key));
    }
    
    // Sort by request time (newest first)
    requests.sort((a, b) => b.requestTime.compareTo(a.requestTime));
    return requests;
  }

  // Stream Methods for Real-time Updates
  static Stream<List<Donation>> watchAvailableDonations() {
    return _database
        .child(DatabasePaths.donations)
        .orderByChild('status')
        .equalTo('available')
        .onValue
        .map((event) {
      if (!event.snapshot.exists) return <Donation>[];
      
      final donations = <Donation>[];
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      final now = DateTime.now();
      
      for (final entry in data.entries) {
        final donation = Donation.fromJson(Map<String, dynamic>.from(entry.value), entry.key);
        // Filter out expired donations
        if (donation.expiryTime.isAfter(now)) {
          donations.add(donation);
        }
      }
      
      // Sort by expiry time (soonest first)
      donations.sort((a, b) => a.expiryTime.compareTo(b.expiryTime));
      return donations;
    });
  }

  static Stream<List<DonationRequest>> watchDonationRequestsForDonor(String donorId) {
    return _database
        .child(DatabasePaths.donationRequests)
        .orderByChild('donorId')
        .equalTo(donorId)
        .onValue
        .map((event) {
      if (!event.snapshot.exists) return <DonationRequest>[];
      
      final requests = <DonationRequest>[];
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      
      for (final entry in data.entries) {
        requests.add(DonationRequest.fromJson(Map<String, dynamic>.from(entry.value), entry.key));
      }
      
      // Sort by request time (newest first)
      requests.sort((a, b) => b.requestTime.compareTo(a.requestTime));
      return requests;
    });
  }

  // Utility Methods
  static Future<void> markDonationAsExpired(String donationId) async {
    await updateDonation(donationId, {'status': DonationStatus.expired.value});
  }

  static Future<void> markDonationAsCompleted(String donationId) async {
    await updateDonation(donationId, {'status': DonationStatus.completed.value});
  }

  static Future<void> acceptDonationRequest(String requestId) async {
    await updateDonationRequest(requestId, {'status': RequestStatus.accepted.value});
  }

  static Future<void> rejectDonationRequest(String requestId) async {
    await updateDonationRequest(requestId, {'status': RequestStatus.rejected.value});
  }
}