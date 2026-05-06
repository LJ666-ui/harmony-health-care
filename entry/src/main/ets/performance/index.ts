/**
 * 性能优化模块 - 统一导出
 * 
 * @author AI Assistant
 * @date 2026-04-27
 */

// 性能监控
export { PerformanceMonitor, performanceMonitor, MetricType, PerformanceMetric, MonitorConfig } from './PerformanceMonitor';

// 性能统计
export { PerformanceStats, performanceStats, StatsResult, SlidingWindowConfig, StatsUtils } from './PerformanceStats';

// 性能上报
export { PerformanceReporter, performanceReporter, ReporterConfig, ReportPayload, ReportResult } from './PerformanceReporter';

// 性能配置
export { 
  PerformanceConfig, 
  performanceConfig, 
  PerformanceConfigData, 
  PerformanceThresholds, 
  AlertConfig 
} from './PerformanceConfig';

// 启动优化
export { 
  StartupOptimizer, 
  startupOptimizer, 
  LazyLoadTask, 
  PreloadTask, 
  TaskResult, 
  StartupOptimizerConfig 
} from './StartupOptimizer';

// 关键数据预加载
export { 
  CriticalDataPreloader, 
  criticalDataPreloader, 
  PreloadDataType 
} from './CriticalDataPreloader';
