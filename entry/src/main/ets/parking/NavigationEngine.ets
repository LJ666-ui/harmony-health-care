import { INavigationStrategy, NavigationMode, NavigationStatus, Location, NavigationCallbacks, Step } from '../models/ParkingModels';
import { NavigationConstants, ParkingErrorCode, ParkingErrorMessage } from './ParkingConstants';

/**
 * 地图导航策略
 */
class MapKitNavigationStrategy implements INavigationStrategy {
  private status: NavigationStatus = NavigationStatus.IDLE;
  private updateTimer: number | null = null;

  async start(
    start: Location,
    end: Location,
    onUpdate?: (position: Location, distance: number) => void,
    onArrival?: () => void
  ): Promise<void> {
    this.status = NavigationStatus.NAVIGATING;
    this.startLocationTracking(end, onUpdate, onArrival);
  }

  stop(): void {
    this.status = NavigationStatus.IDLE;
    if (this.updateTimer) {
      clearInterval(this.updateTimer);
      this.updateTimer = null;
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

  private startLocationTracking(
    target: Location,
    onUpdate?: (position: Location, distance: number) => void,
    onArrival?: () => void
  ): void {
    this.updateTimer = setInterval(() => {
      onUpdate?.(target, 100);
    }, NavigationConstants.MAP_UPDATE_INTERVAL);
  }
}

/**
 * AR导航策略
 */
class ARNavigationStrategy implements INavigationStrategy {
  private status: NavigationStatus = NavigationStatus.IDLE;
  private updateTimer: number | null = null;

  async start(
    start: Location,
    end: Location,
    onUpdate?: (position: Location, distance: number) => void,
    onArrival?: () => void
  ): Promise<void> {
    this.status = NavigationStatus.NAVIGATING;
    this.startLocationTracking(end, onUpdate, onArrival);
  }

  stop(): void {
    this.status = NavigationStatus.IDLE;
    if (this.updateTimer) {
      clearInterval(this.updateTimer);
      this.updateTimer = null;
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

  private startLocationTracking(
    target: Location,
    onUpdate?: (position: Location, distance: number) => void,
    onArrival?: () => void
  ): void {
    this.updateTimer = setInterval(() => {
      onUpdate?.(target, 50);
    }, NavigationConstants.AR_UPDATE_INTERVAL);
  }
}

/**
 * 文字指引策略
 */
class TextGuideStrategy implements INavigationStrategy {
  private status: NavigationStatus = NavigationStatus.IDLE;
  private updateTimer: number | null = null;
  private steps: Step[] = [];
  private currentStepIndex: number = 0;

  async start(
    start: Location,
    end: Location,
    onUpdate?: (position: Location, distance: number) => void,
    onArrival?: () => void
  ): Promise<void> {
    this.status = NavigationStatus.NAVIGATING;
    this.currentStepIndex = 0;
    this.steps = [
      { stepId: '1', instruction: '从当前位置向北走20米', distance: 20, isCompleted: false },
      { stepId: '2', instruction: '左转,向东走30米', distance: 30, isCompleted: false },
      { stepId: '3', instruction: '进入A区,向前走10米', distance: 10, isCompleted: false },
      { stepId: '4', instruction: '到达停车位', distance: 0, isCompleted: false }
    ];
    this.startLocationTracking(end, onUpdate, onArrival);
  }

  stop(): void {
    this.status = NavigationStatus.IDLE;
    if (this.updateTimer) {
      clearInterval(this.updateTimer);
      this.updateTimer = null;
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

  getSteps() {
    return this.steps;
  }

  private startLocationTracking(
    target: Location,
    onUpdate?: (position: Location, distance: number) => void,
    onArrival?: () => void
  ): void {
    this.updateTimer = setInterval(() => {
      onUpdate?.(target, 50);
    }, NavigationConstants.MAP_UPDATE_INTERVAL);
  }
}

/**
 * 导航引擎类(单例)
 */
export class NavigationEngine {
  private static instance: NavigationEngine;
  private currentStrategy: INavigationStrategy | null = null;
  private strategies: Map<NavigationMode, INavigationStrategy>;

  private constructor() {
    this.strategies = new Map();
    this.strategies.set(NavigationMode.MAP, new MapKitNavigationStrategy());
    this.strategies.set(NavigationMode.AR, new ARNavigationStrategy());
    this.strategies.set(NavigationMode.TEXT, new TextGuideStrategy());
  }

  static getInstance(): NavigationEngine {
    if (!NavigationEngine.instance) {
      NavigationEngine.instance = new NavigationEngine();
    }
    return NavigationEngine.instance;
  }

  async startNavigation(
    mode: NavigationMode,
    end: Location,
    callbacks: NavigationCallbacks
  ): Promise<void> {
    const strategy = this.strategies.get(mode);
    if (!strategy) {
      callbacks.onError?.(new Error(ParkingErrorMessage.getMessage(ParkingErrorCode.NAVIGATION_FAILED)));
      return;
    }
    this.currentStrategy = strategy;
    await strategy.start(end, end, callbacks.onUpdate, callbacks.onArrival);
  }

  stopNavigation(): void {
    if (this.currentStrategy) {
      this.currentStrategy.stop();
      this.currentStrategy = null;
    }
  }

  getNavigationStatus(): NavigationStatus {
    return this.currentStrategy?.getStatus() ?? NavigationStatus.IDLE;
  }

  getTextGuideSteps(): Step[] {
    const strategy = this.strategies.get(NavigationMode.TEXT);
    if (strategy instanceof TextGuideStrategy) {
      return strategy.getSteps();
    }
    return [];
  }
}
