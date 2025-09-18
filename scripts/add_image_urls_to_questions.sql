-- Script to add image_url field to existing questions
-- Run this after the main seed script to add images to relevant questions

-- First, ensure the image_url column exists (if not already added by migration)
ALTER TABLE questions ADD COLUMN IF NOT EXISTS image_url TEXT;

-- Update questions with appropriate road sign images
-- Rules of the Road questions that need images

-- Q3 - Overtaking prohibition
UPDATE questions 
SET image_url = 'assets/individual_signs/Overtaking prohibited for the next 2km.png'
WHERE question_text = 'When may you not overtake another vehicle?... When you ...'
AND category = 'rules_of_road';

-- Q6 - Yield sign
UPDATE questions 
SET image_url = 'assets/individual_signs/Indicates that you must yield to other traffic. Gi.png'
WHERE question_text = 'At an intersection...'
AND category = 'rules_of_road'
AND explanation LIKE '%yield to oncoming traffic%';

-- Q8 - Speed limit sign
UPDATE questions 
SET image_url = 'assets/individual_signs/Maximum speed limit allowed.png'
WHERE question_text = 'Unless otherwise shown by a sign, the general speed limit in an urban area is ...km/h.'
AND category = 'rules_of_road';

-- Q9 - Speed limit sign
UPDATE questions 
SET image_url = 'assets/individual_signs/Maximum speed limit allowed.png'
WHERE question_text = 'The legal speed limit which you may drive...'
AND category = 'rules_of_road';

-- Q13 - Residential area
UPDATE questions 
SET image_url = 'assets/individual_signs/Residential area.png'
WHERE question_text = 'What is the longest period that a vehicle may be parked on one place on a road outside urban areas?'
AND category = 'rules_of_road';

-- Q15 - No stopping/parking
UPDATE questions 
SET image_url = 'assets/individual_signs/No stopping to ensure traffic flow and prevent dri.png'
WHERE question_text = 'You are not allowed to stop...'
AND category = 'rules_of_road'
AND explanation LIKE '%pavement%';

-- Q16 - No stopping/parking
UPDATE questions 
SET image_url = 'assets/individual_signs/No stopping to ensure traffic flow and prevent dri.png'
WHERE question_text = 'You are not allowed to stop...'
AND category = 'rules_of_road'
AND explanation LIKE '%no parking%';

-- Q18 - Overtaking prohibition
UPDATE questions 
SET image_url = 'assets/individual_signs/No over taking vehicles by goods vehicles for the next 500m.png'
WHERE question_text = 'You may overtake another vehicle on the left hand side...'
AND category = 'rules_of_road';

-- Parking related questions
UPDATE questions 
SET image_url = 'assets/individual_signs/Parking only if you pay the parking fee.png'
WHERE question_text LIKE '%parking%' 
AND category = 'rules_of_road'
AND image_url IS NULL;

UPDATE questions 
SET image_url = 'assets/individual_signs/Parking_30min_Week_09-16_Sat_08-13.png.png'
WHERE question_text LIKE '%park%' 
AND category = 'rules_of_road'
AND image_url IS NULL;

-- Additional road sign questions
UPDATE questions 
SET image_url = 'assets/individual_signs/Over taking vehicles is prohibited for the next 500m.png'
WHERE question_text LIKE '%overtak%' 
AND category = 'rules_of_road'
AND image_url IS NULL;

-- Verify the updates
SELECT 'Updated ' || COUNT(*) || ' questions with image URLs' AS result 
FROM questions 
WHERE image_url IS NOT NULL;

-- Show which questions now have images
SELECT category, question_text, image_url 
FROM questions 
WHERE image_url IS NOT NULL
ORDER BY category, question_text;