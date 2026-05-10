import backgroundTaskManager from '@ohos.backgroundTaskManager';
import { MedicationService, MedicationPlan } from './MedicationService';
import { MedicationNotificationService } from './MedicationNotificationService';
import { ToastUtil } from '../common/utils/ToastUtil';

export class MedicationBackgroundTask {
  private static instance: MedicationBackgroundTask | null = null;
  private taskId: string = '';
  private checkInterval: number = 60000;
  private intervalId: number = 0;
  private isRunning: boolean = false;
  private userId: number = 0;

  private constructor() {}

  static getInstance(): MedicationBackgroundTask {
    if (!MedicationBackgroundTask.instance) {
      MedicationBackgroundTask.instance = new MedicationBackgroundTask();
    }
    return MedicationBackgroundTask.instance;
  }

  async startBackgroundTask(userId: number): Promise<boolean> {
    if (this.isRunning) {
      console.warn('[MedicationBackgroundTask] 后台任务已在运行');
      return true;
    }

    this.userId = userId;

    try {
      this.taskId = await backgroundTaskManager.requestSuspendDelay('medication-reminder');
      console.info(`[MedicationBackgroundTask] 后台任务已启动: ${this.taskId}`);

      this.isRunning = true;

      this.intervalId = setInterval(() => {
        this.checkMedicationReminders();
      }, this.checkInterval);

      await this.checkMedicationReminders();

      return true;
    } catch (error) {
      console.error('[MedicationBackgroundTask] 启动后台任务失败:', error);
      ToastUtil.showError('后台任务启动失败，用药提醒可能不准确');
      return false;
    }
  }

  stopBackgroundTask(): void {
    if (!this.isRunning) {
      return;
    }

    try {
      if (this.intervalId) {
        clearInterval(this.intervalId);
        this.intervalId = 0;
      }

      if (this.taskId) {
        backgroundTaskManager.cancelSuspendDelay(this.taskId);
        this.taskId = '';
      }

      this.isRunning = false;
      console.info('[MedicationBackgroundTask] 后台任务已停止');
    } catch (error) {
      console.error('[MedicationBackgroundTask] 停止后台任务失败:', error);
    }
  }

  private async checkMedicationReminders(): Promise<void> {
    try {
      const medicationService = MedicationService.getInstance();
      const plans = await medicationService.getMedicationPlans(this.userId);

      const now = new Date();
      const currentHours = now.getHours();
      const currentMinutes = now.getMinutes();
      const currentTimeStr = `${currentHours.toString().padStart(2, '0')}:${currentMinutes.toString().padStart(2, '0')}`;

      for (const plan of plans) {
        if (!plan.reminderEnabled || plan.status !== 'active') {
          continue;
        }

        for (const time of plan.times) {
          if (this.shouldTriggerReminder(time, currentTimeStr, now)) {
            await this.triggerReminder(plan, time);
          }
        }
      }
    } catch (error) {
      console.error('[MedicationBackgroundTask] 检查用药提醒失败:', error);
    }
  }

  private shouldTriggerReminder(scheduledTime: string, currentTime: string, now: Date): boolean {
    const scheduledParts = scheduledTime.split(':');
    const scheduledHours = Number(scheduledParts[0]);
    const scheduledMinutes = Number(scheduledParts[1]);
    
    const currentParts = currentTime.split(':');
    const currentHours = Number(currentParts[0]);
    const currentMinutes = Number(currentParts[1]);

    const scheduledTotal = scheduledHours * 60 + scheduledMinutes;
    const currentTotal = currentHours * 60 + currentMinutes;

    const diff = Math.abs(currentTotal - scheduledTotal);

    return diff <= 1;
  }

  private async triggerReminder(plan: MedicationPlan, time: string): Promise<void> {
    try {
      const notificationService = MedicationNotificationService.getInstance();
      
      await notificationService.scheduleNotification(
        plan.id,
        plan.medicationName,
        plan.dosage,
        new Date()
      );

      console.info(`[MedicationBackgroundTask] 用药提醒已触发: ${plan.medicationName} - ${time}`);
    } catch (error) {
      console.error('[MedicationBackgroundTask] 触发提醒失败:', error);
    }
  }

  isTaskRunning(): boolean {
    return this.isRunning;
  }

  getTaskId(): string {
    return this.taskId;
  }

  setCheckInterval(interval: number): void {
    this.checkInterval = interval;
    
    if (this.isRunning) {
      clearInterval(this.intervalId);
      this.intervalId = setInterval(() => {
        this.checkMedicationReminders();
      }, this.checkInterval);
    }
  }
}
