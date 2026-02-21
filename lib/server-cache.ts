/**
 * Shared in-memory cache for server-side API routes.
 * This allows multiple API routes to share the same cache and 
 * enables centralized invalidation.
 */

interface CacheEntry<T> {
    data: T;
    timestamp: number;
}

// Using a global variable to persist cache across hot-reloads in development
// and across different API route executions.
const globalWithCache = global as typeof globalThis & {
    serverQueryCache?: Map<string, CacheEntry<any>>;
};

const cache = globalWithCache.serverQueryCache || new Map<string, CacheEntry<any>>();

if (process.env.NODE_ENV !== 'production') {
    globalWithCache.serverQueryCache = cache;
}

export function getServerCache<T>(key: string, ttlMs: number): T | null {
    const entry = cache.get(key);
    if (entry && (Date.now() - entry.timestamp) < ttlMs) {
        return entry.data;
    }
    return null;
}

export function setServerCache<T>(key: string, data: T): void {
    cache.set(key, { data, timestamp: Date.now() });
}

export function clearServerCache(): void {
    console.log('[Server Cache] Clearing all entries');
    cache.clear();
}

/**
 * Helper for server-side routes to handle caching logic
 */
export async function withServerCache<T>(
    key: string,
    ttlMs: number,
    fetchFn: () => Promise<T>
): Promise<{ data: T; hit: boolean }> {
    const cached = getServerCache<T>(key, ttlMs);
    if (cached !== null) {
        return { data: cached, hit: true };
    }

    const data = await fetchFn();
    setServerCache(key, data);
    return { data, hit: false };
}
