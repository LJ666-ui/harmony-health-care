/**
 * 性能监控核心类
 * 用于采集、存储和管理应用性能指标
 * 
 * @author AI Assistant
 * @date 2026-04-27
 */

/**
 * 性能指标类型枚举
 */
export enum MetricType {
  STARTUP_TIME = 'startup_time',           // 启动时间
  PAGE_SWITCH = 'page_switch',             // 页面切换时间
  FRAME_RATE = 'frame_rate',               // 帧率
  MEMORY_USAGE = 'memory_usage',           // 内存使用
  CPU_USAGE = 'cpu_usage',                 // CPU使用率
  NETWORK_REQUEST = 'network_request',     // 网络请求时间
  RENDER_TIME = 'render_time'              // 渲染时间
}

/**
 * 性能指标接口
 */
export interface PerformanceMetric {
  type: MetricType;                        // 指标类型
  name: string;                            // 指标名称
  value: number;                           // 指标值
  timestamp: number;                       // 时间戳
  tags?: Map<string, string>;              // 标签（可选）
  metadata?: Map<string, string | number>; // 元数据（可选）
}

/**
 * 性能监控配置接口
 */
export interface MonitorConfig {
  enabled: boolean;                        // 是否启用监控
  sampleRate: number;                      // 采样率 (0-1)
  maxMetrics: number;                      // 最大指标数量
  reportInterval: number;                  // 上报间隔（毫秒）
  enableRealTimeReport: boolean;           // 是否启用实时上报
}

/**
 * 性能监控器单例类
 * 提供性能数据采集、存储和管理功能
 */
export class PerformanceMonitor {
  private static instance: PerformanceMonitor | null = null;
  
  // 性能指标存储
  private metrics: PerformanceMetric[] = [];
  
  // 监控配置
  private config: MonitorConfig = {
    enabled: true,
    sampleRate: 1.0,
    maxMetrics: 1000,
    reportInterval: 60000, // 1分钟
    enableRealTimeReport: false
  };
  
  // 监控状态
  private isMonitoring: boolean = false;
  private startTime: number = 0;
  
  // 私有构造函数（单例模式）
  private constructor() {
    console.info('[PerformanceMonitor] 初始化性能监控器');
  }
  
  /**
   * 获取单例实例
   */
  public static getInstance(): PerformanceMonitor {
    if (!PerformanceMonitor.instance) {
      PerformanceMonitor.instance = new PerformanceMonitor();
    }
    return PerformanceMonitor.instance;
  }
  
  /**
   * 启动性能监控
   */
  public startMonitoring(): void {
    if (this.isMonitoring) {
      console.warn('[PerformanceMonitor] 监控已在运行中');
      return;
    }
    
    this.isMonitoring = true;
    this.startTime = Date.now();
    console.info(`[PerformanceMonitor] 启动监控，开始时间: ${this.startTime}`);
    
    // 启动定时上报任务
    if (this.config.enableRealTimeReport) {
      this.startPeriodicReport();
    }
  }
  
  /**
   * 停止性能监控
   */
  public stopMonitoring(): void {
    if (!this.isMonitoring) {
      console.warn('[PerformanceMonitor] 监控未运行');
      return;
    }
    
    this.isMonitoring = false;
    console.info('[PerformanceMonitor] 停止监控');
    
    // 停止前上报所有数据
    this.reportMetrics();
  }
  
  /**
   * 记录性能指标
   * @param type 指标类型
   * @param name 指标名称
   * @param value 指标值
   * @param tags 标签（可选）
   * @param metadata 元数据（可选）
   */
  public recordMetric(
    type: MetricType,
    name: string,
    value: number,
    tags?: Map<string, string>,
    metadata?: Map<string, string | number>
  ): void {
    // 检查是否启用监控
    if (!this.config.enabled) {
      return;
    }
    
    // 采样率检查
    if (Math.random() > this.config.sampleRate) {
      return;
    }
    
    // 创建性能指标
    const metric: PerformanceMetric = {
      type,
      name,
      value,
      timestamp: Date.now(),
      tags,
      metadata
    };
    
    // 添加到存储
    this.metrics.push(metric);
    
    // 检查是否超过最大数量
    if (this.metrics.length >= this.config.maxMetrics) {
      this.reportMetrics();
      this.metrics = [];
    }
    
    // 实时上报关键指标
    if (this.config.enableRealTimeReport && this.isCriticalMetric(type)) {
      this.reportMetricImmediately(metric);
    }
  }
  
  /**
   * 记录启动时间
   * @param duration 启动耗时（毫秒）
   */
  public recordStartupTime(duration: number): void {
    this.recordMetric(
      MetricType.STARTUP_TIME,
      'app_startup',
      duration,
      new Map([['phase', 'cold_start']])
    );
    console.info(`[PerformanceMonitor] 记录启动时间: ${duration}ms`);
  }
  
