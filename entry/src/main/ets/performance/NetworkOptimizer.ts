/**
 * 网络请求优化器
 * 管理请求合并、数据预取和离线缓存，提升网络性能
 * 
 * @author AI Assistant
 * @date 2026-04-27
 */

import { performanceMonitor, MetricType } from './PerformanceMonitor';

/**
 * 网络优化配置
 */
export interface NetworkOptimizerConfig {
  enableBatch: boolean;           // 是否启用批处理
  enablePrefetch: boolean;        // 是否启用预取
  enableOfflineCache: boolean;    // 是否启用离线缓存
  enableDeduplication: boolean;   // 是否启用去重
  maxConcurrent: number;          // 最大并发数
  timeout: number;                // 默认超时（毫秒）
  retryCount: number;             // 重试次数
}

/**
 * 请求项
 */
interface RequestItem {
  id: string;
  url: string;
  method: string;
  data?: unknown;
  timestamp: number;
  priority: number;
}

/**
 * 响应缓存项
 */
interface ResponseCacheItem {
  url: string;
  method: string;
  response: unknown;
  timestamp: number;
  expireTime: number;
}

/**
 * 网络统计
 */
export interface NetworkStats {
  totalRequests: number;          // 总请求数
  successRequests: number;        // 成功请求数
  failedRequests: number;         // 失败请求数
  cachedRequests: number;         // 缓存请求数
  avgResponseTime: number;        // 平均响应时间
  totalDataSize: number;          // 总数据大小（KB）
}

/**
 * 网络请求优化器
 */
export class NetworkOptimizer {
  private static instance: NetworkOptimizer | null = null;
  
  // 配置
  private config: NetworkOptimizerConfig = {
    enableBatch: true,
    enablePrefetch: true,
    enableOfflineCache: true,
    enableDeduplication: true,
    maxConcurrent: 6,
    timeout: 30000,
    retryCount: 3
  };
  
  // 请求队列
  private requestQueue: RequestItem[] = [];
  
  // 正在进行的请求
  private pendingRequests: Map<string, Promise<unknown>> = new Map();
  
  // 响应缓存
  private responseCache: Map<string, ResponseCacheItem> = new Map();
  
  // 统计信息
  private stats: NetworkStats = {
    totalRequests: 0,
    successRequests: 0,
    failedRequests: 0,
    cachedRequests: 0,
    avgResponseTime: 0,
    totalDataSize: 0
  };
  
  // 响应时间历史
  private responseTimeHistory: number[] = [];
  
  // 私有构造函数
  private constructor() {
    console.info('[NetworkOptimizer] 初始化网络请求优化器');
  }
  
  /**
   * 获取单例实例
   */
  public static getInstance(): NetworkOptimizer {
    if (!NetworkOptimizer.instance) {
      NetworkOptimizer.instance = new NetworkOptimizer();
    }
    return NetworkOptimizer.instance;
  }
  
  /**
   * 发送请求
   * @param url 请求URL
   * @param method 请求方法
   * @param data 请求数据
   * @param priority 优先级
   */
  public async request<T>(
    url: string,
    method: string = 'GET',
    data?: unknown,
    priority: number = 0
  ): Promise<T> {
    this.stats.totalRequests++;
    
    // 检查缓存
    if (method === 'GET') {
      const cached = this.getCachedResponse<T>(url, method);
      if (cached) {
        this.stats.cachedRequests++;
        console.debug(`[NetworkOptimizer] 使用缓存响应: ${url}`);
        return cached;
      }
    }
    
    // 去重检查
    if (this.config.enableDeduplication) {
      const pending = this.pendingRequests.get(url);
      if (pending) {
        console.debug(`[NetworkOptimizer] 请求去重: ${url}`);
        return pending as Promise<T>;
      }
    }
    
    // 创建请求
    const requestId = this.generateRequestId(url, method);
    const requestPromise = this.executeRequest<T>(url, method, data, priority);
    
    // 添加到pending
    this.pendingRequests.set(requestId, requestPromise);
    
    try {
      const response = await requestPromise;
      return response;
    } finally {
      this.pendingRequests.delete(requestId);
    }
  }
  
  /**
   * 预取数据
   * @param urls URL数组
   */
  public async prefetch(urls: string[]): Promise<void> {
    if (!this.config.enablePrefetch) {
      return;
    }
    
    console.info(`[NetworkOptimizer] 开始预取 ${urls.length} 个资源`);
    
    const promises = urls.map(url => 
      this.request(url, 'GET').catch(error => {
        console.error(`[NetworkOptimizer] 预取失败: ${url}`, error);
      })
    );
    
    await Promise.all(promises);
    console.info('[NetworkOptimizer] 预取完成');
  }
  
