/**
 * 智慧停车常量定义
 */

/**
 * 错误码定义
 */
export enum ParkingErrorCode {
  LOCATION_FAILED = 1001, // 定位失败
  PERMISSION_DENIED = 1002, // 权限拒绝
  NETWORK_ERROR = 1003, // 网络错误
  INVALID_PARAMS = 1004, // 参数错误
  RESERVATION_FAILED = 1005, // 预约失败
  CANCELLATION_LIMIT_EXCEEDED = 1006, // 取消次数超限
  PARKING_RECORD_NOT_FOUND = 1007, // 停车记录不存在
  NAVIGATION_FAILED = 1008, // 导航失败
  CAMERA_FAILED = 1009, // 相机启动失败
  SENSOR_FAILED = 1010 // 传感器启动失败
}

/**
 * 错误信息定义
 */
export class ParkingErrorMessage {
  static readonly LOCATION_FAILED: string = '定位失败,请检查位置权限';
  static readonly PERMISSION_DENIED: string = '权限被拒绝,请在设置中开启权限';
  static readonly NETWORK_ERROR: string = '网络错误,请检查网络连接';
  static readonly INVALID_PARAMS: string = '参数错误';
  static readonly RESERVATION_FAILED: string = '预约失败,请稍后重试';
  static readonly CANCELLATION_LIMIT_EXCEEDED: string = '今日取消次数已达上限(3次)';
  static readonly PARKING_RECORD_NOT_FOUND: string = '停车记录不存在';
  static readonly NAVIGATION_FAILED: string = '导航失败,请稍后重试';
  static readonly CAMERA_FAILED: string = '相机启动失败,请检查相机权限';
  static readonly SENSOR_FAILED: string = '传感器启动失败,请检查设备支持';

  static getMessage(code: number): string {
    if (code === ParkingErrorCode.LOCATION_FAILED) {
      return ParkingErrorMessage.LOCATION_FAILED;
    }
    if (code === ParkingErrorCode.PERMISSION_DENIED) {
      return ParkingErrorMessage.PERMISSION_DENIED;
    }
    if (code === ParkingErrorCode.NETWORK_ERROR) {
      return ParkingErrorMessage.NETWORK_ERROR;
    }
    if (code === ParkingErrorCode.INVALID_PARAMS) {
      return ParkingErrorMessage.INVALID_PARAMS;
    }
    if (code === ParkingErrorCode.RESERVATION_FAILED) {
      return ParkingErrorMessage.RESERVATION_FAILED;
    }
    if (code === ParkingErrorCode.CANCELLATION_LIMIT_EXCEEDED) {
      return ParkingErrorMessage.CANCELLATION_LIMIT_EXCEEDED;
    }
    if (code === ParkingErrorCode.PARKING_RECORD_NOT_FOUND) {
      return ParkingErrorMessage.PARKING_RECORD_NOT_FOUND;
    }
    if (code === ParkingErrorCode.NAVIGATION_FAILED) {
      return ParkingErrorMessage.NAVIGATION_FAILED;
    }
    if (code === ParkingErrorCode.CAMERA_FAILED) {
      return ParkingErrorMessage.CAMERA_FAILED;
    }
    if (code === ParkingErrorCode.SENSOR_FAILED) {
      return ParkingErrorMessage.SENSOR_FAILED;
    }
    return '未知错误';
  }
}

/**
 * 预约相关常量
 */
export class ReservationConstants {
  /**
   * 预约超时时间(毫秒) - 15分钟
   */
  static readonly RESERVATION_TIMEOUT: number = 15 * 60 * 1000;

  /**
   * 每日最大取消次数
   */
  static readonly DAILY_CANCELLATION_LIMIT: number = 3;

  /**
   * 到期前提醒时间(毫秒) - 2分钟
   */
  static readonly REMINDER_BEFORE_EXPIRE: number = 2 * 60 * 1000;

  /**
   * 预约缓存Key前缀
   */
  static readonly RESERVATION_CACHE_PREFIX: string = 'reservation_';

  /**
   * 取消次数缓存Key
   */
  static readonly CANCELLATION_COUNT_KEY: string = 'cancellation_count';

  /**
   * 取消次数日期Key
   */
  static readonly CANCELLATION_DATE_KEY: string = 'cancellation_date';
}

/**
 * 导航相关常量
 */
export class NavigationConstants {
  /**
   * 到达阈值(米) - 5米
   */
  static readonly ARRIVAL_THRESHOLD: number = 5;

  /**
   * AR导航更新频率(毫秒) - 100ms
   */
  static readonly AR_UPDATE_INTERVAL: number = 100;

