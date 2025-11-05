// ✅ نظام قاعدة البيانات باستخدام Supabase
// Database System using Supabase

// Note: Supabase client is initialized in supabase-config.js
// This file uses the global 'supabase' variable from that file

class Database {
    constructor() {
        // استخدام كائن supabase المُعرف في supabase-config.js
        this.supabase = supabase;
    }

    // ========================================
    // جدول العجنات (Daily Bakes Operations)
    // ========================================
    
    async addDough(data) {
        // Convert old structure (morning/evening counts) to new structure (shift-based)
        const records = [];
        
        // Add morning shift if count > 0
        if (data.morning_count && parseInt(data.morning_count) > 0) {
            const morning_count = parseInt(data.morning_count) || 0;
            const morning_profit = morning_count * 10 / 8;
            records.push({
                date: data.date,
                shift: 'morning',
                dough_count: morning_count,
                total_profit: morning_profit
            });
        }
        
        // Add evening shift if count > 0
        if (data.evening_count && parseInt(data.evening_count) > 0) {
            const evening_count = parseInt(data.evening_count) || 0;
            const evening_profit = evening_count * 10 / 8;
            records.push({
                date: data.date,
                shift: 'evening',
                dough_count: evening_count,
                total_profit: evening_profit
            });
        }
        
        if (records.length === 0) {
            throw new Error('At least one shift must have a count greater than 0');
        }
        
        const { data: result, error } = await this.supabase
            .from('daily_bakes')
            .insert(records)
            .select();

        if (error) {
            console.error('Error adding dough:', error);
            throw error;
        }
        return result;
    }

    async getAllDough() {
        const { data, error } = await this.supabase
            .from('daily_bakes')
            .select('*')
            .order('date', { ascending: true })
            .order('shift', { ascending: true });

        if (error) {
            console.error('Error getting dough:', error);
            return [];
        }
        
        // Convert to old format for compatibility
        return this._convertDailyBakesToOldFormat(data);
    }

    async getTodayDough() {
        const today = new Date().toISOString().split('T')[0];
        const { data, error } = await this.supabase
            .from('daily_bakes')
            .select('*')
            .eq('date', today)
            .order('created_at', { ascending: true });

        if (error) {
            console.error('Error getting today dough:', error);
            return [];
        }
        
        // Convert to old format for compatibility
        return this._convertDailyBakesToOldFormat(data);
    }

    async getDoughByDate(date) {
        const { data, error } = await this.supabase
            .from('daily_bakes')
            .select('*')
            .eq('date', date);

        if (error && error.code !== 'PGRST116') {
            console.error('Error getting dough by date:', error);
            return [];
        }
        
        // Convert to old format for compatibility
        return this._convertDailyBakesToOldFormat(data);
    }

    async getDoughRecords() {
        const today = new Date().toISOString().split('T')[0];
        const { data, error } = await this.supabase
            .from('daily_bakes')
            .select('*')
            .lt('date', today)
            .order('date', { ascending: false });

        if (error) {
            console.error('Error getting dough records:', error);
            return [];
        }
        
        // Convert to old format for compatibility
        return this._convertDailyBakesToOldFormat(data);
    }

    async getDoughRecordsByDateRange(startDate, endDate) {
        const { data, error } = await this.supabase
            .from('daily_bakes')
            .select('*')
            .gte('date', startDate)
            .lte('date', endDate)
            .order('date', { ascending: false });

        if (error) {
            console.error('Error getting dough records by range:', error);
            return [];
        }
        
        // Convert to old format for compatibility
        return this._convertDailyBakesToOldFormat(data);
    }

    async updateDough(id, data) {
        // For daily_bakes, we need to update the specific shift record
        const dough_count = parseInt(data.morning_count || data.evening_count) || 0;
        const total_profit = dough_count * 10 / 8;

        const { data: result, error } = await this.supabase
            .from('daily_bakes')
            .update({
                date: data.date,
                dough_count: dough_count,
                total_profit: total_profit
            })
            .eq('id', id)
            .select()
            .single();

        if (error) {
            console.error('Error updating dough:', error);
            throw error;
        }
        return result;
    }

