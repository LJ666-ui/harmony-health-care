/**
 * 页面缓存机制
 * 实现页面数据的缓存，加快页面回退速度
 * 
 * @author AI Assistant
 * @date 2026-04-27
 */

import { performanceMonitor, MetricType } from './PerformanceMonitor';

/**
 * 页面缓存项
 */
interface PageCacheItem {
  pageName: string;              // 页面名称
  pagePath: string;              // 页面路径
  data: unknown;                 // 页面数据
  state: Map<string, unknown>;   // 页面状态
  timestamp: number;             // 缓存时间戳
  accessCount: number;           // 访问次数
  lastAccessTime: number;        // 最后访问时间
  size: number;                  // 数据大小（估算）
}

/**
 * 页面缓存配置
 */
export interface PageCacheConfig {
  enabled: boolean;              // 是否启用缓存
  maxSize: number;               // 最大缓存数量
  maxMemorySize: number;         // 最大内存占用（MB）
  expireTime: number;            // 过期时间（毫秒）
  enableLRU: boolean;            // 是否启用LRU淘汰
  enablePreload: boolean;        // 是否启用预加载
}

/**
 * 缓存统计
 */
export interface CacheStats {
  totalCaches: number;           // 总缓存数
  hitCount: number;              // 命中次数
  missCount: number;             // 未命中次数
  hitRate: number;               // 命中率
  totalMemory: number;           // 总内存占用（MB）
  avgAccessCount: number;        // 平均访问次数
}

/**
 * 页面缓存管理器
 */
export class PageCache {
  private static instance: PageCache | null = null;
  
  // 配置
  private config: PageCacheConfig = {
    enabled: true,
    maxSize: 10,
    maxMemorySize: 50,           // 50MB
    expireTime: 600000,          // 10分钟
    enableLRU: true,
    enablePreload: true
  };
  
  // 缓存映射
  private cache: Map<string, PageCacheItem> = new Map();
  
  // 统计信息
  private stats: CacheStats = {
    totalCaches: 0,
    hitCount: 0,
    missCount: 0,
    hitRate: 0,
    totalMemory: 0,
    avgAccessCount: 0
  };
  
  // 预加载队列
  private preloadQueue: string[] = [];
  
  // 私有构造函数
  private constructor() {
    console.info('[PageCache] 初始化页面缓存管理器');
  }
  
  /**
   * 获取单例实例
   */
  public static getInstance(): PageCache {
    if (!PageCache.instance) {
      PageCache.instance = new PageCache();
    }
    return PageCache.instance;
  }
  
  /**
   * 缓存页面
   * @param pageName 页面名称
   * @param pagePath 页面路径
   * @param data 页面数据
   * @param state 页面状态（可选）
   */
  public set(pageName: string, pagePath: string, data: unknown, state?: Map<string, unknown>): void {
    if (!this.config.enabled) {
      return;
    }
    
    // 检查是否需要淘汰
    this.checkEviction();
    
    // 估算数据大小
    const size = this.estimateSize(data);
    
    // 创建缓存项
    const item: PageCacheItem = {
      pageName,
      pagePath,
      data,
      state: state || new Map(),
      timestamp: Date.now(),
      accessCount: 0,
      lastAccessTime: Date.now(),
      size
    };
    
    // 添加到缓存
    this.cache.set(pageName, item);
    
    // 更新统计
    this.updateStats();
    
    console.debug(`[PageCache] 缓存页面: ${pageName}, 大小: ${size}KB`);
  }
  
  /**
   * 获取缓存的页面
   * @param pageName 页面名称
   */
  public get<T = unknown>(pageName: string): { data: T; state: Map<string, unknown> } | null {
    if (!this.config.enabled) {
      this.stats.missCount++;
      return null;
    }
    
    const item = this.cache.get(pageName);
    
    if (!item) {
      this.stats.missCount++;
      this.updateHitRate();
      console.debug(`[PageCache] 缓存未命中: ${pageName}`);
      return null;
    }
    
    // 检查是否过期
    if (Date.now() - item.timestamp > this.config.expireTime) {
      this.cache.delete(pageName);
      this.stats.missCount++;
      this.updateHitRate();
      console.debug(`[PageCache] 缓存已过期: ${pageName}`);
      return null;
    }
    
    // 更新访问信息
    item.accessCount++;
    item.lastAccessTime = Date.now();
    
    this.stats.hitCount++;
    this.updateHitRate();
    
    console.debug(`[PageCache] 缓存命中: ${pageName}, 访问次数: ${item.accessCount}`);
    
    return {
      data: item.data as T,
      state: item.state
    };
  }
  
  /**
   * 检查页面是否已缓存
   * @param pageName 页面名称
   */
  public has(pageName: string): boolean {
    const item = this.cache.get(pageName);
    if (!item) {
      return false;
    }
    
    // 检查是否过期
    return (Date.now() - item.timestamp) <= this.config.expireTime;
  }
  
