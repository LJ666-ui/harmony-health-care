/**
 * 多智能体编排器
 * 协调多个专科智能体进行会诊
 */

import { MedicalAgent } from './MedicalAgent';
import { IntentClassifier } from './IntentClassifier';
import { ConversationMemory } from './ConversationMemory';
import { RAGRetriever } from './RAGRetriever';
import {
  ConsultationRequest,
  ConsultationResponse,
  AgentAnswer,
  AggregatedResult
} from './types/ConsultationTypes';
import { Intent, IntentType } from './types/IntentTypes';
import { ConversationMessage } from './types/ConversationTypes';

/**
 * 多智能体编排器类
 */
export class MultiAgentOrchestrator {
  private agents: Map<string, MedicalAgent> = new Map();
  private intentClassifier: IntentClassifier;
  private memory: ConversationMemory;
  private ragRetriever: RAGRetriever;

  /**
   * 构造函数
   * @param intentClassifier 意图分类器
   * @param memory 对话记忆管理器
   * @param ragRetriever RAG检索器
   */
  constructor(
    intentClassifier: IntentClassifier,
    memory: ConversationMemory,
    ragRetriever: RAGRetriever
  ) {
    this.intentClassifier = intentClassifier;
    this.memory = memory;
    this.ragRetriever = ragRetriever;
  }

  /**
   * 编排问诊流程
   * @param request 问诊请求
   * @returns 会诊响应
   */
  async orchestrate(request: ConsultationRequest): Promise<ConsultationResponse> {
    const startTime = Date.now();

    // 1. 生成或获取会话ID
    const sessionId = request.sessionId || this.generateSessionId();

    // 2. 检索对话历史
    const history = await this.memory.retrieve(sessionId);

    // 3. 意图分类
    const intent = await this.intentClassifier.classify(request.question);

    // 4. 选择专科智能体
    const selectedAgents = this.selectAgents(intent);

    // 5. 并行调用智能体
    const answers = await this.invokeAgentsParallel(
      selectedAgents,
      request.question,
      history || undefined
    );

    // 6. 汇总会诊结果
    const aggregatedResult = this.aggregate(answers);

    // 7. 存储对话记忆
    await this.saveConversation(sessionId, request.userId, request.question, answers);

    // 8. 构建响应
    const response: ConsultationResponse = {
      responseId: this.generateResponseId(),
      sessionId,
      answers,
      summary: aggregatedResult.summary,
      knowledgeRefs: this.extractKnowledgeRefs(answers),
      timestamp: Date.now()
    };

    return response;
  }

  /**
   * 根据意图选择智能体
   * @param intent 意图类型
   * @returns 智能体列表
   */
  private selectAgents(intent: Intent): MedicalAgent[] {
    const agentIds = this.intentClassifier.getAgentIdsForIntent(intent.type);
    const selectedAgents: MedicalAgent[] = [];

    for (const agentId of agentIds) {
      const agent = this.agents.get(agentId);
      if (agent) {
        selectedAgents.push(agent);
      }
    }

    // 如果没有找到对应智能体，使用内科智能体作为默认
    if (selectedAgents.length === 0) {
      const defaultAgent = this.agents.get('internal_medicine');
      if (defaultAgent) {
        selectedAgents.push(defaultAgent);
      }
    }

    return selectedAgents;
  }

  /**
   * 并行调用智能体
   * @param agents 智能体列表
   * @param question 用户问题
   * @param context 对话上下文
   * @returns 智能体回答列表
   */
  private async invokeAgentsParallel(
    agents: MedicalAgent[],
    question: string,
    context?: any
  ): Promise<AgentAnswer[]> {
    const promises = agents.map(agent =>
      agent.process(question, context).catch(error => {
        // 单个智能体失败不影响其他智能体
        console.error(`Agent ${agent.getId()} failed:`, error);
        return null;
      })
    );

    const results = await Promise.all(promises);

    // 过滤掉失败的回答
    return results.filter((answer): answer is AgentAnswer => answer !== null);
  }

