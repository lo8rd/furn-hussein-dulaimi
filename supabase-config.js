// ✅ Supabase Configuration
const SUPABASE_URL = 'https://yhbyypzwuyyhvblueevo.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InloYnl5cHp3dXl5aHZibHVlZXZvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIyODYyODUsImV4cCI6MjA3Nzg2MjI4NX0.HhnILqycYKkdUp95aVM0tSPY6pWyxaplBAiTL80AORs';

// Wait for Supabase library to load, then create client
// الانتظار حتى يتم تحميل مكتبة Supabase من CDN
let supabase;
if (typeof window.supabase !== 'undefined') {
    const { createClient } = window.supabase;
    supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
        auth: {
            autoRefreshToken: true,
            persistSession: true,
            detectSessionInUrl: true
        }
    });
    console.log('✅ Supabase client initialized successfully');
} else {
    console.error('❌ Supabase library not loaded from CDN!');
}

// تنسيق الأرقام مع فواصل الآلاف
function formatNumber(number, decimals = 0) {
    if (number === null || number === undefined || isNaN(number)) return '0';
    return Number(number).toLocaleString('en-US', {
        minimumFractionDigits: decimals,
        maximumFractionDigits: decimals
    });
}

// تنسيق الأرقام المحفوظة بالألف (مثلاً 150 يعرض كـ 150,000)
function formatThousands(number, decimals = 0) {
    if (number === null || number === undefined || isNaN(number)) return '0';
    const fullNumber = number * 1000;
    return formatNumber(fullNumber, decimals);
}