    async deleteDough(id) {
        const { error } = await this.supabase
            .from('daily_bakes')
            .delete()
            .eq('id', id);

        if (error) {
            console.error('Error deleting dough:', error);
            throw error;
        }
    }

    // Helper function to convert daily_bakes format to old dough format
    _convertDailyBakesToOldFormat(dailyBakes) {
        if (!dailyBakes || dailyBakes.length === 0) return [];
        
        // Group by date
        const grouped = {};
        dailyBakes.forEach(bake => {
            if (!grouped[bake.date]) {
                grouped[bake.date] = {
                    id: bake.id,
                    date: bake.date,
                    morning_count: 0,
                    evening_count: 0,
                    morning_profit: 0,
                    evening_profit: 0,
                    total_profit: 0,
                    created_at: bake.created_at
                };
            }
            
            if (bake.shift === 'morning') {
                grouped[bake.date].morning_count = bake.dough_count;
                grouped[bake.date].morning_profit = bake.total_profit;
            } else if (bake.shift === 'evening') {
                grouped[bake.date].evening_count = bake.dough_count;
                grouped[bake.date].evening_profit = bake.total_profit;
            }
            
            grouped[bake.date].total_profit += bake.total_profit;
        });
        
        return Object.values(grouped);
    }

    // ========================================
    // جدول الطحين (Flour Operations)
    // ========================================
    
    async addFlour(data) {
        const { data: result, error } = await this.supabase
            .from('flour')
            .insert([{
                date: data.date,
                bag_price: parseFloat(data.bag_price) || 0,
                bag_count: parseInt(data.bag_count) || 0,
                total_cost: (parseFloat(data.bag_price) || 0) * (parseInt(data.bag_count) || 0)
            }])
            .select()
            .single();

        if (error) {
            console.error('Error adding flour:', error);
            throw error;
        }
        return result;
    }

    async getAllFlour() {
        const { data, error } = await this.supabase
            .from('flour')
            .select('*')
            .order('date', { ascending: false });

        if (error) {
            console.error('Error getting flour:', error);
            return [];
        }
        return data || [];
    }

    async getFlourByDate(date) {
        const { data, error } = await this.supabase
            .from('flour')
            .select('*')
            .eq('date', date);

        if (error) {
            console.error('Error getting flour by date:', error);
            return [];
        }
        return data || [];
    }

    async updateFlour(id, data) {
        const { data: result, error } = await this.supabase
            .from('flour')
            .update({
                date: data.date,
                bag_price: parseFloat(data.bag_price) || 0,
                bag_count: parseInt(data.bag_count) || 0,
                total_cost: (parseFloat(data.bag_price) || 0) * (parseInt(data.bag_count) || 0)
            })
            .eq('id', id)
            .select()
            .single();

        if (error) {
            console.error('Error updating flour:', error);
            throw error;
        }
        return result;
    }

    async deleteFlour(id) {
        const { error } = await this.supabase
            .from('flour')
            .delete()
            .eq('id', id);

        if (error) {
            console.error('Error deleting flour:', error);
            throw error;
        }
    }

    // ========================================
    // جدول المصاريف (Expenses Operations)
    // ========================================
    
    async addExpense(data) {
        const { data: result, error } = await this.supabase
            .from('expenses')
            .insert([{
                date: data.date,
                expense_name: data.expense_name,
                amount: parseFloat(data.amount) || 0
            }])
            .select()
            .single();

        if (error) {
            console.error('Error adding expense:', error);
            throw error;
        }
        return result;
    }

    async getAllExpenses() {
        const { data, error } = await this.supabase
            .from('expenses')
            .select('*')
            .order('date', { ascending: false });

        if (error) {
            console.error('Error getting expenses:', error);
            return [];
        }
        return data || [];
    }

    async getExpensesByDate(date) {
        const { data, error } = await this.supabase
            .from('expenses')
            .select('*')
            .eq('date', date);

        if (error) {
            console.error('Error getting expenses by date:', error);
            return [];
        }
        return data || [];
    }

    async updateExpense(id, data) {
        const { data: result, error } = await this.supabase
            .from('expenses')
            .update({
                date: data.date,
                expense_name: data.expense_name,
                amount: parseFloat(data.amount) || 0
            })
            .eq('id', id)
            .select()
            .single();

        if (error) {
            console.error('Error updating expense:', error);
            throw error;
        }
        return result;
    }

