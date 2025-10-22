-- Migration to fix gamification schema and add missing fields
-- This creates the proper achievements structure and user profile fields

-- Drop the old user-specific achievements table (we'll recreate it properly)
DROP TABLE IF EXISTS achievements CASCADE;

-- Create global achievements table (master list of all possible achievements)
CREATE TABLE achievements (
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

-- Create user achievements table (tracks user progress on achievements)
CREATE TABLE user_achievements (
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

-- Add missing gamification fields to profiles table
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS daily_points INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS gaming_points INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_points INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS level INTEGER DEFAULT 1,
ADD COLUMN IF NOT EXISTS login_streak INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS last_login_date TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS last_daily_points_date TIMESTAMPTZ;

-- Create achievement events table for analytics
CREATE TABLE achievement_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    achievement_id UUID REFERENCES achievements(id) ON DELETE CASCADE,
    unlocked_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create login events table for streak tracking
CREATE TABLE login_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    login_time TIMESTAMPTZ DEFAULT NOW()
);

-- Create user stats table for gamification data
CREATE TABLE user_stats (
    user_id UUID PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
    login_streak INTEGER DEFAULT 0,
    last_login TIMESTAMPTZ,
    total_study_sessions INTEGER DEFAULT 0,
    total_exam_sessions INTEGER DEFAULT 0,
    total_correct_answers INTEGER DEFAULT 0,
    total_answers INTEGER DEFAULT 0,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert predefined achievements
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
('K53 Expert', 'Complete 200 total questions', 'k53_expert', 100, 'completion', 200),

-- Speed achievements
('Quick Thinker', 'Answer 5 questions in under 10 seconds each', 'quick_thinker', 20, 'speed', 5),
('Speed Demon', 'Complete a 20-question session in under 5 minutes', 'speed_demon', 40, 'speed', 1),
('Lightning Reflexes', 'Maintain 90% accuracy while answering quickly', 'lightning_reflexes', 60, 'speed', 10),

-- Social achievements
('Study Buddy', 'Share the app with a friend', 'study_buddy', 25, 'social', 1),
('Community Contributor', 'Report 5 helpful question issues', 'community_contributor', 30, 'social', 5),
('Knowledge Sharer', 'Share your progress 10 times', 'knowledge_sharer', 40, 'social', 10);

-- Create indexes for better performance
CREATE INDEX idx_achievements_type ON achievements(type);
CREATE INDEX idx_user_achievements_user_id ON user_achievements(user_id);
CREATE INDEX idx_user_achievements_achievement_id ON user_achievements(achievement_id);
CREATE INDEX idx_achievement_events_user_id ON achievement_events(user_id);
CREATE INDEX idx_login_events_user_id ON login_events(user_id);
CREATE INDEX idx_login_events_login_time ON login_events(login_time);

-- Enable RLS on new tables
ALTER TABLE achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE achievement_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE login_events ENABLE ROW LEVEL SECURITY;
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

-- Achievement events (users can only see their own)
CREATE POLICY "Users can view own achievement events" ON achievement_events
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own achievement events" ON achievement_events
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Login events (users can only see their own)
CREATE POLICY "Users can view own login events" ON login_events
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own login events" ON login_events
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- User stats (users can only see their own)
CREATE POLICY "Users can view own user stats" ON user_stats
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own user stats" ON user_stats
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own user stats" ON user_stats
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Create trigger for updated_at on user_achievements
CREATE TRIGGER update_user_achievements_updated_at
    BEFORE UPDATE ON user_achievements
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Create trigger for updated_at on user_stats
CREATE TRIGGER update_user_stats_updated_at
    BEFORE UPDATE ON user_stats
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Update the handle_new_user function to include gamification fields
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, handle, learner_code, locale)
    VALUES (
        NEW.id,
        'user_' || substr(NEW.id::text, 1, 8),
        1,
        'en'
    )
    ON CONFLICT (id) DO NOTHING;
    
    INSERT INTO public.user_settings (id)
    VALUES (NEW.id)
    ON CONFLICT (id) DO NOTHING;
    
    -- Initialize user stats
    INSERT INTO public.user_stats (user_id)
    VALUES (NEW.id)
    ON CONFLICT (user_id) DO NOTHING;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to calculate user level based on points
CREATE OR REPLACE FUNCTION calculate_user_level(total_points INTEGER)
RETURNS INTEGER AS $$
BEGIN
    IF total_points < 100 THEN RETURN 1; END IF;
    IF total_points < 300 THEN RETURN 2; END IF;
    IF total_points < 600 THEN RETURN 3; END IF;
    IF total_points < 1000 THEN RETURN 4; END IF;
    IF total_points < 1500 THEN RETURN 5; END IF;
    IF total_points < 2100 THEN RETURN 6; END IF;
    IF total_points < 2800 THEN RETURN 7; END IF;
    IF total_points < 3600 THEN RETURN 8; END IF;
    IF total_points < 4500 THEN RETURN 9; END IF;
    RETURN 10;
END;
$$ LANGUAGE plpgsql;

-- Create function to get points needed for next level
CREATE OR REPLACE FUNCTION points_for_next_level(current_level INTEGER)
RETURNS INTEGER AS $$
BEGIN
    RETURN current_level * (current_level + 1) * 50;
END;
$$ LANGUAGE plpgsql;

-- Create function to update user level automatically
CREATE OR REPLACE FUNCTION update_user_level()
RETURNS TRIGGER AS $$
DECLARE
    new_level INTEGER;
    next_level_points INTEGER;
BEGIN
    -- Calculate new level based on total_points
    new_level := calculate_user_level(NEW.total_points);
    next_level_points := points_for_next_level(new_level);
    
    -- Update level if it changed
    IF NEW.level != new_level THEN
        NEW.level := new_level;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update user level when points change
CREATE TRIGGER update_user_level_trigger
    BEFORE UPDATE OF total_points ON profiles
    FOR EACH ROW EXECUTE FUNCTION update_user_level();

COMMENT ON MIGRATION '005_fix_gamification_schema' IS 'Fixes gamification schema, adds achievements system, and integrates with user profiles';