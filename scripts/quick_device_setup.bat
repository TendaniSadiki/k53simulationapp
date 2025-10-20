@echo off
echo ========================================
echo K53 App - Physical Device Setup Helper
echo ========================================
echo.

echo Checking Flutter installation...
flutter --version
if %errorlevel% neq 0 (
    echo ❌ Flutter not found. Please install Flutter first.
    pause
    exit /b 1
)

echo.
echo Checking connected devices...
flutter devices
if %errorlevel% neq 0 (
    echo ❌ No devices detected.
    echo.
    echo For Android:
    echo 1. Enable Developer Options
    echo 2. Enable USB Debugging
    echo 3. Connect device via USB
    echo 4. Allow USB debugging when prompted
    echo.
    echo For iOS:
    echo 1. Connect device via USB
    echo 2. Trust developer in Settings
    echo.
    pause
    exit /b 1
)

echo.
echo Installing dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo ❌ Failed to install dependencies.
    pause
    exit /b 1
)

echo.
echo Building the app...
flutter build apk --debug
if %errorlevel% neq 0 (
    echo ❌ Build failed.
    pause
    exit /b 1
)

echo.
echo ✅ Ready to run on device!
echo.
echo Choose an option:
echo 1. Run in debug mode (recommended for testing)
echo 2. Run in release mode (better performance)
echo 3. Build APK only
echo 4. Exit
echo.

set /p choice="Enter your choice (1-4): "

if "%choice%"=="1" (
    echo Starting debug mode...
    flutter run --debug
) else if "%choice%"=="2" (
    echo Starting release mode...
    flutter run --release
) else if "%choice%"=="3" (
    echo Building APK...
    flutter build apk --release
    echo.
    echo ✅ APK created at: build\app\outputs\flutter-apk\app-release.apk
    echo You can install this APK on any Android device.
) else (
    echo Exiting...
    exit /b 0
)

pause