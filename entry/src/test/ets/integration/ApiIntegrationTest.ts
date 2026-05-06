/**
 * API集成测试
 * 测试API调用和数据流转
 * 
 * @author AI Assistant
 * @date 2026-04-27
 */

import { IntegrationTestSuite, ApiMockConfig, Assert } from './IntegrationTestFramework';
import { MockDataType, mockDataManager } from '../mock/MockDataManager';

export class ApiIntegrationTest extends IntegrationTestSuite {
  constructor() {
    super('API集成测试');
    this.registerTests();
  }
  
  private registerTests(): void {
    // 测试用户API
    this.test('用户API - 获取用户信息', async () => {
      // 设置Mock
      const mockConfig: ApiMockConfig = {
        url: '/api/user/info',
        method: 'GET',
        response: {
          id: 'user_001',
          name: '张三',
          age: 35
        },
        status: 200,
        delay: 100
      };
      
      this.setupApiMocks([mockConfig]);
      
      // 调用API
      const response = await this.apiMock.call('/api/user/info', 'GET');
      
      // 验证
      Assert.notNull(response, '响应不应为空');
      Assert.true(this.verifyApiCall('/api/user/info', 'GET'), '应该调用了API');
      
      this.apiMock.clear();
    });
    
    // 测试健康记录API
    this.test('健康记录API - 提交健康数据', async () => {
      const mockConfig: ApiMockConfig = {
        url: '/api/health/record',
        method: 'POST',
        response: {
          success: true,
          id: 'hr_001'
        },
        status: 200
      };
      
      this.setupApiMocks([mockConfig]);
      
      const data = {
        type: 'blood_pressure',
        value: '120/80',
        timestamp: Date.now()
      };
      
      const response = await this.apiMock.call('/api/health/record', 'POST', data);
      
      Assert.notNull(response, '响应不应为空');
      Assert.equal((response as Record<string, unknown>).success, true, '应该成功');
      
      this.apiMock.clear();
    });
    
    // 测试预约API
    this.test('预约API - 创建预约', async () => {
      const mockConfig: ApiMockConfig = {
        url: '/api/appointment/create',
        method: 'POST',
        response: {
          success: true,
          appointmentId: 'apt_001'
        },
        status: 200
      };
      
      this.setupApiMocks([mockConfig]);
      
      const appointment = {
        hospital: '北京协和医院',
        department: '心内科',
        date: '2026-04-28',
        time: '09:00'
      };
      
      const response = await this.apiMock.call('/api/appointment/create', 'POST', appointment);
      
      Assert.notNull(response, '响应不应为空');
      Assert.equal((response as Record<string, unknown>).success, true, '应该成功');
      
      this.apiMock.clear();
    });
    
    // 测试API错误处理
    this.test('API错误处理 - 应正确处理错误', async () => {
      const mockConfig: ApiMockConfig = {
        url: '/api/error',
        method: 'GET',
        response: null,
        status: 500
      };
      
      this.setupApiMocks([mockConfig]);
      
      try {
        await this.apiMock.call('/api/error', 'GET');
        Assert.true(false, '应该抛出错误');
      } catch (error) {
        Assert.notNull(error, '应该捕获到错误');
      }
      
      this.apiMock.clear();
    });
    
    // 测试API调用记录
    this.test('API调用记录 - 应正确记录调用', async () => {
      const mockConfig: ApiMockConfig = {
        url: '/api/test',
        method: 'GET',
        response: { data: 'test' },
        status: 200
      };
      
      this.setupApiMocks([mockConfig]);
      
      // 调用多次
      await this.apiMock.call('/api/test', 'GET');
      await this.apiMock.call('/api/test', 'GET');
      await this.apiMock.call('/api/test', 'GET');
      
      const callCount = this.getApiCallCount('/api/test', 'GET');
      Assert.equal(callCount, 3, '应该调用了3次');
      
      this.apiMock.clear();
    });
  }
}

/**
 * 数据流集成测试
 */
export class DataFlowIntegrationTest extends IntegrationTestSuite {
  constructor() {
    super('数据流集成测试');
    this.registerTests();
  }
  
  private registerTests(): void {
    // 测试健康数据流
    this.test('健康数据流 - 录入→存储→展示', async () => {
      const { DataFlowTester } = await import('./IntegrationTestFramework');
      
      const result = await DataFlowTester.testFlow([
        {
          name: '录入健康数据',
          action: async () => {
            return { type: 'heart_rate', value: 72, timestamp: Date.now() };
          }
        },
        {
          name: '存储数据',
          action: async (input) => {
            return { ...input as object, id: 'hr_001', saved: true };
          }
        },
        {
          name: '展示数据',
          action: async (input) => {
            return { ...input as object, displayed: true };
          }
        }
      ]);
      
      Assert.true(result.success, '数据流应该成功');
      Assert.equal(result.results.length, 3, '应该有3个步骤结果');
    });
    
    // 测试预约流程
    this.test('预约流程 - 选择→确认→就诊', async () => {
      const { DataFlowTester } = await import('./IntegrationTestFramework');
      
      const result = await DataFlowTester.testFlow([
        {
          name: '选择医院和科室',
          action: async () => {
            return { hospital: '协和医院', department: '心内科' };
          }
        },
        {
          name: '选择医生和时间',
          action: async (input) => {
            return { ...input as object, doctor: '李医生', time: '09:00' };
          }
        },
        {
          name: '确认预约',
          action: async (input) => {
            return { ...input as object, status: 'confirmed', id: 'apt_001' };
          }
        }
      ]);
      
      Assert.true(result.success, '预约流程应该成功');
    });
  }
}
