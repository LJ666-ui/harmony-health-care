/**
 * 渲染性能优化器
 * 管理组件复用、状态更新和页面缓存，提升渲染性能
 * 
 * @author AI Assistant
 * @date 2026-04-27
 */

import { performanceMonitor, MetricType } from './PerformanceMonitor';

/**
 * 渲染优化配置
 */
export interface RenderOptimizerConfig {
  enableComponentPool: boolean;      // 是否启用组件复用池
  enableStateBatch: boolean;         // 是否启用状态批量更新
  enablePageCache: boolean;          // 是否启用页面缓存
  maxPoolSize: number;               // 组件池最大大小
  maxCacheSize: number;              // 页面缓存最大数量
  batchDelay: number;                // 批量更新延迟（毫秒）
}

/**
 * 组件池项
 */
interface PoolItem {
  type: string;
  instance: object;
  inUse: boolean;
  createTime: number;
}

/**
 * 状态更新项
 */
interface StateUpdate {
  target: object;
  key: string;
  value: unknown;
  timestamp: number;
}

/**
 * 页面缓存项
 */
interface CacheItem {
  pageName: string;
  data: unknown;
  timestamp: number;
  accessCount: number;
}

/**
 * 渲染性能优化器
 */
export class RenderOptimizer {
  private static instance: RenderOptimizer | null = null;
  
  // 配置
  private config: RenderOptimizerConfig = {
    enableComponentPool: true,
    enableStateBatch: true,
    enablePageCache: true,
    maxPoolSize: 50,
    maxCacheSize: 10,
    batchDelay: 16 // 一帧的时间
  };
  
  // 组件复用池
  private componentPool: Map<string, PoolItem[]> = new Map();
  
  // 状态更新队列
  private stateUpdateQueue: StateUpdate[] = [];
  private batchUpdateTimer: number | null = null;
  
  // 页面缓存
  private pageCache: Map<string, CacheItem> = new Map();
  
  // 渲染统计
  private renderStats = {
    poolHits: 0,
    poolMisses: 0,
    cacheHits: 0,
    cacheMisses: 0,
    batchUpdates: 0
  };
  
  // 私有构造函数
  private constructor() {
    console.info('[RenderOptimizer] 初始化渲染优化器');
  }
  
  /**
   * 获取单例实例
   */
  public static getInstance(): RenderOptimizer {
    if (!RenderOptimizer.instance) {
      RenderOptimizer.instance = new RenderOptimizer();
    }
    return RenderOptimizer.instance;
  }
  
  // ==================== 组件复用池 ====================
  
  /**
   * 从组件池获取组件
   * @param type 组件类型
   */
  public acquireComponent<T>(type: string): T | null {
    if (!this.config.enableComponentPool) {
      return null;
    }
    
    const pool = this.componentPool.get(type);
    if (!pool) {
      this.renderStats.poolMisses++;
      return null;
    }
    
    // 查找可用组件
    const available = pool.find(item => !item.inUse);
    if (available) {
      available.inUse = true;
      this.renderStats.poolHits++;
      console.debug(`[RenderOptimizer] 从池获取组件: ${type}`);
      return available.instance as T;
    }
    
    this.renderStats.poolMisses++;
    return null;
  }
  
  /**
   * 归还组件到池
   * @param type 组件类型
   * @param instance 组件实例
   */
  public releaseComponent(type: string, instance: object): void {
    if (!this.config.enableComponentPool) {
      return;
    }
    
    let pool = this.componentPool.get(type);
    if (!pool) {
      pool = [];
      this.componentPool.set(type, pool);
    }
    
    // 查找是否已在池中
    const existing = pool.find(item => item.instance === instance);
    if (existing) {
      existing.inUse = false;
      console.debug(`[RenderOptimizer] 归还组件到池: ${type}`);
      return;
    }
    
    // 检查池大小限制
    if (pool.length >= this.config.maxPoolSize) {
      // 移除最旧的未使用组件
      const oldest = pool.findIndex(item => !item.inUse);
      if (oldest !== -1) {
        pool.splice(oldest, 1);
      } else {
        console.warn(`[RenderOptimizer] 组件池已满: ${type}`);
        return;
      }
    }
    
    // 添加到池
    pool.push({
      type,
      instance,
      inUse: false,
      createTime: Date.now()
    });
    
    console.debug(`[RenderOptimizer] 添加组件到池: ${type}`);
  }
  
  /**
   * 清空组件池
   * @param type 组件类型（可选）
   */
  public clearComponentPool(type?: string): void {
    if (type) {
      this.componentPool.delete(type);
      console.info(`[RenderOptimizer] 清空组件池: ${type}`);
    } else {
      this.componentPool.clear();
      console.info('[RenderOptimizer] 清空所有组件池');
    }
  }
  
  // ==================== 状态批量更新 ====================
  
  /**
   * 添加状态更新到队列
   * @param target 目标对象
   * @param key 属性键
   * @param value 新值
   */
  public enqueueStateUpdate(target: object, key: string, value: unknown): void {
    if (!this.config.enableStateBatch) {
      // 直接更新
      (target as Record<string, unknown>)[key] = value;
      return;
    }
    
    // 添加到队列
    this.stateUpdateQueue.push({
      target,
      key,
      value,
      timestamp: Date.now()
    });
    
    // 启动批量更新定时器
    if (!this.batchUpdateTimer) {
      this.scheduleBatchUpdate();
    }
  }
  
