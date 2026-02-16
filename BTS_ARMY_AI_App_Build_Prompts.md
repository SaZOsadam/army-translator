# ARMY Comeback Hub – BTS AI App Build Guide

**Current Date Reference:** February 14, 2026  
**BTS Momentum:** *ARIRANG* album release March 20, 2026 + World Tour  
**Target Audience:** Global ARMY (18-55, multilingual, high engagement)

---

## Project Overview

**App Name:** ARMY Hub – BTS Comeback AI  
**Platform:** Cross-platform mobile (Flutter)  
**Backend:** Firebase (Auth, Firestore, Cloud Messaging)  
**AI Integration:** OpenAI GPT-4o  
**Theme:** Purple (#A020F0 dominant), BT21-inspired, hearts, lightstick motifs

---

## Tech Stack

| Layer | Technology |
|-------|------------|
| **Framework** | Flutter 3.x (Dart) |
| **State Management** | Riverpod |
| **Backend** | Firebase (Auth, Firestore, Cloud Functions) |
| **AI** | OpenAI GPT-4o API |
| **Push Notifications** | Firebase Cloud Messaging |
| **Monetization** | Stripe / RevenueCat |
| **Analytics** | Firebase Analytics |

---

## Core Features

### 1. User Onboarding
- Sign up/login via Google, Apple, or Email
- Bias selection: RM, Jin, SUGA, J-Hope, Jimin, V, Jungkook, or OT7
- Language preference: English (default), Korean, Spanish, Japanese, etc.
- Optional Weverse deep link integration

### 2. Home Screen
- Daily personalized AI message based on different team member(RM, Jin, SUGA, J-Hope, Jimin, V, Jungkook)
- Example: *"Hey ARMY! Today's ARIRANG theory: Jungkook might drop a rock-infused solo hint based on the red circle teaser 🔴"*
- Quick access to all features
- Real-time notification badges

### 3. Countdown Timer
- Live countdown to **March 20, 2026** album drop
- Tour date countdowns (user selectable)
- Push notification reminders at milestones (1 week, 1 day, 1 hour)
- Animated celebration effects on release

### 4. AI Theory Generator
- User inputs: teaser descriptions, symbols, past lyrics, images
- OpenAI generates ARMY-style theories with prompt:
  ```
  "Act as an excited BTS ARMY theorist. Generate fun, cute, and supportive 
  theories about the ARIRANG comeback. Use ARMY slang, reference member 
  dynamics, and keep the tone enthusiastic. Include emojis."
  ```
- Bias role predictions
- Tracklist guesses
- Save and share theories

### 5. Community Prediction Polls
- Simple polls: *"Will ARIRANG have a retro title track? Yes/No"*
- Leaderboards for accurate predictions
- Virtual badges and rewards
- Weekly featured predictions

### 6. Personalized Content
- Bias-specific wallpapers (AI-generated or curated)
- Custom playlist recommendations based on predicted album vibes
- User profile with prediction history
- Achievement badges

### 7. Push Notifications
- New teaser drops
- Daily AI message
- Prediction results
- Countdown milestones

### 8. Premium Tier ($4.99/mo)
- Ad-free experience
- Deeper AI insights and extended theories
- Exclusive prediction pools
- Custom merch generator (AI wallpaper with bias + ARIRANG motif)
- Early access to features

---

## App Screens

```
lib/
├── main.dart
├── app.dart
├── config/
│   ├── theme.dart
│   ├── routes.dart
│   └── constants.dart
├── models/
│   ├── user_model.dart
│   ├── theory_model.dart
│   ├── poll_model.dart
│   └── countdown_model.dart
├── services/
│   ├── auth_service.dart
│   ├── openai_service.dart
│   ├── firebase_service.dart
│   └── notification_service.dart
├── providers/
│   ├── auth_provider.dart
│   ├── user_provider.dart
│   ├── theory_provider.dart
│   └── countdown_provider.dart
├── screens/
│   ├── splash_screen.dart
│   ├── onboarding/
│   │   ├── onboarding_screen.dart
│   │   ├── bias_selection_screen.dart
│   │   └── language_selection_screen.dart
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── signup_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── countdown/
│   │   └── countdown_screen.dart
│   ├── theory/
│   │   ├── theory_generator_screen.dart
│   │   └── theory_detail_screen.dart
│   ├── polls/
│   │   ├── polls_screen.dart
│   │   └── poll_detail_screen.dart
│   ├── profile/
│   │   └── profile_screen.dart
│   └── settings/
│       └── settings_screen.dart
├── widgets/
│   ├── countdown_timer.dart
│   ├── bias_avatar.dart
│   ├── theory_card.dart
│   ├── poll_card.dart
│   ├── gradient_button.dart
│   └── loading_animation.dart
└── utils/
    ├── helpers.dart
    └── validators.dart
```

---

## Design Guidelines

### Color Palette
| Name | Hex | Usage |
|------|-----|-------|
| **Primary Purple** | `#A020F0` | Main accent, buttons, highlights |
| **Deep Purple** | `#6739C6` | Gradients, headers |
| **Royal Blue** | `#4040BF` | Secondary accents |
| **Dark BG** | `#0D0D0D` | Dark mode background |
| **Light BG** | `#FAFAFA` | Light mode background |
| **Gold** | `#FFD400` | Premium badges, achievements |
| **White** | `#FFFFFF` | Text, cards |

### Typography
- **Headers:** Bold, playful (consider custom BTS-inspired font)
- **Body:** Clean sans-serif (Pretendard, Noto Sans)
- **Accent:** Rounded for cute elements

### UI Elements
- Rounded corners (16px default)
- Soft shadows
- BT21 character-inspired loading animations
- ARMY Bomb (lightstick) motifs
- Heart iconography
- Smooth page transitions

---

## OpenAI Integration

### API Configuration
```dart
// lib/services/openai_service.dart
class OpenAIService {
  static const String apiUrl = 'https://api.openai.com/v1/chat/completions';
  
  Future<String> generateTheory({
    required String userInput,
    required String bias,
  }) async {
    final systemPrompt = '''
You are an enthusiastic BTS ARMY theorist helping fans decode teasers 
and predict details about the ARIRANG comeback (March 20, 2026).

Guidelines:
- Use ARMY slang naturally (bias, maknae, hyung line, vocal line, etc.)
- Reference BTS history and member dynamics
- Keep tone excited, supportive, and fun
- Include relevant emojis 💜🔮✨
- If bias is specified, include ${bias}-centric predictions
- Be creative but grounded in actual BTS patterns
''';
    
    // API call implementation
  }
}
```

### Theory Generation Prompt Template
```
User Input: [teaser description/symbols]
Bias Focus: [selected member or OT7]

Generate:
1. Main theory (2-3 paragraphs)
2. Supporting evidence from past BTS content
3. Bold prediction for the album
4. Fun conspiracy bonus
```

---

## Firebase Schema

### Users Collection
```json
{
  "uid": "string",
  "email": "string",
  "displayName": "string",
  "bias": "string (RM|Jin|SUGA|J-Hope|Jimin|V|Jungkook|OT7)",
  "language": "string",
  "isPremium": "boolean",
  "createdAt": "timestamp",
  "predictions": ["array of prediction IDs"],
  "badges": ["array of badge IDs"],
  "theoriesGenerated": "number"
}
```

### Theories Collection
```json
{
  "id": "string",
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
  "id": "string",
  "question": "string",
  "options": ["array of option objects"],
  "createdAt": "timestamp",
  "endsAt": "timestamp",
  "totalVotes": "number",
  "status": "string (active|closed)"
}
```

---

## Deployment Checklist

- [ ] Set up Firebase project
- [ ] Configure OpenAI API key (secure storage)
- [ ] Test on iOS and Android devices
- [ ] Set up Stripe/RevenueCat for premium
- [ ] Configure push notifications
- [ ] Add analytics events
- [ ] Create App Store / Play Store listings
- [ ] Add legal disclaimer splash screen

---

## Legal Disclaimer

> **Fan-made, unofficial app.**  
> Not affiliated with BTS, HYBE, or BigHit Music.  
> For entertainment purposes only.  
> All BTS-related content belongs to respective owners.

---

## Marketing Ideas

1. TikTok demos: *"Watch AI predict the next BTS theory!"*
2. X/Twitter threads with generated theories
3. Partner with ARMY fan accounts
4. Reddit r/bangtan promotion
5. Weverse community engagement

---

## Next Steps

1. ✅ Documentation complete
2. 🔄 Set up Flutter project
3. ⏳ Implement core screens
4. ⏳ Integrate OpenAI
5. ⏳ Add Firebase backend
6. ⏳ Test MVP with ARMY testers
7. ⏳ Deploy beta

---

*Built with 💜 for ARMY*
