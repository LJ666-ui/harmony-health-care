import { HttpUtil } from '../common/utils/HttpUtil';

interface CacheItem<T> {
  data: T;
  timestamp: number;
  expireTime: number;
}

type GenericFunction = (...args: unknown[]) => unknown;

export class PerformanceOptimizer {
  private static instance: PerformanceOptimizer | null = null;
  private cache: Map<string, CacheItem<unknown>> = new Map();
  private requestQueue: Map<string, Promise<unknown>> = new Map();
  private maxCacheSize: number = 100;
  private defaultExpireTime: number = 300000;

  private constructor() {}

  static getInstance(): PerformanceOptimizer {
    if (!PerformanceOptimizer.instance) {
      PerformanceOptimizer.instance = new PerformanceOptimizer();
    }
    return PerformanceOptimizer.instance;
  }

  async getCachedData<T>(
    key: string,
    fetchFn: () => Promise<T>,
    expireTime: number = this.defaultExpireTime
  ): Promise<T> {
    const cached = this.cache.get(key);
    const now = Date.now();

    if (cached && (now - cached.timestamp) < cached.expireTime) {
      console.info(`[PerformanceOptimizer] 缓存命中: ${key}`);
      return cached.data as T;
    }

    if (this.requestQueue.has(key)) {
      console.info(`[PerformanceOptimizer] 请求合并: ${key}`);
      return this.requestQueue.get(key) as Promise<T>;
    }

    console.info(`[PerformanceOptimizer] 发起新请求: ${key}`);
    const requestPromise = fetchFn();
    this.requestQueue.set(key, requestPromise);

    try {
      const data = await requestPromise;
      
      this.cache.set(key, {
        data: data,
        timestamp: now,
        expireTime: expireTime
      });

      if (this.cache.size > this.maxCacheSize) {
        this.evictOldestCache();
      }

      return data;
    } finally {
      this.requestQueue.delete(key);
    }
  }

  setCache<T>(key: string, data: T, expireTime: number = this.defaultExpireTime): void {
    this.cache.set(key, {
      data: data,
      timestamp: Date.now(),
      expireTime: expireTime
    });

    if (this.cache.size > this.maxCacheSize) {
      this.evictOldestCache();
    }
  }

  getCache<T>(key: string): T | null {
    const cached = this.cache.get(key);
    const now = Date.now();

    if (cached && (now - cached.timestamp) < cached.expireTime) {
      return cached.data as T;
    }

    return null;
  }

  clearCache(key?: string): void {
    if (key) {
      this.cache.delete(key);
    } else {
      this.cache.clear();
    }
    console.info(`[PerformanceOptimizer] 缓存已清除: ${key || '全部'}`);
  }

  private evictOldestCache(): void {
    let oldestKey: string | null = null;
    let oldestTimestamp: number = Infinity;

    this.cache.forEach((value, key) => {
      if (value.timestamp < oldestTimestamp) {
        oldestTimestamp = value.timestamp;
        oldestKey = key;
      }
    });

    if (oldestKey) {
      this.cache.delete(oldestKey);
      console.info(`[PerformanceOptimizer] 驱逐最旧缓存: ${oldestKey}`);
    }
  }

  getCacheSize(): number {
    return this.cache.size;
  }

  getCacheStats(): { size: number; keys: string[] } {
    return {
      size: this.cache.size,
      keys: Array.from(this.cache.keys())
    };
  }

  shouldLoadMore(
    currentIndex: number,
    totalItems: number,
    threshold: number = 10
  ): boolean {
    return currentIndex >= totalItems - threshold;
  }

  calculateVisibleRange(
    scrollTop: number,
    itemHeight: number,
    containerHeight: number,
    totalItems: number
  ): { start: number; end: number } {
    const visibleCount = Math.ceil(containerHeight / itemHeight);
    const start = Math.max(0, Math.floor(scrollTop / itemHeight) - 2);
    const end = Math.min(totalItems, start + visibleCount + 4);

    return { start, end };
  }

  debounce<T extends GenericFunction>(
    fn: T,
    delay: number = 300
  ): (...args: Parameters<T>) => void {
    let timeoutId: number | null = null;

    return (...args: Parameters<T>) => {
      if (timeoutId !== null) {
        clearTimeout(timeoutId);
      }

      timeoutId = setTimeout(() => {
        fn(...args);
        timeoutId = null;
      }, delay);
    };
  }

  throttle<T extends GenericFunction>(
    fn: T,
    interval: number = 300
  ): (...args: Parameters<T>) => void {
    let lastTime: number = 0;

    return (...args: Parameters<T>) => {
      const now = Date.now();
      if (now - lastTime >= interval) {
        fn(...args);
        lastTime = now;
      }
    };
  }

  async batchRequest<T>(
    requests: Array<() => Promise<T>>,
    batchSize: number = 5
  ): Promise<T[]> {
    const results: T[] = [];

    for (let i = 0; i < requests.length; i += batchSize) {
      const batch = requests.slice(i, i + batchSize);
      const batchResults = await Promise.all(batch.map(req => req()));
      results.push(...batchResults);
    }

    return results;
  }

  measurePerformance(label: string): { end: () => void } {
    const startTime = Date.now();

    return {
      end: () => {
        const duration = Date.now() - startTime;
        console.info(`[Performance] ${label}: ${duration}ms`);
      }
    };
  }
}

export const performanceOptimizer = PerformanceOptimizer.getInstance();