  /**
   * 批量请求
   * @param requests 请求数组
   */
  public async batchRequest<T>(
    requests: Array<{ url: string; method?: string; data?: unknown }>
  ): Promise<T[]> {
    if (!this.config.enableBatch) {
      return Promise.all(
        requests.map(req => this.request<T>(req.url, req.method, req.data))
      );
    }
    
    console.info(`[NetworkOptimizer] 批量请求 ${requests.length} 个资源`);
    
    // 分批执行，控制并发数
    const results: T[] = [];
    const batches = this.splitIntoBatches(requests, this.config.maxConcurrent);
    
    for (const batch of batches) {
      const batchResults = await Promise.all(
        batch.map(req => this.request<T>(req.url, req.method, req.data))
      );
      results.push(...batchResults);
    }
    
    return results;
  }
  
  /**
   * 清空缓存
   */
  public clearCache(): void {
    this.responseCache.clear();
    console.info('[NetworkOptimizer] 清空响应缓存');
  }
  
  /**
   * 获取统计信息
   */
  public getStats(): NetworkStats {
    return { ...this.stats };
  }
  
  /**
   * 更新配置
   */
  public updateConfig(config: Partial<NetworkOptimizerConfig>): void {
    this.config = { ...this.config, ...config };
    console.info('[NetworkOptimizer] 更新配置:', JSON.stringify(this.config));
  }
  
  /**
   * 获取当前配置
   */
  public getConfig(): NetworkOptimizerConfig {
    return { ...this.config };
  }
  
  // ==================== 私有方法 ====================
  
  /**
   * 执行请求
   */
  private async executeRequest<T>(
    url: string,
    method: string,
    data?: unknown,
    priority: number = 0
  ): Promise<T> {
    const startTime = Date.now();
    
    try {
      // TODO: 实际的HTTP请求
      // const response = await HttpUtil.request(url, { method, data, timeout: this.config.timeout });
      
      // 模拟请求
      const response = await this.simulateRequest<T>(url, method, data);
      
      const duration = Date.now() - startTime;
      
      // 更新统计
      this.stats.successRequests++;
      this.updateResponseTime(duration);
      
      // 缓存GET请求响应
      if (method === 'GET') {
        this.cacheResponse(url, method, response);
      }
      
      // 记录性能指标
      performanceMonitor.recordNetworkRequest(url, method, duration, 200);
      
      console.debug(`[NetworkOptimizer] 请求成功: ${url}, 耗时: ${duration}ms`);
      
      return response;
    } catch (error) {
      const duration = Date.now() - startTime;
      
      this.stats.failedRequests++;
      
      // 记录失败请求
      performanceMonitor.recordNetworkRequest(url, method, duration, 500);
      
      console.error(`[NetworkOptimizer] 请求失败: ${url}`, error);
      
      throw error;
    }
  }
  
  /**
   * 模拟请求（用于测试）
   */
  private async simulateRequest<T>(url: string, method: string, data?: unknown): Promise<T> {
    return new Promise((resolve) => {
      setTimeout(() => {
        resolve({ url, method, data, timestamp: Date.now() } as T);
      }, Math.random() * 100 + 50); // 50-150ms延迟
    });
  }
  
  /**
   * 获取缓存的响应
   */
  private getCachedResponse<T>(url: string, method: string): T | null {
    const cacheKey = this.generateCacheKey(url, method);
    const cached = this.responseCache.get(cacheKey);
    
    if (!cached) {
      return null;
    }
    
    // 检查是否过期
    if (Date.now() - cached.timestamp > cached.expireTime) {
      this.responseCache.delete(cacheKey);
      return null;
    }
    
    return cached.response as T;
  }
  
  /**
   * 缓存响应
   */
  private cacheResponse(url: string, method: string, response: unknown): void {
    if (!this.config.enableOfflineCache) {
      return;
    }
    
    const cacheKey = this.generateCacheKey(url, method);
    
    this.responseCache.set(cacheKey, {
      url,
      method,
      response,
      timestamp: Date.now(),
      expireTime: 300000 // 5分钟
    });
    
    console.debug(`[NetworkOptimizer] 缓存响应: ${url}`);
  }
  
  /**
   * 生成请求ID
   */
  private generateRequestId(url: string, method: string): string {
    return `${method}_${url}`;
  }
  
  /**
   * 生成缓存键
   */
  private generateCacheKey(url: string, method: string): string {
    return `${method}_${url}`;
  }
  
  /**
   * 分割为批次
   */
  private splitIntoBatches<T>(items: T[], batchSize: number): T[][] {
    const batches: T[][] = [];
    
    for (let i = 0; i < items.length; i += batchSize) {
      batches.push(items.slice(i, i + batchSize));
    }
    
    return batches;
  }
  
  /**
   * 更新平均响应时间
   */
  private updateResponseTime(duration: number): void {
    this.responseTimeHistory.push(duration);
    
    // 保留最近100次
    if (this.responseTimeHistory.length > 100) {
      this.responseTimeHistory.shift();
    }
    
    const total = this.responseTimeHistory.reduce((sum, time) => sum + time, 0);
    this.stats.avgResponseTime = total / this.responseTimeHistory.length;
  }
}

// 导出单例
export const networkOptimizer = NetworkOptimizer.getInstance();