  /**
   * 汇总多个智能体的回答
   * @param answers 智能体回答列表
   * @returns 汇总后的会诊结果
   */
  private aggregate(answers: AgentAnswer[]): AggregatedResult {
    if (answers.length === 0) {
      return {
        summary: '抱歉，暂时无法提供诊疗建议，请稍后重试或咨询专业医生。',
        keyPoints: [],
        recommendations: [],
        warnings: []
      };
    }

    // 提取关键要点
    const keyPoints: string[] = [];
    const recommendations: string[] = [];
    const warnings: string[] = [];

    for (const answer of answers) {
      // 简单的关键点提取（实际项目中可使用NLP技术）
      const lines = answer.content.split('\n').filter(line => line.trim());
      for (const line of lines) {
        if (line.includes('建议') || line.includes('注意')) {
          recommendations.push(line);
        } else if (line.includes('警告') || line.includes('禁忌')) {
          warnings.push(line);
        } else {
          keyPoints.push(line);
        }
      }
    }

    // 生成汇总摘要
    const summary = this.generateSummary(answers);

    return {
      summary,
      keyPoints: keyPoints.slice(0, 5),
      recommendations: recommendations.slice(0, 3),
      warnings: warnings.slice(0, 3)
    };
  }

  /**
   * 生成汇总摘要
   * @param answers 智能体回答列表
   * @returns 汇总摘要
   */
  private generateSummary(answers: AgentAnswer[]): string {
    const agentNames = answers.map(a => a.agentName).join('、');
    const avgConfidence = answers.reduce((sum, a) => sum + a.confidence, 0) / answers.length;

    let summary = `经${agentNames}会诊，`;

    if (avgConfidence >= 0.8) {
      summary += '建议如下：';
    } else if (avgConfidence >= 0.6) {
      summary += '初步建议如下，建议进一步咨询专业医生：';
    } else {
      summary += '建议咨询专业医生获取更准确的诊断：';
    }

    return summary;
  }

  /**
   * 提取知识引用
   * @param answers 智能体回答列表
   * @returns 知识引用列表
   */
  private extractKnowledgeRefs(answers: AgentAnswer[]): any[] {
    const refs: any[] = [];

    for (const answer of answers) {
      for (const ref of answer.knowledgeUsed) {
        if (!refs.find(r => r.id === ref.id)) {
          refs.push(ref);
        }
      }
    }

    return refs;
  }

  /**
   * 保存对话
   * @param sessionId 会话ID
   * @param userId 用户ID
   * @param question 用户问题
   * @param answers 智能体回答
   */
  private async saveConversation(
    sessionId: string,
    userId: string,
    question: string,
    answers: AgentAnswer[]
  ): Promise<void> {
    // 保存用户消息
    const userMessage: ConversationMessage = {
      role: 'user',
      content: question,
      timestamp: Date.now()
    };
    await this.memory.save(sessionId, userMessage);

    // 保存助手消息
    const assistantContent = answers.map(a => `【${a.agentName}】\n${a.content}`).join('\n\n');
    const assistantMessage: ConversationMessage = {
      role: 'assistant',
      content: assistantContent,
      timestamp: Date.now()
    };
    await this.memory.save(sessionId, assistantMessage);
  }

  /**
   * 注册专科智能体
   * @param agent 智能体实例
   */
  registerAgent(agent: MedicalAgent): void {
    this.agents.set(agent.getId(), agent);
  }

  /**
   * 批量注册智能体
   * @param agents 智能体列表
   */
  registerAgents(agents: MedicalAgent[]): void {
    for (const agent of agents) {
      this.registerAgent(agent);
    }
  }

  /**
   * 获取所有注册的智能体
   */
  getRegisteredAgents(): MedicalAgent[] {
    return Array.from(this.agents.values());
  }

  /**
   * 生成会话ID
   */
  private generateSessionId(): string {
    return `session_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  /**
   * 生成响应ID
   */
  private generateResponseId(): string {
    return `response_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }
}
