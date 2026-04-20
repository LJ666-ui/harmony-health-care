/**
 * 导航引擎（路径规划+AR导航）
 * 
 * 核心职责：
 * 1. 路径规划（生成文字指引）
 * 2. AR导航数据计算
 * 3. 导航状态管理
 */

import { Location } from './LocationService';
import { AR_NAVIGATION_CONFIG } from './ParkingConstants';

export interface NavigationStep {
  stepId: number;
  instruction: string;           // "向前走50米"
  distance: number;              // 距离（米）
  direction: string;             // 方向（北/南/东/西/左转/右转）
  turnAngle?: number;            // 转弯角度
  landmark?: string;             // 地标提示（如"电梯口"）
}

export interface NavigationRoute {
  routeId: string;
  totalDistance: number;          // 总距离（米）
  estimatedTime: number;          // 预计时间（秒）
  steps: NavigationStep[];        // 导航步骤列表
}

export interface ARNavigationData {
  targetLatitude: number;
  targetLongitude: number;
  currentLatitude: number;
  currentLongitude: number;
  distanceRemaining: number;      // 剩余距离（米）
  bearing: number;                // 方位角（度）
  arrowRotation: number;          // 箭头旋转角度（度）
  isArrived: boolean;             // 是否到达
  instruction: string;            // 当前指令
}

export class NavigationEngine {
  private static instance: NavigationEngine;
  private currentRoute: NavigationRoute | null = null;
  private currentStepIndex: number = 0;
  private isNavigating: boolean = false;

  private constructor() {}

  /**
   * 获取单例实例
   */
  public static getInstance(): NavigationEngine {
    if (!NavigationEngine.instance) {
      NavigationEngine.instance = new NavigationEngine();
      console.log('[NavigationEngine] 创建单例实例');
    }
    return NavigationEngine.instance;
  }

  /**
   * 规划导航路径（从当前位置到目标位置）
   */
  planRoute(
    startLocation: Location,
    targetLat: number,
    targetLng: number,
    floorInfo?: string
  ): NavigationRoute {
    try {
      console.log('[NavigationEngine] 开始路径规划...');

      const totalDistance = this.calculateStraightLineDistance(
        startLocation.latitude,
        startLocation.longitude,
        targetLat,
        targetLng
      );

      const steps = this.generateNavigationSteps(
        startLocation,
        targetLat,
        targetLng,
        floorInfo
      );

      const estimatedTime = Math.ceil(totalDistance / 1.2);

      const route: NavigationRoute = {
        routeId: 'ROUTE_' + Date.now(),
        totalDistance: totalDistance,
        estimatedTime: estimatedTime,
        steps: steps
      };

      console.log('[NavigationEngine] 路径规划完成:');
      console.log('  总距离: ' + totalDistance + 'm');
      console.log('  预计时间: ' + estimatedTime + 's (' + Math.ceil(estimatedTime / 60) + '分钟)');
      console.log('  步骤数: ' + steps.length);

      return route;

    } catch (error) {
      console.error('[NavigationEngine] 路径规划失败:', error.message);
      
      return {
        routeId: 'ROUTE_ERROR',
        totalDistance: 0,
        estimatedTime: 0,
        steps: []
      };
    }
  }

