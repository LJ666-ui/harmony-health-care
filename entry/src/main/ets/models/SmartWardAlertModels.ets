/**
 * 智慧病房告警相关接口定义
 * 包含告警记录、告警快照等接口
 */

import { AlertLevel, AlertCategory } from './SmartWardEnums';

/**
 * 血压数据接口
 */
export interface BloodPressure {
  systolic: number;                  // 收缩压（mmHg）
  diastolic: number;                 // 舒张压（mmHg）
}

/**
 * 生命体征快照接口
 * 描述告警触发时的生命体征数据
 */
export interface VitalSignSnapshot {
  heartRate: number;                   // 心率（bpm）
  bloodPressure: BloodPressure;        // 血压
  bloodOxygen: number;                 // 血氧饱和度（%）
  temperature: number;                 // 体温（℃）
  respiratoryRate: number;             // 呼吸频率（次/分钟）
  recordedAt: number;                  // 记录时间戳
}

/**
 * 告警记录接口
 * 描述告警事件的完整信息
 */
export interface WardAlert {
  alertId: string;                     // 告警唯一ID
  level: AlertLevel;                   // 告警等级
  category: AlertCategory;             // 告警类别
  message: string;                     // 告警消息
  roomId: string;                      // 房间ID
  roomNumber: string;                  // 房间号
  sourceDeviceId?: string;             // 触发设备ID
  vitalSigns?: VitalSignSnapshot;      // 生命体征快照
  triggeredAt: number;                 // 触发时间戳
  acknowledgedAt?: number | null;      // 确认时间戳
  acknowledgedBy?: string | null;      // 确认人
  resolvedAt?: number | null;          // 解决时间戳
  resolvedBy?: string | null;          // 解决人
  resolutionNote?: string | null;      // 解决说明
  isAcknowledged: boolean;             // 是否已确认
  isResolved: boolean;                 // 是否已解决
}

/**
 * 告警统计信息接口
 */
export interface AlertStatistics {
  totalAlerts: number;                 // 总告警数
  emergencyCount: number;              // 急救告警数
  urgentCount: number;                 // 紧急告警数
  warningCount: number;                // 警告告警数
  infoCount: number;                   // 信息告警数
  unacknowledgedCount: number;         // 未确认告警数
  unresolvedCount: number;             // 未解决告警数
}

export interface ExtendedWardAlert {
  alertId: string;
  deviceId: string;
  deviceName: string;
  category: AlertCategory;
  level: AlertLevel;
  title: string;
  message: string;
  timestamp: number;
  status: 'ACTIVE' | 'IN_PROGRESS' | 'ACKNOWLEDGED' | 'RESOLVED' | 'CLOSED';
  acknowledgedBy?: string | null;
  acknowledgedAt?: number | null;
  resolvedAt?: number | null;
  resolvedBy?: string | null;
  resolutionNote?: string | null;
}
