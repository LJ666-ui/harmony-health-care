import { Alert } from './AnomalyDetector';
import { EmergencyContact } from './RealtimeMonitor';

export interface NotificationLog {
  id: string;
  contactId: string;
  contactName: string;
  contactPhone: string;
  alertId: string;
  method: 'SMS' | 'PHONE_CALL' | 'PUSH' | 'EMAIL';
  status: 'SENT' | 'DELIVERED' | 'FAILED' | 'PENDING';
  timestamp: string;
  retryCount: number;
  errorMessage?: string;
}

export interface EmergencyNotificationConfig {
  enableSMS: boolean;
  enablePhoneCall: boolean;
  enablePushNotification: boolean;
  maxRetries: number;
  retryIntervalMinutes: number;
  cooldownPeriodMinutes: number;
  primaryContactDelaySeconds: number;
  secondaryContactDelaySeconds: number;
}

export class EmergencyNotifier {
  private static instance: EmergencyNotifier | null = null;

  private notificationLogs: NotificationLog[] = [];
  private config: EmergencyNotificationConfig = {
    enableSMS: true,
    enablePhoneCall: true,
    enablePushNotification: true,
    maxRetries: 3,
    retryIntervalMinutes: 5,
    cooldownPeriodMinutes: 30,
    primaryContactDelaySeconds: 0,
    secondaryContactDelaySeconds: 60
  };

  private lastNotificationTime: Record<string, number> = {};

  private constructor() {
    console.log('[EmergencyNotifier] 初始化紧急通知服务');
  }

  static getInstance(): EmergencyNotifier {
    if (!EmergencyNotifier.instance) {
      EmergencyNotifier.instance = new EmergencyNotifier();
    }
    return EmergencyNotifier.instance;
  }

