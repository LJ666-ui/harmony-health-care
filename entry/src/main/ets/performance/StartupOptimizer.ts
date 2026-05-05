/**
 * 启动性能优化器
 * 管理延迟加载和预加载任务，优化应用启动性能
 * 
 * @author AI Assistant
 * @date 2026-04-27
 */

import { performanceMonitor, MetricType } from './PerformanceMonitor';

/**
 * 延迟加载任务接口
 */
export interface LazyLoadTask {
  id: string;                    // 任务ID
  name: string;                  // 任务名称
  priority: number;              // 优先级（数字越小优先级越高）
  execute: () => Promise<void>;  // 执行函数
  timeout?: number;              // 超时时间（毫秒）
  retryCount?: number;           // 重试次数
}

/**
 * 预加载任务接口
 */
export interface PreloadTask {
  id: string;                    // 任务ID
  name: string;                  // 任务名称
  execute: () => Promise<void>;  // 执行函数
  timeout?: number;              // 超时时间（毫秒）
  critical?: boolean;            // 是否为关键任务
}

/**
 * 任务执行结果
 */
export interface TaskResult {
  taskId: string;
  taskName: string;
  success: boolean;
  duration: number;
  error?: string;
}

/**
 * 启动优化器配置
 */
export interface StartupOptimizerConfig {
  enablePreload: boolean;        // 是否启用预加载
  enableLazyLoad: boolean;       // 是否启用延迟加载
  preloadTimeout: number;        // 预加载超时（毫秒）
  lazyLoadDelay: number;         // 延迟加载延迟（毫秒）
  maxConcurrentPreload: number;  // 最大并发预加载数
}

/**
 * 启动性能优化器
 */
export class StartupOptimizer {
  private static instance: StartupOptimizer | null = null;
  
  // 配置
  private config: StartupOptimizerConfig = {
    enablePreload: true,
    enableLazyLoad: true,
    preloadTimeout: 800,
    lazyLoadDelay: 1000,
    maxConcurrentPreload: 5
  };
  
  // 预加载任务队列
  private preloadTasks: PreloadTask[] = [];
  
  // 延迟加载任务队列（按优先级排序）
  private lazyLoadTasks: LazyLoadTask[] = [];
  
  // 任务执行结果
  private taskResults: TaskResult[] = [];
  
  // 启动时间记录
  private startupBeginTime: number = 0;
  private startupEndTime: number = 0;
  
  // 状态标记
  private isPreloading: boolean = false;
  private isLazyLoading: boolean = false;
  
  // 私有构造函数（单例模式）
  private constructor() {
    console.info('[StartupOptimizer] 初始化启动优化器');
  }
  
  /**
   * 获取单例实例
   */
  public static getInstance(): StartupOptimizer {
    if (!StartupOptimizer.instance) {
      StartupOptimizer.instance = new StartupOptimizer();
    }
    return StartupOptimizer.instance;
  }
  
  /**
   * 标记启动开始
   */
  public markStartupBegin(): void {
    this.startupBeginTime = Date.now();
    console.info(`[StartupOptimizer] 启动开始: ${this.startupBeginTime}`);
  }
  
  /**
   * 标记启动结束
   */
  public markStartupEnd(): void {
    this.startupEndTime = Date.now();
    const duration = this.startupEndTime - this.startupBeginTime;
    
    console.info(`[StartupOptimizer] 启动结束: ${this.startupEndTime}, 耗时: ${duration}ms`);
    
    // 记录启动时间
    performanceMonitor.recordStartupTime(duration);
  }
  
  /**
   * 获取启动耗时
   */
  public getStartupDuration(): number {
    if (this.startupEndTime === 0) {
      return Date.now() - this.startupBeginTime;
    }
    return this.startupEndTime - this.startupBeginTime;
  }
  
  /**
   * 注册预加载任务
   * @param task 预加载任务
   */
  public registerPreloadTask(task: PreloadTask): void {
    this.preloadTasks.push(task);
    console.info(`[StartupOptimizer] 注册预加载任务: ${task.name}`);
  }
  
