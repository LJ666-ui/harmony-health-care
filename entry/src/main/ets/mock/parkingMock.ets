import { ParkingLot, ParkingSpace, SpaceStatus, SpaceType, ParkingRecord, FeeConfig } from '../parking/ParkingConstants';

export interface ReservationResult {
  success: boolean;
  message: string;
  reservationId?: string;
  spaceId?: string;
  expireTime?: number;
}

export class ParkingMock {
  private static instance: ParkingMock | null = null;

  feeConfig: FeeConfig = {
    freeMinutes: 60,
    hourlyRate: 5,
    dailyCap: 50,
    maxDays: 7
  };

  parkingLots: ParkingLot[] = [
    {
      id: 'LOT_001',
      name: '门诊楼地下停车场',
      address: '北京市东城区协和医院门诊楼地下',
      totalSpaces: 200,
      availableSpaces: 45,
      latitude: 39.9075,
      longitude: 116.4102,
      hourlyRate: 5,
      distance: 120
    },
    {
      id: 'LOT_002',
      name: '住院部地面停车场',
      address: '北京市东城区协和医院住院部北侧',
      totalSpaces: 120,
      availableSpaces: 28,
      latitude: 39.9088,
      longitude: 116.4095,
      hourlyRate: 4,
      distance: 280
    }
  ];

  parkingSpaces: ParkingSpace[] = this.generateAllParkingSpaces();

  activeRecord: ParkingRecord = {
    recordId: 'RECORD_20250420_001',
    spaceId: 'LOT_001_SPACE_128',
    spaceNumber: 'A-128',
    lotId: 'LOT_001',
    lotName: '门诊楼地下停车场',
    floor: 'B2',
    parkingTime: new Date(Date.now() - 2.58 * 60 * 60 * 1000).toISOString(),
    note: '靠近电梯口，红色SUV，车牌京A·88888',
    latitude: 39.90748,
    longitude: 116.41018,
    isActive: true,
    photoUri: '',
    userId: 'USER_001'
  };

  private constructor() {}

  static getInstance(): ParkingMock {
    if (!ParkingMock.instance) {
      ParkingMock.instance = new ParkingMock();
    }
    return ParkingMock.instance;
  }

  getSpacesByLotId(lotId: string): ParkingSpace[] {
    return this.parkingSpaces.filter(space => space.lotId === lotId);
  }

  getAvailableSpacesCount(lotId: string): number {
    return this.getSpacesByLotId(lotId).filter(
      space => space.status === SpaceStatus.AVAILABLE
    ).length;
  }

  getSpaceById(spaceId: string): ParkingSpace | undefined {
    return this.parkingSpaces.find(space => space.id === spaceId);
  }

  getLotById(lotId: string): ParkingLot | undefined {
    return this.parkingLots.find(lot => lot.id === lotId);
  }

  generateReservationResult(spaceId: string, userId: string): ReservationResult {
    const space = this.getSpaceById(spaceId);

    if (!space) {
      const result: ReservationResult = {
        success: false,
        message: '车位不存在'
      };
      return result;
    }

    if (space.status !== SpaceStatus.AVAILABLE) {
      const result: ReservationResult = {
        success: false,
        message: `该车位当前不可用（状态: ${space.status}）`
      };
      return result;
    }

    const reservationId = `RESV_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    const expireTime = Date.now() + 15 * 60 * 1000;

    space.status = SpaceStatus.RESERVED;

    const result: ReservationResult = {
      success: true,
      reservationId: reservationId,
      spaceId: spaceId,
      expireTime: expireTime,
      message: '预约成功，请在15分钟内到达'
    };
    return result;
  }

  calculateFee(parkingTime: string): number {
    const startTime = new Date(parkingTime).getTime();
    const elapsed = Date.now() - startTime;
    const totalMinutes = elapsed / (1000 * 60);
    const chargeableMinutes = Math.max(0, totalMinutes - this.feeConfig.freeMinutes);

    if (chargeableMinutes <= 0) {
      return 0;
    }

    const hours = chargeableMinutes / 60;
    const fee = hours * this.feeConfig.hourlyRate;
    const days = Math.ceil(hours / 24);
    const cappedFee = Math.min(fee, days * this.feeConfig.dailyCap);

    return Math.round(cappedFee * 100) / 100;
  }

  private generateAllParkingSpaces(): ParkingSpace[] {
    return [
      ...this.generateParkingSpaces('LOT_001', 17, 1, 'B1'),
      ...this.generateParkingSpaces('LOT_001', 17, 18, 'B2'),
      ...this.generateParkingSpaces('LOT_001', 16, 35, 'B3'),
      ...this.generateParkingSpaces('LOT_002', 18, 51, 'G'),
      ...this.generateParkingSpaces('LOT_002', 17, 69, 'G')
    ];
  }

  private generateParkingSpaces(lotId: string, count: number, startNumber: number, floor: string): ParkingSpace[] {
    const spaces: ParkingSpace[] = [];

    for (let i = 0; i < count; i++) {
      const statusRandom = Math.random();
      let status: SpaceStatus;

      if (statusRandom < 0.55) {
        status = SpaceStatus.AVAILABLE;
      } else if (statusRandom < 0.88) {
        status = SpaceStatus.OCCUPIED;
      } else {
        status = SpaceStatus.RESERVED;
      }

      const typeRandom = Math.random();
      let type: SpaceType;

      if (typeRandom < 0.75) {
        type = SpaceType.NORMAL;
      } else if (typeRandom < 0.85) {
        type = SpaceType.DISABLED;
      } else if (typeRandom < 0.95) {
        type = SpaceType.ELECTRIC;
      } else {
        type = SpaceType.CHARGING;
      }

      const lot = this.parkingLots.find(l => l.id === lotId);
      const baseLat = lot ? lot.latitude : 39.9075;
      const baseLng = lot ? lot.longitude : 116.4102;

      spaces.push({
        id: `${lotId}_SPACE_${String(startNumber + i).padStart(3, '0')}`,
        lotId: lotId,
        spaceNumber: `A-${String(startNumber + i).padStart(3, '0')}`,
        status: status,
        type: type,
        latitude: baseLat + (Math.random() - 0.5) * 0.001,
        longitude: baseLng + (Math.random() - 0.5) * 0.001,
        floor: floor
      });
    }

    return spaces;
  }
}

export const parkingMockData: ParkingMock = ParkingMock.getInstance();
