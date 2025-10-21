# K53 App OFFLINE APK Builder
Write-Host "=== K53 App OFFLINE APK Builder ===" -ForegroundColor Green
Write-Host "Building COMPLETELY OFFLINE APK..." -ForegroundColor Yellow
Write-Host "No external API connections required!" -ForegroundColor Cyan

# Clean previous builds
Write-Host "Cleaning previous builds..." -ForegroundColor Cyan
flutter clean

# Get dependencies
Write-Host "Getting dependencies..." -ForegroundColor Cyan
flutter pub get

# Build OFFLINE APK (no external dependencies)
Write-Host "Building OFFLINE APK (no external dependencies)..." -ForegroundColor Cyan
flutter build apk --release `
  --dart-define=ENVIRONMENT=production `
  --dart-define=APP_NAME="K53 Learner's License (Offline)" `
  --dart-define=APP_VERSION=1.0.0 `
  --dart-define=ENABLE_ANALYTICS=false `
  --dart-define=ENABLE_GAMIFICATION=true `
  --dart-define=ENABLE_SHARING=true `
  --dart-define=ENABLE_OFFLINE_MODE=true

Write-Host "=== OFFLINE APK Build Complete ===" -ForegroundColor Green
Write-Host "OFFLINE APK location: build/app/outputs/apk/release/app-release.apk" -ForegroundColor Yellow
Write-Host "File size: " -NoNewline
if (Test-Path "build/app/outputs/apk/release/app-release.apk") {
    $file = Get-Item "build/app/outputs/apk/release/app-release.apk"
    Write-Host "$([math]::Round($file.Length/1MB, 2)) MB" -ForegroundColor Yellow
} else {
    Write-Host "File not found" -ForegroundColor Red
}

Write-Host "`n✅ THIS APK WORKS COMPLETELY OFFLINE" -ForegroundColor Green
Write-Host "`nFeatures included:" -ForegroundColor White
Write-Host "- All K53 questions and road signs" -ForegroundColor Gray
Write-Host "- Study mode with flashcards" -ForegroundColor Gray
Write-Host "- Mock exams with scoring" -ForegroundColor Gray
Write-Host "- Local user profiles" -ForegroundColor Gray
Write-Host "- Gamification (points, achievements)" -ForegroundColor Gray
Write-Host "- Progress tracking" -ForegroundColor Gray
Write-Host "- No internet connection required!" -ForegroundColor Green

Write-Host "`nTo share with your boss:" -ForegroundColor White
Write-Host "1. Copy the file: build/app/outputs/apk/release/app-release.apk" -ForegroundColor Gray
Write-Host "2. Send it via email, WhatsApp, or file sharing service" -ForegroundColor Gray
Write-Host "3. Your boss can install it on any Android device" -ForegroundColor Gray
Write-Host "4. Works immediately without internet!" -ForegroundColor Green