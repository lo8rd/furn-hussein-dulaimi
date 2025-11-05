-- ═══════════════════════════════════════════════════════════════════
-- 🔄 COMPLETE DATABASE RESET - فرن حسين الدليمي
-- ═══════════════════════════════════════════════════════════════════
-- This file completely resets the database and creates a clean schema
-- Run this in Supabase SQL Editor to start fresh
-- ═══════════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════════
-- STEP 1: DROP ALL EXISTING TABLES
-- ═══════════════════════════════════════════════════════════════════
-- This removes all tables created by previous versions
-- Note: Each table is dropped individually to avoid errors

DO $$ 
DECLARE
    r RECORD;
BEGIN
    -- Drop all policies first
    FOR r IN (SELECT tablename, policyname FROM pg_policies WHERE schemaname = 'public') LOOP
        EXECUTE 'DROP POLICY IF EXISTS "' || r.policyname || '" ON ' || r.tablename;
    END LOOP;
    
    -- Drop all tables
    FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public') LOOP
        EXECUTE 'DROP TABLE IF EXISTS ' || quote_ident(r.tablename) || ' CASCADE';
    END LOOP;
END $$;

-- ═══════════════════════════════════════════════════════════════════
-- STEP 2: ENABLE UUID EXTENSION
-- ═══════════════════════════════════════════════════════════════════

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ═══════════════════════════════════════════════════════════════════
-- STEP 3: CREATE CLEAN TABLES
-- ═══════════════════════════════════════════════════════════════════

-- ────────────────────────────────────────────────────────────────────
-- 👤 Users Table
-- ────────────────────────────────────────────────────────────────────
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username TEXT UNIQUE NOT NULL,
    email TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add indexes for performance
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);

-- Insert default user
-- ⚠️ IMPORTANT: Change email to your actual email address
INSERT INTO users (username, email, password) 
VALUES ('hus_dul9', 'hus_dul9@gmail.com', 'G7r$k9ZnQ!t4Wp2')
ON CONFLICT (username) DO NOTHING;

-- ────────────────────────────────────────────────────────────────────
-- 🍞 Daily Bakes Table (العجنات اليومية)
-- ────────────────────────────────────────────────────────────────────
CREATE TABLE daily_bakes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    shift TEXT NOT NULL CHECK (shift IN ('morning', 'evening')),
    dough_count INTEGER NOT NULL CHECK (dough_count >= 0),
    total_profit NUMERIC(12,2) NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add indexes
CREATE INDEX idx_daily_bakes_date ON daily_bakes(date);
CREATE INDEX idx_daily_bakes_shift ON daily_bakes(shift);
CREATE INDEX idx_daily_bakes_date_shift ON daily_bakes(date, shift);

-- Add comments
COMMENT ON TABLE daily_bakes IS 'Stores daily bakery production data by shift';
COMMENT ON COLUMN daily_bakes.shift IS 'morning or evening shift';
COMMENT ON COLUMN daily_bakes.dough_count IS 'Number of dough units produced';
COMMENT ON COLUMN daily_bakes.total_profit IS 'Total profit for this shift in thousands';

-- ────────────────────────────────────────────────────────────────────
-- 💰 Expenses Table (المصاريف)
-- ────────────────────────────────────────────────────────────────────
CREATE TABLE expenses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    type TEXT NOT NULL CHECK (type IN ('labor', 'flour', 'other')),
    amount NUMERIC(12,2) NOT NULL CHECK (amount >= 0),
    note TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add indexes
CREATE INDEX idx_expenses_date ON expenses(date);
CREATE INDEX idx_expenses_type ON expenses(type);
CREATE INDEX idx_expenses_date_type ON expenses(date, type);

-- Add comments
COMMENT ON TABLE expenses IS 'Stores daily expenses and costs';
COMMENT ON COLUMN expenses.type IS 'Expense category: labor (عمال), flour (طحين), or other (أخرى)';
COMMENT ON COLUMN expenses.amount IS 'Expense amount in thousands of dinars';

