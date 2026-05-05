/**
 * 性能监控配置管理类
 * 提供配置读取、修改和验证功能
 * 
 * @author AI Assistant
 * @date 2026-04-27
 */

import { MonitorConfig } from './PerformanceMonitor';
import { SlidingWindowConfig } from './PerformanceStats';
import { ReporterConfig } from './PerformanceReporter';

/**
 * 性能阈值配置
 */
export interface PerformanceThresholds {
  startupTime: number;      // 启动时间阈值（毫秒）
  pageSwitch: number;       // 页面切换阈值（毫秒）
  frameRate: number;        // 帧率阈值（fps）
  memoryUsage: number;      // 内存使用阈值（MB）
  cpuUsage: number;         // CPU使用率阈值（百分比）
  networkRequest: number;   // 网络请求阈值（毫秒）
}

/**
 * 告警配置
 */
export interface AlertConfig {
  enabled: boolean;              // 是否启用告警
  startupTimeAlert: boolean;     // 启动时间告警
  memoryLeakAlert: boolean;      // 内存泄漏告警
  cpuSpikeAlert: boolean;        // CPU峰值告警
  frameDropAlert: boolean;       // 掉帧告警
}

/**
 * 完整的性能配置
 */
export interface PerformanceConfigData {
  version: string;
  monitor: MonitorConfig;
  stats: SlidingWindowConfig;
  reporter: ReporterConfig;
  thresholds: PerformanceThresholds;
  alerts: AlertConfig;
}

/**
 * 性能配置管理类
 */
export class PerformanceConfig {
  private static instance: PerformanceConfig | null = null;
  
  // 默认配置
  private config: PerformanceConfigData = {
    version: '1.0.0',
    monitor: {
      enabled: true,
      sampleRate: 1.0,
      maxMetrics: 1000,
      reportInterval: 60000,
      enableRealTimeReport: false
    },
    stats: {
      windowSize: 100,
      timeWindow: 300000
    },
    reporter: {
      serverUrl: 'https://api.example.com/performance/report',
      batchSize: 50,
      maxRetryCount: 3,
      retryDelay: 1000,
      enableEncryption: true,
      enableLocalCache: true,
      cacheKey: 'performance_metrics_cache'
    },
    thresholds: {
      startupTime: 1500,
      pageSwitch: 300,
      frameRate: 55,
      memoryUsage: 200,
      cpuUsage: 30,
      networkRequest: 500
    },
    alerts: {
      enabled: true,
      startupTimeAlert: true,
      memoryLeakAlert: true,
      cpuSpikeAlert: true,
      frameDropAlert: true
    }
  };
  
  // 配置文件路径
  private configFilePath: string = 'resources/rawfile/performance-config.json';
  
  // 私有构造函数（单例模式）
  private constructor() {
    this.loadConfig();
  }
  
  /**
   * 获取单例实例
   */
  public static getInstance(): PerformanceConfig {
    if (!PerformanceConfig.instance) {
      PerformanceConfig.instance = new PerformanceConfig();
    }
    return PerformanceConfig.instance;
  }
  
  /**
   * 加载配置文件
   */
  public async loadConfig(): Promise<void> {
    try {
      // TODO: 从rawfile读取配置文件
      // 使用resourceManager API
      
      console.info('[PerformanceConfig] 加载配置文件:', this.configFilePath);
      
      // 暂时使用默认配置
      console.info('[PerformanceConfig] 使用默认配置');
    } catch (error) {
      console.error('[PerformanceConfig] 加载配置失败:', error);
      console.info('[PerformanceConfig] 使用默认配置');
    }
  }
  
  /**
   * 获取完整配置
   */
  public getConfig(): PerformanceConfigData {
    return { ...this.config };
  }
  
  /**
   * 获取监控配置
   */
  public getMonitorConfig(): MonitorConfig {
    return { ...this.config.monitor };
  }
  
  /**
   * 获取统计配置
   */
  public getStatsConfig(): SlidingWindowConfig {
    return { ...this.config.stats };
  }
  
  /**
   * 获取上报配置
   */
  public getReporterConfig(): ReporterConfig {
    return { ...this.config.reporter };
  }
  
  /**
   * 获取性能阈值
   */
  public getThresholds(): PerformanceThresholds {
    return { ...this.config.thresholds };
  }
  
  /**
   * 获取告警配置
   */
  public getAlertConfig(): AlertConfig {
    return { ...this.config.alerts };
  }
  
  /**
   * 更新监控配置
   * @param config 新配置
   */
  public updateMonitorConfig(config: Partial<MonitorConfig>): void {
    this.config.monitor = { ...this.config.monitor, ...config };
    this.validateConfig();
    console.info('[PerformanceConfig] 更新监控配置:', JSON.stringify(this.config.monitor));
  }
  
  /**
   * 更新统计配置
   * @param config 新配置
   */
  public updateStatsConfig(config: Partial<SlidingWindowConfig>): void {
    this.config.stats = { ...this.config.stats, ...config };
    this.validateConfig();
    console.info('[PerformanceConfig] 更新统计配置:', JSON.stringify(this.config.stats));
  }
  
