/**
 * 智慧病房设备相关接口定义
 * 包含设备信息、设备状态、设备命令等接口
 */

import { DeviceType } from './SmartWardEnums';

/**
 * 设备基本信息接口
 * 描述设备的基本属性和元数据
 */
export interface DeviceInfo {
  deviceId: string;                    // 设备唯一标识
  deviceType: DeviceType;              // 设备类型
  roomId: string;                      // 所属房间ID
  name: string;                        // 设备名称
  status: 'online' | 'offline' | 'error';  // 设备状态
  lastUpdateTime: number;              // 最后更新时间戳
  firmwareVersion?: string;            // 固件版本
  manufacturer?: string;               // 制造商
  model?: string;                      // 型号
}

/**
 * 设备属性接口
 * 描述设备的单个属性值
 */
export interface DeviceProperty {
  key: string;                         // 属性键名
  value: number | string | boolean;    // 属性值
  unit?: string;                       // 单位（如 '%'、'℃'、'度'）
  min?: number;                        // 最小值
  max?: number;                        // 最大值
  readOnly: boolean;                   // 是否只读
  updatedAt: number;                   // 属性更新时间戳
}

/**
 * 设备状态接口
 * 描述设备的实时状态和属性
 */
export interface DeviceStatus {
  deviceId: string;                    // 设备唯一标识
  deviceType: DeviceType;              // 设备类型
  deviceName: string;                  // 设备名称
  isOnline: boolean;                   // 是否在线
  batteryLevel?: number;               // 电量百分比（0-100）
  properties: Map<string, DeviceProperty>;  // 设备属性集合
  lastHeartbeat: number;               // 最后心跳时间戳
  firmwareVersion?: string;            // 固件版本
}

/**
 * 设备命令接口
 * 描述发送给设备的控制命令
 */
export interface DeviceCommand {
  deviceId: string;                    // 目标设备ID
  deviceType: DeviceType;              // 设备类型
  action: string;                      // 动作类型（如 "setBrightness"、"adjustBed"、"toggle"）
  params: Record<string, number | string | boolean>;  // 命令参数
  timestamp: number;                   // 命令发送时间戳
}

/**
 * 灯光控制参数接口
 */
export interface LightControlParams {
  brightness?: number;               // 亮度（0-100）
  colorTemp?: number;                // 色温（2700-6500K）
  isOn?: boolean;                    // 开关状态
}

/**
 * 灯光控制命令接口
 * 继承自DeviceCommand，专门用于灯光控制
 */
export interface LightCommand extends DeviceCommand {
  deviceType: DeviceType.SMART_LIGHT;
  action: 'setBrightness' | 'setColorTemp' | 'toggle';
  params: LightControlParams;
}

/**
 * 病床控制参数接口
 */
export interface BedControlParams {
  headAngle?: number;                // 头侧角度（0-90度）
  footAngle?: number;                // 脚侧角度（0-45度）
  turnOver?: boolean;                // 是否翻身
  callBell?: boolean;                // 是否按铃
}

/**
 * 病床控制命令接口
 * 继承自DeviceCommand，专门用于病床控制
 */
export interface BedCommand extends DeviceCommand {
  deviceType: DeviceType.HOSPITAL_BED;
  action: 'adjustHeadAngle' | 'adjustFootAngle' | 'turnOver' | 'callBell';
  params: BedControlParams;
}

/**
 * 监护仪数据接口
 * 描述患者监护仪采集的生命体征数据
 */
export interface MonitorData {
  heartRate: number;                   // 心率（bpm）
  oxygenSaturation: number;            // 血氧饱和度（%）
  systolicBP: number;                  // 收缩压（mmHg）
  diastolicBP: number;                 // 舒张压（mmHg）
  temperature: number;                 // 体温（℃）
  respiratoryRate: number;             // 呼吸频率（次/分钟）
  timestamp: number;                   // 采集时间戳
}

/**
 * 窗帘控制参数接口
 */
export interface CurtainControlParams {
  openPercentage?: number;           // 开合度（0-100）
  isOn?: boolean;                    // 开关状态
}

/**
 * 窗帘控制命令接口
 */
export interface CurtainCommand extends DeviceCommand {
  deviceType: DeviceType.SMART_CURTAIN;
  action: 'setOpenPercentage' | 'toggle';
  params: CurtainControlParams;
}

/**
 * 电视控制参数接口
 */
export interface TVControlParams {
  volume?: number;                   // 音量（0-100）
  channel?: number;                  // 频道
  isOn?: boolean;                    // 开关状态
  isMuted?: boolean;                 // 是否静音
}

/**
 * 电视控制命令接口
 */
export interface TVCommand extends DeviceCommand {
  deviceType: DeviceType.SMART_TV;
  action: 'setVolume' | 'setChannel' | 'toggle' | 'mute';
  params: TVControlParams;
}

/**
 * 空调控制参数接口
 */
export interface ACControlParams {
  temperature?: number;              // 温度（16-30℃）
  mode?: 'cool' | 'heat' | 'auto' | 'fan';  // 模式
  isOn?: boolean;                    // 开关状态
}

/**
 * 空调控制命令接口
 */
export interface ACCommand extends DeviceCommand {
  deviceType: DeviceType.AIR_CONDITIONER;
  action: 'setTemperature' | 'setMode' | 'toggle';
  params: ACControlParams;
}

/**
 * 呼叫按钮控制参数接口
 */
export interface CallButtonControlParams {
  isPressed?: boolean;               // 是否按下
}

/**
 * 呼叫按钮命令接口
 */
export interface CallButtonCommand extends DeviceCommand {
  deviceType: DeviceType.CALL_BUTTON;
  action: 'press' | 'reset';
  params: CallButtonControlParams;
}

/**
 * 输液泵控制参数接口
 */
export interface InfusionPumpControlParams {
  flowRate?: number;                 // 滴速（ml/h）
  isPaused?: boolean;                // 是否暂停
}

/**
 * 输液泵控制命令接口
 */
export interface InfusionPumpCommand extends DeviceCommand {
  deviceType: DeviceType.INFUSION_PUMP;
  action: 'setFlowRate' | 'pause' | 'resume';
  params: InfusionPumpControlParams;
}
