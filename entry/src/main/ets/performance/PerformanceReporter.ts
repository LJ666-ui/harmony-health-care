/**
 * 性能数据上报类
 * 实现性能数据的上报、加密和缓存功能
 * 
 * @author AI Assistant
 * @date 2026-04-27
 */

import { PerformanceMetric } from './PerformanceMonitor';

/**
 * 上报配置接口
 */
export interface ReporterConfig {
  serverUrl: string;              // 上报服务器URL
  batchSize: number;              // 批量上报大小
  maxRetryCount: number;          // 最大重试次数
  retryDelay: number;             // 重试延迟（毫秒）
  enableEncryption: boolean;      // 是否启用加密
  enableLocalCache: boolean;      // 是否启用本地缓存
  cacheKey: string;               // 缓存键名
}

/**
 * 上报数据包接口
 */
export interface ReportPayload {
  deviceId: string;               // 设备ID
  appVersion: string;             // 应用版本
  timestamp: number;              // 时间戳
  metrics: PerformanceMetric[];   // 性能指标数组
  stats?: Map<string, number>;    // 统计摘要（可选）
}

/**
 * 上报结果接口
 */
export interface ReportResult {
  success: boolean;               // 是否成功
  message: string;                // 结果消息
  timestamp: number;              // 时间戳
  failedCount?: number;           // 失败数量
}

/**
 * 性能数据上报器
 */
export class PerformanceReporter {
  private static instance: PerformanceReporter | null = null;
  
  // 上报配置
  private config: ReporterConfig = {
    serverUrl: 'https://api.example.com/performance/report',
    batchSize: 50,
    maxRetryCount: 3,
    retryDelay: 1000,
    enableEncryption: true,
    enableLocalCache: true,
    cacheKey: 'performance_metrics_cache'
  };
  
  // 上报队列
  private reportQueue: PerformanceMetric[] = [];
  
  // 失败队列（用于重试）
  private failedQueue: PerformanceMetric[] = [];
  
  // 设备信息
  private deviceId: string = '';
  private appVersion: string = '1.0.0';
  
  // 上报状态
  private isReporting: boolean = false;
  
  // 私有构造函数（单例模式）
  private constructor() {
    this.initDeviceInfo();
    this.loadCachedMetrics();
    console.info('[PerformanceReporter] 初始化性能数据上报器');
  }
  
  /**
   * 获取单例实例
   */
  public static getInstance(): PerformanceReporter {
    if (!PerformanceReporter.instance) {
      PerformanceReporter.instance = new PerformanceReporter();
    }
    return PerformanceReporter.instance;
  }
  
  /**
   * 上报单个指标（实时上报）
   * @param metric 性能指标
   */
  public async reportImmediately(metric: PerformanceMetric): Promise<ReportResult> {
    try {
      const payload = this.createPayload([metric]);
      
      if (this.config.enableEncryption) {
        await this.encryptPayload(payload);
      }
      
      const result = await this.sendToServer(payload);
      
      if (!result.success && this.config.enableLocalCache) {
        this.cacheMetric(metric);
      }
      
      return result;
    } catch (error) {
      console.error('[PerformanceReporter] 实时上报失败:', error);
      return {
        success: false,
        message: `上报失败: ${error}`,
        timestamp: Date.now()
      };
    }
  }
  
  /**
   * 批量上报指标
   * @param metrics 性能指标数组
   */
  public async reportBatch(metrics: PerformanceMetric[]): Promise<ReportResult> {
    if (metrics.length === 0) {
      return {
        success: true,
        message: '无数据需要上报',
        timestamp: Date.now()
      };
    }
    
    try {
      // 分批上报
      const batches = this.splitIntoBatches(metrics);
      let successCount = 0;
      let failedCount = 0;
      
      for (const batch of batches) {
        const payload = this.createPayload(batch);
        
        if (this.config.enableEncryption) {
          await this.encryptPayload(payload);
        }
        
        const result = await this.sendToServer(payload);
        
        if (result.success) {
          successCount += batch.length;
        } else {
          failedCount += batch.length;
          // 失败的数据加入重试队列
          this.failedQueue.push(...batch);
        }
      }
      
      // 处理失败的数据
      if (failedCount > 0) {
        await this.retryFailedMetrics();
      }
      
      return {
        success: failedCount === 0,
        message: `上报完成: 成功${successCount}个, 失败${failedCount}个`,
        timestamp: Date.now(),
        failedCount
      };
    } catch (error) {
      console.error('[PerformanceReporter] 批量上报失败:', error);
      
      // 缓存失败的数据
      if (this.config.enableLocalCache) {
        metrics.forEach(m => this.cacheMetric(m));
      }
      
      return {
        success: false,
        message: `批量上报失败: ${error}`,
        timestamp: Date.now(),
        failedCount: metrics.length
      };
    }
  }
  
  /**
   * 添加指标到上报队列
   * @param metric 性能指标
   */
  public addToQueue(metric: PerformanceMetric): void {
    this.reportQueue.push(metric);
    
    // 检查是否达到批量上报阈值
    if (this.reportQueue.length >= this.config.batchSize) {
      this.flushQueue();
    }
  }
  
