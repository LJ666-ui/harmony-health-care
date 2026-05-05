/**
 * 对象追踪器
 * 追踪大对象的创建和释放，检测潜在内存泄漏
 * 
 * @author AI Assistant
 * @date 2026-04-27
 */

/**
 * 对象追踪信息
 */
interface ObjectTrackInfo {
  id: string;                     // 对象ID
  type: string;                   // 对象类型
  createTime: number;             // 创建时间
  stackTrace?: string;            // 创建堆栈
  size?: number;                  // 估算大小
  released: boolean;              // 是否已释放
  releaseTime?: number;           // 释放时间
  accessCount: number;            // 访问次数
  lastAccessTime: number;         // 最后访问时间
}

/**
 * 内存泄漏报告
 */
export interface MemoryLeakReport {
  objectId: string;               // 对象ID
  objectType: string;             // 对象类型
  aliveTime: number;              // 存活时间（毫秒）
  createTime: number;             // 创建时间
  stackTrace?: string;            // 创建堆栈
  size?: number;                  // 估算大小
  accessCount: number;            // 访问次数
  severity: 'low' | 'medium' | 'high';  // 严重程度
}

/**
 * 对象追踪配置
 */
export interface ObjectTrackerConfig {
  enabled: boolean;               // 是否启用追踪
  trackStackTrace: boolean;       // 是否追踪堆栈
  maxTrackCount: number;          // 最大追踪数量
  leakThreshold: number;          // 泄漏阈值（毫秒）
  warningThreshold: number;       // 警告阈值（毫秒）
  checkInterval: number;          // 检查间隔（毫秒）
}

/**
 * 追踪统计
 */
export interface TrackerStats {
  totalTracked: number;           // 总追踪数
  activeObjects: number;          // 活跃对象数
  releasedObjects: number;        // 已释放对象数
  potentialLeaks: number;         // 潜在泄漏数
  avgLifetime: number;            // 平均生命周期（毫秒）
}

/**
 * 对象追踪器
 */
export class ObjectTracker {
  private static instance: ObjectTracker | null = null;
  
  // 配置
  private config: ObjectTrackerConfig = {
    enabled: true,
    trackStackTrace: false,
    maxTrackCount: 1000,
    leakThreshold: 300000,        // 5分钟
    warningThreshold: 60000,      // 1分钟
    checkInterval: 60000          // 1分钟
  };
  
  // 对象追踪映射（使用WeakMap避免影响GC）
  private trackedObjects: Map<string, ObjectTrackInfo> = new Map();
  
  // 对象ID计数器
  private idCounter: number = 0;
  
  // 统计信息
  private stats: TrackerStats = {
    totalTracked: 0,
    activeObjects: 0,
    releasedObjects: 0,
    potentialLeaks: 0,
    avgLifetime: 0
  };
  
  // 生命周期历史（用于计算平均值）
  private lifetimeHistory: number[] = [];
  
  // 检查定时器
  private checkTimer: number | null = null;
  
  // 泄漏检测回调
  private leakCallbacks: Set<(report: MemoryLeakReport) => void> = new Set();
  
  // 私有构造函数
  private constructor() {
    this.startLeakCheck();
    console.info('[ObjectTracker] 初始化对象追踪器');
  }
  
  /**
   * 获取单例实例
   */
  public static getInstance(): ObjectTracker {
    if (!ObjectTracker.instance) {
      ObjectTracker.instance = new ObjectTracker();
    }
    return ObjectTracker.instance;
  }
  
  /**
   * 追踪对象
   * @param obj 对象
   * @param type 对象类型
   * @param size 估算大小（可选）
   */
  public track<T extends object>(obj: T, type: string, size?: number): string {
    if (!this.config.enabled) {
      return '';
    }
    
    // 检查追踪数量限制
    if (this.trackedObjects.size >= this.config.maxTrackCount) {
      this.cleanup();
    }
    
    // 生成对象ID
    const id = `obj_${++this.idCounter}`;
    
    // 获取堆栈信息
    let stackTrace: string | undefined;
    if (this.config.trackStackTrace) {
      stackTrace = new Error().stack;
    }
    
    // 创建追踪信息
    const info: ObjectTrackInfo = {
      id,
      type,
      createTime: Date.now(),
      stackTrace,
      size,
      released: false,
      accessCount: 0,
      lastAccessTime: Date.now()
    };
    
    // 添加到追踪映射
    this.trackedObjects.set(id, info);
    
    // 更新统计
    this.stats.totalTracked++;
    this.stats.activeObjects++;
    
    console.debug(`[ObjectTracker] 追踪对象: ${type} (${id})`);
    
    return id;
  }
  
  /**
   * 访问对象
   * @param id 对象ID
   */
  public access(id: string): void {
    const info = this.trackedObjects.get(id);
    if (info && !info.released) {
      info.accessCount++;
      info.lastAccessTime = Date.now();
    }
  }
  
