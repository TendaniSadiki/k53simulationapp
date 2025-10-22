-- SQL script to apply missing schema fixes
-- Copy and paste this into your Supabase SQL Editor

-- Add missing columns to questions table
ALTER TABLE questions 
ADD COLUMN IF NOT EXISTS times_answered INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS times_correct INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS times_incorrect INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS difficulty_rating NUMERIC(3,2) DEFAULT 0.5,
ADD COLUMN IF NOT EXISTS last_answered TIMESTAMPTZ;

-- Add missing weekly_points column to profiles table
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS weekly_points INTEGER DEFAULT 0;

-- Ensure all gamification columns exist in profiles table
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS daily_points INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS gaming_points INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_points INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS level INTEGER DEFAULT 1,
ADD COLUMN IF NOT EXISTS login_streak INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS last_login_date TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS last_daily_points_date TIMESTAMPTZ;

-- Create achievements table if it doesn't exist
CREATE TABLE IF NOT EXISTS achievements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    icon TEXT NOT NULL,
    points INTEGER NOT NULL DEFAULT 10,
    type TEXT NOT NULL CHECK (type IN ('streak', 'accuracy', 'completion', 'speed', 'social')),
    target_value INTEGER NOT NULL DEFAULT 1,
    is_hidden BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(name)
);

-- Create user_achievements table if it doesn't exist
CREATE TABLE IF NOT EXISTS user_achievements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    achievement_id UUID REFERENCES achievements(id) ON DELETE CASCADE,
    progress INTEGER DEFAULT 0,
    unlocked BOOLEAN DEFAULT FALSE,
    unlocked_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, achievement_id)
);

-- Create user_stats table if it doesn't exist
CREATE TABLE IF NOT EXISTS user_stats (
    user_id UUID PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
    login_streak INTEGER DEFAULT 0,
    last_login TIMESTAMPTZ,
    total_study_sessions INTEGER DEFAULT 0,
    total_exam_sessions INTEGER DEFAULT 0,
    total_correct_answers INTEGER DEFAULT 0,
    total_answers INTEGER DEFAULT 0,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert predefined achievements if they don't exist
INSERT INTO achievements (name, description, icon, points, type, target_value) VALUES
-- Streak achievements
('First Steps', 'Complete your first study session', 'first_steps', 10, 'streak', 1),
('Daily Learner', 'Study for 3 consecutive days', 'daily_learner', 20, 'streak', 3),
('Week Warrior', 'Study for 7 consecutive days', 'week_warrior', 50, 'streak', 7),
('Month Master', 'Study for 30 consecutive days', 'month_master', 100, 'streak', 30),
('Consistent Scholar', 'Maintain a 90-day study streak', 'consistent_scholar', 250, 'streak', 90),

-- Accuracy achievements
('Quick Learner', 'Get 5 correct answers in a row', 'quick_learner', 15, 'accuracy', 5),
('Accuracy Ace', 'Achieve 80% accuracy in a study session', 'accuracy_ace', 25, 'accuracy', 1),
('Perfect Score', 'Get 100% on a mock exam', 'perfect_score', 50, 'accuracy', 1),
('Master of Knowledge', 'Achieve 90% accuracy across 100 questions', 'master_knowledge', 75, 'accuracy', 100),
('Flawless Victory', 'Get 100% on 5 different mock exams', 'flawless_victory', 150, 'accuracy', 5),

-- Completion achievements
('Rules Explorer', 'Complete 10 rules of the road questions', 'rules_explorer', 15, 'completion', 10),
('Signs Specialist', 'Complete 25 road sign questions', 'signs_specialist', 30, 'completion', 25),
('Controls Champion', 'Complete 15 vehicle controls questions', 'controls_champion', 20, 'completion', 15),
('Category Master', 'Complete all questions in one category', 'category_master', 50, 'completion', 50),
('K53 Expert', 'Complete 200 total questions', 'k53_expert', 100, 'completion', 200)
ON CONFLICT (name) DO NOTHING;

-- Enable RLS on new tables
ALTER TABLE achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_stats ENABLE ROW LEVEL SECURITY;

-- RLS Policies for new tables

-- Achievements (read-only for all authenticated users)
CREATE POLICY "Authenticated users can read achievements" ON achievements
    FOR SELECT USING (auth.role() = 'authenticated');

-- User achievements (users can only see their own)
CREATE POLICY "Users can view own user achievements" ON user_achievements
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own user achievements" ON user_achievements
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own user achievements" ON user_achievements
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- User stats (users can only see their own)
CREATE POLICY "Users can view own user stats" ON user_stats
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own user stats" ON user_stats
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own user stats" ON user_stats
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Verify the changes
SELECT 'Schema fixes applied successfully!' as status;

-- Check if all required columns exist
SELECT 
    'questions.times_answered' as column_name,
    EXISTS(SELECT 1 FROM information_schema.columns WHERE table_name='questions' AND column_name='times_answered') as exists
UNION ALL
SELECT 
    'profiles.weekly_points' as column_name,
    EXISTS(SELECT 1 FROM information_schema.columns WHERE table_name='profiles' AND column_name='weekly_points') as exists
UNION ALL
SELECT 
    'profiles.daily_points' as column_name,
    EXISTS(SELECT 1 FROM information_schema.columns WHERE table_name='profiles' AND column_name='daily_points') as exists
UNION ALL
SELECT 
    'achievements table' as column_name,
    EXISTS(SELECT 1 FROM information_schema.tables WHERE table_name='achievements') as exists
UNION ALL
SELECT 
    'user_stats table' as column_name,
    EXISTS(SELECT 1 FROM information_schema.tables WHERE table_name='user_stats') as exists;