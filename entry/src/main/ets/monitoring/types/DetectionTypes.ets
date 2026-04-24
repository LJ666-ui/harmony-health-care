/**
 * 检测结果类型定义
 * 
 * 本文件定义了异常检测算法相关的类型
 * 包括检测结果、策略结果、通用结果接口等
 * 
 * @module monitoring/types/DetectionTypes
 * @version 1.0
 * @date 2025-01-15
 */

import { AlertLevel, HealthDataType } from './HealthDataType';

/**
 * 检测策略枚举
 * 定义三种检测策略
 */
export enum DetectionStrategy {
  /** 阈值检测策略 - 基于医学标准阈值 */
  THRESHOLD = 'THRESHOLD',
  
  /** 偏移检测策略 - 基于个人基线偏移 */
  DEVIATION = 'DEVIATION',
  
  /** 趋势检测策略 - 基于连续测量趋势 */
  TREND = 'TREND'
}

/**
 * 单个检测策略的结果接口
 */
export interface DetectionStrategyResult {
  /** 使用的检测策略 */
  strategy: DetectionStrategy;
  
  /** 检测结果等级 */
  level: AlertLevel;
  
  /** 检测原因说明 */
  reason: string;
  
  /** 置信度(0-1) */
  confidence: number;
  
  /** 是否触发预警 */
  triggered: boolean;
  
  /** 详细数据(用于调试) */
  details?: Record<string, number | string>;
}

/**
 * 综合异常检测结果接口
 */
export interface AnomalyDetectionResult {
  /** 最终预警等级(取所有策略的最高等级) */
  finalLevel: AlertLevel;
  
  /** 是否检测到异常 */
  hasAnomaly: boolean;
  
  /** 所有策略的检测结果 */
  strategyResults: DetectionStrategyResult[];
  
  /** 综合描述 */
  description: string;
  
  /** 检测时间 */
  detectedAt: number;
  
  /** 关联的数据类型 */
  dataType: HealthDataType;
}

/**
 * 通用结果接口(泛型)
 * 用于统一处理成功和失败结果
 */
export interface Result<T> {
  /** 是否成功 */
  success: boolean;
  
  /** 结果数据(成功时) */
  data?: T;
  
  /** 错误信息(失败时) */
  error?: AppError;
}

/**
 * 应用错误类型枚举
 */
export enum AppErrorCode {
  /** 数据验证错误 */
  VALIDATION_ERROR = 'VALIDATION_ERROR',
  
  /** 数据库错误 */
  DATABASE_ERROR = 'DATABASE_ERROR',
  
  /** 网络错误 */
  NETWORK_ERROR = 'NETWORK_ERROR',
  
  /** 权限错误 */
  PERMISSION_ERROR = 'PERMISSION_ERROR',
  
  /** 未找到数据 */
  NOT_FOUND = 'NOT_FOUND',
  
  /** 未知错误 */
  UNKNOWN_ERROR = 'UNKNOWN_ERROR'
}

/**
 * 应用错误接口
 */
export interface AppError {
  /** 错误代码 */
  code: AppErrorCode;
  
  /** 错误消息 */
  message: string;
  
  /** 详细信息 */
  details?: string;
  
  /** 原始错误 */
  originalError?: Error;
}

/**
 * 趋势分析结果接口
 */
export interface TrendAnalysis {
  /** 趋势方向(rising:上升, falling:下降, stable:稳定) */
  direction: 'rising' | 'falling' | 'stable';
  
  /** 连续变化次数 */
  consecutive: number;
  
  /** 变化率(百分比) */
  changeRate: number;
  
  /** 趋势强度(0-1) */
  strength: number;
}

/**
 * 阈值配置接口
 */
export interface ThresholdConfig {
  /** 数据类型 */
  type: HealthDataType;
  
  /** 正常范围下限 */
  normalMin: number;
  
  /** 正常范围上限 */
  normalMax: number;
  
  /** 注意范围下限 */
  attentionMin: number;
  
  /** 注意范围上限 */
  attentionMax: number;
  
  /** 警告范围下限 */
  warningMin: number;
  
  /** 警告范围上限 */
  warningMax: number;
  
  /** 危险阈值(超过此值为危险) */
  dangerThreshold: number;
}

/**
 * 检测配置接口
 */
export interface DetectionConfig {
  /** 是否启用阈值检测 */
  enableThreshold: boolean;
  
  /** 是否启用偏移检测 */
  enableDeviation: boolean;
  
  /** 是否启用趋势检测 */
  enableTrend: boolean;
  
  /** 偏移检测的σ倍数(默认2) */
  deviationSigma: number;
  
  /** 趋势检测的最小连续次数(默认3) */
  trendMinConsecutive: number;
  
  /** 历史数据天数(用于计算基线) */
  historyDays: number;
}

/**
 * 创建成功结果的辅助函数
 */
export function success<T>(data: T): Result<T> {
  return {
    success: true,
    data
  };
}

/**
 * 创建失败结果的辅助函数
 */
export function failure<T>(error: AppError): Result<T> {
  return {
    success: false,
    error
  };
}

/**
 * 创建应用错误的辅助函数
 */
export function createError(
  code: AppErrorCode,
  message: string,
  details?: string,
  originalError?: Error
): AppError {
  return {
    code,
    message,
    details,
    originalError
  };
}
