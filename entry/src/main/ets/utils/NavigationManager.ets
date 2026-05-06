/**
 * 导航管理器
 * 提供统一的页面导航接口，封装路由操作
 */

import { router } from '@kit.ArkUI';
import { NavigationErrorHandler, NavigationError } from './NavigationErrorHandler';
import { RouteConfigManager } from '../config/RouteConfigManager';
import { NavigationParams, NavigationErrorType } from '../types/NavigationTypes';

/**
 * 导航配置常量
 */
class NavigationConfig {
  /**
   * 导航历史最大长度
   */
  public static readonly MAX_HISTORY_SIZE: number = 50;

  /**
   * 导航超时时间（毫秒）
   */
  public static readonly NAVIGATION_TIMEOUT: number = 5000;

  /**
   * 是否启用导航日志
   */
  public static readonly ENABLE_NAVIGATION_LOG: boolean = true;

  /**
   * 是否启用性能监控
   */
  public static readonly ENABLE_PERFORMANCE_MONITOR: boolean = true;
}

/**
 * 导航管理器（单例模式）
 */
export class NavigationManager {
  private static instance: NavigationManager;

  /**
   * 导航历史记录
   */
  private navigationHistory: string[] = [];

  /**
   * 私有构造函数（单例模式）
   */
  private constructor() {
    // 确保路由配置已初始化
    RouteConfigManager.getInstance();
  }

  /**
   * 获取单例实例
   */
  public static getInstance(): NavigationManager {
    if (!NavigationManager.instance) {
      NavigationManager.instance = new NavigationManager();
    }
    return NavigationManager.instance;
  }

  /**
   * 页面跳转（无参数）
   * @param url 目标页面路径
   * @returns Promise<void>
   */
  public async navigateTo(url: string): Promise<void> {
    const startTime = Date.now();

    try {
      // 验证路由路径
      if (!this.validateRoute(url)) {
        throw NavigationErrorHandler.createRouteNotFoundError(url);
      }

      // 记录导航开始
      this.logNavigation('NAVIGATE_TO', url);

      // 执行跳转
      await router.pushUrl({ url: url });

      // 记录导航历史
      this.addToHistory(url);

      // 记录导航成功
      this.logNavigationSuccess(url, startTime);

    } catch (error) {
      // 错误处理
      NavigationErrorHandler.handle(error as Error, url);
      throw error;
    }
  }

  /**
   * 页面跳转（带参数）
   * @param url 目标页面路径
   * @param params 导航参数
   * @returns Promise<void>
   */
  public async navigateWithParams<T extends NavigationParams>(url: string, params: T): Promise<void> {
    const startTime = Date.now();

    try {
      // 验证路由路径
      if (!this.validateRoute(url)) {
        throw NavigationErrorHandler.createRouteNotFoundError(url);
      }

      // 验证参数
      if (!params || typeof params !== 'object') {
        throw NavigationErrorHandler.createInvalidParamsError(url, 'params is null or not an object');
      }

      // 记录导航开始
      this.logNavigation('NAVIGATE_WITH_PARAMS', url, params);

      // 执行带参数跳转
      await router.pushUrl({
        url: url,
        params: params
      });

      // 记录导航历史
      this.addToHistory(url);

      // 记录导航成功
      this.logNavigationSuccess(url, startTime);

    } catch (error) {
      // 错误处理
      NavigationErrorHandler.handle(error as Error, url);
      throw error;
    }
  }

  /**
   * 返回上一页
   * @returns Promise<void>
   */
  public async goBack(): Promise<void> {
    try {
      this.logNavigation('GO_BACK', 'previous page');

      await router.back();

      // 从历史记录中移除当前页面
      if (this.navigationHistory.length > 0) {
        this.navigationHistory.pop();
      }

    } catch (error) {
      console.error('[NavigationManager] 返回失败:', error);
      throw error;
    }
  }

  /**
   * 返回到指定页面
   * @param url 目标页面路径
   * @returns Promise<void>
   */
  public async backTo(url: string): Promise<void> {
    try {
      this.logNavigation('BACK_TO', url);

      // 使用 router.back() 返回到指定页面
      // 注意：HarmonyOS router.back() 可以指定返回的页面
      await router.back({ url: url });

      // 清理历史记录
      const index = this.navigationHistory.lastIndexOf(url);
      if (index !== -1) {
        this.navigationHistory = this.navigationHistory.slice(0, index + 1);
      }

    } catch (error) {
      NavigationErrorHandler.handle(error as Error, url);
      throw error;
    }
  }

