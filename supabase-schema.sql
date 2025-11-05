-- ✅ Supabase Database Schema for فرن حسين الدليمي
-- يجب تنفيذ هذا الملف في Supabase SQL Editor

-- ================================================
-- 1️⃣ جدول المستخدمين (Users)
-- ================================================

-- ⚠️ هام: إذا كان الجدول موجوداً بالفعل، استخدم الخطوات أدناه بدلاً من CREATE TABLE

-- للتثبيت الجديد: إنشاء جدول جديد مع عمود email
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- ════════════════════════════════════════════════════════════
-- 🔄 إذا كان الجدول موجوداً: قم بتشغيل هذه الأوامر بدلاً من ذلك
-- ════════════════════════════════════════════════════════════

-- الخطوة 1: إضافة عمود email إذا لم يكن موجوداً
ALTER TABLE users ADD COLUMN IF NOT EXISTS email VARCHAR(255);

-- الخطوة 2: تحديث المستخدم الموجود بالبريد الإلكتروني الحقيقي
-- ⚠️ هام: غيّر 'hus_dul9@gmail.com' إلى بريدك الإلكتروني الحقيقي
UPDATE users 
SET email = 'hus_dul9@gmail.com' 
WHERE username = 'hus_dul9' AND (email IS NULL OR email = '');

-- الخطوة 3: التحقق من التحديث
SELECT username, email, created_at FROM users;

-- الخطوة 4: (اختياري) جعل عمود email إلزامياً وفريداً بعد أن يكون لدى جميع المستخدمين بريد
-- قم بتشغيل هذا فقط بعد التأكد من أن جميع المستخدمين لديهم عناوين بريد صالحة
-- ALTER TABLE users ALTER COLUMN email SET NOT NULL;
-- CREATE UNIQUE INDEX IF NOT EXISTS users_email_unique_idx ON users(email) WHERE email IS NOT NULL;

-- ════════════════════════════════════════════════════════════
-- 📝 للتثبيت الجديد فقط: إدخال بيانات المستخدم الأساسية
-- ════════════════════════════════════════════════════════════
-- قم بتشغيل هذا فقط إذا كان الجدول فارغاً
INSERT INTO users (username, email, password) 
VALUES ('hus_dul9', 'hus_dul9@gmail.com', 'G7r$k9ZnQ!t4Wp2')
ON CONFLICT (username) DO NOTHING;

-- ================================================
-- 2️⃣ جدول العجنات (Dough)
-- ================================================
CREATE TABLE IF NOT EXISTS dough (
    id SERIAL PRIMARY KEY,
    date DATE NOT NULL,
    morning_count INTEGER DEFAULT 0,
    evening_count INTEGER DEFAULT 0,
    morning_profit DECIMAL(10, 2) DEFAULT 0,
    evening_profit DECIMAL(10, 2) DEFAULT 0,
    total_profit DECIMAL(10, 2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW()
);

-- ================================================
-- 3️⃣ جدول الطحين (Flour)
-- ================================================
CREATE TABLE IF NOT EXISTS flour (
    id SERIAL PRIMARY KEY,
    date DATE NOT NULL,
    bag_price DECIMAL(10, 2) NOT NULL,
    bag_count INTEGER NOT NULL,
    total_cost DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- ================================================
-- 4️⃣ جدول المصاريف (Expenses)
-- ================================================
CREATE TABLE IF NOT EXISTS expenses (
    id SERIAL PRIMARY KEY,
    date DATE NOT NULL,
    expense_name VARCHAR(255) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- ================================================
-- 5️⃣ جدول الصمون الكهربائي (Electric Bread)
-- ================================================
CREATE TABLE IF NOT EXISTS electric_bread (
    id SERIAL PRIMARY KEY,
    date DATE NOT NULL,
    jerq_count INTEGER DEFAULT 0,
    jerq_total DECIMAL(10, 2) DEFAULT 0,
    circle_count INTEGER DEFAULT 0,
    circle_total DECIMAL(10, 2) DEFAULT 0,
    total_profit DECIMAL(10, 2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW()
);

-- ================================================
-- 6️⃣ جدول الفروقات (Differences)
-- ================================================
CREATE TABLE IF NOT EXISTS differences (
    id SERIAL PRIMARY KEY,
    date DATE NOT NULL,
    type VARCHAR(255) NOT NULL,
    count INTEGER NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- ================================================
-- إنشاء Indexes لتحسين الأداء
-- ================================================
CREATE INDEX IF NOT EXISTS idx_dough_date ON dough(date);
CREATE INDEX IF NOT EXISTS idx_flour_date ON flour(date);
CREATE INDEX IF NOT EXISTS idx_expenses_date ON expenses(date);
CREATE INDEX IF NOT EXISTS idx_electric_date ON electric_bread(date);
CREATE INDEX IF NOT EXISTS idx_differences_date ON differences(date);

-- ================================================
-- تفعيل Row Level Security (RLS)
-- ================================================
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE dough ENABLE ROW LEVEL SECURITY;
ALTER TABLE flour ENABLE ROW LEVEL SECURITY;
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE electric_bread ENABLE ROW LEVEL SECURITY;
ALTER TABLE differences ENABLE ROW LEVEL SECURITY;

-- ================================================
-- Policies للوصول للبيانات
-- ================================================

-- Users table policies
CREATE POLICY "Allow public read access to users" ON users
    FOR SELECT USING (true);

-- Dough table policies
CREATE POLICY "Allow public read access to dough" ON dough
    FOR SELECT USING (true);
CREATE POLICY "Allow public insert access to dough" ON dough
    FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update access to dough" ON dough
    FOR UPDATE USING (true);
CREATE POLICY "Allow public delete access to dough" ON dough
    FOR DELETE USING (true);

-- Flour table policies
CREATE POLICY "Allow public read access to flour" ON flour
    FOR SELECT USING (true);
CREATE POLICY "Allow public insert access to flour" ON flour
    FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update access to flour" ON flour
    FOR UPDATE USING (true);
CREATE POLICY "Allow public delete access to flour" ON flour
    FOR DELETE USING (true);

-- Expenses table policies
CREATE POLICY "Allow public read access to expenses" ON expenses
    FOR SELECT USING (true);
CREATE POLICY "Allow public insert access to expenses" ON expenses
    FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update access to expenses" ON expenses
    FOR UPDATE USING (true);
CREATE POLICY "Allow public delete access to expenses" ON expenses
    FOR DELETE USING (true);

-- Electric Bread table policies
CREATE POLICY "Allow public read access to electric_bread" ON electric_bread
    FOR SELECT USING (true);
CREATE POLICY "Allow public insert access to electric_bread" ON electric_bread
    FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update access to electric_bread" ON electric_bread
    FOR UPDATE USING (true);
CREATE POLICY "Allow public delete access to electric_bread" ON electric_bread
    FOR DELETE USING (true);

-- Differences table policies
CREATE POLICY "Allow public read access to differences" ON differences
    FOR SELECT USING (true);
CREATE POLICY "Allow public insert access to differences" ON differences
    FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update access to differences" ON differences
    FOR UPDATE USING (true);
CREATE POLICY "Allow public delete access to differences" ON differences
    FOR DELETE USING (true);

-- ================================================
-- ✅ انتهى إنشاء قاعدة البيانات
-- ================================================

