# 🍽️ OnePlate - Food Donation Platform

A Flutter mobile application connecting food donors (hotels and individuals) with NGOs to reduce food waste and help those in need.

## 📱 About OnePlate

OnePlate is a comprehensive food donation platform that bridges the gap between food surplus and food scarcity. The app enables hotels and individuals to donate excess food to NGOs, who can then distribute it to those in need.

## ✨ Features

### 🏨 For Hotels
- Create and manage food donations
- View NGO food requests
- Track donation history
- Real-time response notifications
- Profile management with verification badges

### 🧑 For Individuals
- Donate surplus food from home
- Browse NGO requests
- View donation history
- Simple and intuitive interface

### 🏢 For NGOs
- Browse available food donations nearby
- Create food requests specifying requirements
- Accept and confirm donations
- Track donation history
- Manage organization profile

## 🎨 Design

- **Clean UI**: Simple, modern interface with purple theme (#6C63FF)
- **Intuitive Navigation**: Easy-to-use bottom navigation
- **Responsive Design**: Works seamlessly across different screen sizes
- **Real-time Updates**: Live data synchronization with Firebase

## 🛠️ Tech Stack

- **Framework**: Flutter/Dart
- **Backend**: Firebase
  - Authentication
  - Realtime Database
  - Cloud Storage (for profile pictures)
- **State Management**: StatefulWidget
- **Image Handling**: image_picker package

## 📋 Prerequisites

- Flutter SDK (3.0+)
- Dart SDK (3.0+)
- Firebase account
- Android Studio / Xcode (for mobile development)
- Git

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/Mohitvaishnva/oneplate.git
cd oneplate
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Firebase Setup

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add Android/iOS apps to your Firebase project
3. Download and add configuration files:
   - `google-services.json` (Android) → `android/app/`
   - `GoogleService-Info.plist` (iOS) → `ios/Runner/`
4. Enable Firebase Authentication (Email/Password)
5. Enable Firebase Realtime Database

### 4. Deploy Firebase Rules

**Important**: You must deploy the Firebase rules for the app to work properly.

#### Option 1: Firebase Console (Recommended)
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Navigate to **Realtime Database** → **Rules**
4. Copy the contents from `firebase_rules.json`
5. Paste into the rules editor
6. Click **Publish**

#### Option 2: Firebase CLI
```bash
firebase deploy --only database
```

### 5. Run the App

```bash
flutter run
```

## 📁 Project Structure

```
lib/
├── components/        # Reusable UI components
├── models/           # Data models
├── screens/          # All app screens
│   ├── commonscreens/   # Login, Welcome
│   ├── hotelscreens/    # Hotel-specific screens
│   ├── individualscreens/ # Individual user screens
│   └── ngoscreens/      # NGO-specific screens
├── services/         # Firebase and other services
├── utils/           # Utilities and helpers
├── widgets/         # Custom widgets
└── main.dart        # App entry point
```

## 🗄️ Database Schema

### Collections
- **users**: Base user information
- **hotels**: Hotel-specific data
- **individuals**: Individual user data
- **ngos**: NGO organization data
- **donations**: Food donations created by hotels/individuals
- **donation_requests**: Food requests created by NGOs

## 🔐 Firebase Security Rules

The app uses comprehensive security rules to ensure:
- Authenticated users can read public data
- Users can only modify their own data
- Proper validation of donation and request data
- Database indexes for optimized queries

## 📸 Screenshots

[Add screenshots here]

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👨‍💻 Developer

**Mohit Vaishnav**
- GitHub: [@Mohitvaishnva](https://github.com/Mohitvaishnva)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend infrastructure
- All contributors who help make this project better

## 📞 Support

For support, please open an issue in the GitHub repository or contact the developer.

---

**Made with ❤️ to reduce food waste and help those in need**
