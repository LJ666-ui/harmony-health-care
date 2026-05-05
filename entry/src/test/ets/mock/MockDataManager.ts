/**
 * Mock数据管理器
 * 提供统一的Mock数据访问和管理功能
 * 
 * @author AI Assistant
 * @date 2026-04-27
 */

/**
 * Mock数据类型
 */
export enum MockDataType {
  USER = 'user',
  HEALTH_RECORD = 'health_record',
  APPOINTMENT = 'appointment',
  AI_CONVERSATION = 'ai_conversation',
  HOSPITAL = 'hospital',
  MEDICINE = 'medicine',
  ARTICLE = 'article'
}

/**
 * Mock场景
 */
export enum MockScenario {
  NORMAL = 'normal',           // 正常场景
  ERROR = 'error',             // 错误场景
  EMPTY = 'empty',             // 空数据场景
  BOUNDARY = 'boundary',       // 边界场景
  PERFORMANCE = 'performance'  // 性能测试场景
}

/**
 * Mock数据配置
 */
export interface MockConfig {
  enabled: boolean;            // 是否启用Mock
  scenario: MockScenario;      // 当前场景
  delay: number;               // 模拟延迟（毫秒）
  errorRate: number;           // 错误率（0-1）
}

/**
 * Mock数据管理器
 */
export class MockDataManager {
  private static instance: MockDataManager | null = null;
  
  // 配置
  private config: MockConfig = {
    enabled: true,
    scenario: MockScenario.NORMAL,
    delay: 100,
    errorRate: 0
  };
  
  // Mock数据存储
  private mockData: Map<string, Map<MockScenario, unknown>> = new Map();
  
  // 私有构造函数
  private constructor() {
    this.initializeMockData();
    console.info('[MockDataManager] 初始化Mock数据管理器');
  }
  
  /**
   * 获取单例实例
   */
  public static getInstance(): MockDataManager {
    if (!MockDataManager.instance) {
      MockDataManager.instance = new MockDataManager();
    }
    return MockDataManager.instance;
  }
  
  /**
   * 获取Mock数据
   * @param type 数据类型
   */
  public async getMockData<T>(type: MockDataType): Promise<T> {
    if (!this.config.enabled) {
      throw new Error('Mock模式未启用');
    }
    
    // 模拟延迟
    await this.simulateDelay();
    
    // 模拟错误
    if (Math.random() < this.config.errorRate) {
      throw new Error(`Mock错误: ${type}`);
    }
    
    const typeData = this.mockData.get(type);
    if (!typeData) {
      throw new Error(`未找到Mock数据: ${type}`);
    }
    
    const scenarioData = typeData.get(this.config.scenario);
    if (!scenarioData) {
      // 降级到正常场景
      const normalData = typeData.get(MockScenario.NORMAL);
      if (!normalData) {
        throw new Error(`未找到Mock数据: ${type} - ${this.config.scenario}`);
      }
      return normalData as T;
    }
    
    return scenarioData as T;
  }
  
  /**
   * 设置Mock数据
   * @param type 数据类型
   * @param scenario 场景
   * @param data 数据
   */
  public setMockData<T>(type: MockDataType, scenario: MockScenario, data: T): void {
    let typeData = this.mockData.get(type);
    
    if (!typeData) {
      typeData = new Map();
      this.mockData.set(type, typeData);
    }
    
    typeData.set(scenario, data);
    console.debug(`[MockDataManager] 设置Mock数据: ${type} - ${scenario}`);
  }
  
  /**
   * 切换场景
   * @param scenario 场景
   */
  public setScenario(scenario: MockScenario): void {
    this.config.scenario = scenario;
    console.info(`[MockDataManager] 切换场景: ${scenario}`);
  }
  
  /**
   * 获取当前场景
   */
  public getScenario(): MockScenario {
    return this.config.scenario;
  }
  