  /**
   * 批量注册预加载任务
   * @param tasks 预加载任务数组
   */
  public registerPreloadTasks(tasks: PreloadTask[]): void {
    tasks.forEach(task => this.registerPreloadTask(task));
  }
  
  /**
   * 注册延迟加载任务
   * @param task 延迟加载任务
   */
  public registerLazyLoadTask(task: LazyLoadTask): void {
    this.lazyLoadTasks.push(task);
    // 按优先级排序
    this.lazyLoadTasks.sort((a, b) => a.priority - b.priority);
    console.info(`[StartupOptimizer] 注册延迟加载任务: ${task.name}, 优先级: ${task.priority}`);
  }
  
  /**
   * 批量注册延迟加载任务
   * @param tasks 延迟加载任务数组
   */
  public registerLazyLoadTasks(tasks: LazyLoadTask[]): void {
    tasks.forEach(task => this.registerLazyLoadTask(task));
  }
  
  /**
   * 执行预加载
   */
  public async executePreload(): Promise<TaskResult[]> {
    if (!this.config.enablePreload) {
      console.info('[StartupOptimizer] 预加载已禁用');
      return [];
    }
    
    if (this.isPreloading) {
      console.warn('[StartupOptimizer] 预加载正在进行中');
      return [];
    }
    
    this.isPreloading = true;
    console.info(`[StartupOptimizer] 开始预加载 ${this.preloadTasks.length} 个任务`);
    
    const results: TaskResult[] = [];
    
    try {
      // 分离关键任务和普通任务
      const criticalTasks = this.preloadTasks.filter(t => t.critical);
      const normalTasks = this.preloadTasks.filter(t => !t.critical);
      
      // 先执行关键任务（并行）
      if (criticalTasks.length > 0) {
        const criticalResults = await this.executeTasksParallel(criticalTasks, '预加载-关键任务');
        results.push(...criticalResults);
      }
      
      // 再执行普通任务（并发控制）
      if (normalTasks.length > 0) {
        const normalResults = await this.executeTasksWithConcurrency(
          normalTasks,
          this.config.maxConcurrentPreload,
          '预加载-普通任务'
        );
        results.push(...normalResults);
      }
      
      this.taskResults.push(...results);
      
      console.info(`[StartupOptimizer] 预加载完成: ${results.filter(r => r.success).length}/${results.length} 成功`);
    } catch (error) {
      console.error('[StartupOptimizer] 预加载失败:', error);
    } finally {
      this.isPreloading = false;
    }
    
    return results;
  }
  
  /**
   * 执行延迟加载
   */
  public async executeLazyLoad(): Promise<TaskResult[]> {
    if (!this.config.enableLazyLoad) {
      console.info('[StartupOptimizer] 延迟加载已禁用');
      return [];
    }
    
    if (this.isLazyLoading) {
      console.warn('[StartupOptimizer] 延迟加载正在进行中');
      return [];
    }
    
    // 延迟执行
    await this.delay(this.config.lazyLoadDelay);
    
    this.isLazyLoading = true;
    console.info(`[StartupOptimizer] 开始延迟加载 ${this.lazyLoadTasks.length} 个任务`);
    
    const results: TaskResult[] = [];
    
    try {
      // 按优先级顺序执行
      for (const task of this.lazyLoadTasks) {
        const result = await this.executeTask(task, '延迟加载');
        results.push(result);
        
        // 如果任务失败且需要重试
        if (!result.success && task.retryCount && task.retryCount > 0) {
          for (let i = 0; i < task.retryCount; i++) {
            console.info(`[StartupOptimizer] 重试任务 ${task.name} (${i + 1}/${task.retryCount})`);
            const retryResult = await this.executeTask(task, '延迟加载-重试');
            if (retryResult.success) {
              results.push(retryResult);
              break;
            }
          }
        }
      }
      
      this.taskResults.push(...results);
      
      console.info(`[StartupOptimizer] 延迟加载完成: ${results.filter(r => r.success).length}/${results.length} 成功`);
    } catch (error) {
      console.error('[StartupOptimizer] 延迟加载失败:', error);
    } finally {
      this.isLazyLoading = false;
    }
    
    return results;
  }
  
