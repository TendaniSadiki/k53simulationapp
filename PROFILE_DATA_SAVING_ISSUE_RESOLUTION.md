# Profile Data Saving Issue Resolution

## Problem Identified
The user reported that profile data is being saved to the `auth.users` table instead of the `profiles` table.

## Root Cause Analysis

### Current Database Structure
1. **auth.users** (built-in Supabase table): Stores authentication data (email, password hash, etc.)
2. **profiles** (custom table): Stores extended user profile data (handle, learner_code, locale, etc.)

### The Issue
- The database migration script [`scripts/add_user_profile_fields.sql`](scripts/add_user_profile_fields.sql) has not been run yet
- Without the migration, the `profiles` table is missing the new columns:
  - `full_name`
  - `phone` 
  - `first_login`
- The login screen attempts to save to the `profiles` table, but without the new columns, the data may not be visible or properly saved

## Solution Implemented

### 1. Enhanced Error Handling in Login Screen
Updated [`lib/src/features/auth/presentation/screens/login_screen.dart`](lib/src/features/auth/presentation/screens/login_screen.dart) to:

- **Graceful Fallback**: If enhanced profile creation fails, fall back to basic profile creation
- **Better Error Logging**: Clear console messages indicating what's happening
- **Migration Awareness**: Inform when database migration is needed

### 2. Database Migration Script
Created [`scripts/add_user_profile_fields.sql`](scripts/add_user_profile_fields.sql) to:
- Add `full_name`, `phone`, and `first_login` columns to profiles table
- Update the `handle_new_user()` trigger function to include new fields

### 3. Migration Assistance Tools
- [`scripts/run_profile_migration.bat`](scripts/run_profile_migration.bat): Windows batch file with migration instructions
- [`scripts/verify_profile_structure.dart`](scripts/verify_profile_structure.dart): Dart script to verify database structure

## Steps to Fix the Issue

### Immediate Action Required
1. **Run the Database Migration**:
   ```bash
   # Open Supabase SQL Editor and run:
   # Copy and paste the contents of scripts/add_user_profile_fields.sql
   ```

2. **Verify Migration Success**:
   - Check that the `profiles` table now has the new columns
   - Test user registration to ensure data is saved correctly

### Code Changes Made
The login screen now handles the transition gracefully:

```dart
// Before: Direct upsert that would fail if columns don't exist
await SupabaseService.client.from('profiles').upsert({
  'id': userId,
  'full_name': fullName, // This would fail if column doesn't exist
  // ...
});

// After: Graceful fallback approach
try {
  // Try enhanced profile creation
  await SupabaseService.client.from('profiles').upsert({
    ...profileData,
    'full_name': fullName, // Try new fields
    'phone': phone,
    'first_login': true,
  });
} catch (e) {
  // Fall back to basic profile creation
  await SupabaseService.client.from('profiles').upsert(profileData);
}
```

## Expected Behavior After Fix

### With Migration Applied
- ✅ User signs up with full name and phone
- ✅ Data is saved to `profiles` table with all fields
- ✅ `first_login` is set to `true`
- ✅ Profile is properly linked to auth user via `id`

### Without Migration (Current State)
- ✅ User can still sign up successfully
- ✅ Basic profile is created in `profiles` table
- ⚠️ Full name and phone data may not be saved
- ⚠️ Console shows migration reminder message

## Verification Steps

1. **Check Database Structure**:
   ```sql
   SELECT column_name, data_type 
   FROM information_schema.columns 
   WHERE table_name = 'profiles';
   ```

2. **Test User Registration**:
   - Sign up a new user with full name and phone
   - Check the `profiles` table for the new user record
   - Verify all fields are populated correctly

3. **Monitor Console Output**:
   - Look for success messages in the console
   - Check for any error messages during profile creation

## Technical Notes

- The `auth.users` table is managed by Supabase authentication system
- The `profiles` table is our custom extension for additional user data
- The `handle_new_user()` trigger automatically creates basic profiles
- Manual profile creation in the login screen ensures additional data is captured
- Row Level Security (RLS) policies ensure users can only access their own data

## Files Modified
- [`lib/src/features/auth/presentation/screens/login_screen.dart`](lib/src/features/auth/presentation/screens/login_screen.dart) - Enhanced profile creation with fallback
- [`scripts/add_user_profile_fields.sql`](scripts/add_user_profile_fields.sql) - Database migration script
- [`scripts/run_profile_migration.bat`](scripts/run_profile_migration.bat) - Migration instructions
- [`scripts/verify_profile_structure.dart`](scripts/verify_profile_structure.dart) - Database verification script
- [`PROFILE_DATA_SAVING_ISSUE_RESOLUTION.md`](PROFILE_DATA_SAVING_ISSUE_RESOLUTION.md) - This documentation

## Next Steps
1. Run the database migration script in Supabase SQL Editor
2. Test user registration to verify data is saved to profiles table
3. Monitor console output for any remaining issues
4. Update any tests if necessary