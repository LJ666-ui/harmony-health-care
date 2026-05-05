/**
 * 关键数据预加载器
 * 在应用启动时预加载关键数据，提升用户体验
 * 
 * @author AI Assistant
 * @date 2026-04-27
 */

import { startupOptimizer } from './StartupOptimizer';

/**
 * 预加载数据类型
 */
export enum PreloadDataType {
  USER_INFO = 'user_info',           // 用户信息
  APP_CONFIG = 'app_config',         // 应用配置
  HOME_DATA = 'home_data',           // 首页数据
  HEALTH_SUMMARY = 'health_summary', // 健康摘要
  RECENT_RECORDS = 'recent_records', // 最近记录
  NOTIFICATIONS = 'notifications'    // 通知消息
}

/**
 * 预加载数据缓存
 */
interface PreloadCache {
  [key: string]: {
    data: unknown;
    timestamp: number;
    expired: boolean;
  };
}

/**
 * 关键数据预加载器
 */
export class CriticalDataPreloader {
  private static instance: CriticalDataPreloader | null = null;
  
  // 预加载数据缓存
  private cache: PreloadCache = {};
  
  // 预加载超时时间
  private preloadTimeout: number = 800;
  
  // 缓存过期时间（5分钟）
  private cacheExpireTime: number = 300000;
  
  // 私有构造函数（单例模式）
  private constructor() {
    this.registerPreloadTasks();
    console.info('[CriticalDataPreloader] 初始化关键数据预加载器');
  }
  
  /**
   * 获取单例实例
   */
  public static getInstance(): CriticalDataPreloader {
    if (!CriticalDataPreloader.instance) {
      CriticalDataPreloader.instance = new CriticalDataPreloader();
    }
    return CriticalDataPreloader.instance;
  }
  
  /**
   * 注册预加载任务
   */
  private registerPreloadTasks(): void {
    const tasks = [
      {
        id: 'preload_user_info',
        name: '预加载用户信息',
        execute: () => this.preloadUserInfo(),
        timeout: this.preloadTimeout,
        critical: true
      },
      {
        id: 'preload_app_config',
        name: '预加载应用配置',
        execute: () => this.preloadAppConfig(),
        timeout: this.preloadTimeout,
        critical: true
      },
      {
        id: 'preload_home_data',
        name: '预加载首页数据',
        execute: () => this.preloadHomeData(),
        timeout: this.preloadTimeout,
        critical: true
      },
      {
        id: 'preload_health_summary',
        name: '预加载健康摘要',
        execute: () => this.preloadHealthSummary(),
        timeout: this.preloadTimeout,
        critical: false
      },
      {
        id: 'preload_recent_records',
        name: '预加载最近记录',
        execute: () => this.preloadRecentRecords(),
        timeout: this.preloadTimeout,
        critical: false
      },
      {
        id: 'preload_notifications',
        name: '预加载通知消息',
        execute: () => this.preloadNotifications(),
        timeout: this.preloadTimeout,
        critical: false
      }
    ];
    
    startupOptimizer.registerPreloadTasks(tasks);
  }
  
  /**
   * 执行预加载
   */
  public async preload(): Promise<void> {
    console.info('[CriticalDataPreloader] 开始预加载关键数据');
    await startupOptimizer.executePreload();
  }
  
  /**
   * 获取预加载数据
   * @param type 数据类型
   */
  public getData<T>(type: PreloadDataType): T | null {
    const cached = this.cache[type];
    
    if (!cached) {
      console.warn(`[CriticalDataPreloader] 数据 ${type} 未缓存`);
      return null;
    }
    
    // 检查是否过期
    if (cached.expired || Date.now() - cached.timestamp > this.cacheExpireTime) {
      console.warn(`[CriticalDataPreloader] 数据 ${type} 已过期`);
      return null;
    }
    
    return cached.data as T;
  }
  
  /**
   * 设置预加载数据
   * @param type 数据类型
   * @param data 数据
   */
  public setData<T>(type: PreloadDataType, data: T): void {
    this.cache[type] = {
      data,
      timestamp: Date.now(),
      expired: false
    };
    
    console.info(`[CriticalDataPreloader] 缓存数据 ${type}`);
  }
  
  /**
   * 清空缓存
   * @param type 数据类型（可选，不传则清空所有）
   */
  public clearCache(type?: PreloadDataType): void {
    if (type) {
      delete this.cache[type];
      console.info(`[CriticalDataPreloader] 清空缓存 ${type}`);
    } else {
      this.cache = {};
      console.info('[CriticalDataPreloader] 清空所有缓存');
    }
  }
  
