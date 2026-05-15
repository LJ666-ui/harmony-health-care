/**
 * AR院内导航系统 - 导航服务核心
 * 
 * 导航流程编排中心,核心功能:
 * - 导航生命周期管理(开始/暂停/结束)
 * - 导航状态维护和分发
 * - 协调各子服务(PathPlanner/IndoorLocator/ARRenderer/VoiceGuide)
 * - 处理导航事件(偏航/到达/异常)
 * 
 * @version 1.0
 * @date 2025-01-18
 * @author SDD Agent
 */

import {
  NavigationDestination,
  NavigationPath,
  ARNavigationState,
  NavigationOptions,
  NavigationMode,
  Position3D,
  Waypoint,
  NavigationHistory
} from '../models/ARNavigationModels';
import { PathPlanner } from './PathPlanner';
import { IndoorLocator } from './IndoorLocator';
import { ARRenderer } from './ARRenderer';
import { VoiceGuide } from './VoiceGuide';

/**
 * 导航事件类型
 */
export enum NavigationEventType {
  STARTED = 'STARTED',
  PAUSED = 'PAUSED',
  RESUMED = 'RESUMED',
  ENDED = 'ENDED',
  DEVIATED = 'DEVIATED',
  ARRIVED = 'ARRIVED',
  ERROR = 'ERROR'
}

/**
 * 导航事件
 */
interface NavigationEvent {
  type: NavigationEventType;
  data?: NavigationEventData;
  timestamp: number;
}

// 导航事件数据类型
interface NavigationEventData {
  destination?: NavigationDestination;
  path?: NavigationPath;
  position?: Position3D;
  currentPosition?: Position3D;
  distance?: number;
  waypoint?: Waypoint;
  message?: string;
  error?: Error;
}

/**
 * AR导航服务类(单例)
 */
export class ARNavigationService {
  private static instance: ARNavigationService | null = null;

  // 子服务实例
  private pathPlanner: PathPlanner;
  private indoorLocator: IndoorLocator;
  private arRenderer: ARRenderer;
  private voiceGuide: VoiceGuide;

  // 导航状态
  private navigationState: ARNavigationState;
  private currentDestination: NavigationDestination | null = null;

  // 导航循环
  private navigationLoopTimer: number | null = null;
  private readonly navigationLoopInterval: number = 1000; // 1秒

  // 事件监听器
  private eventListeners: Map<NavigationEventType, ((event: NavigationEvent) => void)[]> = new Map();

  // 导航历史
  private navigationStartTime: number = 0;

  // 偏航阈值(米)
  private readonly deviationThreshold: number = 5;

  // 到达阈值(米)
  private readonly arrivalThreshold: number = 3;

  /**
   * 私有构造函数(单例模式)
   */
  private constructor() {
    this.pathPlanner = PathPlanner.getInstance();
    this.indoorLocator = IndoorLocator.getInstance();
    this.arRenderer = ARRenderer.getInstance();
    this.voiceGuide = VoiceGuide.getInstance();

    this.navigationState = this.initNavigationState();
  }

  /**
   * 获取单例实例
   */
  public static getInstance(): ARNavigationService {
    if (!ARNavigationService.instance) {
      ARNavigationService.instance = new ARNavigationService();
    }
    return ARNavigationService.instance;
  }

  /**
   * 初始化导航状态
   */
  private initNavigationState(): ARNavigationState {
    return {
      isActive: false,
      isPaused: false,
      currentPath: null,
      currentWaypointIndex: 0,
      currentPosition: { x: 0, y: 0, z: 0 },
      heading: 0,
      totalDistance: 0,
      remainingDistance: 0,
      estimatedTime: 0,
      estimatedArrival: 0,
      navigationMode: NavigationMode.AR_MODE,
      isMuted: false,
      lastUpdateTime: Date.now()
    };
  }

