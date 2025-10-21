# K53 App Release Build Script
Write-Host "=== K53 App Release Build ===" -ForegroundColor Green
Write-Host "Building release APK for sharing..." -ForegroundColor Yellow

# Clean previous builds
Write-Host "Cleaning previous builds..." -ForegroundColor Cyan
flutter clean

# Get dependencies
Write-Host "Getting dependencies..." -ForegroundColor Cyan
flutter pub get

# Build release APK
Write-Host "Building release APK..." -ForegroundColor Cyan
flutter build apk --release

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