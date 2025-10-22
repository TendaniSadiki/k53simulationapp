-- Check current question statistics in the database
-- Run this in Supabase SQL Editor to see current state

-- Count total questions
SELECT 'Total Questions' AS metric, COUNT(*) AS count FROM questions;

-- Count questions with images
SELECT 'Questions with Images' AS metric, COUNT(*) AS count FROM questions WHERE image_url IS NOT NULL;

-- Count questions without images
SELECT 'Questions without Images' AS metric, COUNT(*) AS count FROM questions WHERE image_url IS NULL;

-- Breakdown by category
SELECT 
    category,
    COUNT(*) AS total_questions,
    COUNT(image_url) AS questions_with_images,
    COUNT(*) - COUNT(image_url) AS questions_without_images
FROM questions 
GROUP BY category 
ORDER BY category;

-- Show sample of questions with images
SELECT id, category, learner_code, question_text, image_url 
FROM questions 
WHERE image_url IS NOT NULL 
LIMIT 10;

-- Show sample of questions without images
SELECT id, category, learner_code, question_text 
FROM questions 
WHERE image_url IS NULL 
LIMIT 10;