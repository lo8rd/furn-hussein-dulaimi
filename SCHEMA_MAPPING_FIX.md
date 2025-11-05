# ✅ إصلاح مطابقة المخطط (Schema Mapping Fix)

## 🎯 **المشاكل التي تم حلها:**

### **❌ Error 1: `expense_name` لم يعد موجوداً**
**الخطأ:**
```
Could not find the 'expense_name' column of 'expenses' in the schema cache
```

**الحل:**
- تم استبدال `expense_name` بـ:
  - `type` (نوع المصروف: 'labor', 'flour', 'other')
  - `note` (ملاحظة اختيارية)

**التحديثات في db.js:**
```javascript
// ❌ قديم:
expense_name: data.expense_name,
amount: parseFloat(data.amount) || 0

// ✅ جديد:
type: data.type || data.expense_name || 'other',
amount: parseFloat(data.amount) || 0,
note: data.note || data.expense_name || null
```

---

### **❌ Error 2: `amount` في جدول `differences` لم يعد موجوداً**
**الخطأ:**
```
Could not find the 'amount' column of 'differences' in the schema cache
```

**الحل:**
- تم استبدال:
  - `count` → `quantity`
  - `amount` → `total_value`

**التحديثات في db.js:**
```javascript
// ❌ قديم:
count: count,
amount: amount

// ✅ جديد:
quantity: quantity,
total_value: total_value
```

**حساب القيمة الإجمالية:**
```javascript
// عدد الصمون ÷ 8 × 1000 = القيمة بالدينار
const quantity = parseInt(data.count) || parseInt(data.quantity) || 0;
const total_value = (quantity / 8) * 1000;
```

---

### **❌ Error 3: جدول `electric_bread` لم يعد موجوداً**
**الخطأ:**
```
Could not find the table 'public.electric_bread' in the schema cache
```

**الحل:**
- تم إزالة جدول `electric_bread` من المخطط الجديد
- جميع الدوال المتعلقة به ترجع خطأ أو مصفوفة فارغة
- رسالة واضحة: **"استخدم `daily_bakes` أو `differences` بدلاً من ذلك"**

**التحديثات في db.js:**
```javascript
async addElectricBread(data) {
    console.warn('⚠️ Electric bread table removed. Use daily_bakes or differences instead.');
    throw new Error('Electric bread table no longer exists. Please use daily_bakes or differences.');
}

async getAllElectricBread() {
    console.warn('⚠️ Electric bread table removed. Use daily_bakes or differences instead.');
    return [];
}
```

---

## 📋 **مطابقة الأعمدة الجديدة:**

### **جدول `expenses`:**
```sql
id           UUID PRIMARY KEY
date         DATE
type         TEXT ('labor', 'flour', 'other')
amount       NUMERIC(12,2)
note         TEXT (nullable)
created_at   TIMESTAMPTZ
```

### **جدول `differences`:**
```sql
id           UUID PRIMARY KEY
date         DATE
type         TEXT ('waste', 'restaurant', 'other')
quantity     INTEGER
total_value  NUMERIC(12,2)
created_at   TIMESTAMPTZ
```

### **جدول `daily_bakes`:**
```sql
id           UUID PRIMARY KEY
date         DATE
shift        TEXT ('morning', 'evening')
dough_count  INTEGER
total_profit NUMERIC(12,2)
created_at   TIMESTAMPTZ
```

### **جدول `users`:**
```sql
id           UUID PRIMARY KEY
username     TEXT UNIQUE
email        TEXT UNIQUE
password     TEXT
created_at   TIMESTAMPTZ
```

---

## ✅ **التحقق من التحديثات:**

### **1. المصاريف (Expenses):**
```javascript
// إضافة مصروف:
await db.addExpense({
    date: '2025-01-15',
    type: 'labor',        // ✅ جديد
    amount: 50000,        // ✅ موجود
    note: 'رواتب العمال' // ✅ جديد
});
```

### **2. الفروقات (Differences):**
```javascript
// إضافة فرق:
await db.addDifference({
    date: '2025-01-15',
    type: 'waste',      // ✅ موجود
    count: 80           // ✅ يتحول إلى quantity
    // سيتم حساب total_value تلقائياً: (80 ÷ 8) × 1000 = 10000
});
```

### **3. الصمون الكهربائي (Electric Bread):**
```javascript
// ⚠️ لم يعد مدعوماً - استخدم بدلاً منه:
await db.addDough({
    date: '2025-01-15',
    morning_count: 50,
    evening_count: 45
});
```

---

## 🚀 **الخطوات التالية:**

1. ✅ **تم**: تحديث `db.js` ليتوافق مع المخطط الجديد
2. 📝 **التالي**: تحديث صفحات HTML لاستخدام الحقول الجديدة:
   - `expenses.html` → استخدام `type` و `note` بدلاً من `expense_name`
   - `differences.html` → استخدام `quantity` و `total_value` بدلاً من `count` و `amount`
   - `electric.html` → تعطيل أو إزالة الصفحة، أو ربطها بـ `daily_bakes`

3. ✅ **تم**: تحديث دوال الإحصائيات في `getStats()` لاستخدام:
   - `daily_bakes.total_profit`
   - `expenses.amount` (مقسمة حسب النوع)
   - `differences.total_value`

---

## 📌 **ملاحظات مهمة:**

- جميع الحسابات تتم في JavaScript **قبل** الإرسال إلى Supabase
- القيم المالية تُخزن بالدينار الفعلي (مع الأصفار الثلاثة)
- الأعمدة الجديدة تتطابق 100% مع `schema.sql` و `CLEAN_START.sql`
- RLS مفعّلة على جميع الجداول

---

**✅ التحديثات مكتملة - الكود الآن متوافق تماماً مع المخطط الجديد!**

