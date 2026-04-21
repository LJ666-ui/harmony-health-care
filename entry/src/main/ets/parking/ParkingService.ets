/**
 * 停车业务核心服务
 * 
 * 核心职责：
 * 1. 获取停车场和车位信息（支持缓存）
 * 2. 车位预约管理
 * 3. 停车位置记录
 * 4. 停车费用计算
 */

import { SpaceStatus, SpaceType, DEFAULT_FEE_CONFIG, CACHE_EXPIRY_MS } from './ParkingConstants';

// ==================== 数据模型定义 ====================
export interface ParkingLot {
  id: string;
  name: string;                // "门诊楼地下停车场"
  address: string;
  totalSpaces: number;          // 总车位数
  availableSpaces: number;      // 空闲车位数
  latitude: number;
  longitude: number;
  hourlyRate: number;           // 每小时费用（元）
  distance: number;             // 距离当前位置（米）
}

export interface ParkingSpace {
  id: string;
  lotId: string;
  spaceNumber: string;          // "A-128"
  status: SpaceStatus;
  type: SpaceType;
  latitude: number;
  longitude: number;
  floor: string;                // "B2"
}

export interface ReservationResult {
  success: boolean;
  reservationId?: string;
  spaceId?: string;
  expireTime?: number;           // 预约过期时间戳
  message?: string;
}

export interface ParkingRecord {
  recordId: string;
  userId: string;
  reservationId: string;
  spaceId: string;
  spaceNumber: string;
  lotId: string;
  lotName: string;
  latitude: number;
  longitude: number;
  floor: string;
  parkingTime: string;           // ISO格式时间字符串
  photoUri?: string;             // 停车照片URI
  note?: string;                 // 文字备注
  isActive: boolean;             // 是否有效（未离场）
}

export interface FeeBreakdownItem {
  day: number;
  hours: number;
  fee: number;
}

export interface FeeDetail {
  totalFee: number;              // 总费用
  parkedHours: number;           // 停放时长（小时）
  freeHours: number;             // 免费时长
  chargedHours: number;          // 计费时长
  hourlyRate: number;            // 小时费率
  dailyCap: number;              // 日封顶金额
  breakdown: FeeBreakdownItem[];
}

// ==================== 缓存数据结构 ====================
interface CacheItem<T> {
  data: T;
  timestamp: number;
  expiry: number;
}

export class ParkingService {
  private static instance: ParkingService;

  export interface ReservationData {
    spaceId: string;
    lotId: string;
    reservedAt: number;
    expiresAt: number;
    userId: string;
  }

  private parkingLotsCache: CacheItem<ParkingLot[]> | null = null;
  private spacesCache: Map<string, CacheItem<ParkingSpace[]>> = new Map<string, CacheItem<ParkingSpace[]>>();
  private activeReservations: Map<string, ReservationData> = new Map<string, ReservationData>();
  private activeRecords: Map<string, ParkingRecord> = new Map<string, ParkingRecord>();   // userId → ParkingRecord

  private constructor() {}

  /**
   * 获取单例实例
   */
  public static getInstance(): ParkingService {
    if (!ParkingService.instance) {
      ParkingService.instance = new ParkingService();
      console.log('[ParkingService] 创建单例实例');
    }
    return ParkingService.instance;
  }

  /**
   * 获取附近停车场列表（先读缓存，过期则请求API）
   */
  async getParkingLots(): Promise<ParkingLot[]> {
    try {
      console.log('[ParkingService] 获取停车场列表...');

      if (this.isCacheValid(this.parkingLotsCache)) {
        console.log('[ParkingService] 使用缓存数据');
        return this.parkingLotsCache!.data;
      }

      const mockData = await import('../mock/parkingMock');
      const lots: ParkingLot[] = mockData.getParkingLots();

      this.parkingLotsCache = {
        data: lots,
        timestamp: Date.now(),
        expiry: CACHE_EXPIRY_MS
      };

      console.log('[ParkingService] 获取到 ' + lots.length + ' 个停车场');
      return lots;

    } catch (error) {
      console.error('[ParkingService] 获取停车场列表失败:', error.message);
      
      if (this.parkingLotsCache) {
        return this.parkingLotsCache.data;
      }
      return [];
    }
  }

