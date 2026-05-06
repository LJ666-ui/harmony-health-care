/**
 * 请求批处理器
 * 实现请求队列管理和批量发送，减少网络开销
 * 
 * @author AI Assistant
 * @date 2026-04-27
 */

import { performanceMonitor, MetricType } from './PerformanceMonitor';

/**
 * 批处理请求项
 */
interface BatchRequestItem {
  id: string;
  url: string;
  method: string;
  data?: unknown;
  resolve: (value: unknown) => void;
  reject: (error: Error) => void;
  timestamp: number;
  priority: number;
}

/**
 * 批处理配置
 */
export interface RequestBatchConfig {
  enabled: boolean;               // 是否启用批处理
  maxBatchSize: number;           // 最大批量大小
  batchWindow: number;            // 批处理窗口时间（毫秒）
  maxQueueSize: number;           // 最大队列大小
  enablePriority: boolean;        // 是否启用优先级
}

/**
 * 批处理统计
 */
export interface BatchStats {
  totalRequests: number;          // 总请求数
  batchedRequests: number;        // 批处理请求数
  batchCount: number;             // 批处理次数
  avgBatchSize: number;           // 平均批量大小
  avgWaitTime: number;            // 平均等待时间
}

/**
 * 请求批处理器
 */
export class RequestBatch {
  private static instance: RequestBatch | null = null;
  
  // 配置
  private config: RequestBatchConfig = {
    enabled: true,
    maxBatchSize: 10,
    batchWindow: 50,              // 50ms窗口
    maxQueueSize: 100,
    enablePriority: true
  };
  
  // 请求队列
  private queue: BatchRequestItem[] = [];
  
  // 批处理定时器
  private batchTimer: number | null = null;
  
  // 是否正在处理
  private isProcessing: boolean = false;
  
  // 统计信息
  private stats: BatchStats = {
    totalRequests: 0,
    batchedRequests: 0,
    batchCount: 0,
    avgBatchSize: 0,
    avgWaitTime: 0
  };
  
  // 批处理历史
  private batchHistory: Array<{ size: number; waitTime: number }> = [];
  
  // 私有构造函数
  private constructor() {
    console.info('[RequestBatch] 初始化请求批处理器');
  }
  
  /**
   * 获取单例实例
   */
  public static getInstance(): RequestBatch {
    if (!RequestBatch.instance) {
      RequestBatch.instance = new RequestBatch();
    }
    return RequestBatch.instance;
  }
  
  /**
   * 添加请求到批处理队列
   * @param url 请求URL
   * @param method 请求方法
   * @param data 请求数据
   * @param priority 优先级
   */
  public add<T>(
    url: string,
    method: string = 'GET',
    data?: unknown,
    priority: number = 0
  ): Promise<T> {
    if (!this.config.enabled) {
      // 直接发送请求
      return this.sendRequest<T>(url, method, data);
    }
    
    this.stats.totalRequests++;
    
    // 检查队列大小
    if (this.queue.length >= this.config.maxQueueSize) {
      console.warn('[RequestBatch] 队列已满，立即发送');
      this.flush();
    }
    
    return new Promise<T>((resolve, reject) => {
      const item: BatchRequestItem = {
        id: this.generateId(),
        url,
        method,
        data,
        resolve: resolve as (value: unknown) => void,
        reject,
        timestamp: Date.now(),
        priority
      };
      
      // 添加到队列
      this.queue.push(item);
      
      // 优先级排序
      if (this.config.enablePriority) {
        this.queue.sort((a, b) => b.priority - a.priority);
      }
      
      // 检查是否达到批量大小
      if (this.queue.length >= this.config.maxBatchSize) {
        this.flush();
      } else {
        // 调度批处理
        this.scheduleBatch();
      }
    });
  }
  
  /**
   * 立即发送所有待处理请求
   */
  public async flush(): Promise<void> {
    if (this.queue.length === 0 || this.isProcessing) {
      return;
    }
    
    // 清除定时器
    if (this.batchTimer) {
      clearTimeout(this.batchTimer);
      this.batchTimer = null;
    }
    
    await this.processBatch();
  }
  
