/**
 * 停车服务真实数据（基于数据库 parking_lot, parking_space, parking_record 表）
 *
 * 数据来源: new_tables_part1_parking.sql
 * 包含:
 *   - 3个停车场（协和医院门诊楼、外科楼、朝阳医院）
 *   - 10个车位（涵盖5种类型：VIP/普通/充电桩120kW/充电桩180kW/无障碍）
 *   - 5条停车记录（展示完整生命周期）
 */

import { ParkingLot, ParkingSpace, ParkingRecord, FeeDetailBreakdown, FeeRateConfig, IndoorLocation, FeeDetail, FeeItem } from '../models/ParkingModels';

export interface ParkingHistoryItem {
  recordId: string;
  parkingLotName: string;
  spaceNumber: string;
  enterTime: number;
  exitTime: number | null;
  duration: string;
  fee: number;
  paymentMethod: string;
  status: 'COMPLETED' | 'ACTIVE' | 'CANCELLED';
}

/**
 * 获取真实停车场数据
 * @returns 停车场列表（3个协和医院+朝阳医院停车场）
 */
export function getMockParkingLots(): ParkingLot[] {
  return [
    {
      id: '1',
      name: '协和医院门诊楼地下停车场',
      address: '北京市东城区帅府园1号，门诊楼B1-B3层',
      totalSpaces: 500,
      availableSpaces: 127,
      latitude: 39.913889,
      longitude: 116.417778,
      hourlyRate: 6,
      dailyMaxFee: 60,
      distance: 0,
      floors: 3,
      hasCharging: true,
      hasDisabled: true,
      openTime: '00:00-24:00'
    },
    {
      id: '2',
      name: '协和医院外科楼地面停车场',
      address: '北京市东城区帅府园1号外科楼北侧',
      totalSpaces: 200,
      availableSpaces: 43,
      latitude: 39.914256,
      longitude: 116.418034,
      hourlyRate: 5,
      dailyMaxFee: 50,
      distance: 150,
      floors: 1,
      hasCharging: true,
      hasDisabled: true,
      openTime: '05:30-23:00'
    },
    {
      id: '3',
      name: '北京朝阳医院本部停车场',
      address: '北京市朝阳区工人体育场南路8号',
      totalSpaces: 350,
      availableSpaces: 89,
      latitude: 39.928611,
      longitude: 116.452778,
      hourlyRate: 8,
      dailyMaxFee: 80,
      distance: 2500,
      floors: 2,
      hasCharging: false,
      hasDisabled: true,
      openTime: '06:00-22:00'
    }
  ];
}

/**
 * 获取真实车位数据
 * @param lotId 停车场ID
 * @returns 车位列表（10个真实车位，覆盖所有类型）
 */