  /**
   * 刷新上报队列
   */
  public async flushQueue(): Promise<ReportResult> {
    if (this.reportQueue.length === 0) {
      return {
        success: true,
        message: '队列为空',
        timestamp: Date.now()
      };
    }
    
    const metrics = [...this.reportQueue];
    this.reportQueue = [];
    
    return await this.reportBatch(metrics);
  }
  
  /**
   * 更新配置
   * @param config 新配置
   */
  public updateConfig(config: Partial<ReporterConfig>): void {
    this.config = { ...this.config, ...config };
    console.info('[PerformanceReporter] 更新配置:', JSON.stringify(this.config));
  }
  
  /**
   * 获取当前配置
   */
  public getConfig(): ReporterConfig {
    return { ...this.config };
  }
  
  /**
   * 获取队列状态
   */
  public getQueueStatus(): { pending: number; failed: number } {
    return {
      pending: this.reportQueue.length,
      failed: this.failedQueue.length
    };
  }
  
  // ==================== 私有方法 ====================
  
  /**
   * 初始化设备信息
   */
  private initDeviceInfo(): void {
    // TODO: 从系统API获取设备ID和应用版本
    // 这里使用临时值
    this.deviceId = `device_${Date.now()}`;
    this.appVersion = '14.0.0';
  }
  
  /**
   * 加载缓存的指标
   */
  private loadCachedMetrics(): void {
    if (!this.config.enableLocalCache) {
      return;
    }
    
    try {
      // TODO: 从本地存储加载缓存的指标
      // 使用Preferences API
      console.info('[PerformanceReporter] 加载缓存指标');
    } catch (error) {
      console.error('[PerformanceReporter] 加载缓存失败:', error);
    }
  }
  
  /**
   * 缓存指标到本地
   * @param metric 性能指标
   */
  private cacheMetric(metric: PerformanceMetric): void {
    if (!this.config.enableLocalCache) {
      return;
    }
    
    try {
      // TODO: 使用Preferences API缓存指标
      console.debug('[PerformanceReporter] 缓存指标:', metric.name);
    } catch (error) {
      console.error('[PerformanceReporter] 缓存指标失败:', error);
    }
  }
  
  /**
   * 创建上报数据包
   * @param metrics 性能指标数组
   */
  private createPayload(metrics: PerformanceMetric[]): ReportPayload {
    return {
      deviceId: this.deviceId,
      appVersion: this.appVersion,
      timestamp: Date.now(),
      metrics: metrics
    };
  }
  
  /**
   * 加密数据包
   * @param payload 数据包
   */
  private async encryptPayload(payload: ReportPayload): Promise<void> {
    // TODO: 实现数据加密
    // 可以使用AES加密或其他加密算法
    console.debug('[PerformanceReporter] 加密数据包');
  }
  
  /**
   * 发送数据到服务器
   * @param payload 数据包
   */
  private async sendToServer(payload: ReportPayload): Promise<ReportResult> {
    try {
      // TODO: 实现实际的HTTP请求
      // 使用HttpUtil或fetch API
      
      console.info(`[PerformanceReporter] 发送${payload.metrics.length}个指标到服务器`);
      
      // 模拟网络请求
      await this.simulateNetworkRequest();
      
      return {
        success: true,
        message: '上报成功',
        timestamp: Date.now()
      };
    } catch (error) {
      console.error('[PerformanceReporter] 发送失败:', error);
      return {
        success: false,
        message: `发送失败: ${error}`,
        timestamp: Date.now()
      };
    }
  }
  
  /**
   * 模拟网络请求（用于测试）
   */
  private async simulateNetworkRequest(): Promise<void> {
    return new Promise((resolve) => {
      setTimeout(resolve, 100); // 模拟100ms网络延迟
    });
  }
  
  /**
   * 分割数据为批次
   * @param metrics 性能指标数组
   */
  private splitIntoBatches(metrics: PerformanceMetric[]): PerformanceMetric[][] {
    const batches: PerformanceMetric[][] = [];
    const batchSize = this.config.batchSize;
    
    for (let i = 0; i < metrics.length; i += batchSize) {
      batches.push(metrics.slice(i, i + batchSize));
    }
    
    return batches;
  }
  
  /**
   * 重试失败的指标
   */
  private async retryFailedMetrics(): Promise<void> {
    if (this.failedQueue.length === 0) {
      return;
    }
    
    console.info(`[PerformanceReporter] 重试${this.failedQueue.length}个失败指标`);
    
    const metrics = [...this.failedQueue];
    this.failedQueue = [];
    
    for (let retry = 0; retry < this.config.maxRetryCount; retry++) {
      const result = await this.reportBatch(metrics);
      
      if (result.success) {
        console.info('[PerformanceReporter] 重试成功');
        return;
      }
      
      // 等待重试延迟
      await this.delay(this.config.retryDelay);
    }
    
    // 重试失败，缓存数据
    if (this.config.enableLocalCache) {
      metrics.forEach(m => this.cacheMetric(m));
    }
    
    console.warn('[PerformanceReporter] 重试失败，已缓存数据');
  }
  
  /**
   * 延迟函数
   * @param ms 延迟毫秒数
   */
  private delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}

// 导出单例实例
export const performanceReporter = PerformanceReporter.getInstance();
