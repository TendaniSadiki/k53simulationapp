# Enhanced User Registration Testing Guide

## Overview
This guide will help you test the enhanced user registration to verify that `full_name`, `phone`, and `first_login` data are being saved correctly to the `profiles` table.

## Prerequisites
- ✅ Database migration has been applied (columns exist in profiles table)
- ✅ App is ready to run
- ✅ Supabase connection is working

## Step-by-Step Testing Process

### Step 1: Run the App
```bash
flutter run
```

### Step 2: Test User Registration
1. **Navigate to the Login Screen**
   - The app should start on the login screen
   - You should see "Welcome" text and sign-in form

2. **Switch to Sign-Up Mode**
   - Click "Don't have an account? Sign Up"
   - The form should expand to show:
     - Full Name field
     - Phone Number field
     - Email field
     - Password field

3. **Fill Out Registration Form**
   - **Full Name**: `Test User 123`
   - **Phone**: `+1234567890`
   - **Email**: `testuser123@example.com` (use a unique email)
   - **Password**: `password123`

4. **Submit Registration**
   - Click "Create Account" button
   - You should see a loading indicator
   - After successful registration, you should see:
     - "Please check your email for verification link" message

### Step 3: Monitor Console Output
**Expected Console Messages:**
```
✅ User profile created with enhanced fields for user: <user_id>
📝 Profile data: full_name=Test User 123, phone=+1234567890, first_login=true
```

### Step 4: Verify Database Data
1. **Open Supabase Dashboard**
   - Go to your Supabase project
   - Navigate to Table Editor
   - Select the `profiles` table

2. **Find the New User**
   - Look for the user with:
     - `full_name`: "Test User 123"
     - `phone`: "+1234567890"
     - `first_login`: true

3. **Verify All Fields**
   - Check that all fields are populated correctly:
     - `id`: Should match the auth user ID
     - `handle`: Should be auto-generated (e.g., "user_abc12345")
     - `full_name`: "Test User 123"
     - `phone`: "+1234567890"
     - `first_login`: true
     - `learner_code`: 1
     - `locale`: "en"
     - `created_at`: Current timestamp
     - `updated_at`: Current timestamp

### Step 5: SQL Verification (Optional)
Run this SQL query in Supabase SQL Editor:
```sql
SELECT 
    id,
    handle,
    full_name,
    phone,
    first_login,
    learner_code,
    locale,
    created_at,
    updated_at
FROM profiles 
WHERE full_name = 'Test User 123';
```

## Expected Results

### ✅ Success Indicators
- **Console**: Success messages appear
- **Database**: New user profile exists with all fields populated
- **UI**: Registration completes with success message
- **Data Flow**: 
  - User created in `auth.users` (Supabase Auth)
  - Profile created in `profiles` with enhanced data
  - Settings created in `user_settings`

### ❌ Failure Indicators
- **Console**: Error messages or fallback to basic profile
- **Database**: Profile exists but missing new fields
- **UI**: Registration fails or shows error

## Troubleshooting

### If Console Shows Fallback Message
```
⚠️ Enhanced profile creation failed, using basic profile: <error>
✅ Basic user profile created successfully for user: <user_id>
📝 Note: Run database migration to enable full_name, phone, and first_login fields
```

**Solution:**
- Verify the database migration was applied correctly
- Check that columns exist in the profiles table

### If Registration Fails
- Check internet connection
- Verify Supabase credentials
- Check console for specific error messages

### If Data Not Saving
- Verify RLS policies allow profile creation
- Check that the user has proper permissions
- Ensure the profiles table has the correct structure

## Test Data Examples
Use different test data for multiple tests:
- **Test 1**: `Test User 123`, `+1234567890`, `testuser123@example.com`
- **Test 2**: `Jane Smith`, `+0987654321`, `janesmith@example.com`
- **Test 3**: `Bob Johnson`, `+1122334455`, `bobjohnson@example.com`

## Verification Checklist
- [ ] App runs without errors
- [ ] Registration form shows all fields
- [ ] Registration completes successfully
- [ ] Console shows success messages
- [ ] Database has new user profile
- [ ] All profile fields are populated correctly
- [ ] `first_login` is set to `true`

## Next Steps After Testing
1. If successful: The enhanced registration is working correctly
2. If issues: Follow troubleshooting steps above
3. Consider updating existing tests to include the new fields
4. Document any findings for future reference

## Support
If you encounter any issues during testing, check:
- Console logs for specific error messages
- Supabase logs for database errors
- Network tab for API call failures