export function getMockParkingSpaces(lotId: string): ParkingSpace[] {
  const spaces: ParkingSpace[] = [];

  if (lotId === '1') {
    // 协和门诊楼停车场 - B1层普通区
    spaces.push({
      id: '1',
      lotId: '1',
      spaceNumber: 'A-001',
      floor: 'B1',
      zone: 'A区(普通)',
      type: 'NORMAL',
      status: 'AVAILABLE',
      latitude: 39.913879,
      longitude: 116.417769
    });
    spaces.push({
      id: '2',
      lotId: '1',
      spaceNumber: 'A-002',
      floor: 'B1',
      zone: 'A区(普通)',
      type: 'NORMAL',
      status: 'OCCUPIED',
      latitude: 39.913880,
      longitude: 116.417770
    });

    // B2层VIP专区
    spaces.push({
      id: '3',
      lotId: '1',
      spaceNumber: 'VIP-001',
      floor: 'B2',
      zone: 'VIP专区',
      type: 'VIP',
      status: 'OCCUPIED',
      latitude: 39.913869,
      longitude: 116.417759
    });
    spaces.push({
      id: '4',
      lotId: '1',
      spaceNumber: 'VIP-002',
      floor: 'B2',
      zone: 'VIP专区',
      type: 'VIP',
      status: 'AVAILABLE',
      latitude: 39.913870,
      longitude: 116.417760
    });

    // B2层120kW快充桩
    spaces.push({
      id: '5',
      lotId: '1',
      spaceNumber: 'CHG-001',
      floor: 'B2',
      zone: '新能源充电区',
      type: 'ELECTRIC',
      status: 'OCCUPIED',
      latitude: 39.913859,
      longitude: 116.417749
    });
    spaces.push({
      id: '6',
      lotId: '1',
      spaceNumber: 'CHG-002',
      floor: 'B2',
      zone: '新能源充电区',
      type: 'ELECTRIC',
      status: 'AVAILABLE',
      latitude: 39.913860,
      longitude: 116.417750
    });

    // B3层180kW超充桩
    spaces.push({
      id: '7',
      lotId: '1',
      spaceNumber: 'FAST-001',
      floor: 'B3',
      zone: '超充区',
      type: 'FAST_CHARGING',
      status: 'RESERVED',
      latitude: 39.913849,
      longitude: 116.417739
    });
    spaces.push({
      id: '8',
      lotId: '1',
      spaceNumber: 'FAST-002',
      floor: 'B3',
      zone: '超充区',
      type: 'FAST_CHARGING',
      status: 'AVAILABLE',
      latitude: 39.913850,
      longitude: 116.417740
    });

    // B1层无障碍车位
    spaces.push({
      id: '9',
      lotId: '1',
      spaceNumber: 'DIS-001',
      floor: 'B1',
      zone: '无障碍专区',
      type: 'DISABLED',
      status: 'AVAILABLE',
      latitude: 39.913889,
      longitude: 116.417779
    });
    spaces.push({
      id: '10',
      lotId: '1',
      spaceNumber: 'DIS-002',
      floor: 'B1',
      zone: '无障碍专区',
      type: 'DISABLED',
      status: 'OCCUPIED',
      latitude: 39.913890,
      longitude: 116.417780
    });
  } else if (lotId === '2') {
    // 协和外科楼停车场 - F1层
    for (let i = 11; i <= 15; i++) {
      spaces.push({
        id: `${i}`,
        lotId: '2',
        spaceNumber: `F1-${i - 10}`,
        floor: 'F1',
        zone: '普通停车区',
        type: 'NORMAL',
        status: ['AVAILABLE', 'OCCUPIED', 'RESERVED'][Math.floor(Math.random() * 3)] as 'AVAILABLE' | 'OCCUPIED' | 'RESERVED',
        latitude: 39.914246 + (i * 0.00001),
        longitude: 116.418024 + (i * 0.00001)
      });
    }
  } else if (lotId === '3') {
    // 朝阳医院停车场
    for (let i = 16; i <= 20; i++) {
      spaces.push({
        id: `${i}`,
        lotId: '3',
        spaceNumber: `CY-${i - 15}`,
        floor: 'F1',
        zone: '普通停车区',
        type: 'NORMAL',
        status: ['AVAILABLE', 'OCCUPIED', 'RESERVED'][Math.floor(Math.random() * 3)] as 'AVAILABLE' | 'OCCUPIED' | 'RESERVED',
        latitude: 39.928601 + (i * 0.00001),
        longitude: 116.452768 + (i * 0.00001)
      });
    }
  }

  return spaces;
}

/**
 * 获取当前用户的活跃停车记录（模拟用户ID=107的进行中记录）
 * @returns 当前停车记录
 */
export function getMockParkingRecord(): ParkingRecord {
  const parkTime = Date.now() - 7200000; // 2小时前进入
  const feeDetails = calculateParkingFee(120, getMockFeeRates());
  const indoorLocation: IndoorLocation = {
    building: '门诊楼',
    floor: 'B2',
    nearLandmark: '3号电梯厅旁A区第5排'
  };
  const feeDetail: FeeDetail = {
    baseFee: feeDetails.totalFee,
    weekendDiscount: 0,
    capDiscount: 0,
    finalFee: feeDetails.totalFee
  };

  return {
    recordId: 'PRK20260510001',
    parkingLotId: '1',
    parkingLotName: '协和医院门诊楼地下停车场',
    spaceId: '3',
    spaceNumber: 'VIP-001',
    floor: 'B2',
    zone: 'VIP专区',
    latitude: 39.913869,
    longitude: 116.417759,
    accuracy: 3,
    indoorLocation: indoorLocation,
    photoUri: 'internal://cache/parking_photo_vip001.jpg',
    note: 'B2层VIP专区001号位,靠近电梯厅,白色特斯拉Model Y',
    carDescription: '白色特斯拉 Model Y',
    licensePlate: '京A·88888',
    parkTime: parkTime,
    isActive: true,
    currentFee: feeDetails.totalFee,
    feeDetails: feeDetail
  };
}

/**
 * 获取历史停车记录列表（5条真实记录）
 * @returns 历史停车记录数组
 */
