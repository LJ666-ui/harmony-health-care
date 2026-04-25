import { ParkingLot, ParkingSpace, ParkingRecord, FeeDetailBreakdown, FeeRateConfig, IndoorLocation, FeeDetail, FeeItem } from '../models/ParkingModels';

/**
 * 获取Mock停车场数据
 * @returns 停车场列表
 */
export function getMockParkingLots(): ParkingLot[] {
  return [
    {
      id: 'LOT001',
      name: '门诊楼地下停车场',
      address: '医院东门进入后左转100米',
      totalSpaces: 200,
      availableSpaces: 35,
      latitude: 39.908722,
      longitude: 116.39876,
      hourlyRate: 5,
      dailyMaxFee: 50,
      distance: 150,
      floors: 3,
      hasCharging: true,
      hasDisabled: true,
      openTime: '06:00-22:00'
    },
    {
      id: 'LOT002',
      name: '住院部地面停车场',
      address: '住院楼北侧',
      totalSpaces: 150,
      availableSpaces: 20,
      latitude: 39.909512,
      longitude: 116.399234,
      hourlyRate: 3,
      dailyMaxFee: 30,
      distance: 380,
      floors: 1,
      hasCharging: true,
      hasDisabled: false,
      openTime: '00:00-24:00'
    }
  ];
}

/**
 * 获取Mock车位数据
 * @param lotId 停车场ID
 * @returns 车位列表
 */
export function getMockParkingSpaces(lotId: string): ParkingSpace[] {
  const spaces: ParkingSpace[] = [];

  if (lotId === 'LOT001') {
    // A区(NORMAL): A-001~A-020
    for (let i = 1; i <= 20; i++) {
      spaces.push({
        id: `SPACE_A_${i.toString().padStart(3, '0')}`,
        lotId: 'LOT001',
        spaceNumber: `A-${i.toString().padStart(3, '0')}`,
        floor: 'B1',
        zone: 'A区',
        type: 'NORMAL',
        status: getRandomStatus(),
        latitude: 39.908715 + (i * 0.00001),
        longitude: 116.398755 + (i * 0.00001)
      });
    }

    // B区(DISABLED): B-001~B-005
    for (let i = 1; i <= 5; i++) {
      spaces.push({
        id: `SPACE_B_${i.toString().padStart(3, '0')}`,
        lotId: 'LOT001',
        spaceNumber: `B-${i.toString().padStart(3, '0')}`,
        floor: 'B1',
        zone: 'B区',
        type: 'DISABLED',
        status: getRandomStatus(),
        latitude: 39.908715 + (i * 0.00001),
        longitude: 116.398755 + (i * 0.00001)
      });
    }

    // C区(ELECTRIC/CHARGING): C-001~C-010
    for (let i = 1; i <= 10; i++) {
      spaces.push({
        id: `SPACE_C_${i.toString().padStart(3, '0')}`,
        lotId: 'LOT001',
        spaceNumber: `C-${i.toString().padStart(3, '0')}`,
        floor: 'B2',
        zone: 'C区',
        type: 'ELECTRIC',
        status: getRandomStatus(),
        latitude: 39.908715 + (i * 0.00001),
        longitude: 116.398755 + (i * 0.00001)
      });
    }

    // D区(VIP): D-001~D-003
    for (let i = 1; i <= 3; i++) {
      spaces.push({
        id: `SPACE_D_${i.toString().padStart(3, '0')}`,
        lotId: 'LOT001',
        spaceNumber: `D-${i.toString().padStart(3, '0')}`,
        floor: 'B2',
        zone: 'D区',
        type: 'VIP',
        status: getRandomStatus(),
        latitude: 39.908715 + (i * 0.00001),
        longitude: 116.398755 + (i * 0.00001)
      });
    }
  } else if (lotId === 'LOT002') {
    // A区(NORMAL): A-001~A-015
    for (let i = 1; i <= 15; i++) {
      spaces.push({
        id: `SPACE_A_${i.toString().padStart(3, '0')}`,
        lotId: 'LOT002',
        spaceNumber: `A-${i.toString().padStart(3, '0')}`,
        floor: 'F1',
        zone: 'A区',
        type: 'NORMAL',
        status: getRandomStatus(),
        latitude: 39.909512 + (i * 0.00001),
        longitude: 116.399234 + (i * 0.00001)
      });
    }

    // B区(ELECTRIC): B-001~B-005
    for (let i = 1; i <= 5; i++) {
      spaces.push({
        id: `SPACE_B_${i.toString().padStart(3, '0')}`,
        lotId: 'LOT002',
        spaceNumber: `B-${i.toString().padStart(3, '0')}`,
        floor: 'F1',
        zone: 'B区',
        type: 'ELECTRIC',
        status: getRandomStatus(),
        latitude: 39.909512 + (i * 0.00001),
        longitude: 116.399234 + (i * 0.00001)
      });
    }
  }

  return spaces;
}