  /**
   * 清空队列
   */
  public clear(): void {
    // 拒绝所有待处理请求
    for (const item of this.queue) {
      item.reject(new Error('队列已清空'));
    }
    
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
  public getStats(): BatchStats {
    return { ...this.stats };
  }
  
  /**
   * 更新配置
   */
  public updateConfig(config: Partial<RequestBatchConfig>): void {
    this.config = { ...this.config, ...config };
    console.info('[RequestBatch] 更新配置:', JSON.stringify(this.config));
  }
  
  /**
   * 获取当前配置
   */
  public getConfig(): RequestBatchConfig {
    return { ...this.config };
  }
  
  // ==================== 私有方法 ====================
  
  /**
   * 生成请求ID
   */
  private generateId(): string {
    return `req_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }
  
  /**
   * 调度批处理
   */
  private scheduleBatch(): void {
    if (this.batchTimer) {
      return;
    }
    
    this.batchTimer = setTimeout(() => {
      this.processBatch();
    }, this.config.batchWindow) as unknown as number;
  }
  
  /**
   * 处理批量请求
   */
  private async processBatch(): Promise<void> {
    if (this.isProcessing || this.queue.length === 0) {
      return;
    }
    
    this.isProcessing = true;
    
    // 取出所有待处理请求
    const items = [...this.queue];
    this.queue = [];
    
    const startTime = Date.now();
    
    console.info(`[RequestBatch] 开始批处理 ${items.length} 个请求`);
    
    try {
      // 按URL分组（相同URL的请求可以合并）
      const groups = this.groupRequests(items);
      
      // 并行发送所有组
      const promises = Array.from(groups.values()).map(group => 
        this.sendBatchRequest(group)
      );
      
      await Promise.all(promises);
      
      const duration = Date.now() - startTime;
      
      // 更新统计
      this.stats.batchCount++;
      this.stats.batchedRequests += items.length;
      
      // 计算平均等待时间
      const avgWait = items.reduce((sum, item) => 
        sum + (startTime - item.timestamp), 0) / items.length;
      
      this.batchHistory.push({ size: items.length, waitTime: avgWait });
      
      // 保留最近100次历史
      if (this.batchHistory.length > 100) {
        this.batchHistory.shift();
      }
      
      this.updateStats();
      
      console.info(`[RequestBatch] 批处理完成, 耗时: ${duration}ms`);
      
      // 记录性能指标
      performanceMonitor.recordMetric(
        MetricType.NETWORK_REQUEST,
        'batch_request',
        duration,
        undefined,
        new Map([['count', items.length]])
      );
    } catch (error) {
      console.error('[RequestBatch] 批处理失败:', error);
    } finally {
      this.isProcessing = false;
      this.batchTimer = null;
      
      // 如果队列中还有请求，继续处理
      if (this.queue.length > 0) {
        this.scheduleBatch();
      }
    }
  }
  
  /**
   * 按URL分组请求
   */
  private groupRequests(items: BatchRequestItem[]): Map<string, BatchRequestItem[]> {
    const groups = new Map<string, BatchRequestItem[]>();
    
    for (const item of items) {
      const key = `${item.method}_${item.url}`;
      
      if (!groups.has(key)) {
        groups.set(key, []);
      }
      
      groups.get(key)!.push(item);
    }
    
    return groups;
  }
  
  /**
   * 发送批量请求
   */
  private async sendBatchRequest(items: BatchRequestItem[]): Promise<void> {
    if (items.length === 0) {
      return;
    }
    
    // 对于相同URL的请求，只发送一次，结果分发给所有等待者
    const first = items[0];
    
    try {
      const response = await this.sendRequest(first.url, first.method, first.data);
      
      // 分发结果给所有等待者
      for (const item of items) {
        item.resolve(response);
      }
    } catch (error) {
      // 分发错误给所有等待者
      for (const item of items) {
        item.reject(error as Error);
      }
    }
  }
  
  /**
   * 发送单个请求
   */
  private async sendRequest<T>(url: string, method: string, data?: unknown): Promise<T> {
    // TODO: 实际的HTTP请求
    // return await HttpUtil.request(url, { method, data });
    
    // 模拟请求
    return new Promise((resolve) => {
      setTimeout(() => {
        resolve({ url, method, data, timestamp: Date.now() } as T);
      }, Math.random() * 50 + 20);
    });
  }
  
  /**
   * 更新统计信息
   */
  private updateStats(): void {
    if (this.batchHistory.length === 0) {
      return;
    }
    
    const totalSize = this.batchHistory.reduce((sum, h) => sum + h.size, 0);
    const totalWait = this.batchHistory.reduce((sum, h) => sum + h.waitTime, 0);
    
    this.stats.avgBatchSize = totalSize / this.batchHistory.length;
    this.stats.avgWaitTime = totalWait / this.batchHistory.length;
  }
}

// 导出单例
export const requestBatch = RequestBatch.getInstance();
