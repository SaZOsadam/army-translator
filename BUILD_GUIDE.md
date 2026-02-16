# Build Guide - ARMY Apps

## Cloud Build with GitHub Actions

### Setup Steps:

1. **Create GitHub Repository**
   ```bash
   cd "Comeback Project"
   git init
   git add .
   git commit -m "Initial commit - Supabase migration complete"
   ```

2. **Push to GitHub**
   - Create a new repo at https://github.com/new
   - Name it `army-apps` or similar
   ```bash
   git remote add origin https://github.com/YOUR_USERNAME/army-apps.git
   git branch -M main
   git push -u origin main
   ```

3. **Trigger Build**
   - Go to your repo → Actions tab
   - The build will start automatically on push
   - Or click "Run workflow" to trigger manually

4. **Download APK**
   - After build completes, go to Actions → Latest run
   - Download artifacts: `army-hub-apk` or `army-translator-apk`

---

## Build Outputs

| App | Artifact Name | File |
|-----|---------------|------|
| ARMY Hub | army-hub-apk | app-release.apk |
| ARMY Translator | army-translator-apk | app-release.apk |
| ARMY Hub Web | army-hub-web | build/web folder |
| ARMY Translator Web | army-translator-web | build/web folder |

---

## Environment Variables (Optional)

For production builds, add these secrets in GitHub:
- `Repository Settings` → `Secrets and variables` → `Actions`

| Secret | Description |
|--------|-------------|
| KEYSTORE_BASE64 | Android signing keystore (base64 encoded) |
| KEYSTORE_PASSWORD | Keystore password |
| KEY_ALIAS | Key alias |
| KEY_PASSWORD | Key password |

---

## Local Development

If you want to build locally later:

```bash
# Install Android Studio
# https://developer.android.com/studio

# Then build
cd army_hub
flutter build apk --release

cd army_translator  
flutter build apk --release
```

---

## Supabase Configuration

Both apps are configured to use:
- **Project URL:** https://zcivfmgmfxqsqukoygcn.supabase.co
- **Database:** PostgreSQL with RLS policies
- **Auth:** Email/Password + Google OAuth

Database tables created via `SUPABASE_SETUP.sql`
