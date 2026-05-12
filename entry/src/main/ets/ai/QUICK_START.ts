/**
 * 多智能体系统 - 快速开始指南
 * 
 * 本文件展示如何在项目中使用五层AI智能体架构
 */

import { AIOrchestrator } from './orchestrator/AIOrchestrator';
import { AIRequest, AIResponse, AgentId } from './models/AITypes';

// ==================== 基础用法 ====================

export async function basicUsageExample() {
  // 1. 获取调度器实例（单例模式）
  const orchestrator = AIOrchestrator.getInstance();

  // 2. 构建请求
  const request: AIRequest = {
    requestId: 'req_001',
    userId: 'user_123',
    input: {
      type: 'text',
      content: '帮我挂号张医生明天上午'
    },
    preferences: {
      priority: 'speed', // 优先速度
      maxLatency: 1000   // 最大延迟1秒
    }
  };

  // 3. 发送请求（自动路由到最合适的智能体）
  const response: AIResponse = await orchestrator.process(request);

  // 4. 处理响应
  console.log('回复内容:', response.output.content);
  console.log('使用智能体:', response.agentId);
  console.log('置信度:', response.output.confidence);
  console.log('处理时间:', response.metadata.processingTime, 'ms');
  
  if (response.suggestions) {
    console.log('建议操作:', response.suggestions);
  }
}

// ==================== 场景化示例 ====================

// 示例1：语音命令 → 小艺处理
export async function voiceCommandExample() {
  const orchestrator = AIOrchestrator.getInstance();

  const voiceRequest: AIRequest = {
    requestId: 'voice_001',
    userId: 'user_456',
    input: {
      type: 'voice',
      content: '小艺小艺，打开AR导航去内科'
    },
    preferences: {
      preferredAgent: 'xiaoyi' // 明确指定小艺
    }
  };

  const response = await orchestrator.process(voiceRequest);
  // 预期: 小艺直接执行导航命令，响应 < 500ms
}

// 示例2：健康咨询 → DeepSeek处理
export async function healthConsultationExample() {
  const orchestrator = AIOrchestrator.getInstance();

  const consultRequest: AIRequest = {
    requestId: 'consult_001',
    userId: 'user_789',
    input: {
      type: 'text',
      content: '我最近总是头晕，可能是什麼原因？需要注意什么？'
    },
    conversationHistory: [
      { role: 'user', content: '你好', timestamp: Date.now() - 60000 },
      { role: 'assistant', content: '您好！我是康小智，有什么可以帮您的？', timestamp: Date.now() - 55000, agentId: 'deepseek' }
    ]
  };

  const response = await orchestrator.process(consultRequest);
  // 预期: DeepSeek深度分析，给出专业建议，响应 1-2s
}

// 示例3：风险评估 → MindSpore本地推理
export async function riskAssessmentExample() {
  const orchestrator = AIOrchestrator.getInstance();

  const riskRequest: AIRequest = {
    requestId: 'risk_001',
    userId: 'user_101',
    input: {
      type: 'sensor',
      content: [120, 80, 75, 25.5], // 血压、血糖、心率、BMI等传感器数据
      metadata: {
        deviceType: 'watch',
        timestamp: Date.now()
      }
    },
    preferences: {
      priority: 'privacy', // 优先隐私保护
      offlineMode: true     // 允许离线模式
    }
  };

  const response = await orchestrator.process(riskRequest);
  // 预期: MindSpore本地推理，数据不上传云端，响应 < 100ms
}

// 示例4：紧急情况 → 小艺立即响应
export async function emergencyExample() {
  const orchestrator = AIOrchestrator.getInstance();

  const emergencyRequest: AIRequest = {
    requestId: 'emergency_001',
    userId: 'user_202',
    input: {
      type: 'voice',
      content: '救命！我妈妈晕倒了！'
    },
    preferences: {
      priority: 'speed'
    }
  };

  const response = await orchestrator.process(emergencyRequest);
  // 预期: 小艺识别紧急意图，触发SOS流程 < 200ms
}

// ==================== 高级功能 ====================

// 多智能体并行调用
export async function multiAgentExample() {
  const orchestrator = AIOrchestrator.getInstance();

  const request: AIRequest = {
    requestId: 'multi_001',
    userId: 'user_303',
    input: {
      type: 'text',
      content: '我感觉最近有点头晕，帮我全面分析一下'
    }
  };

  // 同时调用多个智能体获取不同角度的分析
  const responses = await orchestrator.processMultiAgent(request, ['deepseek', 'mindspore']);
  
  /*
  返回结果:
  [
    {
      agentId: 'deepseek',
      output: "从医学角度分析，头晕可能的原因包括..."
    },
    {
      agentId: 'mindspore',
      output: { riskScore: 72, riskLevel: 'medium', ... }
    }
  ]
  
  然后可以聚合两个智能体的结果给出综合建议
  */
}

// 获取对话历史
export async function conversationHistoryExample() {
  const orchestrator = AIOrchestrator.getInstance();
  const userId = 'user_404';
  
  // 获取最近10条对话
  const history = orchestrator.getConversationHistory(userId, 10);
  console.log('对话历史:', history);
  
  // 清除历史（用户主动要求或隐私需求）
  // orchestrator.clearConversationHistory(userId);
}

// 查看系统状态
export async function systemStatusExample() {
  const orchestrator = AIOrchestrator.getInstance();
  
  const status = orchestrator.getSystemStatus();
  console.log('系统状态:', JSON.stringify(status, null, 2));
  /*
  输出示例:
  {
    orchestrator: "active",
    loadedAgents: ["xiaoyi", "deepseek"],
    agentStatuses: [
      { id: "xiaoyi", name: "小艺智能体", available: true, load: 0 },
      { id: "deepseek", name: "硅基流动DeepSeek", available: true, load: 0 }
    ],
    uptime: 3600
  }
  */
}

// ==================== 在页面中的集成示例 ====================

/*
// VoiceAssistantPage.ets 中使用示例

import { AIOrchestrator } from '../ai/orchestrator/AIOrchestrator';

@Entry
@Component
struct VoiceAssistantPage {
  private orchestrator: AIOrchestrator = AIOrchestrator.getInstance();
  @State responseText: string = '';
  @State isLoading: boolean = false;

  async handleUserInput(input: string) {
    this.isLoading = true;
    
    try {
      const request: AIRequest = {
        requestId: `req_${Date.now()}`,
        userId: AppStorage.get('userId') || 'anonymous',
        input: {
          type: 'text',
          content: input
        },
        conversationHistory: this.chatMessages.map(msg => ({
          role: msg.type === 'user' ? 'user' : 'assistant',
          content: msg.content,
          timestamp: msg.timestamp,
          agentId: msg.agentId
        }))
      };

      const response = await this.orchestrator.process(request);
      
      this.responseText = response.output.content as string;
      
      // 更新聊天界面
      this.addMessage('assistant', this.responseText, response.agentId);
      
      // 显示建议按钮
      if (response.suggestions) {
        this.showSuggestions(response.suggestions);
      }
      
    } catch (error) {
      this.responseText = '抱歉，处理失败，请重试';
    } finally {
      this.isLoading = false;
    }
  }
}
*/

// ==================== 导出供外部使用 ====================

export default {
  basicUsageExample,
  voiceCommandExample,
  healthConsultationExample,
  riskAssessmentExample,
  emergencyExample,
  multiAgentExample,
  conversationHistoryExample,
  systemStatusExample
};
