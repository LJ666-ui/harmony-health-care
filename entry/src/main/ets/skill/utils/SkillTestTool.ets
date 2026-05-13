import HarmonyHealthCareSkill from './HarmonyHealthCareSkill';

/**
 * Skill测试工具类
 * 
 * 使用方法:
 * 1. 在任意Page的aboutToAppear()中调用 testAllIntents()
 * 2. 或单独调用测试某个意图
 */

const TAG = '[SkillTestTool]';

export class SkillTestTool {
  private skill: typeof HarmonyHealthCareSkill;
  private testResults: TestResult[] = [];

  constructor() {
    this.skill = HarmonyHealthCareSkill;
  }

  /**
   * 运行全部测试用例
   */
  async runAllTests(): Promise<TestSummary> {
    console.log(`${TAG} 🚀 开始运行全部测试用例...`);
    this.testResults = [];

    // 测试所有意图
    await this.testAppointmentBooking();
    await this.testNavigation();
    await this.testEmergency();
    await this.testHealthQuery();
    await this.testRiskAssessment();
    await this.testMedicationReminder();
    await this.testRehabTraining();
    await this.testDeviceControl();

    // 生成测试报告
    const summary = this.generateSummary();
    
    console.log(`${TAG} ✅ 测试完成！`);
    console.log(`${TAG} 通过率: ${summary.passRate}%`);
    
    return summary;
  }

  /**
   * 测试挂号预约意图
   */
  private async testAppointmentBooking(): Promise<void> {
    const testName = '挂号预约';
    const testCases = [
      { input: '帮我挂号', expectedContains: ['预约', '挂号'] },
      { input: '挂号张医生明天', expectedContains: ['张医生'] },
      { input: '预约下周三上午', expectedContains: ['下周三', '上午'] },
      { input: '取消预约', expectedContains: ['取消'] }
    ];

    for (const tc of testCases) {
      try {
        const result = await this.skill.handleQuickCommand(tc.input);
        const passed = tc.expectedContains.every(keyword => 
          result.ttsText.includes(keyword)
        );
        
        this.addResult(testName, tc.input, passed, result);
      } catch (error) {
        this.addResult(testName, tc.input, false, null, error as string);
      }
    }
  }

  /**
   * 测试导航意图
   */
  private async testNavigation(): Promise<void> {
    const testName = 'AR导航';
    const testCases = [
      { input: '导航去内科', expectedContains: ['导航', '内科'] },
      { input: '怎么走', expectedContains: ['导航'] },
      { input: '打开AR导航', expectedContains: ['AR'] }
    ];

    for (const tc of testCases) {
      try {
        const result = await this.skill.handleQuickCommand(tc.input);
        const passed = tc.expectedIncludes.some(keyword => 
          result.ttsText.includes(keyword)
        );
        
        this.addResult(testName, tc.input, passed, result);
      } catch (error) {
        this.addResult(testName, tc.input, false, null, error as string);
      }
    }
  }

  /**
   * 测试紧急意图
   */
  private async testEmergency(): Promise<void> {
    const testName = '紧急求助';
    const testCases = [
      { input: '救命', expectedContains: ['120', '紧急'] },
      { input: '打120', expectedContains: ['120'] },
      { input: '晕倒了', expectedContains: ['紧急', '120'] }
    ];

    for (const tc of testCases) {
      try {
        const startTime = Date.now();
        const result = await this.skill.handleQuickCommand(tc.input);
        const elapsed = Date.now() - startTime;
        
        const passed = tc.expectedContains.every(keyword => 
          result.ttsText.includes(keyword)
        ) && elapsed < 500;  // 紧急响应必须<500ms
        
        this.addResult(testName, tc.input, passed, result, undefined, elapsed);
      } catch (error) {
        this.addResult(testName, tc.input, false, null, error as string);
      }
    }
  }

  /**
   * 测试健康查询意图
   */
  private async testHealthQuery(): Promise<void> {
    const testName = '健康查询';
    const testCases = [
      { input: '血压怎么样', expectedContains: ['血压', '记录'] },
      { input: '查看血糖记录', expectedContains: ['血糖'] },
      { input: '我的健康数据', expectedContains: ['健康'] }
    ];

    for (const tc of testCases) {
      try {
        const result = await this.skill.handleQuickCommand(tc.input);
        const passed = tc.expectedContains.some(keyword => 
          result.ttsText.includes(keyword)
        );
        
        this.addResult(testName, tc.input, passed, result);
      } catch (error) {
        this.addResult(testName, tc.input, false, null, error as string);
      }
    }
  }

  /**
   * 测试风险评估意图
   */
  private async testRiskAssessment(): Promise<void> {
    const testName = '风险评估';
    
    try {
      const result = await this.skill.handleQuickCommand('评估风险');
      const passed = result.ttsText.includes('评估') || result.ttsText.includes('风险');
      
      this.addResult(testName, '评估风险', passed, result);
    } catch (error) {
      this.addResult(testName, '评估风险', false, null, error as string);
    }
  }

