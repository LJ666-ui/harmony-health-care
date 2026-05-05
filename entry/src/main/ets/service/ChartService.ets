/**
 * 图表服务层
 * 提供数据处理、坐标轴计算、数据聚合、数据验证等功能
 */

import { AxisRange } from '../components/charts/types';

/**
 * 坐标轴配置选项
 */
export interface AxisOptions {
  // 最小值（可选）
  min?: number;
  
  // 最大值（可选）
  max?: number;
  
  // 刻度数量
  tickCount?: number;
  
  // 是否使用美观数字
  nice?: boolean;
  
  // 是否包含0
  includeZero?: boolean;
}

/**
 * 数据聚合选项
 */
export interface AggregationOptions {
  // 聚合粒度：hour, day, week, month
  granularity: 'hour' | 'day' | 'week' | 'month';
  
  // 聚合方式：avg, max, min, sum
  method: 'avg' | 'max' | 'min' | 'sum';
  
  // 时间字段名
  timeField: string;
  
  // 值字段名
  valueField: string;
}

/**
 * 数据验证结果
 */
export interface ValidationResult {
  // 是否有效
  valid: boolean;
  
  // 错误信息
  errors: string[];
  
  // 警告信息
  warnings: string[];
}

/**
 * 图表服务类（单例模式）
 */
export class ChartService {
  private static instance: ChartService;
  
  // 数据缓存
  private cache: Map<string, { data: any; timestamp: number }> = new Map();
  
  // 缓存TTL（毫秒）
  private cacheTTL: number = 5 * 60 * 1000; // 5分钟
  
  /**
   * 私有构造函数（单例模式）
   */
  private constructor() {}
  
  /**
   * 获取单例实例
   */
  public static getInstance(): ChartService {
    if (!ChartService.instance) {
      ChartService.instance = new ChartService();
    }
    return ChartService.instance;
  }
  
  /**
   * 计算坐标轴范围（Nice Numbers算法）
   * 生成美观的刻度值
   */
  public calculateAxisRange(
    data: number[],
    options: AxisOptions = {}
  ): AxisRange {
    const tickCount = options.tickCount ?? 5;
    const nice = options.nice ?? true;
    
    // 计算数据范围
    let min = options.min ?? Math.min(...data);
    let max = options.max ?? Math.max(...data);
    
    // 处理包含0的情况
    if (options.includeZero) {
      min = Math.min(0, min);
      max = Math.max(0, max);
    }
    
    // 处理所有值相同的情况
    if (min === max) {
      min = min - 1;
      max = max + 1;
    }
    
    // 应用Nice Numbers算法
    if (nice) {
      const range = this.niceNumber(max - min, false);
      const tickSpacing = this.niceNumber(range / (tickCount - 1), true);
      
      min = Math.floor(min / tickSpacing) * tickSpacing;
      max = Math.ceil(max / tickSpacing) * tickSpacing;
      
      // 生成刻度值
      const ticks: number[] = [];
      for (let tick = min; tick <= max + tickSpacing * 0.01; tick += tickSpacing) {
        ticks.push(Math.round(tick * 1000000) / 1000000); // 处理浮点数精度问题
      }
      
      return { min, max, ticks };
    }
    
    // 不使用Nice Numbers，均匀分布刻度
    const step = (max - min) / (tickCount - 1);
    const ticks: number[] = [];
    for (let i = 0; i < tickCount; i++) {
      ticks.push(Math.round((min + i * step) * 1000000) / 1000000);
    }
    
    return { min, max, ticks };
  }
  
  /**
   * Nice Number算法
   * 计算美观的数字
   */
  private niceNumber(range: number, round: boolean): number {
    // 处理0的情况
    if (range === 0) {
      return 1;
    }
    
    const exponent = Math.floor(Math.log10(Math.abs(range)));
    const fraction = Math.abs(range) / Math.pow(10, exponent);
    
    let niceFraction: number;
    
    if (round) {
      // 四舍五入模式
      if (fraction < 1.5) {
        niceFraction = 1;
      } else if (fraction < 3) {
        niceFraction = 2;
      } else if (fraction < 7) {
        niceFraction = 5;
      } else {
        niceFraction = 10;
      }
    } else {
      // 向下取整模式
      if (fraction <= 1) {
        niceFraction = 1;
      } else if (fraction <= 2) {
        niceFraction = 2;
      } else if (fraction <= 5) {
        niceFraction = 5;
      } else {
        niceFraction = 10;
      }
    }
    
    return niceFraction * Math.pow(10, exponent);
  }
  
