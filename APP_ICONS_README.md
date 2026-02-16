# App Icons for ARMY Apps 💜

## Icon Designs

### ARMY Hub (`army_hub/assets/icons/app_icon.svg`)
- Purple gradient background
- White heart shape (ARMY logo inspired)
- Bold "A" letter in purple
- Represents: Community, love, BTS connection

### ARMY Translator (`army_translator/assets/icons/app_icon.svg`)
- Purple gradient background  
- White microphone with purple grille lines
- Sound waves on both sides
- Represents: Voice, translation, listening

---

## Converting SVG to App Icons

### Option 1: Online Tools (Easiest)
1. Go to [AppIcon.co](https://appicon.co/) or [MakeAppIcon](https://makeappicon.com/)
2. Upload the SVG file
3. Download the generated icon pack
4. Place files in correct directories

### Option 2: Flutter Package
Add to `pubspec.yaml`:
```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1
```

Create `flutter_launcher_icons.yaml`:
```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icons/app_icon.png"
  adaptive_icon_background: "#A020F0"
  adaptive_icon_foreground: "assets/icons/app_icon_foreground.png"
```

Run:
```bash
flutter pub get
dart run flutter_launcher_icons
```

---

## Icon Placement

### Android
```
android/app/src/main/res/
├── mipmap-hdpi/ic_launcher.png (72x72)
├── mipmap-mdpi/ic_launcher.png (48x48)
├── mipmap-xhdpi/ic_launcher.png (96x96)
├── mipmap-xxhdpi/ic_launcher.png (144x144)
├── mipmap-xxxhdpi/ic_launcher.png (192x192)
```

### iOS
```
ios/Runner/Assets.xcassets/AppIcon.appiconset/
├── Icon-App-20x20@1x.png
├── Icon-App-20x20@2x.png
├── Icon-App-20x20@3x.png
├── Icon-App-29x29@1x.png
├── Icon-App-29x29@2x.png
├── Icon-App-29x29@3x.png
├── Icon-App-40x40@1x.png
├── Icon-App-40x40@2x.png
├── Icon-App-40x40@3x.png
├── Icon-App-60x60@2x.png
├── Icon-App-60x60@3x.png
├── Icon-App-76x76@1x.png
├── Icon-App-76x76@2x.png
├── Icon-App-83.5x83.5@2x.png
├── Icon-App-1024x1024@1x.png
```

---

## Color Palette

| Color | Hex | Usage |
|-------|-----|-------|
| Primary Purple | `#A020F0` | Main brand color |
| Deep Purple | `#6739C6` | Gradient mid |
| Royal Blue | `#4040BF` | Gradient end |
| White | `#FFFFFF` | Icons, text |

---

## Quick Setup Commands

```bash
# Navigate to project
cd army_hub
# OR
cd army_translator

# Add flutter_launcher_icons
flutter pub add --dev flutter_launcher_icons

# Generate icons (after adding PNG to assets/icons/)
dart run flutter_launcher_icons
```

---

Built with 💜 for ARMY
