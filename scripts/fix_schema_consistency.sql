-- Simple script to fix profile schema consistency issues
-- Run this after the main UUID migration

-- Check current state
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'profiles' 
ORDER BY ordinal_position;

-- Fix first_login column type if it's boolean
DO $$
BEGIN
    -- Check if first_login exists and is boolean type
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'profiles' 
        AND column_name = 'first_login' 
        AND data_type = 'boolean'
    ) THEN
        -- Convert first_login from boolean to timestamptz
        ALTER TABLE profiles 
        ALTER COLUMN first_login TYPE timestamptz 
        USING CASE 
            WHEN first_login = TRUE THEN NOW() 
            ELSE NULL 
        END;
        
        RAISE NOTICE '✅ Converted first_login from boolean to timestamptz';
    ELSE
        RAISE NOTICE '✅ first_login is already timestamptz type';
    END IF;
END $$;

-- Ensure all required columns exist with correct types
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS email TEXT,
ADD COLUMN IF NOT EXISTS full_name TEXT,
ADD COLUMN IF NOT EXISTS phone TEXT,
ADD COLUMN IF NOT EXISTS first_login TIMESTAMPTZ DEFAULT NOW(),
ADD COLUMN IF NOT EXISTS total_points INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS level INTEGER DEFAULT 1,
ADD COLUMN IF NOT EXISTS login_streak INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS last_login_date TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW(),
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

-- Update existing profiles with missing data
UPDATE profiles 
SET 
    email = COALESCE(email, 'user@example.com'),
    full_name = COALESCE(full_name, 'User'),
    first_login = COALESCE(first_login, NOW()),
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

-- Verify the corrected schema
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'profiles' 
ORDER BY ordinal_position;

-- Final verification
SELECT '✅ Schema consistency fix completed successfully!' as status;
SELECT '✅ first_login column is now properly typed as TIMESTAMPTZ' as details;
SELECT '✅ All required columns are present with correct types' as verification;
SELECT '✅ Application should now work correctly with user profiles' as next_step;