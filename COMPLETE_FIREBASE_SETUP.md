# 🔥 Complete Firebase Realtime Database Setup for OnePlace App

## 📊 Overview
This comprehensive Firebase Realtime Database setup supports:
- **Hotels**: Create and manage food donations
- **NGOs**: Request and receive food donations  
- **Individuals**: Donate and receive food
- **Real-time Updates**: Live notifications and status changes
- **Advanced Features**: Emergency requests, ratings, analytics

## 🏗️ Database Structure

### Core Collections
```
/users              - User profiles and basic information
/hotels             - Hotel-specific data and settings
/ngos               - NGO-specific data and verification
/individuals        - Individual user preferences
/donations          - Available food donations
/donation_requests  - Requests for specific donations
/donation_acceptances - Confirmed donation pickups
/pickup_confirmations - Pickup completion records
/notifications      - User notifications
/ratings_reviews    - Rating and review system
/analytics          - Usage statistics and insights
/emergency_requests - Urgent food requests
/food_categories    - Food type definitions
/app_settings       - Application configuration
```

## 🔐 Security Rules

### Apply These Rules in Firebase Console:

1. Go to **Firebase Console** → **Your Project** → **Realtime Database** → **Rules**
2. Replace existing rules with:

```json
{
  "rules": {
    ".read": false,
    ".write": false,
    
    "users": {
      "$uid": {
        ".read": "$uid === auth.uid || root.child('users').child(auth.uid).child('userType').val() === 'admin'",
        ".write": "$uid === auth.uid",
        ".validate": "newData.hasChildren(['email', 'userType', 'name', 'phone', 'createdAt'])"
      }
    },
    
    "hotels": {
      ".read": "auth != null",
      "$uid": {
        ".write": "$uid === auth.uid && root.child('users').child(auth.uid).child('userType').val() === 'hotel'",
        ".validate": "newData.hasChildren(['name', 'verified', 'status'])"
      },
      ".indexOn": ["verified", "status", "lastDonationDate"]
    },
    
    "ngos": {
      ".read": "auth != null",
      "$uid": {
        ".write": "$uid === auth.uid && root.child('users').child(auth.uid).child('userType').val() === 'ngo'",
        ".validate": "newData.hasChildren(['name', 'registrationNumber', 'verified', 'status'])"
      },
      ".indexOn": ["verified", "status", "lastReceivedDate"]
    },
    
    "individuals": {
      ".read": "auth != null",
      "$uid": {
        ".write": "$uid === auth.uid && root.child('users').child(auth.uid).child('userType').val() === 'individual'",
        ".validate": "newData.hasChildren(['name', 'status'])"
      },
      ".indexOn": ["verified", "status"]
    },
    
    "donations": {
      ".read": "auth != null",
      ".write": "auth != null",
      "$donationId": {
        ".validate": "newData.hasChildren(['donorId', 'donorType', 'title', 'description', 'quantity', 'expiryTime', 'createdAt', 'status', 'location']) && (newData.child('donorId').val() === auth.uid || data.child('donorId').val() === auth.uid)",
        "status": {
          ".validate": "newData.isString() && (newData.val() === 'available' || newData.val() === 'reserved' || newData.val() === 'completed' || newData.val() === 'expired')"
        }
      },
      ".indexOn": ["donorId", "donorType", "status", "expiryTime", "createdAt", "foodType", "priority"]
    },
    
    "donation_requests": {
      ".read": "auth != null",
      ".write": "auth != null",
      "$requestId": {
        ".validate": "newData.hasChildren(['requesterId', 'requesterType', 'donationId', 'donorId', 'requestTime', 'status']) && (newData.child('requesterId').val() === auth.uid || newData.child('donorId').val() === auth.uid || data.child('requesterId').val() === auth.uid || data.child('donorId').val() === auth.uid)",
        "status": {
          ".validate": "newData.isString() && (newData.val() === 'pending' || newData.val() === 'accepted' || newData.val() === 'rejected' || newData.val() === 'cancelled')"
        }
      },
      ".indexOn": ["requesterId", "donationId", "donorId", "status", "requestTime", "urgency"]
    },
    
    "donation_acceptances": {
      ".read": "auth != null",
      ".write": "auth != null",
      "$acceptanceId": {
        ".validate": "newData.hasChildren(['donationId', 'donorId', 'recipientId', 'acceptanceTime', 'status']) && (newData.child('donorId').val() === auth.uid || newData.child('recipientId').val() === auth.uid || data.child('donorId').val() === auth.uid || data.child('recipientId').val() === auth.uid)",
        "status": {
          ".validate": "newData.isString() && (newData.val() === 'confirmed' || newData.val() === 'in_progress' || newData.val() === 'completed' || newData.val() === 'cancelled')"
        }
      },
      ".indexOn": ["donationId", "donorId", "recipientId", "status", "acceptanceTime", "scheduledPickupTime"]
    },
    
    "pickup_confirmations": {
      ".read": "auth != null",
      ".write": "auth != null",
      "$pickupId": {
        ".validate": "newData.hasChildren(['donationId', 'acceptanceId', 'pickedUpBy', 'pickupTime']) && (root.child('donation_acceptances').child(newData.child('acceptanceId').val()).child('donorId').val() === auth.uid || root.child('donation_acceptances').child(newData.child('acceptanceId').val()).child('recipientId').val() === auth.uid)"
      },
      ".indexOn": ["donationId", "acceptanceId", "pickedUpBy", "pickupTime"]
    },
    
    "notifications": {
      "$uid": {
        ".read": "$uid === auth.uid",
        ".write": "$uid === auth.uid",
        "$notificationId": {
          ".validate": "newData.hasChildren(['type', 'title', 'message', 'createdAt', 'read'])"
        }
      },
      ".indexOn": ["createdAt", "read", "type", "priority"]
    },
    
    "ratings_reviews": {
      ".read": "auth != null",
      ".write": "auth != null",
      "$reviewId": {
        ".validate": "newData.hasChildren(['reviewerId', 'reviewedId', 'donationId', 'rating', 'createdAt']) && newData.child('reviewerId').val() === auth.uid && newData.child('rating').isNumber() && newData.child('rating').val() >= 1 && newData.child('rating').val() <= 5"
      },
      ".indexOn": ["reviewerId", "reviewedId", "donationId", "rating", "createdAt"]
    },
    
    "analytics": {
      "daily_stats": {
        ".read": "auth != null",
        ".write": "root.child('users').child(auth.uid).child('userType').val() === 'admin'"
      },
      "user_stats": {
        "$uid": {
          ".read": "$uid === auth.uid || root.child('users').child(auth.uid).child('userType').val() === 'admin'",
          ".write": "root.child('users').child(auth.uid).child('userType').val() === 'admin'"
        }
      }
    },
    
    "emergency_requests": {
      ".read": "auth != null",
      ".write": "auth != null && (root.child('users').child(auth.uid).child('userType').val() === 'ngo' || root.child('users').child(auth.uid).child('userType').val() === 'admin')",
      "$emergencyId": {
        ".validate": "newData.hasChildren(['requesterId', 'requesterType', 'title', 'description', 'urgency', 'deadline', 'status', 'createdAt']) && newData.child('requesterId').val() === auth.uid"
      },
      ".indexOn": ["requesterId", "urgency", "status", "deadline", "createdAt"]
    },
    
    "food_categories": {
      ".read": "auth != null",
      ".write": "root.child('users').child(auth.uid).child('userType').val() === 'admin'"
    },
    
    "app_settings": {
      ".read": "auth != null",
      ".write": "root.child('users').child(auth.uid).child('userType').val() === 'admin'"
    }
  }
}
```

