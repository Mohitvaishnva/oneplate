import '../utils/database_enums.dart';

class Donation {
  final String id;
  final String donorId;
  final UserType donorType;
  final String donorName;
  final String title;
  final String description;
  final String foodType;
  final String quantity;
  final DateTime expiryTime;
  final DateTime createdAt;
  final List<String> images;
  final Location location;
  final DonationStatus status;
  final DietaryInfo dietaryInfo;
  final String pickupInstructions;
  final String contactNumber;
  final PriorityLevel priority;
  final List<String> tags;

  Donation({
    required this.id,
    required this.donorId,
    required this.donorType,
    required this.donorName,
    required this.title,
    required this.description,
    required this.foodType,
    required this.quantity,
    required this.expiryTime,
    required this.createdAt,
    this.images = const [],
    required this.location,
    this.status = DonationStatus.available,
    required this.dietaryInfo,
    this.pickupInstructions = '',
    required this.contactNumber,
    this.priority = PriorityLevel.medium,
    this.tags = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'donorId': donorId,
      'donorType': donorType.value,
      'donorName': donorName,
      'title': title,
      'description': description,
      'foodType': foodType,
      'quantity': quantity,
      'expiryTime': expiryTime.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'images': images,
      'location': location.toJson(),
      'status': status.value,
      'dietaryInfo': dietaryInfo.toJson(),
      'pickupInstructions': pickupInstructions,
      'contactNumber': contactNumber,
      'priority': priority.name,
      'tags': tags,
    };
  }

  factory Donation.fromJson(Map<String, dynamic> json, String id) {
    try {
      // Safely handle location data
      Map<String, dynamic> locationData = {};
      if (json['location'] != null) {
        if (json['location'] is Map<Object?, Object?>) {
          locationData = Map<String, dynamic>.from(json['location'] as Map<Object?, Object?>);
        } else if (json['location'] is Map<String, dynamic>) {
          locationData = json['location'];
        }
      }

      // Safely handle dietaryInfo data
      Map<String, dynamic> dietaryData = {};
      if (json['dietaryInfo'] != null) {
        if (json['dietaryInfo'] is Map<Object?, Object?>) {
          dietaryData = Map<String, dynamic>.from(json['dietaryInfo'] as Map<Object?, Object?>);
        } else if (json['dietaryInfo'] is Map<String, dynamic>) {
          dietaryData = json['dietaryInfo'];
        }
      }

      return Donation(
        id: id,
        donorId: json['donorId']?.toString() ?? '',
        donorType: UserTypeExtension.fromString(json['donorType']?.toString() ?? 'individual'),
        donorName: json['donorName']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        foodType: json['foodType']?.toString() ?? '',
        quantity: json['quantity']?.toString() ?? '',
        expiryTime: _parseDateTime(json['expiryTime']),
        createdAt: _parseDateTime(json['createdAt']),
        images: _parseStringList(json['images']),
        location: Location.fromJson(locationData),
        status: DonationStatusExtension.fromString(json['status']?.toString() ?? 'available'),
        dietaryInfo: DietaryInfo.fromJson(dietaryData),
        pickupInstructions: json['pickupInstructions']?.toString() ?? '',
        contactNumber: json['contactNumber']?.toString() ?? '',
        priority: PriorityLevel.values.firstWhere(
          (p) => p.name == json['priority']?.toString(),
          orElse: () => PriorityLevel.medium,
        ),
        tags: _parseStringList(json['tags']),
      );
    } catch (e) {
      print('Error parsing donation data: $e');
      print('JSON: $json');
      rethrow;
    }
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    try {
      if (value is String) {
        return DateTime.parse(value);
      } else if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      }
      return DateTime.now();
    } catch (e) {
      return DateTime.now();
    }
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }
}

class Location {
  final double latitude;
  final double longitude;
  final String address;

  Location({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      address: json['address'] ?? '',
    );
  }
}

class DietaryInfo {
  final bool vegetarian;
  final bool vegan;
  final bool glutenFree;
  final bool nutFree;

  DietaryInfo({
    this.vegetarian = false,
    this.vegan = false,
    this.glutenFree = false,
    this.nutFree = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'vegetarian': vegetarian,
      'vegan': vegan,
      'glutenFree': glutenFree,
      'nutFree': nutFree,
    };
  }

  factory DietaryInfo.fromJson(Map<String, dynamic> json) {
    return DietaryInfo(
      vegetarian: json['vegetarian'] ?? false,
      vegan: json['vegan'] ?? false,
      glutenFree: json['glutenFree'] ?? false,
      nutFree: json['nutFree'] ?? false,
    );
  }
}

class DonationRequest {
  final String id;
  final String requesterId;
  final UserType requesterType;
  final String requesterName;
  final String donationId;
  final String donorId;
  final String message;
  final DateTime requestTime;
  final RequestStatus status;
  final UrgencyLevel urgency;
  final DateTime? estimatedPickupTime;
  final String contactNumber;
  final int? numberOfBeneficiaries;

  DonationRequest({
    required this.id,
    required this.requesterId,
    required this.requesterType,
    required this.requesterName,
    required this.donationId,
    required this.donorId,
    this.message = '',
    required this.requestTime,
    this.status = RequestStatus.pending,
    this.urgency = UrgencyLevel.medium,
    this.estimatedPickupTime,
    required this.contactNumber,
    this.numberOfBeneficiaries,
  });

