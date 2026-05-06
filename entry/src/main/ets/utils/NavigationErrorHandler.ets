/**
 * 导航错误处理器
 * 统一处理导航过程中的各种错误
 */

import { NavigationErrorType } from '../types/NavigationTypes';

/**
 * 导航错误类
 */
export class NavigationError extends Error {
  public type: NavigationErrorType;
  public url: string;
  public timestamp: number;

  constructor(message: string, type: NavigationErrorType, url: string) {
    super(message);
    this.type = type;
    this.url = url;
    this.timestamp = Date.now();
    this.name = 'NavigationError';
  }
}

/**
 * 导航错误处理器
 */
export class NavigationErrorHandler {
  /**
   * 错误类型对应的用户友好提示信息
   */
  private static readonly ERROR_MESSAGES: Record<NavigationErrorType, string> = {
    [NavigationErrorType.ROUTE_NOT_FOUND]: '页面不存在，请检查路由配置',
    [NavigationErrorType.INVALID_PARAMS]: '导航参数错误，请重试',
    [NavigationErrorType.NAVIGATION_FAILED]: '页面跳转失败，请稍后重试',
    [NavigationErrorType.PERMISSION_DENIED]: '权限不足，无法访问该页面'
  };

  /**
   * 处理导航错误
   * @param error 错误对象
   * @param url 目标URL
   */
  public static handle(error: Error | NavigationError, url: string): void {
    // 确定错误类型
    const errorType = error instanceof NavigationError
      ? error.type
      : NavigationErrorType.NAVIGATION_FAILED;

    // 记录错误日志
    NavigationErrorHandler.logError(error, url, errorType);

    // 获取用户友好的错误消息
    const userMessage = NavigationErrorHandler.getUserMessage(errorType);

    // 显示错误提示（使用console输出，实际应用中可替换为Toast）
    console.error(`[导航错误] ${userMessage} (目标: ${url})`);

    // 在实际应用中，这里可以调用Toast或Dialog显示错误
    // ToastUtil.showError(userMessage);
  }

  /**
   * 获取用户友好的错误消息
   * @param errorType 错误类型
   * @returns 用户友好的错误消息
   */
  private static getUserMessage(errorType: NavigationErrorType): string {
    return NavigationErrorHandler.ERROR_MESSAGES[errorType];
  }

  /**
   * 记录错误日志
   * @param error 错误对象
   * @param url 目标URL
   * @param errorType 错误类型
   */
  private static logError(error: Error, url: string, errorType: NavigationErrorType): void {
    const logEntry = {
      timestamp: new Date().toISOString(),
      level: 'ERROR',
      category: 'NAVIGATION',
      errorType: errorType,
      url: url,
      message: error.message,
      stack: error.stack
    };

    // 输出详细日志
    console.error('[NavigationErrorHandler]', JSON.stringify(logEntry, null, 2));
  }

  /**
   * 创建路由不存在错误
   * @param url 路由路径
   * @returns NavigationError
   */
  public static createRouteNotFoundError(url: string): NavigationError {
    return new NavigationError(
      `Route not found: ${url}`,
      NavigationErrorType.ROUTE_NOT_FOUND,
      url
    );
  }

  /**
   * 创建参数无效错误
   * @param url 路由路径
   * @param reason 原因
   * @returns NavigationError
   */
  public static createInvalidParamsError(url: string, reason?: string): NavigationError {
    return new NavigationError(
      `Invalid navigation params: ${reason || 'unknown'}`,
      NavigationErrorType.INVALID_PARAMS,
      url
    );
  }

  /**
   * 创建导航失败错误
   * @param url 路由路径
   * @param originalError 原始错误
   * @returns NavigationError
   */
  public static createNavigationFailedError(url: string, originalError?: Error): NavigationError {
    return new NavigationError(
      `Navigation failed: ${originalError?.message || 'unknown error'}`,
      NavigationErrorType.NAVIGATION_FAILED,
      url
    );
  }

  /**
   * 创建权限拒绝错误
   * @param url 路由路径
   * @returns NavigationError
   */
  public static createPermissionDeniedError(url: string): NavigationError {
    return new NavigationError(
      `Permission denied for route: ${url}`,
      NavigationErrorType.PERMISSION_DENIED,
      url
    );
  }
}
