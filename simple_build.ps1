Write-Host "=== K53 App Simple Build ===" -ForegroundColor Cyan

# Clean build directories
Write-Host "Cleaning build directories..." -ForegroundColor Green
if (Test-Path "build") { Remove-Item -Recurse -Force "build" }
if (Test-Path ".dart_tool") { Remove-Item -Recurse -Force ".dart_tool" }
if (Test-Path "android\app\build") { Remove-Item -Recurse -Force "android\app\build" }
if (Test-Path "android\build") { Remove-Item -Recurse -Force "android\build" }

# Flutter commands
Write-Host "Running Flutter clean..." -ForegroundColor Green
flutter clean

Write-Host "Getting dependencies..." -ForegroundColor Green  
flutter pub get

Write-Host "Building APK..." -ForegroundColor Green
flutter build apk --debug

Write-Host "Running on device..." -ForegroundColor Green
flutter run -d 2409BRN2CA

Write-Host "=== Build Complete ===" -ForegroundColor Cyan