// ✅ Authentication Check - يتم تضمينه في جميع الصفحات المحمية
// يتحقق من تسجيل الدخول عبر Supabase قبل السماح بالوصول

// Wait for DOM and Supabase to be fully loaded before checking auth
async function checkAuth() {
    // Get current page
    const currentPage = window.location.pathname.split('/').pop();
    
    // Pages that don't require authentication
    const publicPages = ['login.html', '404.html', ''];
    
    // Skip check for public pages
    if (publicPages.includes(currentPage)) {
        return;
    }
    
    // Wait a bit for Supabase to initialize
    let attempts = 0;
    const maxAttempts = 30; // Wait up to 3 seconds (30 * 100ms)
    
    while (typeof supabase === 'undefined' && attempts < maxAttempts) {
        await new Promise(resolve => setTimeout(resolve, 100));
        attempts++;
    }
    
    // If Supabase still not loaded after waiting, redirect to login
    if (typeof supabase === 'undefined') {
        console.error('Supabase failed to load');
        window.location.href = 'login.html';
        return;
    }
    
    try {
        // Check if user is authenticated via Supabase Auth ONLY
        const { data: { session }, error } = await supabase.auth.getSession();
        
        if (error) {
            console.error('Session check error:', error);
            // Clear any stored data
            sessionStorage.clear();
            localStorage.clear();
            // Redirect to login
            window.location.href = 'login.html';
            return;
        }
        
        // Check if session exists and is valid
        if (!session) {
            console.warn('No valid Supabase session found');
            // Clear any stored data
            sessionStorage.clear();
            localStorage.clear();
            // Redirect to login
            window.location.href = 'login.html';
            return;
        }
        
        // Valid Supabase session found - allow access
        console.log('✅ Valid Supabase session found for user:', session.user.email);
        
        // Store flag for convenience (but never rely on it for auth)
        sessionStorage.setItem('isLoggedIn', 'true');
        
    } catch (error) {
        console.error('Auth check error:', error);
        // Clear any stored data
        sessionStorage.clear();
        localStorage.clear();
        // Redirect to login
        window.location.href = 'login.html';
    }
}

// Run auth check when page loads
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', checkAuth);
} else {
    checkAuth();
}

// Logout function
async function logout() {
    if (confirm('هل أنت متأكد من تسجيل الخروج؟')) {
        try {
            // Sign out from Supabase
            await supabase.auth.signOut();
            
            // Clear any local storage
            sessionStorage.clear();
            localStorage.clear();
            
            // Redirect to login page
            window.location.href = 'login.html';
        } catch (error) {
            console.error('Logout error:', error);
            alert('حدث خطأ أثناء تسجيل الخروج');
        }
    }
}

