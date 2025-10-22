@echo off
echo ================================================
echo    K53 App HYBRID APK Builder
echo ================================================
echo.
echo This script builds a HYBRID APK that:
echo - Tries to fetch questions from Supabase when available
echo - Falls back to cached questions when offline
echo - Works completely offline as final fallback
echo.

echo Cleaning previous builds...
flutter clean

echo Getting dependencies...
flutter pub get

echo Building HYBRID APK with Supabase configuration...
flutter build apk --release ^
  --dart-define=SUPABASE_URL=https://ceydnflvovxphncnuhop.supabase.co ^
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNleWRuZmx2b3Z4cGhuY251aG9wIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYwMzQzMDAsImV4cCI6MjA3MTYxMDMwMH0.ear-PJjrY6EcehGEVmcOY0XwUb7uFQLkt4agzQHqJOE ^
  --dart-define=ENVIRONMENT=production ^
  --dart-define=APP_NAME="K53 Learner's License" ^
  --dart-define=APP_VERSION=1.0.0 ^
  --dart-define=ENABLE_ANALYTICS=true ^
  --dart-define=ENABLE_GAMIFICATION=true ^
  --dart-define=ENABLE_SHARING=true ^
  --dart-define=ENABLE_OFFLINE_MODE=true

echo ================================================
echo HYBRID APK Location: build/app/outputs/apk/release/app-release.apk
echo Expected Size: ~30-50 MB
echo Android Compatibility: 5.0+ (API 21+)
echo ================================================
echo.
echo ✅ THIS APK USES HYBRID APPROACH:
echo - Tries Supabase API first when online
echo - Falls back to cached questions when offline
echo - Works completely offline as final fallback
echo.
echo Features included:
echo - All K53 questions and road signs
echo - Study mode with flashcards
echo - Mock exams with scoring
echo - Local user profiles
echo - Gamification (points, achievements)
echo - Progress tracking
echo - Robust error handling
echo.
echo To share with your boss:
echo - Copy the APK file
echo - Send via email, WhatsApp, or file sharing
echo - Enable "Unknown sources" on Android device
echo - Install and launch the app
echo - Works in all connectivity scenarios!
echo.
echo Press any key to close...
pause >nul