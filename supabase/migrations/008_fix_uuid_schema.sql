-- Fix UUID schema mismatch in profiles table
-- This migration converts the profiles table to use UUID type for the id column

-- First, check if we need to alter the column type
DO $$
BEGIN
    -- Check if the id column is currently bigint type
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'profiles' 
        AND column_name = 'id' 
        AND data_type = 'bigint'
    ) THEN
        -- Convert id column from bigint to uuid type
        ALTER TABLE profiles 
        ALTER COLUMN id TYPE uuid USING id::text::uuid;
        
        RAISE NOTICE 'Successfully converted profiles.id from bigint to uuid type';
    ELSE
        RAISE NOTICE 'profiles.id is already uuid type, no conversion needed';
    END IF;
END $$;

-- Ensure the foreign key relationship with auth.users is correct
DO $$
BEGIN
    -- Check if the foreign key constraint exists
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'profiles_id_fkey' 
        AND table_name = 'profiles'
    ) THEN
        -- Add foreign key constraint to auth.users
        ALTER TABLE profiles 
        ADD CONSTRAINT profiles_id_fkey 
        FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE;
        
        RAISE NOTICE 'Added foreign key constraint profiles_id_fkey';
    ELSE
        RAISE NOTICE 'Foreign key constraint profiles_id_fkey already exists';
    END IF;
END $$;

-- Update RLS policies to work with UUID type
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON profiles;

-- Recreate RLS policies with proper UUID handling
CREATE POLICY "Users can view own profile" ON profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Enable insert for authenticated users only" ON profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Add any missing columns that might be needed
DO $$
BEGIN
    -- Check and add full_name column if missing
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'profiles' 
        AND column_name = 'full_name'
    ) THEN
        ALTER TABLE profiles ADD COLUMN full_name text;
        RAISE NOTICE 'Added full_name column to profiles';
    END IF;
    
    -- Check and add phone column if missing
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'profiles' 
        AND column_name = 'phone'
    ) THEN
        ALTER TABLE profiles ADD COLUMN phone text;
        RAISE NOTICE 'Added phone column to profiles';
    END IF;
    
    -- Check and add total_points column if missing
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'profiles' 
        AND column_name = 'total_points'
    ) THEN
        ALTER TABLE profiles ADD COLUMN total_points integer DEFAULT 0;
        RAISE NOTICE 'Added total_points column to profiles';
    END IF;
    
    -- Check and add level column if missing
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'profiles' 
        AND column_name = 'level'
    ) THEN
        ALTER TABLE profiles ADD COLUMN level integer DEFAULT 1;
        RAISE NOTICE 'Added level column to profiles';
    END IF;
    
    -- Check and add login_streak column if missing
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'profiles' 
        AND column_name = 'login_streak'
    ) THEN
        ALTER TABLE profiles ADD COLUMN login_streak integer DEFAULT 0;
        RAISE NOTICE 'Added login_streak column to profiles';
    END IF;
    
    -- Check and add last_login column if missing
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'profiles' 
        AND column_name = 'last_login'
    ) THEN
        ALTER TABLE profiles ADD COLUMN last_login timestamptz;
        RAISE NOTICE 'Added last_login column to profiles';
    END IF;
    
    -- Check and add first_login column if missing
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'profiles' 
        AND column_name = 'first_login'
    ) THEN
        ALTER TABLE profiles ADD COLUMN first_login timestamptz DEFAULT now();
        RAISE NOTICE 'Added first_login column to profiles';
    END IF;
    
    -- Check and add updated_at column if missing
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'profiles' 
        AND column_name = 'updated_at'
    ) THEN
        ALTER TABLE profiles ADD COLUMN updated_at timestamptz DEFAULT now();
        RAISE NOTICE 'Added updated_at column to profiles';
    END IF;
END $$;

-- Create or replace the updated_at trigger
DROP TRIGGER IF EXISTS update_profiles_updated_at ON profiles;
CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Verify the schema changes
DO $$
BEGIN
    RAISE NOTICE 'Database schema migration completed successfully';
    RAISE NOTICE 'profiles table now supports UUID type for user IDs';
    RAISE NOTICE 'All required columns have been added';
END $$;