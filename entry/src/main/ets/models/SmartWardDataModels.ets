/**
 * 智慧病房数据接口定义
 * 包含生命体征数据、事件数据等接口
 */

/**
 * 血压数据接口
 */
export interface BloodPressure {
  systolic: number;                      // 收缩压
  diastolic: number;                     // 舒张压
}

/**
 * 生命体征数据接口
 * 描述患者的生命体征数据
 */
export interface VitalSigns {
  heartRate: number;                   // 心率（bpm）
  oxygenSaturation: number;            // 血氧饱和度（%）
  bloodPressure: BloodPressure;        // 血压
  temperature: number;                 // 体温（℃）
  respiratoryRate: number;             // 呼吸频率（次/分钟）
  timestamp: number;                   // 记录时间戳
}

/**
 * 事件数据接口
 * 描述系统中的事件数据
 */
export interface EventData {
  eventType: string;                   // 事件类型
  roomId: string;                      // 房间ID
  deviceId?: string;                   // 设备ID
  data: number | boolean | object;     // 事件数据
  timestamp: number;                   // 事件时间戳
}

/**
 * 事件类型常量接口
 */
export interface EventTypeConstants {
  VITAL_SIGNS_CHANGE: string;
  CALL_BUTTON_PRESSED: string;
  INFUSION_STATUS_CHANGE: string;
  DEVICE_OFFLINE: string;
  TIME_ARRIVED: string;
  FALL_DETECTED: string;
}

/**
 * 事件类型常量
 */
export const EventType: EventTypeConstants = {
  VITAL_SIGNS_CHANGE: 'VITAL_SIGNS_CHANGE',              // 生命体征变化
  CALL_BUTTON_PRESSED: 'CALL_BUTTON_PRESSED',            // 呼叫按钮按下
  INFUSION_STATUS_CHANGE: 'INFUSION_STATUS_CHANGE',      // 输液状态变化
  DEVICE_OFFLINE: 'DEVICE_OFFLINE',                      // 设备离线
  TIME_ARRIVED: 'TIME_ARRIVED',                          // 定时到达
  FALL_DETECTED: 'FALL_DETECTED'                         // 跌倒检测
};

/**
 * 数据采集记录接口
 * 描述数据采集的记录信息
 */
export interface DataCollectionRecord {
  collectionId: string;             // 采集记录ID
  deviceId: string;                 // 设备ID
  deviceType: string;               // 设备类型
  collectedAt: number;              // 采集时间戳
  data: object | null;              // 采集的数据
  collectionDuration: number;       // 采集耗时（毫秒）
  status: 'success' | 'failed';     // 采集状态
  errorMessage?: string;            // 错误消息
}
