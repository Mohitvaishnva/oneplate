# 🔥 Firebase Setup Guide - Fix Permission Errors

## 🚨 CRITICAL: Your Firebase rules are NOT applied correctly!

The logs show permission denied errors for both direct database writes and service calls, which means the Firebase security rules haven't been properly updated in your Firebase Console.

## Step 1: Apply Firebase Security Rules

1. **Open Firebase Console**: https://console.firebase.google.com
2. **Select your project**: `oneplate` (or whatever your project is named)
3. **Go to Realtime Database** in the left sidebar
4. **Click on "Rules" tab**
5. **Replace ALL existing rules** with these:

```json
{
  "rules": {
    ".read": false,
    ".write": false,
    
    "users": {
      "$uid": {
        ".read": "$uid === auth.uid",
        ".write": "$uid === auth.uid"
      }
    },
    
    "ngos": {
      ".read": "auth != null",
      ".write": "auth != null"
    },
    
    "hotels": {
      ".read": "auth != null", 
      ".write": "auth != null"
    },
    
    "donations": {
      ".read": "auth != null",
      ".write": "auth != null",
      ".indexOn": ["hotelId", "expiryTime", "status"]
    },
    
    "donation_requests": {
      ".read": "auth != null",
      ".write": "auth != null", 
      ".indexOn": ["hotelId", "ngoId", "requestTime", "status"]
    },
    
    "donation_acceptances": {
      ".read": "auth != null",
      ".write": "auth != null",
      ".indexOn": ["donationId", "ngoId", "acceptanceTime"]
    }
  }
}
```

6. **Click "Publish"** button
7. **Wait 10-15 seconds** for rules to propagate

## Step 2: Verify Authentication

Make sure you're properly signed in:

1. **Check Authentication tab** in Firebase Console
2. **Verify your test users exist**:
   - `mohitsk@gmail.com` (Hotel user)
   - `mohit@gmail.com` (NGO user)
3. **Enable Email/Password authentication** if not already enabled

## Step 3: Test Database Access

After applying rules, test in Firebase Console:

1. **Go to Realtime Database > Data tab**
2. **Try to manually add data** to test write permissions
3. **Create test paths**:
   ```
   /donations/test123
   /donation_requests/test456
   ```

## Step 4: Verify in Your App

After applying rules correctly:

1. **Hot restart your Flutter app** (not just hot reload)
2. **Login with test credentials**
3. **Try creating a donation request**
4. **Check for successful database writes**

## 🔍 Debugging Tips

If still getting permission errors:

### Check Current User
Add this debug code to see who's authenticated:
```dart
print('Current user: ${FirebaseAuth.instance.currentUser?.uid}');
print('User email: ${FirebaseAuth.instance.currentUser?.email}');
```

### Verify Database Path
Check the exact paths being used:
```dart
print('Writing to path: ${DatabasePaths.donationRequests}');
```

### Test Simple Write
Try a simple write first:
```dart
await FirebaseDatabase.instance.ref().child('test').set({'hello': 'world'});
```

## 🚨 Common Issues

1. **Rules not published**: Make sure you clicked "Publish" button
2. **Cache issue**: Wait 10-15 seconds after publishing rules
3. **Wrong project**: Verify you're editing the correct Firebase project
4. **Authentication issue**: User must be signed in for rules to work
5. **Path mismatch**: Ensure database paths match rule paths exactly

## ✅ Success Indicators

You'll know it's working when:
- No more `Permission denied` errors in logs
- Donations appear in NGO home screen
- Database writes complete successfully
- Firebase Console shows new data entries

---

**Next Steps**: After applying rules correctly, we can restore the proper Firebase service usage and remove the direct database write workaround.