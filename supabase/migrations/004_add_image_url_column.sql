-- Migration to add image_url column to questions table for road sign images
-- This enables storing image paths for visual questions

-- Add image_url column to questions table
ALTER TABLE questions 
ADD COLUMN image_url TEXT;

-- Add video_url and audio_url columns for future media support
ALTER TABLE questions 
ADD COLUMN video_url TEXT;

ALTER TABLE questions 
ADD COLUMN audio_url TEXT;

-- Add localized_texts column for multilingual support
ALTER TABLE questions 
ADD COLUMN localized_texts JSONB;

-- Update existing questions that should have images
-- This will be populated by the seeding script
UPDATE questions 
SET image_url = 'assets/images/signs/parking.png'
WHERE question_text LIKE '%blue rectangular sign with a white "P"%';

UPDATE questions 
SET image_url = 'assets/images/signs/stop_ahead.png'  
WHERE question_text LIKE '%triangular sign with red border%';

-- Create index for better performance on media queries
CREATE INDEX idx_questions_image_url ON questions(image_url) WHERE image_url IS NOT NULL;
CREATE INDEX idx_questions_video_url ON questions(video_url) WHERE video_url IS NOT NULL;
CREATE INDEX idx_questions_audio_url ON questions(audio_url) WHERE audio_url IS NOT NULL;