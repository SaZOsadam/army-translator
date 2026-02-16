# ARMY Hub - BTS Comeback AI App 💜

A Flutter mobile application for BTS ARMY fans during the ARIRANG comeback era (March 20, 2026).

## Features

- **🔮 AI Theory Generator** - Generate ARMY-style theories using OpenAI GPT-4o
- **⏰ Live Countdown** - Real-time countdown to album release and tour dates
- **📊 Prediction Polls** - Vote on comeback predictions with the community
- **💜 Bias Personalization** - Customize your experience based on your favorite member
- **🏆 Leaderboards** - Compete with other ARMY theorists
- **🔔 Push Notifications** - Never miss a teaser or release

## Tech Stack

- **Framework**: Flutter 3.x (Dart)
- **State Management**: Riverpod
- **Backend**: Firebase (Auth, Firestore, Cloud Messaging)
- **AI**: OpenAI GPT-4o API
- **Authentication**: Google Sign-In, Apple Sign-In, Email/Password

## Getting Started

### Prerequisites

- Flutter SDK 3.2.0 or higher
- Dart SDK 3.2.0 or higher
- Firebase account
- OpenAI API key

### Installation

1. **Clone the repository**
   ```bash
   cd army_hub
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Add Android and iOS apps
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place them in the appropriate directories:
     - Android: `android/app/google-services.json`
     - iOS: `ios/Runner/GoogleService-Info.plist`

4. **Enable Firebase services**
   - Authentication (Google, Apple, Email/Password)
   - Cloud Firestore
   - Cloud Messaging

5. **Run the app**
   ```bash
   flutter run
   ```

### OpenAI API Key

The app requires an OpenAI API key for AI theory generation:

1. Get your API key from [OpenAI Platform](https://platform.openai.com/api-keys)
2. In the app, go to **Settings > OpenAI API Key**
3. Enter your API key (stored securely on device)

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── app.dart                  # App configuration
├── config/
│   ├── theme.dart           # Purple BTS theme
│   ├── routes.dart          # Navigation routes
│   └── constants.dart       # App constants
├── models/
│   ├── user_model.dart      # User data model
│   ├── theory_model.dart    # Theory data model
│   └── poll_model.dart      # Poll data model
├── services/
│   ├── auth_service.dart    # Authentication
│   ├── openai_service.dart  # OpenAI integration
│   ├── firebase_service.dart # Firestore operations
│   └── notification_service.dart # Push notifications
├── providers/
│   ├── auth_provider.dart   # Auth state
│   ├── theory_provider.dart # Theory state
│   ├── countdown_provider.dart # Countdown state
│   └── user_provider.dart   # User preferences
├── screens/
│   ├── splash_screen.dart
│   ├── onboarding/
│   ├── auth/
│   ├── home/
│   ├── countdown/
│   ├── theory/
│   ├── polls/
│   ├── profile/
│   └── settings/
├── widgets/
│   ├── countdown_timer.dart
│   ├── gradient_button.dart
│   ├── bias_avatar.dart
│   ├── theory_card.dart
│   ├── poll_card.dart
│   └── loading_animation.dart
└── utils/
    ├── helpers.dart
    └── validators.dart
```

## Firestore Schema

### Users Collection
```json
{
  "uid": "string",
  "email": "string",
  "displayName": "string",
  "bias": "RM | Jin | SUGA | J-Hope | Jimin | V | Jungkook | OT7",
  "language": "string",
  "isPremium": "boolean",
  "theoriesGenerated": "number"
}
```

### Theories Collection
```json
{
  "userId": "string",
  "input": "string",
  "output": "string",
  "bias": "string",
  "createdAt": "timestamp",
  "likes": "number",
  "shares": "number"
}
```

### Polls Collection
```json
{
  "question": "string",
  "options": [{ "id": "string", "text": "string", "votes": "number" }],
  "totalVotes": "number",
  "status": "active | closed"
}
```

## Building for Production

### Android
```bash
flutter build apk --release
# or for app bundle
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## Premium Features ($4.99/mo)

- Ad-free experience
- Extended AI theory insights
- Exclusive prediction pools
- Custom wallpaper generator
- Priority support

## Legal Disclaimer

> **Fan-made, unofficial app.**  
> Not affiliated with BTS, HYBE, or BigHit Music.  
> For entertainment purposes only.  
> All BTS-related content belongs to respective owners.

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Support

- 💜 [Love Myself Campaign](https://www.love-myself.org/)
- 🦋 [UNICEF](https://www.unicef.org/)

## License

This project is for educational and fan purposes only.

---

Built with 💜 for ARMY
