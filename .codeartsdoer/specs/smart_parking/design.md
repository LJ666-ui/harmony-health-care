> hvigor ERROR: Failed :entry:default@PreviewArkTS... 
> hvigor ERROR: 10605030 ArkTS Compiler Error
Error Message: Structural typing is not supported (arkts-no-structural-typing) At File: E:/HMOS6.0/Github/harmony-health-care/entry/src/main/ets/pages/Login.ets:120:19


* Try:
> Run with --stacktrace option to get the stack trace.
> Run with --debug option to get more log output.

> hvigor ERROR: BUILD FAILED in 53 s 297 ms 

Process finished with exit code -1
# 技术设计文档

## 文档信息
- **功能名称**: 智慧停车+反向寻车系统
- **版本**: v1.0
- **创建日期**: 2024-01-15
- **最后更新**: 2024-01-15
- **设计负责人**: 开发团队

---

## 1. 设计概述

### 1.1 设计目标

本技术设计旨在为"智慧停车+反向寻车系统"提供清晰、可实现的架构方案,实现以下目标:

1. **高可用性**: 确保核心功能(GPS定位、导航、计费)在弱网环境下仍可正常使用
2. **类型安全**: 使用ArkTS强类型系统,杜绝运行时类型错误
3. **性能优化**: 关键操作(定位、导航、计费)响应时间<3秒,AR导航帧率≥10fps
4. **可扩展性**: 模块化设计,便于后续集成真实后端服务和多种导航算法
5. **无障碍支持**: 提供大字体、高对比度、语音提示等无障碍功能

### 1.2 设计原则

遵循以下核心设计原则:

1. **单一职责原则(SRP)**: 每个模块只负责一个功能领域(如ParkingService只负责停车业务逻辑)
2. **开闭原则(OCP)**: 导航模式、计费策略等使用策略模式,支持扩展无需修改现有代码
3. **依赖倒置原则(DIP)**: 高层模块依赖抽象接口,而非具体实现
4. **类型安全原则**: 禁止使用`any`类型,所有函数参数和返回值必须有明确类型注解
5. **空值安全原则**: 使用可选链`?.`和空值合并`??`处理可能为空的值
6. **性能优化原则**: 合理使用缓存、懒加载、异步处理提升性能
7. **最小权限原则**: 仅请求必要的系统权限,权限拒绝时提供降级方案

### 1.3 技术选型

| 技术组件 | 选择方案 | 选择理由 |
|---------|---------|---------|
| **开发语言** | ArkTS | HarmonyOS官方推荐语言,支持TypeScript语法,强类型安全 |
| **定位服务** | @ohos.geolocationManager | 官方定位API,支持GPS定位,精度<100米 |
| **地图服务** | @kit.MapKit | 官方地图组件,支持路线规划和实时导航 |
| **相机服务** | @kit.CameraKit | 官方相机API,支持实时画面获取和AR叠加 |
| **传感器服务** | @kit.SensorKit | 官方传感器API,支持陀螺仪和指南针数据 |
| **权限管理** | @kit.AbilityAccessCtrl | 官方权限管理API,支持运行时权限请求 |
| **数据存储** | Preferences | 轻量级本地存储,适合缓存和配置数据 |
| **状态管理** | @State/@Prop/@Link | ArkUI官方状态管理,响应式数据更新 |
| **导航模式** | 策略模式 | 支持地图/AR/文字三种模式切换,易于扩展 |
| **计费策略** | 策略模式 | 支持阶梯计费、周末折扣、封顶等复杂规则 |

---

## 2. 系统架构

### 2.1 整体架构

系统采用分层架构设计,自顶向下分为:

```
┌─────────────────────────────────────────────────────────┐
│                     表现层 (Presentation)                │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐       │
│  │ ParkingList │ │ Reservation │ │ FindCarPage │       │
│  │   Page      │ │   Page      │ │   Page      │       │
│  └─────────────┘ └─────────────┘ └─────────────┘       │
└─────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────┐
│                     业务层 (Business)                    │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐       │
│  │ Parking     │ │ Reservation │ │  Navigation │       │
│  │  Service    │ │  Service    │ │   Engine    │       │
│  └─────────────┘ └─────────────┘ └─────────────┘       │
│  ┌─────────────┐ ┌─────────────┐                     │
│  │  Fee        │ │  Location   │                     │
│  │  Calculator │ │  Manager    │                     │
│  └─────────────┘ └─────────────┘                     │
└─────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────┐
│                     数据层 (Data)                        │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐       │
│  │ Preferences │ │  Mock Data  │ │  Data Model │       │
│  │   Storage   │ │  Provider   │ │  Repository │       │
│  └─────────────┘ └─────────────┘ └─────────────┘       │
└─────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────┐
│                   基础设施层 (Infrastructure)            │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐       │
│  │  Geo-       │ │   MapKit    │ │  CameraKit  │       │
│  │  Location   │ │   Service   │ │   Service   │       │
│  └─────────────┘ └─────────────┘ └─────────────┘       │
│  ┌─────────────┐ ┌─────────────┐                     │
│  │  SensorKit  │ │  Permission │                     │
│  │   Service   │ │  Manager    │                     │
│  └─────────────┘ └─────────────┘                     │
└─────────────────────────────────────────────────────────┘
```

**架构说明**:
- **表现层**: 负责UI展示和用户交互,使用ArkUI组件构建页面
- **业务层**: 包含核心业务逻辑,如停车服务、预约服务、导航引擎、计费计算器等
- **数据层**: 负责数据存储和访问,包括本地缓存、Mock数据、数据模型定义
- **基础设施层**: 封装系统API,提供定位、地图、相机、传感器、权限等基础服务

### 2.2 模块划分

系统划分为以下核心模块:

| 模块名称 | 职责 | 主要类/接口 |
|---------|------|------------|
| **ParkingService** | 停车业务核心服务,单例模式 | `ParkingService`, `IParkingService` |
| **ReservationService** | 车位预约业务服务 | `ReservationService`, `IReservationService` |
| **NavigationEngine** | 导航引擎,支持三种导航模式 | `NavigationEngine`, `INavigationStrategy` |
| **FeeCalculator** | 计费计算器,实现阶梯计费 | `FeeCalculator`, `IFeeStrategy` |
| **LocationManager** | 定位管理器,封装GPS定位 | `LocationManager`, `ILocationProvider` |
| **ParkingConstants** | 常量定义(费率、规则、错误码) | `ParkingConstants` |
| **ParkingModels** | 数据模型定义 | `ParkingLot`, `ParkingSpace`, `ParkingRecord` |
| **DataRepository** | 数据仓库,统一数据访问 | `DataRepository`, `IDataProvider` |
| **PermissionManager** | 权限管理器,封装权限请求 | `PermissionManager`, `IPermissionHandler` |

### 2.3 数据流

#### 停车场发现数据流
```
用户打开页面 → ParkingService → LocationManager → @ohos.geolocationManager
                                              ↓
                                          获取GPS坐标
                                              ↓
                                    DataRepository.getMockParkingLots()
                                              ↓
                                    计算距离(Haversine公式)
                                              ↓
                                    按距离排序
                                              ↓
                                    缓存到Preferences(5分钟)
                                              ↓
                                    返回停车场列表
                                              ↓
                                    UI展示
```

#### 车位预约数据流
```
用户点击预约 → ParkingService → ReservationService
                                     ↓
                            验证登录状态 → 未登录跳转登录页
                                     ↓
                            验证取消次数 → 超过3次拒绝
                                     ↓
                            更新车位状态 → AVAILABLE → RESERVED
                                     ↓
                            启动15分钟倒计时定时器
                                     ↓
                            到期前2分钟提醒
                                     ↓
                            超时自动释放 → RESERVED → AVAILABLE
                                     ↓
                            返回预约结果
                                     ↓
                            UI展示倒计时
```