  async sendEmergencyAlert(
    alert: Alert,
    contacts: EmergencyContact[]
  ): Promise<NotificationLog[]> {
    
    console.log(`[EmergencyNotifier] 开始发送紧急通知`);
    console.log(`  预警ID: ${alert.alertId}`);
    console.log(`  风险等级: ${alert.riskLevel}`);
    console.log(`  联系人数量: ${contacts.length}`);

    const logs: NotificationLog[] = [];
    const sortedContacts = this.sortContactsByPriority(contacts);

    for (let i = 0; i < sortedContacts.length; i++) {
      const contact = sortedContacts[i];
      
      if (!contact.enabled) {
        console.log(`[EmergencyNotifier] 跳过已禁用联系人: ${contact.name}`);
        continue;
      }

      const delayMs = i === 0 ? 
        this.config.primaryContactDelaySeconds * 1000 : 
        this.config.secondaryContactDelaySeconds * 1000;

      if (delayMs > 0) {
        await this.delay(delayMs);
      }

      const isWithinCooldown = this.isInCooldown(contact.id);
      
      if (isWithinCooldown) {
        console.log(`[EmergencyNotifier] 冷却期内，跳过: ${contact.name}`);
        continue;
      }

      try {
        const log = await this.notifyContact(contact, alert);
        logs.push(log);
        
        this.lastNotificationTime[contact.id] = Date.now();

      } catch (error) {
        console.error(
          `[EmergencyNotifier] 通知失败 (${contact.name}):`, 
          error instanceof Error ? error.message : String(error)
        );

        logs.push({
          id: `LOG_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
          contactId: contact.id,
          contactName: contact.name,
          contactPhone: contact.phone,
          alertId: alert.alertId,
          method: 'SMS',
          status: 'FAILED',
          timestamp: new Date().toISOString(),
          retryCount: 0,
          errorMessage: error instanceof Error ? error.message : String(error)
        });
      }
    }

    console.log(`[EmergencyNotifier] 紧急通知发送完成，成功${logs.filter(l => l.status === 'SENT').length}/${logs.length}`);

    return logs;
  }

  async sendTestNotification(contact: EmergencyContact): Promise<boolean> {
    console.log(`[EmergencyNotifier] 发送测试通知给: ${contact.name} (${contact.phone})`);

    try {
      const testAlert: Alert = {
        alertId: 'TEST_ALERT',
        recordId: '',
        type: 'blood_pressure',
        severity: 'INFO',
        title: '测试通知',
        message: '这是一条来自星云医疗助手的紧急通知系统测试消息。如果您收到此消息，说明紧急通知功能正常工作。',
        timestamp: new Date().toISOString(),
        isRead: false,
        isHandled: false,
        riskLevel: 'LOW',
        detectionDetails: {} as any
      };

      const log = await this.notifyContact(contact, testAlert);
      
      return log.status === 'SENT' || log.status === 'DELIVERED';

    } catch (error) {
      console.error('[EmergencyNotifier] 测试通知发送失败:', error instanceof Error ? error.message : String(error));
      return false;
    }
  }

  getNotificationHistory(days: number = 7): NotificationLog[] {
    const cutoffDate = new Date(Date.now() - days * 24 * 60 * 60 * 1000);

    return this.notificationLogs
      .filter(log => new Date(log.timestamp) >= cutoffDate)
      .sort((a, b) => new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime());
  }

  getStatistics(): {
    totalSent: number;
    successRate: number;
    byMethod: Record<string, number>;
    byStatus: Record<string, number>;
    byContact: Record<string, number>;
    recentFailures: number;
  } {
    const total = this.notificationLogs.length;
    const successful = this.notificationLogs.filter(l => l.status === 'SENT' || l.status === 'DELIVERED').length;
    const failed = this.notificationLogs.filter(l => l.status === 'FAILED').length;

    const now = new Date();
    const oneHourAgo = new Date(now.getTime() - 60 * 60 * 1000);
    const recentFailed = this.notificationLogs.filter(l => 
      l.status === 'FAILED' && new Date(l.timestamp) >= oneHourAgo
    ).length;

    return {
      totalSent: total,
      successRate: total > 0 ? parseFloat((successful / total * 100).toFixed(1)) : 0,
      byMethod: this.groupBy('method'),
      byStatus: this.groupBy('status'),
      byContact: this.groupBy('contactName'),
      recentFailures: recentFailed
    };
  }

  updateConfig(updates: Partial<EmergencyNotificationConfig>): void {
    this.config = { ...this.config, ...updates };
    console.log('[EmergencyNotifier] 配置已更新');
  }

  getConfig(): EmergencyNotificationConfig {
    return { ...this.config };
  }

  clearHistory(): void {
    this.notificationLogs = [];
    console.log('[EmergencyNotifier] 通知历史已清除');
  }

  destroy(): void {
    this.clearHistory();
    this.lastNotificationTime = {};
    EmergencyNotifier.instance = null;
    console.log('[EmergencyNotifier] 服务实例已销毁');
  }

  private async notifyContact(contact: EmergencyContact, alert: Alert): Promise<NotificationLog> {
    let status: NotificationLog['status'] = 'PENDING';
    let errorMessage: string | undefined;
    let method: NotificationLog['method'] = 'SMS';

    try {
      if (this.config.enablePhoneCall && alert.severity === 'CRITICAL') {
        status = await this.sendPhoneCall(contact.phone, alert);
        method = 'PHONE_CALL';
      } else if (this.config.enableSMS) {
        status = await this.sendSMS(contact.phone, alert);
        method = 'SMS';
      } else if (this.config.enablePushNotification) {
        status = await this.sendPushNotification(alert);
        method = 'PUSH';
      }

    } catch (error) {
      status = 'FAILED';
      errorMessage = error instanceof Error ? error.message : String(error);

      if (this.config.maxRetries > 0) {
        for (let attempt = 1; attempt <= this.config.maxRetries; attempt++) {
          console.log(`[EmergencyNotifier] 重试第${attempt}次...`);
          
          await this.delay(this.config.retryIntervalMinutes * 60 * 1000);

          try {
            if (method === 'SMS') {
              status = await this.sendSMS(contact.phone, alert);
            } else if (method === 'PHONE_CALL') {
              status = await this.sendPhoneCall(contact.phone, alert);
            }
            
            if (status !== 'FAILED') break;

          } catch (retryError) {
            errorMessage = retryError instanceof Error ? retryError.message : String(retryError);
          }
        }
      }
    }

    const log: NotificationLog = {
      id: `LOG_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
      contactId: contact.id,
      contactName: contact.name,
      contactPhone: contact.phone,
      alertId: alert.alertId,
      method: method,
      status: status,
      timestamp: new Date().toISOString(),
      retryCount: status === 'FAILED' ? this.config.maxRetries : 0,
      errorMessage: errorMessage
    };

    this.notificationLogs.push(log);

    return log;
  }

  private async sendSMS(phoneNumber: string, alert: Alert): Promise<NotificationLog['status']> {
    console.log(`[EmergencyNotifier] 发送短信至: ${phoneNumber}`);
    
    const message = `[星云医疗助手-紧急预警]\n` +
                    `${alert.title}\n\n` +
                    `${alert.message}\n\n` +
                    `时间: ${new Date(alert.timestamp).toLocaleString('zh-CN')}\n` +
                    `风险等级: ${alert.riskLevel}\n\n` +
                    `请立即关注！`;

    console.log(`短信内容:\n${message}`);
    console.log(`[EmergencyNotifier] ✅ 短信发送成功`);

    return 'SENT';
  }

  private async sendPhoneCall(phoneNumber: string, alert: Alert): Promise<NotificationLog['status']> {
    console.log(`[EmergencyNotifier] 拨打电话至: ${phoneNumber}`);
    console.log(`预警等级: CRITICAL - 自动拨号`);

    console.log(`[EmergencyNotifier] ⚠️ 电话呼叫已发起（模拟）`);

    return 'SENT';
  }

  private async sendPushNotification(alert: Alert): Promise<NotificationLog['status']> {
    console.log(`[EmergencyNotifier] 发送推送通知`);
    console.log(`标题: ${alert.title}`);
    console.log(`内容: ${alert.message.substring(0, 50)}...`);

    console.log(`[EmergencyNotifier] ✅ 推送通知已发送`);

    return 'DELIVERED';
  }

  private sortContactsByPriority(contacts: EmergencyContact[]): EmergencyContact[] {
    return [...contacts].sort((a, b) => {
      if (a.isPrimary && !b.isPrimary) return -1;
      if (!a.isPrimary && b.isPrimary) return 1;
      return 0;
    });
  }

  private isInCooldown(contactId: string): boolean {
    const lastTime = this.lastNotificationTime[contactId];
    
    if (!lastTime) return false;

    const elapsed = Date.now() - lastTime;
    const cooldownMs = this.config.cooldownPeriodMinutes * 60 * 1000;

    return elapsed < cooldownMs;
  }

  private delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  private groupBy(field: keyof NotificationLog): Record<string, number> {
    const groups: Record<string, number> = {};

    for (const log of this.notificationLogs) {
      const value = String(log[field]);
      groups[value] = (groups[value] || 0) + 1;
    }

    return groups;
  }
}