/**
 * 随机生成车位状态
 * @returns 车位状态
 */
function getRandomStatus(): 'AVAILABLE' | 'OCCUPIED' | 'RESERVED' {
  const rand = Math.random();
  if (rand < 0.4) {
    return 'AVAILABLE'; // 40% 空闲
  } else if (rand < 0.85) {
    return 'OCCUPIED'; // 45% 占用
  } else {
    return 'RESERVED'; // 15% 已预约
  }
}

/**
 * 获取Mock停车记录
 * @returns 停车记录
 */
export function getMockParkingRecord(): ParkingRecord {
  const parkTime = Date.now() - 9300000; // 2小时35分钟前
  const feeDetails = calculateParkingFee(155, getMockFeeRates());
  const indoorLocation: IndoorLocation = {
    building: '门诊楼',
    floor: 'B2',
    nearLandmark: '3号电梯厅旁'
  };
  const feeDetail: FeeDetail = {
    baseFee: feeDetails.totalFee,
    weekendDiscount: 0,
    capDiscount: 0,
    finalFee: feeDetails.totalFee
  };

  return {
    recordId: 'PRK20260424001',
    parkingLotId: 'LOT001',
    parkingLotName: '门诊楼地下停车场',
    spaceId: 'SPACE_A_128',
    spaceNumber: 'A-128',
    floor: 'B2',
    zone: 'A区',
    latitude: 39.908715,
    longitude: 116.398755,
    accuracy: 5,
    indoorLocation: indoorLocation,
    photoUri: 'internal://cache/parking_photo_001.jpg',
    note: 'B2层A区,电梯口左转第一排,白色柱子旁边',
    carDescription: '白色特斯拉 Model 3',
    licensePlate: '京A·88888',
    parkTime: parkTime,
    isActive: true,
    currentFee: feeDetails.totalFee,
    feeDetails: feeDetail
  };
}

/**
 * 获取Mock费率配置
 * @returns 费率配置
 */
export function getMockFeeRates(): FeeRateConfig {
  return {
    freeMinutes: 30,
    halfPriceMinutes: 30,
    hourlyRate: 5,
    dailyMax: 50,
    weekendDiscount: 0.8,
    vipDiscount: 0.7
  };
}

/**
 * 计算停车费用
 * @param parkDurationMinutes 停放时长(分钟)
 * @param config 费率配置
 * @returns 费用详情
 */
function calculateParkingFee(parkDurationMinutes: number, config: FeeRateConfig): FeeDetailBreakdown {
  let totalFee = 0;
  const breakdown: FeeItem[] = [];

  if (parkDurationMinutes <= config.freeMinutes) {
    // 0-30分钟: 免费
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
    const item: FeeItem = { period: '超出小时(全价)', fee: fullPriceFee };
    breakdown.push(item);
  }

  // 日封顶检查
  const daysParked = Math.ceil(parkDurationMinutes / (24 * 60));
  const dailyCapTotal = daysParked * config.dailyMax;
  if (totalFee > dailyCapTotal) {
    totalFee = dailyCapTotal;
    const item: FeeItem = {
      period: '已达每日封顶',
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