  /**
   * 数据聚合
   */
  public aggregateData(
    data: any[],
    options: AggregationOptions
  ): any[] {
    if (!data || data.length === 0) {
      return [];
    }
    
    // 按时间粒度分组
    const groups = new Map<string, number[]>();
    
    data.forEach(item => {
      const time = new Date(item[options.timeField]);
      const key = this.getTimeKey(time, options.granularity);
      
      if (!groups.has(key)) {
        groups.set(key, []);
      }
      
      groups.get(key)!.push(item[options.valueField]);
    });
    
    // 对每组数据进行聚合
    const result: any[] = [];
    
    groups.forEach((values, key) => {
      let aggregatedValue: number;
      
      switch (options.method) {
        case 'avg':
          aggregatedValue = values.reduce((a, b) => a + b, 0) / values.length;
          break;
        case 'max':
          aggregatedValue = Math.max(...values);
          break;
        case 'min':
          aggregatedValue = Math.min(...values);
          break;
        case 'sum':
          aggregatedValue = values.reduce((a, b) => a + b, 0);
          break;
        default:
          aggregatedValue = values[values.length - 1];
      }
      
      result.push({
        [options.timeField]: this.parseTimeKey(key, options.granularity),
        [options.valueField]: aggregatedValue,
        count: values.length
      });
    });
    
    // 按时间排序
    result.sort((a, b) => {
      return new Date(a[options.timeField]).getTime() - new Date(b[options.timeField]).getTime();
    });
    
    return result;
  }
  
  /**
   * 获取时间键（用于分组）
   */
  private getTimeKey(time: Date, granularity: string): string {
    const year = time.getFullYear();
    const month = time.getMonth() + 1;
    const day = time.getDate();
    const hour = time.getHours();
    
    switch (granularity) {
      case 'hour':
        return `${year}-${month}-${day}-${hour}`;
      case 'day':
        return `${year}-${month}-${day}`;
      case 'week':
        const week = Math.ceil((day + new Date(year, month - 1, 1).getDay()) / 7);
        return `${year}-${month}-W${week}`;
      case 'month':
        return `${year}-${month}`;
      default:
        return `${year}-${month}-${day}`;
    }
  }
  
  /**
   * 解析时间键
   */
  private parseTimeKey(key: string, granularity: string): string {
    // 简化实现，返回ISO格式时间字符串
    const parts = key.split('-');
    
    switch (granularity) {
      case 'hour':
        return `${parts[0]}-${parts[1].padStart(2, '0')}-${parts[2].padStart(2, '0')}T${parts[3].padStart(2, '0')}:00:00`;
      case 'day':
        return `${parts[0]}-${parts[1].padStart(2, '0')}-${parts[2].padStart(2, '0')}T00:00:00`;
      case 'month':
        return `${parts[0]}-${parts[1].padStart(2, '0')}-01T00:00:00`;
      default:
        return `${parts[0]}-${parts[1].padStart(2, '0')}-${parts[2].padStart(2, '0')}T00:00:00`;
    }
  }
  