  /**
   * 获取指定停车场的车位列表及状态
   */
  async getParkingSpaces(lotId: string): Promise<ParkingSpace[]> {
    try {
      console.log('[ParkingService] 获取停车场 ' + lotId + ' 的车位...');

      const cached = this.spacesCache.get(lotId);
      if (cached && this.isCacheValid(cached)) {
        console.log('[ParkingService] 使用缓存的车位数据');
        return cached.data;
      }

      const mockData = await import('../mock/parkingMock');
      const spaces: ParkingSpace[] = mockData.getParkingSpaces(lotId);

      this.spacesCache.set(lotId, {
        data: spaces,
        timestamp: Date.now(),
        expiry: CACHE_EXPIRY_MS
      });

      console.log('[ParkingService] 获取到 ' + spaces.length + ' 个车位');
      return spaces;

    } catch (error) {
      console.error('[ParkingService] 获取车位失败:', error.message);
      
      const cached = this.spacesCache.get(lotId);
      if (cached) {
        return cached.data;
      }
      return [];
    }
  }

  /**
   * 预约车位（检查是否空闲→锁定15分钟→返回预约ID）
   */
  async reserveSpace(spaceId: string, userId: string): Promise<ReservationResult> {
    try {
      console.log('[ParkingService] 开始预约车位: ' + spaceId);

      const allSpaces = await this.getAllSpacesForReservation(spaceId);
      const targetSpace = allSpaces.find(s => s.id === spaceId);

      if (!targetSpace) {
        return {
          success: false,
          message: '车位不存在'
        };
      }

      if (targetSpace.status !== SpaceStatus.AVAILABLE) {
        return {
          success: false,
          message: '该车位当前不可用（状态: ' + targetSpace.status + '）'
        };
      }

      const reservationId = 'RESV_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
      const expireTime = Date.now() + 15 * 60 * 1000;

      this.activeReservations.set(reservationId, {
        reservationId: reservationId,
        spaceId: spaceId,
        userId: userId,
        createTime: Date.now(),
        expireTime: expireTime,
        status: 'ACTIVE'
      });

      targetSpace.status = SpaceStatus.RESERVED;

      console.log('[ParkingService] 预约成功，ID: ' + reservationId);
      return {
        success: true,
        reservationId: reservationId,
        spaceId: spaceId,
        expireTime: expireTime,
        message: '预约成功，请在15分钟内到达'
      };

    } catch (error) {
      const err = error as Error;
      console.error('[ParkingService] 预约失败:', err.message);
      return {
        success: false,
        message: '预约失败: ' + err.message
      };
    }
  }

  /**
   * 取消预约
   */
  async cancelReservation(reservationId: string): Promise<boolean> {
    try {
      console.log('[ParkingService] 取消预约: ' + reservationId);

      const reservation = this.activeReservations.get(reservationId);
      if (!reservation) {
        console.warn('[ParkingService] 预约不存在或已过期');
        return false;
      }

      this.activeReservations.delete(reservationId);
      console.log('[ParkingService] 预约已取消');
      return true;

    } catch (error) {
      const err = error as Error;
      console.error('[ParkingService] 取消预约失败:', err.message);
      return false;
    }
  }

  /**
   * 记录停车位置（GPS+拍照+备注）
   */
  async recordParkingLocation(
    reservationId: string,
    photoUri?: string,
    note?: string
  ): Promise<ParkingRecord> {
    try {
      console.log('[ParkingService] 记录停车位置...');

      const reservation = this.activeReservations.get(reservationId);
      if (!reservation) {
        throw new Error('无效的预约ID');
      }

      const allSpaces = await this.getAllSpacesForReservation(reservation.spaceId);
      const space = allSpaces.find(s => s.id === reservation.spaceId);
      
      if (!space) {
        throw new Error('车位信息不存在');
      }

      const lots = await this.getParkingLots();
      const lot = lots.find(l => l.id === space.lotId);
      
      if (!lot) {
        throw new Error('停车场信息不存在');
      }

      const record: ParkingRecord = {
        recordId: 'RECORD_' + Date.now(),
        userId: reservation.userId,
        reservationId: reservationId,
        spaceId: space.id,
        spaceNumber: space.spaceNumber,
        lotId: lot.id,
        lotName: lot.name,
        latitude: space.latitude,
        longitude: space.longitude,
        floor: space.floor,
        parkingTime: new Date().toISOString(),
        photoUri: photoUri,
        note: note,
        isActive: true
      };

      space.status = SpaceStatus.OCCUPIED;
      this.activeRecords.set(record.userId, record);

      console.log('[ParkingService] 停车位置已记录: ' + record.spaceNumber);
      return record;

    } catch (error) {
      const err = error as Error;
      console.error('[ParkingService] 记录停车位置失败:', err.message);
      throw new Error(err.message);
    }
  }

