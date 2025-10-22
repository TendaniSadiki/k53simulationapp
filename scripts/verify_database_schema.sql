-- SQL script to verify database schema and test user signup functionality
-- Run this in your Supabase SQL editor to check if everything is set up correctly

-- 1. Check profiles table structure
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'profiles' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- 2. Check if required fields exist
SELECT 
    'full_name' as field_name,
    EXISTS(
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'profiles' AND column_name = 'full_name'
    ) as exists_in_schema,
    'TEXT' as expected_type
UNION ALL
SELECT 
    'phone',
    EXISTS(
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'profiles' AND column_name = 'phone'
    ),
    'TEXT'
UNION ALL
SELECT 
    'first_login',
    EXISTS(
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'profiles' AND column_name = 'first_login'
    ),
    'BOOLEAN'
UNION ALL
SELECT 
    'total_points',
    EXISTS(
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'profiles' AND column_name = 'total_points'
    ),
    'INTEGER'
UNION ALL
SELECT 
    'level',
    EXISTS(
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'profiles' AND column_name = 'level'
    ),
    'INTEGER'
UNION ALL
SELECT 
    'login_streak',
    EXISTS(
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'profiles' AND column_name = 'login_streak'
    ),
    'INTEGER';

-- 3. Check RLS policies
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual
FROM pg_policies 
WHERE tablename = 'profiles'
ORDER BY policyname;

-- 4. Check triggers (especially handle_new_user)
SELECT 
    trigger_name,
    event_manipulation,
    action_statement,
    action_timing
FROM information_schema.triggers 
WHERE event_object_table = 'profiles';

-- 5. Test the handle_new_user function by creating a test user
-- Note: This will create an actual auth user, so use with caution
-- Uncomment the following lines if you want to test the trigger:

/*
-- Create a test user (this will trigger the handle_new_user function)
INSERT INTO auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    invited_at,
    confirmation_token,
    confirmation_sent_at,
    recovery_token,
    recovery_sent_at,
    email_change_token_new,
    email_change,
    email_change_sent_at,
    last_sign_in_at,
    raw_app_meta_data,
    raw_user_meta_data,
    is_super_admin,
    created_at,
    updated_at,
    phone,
    phone_confirmed_at,
    phone_change,
    phone_change_token,
    phone_change_sent_at,
    email_change_token_current,
    email_change_confirm_status,
    banned_until,
    reauthentication_token,
    reauthentication_sent_at,
    is_sso_user
) VALUES (
    '00000000-0000-0000-0000-000000000000',
    gen_random_uuid(),
    'authenticated',
    'authenticated',
    'test_' || substr(gen_random_uuid()::text, 1, 8) || '@example.com',
    crypt('testpassword123', gen_salt('bf')),
    NOW(),
    NULL,
    '',
    NULL,
    '',
    NULL,
    '',
    '',
    NULL,
    NULL,
    '{"provider": "email", "providers": ["email"]}',
    '{"full_name": "Test User", "phone": "+1234567890"}',
    false,
    NOW(),
    NOW(),
    NULL,
    NULL,
    '',
    '',
    NULL,
    '',
    0,
    NULL,
    '',
    NULL,
    false
);

-- Check if profile was created automatically
SELECT 'Profile creation test:' as test_description;
SELECT 
    p.id,
    p.email,
    p.full_name,
    p.phone,
    p.first_login,
    p.total_points,
    p.level,
    p.login_streak
FROM profiles p
JOIN auth.users u ON p.id = u.id
WHERE u.email LIKE 'test_%@example.com'
LIMIT 1;

-- Clean up test user (optional)
-- DELETE FROM auth.users WHERE email LIKE 'test_%@example.com';
*/

-- 6. Show sample data from profiles table (if any exists)
SELECT 'Sample profiles data:' as description;
SELECT 
    id,
    email,
    full_name,
    phone,
    first_login,
    total_points,
    level,
    login_streak,
    created_at
FROM profiles 
LIMIT 5;

-- 7. Summary report
SELECT 
    'Database Schema Verification Complete' as status,
    (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = 'profiles') as total_profile_columns,
    (SELECT COUNT(*) FROM pg_policies WHERE tablename = 'profiles') as total_rls_policies,
    (SELECT COUNT(*) FROM information_schema.triggers WHERE event_object_table = 'profiles') as total_triggers;