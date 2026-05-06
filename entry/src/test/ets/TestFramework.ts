/**
 * 单元测试基类
 * 提供测试框架的基础功能
 * 
 * @author AI Assistant
 * @date 2026-04-27
 */

/**
 * 测试结果
 */
export interface TestResult {
  testName: string;
  passed: boolean;
  duration: number;
  error?: Error;
  message?: string;
}

/**
 * 测试套件结果
 */
export interface TestSuiteResult {
  suiteName: string;
  tests: TestResult[];
  passed: number;
  failed: number;
  total: number;
  duration: number;
}

/**
 * 断言类
 */
export class Assert {
  /**
   * 相等断言
   */
  static equal<T>(actual: T, expected: T, message?: string): void {
    if (actual !== expected) {
      throw new Error(message || `期望 ${expected}，实际 ${actual}`);
    }
  }
  
  /**
   * 深度相等断言
   */
  static deepEqual<T>(actual: T, expected: T, message?: string): void {
    if (JSON.stringify(actual) !== JSON.stringify(expected)) {
      throw new Error(message || `深度比较失败`);
    }
  }
  
  /**
   * 不相等断言
   */
  static notEqual<T>(actual: T, expected: T, message?: string): void {
    if (actual === expected) {
      throw new Error(message || `不应等于 ${expected}`);
    }
  }
  
  /**
   * 真值断言
   */
  static true(value: boolean, message?: string): void {
    if (!value) {
      throw new Error(message || '期望为真');
    }
  }
  
  /**
   * 假值断言
   */
  static false(value: boolean, message?: string): void {
    if (value) {
      throw new Error(message || '期望为假');
    }
  }
  
  /**
   * 空值断言
   */
  static isNull(value: unknown, message?: string): void {
    if (value !== null) {
      throw new Error(message || '期望为null');
    }
  }
  
  /**
   * 非空断言
   */
  static notNull(value: unknown, message?: string): void {
    if (value === null || value === undefined) {
      throw new Error(message || '期望非null');
    }
  }
  
  /**
   * 包含断言
   */
  static contains<T>(array: T[], item: T, message?: string): void {
    if (!array.includes(item)) {
      throw new Error(message || `数组不包含 ${item}`);
    }
  }
  
  /**
   * 大于断言
   */
  static greaterThan(actual: number, expected: number, message?: string): void {
    if (actual <= expected) {
      throw new Error(message || `期望大于 ${expected}，实际 ${actual}`);
    }
  }
  
  /**
   * 小于断言
   */
  static lessThan(actual: number, expected: number, message?: string): void {
    if (actual >= expected) {
      throw new Error(message || `期望小于 ${expected}，实际 ${actual}`);
    }
  }
  
  /**
   * 抛出异常断言
   */
  static async throws(fn: () => Promise<void>, message?: string): Promise<void> {
    try {
      await fn();
      throw new Error(message || '期望抛出异常');
    } catch (error) {
      // 预期的异常
    }
  }
}

/**
 * 测试基类
 */
export abstract class TestSuite {
  protected suiteName: string;
  protected tests: Array<{ name: string; fn: () => Promise<void> }> = [];
  
  constructor(suiteName: string) {
    this.suiteName = suiteName;
  }
  
  /**
   * 添加测试
   */
  protected test(name: string, fn: () => Promise<void>): void {
    this.tests.push({ name, fn });
  }
  
  /**
   * 设置（每个测试前执行）
   */
  protected async beforeEach(): Promise<void> {}
  
  /**
   * 清理（每个测试后执行）
   */
  protected async afterEach(): Promise<void> {}
  
  /**
   * 套件设置（所有测试前执行一次）
   */
  protected async beforeAll(): Promise<void> {}
  
  /**
   * 套件清理（所有测试后执行一次）
   */
  protected async afterAll(): Promise<void> {}
  
  /**
   * 运行所有测试
   */
  async run(): Promise<TestSuiteResult> {
    console.info(`\n========== ${this.suiteName} ==========`);
    
    const results: TestResult[] = [];
    const suiteStartTime = Date.now();
    
    // 执行套件设置
    await this.beforeAll();
    
    // 执行所有测试
    for (const test of this.tests) {
      const result = await this.runTest(test.name, test.fn);
      results.push(result);
    }
    
    // 执行套件清理
    await this.afterAll();
    
    const suiteDuration = Date.now() - suiteStartTime;
    const passed = results.filter(r => r.passed).length;
    const failed = results.filter(r => !r.passed).length;
    
    const suiteResult: TestSuiteResult = {
      suiteName: this.suiteName,
      tests: results,
      passed,
      failed,
      total: results.length,
      duration: suiteDuration
    };
    
    // 打印结果
    this.printResult(suiteResult);
    
    return suiteResult;
  }
  
  /**
   * 运行单个测试
   */
  private async runTest(name: string, fn: () => Promise<void>): Promise<TestResult> {
    const startTime = Date.now();
    
    try {
      // 执行设置
      await this.beforeEach();
      
      // 执行测试
      await fn();
      
      // 执行清理
      await this.afterEach();
      
      const duration = Date.now() - startTime;
      
      console.info(`  ✓ ${name} (${duration}ms)`);
      
      return {
        testName: name,
        passed: true,
        duration
      };
    } catch (error) {
      const duration = Date.now() - startTime;
      
      console.error(`  ✗ ${name} (${duration}ms)`);
      console.error(`    ${error}`);
      
      return {
        testName: name,
        passed: false,
        duration,
        error: error as Error,
        message: (error as Error).message
      };
    }
  }
  
  /**
   * 打印结果
   */
  private printResult(result: TestSuiteResult): void {
    console.info(`\n${this.suiteName} 结果:`);
    console.info(`  通过: ${result.passed}/${result.total}`);
    console.info(`  失败: ${result.failed}/${result.total}`);
    console.info(`  耗时: ${result.duration}ms`);
  }
}

/**
 * 测试运行器
 */
export class TestRunner {
  private suites: TestSuite[] = [];
  
  /**
   * 添加测试套件
   */
  addSuite(suite: TestSuite): void {
    this.suites.push(suite);
  }
  
  /**
   * 运行所有测试套件
   */
  async runAll(): Promise<void> {
    console.info('\n========================================');
    console.info('开始运行测试');
    console.info('========================================');
    
    const startTime = Date.now();
    let totalPassed = 0;
    let totalFailed = 0;
    
    for (const suite of this.suites) {
      const result = await suite.run();
      totalPassed += result.passed;
      totalFailed += result.failed;
    }
    
    const duration = Date.now() - startTime;
    
    console.info('\n========================================');
    console.info('测试总结');
    console.info('========================================');
    console.info(`总通过: ${totalPassed}`);
    console.info(`总失败: ${totalFailed}`);
    console.info(`总耗时: ${duration}ms`);
    console.info('========================================\n');
  }
}
