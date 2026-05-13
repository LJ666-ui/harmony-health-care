/**
 * 停车场模型
 */
export interface ParkingLot {
  id: string;                    // 停车场ID
  name: string;                  // 停车场名称
  address: string;               // 地址
  totalSpaces: number;           // 总车位数量
  availableSpaces: number;       // 空闲车位数量
  latitude: number;              // 纬度
  longitude: number;             // 经度
  hourlyRate: number;            // 小时费率(元)
  dailyMaxFee: number;           // 每日封顶费用(元)
  distance: number;              // 距离用户当前位置的距离(米)
  floors: number;                // 楼层数
  hasCharging: boolean;          // 是否有充电桩
  hasDisabled: boolean;          // 是否有无障碍车位
  openTime: string;              // 营业时间
}

/**
 * 车位模型
 */
export interface ParkingSpace {
  id: string;                    // 车位ID
  lotId: string;                 // 所属停车场ID
  spaceNumber: string;           // 车位号
  floor: string;                 // 楼层
  zone: string;                  // 区域
  type: 'NORMAL' | 'DISABLED' | 'ELECTRIC' | 'VIP' | 'FAST_CHARGING';  // 车位类型
  status: 'AVAILABLE' | 'OCCUPIED' | 'RESERVED';     // 车位状态
  latitude?: number;             // 纬度(可选)
  longitude?: number;            // 经度(可选)
}

/**
 * 室内位置信息模型
 */
export interface IndoorLocation {
  building: string;            // 建筑
  floor: string;               // 楼层
  nearLandmark: string;        // 附近地标
}

/**
 * 停车记录模型
 */
export interface ParkingRecord {
  recordId: string;              // 记录ID
  parkingLotId: string;          // 停车场ID
  parkingLotName: string;        // 停车场名称
  spaceId: string;               // 车位ID
  spaceNumber: string;           // 车位号
  floor: string;                 // 楼层
  zone: string;                  // 区域
  latitude: number;              // 纬度
  longitude: number;             // 经度
  accuracy: number;              // 定位精度(米)
  indoorLocation: IndoorLocation; // 室内位置信息
  photoUri: string;              // 停车照片URI
  note: string;                  // 备注
  carDescription: string;        // 车辆描述
  licensePlate: string;          // 车牌号
  parkTime: number;              // 入场时间(时间戳)
  isActive: boolean;             // 是否激活(停放中)
  currentFee: number;            // 当前费用(元)
  feeDetails: FeeDetail;         // 费用明细
}

/**
 * 费用明细模型
 */
export interface FeeDetail {
  baseFee: number;               // 基础费用(元)
  weekendDiscount: number;       // 周末折扣(元)
  capDiscount: number;           // 封顶优惠(元)
  finalFee: number;              // 最终费用(元)
}

/**
 * 导航步骤模型
 */
export interface Step {
  stepId: string;                // 步骤ID
  instruction: string;           // 指引文字
  distance: number;              // 距离(米)
  isCompleted: boolean;          // 是否已完成
}

/**
 * 位置信息模型
 */
export interface Location {
  latitude: number;              // 纬度
  longitude: number;             // 经度
}

/**
 * 导航状态枚举
 */
export enum NavigationStatus {
  IDLE = 'idle',
  NAVIGATING = 'navigating',
  PAUSED = 'paused',
  ARRIVED = 'arrived',
  ERROR = 'error'
}

/**
 * 导航模式枚举
 */
export enum NavigationMode {
  MAP = 'map',
  AR = 'ar',
  TEXT = 'text'
}

/**
 * 预约记录模型
 */
export interface Reservation {
  spaceId: string;               // 车位ID
  userId: string;                // 用户ID
  reserveTime: number;           // 预约时间(时间戳)
  expireTime: number;            // 过期时间(时间戳)
  cancellationCount: number;     // 取消次数
}

/**
 * 预约结果模型
 */
export interface ReservationResult {
  success: boolean;              // 是否成功
  spaceId: string;               // 车位ID
  expireTime: number;            // 过期时间(时间戳)
  error?: Error;                 // 错误信息
}

/**
 * 操作结果模型
 */
export interface OperationResult {
  success: boolean;              // 是否成功
  message?: string;              // 消息
  error?: Error;                 // 错误信息
}

/**
 * 导航回调模型
 */
export interface NavigationCallbacks {
  onUpdate?: (position: Location, distance: number) => void;  // 位置更新回调
  onArrival?: () => void;        // 到达回调
  onError?: (error: Error) => void;  // 错误回调
}

/**
 * 导航策略接口
 */
export interface INavigationStrategy {
  /**
   * 启动导航
   * @param start 起点坐标
   * @param end 终点坐标(停车位)
   * @param onUpdate 位置更新回调
   * @param onArrival 到达回调
   */
  start(
    start: Location,
    end: Location,
    onUpdate?: (position: Location, distance: number) => void,
    onArrival?: () => void
  ): Promise<void>;

  /**
   * 停止导航
   */
  stop(): void;

  /**
   * 暂停导航
   */
  pause(): void;

  /**
   * 恢复导航
   */
  resume(): void;

  /**
   * 获取导航状态
   */
  getStatus(): NavigationStatus;
}

/**
 * 导航信息模型
 */
export interface NavigationInfo {
  distance: number;              // 剩余距离(米)
  duration: number;              // 预计时间(秒)
  currentStep: number;           // 当前步骤索引
  totalSteps: number;            // 总步骤数
}

/**
 * 费率配置模型
 */
export interface FeeRateConfig {
  freeMinutes: number;           // 免费时长(分钟)
  halfPriceMinutes: number;      // 半价时长(分钟)
  hourlyRate: number;            // 小时费率(元)
  dailyMax: number;              // 每日封顶(元)
  weekendDiscount: number;       // 周末折扣(0-1)
  vipDiscount: number;           // VIP折扣(0-1)
}

/**
 * 费用项目模型
 */
export interface FeeItem {
  period: string;                // 时间段
  fee: number;                   // 费用(元)
  adjustment?: number;           // 调整金额(元)
}

/**
 * 费用详情模型
 */
export interface FeeDetailBreakdown {
  totalFee: number;              // 总费用(元)
  breakdown: FeeItem[];          // 费用明细
  durationMinutes: number;       // 停放时长(分钟)
  discountApplied?: string;      // 应用的折扣
}
