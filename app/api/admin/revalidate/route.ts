import { NextResponse } from 'next/server';
import { supabase } from '@/lib/supabase';
import { clearServerCache } from '@/lib/server-cache';

/**
 * Endpoint to clear the server-side in-memory cache.
 * Should be called by admin pages after successful data mutations.
 */
export async function POST(request: Request) {
    try {
        // Simple security check: Verify user is authenticated and is staff
        const { data: { user }, error: authError } = await supabase.auth.getUser();

        if (authError || !user) {
            return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
        }

        // Check if user is admin/staff
        const { data: profile, error: profileError } = await supabase
            .from('profiles')
            .select('role')
            .eq('id', user.id)
            .single();

        if (profileError || !['admin', 'staff'].includes(profile?.role)) {
            return NextResponse.json({ error: 'Forbidden' }, { status: 403 });
        }

        clearServerCache();

        return NextResponse.json({
            success: true,
            message: 'Server cache cleared successfully'
        });
    } catch (err: any) {
        console.error('[Revalidate API] Error:', err);
        return NextResponse.json({ error: err.message }, { status: 500 });
    }
}
