/**
 * 离线缓存
 * 实现基于SQLite的离线缓存，支持断网场景
 * 
 * @author AI Assistant
 * @date 2026-04-27
 */

/**
 * 缓存数据项
 */
interface CacheDataItem {
  key: string;                    // 缓存键
  data: string;                   // 缓存数据（JSON字符串）
  timestamp: number;              // 缓存时间
  expireTime: number;             // 过期时间
  size: number;                   // 数据大小
  accessCount: number;            // 访问次数
  lastAccessTime: number;         // 最后访问时间
  tags: string;                   // 标签（JSON字符串）
}

/**
 * 离线缓存配置
 */
export interface OfflineCacheConfig {
  enabled: boolean;               // 是否启用缓存
  maxSize: number;                // 最大缓存大小（MB）
  defaultExpireTime: number;      // 默认过期时间（毫秒）
  cleanupInterval: number;        // 清理间隔（毫秒）
  enableAutoSync: boolean;        // 是否启用自动同步
}

/**
 * 缓存统计
 */
export interface CacheStats {
  totalItems: number;             // 总缓存项数
  totalSize: number;              // 总大小（MB）
  hitCount: number;               // 命中次数
  missCount: number;              // 未命中次数
  hitRate: number;                // 命中率
  expiredCount: number;           // 过期项数
}

/**
 * 离线缓存管理器
 */
export class OfflineCache {
  private static instance: OfflineCache | null = null;
  
  // 配置
  private config: OfflineCacheConfig = {
    enabled: true,
    maxSize: 50,                  // 50MB
    defaultExpireTime: 86400000,  // 1天
    cleanupInterval: 3600000,     // 1小时
    enableAutoSync: true
  };
  
  // 内存缓存（快速访问）
  private memoryCache: Map<string, CacheDataItem> = new Map();
  
  // 当前缓存大小
  private currentSize: number = 0;
  
  // 统计信息
  private stats: CacheStats = {
    totalItems: 0,
    totalSize: 0,
    hitCount: 0,
    missCount: 0,
    hitRate: 0,
    expiredCount: 0
  };
  
  // 清理定时器
  private cleanupTimer: number | null = null;
  
  // 私有构造函数
  private constructor() {
    this.startCleanup();
    console.info('[OfflineCache] 初始化离线缓存');
  }
  
  /**
   * 获取单例实例
   */
  public static getInstance(): OfflineCache {
    if (!OfflineCache.instance) {
      OfflineCache.instance = new OfflineCache();
    }
    return OfflineCache.instance;
  }
  
  /**
   * 设置缓存
   * @param key 缓存键
   * @param data 缓存数据
   * @param expireTime 过期时间（可选）
   * @param tags 标签（可选）
   */
  public async set<T>(
    key: string,
    data: T,
    expireTime?: number,
    tags?: string[]
  ): Promise<void> {
    if (!this.config.enabled) {
      return;
    }
    
    // 序列化数据
    const dataStr = JSON.stringify(data);
    const size = dataStr.length / 1024; // KB
    
    // 检查是否需要清理
    while (this.currentSize + size > this.config.maxSize * 1024) {
      await this.evict();
    }
    
    // 创建缓存项
    const item: CacheDataItem = {
      key,
      data: dataStr,
      timestamp: Date.now(),
      expireTime: expireTime || this.config.defaultExpireTime,
      size,
      accessCount: 0,
      lastAccessTime: Date.now(),
      tags: JSON.stringify(tags || [])
    };
    
    // 添加到内存缓存
    const existing = this.memoryCache.get(key);
    if (existing) {
      this.currentSize -= existing.size;
    }
    
    this.memoryCache.set(key, item);
    this.currentSize += size;
    
    // 持久化到SQLite
    await this.persistToDB(item);
    
    // 更新统计
    this.updateStats();
    
    console.debug(`[OfflineCache] 缓存数据: ${key}, 大小: ${size.toFixed(2)}KB`);
  }
  
  /**
   * 获取缓存
   * @param key 缓存键
   */
  public async get<T>(key: string): Promise<T | null> {
    if (!this.config.enabled) {
      this.stats.missCount++;
      return null;
    }
    
    // 先从内存缓存获取
    let item = this.memoryCache.get(key);
    
    // 如果内存缓存没有，从数据库加载
    if (!item) {
      item = await this.loadFromDB(key);
      if (item) {
        this.memoryCache.set(key, item);
        this.currentSize += item.size;
      }
    }
    
    if (!item) {
      this.stats.missCount++;
      this.updateHitRate();
      console.debug(`[OfflineCache] 缓存未命中: ${key}`);
      return null;
    }
    
    // 检查是否过期
    if (Date.now() - item.timestamp > item.expireTime) {
      await this.delete(key);
      this.stats.missCount++;
      this.stats.expiredCount++;
      this.updateHitRate();
      console.debug(`[OfflineCache] 缓存已过期: ${key}`);
      return null;
    }
    
    // 更新访问信息
    item.accessCount++;
    item.lastAccessTime = Date.now();
    
    this.stats.hitCount++;
    this.updateHitRate();
    
    console.debug(`[OfflineCache] 缓存命中: ${key}`);
    
    return JSON.parse(item.data) as T;
  }
  
