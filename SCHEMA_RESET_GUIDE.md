# 🔄 Database Schema Reset Guide

## ⚠️ IMPORTANT: This will delete ALL existing data

The `schema.sql` file will completely reset your database and create a clean, unified structure.

---

## 📋 What This Does

### **Removes:**
- ❌ All old tables (users, dough, flour, electric_bread, differences, expenses, etc.)
- ❌ All old policies
- ❌ All old data
- ❌ All foreign key relationships

### **Creates:**
- ✅ 4 clean tables with UUID primary keys
- ✅ Row Level Security (RLS) policies
- ✅ Performance indexes
- ✅ Helpful views for daily/monthly summaries
- ✅ Auto-update timestamp triggers
- ✅ Data validation constraints

---

## 🚀 How to Use

### **Step 1: Backup Current Data** (Optional but Recommended)

If you want to save your existing data, export it first:

1. Go to Supabase Dashboard
2. Click on each table
3. Export to CSV

### **Step 2: Run the Schema**

1. Open Supabase Dashboard: https://supabase.com/dashboard
2. Select your project: **yhbyypzwuyyhvblueevo**
3. Go to: **SQL Editor**
4. Copy entire contents of `schema.sql`
5. Paste into SQL Editor
6. **IMPORTANT**: Change the default email if needed:
   ```sql
   -- Find this line in the SQL:
   INSERT INTO users (username, email, password) 
   VALUES ('hus_dul9', 'hus_dul9@gmail.com', 'G7r$k9ZnQ!t4Wp2')
   ```
7. Click **Run** or press `Ctrl+Enter`
8. Wait for completion (should take 5-10 seconds)

### **Step 3: Verify Success**

You should see output showing:
- ✅ Tables created
- ✅ RLS enabled
- ✅ Policies created
- ✅ User inserted

---

## 📊 New Table Structure

### **1. users**
```
id          UUID (Primary Key)
username    TEXT (Unique)
email       TEXT (Unique)
password    TEXT
created_at  TIMESTAMPTZ
updated_at  TIMESTAMPTZ
```

**Purpose**: User authentication
**Default User**: username: `hus_dul9`, email: `hus_dul9@gmail.com`

---

### **2. daily_bakes** (العجنات اليومية)
```
id           UUID (Primary Key)
date         DATE
shift        TEXT ('morning' or 'evening')
dough_count  INTEGER
total_profit NUMERIC(12,2)
created_at   TIMESTAMPTZ
updated_at   TIMESTAMPTZ
```

**Purpose**: Track daily bakery production by shift
**Replaces**: Old `dough` table

---

### **3. expenses** (المصاريف)
```
id          UUID (Primary Key)
date        DATE
type        TEXT ('labor', 'flour', 'other')
amount      NUMERIC(12,2)
note        TEXT
created_at  TIMESTAMPTZ
updated_at  TIMESTAMPTZ
```

**Purpose**: Track all expenses
**Replaces**: Old `expenses` and `flour` tables combined

---

### **4. differences** (الفروقات)
```
id          UUID (Primary Key)
date        DATE
type        TEXT ('waste', 'restaurant', 'other')
quantity    INTEGER
total_value NUMERIC(12,2)
created_at  TIMESTAMPTZ
updated_at  TIMESTAMPTZ
```

**Purpose**: Track differences in production
**Replaces**: Old `differences` and `electric_bread` tables

---

## 🔐 Security (RLS Policies)

All tables have RLS enabled with public access policies suitable for internal applications:

- ✅ **SELECT**: Anyone can read
- ✅ **INSERT**: Anyone can add records
- ✅ **UPDATE**: Anyone can modify records
- ✅ **DELETE**: Anyone can remove records

**Note**: "Public" means anyone with your Supabase anon key (stored in frontend code). This is suitable for internal company apps.

---

## 📈 Bonus Features

### **Views Created:**

1. **daily_summary** - Shows profit, expenses, and net profit by day
2. **monthly_summary** - Aggregates data by month

**Usage:**
```sql
-- Get daily summary
SELECT * FROM daily_summary WHERE date = '2025-01-05';

-- Get monthly totals
SELECT * FROM monthly_summary WHERE month = '2025-01-01';
```

### **Auto-Update Timestamps:**

All tables automatically update the `updated_at` column when records are modified.

---

## 🔄 Frontend Code Updates Needed

After running the schema, update your frontend code:

### **Before (Old Table Names):**
```javascript
await supabase.from('dough').select('*');
await supabase.from('electric_bread').select('*');
await supabase.from('flour').select('*');
```

### **After (New Table Names):**
```javascript
await supabase.from('daily_bakes').select('*');
await supabase.from('expenses').select('*').eq('type', 'flour');
await supabase.from('differences').select('*');
```

---

## 🧪 Testing After Reset

### **1. Verify Tables:**
```sql
SELECT tablename FROM pg_tables 
WHERE schemaname = 'public'
ORDER BY tablename;
```

**Expected Output:**
- daily_bakes
- differences
- expenses
- users

### **2. Verify User:**
```sql
SELECT username, email FROM users;
```

**Expected Output:**
```
username  | email
----------|---------------------
hus_dul9  | hus_dul9@gmail.com
```

### **3. Test Insert:**
```sql
INSERT INTO daily_bakes (shift, dough_count, total_profit)
VALUES ('morning', 50, 625.00);

SELECT * FROM daily_bakes;
```

---

## 🚨 Troubleshooting

### Error: "relation does not exist"
**Cause**: Schema didn't run completely
**Solution**: Run the entire `schema.sql` again

### Error: "violates check constraint"
**Cause**: Invalid data (e.g., wrong shift value)
**Solution**: Use only allowed values:
- `shift`: 'morning' or 'evening'
- `type` (expenses): 'labor', 'flour', 'other'
- `type` (differences): 'waste', 'restaurant', 'other'

### Error: "permission denied"
**Cause**: RLS policies not created
**Solution**: Verify policies with:
```sql
SELECT tablename, policyname FROM pg_policies;
```

---

## 📝 Migrating Old Data (Optional)

If you exported old data and want to import it:

### **From `dough` table → `daily_bakes`:**
```sql
INSERT INTO daily_bakes (date, shift, dough_count, total_profit)
SELECT 
    date,
    CASE 
        WHEN hour > 12 THEN 'evening'
        ELSE 'morning'
    END as shift,
    count,
    profit
FROM old_dough_export;
```

---

## ✅ Checklist

After running the schema:

- [ ] All old tables dropped
- [ ] New tables created (users, daily_bakes, expenses, differences)
- [ ] RLS enabled on all tables
- [ ] Policies created
- [ ] Default user exists
- [ ] Views created (daily_summary, monthly_summary)
- [ ] Test insert/select works
- [ ] Frontend code updated to use new table names

---

## 🎉 Done!

Your database is now clean, organized, and ready for production use with:
- ✅ Modern UUID primary keys
- ✅ Proper data validation
- ✅ Performance indexes
- ✅ Security policies
- ✅ Helpful views and functions

---

*Last Updated: 2025-01-05*
*Schema File: schema.sql*

