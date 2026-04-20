export type ReminderType = 'MEDICATION' | 'MEASUREMENT' | 'EXERCISE' | 'APPOINTMENT' | 'CUSTOM';
export type RepeatPattern = 'ONCE' | 'DAILY' | 'WEEKLY' | 'MONTHLY';
export type PriorityType = 'LOW' | 'MEDIUM' | 'HIGH';

export interface Reminder {
  id: string;
  title: string;
  description: string;
  type: ReminderType;
  scheduledTime: string;
  repeatPattern: RepeatPattern;
  repeatDays?: number[];
  isActive: boolean;
  isCompleted: boolean;
  completedAt?: string;
  snoozedUntil?: string;
  priority: PriorityType;
  soundEnabled: boolean;
  vibrationEnabled: boolean;
  advanceNoticeMinutes: number;
  createdAt: string;
  lastTriggeredAt?: string;
}

export interface ReminderTemplate {
  id: string;
  name: string;
  category: ReminderType;
  defaultTitle: string;
  defaultDescription: string;
  suggestedTimes: string[];
  icon: string;
  color: string;
}

export interface ReminderInput {
  title: string;
  description: string;
  type: ReminderType;
  scheduledTime: string;
  repeatPattern: RepeatPattern;
  repeatDays?: number[];
  isActive?: boolean;
  priority?: PriorityType;
  soundEnabled?: boolean;
  vibrationEnabled?: boolean;
  advanceNoticeMinutes?: number;
}

export interface ReminderStatistics {
  total: number;
  active: number;
  completed: number;
  overdue: number;
  upcoming: number;
  byType: Record<string, number>;
  completionRate: number;
}

export class ReminderScheduler {
  private static instance: ReminderScheduler | null = null;

  private reminders: Reminder[] = [];
  private schedulerTimerId: number | null = null;
  private checkIntervalMs: number = 60 * 1000;

  private reminderCallbacks: ((reminder: Reminder) => void)[] = [];

  private static readonly DEFAULT_TEMPLATES: ReminderTemplate[] = [
    {
      id: 'TPL_MED_001',
      name: '服药提醒',
      category: 'MEDICATION',
      defaultTitle: '该吃药了',
      defaultDescription: '请按时服用医生开具的药物',
      suggestedTimes: ['08:00', '12:00', '18:00', '22:00'],
      icon: '💊',
      color: '#1677FF'
    },
    {
      id: 'TPL_MEAS_001',
      name: '血压测量',
      category: 'MEASUREMENT',
      defaultTitle: '测量血压',
      defaultDescription: '请记录您的血压数据（收缩压/舒张压）',
      suggestedTimes: ['07:00', '19:00'],
      icon: '🩸',
      color: '#FF4D4F'
    },
    {
      id: 'TPL_MEAS_002',
      name: '血糖测量',
      category: 'MEASUREMENT',
      defaultTitle: '测量血糖',
      defaultDescription: '请记录您的血糖值',
      suggestedTimes: ['07:30', '11:30', '17:30', '21:00'],
      icon: '🍬',
      color: '#FAAD14'
    },
    {
      id: 'TPL_EXE_001',
      name: '运动提醒',
      category: 'EXERCISE',
      defaultTitle: '运动时间到了',
      defaultDescription: '建议进行30分钟中等强度运动',
      suggestedTimes: ['09:00', '16:00'],
      icon: '🏃',
      color: '#52C41A'
    },
    {
      id: 'TPL_APT_001',
      name: '复诊预约',
      category: 'APPOINTMENT',
      defaultTitle: '复诊预约',
      defaultDescription: '别忘了按时去医院复诊',
      suggestedTimes: [],
      icon: '🏥',
      color: '#722ED1'
    }
  ];

  private constructor() {
    console.log('[ReminderScheduler] 初始化智能提醒调度器');
  }

  static getInstance(): ReminderScheduler {
    if (!ReminderScheduler.instance) {
      ReminderScheduler.instance = new ReminderScheduler();
    }
    return ReminderScheduler.instance;
  }

