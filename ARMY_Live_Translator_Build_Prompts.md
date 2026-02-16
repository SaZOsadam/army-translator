# ARMY Live Translator – BTS Real-Time Translation App

**Current Date Reference:** February 14, 2026  
**Purpose:** Shazam-style real-time Korean speech translator for BTS Weverse lives, YouTube videos, and fancams  
**Target Audience:** Global ARMY who don't speak Korean fluently

---

## Project Overview

**App Name:** ARMY Live Translator  
**Platform:** Cross-platform mobile (Flutter)  
**Backend:** Firebase (Auth, Firestore for history)  
**AI Integration:** OpenAI Whisper (STT) + Papago/DeepL/Google Translate + GPT-4o (polish)  
**Theme:** Purple (#A020F0 dominant), BT21-inspired, clean subtitle UI

---

## Tech Stack

| Layer | Technology |
|-------|------------|
| **Framework** | Flutter 3.x (Dart) |
| **State Management** | Riverpod |
| **Backend** | Firebase (Auth, Firestore) |
| **Speech-to-Text** | OpenAI Whisper API |
| **Translation** | Papago API (best for Korean) |
| **AI Polish** | OpenAI GPT-4o (natural ARMY-friendly translations) |
| **Audio Capture** | flutter_sound |
| **Storage** | Local + Cloud sync |

---

## Core Features

### 1. One-Tap Listening
- Large "Start Listening" button on home screen
- Instantly begins capturing audio from microphone
- Visual audio waveform indicator
- Low-latency processing (<3s target)

### 2. Real-Time Translation Flow
```
Audio Input → Speech-to-Text (Korean) → Translation (English) → GPT Polish → Display
```

### 3. Split-Screen Mode
- Top: Video player or audio waveform
- Bottom: Scrolling live subtitles
- Transparency/overlay options
- Picture-in-picture support

### 4. BTS Fandom Dictionary
Custom translations for BTS-specific terms:
| Korean | Standard | ARMY Translation |
|--------|----------|------------------|
| 형 (hyung) | older brother | hyung (keep as-is) |
| 막내 (maknae) | youngest | maknae |
| 아미 (ARMY) | Ami | ARMY (fandom) |
| 보라해 (borahae) | purple you | I purple you 💜 |
| 멤버 names | - | Keep stage names |
| 월드투어 | world tour | world tour |

### 5. Member Voice Detection (Optional)
- Manual bias selector to highlight lines
- Future: Voice fingerprinting for auto-detect
- Color-coded subtitles per member

### 6. Session History
- Save past translation sessions
- Browse by date/content
- Search within transcripts
- Export as .srt or .txt

### 7. Subtitle Export
- Export as .srt file for video editing
- Share as image for social media
- Copy full transcript to clipboard

---

## App Screens

```
lib/
├── main.dart
├── app.dart
├── config/
│   ├── theme.dart
│   ├── routes.dart
│   ├── constants.dart
│   └── bts_dictionary.dart
├── models/
│   ├── transcript_model.dart
│   ├── session_model.dart
│   ├── subtitle_model.dart
│   └── settings_model.dart
├── services/
│   ├── audio_service.dart
│   ├── speech_to_text_service.dart
│   ├── translation_service.dart
│   ├── gpt_polish_service.dart
│   ├── firebase_service.dart
│   └── export_service.dart
├── providers/
│   ├── audio_provider.dart
│   ├── translation_provider.dart
│   ├── session_provider.dart
│   └── settings_provider.dart
├── screens/
│   ├── splash_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── live/
│   │   ├── live_view_screen.dart
│   │   └── subtitle_overlay.dart
│   ├── history/
│   │   ├── history_screen.dart
│   │   └── session_detail_screen.dart
│   ├── settings/
│   │   └── settings_screen.dart
│   └── onboarding/
│       └── onboarding_screen.dart
├── widgets/
│   ├── listen_button.dart
│   ├── audio_waveform.dart
│   ├── subtitle_display.dart
│   ├── member_selector.dart
│   ├── language_selector.dart
│   └── export_dialog.dart
└── utils/
    ├── audio_helpers.dart
    ├── subtitle_formatter.dart
    └── time_helpers.dart
```

---

## Design Guidelines

### Color Palette
| Name | Hex | Usage |
|------|-----|-------|
| **Primary Purple** | `#A020F0` | Main accent, buttons |
| **Deep Purple** | `#6739C6` | Gradients |
| **Subtitle BG** | `#000000CC` | Semi-transparent subtitle background |
| **Text White** | `#FFFFFF` | Subtitle text |
| **Korean Text** | `#E0B0FF` | Original Korean (light purple) |
| **Confidence High** | `#4CAF50` | High accuracy indicator |
| **Confidence Low** | `#FFA726` | Low accuracy warning |

### UI Principles
- **Minimal**: Focus on subtitles, not UI chrome
- **Readable**: Large, clear subtitle text
- **Fast**: Instant visual feedback
- **Battery-aware**: Optimize for long streaming sessions

---

## Translation Pipeline

### Step 1: Audio Capture
```dart
// Capture audio from microphone in chunks
final audioStream = await AudioService.startCapture(
  sampleRate: 16000,
  channels: 1,
  chunkDuration: Duration(seconds: 3),
);
```

### Step 2: Speech-to-Text (Whisper)
```dart
final transcript = await WhisperService.transcribe(
  audioData: chunk,
  language: 'ko', // Korean
  prompt: 'BTS Weverse live, casual conversation',
);
```

### Step 3: Translation
```dart
final translated = await TranslationService.translate(
  text: transcript.text,
  from: 'ko',
  to: userLanguage,
  dictionary: BTSDictionary.terms,
);
```

### Step 4: GPT Polish (Optional Premium)
```dart
final polished = await GPTService.polish(
  text: translated,
  context: 'BTS member speaking casually to ARMY',
  style: 'natural, friendly, keep Korean honorifics',
);
```

---

## API Configuration

### OpenAI Whisper
```dart
class WhisperService {
  static const apiUrl = 'https://api.openai.com/v1/audio/transcriptions';
  
  Future<String> transcribe(Uint8List audio) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Authorization': 'Bearer $apiKey'},
      body: {
        'file': audio,
        'model': 'whisper-1',
        'language': 'ko',
        'response_format': 'json',
      },
    );
    return jsonDecode(response.body)['text'];
  }
}
```

### Papago Translation (Recommended for Korean)
```dart
class PapagoService {
  static const apiUrl = 'https://openapi.naver.com/v1/papago/n2mt';
  
  Future<String> translate(String text, String targetLang) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'X-Naver-Client-Id': clientId,
        'X-Naver-Client-Secret': clientSecret,
      },
      body: {
        'source': 'ko',
        'target': targetLang,
        'text': text,
      },
    );
    return jsonDecode(response.body)['message']['result']['translatedText'];
  }
}
```

---

## Firebase Schema

### Sessions Collection
```json
{
  "id": "string",
  "userId": "string",
  "title": "string",
  "startTime": "timestamp",
  "endTime": "timestamp",
  "duration": "number (seconds)",
  "transcriptCount": "number",
  "sourceLanguage": "ko",
  "targetLanguage": "en"
}
```

### Transcripts Subcollection
```json
{
  "id": "string",
  "sessionId": "string",
  "timestamp": "timestamp",
  "originalText": "string (Korean)",
  "translatedText": "string",
  "confidence": "number (0-1)",
  "speaker": "string (member name, optional)",
  "startMs": "number",
  "endMs": "number"
}
```

---

## Premium Features ($4.99/mo)

- **Ad-free** experience
- **GPT Polish** for natural translations
- **Offline mode** with downloaded language packs
- **Voice dubbing simulation** (TTS with member-like voices)
- **Unlimited history** storage
- **Priority processing** for lower latency

---

## Legal Disclaimer

> **Fan-made tool – not official HYBE/Weverse app.**  
> Audio captured from public sources only.  
> For personal entertainment use.  
> Respect artist privacy and content rights.

---

## Performance Targets

| Metric | Target |
|--------|--------|
| **Latency** | <3 seconds end-to-end |
| **Accuracy** | >90% for clear speech |
| **Battery** | <15% per hour of use |
| **Data** | ~5MB per minute of audio |

---

## Next Steps

1. ✅ Documentation complete
2. 🔄 Set up Flutter project
3. ⏳ Implement audio capture
4. ⏳ Integrate Whisper STT
5. ⏳ Add translation pipeline
6. ⏳ Build UI screens
7. ⏳ Test with real Weverse content
8. ⏳ Deploy beta

---

*Built with 💜 for ARMY who want to understand their favorite artists*
