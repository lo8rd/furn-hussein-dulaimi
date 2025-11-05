-- ═══════════════════════════════════════════════════════════════════
-- إضافة جدول الصمون الكهربائي (Electric Bread)
-- ═══════════════════════════════════════════════════════════════════

-- إنشاء الجدول
CREATE TABLE IF NOT EXISTS electric_bread (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    jerq_count INTEGER NOT NULL DEFAULT 0 CHECK (jerq_count >= 0),
    jerq_total NUMERIC(12,2) NOT NULL DEFAULT 0,
    circle_count INTEGER NOT NULL DEFAULT 0 CHECK (circle_count >= 0),
    circle_total NUMERIC(12,2) NOT NULL DEFAULT 0,
    total_profit NUMERIC(12,2) NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- إضافة فهرس للتاريخ
CREATE INDEX IF NOT EXISTS idx_electric_bread_date ON electric_bread(date);

-- تفعيل RLS
ALTER TABLE electric_bread ENABLE ROW LEVEL SECURITY;

-- إنشاء سياسة للوصول الكامل
DROP POLICY IF EXISTS "electric_bread_all" ON electric_bread;
CREATE POLICY "electric_bread_all" ON electric_bread 
    FOR ALL 
    USING (true) 
    WITH CHECK (true);

-- التحقق
SELECT 'تم إضافة جدول electric_bread بنجاح!' as message;
SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename;

