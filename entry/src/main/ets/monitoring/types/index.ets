/**
 * 监控系统简化版类型定义
 * 符合ArkTS规范
 */

// 枚举定义
export enum HealthDataType {
  BLOOD_PRESSURE = 'BLOOD_PRESSURE',
  BLOOD_GLUCOSE = 'BLOOD_GLUCOSE',
  HEART_RATE = 'HEART_RATE',
  WEIGHT = 'WEIGHT',
  BODY_TEMPERATURE = 'BODY_TEMPERATURE'
}

export enum AlertLevel {
  NORMAL = 'NORMAL',
  ATTENTION = 'ATTENTION',
  WARNING = 'WARNING',
  DANGER = 'DANGER'
}

export enum AlertStatus {
  UNREAD = 'UNREAD',
  READ = 'READ',
  HANDLED = 'HANDLED'
}

export enum ReminderType {
  MEDICATION = 'MEDICATION',
  MEASUREMENT = 'MEASUREMENT',
  FOLLOW_UP = 'FOLLOW_UP'
}

export enum ReminderRepeat {
  NONE = 'NONE',
  DAILY = 'DAILY',
  WEEKLY = 'WEEKLY',
  MONTHLY = 'MONTHLY'
}

// 接口定义
export interface HealthRecord {
  id: string;
  type: HealthDataType;
  value: number;
  value2?: number;
  unit: string;
  timestamp: number;
  source: string;
  deviceId?: string;
  note?: string;
  userId: string;
}

export interface Alert {
  id: string;
  level: AlertLevel;
  title: string;
  description: string;
  dataType: HealthDataType;
  triggerValue: number;
  triggerValue2?: number;
  reason: string;
  timestamp: number;
  status: AlertStatus;
  userId: string;
  handledAt?: number;
  handleNote?: string;
}

export interface Reminder {
  id: string;
  type: ReminderType;
  title: string;
  content: string;
  time: string;
  repeat: ReminderRepeat;
  enabled: boolean;
  dataType?: HealthDataType;
  userId: string;
  createdAt: number;
  lastTriggeredAt?: number;
  nextTriggerAt?: number;
}

export interface EmergencyContact {
  id: string;
  name: string;
  phone: string;
  relationship: string;
  priority: number;
  userId: string;
  createdAt: number;
  lastNotifiedAt?: number;
}

export interface VitalSignsSnapshot {
  bloodPressure?: BloodPressureData;
  bloodGlucose?: BloodGlucoseData;
  heartRate?: HeartRateData;
  bodyTemperature?: BodyTemperatureData;
  weight?: WeightData;
  snapshotTime: number;
}

export interface BloodPressureData {
  systolic: number;
  diastolic: number;
  status: AlertLevel;
  timestamp: number;
}

export interface BloodGlucoseData {
  value: number;
  unit: string;
  status: AlertLevel;
  timestamp: number;
}

export interface HeartRateData {
  value: number;
  status: AlertLevel;
  timestamp: number;
}

export interface BodyTemperatureData {
  value: number;
  status: AlertLevel;
  timestamp: number;
}

export interface WeightData {
  value: number;
  status: AlertLevel;
  timestamp: number;
}
