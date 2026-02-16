# Flutter Setup Guide for Windows 💜

## Step 1: Download Flutter SDK

1. Go to: https://docs.flutter.dev/get-started/install/windows
2. Click **"Download Flutter SDK"** (flutter_windows_3.x.x-stable.zip)
3. Extract to: `C:\flutter` (NOT in Program Files - avoid spaces in path)

---

## Step 2: Add Flutter to PATH

### Option A: Using PowerShell (Temporary)
```powershell
$env:Path += ";C:\flutter\bin"
```

### Option B: Permanent (Recommended)
1. Press `Win + R`, type `sysdm.cpl`, press Enter
2. Click **Advanced** tab → **Environment Variables**
3. Under "User variables", find **Path** → Click **Edit**
4. Click **New** → Add: `C:\flutter\bin`
5. Click **OK** on all dialogs
6. **Restart your terminal/IDE**

---

## Step 3: Install Git (Required)

Flutter needs Git. Download from: https://git-scm.com/download/win

---

## Step 4: Verify Installation

Open a **new** terminal and run:
```powershell
flutter --version
```

You should see:
```
Flutter 3.x.x • channel stable
```

---

## Step 5: Run Flutter Doctor

```powershell
flutter doctor
```

This checks your setup. You'll likely see:
- ✅ Flutter
- ❌ Android toolchain (need Android Studio)
- ❌ Chrome (optional, for web)
- ❌ Visual Studio (optional, for Windows apps)

---

## Step 6: Install Android Studio

1. Download: https://developer.android.com/studio
2. Install with default settings
3. Open Android Studio → **More Actions** → **SDK Manager**
4. Install:
   - Android SDK
   - Android SDK Command-line Tools
   - Android SDK Build-Tools
5. Go to **More Actions** → **Virtual Device Manager**
6. Create a virtual device (e.g., Pixel 7, API 34)

---

## Step 7: Accept Android Licenses

```powershell
flutter doctor --android-licenses
```
Type `y` to accept all.

---

## Step 8: Final Check

```powershell
flutter doctor
```

You need at least:
```
[✓] Flutter
[✓] Android toolchain
[✓] Android Studio
```

---

## Step 9: Run Your Apps!

```powershell
# Navigate to project
cd "C:\Users\SARAH875\Comeback Project\army_hub"

# Get dependencies
flutter pub get

# Generate icons
dart run flutter_launcher_icons

# Run app (with emulator open)
flutter run
```

---

## Quick Reference

| Command | Description |
|---------|-------------|
| `flutter --version` | Check Flutter version |
| `flutter doctor` | Diagnose setup issues |
| `flutter pub get` | Install dependencies |
| `flutter run` | Run app on connected device/emulator |
| `flutter build apk` | Build Android APK |
| `flutter build ios` | Build iOS (requires Mac) |

---

## Troubleshooting

### "flutter is not recognized"
→ PATH not set correctly. Restart terminal after adding to PATH.

### "No connected devices"
→ Open Android Studio → Virtual Device Manager → Start an emulator

### "Android SDK not found"
→ Run: `flutter config --android-sdk "C:\Users\YOUR_NAME\AppData\Local\Android\Sdk"`

---

## Estimated Setup Time: 30-45 minutes

Once Flutter is installed, your ARMY apps are ready to build! 💜