  /**
   * 释放对象
   * @param id 对象ID
   */
  public release(id: string): void {
    const info = this.trackedObjects.get(id);
    if (!info || info.released) {
      return;
    }
    
    info.released = true;
    info.releaseTime = Date.now();
    
    // 计算生命周期
    const lifetime = info.releaseTime - info.createTime;
    this.lifetimeHistory.push(lifetime);
    
    // 保留最近1000条历史
    if (this.lifetimeHistory.length > 1000) {
      this.lifetimeHistory.shift();
    }
    
    // 更新统计
    this.stats.activeObjects--;
    this.stats.releasedObjects++;
    this.updateAvgLifetime();
    
    console.debug(`[ObjectTracker] 释放对象: ${info.type} (${id}), 生命周期: ${lifetime}ms`);
  }
  
  /**
   * 检测内存泄漏
   */
  public detectLeaks(): MemoryLeakReport[] {
    const now = Date.now();
    const leaks: MemoryLeakReport[] = [];
    
    for (const info of this.trackedObjects.values()) {
      if (info.released) {
        continue;
      }
      
      const aliveTime = now - info.createTime;
      
      // 检查是否超过泄漏阈值
      if (aliveTime > this.config.leakThreshold) {
        const severity = this.determineSeverity(aliveTime, info.accessCount);
        
        leaks.push({
          objectId: info.id,
          objectType: info.type,
          aliveTime,
          createTime: info.createTime,
          stackTrace: info.stackTrace,
          size: info.size,
          accessCount: info.accessCount,
          severity
        });
      }
    }
    
    // 按严重程度和存活时间排序
    leaks.sort((a, b) => {
      const severityOrder = { high: 3, medium: 2, low: 1 };
      const severityDiff = severityOrder[b.severity] - severityOrder[a.severity];
      return severityDiff !== 0 ? severityDiff : b.aliveTime - a.aliveTime;
    });
    
    this.stats.potentialLeaks = leaks.length;
    
    if (leaks.length > 0) {
      console.warn(`[ObjectTracker] 检测到 ${leaks.length} 个潜在内存泄漏`);
    }
    
    return leaks;
  }
  
  /**
   * 注册泄漏检测回调
   */
  public onLeakDetected(callback: (report: MemoryLeakReport) => void): void {
    this.leakCallbacks.add(callback);
  }
  
  /**
   * 注销泄漏检测回调
   */
  public offLeakDetected(callback: (report: MemoryLeakReport) => void): void {
    this.leakCallbacks.delete(callback);
  }
  
  /**
   * 获取追踪统计
   */
  public getStats(): TrackerStats {
    return { ...this.stats };
  }
  
  /**
   * 获取活跃对象列表
   */
  public getActiveObjects(): ObjectTrackInfo[] {
    return Array.from(this.trackedObjects.values())
      .filter(info => !info.released)
      .map(info => ({ ...info }));
  }
  
  /**
   * 清理已释放的对象
   */
  public cleanup(): void {
    const now = Date.now();
    const toDelete: string[] = [];
    
    for (const [id, info] of this.trackedObjects) {
      // 删除已释放超过1小时的对象
      if (info.released && info.releaseTime && now - info.releaseTime > 3600000) {
        toDelete.push(id);
      }
    }
    
    for (const id of toDelete) {
      this.trackedObjects.delete(id);
    }
    
    if (toDelete.length > 0) {
      console.debug(`[ObjectTracker] 清理 ${toDelete.length} 个已释放对象`);
    }
  }
  
  /**
   * 清空所有追踪
   */
  public clear(): void {
    this.trackedObjects.clear();
    this.stats.activeObjects = 0;
    console.info('[ObjectTracker] 清空所有追踪');
  }
  
  /**
   * 更新配置
   */
  public updateConfig(config: Partial<ObjectTrackerConfig>): void {
    this.config = { ...this.config, ...config };
    console.info('[ObjectTracker] 更新配置:', JSON.stringify(this.config));
  }
  
  /**
   * 获取当前配置
   */
  public getConfig(): ObjectTrackerConfig {
    return { ...this.config };
  }
  
  /**
   * 停止泄漏检查
   */
  public stopLeakCheck(): void {
    if (this.checkTimer) {
      clearInterval(this.checkTimer);
      this.checkTimer = null;
    }
  }
  
  // ==================== 私有方法 ====================
  
  /**
   * 启动泄漏检查
   */
  private startLeakCheck(): void {
    this.checkTimer = setInterval(() => {
      const leaks = this.detectLeaks();
      
      // 触发泄漏回调
      for (const leak of leaks) {
        this.leakCallbacks.forEach(callback => callback(leak));
      }
    }, this.config.checkInterval) as unknown as number;
  }
  
  /**
   * 确定严重程度
   */
  private determineSeverity(aliveTime: number, accessCount: number): 'low' | 'medium' | 'high' {
    // 存活时间长且访问次数少，严重程度高
    if (aliveTime > this.config.leakThreshold * 2 && accessCount < 5) {
      return 'high';
    }
    
    if (aliveTime > this.config.leakThreshold * 1.5 && accessCount < 10) {
      return 'medium';
    }
    
    return 'low';
  }
  
  /**
   * 更新平均生命周期
   */
  private updateAvgLifetime(): void {
    if (this.lifetimeHistory.length === 0) {
      this.stats.avgLifetime = 0;
      return;
    }
    
    const total = this.lifetimeHistory.reduce((sum, lifetime) => sum + lifetime, 0);
    this.stats.avgLifetime = total / this.lifetimeHistory.length;
  }
}

// 导出单例
export const objectTracker = ObjectTracker.getInstance();