export function getMockParkingHistory(): ParkingHistoryItem[] {
  return [
    {
      recordId: 'PRK20260509001',
      parkingLotName: '协和医院门诊楼地下停车场',
      spaceNumber: 'A-128',
      enterTime: Date.now() - 86400000, // 昨天10:00
      exitTime: Date.now() - 79200000,  // 昨天12:00
      duration: '2小时',
      fee: 12.00,
      paymentMethod: '微信支付',
      status: 'COMPLETED'
    },
    {
      recordId: 'PRK20260508002',
      parkingLotName: '协和医院外科楼地面停车场',
      spaceNumber: 'F1-015',
      enterTime: Date.now() - 172800000, // 前天08:30
      exitTime: Date.now() - 162000000,  // 前天11:45
      duration: '3小时15分钟',
      fee: 16.25,
      paymentMethod: '支付宝',
      status: 'COMPLETED'
    },
    {
      recordId: 'PRK20260507003',
      parkingLotName: '北京朝阳医院本部停车场',
      spaceNumber: 'CY-008',
      enterTime: Date.now() - 259200000, // 3天前14:00
      exitTime: Date.now() - 257400000,  // 3天前14:30
      duration: '30分钟',
      fee: 0,
      paymentMethod: '-',
      status: 'COMPLETED' // 免费时段内离开
    },
    {
      recordId: 'PRK20260510004',
      parkingLotName: '协和医院门诊楼地下停车场',
      spaceNumber: 'CHG-001',
      enterTime: Date.now() - 3600000,  // 1小时前
      exitTime: null,
      duration: '1小时(进行中)',
      fee: 6.00,
      paymentMethod: '-',
      status: 'ACTIVE' // 正在充电中
    },
    {
      recordId: 'PRK20260501005',
      parkingLotName: '协和医院门诊楼地下停车场',
      spaceNumber: 'VIP-003',
      enterTime: Date.now() - 432000000, // 5天前09:00
      exitTime: Date.now() - 430200000,  // 5天前09:30
      duration: '30分钟',
      fee: 0,
      paymentMethod: '银行卡',
      status: 'COMPLETED' // 医疗绿色通道免费
    }
  ];
}

/**
 * 获取真实费率配置（基于数据库parking_lot表配置）
 * @returns 费率配置
 */
export function getMockFeeRates(): FeeRateConfig {
  return {
    freeMinutes: 30,
    halfPriceMinutes: 30,
    hourlyRate: 6,
    dailyMax: 60,
    weekendDiscount: 0.8,
    vipDiscount: 0.7
  };
}

/**
 * 计算停车费用（基于真实费率规则）
 * @param parkDurationMinutes 停放时长(分钟)
 * @param config 费率配置
 * @returns 费用详情
 */
function calculateParkingFee(parkDurationMinutes: number, config: FeeRateConfig): FeeDetailBreakdown {
  let totalFee = 0;
  const breakdown: FeeItem[] = [];

  if (parkDurationMinutes <= config.freeMinutes) {
    const item: FeeItem = { period: '0-30分钟(免费)', fee: 0 };
    breakdown.push(item);
    return { totalFee: 0, breakdown, durationMinutes: parkDurationMinutes };
  }

  // 30-60分钟: 半价
  if (parkDurationMinutes > config.freeMinutes) {
    const halfPriceDuration = Math.min(
      config.halfPriceMinutes,
      parkDurationMinutes - config.freeMinutes
    );
    const halfPriceFee = (halfPriceDuration / 60) * config.hourlyRate * 0.5;
    totalFee += halfPriceFee;
    const item: FeeItem = { period: '30-60分钟(半价)', fee: halfPriceFee };
    breakdown.push(item);
  }

  // >60分钟: 全价每小时
  const fullPriceMinutes = Math.max(0, parkDurationMinutes - config.freeMinutes - config.halfPriceMinutes);
  if (fullPriceMinutes > 0) {
    const fullPriceHours = Math.ceil(fullPriceMinutes / 60);
    const fullPriceFee = fullPriceHours * config.hourlyRate;
    totalFee += fullPriceFee;
    const item: FeeItem = { period: '超出小时(全价¥' + config.hourlyRate + '/h)', fee: fullPriceFee };
    breakdown.push(item);
  }

  // 日封顶检查
  const daysParked = Math.ceil(parkDurationMinutes / (24 * 60));
  const dailyCapTotal = daysParked * config.dailyMax;
  if (totalFee > dailyCapTotal) {
    totalFee = dailyCapTotal;
    const item: FeeItem = {
      period: '已达每日封顶¥' + config.dailyMax,
      fee: 0,
      adjustment: dailyCapTotal - (totalFee - dailyCapTotal)
    };
    breakdown.push(item);
  }

  // 周末折扣(周六日8折)
  const now = new Date();
  const isWeekend = now.getDay() === 0 || now.getDay() === 6;
  let discountApplied: string | undefined;
  if (isWeekend) {
    const discount = totalFee * (1 - config.weekendDiscount);
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
