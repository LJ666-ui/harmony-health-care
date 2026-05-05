/**
 * 状态批量更新队列
 * 实现状态更新的合并和批量执行，减少重复渲染
 * 
 * @author AI Assistant
 * @date 2026-04-27
 */

import { performanceMonitor, MetricType } from './PerformanceMonitor';

/**
 * 状态更新项
 */
interface StateUpdateItem {
  id: string;                    // 更新ID
  target: object;                // 目标对象
  key: string;                   // 属性键
  value: unknown;                // 新值
  timestamp: number;             // 时间戳
  priority: number;              // 优先级
}

/**
 * 批量更新配置
 */
export interface BatchUpdateConfig {
  enabled: boolean;              // 是否启用批量更新
  maxBatchSize: number;          // 最大批量大小
  batchDelay: number;            // 批量延迟（毫秒）
  enableDeduplication: boolean;  // 是否启用去重
  enablePriority: boolean;       // 是否启用优先级
}

/**
 * 批量更新统计
 */
export interface BatchUpdateStats {
  totalUpdates: number;          // 总更新数
  batchedUpdates: number;        // 批量更新数
  deduplicatedUpdates: number;   // 去重更新数
  avgBatchSize: number;          // 平均批量大小
  avgProcessTime: number;        // 平均处理时间
}

/**
 * 状态批量更新队列
 */
export class StateUpdateQueue {
  private static instance: StateUpdateQueue | null = null;
  
  // 配置
  private config: BatchUpdateConfig = {
    enabled: true,
    maxBatchSize: 100,
    batchDelay: 16,              // 一帧时间
    enableDeduplication: true,
    enablePriority: true
  };
  
  // 更新队列
  private queue: StateUpdateItem[] = [];
  
  // 批量处理定时器
  private batchTimer: number | null = null;
  
  // 是否正在处理
  private isProcessing: boolean = false;
  
  // 统计信息
  private stats: BatchUpdateStats = {
    totalUpdates: 0,
    batchedUpdates: 0,
    deduplicatedUpdates: 0,
    avgBatchSize: 0,
    avgProcessTime: 0
  };
  
  // 处理历史（用于计算平均值）
  private processHistory: Array<{ size: number; time: number }> = [];
  
  // 私有构造函数
  private constructor() {
    console.info('[StateUpdateQueue] 初始化状态批量更新队列');
  }
  
  /**
   * 获取单例实例
   */
  public static getInstance(): StateUpdateQueue {
    if (!StateUpdateQueue.instance) {
      StateUpdateQueue.instance = new StateUpdateQueue();
    }
    return StateUpdateQueue.instance;
  }
  
  /**
   * 添加状态更新到队列
   * @param target 目标对象
   * @param key 属性键
   * @param value 新值
   * @param priority 优先级（可选）
   */
  public enqueue(target: object, key: string, value: unknown, priority: number = 0): void {
    if (!this.config.enabled) {
      // 直接更新
      this.applyUpdate(target, key, value);
      return;
    }
    
    this.stats.totalUpdates++;
    
    // 创建更新项
    const item: StateUpdateItem = {
      id: this.generateId(target, key),
      target,
      key,
      value,
      timestamp: Date.now(),
      priority
    };
    
    // 去重检查
    if (this.config.enableDeduplication) {
      const existing = this.queue.find(q => q.id === item.id);
      if (existing) {
        existing.value = value;
        existing.timestamp = item.timestamp;
        existing.priority = Math.max(existing.priority, priority);
        this.stats.deduplicatedUpdates++;
        console.debug(`[StateUpdateQueue] 去重更新: ${item.id}`);
        return;
      }
    }
    
    // 添加到队列
    this.queue.push(item);
    
    // 优先级排序
    if (this.config.enablePriority) {
      this.queue.sort((a, b) => b.priority - a.priority);
    }
    
    // 检查批量大小限制
    if (this.queue.length >= this.config.maxBatchSize) {
      this.processBatch();
    } else {
      // 调度批量处理
      this.scheduleBatch();
    }
  }
  