  /**
   * 测试用药提醒意图
   */
  private async testMedicationReminder(): Promise<void> {
    const testName = '用药提醒';
    
    try {
      const result = await this.skill.handleQuickCommand('该吃药了');
      const passed = result.ttsText.includes('药') || result.ttsText.includes('用药');
      
      this.addResult(testName, '该吃药了', passed, result);
    } catch (error) {
      this.addResult(testName, '该吃药了', false, null, error as string);
    }
  }

  /**
   * 测试康复训练意图
   */
  private async testRehabTraining(): Promise<void> {
    const testName = '康复训练';
    
    try {
      const result = await this.skill.handleQuickCommand('开始康复训练');
      const passed = result.ttsText.includes('康复') || result.ttsText.includes('训练');
      
      this.addResult(testName, '开始康复训练', passed, result);
    } catch (error) {
      this.addResult(testName, '开始康复训练', false, null, error as string);
    }
  }

  /**
   * 测试设备管理意图
   */
  private async testDeviceControl(): Promise<void> {
    const testName = '设备管理';
    
    try {
      const result = await this.skill.handleQuickCommand('连接设备');
      const passed = result.ttsText.includes('设备') || result.ttsText.includes('连接');
      
      this.addResult(testName, '连接设备', passed, result);
    } catch (error) {
      this.addResult(testName, '连接设备', false, null, error as string);
    }
  }

  /**
   * 添加测试结果
   */
  private addResult(
    testName: string, 
    input: string, 
    passed: boolean, 
    result: any, 
    error?: string,
    elapsedTime?: number
  ): void {
    const testResult: TestResult = {
      testName,
      input,
      passed,
      timestamp: new Date().toISOString(),
      response: result ? {
        ttsText: result.ttsText,
        confidence: result.confidence,
        processingTime: result.metadata?.processingTime
      } : null,
      error,
      elapsedTime
    };

    this.testResults.push(testResult);

    const icon = passed ? '✅' : '❌';
    console.log(`${TAG} ${icon} [${testName}] "${input}" - ${passed ? '通过' : '失败'}`);
    
    if (error) {
      console.error(`${TAG} ❌ 错误: ${error}`);
    }
  }

  /**
   * 生成测试摘要
   */
  private generateSummary(): TestSummary {
    const total = this.testResults.length;
    const passed = this.testResults.filter(r => r.passed).length;
    const failed = total - passed;

    return {
      total,
      passed,
      failed,
      passRate: Math.round((passed / total) * 100),
      results: this.testResults,
      generatedAt: new Date().toISOString()
    };
  }

  /**
   * 打印详细报告
   */
  printDetailedReport(): void {
    console.log('\n' + '='.repeat(80));
    console.log('📊 小艺Skill测试报告');
    console.log('='.repeat(80));
    
    const summary = this.generateSummary();
    
    console.log(`\n总览:`);
    console.log(`  总计测试: ${summary.total}`);
    console.log(`  ✅ 通过: ${summary.passed}`);
    console.log(`  ❌ 失败: ${summary.failed}`);
    console.log(`  📈 通过率: ${summary.passRate}%`);
    
    console.log(`\n详细结果:`);
    console.log('-'.repeat(80));
    
    for (const result of summary.results) {
      const icon = result.passed ? '✅' : '❌';
      const time = result.elapsedTime ? ` (${result.elapsedTime}ms)` : '';
      console.log(`${icon} [${result.testName}] "${result.input}"${time}`);
      
      if (result.response) {
        console.log(`   回复: ${result.response.ttsText?.substring(0, 50)}...`);
        console.log(`   置信度: ${result.response.confidence}`);
        console.log(`   耗时: ${result.response.processingTime}ms`);
      }
      
      if (result.error) {
        console.log(`   错误: ${result.error}`);
      }
    }
    
    console.log('\n' + '='.repeat(80));
    console.log(`报告生成时间: ${summary.generatedAt}`);
    console.log('='.repeat(80) + '\n');
  }
}

// 类型定义
interface TestResult {
  testName: string;
  input: string;
  passed: boolean;
  timestamp: string;
  response?: {
    ttsText: string;
    confidence: number;
    processingTime: number;
  } | null;
  error?: string;
  elapsedTime?: number;
}

interface TestSummary {
  total: number;
  passed: number;
  failed: number;
  passRate: number;
  results: TestResult[];
  generatedAt: string;
}

// 导出单例
export default new SkillTestTool();

// 便捷函数
export async function runSkillTests(): Promise<TestSummary> {
  const tester = new SkillTestTool();
  return await tester.runAllTests();
}
