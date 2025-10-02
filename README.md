# OnePlate - Food Donation App

OnePlate is a Flutter application that connects NGOs, Hotels, and Individual donors to facilitate food donation and reduce food waste.

## Features

### 🏢 NGO Features
- Register as an NGO with organization details
- Create food requests specifying needs and food type preferences
- View available donations from hotels and individuals
- Accept donations and manage donation history
- View responses from donors

### 🏨 Hotel Features
- Register hotel with details and food type offerings
- Browse NGO food requests
- Send donations with quantity, preparation time, and expiry details
- View donation history
- Get responses from NGOs

### 👤 Individual Features
- Register as individual donor
- Browse NGO requests
- Make food donations
- Track donation history
- Receive NGO responses

## Architecture

```
lib/
├── main.dart                    # App entry point
├── models/                      # Data models
│   ├── ngo.dart
│   ├── hotel.dart
│   ├── individual.dart
│   ├── donation_request.dart
│   └── donation.dart
├── services/                    # Business logic
│   ├── firebase_config.dart
│   └── firebase_service.dart
├── screens/                     # UI screens
│   ├── commonscreens/          # Shared screens
│   │   ├── welcome.dart
│   │   └── login.dart
│   ├── ngoscreens/             # NGO workflow
│   │   ├── registerngo.dart
│   │   ├── ngomain.dart
│   │   ├── ngohome.dart
│   │   ├── donordetails.dart
│   │   ├── ngohistory.dart
│   │   ├── createdonation.dart
│   │   ├── profile.dart
│   │   └── response.dart
│   ├── hotelscreens/           # Hotel workflow
│   │   ├── hotelregister.dart
│   │   ├── hotelmain.dart
│   │   ├── hotelhome.dart
│   │   ├── ngodetails.dart
│   │   ├── donate.dart
│   │   ├── donatehistory.dart
│   │   ├── profile.dart
│   │   └── response.dart
│   └── individualscreens/      # Individual workflow
│       ├── individualregister.dart
│       ├── individualmain.dart
│       ├── individualhome.dart
│       ├── donate.dart
│       ├── donatehistory.dart
│       ├── profile.dart
│       └── response.dart
└── widgets/                    # Reusable widgets (future expansion)
```

## Firebase Setup

### Prerequisites
1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Enable Firebase Authentication (Email/Password)
3. Enable Firebase Realtime Database
4. Configure Firebase for your platforms

### Database Structure
```json
{
  "ngos": {
    "userId": {
      "id": "userId",
      "ownerName": "NGO Owner",
      "ngoName": "NGO Name",
      "address": "Address",
      "email": "email@example.com",
      "phoneNumber": "1234567890",
      "areaCovered": "Area",
      "certificateUrl": "optional"
    }
  },
  "hotels": {
    "userId": {
      "id": "userId",
      "hotelName": "Hotel Name",
      "email": "email@example.com",
      "address": "Address",
      "openingHours": "9AM-11PM",
      "foodType": "Veg/Non-Veg/Both",
      "imageUrl": "optional"
    }
  },
  "individuals": {
    "userId": {
      "id": "userId",
      "name": "Individual Name",
      "email": "email@example.com",
      "address": "Address",
      "phoneNumber": "1234567890"
    }
  },
  "donation_requests": {
    "requestId": {
      "id": "requestId",
      "ngoId": "userId",
      "ngoName": "NGO Name",
      "description": "Food request description",
      "foodType": "Veg/Non-Veg/Both",
      "createdAt": 1234567890,
      "isActive": true
    }
  },
  "donations": {
    "donationId": {
      "id": "donationId",
      "donorId": "userId",
      "donorName": "Donor Name",
      "donorType": "Hotel/Individual",
      "ngoId": "userId",
      "ngoName": "NGO Name",
      "foodQuantity": "20 plates",
      "madAt": 1234567890,
      "expiryTime": 1234567890,
      "imageUrl": "optional",
      "status": "Pending/Accepted/Completed",
      "createdAt": 1234567890
    }
  }
}
```

## Setup Instructions

### 1. Clone and Setup
```bash
git clone <repository-url>
cd oneplate
flutter pub get
```

### 2. Firebase Configuration
- Replace the Firebase configuration in `lib/services/firebase_config.dart` with your project's config
- For Android: Add `google-services.json` to `android/app/`
- For iOS: Add `GoogleService-Info.plist` to `ios/Runner/`

### 3. Run the App
```bash
# Clean build (if needed)
flutter clean
flutter pub get

# Run on device/emulator
flutter run
```

### 4. Troubleshooting Storage Issues
If you encounter `INSTALL_FAILED_INSUFFICIENT_STORAGE`:

1. **Clean project:**
   ```bash
   flutter clean
   flutter pub get
   ```

2. **Free up emulator space:**
   - Wipe emulator data in Android Studio
   - Create new emulator with more storage
   - Or use physical device

3. **Alternative run methods:**
   ```bash
   # Run in release mode (smaller APK)
   flutter run --release
   
   # Run on web
   flutter run -d chrome
   ```

## Current Implementation Status

### ✅ Completed Features
- Complete project structure
- Firebase integration (Auth + Realtime Database)
- User registration for all user types (NGO, Hotel, Individual)
- Login system with user type detection
- NGO workflow:
  - Registration with organization details
  - Dashboard with statistics
  - Create food requests
  - View and accept donations
  - Bottom navigation
- Hotel workflow:
  - Registration with hotel details
  - Dashboard showing NGO requests
  - Send donations to NGOs
  - Bottom navigation
- Individual workflow:
  - Basic registration and navigation structure
- Material Design UI with consistent theming

### 🚧 Features for Future Enhancement
- Image upload functionality for certificates and food photos
- Push notifications for new requests/donations
- Real-time chat between NGOs and donors
- Location-based matching
- Donation tracking and delivery status
- Rating and review system
- Advanced filtering and search
- Analytics dashboard for NGOs
- Multi-language support

## Dependencies
- `firebase_core`: Firebase SDK
- `firebase_auth`: Authentication
- `firebase_database`: Realtime Database
- `image_picker`: Image selection (for future use)
- `cached_network_image`: Image caching (for future use)

## Contributing
1. Fork the repository
2. Create feature branch
3. Commit changes
4. Push to branch
5. Create Pull Request

## License
This project is licensed under the MIT License.
