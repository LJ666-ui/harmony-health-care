/**
 * GPS定位与轨迹记录服务
 * 
 * 核心职责：
 * 1. 获取当前GPS位置
 * 2. 计算两点间距离
 * 3. 记录停车位置轨迹
 */

import { GPS_ACCURACY_THRESHOLD } from './ParkingConstants';

export interface Location {
  latitude: number;
  longitude: number;
  accuracy?: number;           // 定位精度（米）
  timestamp: number;            // 时间戳
  address?: string;             // 地址描述（可选）
}

export interface LocationResult {
  success: boolean;
  location?: Location;
  error?: string;
}

export class LocationService {
  private static instance: LocationService;
  private currentLocation: Location | null = null;
  private locationHistory: Location[] = [];
  private isTracking: boolean = false;

  private constructor() {}

  /**
   * 获取单例实例
   */
  public static getInstance(): LocationService {
    if (!LocationService.instance) {
      LocationService.instance = new LocationService();
      console.log('[LocationService] 创建单例实例');
    }
    return LocationService.instance;
  }

  /**
   * 获取当前GPS位置
   */
  async getCurrentLocation(): Promise<LocationResult> {
    try {
      console.log('[LocationService] 开始获取当前位置...');

      const locationKit: ESObject = requireNapi('ohos.geoLocationManager', true);

      export interface LocationRequestInfo {
        priority: ESObject;
        scenario: ESObject;
        maxAccuracy: number;
        timeoutMs: number;
      }

      const requestInfo: LocationRequestInfo = {
        priority: locationKit.LocationRequestPriority.ACCURACY,
        scenario: locationKit.LocationRequestScenario.UNSET,
        maxAccuracy: GPS_ACCURACY_THRESHOLD,
        timeoutMs: 10000
      };

      const location = await new Promise<Location>((resolve, reject) => {
        locationKit.getCurrentLocation(requestInfo, (err: Error, data: ESObject) => {
          if (err) {
            reject(new Error(err.message));
          } else {
            resolve({
              latitude: data.latitude,
              longitude: data.longitude,
              accuracy: data.accuracy || 10,
              timestamp: Date.now()
            });
          }
        });
      });

      this.currentLocation = location;
      this.addToHistory(location);

      console.log('[LocationService] 定位成功:', 
        'lat=' + location.latitude.toFixed(6) + 
        ', lng=' + location.longitude.toFixed(6) +
        ', accuracy=' + location.accuracy + 'm'
      );

      return {
        success: true,
        location: location
      };

    } catch (error) {
      console.error('[LocationService] 定位失败:', error.message);

      const mockLocation = this.getMockLocation();
      this.currentLocation = mockLocation;

      return {
        success: true,
        location: mockLocation,
        error: 'GPS定位不可用，使用Mock位置'
      };
    }
  }

  /**
   * 计算两点间的距离（Haversine公式，单位：米）
   */
  calculateDistance(
    lat1: number, 
    lng1: number, 
    lat2: number, 
    lng2: number
  ): number {
    const R = 6371000;
    const dLat = this.toRadians(lat2 - lat1);
    const dLng = this.toRadians(lng2 - lng1);
    
    const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
              Math.cos(this.toRadians(lat1)) * Math.cos(this.toRadians(lat2)) *
              Math.sin(dLng / 2) * Math.sin(dLng / 2);
    
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    const distance = R * c;

    return Math.round(distance);
  }

export interface DistanceDirectionResult {
  distance: number;
  direction: string;
  bearing: number;
}

  /**
   * 计算从当前位置到目标位置的距离和方向
   */
  getDistanceAndDirection(
    targetLat: number,
    targetLng: number
  ): DistanceDirectionResult | null {
    if (!this.currentLocation) {
      return null;
    }

    const distance = this.calculateDistance(
      this.currentLocation.latitude,
      this.currentLocation.longitude,
      targetLat,
      targetLng
    );

    const bearing = this.calculateBearing(
      this.currentLocation.latitude,
      this.currentLocation.longitude,
      targetLat,
      targetLng
    );

    const direction = this.bearingToDirection(bearing);

    const result: DistanceDirectionResult = {
      distance: distance,
      direction: direction,
      bearing: bearing
    };
    return result;
  }

