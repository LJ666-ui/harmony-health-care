import { geoLocationManager } from '@kit.LocationKit';
import { ParkingLot, ParkingSpace, ParkingRecord, FeeDetailBreakdown, FeeRateConfig, Location, FeeItem } from '../models/ParkingModels';
import {
  getMockParkingLots,
  getMockParkingSpaces,
  getMockParkingRecord,
  getMockFeeRates
} from '../mock/parkingMock';
import {
  CacheConstants,
  FeeConstants,
  LogConstants,
  NavigationConstants,
  ParkingErrorCode,
  ParkingErrorMessage,
  ReservationConstants,
  StorageConstants
} from './ParkingConstants';
import { preferences } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';

/**
 * 停车服务类(单例)
 */
export class ParkingService {
  private static instance: ParkingService;
  private preferences: preferences.Preferences | null = null;

  private constructor() {
  }

  /**
   * 获取单例实例
   */
  static getInstance(): ParkingService {
    if (!ParkingService.instance) {
      ParkingService.instance = new ParkingService();
    }
    return ParkingService.instance;
  }

  /**
   * 初始化服务
   */
  async init(): Promise<void> {
    try {
      this.preferences = await preferences.getPreferences(getContext(), StorageConstants.PREFERENCES_NAME);
    } catch (err) {
      let code = (err as BusinessError).code;
      let message = (err as BusinessError).message;
      console.error(`Failed to get preferences. Code:${code}, message:${message}`);
    }
  }

  /**
   * 获取用户当前位置
   */
  async getCurrentLocation(): Promise<Location> {
    try {
      const locationInfo: geoLocationManager.Location = await geoLocationManager.getCurrentLocation({
        priority: geoLocationManager.LocationRequestPriority.ACCURACY,
        timeoutMs: NavigationConstants.LOCATION_TIMEOUT,
        maxAccuracy: NavigationConstants.GPS_ACCURACY
      });
      return {
        latitude: locationInfo.latitude,
        longitude: locationInfo.longitude
      };
    } catch (err) {
      console.error(`errCode:${(err as BusinessError).code},errMessage:${(err as BusinessError).message}`);
      throw new Error(ParkingErrorMessage.getMessage(ParkingErrorCode.LOCATION_FAILED));
    }
  }

  /**
   * 获取附近停车场列表
   */
  async getParkingLots(userLat: number, userLng: number): Promise<ParkingLot[]> {
    const parkingLots: ParkingLot[] = getMockParkingLots();
    const lotsWithDistance: ParkingLot[] = [];
    for (let i = 0; i < parkingLots.length; i++) {
      const lot = parkingLots[i];
      const distance: number = this.calculateDistance(userLat, userLng, lot.latitude, lot.longitude);
      const newLot: ParkingLot = {
        id: lot.id,
        name: lot.name,
        address: lot.address,
        totalSpaces: lot.totalSpaces,
        availableSpaces: lot.availableSpaces,
        latitude: lot.latitude,
        longitude: lot.longitude,
        hourlyRate: lot.hourlyRate,
        dailyMaxFee: lot.dailyMaxFee,
        distance: distance,
        floors: lot.floors,
        hasCharging: lot.hasCharging,
        hasDisabled: lot.hasDisabled,
        openTime: lot.openTime
      };
      lotsWithDistance.push(newLot);
    }
    lotsWithDistance.sort((a, b) => a.distance - b.distance);
    return lotsWithDistance;
  }

  /**
   * 获取指定停车场的车位列表
   */
  async getParkingSpaces(lotId: string): Promise<ParkingSpace[]> {
    return getMockParkingSpaces(lotId);
  }

  /**
   * 计算两点之间的距离(Haversine公式)
   */
  calculateDistance(lat1: number, lng1: number, lat2: number, lng2: number): number {
    const R = 6371000;
    const dLat = (lat2 - lat1) * Math.PI / 180;
    const dLng = (lng2 - lng1) * Math.PI / 180;
    const a = Math.sin(dLat / 2) ** 2 + Math.cos(lat1 * Math.PI / 180) *
      Math.cos(lat2 * Math.PI / 180) * Math.sin(dLng / 2) ** 2;
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
  }

  /**
   * 获取停车费率配置
   */
  getFeeRates(): FeeRateConfig {
    return getMockFeeRates();
  }

  /**
   * 计算停车费用
   */
  calculateFee(parkDurationMinutes: number): FeeDetailBreakdown {
    const config: FeeRateConfig = this.getFeeRates();
    let totalFee: number = 0;
    const breakdown: FeeItem[] = [];

    if (parkDurationMinutes <= config.freeMinutes) {
      const item: FeeItem = { period: '0-30分钟(免费)', fee: 0 };
      breakdown.push(item);
      return { totalFee: 0, breakdown, durationMinutes: parkDurationMinutes };
    }

    if (parkDurationMinutes > config.freeMinutes) {
      const halfPriceDuration: number = Math.min(
        config.halfPriceMinutes,
        parkDurationMinutes - config.freeMinutes
      );
      const halfPriceFee: number = (halfPriceDuration / 60) * config.hourlyRate * 0.5;
      totalFee += halfPriceFee;
      const item: FeeItem = { period: '30-60分钟(半价)', fee: halfPriceFee };
      breakdown.push(item);
    }

    const fullPriceMinutes: number = Math.max(0, parkDurationMinutes - config.freeMinutes - config.halfPriceMinutes);
    if (fullPriceMinutes > 0) {
      const fullPriceHours: number = Math.ceil(fullPriceMinutes / 60);
      const fullPriceFee: number = fullPriceHours * config.hourlyRate;
      totalFee += fullPriceFee;
      const item: FeeItem = { period: '超出小时(全价)', fee: fullPriceFee };
      breakdown.push(item);
    }

    const daysParked: number = Math.ceil(parkDurationMinutes / (24 * 60));
    const dailyCapTotal: number = daysParked * config.dailyMax;
    if (totalFee > dailyCapTotal) {
      totalFee = dailyCapTotal;
      const item: FeeItem = {
        period: '已达每日封顶',
        fee: 0,
        adjustment: dailyCapTotal - (totalFee - dailyCapTotal)
      };
      breakdown.push(item);
    }

    const now: Date = new Date();
    const isWeekend: boolean = now.getDay() === 0 || now.getDay() === 6;
    let discountApplied: string | undefined;
    if (isWeekend) {
      const discount: number = totalFee * (1 - config.weekendDiscount);
      const item: FeeItem = { period: '周末8折优惠', fee: 0, adjustment: -discount };
      breakdown.push(item);
      totalFee *= config.weekendDiscount;
      discountApplied = '周末8折优惠';
    }

    return {
      totalFee: Math.round(totalFee * 100) / 100,
      breakdown,
      durationMinutes: parkDurationMinutes,
      discountApplied
    };
  }

  /**
   * 获取当前停车记录
   */
  async getParkingRecord(): Promise<ParkingRecord | null> {
    try {
      if (this.preferences != null) {
        const record: preferences.ValueType | null = await this.preferences.get(StorageConstants.CURRENT_RECORD_KEY, null);
        return record as ParkingRecord | null;
      }
      return null;
    } catch (err) {
      console.error(`errCode:${(err as BusinessError).code},errMessage:${(err as BusinessError).message}`);
      return null;
    }
  }
}
