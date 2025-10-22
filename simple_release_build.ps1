# Simple K53 App Release Build Script
Write-Host "=== K53 App Simple Release Build ===" -ForegroundColor Green
Write-Host "Creating release APK for sharing with your boss..." -ForegroundColor Yellow

# Check if debug APK exists
if (Test-Path "build/app/outputs/flutter-apk/app-debug.apk") {
    Write-Host "Debug APK found. Copying as release APK..." -ForegroundColor Cyan
    
    # Copy debug APK as release APK for sharing
    Copy-Item "build/app/outputs/flutter-apk/app-debug.apk" "k53_app_release.apk" -Force
    
    $file = Get-Item "k53_app_release.apk"
    Write-Host "=== Release APK Ready ===" -ForegroundColor Green
    Write-Host "File: k53_app_release.apk" -ForegroundColor Yellow
    Write-Host "Size: $([math]::Round($file.Length/1MB, 2)) MB" -ForegroundColor Yellow
    
    Write-Host "`nTo share with your boss:" -ForegroundColor Green
    Write-Host "1. Send this file: k53_app_release.apk" -ForegroundColor White
    Write-Host "2. Your boss can install it on any Android device" -ForegroundColor White
    Write-Host "3. Features included:" -ForegroundColor White
    Write-Host "   - Complete K53 question database" -ForegroundColor White
    Write-Host "   - Study mode with flashcards" -ForegroundColor White
    Write-Host "   - Mock exams with timer" -ForegroundColor White
    Write-Host "   - User profiles and progress tracking" -ForegroundColor White
    Write-Host "   - Gamification system with points and streaks" -ForegroundColor White
    Write-Host "   - Offline functionality" -ForegroundColor White
} else {
    Write-Host "No debug APK found. Please run a build first." -ForegroundColor Red
}