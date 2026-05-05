/**
 * 性能数据统计类
 * 实现滑动窗口统计和分位数计算
 * 
 * @author AI Assistant
 * @date 2026-04-27
 */

import { PerformanceMetric, MetricType } from './PerformanceMonitor';

/**
 * 统计结果接口
 */
export interface StatsResult {
  count: number;        // 数据点数量
  min: number;          // 最小值
  max: number;          // 最大值
  avg: number;          // 平均值
  sum: number;          // 总和
  p50: number;          // 中位数（P50）
  p90: number;          // P90分位数
  p95: number;          // P95分位数
  p99: number;          // P99分位数
  stdDev: number;       // 标准差
  variance: number;     // 方差
}

/**
 * 滑动窗口配置
 */
export interface SlidingWindowConfig {
  windowSize: number;   // 窗口大小（数据点数量）
  timeWindow?: number;  // 时间窗口（毫秒，可选）
}

/**
 * 滑动窗口数据结构
 * 用于存储最近N个数据点或最近T时间内的数据
 */
class SlidingWindow {
  private data: number[] = [];
  private timestamps: number[] = [];
  private config: SlidingWindowConfig;
  
  constructor(config: SlidingWindowConfig) {
    this.config = config;
  }
  
  /**
   * 添加数据点
   * @param value 数据值
   * @param timestamp 时间戳（可选，默认当前时间）
   */
  public add(value: number, timestamp: number = Date.now()): void {
    this.data.push(value);
    this.timestamps.push(timestamp);
    
    // 根据配置清理过期数据
    this.cleanup();
  }
  
  /**
   * 获取窗口内所有数据
   */
  public getData(): number[] {
    this.cleanup();
    return [...this.data];
  }
  
  /**
   * 获取窗口大小
   */
  public size(): number {
    this.cleanup();
    return this.data.length;
  }
  
  /**
   * 清空窗口
   */
  public clear(): void {
    this.data = [];
    this.timestamps = [];
  }
  
  /**
   * 清理过期数据
   */
  private cleanup(): void {
    // 按数量窗口清理
    if (this.data.length > this.config.windowSize) {
      const removeCount = this.data.length - this.config.windowSize;
      this.data.splice(0, removeCount);
      this.timestamps.splice(0, removeCount);
    }
    
    // 按时间窗口清理
    if (this.config.timeWindow) {
      const now = Date.now();
      const cutoff = now - this.config.timeWindow;
      
      while (this.timestamps.length > 0 && this.timestamps[0] < cutoff) {
        this.data.shift();
        this.timestamps.shift();
      }
    }
  }
}

/**
 * 性能统计类
 * 提供性能数据的统计分析功能
 */
export class PerformanceStats {
  // 滑动窗口映射（按指标类型）
  private windows: Map<string, SlidingWindow> = new Map();
  
  // 默认窗口配置
  private defaultConfig: SlidingWindowConfig = {
    windowSize: 100,      // 默认保留最近100个数据点
    timeWindow: 300000    // 默认时间窗口5分钟
  };
  
  /**
   * 添加性能指标到统计窗口
   * @param metric 性能指标
   */
  public addMetric(metric: PerformanceMetric): void {
    const key = this.getWindowKey(metric.type, metric.name);
    
    // 获取或创建滑动窗口
    let window = this.windows.get(key);
    if (!window) {
      window = new SlidingWindow(this.defaultConfig);
      this.windows.set(key, window);
    }
    
    // 添加数据点
    window.add(metric.value, metric.timestamp);
  }
  
  /**
   * 批量添加性能指标
   * @param metrics 性能指标数组
   */
  public addMetrics(metrics: PerformanceMetric[]): void {
    metrics.forEach(metric => this.addMetric(metric));
  }
  
  /**
   * 获取统计结果
   * @param type 指标类型
   * @param name 指标名称（可选）
   */
  public getStats(type: MetricType, name?: string): StatsResult | null {
    const key = name ? this.getWindowKey(type, name) : type;
    const window = this.windows.get(key);
    
    if (!window || window.size() === 0) {
      return null;
    }
    
    const data = window.getData();
    return this.calculateStats(data);
  }
  
  /**
   * 获取所有指标的统计结果
   */
  public getAllStats(): Map<string, StatsResult> {
    const results = new Map<string, StatsResult>();
    
    this.windows.forEach((window, key) => {
      if (window.size() > 0) {
        const data = window.getData();
        results.set(key, this.calculateStats(data));
      }
    });
    
    return results;
  }
  
  /**
   * 清空所有统计数据
   */
  public clear(): void {
    this.windows.forEach(window => window.clear());
    this.windows.clear();
  }
  
