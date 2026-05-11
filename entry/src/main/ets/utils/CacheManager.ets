import { CacheDataWrapper, DefaultCacheConfig } from '../model/CacheModel';

export class CacheManager {
  private static instance: CacheManager | null = null;
  private cache: Map<string, CacheDataWrapper<Object>> = new Map();
  private config = DefaultCacheConfig;

  static getInstance(): CacheManager {
    if (CacheManager.instance === null) {
      CacheManager.instance = new CacheManager();
    }
    return CacheManager.instance;
  }

  saveCache<T>(key: string, data: T, expireTime: number): void {
    if (!this.config.enableCache) {
      return;
    }

    const now = Date.now();
    const wrapper: CacheDataWrapper<T> = {
      data: data,
      cacheTime: now,
      expireTime: now + expireTime,
      version: 1
    };

    this.cache.set(key, wrapper as CacheDataWrapper<Object>);
    this.cleanupCache();
  }

  getCache<T>(key: string): T | null {
    if (!this.config.enableCache) {
      return null;
    }

    const wrapper = this.cache.get(key);
    if (!wrapper) {
      return null;
    }

    if (!this.isCacheValid(wrapper)) {
      this.cache.delete(key);
      return null;
    }

    return wrapper.data as T;
  }

  isCacheValid(wrapper: CacheDataWrapper<Object>): boolean {
    const now = Date.now();
    return now < wrapper.expireTime;
  }

  clearCache(key?: string): void {
    if (key) {
      this.cache.delete(key);
    } else {
      this.cache.clear();
    }
  }

  updateExpireTime(key: string, newExpireTime: number): boolean {
    const wrapper = this.cache.get(key);
    if (!wrapper) {
      return false;
    }

    wrapper.expireTime = Date.now() + newExpireTime;
    return true;
  }

  getCacheSize(): number {
    return this.cache.size;
  }

  hasCache(key: string): boolean {
    const wrapper = this.cache.get(key);
    return wrapper !== undefined && this.isCacheValid(wrapper);
  }

  private cleanupCache(): void {
    if (this.cache.size <= this.config.maxCacheCount) {
      return;
    }

    const entries = Array.from(this.cache.entries());
    entries.sort((a, b) => a[1].cacheTime - b[1].cacheTime);

    const toRemove = this.cache.size - this.config.maxCacheCount;
    for (let i = 0; i < toRemove; i++) {
      this.cache.delete(entries[i][0]);
    }
  }
}