  startScheduler(): void {
    console.log('[ReminderScheduler] 启动调度器');

    this.schedulerTimerId = setInterval(() => {
      this.checkDueReminders();
    }, this.checkIntervalMs);

    console.log(`[ReminderScheduler] 调度器已启动，检查间隔: ${this.checkIntervalMs / 1000}秒`);
  }

  stopScheduler(): void {
    if (this.schedulerTimerId !== null) {
      clearInterval(this.schedulerTimerId);
      this.schedulerTimerId = null;
    }

    console.log('[ReminderScheduler] 调度器已停止');
  }

  addReminder(reminderData: ReminderInput): Reminder {
    const newReminder: Reminder = {
      id: `REM_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
      title: reminderData.title,
      description: reminderData.description,
      type: reminderData.type,
      scheduledTime: reminderData.scheduledTime,
      repeatPattern: reminderData.repeatPattern,
      repeatDays: reminderData.repeatDays,
      isActive: reminderData.isActive !== undefined ? reminderData.isActive : true,
      isCompleted: false,
      completedAt: undefined,
      snoozedUntil: undefined,
      priority: reminderData.priority || 'MEDIUM',
      soundEnabled: reminderData.soundEnabled !== undefined ? reminderData.soundEnabled : true,
      vibrationEnabled: reminderData.vibrationEnabled !== undefined ? reminderData.vibrationEnabled : true,
      advanceNoticeMinutes: reminderData.advanceNoticeMinutes || 15,
      createdAt: new Date().toISOString(),
      lastTriggeredAt: undefined
    };

    this.reminders.push(newReminder);

    console.log(`[ReminderScheduler] 添加提醒: ${newReminder.title}`);

    return newReminder;
  }

  removeReminder(reminderId: string): void {
    const index = this.reminders.findIndex(r => r.id === reminderId);
    
    if (index > -1) {
      const removed = this.reminders.splice(index, 1)[0];
      console.log(`[ReminderScheduler] 删除提醒: ${removed.title}`);
    }
  }

  updateReminder(reminderId: string, updates: ReminderInput): void {
    const reminder = this.reminders.find(r => r.id === reminderId);

    if (reminder) {
      if (updates.title !== undefined) reminder.title = updates.title;
      if (updates.description !== undefined) reminder.description = updates.description;
      if (updates.type !== undefined) reminder.type = updates.type;
      if (updates.scheduledTime !== undefined) reminder.scheduledTime = updates.scheduledTime;
      if (updates.repeatPattern !== undefined) reminder.repeatPattern = updates.repeatPattern;
      if (updates.repeatDays !== undefined) reminder.repeatDays = updates.repeatDays;
      if (updates.isActive !== undefined) reminder.isActive = updates.isActive;
      if (updates.priority !== undefined) reminder.priority = updates.priority;
      if (updates.soundEnabled !== undefined) reminder.soundEnabled = updates.soundEnabled;
      if (updates.vibrationEnabled !== undefined) reminder.vibrationEnabled = updates.vibrationEnabled;
      if (updates.advanceNoticeMinutes !== undefined) reminder.advanceNoticeMinutes = updates.advanceNoticeMinutes;
      console.log(`[ReminderScheduler] 更新提醒: ${reminder.title}`);
    }
  }

  completeReminder(reminderId: string): void {
    const reminder = this.reminders.find(r => r.id === reminderId);
    
    if (reminder) {
      reminder.isCompleted = true;
      reminder.completedAt = new Date().toISOString();
      
      console.log(`[ReminderScheduler] 完成提醒: ${reminder.title}`);
    }
  }

  snoozeReminder(reminderId: string, minutes: number): void {
    const reminder = this.reminders.find(r => r.id === reminderId);
    
    if (reminder) {
      const snoozeTime = new Date(Date.now() + minutes * 60 * 1000);
      reminder.snoozedUntil = snoozeTime.toISOString();
      
      console.log(`[ReminderScheduler] 延迟提醒 ${minutes} 分钟: ${reminder.title}`);
    }
  }

  toggleReminder(reminderId: string, active: boolean): void {
    const reminder = this.reminders.find(r => r.id === reminderId);
    
    if (reminder) {
      reminder.isActive = active;
      console.log(`[ReminderScheduler] 提醒${active ? '启用' : '禁用'}: ${reminder.title}`);
    }
  }

  getActiveReminders(): Reminder[] {
    return this.reminders
      .filter(r => r.isActive && !r.isCompleted)
      .sort((a, b) => new Date(a.scheduledTime).getTime() - new Date(b.scheduledTime).getTime());
  }

  getTodayReminders(): Reminder[] {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    return this.getActiveReminders().filter(r => {
      const scheduledDate = new Date(r.scheduledTime);
      return scheduledDate >= today && 
             scheduledDate < new Date(today.getTime() + 24 * 60 * 60 * 1000);
    });
  }

  getOverdueReminders(): Reminder[] {
    const now = new Date();

    return this.getActiveReminders().filter(r => {
      if (r.isCompleted || r.snoozedUntil) return false;
      
      const snoozeTime = r.snoozedUntil ? new Date(r.snoozedUntil) : now;
      return new Date(r.scheduledTime) < now && new Date(r.scheduledTime) <= snoozeTime;
    });
  }

  getUpcomingReminders(hours: number = 2): Reminder[] {
    const now = new Date();
    const future = new Date(now.getTime() + hours * 60 * 60 * 1000);

    return this.getActiveReminders().filter(r => {
      if (r.isCompleted || r.snoozedUntil) return false;
      
      const scheduledDate = new Date(r.scheduledTime);
      return scheduledDate > now && scheduledDate <= future;
    }).sort((a, b) => new Date(a.scheduledTime).getTime() - new Date(b.scheduledTime).getTime());
  }

  getRemindersByType(type: ReminderType): Reminder[] {
    return this.reminders.filter(r => r.type === type);
  }

  subscribeToReminders(callback: (reminder: Reminder) => void): void {
    this.reminderCallbacks.push(callback);
    console.log(`[ReminderScheduler] 新的提醒订阅者，当前共${this.reminderCallbacks.length}个`);
  }

  unsubscribeFromReminders(callback: (reminder: Reminder) => void): void {
    const index = this.reminderCallbacks.indexOf(callback);
    
    if (index > -1) {
      this.reminderCallbacks.splice(index, 1);
    }
  }

  getTemplates(): ReminderTemplate[] {
    const result: ReminderTemplate[] = [];
    for (let i = 0; i < ReminderScheduler.DEFAULT_TEMPLATES.length; i++) {
      result.push(ReminderScheduler.DEFAULT_TEMPLATES[i]);
    }
    return result;
  }

  createReminderFromTemplate(templateId: string, scheduledTime: string): Reminder | null {
    const template = ReminderScheduler.DEFAULT_TEMPLATES.find(t => t.id === templateId);

    if (!template) {
      console.error(`[ReminderScheduler] 模板未找到: ${templateId}`);
      return null;
    }

    const reminderData: ReminderInput = {
      title: template.defaultTitle,
      description: template.defaultDescription,
      type: template.category,
      scheduledTime: scheduledTime,
      repeatPattern: 'DAILY',
      isActive: true,
      priority: 'MEDIUM',
      soundEnabled: true,
      vibrationEnabled: true,
      advanceNoticeMinutes: 5
    };
    return this.addReminder(reminderData);
  }

  getNextScheduledTime(reminder: Reminder): Date | null {
    if (!reminder.isActive || reminder.isCompleted) return null;

    let scheduledDate = new Date(reminder.scheduledTime);

    if (scheduledDate < new Date()) {
      switch (reminder.repeatPattern) {
        case 'DAILY':
          scheduledDate.setDate(scheduledDate.getDate() + 1);
          break;
        
        case 'WEEKLY':
          if (reminder.repeatDays && reminder.repeatDays.length > 0) {
            do {
              scheduledDate.setDate(scheduledDate.getDate() + 1);
            } while (!reminder.repeatDays.includes(scheduledDate.getDay()));
          } else {
            scheduledDate.setDate(scheduledDate.getDate() + 7);
          }
          break;
        
        case 'MONTHLY':
          scheduledDate.setMonth(scheduledDate.getMonth() + 1);
          break;
        
        case 'ONCE':
          return null;
      }
    }

    return scheduledDate;
  }

  getStatistics(): ReminderStatistics {
    const today = new Date();
    today.setHours(23, 59, 59, 999);

    const todayReminders = this.reminders.filter(r => {
      const scheduledDate = new Date(r.scheduledTime);
      return scheduledDate <= today;
    });

    const completedToday = todayReminders.filter(r => r.isCompleted).length;

    const stats: ReminderStatistics = {
      total: this.reminders.length,
      active: this.getActiveReminders().length,
      completed: this.reminders.filter(r => r.isCompleted).length,
      overdue: this.getOverdueReminders().length,
      upcoming: this.getUpcomingReminders(24).length,
      byType: this.groupByType(),
      completionRate: todayReminders.length > 0 ?
        parseFloat((completedToday / todayReminders.length * 100).toFixed(1)) : 0
    };
    return stats;
  }

  clearAllReminders(): void {
    this.reminders = [];
    console.log('[ReminderScheduler] 所有提醒已清除');
  }

  destroy(): void {
    this.stopScheduler();
    this.clearAllReminders();
    this.reminderCallbacks = [];
    ReminderScheduler.instance = null;
    console.log('[ReminderScheduler] 调度器实例已销毁');
  }

  private checkDueReminders(): void {
    const now = new Date();

    for (const reminder of this.getActiveReminders()) {
      if (reminder.isCompleted) continue;

      const snoozeTime = reminder.snoozedUntil ? new Date(reminder.snoozedUntil) : null;
      
      if (snoozeTime && now < snoozeTime) continue;

      const scheduledTime = new Date(reminder.scheduledTime);
      const timeDiff = scheduledTime.getTime() - now.getTime();
      const advanceNoticeMs = reminder.advanceNoticeMinutes * 60 * 1000;

      if (timeDiff <= 0 && timeDiff >= -advanceNoticeMs) {
        this.triggerReminder(reminder);
      } else if (timeDiff > 0 && timeDiff <= advanceNoticeMs) {
        this.triggerAdvanceNotice(reminder);
      }
    }
  }

  private triggerReminder(reminder: Reminder): void {
    console.log(`[ReminderScheduler] 触发提醒: ${reminder.title}`);
    console.log(`  类型: ${reminder.type}`);
    console.log(`  优先级: ${reminder.priority}`);

    for (const callback of this.reminderCallbacks) {
      try {
        callback(reminder);
      } catch (error) {
        console.error('[ReminderScheduler] 回调执行失败:', error instanceof Error ? error.message : String(error));
      }
    }

    reminder.lastTriggeredAt = new Date().toISOString();
  }

  private triggerAdvanceNotice(reminder: Reminder): void {
    console.log(`[ReminderScheduler] 提前通知: ${reminder.title} (${reminder.advanceNoticeMinutes}分钟后)`);

    for (const callback of this.reminderCallbacks) {
      try {
        const advanceReminder: Reminder = {
          id: reminder.id,
          title: `[即将开始] ${reminder.title}`,
          description: `${reminder.description}\n\n⏰ 还有${reminder.advanceNoticeMinutes}分钟`,
          type: reminder.type,
          scheduledTime: reminder.scheduledTime,
          repeatPattern: reminder.repeatPattern,
          repeatDays: reminder.repeatDays,
          isActive: reminder.isActive,
          isCompleted: reminder.isCompleted,
          completedAt: reminder.completedAt,
          snoozedUntil: reminder.snoozedUntil,
          priority: reminder.priority,
          soundEnabled: reminder.soundEnabled,
          vibrationEnabled: reminder.vibrationEnabled,
          advanceNoticeMinutes: reminder.advanceNoticeMinutes,
          createdAt: reminder.createdAt,
          lastTriggeredAt: reminder.lastTriggeredAt
        };
        callback(advanceReminder);
      } catch (error) {
        console.error('[ReminderScheduler] 提前通知回调失败:', error instanceof Error ? error.message : String(error));
      }
    }
  }

  private groupByType(): Record<string, number> {
    const groups: Record<string, number> = {};

    for (const reminder of this.reminders) {
      groups[reminder.type] = (groups[reminder.type] || 0) + 1;
    }

    return groups;
  }
}
