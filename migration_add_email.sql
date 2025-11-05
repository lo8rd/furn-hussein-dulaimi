-- ═══════════════════════════════════════════════════════════
-- 📧 Migration: Add Email Column to Users Table
-- ═══════════════════════════════════════════════════════════
-- Date: 2025-01-05
-- Purpose: Add real email addresses to support Supabase Auth
-- 
-- IMPORTANT: Run this in Supabase SQL Editor if your users table 
-- already exists without an email column
-- ═══════════════════════════════════════════════════════════

-- Step 1: Add email column to users table (if it doesn't exist)
ALTER TABLE users ADD COLUMN IF NOT EXISTS email VARCHAR(255);

-- Step 2: Update existing user with real email address
-- ⚠️ CRITICAL: Replace 'hus_dul9@gmail.com' with the actual email address
UPDATE users 
SET email = 'hus_dul9@gmail.com' 
WHERE username = 'hus_dul9';

-- Step 3: Make email column required and unique (after all users have emails)
-- Uncomment these lines after you've added email for ALL users:
-- ALTER TABLE users ALTER COLUMN email SET NOT NULL;
-- ALTER TABLE users ADD CONSTRAINT users_email_unique UNIQUE (email);

-- Step 4: Verify the update
SELECT username, email, created_at 
FROM users 
ORDER BY created_at DESC;

-- ═══════════════════════════════════════════════════════════
-- 📝 Notes for Adding More Users
-- ═══════════════════════════════════════════════════════════

-- When adding new users, always include a real email address:
-- INSERT INTO users (username, email, password) 
-- VALUES ('new_username', 'real_email@example.com', 'password123');

-- Example for adding more bakery users:
-- INSERT INTO users (username, email, password) 
-- VALUES 
--   ('baker1', 'baker1@furn-hussein.com', 'secure_password_1'),
--   ('manager1', 'manager1@furn-hussein.com', 'secure_password_2');

-- ═══════════════════════════════════════════════════════════
-- 🔐 Supabase Auth Setup
-- ═══════════════════════════════════════════════════════════

-- After running this migration:
-- 1. Go to Supabase Dashboard → Authentication → Providers → Email
-- 2. DISABLE "Confirm email" (since we're using real emails but no email server)
-- 3. ENABLE "Auto Confirm Users"
-- 4. Save changes

-- The first time a user logs in with their username:
-- - System will look up their email from the users table
-- - System will create a Supabase Auth account with that email
-- - Subsequent logins will use the existing Supabase Auth account

-- ═══════════════════════════════════════════════════════════
-- ✅ Verification
-- ═══════════════════════════════════════════════════════════

-- Check all users have email addresses:
SELECT 
    username,
    email,
    CASE 
        WHEN email IS NULL THEN '❌ Missing'
        WHEN email = '' THEN '❌ Empty'
        ELSE '✅ Has Email'
    END as email_status
FROM users;

-- ═══════════════════════════════════════════════════════════

