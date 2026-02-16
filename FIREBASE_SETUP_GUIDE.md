# Firebase Setup Guide for ARMY Apps 🔥

Complete guide to configure Firebase for both ARMY Hub and ARMY Translator.

---

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Create a project"**
3. Enter project name: `army-apps` (or your choice)
4. Enable Google Analytics (optional)
5. Click **Create project**

---

## Step 2: Add Android App

### 2.1 Register Android App

1. In Firebase Console, click **"Add app"** → **Android icon**
2. Enter package name:
   - ARMY Hub: `com.armyapps.armyhub`
   - ARMY Translator: `com.armyapps.armytranslator`
3. App nickname: `ARMY Hub` or `ARMY Translator`
4. Click **Register app**

### 2.2 Download Config File

1. Download `google-services.json`
2. Place it in:
   ```
   army_hub/android/app/google-services.json
   army_translator/android/app/google-services.json
   ```

### 2.3 Update Android Files

**`android/build.gradle`** (project level):
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

**`android/app/build.gradle`** (app level):
```gradle
plugins {
    id 'com.google.gms.google-services'
}

android {
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
}
```

---

## Step 3: Add iOS App (Optional)

### 3.1 Register iOS App

1. Click **"Add app"** → **iOS icon**
2. Enter bundle ID:
   - ARMY Hub: `com.armyapps.armyhub`
   - ARMY Translator: `com.armyapps.armytranslator`
3. Click **Register app**

### 3.2 Download Config File

1. Download `GoogleService-Info.plist`
2. Place it in:
   ```
   army_hub/ios/Runner/GoogleService-Info.plist
   army_translator/ios/Runner/GoogleService-Info.plist
   ```

### 3.3 Open in Xcode

```bash
cd army_hub/ios
open Runner.xcworkspace
```

Drag `GoogleService-Info.plist` into Runner folder in Xcode.

---

## Step 4: Enable Firebase Services

### 4.1 Authentication

1. Go to **Authentication** in Firebase Console
2. Click **Get started**
3. Enable sign-in methods:
   - ✅ Email/Password
   - ✅ Google
   - ✅ Anonymous (optional)

### 4.2 Firestore Database

1. Go to **Firestore Database**
2. Click **Create database**
3. Choose **Start in test mode** (for development)
4. Select region closest to your users

### 4.3 Security Rules (Production)

Replace default rules with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Sessions belong to users
    match /sessions/{sessionId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
      allow create: if request.auth != null;
    }
    
    // Transcripts under sessions
    match /sessions/{sessionId}/transcripts/{transcriptId} {
      allow read, write: if request.auth != null;
    }
    
    // Theories - public read, authenticated write
    match /theories/{theoryId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // Polls - public read, authenticated vote
    match /polls/{pollId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

---

## Step 5: Firestore Data Structure

### ARMY Translator Collections

```
📁 users/
   └── {userId}/
       ├── email: string
       ├── displayName: string
       ├── createdAt: timestamp
       └── preferences: map

📁 sessions/
   └── {sessionId}/
       ├── userId: string
       ├── title: string
       ├── startTime: timestamp
       ├── endTime: timestamp
       ├── duration: number (seconds)
       ├── transcriptCount: number
       └── 📁 transcripts/
           └── {transcriptId}/
               ├── originalText: string
               ├── translatedText: string
               ├── startMs: number
               ├── endMs: number
               ├── confidence: number
               └── speaker: string (optional)
```

### ARMY Hub Collections

```
📁 users/
   └── {userId}/
       ├── email: string
       ├── displayName: string
       ├── bias: string
       ├── isPremium: bool
       ├── points: number
       └── createdAt: timestamp

📁 theories/
   └── {theoryId}/
       ├── userId: string
       ├── prompt: string
       ├── output: string
       ├── bias: string
       ├── likes: number
       ├── isPublic: bool
       └── createdAt: timestamp

📁 polls/
   └── {pollId}/
       ├── question: string
       ├── options: array
       ├── votes: map
       ├── totalVotes: number
       ├── endsAt: timestamp
       └── createdAt: timestamp

📁 dailyMessages/
   └── {date}/
       ├── message: string
       ├── bias: string
       └── createdAt: timestamp
```

---

## Step 6: Environment Variables (Optional)

Create `.env` file (add to .gitignore):

```env
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_API_KEY=your-api-key
OPENAI_API_KEY=your-openai-key
```

---

## Step 7: Test Connection

Run the app and check for Firebase initialization:

```bash
cd army_hub
flutter run
```

Check debug console for:
```
✓ Firebase initialized successfully
```

---

## Troubleshooting

### "No Firebase App" Error
- Ensure `google-services.json` is in correct location
- Run `flutter clean && flutter pub get`

### "Permission Denied" Error
- Check Firestore security rules
- Ensure user is authenticated

### Google Sign-In Not Working
- Add SHA-1 fingerprint in Firebase Console
- Get SHA-1: `cd android && ./gradlew signingReport`

### iOS Build Fails
- Run `cd ios && pod install`
- Open Xcode and check `GoogleService-Info.plist` is added

---

## Quick Checklist

- [ ] Created Firebase project
- [ ] Added Android app
- [ ] Downloaded `google-services.json`
- [ ] Placed config in `android/app/`
- [ ] Updated `build.gradle` files
- [ ] Enabled Authentication
- [ ] Created Firestore database
- [ ] Set security rules
- [ ] (iOS) Added `GoogleService-Info.plist`
- [ ] Tested with `flutter run`

---

## Need Help?

- [Firebase Flutter Docs](https://firebase.flutter.dev/)
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/)
- [Firebase Console](https://console.firebase.google.com/)

---

Built with 💜 for ARMY