  /**
   * 标记数据过期
   * @param type 数据类型
   */
  public markExpired(type: PreloadDataType): void {
    if (this.cache[type]) {
      this.cache[type].expired = true;
      console.info(`[CriticalDataPreloader] 标记数据 ${type} 过期`);
    }
  }
  
  // ==================== 预加载方法 ====================
  
  /**
   * 预加载用户信息
   */
  private async preloadUserInfo(): Promise<void> {
    try {
      // TODO: 从本地存储或API获取用户信息
      // const userInfo = await UserService.getUserInfo();
      
      // 模拟数据
      const userInfo = {
        id: 'user_001',
        name: '张三',
        avatar: '',
        age: 35,
        gender: 'male'
      };
      
      this.setData(PreloadDataType.USER_INFO, userInfo);
      console.info('[CriticalDataPreloader] 用户信息预加载完成');
    } catch (error) {
      console.error('[CriticalDataPreloader] 用户信息预加载失败:', error);
      throw error;
    }
  }
  
  /**
   * 预加载应用配置
   */
  private async preloadAppConfig(): Promise<void> {
    try {
      // TODO: 从本地存储或API获取应用配置
      // const config = await ConfigService.getAppConfig();
      
      // 模拟数据
      const config = {
        theme: 'light',
        language: 'zh-CN',
        fontSize: 'normal',
        notifications: true,
        autoSync: true
      };
      
      this.setData(PreloadDataType.APP_CONFIG, config);
      console.info('[CriticalDataPreloader] 应用配置预加载完成');
    } catch (error) {
      console.error('[CriticalDataPreloader] 应用配置预加载失败:', error);
      throw error;
    }
  }
  
  /**
   * 预加载首页数据
   */
  private async preloadHomeData(): Promise<void> {
    try {
      // TODO: 从API获取首页数据
      // const homeData = await HomeService.getHomeData();
      
      // 模拟数据
      const homeData = {
        banners: [],
        quickActions: [],
        healthOverview: {},
        recentActivities: []
      };
      
      this.setData(PreloadDataType.HOME_DATA, homeData);
      console.info('[CriticalDataPreloader] 首页数据预加载完成');
    } catch (error) {
      console.error('[CriticalDataPreloader] 首页数据预加载失败:', error);
      throw error;
    }
  }
  
  /**
   * 预加载健康摘要
   */
  private async preloadHealthSummary(): Promise<void> {
    try {
      // TODO: 从API获取健康摘要
      // const summary = await HealthService.getSummary();
      
      // 模拟数据
      const summary = {
        bmi: 22.5,
        heartRate: 72,
        bloodPressure: '120/80',
        bloodSugar: 5.2,
        steps: 8500,
        sleepHours: 7.5
      };
      
      this.setData(PreloadDataType.HEALTH_SUMMARY, summary);
      console.info('[CriticalDataPreloader] 健康摘要预加载完成');
    } catch (error) {
      console.error('[CriticalDataPreloader] 健康摘要预加载失败:', error);
      throw error;
    }
  }
  
  /**
   * 预加载最近记录
   */
  private async preloadRecentRecords(): Promise<void> {
    try {
      // TODO: 从API获取最近记录
      // const records = await RecordService.getRecentRecords();
      
      // 模拟数据
      const records = [
        { id: '1', type: 'appointment', date: '2026-04-26', title: '预约挂号' },
        { id: '2', type: 'health', date: '2026-04-25', title: '健康记录' },
        { id: '3', type: 'medicine', date: '2026-04-24', title: '用药提醒' }
      ];
      
      this.setData(PreloadDataType.RECENT_RECORDS, records);
      console.info('[CriticalDataPreloader] 最近记录预加载完成');
    } catch (error) {
      console.error('[CriticalDataPreloader] 最近记录预加载失败:', error);
      throw error;
    }
  }
  
  /**
   * 预加载通知消息
   */
  private async preloadNotifications(): Promise<void> {
    try {
      // TODO: 从API获取通知消息
      // const notifications = await NotificationService.getNotifications();
      
      // 模拟数据
      const notifications = [
        { id: '1', type: 'system', title: '系统通知', time: '10:30', read: false },
        { id: '2', type: 'health', title: '健康提醒', time: '09:00', read: true }
      ];
      
      this.setData(PreloadDataType.NOTIFICATIONS, notifications);
      console.info('[CriticalDataPreloader] 通知消息预加载完成');
    } catch (error) {
      console.error('[CriticalDataPreloader] 通知消息预加载失败:', error);
      throw error;
    }
  }
}

// 导出单例实例
export const criticalDataPreloader = CriticalDataPreloader.getInstance();