  /**
   * 调度批量更新
   */
  private scheduleBatchUpdate(): void {
    // 使用requestAnimationFrame或setTimeout
    this.batchUpdateTimer = setTimeout(() => {
      this.processBatchUpdate();
    }, this.config.batchDelay) as unknown as number;
  }
  
  /**
   * 处理批量更新
   */
  private processBatchUpdate(): void {
    if (this.stateUpdateQueue.length === 0) {
      this.batchUpdateTimer = null;
      return;
    }
    
    const startTime = Date.now();
    
    // 去重：相同target+key的更新只保留最新的
    const updateMap = new Map<string, StateUpdate>();
    for (const update of this.stateUpdateQueue) {
      const key = `${update.target.constructor.name}_${update.key}`;
      updateMap.set(key, update);
    }
    
    // 执行更新
    for (const update of updateMap.values()) {
      (update.target as Record<string, unknown>)[update.key] = update.value;
    }
    
    const duration = Date.now() - startTime;
    const count = updateMap.size;
    
    this.renderStats.batchUpdates++;
    this.stateUpdateQueue = [];
    this.batchUpdateTimer = null;
    
    console.debug(`[RenderOptimizer] 批量更新 ${count} 个状态, 耗时: ${duration}ms`);
    
    // 记录渲染时间
    performanceMonitor.recordMetric(
      MetricType.RENDER_TIME,
      'batch_state_update',
      duration,
      undefined,
      new Map([['count', count]])
    );
  }
  
  // ==================== 页面缓存 ====================
  
  /**
   * 缓存页面数据
   * @param pageName 页面名称
   * @param data 页面数据
   */
  public cachePage(pageName: string, data: unknown): void {
    if (!this.config.enablePageCache) {
      return;
    }
    
    // 检查缓存大小限制
    if (this.pageCache.size >= this.config.maxCacheSize) {
      // 移除最少使用的页面
      this.evictLeastUsed();
    }
    
    this.pageCache.set(pageName, {
      pageName,
      data,
      timestamp: Date.now(),
      accessCount: 0
    });
    
    console.debug(`[RenderOptimizer] 缓存页面: ${pageName}`);
  }
  
  /**
   * 获取缓存的页面数据
   * @param pageName 页面名称
   */
  public getCachedPage<T>(pageName: string): T | null {
    if (!this.config.enablePageCache) {
      return null;
    }
    
    const cached = this.pageCache.get(pageName);
    if (cached) {
      cached.accessCount++;
      this.renderStats.cacheHits++;
      console.debug(`[RenderOptimizer] 页面缓存命中: ${pageName}`);
      return cached.data as T;
    }
    
    this.renderStats.cacheMisses++;
    return null;
  }
  
  /**
   * 移除最少使用的页面缓存
   */
  private evictLeastUsed(): void {
    let minAccess = Infinity;
    let evictKey = '';
    
    for (const [key, item] of this.pageCache) {
      if (item.accessCount < minAccess) {
        minAccess = item.accessCount;
        evictKey = key;
      }
    }
    
    if (evictKey) {
      this.pageCache.delete(evictKey);
      console.debug(`[RenderOptimizer] 移除页面缓存: ${evictKey}`);
    }
  }
  
  /**
   * 清空页面缓存
   * @param pageName 页面名称（可选）
   */
  public clearPageCache(pageName?: string): void {
    if (pageName) {
      this.pageCache.delete(pageName);
      console.info(`[RenderOptimizer] 清空页面缓存: ${pageName}`);
    } else {
      this.pageCache.clear();
      console.info('[RenderOptimizer] 清空所有页面缓存');
    }
  }
  
  // ==================== 统计和配置 ====================
  
  /**
   * 获取渲染统计
   */
  public getRenderStats(): typeof this.renderStats {
    return { ...this.renderStats };
  }
  
  /**
   * 获取组件池统计
   */
  public getPoolStats(): Map<string, { total: number; inUse: number; available: number }> {
    const stats = new Map<string, { total: number; inUse: number; available: number }>();
    
    for (const [type, pool] of this.componentPool) {
      const total = pool.length;
      const inUse = pool.filter(item => item.inUse).length;
      stats.set(type, { total, inUse, available: total - inUse });
    }
    
    return stats;
  }
  
  /**
   * 获取页面缓存统计
   */
  public getCacheStats(): { total: number; items: Array<{ name: string; accessCount: number }> } {
    const items = Array.from(this.pageCache.values()).map(item => ({
      name: item.pageName,
      accessCount: item.accessCount
    }));
    
    return {
      total: this.pageCache.size,
      items
    };
  }
  
  /**
   * 更新配置
   */
  public updateConfig(config: Partial<RenderOptimizerConfig>): void {
    this.config = { ...this.config, ...config };
    console.info('[RenderOptimizer] 更新配置:', JSON.stringify(this.config));
  }
  
  /**
   * 获取当前配置
   */
  public getConfig(): RenderOptimizerConfig {
    return { ...this.config };
  }
  
  /**
   * 重置统计
   */
  public resetStats(): void {
    this.renderStats = {
      poolHits: 0,
      poolMisses: 0,
      cacheHits: 0,
      cacheMisses: 0,
      batchUpdates: 0
    };
    console.info('[RenderOptimizer] 重置统计');
  }
}

// 导出单例
export const renderOptimizer = RenderOptimizer.getInstance();