#### 智能计费数据流
```
车辆入场 → ParkingService → 创建ParkingRecord(状态:PARKING)
                                     ↓
                            1秒后更新状态 → ACTIVE
                                     ↓
                            启动每秒费用更新定时器
                                     ↓
                            FeeCalculator.calculateFee(停放时长)
                                     ↓
                            应用计费策略:
                              - 0-30分钟:免费
                              - 30-60分钟:半价
                              - >60分钟:全价
                              - 周末8折
                              - 每日封顶50元
                                     ↓
                            更新currentFee
                                     ↓
                            UI展示实时费用
```

#### 反向寻车导航数据流
```
用户选择导航模式 → NavigationEngine → 根据模式选择策略
                                              ↓
        ┌─────────────────┬──────────────────┼─────────────────┐
        ↓                 ↓                  ↓                 ↓
   MapKitStrategy  ARNavigationStrategy  TextGuideStrategy  (其他策略)
        ↓                 ↓                  ↓
    获取地图路线    XComponent+Canvas   生成分步指引
    显示导航       实时箭头更新        当前步高亮
        ↓                 ↓                  ↓
        └─────────────────┴──────────────────┘
                              ↓
                    到达检测(距离<5米)
                              ↓
                    提示"您已到达停车位!"
                              ↓
                    导航结束
```

---

## 3. 核心模块设计

### 3.1 ParkingService(停车服务)

#### 3.1.1 职责定义
ParkingService是停车业务的核心服务,采用单例模式,负责:
- 停车场发现与选择
- 车位预约管理
- 停车记录全生命周期管理
- 费用计算与更新
- 提供统一的业务接口给表现层

#### 3.1.2 接口设计

```typescript
/**
 * 停车服务接口
 */
interface IParkingService {
  /**
   * 获取附近停车场列表
   * @param forceRefresh 是否强制刷新(忽略缓存)
   * @returns 停车场列表,按距离升序排序
   */
  getNearbyParkingLots(forceRefresh?: boolean): Promise<ParkingLot[]>;

  /**
   * 获取指定停车场的车位列表
   * @param lotId 停车场ID
   * @returns 车位列表
   */
  getParkingSpaces(lotId: string): Promise<ParkingSpace[]>;

  /**
   * 预约车位
   * @param spaceId 车位ID
   * @returns 预约结果
   */
  reserveSpace(spaceId: string): Promise<ReservationResult>;

  /**
   * 取消车位预约
   * @param spaceId 车位ID
   * @returns 操作结果
   */
  cancelReservation(spaceId: string): Promise<OperationResult>;

  /**
   * 创建停车记录(车辆入场)
   * @param record 停车记录信息
   * @returns 创建的停车记录
   */
  createParkingRecord(record: ParkingRecordInput): Promise<ParkingRecord>;

  /**
   * 获取当前活跃的停车记录
   * @returns 当前停车记录,不存在返回null
   */
  getCurrentParkingRecord(): Promise<ParkingRecord | null>;

  /**
   * 完成停车记录(离场)
   * @param recordId 记录ID
   * @returns 完成的停车记录
   */
  completeParkingRecord(recordId: string): Promise<ParkingRecord>;

  /**
   * 订阅停车记录费用更新
   * @param callback 费用更新回调
   * @returns 取消订阅函数
   */
  subscribeFeeUpdate(callback: (fee: number, record: ParkingRecord) => void): () => void;
}

/**
 * 预约结果
 */
interface ReservationResult {
  success: boolean;
  spaceId: string;
  expireTime: number; // 过期时间戳
  error?: AppError;
}

/**
 * 操作结果
 */
interface OperationResult {
  success: boolean;
  message?: string;
  error?: AppError;
}
```

#### 3.1.3 类设计

```typescript
/**
 * 停车服务实现(单例)
 */
class ParkingService implements IParkingService {
  private static instance: ParkingService;
  private locationManager: LocationManager;
  private reservationService: ReservationService;
  private feeCalculator: FeeCalculator;
  private dataRepository: DataRepository;
  private feeUpdateTimer?: number;
  private feeUpdateCallbacks: Set<(fee: number, record: ParkingRecord) => void>;

  private constructor() {
    this.locationManager = LocationManager.getInstance();
    this.reservationService = ReservationService.getInstance();
    this.feeCalculator = FeeCalculator.getInstance();
    this.dataRepository = DataRepository.getInstance();
    this.feeUpdateCallbacks = new Set();
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
   * 获取附近停车场列表
   */
  async getNearbyParkingLots(forceRefresh: boolean = false): Promise<ParkingLot[]> {
    try {
      // 检查缓存
      if (!forceRefresh) {
        const cached = await this.dataRepository.getCachedParkingLots();
        if (cached && !this.isCacheExpired(cached.timestamp)) {
          return cached.lots;
        }
      }

      // 获取用户位置
      const userLocation = await this.locationManager.getCurrentLocation();

      // 获取Mock停车场数据
      let lots = await this.dataRepository.getMockParkingLots();

      // 计算距离并排序
      lots = this.calculateDistancesAndSort(lots, userLocation);

      // 缓存结果
      await this.dataRepository.cacheParkingLots(lots);

      return lots;
    } catch (error) {
      console.error('Failed to get nearby parking lots:', error);
      throw new ParkingServiceError('Failed to get parking lots', error);
    }
  }

  /**
   * 获取指定停车场的车位列表
   */
  async getParkingSpaces(lotId: string): Promise<ParkingSpace[]> {
    try {
      return await this.dataRepository.getMockParkingSpaces(lotId);
    } catch (error) {
      console.error('Failed to get parking spaces:', error);
      throw new ParkingServiceError('Failed to get parking spaces', error);
    }
  }

  /**
   * 预约车位
   */
  async reserveSpace(spaceId: string): Promise<ReservationResult> {
    try {
      // 验证登录状态
      if (!await this.isUserLoggedIn()) {
        return {
          success: false,
          spaceId,
          expireTime: 0,
          error: new AuthError('User not logged in')
        };
      }

      return await this.reservationService.reserveSpace(spaceId);
    } catch (error) {
      console.error('Failed to reserve space:', error);
      throw new ParkingServiceError('Failed to reserve space', error);
    }
  }

  /**
   * 取消车位预约
   */
  async cancelReservation(spaceId: string): Promise<OperationResult> {
    try {
      return await this.reservationService.cancelReservation(spaceId);
    } catch (error) {
      console.error('Failed to cancel reservation:', error);
      throw new ParkingServiceError('Failed to cancel reservation', error);
    }
  }

  /**
   * 创建停车记录
   */
  async createParkingRecord(record: ParkingRecordInput): Promise<ParkingRecord> {
    try {
      const parkingRecord = await this.dataRepository.createParkingRecord(record);
      
      // 启动费用更新定时器
      this.startFeeUpdateTimer(parkingRecord);
      
      return parkingRecord;
    } catch (error) {
      console.error('Failed to create parking record:', error);
      throw new ParkingServiceError('Failed to create parking record', error);
    }
  }

  /**
   * 获取当前活跃的停车记录
   */
  async getCurrentParkingRecord(): Promise<ParkingRecord | null> {
    try {
      return await this.dataRepository.getCurrentParkingRecord();
    } catch (error) {
      console.error('Failed to get current parking record:', error);
      throw new ParkingServiceError('Failed to get current parking record', error);
    }
  }

  /**
   * 完成停车记录
   */
  async completeParkingRecord(recordId: string): Promise<ParkingRecord> {
    try {
      // 停止费用更新定时器
      this.stopFeeUpdateTimer();
      
      return await this.dataRepository.completeParkingRecord(recordId);
    } catch (error) {
      console.error('Failed to complete parking record:', error);
      throw new ParkingServiceError('Failed to complete parking record', error);
    }
  }

  /**
   * 订阅停车记录费用更新
   */
  subscribeFeeUpdate(callback: (fee: number, record: ParkingRecord) => void): () => void {
    this.feeUpdateCallbacks.add(callback);
    
    // 返回取消订阅函数
    return () => {
      this.feeUpdateCallbacks.delete(callback);
    };
  }

  /**
   * 计算距离并排序
   */
  private calculateDistancesAndSort(
    lots: ParkingLot[],
    userLocation: Location
  ): ParkingLot[] {
    return lots
      .map(lot => ({
        ...lot,
        distance: this.calculateDistance(userLocation, {
          latitude: lot.latitude,
          longitude: lot.longitude
        })
      }))
      .sort((a, b) => a.distance - b.distance);
  }

  /**
   * 计算两点之间的距离(Haversine公式)
   */
  private calculateDistance(from: Location, to: Location): number {
    const R = 6371000; // 地球半径(米)
    const φ1 = (from.latitude * Math.PI) / 180;
    const φ2 = (to.latitude * Math.PI) / 180;
    const Δφ = ((to.latitude - from.latitude) * Math.PI) / 180;
    const Δλ = ((to.longitude - from.longitude) * Math.PI) / 180;

    const a = Math.sin(Δφ / 2) * Math.sin(Δφ / 2) +
              Math.cos(φ1) * Math.cos(φ2) *
              Math.sin(Δλ / 2) * Math.sin(Δλ / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

    return R * c; // 返回距离(米)
  }

  /**
   * 检查缓存是否过期
   */
  private isCacheExpired(timestamp: number): boolean {
    const CACHE_DURATION = 5 * 60 * 1000; // 5分钟
    return Date.now() - timestamp > CACHE_DURATION;
  }

  /**
   * 启动费用更新定时器
   */
  private startFeeUpdateTimer(record: ParkingRecord): void {
    this.stopFeeUpdateTimer(); // 先停止之前的定时器
    
    this.feeUpdateTimer = setInterval(async () => {
      try {
        const updatedRecord = await this.dataRepository.getParkingRecord(record.recordId);
        if (updatedRecord) {
          const duration = Date.now() - updatedRecord.parkTime;
          const fee = this.feeCalculator.calculateFee(
            duration,
            updatedRecord.parkTime,
            updatedRecord.feeDetails
          );
          
          // 更新记录
          updatedRecord.currentFee = fee;
          await this.dataRepository.updateParkingRecord(updatedRecord);
          
          // 通知订阅者
          this.feeUpdateCallbacks.forEach(callback => {
            callback(fee, updatedRecord);
          });
        }
      } catch (error) {
        console.error('Failed to update fee:', error);
      }
    }, 1000); // 每秒更新一次
  }

  /**
   * 停止费用更新定时器
   */
  private stopFeeUpdateTimer(): void {
    if (this.feeUpdateTimer) {
      clearInterval(this.feeUpdateTimer);
      this.feeUpdateTimer = undefined;
    }
  }

  /**
   * 检查用户是否已登录
   */
  private async isUserLoggedIn(): Promise<boolean> {
    // TODO: 实现登录状态检查
    return true;
  }
}
```

