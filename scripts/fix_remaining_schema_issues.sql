-- SQL script to fix remaining schema issues
-- Copy and paste this into your Supabase SQL Editor

-- Add missing study_goal_date column to profiles table
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS study_goal_date TIMESTAMPTZ;

-- Add missing level column to user_stats table
ALTER TABLE user_stats 
ADD COLUMN IF NOT EXISTS level INTEGER DEFAULT 1;

-- Add any other missing columns that might be needed
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS study_goal_type TEXT,
ADD COLUMN IF NOT EXISTS study_goal_value INTEGER,
ADD COLUMN IF NOT EXISTS study_goal_progress INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS study_goal_completed BOOLEAN DEFAULT FALSE;

-- Ensure user_stats has all required columns
ALTER TABLE user_stats
ADD COLUMN IF NOT EXISTS total_points INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS daily_points INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS weekly_points INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS gaming_points INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS login_streak INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS last_login TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS total_study_sessions INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_exam_sessions INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_correct_answers INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_answers INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS unlocked_achievements INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_achievements INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

-- Initialize user_stats for existing users if needed
INSERT INTO user_stats (user_id)
SELECT id FROM profiles
WHERE id NOT IN (SELECT user_id FROM user_stats)
ON CONFLICT (user_id) DO NOTHING;

-- Verify the fixes
SELECT 'Remaining schema fixes applied successfully!' as status;

-- Check if all required columns now exist
SELECT 
    'profiles.study_goal_date' as column_name,
    EXISTS(SELECT 1 FROM information_schema.columns WHERE table_name='profiles' AND column_name='study_goal_date') as exists
UNION ALL
SELECT 
    'user_stats.level' as column_name,
    EXISTS(SELECT 1 FROM information_schema.columns WHERE table_name='user_stats' AND column_name='level') as exists
UNION ALL
SELECT 
    'user_stats.total_points' as column_name,
    EXISTS(SELECT 1 FROM information_schema.columns WHERE table_name='user_stats' AND column_name='total_points') as exists;