-- ────────────────────────────────────────────────────────────────────
-- 📊 Differences Table (الفروقات)
-- ────────────────────────────────────────────────────────────────────
CREATE TABLE differences (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    type TEXT NOT NULL CHECK (type IN ('waste', 'restaurant', 'other')),
    quantity INTEGER NOT NULL CHECK (quantity >= 0),
    total_value NUMERIC(12,2) NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add indexes
CREATE INDEX idx_differences_date ON differences(date);
CREATE INDEX idx_differences_type ON differences(type);
CREATE INDEX idx_differences_date_type ON differences(date, type);

-- Add comments
COMMENT ON TABLE differences IS 'Stores differences in production (waste, restaurant orders, etc.)';
COMMENT ON COLUMN differences.type IS 'Difference category: waste (هدر), restaurant (مطاعم), or other (أخرى)';
COMMENT ON COLUMN differences.quantity IS 'Quantity of items in the difference';
COMMENT ON COLUMN differences.total_value IS 'Total value in thousands of dinars';

-- ═══════════════════════════════════════════════════════════════════
-- STEP 4: ENABLE ROW LEVEL SECURITY (RLS)
-- ═══════════════════════════════════════════════════════════════════

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_bakes ENABLE ROW LEVEL SECURITY;
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE differences ENABLE ROW LEVEL SECURITY;

-- ═══════════════════════════════════════════════════════════════════
-- STEP 5: CREATE RLS POLICIES
-- ═══════════════════════════════════════════════════════════════════

-- ────────────────────────────────────────────────────────────────────
-- Users Table Policies
-- ────────────────────────────────────────────────────────────────────
-- Allow public to read users (for login verification)
CREATE POLICY "users_select_public" ON users
    FOR SELECT
    USING (true);

-- Allow authenticated users to update their own data
CREATE POLICY "users_update_authenticated" ON users
    FOR UPDATE
    USING (auth.uid()::text = id::text)
    WITH CHECK (auth.uid()::text = id::text);

-- ────────────────────────────────────────────────────────────────────
-- Daily Bakes Table Policies
-- ────────────────────────────────────────────────────────────────────
-- Allow public to read all bakes data
CREATE POLICY "daily_bakes_select_public" ON daily_bakes
    FOR SELECT
    USING (true);

-- Allow public to insert new bakes data
CREATE POLICY "daily_bakes_insert_public" ON daily_bakes
    FOR INSERT
    WITH CHECK (true);

-- Allow public to update bakes data
CREATE POLICY "daily_bakes_update_public" ON daily_bakes
    FOR UPDATE
    USING (true)
    WITH CHECK (true);

-- Allow public to delete bakes data
CREATE POLICY "daily_bakes_delete_public" ON daily_bakes
    FOR DELETE
    USING (true);

-- ────────────────────────────────────────────────────────────────────
-- Expenses Table Policies
-- ────────────────────────────────────────────────────────────────────
-- Allow public to read all expenses
CREATE POLICY "expenses_select_public" ON expenses
    FOR SELECT
    USING (true);

-- Allow public to insert expenses
CREATE POLICY "expenses_insert_public" ON expenses
    FOR INSERT
    WITH CHECK (true);

-- Allow public to update expenses
CREATE POLICY "expenses_update_public" ON expenses
    FOR UPDATE
    USING (true)
    WITH CHECK (true);

-- Allow public to delete expenses
CREATE POLICY "expenses_delete_public" ON expenses
    FOR DELETE
    USING (true);

-- ────────────────────────────────────────────────────────────────────
-- Differences Table Policies
-- ────────────────────────────────────────────────────────────────────
-- Allow public to read all differences
CREATE POLICY "differences_select_public" ON differences
    FOR SELECT
    USING (true);

-- Allow public to insert differences
CREATE POLICY "differences_insert_public" ON differences
    FOR INSERT
    WITH CHECK (true);

-- Allow public to update differences
CREATE POLICY "differences_update_public" ON differences
    FOR UPDATE
    USING (true)
    WITH CHECK (true);

-- Allow public to delete differences
CREATE POLICY "differences_delete_public" ON differences
    FOR DELETE
    USING (true);

-- ═══════════════════════════════════════════════════════════════════
-- STEP 6: CREATE HELPFUL VIEWS
-- ═══════════════════════════════════════════════════════════════════

-- ────────────────────────────────────────────────────────────────────
-- Daily Summary View
-- ────────────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW daily_summary AS
SELECT 
    d.date,
    COALESCE(SUM(db.total_profit), 0) as total_profit,
    COALESCE(SUM(e.amount), 0) as total_expenses,
    COALESCE(SUM(diff.total_value), 0) as total_differences,
    COALESCE(SUM(db.total_profit), 0) - 
    COALESCE(SUM(e.amount), 0) - 
    COALESCE(SUM(diff.total_value), 0) as net_profit
FROM (
    SELECT DISTINCT date FROM daily_bakes
    UNION
    SELECT DISTINCT date FROM expenses
    UNION
    SELECT DISTINCT date FROM differences
) d
LEFT JOIN daily_bakes db ON d.date = db.date
LEFT JOIN expenses e ON d.date = e.date
LEFT JOIN differences diff ON d.date = diff.date
GROUP BY d.date
ORDER BY d.date DESC;

-- ────────────────────────────────────────────────────────────────────
-- Monthly Summary View
-- ────────────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW monthly_summary AS
SELECT 
    DATE_TRUNC('month', date) as month,
    COUNT(DISTINCT date) as working_days,
    SUM(total_profit) as total_profit,
    SUM(total_expenses) as total_expenses,
    SUM(total_differences) as total_differences,
    SUM(net_profit) as net_profit
FROM daily_summary
GROUP BY DATE_TRUNC('month', date)
ORDER BY month DESC;

-- ═══════════════════════════════════════════════════════════════════
-- STEP 7: CREATE UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════════════════════════

-- ────────────────────────────────────────────────────────────────────
-- Function to update updated_at timestamp
-- ────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for all tables
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_daily_bakes_updated_at BEFORE UPDATE ON daily_bakes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_expenses_updated_at BEFORE UPDATE ON expenses
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_differences_updated_at BEFORE UPDATE ON differences
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ═══════════════════════════════════════════════════════════════════
-- STEP 8: VERIFICATION QUERIES
-- ═══════════════════════════════════════════════════════════════════

-- Check all tables exist
SELECT 
    tablename,
    CASE 
        WHEN tablename IN ('users', 'daily_bakes', 'expenses', 'differences') 
        THEN '✅ Created'
        ELSE '⚠️ Unexpected'
    END as status
FROM pg_tables 
WHERE schemaname = 'public'
ORDER BY tablename;

-- Check RLS is enabled
SELECT 
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables 
WHERE schemaname = 'public'
    AND tablename IN ('users', 'daily_bakes', 'expenses', 'differences');

-- Check policies exist
SELECT 
    tablename,
    policyname,
    cmd as operation
FROM pg_policies 
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

-- Check user exists
SELECT username, email, created_at FROM users;

-- ═══════════════════════════════════════════════════════════════════
-- ✅ SCHEMA RESET COMPLETE
-- ═══════════════════════════════════════════════════════════════════
-- 
-- Tables Created:
-- ✅ users (with default user: hus_dul9)
-- ✅ daily_bakes (morning/evening shifts)
-- ✅ expenses (labor/flour/other)
-- ✅ differences (waste/restaurant/other)
--
-- Security:
-- ✅ Row Level Security (RLS) enabled on all tables
-- ✅ Policies created for public access (suitable for internal apps)
--
-- Additional Features:
-- ✅ UUID primary keys for all tables
-- ✅ Indexes for performance
-- ✅ Check constraints for data validation
-- ✅ Views for daily and monthly summaries
-- ✅ Auto-update timestamps
-- ✅ Table and column comments
--
-- Next Steps:
-- 1. Update your frontend code to use new table structure
-- 2. Test authentication with user: hus_dul9
-- 3. Configure Supabase Auth settings (disable email confirmation)
--
-- ═══════════════════════════════════════════════════════════════════

