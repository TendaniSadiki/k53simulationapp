Write-Host "=== K53 App Gradle Configuration Fix ===" -ForegroundColor Cyan
Write-Host "Fixing Gradle plugin configuration for Flutter 3.32.8+" -ForegroundColor Yellow

# Step 1: Clean existing build directories
Write-Host "`nStep 1: Cleaning build directories..." -ForegroundColor Green
.\clean_build_windows.ps1

# Step 2: Run Flutter clean
Write-Host "`nStep 2: Running Flutter clean..." -ForegroundColor Green
flutter clean

# Step 3: Get dependencies
Write-Host "`nStep 3: Getting Flutter dependencies..." -ForegroundColor Green
flutter pub get

# Step 4: Verify Gradle configuration
Write-Host "`nStep 4: Verifying Gradle configuration..." -ForegroundColor Green

# Check if declarative plugin configuration exists
$appBuildGradle = Get-Content "android\app\build.gradle" -Raw
if ($appBuildGradle -match 'plugins\s*\{') {
    Write-Host "✓ Declarative plugin configuration found" -ForegroundColor Green
} else {
    Write-Host "✗ Missing declarative plugin configuration" -ForegroundColor Red
    exit 1
}

# Step 5: Build the app with new configuration
Write-Host "`nStep 5: Building the app with new Gradle configuration..." -ForegroundColor Green
Write-Host "This may take a few minutes..." -ForegroundColor Yellow

try {
    # First try to build APK
    flutter build apk --debug
    Write-Host "✓ Debug APK build successful!" -ForegroundColor Green
    
    # Then try to run
    Write-Host "`nStep 6: Running the app..." -ForegroundColor Green
    Write-Host "Make sure your Android device is connected or emulator is running" -ForegroundColor Yellow
    
    flutter run -d 2409BRN2CA
    
} catch {
    Write-Host "✗ Build failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "`nTroubleshooting steps:" -ForegroundColor Yellow
    Write-Host "1. Check Flutter doctor: flutter doctor" -ForegroundColor White
    Write-Host "2. Try: flutter run --verbose for detailed logs" -ForegroundColor White
    Write-Host "3. Check Android SDK installation" -ForegroundColor White
}

Write-Host "`n=== Gradle Configuration Fix Complete ===" -ForegroundColor Cyan
Write-Host "If issues persist, check:" -ForegroundColor Yellow
Write-Host "- FIX_DEVICE_INSTALLATION.md" -ForegroundColor White
Write-Host "- FIX_ANDROID_CONFIGURATION.md" -ForegroundColor White