  /**
   * 替换当前页面
   * @param url 目标页面路径
   * @returns Promise<void>
   */
  public async replace(url: string): Promise<void> {
    const startTime = Date.now();

    try {
      // 验证路由路径
      if (!this.validateRoute(url)) {
        throw NavigationErrorHandler.createRouteNotFoundError(url);
      }

      this.logNavigation('REPLACE', url);

      // 使用 router.replaceUrl() 替换当前页面
      await router.replaceUrl({ url: url });

      // 更新历史记录（替换最后一项）
      if (this.navigationHistory.length > 0) {
        this.navigationHistory[this.navigationHistory.length - 1] = url;
      } else {
        this.addToHistory(url);
      }

      this.logNavigationSuccess(url, startTime);

    } catch (error) {
      NavigationErrorHandler.handle(error as Error, url);
      throw error;
    }
  }

  /**
   * 替换当前页面（带参数）
   * @param url 目标页面路径
   * @param params 导航参数
   * @returns Promise<void>
   */
  public async replaceWithParams<T extends NavigationParams>(url: string, params: T): Promise<void> {
    const startTime = Date.now();

    try {
      // 验证路由路径
      if (!this.validateRoute(url)) {
        throw NavigationErrorHandler.createRouteNotFoundError(url);
      }

      // 验证参数
      if (!params || typeof params !== 'object') {
        throw NavigationErrorHandler.createInvalidParamsError(url, 'params is null or not an object');
      }

      this.logNavigation('REPLACE_WITH_PARAMS', url, params);

      // 执行替换跳转
      await router.replaceUrl({
        url: url,
        params: params
      });

      // 更新历史记录
      if (this.navigationHistory.length > 0) {
        this.navigationHistory[this.navigationHistory.length - 1] = url;
      } else {
        this.addToHistory(url);
      }

      this.logNavigationSuccess(url, startTime);

    } catch (error) {
      NavigationErrorHandler.handle(error as Error, url);
      throw error;
    }
  }

  /**
   * 获取当前页面路径
   * @returns string
   */
  public getCurrentPage(): string {
    if (this.navigationHistory.length > 0) {
      return this.navigationHistory[this.navigationHistory.length - 1];
    }
    return '';
  }

  /**
   * 获取导航历史
   * @returns string[]
   */
  public getHistory(): string[] {
    return [...this.navigationHistory];
  }

  /**
   * 清空导航历史
   */
  public clearHistory(): void {
    this.navigationHistory = [];
    console.info('[NavigationManager] 导航历史已清空');
  }

  /**
   * 验证路由路径
   * @param url 路由路径
   * @returns boolean
   */
  private validateRoute(url: string): boolean {
    return RouteConfigManager.getInstance().hasRoute(url);
  }

  /**
   * 添加到导航历史
   * @param url 页面路径
   */
  private addToHistory(url: string): void {
    // 限制历史记录长度
    if (this.navigationHistory.length >= NavigationConfig.MAX_HISTORY_SIZE) {
      this.navigationHistory.shift();
    }

    this.navigationHistory.push(url);
  }

  /**
   * 记录导航日志
   * @param action 导航动作
   * @param url 目标URL
   * @param params 参数（可选）
   */
  private logNavigation(action: string, url: string, params?: NavigationParams): void {
    if (!NavigationConfig.ENABLE_NAVIGATION_LOG) {
      return;
    }

    const logEntry = {
      timestamp: new Date().toISOString(),
      action: action,
      url: url,
      hasParams: !!params,
      currentHistory: this.navigationHistory.length
    };

    console.info('[NavigationManager]', JSON.stringify(logEntry));
  }

  /**
   * 记录导航成功日志
   * @param url 目标URL
   * @param startTime 开始时间
   */
  private logNavigationSuccess(url: string, startTime: number): void {
    if (!NavigationConfig.ENABLE_PERFORMANCE_MONITOR) {
      return;
    }

    const duration = Date.now() - startTime;

    if (duration > 500) {
      console.warn(`[NavigationManager] 慢导航警告: ${url} 耗时 ${duration}ms`);
    } else {
      console.info(`[NavigationManager] 导航成功: ${url} 耗时 ${duration}ms`);
    }
  }

  /**
   * 获取导航历史长度
   * @returns number
   */
  public getHistoryLength(): number {
    return this.navigationHistory.length;
  }

  /**
   * 检查是否可以返回
   * @returns boolean
   */
  public canGoBack(): boolean {
    return this.navigationHistory.length > 1;
  }

  /**
   * 获取上一页面路径
   * @returns string | null
   */
  public getPreviousPage(): string | null {
    if (this.navigationHistory.length > 1) {
      return this.navigationHistory[this.navigationHistory.length - 2];
    }
    return null;
  }
}