  /**
   * 启用/禁用Mock
   * @param enabled 是否启用
   */
  public setEnabled(enabled: boolean): void {
    this.config.enabled = enabled;
    console.info(`[MockDataManager] Mock模式: ${enabled ? '启用' : '禁用'}`);
  }
  
  /**
   * 更新配置
   */
  public updateConfig(config: Partial<MockConfig>): void {
    this.config = { ...this.config, ...config };
    console.info('[MockDataManager] 更新配置:', JSON.stringify(this.config));
  }
  
  /**
   * 获取当前配置
   */
  public getConfig(): MockConfig {
    return { ...this.config };
  }
  
  /**
   * 清空所有Mock数据
   */
  public clear(): void {
    this.mockData.clear();
    console.info('[MockDataManager] 清空所有Mock数据');
  }
  
  // ==================== 私有方法 ====================
  
  /**
   * 初始化Mock数据
   */
  private initializeMockData(): void {
    // 用户数据
    this.setMockData(MockDataType.USER, MockScenario.NORMAL, {
      id: 'user_001',
      name: '张三',
      avatar: '',
      age: 35,
      gender: 'male',
      phone: '13800138000'
    });
    
    this.setMockData(MockDataType.USER, MockScenario.EMPTY, null);
    
    // 健康记录数据
    this.setMockData(MockDataType.HEALTH_RECORD, MockScenario.NORMAL, [
      {
        id: 'hr_001',
        type: 'blood_pressure',
        value: '120/80',
        unit: 'mmHg',
        timestamp: Date.now() - 3600000
      },
      {
        id: 'hr_002',
        type: 'heart_rate',
        value: 72,
        unit: 'bpm',
        timestamp: Date.now() - 7200000
      }
    ]);
    
    this.setMockData(MockDataType.HEALTH_RECORD, MockScenario.EMPTY, []);
    
    // 预约数据
    this.setMockData(MockDataType.APPOINTMENT, MockScenario.NORMAL, [
      {
        id: 'apt_001',
        hospital: '北京协和医院',
        department: '心内科',
        doctor: '李医生',
        date: '2026-04-28',
        time: '09:00',
        status: 'confirmed'
      }
    ]);
    
    this.setMockData(MockDataType.APPOINTMENT, MockScenario.EMPTY, []);
    
    // AI对话数据
    this.setMockData(MockDataType.AI_CONVERSATION, MockScenario.NORMAL, [
      {
        id: 'conv_001',
        role: 'user',
        content: '我最近感觉心跳有点快',
        timestamp: Date.now() - 1800000
      },
      {
        id: 'conv_002',
        role: 'assistant',
        content: '心跳加快可能有多种原因，建议您测量一下心率，并记录下来。',
        timestamp: Date.now() - 1700000
      }
    ]);
    
    // 医院数据
    this.setMockData(MockDataType.HOSPITAL, MockScenario.NORMAL, [
      {
        id: 'hosp_001',
        name: '北京协和医院',
        address: '北京市东城区帅府园1号',
        level: '三甲',
        departments: ['心内科', '神经内科', '骨科']
      }
    ]);
    
    // 药品数据
    this.setMockData(MockDataType.MEDICINE, MockScenario.NORMAL, [
      {
        id: 'med_001',
        name: '阿司匹林',
        specification: '100mg',
        usage: '口服，一日一次',
        price: 15.5
      }
    ]);
    
    // 科普文章数据
    this.setMockData(MockDataType.ARTICLE, MockScenario.NORMAL, [
      {
        id: 'art_001',
        title: '如何预防高血压',
        author: '王医生',
        content: '高血压是常见的慢性病...',
        publishTime: Date.now() - 86400000
      }
    ]);
    
    console.info('[MockDataManager] 初始化Mock数据完成');
  }
  
  /**
   * 模拟延迟
   */
  private async simulateDelay(): Promise<void> {
    if (this.config.delay > 0) {
      await new Promise(resolve => setTimeout(resolve, this.config.delay));
    }
  }
}

// 导出单例
export const mockDataManager = MockDataManager.getInstance();
