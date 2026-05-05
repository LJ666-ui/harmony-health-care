/**
 * 组件复用池
 * 实现组件实例的复用，减少组件创建开销
 * 
 * @author AI Assistant
 * @date 2026-04-27
 */

/**
 * 池配置
 */
export interface PoolConfig {
  maxSize: number;              // 最大池大小
  enableStats: boolean;         // 是否启用统计
  cleanupInterval: number;      // 清理间隔（毫秒）
  maxIdleTime: number;          // 最大空闲时间（毫秒）
}

/**
 * 池项信息
 */
interface PoolItemInfo {
  instance: object;
  inUse: boolean;
  createTime: number;
  lastUseTime: number;
  useCount: number;
}

/**
 * 池统计信息
 */
export interface PoolStats {
  type: string;
  total: number;
  inUse: number;
  available: number;
  hitRate: number;
  avgUseCount: number;
}

/**
 * 组件复用池
 */
export class ComponentPool {
  private static instance: ComponentPool | null = null;
  
  // 默认配置
  private config: PoolConfig = {
    maxSize: 50,
    enableStats: true,
    cleanupInterval: 60000,    // 1分钟
    maxIdleTime: 300000        // 5分钟
  };
  
  // 组件池映射
  private pools: Map<string, PoolItemInfo[]> = new Map();
  
  // 统计信息
  private stats = {
    totalAcquire: 0,
    poolHits: 0,
    poolMisses: 0,
    totalRelease: 0
  };
  
  // 清理定时器
  private cleanupTimer: number | null = null;
  
  // 私有构造函数
  private constructor() {
    this.startCleanupTimer();
    console.info('[ComponentPool] 初始化组件复用池');
  }
  
  /**
   * 获取单例实例
   */
  public static getInstance(): ComponentPool {
    if (!ComponentPool.instance) {
      ComponentPool.instance = new ComponentPool();
    }
    return ComponentPool.instance;
  }
  
  /**
   * 从池获取组件
   * @param type 组件类型
   * @param factory 创建工厂（当池中无可用组件时使用）
   */
  public acquire<T extends object>(type: string, factory?: () => T): T | null {
    this.stats.totalAcquire++;
    
    let pool = this.pools.get(type);
    
    // 如果池不存在，创建新池
    if (!pool) {
      pool = [];
      this.pools.set(type, pool);
    }
    
    // 查找可用组件
    const available = pool.find(item => !item.inUse);
    
    if (available) {
      available.inUse = true;
      available.lastUseTime = Date.now();
      available.useCount++;
      
      this.stats.poolHits++;
      
      console.debug(`[ComponentPool] 从池获取组件: ${type} (命中)`);
      return available.instance as T;
    }
    
    // 池中无可用组件，使用工厂创建
    if (factory) {
      const instance = factory();
      
      // 检查池大小限制
      if (pool.length < this.config.maxSize) {
        pool.push({
          instance,
          inUse: true,
          createTime: Date.now(),
          lastUseTime: Date.now(),
          useCount: 1
        });
        
        console.debug(`[ComponentPool] 创建新组件: ${type}`);
      }
      
      this.stats.poolMisses++;
      return instance;
    }
    
    this.stats.poolMisses++;
    console.warn(`[ComponentPool] 无法获取组件: ${type}`);
    return null;
  }
  
  /**
   * 归还组件到池
   * @param type 组件类型
   * @param instance 组件实例
   */
  public release<T extends object>(type: string, instance: T): void {
    this.stats.totalRelease++;
    
    const pool = this.pools.get(type);
    if (!pool) {
      console.warn(`[ComponentPool] 组件池不存在: ${type}`);
      return;
    }
    
    // 查找组件
    const item = pool.find(p => p.instance === instance);
    if (item) {
      item.inUse = false;
      item.lastUseTime = Date.now();
      console.debug(`[ComponentPool] 归还组件: ${type}`);
    } else {
      console.warn(`[ComponentPool] 组件不在池中: ${type}`);
    }
  }
  