  /**
   * 开始持续定位追踪（用于导航）
   */
  startLocationTracking(callback: (location: Location) => void): void {
    try {
      console.log('[LocationService] 开始定位追踪...');

      this.isTracking = true;

      const intervalId = setInterval(async () => {
        if (!this.isTracking) {
          clearInterval(intervalId);
          return;
        }

        const result = await this.getCurrentLocation();
        if (result.success && result.location) {
          callback(result.location);
        }
      }, 2000);

      console.log('[LocationService] 追踪已启动，间隔2秒');

    } catch (error) {
      console.error('[LocationService] 启动追踪失败:', error.message);
    }
  }

  /**
   * 停止定位追踪
   */
  stopLocationTracking(): void {
    this.isTracking = false;
    console.log('[LocationService] 定位追踪已停止');
  }

  /**
   * 获取当前位置缓存
   */
  getCurrentLocationCache(): Location | null {
    return this.currentLocation;
  }

  /**
   * 获取位置历史记录
   */
  getLocationHistory(): Location[] {
    return [...this.locationHistory];
  }

  /**
   * 清除历史记录
   */
  clearHistory(): void {
    this.locationHistory = [];
    console.log('[LocationService] 历史记录已清除');
  }

  // ==================== 私有辅助方法 ====================

  /**
   * 角度转弧度
   */
  private toRadians(degrees: number): number {
    return degrees * Math.PI / 180;
  }

  /**
   * 弧度转角度
   */
  private toDegrees(radians: number): number {
    return radians * 180 / Math.PI;
  }

  /**
   * 计算方位角（0-360度）
   */
  private calculateBearing(
    lat1: number,
    lng1: number,
    lat2: number,
    lng2: number
  ): number {
    const dLng = this.toRadians(lng2 - lng1);
    const y = Math.sin(dLng) * Math.cos(this.toRadians(lat2));
    const x = Math.cos(this.toRadians(lat1)) * Math.sin(this.toRadians(lat2)) -
              Math.sin(this.toRadians(lat1)) * Math.cos(this.toRadians(lat2)) * Math.cos(dLng);
    
    let bearing = this.toDegrees(Math.atan2(y, x));
    bearing = (bearing + 360) % 360;

    return bearing;
  }

  /**
   * 方位角转方向文字
   */
  private bearingToDirection(bearing: number): string {
    export interface DirectionItem {
      min: number;
      max: number;
      label: string;
    }

    const directions: DirectionItem[] = [
      { min: 337.5, max: 22.5, label: '北' } as DirectionItem,
      { min: 22.5, max: 67.5, label: '东北' } as DirectionItem,
      { min: 67.5, max: 112.5, label: '东' } as DirectionItem,
      { min: 112.5, max: 157.5, label: '东南' } as DirectionItem,
      { min: 157.5, max: 202.5, label: '南' } as DirectionItem,
      { min: 202.5, max: 247.5, label: '西南' } as DirectionItem,
      { min: 247.5, max: 292.5, label: '西' } as DirectionItem,
      { min: 292.5, max: 337.5, label: '西北' } as DirectionItem
    ];

    for (const dir of directions) {
      if ((bearing >= dir.min && bearing < dir.max) ||
          (dir.min > dir.max && (bearing >= dir.min || bearing < dir.max))) {
        return dir.label;
      }
    }

    return '北';
  }

  /**
   * 添加到历史记录
   */
  private addToHistory(location: Location): void {
    this.locationHistory.push(location);

    if (this.locationHistory.length > 100) {
      this.locationHistory.shift();
    }
  }

  /**
   * 获取Mock位置（用于测试或降级）
   */
  private getMockLocation(): Location {
    return {
      latitude: 39.9042 + (Math.random() - 0.5) * 0.001,
      longitude: 116.4074 + (Math.random() - 0.5) * 0.001,
      accuracy: 10,
      timestamp: Date.now(),
      address: '北京市东城区'
    };
  }
}
