import { createClient } from '@supabase/supabase-js';

let _client: ReturnType<typeof createClient> | null = null;

const getSupabase = () => {
    if (_client) return _client;

    const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || 'https://placeholder.supabase.co';
    const supabaseKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.placeholder';

    if (
        !process.env.NEXT_PUBLIC_SUPABASE_URL ||
        process.env.NEXT_PUBLIC_SUPABASE_URL === 'your_supabase_url'
    ) {
        console.warn('[supabase] Supabase client initialized with missing or placeholder environment variables');
    }

    try {
        _client = createClient(supabaseUrl, supabaseKey);
    } catch (e) {
        console.warn('[supabase] Failed to initialize Supabase client:', e);
        _client = {} as any;
    }

    return _client!;
};

export const supabase = new Proxy({} as any, {
    get: (_target, prop) => {
        const client = getSupabase();
        return (client as any)[prop];
    }
});
