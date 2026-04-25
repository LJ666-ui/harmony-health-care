/**
 * 健康数据类型定义
 * 
 * 本文件定义了患者实时监控系统所需的所有健康数据相关类型
 * 包括数据类型枚举、健康记录接口、生命体征快照等
 * 
 * @module monitoring/types/HealthDataType
 * @version 1.0
 * @date 2025-01-15
 */

/**
 * 健康数据类型枚举
 * 定义系统支持的5种健康数据类型
 */
export enum HealthDataType {
  /** 血压数据(收缩压/舒张压) */
  BLOOD_PRESSURE = 'BLOOD_PRESSURE',
  
  /** 血糖数据(空腹血糖/餐后血糖) */
  BLOOD_GLUCOSE = 'BLOOD_GLUCOSE',
  
  /** 心率数据(静息心率) */
  HEART_RATE = 'HEART_RATE',
  
  /** 体重数据 */
  WEIGHT = 'WEIGHT',
  
  /** 体温数据 */
  BODY_TEMPERATURE = 'BODY_TEMPERATURE'
}

/**
 * 预警等级枚举
 * 定义四级预警等级,从低到高
 */
export enum AlertLevel {
  /** 正常 - 无需关注 */
  NORMAL = 'NORMAL',
  
  /** 注意 - 轻度偏离,需关注 */
  ATTENTION = 'ATTENTION',
  
  /** 警告 - 明显异常,需重视 */
  WARNING = 'WARNING',
  
  /** 危险 - 严重异常,需立即处理 */
  DANGER = 'DANGER'
}

/**
 * 数据来源枚举
 */
export enum DataSource {
  MANUAL = 'manual',
  DEVICE = 'device'
}

/**
 * 健康数据记录接口
 * 表示单条健康数据记录
 */
export interface HealthRecord {
  /** 记录唯一标识 */
  id: string;
  
  /** 数据类型 */
  type: HealthDataType;
  
  /** 数值(对于血压,存储收缩压) */
  value: number;
  
  /** 第二数值(仅血压使用,存储舒张压) */
  value2?: number;
  
  /** 单位(如:mmHg, mmol/L, bpm, kg, °C) */
  unit: string;
  
  /** 测量时间(Unix时间戳,毫秒) */
  timestamp: number;
  
  /** 数据来源(manual:手动录入, device:设备同步) */
  source: DataSource;
  
  /** 设备ID(如果来自设备) */
  deviceId?: string;
  
  /** 备注 */
  note?: string;
  
  /** 用户ID */
  userId: string;
}

/**
 * 血压数据接口
 */
export interface BloodPressureData {
  /** 收缩压 */
  systolic: number;
  /** 舒张压 */
  diastolic: number;
  /** 状态等级 */
  status: AlertLevel;
  /** 测量时间 */
  timestamp: number;
}

/**
 * 血糖数据接口
 */
export interface BloodGlucoseData {
  /** 血糖值 */
  value: number;
  /** 单位 */
  unit: string;
  /** 状态等级 */
  status: AlertLevel;
  /** 测量时间 */
  timestamp: number;
}

/**
 * 心率数据接口
 */
export interface HeartRateData {
  /** 心率值 */
  value: number;
  /** 状态等级 */
  status: AlertLevel;
  /** 测量时间 */
  timestamp: number;
}

/**
 * 体重数据接口
 */
export interface WeightData {
  /** 体重值 */
  value: number;
  /** 状态等级 */
  status: AlertLevel;
  /** 测量时间 */
  timestamp: number;
}

/**
 * 体温数据接口
 */
export interface BodyTemperatureData {
  /** 体温值 */
  value: number;
  /** 状态等级 */
  status: AlertLevel;
  /** 测量时间 */
  timestamp: number;
}

/**
 * 生命体征快照接口
 * 表示某一时刻的所有生命体征数据
 */
export interface VitalSignsSnapshot {
  /** 血压数据 */
  bloodPressure?: BloodPressureData;
  
  /** 血糖数据 */
  bloodGlucose?: BloodGlucoseData;
  
  /** 心率数据 */
  heartRate?: HeartRateData;
  
  /** 体重数据 */
  weight?: WeightData;
  
  /** 体温数据 */
  bodyTemperature?: BodyTemperatureData;
  
  /** 快照生成时间 */
  snapshotTime: number;
}

/**
 * 健康数据统计接口
 * 用于计算个人基线统计值
 */
export interface HealthStatistics {
  /** 数据类型 */
  type: HealthDataType;
  
  /** 均值 */
  mean: number;
  
  /** 标准差 */
  stdDev: number;
  
  /** 最小值 */
  min: number;
  
  /** 最大值 */
  max: number;
  
  /** 数据点数量 */
  count: number;
  
  /** 计算时间 */
  calculatedAt: number;
}

/**
 * 健康数据查询参数接口
 */
export interface HealthQueryParams {
  /** 数据类型(可选,不指定则查询所有) */
  type?: HealthDataType;
  
  /** 开始时间(Unix时间戳,毫秒) */
  startTime?: number;
  
  /** 结束时间(Unix时间戳,毫秒) */
  endTime?: number;
  
  /** 限制数量 */
  limit?: number;
  
  /** 用户ID */
  userId: string;
}
