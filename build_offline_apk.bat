@echo off
echo ================================================
echo    K53 App OFFLINE APK Builder
echo ================================================
echo.
echo This script builds a COMPLETELY OFFLINE APK
echo that works without any external API connections.
echo.

echo Cleaning previous builds...
flutter clean

echo Getting dependencies...
flutter pub get

echo Building OFFLINE APK (no external dependencies)...
flutter build apk --release ^
  --dart-define=ENVIRONMENT=production ^
  --dart-define=APP_NAME="K53 Learner's License (Offline)" ^
  --dart-define=APP_VERSION=1.0.0 ^
  --dart-define=ENABLE_ANALYTICS=false ^
  --dart-define=ENABLE_GAMIFICATION=true ^
  --dart-define=ENABLE_SHARING=true ^
  --dart-define=ENABLE_OFFLINE_MODE=true

echo ================================================
echo OFFLINE APK Location: build/app/outputs/apk/release/app-release.apk
echo Expected Size: ~30-50 MB
echo Android Compatibility: 5.0+ (API 21+)
echo ================================================
echo.
echo ✅ THIS APK WORKS COMPLETELY OFFLINE
echo.
echo Features included:
echo - All K53 questions and road signs
echo - Study mode with flashcards
echo - Mock exams with scoring
echo - Local user profiles
echo - Gamification (points, achievements)
echo - Progress tracking
echo - No internet connection required!
echo.
echo To share with your boss:
echo - Copy the APK file
echo - Send via email, WhatsApp, or file sharing
echo - Enable "Unknown sources" on Android device
echo - Install and launch the app
echo - Works immediately without internet!
echo.
echo Press any key to close...
pause >nul