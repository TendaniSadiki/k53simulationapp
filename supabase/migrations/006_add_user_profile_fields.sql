-- Migration: Add missing user profile fields for enhanced authentication
-- Created: 2025-10-20
-- Description: Adds email, full_name, phone, first_login, and gamification fields to profiles table

-- Add missing fields to profiles table
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS email TEXT,
ADD COLUMN IF NOT EXISTS full_name TEXT,
ADD COLUMN IF NOT EXISTS phone TEXT,
ADD COLUMN IF NOT EXISTS first_login BOOLEAN DEFAULT TRUE,
ADD COLUMN IF NOT EXISTS total_points INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS level INTEGER DEFAULT 1,
ADD COLUMN IF NOT EXISTS login_streak INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS last_login_date TIMESTAMPTZ;

-- Update the handle_new_user function to include new fields
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
        last_login_date
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

-- Create indexes for better performance on new fields
CREATE INDEX IF NOT EXISTS idx_profiles_email ON profiles(email);
CREATE INDEX IF NOT EXISTS idx_profiles_level ON profiles(level);
CREATE INDEX IF NOT EXISTS idx_profiles_total_points ON profiles(total_points);
CREATE INDEX IF NOT EXISTS idx_profiles_last_login ON profiles(last_login_date);

-- Update existing profiles with email if missing
-- Note: This update is optional and can be skipped if there are type issues
-- The main functionality will work for new users created after this migration

-- Add comment explaining the migration
COMMENT ON COLUMN profiles.email IS 'User email address from authentication';
COMMENT ON COLUMN profiles.full_name IS 'User full name for display';
COMMENT ON COLUMN profiles.phone IS 'User phone number for contact';
COMMENT ON COLUMN profiles.first_login IS 'Indicates if this is the user''s first login';
COMMENT ON COLUMN profiles.total_points IS 'Total points earned for gamification';
COMMENT ON COLUMN profiles.level IS 'User level for gamification progression';
COMMENT ON COLUMN profiles.login_streak IS 'Consecutive days user has logged in';
COMMENT ON COLUMN profiles.last_login_date IS 'Last time user logged into the app';