Write-Host "=== K53 App Android Build Fix ===" -ForegroundColor Cyan
Write-Host "This script will convert from Kotlin DSL to traditional Gradle configuration" -ForegroundColor Yellow

# Step 1: Clean existing build directories
Write-Host "`nStep 1: Cleaning build directories..." -ForegroundColor Green
.\clean_build_windows.ps1

# Step 2: Run Flutter clean
Write-Host "`nStep 2: Running Flutter clean..." -ForegroundColor Green
flutter clean

# Step 3: Get dependencies
Write-Host "`nStep 3: Getting Flutter dependencies..." -ForegroundColor Green
flutter pub get

# Step 4: Verify Android configuration
Write-Host "`nStep 4: Verifying Android configuration..." -ForegroundColor Green

# Check if traditional Gradle files exist
$buildGradleExists = Test-Path "android\build.gradle"
$appBuildGradleExists = Test-Path "android\app\build.gradle"
$settingsGradleExists = Test-Path "android\settings.gradle"

if ($buildGradleExists -and $appBuildGradleExists -and $settingsGradleExists) {
    Write-Host "✓ Traditional Gradle configuration files found" -ForegroundColor Green
} else {
    Write-Host "✗ Missing traditional Gradle configuration files" -ForegroundColor Red
    exit 1
}

# Step 5: Build the app
Write-Host "`nStep 5: Building the app..." -ForegroundColor Green
Write-Host "This may take a few minutes..." -ForegroundColor Yellow

# Try building for debug first
try {
    flutter build apk --debug
    Write-Host "✓ Debug build successful!" -ForegroundColor Green
} catch {
    Write-Host "✗ Debug build failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Trying alternative build approach..." -ForegroundColor Yellow
}

# Step 6: Run the app
Write-Host "`nStep 6: Running the app..." -ForegroundColor Green
Write-Host "Make sure your Android device is connected or emulator is running" -ForegroundColor Yellow

try {
    flutter run
} catch {
    Write-Host "✗ Failed to run app: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "`nTroubleshooting steps:" -ForegroundColor Yellow
    Write-Host "1. Check if device is connected: flutter devices" -ForegroundColor White
    Write-Host "2. Enable USB Debugging on your Android device" -ForegroundColor White
    Write-Host "3. Enable 'Install Unknown Apps' in device settings" -ForegroundColor White
    Write-Host "4. Try: flutter run --verbose for detailed logs" -ForegroundColor White
}

Write-Host "`n=== Build Fix Complete ===" -ForegroundColor Cyan
Write-Host "If you still encounter issues, check the troubleshooting guides:" -ForegroundColor Yellow
Write-Host "- FIX_DEVICE_INSTALLATION.md" -ForegroundColor White
Write-Host "- FIX_ANDROID_CONFIGURATION.md" -ForegroundColor White