  /**
   * 立即执行所有待处理更新
   */
  public flush(): void {
    if (this.queue.length > 0) {
      this.processBatch();
    }
  }
  
  /**
   * 清空队列
   */
  public clear(): void {
    this.queue = [];
    if (this.batchTimer) {
      clearTimeout(this.batchTimer);
      this.batchTimer = null;
    }
  }
  
  /**
   * 获取队列大小
   */
  public size(): number {
    return this.queue.length;
  }
  
  /**
   * 获取统计信息
   */
  public getStats(): BatchUpdateStats {
    return { ...this.stats };
  }
  
  /**
   * 更新配置
   */
  public updateConfig(config: Partial<BatchUpdateConfig>): void {
    this.config = { ...this.config, ...config };
    console.info('[StateUpdateQueue] 更新配置:', JSON.stringify(this.config));
  }
  
  /**
   * 获取当前配置
   */
  public getConfig(): BatchUpdateConfig {
    return { ...this.config };
  }
  
  /**
   * 重置统计
   */
  public resetStats(): void {
    this.stats = {
      totalUpdates: 0,
      batchedUpdates: 0,
      deduplicatedUpdates: 0,
      avgBatchSize: 0,
      avgProcessTime: 0
    };
    this.processHistory = [];
  }
  
  // ==================== 私有方法 ====================
  
  /**
   * 生成更新ID
   */
  private generateId(target: object, key: string): string {
    return `${target.constructor.name}_${key}`;
  }
  
  /**
   * 调度批量处理
   */
  private scheduleBatch(): void {
    if (this.batchTimer) {
      return;
    }
    
    this.batchTimer = setTimeout(() => {
      this.processBatch();
    }, this.config.batchDelay) as unknown as number;
  }
  
  /**
   * 处理批量更新
   */
  private processBatch(): void {
    if (this.isProcessing || this.queue.length === 0) {
      return;
    }
    
    this.isProcessing = true;
    const startTime = Date.now();
    
    // 取出所有待处理更新
    const updates = [...this.queue];
    this.queue = [];
    
    // 清除定时器
    if (this.batchTimer) {
      clearTimeout(this.batchTimer);
      this.batchTimer = null;
    }
    
    // 执行更新
    let successCount = 0;
    for (const update of updates) {
      try {
        this.applyUpdate(update.target, update.key, update.value);
        successCount++;
      } catch (error) {
        console.error(`[StateUpdateQueue] 更新失败: ${update.id}`, error);
      }
    }
    
    const duration = Date.now() - startTime;
    
    // 更新统计
    this.stats.batchedUpdates++;
    this.processHistory.push({ size: updates.length, time: duration });
    
    // 保留最近100次处理历史
    if (this.processHistory.length > 100) {
      this.processHistory.shift();
    }
    
    // 计算平均值
    this.updateAverages();
    
    console.debug(`[StateUpdateQueue] 批量处理 ${successCount}/${updates.length} 个更新, 耗时: ${duration}ms`);
    
    // 记录性能指标
    performanceMonitor.recordMetric(
      MetricType.RENDER_TIME,
      'state_batch_update',
      duration,
      undefined,
      new Map([['count', updates.length]])
    );
    
    this.isProcessing = false;
    
    // 如果队列中还有更新，继续处理
    if (this.queue.length > 0) {
      this.scheduleBatch();
    }
  }
  
  /**
   * 应用单个更新
   */
  private applyUpdate(target: object, key: string, value: unknown): void {
    (target as Record<string, unknown>)[key] = value;
  }
  
  /**
   * 更新平均值统计
   */
  private updateAverages(): void {
    if (this.processHistory.length === 0) {
      return;
    }
    
    const totalSize = this.processHistory.reduce((sum, h) => sum + h.size, 0);
    const totalTime = this.processHistory.reduce((sum, h) => sum + h.time, 0);
    
    this.stats.avgBatchSize = totalSize / this.processHistory.length;
    this.stats.avgProcessTime = totalTime / this.processHistory.length;
  }
}

// 导出单例
export const stateUpdateQueue = StateUpdateQueue.getInstance();
