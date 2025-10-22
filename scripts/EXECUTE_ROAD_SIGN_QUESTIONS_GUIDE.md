# Road Sign Questions Execution Guide

## Overview
This guide provides instructions for executing the SQL files to populate the K53 test database with road sign questions and their corresponding images.

## Prerequisites
- Supabase database set up with the correct schema
- Database tables created (run `scripts/check_and_create_tables.sql` first if needed)

## Execution Order

### 1. First: Create Database Tables (if not already created)
```sql
-- Run this in Supabase SQL Editor
\i scripts/check_and_create_tables.sql
```

### 2. Second: Insert Road Sign Questions
```sql
-- Run this in Supabase SQL Editor  
\i scripts/road_sign_questions_output_fixed.sql
```

### 3. Third: Insert Rules of the Road Questions
```sql
-- Run this in Supabase SQL Editor
\i scripts/seed_evolve_questions_with_images.sql
```

## File Details

### `scripts/road_sign_questions_output_fixed.sql`
- **Purpose**: Inserts 19 road sign specific questions
- **Categories**: regulatory, prohibition, command, warning, freeway, informational, mass_dimension
- **Images**: 12 questions have associated images, 7 use NULL (no image available)

### `scripts/seed_evolve_questions_with_images.sql`  
- **Purpose**: Inserts 72 rules of the road questions + vehicle controls
- **Categories**: rules_of_road, vehicle_controls
- **Images**: 2 questions have associated images, 70 use NULL (no image available)

## Verification

After executing the SQL files, verify the insertions:

```sql
-- Check road sign questions
SELECT category, COUNT(*) as question_count 
FROM questions 
WHERE category IN ('regulatory', 'prohibition', 'command', 'warning', 'freeway', 'informational', 'mass_dimension')
GROUP BY category;

-- Check total questions with images
SELECT COUNT(*) as questions_with_images FROM questions WHERE image_url IS NOT NULL;
SELECT COUNT(*) as total_questions FROM questions;
```

## Expected Results

- **Total Questions**: ~83 questions (based on current analytics: 49 road signs + 25 vehicle controls + 7 general knowledge + 2 rules of road)
- **Questions with Images**: 14 questions with verified working images
- **Questions without Images**: 69 questions (using NULL values appropriately)

## Troubleshooting

### Common Issues

1. **Image Loading Errors**: If images don't load in the app, verify:
   - All image paths in the database point to existing files
   - The Flutter app has the correct asset declarations in `pubspec.yaml`

2. **Database Errors**: If you get foreign key or constraint errors:
   - Make sure to run the table creation script first
   - Check that all required tables exist

3. **Duplicate Questions**: If questions are duplicated:
   - Clear the questions table before re-running: `DELETE FROM questions;`

### Verification Script

Use the provided Dart script to verify all image paths:

```bash
dart run scripts/verify_sql_image_paths.dart
```

This will check that all image URLs in the SQL files point to actual files that exist.

## Notes

- The image paths now use the organized subfolder structure (`assets/individual_signs/CATEGORY/filename.png`)
- Some questions don't have corresponding images and use NULL values
- All image paths have been verified to exist in the current file structure