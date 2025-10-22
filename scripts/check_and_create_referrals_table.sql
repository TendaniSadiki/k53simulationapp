-- Check and create referrals table if it doesn't exist
-- Run this script in your Supabase SQL editor to ensure the referrals table exists

DO $$
BEGIN
    -- Check if referrals table exists
    IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'referrals') THEN
        -- Create referrals table
        CREATE TABLE referrals (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            referrer_user_id UUID REFERENCES profiles(id),
            referred_email TEXT,
            medium TEXT,
            campaign TEXT,
            referral_code TEXT,
            status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'expired')),
            points_awarded INTEGER DEFAULT 0,
            clicked_at TIMESTAMPTZ,
            installed_at TIMESTAMPTZ,
            signed_up_at TIMESTAMPTZ,
            completed_at TIMESTAMPTZ,
            created_at TIMESTAMPTZ DEFAULT NOW()
        );

        -- Create index for better performance
        CREATE INDEX idx_referrals_referrer_id ON referrals(referrer_user_id);
        
        -- Enable Row Level Security
        ALTER TABLE referrals ENABLE ROW LEVEL SECURITY;
        
        -- RLS Policies
        CREATE POLICY "Users can view own referrals" ON referrals
            FOR SELECT USING (auth.uid() = referrer_user_id);
        
        CREATE POLICY "Users can insert own referrals" ON referrals
            FOR INSERT WITH CHECK (auth.uid() = referrer_user_id);
        
        RAISE NOTICE 'Referrals table created successfully';
    ELSE
        RAISE NOTICE 'Referrals table already exists';
    END IF;
END $$;