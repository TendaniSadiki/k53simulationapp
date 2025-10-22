-- Check if questions table exists and create it if not
-- This script uses simple conditional logic to avoid DO block syntax issues

-- First, check if the questions table exists by attempting to create it
-- This will fail gracefully if the table already exists
CREATE TABLE IF NOT EXISTS questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category TEXT NOT NULL,
    learner_code INTEGER NOT NULL,
    question_text TEXT NOT NULL,
    options JSONB NOT NULL,
    correct_index INTEGER NOT NULL,
    explanation TEXT NOT NULL,
    version INTEGER DEFAULT 1,
    is_active BOOLEAN DEFAULT TRUE,
    difficulty_level INTEGER DEFAULT 1 CHECK (difficulty_level BETWEEN 1 AND 5),
    image_url TEXT,
    video_url TEXT,
    audio_url TEXT,
    localized_texts JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes (will fail gracefully if they exist)
CREATE INDEX IF NOT EXISTS idx_questions_category ON questions(category);
CREATE INDEX IF NOT EXISTS idx_questions_learner_code ON questions(learner_code);
CREATE INDEX IF NOT EXISTS idx_questions_image_url ON questions(image_url) WHERE image_url IS NOT NULL;

-- Enable RLS
ALTER TABLE questions ENABLE ROW LEVEL SECURITY;

-- Create or replace RLS policies
DROP POLICY IF EXISTS "Authenticated users can read questions" ON questions;
CREATE POLICY "Authenticated users can read questions" ON questions
    FOR SELECT USING (auth.role() = 'authenticated' AND is_active = true);
    
DROP POLICY IF EXISTS "Allow question seeding" ON questions;
CREATE POLICY "Allow question seeding" ON questions
    FOR INSERT TO authenticated WITH CHECK (true);

-- Create or replace updated_at function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create or replace trigger
DROP TRIGGER IF EXISTS update_questions_updated_at ON questions;
CREATE TRIGGER update_questions_updated_at
    BEFORE UPDATE ON questions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Check if image_url column exists and add it if not
-- We'll use a simple approach by trying to add the column
-- This will fail gracefully if the column already exists
DO LANGUAGE plpgsql $$
BEGIN
    BEGIN
        ALTER TABLE questions ADD COLUMN image_url TEXT;
        RAISE NOTICE 'Added image_url column to questions table';
    EXCEPTION WHEN duplicate_column THEN
        RAISE NOTICE 'image_url column already exists';
    END;
    
    BEGIN
        ALTER TABLE questions ADD COLUMN video_url TEXT;
        RAISE NOTICE 'Added video_url column to questions table';
    EXCEPTION WHEN duplicate_column THEN
        RAISE NOTICE 'video_url column already exists';
    END;
    
    BEGIN
        ALTER TABLE questions ADD COLUMN audio_url TEXT;
        RAISE NOTICE 'Added audio_url column to questions table';
    EXCEPTION WHEN duplicate_column THEN
        RAISE NOTICE 'audio_url column already exists';
    END;
    
    BEGIN
        ALTER TABLE questions ADD COLUMN localized_texts JSONB;
        RAISE NOTICE 'Added localized_texts column to questions table';
    EXCEPTION WHEN duplicate_column THEN
        RAISE NOTICE 'localized_texts column already exists';
    END;
END
$$;

-- Verify table structure
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public' 
AND table_name = 'questions'
ORDER BY ordinal_position;

-- Show current row count in questions table
SELECT COUNT(*) as total_questions FROM questions;

-- Show notification about what was done
SELECT 'Table setup completed successfully. Ready for question insertion.' as status;