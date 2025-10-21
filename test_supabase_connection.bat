@echo off
echo ================================================
echo    Supabase Connection Test
echo ================================================
echo.
echo This script will test if the Supabase project is
echo active and accessible from your current network.
echo.

echo Checking if Flutter is available...
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Flutter is not available or not in PATH
    echo Please ensure Flutter is installed and configured
    pause
    exit /b 1
)

echo ✅ Flutter is available
echo.
echo Running Supabase connection test...
echo.

flutter run test_supabase_connection_comprehensive.dart

echo.
echo ================================================
echo Test Complete
echo ================================================
echo.
echo If you see "✅ Supabase project is ACTIVE" above:
echo - The API should work in release APK
echo - Use build_hybrid_apk.bat for best results
echo.
echo If you see "❌ Supabase project appears INACCESSIBLE":
echo - The project may be paused, deleted, or blocked
echo - Use build_offline_apk.bat for guaranteed functionality
echo - Consider setting up alternative backend
echo.
echo Press any key to close...
pause >nul