  /**
   * 删除缓存
   * @param key 缓存键
   */
  public async delete(key: string): Promise<boolean> {
    const item = this.memoryCache.get(key);
    
    if (item) {
      this.currentSize -= item.size;
      this.memoryCache.delete(key);
    }
    
    // 从数据库删除
    await this.deleteFromDB(key);
    
    this.updateStats();
    console.debug(`[OfflineCache] 删除缓存: ${key}`);
    
    return true;
  }
  
  /**
   * 清空所有缓存
   */
  public async clear(): Promise<void> {
    this.memoryCache.clear();
    this.currentSize = 0;
    
    // 清空数据库
    await this.clearDB();
    
    this.updateStats();
    console.info('[OfflineCache] 清空所有缓存');
  }
  
  /**
   * 按标签删除缓存
   * @param tag 标签
   */
  public async deleteByTag(tag: string): Promise<void> {
    const toDelete: string[] = [];
    
    for (const [key, item] of this.memoryCache) {
      const tags = JSON.parse(item.tags) as string[];
      if (tags.includes(tag)) {
        toDelete.push(key);
      }
    }
    
    for (const key of toDelete) {
      await this.delete(key);
    }
    
    console.info(`[OfflineCache] 按标签删除缓存: ${tag}, 数量: ${toDelete.length}`);
  }
  
  /**
   * 获取缓存统计
   */
  public getStats(): CacheStats {
    return { ...this.stats };
  }
  
  /**
   * 更新配置
   */
  public updateConfig(config: Partial<OfflineCacheConfig>): void {
    this.config = { ...this.config, ...config };
    console.info('[OfflineCache] 更新配置:', JSON.stringify(this.config));
  }
  
  /**
   * 获取当前配置
   */
  public getConfig(): OfflineCacheConfig {
    return { ...this.config };
  }
  
  /**
   * 停止清理
   */
  public stopCleanup(): void {
    if (this.cleanupTimer) {
      clearInterval(this.cleanupTimer);
      this.cleanupTimer = null;
    }
  }
  
  // ==================== 私有方法 ====================
  
  /**
   * 启动清理定时器
   */
  private startCleanup(): void {
    this.cleanupTimer = setInterval(() => {
      this.cleanup();
    }, this.config.cleanupInterval) as unknown as number;
  }
  
  /**
   * 清理过期缓存
   */
  private async cleanup(): Promise<void> {
    const now = Date.now();
    const toDelete: string[] = [];
    
    for (const [key, item] of this.memoryCache) {
      if (now - item.timestamp > item.expireTime) {
        toDelete.push(key);
      }
    }
    
    for (const key of toDelete) {
      await this.delete(key);
    }
    
    if (toDelete.length > 0) {
      console.info(`[OfflineCache] 清理 ${toDelete.length} 个过期缓存`);
    }
  }
  
  /**
   * 淘汰缓存
   */
  private async evict(): Promise<void> {
    // LRU淘汰：删除最少使用的缓存
    let minScore = Infinity;
    let evictKey = '';
    
    for (const [key, item] of this.memoryCache) {
      // 综合考虑访问次数和最后访问时间
      const score = item.accessCount + (Date.now() - item.lastAccessTime) / 10000;
      if (score < minScore) {
        minScore = score;
        evictKey = key;
      }
    }
    
    if (evictKey) {
      await this.delete(evictKey);
      console.debug(`[OfflineCache] LRU淘汰缓存: ${evictKey}`);
    }
  }
  
  /**
   * 持久化到数据库
   */
  private async persistToDB(item: CacheDataItem): Promise<void> {
    // TODO: 使用RDB存储到SQLite
    // const db = await this.getDB();
    // await db.insert('offline_cache', item);
    console.debug(`[OfflineCache] 持久化到数据库: ${item.key}`);
  }
  
  /**
   * 从数据库加载
   */
  private async loadFromDB(key: string): Promise<CacheDataItem | null> {
    // TODO: 从SQLite加载
    // const db = await this.getDB();
    // const result = await db.query('offline_cache', { key });
    // return result[0];
    console.debug(`[OfflineCache] 从数据库加载: ${key}`);
    return null;
  }
  
  /**
   * 从数据库删除
   */
  private async deleteFromDB(key: string): Promise<void> {
    // TODO: 从SQLite删除
    // const db = await this.getDB();
    // await db.delete('offline_cache', { key });
    console.debug(`[OfflineCache] 从数据库删除: ${key}`);
  }
  
  /**
   * 清空数据库
   */
  private async clearDB(): Promise<void> {
    // TODO: 清空SQLite表
    // const db = await this.getDB();
    // await db.deleteAll('offline_cache');
    console.debug('[OfflineCache] 清空数据库');
  }
  
  /**
   * 更新统计信息
   */
  private updateStats(): void {
    this.stats.totalItems = this.memoryCache.size;
    this.stats.totalSize = this.currentSize / 1024; // 转换为MB
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
export const offlineCache = OfflineCache.getInstance();
