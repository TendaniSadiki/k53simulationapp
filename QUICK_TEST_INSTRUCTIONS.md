# Quick Test Instructions - Enhanced User Registration

## App is Running - Follow These Steps:

### Step 1: Navigate to Registration
1. On the login screen, tap "Don't have an account? Sign Up"
2. You should see additional fields appear:
   - Full Name
   - Phone Number

### Step 2: Fill Out Test Data
Use this test data:
- **Full Name**: `Test User 456`
- **Phone**: `+1234567890`
- **Email**: `testuser456@example.com` (use a unique email)
- **Password**: `password123`

### Step 3: Submit Registration
1. Tap "Create Account"
2. Watch for:
   - Loading indicator
   - Success message: "Please check your email for verification link"

### Step 4: Check Console Output
Look for these success messages in your terminal/console:
```
✅ User profile created with enhanced fields for user: <user_id>
📝 Profile data: full_name=Test User 456, phone=+1234567890, first_login=true
```

### Step 5: Verify in Supabase
1. Open your Supabase dashboard
2. Go to Table Editor → profiles table
3. Find the user with full_name = "Test User 456"
4. Verify all fields are populated:
   - full_name: "Test User 456"
   - phone: "+1234567890"
   - first_login: true
   - handle: auto-generated
   - learner_code: 1
   - locale: "en"

## Expected Results:
- ✅ Registration completes successfully
- ✅ Console shows success messages
- ✅ Database has complete user profile with all new fields
- ✅ Profile data is saved to `profiles` table (not just `auth.users`)

## If You See Issues:
- Check console for error messages
- Verify database columns exist (full_name, phone, first_login)
- Ensure internet connection is stable

Let me know what you see in the console and if the registration works!