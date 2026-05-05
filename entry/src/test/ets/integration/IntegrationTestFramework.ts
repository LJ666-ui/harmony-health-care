/**
 * 集成测试框架
 * 支持API Mock和数据流测试
 * 
 * @author AI Assistant
 * @date 2026-04-27
 */

import { TestSuite, TestResult } from '../TestFramework';

/**
 * API Mock配置
 */
export interface ApiMockConfig {
  url: string;
  method: string;
  response: unknown;
  status: number;
  delay?: number;
}

/**
 * API调用记录
 */
export interface ApiCallRecord {
  url: string;
  method: string;
  data?: unknown;
  timestamp: number;
}

/**
 * API Mock管理器
 */
export class ApiMockManager {
  private static instance: ApiMockManager | null = null;
  
  // Mock配置映射
  private mocks: Map<string, ApiMockConfig> = new Map();
  
  // API调用记录
  private callRecords: ApiCallRecord[] = [];
  
  // 是否启用Mock
  private enabled: boolean = true;
  
  private constructor() {}
  
  public static getInstance(): ApiMockManager {
    if (!ApiMockManager.instance) {
      ApiMockManager.instance = new ApiMockManager();
    }
    return ApiMockManager.instance;
  }
  
  /**
   * 注册API Mock
   */
  registerMock(config: ApiMockConfig): void {
    const key = `${config.method}_${config.url}`;
    this.mocks.set(key, config);
    console.debug(`[ApiMock] 注册Mock: ${key}`);
  }
  
  /**
   * 批量注册Mock
   */
  registerMocks(configs: ApiMockConfig[]): void {
    configs.forEach(config => this.registerMock(config));
  }
  
  /**
   * 模拟API调用
   */
  async call<T>(url: string, method: string = 'GET', data?: unknown): Promise<T> {
    // 记录调用
    this.callRecords.push({
      url,
      method,
      data,
      timestamp: Date.now()
    });
    
    if (!this.enabled) {
      // 实际调用
      return this.realCall<T>(url, method, data);
    }
    
    // 查找Mock
    const key = `${method}_${url}`;
    const mock = this.mocks.get(key);
    
    if (!mock) {
      throw new Error(`未找到Mock: ${key}`);
    }
    
    // 模拟延迟
    if (mock.delay) {
      await new Promise(resolve => setTimeout(resolve, mock.delay));
    }
    
    // 返回Mock响应
    if (mock.status >= 400) {
      throw new Error(`Mock错误: ${mock.status}`);
    }
    
    return mock.response as T;
  }
  
  /**
   * 实际API调用
   */
  private async realCall<T>(url: string, method: string, data?: unknown): Promise<T> {
    // TODO: 实际的HTTP调用
    throw new Error('实际API调用未实现');
  }
  
  /**
   * 获取调用记录
   */
  getCallRecords(): ApiCallRecord[] {
    return [...this.callRecords];
  }
  
  /**
   * 清空调用记录
   */
  clearCallRecords(): void {
    this.callRecords = [];
  }
  
  /**
   * 启用/禁用Mock
   */
  setEnabled(enabled: boolean): void {
    this.enabled = enabled;
  }
  
  /**
   * 清空所有Mock
   */
  clear(): void {
    this.mocks.clear();
    this.callRecords = [];
  }
}

/**
 * 集成测试基类
 */
export abstract class IntegrationTestSuite extends TestSuite {
  protected apiMock: ApiMockManager;
  
  constructor(suiteName: string) {
    super(suiteName);
    this.apiMock = ApiMockManager.getInstance();
  }
  
  /**
   * 设置API Mock
   */
  protected setupApiMocks(mocks: ApiMockConfig[]): void {
    this.apiMock.registerMocks(mocks);
  }
  
  /**
   * 验证API调用
   */
  protected verifyApiCall(url: string, method: string = 'GET'): boolean {
    const records = this.apiMock.getCallRecords();
    return records.some(r => r.url === url && r.method === method);
  }
  
  /**
   * 获取API调用次数
   */
  protected getApiCallCount(url: string, method: string = 'GET'): number {
    const records = this.apiMock.getCallRecords();
    return records.filter(r => r.url === url && r.method === method).length;
  }
}

/**
 * 数据流测试工具
 */
export class DataFlowTester {
  /**
   * 测试数据流完整性
   */
  static async testFlow(
    steps: Array<{ name: string; action: () => Promise<unknown> }>
  ): Promise<{ success: boolean; results: unknown[] }> {
    const results: unknown[] = [];
    
    for (const step of steps) {
      try {
        console.info(`[DataFlow] 执行步骤: ${step.name}`);
        const result = await step.action();
        results.push(result);
      } catch (error) {
        console.error(`[DataFlow] 步骤失败: ${step.name}`, error);
        return { success: false, results };
      }
    }
    
    return { success: true, results };
  }
  
  /**
   * 测试数据转换
   */
  static testTransformation<T, R>(
    input: T,
    transformer: (input: T) => R,
    validator: (output: R) => boolean
  ): boolean {
    try {
      const output = transformer(input);
      return validator(output);
    } catch (error) {
      console.error('[DataFlow] 转换失败:', error);
      return false;
    }
  }
}

// 导出单例
export const apiMock = ApiMockManager.getInstance();
