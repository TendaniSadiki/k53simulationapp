# K53 App Release Build Script (With Config)
Write-Host "=== K53 App Release Build (With Config) ===" -ForegroundColor Green
Write-Host "Building release APK with embedded Supabase configuration..." -ForegroundColor Yellow

# Clean previous builds
Write-Host "Cleaning previous builds..." -ForegroundColor Cyan
flutter clean

# Get dependencies
Write-Host "Getting dependencies..." -ForegroundColor Cyan
flutter pub get

# Build release APK with configuration
Write-Host "Building release APK with Supabase configuration..." -ForegroundColor Cyan
flutter build apk --release `
  --dart-define=SUPABASE_URL=https://ceydnflvovxphncnuhop.supabase.co `
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNleWRuZmx2b3Z4cGhuY251aG9wIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYwMzQzMDAsImV4cCI6MjA3MTYxMDMwMH0.ear-PJjrY6EcehGEVmcOY0XwUb7uFQLkt4agzQHqJOE `
  --dart-define=ENVIRONMENT=production `
  --dart-define=APP_NAME="K53 Learner's License" `
  --dart-define=APP_VERSION=1.0.0 `
  --dart-define=ENABLE_ANALYTICS=true `
  --dart-define=ENABLE_GAMIFICATION=true `
  --dart-define=ENABLE_SHARING=true `
  --dart-define=ENABLE_OFFLINE_MODE=true

Write-Host "=== Release Build Complete ===" -ForegroundColor Green
Write-Host "Release APK location: build/app/outputs/apk/release/app-release.apk" -ForegroundColor Yellow
Write-Host "File size: " -NoNewline
if (Test-Path "build/app/outputs/apk/release/app-release.apk") {
    $file = Get-Item "build/app/outputs/apk/release/app-release.apk"
    Write-Host "$([math]::Round($file.Length/1MB, 2)) MB" -ForegroundColor Yellow
} else {
    Write-Host "File not found" -ForegroundColor Red
}

Write-Host "`nTo share with your boss:" -ForegroundColor Green
Write-Host "1. Copy the file: build/app/outputs/apk/release/app-release.apk" -ForegroundColor White
Write-Host "2. Send it via email, WhatsApp, or file sharing service" -ForegroundColor White
Write-Host "3. Your boss can install it on any Android device" -ForegroundColor White
Write-Host "4. Supabase API configuration is embedded in the APK" -ForegroundColor White