#### 3.1.4 关键算法

**Haversine距离计算算法**:
```typescript
/**
 * 计算两点之间的球面距离(Haversine公式)
 * 
 * 公式说明:
 * a = sin²(Δφ/2) + cos(φ1)·cos(φ2)·sin²(Δλ/2)
 * c = 2·atan2(√a, √(1−a))
 * d = R·c
 * 
 * 其中:
 * - φ: 纬度(弧度)
 * - λ: 经度(弧度)
 * - Δφ: 纬度差(弧度)
 * - Δλ: 经度差(弧度)
 * - R: 地球半径(6371000米)
 * - d: 距离(米)
 * 
 * @param from 起点坐标
 * @param to 终点坐标
 * @returns 距离(米),精度<5米
 */
function calculateDistance(from: Location, to: Location): number {
  const R = 6371000; // 地球半径(米)
  
  // 将角度转换为弧度
  const φ1 = (from.latitude * Math.PI) / 180;
  const φ2 = (to.latitude * Math.PI) / 180;
  const Δφ = ((to.latitude - from.latitude) * Math.PI) / 180;
  const Δλ = ((to.longitude - from.longitude) * Math.PI) / 180;
  
  // Haversine公式
  const a = Math.sin(Δφ / 2) * Math.sin(Δφ / 2) +
            Math.cos(φ1) * Math.cos(φ2) *
            Math.sin(Δλ / 2) * Math.sin(Δλ / 2);
  
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  
  return R * c; // 返回距离(米)
}
```

---

### 3.2 NavigationEngine(导航引擎)

#### 3.2.1 职责定义
NavigationEngine负责反向寻车导航功能,采用策略模式支持多种导航模式:
- 地图导航(MapKit)
- AR实景导航(XComponent+Canvas)
- 文字指引(离线可用)

#### 3.2.2 接口设计

```typescript
/**
 * 导航策略接口
 */
interface INavigationStrategy {
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
 * 导航状态
 */
enum NavigationStatus {
  IDLE = 'idle',
  NAVIGATING = 'navigating',
  PAUSED = 'paused',
  ARRIVED = 'arrived',
  ERROR = 'error'
}
```

#### 3.2.3 类设计

```typescript
/**
 * 导航引擎
 */
class NavigationEngine {
  private static instance: NavigationEngine;
  private currentStrategy: INavigationStrategy | null = null;
  private locationManager: LocationManager;
  private strategies: Map<NavigationMode, INavigationStrategy>;

  private constructor() {
    this.locationManager = LocationManager.getInstance();
    this.strategies = new Map();
    this.initializeStrategies();
  }

  /**
   * 获取单例实例
   */
  static getInstance(): NavigationEngine {
    if (!NavigationEngine.instance) {
      NavigationEngine.instance = new NavigationEngine();
    }
    return NavigationEngine.instance;
  }

  /**
   * 初始化导航策略
   */
  private initializeStrategies(): void {
    this.strategies.set(NavigationMode.MAP, new MapKitNavigationStrategy());
    this.strategies.set(NavigationMode.AR, new ARNavigationStrategy());
    this.strategies.set(NavigationMode.TEXT, new TextGuideStrategy());
  }

  /**
   * 启动导航
   * @param mode 导航模式
   * @param end 终点坐标
   * @param callbacks 回调函数
   */
  async startNavigation(
    mode: NavigationMode,
    end: Location,
    callbacks: NavigationCallbacks
  ): Promise<void> {
    try {
      // 获取当前位置
      const start = await this.locationManager.getCurrentLocation();

      // 停止之前的导航
      this.stopNavigation();

      // 获取对应的策略
      const strategy = this.strategies.get(mode);
      if (!strategy) {
        throw new NavigationError(`Navigation mode ${mode} not supported`);
      }

      // 启动导航
      this.currentStrategy = strategy;
      await strategy.start(
        start,
        end,
        callbacks.onUpdate,
        callbacks.onArrival
      );
    } catch (error) {
      console.error('Failed to start navigation:', error);
      throw new NavigationError('Failed to start navigation', error);
    }
  }

  /**
   * 停止导航
   */
  stopNavigation(): void {
    if (this.currentStrategy) {
      this.currentStrategy.stop();
      this.currentStrategy = null;
    }
  }

  /**
   * 暂停导航
   */
  pauseNavigation(): void {
    if (this.currentStrategy) {
      this.currentStrategy.pause();
    }
  }

  /**
   * 恢复导航
   */
  resumeNavigation(): void {
    if (this.currentStrategy) {
      this.currentStrategy.resume();
    }
  }

  /**
   * 获取导航状态
   */
  getNavigationStatus(): NavigationStatus {
    return this.currentStrategy?.getStatus() ?? NavigationStatus.IDLE;
  }
}

/**
 * 导航回调
 */
interface NavigationCallbacks {
  onUpdate?: (position: Location, distance: number) => void;
  onArrival?: () => void;
  onError?: (error: Error) => void;
}

/**
 * 导航模式
 */
enum NavigationMode {
  MAP = 'map',
  AR = 'ar',
  TEXT = 'text'
}
```

#### 3.2.4 导航策略实现