  /**
   * 预热组件池
   * @param type 组件类型
   * @param factory 创建工厂
   * @param count 预热数量
   */
  public warmup<T extends object>(type: string, factory: () => T, count: number): void {
    let pool = this.pools.get(type);
    if (!pool) {
      pool = [];
      this.pools.set(type, pool);
    }
    
    const actualCount = Math.min(count, this.config.maxSize - pool.length);
    
    for (let i = 0; i < actualCount; i++) {
      const instance = factory();
      pool.push({
        instance,
        inUse: false,
        createTime: Date.now(),
        lastUseTime: Date.now(),
        useCount: 0
      });
    }
    
    console.info(`[ComponentPool] 预热组件池: ${type}, 数量: ${actualCount}`);
  }
  
  /**
   * 清空指定类型的组件池
   * @param type 组件类型
   */
  public clear(type: string): void {
    this.pools.delete(type);
    console.info(`[ComponentPool] 清空组件池: ${type}`);
  }
  
  /**
   * 清空所有组件池
   */
  public clearAll(): void {
    this.pools.clear();
    console.info('[ComponentPool] 清空所有组件池');
  }
  
  /**
   * 获取池统计信息
   * @param type 组件类型（可选）
   */
  public getStats(type?: string): PoolStats[] {
    const result: PoolStats[] = [];
    
    const types = type ? [type] : Array.from(this.pools.keys());
    
    for (const t of types) {
      const pool = this.pools.get(t);
      if (!pool) continue;
      
      const total = pool.length;
      const inUse = pool.filter(item => item.inUse).length;
      const available = total - inUse;
      const avgUseCount = total > 0 
        ? pool.reduce((sum, item) => sum + item.useCount, 0) / total 
        : 0;
      
      result.push({
        type: t,
        total,
        inUse,
        available,
        hitRate: this.stats.totalAcquire > 0 
          ? this.stats.poolHits / this.stats.totalAcquire 
          : 0,
        avgUseCount
      });
    }
    
    return result;
  }
  
  /**
   * 获取全局统计
   */
  public getGlobalStats(): typeof this.stats {
    return { ...this.stats };
  }
  
  /**
   * 更新配置
   */
  public updateConfig(config: Partial<PoolConfig>): void {
    this.config = { ...this.config, ...config };
    
    // 重启清理定时器
    if (this.cleanupTimer) {
      clearInterval(this.cleanupTimer);
      this.startCleanupTimer();
    }
    
    console.info('[ComponentPool] 更新配置:', JSON.stringify(this.config));
  }
  
  /**
   * 获取当前配置
   */
  public getConfig(): PoolConfig {
    return { ...this.config };
  }
  
  // ==================== 私有方法 ====================
  
  /**
   * 启动清理定时器
   */
  private startCleanupTimer(): void {
    this.cleanupTimer = setInterval(() => {
      this.cleanup();
    }, this.config.cleanupInterval) as unknown as number;
  }
  
  /**
   * 清理过期组件
   */
  private cleanup(): void {
    const now = Date.now();
    let cleanedCount = 0;
    
    for (const [type, pool] of this.pools) {
      // 过滤掉过期的未使用组件
      const before = pool.length;
      const filtered = pool.filter(item => {
        if (item.inUse) return true;
        return (now - item.lastUseTime) < this.config.maxIdleTime;
      });
      
      if (filtered.length < before) {
        this.pools.set(type, filtered);
        cleanedCount += before - filtered.length;
      }
    }
    
    if (cleanedCount > 0) {
      console.info(`[ComponentPool] 清理 ${cleanedCount} 个过期组件`);
    }
  }
  
  /**
   * 停止清理定时器
   */
  public stopCleanup(): void {
    if (this.cleanupTimer) {
      clearInterval(this.cleanupTimer);
      this.cleanupTimer = null;
    }
  }
}

// 导出单例
export const componentPool = ComponentPool.getInstance();
