-- Migration: Fix profiles table schema issues
-- Created: 2025-10-20
-- Description: Adds missing updated_at column and ensures all required fields exist

-- Add updated_at column if it doesn't exist
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

-- Ensure all required columns exist with proper defaults
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW(),
ADD COLUMN IF NOT EXISTS email TEXT,
ADD COLUMN IF NOT EXISTS full_name TEXT,
ADD COLUMN IF NOT EXISTS phone TEXT,
ADD COLUMN IF NOT EXISTS first_login BOOLEAN DEFAULT TRUE,
ADD COLUMN IF NOT EXISTS total_points INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS level INTEGER DEFAULT 1,
ADD COLUMN IF NOT EXISTS login_streak INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS last_login_date TIMESTAMPTZ;

-- Update the handle_new_user function to include all fields
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
        TRUE,
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
    
    INSERT INTO public.user_settings (id)
    VALUES (NEW.id)
    ON CONFLICT (id) DO NOTHING;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_profiles_email ON profiles(email);
CREATE INDEX IF NOT EXISTS idx_profiles_level ON profiles(level);
CREATE INDEX IF NOT EXISTS idx_profiles_total_points ON profiles(total_points);
CREATE INDEX IF NOT EXISTS idx_profiles_last_login ON profiles(last_login_date);
CREATE INDEX IF NOT EXISTS idx_profiles_updated_at ON profiles(updated_at);

-- Update existing profiles with missing fields
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

-- Add comments explaining the columns
COMMENT ON COLUMN profiles.email IS 'User email address from authentication';
COMMENT ON COLUMN profiles.full_name IS 'User full name for display';
COMMENT ON COLUMN profiles.phone IS 'User phone number for contact';
COMMENT ON COLUMN profiles.first_login IS 'Indicates if this is the user''s first login';
COMMENT ON COLUMN profiles.total_points IS 'Total points earned for gamification';
COMMENT ON COLUMN profiles.level IS 'User level for gamification progression';
COMMENT ON COLUMN profiles.login_streak IS 'Consecutive days user has logged in';
COMMENT ON COLUMN profiles.last_login_date IS 'Last time user logged into the app';
COMMENT ON COLUMN profiles.created_at IS 'When the user profile was created';
COMMENT ON COLUMN profiles.updated_at IS 'When the user profile was last updated';