# Deploy Firebase Rules

## Updated Rules
I've updated the Firebase Realtime Database rules to allow NGOs to read donor information.

### Changes Made:
- ✅ **users**: Changed from `"$userId === auth.uid"` to `"auth != null"` (read permission)
- ✅ **ngos**: Changed from `"$userId === auth.uid"` to `"auth != null"` (read permission)
- ✅ **hotels**: Changed from `"$userId === auth.uid"` to `"auth != null"` (read permission)
- ✅ **individuals**: Changed from `"$userId === auth.uid"` to `"auth != null"` (read permission)

This allows any authenticated user (including NGOs) to read donor profiles while maintaining write restrictions.

## How to Deploy

### Option 1: Using Firebase Console (Easiest)
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project "OnePlate"
3. Click on **Realtime Database** in the left sidebar
4. Click on the **Rules** tab
5. Copy the contents of `firebase_rules.json` from this project
6. Paste it into the Firebase Console rules editor
7. Click **Publish** button

### Option 2: Using Firebase CLI
```bash
# Install Firebase CLI if not already installed
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase in your project (if not done)
firebase init database

# Deploy the rules
firebase deploy --only database
```

## Verify Rules are Working
After deploying, restart your app and try to:
1. Login as NGO
2. View available donations
3. Click on a donation to see donor details

The permission error should be gone! ✅

## Security Notes
- ✅ All users must be authenticated to read data
- ✅ Users can only write to their own profiles
- ✅ NGOs can read donor information to facilitate donations
- ✅ Donations are readable by all authenticated users
