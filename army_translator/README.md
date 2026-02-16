# ARMY Translator - Real-Time Korean Translation 🎤💜

A Flutter mobile application for real-time Korean to English translation, designed for BTS ARMY watching Weverse lives, YouTube videos, and fancams.

## Features

- **🎤 One-Tap Listening** - Instantly start translating Korean speech
- **💬 Real-Time Subtitles** - See translations as they happen
- **📚 BTS Dictionary** - Smart translations for "borahae", member names, ARMY slang
- **🎨 Member Detection** - Color-coded subtitles by speaker
- **📝 Session History** - Save and browse past translations
- **📤 Export Subtitles** - Export as .srt, .vtt, or text files
- **🌍 Multi-Language** - Translate to 11+ languages

## Tech Stack

- **Framework**: Flutter 3.x (Dart)
- **State Management**: Riverpod
- **Backend**: Firebase (Auth, Firestore)
- **Speech-to-Text**: OpenAI Whisper API
- **Translation**: Papago / DeepL / Google Translate
- **AI Polish**: OpenAI GPT-4o (optional premium feature)

## Getting Started

### Prerequisites

- Flutter SDK 3.2.0+
- Dart SDK 3.2.0+
- Firebase account
- OpenAI API key (for Whisper STT)

### Installation

1. **Navigate to project**
   ```bash
   cd army_translator
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create project at [Firebase Console](https://console.firebase.google.com)
   - Add `google-services.json` (Android)
   - Add `GoogleService-Info.plist` (iOS)
   - Enable Authentication and Firestore

4. **Run the app**
   ```bash
   flutter run
   ```

5. **Configure API keys** in Settings after launch

## Project Structure

```
lib/
├── main.dart                    # Entry point
├── app.dart                     # App configuration
├── config/
│   ├── theme.dart              # Dark theme optimized for subtitles
│   ├── routes.dart             # Navigation
│   ├── constants.dart          # App constants
│   └── bts_dictionary.dart     # Korean-English BTS terms
├── models/
│   ├── transcript_model.dart   # Individual transcript entry
│   ├── session_model.dart      # Translation session
│   └── subtitle_model.dart     # Subtitle display model
├── services/
│   ├── audio_service.dart      # Microphone capture
│   ├── speech_to_text_service.dart  # Whisper STT
│   ├── translation_service.dart     # Multi-provider translation
│   ├── gpt_polish_service.dart      # AI polishing
│   ├── firebase_service.dart        # Cloud storage
│   └── export_service.dart          # Subtitle export
├── providers/
│   ├── translation_provider.dart    # Translation state
│   └── settings_provider.dart       # App settings
├── screens/
│   ├── splash_screen.dart
│   ├── onboarding/
│   ├── home/
│   ├── live/                   # Real-time translation view
│   ├── history/
│   └── settings/
└── widgets/
    ├── listen_button.dart      # Main recording button
    ├── subtitle_display.dart   # Subtitle rendering
    ├── audio_waveform.dart     # Visual feedback
    └── member_selector.dart    # BTS member picker
```

## Translation Pipeline

```
Audio Input → Whisper STT (Korean) → Translation API → GPT Polish → Display
     ↓              ↓                     ↓               ↓           ↓
 Microphone    OpenAI API         Papago/DeepL/Google   GPT-4o   Subtitles
```

## API Configuration

### OpenAI (Whisper + GPT)
Required for speech-to-text. Add in Settings > OpenAI API Key.

### Papago (Recommended for Korean)
Best quality for Korean translations. Requires Naver Developer account.

### DeepL
High-quality translations. Requires DeepL API key.

### Google Translate
Free fallback option, no API key required.

## Export Formats

| Format | Extension | Description |
|--------|-----------|-------------|
| SRT | `.srt` | Standard subtitle format |
| VTT | `.vtt` | Web video subtitles |
| Text | `.txt` | Plain text with timestamps |
| Bilingual | `.txt` | Korean + English side by side |

## Premium Features ($4.99/mo)

- **GPT Polish** - Natural-sounding translations
- **Offline Mode** - Downloaded language packs
- **Unlimited History** - Cloud sync all sessions
- **Priority Processing** - Lower latency

## Performance Targets

| Metric | Target |
|--------|--------|
| Latency | <3 seconds |
| Accuracy | >90% clear speech |
| Battery | <15% per hour |

## Legal Disclaimer

> **Fan-made tool – not affiliated with BTS, HYBE, or Weverse.**  
> For personal entertainment use only.  
> Respect artist privacy and content rights.

## Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

---

Built with 💜 for ARMY who want to understand their favorite artists