  /**
   * 生成AR导航数据（实时更新用）
   */
  calculateARNavigation(
    currentLocation: Location,
    targetLat: number,
    targetLng: number
  ): ARNavigationData {
    try {
      const distance = this.calculateStraightLineDistance(
        currentLocation.latitude,
        currentLocation.longitude,
        targetLat,
        targetLng
      );

      const bearing = this.calculateBearing(
        currentLocation.latitude,
        currentLocation.longitude,
        targetLat,
        targetLng
      );

      const isArrived = distance <= AR_NAVIGATION_CONFIG.arrivalThreshold;

      let instruction: string;
      if (isArrived) {
        instruction = '您已到达停车位';
      } else if (distance < 10) {
        instruction = '距离车位还有' + Math.round(distance) + '米，即将到达';
      } else if (distance < 50) {
        instruction = '继续前行' + Math.round(distance) + '米';
      } else {
        instruction = '距离车位还有' + Math.round(distance) + '米';
      }

      const data: ARNavigationData = {
        targetLatitude: targetLat,
        targetLongitude: targetLng,
        currentLatitude: currentLocation.latitude,
        currentLongitude: currentLocation.longitude,
        distanceRemaining: distance,
        bearing: bearing,
        arrowRotation: bearing,
        isArrived: isArrived,
        instruction: instruction
      };

      return data;

    } catch (error) {
      console.error('[NavigationEngine] 计算AR导航失败:', error.message);
      
      return {
        targetLatitude: targetLat,
        targetLongitude: targetLng,
        currentLatitude: currentLocation.latitude,
        currentLongitude: currentLocation.longitude,
        distanceRemaining: 9999,
        bearing: 0,
        arrowRotation: 0,
        isArrived: false,
        instruction: '导航数据异常'
      };
    }
  }

  /**
   * 生成文字指引（用于非AR模式）
   */
  generateTextGuidance(
    parkingRecord: any
  ): string[] {
    try {
      const guidance: string[] = [];

      guidance.push('📍 停车位置：' + parkingRecord.lotName);
      guidance.push('🚗 车位编号：' + parkingRecord.spaceNumber);
      guidance.push('🏢 楼层位置：' + (parkingRecord.floor || '地面'));
      guidance.push('');

      if (parkingRecord.floor && parkingRecord.floor.startsWith('B')) {
        guidance.push('📋 前往路线指引：');
        guidance.push('1️⃣ 从门诊大厅北门进入');
        guidance.push('2️⃣ 乘坐扶梯下至' + parkingRecord.floor + '层');
        guidance.push('3️⃣ 出扶梯后向左转直行约50米');
        guidance.push('4️⃣ 找到' + parkingRecord.spaceNumber + '号停车位');
        guidance.push('');
        guidance.push('⏱️ 预计步行时间：约3-5分钟');
      } else {
        guidance.push('📋 前往路线指引：');
        guidance.push('1️⃣ 从门诊大厅出口向右走');
        guidance.push('2️⃣ 直行约100米进入停车场入口');
        guidance.push('3️⃣ 找到' + parkingRecord.spaceNumber + '号停车位');
        guidance.push('');
        guidance.push('⏱️ 预计步行时间：约2-3分钟');
      }

      if (parkingRecord.note) {
        guidance.push('');
        guidance.push('📝 备注：' + parkingRecord.note);
      }

      return guidance;

    } catch (error) {
      console.error('[NavigationEngine] 生成文字指引失败:', error.message);
      return ['无法生成路线指引'];
    }
  }

  /**
   * 启动系统地图APP导航
   */
  launchSystemMapNavigation(
    targetLat: number,
    targetLng: number,
    destinationName: string
  ): Promise<boolean> {
    try {
      console.log('[NavigationEngine] 启动系统地图导航...');
      console.log('  目标: ' + destinationName);
      console.log('  坐标: ' + targetLat + ', ' + targetLng);

      const mapKit = requireNapi('ohos.mapKit', true);
      
      const location: any = {
        latitude: targetLat,
        longitude: targetLng,
        name: destinationName
      };

      mapKit.startNavigation(location);

      console.log('[NavigationEngine] 地图导航已启动');
      return true;

    } catch (error) {
      console.error('[NavigationEngine] 启动地图导航失败:', error.message);
      
      console.warn('[NavigationEngine] 使用URL Scheme降级方案');
      const url = 'https://uri.amap.com/navigation?to=' + 
                  targetLng + ',' + targetLat + ',' + 
                  encodeURIComponent(destinationName) + '&mode=car';
      
      console.log('[NavigationEngine] 导航URL: ' + url);
      return false;
    }
  }