  /**
   * 记录页面切换时间
   * @param fromPage 源页面
   * @param toPage 目标页面
   * @param duration 切换耗时（毫秒）
   */
  public recordPageSwitch(fromPage: string, toPage: string, duration: number): void {
    this.recordMetric(
      MetricType.PAGE_SWITCH,
      'page_switch',
      duration,
      new Map([
        ['from_page', fromPage],
        ['to_page', toPage]
      ])
    );
  }
  
  /**
   * 记录帧率
   * @param fps 帧率
   * @param page 页面名称
   */
  public recordFrameRate(fps: number, page: string): void {
    this.recordMetric(
      MetricType.FRAME_RATE,
      'frame_rate',
      fps,
      new Map([['page', page]])
    );
  }
  
  /**
   * 记录内存使用
   * @param used 已使用内存（MB）
   * @param total 总内存（MB）
   */
  public recordMemoryUsage(used: number, total: number): void {
    this.recordMetric(
      MetricType.MEMORY_USAGE,
      'memory_usage',
      used,
      undefined,
      new Map([['total', total], ['used', used]])
    );
  }
  
  /**
   * 记录CPU使用率
   * @param usage CPU使用率（百分比）
   */
  public recordCpuUsage(usage: number): void {
    this.recordMetric(
      MetricType.CPU_USAGE,
      'cpu_usage',
      usage
    );
  }
  
  /**
   * 记录网络请求时间
   * @param url 请求URL
   * @param method 请求方法
   * @param duration 请求耗时（毫秒）
   * @param statusCode 状态码
   */
  public recordNetworkRequest(
    url: string,
    method: string,
    duration: number,
    statusCode: number
  ): void {
    this.recordMetric(
      MetricType.NETWORK_REQUEST,
      'network_request',
      duration,
      new Map([
        ['url', url],
        ['method', method]
      ]),
      new Map([['status_code', statusCode]])
    );
  }
  
  /**
   * 获取所有指标
   */
  public getMetrics(): PerformanceMetric[] {
    return [...this.metrics];
  }
  
  /**
   * 获取指定类型的指标
   * @param type 指标类型
   */
  public getMetricsByType(type: MetricType): PerformanceMetric[] {
    return this.metrics.filter(m => m.type === type);
  }
  
  /**
   * 清空所有指标
   */
  public clearMetrics(): void {
    this.metrics = [];
    console.info('[PerformanceMonitor] 清空所有指标');
  }
  
  /**
   * 更新配置
   * @param config 新配置
   */
  public updateConfig(config: Partial<MonitorConfig>): void {
    this.config = { ...this.config, ...config };
    console.info('[PerformanceMonitor] 更新配置:', JSON.stringify(this.config));
  }
  
  /**
   * 获取当前配置
   */
  public getConfig(): MonitorConfig {
    return { ...this.config };
  }
  
  /**
   * 获取监控状态
   */
  public getMonitoringStatus(): boolean {
    return this.isMonitoring;
  }
  
  /**
   * 获取监控运行时长
   */
  public getMonitoringDuration(): number {
    if (!this.isMonitoring) {
      return 0;
    }
    return Date.now() - this.startTime;
  }
  
  // ==================== 私有方法 ====================
  
  /**
   * 判断是否为关键指标
   * @param type 指标类型
   */
  private isCriticalMetric(type: MetricType): boolean {
    const criticalTypes = [
      MetricType.STARTUP_TIME,
      MetricType.MEMORY_USAGE,
      MetricType.CPU_USAGE
    ];
    return criticalTypes.includes(type);
  }
  
  /**
   * 启动定时上报任务
   */
  private startPeriodicReport(): void {
    // 使用setInterval定时上报
    setInterval(() => {
      if (this.isMonitoring && this.metrics.length > 0) {
        this.reportMetrics();
      }
    }, this.config.reportInterval);
  }
  
  /**
   * 批量上报指标
   */
  private reportMetrics(): void {
    if (this.metrics.length === 0) {
      return;
    }
    
    console.info(`[PerformanceMonitor] 批量上报 ${this.metrics.length} 个指标`);
    
    // TODO: 实现实际的上报逻辑（调用PerformanceReporter）
    // 这里先打印日志，后续在T01-3中实现
    const reportData = {
      timestamp: Date.now(),
      count: this.metrics.length,
      metrics: this.metrics
    };
    console.debug('[PerformanceMonitor] 上报数据:', JSON.stringify(reportData));
  }
  
  /**
   * 立即上报单个指标
   * @param metric 性能指标
   */
  private reportMetricImmediately(metric: PerformanceMetric): void {
    console.info(`[PerformanceMonitor] 实时上报指标: ${metric.name} = ${metric.value}`);
    
    // TODO: 实现实际的实时上报逻辑（调用PerformanceReporter）
    // 这里先打印日志，后续在T01-3中实现
  }
}

// 导出单例实例（便捷访问）
export const performanceMonitor = PerformanceMonitor.getInstance();
