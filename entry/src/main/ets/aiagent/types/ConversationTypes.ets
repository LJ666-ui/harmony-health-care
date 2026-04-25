/**
 * 对话记忆相关类型定义
 * 包含对话上下文、对话消息等数据结构
 */

/**
 * 消息元数据
 */
export interface MessageMetadata {
  agentId?: string;                // 智能体ID
  intent?: string;                 // 意图类型
  confidence?: number;             // 置信度
}

/**
 * 对话消息
 */
export interface ConversationMessage {
  role: 'user' | 'assistant';      // 角色
  content: string;                 // 消息内容
  timestamp: number;               // 时间戳
  metadata?: MessageMetadata;      // 元数据
}

/**
 * 对话上下文
 */
export interface ConversationContext {
  sessionId: string;               // 会话ID
  userId: string;                  // 用户ID
  messages: ConversationMessage[]; // 对话消息列表
  createdAt: number;               // 创建时间
  updatedAt: number;               // 更新时间
}

/**
 * 对话记忆配置
 */
export interface ConversationMemoryConfig {
  maxTurns: number;                // 最大对话轮数，默认10
  sessionTTL: number;              // 会话过期时间（秒），默认3600
  storageKey: string;              // 存储键前缀
}

/**
 * 对话历史摘要
 */
export interface ConversationSummary {
  sessionId: string;               // 会话ID
  messageCount: number;            // 消息数量
  lastMessageTime: number;         // 最后消息时间
  mainTopics: string[];            // 主要话题
}