**地图导航策略(MapKit)**:
```typescript
/**
 * 地图导航策略
 */
class MapKitNavigationStrategy implements INavigationStrategy {
  private status: NavigationStatus = NavigationStatus.IDLE;
  private mapController?: map.MapComponentController;
  private locationTimer?: number;
  private arrivalThreshold: number = 5; // 到达阈值(米)

  async start(
    start: Location,
    end: Location,
    onUpdate?: (position: Location, distance: number) => void,
    onArrival?: () => void
  ): Promise<void> {
    this.status = NavigationStatus.NAVIGATING;

    // 初始化地图组件
    this.mapController = await this.initializeMap();

    // 绘制起点和终点
    this.drawMarkers(start, end);

    // 规划路线
    await this.planRoute(start, end);

    // 启动位置更新
    this.startLocationTracking(end, onUpdate, onArrival);
  }

  stop(): void {
    this.status = NavigationStatus.IDLE;
    if (this.locationTimer) {
      clearInterval(this.locationTimer);
      this.locationTimer = undefined;
    }
  }

  pause(): void {
    this.status = NavigationStatus.PAUSED;
  }

  resume(): void {
    this.status = NavigationStatus.NAVIGATING;
  }

  getStatus(): NavigationStatus {
    return this.status;
  }

  /**
   * 初始化地图
   */
  private async initializeMap(): Promise<map.MapComponentController> {
    // TODO: 使用@kit.MapKit初始化地图组件
    throw new Error('Not implemented');
  }

  /**
   * 绘制标记点
   */
  private drawMarkers(start: Location, end: Location): void {
    // TODO: 在地图上绘制起点和终点标记
  }

  /**
   * 规划路线
   */
  private async planRoute(start: Location, end: Location): Promise<void> {
    // TODO: 使用MapKit路线规划API
  }

  /**
   * 启动位置跟踪
   */
  private startLocationTracking(
    target: Location,
    onUpdate?: (position: Location, distance: number) => void,
    onArrival?: () => void
  ): void {
    const locationManager = LocationManager.getInstance();
    
    this.locationTimer = setInterval(async () => {
      try {
        const currentPosition = await locationManager.getCurrentLocation();
        const distance = this.calculateDistance(currentPosition, target);
        
        // 更新回调
        onUpdate?.(currentPosition, distance);
        
        // 到达检测
        if (distance <= this.arrivalThreshold) {
          onArrival?.();
          this.stop();
        }
      } catch (error) {
        console.error('Failed to track location:', error);
      }
    }, 1000); // 每秒更新
  }

  /**
   * 计算距离
   */
  private calculateDistance(from: Location, to: Location): number {
    // 使用Haversine公式
    const R = 6371000;
    const φ1 = (from.latitude * Math.PI) / 180;
    const φ2 = (to.latitude * Math.PI) / 180;
    const Δφ = ((to.latitude - from.latitude) * Math.PI) / 180;
    const Δλ = ((to.longitude - from.longitude) * Math.PI) / 180;
    const a = Math.sin(Δφ / 2) * Math.sin(Δφ / 2) +
              Math.cos(φ1) * Math.cos(φ2) *
              Math.sin(Δλ / 2) * Math.sin(Δλ / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
  }
}
```

**AR导航策略(XComponent+Canvas)**:
```typescript
/**
 * AR导航策略
 */
class ARNavigationStrategy implements INavigationStrategy {
  private status: NavigationStatus = NavigationStatus.IDLE;
  private xComponentController?: XComponentController;
  private canvasContext?: CanvasRenderingContext2D;
  private sensorManager?: SensorManager;
  private updateTimer?: number;
  private arrowAngle: number = 0; // 箭头角度(度)
  private arrivalThreshold: number = 5; // 到达阈值(米)

  async start(
    start: Location,
    end: Location,
    onUpdate?: (position: Location, distance: number) => void,
    onArrival?: () => void
  ): Promise<void> {
    this.status = NavigationStatus.NAVIGATING;

    // 初始化相机(XComponent)
    this.xComponentController = await this.initializeCamera();

    // 初始化Canvas
    this.canvasContext = await this.initializeCanvas();

    // 初始化传感器(陀螺仪+指南针)
    this.sensorManager = await this.initializeSensors();

    // 启动AR更新循环(每100ms)
    this.startARUpdateLoop(end, onUpdate, onArrival);
  }

  stop(): void {
    this.status = NavigationStatus.IDLE;
    if (this.updateTimer) {
      clearInterval(this.updateTimer);
      this.updateTimer = undefined;
    }
    // 释放相机资源
    this.releaseCamera();
    // 停止传感器
    this.sensorManager?.stop();
  }

  pause(): void {
    this.status = NavigationStatus.PAUSED;
  }

  resume(): void {
    this.status = NavigationStatus.NAVIGATING;
  }

  getStatus(): NavigationStatus {
    return this.status;
  }

  /**
   * 初始化相机
   */
  private async initializeCamera(): Promise<XComponentController> {
    // TODO: 使用@kit.CameraKit初始化相机
    throw new Error('Not implemented');
  }

  /**
   * 初始化Canvas
   */
  private async initializeCanvas(): Promise<CanvasRenderingContext2D> {
    // TODO: 初始化Canvas用于绘制箭头
    throw new Error('Not implemented');
  }

  /**
   * 初始化传感器
   */
  private async initializeSensors(): Promise<SensorManager> {
    // TODO: 使用@kit.SensorKit初始化陀螺仪和指南针
    throw new Error('Not implemented');
  }

  /**
   * 启动AR更新循环
   */
  private startARUpdateLoop(
    target: Location,
    onUpdate?: (position: Location, distance: number) => void,
    onArrival?: () => void
  ): void {
    const locationManager = LocationManager.getInstance();
    
    this.updateTimer = setInterval(async () => {
      try {
        // 获取当前位置
        const currentPosition = await locationManager.getCurrentLocation();
        const distance = this.calculateDistance(currentPosition, target);
        
        // 获取目标方向(相对于当前朝向)
        const targetDirection = this.calculateTargetDirection(currentPosition, target);
        
        // 获取设备朝向(来自陀螺仪和指南针)
        const deviceOrientation = this.sensorManager?.getDeviceOrientation() ?? 0;
        
        // 计算箭头角度
        this.arrowAngle = targetDirection - deviceOrientation;
        
        // 绘制箭头
        this.drawArrow();
        
        // 更新回调
        onUpdate?.(currentPosition, distance);
        
        // 到达检测
        if (distance <= this.arrivalThreshold) {
          onArrival?.();
          this.stop();
        }
      } catch (error) {
        console.error('Failed to update AR:', error);
      }
    }, 100); // 每100ms更新一次
  }

  /**
   * 计算目标方向
   */
  private calculateTargetDirection(from: Location, to: Location): number {
    const Δλ = ((to.longitude - from.longitude) * Math.PI) / 180;
    const φ1 = (from.latitude * Math.PI) / 180;
    const φ2 = (to.latitude * Math.PI) / 180;
    
    const y = Math.sin(Δλ) * Math.cos(φ2);
    const x = Math.cos(φ1) * Math.sin(φ2) -
              Math.sin(φ1) * Math.cos(φ2) * Math.cos(Δλ);
    
    const bearing = Math.atan2(y, x) * 180 / Math.PI;
    
    // 转换为0-360度
    return (bearing + 360) % 360;
  }

  /**
   * 绘制箭头
   */
  private drawArrow(): void {
    if (!this.canvasContext) return;
    
    const ctx = this.canvasContext;
    const centerX = ctx.canvas.width / 2;
    const centerY = ctx.canvas.height / 2;
    const arrowSize = 50;
    
    // 清除画布
    ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height);
    
    // 绘制箭头
    ctx.save();
    ctx.translate(centerX, centerY);
    ctx.rotate((this.arrowAngle * Math.PI) / 180);
    
    ctx.beginPath();
    ctx.moveTo(0, -arrowSize);
    ctx.lineTo(arrowSize / 2, arrowSize / 2);
    ctx.lineTo(-arrowSize / 2, arrowSize / 2);
    ctx.closePath();
    
    ctx.fillStyle = '#FF6B6B';
    ctx.fill();
    ctx.strokeStyle = '#FFFFFF';
    ctx.lineWidth = 2;
    ctx.stroke();
    
    ctx.restore();
  }

  /**
   * 释放相机资源
   */
  private releaseCamera(): void {
    // TODO: 释放相机资源
  }

  /**
   * 计算距离
   */
  private calculateDistance(from: Location, to: Location): number {
    // 使用Haversine公式
    const R = 6371000;
    const φ1 = (from.latitude * Math.PI) / 180;
    const φ2 = (to.latitude * Math.PI) / 180;
    const Δφ = ((to.latitude - from.latitude) * Math.PI) / 180;
    const Δλ = ((to.longitude - from.longitude) * Math.PI) / 180;
    const a = Math.sin(Δφ / 2) * Math.sin(Δφ / 2) +
              Math.cos(φ1) * Math.cos(φ2) *
              Math.sin(Δλ / 2) * Math.sin(Δλ / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
  }
}
```

