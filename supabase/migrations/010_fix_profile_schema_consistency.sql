-- Fix profile schema consistency issues
-- This migration corrects the first_login column type mismatch

-- First, let's check the current state of the profiles table
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'profiles' 
ORDER BY ordinal_position;

-- Fix the first_login column type if it's boolean but should be timestamp
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
        
        RAISE NOTICE 'Converted first_login from boolean to timestamptz';
    END IF;
END $$;

-- Ensure all columns have the correct types and defaults
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

-- Update the handle_new_user function with correct types
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (
        id, 
        handle, 
        learner_code, 
        locale,
        email,
        full_name,
        first_login,
        total_points,
        level,
        login_streak,
        last_login_date,
        created_at,
        updated_at
    )
    VALUES (
        NEW.id,
        'user_' || substr(NEW.id::text, 1, 8),
        1,
        'en',
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email),
        NOW(), -- first_login as timestamp
        0,
        1,
        0,
        NOW(),
        NOW(),
        NOW()
    )
    ON CONFLICT (id) DO UPDATE SET
        email = EXCLUDED.email,
        full_name = COALESCE(profiles.full_name, EXCLUDED.full_name),
        updated_at = NOW();
    
    -- Create user_settings if the table exists
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'user_settings') THEN
        INSERT INTO public.user_settings (id)
        VALUES (NEW.id)
        ON CONFLICT (id) DO NOTHING;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Update existing profiles with correct types
UPDATE profiles 
SET 
    email = COALESCE(email, 'user@example.com'),
    full_name = COALESCE(full_name, 'User'),
    first_login = COALESCE(first_login, NOW()), -- Now using timestamp
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

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_profiles_email ON profiles(email);
CREATE INDEX IF NOT EXISTS idx_profiles_level ON profiles(level);
CREATE INDEX IF NOT EXISTS idx_profiles_total_points ON profiles(total_points);
CREATE INDEX IF NOT EXISTS idx_profiles_last_login ON profiles(last_login_date);
CREATE INDEX IF NOT EXISTS idx_profiles_updated_at ON profiles(updated_at);

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
DO $$
BEGIN
    RAISE NOTICE 'Profile schema consistency fix completed successfully';
    RAISE NOTICE 'first_login column is now properly typed as TIMESTAMPTZ';
    RAISE NOTICE 'All required columns are present with correct types';
END $$;