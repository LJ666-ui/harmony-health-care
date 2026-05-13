/**
 * DeepSeek类型定义
 * 定义硅基流动DeepSeek API的所有数据结构
 */

/**
 * DeepSeek配置
 */
export interface DeepSeekConfig {
  apiKey: string;
  baseUrl: string;
  model: string;
  maxTokens?: number;
  temperature?: number;
  timeout?: number;
}

/**
 * 聊天消息角色
 */
export type ChatRole = 'system' | 'user' | 'assistant' | 'tool';

/**
 * 聊天消息
 */
export interface ChatMessage {
  role: ChatRole;
  content: string | ContentPart[];
  name?: string;
  toolCalls?: ToolCall[];
  toolCallId?: string;
}

/**
 * 多模态内容部分（支持图片等）
 */
export interface ContentPart {
  type: 'text' | 'image_url';
  text?: string;
  image_url?: {
    url: string;
    detail?: 'auto' | 'low' | 'high';
  };
}

/**
 * 工具调用请求
 */
export interface ToolCall {
  id: string;
  type: 'function';
  function: {
    name: string;
    arguments: string;
  };
}

/**
 * 工具定义
 */
export interface ToolDefinition {
  type: 'function';
  function: {
    name: string;
    description: string;
    parameters: Record<string, any>;
  };
}

/**
 * 聊天完成请求
 */
export interface ChatCompletionRequest {
  model: string;
  messages: ChatMessage[];
  max_tokens?: number;
  temperature?: number;
  top_p?: number;
  stream?: boolean;
  stop?: string[] | null;
  tools?: ToolDefinition[];
  tool_choice?: 'auto' | 'none' | 'required' | { type: 'function', function: { name: string } };
  response_format?: { type: 'json_object' } | { type: 'text' };
  user?: string;
}

/**
 * 使用情况统计
 */
export interface Usage {
  prompt_tokens: number;
  completion_tokens: number;
  total_tokens: number;
  prompt_tokens_details?: {
    cached_tokens: number;
  };
  completion_tokens_details?: {
    reasoning_tokens: number;
  };
}

/**
 * 选择项
 */
export interface Choice {
  index: number;
  message: ChatMessage;
  finish_reason: 'stop' | 'length' | 'tool_calls' | 'content_filter';
  logprobs?: any;
}

/**
 * 聊天完成响应
 */
export interface ChatCompletionResponse {
  id: string;
  object: 'chat.completion';
  created: number;
  model: string;
  choices: Choice[];
  usage: Usage;
  system_fingerprint?: string;
}

/**
 * 流式响应块
 */
export interface ChatCompletionChunk {
  id: string;
  object: 'chat.completion.chunk';
  created: number;
  model: string;
  choices: StreamChoice[];
}

/**
 * 流式选择项
 */
export interface StreamChoice {
  index: number;
  delta: {
    role?: ChatRole;
    content?: string;
    tool_calls?: ToolCall[];
  };
  finish_reason: string | null;
}

/**
 * 流式回调函数类型
 */
export type StreamCallback = (chunk: string, done: boolean) => void;

/**
 * 对话会话
 */
export interface ConversationSession {
  sessionId: string;
  userId: string;
  messages: ChatMessage[];
  createdAt: number;
  lastActivityAt: number;
  metadata?: Record<string, any>;
}

/**
 * 对话选项
 */
export interface ConversationOptions {
  systemPrompt?: string;
  maxHistoryLength?: number;
  temperature?: number;
  enableTools?: boolean;
}