  /**
   * 启动导航
   * @param destination 目的地
   * @param options 导航选项
   */
  public async startNavigation(
    destination: NavigationDestination,
    options?: NavigationOptions
  ): Promise<void> {
    console.log('[ARNavigationService] 启动导航,目的地:', destination.name);

    // 检查是否已在导航中
    if (this.navigationState.isActive) {
      console.warn('[ARNavigationService] 已在导航中,请先结束当前导航');
      return;
    }

    try {
      await this.pathPlanner.autoInitialize();

      await this.indoorLocator.initialize();

      const currentPosition = await this.getCurrentPosition();
      if (!currentPosition) {
        throw new Error('无法获取当前位置');
      }

      // 2. 计算导航路径
      console.log('[ARNavigationService] 计算导航路径...');
      const path = await this.pathPlanner.calculatePath(
        currentPosition,
        destination.position,
        {
          avoidStairs: options?.accessibilityMode || false,
          preferElevator: true
        }
      );

      // 3. 更新导航状态
      this.currentDestination = destination;
      this.navigationStartTime = Date.now();
      this.navigationState = {
        isActive: true,
        isPaused: false,
        currentPath: path,
        currentWaypointIndex: 0,
        currentPosition: currentPosition,
        heading: 0,
        totalDistance: path.totalDistance,
        remainingDistance: path.totalDistance,
        estimatedTime: path.estimatedTime,
        estimatedArrival: Date.now() + path.estimatedTime * 1000,
        navigationMode: options?.mode || NavigationMode.AR_MODE,
        isMuted: false,
        lastUpdateTime: Date.now()
      };

      // 4. 启动定位追踪
      await this.indoorLocator.startTracking();
      this.indoorLocator.setPositionUpdateCallback((pos: Position3D) => {
        this.handlePositionUpdate(pos);
      });

      // 5. 启动AR渲染(如果是AR模式)
      if (this.navigationState.navigationMode === NavigationMode.AR_MODE) {
        // AR渲染器需要Canvas上下文,这里先跳过
        // 实际使用时需要在页面中初始化
        console.log('[ARNavigationService] AR模式,等待渲染器初始化');
      }

      // 6. 启动语音引导
      if (options?.voiceEnabled !== false) {
        await this.voiceGuide.initialize();
      }

      // 7. 启动导航循环
      this.startNavigationLoop();

      // 8. 触发事件
      this.emitEvent({
        type: NavigationEventType.STARTED,
        data: { destination, path },
        timestamp: Date.now()
      });

      console.log('[ARNavigationService] 导航已启动,总距离:', path.totalDistance, '米');
    } catch (error) {
      console.error('[ARNavigationService] 启动导航失败:', error);
      const err = error instanceof Error ? error : new Error(String(error));
      this.emitEvent({
        type: NavigationEventType.ERROR,
        data: { error: err },
        timestamp: Date.now()
      });
      throw err;
    }
  }

  /**
   * 暂停导航
   */
  public pauseNavigation(): void {
    if (!this.navigationState.isActive) {
      console.warn('[ARNavigationService] 导航未激活');
      return;
    }

    console.log('[ARNavigationService] 暂停导航');

    // 停止导航循环
    this.stopNavigationLoop();

    // 停止定位追踪
    this.indoorLocator.stopTracking();

    // 停止AR渲染
    this.arRenderer.stopRendering();

    // 触发事件
    this.emitEvent({
      type: NavigationEventType.PAUSED,
      timestamp: Date.now()
    });
  }

  /**
   * 恢复导航
   */
  public resumeNavigation(): void {
    if (!this.navigationState.isActive) {
      console.warn('[ARNavigationService] 导航未激活');
      return;
    }

    console.log('[ARNavigationService] 恢复导航');

    // 恢复定位追踪
    this.indoorLocator.startTracking();

    // 恢复AR渲染
    if (this.navigationState.navigationMode === NavigationMode.AR_MODE) {
      this.arRenderer.startRendering();
    }

    // 恢复导航循环
    this.startNavigationLoop();

    // 触发事件
    this.emitEvent({
      type: NavigationEventType.RESUMED,
      timestamp: Date.now()
    });
  }

  /**
   * 结束导航
   */
  public endNavigation(): void {
    if (!this.navigationState.isActive) {
      console.warn('[ARNavigationService] 导航未激活');
      return;
    }

    console.log('[ARNavigationService] 结束导航');

    // 1. 停止导航循环
    this.stopNavigationLoop();

    // 2. 停止定位追踪
    this.indoorLocator.stopTracking();

    // 3. 停止AR渲染
    this.arRenderer.stopRendering();

    // 4. 重置语音引导
    this.voiceGuide.reset();

    // 5. 保存导航历史
    this.saveNavigationHistory();

    // 6. 重置导航状态
    this.navigationState = this.initNavigationState();
    this.currentDestination = null;

    // 7. 触发事件
    this.emitEvent({
      type: NavigationEventType.ENDED,
      timestamp: Date.now()
    });
  }

