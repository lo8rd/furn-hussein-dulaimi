-- ═══════════════════════════════════════════════════════════════════
-- 🔄 COMPLETE DATABASE RESET - فرن حسين الدليمي
-- ═══════════════════════════════════════════════════════════════════
-- This script completely resets the database and creates a clean schema
-- Run this in Supabase SQL Editor to start fresh
-- ═══════════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════════
-- STEP 1: DROP ALL EXISTING TABLES
-- ═══════════════════════════════════════════════════════════════════

-- Drop all possible tables from previous versions (with CASCADE to remove dependencies)
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS dough CASCADE;
DROP TABLE IF EXISTS daily_bakes CASCADE;
DROP TABLE IF EXISTS expenses CASCADE;
DROP TABLE IF EXISTS differences CASCADE;
DROP TABLE IF EXISTS flour CASCADE;
DROP TABLE IF EXISTS electric_bread CASCADE;
DROP TABLE IF EXISTS profits CASCADE;
DROP TABLE IF EXISTS logs CASCADE;
DROP TABLE IF EXISTS auth CASCADE;
DROP TABLE IF EXISTS login_history CASCADE;
DROP TABLE IF EXISTS settings CASCADE;
DROP TABLE IF EXISTS bakery CASCADE;
DROP TABLE IF EXISTS doughs CASCADE;

-- Drop any existing policies
DROP POLICY IF EXISTS "Allow public read access to users" ON users;
DROP POLICY IF EXISTS "Allow public insert access to users" ON users;
DROP POLICY IF EXISTS "Allow public update access to users" ON users;
DROP POLICY IF EXISTS "Allow public delete access to users" ON users;

-- ═══════════════════════════════════════════════════════════════════
-- STEP 2: ENABLE EXTENSIONS
-- ═══════════════════════════════════════════════════════════════════

-- Enable UUID extension for generating unique IDs
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ═══════════════════════════════════════════════════════════════════
-- STEP 3: CREATE CLEAN UNIFIED SCHEMA
-- ═══════════════════════════════════════════════════════════════════

-- ───────────────────────────────────────────────────────────────────
-- TABLE 1: users - User accounts and authentication
-- ───────────────────────────────────────────────────────────────────
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username TEXT UNIQUE NOT NULL,
    email TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- Insert default user
INSERT INTO users (username, email, password)
VALUES ('hus_dul9', 'hus_dul9@gmail.com', 'G7r$k9ZnQ!t4Wp2');

-- ───────────────────────────────────────────────────────────────────
-- TABLE 2: daily_bakes - Daily dough production and profits
-- ───────────────────────────────────────────────────────────────────
CREATE TABLE daily_bakes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    shift TEXT NOT NULL CHECK (shift IN ('morning', 'evening')),
    dough_count INTEGER NOT NULL CHECK (dough_count >= 0),
    total_profit NUMERIC(12, 2) NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- Create index for faster date queries
CREATE INDEX idx_daily_bakes_date ON daily_bakes(date DESC);
CREATE INDEX idx_daily_bakes_shift ON daily_bakes(shift);

-- ───────────────────────────────────────────────────────────────────
-- TABLE 3: expenses - Daily expenses tracking
-- ───────────────────────────────────────────────────────────────────
CREATE TABLE expenses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    type TEXT NOT NULL CHECK (type IN ('labor', 'flour', 'electric', 'other')),
    amount NUMERIC(12, 2) NOT NULL CHECK (amount >= 0),
    note TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- Create index for faster date queries
CREATE INDEX idx_expenses_date ON expenses(date DESC);
CREATE INDEX idx_expenses_type ON expenses(type);

