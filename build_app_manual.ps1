Write-Host "=== K53 App Manual Build ===" -ForegroundColor Cyan
Write-Host "Building with fixed Gradle configuration" -ForegroundColor Yellow

# Step 1: Manual cleanup
Write-Host "`nStep 1: Manual cleanup..." -ForegroundColor Green
if (Test-Path "build") {
    Remove-Item -Recurse -Force "build"
    Write-Host "✓ Removed build directory" -ForegroundColor Green
}

if (Test-Path ".dart_tool") {
    Remove-Item -Recurse -Force ".dart_tool"
    Write-Host "✓ Removed .dart_tool directory" -ForegroundColor Green
}

if (Test-Path "android\app\build") {
    Remove-Item -Recurse -Force "android\app\build"
    Write-Host "✓ Removed android/app/build directory" -ForegroundColor Green
}

if (Test-Path "android\build") {
    Remove-Item -Recurse -Force "android\build"
    Write-Host "✓ Removed android/build directory" -ForegroundColor Green
}

# Step 2: Flutter clean
Write-Host "`nStep 2: Running Flutter clean..." -ForegroundColor Green
flutter clean

# Step 3: Get dependencies
Write-Host "`nStep 3: Getting Flutter dependencies..." -ForegroundColor Green
flutter pub get

# Step 4: Build APK
Write-Host "`nStep 4: Building APK..." -ForegroundColor Green
Write-Host "This may take a few minutes..." -ForegroundColor Yellow
flutter build apk --debug

# Step 5: Run on device
Write-Host "`nStep 5: Running on device..." -ForegroundColor Green
Write-Host "Make sure device 2409BRN2CA is connected" -ForegroundColor Yellow
flutter run -d 2409BRN2CA

Write-Host "`n=== Build Complete ===" -ForegroundColor Cyan