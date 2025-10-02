// User Types
enum UserType { hotel, ngo, individual, admin }

// User Status
enum UserStatus { active, inactive, suspended, pending }

// Donation Status
enum DonationStatus { available, reserved, completed, expired }

// Request Status
enum RequestStatus { pending, accepted, rejected, cancelled }

// Acceptance Status
enum AcceptanceStatus { confirmed, inProgress, completed, cancelled }

// Urgency Levels
enum UrgencyLevel { low, medium, high, critical }

// Priority Levels
enum PriorityLevel { low, medium, high }

// Food Types
enum FoodType { 
  italian, indian, chinese, continental, mexican, 
  thai, american, mediterranean, japanese, korean,
  vegetarian, vegan, glutenFree, organic, homemade
}

// Notification Types
enum NotificationType {
  donationRequest,
  donationAccepted,
  donationRejected,
  pickupReminder,
  pickupConfirmed,
  emergencyRequest,
  rating,
  system
}

// Extensions for easy string conversion
extension UserTypeExtension on UserType {
  String get value {
    switch (this) {
      case UserType.hotel:
        return 'hotel';
      case UserType.ngo:
        return 'ngo';
      case UserType.individual:
        return 'individual';
      case UserType.admin:
        return 'admin';
    }
  }
  
  static UserType fromString(String value) {
    try {
      switch (value.toLowerCase().trim()) {
        case 'hotel':
          return UserType.hotel;
        case 'ngo':
          return UserType.ngo;
        case 'individual':
          return UserType.individual;
        case 'admin':
          return UserType.admin;
        default:
          print('Warning: Unknown user type "$value", defaulting to individual');
          return UserType.individual;
      }
    } catch (e) {
      print('Error parsing user type "$value": $e, defaulting to individual');
      return UserType.individual;
    }
  }
}

extension DonationStatusExtension on DonationStatus {
  String get value {
    switch (this) {
      case DonationStatus.available:
        return 'available';
      case DonationStatus.reserved:
        return 'reserved';
      case DonationStatus.completed:
        return 'completed';
      case DonationStatus.expired:
        return 'expired';
    }
  }
  
  static DonationStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'available':
        return DonationStatus.available;
      case 'reserved':
        return DonationStatus.reserved;
      case 'completed':
        return DonationStatus.completed;
      case 'expired':
        return DonationStatus.expired;
      default:
        throw ArgumentError('Invalid donation status: $value');
    }
  }
}

extension RequestStatusExtension on RequestStatus {
  String get value {
    switch (this) {
      case RequestStatus.pending:
        return 'pending';
      case RequestStatus.accepted:
        return 'accepted';
      case RequestStatus.rejected:
        return 'rejected';
      case RequestStatus.cancelled:
        return 'cancelled';
    }
  }
  
  static RequestStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return RequestStatus.pending;
      case 'accepted':
        return RequestStatus.accepted;
      case 'rejected':
        return RequestStatus.rejected;
      case 'cancelled':
        return RequestStatus.cancelled;
      default:
        throw ArgumentError('Invalid request status: $value');
    }
  }
}

extension AcceptanceStatusExtension on AcceptanceStatus {
  String get value {
    switch (this) {
      case AcceptanceStatus.confirmed:
        return 'confirmed';
      case AcceptanceStatus.inProgress:
        return 'in_progress';
      case AcceptanceStatus.completed:
        return 'completed';
      case AcceptanceStatus.cancelled:
        return 'cancelled';
    }
  }
  
  static AcceptanceStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'confirmed':
        return AcceptanceStatus.confirmed;
      case 'in_progress':
        return AcceptanceStatus.inProgress;
      case 'completed':
        return AcceptanceStatus.completed;
      case 'cancelled':
        return AcceptanceStatus.cancelled;
      default:
        throw ArgumentError('Invalid acceptance status: $value');
    }
  }
}

extension UrgencyLevelExtension on UrgencyLevel {
  String get value {
    switch (this) {
      case UrgencyLevel.low:
        return 'low';
      case UrgencyLevel.medium:
        return 'medium';
      case UrgencyLevel.high:
        return 'high';
      case UrgencyLevel.critical:
        return 'critical';
    }
  }
  
  static UrgencyLevel fromString(String value) {
    switch (value.toLowerCase()) {
      case 'low':
        return UrgencyLevel.low;
      case 'medium':
        return UrgencyLevel.medium;
      case 'high':
        return UrgencyLevel.high;
      case 'critical':
        return UrgencyLevel.critical;
      default:
        throw ArgumentError('Invalid urgency level: $value');
    }
  }
}

extension NotificationTypeExtension on NotificationType {
  String get value {
    switch (this) {
      case NotificationType.donationRequest:
        return 'donation_request';
      case NotificationType.donationAccepted:
        return 'donation_accepted';
      case NotificationType.donationRejected:
        return 'donation_rejected';
      case NotificationType.pickupReminder:
        return 'pickup_reminder';
      case NotificationType.pickupConfirmed:
        return 'pickup_confirmed';
      case NotificationType.emergencyRequest:
        return 'emergency_request';
      case NotificationType.rating:
        return 'rating';
      case NotificationType.system:
        return 'system';
    }
  }
  
  static NotificationType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'donation_request':
        return NotificationType.donationRequest;
      case 'donation_accepted':
        return NotificationType.donationAccepted;
      case 'donation_rejected':
        return NotificationType.donationRejected;
      case 'pickup_reminder':
        return NotificationType.pickupReminder;
      case 'pickup_confirmed':
        return NotificationType.pickupConfirmed;
      case 'emergency_request':
        return NotificationType.emergencyRequest;
      case 'rating':
        return NotificationType.rating;
      case 'system':
        return NotificationType.system;
      default:
        throw ArgumentError('Invalid notification type: $value');
    }
  }
}