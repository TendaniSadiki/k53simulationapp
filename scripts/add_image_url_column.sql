-- SQL to add image_url column to questions table
-- Run this in your Supabase dashboard SQL editor

-- Add image_url column to questions table
ALTER TABLE questions 
ADD COLUMN IF NOT EXISTS image_url TEXT;

-- Add video_url and audio_url columns for future media support
ALTER TABLE questions 
ADD COLUMN IF NOT EXISTS video_url TEXT;

ALTER TABLE questions 
ADD COLUMN IF NOT EXISTS audio_url TEXT;

-- Add localized_texts column for multilingual support
ALTER TABLE questions 
ADD COLUMN IF NOT EXISTS localized_texts JSONB;

-- Create index for better performance on media queries
CREATE INDEX IF NOT EXISTS idx_questions_image_url ON questions(image_url) WHERE image_url IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_questions_video_url ON questions(video_url) WHERE video_url IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_questions_audio_url ON questions(audio_url) WHERE audio_url IS NOT NULL;

-- Verify the columns were added
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'questions' 
AND column_name IN ('image_url', 'video_url', 'audio_url', 'localized_texts');