**文字指引策略**:
```typescript
/**
 * 文字指引策略
 */
class TextGuideStrategy implements INavigationStrategy {
  private status: NavigationStatus = NavigationStatus.IDLE;
  private currentStepIndex: number = 0;
  private steps: Step[] = [];
  private locationTimer?: number;
  private arrivalThreshold: number = 5; // 到达阈值(米)

  async start(
    start: Location,
    end: Location,
    onUpdate?: (position: Location, distance: number) => void,
    onArrival?: () => void
  ): Promise<void> {
    this.status = NavigationStatus.NAVIGATING;
    this.currentStepIndex = 0;

    // 生成导航步骤
    this.steps = this.generateSteps(start, end);

    // 启动位置跟踪
    this.startLocationTracking(end, onUpdate, onArrival);
  }

  stop(): void {
    this.status = NavigationStatus.IDLE;
    if (this.locationTimer) {
      clearInterval(this.locationTimer);
      this.locationTimer = undefined;
    }
  }

  pause(): void {
    this.status = NavigationStatus.PAUSED;
  }

  resume(): void {
    this.status = NavigationStatus.NAVIGATING;
  }

  getStatus(): NavigationStatus {
    return this.status;
  }

  /**
   * 获取导航步骤
   */
  getSteps(): Step[] {
    return this.steps.map((step, index) => ({
      ...step,
      isCompleted: index < this.currentStepIndex
    }));
  }

  /**
   * 生成导航步骤
   */
  private generateSteps(start: Location, end: Location): Step[] {
    // TODO: 根据起点和终点生成导航步骤
    // 示例步骤
    return [
      {
        stepId: '1',
        instruction: '从当前位置向北走20米',
        distance: 20,
        isCompleted: false
      },
      {
        stepId: '2',
        instruction: '左转,向东走30米',
        distance: 30,
        isCompleted: false
      },
      {
        stepId: '3',
        instruction: '进入A区,向前走10米',
        distance: 10,
        isCompleted: false
      },
      {
        stepId: '4',
        instruction: '到达停车位',
        distance: 0,
        isCompleted: false
      }
    ];
  }

  /**
   * 启动位置跟踪
   */
  private startLocationTracking(
    target: Location,
    onUpdate?: (position: Location, distance: number) => void,
    onArrival?: () => void
  ): void {
    const locationManager = LocationManager.getInstance();
    
    this.locationTimer = setInterval(async () => {
      try {
        const currentPosition = await locationManager.getCurrentLocation();
        const distance = this.calculateDistance(currentPosition, target);
        
        // 更新回调
        onUpdate?.(currentPosition, distance);
        
        // 检查当前步骤是否完成
        this.checkStepCompletion(currentPosition);
        
        // 到达检测
        if (distance <= this.arrivalThreshold) {
          onArrival?.();
          this.stop();
        }
      } catch (error) {
        console.error('Failed to track location:', error);
      }
    }, 1000); // 每秒更新
  }

  /**
   * 检查步骤完成情况
   */
  private checkStepCompletion(position: Location): void {
    const currentStep = this.steps[this.currentStepIndex];
    if (!currentStep || currentStep.isCompleted) return;
    
    // TODO: 检查是否到达当前步骤的目标位置
    // 如果到达,标记为完成并进入下一步
    // currentStep.isCompleted = true;
    // this.currentStepIndex++;
  }

  /**
   * 计算距离
   */
  private calculateDistance(from: Location, to: Location): number {
    // 使用Haversine公式
    const R = 6371000;
    const φ1 = (from.latitude * Math.PI) / 180;
    const φ2 = (to.latitude * Math.PI) / 180;
    const Δφ = ((to.latitude - from.latitude) * Math.PI) / 180;
    const Δλ = ((to.longitude - from.longitude) * Math.PI) / 180;
    const a = Math.sin(Δφ / 2) * Math.sin(Δφ / 2) +
              Math.cos(φ1) * Math.cos(φ2) *
              Math.sin(Δλ / 2) * Math.sin(Δλ / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
  }
}
```

---

### 3.3 FeeCalculator(计费计算器)

#### 3.3.1 职责定义
FeeCalculator负责停车费用计算,采用策略模式支持多种计费规则:
- 阶梯计费(免费/半价/全价)
- 周末折扣
- 每日封顶

#### 3.3.2 接口设计

```typescript
/**
 * 计费策略接口
 */
interface IFeeStrategy {
  /**
   * 计算费用
   * @param duration 停放时长(毫秒)
   * @param parkTime 入场时间(时间戳)
   * @param feeDetails 费用明细
   * @returns 费用明细
   */
  calculate(
    duration: number,
    parkTime: number,
    feeDetails: FeeDetail
  ): FeeDetail;
}
```

#### 3.3.3 类设计

```typescript
/**
 * 计费计算器(单例)
 */
class FeeCalculator {
  private static instance: FeeCalculator;
  private strategies: Map<FeeType, IFeeStrategy>;

  private constructor() {
    this.strategies = new Map();
    this.initializeStrategies();
  }

  /**
   * 获取单例实例
   */
  static getInstance(): FeeCalculator {
    if (!FeeCalculator.instance) {
      FeeCalculator.instance = new FeeCalculator();
    }
    return FeeCalculator.instance;
  }

  /**
   * 初始化计费策略
   */
  private initializeStrategies(): void {
    this.strategies.set(FeeType.TIERED, new TieredFeeStrategy());
    this.strategies.set(FeeType.WEEKEND_DISCOUNT, new WeekendDiscountStrategy());
    this.strategies.set(FeeType.DAILY_CAP, new DailyCapStrategy());
  }

  /**
   * 计算费用
   * @param duration 停放时长(毫秒)
   * @param parkTime 入场时间(时间戳)
   * @param feeDetails 费用明细
   * @returns 最终费用
   */
  calculateFee(
    duration: number,
    parkTime: number,
    feeDetails: FeeDetail
  ): number {
    // 应用所有计费策略
    let currentDetails = feeDetails;
    
    // 阶梯计费
    const tieredStrategy = this.strategies.get(FeeType.TIERED);
    if (tieredStrategy) {
      currentDetails = tieredStrategy.calculate(duration, parkTime, currentDetails);
    }
    
    // 周末折扣
    const weekendStrategy = this.strategies.get(FeeType.WEEKEND_DISCOUNT);
    if (weekendStrategy) {
      currentDetails = weekendStrategy.calculate(duration, parkTime, currentDetails);
    }
    
    // 每日封顶
    const capStrategy = this.strategies.get(FeeType.DAILY_CAP);
    if (capStrategy) {
      currentDetails = capStrategy.calculate(duration, parkTime, currentDetails);
    }
    
    // 计算最终费用
    currentDetails.finalFee = currentDetails.baseFee +
                              currentDetails.weekendDiscount +
                              currentDetails.capDiscount;
    
    return currentDetails.finalFee;
  }
}

/**
 * 费用类型
 */
enum FeeType {
  TIERED = 'tiered',
  WEEKEND_DISCOUNT = 'weekend_discount',
  DAILY_CAP = 'daily_cap'
}
```

#### 3.3.4 计费策略实现

