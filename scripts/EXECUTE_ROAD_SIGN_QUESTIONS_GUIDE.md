# Road Sign Questions Execution Guide

## Prerequisites
- Access to your Supabase project at https://app.supabase.com/
- Your Supabase URL and service role key from `.env` file

## Step 1: Check and Create Tables (If Needed)

First, run the table verification script to ensure the questions table exists:

### Method A: Via Supabase Dashboard (Recommended)
1. Go to [Supabase Dashboard](https://app.supabase.com/)
2. Select your project
3. Navigate to "SQL Editor"
4. Copy and paste the entire content from [`scripts/check_and_create_tables.sql`](scripts/check_and_create_tables.sql:1)
5. Click "Run" to execute

### Method B: Using Supabase CLI
```bash
supabase db execute --file scripts/check_and_create_tables.sql
```

## Step 2: Execute Road Sign Questions

After verifying the table exists, execute the road sign questions:

### Method A: Via Supabase Dashboard (Recommended)
1. In the SQL Editor, copy and paste the entire content from [`scripts/road_sign_questions_output.sql`](scripts/road_sign_questions_output.sql:1)
2. Click "Run" to execute the SQL

### Method B: Using Supabase CLI
```bash
supabase db execute --file scripts/road_sign_questions_output.sql
```

## Step 3: Verify Execution

After execution, verify the questions were inserted correctly:

```sql
-- Check total road sign questions
SELECT COUNT(*) FROM questions WHERE category = 'road_signs';

-- View sample questions with images
SELECT id, question_text, image_url 
FROM questions 
WHERE category = 'road_signs' 
AND image_url IS NOT NULL 
LIMIT 5;

-- Check all inserted questions
SELECT id, category, learner_code, question_text, image_url
FROM questions 
WHERE category = 'road_signs'
ORDER BY created_at DESC;
```

## Troubleshooting

### Common Issues:

1. **"relation 'questions' does not exist"**:
   - Run the [`scripts/check_and_create_tables.sql`](scripts/check_and_create_tables.sql:1) first
   - This will create the table if it doesn't exist

2. **Permission denied**:
   - Ensure you're using the service role key for database modifications
   - Check your RLS (Row Level Security) policies

3. **JSON parsing error**:
   - Verify the JSON format in the options field
   - Ensure proper escaping of special characters

4. **Image path issues**:
   - Confirm all image paths exist in the `assets/individual_signs/` directory
   - Paths should match exactly (case-sensitive)

### If migrations haven't been applied:

If your database is completely empty, you may need to run all migrations:

1. **Run initial schema**:
   ```sql
   -- Copy and paste the content from:
   -- supabase/migrations/001_initial_schema.sql
   -- supabase/migrations/004_add_image_url_column.sql
   ```

2. **Apply RLS policies**:
   - The table creation script includes basic RLS policies
   - For full policies, refer to the migration files

## Alternative: Manual Table Creation

If you prefer to create the table manually:

```sql
-- Create questions table
CREATE TABLE questions (
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
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes
CREATE INDEX idx_questions_category ON questions(category);
CREATE INDEX idx_questions_learner_code ON questions(learner_code);
CREATE INDEX idx_questions_image_url ON questions(image_url) WHERE image_url IS NOT NULL;

-- Enable RLS
ALTER TABLE questions ENABLE ROW LEVEL SECURITY;

-- Basic RLS policies
CREATE POLICY "Authenticated users can read questions" ON questions
    FOR SELECT USING (auth.role() = 'authenticated' AND is_active = true);
    
CREATE POLICY "Allow question seeding" ON questions
    FOR INSERT TO authenticated WITH CHECK (true);
```

## Next Steps

After successful insertion:
1. Test the questions in your Flutter app
2. Verify images load correctly in the offline test screen
3. Check that the new road sign questions appear in study and exam modes
4. Consider adding more questions from the available 587 road sign images

## Support

If you encounter issues:
- Check Supabase documentation: https://supabase.com/docs
- Review the migration files in `supabase/migrations/`
- Verify database connection settings in your `.env` file

## Expected Results

After successful execution, you should have:
- ✅ Questions table created (if it didn't exist)
- ✅ 19 new road sign questions inserted
- ✅ All questions with proper image_url references
- ✅ Proper categorization and difficulty levels
- ✅ Working RLS policies for application access