  /**
   * 获取任务执行结果
   */
  public getTaskResults(): TaskResult[] {
    return [...this.taskResults];
  }
  
  /**
   * 清空任务队列
   */
  public clearTasks(): void {
    this.preloadTasks = [];
    this.lazyLoadTasks = [];
    console.info('[StartupOptimizer] 清空任务队列');
  }
  
  /**
   * 更新配置
   * @param config 新配置
   */
  public updateConfig(config: Partial<StartupOptimizerConfig>): void {
    this.config = { ...this.config, ...config };
    console.info('[StartupOptimizer] 更新配置:', JSON.stringify(this.config));
  }
  
  /**
   * 获取当前配置
   */
  public getConfig(): StartupOptimizerConfig {
    return { ...this.config };
  }
  
  // ==================== 私有方法 ====================
  
  /**
   * 并行执行任务
   * @param tasks 任务数组
   * @param phase 执行阶段
   */
  private async executeTasksParallel(tasks: PreloadTask[], phase: string): Promise<TaskResult[]> {
    const promises = tasks.map(task => this.executeTask(task, phase));
    return await Promise.all(promises);
  }
  
  /**
   * 带并发控制的任务执行
   * @param tasks 任务数组
   * @param maxConcurrent 最大并发数
   * @param phase 执行阶段
   */
  private async executeTasksWithConcurrency(
    tasks: PreloadTask[],
    maxConcurrent: number,
    phase: string
  ): Promise<TaskResult[]> {
    const results: TaskResult[] = [];
    const executing: Promise<void>[] = [];
    
    for (const task of tasks) {
      const promise = this.executeTask(task, phase).then(result => {
        results.push(result);
        const index = executing.indexOf(promise);
        if (index > -1) {
          executing.splice(index, 1);
        }
      });
      
      executing.push(promise);
      
      if (executing.length >= maxConcurrent) {
        await Promise.race(executing);
      }
    }
    
    await Promise.all(executing);
    return results;
  }
  
  /**
   * 执行单个任务
   * @param task 任务
   * @param phase 执行阶段
   */
  private async executeTask(task: PreloadTask | LazyLoadTask, phase: string): Promise<TaskResult> {
    const startTime = Date.now();
    const timeout = task.timeout || this.config.preloadTimeout;
    
    try {
      // 使用Promise.race实现超时控制
      await Promise.race([
        task.execute(),
        this.createTimeoutPromise(timeout, task.name)
      ]);
      
      const duration = Date.now() - startTime;
      
      console.info(`[StartupOptimizer] [${phase}] 任务 ${task.name} 执行成功, 耗时: ${duration}ms`);
      
      return {
        taskId: task.id,
        taskName: task.name,
        success: true,
        duration
      };
    } catch (error) {
      const duration = Date.now() - startTime;
      const errorMessage = error instanceof Error ? error.message : String(error);
      
      console.error(`[StartupOptimizer] [${phase}] 任务 ${task.name} 执行失败:`, errorMessage);
      
      return {
        taskId: task.id,
        taskName: task.name,
        success: false,
        duration,
        error: errorMessage
      };
    }
  }
  
  /**
   * 创建超时Promise
   * @param timeout 超时时间
   * @param taskName 任务名称
   */
  private createTimeoutPromise(timeout: number, taskName: string): Promise<void> {
    return new Promise((_, reject) => {
      setTimeout(() => {
        reject(new Error(`任务 ${taskName} 执行超时 (${timeout}ms)`));
      }, timeout);
    });
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
export const startupOptimizer = StartupOptimizer.getInstance();
