/**
 * 神经内科智能体测试用例
 * 
 * 根据项目规划V14.0 - 9.2提示词4要求添加单元测试
 */

import { NeurologyAgent } from '../NeurologyAgent';
import { LLMClient } from '../infrastructure/LLMClient';
import { RAGRetriever } from '../RAGRetriever';

/**
 * 测试套件
 */
export class NeurologyAgentTest {
  private agent: NeurologyAgent;
  
  constructor() {
    // 创建Mock LLM客户端
    const mockLLMClient = {
      generate: async (prompt: string): Promise<string> => {
        return '这是模拟的LLM回复';
      }
    } as LLMClient;
    
    // 创建Mock RAG检索器
    const mockRAGRetriever = {
      retrieve: async (query: string): Promise<any> => {
        return {
          content: '相关医学知识',
          references: [
            { title: '脑梗塞诊疗指南', content: '...' }
          ],
          totalFound: 1,
          filteredCount: 1
        };
      }
    } as RAGRetriever;
    
    this.agent = new NeurologyAgent(mockLLMClient, mockRAGRetriever);
  }
  
  /**
   * 运行所有测试
   */
  async runAllTests(): Promise<void> {
    console.log('=== 神经内科智能体测试开始 ===\n');
    
    await this.testCanHandle();
    await this.testGetConfidenceScore();
    await this.testProcess();
    
    console.log('\n=== 所有测试完成 ===');
  }
  
  /**
   * 测试canHandle方法
   */
  async testCanHandle(): Promise<void> {
    console.log('【测试1】canHandle方法测试');
    
    const testCases = [
      { question: '我最近经常头痛', expected: true },
      { question: '脑梗塞怎么治疗', expected: true },
      { question: '帕金森病的症状', expected: true },
      { question: '记忆力下降是什么原因', expected: true },
      { question: '手抖是什么病', expected: true },
      { question: '感冒发烧怎么办', expected: false },
      { question: '高血压怎么控制', expected: false }
    ];
    
    let passed = 0;
    let failed = 0;
    
    for (const testCase of testCases) {
      const result = this.agent.canHandle(testCase.question);
      const status = result === testCase.expected ? '✅ 通过' : '❌ 失败';
      
      if (result === testCase.expected) {
        passed++;
      } else {
        failed++;
      }
      
      console.log(`  ${status} - 问题: "${testCase.question}" - 结果: ${result} - 期望: ${testCase.expected}`);
    }
    
    console.log(`  总计: ${passed}个通过, ${failed}个失败\n`);
  }
  
  /**
   * 测试getConfidenceScore方法
   */
  async testGetConfidenceScore(): Promise<void> {
    console.log('【测试2】getConfidenceScore方法测试');
    
    const testCases = [
      { question: '脑梗塞急性期怎么处理', minScore: 0.9 },
      { question: '帕金森病用药指导', minScore: 0.85 },
      { question: '偏头痛怎么治疗', minScore: 0.8 },
      { question: '老年痴呆早期症状', minScore: 0.8 },
      { question: '手脚麻木是什么原因', minScore: 0.75 },
      { question: '感冒发烧', minScore: 0 }
    ];
    
    let passed = 0;
    let failed = 0;
    
    for (const testCase of testCases) {
      const score = this.agent.getConfidenceScore(testCase.question);
      const status = score >= testCase.minScore ? '✅ 通过' : '❌ 失败';
      
      if (score >= testCase.minScore) {
        passed++;
      } else {
        failed++;
      }
      
      console.log(`  ${status} - 问题: "${testCase.question}" - 得分: ${score.toFixed(2)} - 最低期望: ${testCase.minScore}`);
    }
    
    console.log(`  总计: ${passed}个通过, ${failed}个失败\n`);
  }
  
  /**
   * 测试process方法
   */
  async testProcess(): Promise<void> {
    console.log('【测试3】process方法测试');
    
    const testQuestions = [
      '我最近经常头痛，特别是左边',
      '脑梗塞后遗症怎么康复',
      '帕金森病早期有什么症状'
    ];
    
    for (const question of testQuestions) {
      try {
        console.log(`  测试问题: "${question}"`);
        const answer = await this.agent.process(question);
        
        console.log(`    ✅ 回答生成成功`);
        console.log(`    - Agent: ${answer.agentName}`);
        console.log(`    - 置信度: ${answer.confidence.toFixed(2)}`);
        console.log(`    - 知识引用: ${answer.knowledgeUsed?.length || 0}条`);
        console.log(`    - 回答长度: ${answer.content.length}字符\n`);
      } catch (error) {
        console.log(`    ❌ 回答生成失败: ${error}\n`);
      }
    }
  }
}

/**
 * 运行测试
 */
export async function runNeurologyAgentTests(): Promise<void> {
  const test = new NeurologyAgentTest();
  await test.runAllTests();
}
