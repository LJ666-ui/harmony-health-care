import notification from '@ohos.notification';
import { ToastUtil } from '../common/utils/ToastUtil';

export interface NotificationData {
  medicationName: string;
  dosage: string;
  scheduledTime: string;
  reminderId: number;
}

export class MedicationNotificationService {
  private static instance: MedicationNotificationService | null = null;
  private notificationIds: Map<number, number> = new Map();

  private constructor() {}

  static getInstance(): MedicationNotificationService {
    if (!MedicationNotificationService.instance) {
      MedicationNotificationService.instance = new MedicationNotificationService();
    }
    return MedicationNotificationService.instance;
  }

  async requestNotificationPermission(): Promise<boolean> {
    try {
      const result = await notification.requestEnableNotification();
      if (result) {
        console.info('[MedicationNotification] 通知权限已授权');
        return true;
      } else {
        console.warn('[MedicationNotification] 通知权限被拒绝');
        ToastUtil.showWarning('请开启通知权限以接收用药提醒');
        return false;
      }
    } catch (error) {
      console.error('[MedicationNotification] 请求通知权限失败:', error);
      return false;
    }
  }

  async scheduleNotification(
    reminderId: number,
    medicationName: string,
    dosage: string,
    scheduledTime: Date
  ): Promise<boolean> {
    try {
      const notificationId = Date.now();
      
      const notificationRequest: notification.NotificationRequest = {
        id: notificationId,
        content: {
          contentType: notification.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
          normal: {
            title: '💊 用药提醒',
            text: `该服用${medicationName}了，剂量：${dosage}`,
            additionalText: '点击查看详情'
          }
        },
        deliveryTime: scheduledTime.getTime(),
        tapDismissed: true,
        autoDeletedTime: scheduledTime.getTime() + 3600000
      };

      await notification.publish(notificationRequest);
      
      this.notificationIds.set(reminderId, notificationId);
      
      console.info(`[MedicationNotification] 通知已安排: ${medicationName}, 时间: ${scheduledTime.toLocaleString()}`);
      return true;
    } catch (error) {
      console.error('[MedicationNotification] 安排通知失败:', error);
      return false;
    }
  }

  async scheduleDailyNotifications(
    reminderId: number,
    medicationName: string,
    dosage: string,
    times: string[]
  ): Promise<boolean> {
    try {
      const now = new Date();
      const currentHours = now.getHours();
      const currentMinutes = now.getMinutes();
      const currentTotalMinutes = currentHours * 60 + currentMinutes;

      for (const timeStr of times) {
        const parts = timeStr.split(':');
        const hours = Number(parts[0]);
        const minutes = Number(parts[1]);
        const totalMinutes = hours * 60 + minutes;

        if (totalMinutes > currentTotalMinutes) {
          const scheduledTime = new Date(now);
          scheduledTime.setHours(hours, minutes, 0, 0);
          
          await this.scheduleNotification(
            reminderId,
            medicationName,
            dosage,
            scheduledTime
          );
        }
      }

      return true;
    } catch (error) {
      console.error('[MedicationNotification] 安排每日通知失败:', error);
      return false;
    }
  }

  async cancelNotification(reminderId: number): Promise<boolean> {
    try {
      const notificationId = this.notificationIds.get(reminderId);
      
      if (notificationId) {
        await notification.cancel(notificationId);
        this.notificationIds.delete(reminderId);
        console.info(`[MedicationNotification] 通知已取消: ${reminderId}`);
      }
      
      return true;
    } catch (error) {
      console.error('[MedicationNotification] 取消通知失败:', error);
      return false;
    }
  }

  async cancelAllNotifications(): Promise<boolean> {
    try {
      await notification.cancelAll();
      this.notificationIds.clear();
      console.info('[MedicationNotification] 所有通知已取消');
      return true;
    } catch (error) {
      console.error('[MedicationNotification] 取消所有通知失败:', error);
      return false;
    }
  }

  async updateNotification(
    reminderId: number,
    medicationName: string,
    dosage: string,
    newTime: Date
  ): Promise<boolean> {
    await this.cancelNotification(reminderId);
    return await this.scheduleNotification(reminderId, medicationName, dosage, newTime);
  }

  isNotificationScheduled(reminderId: number): boolean {
    return this.notificationIds.has(reminderId);
  }

  getScheduledNotificationIds(): number[] {
    return Array.from(this.notificationIds.keys());
  }
}