3. Click **Publish**
4. Wait 10-15 seconds for propagation

## 📱 Implementation Files

### 1. Database Paths (`lib/utils/database_paths.dart`)
```dart
class DatabasePaths {
  // User paths
  static const String users = 'users';
  static const String hotels = 'hotels';
  static const String ngos = 'ngos';
  static const String individuals = 'individuals';
  
  // Donation paths
  static const String donations = 'donations';
  static const String donationRequests = 'donation_requests';
  static const String donationAcceptances = 'donation_acceptances';
  static const String pickupConfirmations = 'pickup_confirmations';
  
  // Communication paths
  static const String notifications = 'notifications';
  static const String ratingsReviews = 'ratings_reviews';
  
  // Analytics paths
  static const String analytics = 'analytics';
  static const String dailyStats = 'analytics/daily_stats';
  static const String userStats = 'analytics/user_stats';
  
  // Emergency and categories
  static const String emergencyRequests = 'emergency_requests';
  static const String foodCategories = 'food_categories';
  static const String appSettings = 'app_settings';
  
  // Helper methods
  static String userPath(String uid) => '$users/$uid';
  static String hotelPath(String uid) => '$hotels/$uid';
  static String ngoPath(String uid) => '$ngos/$uid';
  static String individualPath(String uid) => '$individuals/$uid';
  
  static String donationPath(String donationId) => '$donations/$donationId';
  static String donationRequestPath(String requestId) => '$donationRequests/$requestId';
  static String donationAcceptancePath(String acceptanceId) => '$donationAcceptances/$acceptanceId';
  static String pickupConfirmationPath(String pickupId) => '$pickupConfirmations/$pickupId';
  
  static String userNotificationsPath(String uid) => '$notifications/$uid';
  static String userStatsPath(String uid) => '$userStats/$uid';
  
  static String emergencyRequestPath(String emergencyId) => '$emergencyRequests/$emergencyId';
  static String ratingReviewPath(String reviewId) => '$ratingsReviews/$reviewId';
}
```

