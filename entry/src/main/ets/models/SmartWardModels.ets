/**
 * 智慧病房核心数据模型
 * 包含病房、患者信息、环境数据等核心接口
 */

import { PatientRiskLevel } from './SmartWardEnums';
import { DeviceStatus } from './SmartWardDeviceModels';

/**
 * 环境数据接口
 * 描述病房的环境参数
 */
export interface EnvironmentData {
  temperature: number;                 // 室温（℃）
  humidity: number;                    // 湿度（%）
  lightLevel: number;                  // 光照强度（lux）
  noiseLevel: number;                  // 噪音（分贝）
  airQuality: number;                  // 空气质量指数（AQI）
  updatedAt: number;                   // 更新时间戳
}

/**
 * 患者信息接口
 * 描述病房内患者的基本信息
 */
export interface WardPatientInfo {
  patientId: string;                   // 患者唯一ID
  name: string;                        // 患者姓名（脱敏显示）
  age: number;                         // 年龄
  gender: 'male' | 'female' | 'other'; // 性别
  admissionDate: number;               // 入院时间戳
  diagnosis: string;                   // 诊断
  attendingDoctor: string;             // 主治医生
  nurseName: string;                   // 责任护士
  riskLevel: PatientRiskLevel;         // 风险等级
  allergies: string[];                 // 过敏史
  dietRequirement: string;             // 饮食要求
  emergencyContact: string;            // 紧急联系人
  notes?: string;                      // 备注
}

/**
 * 智慧病房接口
 * 描述病房的完整信息，包含患者、设备、环境等所有数据
 */
export interface SmartWardRoom {
  roomId: string;                      // 房间唯一ID
  roomNumber: string;                  // 房间号（如"301"）
  bedId: string;                       // 床位ID
  patientInfo: WardPatientInfo;        // 患者信息
  devices: Map<string, DeviceStatus>;  // 设备状态集合（设备ID→状态）
  environmentData: EnvironmentData;    // 环境数据
  lastUpdated: number;                 // 最后更新时间戳
}

/**
 * 患者生命体征接口
 */
export interface PatientVitalSigns {
  heartRate: number;
  oxygenSaturation: number;
  systolicBP: number;
  diastolicBP: number;
}

/**
 * 病房概览信息接口
 * 用于护士站大屏展示的简化病房信息
 */
export interface WardOverviewInfo {
  roomId: string;
  roomNumber: string;
  bedId: string;
  patientName: string;                 // 脱敏姓名
  patientAge: number;
  patientGender: 'male' | 'female' | 'other';
  riskLevel: PatientRiskLevel;
  vitalSigns: PatientVitalSigns;
  deviceOnlineCount: number;           // 在线设备数量
  deviceTotalCount: number;            // 设备总数
  lastAlertMessage?: string;           // 最近告警消息
  lastAlertTime?: number;              // 最近告警时间
}
