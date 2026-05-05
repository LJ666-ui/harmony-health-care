/**
 * PerformanceMonitor 单元测试
 * 
 * @author AI Assistant
 * @date 2026-04-27
 */

import { TestSuite, Assert } from '../TestFramework';
import { PerformanceMonitor, MetricType } from '../../../main/ets/performance/PerformanceMonitor';

export class PerformanceMonitorTest extends TestSuite {
  constructor() {
    super('PerformanceMonitor 测试');
    this.registerTests();
  }
  
  private registerTests(): void {
    // 测试单例模式
    this.test('单例模式 - 应返回同一实例', async () => {
      const instance1 = PerformanceMonitor.getInstance();
      const instance2 = PerformanceMonitor.getInstance();
      
      Assert.equal(instance1, instance2, '单例实例应该相同');
    });
    
    // 测试启动监控
    this.test('启动监控 - 应成功启动', async () => {
      const monitor = PerformanceMonitor.getInstance();
      
      monitor.startMonitoring();
      const status = monitor.getMonitoringStatus();
      
      Assert.true(status, '监控应该已启动');
      
      monitor.stopMonitoring();
    });
    
    // 测试停止监控
    this.test('停止监控 - 应成功停止', async () => {
      const monitor = PerformanceMonitor.getInstance();
      
      monitor.startMonitoring();
      monitor.stopMonitoring();
      const status = monitor.getMonitoringStatus();
      
      Assert.false(status, '监控应该已停止');
    });
    
    // 测试记录指标
    this.test('记录指标 - 应成功记录', async () => {
      const monitor = PerformanceMonitor.getInstance();
      monitor.startMonitoring();
      
      monitor.recordMetric(
        MetricType.STARTUP_TIME,
        'test_startup',
        1000
      );
      
      const metrics = monitor.getMetrics();
      Assert.greaterThan(metrics.length, 0, '应该有指标记录');
      
      monitor.stopMonitoring();
      monitor.clearMetrics();
    });
    
    // 测试记录启动时间
    this.test('记录启动时间 - 应正确记录', async () => {
      const monitor = PerformanceMonitor.getInstance();
      monitor.startMonitoring();
      
      monitor.recordStartupTime(1500);
      
      const metrics = monitor.getMetricsByType(MetricType.STARTUP_TIME);
      Assert.greaterThan(metrics.length, 0, '应该有启动时间记录');
      
      if (metrics.length > 0) {
        Assert.equal(metrics[0].value, 1500, '启动时间应该为1500ms');
      }
      
      monitor.stopMonitoring();
      monitor.clearMetrics();
    });
    
    // 测试记录页面切换
    this.test('记录页面切换 - 应包含页面信息', async () => {
      const monitor = PerformanceMonitor.getInstance();
      monitor.startMonitoring();
      
      monitor.recordPageSwitch('HomePage', 'DetailPage', 200);
      
      const metrics = monitor.getMetricsByType(MetricType.PAGE_SWITCH);
      Assert.greaterThan(metrics.length, 0, '应该有页面切换记录');
      
      if (metrics.length > 0) {
        const metric = metrics[0];
        Assert.equal(metric.value, 200, '切换时间应该为200ms');
        Assert.notNull(metric.tags, '应该包含标签信息');
      }
      
      monitor.stopMonitoring();
      monitor.clearMetrics();
    });
    
    // 测试清空指标
    this.test('清空指标 - 应清空所有指标', async () => {
      const monitor = PerformanceMonitor.getInstance();
      monitor.startMonitoring();
      
      monitor.recordMetric(MetricType.CPU_USAGE, 'test_cpu', 30);
      monitor.recordMetric(MetricType.MEMORY_USAGE, 'test_memory', 100);
      
      monitor.clearMetrics();
      
      const metrics = monitor.getMetrics();
      Assert.equal(metrics.length, 0, '指标应该已清空');
      
      monitor.stopMonitoring();
    });
    
    // 测试配置更新
    this.test('配置更新 - 应正确更新配置', async () => {
      const monitor = PerformanceMonitor.getInstance();
      
      monitor.updateConfig({
        sampleRate: 0.5,
        maxMetrics: 500
      });
      
      const config = monitor.getConfig();
      Assert.equal(config.sampleRate, 0.5, '采样率应该为0.5');
      Assert.equal(config.maxMetrics, 500, '最大指标数应该为500');
      
      // 恢复默认配置
      monitor.updateConfig({
        sampleRate: 1.0,
        maxMetrics: 1000
      });
    });
  }
}