### 2. Database Enums (`lib/utils/database_enums.dart`)
```dart
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

// Extensions for easy string conversion
extension UserTypeExtension on UserType {
  String get value {
    switch (this) {
      case UserType.hotel: return 'hotel';
      case UserType.ngo: return 'ngo';
      case UserType.individual: return 'individual';
      case UserType.admin: return 'admin';
    }
  }
  
  static UserType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'hotel': return UserType.hotel;
      case 'ngo': return UserType.ngo;
      case 'individual': return UserType.individual;
      case 'admin': return UserType.admin;
      default: throw ArgumentError('Invalid user type: $value');
    }
  }
}

// Add similar extensions for other enums...
```

## 🚀 Usage Examples

### For Hotels - Creating a Donation:
```dart
final donation = Donation(
  id: '', // Will be generated
  donorId: FirebaseService.currentUserId!,
  donorType: UserType.hotel,
  donorName: 'Grand Hotel',
  title: 'Fresh Pasta and Salads',
  description: 'Leftover pasta dishes from lunch service',
  foodType: 'Italian',
  quantity: '20 servings',
  expiryTime: DateTime.now().add(Duration(hours: 4)),
  createdAt: DateTime.now(),
  location: Location(
    latitude: 40.7128,
    longitude: -74.0060,
    address: '123 Main St, New York, NY'
  ),
  dietaryInfo: DietaryInfo(
    vegetarian: true,
    vegan: false,
    glutenFree: false,
    nutFree: true,
  ),
  contactNumber: '+1234567890',
  priority: PriorityLevel.medium,
  tags: ['fresh', 'italian', 'vegetarian'],
);

final donationId = await FirebaseService.saveDonation(donation);
```

### For NGOs - Requesting a Donation:
```dart
final request = DonationRequest(
  id: '', // Will be generated
  requesterId: FirebaseService.currentUserId!,
  requesterType: UserType.ngo,
  requesterName: 'Food Relief Foundation',
  donationId: donationId,
  donorId: donation.donorId,
  message: 'We would like to collect this for our evening distribution',
  requestTime: DateTime.now(),
  urgency: UrgencyLevel.medium,
  estimatedPickupTime: DateTime.now().add(Duration(hours: 2)),
  contactNumber: '+1234567891',
  numberOfBeneficiaries: 50,
);

final requestId = await FirebaseService.saveDonationRequest(request);
```

