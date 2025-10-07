@echo off
echo ============================================
echo K53 App - Profile Migration Instructions
echo ============================================
echo.
echo This script provides instructions for running the database migration
echo to add new profile fields (full_name, phone, first_login).
echo.
echo STEPS TO RUN MIGRATION:
echo.
echo 1. Open your Supabase dashboard
echo 2. Go to the SQL Editor section
echo 3. Copy and paste the contents of 'scripts\add_user_profile_fields.sql'
echo 4. Run the SQL script
echo 5. Verify the migration was successful
echo.
echo ============================================
echo VERIFICATION STEPS:
echo ============================================
echo.
echo After running the migration, verify the changes by:
echo 1. Checking the profiles table structure
echo 2. Looking for the new columns: full_name, phone, first_login
echo 3. Testing user registration to ensure data is saved correctly
echo.
echo ============================================
echo TROUBLESHOOTING:
echo ============================================
echo.
echo If you encounter issues:
echo - Check that you have proper permissions in Supabase
echo - Verify the SQL syntax is correct
echo - Ensure the profiles table exists
echo.
pause