/**
 * 时间检测机制
 * 支持定时触发联动规则
 */

import { AutomationEngine } from '../engines/AutomationEngine';
import { EventData, EventType } from '../../../models/SmartWardDataModels';

/**
 * 时间检测器单例类
 */
export class TimeChecker {
  private static instance: TimeChecker;

  // 定时器ID
  private timerId: number | null = null;

  // 检测间隔（毫秒）
  private checkInterval: number = 60000; // 1分钟

  // 上一次检查的分钟数
  private lastCheckedMinute: number = -1;

  private constructor() {
    console.log('TimeChecker initialized');
  }

  /**
   * 获取时间检测器单例实例
   */
  public static getInstance(): TimeChecker {
    if (!TimeChecker.instance) {
      TimeChecker.instance = new TimeChecker();
    }
    return TimeChecker.instance;
  }

  /**
   * 启动时间检查
   */
  public startTimeCheck(): void {
    if (this.timerId !== null) {
      console.log('TimeChecker: Already running');
      return;
    }

    this.timerId = setInterval(() => {
      this.checkTimeRules();
    }, this.checkInterval);

    console.log(`TimeChecker: Started with interval ${this.checkInterval}ms`);
  }

  /**
   * 停止时间检查
   */
  public stopTimeCheck(): void {
    if (this.timerId !== null) {
      clearInterval(this.timerId);
      this.timerId = null;
      console.log('TimeChecker: Stopped');
    }
  }

  /**
   * 检查时间规则
   */
  private checkTimeRules(): void {
    const now = new Date();
    const currentMinute = now.getHours() * 60 + now.getMinutes();

    // 避免同一分钟重复检查
    if (currentMinute === this.lastCheckedMinute) {
      return;
    }

    this.lastCheckedMinute = currentMinute;

    const currentTimeStr = `${String(now.getHours()).padStart(2, '0')}:${String(now.getMinutes()).padStart(2, '0')}`;
    console.log(`TimeChecker: Checking at ${currentTimeStr}`);

    // 构造时间到达事件
    const eventData: EventData = {
      eventType: EventType.TIME_ARRIVED,
      roomId: 'ALL',
      data: {
        time: currentTimeStr,
        hour: now.getHours(),
        minute: now.getMinutes()
      },
      timestamp: Date.now()
    };

    // 调用规则引擎检查规则
    const automationEngine = AutomationEngine.getInstance();
    automationEngine.checkRules(eventData);
  }

  /**
   * 设置检测间隔
   */
  public setCheckInterval(interval: number): void {
    this.checkInterval = interval;
    console.log(`TimeChecker: Check interval set to ${interval}ms`);
  }

  /**
   * 检查是否正在运行
   */
  public isRunning(): boolean {
    return this.timerId !== null;
  }
}