  /**
   * 获取当前有效的停车记录
   */
  async getParkingRecord(userId: string): Promise<ParkingRecord | null> {
    try {
      console.log('[ParkingService] 查询用户停车记录: ' + userId);

      const record = this.activeRecords.get(userId);
      
      if (record && record.isActive) {
        console.log('[ParkingService] 找到有效停车记录: ' + record.recordId);
        return record;
      }

      console.log('[ParkingService] 无有效停车记录');
      return null;

    } catch (error) {
      console.error('[ParkingService] 查询停车记录失败:', error.message);
      return null;
    }
  }

  /**
   * 计算停车费用（按时长阶梯计费）
   */
  calculateFee(parkingRecord: ParkingRecord): FeeDetail {
    try {
      const config = DEFAULT_FEE_CONFIG;
      const parkingTime = new Date(parkingRecord.parkingTime).getTime();
      const currentTime = Date.now();
      const durationMs = currentTime - parkingTime;
      const totalMinutes = Math.floor(durationMs / (1000 * 60));
      const totalHours = totalMinutes / 60;

      const freeHours = Math.min(totalHours, config.freeMinutes / 60);
      const chargedHours = Math.max(0, totalHours - freeHours);

      let totalFee = 0;
      let remainingHours = chargedHours;
      const breakdown: FeeBreakdownItem[] = [];

      for (let day = 1; day <= config.maxDays && remainingHours > 0; day++) {
        const dayHours = Math.min(remainingHours, 24);
        const dayFee = Math.min(dayHours * config.hourlyRate, config.dailyCap);

        totalFee += dayFee;
        remainingHours -= dayHours;

        breakdown.push({
          day: day,
          hours: Math.round(dayHours * 100) / 100,
          fee: dayFee
        } as FeeBreakdownItem);
      }

      const result: FeeDetail = {
        totalFee: Math.round(totalFee * 100) / 100,
        parkedHours: Math.round(totalHours * 100) / 100,
        freeHours: Math.round(freeHours * 100) / 100,
        chargedHours: Math.round(chargedHours * 100) / 100,
        hourlyRate: config.hourlyRate,
        dailyCap: config.dailyCap,
        breakdown: breakdown
      };

      console.log('[ParkingService] 费用计算完成:', JSON.stringify(result));
      return result;

    } catch (error) {
      console.error('[ParkingService] 计算费用失败:', error.message);
      return {
        totalFee: 0,
        parkedHours: 0,
        freeHours: 0,
        chargedHours: 0,
        hourlyRate: 0,
        dailyCap: 0,
        breakdown: []
      };
    }
  }

  // ==================== 私有辅助方法 ====================

  /**
   * 检查缓存是否有效
   */
  private isCacheValid<T>(cache: CacheItem<T> | null | undefined): boolean {
    if (!cache) return false;
    
    const elapsed = Date.now() - cache.timestamp;
    return elapsed < cache.expiry;
  }

  /**
   * 获取所有车位（用于预约检查）
   */
  private async getAllSpacesForReservation(spaceId: string): Promise<ParkingSpace[]> {
    const mockData: ESObject = await import('../mock/parkingMock') as ESObject;
    const lots: ParkingLot[] = mockData.getParkingLots() as ParkingLot[];

    for (const lot of lots) {
      const spaces: ParkingSpace[] = mockData.getParkingSpaces(lot.id) as ParkingSpace[];
      const target = spaces.find(s => s.id === spaceId);
      if (target) {
        return spaces;
      }
    }
    
    return [];
  }

  /**
   * 清除所有缓存
   */
  clearCache(): void {
    this.parkingLotsCache = null;
    this.spacesCache.clear();
    console.log('[ParkingService] 缓存已清除');
  }

  /**
   * 结束停车（标记为已完成）
   */
  endParking(userId: string): boolean {
    const record = this.activeRecords.get(userId);
    if (record) {
      record.isActive = false;
      console.log('[ParkingService] 停车已结束: ' + record.recordId);
      return true;
    }
    return false;
  }
}
