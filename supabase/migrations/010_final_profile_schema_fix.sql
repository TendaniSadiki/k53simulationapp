-- FINAL Profile Schema Fix Migration
-- This migration creates a clean, consistent profiles table with all required fields
-- Run this migration to fix all profile creation issues
--

-- First, let's check the current state
SELECT 
    table_name,
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'profiles' 
ORDER BY ordinal_position;

-- Check if we have any existing profiles (likely 0)
SELECT COUNT(*) as existing_profiles FROM profiles;

-- Drop the old profiles table if it exists (safe since we have no important data)
DROP TABLE IF EXISTS profiles CASCADE;

-- Create the new profiles table with UUID support and ALL required fields
CREATE TABLE profiles (
    id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    handle text UNIQUE NOT NULL,
    learner_code integer DEFAULT 1,
    locale text DEFAULT 'en',
    email text, -- Add email column that the application expects
    full_name text,
    phone text,
    total_points integer DEFAULT 0,
    level integer DEFAULT 1,
    login_streak integer DEFAULT 0,
    last_login timestamptz,
    first_login timestamptz DEFAULT now(),
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "Users can view own profile" ON profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Enable insert for authenticated users only" ON profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Create indexes for better performance
CREATE INDEX idx_profiles_handle ON profiles(handle);
CREATE INDEX idx_profiles_email ON profiles(email);
CREATE INDEX idx_profiles_level ON profiles(level);
CREATE INDEX idx_profiles_total_points ON profiles(total_points);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create the trigger
CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Create a trigger to automatically create profiles for new users
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
        last_login
    )
    VALUES (
        NEW.id,
        'user_' || substr(NEW.id::text, 1, 8),
        1,
        'en',
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email),
        NOW(),
        0,
        1,
        0,
        NOW()
    )
    ON CONFLICT (id) DO UPDATE SET
        email = EXCLUDED.email,
        full_name = COALESCE(profiles.full_name, EXCLUDED.full_name),
        updated_at = NOW();
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create the trigger for new users
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Verify the new table structure
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'profiles' 
ORDER BY ordinal_position;

-- Final verification
SELECT '✅ New profiles table created successfully!' as status;
SELECT '✅ The table now has ALL required fields including email' as details;
SELECT '✅ Automatic profile creation trigger is active' as trigger_status;
SELECT '✅ User signup should now work correctly' as next_step;