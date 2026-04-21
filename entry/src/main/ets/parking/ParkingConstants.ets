/**
 * 停车系统常量定义
 * 
 * 包含：车位状态、车位类型、费率配置、UI颜色等
 */

// ==================== 车位状态枚举 ====================
export enum SpaceStatus {
  AVAILABLE = 'AVAILABLE',     // 空闲（绿色）
  OCCUPIED = 'OCCUPIED',       // 占用（红色）
  RESERVED = 'RESERVED'        // 预约中（黄色）
}

// ==================== 车位类型枚举 ====================
export enum SpaceType {
  NORMAL = 'NORMAL',           // 普通车位
  DISABLED = 'DISABLED',       // 无障碍车位
  ELECTRIC = 'ELECTRIC',       // 新能源车位
  CHARGING = 'CHARGING'        // 充电桩车位
}

// ==================== 数据模型接口 ====================
export interface ParkingLot {
  id: string;
  name: string;
  address: string;
  totalSpaces: number;
  availableSpaces: number;
  latitude: number;
  longitude: number;
  hourlyRate: number;
  distance: number;
}

export interface ParkingSpace {
  id: string;
  lotId: string;
  spaceNumber: string;
  status: SpaceStatus;
  type: SpaceType;
  latitude: number;
  longitude: number;
  floor: string;
}

export interface ParkingRecord {
  recordId: string;
  spaceId: string;
  spaceNumber: string;
  lotId: string;
  lotName: string;
  floor: string;
  parkingTime: string;
  note: string;
  latitude: number;
  longitude: number;
  isActive: boolean;
  photoUri: string;
  userId: string;
}

// ==================== UI颜色配置 ====================
export interface ParkingColorsType {
  AVAILABLE: string;
  OCCUPIED: string;
  RESERVED: string;
  PRIMARY: string;
  BACKGROUND: string;
  CARD_BG: string;
  TEXT_PRIMARY: string;
  TEXT_SECONDARY: string;
  TEXT_HINT: string;
}

export const ParkingColors: ParkingColorsType = {
  AVAILABLE: '#52C41A',        // 空闲 - 绿色
  OCCUPIED: '#FF4D4F',         // 占用 - 红色
  RESERVED: '#FAAD14',         // 预约 - 黄色
  PRIMARY: '#1677FF',          // 主色调 - 蓝色
  BACKGROUND: '#F5F5F5',       // 背景色
  CARD_BG: '#FFFFFF',          // 卡片背景
  TEXT_PRIMARY: '#333333',     // 主文字颜色
  TEXT_SECONDARY: '#666666',   // 次要文字颜色
  TEXT_HINT: '#999999'         // 提示文字颜色
};

// ==================== 费率配置 ====================
export interface FeeConfig {
  freeMinutes: number;          // 免费时长（分钟）
  hourlyRate: number;           // 每小时费用（元）
  dailyCap: number;             // 每日封顶（元）
  maxDays: number;              // 最大计费天数（超过后不再增加）
}

export const DEFAULT_FEE_CONFIG: FeeConfig = {
  freeMinutes: 60,              // 首小时免费
  hourlyRate: 5,                // 之后每小时5元
  dailyCap: 50,                 // 每日封顶50元
  maxDays: 7                    // 最多计费7天
};

// ==================== 预约相关常量 ====================
export const RESERVATION_TIMEOUT_MS = 15 * 60 * 1000;  // 预约超时15分钟

// ==================== 缓存过期时间 ====================
export const CACHE_EXPIRY_MS = 5 * 60 * 1000;          // 停车场数据缓存5分钟

// ==================== GPS精度配置 ====================
export const GPS_ACCURACY_THRESHOLD = 10;               // GPS精度阈值（米）

// ==================== AR导航配置 ====================
export interface ArNavigationConfigType {
  arrowColor: string;
  arrowBorderColor: string;
  arrivalThreshold: number;
  updateIntervalMs: number;
}

export const AR_NAVIGATION_CONFIG: ArNavigationConfigType = {
  arrowColor: '#FFFFFF',                            // 箭头颜色
  arrowBorderColor: '#1677FF',                      // 箭头边框颜色
  arrivalThreshold: 5,                              // 到达阈值（米）
  updateIntervalMs: 100                             // 更新间隔（毫秒）
};
