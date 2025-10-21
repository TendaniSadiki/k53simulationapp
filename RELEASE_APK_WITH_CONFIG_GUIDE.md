# K53 App Release APK Guide (With Embedded Configuration)

## Problem Solved
The previous release APK had Supabase API connection issues because the `.env` file containing the Supabase configuration was not included in the release build. This guide provides the solution using compile-time configuration via `--dart-define` flags.

## What Changed

### 1. New Configuration System
- **Old**: Used `flutter_dotenv` to load `.env` file at runtime
- **New**: Uses `--dart-define` flags to embed configuration at compile time
- **Result**: Configuration is now embedded in the APK and works in release builds

### 2. Files Created/Modified
- ✅ `lib/src/core/config/app_config.dart` - New compile-time configuration system
- ✅ `lib/src/core/services/supabase_service.dart` - Updated to use AppConfig
- ✅ `lib/src/core/app_initializer.dart` - Updated to use AppConfig
- ✅ `pubspec.yaml` - Removed flutter_dotenv dependency
- ✅ `build_release_apk_with_config.bat` - New build script with configuration
- ✅ `release_build_with_config.ps1` - New PowerShell build script

## How to Build the Release APK

### Option 1: Using Batch Script (Windows)
1. Double-click `build_release_apk_with_config.bat`
2. Wait for the build to complete
3. APK will be at: `build/app/outputs/apk/release/app-release.apk`

### Option 2: Using PowerShell Script (Windows)
1. Right-click `release_build_with_config.ps1`
2. Select "Run with PowerShell"
3. Wait for the build to complete
4. APK will be at: `build/app/outputs/apk/release/app-release.apk`

### Option 3: Manual Command Line
```bash
flutter clean
flutter pub get
flutter build apk --release \
  --dart-define=SUPABASE_URL=https://ceydnflvovxphncnuhop.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNleWRuZmx2b3Z4cGhuY251aG9wIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYwMzQzMDAsImV4cCI6MjA3MTYxMDMwMH0.ear-PJjrY6EcehGEVmcOY0XwUb7uFQLkt4agzQHqJOE \
  --dart-define=ENVIRONMENT=production \
  --dart-define=APP_NAME="K53 Learner's License" \
  --dart-define=APP_VERSION=1.0.0 \
  --dart-define=ENABLE_ANALYTICS=true \
  --dart-define=ENABLE_GAMIFICATION=true \
  --dart-define=ENABLE_SHARING=true \
  --dart-define=ENABLE_OFFLINE_MODE=true
```

## Configuration Embedded in APK

The following configuration is now embedded in the release APK:

| Setting | Value |
|---------|-------|
| **Supabase URL** | `https://ceydnflvovxphncnuhop.supabase.co` |
| **Supabase Key** | `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...` |
| **Environment** | `production` |
| **App Name** | `K53 Learner's License` |
| **App Version** | `1.0.0` |
| **Analytics** | `enabled` |
| **Gamification** | `enabled` |
| **Sharing** | `enabled` |
| **Offline Mode** | `enabled` |

## Sharing with Your Boss

1. **Build the APK** using one of the methods above
2. **Copy the APK file**: `build/app/outputs/apk/release/app-release.apk`
3. **Send via**:
   - Email attachment
   - WhatsApp file sharing
   - Google Drive/Dropbox
   - USB drive
4. **Installation Instructions**:
   - Enable "Unknown sources" in Android settings
   - Open the APK file
   - Tap "Install"
   - Launch the app

## Expected Results

- ✅ **Supabase API Connection**: Will work in release APK
- ✅ **User Authentication**: Login/registration will function
- ✅ **Database Operations**: All CRUD operations will work
- ✅ **Gamification**: Points, achievements, and progress tracking
- ✅ **Offline Mode**: Works when internet is unavailable
- ✅ **Image Loading**: Road sign images display correctly

## Troubleshooting

If you still experience issues:

1. **Check Internet Connection**: Ensure device has internet access
2. **Verify Supabase Status**: Check if Supabase service is running
3. **Clear App Data**: Uninstall and reinstall the APK
4. **Check Logs**: Enable debug mode to see detailed error messages

## Technical Details

The new configuration system uses Dart's `String.fromEnvironment()` and `bool.fromEnvironment()` methods to read compile-time constants. These values are embedded during the build process and cannot be changed without rebuilding the APK.

This approach is more secure and reliable than runtime configuration files, as the configuration becomes part of the compiled application binary.