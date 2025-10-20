# Database Migration Application Guide

## Critical Issue
The K53 app is experiencing database schema issues that prevent user profiles from working properly. The errors include:
- "invalid input syntax for type bigint" - UUID type mismatch
- "Could not find the 'updated_at' column" - Missing column

## Solution
Apply the database migration `007_fix_profiles_schema.sql` to fix these issues.

## Step-by-Step Instructions

### Option 1: Apply via Supabase Dashboard (Recommended)

1. **Open Supabase Dashboard**
   - Go to https://supabase.com/dashboard
   - Select your project

2. **Navigate to SQL Editor**
   - In the left sidebar, click "SQL Editor"
   - Click "New query"

3. **Copy and Paste Migration SQL**
   - Open the file: `supabase/migrations/007_fix_profiles_schema.sql`
   - Copy ALL the SQL content
   - Paste it into the SQL Editor

4. **Execute the Migration**
   - Click "Run" or press Ctrl+Enter
   - Wait for execution to complete

5. **Verify Success**
   - You should see "Success" message
   - No errors should appear

### Option 2: Apply via Command Line (Advanced)

If you have Supabase CLI installed:

```bash
# Navigate to project directory
cd c:\Users\EdmondSadiki\Desktop\code\my-projects\k53app

# Apply the migration
supabase db push
```

### Option 3: Manual SQL Execution

If the above options don't work, you can execute the SQL manually in sections:

1. **Add missing columns:**
```sql
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW(),
ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW(),
ADD COLUMN IF NOT EXISTS email TEXT,
ADD COLUMN IF NOT EXISTS full_name TEXT,
ADD COLUMN IF NOT EXISTS phone TEXT,
ADD COLUMN IF NOT EXISTS first_login BOOLEAN DEFAULT TRUE,
ADD COLUMN IF NOT EXISTS total_points INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS level INTEGER DEFAULT 1,
ADD COLUMN IF NOT EXISTS login_streak INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS last_login_date TIMESTAMPTZ;
```

2. **Update existing profiles:**
```sql
UPDATE profiles 
SET 
    email = COALESCE(email, 'user@example.com'),
    full_name = COALESCE(full_name, 'User'),
    first_login = COALESCE(first_login, TRUE),
    total_points = COALESCE(total_points, 0),
    level = COALESCE(level, 1),
    login_streak = COALESCE(login_streak, 0),
    updated_at = COALESCE(updated_at, NOW())
WHERE 
    email IS NULL OR 
    full_name IS NULL OR 
    first_login IS NULL OR 
    total_points IS NULL OR 
    level IS NULL OR 
    login_streak IS NULL OR 
    updated_at IS NULL;
```

## Verification Steps

After applying the migration:

1. **Hot Reload the App**
   - In the terminal where `flutter run` is running, press `r`
   - Wait for the app to restart

2. **Test Profile Functionality**
   - Navigate to the profile screen
   - Check if database errors are gone
   - Try editing profile information

3. **Test User Registration**
   - Sign out
   - Create a new user account
   - Verify profile is created successfully

## Expected Results

✅ **No MaterialLocalizations errors**  
✅ **Profile screen loads without database errors**  
✅ **User registration creates profiles successfully**  
✅ **Profile updates work correctly**  
✅ **Gamification fields accessible**

## Troubleshooting

### If errors persist:
- **Check migration was applied**: Look for the new columns in your Supabase table editor
- **Clear app cache**: Sometimes the app needs a fresh start
- **Check RLS policies**: Ensure profiles table has proper Row Level Security

### Common Issues:
- **Migration failed**: Check SQL syntax and permissions
- **Columns still missing**: The migration might have partial success
- **App still shows errors**: Hot restart the app (press `R` instead of `r`)

## Next Steps

Once the migration is successfully applied:
1. Re-enable session recovery dialogs in `app.dart`
2. Test all authentication flows
3. Verify offline functionality
4. Complete remaining UI screens

## Support

If you continue to experience issues:
1. Check the Supabase logs for detailed error messages
2. Verify your environment variables are correct
3. Ensure your Supabase project is properly configured