  /**
   * 开始导航
   */
  startNavigation(route: NavigationRoute): void {
    this.currentRoute = route;
    this.currentStepIndex = 0;
    this.isNavigating = true;
    console.log('[NavigationEngine] 导航已开始');
  }

  /**
   * 停止导航
   */
  stopNavigation(): void {
    this.isNavigating = false;
    this.currentRoute = null;
    this.currentStepIndex = 0;
    console.log('[NavigationEngine] 导航已停止');
  }

  /**
   * 获取当前导航状态
   */
  getNavigationStatus(): {
    isNavigating: boolean;
    currentStep?: NavigationStep;
    progress: number;
  } | null {
    if (!this.currentRoute || !this.isNavigating) {
      return null;
    }

    const currentStep = this.currentRoute.steps[this.currentStepIndex];
    const progress = (this.currentStepIndex / this.currentRoute.steps.length) * 100;

    return {
      isNavigating: this.isNavigating,
      currentStep: currentStep,
      progress: progress
    };
  }

  // ==================== 私有辅助方法 ====================

  /**
   * 计算直线距离（米）
   */
  private calculateStraightLineDistance(
    lat1: number, lng1: number,
    lat2: number, lng2: number
  ): number {
    const R = 6371000;
    const dLat = (lat2 - lat1) * Math.PI / 180;
    const dLng = (lng2 - lng1) * Math.PI / 180;
    
    const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
              Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
              Math.sin(dLng / 2) * Math.sin(dLng / 2);
    
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    
    return Math.round(R * c);
  }

  /**
   * 计算方位角
   */
  private calculateBearing(
    lat1: number, lng1: number,
    lat2: number, lng2: number
  ): number {
    const dLng = (lng2 - lng1) * Math.PI / 180;
    const y = Math.sin(dLng) * Math.cos(lat2 * Math.PI / 180);
    const x = Math.cos(lat1 * Math.PI / 180) * Math.sin(lat2 * Math.PI / 180) -
              Math.sin(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) * Math.cos(dLng);
    
    let bearing = Math.atan2(y, x) * 180 / Math.PI;
    bearing = (bearing + 360) % 360;

    return bearing;
  }

  /**
   * 生成导航步骤列表
   */
  private generateNavigationSteps(
    start: Location,
    targetLat: number,
    targetLng: number,
    floorInfo?: string
  ): NavigationStep[] {
    const steps: NavigationStep[] = [];
    const totalDistance = this.calculateStraightLineDistance(
      start.latitude, start.longitude,
      targetLat, targetLng
    );

    if (floorInfo && floorInfo.startsWith('B')) {
      steps.push({
        stepId: 1,
        instruction: '从当前位置前往停车场入口',
        distance: Math.min(totalDistance * 0.3, 150),
        direction: '前方',
        landmark: '停车场入口'
      });

      steps.push({
        stepId: 2,
        instruction: '乘坐电梯/扶梯下至' + floorInfo + '层',
        distance: 0,
        direction: '下行',
        landmark: floorInfo + '层'
      });

      steps.push({
        stepId: 3,
        instruction: '出电梯后按指示牌前往目标区域',
        distance: Math.min(totalDistance * 0.5, 200),
        direction: '直行',
        landmark: '停车区标识'
      });

      steps.push({
        stepId: 4,
        instruction: '到达目标停车位',
        distance: Math.max(totalDistance - 350, 20),
        direction: '前方',
        landmark: '停车位'
      });
    } else {
      steps.push({
        stepId: 1,
        instruction: '从当前位置出发',
        distance: Math.min(totalDistance * 0.5, 200),
        direction: '前方',
        landmark: '出发地'
      });

      steps.push({
        stepId: 2,
        instruction: '沿指示牌方向继续前进',
        distance: Math.min(totalDistance * 0.4, 150),
        direction: '直行',
        landmark: '停车场内部道路'
      });

      steps.push({
        stepId: 3,
        instruction: '到达目标停车位',
        distance: Math.max(totalDistance - 350, 30),
        direction: '前方',
        landmark: '停车位'
      });
    }

    return steps;
  }
}
