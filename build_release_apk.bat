@echo off
echo ================================================
echo    K53 App Release APK Builder
echo ================================================
echo.
echo This script provides instructions for building a
echo release APK to share with your boss.
echo.
echo Please follow these steps:
echo.
echo 1. Open Android Studio
echo 2. Open the K53 app project
echo 3. Go to Build -> Flutter -> Build APK
echo 4. Wait for the build to complete
echo 5. The APK will be at: build/app/outputs/apk/release/app-release.apk
echo.
echo OR use command line:
echo   flutter clean
echo   flutter pub get  
echo   flutter build apk --release
echo.
echo ================================================
echo APK Location: build/app/outputs/apk/release/app-release.apk
echo Expected Size: ~30-50 MB
echo Android Compatibility: 5.0+ (API 21+)
echo ================================================
echo.
echo To share with your boss:
echo - Copy the APK file
echo - Send via email, WhatsApp, or file sharing
echo - Enable "Unknown sources" on Android device
echo - Install and launch the app
echo.
echo Press any key to close...
pause >nul