  /**
   * 数据验证
   */
  public validateData(
    data: any[],
    schema: Record<string, { type: string; required: boolean; min?: number; max?: number }>
  ): ValidationResult {
    const errors: string[] = [];
    const warnings: string[] = [];
    
    if (!data || !Array.isArray(data)) {
      errors.push('数据必须是非空数组');
      return { valid: false, errors, warnings };
    }
    
    if (data.length === 0) {
      warnings.push('数据数组为空');
      return { valid: true, errors, warnings };
    }
    
    // 验证每条数据
    data.forEach((item, index) => {
      Object.keys(schema).forEach(field => {
        const rule = schema[field];
        const value = item[field];
        
        // 检查必填字段
        if (rule.required && (value === undefined || value === null)) {
          errors.push(`第${index + 1}条数据缺少必填字段: ${field}`);
          return;
        }
        
        // 跳过空值
        if (value === undefined || value === null) {
          return;
        }
        
        // 检查类型
        switch (rule.type) {
          case 'number':
            if (typeof value !== 'number' || isNaN(value)) {
              errors.push(`第${index + 1}条数据字段${field}类型错误，期望number`);
            } else {
              // 检查范围
              if (rule.min !== undefined && value < rule.min) {
                warnings.push(`第${index + 1}条数据字段${field}值${value}小于最小值${rule.min}`);
              }
              if (rule.max !== undefined && value > rule.max) {
                warnings.push(`第${index + 1}条数据字段${field}值${value}大于最大值${rule.max}`);
              }
            }
            break;
          case 'string':
            if (typeof value !== 'string') {
              errors.push(`第${index + 1}条数据字段${field}类型错误，期望string`);
            }
            break;
          case 'date':
            if (!(value instanceof Date) && isNaN(Date.parse(value))) {
              errors.push(`第${index + 1}条数据字段${field}类型错误，期望date`);
            }
            break;
        }
      });
    });
    
    return {
      valid: errors.length === 0,
      errors,
      warnings
    };
  }
  
  /**
   * 数据降采样（LTTB算法 - Largest-Triangle-Three-Buckets）
   * 保留数据视觉特征，减少数据点数量
   */
  public downsampleLTTB(
    data: { x: number; y: number }[],
    threshold: number
  ): { x: number; y: number }[] {
    if (!data || data.length <= threshold) {
      return data;
    }
    
    const result: { x: number; y: number }[] = [];
    const dataLength = data.length;
    
    // 始终保留第一个点
    result.push(data[0]);
    
    // 桶大小
    const bucketSize = (dataLength - 2) / (threshold - 2);
    
    let a = 0; // 前一个选中点的索引
    
    for (let i = 0; i < threshold - 2; i++) {
      // 计算当前桶的范围
      const bucketStart = Math.floor((i + 0) * bucketSize) + 1;
      const bucketEnd = Math.floor((i + 1) * bucketSize) + 1;
      
      // 计算下一个桶的范围
      const nextBucketStart = Math.floor((i + 1) * bucketSize) + 1;
      const nextBucketEnd = Math.floor((i + 2) * bucketSize) + 1;
      
      // 计算下一个桶的平均点
      let avgX = 0;
      let avgY = 0;
      let avgCount = 0;
      
      for (let j = nextBucketStart; j < nextBucketEnd && j < dataLength; j++) {
        avgX += data[j].x;
        avgY += data[j].y;
        avgCount++;
      }
      
      avgX /= avgCount;
      avgY /= avgCount;
      
      // 在当前桶中选择与三角形面积最大的点
      let maxArea = -1;
      let maxAreaIndex = bucketStart;
      
      for (let j = bucketStart; j < bucketEnd && j < dataLength; j++) {
        // 计算三角形面积
        const area = Math.abs(
          (data[a].x - avgX) * (data[j].y - data[a].y) -
          (data[a].x - data[j].x) * (avgY - data[a].y)
        ) * 0.5;
        
        if (area > maxArea) {
          maxArea = area;
          maxAreaIndex = j;
        }
      }
      
      result.push(data[maxAreaIndex]);
      a = maxAreaIndex;
    }
    
    // 始终保留最后一个点
    result.push(data[dataLength - 1]);
    
    return result;
  }
  
  /**
   * 设置缓存
   */
  public setCache(key: string, data: any): void {
    this.cache.set(key, {
      data,
      timestamp: Date.now()
    });
  }
  
  /**
   * 获取缓存
   */
  public getCache(key: string): any | null {
    const cached = this.cache.get(key);
    
    if (!cached) {
      return null;
    }
    
    // 检查是否过期
    if (Date.now() - cached.timestamp > this.cacheTTL) {
      this.cache.delete(key);
      return null;
    }
    
    return cached.data;
  }
  
  /**
   * 清空缓存
   */
  public clearCache(): void {
    this.cache.clear();
  }
  
  /**
   * 设置缓存TTL
   */
  public setCacheTTL(ttl: number): void {
    this.cacheTTL = ttl;
  }
}