-- ───────────────────────────────────────────────────────────────────
-- TABLE 4: differences - Samoon differences tracking
-- ───────────────────────────────────────────────────────────────────
CREATE TABLE differences (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    type TEXT NOT NULL CHECK (type IN ('waste', 'restaurant', 'shortage', 'other')),
    quantity INTEGER NOT NULL CHECK (quantity >= 0),
    total_value NUMERIC(12, 2) NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- Create index for faster date queries
CREATE INDEX idx_differences_date ON differences(date DESC);
CREATE INDEX idx_differences_type ON differences(type);

-- ═══════════════════════════════════════════════════════════════════
-- STEP 4: ENABLE ROW LEVEL SECURITY (RLS)
-- ═══════════════════════════════════════════════════════════════════

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_bakes ENABLE ROW LEVEL SECURITY;
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE differences ENABLE ROW LEVEL SECURITY;

-- ═══════════════════════════════════════════════════════════════════
-- STEP 5: CREATE RLS POLICIES
-- ═══════════════════════════════════════════════════════════════════

-- ───────────────────────────────────────────────────────────────────
-- Policies for users table
-- ───────────────────────────────────────────────────────────────────
CREATE POLICY "Allow public read access to users"
ON users FOR SELECT
USING (true);

CREATE POLICY "Allow public insert access to users"
ON users FOR INSERT
WITH CHECK (true);

CREATE POLICY "Allow public update access to users"
ON users FOR UPDATE
USING (true);

CREATE POLICY "Allow public delete access to users"
ON users FOR DELETE
USING (true);

-- ───────────────────────────────────────────────────────────────────
-- Policies for daily_bakes table
-- ───────────────────────────────────────────────────────────────────
CREATE POLICY "Allow public read access to daily_bakes"
ON daily_bakes FOR SELECT
USING (true);

CREATE POLICY "Allow public insert access to daily_bakes"
ON daily_bakes FOR INSERT
WITH CHECK (true);

CREATE POLICY "Allow public update access to daily_bakes"
ON daily_bakes FOR UPDATE
USING (true);

CREATE POLICY "Allow public delete access to daily_bakes"
ON daily_bakes FOR DELETE
USING (true);

-- ───────────────────────────────────────────────────────────────────
-- Policies for expenses table
-- ───────────────────────────────────────────────────────────────────
CREATE POLICY "Allow public read access to expenses"
ON expenses FOR SELECT
USING (true);

CREATE POLICY "Allow public insert access to expenses"
ON expenses FOR INSERT
WITH CHECK (true);

CREATE POLICY "Allow public update access to expenses"
ON expenses FOR UPDATE
USING (true);

CREATE POLICY "Allow public delete access to expenses"
ON expenses FOR DELETE
USING (true);

-- ───────────────────────────────────────────────────────────────────
-- Policies for differences table
-- ───────────────────────────────────────────────────────────────────
CREATE POLICY "Allow public read access to differences"
ON differences FOR SELECT
USING (true);

CREATE POLICY "Allow public insert access to differences"
ON differences FOR INSERT
WITH CHECK (true);

CREATE POLICY "Allow public update access to differences"
ON differences FOR UPDATE
USING (true);

CREATE POLICY "Allow public delete access to differences"
ON differences FOR DELETE
USING (true);

-- ═══════════════════════════════════════════════════════════════════
-- STEP 6: CREATE HELPER FUNCTIONS
-- ═══════════════════════════════════════════════════════════════════

-- Function to update updated_at timestamp automatically
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = TIMEZONE('utc', NOW());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for automatic timestamp updates
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_daily_bakes_updated_at
    BEFORE UPDATE ON daily_bakes
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_expenses_updated_at
    BEFORE UPDATE ON expenses
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_differences_updated_at
    BEFORE UPDATE ON differences
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ═══════════════════════════════════════════════════════════════════
-- STEP 7: VERIFICATION
-- ═══════════════════════════════════════════════════════════════════

-- Verify tables were created
SELECT 
    tablename,
    CASE 
        WHEN rowsecurity = true THEN '✅ RLS Enabled'
        ELSE '❌ RLS Disabled'
    END as rls_status
FROM pg_tables 
WHERE schemaname = 'public'
AND tablename IN ('users', 'daily_bakes', 'expenses', 'differences')
ORDER BY tablename;

-- Verify user was created
SELECT username, email, created_at FROM users;

-- Show table structures
SELECT 
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name IN ('users', 'daily_bakes', 'expenses', 'differences')
ORDER BY table_name, ordinal_position;

-- ═══════════════════════════════════════════════════════════════════
-- ✅ DATABASE RESET COMPLETE
-- ═══════════════════════════════════════════════════════════════════
-- 
-- Summary:
-- • All old tables dropped
-- • 4 clean tables created: users, daily_bakes, expenses, differences
-- • UUID primary keys on all tables
-- • RLS enabled with public access policies
-- • Indexes created for performance
-- • Automatic timestamp updates configured
-- • Default user created: hus_dul9 / hus_dul9@gmail.com
--
-- Next Steps:
-- 1. Configure Supabase Auth (disable email confirmation)
-- 2. Test login with username: hus_dul9
-- 3. Update frontend code to use new table names if needed
--
-- ═══════════════════════════════════════════════════════════════════