  /**
   * 启动导航循环
   */
  private startNavigationLoop(): void {
    this.navigationLoopTimer = setInterval(() => {
      this.navigationLoop();
    }, this.navigationLoopInterval);
  }

  /**
   * 停止导航循环
   */
  private stopNavigationLoop(): void {
    if (this.navigationLoopTimer !== null) {
      clearInterval(this.navigationLoopTimer);
      this.navigationLoopTimer = null;
    }
  }

  /**
   * 导航循环
   */
  private async navigationLoop(): Promise<void> {
    if (!this.navigationState.isActive || !this.navigationState.currentPath) {
      return;
    }

    try {
      // 1. 获取当前位置
      const currentPosition = this.indoorLocator.getCurrentPosition();
      if (!currentPosition) {
        console.warn('[ARNavigationService] 无法获取当前位置');
        return;
      }

      // 2. 更新导航状态
      this.updateNavigationState(currentPosition);

      // 3. 检查是否偏航
      if (this.isDeviated(currentPosition)) {
        await this.handleDeviation(currentPosition);
        return;
      }

      // 4. 检查是否到达
      if (this.isArrived(currentPosition)) {
        await this.handleArrival();
        return;
      }

      // 5. 更新AR渲染
      this.updateARRendering();

      // 6. 触发语音引导
      this.triggerVoiceGuidance(currentPosition);
    } catch (error) {
      console.error('[ARNavigationService] 导航循环错误:', error);
    }
  }

  /**
   * 处理位置更新
   */
  private handlePositionUpdate(position: Position3D): void {
    if (!this.navigationState.isActive) {
      return;
    }

    // 更新当前位置
    this.navigationState.currentPosition = position;
    this.navigationState.lastUpdateTime = Date.now();
  }

  /**
   * 更新导航状态
   */
  private updateNavigationState(currentPosition: Position3D): void {
    if (!this.navigationState.currentPath) return;

    // 计算剩余距离
    const destination = this.currentDestination;
    if (destination) {
      this.navigationState.remainingDistance = this.pathPlanner.getDistance(
        currentPosition,
        destination.position
      );
    }

    // 更新预计到达时间
    const speed = 1.2;
    const remainingTime = this.navigationState.remainingDistance / speed;
    this.navigationState.estimatedTime = remainingTime;
    this.navigationState.estimatedArrival = Date.now() + remainingTime * 1000;

    // 更新当前途经点索引
    this.updateCurrentWaypointIndex(currentPosition);
  }

  /**
   * 更新当前途经点索引
   */
  private updateCurrentWaypointIndex(currentPosition: Position3D): void {
    if (!this.navigationState.currentPath) return;

    const waypoints = this.navigationState.currentPath.waypoints;
    let minDistance = Infinity;
    let nearestIndex = this.navigationState.currentWaypointIndex;

    // 查找最近的途经点
    for (let i = this.navigationState.currentWaypointIndex; i < waypoints.length; i++) {
      const distance = this.pathPlanner.getDistance(
        currentPosition,
        waypoints[i].position
      );
      if (distance < minDistance) {
        minDistance = distance;
        nearestIndex = i;
      }
    }

    // 如果已经过了当前途经点,推进索引
    if (nearestIndex > this.navigationState.currentWaypointIndex) {
      this.navigationState.currentWaypointIndex = nearestIndex;
      console.log('[ARNavigationService] 推进到途经点:', nearestIndex);
    }
  }

  /**
   * 检查是否偏航
   */
  private isDeviated(currentPosition: Position3D): boolean {
    if (!this.navigationState.currentPath) return false;

    // 计算到路径的距离
    const distanceToPath = this.calculateDistanceToPath(currentPosition);
    return distanceToPath > this.deviationThreshold;
  }

