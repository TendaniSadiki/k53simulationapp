Write-Host "Cleaning Flutter build directories..." -ForegroundColor Green

# Remove Flutter build directories
if (Test-Path "build") {
    Remove-Item -Recurse -Force "build"
    Write-Host "✓ Removed build directory" -ForegroundColor Green
}

if (Test-Path ".dart_tool") {
    Remove-Item -Recurse -Force ".dart_tool"
    Write-Host "✓ Removed .dart_tool directory" -ForegroundColor Green
}

# Remove Android build directories
if (Test-Path "android\app\build") {
    Remove-Item -Recurse -Force "android\app\build"
    Write-Host "✓ Removed android/app/build directory" -ForegroundColor Green
}

if (Test-Path "android\build") {
    Remove-Item -Recurse -Force "android\build"
    Write-Host "✓ Removed android/build directory" -ForegroundColor Green
}

# Remove iOS build directories
if (Test-Path "ios\build") {
    Remove-Item -Recurse -Force "ios\build"
    Write-Host "✓ Removed ios/build directory" -ForegroundColor Green
}

Write-Host "`nBuild cleanup completed!" -ForegroundColor Cyan
Write-Host "Now run: flutter clean" -ForegroundColor Yellow
Write-Host "Then: flutter pub get" -ForegroundColor Yellow
Write-Host "Finally: flutter run" -ForegroundColor Yellow