@echo off
echo ============================================
echo K53 App - Supabase SQL Execution Script
echo ============================================
echo.

echo Checking if Supabase CLI is installed...
where supabase >nul 2>&1
if %errorlevel% neq 0 (
    echo Supabase CLI is not installed.
    echo.
    echo Please install Supabase CLI first:
    echo Option 1: Using Scoop package manager
    echo   scoop install supabase
    echo.
    echo Option 2: Download from GitHub releases:
    echo   https://github.com/supabase/cli/releases
    echo.
    echo After installation, please run this script again.
    pause
    exit /b 1
)

echo Supabase CLI found!
echo.

echo Please make sure you have:
echo 1. Your Supabase access token (from dashboard)
echo 2. Your database password
echo.

set /p SUPABASE_ACCESS_TOKEN="Enter your Supabase access token: "
set /p SUPABASE_DB_PASSWORD="Enter your database password: "

echo.
echo Setting environment variables...
setx SUPABASE_ACCESS_TOKEN %SUPABASE_ACCESS_TOKEN%
setx SUPABASE_DB_PASSWORD %SUPABASE_DB_PASSWORD%

echo.
echo Step 1: Checking and creating tables if needed...
supabase db execute --file scripts/check_and_create_tables.sql

if %errorlevel% neq 0 (
    echo.
    echo ⚠️  Table check failed! Please check your database connection.
    echo.
    echo You may need to manually create the tables first.
    echo Refer to scripts/EXECUTE_ROAD_SIGN_QUESTIONS_GUIDE.md for manual setup.
    pause
    exit /b 1
)

echo.
echo Step 2: Executing road sign questions SQL...
supabase db execute --file scripts/road_sign_questions_output.sql

if %errorlevel% equ 0 (
    echo.
    echo ✅ SQL executed successfully!
    echo.
    echo Please verify the insertion in your Supabase dashboard:
    echo 1. Go to https://app.supabase.com/
    echo 2. Select your project
    echo 3. Check the 'questions' table
    echo 4. Filter by category = 'road_signs'
    echo.
    echo You should see 19 new road sign questions with images.
) else (
    echo.
    echo ❌ SQL execution failed!
    echo.
    echo Please check:
    echo 1. Your database connection settings
    echo 2. The SQL file syntax
    echo 3. Your Supabase project permissions
    echo.
    echo For manual execution, use the Supabase SQL Editor with:
    echo - scripts/check_and_create_tables.sql (first)
    echo - scripts/road_sign_questions_output.sql (second)
)

echo.
pause