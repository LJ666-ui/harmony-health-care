/**
 * CPU使用率优化器
 * 管理任务调度、防抖节流，降低CPU占用
 * 
 * @author AI Assistant
 * @date 2026-04-27
 */

import { performanceMonitor, MetricType } from './PerformanceMonitor';

/**
 * CPU优化配置
 */
export interface CpuOptimizerConfig {
  enableTaskScheduler: boolean;   // 是否启用任务调度
  enableDebounce: boolean;        // 是否启用防抖
  enableThrottle: boolean;        // 是否启用节流
  maxCpuUsage: number;            // 最大CPU使用率（百分比）
  taskQueueSize: number;          // 任务队列大小
  idleThreshold: number;          // 空闲阈值（百分比）
}

/**
 * 任务项
 */
interface TaskItem {
  id: string;
  name: string;
  execute: () => Promise<void>;
  priority: number;
  timestamp: number;
}

/**
 * CPU统计
 */
export interface CpuStats {
  avgUsage: number;               // 平均使用率
  peakUsage: number;              // 峰值使用率
  taskCount: number;              // 任务数量
  completedTasks: number;         // 完成任务数
  droppedTasks: number;           // 丢弃任务数
}

/**
 * CPU使用率优化器
 */
export class CpuOptimizer {
  private static instance: CpuOptimizer | null = null;
  
  // 配置
  private config: CpuOptimizerConfig = {
    enableTaskScheduler: true,
    enableDebounce: true,
    enableThrottle: true,
    maxCpuUsage: 30,              // 30%
    taskQueueSize: 100,
    idleThreshold: 20            // 20%
  };
  
  // 任务队列
  private taskQueue: TaskItem[] = [];
  
  // 正在执行的任务
  private executingTasks: number = 0;
  
  // 统计信息
  private stats: CpuStats = {
    avgUsage: 0,
    peakUsage: 0,
    taskCount: 0,
    completedTasks: 0,
    droppedTasks: 0
  };
  
  // CPU使用历史
  private usageHistory: number[] = [];
  
  // 私有构造函数
  private constructor() {
    this.startMonitoring();
    console.info('[CpuOptimizer] 初始化CPU优化器');
  }
  
  /**
   * 获取单例实例
   */
  public static getInstance(): CpuOptimizer {
    if (!CpuOptimizer.instance) {
      CpuOptimizer.instance = new CpuOptimizer();
    }
    return CpuOptimizer.instance;
  }
  
  /**
   * 防抖函数
   * @param func 要防抖的函数
   * @param delay 延迟时间
   */
  public debounce<T extends (...args: unknown[]) => unknown>(
    func: T,
    delay: number = 300
  ): (...args: Parameters<T>) => void {
    if (!this.config.enableDebounce) {
      return func;
    }
    
    let timer: number | null = null;
    
    return (...args: Parameters<T>) => {
      if (timer) {
        clearTimeout(timer);
      }
      
      timer = setTimeout(() => {
        func(...args);
        timer = null;
      }, delay) as unknown as number;
    };
  }
  
  /**
   * 节流函数
   * @param func 要节流的函数
   * @param limit 时间限制
   */
  public throttle<T extends (...args: unknown[]) => unknown>(
    func: T,
    limit: number = 300
  ): (...args: Parameters<T>) => void {
    if (!this.config.enableThrottle) {
      return func;
    }
    
    let inThrottle = false;
    
    return (...args: Parameters<T>) => {
      if (!inThrottle) {
        func(...args);
        inThrottle = true;
        
        setTimeout(() => {
          inThrottle = false;
        }, limit);
      }
    };
  }
  
  /**
   * 调度任务
   * @param name 任务名称
   * @param execute 执行函数
   * @param priority 优先级
   */
  public async scheduleTask(
    name: string,
    execute: () => Promise<void>,
    priority: number = 0
  ): Promise<void> {
    if (!this.config.enableTaskScheduler) {
      await execute();
      return;
    }
    
    // 检查队列大小
    if (this.taskQueue.length >= this.config.taskQueueSize) {
      console.warn('[CpuOptimizer] 任务队列已满，丢弃低优先级任务');
      this.stats.droppedTasks++;
      return;
    }
    
    // 创建任务
    const task: TaskItem = {
      id: this.generateId(),
      name,
      execute,
      priority,
      timestamp: Date.now()
    };
    
    // 添加到队列
    this.taskQueue.push(task);
    this.taskQueue.sort((a, b) => b.priority - a.priority);
    
    this.stats.taskCount++;
    
    console.debug(`[CpuOptimizer] 调度任务: ${name}`);
    
    // 执行任务
    await this.executeNextTask();
  }
  