### For Individuals - Donating Food:
```dart
final donation = Donation(
  id: '',
  donorId: FirebaseService.currentUserId!,
  donorType: UserType.individual,
  donorName: 'John Doe',
  title: 'Home-cooked Curry',
  description: 'Extra curry and rice from family dinner',
  foodType: 'Indian',
  quantity: '5 servings',
  expiryTime: DateTime.now().add(Duration(hours: 16)),
  createdAt: DateTime.now(),
  location: Location(
    latitude: 40.7505,
    longitude: -73.9934,
    address: '789 Pine St, New York, NY'
  ),
  dietaryInfo: DietaryInfo(
    vegetarian: true,
    vegan: false,
    glutenFree: true,
    nutFree: false,
  ),
  contactNumber: '+1234567892',
  priority: PriorityLevel.low,
  tags: ['homemade', 'indian', 'spicy'],
);

await FirebaseService.saveDonation(donation);
```

## 🔍 Real-time Updates

### Watch Available Donations:
```dart
StreamBuilder<List<Donation>>(
  stream: FirebaseService.watchAvailableDonations(),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      final donations = snapshot.data!;
      return ListView.builder(
        itemCount: donations.length,
        itemBuilder: (context, index) {
          return DonationCard(donation: donations[index]);
        },
      );
    }
    return CircularProgressIndicator();
  },
)
```

### Watch Donation Requests:
```dart
StreamBuilder<List<DonationRequest>>(
  stream: FirebaseService.watchDonationRequestsForDonor(donorId),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      final requests = snapshot.data!;
      return ListView.builder(
        itemCount: requests.length,
        itemBuilder: (context, index) {
          return RequestCard(request: requests[index]);
        },
      );
    }
    return CircularProgressIndicator();
  },
)
```

## 🔧 Testing Setup

### 1. Create Test Users:
```dart
// Hotel user
await FirebaseService.signUpWithEmailPassword('hotel@test.com', 'password123');
await FirebaseService.saveUser(User(
  uid: FirebaseService.currentUserId!,
  email: 'hotel@test.com',
  userType: UserType.hotel,
  name: 'Test Hotel',
  phone: '+1234567890',
  address: Address(
    street: '123 Hotel St',
    city: 'New York',
    state: 'NY',
    zipCode: '10001',
  ),
  createdAt: DateTime.now(),
));

// NGO user
await FirebaseService.signUpWithEmailPassword('ngo@test.com', 'password123');
await FirebaseService.saveUser(User(
  uid: FirebaseService.currentUserId!,
  email: 'ngo@test.com',
  userType: UserType.ngo,
  name: 'Test NGO',
  phone: '+1234567891',
  address: Address(
    street: '456 NGO Ave',
    city: 'New York',
    state: 'NY',
    zipCode: '10002',
  ),
  createdAt: DateTime.now(),
));
```

## ✅ Verification Steps

1. **Authentication**: Users can sign up and sign in
2. **User Profiles**: User data saves correctly in respective collections
3. **Donations**: Hotels/Individuals can create donations
4. **Requests**: NGOs can request donations
5. **Real-time Updates**: Changes reflect immediately across all users
6. **Security**: Rules prevent unauthorized access
7. **Performance**: Database queries are optimized with proper indexing

## 🚨 Troubleshooting

### Common Issues:
1. **Permission Denied**: Ensure Firebase rules are published
2. **Index Required**: Add `.indexOn` rules for query fields
3. **Authentication**: Verify user is signed in before database operations
4. **Data Format**: Ensure JSON structure matches model expectations

### Debug Commands:
```dart
// Check current user
print('Current user: ${FirebaseService.currentUser?.uid}');
print('User email: ${FirebaseService.currentUser?.email}');

// Test database write
await FirebaseDatabase.instance.ref().child('test').set({'hello': 'world'});
```

This comprehensive setup provides a robust, scalable Firebase Realtime Database for your OnePlace food donation app supporting Hotels, NGOs, and Individuals with real-time capabilities!