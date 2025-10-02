import '../utils/database_enums.dart';

class User {
  final String uid;
  final String email;
  final UserType userType;
  final String name;
  final String phone;
  final Address address;
  final DateTime createdAt;
  final bool isActive;
  final String? profileImage;

  User({
    required this.uid,
    required this.email,
    required this.userType,
    required this.name,
    required this.phone,
    required this.address,
    required this.createdAt,
    this.isActive = true,
    this.profileImage,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'userType': userType.value,
      'name': name,
      'phone': phone,
      'address': address.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
      if (profileImage != null) 'profileImage': profileImage,
    };
  }

  factory User.fromJson(Map<String, dynamic> json, String uid) {
    try {
      return User(
        uid: uid,
        email: json['email']?.toString() ?? '',
        userType: UserTypeExtension.fromString(json['userType']?.toString() ?? 'individual'),
        name: json['name']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
        address: json['address'] != null && json['address'] is Map 
            ? Address.fromJson(Map<String, dynamic>.from(json['address']))
            : Address.fromJson({}),
        createdAt: json['createdAt'] != null 
            ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
            : DateTime.now(),
        isActive: json['isActive'] == true,
        profileImage: json['profileImage']?.toString(),
      );
    } catch (e) {
      print('Error parsing User from JSON: $e');
      print('JSON data: $json');
      rethrow;
    }
  }
}

class Address {
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final Coordinates? coordinates;

  Address({
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    this.coordinates,
  });

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      if (coordinates != null) 'coordinates': coordinates!.toJson(),
    };
  }

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      zipCode: json['zipCode'] ?? '',
      coordinates: json['coordinates'] != null 
        ? Coordinates.fromJson(json['coordinates']) 
        : null,
    );
  }
}

class Coordinates {
  final double latitude;
  final double longitude;

  Coordinates({required this.latitude, required this.longitude});

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory Coordinates.fromJson(Map<String, dynamic> json) {
    return Coordinates(
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
    );
  }
}

class Hotel {
  final String uid;
  final String name;
  final String? licenseNumber;
  final List<String> cuisine;
  final int capacity;
  final OperatingHours operatingHours;
  final double rating;
  final int totalDonations;
  final DateTime? lastDonationDate;
  final bool verified;
  final UserStatus status;

  Hotel({
    required this.uid,
    required this.name,
    this.licenseNumber,
    this.cuisine = const [],
    this.capacity = 0,
    required this.operatingHours,
    this.rating = 0.0,
    this.totalDonations = 0,
    this.lastDonationDate,
    this.verified = false,
    this.status = UserStatus.active,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (licenseNumber != null) 'licenseNumber': licenseNumber,
      'cuisine': cuisine,
      'capacity': capacity,
      'operatingHours': operatingHours.toJson(),
      'rating': rating,
      'totalDonations': totalDonations,
      if (lastDonationDate != null) 'lastDonationDate': lastDonationDate!.toIso8601String(),
      'verified': verified,
      'status': status.name,
    };
  }

  factory Hotel.fromJson(Map<String, dynamic> json, String uid) {
    return Hotel(
      uid: uid,
      name: json['name'] ?? '',
      licenseNumber: json['licenseNumber'],
      cuisine: List<String>.from(json['cuisine'] ?? []),
      capacity: json['capacity'] ?? 0,
      operatingHours: OperatingHours.fromJson(json['operatingHours'] ?? {}),
      rating: (json['rating'] ?? 0.0).toDouble(),
      totalDonations: json['totalDonations'] ?? 0,
      lastDonationDate: json['lastDonationDate'] != null 
        ? DateTime.parse(json['lastDonationDate']) 
        : null,
      verified: json['verified'] ?? false,
      status: UserStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => UserStatus.active,
      ),
    );
  }
}

class NGO {
  final String uid;
  final String name;
  final String registrationNumber;
  final List<String> focusAreas;
  final List<String> servingAreas;
  final int capacity;
  final OperatingHours operatingHours;
  final int totalReceived;
  final DateTime? lastReceivedDate;
  final bool verified;
  final UserStatus status;
  final bool documentsVerified;

