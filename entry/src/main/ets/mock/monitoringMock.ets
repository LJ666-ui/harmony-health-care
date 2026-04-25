/**
 * 监控系统Mock数据
 * 
 * 用于测试和演示监控功能
 * 
 * @module mock/monitoringMock
 * @version 1.0
 * @date 2025-01-15
 */

import {
  HealthRecord,
  HealthDataType,
  Alert,
  AlertLevel,
  AlertStatus,
  Reminder,
  ReminderType,
  ReminderRepeat,
  EmergencyContact
} from '../monitoring/types';

/**
 * 生成Mock健康记录
 */
export function generateMockHealthRecords(): HealthRecord[] {
  const now = Date.now();
  const records: HealthRecord[] = [];

  // 血压记录(最近7天)
  for (let i = 0; i < 7; i++) {
    records.push({
      id: `bp_${i}`,
      type: HealthDataType.BLOOD_PRESSURE,
      value: 120 + Math.random() * 20,
      value2: 75 + Math.random() * 10,
      unit: 'mmHg',
      timestamp: now - i * 24 * 60 * 60 * 1000,
      source: 'manual',
      userId: 'user_001'
    });
  }

  // 血糖记录(最近7天)
  for (let i = 0; i < 7; i++) {
    records.push({
      id: `bg_${i}`,
      type: HealthDataType.BLOOD_GLUCOSE,
      value: 5.5 + Math.random() * 1.5,
      unit: 'mmol/L',
      timestamp: now - i * 24 * 60 * 60 * 1000,
      source: 'manual',
      userId: 'user_001'
    });
  }

  // 心率记录(最近7天)
  for (let i = 0; i < 7; i++) {
    records.push({
      id: `hr_${i}`,
      type: HealthDataType.HEART_RATE,
      value: 70 + Math.random() * 15,
      unit: 'bpm',
      timestamp: now - i * 24 * 60 * 60 * 1000,
      source: 'device',
      deviceId: 'watch_001',
      userId: 'user_001'
    });
  }

  return records;
}

/**
 * 生成Mock预警记录
 */
export function generateMockAlerts(): Alert[] {
  const now = Date.now();
  
  return [
    {
      id: 'alert_001',
      level: AlertLevel.WARNING,
      title: '血压警告',
      description: '血压偏高: 收缩压145mmHg, 舒张压92mmHg, 存在高血压风险',
      dataType: HealthDataType.BLOOD_PRESSURE,
      triggerValue: 145,
      triggerValue2: 92,
      reason: '血压超过正常范围',
      timestamp: now - 2 * 60 * 60 * 1000,
      status: AlertStatus.UNREAD,
      userId: 'user_001'
    },
    {
      id: 'alert_002',
      level: AlertLevel.ATTENTION,
      title: '血糖注意',
      description: '血糖轻度偏离: 当前值6.8mmol/L, 个人均值5.8mmol/L',
      dataType: HealthDataType.BLOOD_GLUCOSE,
      triggerValue: 6.8,
      reason: '血糖略高于个人基线',
      timestamp: now - 5 * 60 * 60 * 1000,
      status: AlertStatus.READ,
      userId: 'user_001'
    },
    {
      id: 'alert_003',
      level: AlertLevel.DANGER,
      title: '心率危险',
      description: '心率严重异常: 125bpm, 需立即就医',
      dataType: HealthDataType.HEART_RATE,
      triggerValue: 125,
      reason: '心率超过危险阈值',
      timestamp: now - 24 * 60 * 60 * 1000,
      status: AlertStatus.HANDLED,
      userId: 'user_001'
    }
  ];
}

/**
 * 生成Mock提醒规则
 */
export function generateMockReminders(): Reminder[] {
  return [
    {
      id: 'reminder_001',
      type: ReminderType.MEDICATION,
      title: '服用降压药',
      content: '记得服用氨氯地平5mg',
      time: '08:00',
      repeat: ReminderRepeat.DAILY,
      enabled: true,
      userId: 'user_001',
      createdAt: Date.now() - 7 * 24 * 60 * 60 * 1000,
      nextTriggerAt: Date.now() + 2 * 60 * 60 * 1000
    },
    {
      id: 'reminder_002',
      type: ReminderType.MEASUREMENT,
      title: '测量血压',
      content: '早晚各测量一次血压',
      time: '07:30',
      repeat: ReminderRepeat.DAILY,
      enabled: true,
      dataType: HealthDataType.BLOOD_PRESSURE,
      userId: 'user_001',
      createdAt: Date.now() - 7 * 24 * 60 * 60 * 1000,
      nextTriggerAt: Date.now() + 1.5 * 60 * 60 * 1000
    },
    {
      id: 'reminder_003',
      type: ReminderType.FOLLOW_UP,
      title: '复查提醒',
      content: '下周三到医院复查',
      time: '09:00',
      repeat: ReminderRepeat.NONE,
      enabled: true,
      userId: 'user_001',
      createdAt: Date.now() - 3 * 24 * 60 * 60 * 1000,
      nextTriggerAt: Date.now() + 5 * 24 * 60 * 60 * 1000
    }
  ];
}

/**
 * 生成Mock紧急联系人
 */
export function generateMockEmergencyContacts(): EmergencyContact[] {
  return [
    {
      id: 'contact_001',
      name: '张三(儿子)',
      phone: '13800138001',
      relationship: '子女',
      priority: 1,
      userId: 'user_001',
      createdAt: Date.now() - 30 * 24 * 60 * 60 * 1000
    },
    {
      id: 'contact_002',
      name: '李四(女儿)',
      phone: '13800138002',
      relationship: '子女',
      priority: 2,
      userId: 'user_001',
      createdAt: Date.now() - 30 * 24 * 60 * 60 * 1000
    },
    {
      id: 'contact_003',
      name: '王五(配偶)',
      phone: '13800138003',
      relationship: '配偶',
      priority: 3,
      userId: 'user_001',
      createdAt: Date.now() - 30 * 24 * 60 * 60 * 1000
    }
  ];
}

/**
 * 获取最新生命体征快照(Mock)
 */
export function getMockVitalSignsSnapshot() {
  return {
    bloodPressure: {
      systolic: 135,
      diastolic: 85,
      status: AlertLevel.ATTENTION,
      timestamp: Date.now() - 30 * 60 * 1000
    },
    bloodGlucose: {
      value: 6.2,
      unit: 'mmol/L',
      status: AlertLevel.NORMAL,
      timestamp: Date.now() - 2 * 60 * 60 * 1000
    },
    heartRate: {
      value: 78,
      status: AlertLevel.NORMAL,
      timestamp: Date.now() - 10 * 60 * 1000
    },
    bodyTemperature: {
      value: 36.5,
      status: AlertLevel.NORMAL,
      timestamp: Date.now() - 60 * 60 * 1000
    },
    snapshotTime: Date.now()
  };
}