  /**
   * 更新窗口配置
   * @param config 新配置
   */
  public updateConfig(config: Partial<SlidingWindowConfig>): void {
    this.defaultConfig = { ...this.defaultConfig, ...config };
    
    // 重新创建所有窗口
    this.windows.forEach((_, key) => {
      this.windows.set(key, new SlidingWindow(this.defaultConfig));
    });
  }
  
  // ==================== 私有方法 ====================
  
  /**
   * 获取窗口键
   * @param type 指标类型
   * @param name 指标名称
   */
  private getWindowKey(type: MetricType, name: string): string {
    return `${type}:${name}`;
  }
  
  /**
   * 计算统计结果
   * @param data 数据数组
   */
  private calculateStats(data: number[]): StatsResult {
    if (data.length === 0) {
      return {
        count: 0,
        min: 0,
        max: 0,
        avg: 0,
        sum: 0,
        p50: 0,
        p90: 0,
        p95: 0,
        p99: 0,
        stdDev: 0,
        variance: 0
      };
    }
    
    // 排序数据（用于分位数计算）
    const sorted = [...data].sort((a, b) => a - b);
    
    // 基础统计
    const count = data.length;
    const min = sorted[0];
    const max = sorted[count - 1];
    const sum = data.reduce((acc, val) => acc + val, 0);
    const avg = sum / count;
    
    // 方差和标准差
    const variance = data.reduce((acc, val) => acc + Math.pow(val - avg, 2), 0) / count;
    const stdDev = Math.sqrt(variance);
    
    // 分位数
    const p50 = this.percentile(sorted, 50);
    const p90 = this.percentile(sorted, 90);
    const p95 = this.percentile(sorted, 95);
    const p99 = this.percentile(sorted, 99);
    
    return {
      count,
      min,
      max,
      avg,
      sum,
      p50,
      p90,
      p95,
      p99,
      stdDev,
      variance
    };
  }
  
  /**
   * 计算分位数
   * @param sortedData 已排序的数据数组
   * @param percentile 分位数（0-100）
   */
  private percentile(sortedData: number[], percentile: number): number {
    if (sortedData.length === 0) {
      return 0;
    }
    
    if (percentile <= 0) {
      return sortedData[0];
    }
    
    if (percentile >= 100) {
      return sortedData[sortedData.length - 1];
    }
    
    // 使用线性插值计算分位数
    const index = (percentile / 100) * (sortedData.length - 1);
    const lower = Math.floor(index);
    const upper = Math.ceil(index);
    const weight = index - lower;
    
    if (lower === upper) {
      return sortedData[lower];
    }
    
    return sortedData[lower] * (1 - weight) + sortedData[upper] * weight;
  }
}

/**
 * 性能统计工具函数
 */
export class StatsUtils {
  /**
   * 快速计算数组的统计结果
   * @param data 数据数组
   */
  public static quickStats(data: number[]): StatsResult {
    const stats = new PerformanceStats();
    const window = new SlidingWindow({ windowSize: data.length });
    
    data.forEach(value => window.add(value));
    
    const statsInstance = new PerformanceStats();
    // 临时添加数据用于计算
    const tempMetrics = data.map((value, index) => ({
      type: MetricType.STARTUP_TIME,
      name: 'temp',
      value,
      timestamp: index
    }));
    statsInstance.addMetrics(tempMetrics);
    
    return statsInstance.getStats(MetricType.STARTUP_TIME, 'temp')!;
  }
  
  /**
   * 计算移动平均
   * @param data 数据数组
   * @param windowSize 窗口大小
   */
  public static movingAverage(data: number[], windowSize: number): number[] {
    if (data.length < windowSize) {
      return [data.reduce((a, b) => a + b, 0) / data.length];
    }
    
    const result: number[] = [];
    for (let i = windowSize - 1; i < data.length; i++) {
      const window = data.slice(i - windowSize + 1, i + 1);
      const avg = window.reduce((a, b) => a + b, 0) / windowSize;
      result.push(avg);
    }
    
    return result;
  }
  
  /**
   * 计算增长率
   * @param data 数据数组
   */
  public static growthRate(data: number[]): number[] {
    if (data.length < 2) {
      return [];
    }
    
    const result: number[] = [];
    for (let i = 1; i < data.length; i++) {
      if (data[i - 1] === 0) {
        result.push(0);
      } else {
        result.push((data[i] - data[i - 1]) / data[i - 1] * 100);
      }
    }
    
    return result;
  }
}

// 导出单例实例
export const performanceStats = new PerformanceStats();
