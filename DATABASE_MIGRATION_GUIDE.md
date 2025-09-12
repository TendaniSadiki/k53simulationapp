# Database Migration Guide for K53 App

## Current Issues Identified

1. **Missing `image_url` column** in `questions` table
2. **Missing `referrer_id` column** in `referrals` table  
3. **Incomplete question data** - Only 5 road sign questions instead of 52+
4. **No image URLs populated** for road sign questions

## Step-by-Step Migration Process

### 1. Apply Database Schema Changes

Run these SQL commands in your Supabase dashboard SQL editor:

```sql
-- Add missing columns to questions table
ALTER TABLE questions 
ADD COLUMN image_url TEXT;

ALTER TABLE questions 
ADD COLUMN video_url TEXT;

ALTER TABLE questions 
ADD COLUMN audio_url TEXT;

ALTER TABLE questions 
ADD COLUMN localized_texts JSONB;

-- Add missing referrer_id column to referrals table
ALTER TABLE referrals 
ADD COLUMN referrer_id UUID REFERENCES auth.users(id);

-- Create indexes for better performance
CREATE INDEX idx_questions_image_url ON questions(image_url) WHERE image_url IS NOT NULL;
CREATE INDEX idx_questions_video_url ON questions(video_url) WHERE video_url IS NOT NULL;
CREATE INDEX idx_questions_audio_url ON questions(audio_url) WHERE audio_url IS NOT NULL;
CREATE INDEX idx_referrals_referrer_id ON referrals(referrer_id);
```

### 2. Run Complete Seeding Script

After applying the schema changes, run the complete seeding script:

```bash
dart run scripts/complete_k53_seed.dart
```

This will:
- Populate the database with 196+ complete K53 questions
- Add proper `image_url` values for road sign questions
- Ensure all categories have complete question sets

### 3. Rebuild Offline Cache

After seeding, the app needs to rebuild its offline cache. This happens automatically when:
- The app is restarted
- Or you can trigger it manually in the app settings

### 4. Verify the Changes

Check that the migration was successful:

1. **Road sign questions**: Should show 52+ questions instead of 5
2. **Image URLs**: Should not be null for road sign questions
3. **Categories**: All categories should have complete question sets

## Expected Results After Migration

- ✅ Road sign mock exams will display images correctly
- ✅ All 52+ road sign questions will be available
- ✅ No more database schema errors
- ✅ Proper image paths like `assets/images/signs/parking.png`

## Troubleshooting

If you encounter issues:

1. **Clear existing data**: The seeding script can clear existing questions if needed
2. **Check environment variables**: Ensure `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` are set
3. **Verify database connection**: Test the connection with the check script

## Files Involved

- [`supabase/migrations/004_add_image_url_column.sql`](../supabase/migrations/004_add_image_url_column.sql) - Main migration
- [`scripts/add_image_url_column.sql`](../scripts/add_image_url_column.sql) - Alternative migration script
- [`scripts/complete_k53_seed.dart`](../scripts/complete_k53_seed.dart) - Complete question seeding
- [`scripts/k53_question_database.dart`](../scripts/k53_question_database.dart) - Question data source