  /**
   * 更新上报配置
   * @param config 新配置
   */
  public updateReporterConfig(config: Partial<ReporterConfig>): void {
    this.config.reporter = { ...this.config.reporter, ...config };
    this.validateConfig();
    console.info('[PerformanceConfig] 更新上报配置:', JSON.stringify(this.config.reporter));
  }
  
  /**
   * 更新性能阈值
   * @param thresholds 新阈值
   */
  public updateThresholds(thresholds: Partial<PerformanceThresholds>): void {
    this.config.thresholds = { ...this.config.thresholds, ...thresholds };
    this.validateConfig();
    console.info('[PerformanceConfig] 更新性能阈值:', JSON.stringify(this.config.thresholds));
  }
  
  /**
   * 更新告警配置
   * @param config 新配置
   */
  public updateAlertConfig(config: Partial<AlertConfig>): void {
    this.config.alerts = { ...this.config.alerts, ...config };
    this.validateConfig();
    console.info('[PerformanceConfig] 更新告警配置:', JSON.stringify(this.config.alerts));
  }
  
  /**
   * 重置为默认配置
   */
  public resetToDefault(): void {
    this.config = {
      version: '1.0.0',
      monitor: {
        enabled: true,
        sampleRate: 1.0,
        maxMetrics: 1000,
        reportInterval: 60000,
        enableRealTimeReport: false
      },
      stats: {
        windowSize: 100,
        timeWindow: 300000
      },
      reporter: {
        serverUrl: 'https://api.example.com/performance/report',
        batchSize: 50,
        maxRetryCount: 3,
        retryDelay: 1000,
        enableEncryption: true,
        enableLocalCache: true,
        cacheKey: 'performance_metrics_cache'
      },
      thresholds: {
        startupTime: 1500,
        pageSwitch: 300,
        frameRate: 55,
        memoryUsage: 200,
        cpuUsage: 30,
        networkRequest: 500
      },
      alerts: {
        enabled: true,
        startupTimeAlert: true,
        memoryLeakAlert: true,
        cpuSpikeAlert: true,
        frameDropAlert: true
      }
    };
    
    console.info('[PerformanceConfig] 重置为默认配置');
  }
  
  /**
   * 保存配置到本地
   */
  public async saveConfig(): Promise<void> {
    try {
      // TODO: 使用Preferences API保存配置
      console.info('[PerformanceConfig] 保存配置到本地');
    } catch (error) {
      console.error('[PerformanceConfig] 保存配置失败:', error);
    }
  }
  
  /**
   * 验证配置有效性
   */
  public validateConfig(): boolean {
    try {
      // 验证监控配置
      if (this.config.monitor.sampleRate < 0 || this.config.monitor.sampleRate > 1) {
        throw new Error('采样率必须在0-1之间');
      }
      
      if (this.config.monitor.maxMetrics <= 0) {
        throw new Error('最大指标数量必须大于0');
      }
      
      if (this.config.monitor.reportInterval <= 0) {
        throw new Error('上报间隔必须大于0');
      }
      
      // 验证统计配置
      if (this.config.stats.windowSize <= 0) {
        throw new Error('窗口大小必须大于0');
      }
      
      if (this.config.stats.timeWindow && this.config.stats.timeWindow <= 0) {
        throw new Error('时间窗口必须大于0');
      }
      
      // 验证上报配置
      if (this.config.reporter.batchSize <= 0) {
        throw new Error('批量大小必须大于0');
      }
      
      if (this.config.reporter.maxRetryCount < 0) {
        throw new Error('最大重试次数不能为负数');
      }
      
      // 验证阈值
      if (this.config.thresholds.startupTime <= 0) {
        throw new Error('启动时间阈值必须大于0');
      }
      
      if (this.config.thresholds.frameRate <= 0) {
        throw new Error('帧率阈值必须大于0');
      }
      
      console.info('[PerformanceConfig] 配置验证通过');
      return true;
    } catch (error) {
      console.error('[PerformanceConfig] 配置验证失败:', error);
      return false;
    }
  }
  
  /**
   * 检查性能是否达标
   * @param metricName 指标名称
   * @param value 指标值
   */
  public isPerformanceGood(metricName: keyof PerformanceThresholds, value: number): boolean {
    const threshold = this.config.thresholds[metricName];
    
    // 帧率是越高越好，其他指标是越低越好
    if (metricName === 'frameRate') {
      return value >= threshold;
    }
    
    return value <= threshold;
  }
  
  /**
   * 获取性能评级
   * @param metricName 指标名称
   * @param value 指标值
   */
  public getPerformanceRating(metricName: keyof PerformanceThresholds, value: number): 'excellent' | 'good' | 'fair' | 'poor' {
    const threshold = this.config.thresholds[metricName];
    
    // 帧率是越高越好
    if (metricName === 'frameRate') {
      if (value >= threshold * 1.1) return 'excellent';
      if (value >= threshold) return 'good';
      if (value >= threshold * 0.9) return 'fair';
      return 'poor';
    }
    
    // 其他指标是越低越好
    if (value <= threshold * 0.7) return 'excellent';
    if (value <= threshold) return 'good';
    if (value <= threshold * 1.3) return 'fair';
    return 'poor';
  }
}

// 导出单例实例
export const performanceConfig = PerformanceConfig.getInstance();
