import { NextResponse } from 'next/server';
import { supabase } from '@/lib/supabase';
import { withServerCache } from '@/lib/server-cache';

const CACHE_TTL = 30 * 1000; // 30 seconds - products should update quickly after admin changes

export async function GET(request: Request) {
    const { searchParams } = new URL(request.url);
    const featured = searchParams.get('featured') === 'true';
    const limit = parseInt(searchParams.get('limit') || '50');
    const category = searchParams.get('category');

    // Build a cache key from params
    const cacheKey = `storefront:products:${featured}-${limit}-${category || 'all'}`;

    try {
        const { data, hit } = await withServerCache(cacheKey, CACHE_TTL, async () => {
            let query = supabase
                .from('products')
                .select(`
                    id, name, slug, price, compare_at_price, quantity, description, metadata,
                    categories(id, name, slug),
                    product_images(url, position),
                    product_variants(id, name, price, quantity)
                `)
                .order('created_at', { ascending: false });

            // Always filter active products
            query = query.eq('status', 'active');

            if (featured) {
                query = query.eq('featured', true).limit(limit);
            } else {
                query = query.limit(limit);
            }

            const { data, error } = await query;
            if (error) throw error;
            return data;
        });

        return NextResponse.json(data, {
            headers: {
                'Cache-Control': 'public, s-maxage=900, stale-while-revalidate=1800',
                'X-Cache': hit ? 'HIT' : 'MISS'
            }
        });
    } catch (err: any) {
        console.error('[Storefront API] Error:', err);
        return NextResponse.json({ error: err.message || 'Failed to fetch products' }, { status: 500 });
    }
}
