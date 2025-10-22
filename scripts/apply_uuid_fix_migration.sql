-- Simple script to apply the UUID fix migration
-- Run this in your Supabase SQL editor

-- First, let's check the current state of the profiles table
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'profiles' 
ORDER BY ordinal_position;

-- Check if we have any existing data that might need conversion
SELECT COUNT(*) as total_profiles FROM profiles;

-- Apply the migration
-- This will convert the id column from bigint to uuid type
ALTER TABLE profiles 
ALTER COLUMN id TYPE uuid USING id::text::uuid;

-- Verify the change worked
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'profiles' 
AND column_name = 'id';

-- Add any missing columns that the app expects
DO $$
BEGIN
    -- Add full_name if missing
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'profiles' 
        AND column_name = 'full_name'
    ) THEN
        ALTER TABLE profiles ADD COLUMN full_name text;
    END IF;
    
    -- Add phone if missing
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'profiles' 
        AND column_name = 'phone'
    ) THEN
        ALTER TABLE profiles ADD COLUMN phone text;
    END IF;
    
    -- Add total_points if missing
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'profiles' 
        AND column_name = 'total_points'
    ) THEN
        ALTER TABLE profiles ADD COLUMN total_points integer DEFAULT 0;
    END IF;
    
    -- Add level if missing
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'profiles' 
        AND column_name = 'level'
    ) THEN
        ALTER TABLE profiles ADD COLUMN level integer DEFAULT 1;
    END IF;
    
    -- Add login_streak if missing
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'profiles' 
        AND column_name = 'login_streak'
    ) THEN
        ALTER TABLE profiles ADD COLUMN login_streak integer DEFAULT 0;
    END IF;
    
    -- Add last_login if missing
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'profiles' 
        AND column_name = 'last_login'
    ) THEN
        ALTER TABLE profiles ADD COLUMN last_login timestamptz;
    END IF;
    
    -- Add first_login if missing
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'profiles' 
        AND column_name = 'first_login'
    ) THEN
        ALTER TABLE profiles ADD COLUMN first_login timestamptz DEFAULT now();
    END IF;
    
    -- Add updated_at if missing
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'profiles' 
        AND column_name = 'updated_at'
    ) THEN
        ALTER TABLE profiles ADD COLUMN updated_at timestamptz DEFAULT now();
    END IF;
END $$;

-- Verify all columns are present
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'profiles' 
ORDER BY ordinal_position;

-- Test the schema by trying to insert a test profile (this should work now)
-- Note: Replace 'test-uuid-here' with an actual UUID from your auth.users table
-- INSERT INTO profiles (id, handle, learner_code, locale, full_name, phone) 
-- VALUES ('test-uuid-here', 'test_user', 1, 'en', 'Test User', '1234567890');

-- Final verification
SELECT 'Migration completed successfully!' as status;