  /**
   * 计算到路径的距离
   */
  private calculateDistanceToPath(currentPosition: Position3D): number {
    if (!this.navigationState.currentPath) return Infinity;

    const waypoints = this.navigationState.currentPath.waypoints;
    let minDistance = Infinity;

    // 计算到每个途经点的距离
    for (const waypoint of waypoints) {
      const distance = this.pathPlanner.getDistance(
        currentPosition,
        waypoint.position
      );
      minDistance = Math.min(minDistance, distance);
    }

    return minDistance;
  }

  /**
   * 处理偏航
   */
  private async handleDeviation(currentPosition: Position3D): Promise<void> {
    console.log('[ARNavigationService] 检测到偏航,重新规划路径');

    // 播报偏航提示
    await this.voiceGuide.announceDeviation();

    // 重新规划路径
    if (this.currentDestination) {
      try {
        const newPath = await this.pathPlanner.calculatePath(
          currentPosition,
          this.currentDestination.position
        );

        this.navigationState.currentPath = newPath;
        this.navigationState.currentWaypointIndex = 0;

        console.log('[ARNavigationService] 路径重规划完成,新距离:', newPath.totalDistance, '米');
      } catch (error) {
        console.error('[ARNavigationService] 路径重规划失败:', error);
      }
    }

    // 触发事件
    this.emitEvent({
      type: NavigationEventType.DEVIATED,
      data: { currentPosition },
      timestamp: Date.now()
    });
  }

  /**
   * 检查是否到达
   */
  private isArrived(currentPosition: Position3D): boolean {
    return this.navigationState.remainingDistance <= this.arrivalThreshold;
  }

  /**
   * 处理到达
   */
  private async handleArrival(): Promise<void> {
    console.log('[ARNavigationService] 已到达目的地');

    // 播报到达提示
    if (this.currentDestination) {
      await this.voiceGuide.announceArrival(this.currentDestination.name);
    }

    // 触发事件
    this.emitEvent({
      type: NavigationEventType.ARRIVED,
      data: { destination: this.currentDestination ?? undefined },
      timestamp: Date.now()
    });

    // 结束导航
    this.endNavigation();
  }

  /**
   * 更新AR渲染
   */
  private updateARRendering(): void {
    if (!this.navigationState.currentPath) return;

    // 计算箭头方向
    const currentWaypoint = this.getCurrentWaypoint();
    if (currentWaypoint) {
      const direction = this.calculateArrowDirection(
        this.navigationState.currentPosition,
        currentWaypoint.position
      );
      this.arRenderer.updateArrowDirection(direction);
    }

    // 更新导航信息
    this.arRenderer.updateNavigationInfo({
      instruction: this.getCurrentInstruction(),
      remainingDistance: this.navigationState.remainingDistance,
      estimatedTime: (this.navigationState.estimatedArrival - Date.now()) / 1000,
      progress: this.calculateProgress()
    });
  }

  /**
   * 触发语音引导
   */
  private triggerVoiceGuidance(currentPosition: Position3D): void {
    const currentWaypoint = this.getNextWaypoint();
    if (!currentWaypoint) return;

    const distance = this.pathPlanner.getDistance(
      currentPosition,
      currentWaypoint.position
    );

    this.voiceGuide.checkAndAnnounce(
      currentPosition,
      currentWaypoint,
      distance
    );
  }

  /**
   * 获取当前位置
   */
  private async getCurrentPosition(): Promise<Position3D | null> {
    let position = this.indoorLocator.getCurrentPosition();

    if (!position) {
      position = { x: 40, y: 0, z: 5 };
    }

    return position;
  }

  /**
   * 计算箭头方向
   */
  private calculateArrowDirection(from: Position3D, to: Position3D): number {
    const dx = to.x - from.x;
    const dz = to.z - from.z;
    const angle = Math.atan2(dx, dz) * (180 / Math.PI);
    return (angle + 360) % 360;
  }

  /**
   * 获取当前途经点
   */
  private getCurrentWaypoint(): Waypoint | null {
    if (!this.navigationState.currentPath) return null;
    const index = this.navigationState.currentWaypointIndex;
    return this.navigationState.currentPath.waypoints[index] || null;
  }