    async deleteExpense(id) {
        const { error } = await this.supabase
            .from('expenses')
            .delete()
            .eq('id', id);

        if (error) {
            console.error('Error deleting expense:', error);
            throw error;
        }
    }

    // ========================================
    // جدول الصمون الكهربائي (Electric Bread)
    // ========================================
    
    async addElectricBread(data) {
        const jerqTotal = (parseInt(data.jerq_count) || 0) * 250;
        const circleTotal = this.calculateCirclePrice(parseInt(data.circle_count) || 0);

        const { data: result, error } = await this.supabase
            .from('electric_bread')
            .insert([{
                date: data.date,
                jerq_count: parseInt(data.jerq_count) || 0,
                jerq_total: jerqTotal,
                circle_count: parseInt(data.circle_count) || 0,
                circle_total: circleTotal,
                total_profit: jerqTotal + circleTotal
            }])
            .select()
            .single();

        if (error) {
            console.error('Error adding electric bread:', error);
            throw error;
        }
        return result;
    }

    async getAllElectricBread() {
        const { data, error } = await this.supabase
            .from('electric_bread')
            .select('*')
            .order('date', { ascending: false });

        if (error) {
            console.error('Error getting electric bread:', error);
            return [];
        }
        return data || [];
    }

    async getElectricBreadByDate(date) {
        const { data, error } = await this.supabase
            .from('electric_bread')
            .select('*')
            .eq('date', date);

        if (error) {
            console.error('Error getting electric bread by date:', error);
            return [];
        }
        return data || [];
    }

    async updateElectricBread(id, data) {
        const jerqTotal = (parseInt(data.jerq_count) || 0) * 250;
        const circleTotal = this.calculateCirclePrice(parseInt(data.circle_count) || 0);

        const { data: result, error } = await this.supabase
            .from('electric_bread')
            .update({
                date: data.date,
                jerq_count: parseInt(data.jerq_count) || 0,
                jerq_total: jerqTotal,
                circle_count: parseInt(data.circle_count) || 0,
                circle_total: circleTotal,
                total_profit: jerqTotal + circleTotal
            })
            .eq('id', id)
            .select()
            .single();

        if (error) {
            console.error('Error updating electric bread:', error);
            throw error;
        }
        return result;
    }

    async deleteElectricBread(id) {
        const { error } = await this.supabase
            .from('electric_bread')
            .delete()
            .eq('id', id);

        if (error) {
            console.error('Error deleting electric bread:', error);
            throw error;
        }
    }

    // حساب سعر الدائري
    calculateCirclePrice(count) {
        if (count <= 0) return 0;

        let total = 0;
        let remaining = count;

        while (remaining > 0) {
            if (remaining >= 6) {
                total += 1000;
                remaining -= 6;
            } else if (remaining >= 4) {
                total += 750;
                remaining -= 4;
            } else if (remaining >= 3) {
                total += 500;
                remaining -= 3;
            } else {
                total += 250 * remaining;
                remaining = 0;
            }
        }

        return total;
    }

    // ========================================
    // جدول الفروقات (Differences Operations)
    // ========================================
    
    async addDifference(data) {
        const count = parseInt(data.count) || 0;
        // حساب المبلغ: (عدد الصمون ÷ 8) - يُخزن بالألف ليُعرض بـ formatThousands()
        const amount = count / 8;

        const { data: result, error } = await this.supabase
            .from('differences')
            .insert([{
                date: data.date,
                type: data.type,
                count: count,
                amount: amount
            }])
            .select()
            .single();

        if (error) {
            console.error('Error adding difference:', error);
            throw error;
        }
        return result;
    }

    async getAllDifferences() {
        const { data, error } = await this.supabase
            .from('differences')
            .select('*')
            .order('date', { ascending: false });

        if (error) {
            console.error('Error getting differences:', error);
            return [];
        }
        return data || [];
    }

    async getDifferencesByDate(date) {
        const { data, error } = await this.supabase
            .from('differences')
            .select('*')
            .eq('date', date);

        if (error) {
            console.error('Error getting differences by date:', error);
            return [];
        }
        return data || [];
    }

