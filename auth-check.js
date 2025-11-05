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
    const maxAttempts = 20; // Wait up to 2 seconds (20 * 100ms)
    
    while (typeof supabase === 'undefined' && attempts < maxAttempts) {
        await new Promise(resolve => setTimeout(resolve, 100));
        attempts++;
    }
    
    // If Supabase still not loaded after waiting, redirect to 404
    if (typeof supabase === 'undefined') {
        console.error('Supabase failed to load');
        window.location.href = '404.html';
        return;
    }
    
    try {
        // Check if user is authenticated via Supabase Auth
        const { data: { session }, error } = await supabase.auth.getSession();
        
        if (error) {
            console.error('Session check error:', error);
            // Try fallback: check sessionStorage
            if (sessionStorage.getItem('isLoggedIn') === 'true') {
                console.log('Using fallback session from sessionStorage');
                return; // Allow access
            }
            window.location.href = '404.html';
            return;
        }
        image.png
        if (!session) {
            // No Supabase session, check fallback
            if (sessionStorage.getItem('isLoggedIn') === 'true') {
                console.log('No Supabase session but found sessionStorage login');
                return; // Allow access
            }
            // No valid session at all, redirect to 404
            window.location.href = '404.html';
        } else {
            // Valid Supabase session found
            console.log('Valid Supabase session found');
            sessionStorage.setItem('isLoggedIn', 'true');
        }
    } catch (error) {
        console.error('Auth check error:', error);
        // Try fallback before redirecting
        if (sessionStorage.getItem('isLoggedIn') === 'true') {
            return; // Allow access
        }
        window.location.href = '404.html';
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

