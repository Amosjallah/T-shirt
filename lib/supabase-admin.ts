import { createClient } from '@supabase/supabase-js';

/**
 * Server-side Supabase client with service role key.
 * ONLY use this in API routes and server actions — NEVER in client components.
 * This bypasses RLS, so always verify the caller is authorized first.
 */

let _adminClient: ReturnType<typeof createClient> | null = null;

const getSupabaseAdmin = () => {
    if (_adminClient) return _adminClient;

    const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || 'https://placeholder.supabase.co';
    const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.placeholder';

    try {
        _adminClient = createClient(supabaseUrl, supabaseServiceKey, {
            auth: {
                autoRefreshToken: false,
                persistSession: false,
            },
        });
    } catch (e) {
        console.warn('[supabase-admin] Failed to initialize Supabase Admin client:', e);
        _adminClient = {} as any;
    }

    return _adminClient!;
};

// Lazy-loaded proxy for supabaseAdmin
export const supabaseAdmin = new Proxy({} as any, {
    get: (_target, prop) => {
        const admin = getSupabaseAdmin();
        return (admin as any)[prop];
    }
});