**阶梯计费策略**:
```typescript
/**
 * 阶梯计费策略
 * - 0-30分钟:免费
 * - 30-60分钟:半价
 * - >60分钟:全价
 */
class TieredFeeStrategy implements IFeeStrategy {
  calculate(
    duration: number,
    parkTime: number,
    feeDetails: FeeDetail
  ): FeeDetail {
    const FREE_DURATION = 30 * 60 * 1000; // 30分钟
    const HALF_PRICE_DURATION = 60 * 60 * 1000; // 60分钟
    const HOURLY_RATE = 10; // 小时费率(元)
    
    const durationMinutes = Math.floor(duration / 60 / 1000);
    
    if (durationMinutes <= 30) {
      // 免费时段
      feeDetails.baseFee = 0;
    } else if (durationMinutes <= 60) {
      // 半价时段
      feeDetails.baseFee = HOURLY_RATE * 0.5;
    } else {
      // 全价时段
      const extraMinutes = durationMinutes - 60;
      const extraHours = Math.ceil(extraMinutes / 60);
      feeDetails.baseFee = HOURLY_RATE * 0.5 + HOURLY_RATE * extraHours;
    }
    
    return feeDetails;
  }
}
```

**周末折扣策略**:
```typescript
/**
 * 周末折扣策略
 * - 周六周日享受8折
 */
class WeekendDiscountStrategy implements IFeeStrategy {
  calculate(
    duration: number,
    parkTime: number,
    feeDetails: FeeDetail
  ): FeeDetail {
    const parkDate = new Date(parkTime);
    const dayOfWeek = parkDate.getDay(); // 0=周日, 6=周六
    
    if (dayOfWeek === 0 || dayOfWeek === 6) {
      // 周末8折
      feeDetails.weekendDiscount = -Math.round(feeDetails.baseFee * 0.2);
    } else {
      feeDetails.weekendDiscount = 0;
    }
    
    return feeDetails;
  }
}
```

**每日封顶策略**:
```typescript
/**
 * 每日封顶策略
 * - 单日停车费用封顶50元
 */
class DailyCapStrategy implements IFeeStrategy {
  calculate(
    duration: number,
    parkTime: number,
    feeDetails: FeeDetail
  ): FeeDetail {
    const DAILY_CAP = 50; // 每日封顶(元)
    
    const currentFee = feeDetails.baseFee + feeDetails.weekendDiscount;
    
    if (currentFee > DAILY_CAP) {
      feeDetails.capDiscount = -(currentFee - DAILY_CAP);
    } else {
      feeDetails.capDiscount = 0;
    }
    
    return feeDetails;
  }
}
```

#### 3.3.5 关键算法

**阶梯计费算法**:
```typescript
/**
 * 阶梯计费算法
 * 
 * 规则:
 * - 0-30分钟:免费(0元)
 * - 30-60分钟:半价(小时费率×0.5)
 * - >60分钟:全价(30分钟免费+30分钟半价+超出部分×小时费率)
 * 
 * @param durationMinutes 停放时长(分钟)
 * @param hourlyRate 小时费率(元)
 * @returns 费用(元)
 */
function calculateTieredFee(durationMinutes: number, hourlyRate: number): number {
  if (durationMinutes <= 30) {
    // 免费时段
    return 0;
  } else if (durationMinutes <= 60) {
    // 半价时段
    return hourlyRate * 0.5;
  } else {
    // 全价时段
    const extraMinutes = durationMinutes - 60;
    const extraHours = Math.ceil(extraMinutes / 60);
    return hourlyRate * 0.5 + hourlyRate * extraHours;
  }
}

// 示例:
// calculateTieredFee(25, 10) = 0元
// calculateTieredFee(45, 10) = 5元
// calculateTieredFee(150, 10) = 25元
```

---

## 4. 数据模型设计

### 4.1 数据实体

#### ParkingLot(停车场)
```typescript
interface ParkingLot {
  id: string;
  name: string;
  address: string;
  totalSpaces: number;
  availableSpaces: number;
  latitude: number;
  longitude: number;
  hourlyRate: number;
  dailyMaxFee: number;
  distance: number;
  floors: number;
  hasCharging: boolean;
  hasDisabled: boolean;
  openTime: string;
}
```

#### ParkingSpace(车位)
```typescript
interface ParkingSpace {
  id: string;
  lotId: string;
  spaceNumber: string;
  floor: string;
  zone: string;
  type: 'NORMAL' | 'DISABLED' | 'ELECTRIC' | 'VIP';
  status: 'AVAILABLE' | 'OCCUPIED' | 'RESERVED';
  latitude?: number;
  longitude?: number;
}
```

#### ParkingRecord(停车记录)
```typescript
interface ParkingRecord {
  recordId: string;
  parkingLotId: string;
  parkingLotName: string;
  spaceId: string;
  spaceNumber: string;
  floor: string;
  zone: string;
  latitude: number;
  longitude: number;
  accuracy: number;
  indoorLocation: {
    building: string;
    floor: string;
    nearLandmark: string;
  };
  photoUri: string;
  note: string;
  carDescription: string;
  licensePlate: string;
  parkTime: number;
  isActive: boolean;
  currentFee: number;
  feeDetails: FeeDetail;
}

interface FeeDetail {
  baseFee: number;
  weekendDiscount: number;
  capDiscount: number;
  finalFee: number;
}
```

#### Step(导航步骤)
```typescript
interface Step {
  stepId: string;
  instruction: string;
  distance: number;
  isCompleted: boolean;
}
```

### 4.2 数据存储

使用HarmonyOS Preferences API进行本地数据存储:

| 数据类型 | 存储Key | 数据类型 | 过期策略 |
|---------|---------|---------|---------|
| 停车场列表缓存 | `parking_lots_cache` | `CachedParkingLots` | 5分钟过期 |
| 车位预约记录 | `reservation_{spaceId}` | `Reservation` | 15分钟过期 |
| 当前停车记录 | `current_parking_record` | `ParkingRecord` | 长期保存 |
| 用户设置 | `user_settings` | `UserSettings` | 长期保存 |

### 4.3 数据访问

#### DataRepository接口
```typescript
interface IDataRepository {
  getCachedParkingLots(): Promise<CachedParkingLots | null>;
  cacheParkingLots(lots: ParkingLot[]): Promise<void>;
  getMockParkingLots(): Promise<ParkingLot[]>;
  getMockParkingSpaces(lotId: string): Promise<ParkingSpace[]>;
  createParkingRecord(record: ParkingRecordInput): Promise<ParkingRecord>;
  getParkingRecord(recordId: string): Promise<ParkingRecord | null>;
  updateParkingRecord(record: ParkingRecord): Promise<void>;
  getCurrentParkingRecord(): Promise<ParkingRecord | null>;
  completeParkingRecord(recordId: string): Promise<ParkingRecord>;
  saveReservation(reservation: Reservation): Promise<void>;
  getReservation(spaceId: string): Promise<Reservation | null>;
  deleteReservation(spaceId: string): Promise<void>;
}
```

---

## 5. API 设计

### 5.1 内部 API

#### ParkingService API
```typescript
ParkingService.getInstance().getNearbyParkingLots(forceRefresh?: boolean): Promise<ParkingLot[]>
ParkingService.getInstance().getParkingSpaces(lotId: string): Promise<ParkingSpace[]>
ParkingService.getInstance().reserveSpace(spaceId: string): Promise<ReservationResult>
ParkingService.getInstance().cancelReservation(spaceId: string): Promise<OperationResult>
ParkingService.getInstance().createParkingRecord(record: ParkingRecordInput): Promise<ParkingRecord>
ParkingService.getInstance().getCurrentParkingRecord(): Promise<ParkingRecord | null>
ParkingService.getInstance().completeParkingRecord(recordId: string): Promise<ParkingRecord>
ParkingService.getInstance().subscribeFeeUpdate(callback: Function): () => void
```

#### NavigationEngine API
```typescript
NavigationEngine.getInstance().startNavigation(mode: NavigationMode, end: Location, callbacks: NavigationCallbacks): Promise<void>
NavigationEngine.getInstance().stopNavigation(): void
NavigationEngine.getInstance().pauseNavigation(): void
NavigationEngine.getInstance().resumeNavigation(): void
NavigationEngine.getInstance().getNavigationStatus(): NavigationStatus
```

### 5.2 外部 API

#### LocationManager API
```typescript
LocationManager.getInstance().getCurrentLocation(): Promise<Location>
```

#### PermissionManager API
```typescript
PermissionManager.getInstance().requestPermission(permission: string): Promise<boolean>
PermissionManager.getInstance().checkPermission(permission: string): Promise<boolean>
```