  Map<String, dynamic> toJson() {
    return {
      'requesterId': requesterId,
      'requesterType': requesterType.value,
      'requesterName': requesterName,
      'donationId': donationId,
      'donorId': donorId,
      'message': message,
      'requestTime': requestTime.toIso8601String(),
      'status': status.value,
      'urgency': urgency.value,
      if (estimatedPickupTime != null) 'estimatedPickupTime': estimatedPickupTime!.toIso8601String(),
      'contactNumber': contactNumber,
      if (numberOfBeneficiaries != null) 'numberOfBeneficiaries': numberOfBeneficiaries,
    };
  }

  factory DonationRequest.fromJson(Map<String, dynamic> json, String id) {
    return DonationRequest(
      id: id,
      requesterId: json['requesterId'] ?? '',
      requesterType: UserTypeExtension.fromString(json['requesterType'] ?? 'ngo'),
      requesterName: json['requesterName'] ?? '',
      donationId: json['donationId'] ?? '',
      donorId: json['donorId'] ?? '',
      message: json['message'] ?? '',
      requestTime: DateTime.parse(json['requestTime'] ?? DateTime.now().toIso8601String()),
      status: RequestStatusExtension.fromString(json['status'] ?? 'pending'),
      urgency: UrgencyLevelExtension.fromString(json['urgency'] ?? 'medium'),
      estimatedPickupTime: json['estimatedPickupTime'] != null 
        ? DateTime.parse(json['estimatedPickupTime']) 
        : null,
      contactNumber: json['contactNumber'] ?? '',
      numberOfBeneficiaries: json['numberOfBeneficiaries'],
    );
  }
}

class DonationAcceptance {
  final String id;
  final String donationId;
  final String? requestId;
  final String donorId;
  final String recipientId;
  final UserType recipientType;
  final DateTime acceptanceTime;
  final DateTime? scheduledPickupTime;
  final AcceptanceStatus status;
  final String notes;
  final String? trackingCode;

  DonationAcceptance({
    required this.id,
    required this.donationId,
    this.requestId,
    required this.donorId,
    required this.recipientId,
    required this.recipientType,
    required this.acceptanceTime,
    this.scheduledPickupTime,
    this.status = AcceptanceStatus.confirmed,
    this.notes = '',
    this.trackingCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'donationId': donationId,
      if (requestId != null) 'requestId': requestId,
      'donorId': donorId,
      'recipientId': recipientId,
      'recipientType': recipientType.value,
      'acceptanceTime': acceptanceTime.toIso8601String(),
      if (scheduledPickupTime != null) 'scheduledPickupTime': scheduledPickupTime!.toIso8601String(),
      'status': status.value,
      'notes': notes,
      if (trackingCode != null) 'trackingCode': trackingCode,
    };
  }

  factory DonationAcceptance.fromJson(Map<String, dynamic> json, String id) {
    return DonationAcceptance(
      id: id,
      donationId: json['donationId'] ?? '',
      requestId: json['requestId'],
      donorId: json['donorId'] ?? '',
      recipientId: json['recipientId'] ?? '',
      recipientType: UserTypeExtension.fromString(json['recipientType'] ?? 'ngo'),
      acceptanceTime: DateTime.parse(json['acceptanceTime'] ?? DateTime.now().toIso8601String()),
      scheduledPickupTime: json['scheduledPickupTime'] != null 
        ? DateTime.parse(json['scheduledPickupTime']) 
        : null,
      status: AcceptanceStatusExtension.fromString(json['status'] ?? 'confirmed'),
      notes: json['notes'] ?? '',
      trackingCode: json['trackingCode'],
    );
  }
}

class PickupConfirmation {
  final String id;
  final String donationId;
  final String acceptanceId;
  final String pickedUpBy;
  final DateTime pickupTime;
  final String actualQuantity;
  final String condition;
  final String? recipientSignature;
  final bool donorConfirmation;
  final List<String> photos;
  final String notes;

  PickupConfirmation({
    required this.id,
    required this.donationId,
    required this.acceptanceId,
    required this.pickedUpBy,
    required this.pickupTime,
    required this.actualQuantity,
    this.condition = 'good',
    this.recipientSignature,
    this.donorConfirmation = false,
    this.photos = const [],
    this.notes = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'donationId': donationId,
      'acceptanceId': acceptanceId,
      'pickedUpBy': pickedUpBy,
      'pickupTime': pickupTime.toIso8601String(),
      'actualQuantity': actualQuantity,
      'condition': condition,
      if (recipientSignature != null) 'recipientSignature': recipientSignature,
      'donorConfirmation': donorConfirmation,
      'photos': photos,
      'notes': notes,
    };
  }

  factory PickupConfirmation.fromJson(Map<String, dynamic> json, String id) {
    return PickupConfirmation(
      id: id,
      donationId: json['donationId'] ?? '',
      acceptanceId: json['acceptanceId'] ?? '',
      pickedUpBy: json['pickedUpBy'] ?? '',
      pickupTime: DateTime.parse(json['pickupTime'] ?? DateTime.now().toIso8601String()),
      actualQuantity: json['actualQuantity'] ?? '',
      condition: json['condition'] ?? 'good',
      recipientSignature: json['recipientSignature'],
      donorConfirmation: json['donorConfirmation'] ?? false,
      photos: List<String>.from(json['photos'] ?? []),
      notes: json['notes'] ?? '',
    );
  }
}