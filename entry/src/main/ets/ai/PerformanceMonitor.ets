import { EngineType, InferenceScene } from './types/EngineTypes';
import { BackendType } from './types/ModelTypes';

export interface PerformanceMetric {
  timestamp: number;
  scene: InferenceScene;
  engine: EngineType;
  backend: BackendType;
  latency: number;
  success: boolean;
  cached: boolean;
}

export interface PerformanceStats {
  avgLatency: number;
  maxLatency: number;
  minLatency: number;
  successRate: number;
  cacheHitRate: number;
  totalRequests: number;
  npuUtilization: number;
}

export class PerformanceMonitor {
  private static instance: PerformanceMonitor;

  private metrics: PerformanceMetric[] = [];
  private readonly MAX_METRICS: number = 5000;

  private readonly LATENCY_WARNING_THRESHOLD: number = 2000;
  private readonly LATENCY_ERROR_THRESHOLD: number = 5000;
  private readonly SUCCESS_RATE_THRESHOLD: number = 0.95;
  private readonly MEMORY_WARNING_THRESHOLD: number = 0.8;

  private degradationCount: number = 0;
  private readonly DEGRADATION_THRESHOLD: number = 10;

  private constructor() {}

  static getInstance(): PerformanceMonitor {
    if (!PerformanceMonitor.instance) {
      PerformanceMonitor.instance = new PerformanceMonitor();
    }
    return PerformanceMonitor.instance;
  }

  recordMetric(metric: PerformanceMetric): void {
    this.metrics.push(metric);
    if (this.metrics.length > this.MAX_METRICS) {
      this.metrics.shift();
    }

    this.checkThresholds(metric);
  }

  getStats(timeWindowMs: number = 60000): PerformanceStats {
    const now = Date.now();
    const recentMetrics = this.metrics.filter(m => now - m.timestamp <= timeWindowMs);

    if (recentMetrics.length === 0) {
      return {
        avgLatency: 0,
        maxLatency: 0,
        minLatency: 0,
        successRate: 1,
        cacheHitRate: 0,
        totalRequests: 0,
        npuUtilization: 0
      };
    }

    const latencies = recentMetrics.map(m => m.latency);
    const successCount = recentMetrics.filter(m => m.success).length;
    const cacheHitCount = recentMetrics.filter(m => m.cached).length;
    const npuCount = recentMetrics.filter(m => m.backend === BackendType.NPU).length;

    return {
      avgLatency: latencies.reduce((a, b) => a + b, 0) / latencies.length,
      maxLatency: Math.max(...latencies),
      minLatency: Math.min(...latencies),
      successRate: successCount / recentMetrics.length,
      cacheHitRate: cacheHitCount / recentMetrics.length,
      totalRequests: recentMetrics.length,
      npuUtilization: npuCount / recentMetrics.length
    };
  }

  getStatsByScene(scene: InferenceScene, timeWindowMs: number = 60000): PerformanceStats {
    const now = Date.now();
    const sceneMetrics = this.metrics.filter(
      m => m.scene === scene && now - m.timestamp <= timeWindowMs
    );

    if (sceneMetrics.length === 0) {
      return {
        avgLatency: 0,
        maxLatency: 0,
        minLatency: 0,
        successRate: 1,
        cacheHitRate: 0,
        totalRequests: 0,
        npuUtilization: 0
      };
    }

    const latencies = sceneMetrics.map(m => m.latency);
    const successCount = sceneMetrics.filter(m => m.success).length;
    const cacheHitCount = sceneMetrics.filter(m => m.cached).length;

    return {
      avgLatency: latencies.reduce((a, b) => a + b, 0) / latencies.length,
      maxLatency: Math.max(...latencies),
      minLatency: Math.min(...latencies),
      successRate: successCount / sceneMetrics.length,
      cacheHitRate: cacheHitCount / sceneMetrics.length,
      totalRequests: sceneMetrics.length,
      npuUtilization: 0
    };
  }

  isPerformanceDegraded(): boolean {
    const stats = this.getStats();
    return stats.avgLatency > this.LATENCY_ERROR_THRESHOLD ||
           stats.successRate < this.SUCCESS_RATE_THRESHOLD;
  }

  getDegradationCount(): number {
    return this.degradationCount;
  }

  shouldRestartEngine(): boolean {
    return this.degradationCount >= this.DEGRADATION_THRESHOLD;
  }

  resetDegradationCount(): void {
    this.degradationCount = 0;
  }

  clearMetrics(): void {
    this.metrics = [];
  }

  getRecentMetrics(count: number = 100): PerformanceMetric[] {
    return this.metrics.slice(-count);
  }

  exportMetrics(): PerformanceMetric[] {
    return [...this.metrics];
  }

  private checkThresholds(metric: PerformanceMetric): void {
    if (metric.latency > this.LATENCY_WARNING_THRESHOLD) {
      console.warn(`PerformanceMonitor: 推理时延过高 ${metric.latency}ms, scene=${metric.scene}`);
    }

    if (metric.latency > this.LATENCY_ERROR_THRESHOLD || !metric.success) {
      this.degradationCount++;
      console.error(`PerformanceMonitor: 性能劣化计数=${this.degradationCount}`);

      if (this.shouldRestartEngine()) {
        console.error('PerformanceMonitor: 持续性能劣化，建议重启推理引擎');
      }
    } else {
      this.degradationCount = Math.max(0, this.degradationCount - 1);
    }
  }
}
