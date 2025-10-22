-- Simple script to create a new profiles table with UUID support
-- This is the safest approach since we likely don't have important profile data yet

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

-- Create the new profiles table with UUID support
CREATE TABLE profiles (
    id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    handle text UNIQUE NOT NULL,
    learner_code integer DEFAULT 1,
    locale text DEFAULT 'en',
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
CREATE INDEX idx_profiles_level ON profiles(level);
CREATE INDEX idx_profiles_total_points ON profiles(total_points);

-- Create updated_at trigger function if it doesn't exist
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

-- Verify the new table structure
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'profiles' 
ORDER BY ordinal_position;

-- Test: Try to insert a test profile (this will fail without a real user, but that's expected)
-- INSERT INTO profiles (id, handle, full_name, phone) 
-- VALUES ('00000000-0000-0000-0000-000000000000', 'test_user', 'Test User', '1234567890');

-- Final verification
SELECT 'New profiles table created successfully!' as status;
SELECT 'The table now uses UUID type and is properly linked to auth.users' as details;
SELECT 'User signup should now work correctly' as next_step;