  /**
   * 地图导航更新频率(毫秒) - 1000ms
   */
  static readonly MAP_UPDATE_INTERVAL: number = 1000;

  /**
   * 位置超时时间(毫秒) - 10秒
   */
  static readonly LOCATION_TIMEOUT: number = 10 * 1000;

  /**
   * GPS精度要求(米)
   */
  static readonly GPS_ACCURACY: number = 100;
}

/**
 * 缓存相关常量
 */
export class CacheConstants {
  /**
   * 停车场列表缓存Key
   */
  static readonly PARKING_LOTS_CACHE_KEY: string = 'parking_lots_cache';

  /**
   * 停车场列表缓存时间(毫秒) - 5分钟
   */
  static readonly CACHE_DURATION: number = 5 * 60 * 1000;

  /**
   * 停车记录缓存Key
   */
  static readonly PARKING_RECORD_CACHE_KEY: string = 'current_parking_record';

  /**
   * 用户设置缓存Key
   */
  static readonly USER_SETTINGS_CACHE_KEY: string = 'user_settings';
}

/**
 * 费用相关常量
 */
export class FeeConstants {
  /**
   * 费用更新频率(毫秒) - 1000ms
   */
  static readonly FEE_UPDATE_INTERVAL: number = 1000;

  /**
   * 免费时长(分钟)
   */
  static readonly FREE_MINUTES: number = 30;

  /**
   * 半价时长(分钟)
   */
  static readonly HALF_PRICE_MINUTES: number = 30;

  /**
   * 每日封顶(元)
   */
  static readonly DAILY_CAP: number = 50;

  /**
   * 周末折扣(0-1)
   */
  static readonly WEEKEND_DISCOUNT: number = 0.8;

  /**
   * VIP折扣(0-1)
   */
  static readonly VIP_DISCOUNT: number = 0.7;

  /**
   * 默认小时费率(元)
   */
  static readonly DEFAULT_HOURLY_RATE: number = 5;
}

/**
 * UI相关常量
 */
export class UIConstants {
  /**
   * 加载超时时间(毫秒) - 3秒
   */
  static readonly LOADING_TIMEOUT: number = 3 * 1000;

  /**
   * Toast显示时长(毫秒) - 3000ms
   */
  static readonly TOAST_DURATION: number = 3000;

  /**
   * 动画时长(毫秒) - 300ms
   */
  static readonly ANIMATION_DURATION: number = 300;

  /**
   * 列表每页数量
   */
  static readonly PAGE_SIZE: number = 20;

  /**
   * 最大预约数量
   */
  static readonly MAX_RESERVATION_COUNT: number = 1;
}

/**
 * 权限相关常量
 */
export class PermissionConstants {
  /**
   * 位置权限
   */
  static readonly LOCATION_PERMISSION: string = 'ohos.permission.LOCATION';

  /**
   * 相机权限
   */
  static readonly CAMERA_PERMISSION: string = 'ohos.permission.CAMERA';

  /**
   * 陀螺仪权限
   */
  static readonly ACCELEROMETER_PERMISSION: string = 'ohos.permission.ACCELEROMETER';

  /**
   * 指南针权限
   */
  static readonly COMPASS_PERMISSION: string = 'ohos.permission.APPROXIMATELY_LOCATION';
}

/**
 * 存储相关常量
 */
export class StorageConstants {
  /**
   * Preferences名称
   */
  static readonly PREFERENCES_NAME: string = 'SmartParking';

  /**
   * 当前停车记录Key
   */
  static readonly CURRENT_RECORD_KEY: string = 'current_parking_record';

  /**
   * 停车历史记录Key
   */
  static readonly HISTORY_RECORDS_KEY: string = 'parking_history_records';
}

/**
 * 日志标签
 */
export class LogConstants {
  /**
   * 停车服务日志标签
   */
  static readonly PARKING_SERVICE: string = 'ParkingService';

  /**
   * 导航引擎日志标签
   */
  static readonly NAVIGATION_ENGINE: string = 'NavigationEngine';

  /**
   * 预约服务日志标签
   */
  static readonly RESERVATION_SERVICE: string = 'ReservationService';

  /**
   * 计费计算器日志标签
   */
  static readonly FEE_CALCULATOR: string = 'FeeCalculator';

  /**
   * 数据仓库日志标签
   */
  static readonly DATA_REPOSITORY: string = 'DataRepository';

  /**
   * 定位管理器日志标签
   */
  static readonly LOCATION_MANAGER: string = 'LocationManager';
}