  /**
   * 获取下一个途经点
   */
  private getNextWaypoint(): Waypoint | null {
    if (!this.navigationState.currentPath) return null;
    const index = this.navigationState.currentWaypointIndex;
    return this.navigationState.currentPath.waypoints[index + 1] || null;
  }

  /**
   * 获取当前指令
   */
  private getCurrentInstruction(): string {
    if (!this.navigationState.currentPath) return '';
    const index = this.navigationState.currentWaypointIndex;
    const instruction = this.navigationState.currentPath.instructions[index];
    return instruction?.text || '继续前进';
  }

  /**
   * 计算进度
   */
  private calculateProgress(): number {
    if (!this.navigationState.currentPath) return 0;
    const totalDistance = this.navigationState.currentPath.totalDistance;
    const remainingDistance = this.navigationState.remainingDistance;
    return 1 - remainingDistance / totalDistance;
  }

  /**
   * 保存导航历史
   */
  private saveNavigationHistory(): void {
    if (!this.currentDestination || !this.navigationState.currentPath) return;

    const history: NavigationHistory = {
      id: `HISTORY_${Date.now()}`,
      destinationId: this.currentDestination.id,
      destinationName: this.currentDestination.name,
      startTime: this.navigationStartTime,
      endTime: Date.now(),
      duration: (Date.now() - this.navigationStartTime) / 1000,
      distance: this.navigationState.currentPath.totalDistance - this.navigationState.remainingDistance,
      path: this.navigationState.currentPath,
      completed: this.navigationState.remainingDistance <= this.arrivalThreshold
    };

    // 实际实现需要保存到数据库
    console.log('[ARNavigationService] 保存导航历史:', history);
  }

  /**
   * 设置导航模式
   */
  public setNavigationMode(mode: NavigationMode): void {
    this.navigationState.navigationMode = mode;
    console.log('[ARNavigationService] 切换导航模式:', mode);

    // 根据模式启动/停止AR渲染
    if (mode === NavigationMode.AR_MODE) {
      this.arRenderer.startRendering();
    } else {
      this.arRenderer.stopRendering();
    }
  }

  /**
   * 设置静音状态
   * @param muted 是否静音
   */
  public setMuted(muted: boolean): void {
    this.navigationState.isMuted = muted;
    this.voiceGuide.setMuted(muted);
    console.log('[ARNavigationService] 静音状态:', muted);
  }

  /**
   * 获取导航状态
   */
  public getNavigationState(): ARNavigationState {
    // 创建状态副本,避免spread操作符
    const stateCopy: ARNavigationState = {
      isActive: this.navigationState.isActive,
      isPaused: this.navigationState.isPaused,
      currentPath: this.navigationState.currentPath,
      currentWaypointIndex: this.navigationState.currentWaypointIndex,
      currentPosition: this.navigationState.currentPosition,
      heading: this.navigationState.heading,
      totalDistance: this.navigationState.totalDistance,
      remainingDistance: this.navigationState.remainingDistance,
      estimatedTime: this.navigationState.estimatedTime,
      estimatedArrival: this.navigationState.estimatedArrival,
      navigationMode: this.navigationState.navigationMode,
      isMuted: this.navigationState.isMuted,
      lastUpdateTime: this.navigationState.lastUpdateTime
    };
    return stateCopy;
  }

  /**
   * 添加事件监听器
   */
  public addEventListener(
    type: NavigationEventType,
    listener: (event: NavigationEvent) => void
  ): void {
    if (!this.eventListeners.has(type)) {
      this.eventListeners.set(type, []);
    }
    this.eventListeners.get(type)!.push(listener);
  }

  /**
   * 移除事件监听器
   */
  public removeEventListener(
    type: NavigationEventType,
    listener: (event: NavigationEvent) => void
  ): void {
    const listeners = this.eventListeners.get(type);
    if (listeners) {
      const index = listeners.indexOf(listener);
      if (index !== -1) {
        listeners.splice(index, 1);
      }
    }
  }

  /**
   * 触发事件
   */
  private emitEvent(event: NavigationEvent): void {
    const listeners = this.eventListeners.get(event.type);
    if (listeners) {
      for (const listener of listeners) {
        try {
          listener(event);
        } catch (error) {
          console.error('[ARNavigationService] 事件监听器错误:', error);
        }
      }
    }
  }
}
