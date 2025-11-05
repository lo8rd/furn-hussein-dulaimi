-- ═══════════════════════════════════════════════════════════════════
-- 🚀 CLEAN START - Simple Database Reset
-- ═══════════════════════════════════════════════════════════════════
-- This is a simpler version that drops everything and starts fresh
-- Copy and paste this entire file into Supabase SQL Editor
-- ═══════════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════════
-- STEP 1: Drop everything (policies and tables)
-- ═══════════════════════════════════════════════════════════════════

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
    
    RAISE NOTICE '✅ All tables and policies dropped successfully';
END $$;

-- ═══════════════════════════════════════════════════════════════════
-- STEP 2: Enable UUID extension
-- ═══════════════════════════════════════════════════════════════════

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ═══════════════════════════════════════════════════════════════════
-- STEP 3: Create new tables
-- ═══════════════════════════════════════════════════════════════════

-- 👤 Users
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username TEXT UNIQUE NOT NULL,
    email TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 🍞 Daily Bakes
CREATE TABLE daily_bakes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    shift TEXT NOT NULL CHECK (shift IN ('morning', 'evening')),
    dough_count INTEGER NOT NULL CHECK (dough_count >= 0),
    total_profit NUMERIC(12,2) NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 💰 Expenses
CREATE TABLE expenses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    type TEXT NOT NULL CHECK (type IN ('labor', 'flour', 'other')),
    amount NUMERIC(12,2) NOT NULL CHECK (amount >= 0),
    note TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 📊 Differences
CREATE TABLE differences (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    type TEXT NOT NULL CHECK (type IN ('waste', 'restaurant', 'other')),
    quantity INTEGER NOT NULL CHECK (quantity >= 0),
    total_value NUMERIC(12,2) NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ⚡ Electric Bread
CREATE TABLE electric_bread (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    jerq_count INTEGER NOT NULL DEFAULT 0 CHECK (jerq_count >= 0),
    jerq_total NUMERIC(12,2) NOT NULL DEFAULT 0,
    circle_count INTEGER NOT NULL DEFAULT 0 CHECK (circle_count >= 0),
    circle_total NUMERIC(12,2) NOT NULL DEFAULT 0,
    total_profit NUMERIC(12,2) NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ═══════════════════════════════════════════════════════════════════
-- STEP 4: Add indexes for performance
-- ═══════════════════════════════════════════════════════════════════

CREATE INDEX idx_daily_bakes_date ON daily_bakes(date);
CREATE INDEX idx_expenses_date ON expenses(date);
CREATE INDEX idx_differences_date ON differences(date);
CREATE INDEX idx_electric_bread_date ON electric_bread(date);

-- ═══════════════════════════════════════════════════════════════════
-- STEP 5: Enable RLS and create policies
-- ═══════════════════════════════════════════════════════════════════

-- Enable RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_bakes ENABLE ROW LEVEL SECURITY;
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE differences ENABLE ROW LEVEL SECURITY;
ALTER TABLE electric_bread ENABLE ROW LEVEL SECURITY;

-- Users policies
CREATE POLICY "users_select" ON users FOR SELECT USING (true);
CREATE POLICY "users_insert" ON users FOR INSERT WITH CHECK (true);
CREATE POLICY "users_update" ON users FOR UPDATE USING (true);
CREATE POLICY "users_delete" ON users FOR DELETE USING (true);

-- Daily bakes policies
CREATE POLICY "daily_bakes_select" ON daily_bakes FOR SELECT USING (true);
CREATE POLICY "daily_bakes_insert" ON daily_bakes FOR INSERT WITH CHECK (true);
CREATE POLICY "daily_bakes_update" ON daily_bakes FOR UPDATE USING (true);
CREATE POLICY "daily_bakes_delete" ON daily_bakes FOR DELETE USING (true);

-- Expenses policies
CREATE POLICY "expenses_select" ON expenses FOR SELECT USING (true);
CREATE POLICY "expenses_insert" ON expenses FOR INSERT WITH CHECK (true);
CREATE POLICY "expenses_update" ON expenses FOR UPDATE USING (true);
CREATE POLICY "expenses_delete" ON expenses FOR DELETE USING (true);

-- Differences policies
CREATE POLICY "differences_select" ON differences FOR SELECT USING (true);
CREATE POLICY "differences_insert" ON differences FOR INSERT WITH CHECK (true);
CREATE POLICY "differences_update" ON differences FOR UPDATE USING (true);
CREATE POLICY "differences_delete" ON differences FOR DELETE USING (true);

-- Electric bread policies
CREATE POLICY "electric_bread_select" ON electric_bread FOR SELECT USING (true);
CREATE POLICY "electric_bread_insert" ON electric_bread FOR INSERT WITH CHECK (true);
CREATE POLICY "electric_bread_update" ON electric_bread FOR UPDATE USING (true);
CREATE POLICY "electric_bread_delete" ON electric_bread FOR DELETE USING (true);

-- ═══════════════════════════════════════════════════════════════════
-- STEP 6: Insert default user
-- ═══════════════════════════════════════════════════════════════════

-- ⚠️ IMPORTANT: Change the email to your actual email address!
INSERT INTO users (username, email, password) 
VALUES ('hus_dul9', 'hus_dul9@gmail.com', 'G7r$k9ZnQ!t4Wp2');

-- ═══════════════════════════════════════════════════════════════════
-- STEP 7: Verify everything
-- ═══════════════════════════════════════════════════════════════════

-- Show all tables
SELECT 
    tablename,
    '✅' as status
FROM pg_tables 
WHERE schemaname = 'public'
ORDER BY tablename;

-- Show user
SELECT username, email, created_at FROM users;

-- ═══════════════════════════════════════════════════════════════════
-- ✅ DONE!
-- ═══════════════════════════════════════════════════════════════════
-- You should see:
-- ✅ 4 tables: daily_bakes, differences, expenses, users
-- ✅ 1 user: hus_dul9
-- 
-- Next steps:
-- 1. Configure Supabase Auth (disable email confirmation)
-- 2. Update frontend code to use new table names
-- 3. Test login
-- ═══════════════════════════════════════════════════════════════════

