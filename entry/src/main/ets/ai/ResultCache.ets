import { InferenceResult, InferenceInput } from './types/InferenceTypes';

interface CacheEntry {
  result: InferenceResult;
  createdAt: number;
  lastAccessedAt: number;
  accessCount: number;
}

export class ResultCache {
  private static instance: ResultCache;

  private cache: Map<string, CacheEntry> = new Map();
  private readonly MAX_CACHE_SIZE: number = 100;
  private readonly CACHE_TIMEOUT: number = 1800000;
  private readonly CLEANUP_INTERVAL: number = 300000;

  private hits: number = 0;
  private misses: number = 0;

  private cleanupTimer: number | null = null;

  private constructor() {
    this.startCleanupTimer();
  }

  static getInstance(): ResultCache {
    if (!ResultCache.instance) {
      ResultCache.instance = new ResultCache();
    }
    return ResultCache.instance;
  }

  get(key: string): InferenceResult | null {
    const entry = this.cache.get(key);

    if (!entry) {
      this.misses++;
      return null;
    }

    if (Date.now() - entry.createdAt > this.CACHE_TIMEOUT) {
      this.cache.delete(key);
      this.misses++;
      return null;
    }

    entry.lastAccessedAt = Date.now();
    entry.accessCount++;
    this.hits++;

    return entry.result;
  }

  set(key: string, result: InferenceResult): void {
    if (this.cache.size >= this.MAX_CACHE_SIZE) {
      this.evictLRU();
    }

    this.cache.set(key, {
      result,
      createdAt: Date.now(),
      lastAccessedAt: Date.now(),
      accessCount: 1
    });
  }

  has(key: string): boolean {
    const entry = this.cache.get(key);
    if (!entry) {
      return false;
    }
    if (Date.now() - entry.createdAt > this.CACHE_TIMEOUT) {
      this.cache.delete(key);
      return false;
    }
    return true;
  }

  delete(key: string): boolean {
    return this.cache.delete(key);
  }

  clear(): void {
    this.cache.clear();
    this.hits = 0;
    this.misses = 0;
  }

  generateKey(input: InferenceInput, modelVersion: string): string {
    const inputStr = JSON.stringify(input);
    let hash = 0;
    for (let i = 0; i < inputStr.length; i++) {
      const char = inputStr.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash;
    }
    return `${modelVersion}-${hash.toString(16)}`;
  }

  evictLRU(): void {
    if (this.cache.size === 0) {
      return;
    }

    let oldestKey: string | null = null;
    let oldestTime = Infinity;

    this.cache.forEach((entry, key) => {
      if (entry.lastAccessedAt < oldestTime) {
        oldestTime = entry.lastAccessedAt;
        oldestKey = key;
      }
    });

    if (oldestKey) {
      this.cache.delete(oldestKey);
    }
  }

  getHitRate(): number {
    const total = this.hits + this.misses;
    if (total === 0) {
      return 0;
    }
    return this.hits / total;
  }

  getStats(): CacheStats {
    return {
      size: this.cache.size,
      maxSize: this.MAX_CACHE_SIZE,
      hits: this.hits,
      misses: this.misses,
      hitRate: this.getHitRate()
    };
  }

  private startCleanupTimer(): void {
    const timer = setInterval(() => {
      this.cleanupExpired();
    }, this.CLEANUP_INTERVAL);
    this.cleanupTimer = timer as number;
  }

  private cleanupExpired(): void {
    const now = Date.now();
    const keysToDelete: string[] = [];

    this.cache.forEach((entry, key) => {
      if (now - entry.createdAt > this.CACHE_TIMEOUT) {
        keysToDelete.push(key);
      }
    });

    keysToDelete.forEach(key => this.cache.delete(key));
  }

  stopCleanupTimer(): void {
    if (this.cleanupTimer !== null) {
      clearInterval(this.cleanupTimer);
      this.cleanupTimer = null;
    }
  }
}

export interface CacheStats {
  size: number;
  maxSize: number;
  hits: number;
  misses: number;
  hitRate: number;
}
