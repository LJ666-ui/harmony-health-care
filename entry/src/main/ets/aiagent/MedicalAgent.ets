/**
 * 医疗智能体基类
 * 定义医疗智能体的通用行为
 */

import { LLMClient } from './infrastructure/LLMClient';
import { RAGRetriever } from './RAGRetriever';
import {
  AgentAnswer,
  AgentConfig,
  MedicalSpecialty,
  KnowledgeReference
} from './types/AgentTypes';
import { ConversationContext } from './types/ConversationTypes';
import { KnowledgeContext } from './types/RAGTypes';

/**
 * 医疗智能体抽象基类
 */
export abstract class MedicalAgent {
  protected agentId: string;
  protected agentName: string;
  protected specialty: MedicalSpecialty;
  protected llmClient: LLMClient;
  protected ragRetriever: RAGRetriever;
  protected config: AgentConfig;

  /**
   * 构造函数
   * @param config 智能体配置
   * @param llmClient LLM客户端
   * @param ragRetriever RAG检索器
   */
  constructor(
    config: AgentConfig,
    llmClient: LLMClient,
    ragRetriever: RAGRetriever
  ) {
    this.config = config;
    this.agentId = config.agentId;
    this.agentName = config.agentName;
    this.specialty = config.specialty;
    this.llmClient = llmClient;
    this.ragRetriever = ragRetriever;
  }

  /**
   * 处理用户问题
   * @param question 用户问题
   * @param context 对话上下文
   * @returns 智能体回答
   */
  async process(question: string, context?: ConversationContext): Promise<AgentAnswer> {
    const startTime = Date.now();

    // 1. RAG知识检索
    const knowledge = await this.retrieveKnowledge(question);

    // 2. 构建提示词
    const prompt = this.buildPrompt(question, knowledge, context);

    // 3. 调用LLM生成回答
    const response = await this.generateResponse(prompt);

    // 4. 计算置信度
    const confidence = this.calculateConfidence(knowledge);

    // 5. 构建回答
    const answer: AgentAnswer = {
      agentId: this.agentId,
      agentName: this.agentName,
      content: response,
      confidence,
      knowledgeUsed: knowledge.references,
      timestamp: Date.now()
    };

    return answer;
  }

  /**
   * RAG知识检索
   * @param query 检索查询
   * @returns 知识上下文
   */
  protected async retrieveKnowledge(query: string): Promise<KnowledgeContext> {
    try {
      const context = await this.ragRetriever.retrieve(query);
      return context;
    } catch (error) {
      // 检索失败时返回空上下文
      return {
        content: '',
        references: [],
        totalFound: 0,
        filteredCount: 0
      };
    }
  }

  /**
   * 构建提示词
   * @param question 用户问题
   * @param knowledge 知识上下文
   * @param context 对话上下文
   * @returns 完整提示词
   */
  protected buildPrompt(
    question: string,
    knowledge: KnowledgeContext,
    context?: ConversationContext
  ): string {
    let prompt = this.getSystemPrompt();

    // 添加知识参考
    if (knowledge.content) {
      prompt += `\n\n【医学知识参考】\n${knowledge.content}`;
    }

    // 添加对话历史
    if (context && context.messages.length > 0) {
      const history = this.formatConversationHistory(context);
      prompt += `\n\n【对话历史】\n${history}`;
    }

    // 添加用户问题
    prompt += `\n\n【患者问题】\n${question}`;

    // 添加回答要求
    prompt += `\n\n请基于以上信息，给出专业的诊疗建议。`;

    return prompt;
  }

  /**
   * 调用LLM生成回答
   * @param prompt 提示词
   * @returns 生成的回答
   */
  protected async generateResponse(prompt: string): Promise<string> {
    const response = await this.llmClient.generate({ prompt });
    return response.content;
  }

  /**
   * 计算置信度
   * @param knowledge 知识上下文
   * @returns 置信度 [0-1]
   */
  protected calculateConfidence(knowledge: KnowledgeContext): number {
    // 基础置信度
    let confidence = 0.6;

    // 如果有知识支撑，提高置信度
    if (knowledge.filteredCount > 0) {
      confidence += 0.1 * Math.min(knowledge.filteredCount, 3);
    }

    // 限制在 [0, 1] 范围内
    return Math.min(confidence, 1.0);
  }

  /**
   * 格式化对话历史
   * @param context 对话上下文
   * @returns 格式化的历史文本
   */
  protected formatConversationHistory(context: ConversationContext): string {
    const messages = context.messages.slice(-10);  // 最多10轮对话
    let history = '';

    for (const message of messages) {
      const role = message.role === 'user' ? '患者' : '医生';
      history += `${role}：${message.content}\n`;
    }

    return history;
  }

  /**
   * 获取系统提示词（由子类实现）
   * @returns 系统提示词
   */
  protected abstract getSystemPrompt(): string;

  /**
   * 获取智能体ID
   */
  getId(): string {
    return this.agentId;
  }

  /**
   * 获取智能体名称
   */
  getName(): string {
    return this.agentName;
  }

  /**
   * 获取专科领域
   */
  getSpecialty(): MedicalSpecialty {
    return this.specialty;
  }

  /**
   * 获取配置
   */
  getConfig(): AgentConfig {
    return { ...this.config };
  }
}
