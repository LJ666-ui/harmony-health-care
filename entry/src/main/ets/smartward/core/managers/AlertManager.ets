/**
 * 告警管理器
 * 管理告警的创建、查询和确认
 */

import { WardAlert, AlertStatistics } from '../../../models/SmartWardAlertModels';
import { AlertLevel } from '../../../models/SmartWardEnums';

/**
 * 告警管理器单例类
 */
export class AlertManager {
  private static instance: AlertManager;

  // 告警存储
  private alerts: WardAlert[] = [];

  // 最大告警数量
  private maxAlerts: number = 100;

  // 订阅者回调集合
  private subscribers: Array<(alerts: WardAlert[]) => void> = [];

  private constructor() {
    console.log('AlertManager initialized');
  }

  /**
   * 获取告警管理器单例实例
   */
  public static getInstance(): AlertManager {
    if (!AlertManager.instance) {
      AlertManager.instance = new AlertManager();
    }
    return AlertManager.instance;
  }

  /**
   * 创建告警
   */
  public createAlert(alert: WardAlert): void {
    // 添加到数组头部
    this.alerts.unshift(alert);

    // 限制告警数量
    if (this.alerts.length > this.maxAlerts) {
      this.alerts = this.alerts.slice(0, this.maxAlerts);
    }

    console.log(`AlertManager: Alert created - ${alert.message} (${alert.level})`);

    // 通知订阅者
    this.notifySubscribers();
  }

  /**
   * 获取告警列表
   */
  public getAlerts(): WardAlert[] {
    // 按等级排序（EMERGENCY > URGENT > WARNING > INFO）
    return this.alerts.sort((a, b) => {
      const levelOrder: Record<AlertLevel, number> = {
        [AlertLevel.EMERGENCY]: 0,
        [AlertLevel.URGENT]: 1,
        [AlertLevel.WARNING]: 2,
        [AlertLevel.INFO]: 3
      };

      // 先按等级排序
      if (levelOrder[a.level] !== levelOrder[b.level]) {
        return levelOrder[a.level] - levelOrder[b.level];
      }

      // 同等级按时间倒序
      return b.triggeredAt - a.triggeredAt;
    });
  }

  /**
   * 获取未确认的告警
   */
  public getUnacknowledgedAlerts(): WardAlert[] {
    return this.alerts.filter(alert => !alert.isAcknowledged);
  }

  /**
   * 获取未解决的告警
   */
  public getUnresolvedAlerts(): WardAlert[] {
    return this.alerts.filter(alert => !alert.isResolved);
  }

  /**
   * 根据房间ID获取告警
   */
  public getAlertsByRoom(roomId: string): WardAlert[] {
    return this.alerts.filter(alert => alert.roomId === roomId);
  }

  /**
   * 确认告警
   */
  public acknowledgeAlert(alertId: string, acknowledgedBy: string): boolean {
    const alert = this.alerts.find(a => a.alertId === alertId);
    if (alert) {
      alert.isAcknowledged = true;
      alert.acknowledgedAt = Date.now();
      alert.acknowledgedBy = acknowledgedBy;

      console.log(`AlertManager: Alert acknowledged - ${alertId} by ${acknowledgedBy}`);

      // 通知订阅者
      this.notifySubscribers();

      return true;
    }

    return false;
  }

  /**
   * 解决告警
   */
  public resolveAlert(alertId: string, resolutionNote: string): boolean {
    const alert = this.alerts.find(a => a.alertId === alertId);
    if (alert) {
      alert.isResolved = true;
      alert.resolvedAt = Date.now();
      alert.resolutionNote = resolutionNote;

      console.log(`AlertManager: Alert resolved - ${alertId} with note: ${resolutionNote}`);

      // 通知订阅者
      this.notifySubscribers();

      return true;
    }

    return false;
  }

  /**
   * 获取告警统计信息
   */
  public getAlertStatistics(): AlertStatistics {
    const stats: AlertStatistics = {
      totalAlerts: this.alerts.length,
      emergencyCount: 0,
      urgentCount: 0,
      warningCount: 0,
      infoCount: 0,
      unacknowledgedCount: 0,
      unresolvedCount: 0
    };

    this.alerts.forEach(alert => {
      // 统计等级
      switch (alert.level) {
        case AlertLevel.EMERGENCY:
          stats.emergencyCount++;
          break;
        case AlertLevel.URGENT:
          stats.urgentCount++;
          break;
        case AlertLevel.WARNING:
          stats.warningCount++;
          break;
        case AlertLevel.INFO:
          stats.infoCount++;
          break;
      }

      // 统计未确认
      if (!alert.isAcknowledged) {
        stats.unacknowledgedCount++;
      }

      // 统计未解决
      if (!alert.isResolved) {
        stats.unresolvedCount++;
      }
    });

    return stats;
  }

  /**
   * 订阅告警变化
   */
  public subscribe(callback: (alerts: WardAlert[]) => void): void {
    this.subscribers.push(callback);
    console.log('AlertManager: New subscriber added');
  }

  /**
   * 取消订阅告警变化
   */
  public unsubscribe(callback: (alerts: WardAlert[]) => void): void {
    const index = this.subscribers.indexOf(callback);
    if (index > -1) {
      this.subscribers.splice(index, 1);
      console.log('AlertManager: Subscriber removed');
    }
  }

  /**
   * 通知订阅者
   */
  private notifySubscribers(): void {
    const alerts = this.getAlerts();
    this.subscribers.forEach(callback => {
      try {
        callback(alerts);
      } catch (error) {
        console.error('AlertManager: Error in subscriber callback', error);
      }
    });
  }

  /**
   * 清空所有告警
   */
  public clear(): void {
    this.alerts = [];
    this.notifySubscribers();
    console.log('AlertManager cleared');
  }

  /**
   * 删除指定告警
   */
  public deleteAlert(alertId: string): boolean {
    const index = this.alerts.findIndex(a => a.alertId === alertId);
    if (index > -1) {
      this.alerts.splice(index, 1);
      this.notifySubscribers();
      console.log(`AlertManager: Alert deleted - ${alertId}`);
      return true;
    }
    return false;
  }
}
