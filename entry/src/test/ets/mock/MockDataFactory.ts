/**
 * Mock数据工厂
 * 生成各类测试数据
 * 
 * @author AI Assistant
 * @date 2026-04-27
 */

import { MockDataType, MockScenario, mockDataManager } from './MockDataManager';

/**
 * Mock数据工厂
 */
export class MockDataFactory {
  /**
   * 创建用户Mock数据
   */
  static createUserMock(overrides?: Record<string, unknown>): Record<string, unknown> {
    const defaultUser = {
      id: `user_${Date.now()}`,
      name: '测试用户',
      avatar: '',
      age: 30,
      gender: 'male',
      phone: '13800138000',
      email: 'test@example.com',
      createTime: Date.now()
    };
    
    return { ...defaultUser, ...overrides };
  }
  
  /**
   * 创建健康记录Mock数据
   */
  static createHealthRecordMock(overrides?: Record<string, unknown>): Record<string, unknown> {
    const defaultRecord = {
      id: `hr_${Date.now()}`,
      type: 'blood_pressure',
      value: '120/80',
      unit: 'mmHg',
      userId: 'user_001',
      timestamp: Date.now(),
      note: ''
    };
    
    return { ...defaultRecord, ...overrides };
  }
  
  /**
   * 创建预约Mock数据
   */
  static createAppointmentMock(overrides?: Record<string, unknown>): Record<string, unknown> {
    const defaultAppointment = {
      id: `apt_${Date.now()}`,
      hospital: '测试医院',
      department: '测试科室',
      doctor: '测试医生',
      date: '2026-04-28',
      time: '09:00',
      userId: 'user_001',
      status: 'pending',
      createTime: Date.now()
    };
    
    return { ...defaultAppointment, ...overrides };
  }
  
  /**
   * 创建AI对话Mock数据
   */
  static createAIConversationMock(overrides?: Record<string, unknown>): Record<string, unknown> {
    const defaultConversation = {
      id: `conv_${Date.now()}`,
      role: 'user',
      content: '测试消息',
      userId: 'user_001',
      timestamp: Date.now()
    };
    
    return { ...defaultConversation, ...overrides };
  }
  
  /**
   * 创建医院Mock数据
   */
  static createHospitalMock(overrides?: Record<string, unknown>): Record<string, unknown> {
    const defaultHospital = {
      id: `hosp_${Date.now()}`,
      name: '测试医院',
      address: '测试地址',
      level: '三甲',
      phone: '010-12345678',
      departments: ['内科', '外科', '儿科'],
      rating: 4.5
    };
    
    return { ...defaultHospital, ...overrides };
  }
  
  /**
   * 创建药品Mock数据
   */
  static createMedicineMock(overrides?: Record<string, unknown>): Record<string, unknown> {
    const defaultMedicine = {
      id: `med_${Date.now()}`,
      name: '测试药品',
      specification: '100mg',
      usage: '口服，一日一次',
      price: 20.0,
      stock: 100,
      manufacturer: '测试药厂'
    };
    
    return { ...defaultMedicine, ...overrides };
  }
  
  /**
   * 创建科普文章Mock数据
   */
  static createArticleMock(overrides?: Record<string, unknown>): Record<string, unknown> {
    const defaultArticle = {
      id: `art_${Date.now()}`,
      title: '测试文章',
      author: '测试作者',
      content: '这是测试文章内容...',
      category: '健康科普',
      publishTime: Date.now(),
      readCount: 0,
      likeCount: 0
    };
    
    return { ...defaultArticle, ...overrides };
  }
  
  /**
   * 批量创建Mock数据
   */
  static createBatch<T>(
    factory: () => T,
    count: number
  ): T[] {
    return Array.from({ length: count }, () => factory());
  }
  
  /**
   * 创建随机数据
   */
  static createRandomData(type: string): unknown {
    switch (type) {
      case 'number':
        return Math.random() * 100;
      
      case 'integer':
        return Math.floor(Math.random() * 100);
      
      case 'string':
        return `random_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
      
      case 'boolean':
        return Math.random() > 0.5;
      
      case 'date':
        return new Date(Date.now() - Math.random() * 86400000 * 30);
      
      case 'array':
        return Array.from({ length: 5 }, () => Math.random());
      
      default:
        return null;
    }
  }
  
  /**
   * 注册到Mock数据管理器
   */
  static registerToManager(): void {
    // 注册正常场景数据
    mockDataManager.setMockData(
      MockDataType.USER,
      MockScenario.NORMAL,
      MockDataFactory.createUserMock()
    );
    
    mockDataManager.setMockData(
      MockDataType.HEALTH_RECORD,
      MockScenario.NORMAL,
      MockDataFactory.createBatch(() => MockDataFactory.createHealthRecordMock(), 5)
    );
    
    mockDataManager.setMockData(
      MockDataType.APPOINTMENT,
      MockScenario.NORMAL,
      MockDataFactory.createBatch(() => MockDataFactory.createAppointmentMock(), 3)
    );
    
    mockDataManager.setMockData(
      MockDataType.AI_CONVERSATION,
      MockScenario.NORMAL,
      MockDataFactory.createBatch(() => MockDataFactory.createAIConversationMock(), 10)
    );
    
    // 注册空数据场景
    mockDataManager.setMockData(MockDataType.USER, MockScenario.EMPTY, null);
    mockDataManager.setMockData(MockDataType.HEALTH_RECORD, MockScenario.EMPTY, []);
    mockDataManager.setMockData(MockDataType.APPOINTMENT, MockScenario.EMPTY, []);
    
    // 注册边界场景
    mockDataManager.setMockData(
      MockDataType.HEALTH_RECORD,
      MockScenario.BOUNDARY,
      MockDataFactory.createBatch(() => MockDataFactory.createHealthRecordMock(), 1000)
    );
    
    console.info('[MockDataFactory] 注册Mock数据到管理器');
  }
}

// 自动注册
MockDataFactory.registerToManager();
