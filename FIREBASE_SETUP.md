# Firebase Setup Guide for OnePlate

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Enter project name: `oneplate-app` (or your preferred name)
4. Enable Google Analytics (optional)
5. Click "Create project"

## Step 2: Enable Authentication

1. In Firebase Console, go to "Authentication"
2. Click "Get started"
3. Go to "Sign-in method" tab
4. Enable "Email/Password" provider
5. Save changes

## Step 3: Setup Realtime Database

1. In Firebase Console, go to "Realtime Database"
2. Click "Create Database"
3. Choose location (nearest to your users)
4. Start in "Test mode" for development
5. **IMPORTANT**: Update security rules immediately

### Database Security Rules (COPY THESE EXACT RULES):

Go to "Realtime Database" > "Rules" tab and replace with:

```json
{
  "rules": {
    "ngos": {
      "$uid": {
        ".read": "$uid === auth.uid",
        ".write": "$uid === auth.uid"
      }
    },
    "hotels": {
      "$uid": {
        ".read": "$uid === auth.uid",
        ".write": "$uid === auth.uid"
      }
    },
    "individuals": {
      "$uid": {
        ".read": "$uid === auth.uid",
        ".write": "$uid === auth.uid"
      }
    },
    "donation_requests": {
      ".read": "auth != null",
      "$request_id": {
        ".write": "auth != null && (!data.exists() || data.child('ngoId').val() === auth.uid)"
      }
    },
    "donations": {
      ".read": "auth != null",
      "$donation_id": {
        ".write": "auth != null && (!data.exists() || data.child('ngoId').val() === auth.uid || data.child('donorId').val() === auth.uid)"
      }
    }
  }
}
```

### Alternative Simple Rules for Testing Only:
If you're having permission issues, temporarily use these rules (NOT for production):

```json
{
  "rules": {
    ".read": "auth != null",
    ".write": "auth != null"
  }
}
```

## Step 4: Add App to Firebase Project

### For Web:
1. Click the web icon (</>) in project overview
2. Register app with nickname: "oneplate-web"
3. Copy the Firebase configuration
4. Replace the config in `lib/services/firebase_config.dart`

### For Android:
1. Click the Android icon in project overview
2. Enter package name: `com.example.oneplate`
3. Download `google-services.json`
4. Place it in `android/app/` directory
5. Follow the setup instructions

### For iOS:
1. Click the iOS icon in project overview
2. Enter bundle ID: `com.example.oneplate`
3. Download `GoogleService-Info.plist`
4. Add it to `ios/Runner/` directory
5. Follow the setup instructions

## Step 5: Update Firebase Configuration

Replace the configuration in `lib/services/firebase_config.dart` with your actual Firebase config:

```dart
import 'package:firebase_core/firebase_core.dart';

class FirebaseConfig {
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "your-api-key",
    authDomain: "your-project.firebaseapp.com",
    databaseURL: "https://your-project-default-rtdb.firebaseio.com",
    projectId: "your-project-id",
    storageBucket: "your-project.appspot.com",
    messagingSenderId: "your-sender-id",
    appId: "your-app-id",
  );
  
  // Add android and ios configurations as needed
}
```

## Step 6: Test the Setup

1. Run the app: `flutter run -d chrome`
2. Try registering a new user
3. Check Firebase Console:
   - Authentication > Users (should show new user)
   - Realtime Database > Data (should show user data)

## Troubleshooting

### Permission Denied Error Fix:

If you get `Client doesn't have permission to access the desired data`, follow these steps:

1. **Check Authentication**: 
   - User must be logged in before saving data
   - Check if `FirebaseAuth.instance.currentUser` is not null

2. **Update Database Rules**:
   - Go to Firebase Console > Realtime Database > Rules
   - Copy the rules from Step 3 above
   - Click "Publish" to apply changes

3. **Verify User Authentication**:
   - Check Firebase Console > Authentication > Users
   - Ensure the user is successfully created and logged in

4. **Database URL Check**:
   - Ensure your `databaseURL` in firebase_config.dart is correct
   - Format: `https://YOUR-PROJECT-DEFAULT-rtdb.firebaseio.com`

### Common Issues:

1. **Firebase not initialized**: Make sure Firebase.initializeApp() is called in main.dart
2. **CORS errors on web**: Firebase should handle this automatically
3. **Network errors**: Check your internet connection and Firebase project status
4. **Authentication errors**: Verify Email/Password is enabled in Firebase Console
5. **Database permission errors**: Update Realtime Database rules as shown above
6. **Invalid database URL**: Check if the URL matches your Firebase project

### Debug Steps for Permission Issues:

1. **Test Authentication First**:
   ```dart
   User? user = FirebaseAuth.instance.currentUser;
   print('Current user: ${user?.uid}');
   ```

2. **Check Database Rules**: 
   - Simple test rule: `".read": true, ".write": true` (ONLY for testing)
   - Revert to secure rules after testing

3. **Verify Firebase Config**:
   - Check if `databaseURL` is correct in your config
   - Ensure project ID matches your Firebase project

### Emergency Fix for Testing:
If nothing works, temporarily use these open rules for testing (MUST change for production):

```json
{
  "rules": {
    ".read": true,
    ".write": true
  }
}
```

Remember to revert to secure rules before deploying!

### Debug Mode:
Add this to see Firebase debug logs:
```dart
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: FirebaseConfig.web);
  runApp(OnePlateApp());
}
```

## Next Steps

Once setup is complete, you can:
1. Test user registration and login
2. Create donation requests as NGO
3. Browse requests as Hotel/Individual
4. Send and accept donations
5. View data in Firebase Console

Remember to update security rules for production!