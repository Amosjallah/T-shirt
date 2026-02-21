import { NextResponse } from 'next/server';
import { supabase } from '@/lib/supabase';
import { withServerCache } from '@/lib/server-cache';

const CACHE_TTL = 30 * 1000; // 30 seconds - categories should update quickly after admin changes

export async function GET() {
    try {
        const { data, hit } = await withServerCache('storefront:categories', CACHE_TTL, async () => {
            const { data, error } = await supabase
                .from('categories')
                .select('id, name, slug, image_url, parent_id, metadata')
                .eq('status', 'active')
                .order('name');

            if (error) throw error;
            return data;
        });

        return NextResponse.json(data, {
            headers: {
                'Cache-Control': 'public, s-maxage=1800, stale-while-revalidate=3600',
                'X-Cache': hit ? 'HIT' : 'MISS'
            }
        });
    } catch (err: any) {
        console.error('[Storefront API] Error:', err);
        return NextResponse.json({ error: err.message || 'Failed to fetch categories' }, { status: 500 });
    }
}
