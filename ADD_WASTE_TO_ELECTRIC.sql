-- ═══════════════════════════════════════════════════════════════════
-- إضافة حقول التلف لجدول الصمون الكهربائي
-- Adding Waste Fields to Electric Bread Table
-- ═══════════════════════════════════════════════════════════════════

-- إضافة الأعمدة الجديدة
ALTER TABLE electric_bread 
ADD COLUMN IF NOT EXISTS waste_jerq_count INTEGER NOT NULL DEFAULT 0 CHECK (waste_jerq_count >= 0),
ADD COLUMN IF NOT EXISTS waste_jerq_total NUMERIC(12,2) NOT NULL DEFAULT 0,
ADD COLUMN IF NOT EXISTS waste_round_count INTEGER NOT NULL DEFAULT 0 CHECK (waste_round_count >= 0),
ADD COLUMN IF NOT EXISTS waste_round_total NUMERIC(12,2) NOT NULL DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_waste NUMERIC(12,2) NOT NULL DEFAULT 0,
ADD COLUMN IF NOT EXISTS net_profit NUMERIC(12,2) NOT NULL DEFAULT 0;

-- تحديث السجلات القديمة
-- net_profit = total_profit - total_waste (للسجلات القديمة حيث total_waste = 0)
UPDATE electric_bread 
SET net_profit = total_profit - total_waste
WHERE net_profit = 0 OR net_profit IS NULL;

-- إنشاء دالة لحساب صافي الربح تلقائياً
CREATE OR REPLACE FUNCTION calculate_electric_bread_net_profit()
RETURNS TRIGGER AS $$
BEGIN
    -- حساب تلف الچرك (كل قطعة = 250)
    NEW.waste_jerq_total := NEW.waste_jerq_count * 250;
    
    -- حساب تلف الدائري حسب التسعيرة (3=500, 4=750, 6=1000)
    IF NEW.waste_round_count = 3 THEN
        NEW.waste_round_total := 500;
    ELSIF NEW.waste_round_count = 4 THEN
        NEW.waste_round_total := 750;
    ELSIF NEW.waste_round_count = 6 THEN
        NEW.waste_round_total := 1000;
    ELSE
        -- استخدام حساب نسبي للأرقام الأخرى
        NEW.waste_round_total := (NEW.waste_round_count::NUMERIC / 3) * 500;
    END IF;
    
    -- إجمالي التلف
    NEW.total_waste := NEW.waste_jerq_total + NEW.waste_round_total;
    
    -- صافي الربح = الربح الإجمالي - إجمالي التلف
    NEW.net_profit := NEW.total_profit - NEW.total_waste;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- إنشاء Trigger لحساب صافي الربح تلقائياً عند الإدراج أو التحديث
DROP TRIGGER IF EXISTS trigger_calculate_electric_net_profit ON electric_bread;
CREATE TRIGGER trigger_calculate_electric_net_profit
    BEFORE INSERT OR UPDATE ON electric_bread
    FOR EACH ROW
    EXECUTE FUNCTION calculate_electric_bread_net_profit();

-- التحقق
SELECT 
    'تم إضافة حقول التلف لجدول electric_bread بنجاح!' as message,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name = 'electric_bread'
ORDER BY ordinal_position;

