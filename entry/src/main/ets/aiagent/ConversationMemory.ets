/**
 * 对话记忆管理器
 * 管理多轮对话的上下文记忆
 */

import {
  ConversationContext,
  ConversationMessage,
  ConversationMemoryConfig
} from './types/ConversationTypes';

/**
 * 对话记忆管理器类
 */
export class ConversationMemory {
  private storage: Map<string, ConversationContext> = new Map();
  private config: ConversationMemoryConfig;

  /**
   * 构造函数
   * @param config 配置
   */
  constructor(config?: Partial<ConversationMemoryConfig>) {
    this.config = {
      maxTurns: 10,
      sessionTTL: 3600,
      storageKey: 'conversation:',
      ...config
    };
  }

  /**
   * 保存对话消息
   * @param sessionId 会话ID
   * @param message 对话消息
   */
  async save(sessionId: string, message: ConversationMessage): Promise<void> {
    // 获取或创建对话历史
    let context = await this.retrieve(sessionId);

    if (!context) {
      context = {
        sessionId,
        userId: '',
        messages: [],
        createdAt: Date.now(),
        updatedAt: Date.now()
      };
    }

    // 添加新消息
    context.messages.push(message);

    // 限制对话轮数
    const maxMessages = this.config.maxTurns * 2;
    if (context.messages.length > maxMessages) {
      context.messages = context.messages.slice(-maxMessages);
    }

    // 更新时间戳
    context.updatedAt = Date.now();

    // 保存到存储
    this.storage.set(sessionId, context);
  }

  /**
   * 检索对话历史
   * @param sessionId 会话ID
   * @returns 对话上下文
   */
  async retrieve(sessionId: string): Promise<ConversationContext | null> {
    const context = this.storage.get(sessionId);

    if (!context) {
      return null;
    }

    // 检查是否过期
    const now = Date.now();
    const ttl = this.config.sessionTTL * 1000;

    if (now - context.updatedAt > ttl) {
      this.storage.delete(sessionId);
      return null;
    }

    return context;
  }

  /**
   * 清除对话历史
   * @param sessionId 会话ID
   */
  async clear(sessionId: string): Promise<void> {
    this.storage.delete(sessionId);
  }

  /**
   * 构建LLM上下文
   * @param history 对话历史
   * @returns LLM可用的上下文格式
   */
  buildLLMContext(history: ConversationContext): string {
    const messages = history.messages;
    let context = '';

    for (const message of messages) {
      const role = message.role === 'user' ? '用户' : '助手';
      context += `${role}：${message.content}\n`;
    }

    return context;
  }

  /**
   * 获取最近N轮对话
   * @param sessionId 会话ID
   * @param turns 轮数
   * @returns 对话消息列表
   */
  async getRecentTurns(sessionId: string, turns: number): Promise<ConversationMessage[]> {
    const context = await this.retrieve(sessionId);

    if (!context) {
      return [];
    }

    const messages = context.messages;
    const recentMessages = messages.slice(-turns * 2);

    return recentMessages;
  }

  /**
   * 获取会话统计信息
   * @param sessionId 会话ID
   */
  async getSessionStats(sessionId: string): Promise<{
    messageCount: number;
    userMessageCount: number;
    assistantMessageCount: number;
    duration: number;
  } | null> {
    const context = await this.retrieve(sessionId);

    if (!context) {
      return null;
    }

    const userMessages = context.messages.filter(m => m.role === 'user');
    const assistantMessages = context.messages.filter(m => m.role === 'assistant');

    return {
      messageCount: context.messages.length,
      userMessageCount: userMessages.length,
      assistantMessageCount: assistantMessages.length,
      duration: context.updatedAt - context.createdAt
    };
  }

  /**
   * 获取所有活跃会话
   */
  getActiveSessions(): string[] {
    const now = Date.now();
    const ttl = this.config.sessionTTL * 1000;
    const activeSessions: string[] = [];

    for (const [sessionId, context] of this.storage.entries()) {
      if (now - context.updatedAt <= ttl) {
        activeSessions.push(sessionId);
      }
    }

    return activeSessions;
  }

  /**
   * 清理过期会话
   */
  cleanupExpiredSessions(): number {
    const now = Date.now();
    const ttl = this.config.sessionTTL * 1000;
    let cleanedCount = 0;

    for (const [sessionId, context] of this.storage.entries()) {
      if (now - context.updatedAt > ttl) {
        this.storage.delete(sessionId);
        cleanedCount++;
      }
    }

    return cleanedCount;
  }

  /**
   * 获取配置
   */
  getConfig(): ConversationMemoryConfig {
    return { ...this.config };
  }

  /**
   * 更新配置
   */
  updateConfig(config: Partial<ConversationMemoryConfig>): void {
    this.config = {
      ...this.config,
      ...config
    };
  }
}