  /**
   * 获取CPU使用率
   */
  public async getCpuUsage(): Promise<number> {
    // TODO: 使用系统API获取实际CPU使用率
    // const usage = await process.cpuUsage();
    
    // 模拟CPU使用率
    const usage = Math.random() * 40 + 10; // 10-50%
    
    // 更新历史
    this.usageHistory.push(usage);
    if (this.usageHistory.length > 100) {
      this.usageHistory.shift();
    }
    
    // 更新统计
    this.updateStats(usage);
    
    // 记录性能指标
    performanceMonitor.recordCpuUsage(usage);
    
    return usage;
  }
  
  /**
   * 获取统计信息
   */
  public getStats(): CpuStats {
    return { ...this.stats };
  }
  
  /**
   * 更新配置
   */
  public updateConfig(config: Partial<CpuOptimizerConfig>): void {
    this.config = { ...this.config, ...config };
    console.info('[CpuOptimizer] 更新配置:', JSON.stringify(this.config));
  }
  
  /**
   * 获取当前配置
   */
  public getConfig(): CpuOptimizerConfig {
    return { ...this.config };
  }
  
  // ==================== 私有方法 ====================
  
  /**
   * 生成任务ID
   */
  private generateId(): string {
    return `task_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }
  
  /**
   * 执行下一个任务
   */
  private async executeNextTask(): Promise<void> {
    if (this.taskQueue.length === 0) {
      return;
    }
    
    // 检查CPU使用率
    const cpuUsage = await this.getCpuUsage();
    
    if (cpuUsage > this.config.maxCpuUsage) {
      console.warn(`[CpuOptimizer] CPU使用率过高 (${cpuUsage.toFixed(2)}%)，延迟执行任务`);
      // 延迟执行
      setTimeout(() => this.executeNextTask(), 100);
      return;
    }
    
    // 取出任务
    const task = this.taskQueue.shift();
    
    if (!task) {
      return;
    }
    
    this.executingTasks++;
    
    try {
      console.debug(`[CpuOptimizer] 执行任务: ${task.name}`);
      await task.execute();
      this.stats.completedTasks++;
    } catch (error) {
      console.error(`[CpuOptimizer] 任务执行失败: ${task.name}`, error);
    } finally {
      this.executingTasks--;
      
      // 继续执行下一个任务
      if (this.taskQueue.length > 0) {
        // 使用requestIdleCallback在空闲时执行
        this.scheduleIdleTask(() => this.executeNextTask());
      }
    }
  }
  
  /**
   * 调度空闲任务
   */
  private scheduleIdleTask(callback: () => void): void {
    // 使用setTimeout模拟requestIdleCallback
    setTimeout(callback, 0);
  }
  
  /**
   * 启动监控
   */
  private startMonitoring(): void {
    setInterval(async () => {
      await this.getCpuUsage();
    }, 5000); // 每5秒检查一次
  }
  
  /**
   * 更新统计信息
   */
  private updateStats(usage: number): void {
    // 更新峰值
    if (usage > this.stats.peakUsage) {
      this.stats.peakUsage = usage;
    }
    
    // 更新平均值
    if (this.usageHistory.length > 0) {
      const total = this.usageHistory.reduce((sum, u) => sum + u, 0);
      this.stats.avgUsage = total / this.usageHistory.length;
    }
  }
}

// 导出单例
export const cpuOptimizer = CpuOptimizer.getInstance();

// 导出便捷函数
export function debounce<T extends (...args: unknown[]) => unknown>(
  func: T,
  delay?: number
): (...args: Parameters<T>) => void {
  return cpuOptimizer.debounce(func, delay);
}

export function throttle<T extends (...args: unknown[]) => unknown>(
  func: T,
  limit?: number
): (...args: Parameters<T>) => void {
  return cpuOptimizer.throttle(func, limit);
}