---

## 6. UI 设计

### 6.1 页面结构

```
EntryAbility
  └── ParkingListPage (停车场列表页面)
      └── ReservationPage (车位预约页面)
          └── ParkingRecordPage (停车记录页面)
              └── FindCarPage (反向寻车主页面)
                  ├── MapNavigationPage (地图导航页面)
                  ├── ARNavigationPage (AR导航页面)
                  └── TextGuidePage (文字指引页面)
```

### 6.2 组件设计

#### ParkingLotItem组件
停车场列表项组件,显示停车场名称、车位信息、距离、费率、特色标签等。

#### ParkingSpaceItem组件
车位列表项组件,显示车位号、楼层、区域、类型、状态等。

#### NavigationModeSelector组件
导航模式选择器,支持地图/AR/文字三种模式切换。

### 6.3 状态管理

使用ArkUI提供的@State、@Prop、@Link装饰器进行状态管理:

- **@State**: 组件内部状态,如当前选中的停车场、车位等
- **@Prop**: 父组件传递给子组件的只读属性
- **@Link**: 双向绑定的状态,用于父子组件数据同步

#### 示例
```typescript
@Entry
@Component
struct ParkingListPage {
  @State parkingLots: ParkingLot[] = [];
  @State isLoading: boolean = false;
  @State selectedLot: ParkingLot | null = null;

  build() {
    Column() {
      if (this.isLoading) {
        LoadingProgress()
      } else {
        List() {
          ForEach(this.parkingLots, (lot: ParkingLot) => {
            ListItem() {
              ParkingLotItem({ parkingLot: lot })
            }
          })
        }
      }
    }
  }

  async aboutToAppear() {
    this.isLoading = true;
    this.parkingLots = await ParkingService.getInstance().getNearbyParkingLots();
    this.isLoading = false;
  }
}
```

---

## 7. 性能设计

### 7.1 性能目标

| 指标 | 目标值 | 说明 |
|------|--------|------|
| GPS定位响应时间 | <3秒 | 获取当前位置的时间 |
| 停车场列表加载时间 | <2秒 | 列表渲染完成时间 |
| 距离计算精度 | <5米 | Haversine公式计算误差 |
| 费用更新频率 | 1秒/次 | 停车费用实时更新 |
| AR导航更新频率 | 10fps | 箭头方向每100ms更新 |
| 缓存有效期 | 5分钟 | 停车场列表缓存时间 |
| 定位成功率 | ≥95% | GPS定位成功率 |

### 7.2 优化策略

#### 7.2.1 数据加载优化
- **缓存策略**: 停车场列表缓存5分钟,避免频繁GPS定位和网络请求
- **懒加载**: 车位列表按需加载,不一次性加载所有车位
- **分页加载**: 停车场列表超过20条时分页显示

#### 7.2.2 渲染优化
- **虚拟列表**: 使用LazyForEach虚拟列表,只渲染可见区域的项目
- **状态精确控制**: 使用@State/@Prop/@Link精确控制组件更新,避免不必要的重渲染
- **图片懒加载**: 停车场图片使用懒加载,滚动到可见区域时才加载

#### 7.2.3 内存管理
- **及时清理资源**: 导航停止时释放相机、传感器资源
- **定时器清理**: 页面销毁时清除所有定时器
- **订阅清理**: 使用完毕后取消订阅,避免内存泄漏

#### 7.2.4 异步处理
- **并发请求**: 使用Promise.all并发获取GPS定位和停车场数据
- **后台任务**: 费用更新定时器使用后台任务,不影响UI线程
- **错误重试**: GPS定位失败时自动重试,最多3次

---

## 8. 安全设计

### 8.1 安全措施

#### 8.1.1 数据加密
- **敏感数据加密**: 用户位置信息使用AES-256加密存储
- **密钥管理**: 使用系统密钥库管理加密密钥,不硬编码
- **传输加密**: 所有网络请求使用HTTPS协议

#### 8.1.2 权限控制
- **最小权限原则**: 仅请求必要的系统权限(位置、相机、传感器)
- **运行时权限**: 使用@kit.AbilityAccessCtrl在运行时请求权限
- **权限降级**: 权限拒绝时提供降级方案(如文字指引替代AR导航)

#### 8.1.3 输入验证
- **参数验证**: 所有API参数进行类型和范围验证
- **正则验证**: 车牌号、电话号等使用正则表达式验证
- **防注入攻击**: 使用参数化查询,避免SQL注入

### 8.2 权限设计

| 权限 | 用途 | 请求时机 | 降级方案 |
|------|------|---------|---------|
| ohos.permission.LOCATION | GPS定位 | 打开停车场发现页面 | 使用Mock位置数据 |
| ohos.permission.CAMERA | AR导航相机 | 选择AR导航模式 | 切换到地图或文字导航 |
| ohos.permission.ACCELEROMETER | 陀螺仪数据 | AR导航 | 使用指南针替代 |
| ohos.permission.COMPASS | 指南针数据 | AR导航 | 使用GPS方向估算 |

---

## 9. 异常处理

### 9.1 异常分类

#### 9.1.1 业务异常
- **ParkingServiceError**: 停车服务异常
- **ReservationError**: 预约服务异常
- **NavigationError**: 导航服务异常
- **FeeCalculationError**: 计费计算异常

#### 9.1.2 系统异常
- **LocationError**: 定位服务异常
- **PermissionError**: 权限异常
- **NetworkError**: 网络异常
- **StorageError**: 存储异常

### 9.2 处理策略

#### 9.2.1 异常捕获
```typescript
try {
  const lots = await ParkingService.getInstance().getNearbyParkingLots();
} catch (error) {
  if (error instanceof LocationError) {
    // 定位失败,使用Mock数据
    this.parkingLots = await this.dataRepository.getMockParkingLots();
  } else if (error instanceof PermissionError) {
    // 权限拒绝,提示用户授权
    this.showPermissionDialog();
  } else {
    // 其他异常,显示错误提示
    this.showErrorToast('获取停车场失败,请稍后重试');
  }
}
```

#### 9.2.2 错误提示
- **Toast提示**: 轻量级错误信息,3秒自动消失
- **Dialog提示**: 重要错误,需要用户确认
- **页面级错误**: 整个页面加载失败,显示错误页面

#### 9.2.3 日志记录
```typescript
console.error('Failed to get parking lots:', error);
// 或使用系统日志API
hilog.error(0x0001, 'ParkingService', 'Failed to get parking lots: %{public}s', JSON.stringify(error));
```

---

## 10. 测试设计

### 10.1 测试策略

#### 10.1.1 单元测试
- **测试覆盖率**: ≥80%
- **测试框架**: 使用ArkTS单元测试框架
- **Mock隔离**: 使用Mock隔离外部依赖(GPS、相机、传感器)

#### 10.1.2 集成测试
- **模块间交互**: 测试ParkingService与各子模块的交互
- **数据流测试**: 测试完整的数据流(定位→计算→缓存→展示)
- **异常场景**: 测试网络异常、权限拒绝等场景

#### 10.1.3 UI测试
- **页面跳转**: 测试页面导航流程
- **用户交互**: 测试点击、滑动等用户操作
- **状态更新**: 测试UI状态正确更新

### 10.2 测试用例

#### 测试用例1: 停车场距离计算
```typescript
describe('calculateDistance', () => {
  it('should return correct distance', () => {
    const from = { latitude: 39.9042, longitude: 116.4074 }; // 北京
    const to = { latitude: 31.2304, longitude: 121.4737 }; // 上海
    const distance = calculateDistance(from, to);
    expect(distance).toBeGreaterThan(1000000); // 约1068公里
    expect(distance).toBeLessThan(1100000);
    expect(Math.abs(distance - 1068000)).toBeLessThan(5000); // 误差<5公里
  });
});
```

#### 测试用例2: 阶梯计费计算
```typescript
describe('calculateTieredFee', () => {
  it('should return 0 for duration <= 30 minutes', () => {
    expect(calculateTieredFee(25, 10)).toBe(0);
  });

  it('should return half price for duration between 30-60 minutes', () => {
    expect(calculateTieredFee(45, 10)).toBe(5);
  });

  it('should return full price for duration > 60 minutes', () => {
    expect(calculateTieredFee(150, 10)).toBe(25);
  });
});
```

