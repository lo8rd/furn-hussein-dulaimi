-- ═══════════════════════════════════════════════════════════
-- 🚀 QUICK FIX: Add Email Column to Existing Database
-- ═══════════════════════════════════════════════════════════
-- Copy and paste this entire script into Supabase SQL Editor
-- Then click "Run" or press Ctrl+Enter
-- ═══════════════════════════════════════════════════════════

-- Step 1: Add email column to existing users table
ALTER TABLE users ADD COLUMN IF NOT EXISTS email VARCHAR(255);

-- Step 2: Update your user with a real email address
-- ⚠️ IMPORTANT: Change 'hus_dul9@gmail.com' to your actual email!
UPDATE users 
SET email = 'hus_dul9@gmail.com' 
WHERE username = 'hus_dul9';

-- Step 3: Verify the update worked
SELECT 
    username, 
    email,
    CASE 
        WHEN email IS NULL THEN '❌ No Email'
        WHEN email = '' THEN '❌ Empty'
        ELSE '✅ Has Email'
    END as status,
    created_at 
FROM users;

-- ═══════════════════════════════════════════════════════════
-- ✅ Expected Output:
-- ═══════════════════════════════════════════════════════════
-- username  | email               | status       | created_at
-- ----------|---------------------|--------------|------------------
-- hus_dul9  | hus_dul9@gmail.com  | ✅ Has Email | 2025-01-05 ...
-- ═══════════════════════════════════════════════════════════

-- 🎉 Done! Now you can test login at: login.html
-- The system will use the email from the database for authentication

