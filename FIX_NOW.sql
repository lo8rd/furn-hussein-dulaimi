-- ═══════════════════════════════════════════════════════════════════
-- 🚀 حل سريع - تشغيل هذا الآن في Supabase SQL Editor
-- ═══════════════════════════════════════════════════════════════════

-- الخطوة 1: حذف كل شيء
DO $$ 
DECLARE
    r RECORD;
BEGIN
    -- حذف جميع السياسات
    FOR r IN (SELECT tablename, policyname FROM pg_policies WHERE schemaname = 'public') LOOP
        EXECUTE 'DROP POLICY IF EXISTS "' || r.policyname || '" ON ' || r.tablename;
    END LOOP;
    
    -- حذف جميع الجداول
    FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public') LOOP
        EXECUTE 'DROP TABLE IF EXISTS ' || quote_ident(r.tablename) || ' CASCADE';
    END LOOP;
    
    RAISE NOTICE 'تم حذف جميع الجداول القديمة';
END $$;

-- الخطوة 2: تفعيل UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- الخطوة 3: إنشاء الجداول الجديدة

-- جدول المستخدمين
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username TEXT UNIQUE NOT NULL,
    email TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- جدول العجنات اليومية
CREATE TABLE daily_bakes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    shift TEXT NOT NULL CHECK (shift IN ('morning', 'evening')),
    dough_count INTEGER NOT NULL CHECK (dough_count >= 0),
    total_profit NUMERIC(12,2) NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- جدول المصاريف
CREATE TABLE expenses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    type TEXT NOT NULL CHECK (type IN ('labor', 'flour', 'other')),
    amount NUMERIC(12,2) NOT NULL CHECK (amount >= 0),
    note TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- جدول الفروقات
CREATE TABLE differences (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    type TEXT NOT NULL CHECK (type IN ('waste', 'restaurant', 'other')),
    quantity INTEGER NOT NULL CHECK (quantity >= 0),
    total_value NUMERIC(12,2) NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- الخطوة 4: إضافة فهارس
CREATE INDEX idx_daily_bakes_date ON daily_bakes(date);
CREATE INDEX idx_expenses_date ON expenses(date);
CREATE INDEX idx_differences_date ON differences(date);

-- الخطوة 5: تفعيل RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_bakes ENABLE ROW LEVEL SECURITY;
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE differences ENABLE ROW LEVEL SECURITY;

-- الخطوة 6: إنشاء السياسات
CREATE POLICY "users_all" ON users FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "daily_bakes_all" ON daily_bakes FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "expenses_all" ON expenses FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "differences_all" ON differences FOR ALL USING (true) WITH CHECK (true);

-- الخطوة 7: إضافة المستخدم الافتراضي
-- ⚠️ غيّر البريد الإلكتروني إلى بريدك الحقيقي!
INSERT INTO users (username, email, password) 
VALUES ('hus_dul9', 'hus_dul9@gmail.com', 'G7r$k9ZnQ!t4Wp2');

-- الخطوة 8: التحقق
SELECT 'تم بنجاح! الجداول الموجودة:' as message;
SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename;

SELECT 'المستخدم:' as message;
SELECT username, email FROM users;

-- ✅ انتهى!