    async updateDifference(id, data) {
        const count = parseInt(data.count) || 0;
        // حساب المبلغ: (عدد الصمون ÷ 8) - يُخزن بالألف ليُعرض بـ formatThousands()
        const amount = count / 8;

        const { data: result, error } = await this.supabase
            .from('differences')
            .update({
                date: data.date,
                type: data.type,
                count: count,
                amount: amount
            })
            .eq('id', id)
            .select()
            .single();

        if (error) {
            console.error('Error updating difference:', error);
            throw error;
        }
        return result;
    }

    async deleteDifference(id) {
        const { error } = await this.supabase
            .from('differences')
            .delete()
            .eq('id', id);

        if (error) {
            console.error('Error deleting difference:', error);
            throw error;
        }
    }

    // ========================================
    // الإحصائيات (Statistics)
    // ========================================
    
    async getStats(period = 'today') {
        const today = new Date().toISOString().split('T')[0];
        let dateFilter = today;

        if (period === 'week') {
            const weekAgo = new Date();
            weekAgo.setDate(weekAgo.getDate() - 7);
            dateFilter = weekAgo.toISOString().split('T')[0];
        } else if (period === 'month') {
            const monthAgo = new Date();
            monthAgo.setMonth(monthAgo.getMonth() - 1);
            dateFilter = monthAgo.toISOString().split('T')[0];
        }

        // Fetch all data from new tables
        const [doughData, expensesData, differencesData] = await Promise.all([
            period === 'today' 
                ? this.supabase.from('daily_bakes').select('*').eq('date', dateFilter)
                : this.supabase.from('daily_bakes').select('*').gte('date', dateFilter),
            period === 'today'
                ? this.supabase.from('expenses').select('*').eq('date', dateFilter)
                : this.supabase.from('expenses').select('*').gte('date', dateFilter),
            period === 'today'
                ? this.supabase.from('differences').select('*').eq('date', dateFilter)
                : this.supabase.from('differences').select('*').gte('date', dateFilter)
        ]);

        const dough = doughData.data || [];
        const expenses = expensesData.data || [];
        const differences = differencesData.data || [];

        // Calculate totals from new daily_bakes structure
        const totalDoughCount = dough.reduce((sum, d) => sum + (d.dough_count || 0), 0);
        const totalProfit = dough.reduce((sum, d) => sum + parseFloat(d.total_profit || 0), 0);
        
        // Split expenses: flour vs other expenses
        const totalFlourCost = expenses
            .filter(e => e.type === 'flour')
            .reduce((sum, e) => sum + parseFloat(e.amount || 0), 0);
        const totalExpenses = expenses
            .filter(e => e.type !== 'flour')
            .reduce((sum, e) => sum + parseFloat(e.amount || 0), 0);
        
        // Differences using new structure (total_value instead of amount)
        const totalDifferences = differences.reduce((sum, d) => sum + parseFloat(d.total_value || 0), 0);
        const netProfit = totalProfit - totalFlourCost - totalExpenses - totalDifferences;

        return {
            doughCount: totalDoughCount,
            profit: totalProfit,
            flourCost: totalFlourCost,
            expenses: totalExpenses,
            differences: totalDifferences,
            netProfit: netProfit
        };
    }

    // ========================================
    // دوال تنسيق الأرقام
    // ========================================
    
    formatNumber(number, decimals = 0) {
        if (number === null || number === undefined || isNaN(number)) return '0';
        return Number(number).toLocaleString('en-US', {
            minimumFractionDigits: decimals,
            maximumFractionDigits: decimals
        });
    }

    formatThousands(number, decimals = 0) {
        if (number === null || number === undefined || isNaN(number)) return '0';
        const fullNumber = number * 1000;
        return this.formatNumber(fullNumber, decimals);
    }
}

// إنشاء نسخة عامة من قاعدة البيانات
const db = new Database();

// دوال تنسيق عامة
function formatNumber(number, decimals = 0) {
    return db.formatNumber(number, decimals);
}

function formatThousands(number, decimals = 0) {
    return db.formatThousands(number, decimals);
}