  /**
   * 删除页面缓存
   * @param pageName 页面名称
   */
  public delete(pageName: string): boolean {
    const result = this.cache.delete(pageName);
    if (result) {
      this.updateStats();
      console.debug(`[PageCache] 删除缓存: ${pageName}`);
    }
    return result;
  }
  
  /**
   * 清空所有缓存
   */
  public clear(): void {
    this.cache.clear();
    this.updateStats();
    console.info('[PageCache] 清空所有缓存');
  }
  
  /**
   * 获取缓存统计
   */
  public getStats(): CacheStats {
    return { ...this.stats };
  }
  
  /**
   * 获取所有缓存的页面名称
   */
  public getCachedPages(): string[] {
    return Array.from(this.cache.keys());
  }
  
  /**
   * 获取缓存详情
   * @param pageName 页面名称
   */
  public getCacheDetail(pageName: string): PageCacheItem | null {
    const item = this.cache.get(pageName);
    return item ? { ...item } : null;
  }
  
  /**
   * 预加载页面
   * @param pagePath 页面路径
   */
  public preload(pagePath: string): void {
    if (!this.config.enablePreload) {
      return;
    }
    
    if (!this.preloadQueue.includes(pagePath)) {
      this.preloadQueue.push(pagePath);
      console.debug(`[PageCache] 添加预加载: ${pagePath}`);
    }
  }
  
  /**
   * 执行预加载
   */
  public async executePreload(): Promise<void> {
    if (!this.config.enablePreload || this.preloadQueue.length === 0) {
      return;
    }
    
    console.info(`[PageCache] 开始预加载 ${this.preloadQueue.length} 个页面`);
    
    for (const pagePath of this.preloadQueue) {
      try {
        // TODO: 实际预加载页面数据
        // const data = await PageLoader.load(pagePath);
        // this.set(pagePath, pagePath, data);
        console.debug(`[PageCache] 预加载页面: ${pagePath}`);
      } catch (error) {
        console.error(`[PageCache] 预加载失败: ${pagePath}`, error);
      }
    }
    
    this.preloadQueue = [];
  }
  
  /**
   * 更新配置
   */
  public updateConfig(config: Partial<PageCacheConfig>): void {
    this.config = { ...this.config, ...config };
    console.info('[PageCache] 更新配置:', JSON.stringify(this.config));
  }
  
  /**
   * 获取当前配置
   */
  public getConfig(): PageCacheConfig {
    return { ...this.config };
  }
  
  // ==================== 私有方法 ====================
  
  /**
   * 检查是否需要淘汰缓存
   */
  private checkEviction(): void {
    // 检查数量限制
    if (this.cache.size >= this.config.maxSize) {
      this.evict();
    }
    
    // 检查内存限制
    if (this.stats.totalMemory >= this.config.maxMemorySize) {
      this.evict();
    }
  }
  
  /**
   * 淘汰缓存
   */
  private evict(): void {
    if (!this.config.enableLRU) {
      // 简单淘汰：删除最早的缓存
      const firstKey = this.cache.keys().next().value;
      if (firstKey) {
        this.cache.delete(firstKey);
        console.debug(`[PageCache] 淘汰缓存: ${firstKey}`);
      }
      return;
    }
    
    // LRU淘汰：删除最少使用的缓存
    let minAccess = Infinity;
    let evictKey = '';
    
    for (const [key, item] of this.cache) {
      // 综合考虑访问次数和最后访问时间
      const score = item.accessCount + (Date.now() - item.lastAccessTime) / 10000;
      if (score < minAccess) {
        minAccess = score;
        evictKey = key;
      }
    }
    
    if (evictKey) {
      this.cache.delete(evictKey);
      console.debug(`[PageCache] LRU淘汰缓存: ${evictKey}`);
    }
  }
  
  /**
   * 估算数据大小（KB）
   */
  private estimateSize(data: unknown): number {
    try {
      const json = JSON.stringify(data);
      return Math.ceil(json.length / 1024);
    } catch {
      return 1; // 默认1KB
    }
  }
  
  /**
   * 更新统计信息
   */
  private updateStats(): void {
    this.stats.totalCaches = this.cache.size;
    
    let totalMemory = 0;
    let totalAccess = 0;
    
    for (const item of this.cache.values()) {
      totalMemory += item.size;
      totalAccess += item.accessCount;
    }
    
    this.stats.totalMemory = totalMemory / 1024; // 转换为MB
    this.stats.avgAccessCount = this.cache.size > 0 ? totalAccess / this.cache.size : 0;
  }
  
  /**
   * 更新命中率
   */
  private updateHitRate(): void {
    const total = this.stats.hitCount + this.stats.missCount;
    this.stats.hitRate = total > 0 ? this.stats.hitCount / total : 0;
  }
}

// 导出单例
export const pageCache = PageCache.getInstance();