  NGO({
    required this.uid,
    required this.name,
    required this.registrationNumber,
    this.focusAreas = const [],
    this.servingAreas = const [],
    this.capacity = 0,
    required this.operatingHours,
    this.totalReceived = 0,
    this.lastReceivedDate,
    this.verified = false,
    this.status = UserStatus.active,
    this.documentsVerified = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'registrationNumber': registrationNumber,
      'focusAreas': focusAreas,
      'servingAreas': servingAreas,
      'capacity': capacity,
      'operatingHours': operatingHours.toJson(),
      'totalReceived': totalReceived,
      if (lastReceivedDate != null) 'lastReceivedDate': lastReceivedDate!.toIso8601String(),
      'verified': verified,
      'status': status.name,
      'documentsVerified': documentsVerified,
    };
  }

  factory NGO.fromJson(Map<String, dynamic> json, String uid) {
    return NGO(
      uid: uid,
      name: json['name'] ?? '',
      registrationNumber: json['registrationNumber'] ?? '',
      focusAreas: List<String>.from(json['focusAreas'] ?? []),
      servingAreas: List<String>.from(json['servingAreas'] ?? []),
      capacity: json['capacity'] ?? 0,
      operatingHours: OperatingHours.fromJson(json['operatingHours'] ?? {}),
      totalReceived: json['totalReceived'] ?? 0,
      lastReceivedDate: json['lastReceivedDate'] != null 
        ? DateTime.parse(json['lastReceivedDate']) 
        : null,
      verified: json['verified'] ?? false,
      status: UserStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => UserStatus.active,
      ),
      documentsVerified: json['documentsVerified'] ?? false,
    );
  }
}

class Individual {
  final String uid;
  final String name;
  final UserPreferences preferences;
  final DonationHistory donationHistory;
  final bool verified;
  final UserStatus status;

  Individual({
    required this.uid,
    required this.name,
    required this.preferences,
    required this.donationHistory,
    this.verified = false,
    this.status = UserStatus.active,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'preferences': preferences.toJson(),
      'donationHistory': donationHistory.toJson(),
      'verified': verified,
      'status': status.name,
    };
  }

  factory Individual.fromJson(Map<String, dynamic> json, String uid) {
    return Individual(
      uid: uid,
      name: json['name'] ?? '',
      preferences: UserPreferences.fromJson(json['preferences'] ?? {}),
      donationHistory: DonationHistory.fromJson(json['donationHistory'] ?? {}),
      verified: json['verified'] ?? false,
      status: UserStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => UserStatus.active,
      ),
    );
  }
}

class OperatingHours {
  final String open;
  final String close;

  OperatingHours({required this.open, required this.close});

  Map<String, dynamic> toJson() {
    return {
      'open': open,
      'close': close,
    };
  }

  factory OperatingHours.fromJson(Map<String, dynamic> json) {
    return OperatingHours(
      open: json['open'] ?? '00:00',
      close: json['close'] ?? '23:59',
    );
  }
}

class UserPreferences {
  final List<String> foodTypes;
  final double maxDistance;
  final bool notifications;

  UserPreferences({
    this.foodTypes = const [],
    this.maxDistance = 10.0,
    this.notifications = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'foodTypes': foodTypes,
      'maxDistance': maxDistance,
      'notifications': notifications,
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      foodTypes: List<String>.from(json['foodTypes'] ?? []),
      maxDistance: (json['maxDistance'] ?? 10.0).toDouble(),
      notifications: json['notifications'] ?? true,
    );
  }
}

class DonationHistory {
  final int given;
  final int received;

  DonationHistory({this.given = 0, this.received = 0});

  Map<String, dynamic> toJson() {
    return {
      'given': given,
      'received': received,
    };
  }

  factory DonationHistory.fromJson(Map<String, dynamic> json) {
    return DonationHistory(
      given: json['given'] ?? 0,
      received: json['received'] ?? 0,
    );
  }
}