#### 测试用例3: 导航策略切换
```typescript
describe('NavigationEngine', () => {
  it('should switch navigation mode correctly', async () => {
    const engine = NavigationEngine.getInstance();
    const callbacks = {
      onUpdate: jest.fn(),
      onArrival: jest.fn()
    };

    // 启动地图导航
    await engine.startNavigation(NavigationMode.MAP, endLocation, callbacks);
    expect(engine.getNavigationStatus()).toBe(NavigationStatus.NAVIGATING);

    // 切换到AR导航
    await engine.startNavigation(NavigationMode.AR, endLocation, callbacks);
    expect(engine.getNavigationStatus()).toBe(NavigationStatus.NAVIGATING);

    // 停止导航
    engine.stopNavigation();
    expect(engine.getNavigationStatus()).toBe(NavigationStatus.IDLE);
  });
});
```

---

## 11. 部署设计

### 11.1 部署架构

系统为纯前端应用,无需后端部署:

```
应用打包
  ↓
生成HAP包
  ↓
发布到应用市场
  ↓
用户下载安装
  ↓
本地运行
```

### 11.2 配置管理

#### 11.2.1 应用配置
```json
{
  "app": {
    "bundleName": "com.example.smartparking",
    "version": {
      "code": 1000000,
      "name": "1.0.0"
    }
  },
  "module": {
    "mainAbility": ".EntryAbility",
    "deviceTypes": [
      "default",
      "tablet"
    ],
    "reqPermissions": [
      {
        "name": "ohos.permission.LOCATION",
        "reason": "需要获取您的位置以查找附近停车场",
        "usedScene": {
          "abilities": [
            "EntryAbility"
          ]
        }
      },
      {
        "name": "ohos.permission.CAMERA",
        "reason": "AR导航需要使用摄像头",
        "usedScene": {
          "abilities": [
            "EntryAbility"
          ]
        }
      }
    ]
  }
}
```

#### 11.2.2 环境配置
```typescript
// ParkingConstants.ets
export class ParkingConstants {
  // 费率配置
  static readonly HOURLY_RATE = 10; // 小时费率(元)
  static readonly DAILY_CAP = 50; // 每日封顶(元)
  
  // 时长配置
  static readonly FREE_DURATION = 30 * 60 * 1000; // 免费时长(30分钟)
  static readonly HALF_PRICE_DURATION = 60 * 60 * 1000; // 半价时长(60分钟)
  
  // 预约配置
  static readonly RESERVATION_DURATION = 15 * 60 * 1000; // 预约时长(15分钟)
  static readonly REMINDER_TIME = 2 * 60 * 1000; // 提醒时间(2分钟)
  static readonly MAX_CANCEL_COUNT = 3; // 最大取消次数
  
  // 导航配置
  static readonly ARRIVAL_THRESHOLD = 5; // 到达阈值(米)
  static readonly AR_UPDATE_INTERVAL = 100; // AR更新间隔(毫秒)
  
  // 缓存配置
  static readonly CACHE_DURATION = 5 * 60 * 1000; // 缓存时长(5分钟)
  
  // 错误码
  static readonly ERROR_CODE = {
    LOCATION_FAILED: 1001,
    PERMISSION_DENIED: 1002,
    RESERVATION_EXPIRED: 2001,
    CANCEL_LIMIT_EXCEEDED: 2002,
    NAVIGATION_FAILED: 3001
  };
}
```

---

## 12. 附录

### 12.1 术语表

| 术语 | 定义 |
|------|------|
| Haversine公式 | 用于计算地球上两点之间球面距离的数学公式 |
| 策略模式 | 行为设计模式,定义一系列算法,将每个算法封装起来,并使它们可以互换 |
| 单例模式 | 创建型设计模式,保证一个类只有一个实例,并提供全局访问点 |
| Preferences | HarmonyOS提供的轻量级键值对存储API |
| XComponent | HarmonyOS提供的原生组件容器,用于嵌入相机等原生视图 |
| MapKit | HarmonyOS提供的地图服务组件 |
| SensorKit | HarmonyOS提供的传感器服务API |
| ArkTS | HarmonyOS官方推荐的开发语言,基于TypeScript扩展 |
| ArkUI | HarmonyOS提供的声明式UI框架 |

### 12.2 参考资料

- HarmonyOS官方文档: https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/
- @ohos.geolocationManager API文档
- @kit.MapKit API文档
- @kit.CameraKit API文档
- @kit.SensorKit API文档
- @kit.AbilityAccessCtrl API文档
- EARS格式规范文档
- 设计原则文档

### 12.3 变更历史

| 版本 | 日期 | 变更内容 | 变更人 |
|------|------|----------|--------|
| v1.0 | 2024-01-15 | 初始版本,包含完整技术设计 | 开发团队 |

### 12.4 架构图

#### 系统架构图
```
┌─────────────────────────────────────────────────────────┐
│                     表现层 (Presentation)                │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐       │
│  │ ParkingList │ │ Reservation │ │ FindCarPage │       │
│  │   Page      │ │   Page      │ │   Page      │       │
│  └─────────────┘ └─────────────┘ └─────────────┘       │
└─────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────┐
│                     业务层 (Business)                    │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐       │
│  │ Parking     │ │ Reservation │ │  Navigation │       │
│  │  Service    │ │  Service    │ │   Engine    │       │
│  └─────────────┘ └─────────────┘ └─────────────┘       │
│  ┌─────────────┐ ┌─────────────┐                     │
│  │  Fee        │ │  Location   │                     │
│  │  Calculator │ │  Manager    │                     │
│  └─────────────┘ └─────────────┘                     │
└─────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────┐
│                     数据层 (Data)                        │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐       │
│  │ Preferences │ │  Mock Data  │ │  Data Model │       │
│  │   Storage   │ │  Provider   │ │  Repository │       │
│  └─────────────┘ └─────────────┘ └─────────────┘       │
└─────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────┐
│                   基础设施层 (Infrastructure)            │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐       │
│  │  Geo-       │ │   MapKit    │ │  CameraKit  │       │
│  │  Location   │ │   Service   │ │   Service   │       │
│  └─────────────┘ └─────────────┘ └─────────────┘       │
│  ┌─────────────┐ ┌─────────────┐                     │
│  │  SensorKit  │ │  Permission │                     │
│  │   Service   │ │  Manager    │                     │
│  └─────────────┘ └─────────────┘                     │
└─────────────────────────────────────────────────────────┘
```

#### 导航策略类图
```
┌─────────────────────────────────────────┐
│        INavigationStrategy              │
├─────────────────────────────────────────┤
│ + start(): Promise<void>                │
│ + stop(): void                          │
│ + pause(): void                         │
│ + resume(): void                        │
│ + getStatus(): NavigationStatus        │
└─────────────────────────────────────────┘
            △
            │
    ┌───────┴───────┬──────────────┬──────────────┐
    │               │              │              │
┌───┴─────┐   ┌────┴─────┐   ┌────┴─────┐   ┌────┴─────┐
│MapKit   │   │AR        │   │TextGuide │   │  ...     │
│Strategy │   │Navigation│   │Strategy  │   │Strategy  │
└─────────┘   │Strategy  │   └──────────┘   └──────────┘
              └──────────┘
```

#### 计费策略类图
```
┌─────────────────────────────────────────┐
│           IFeeStrategy                  │
├─────────────────────────────────────────┤
│ + calculate(): FeeDetail               │
└─────────────────────────────────────────┘
            △
            │
    ┌───────┴───────┬──────────────┬──────────────┐
    │               │              │              │
┌───┴─────┐   ┌────┴─────┐   ┌────┴─────┐   ┌────┴─────┐
│Tiered   │   │Weekend   │   │Daily     │   │  ...     │
│Fee      │   │Discount  │   │Cap       │   │Strategy  │
│Strategy │   │Strategy  │   │Strategy  │   │          │
└─────────┘   └──────────┘   └──────────┘   └──────────┘
```
