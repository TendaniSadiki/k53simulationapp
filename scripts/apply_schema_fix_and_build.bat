@echo off
echo ============================================
echo K53 App - Schema Fix & Release Build Script
echo ============================================
echo.

echo Step 1: Apply Database Schema Fixes
echo.
echo Please follow these steps to apply the database fixes:
echo.
echo 1. Go to: https://app.supabase.com/
echo 2. Select your project
echo 3. Open the SQL Editor
echo 4. Copy and paste the contents of: scripts/apply_missing_schema_fix.sql
echo 5. Execute the SQL
echo.
echo This will fix the missing columns and tables causing errors.
echo.

echo Step 2: Build Release APK
echo.
echo Building release APK for sharing...
flutter build apk --release

if %errorlevel% equ 0 (
    echo.
    echo ✅ Release APK built successfully!
    echo.
    echo 📱 APK Location: build\app\outputs\flutter-apk\app-release.apk
    echo.
    echo You can now share this APK with your boss.
    echo.
    echo To install on Android device:
    echo 1. Copy the APK to your device
    echo 2. Enable "Install from unknown sources" in settings
    echo 3. Open the APK file and install
) else (
    echo.
    echo ❌ APK build failed. Please check for errors above.
)

echo.
pause