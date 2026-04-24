/**
 * 预警和提醒类型定义
 * 
 * 本文件定义了预警记录、提醒规则、紧急联系人等相关类型
 * 
 * @module monitoring/types/AlertTypes
 * @version 1.0
 * @date 2025-01-15
 */

import { AlertLevel, HealthDataType } from './HealthDataType';

/**
 * 预警状态枚举
 */
export enum AlertStatus {
  /** 未读 */
  UNREAD = 'UNREAD',
  
  /** 已读 */
  READ = 'READ',
  
  /** 已处理 */
  HANDLED = 'HANDLED'
}

/**
 * 预警记录接口
 * 表示一次预警事件
 */
export interface Alert {
  /** 预警唯一标识 */
  id: string;
  
  /** 预警等级 */
  level: AlertLevel;
  
  /** 预警标题 */
  title: string;
  
  /** 预警描述 */
  description: string;
  
  /** 关联的数据类型 */
  dataType: HealthDataType;
  
  /** 触发预警的数据值 */
  triggerValue: number;
  
  /** 触发预警的数据值2(血压舒张压) */
  triggerValue2?: number;
  
  /** 预警原因(详细说明) */
  reason: string;
  
  /** 预警时间(Unix时间戳,毫秒) */
  timestamp: number;
  
  /** 预警状态 */
  status: AlertStatus;
  
  /** 用户ID */
  userId: string;
  
  /** 处理时间(如果已处理) */
  handledAt?: number;
  
  /** 处理备注 */
  handleNote?: string;
}

/**
 * 预警查询参数接口
 */
export interface AlertQueryParams {
  /** 预警等级(可选) */
  level?: AlertLevel;
  
  /** 预警状态(可选) */
  status?: AlertStatus;
  
  /** 开始时间(可选) */
  startTime?: number;
  
  /** 结束时间(可选) */
  endTime?: number;
  
  /** 用户ID */
  userId: string;
  
  /** 分页偏移 */
  offset?: number;
  
  /** 分页限制 */
  limit?: number;
}

/**
 * 预警统计接口
 */
export interface AlertStatistics {
  /** 总预警数 */
  total: number;
  
  /** 未读数 */
  unread: number;
  
  /** 各等级数量 */
  byLevel: AlertLevelStatistics;
  
  /** 今日预警数 */
  today: number;
  
  /** 本周预警数 */
  thisWeek: number;
}

/**
 * 预警等级统计接口
 */
export interface AlertLevelStatistics {
  NORMAL?: number;
  ATTENTION?: number;
  WARNING?: number;
  DANGER?: number;
}

/**
 * 提醒类型枚举
 */
export enum ReminderType {
  /** 用药提醒 */
  MEDICATION = 'MEDICATION',
  
  /** 测量提醒 */
  MEASUREMENT = 'MEASUREMENT',
  
  /** 复查提醒 */
  FOLLOW_UP = 'FOLLOW_UP'
}

/**
 * 提醒重复周期枚举
 */
export enum ReminderRepeat {
  /** 单次(不重复) */
  NONE = 'NONE',
  
  /** 每天 */
  DAILY = 'DAILY',
  
  /** 每周 */
  WEEKLY = 'WEEKLY',
  
  /** 每月 */
  MONTHLY = 'MONTHLY'
}

/**
 * 提醒规则接口
 */
export interface Reminder {
  /** 提醒唯一标识 */
  id: string;
  
  /** 提醒类型 */
  type: ReminderType;
  
  /** 提醒标题 */
  title: string;
  
  /** 提醒内容 */
  content: string;
  
  /** 提醒时间(小时:分钟,如"08:30") */
  time: string;
  
  /** 重复周期 */
  repeat: ReminderRepeat;
  
  /** 是否启用 */
  enabled: boolean;
  
  /** 关联的数据类型(仅测量提醒) */
  dataType?: HealthDataType;
  
  /** 用户ID */
  userId: string;
  
  /** 创建时间 */
  createdAt: number;
  
  /** 最后触发时间 */
  lastTriggeredAt?: number;
  
  /** 下次触发时间 */
  nextTriggerAt?: number;
}

/**
 * 紧急联系人接口
 */
export interface EmergencyContact {
  /** 联系人唯一标识 */
  id: string;
  
  /** 姓名 */
  name: string;
  
  /** 电话号码 */
  phone: string;
  
  /** 与患者关系 */
  relationship: string;
  
  /** 优先级(1-3,1最高) */
  priority: number;
  
  /** 用户ID */
  userId: string;
  
  /** 创建时间 */
  createdAt: number;
  
  /** 最后通知时间 */
  lastNotifiedAt?: number;
}

/**
 * 提醒触发记录接口
 */
export interface ReminderTrigger {
  /** 记录唯一标识 */
  id: string;
  
  /** 提醒ID */
  reminderId: string;
  
  /** 触发时间 */
  triggeredAt: number;
  
  /** 是否已处理 */
  handled: boolean;
  
  /** 用户ID */
  userId: string;
}
