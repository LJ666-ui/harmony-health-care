/**
 * 硅基流动 (SiliconFlow) API 客户端
 * 用于调用 DeepSeek V3 大模型
 *
 * 使用说明:
 * 1. 在使用前确保已配置有效的API Key
 * 2. 支持同步和流式两种调用模式
 * 3. 自动处理重试、超时等异常情况
 */

import { http } from '@kit.NetworkKit';
import {
  DeepSeekConfig,
  ChatCompletionRequest,
  ChatCompletionResponse,
  ChatMessage,
  StreamCallback,
  ConversationSession,
  ConversationOptions,
  Usage,
  ToolDefinition,
  ChatRole
} from './types/DeepSeekTypes';
import { SILICONFLOW_CONFIG } from '../common/constants/SiliconFlowConfig';

export class SiliconFlowClient {
  private config: DeepSeekConfig;
  private sessions: Map<string, ConversationSession> = new Map();
  private requestCount: number = 0;
  private errorCount: number = 0;

  private static instance: SiliconFlowClient | null = null;

  private constructor(config?: Partial<DeepSeekConfig>) {
    this.config = {
      apiKey: config?.apiKey || SILICONFLOW_CONFIG.apiKey,
      baseUrl: config?.baseUrl || 'https://api.siliconflow.cn/v1',
      model: config?.model || SILICONFLOW_CONFIG.model,
      maxTokens: config?.maxTokens || SILICONFLOW_CONFIG.maxTokens,
      temperature: config?.temperature || SILICONFLOW_CONFIG.temperature,
      timeout: config?.timeout || SILICONFLOW_CONFIG.timeout
    };
  }

  public static getInstance(config?: Partial<DeepSeekConfig>): SiliconFlowClient {
    if (SiliconFlowClient.instance === null) {
      SiliconFlowClient.instance = new SiliconFlowClient(config);
    }
    return SiliconFlowClient.instance;
  }

  /**
   * 发送聊天请求（非流式）
   */
  async chat(messages: ChatMessage[], options?: ConversationOptions): Promise<ChatCompletionResponse> {
    const startTime = Date.now();

    try {
      // 构建完整的消息列表（包含系统提示词）
      const fullMessages = this.buildMessages(messages, options);

      const request: ChatCompletionRequest = {
        model: this.config.model,
        messages: fullMessages,
        max_tokens: this.config.maxTokens,
        temperature: options?.temperature || this.config.temperature,
        stream: false
      };

      console.info(`[DeepSeek] 发送聊天请求, 消息数=${messages.length}, model=${this.config.model}`);

      const response = await this.doHttpRequest(request);

      this.requestCount++;
      console.info(`[DeepSeek] 响应成功, 耗时=${Date.now() - startTime}ms`);

      return response;
    } catch (error) {
      this.errorCount++;
      console.error('[DeepSeek] 聊天请求失败:', error);
      throw error;
    }
  }

  /**
   * 发送简单的单轮对话
   */
  async chatSimple(prompt: string, systemPrompt?: string): Promise<string> {
    const messages: ChatMessage[] = [];

    if (systemPrompt) {
      messages.push({ role: 'system', content: systemPrompt });
    }

    messages.push({ role: 'user', content: prompt });

    const response = await this.chat(messages);

    if (response.choices && response.choices.length > 0) {
      const content = response.choices[0].message.content;

      if (typeof content === 'string') {
        return content;
      } else if (Array.isArray(content)) {
        return content.map(part => part.text || '').join('');
      }
    }

    throw new Error('无效的响应格式');
  }

  /**
   * 流式聊天
   */
  async chatStream(
    messages: ChatMessage[],
    callback: StreamCallback,
    options?: ConversationOptions
  ): Promise<void> {
    try {
      const fullMessages = this.buildMessages(messages, options);

      const request: ChatCompletionRequest = {
        model: this.config.model,
        messages: fullMessages,
        max_tokens: this.config.maxTokens,
        temperature: options?.temperature || this.config.temperature,
        stream: true
      };

      console.info(`[DeepSeek] 发送流式聊天请求`);

      await this.doStreamRequest(request, callback);

      this.requestCount++;
      console.info(`[DeepSeek] 流式响应完成`);
    } catch (error) {
      this.errorCount++;
      console.error('[DeepSeek] 流式聊天失败:', error);
      throw error;
    }
  }

  /**
   * 创建或获取对话会话
   */
  createOrGetSession(sessionId: string, userId: string): ConversationSession {
    let session = this.sessions.get(sessionId);

    if (!session) {
      session = {
        sessionId,
        userId,
        messages: [],
        createdAt: Date.now(),
        lastActivityAt: Date.now()
      };
      this.sessions.set(sessionId, session);
    }

    return session;
  }

  /**
   * 向会话添加消息
   */
  addMessageToSession(sessionId: string, message: ChatMessage): void {
    const session = this.sessions.get(sessionId);
    if (session) {
      session.messages.push(message);
      session.lastActivityAt = Date.now();

      // 保持最近50条消息
      if (session.messages.length > 50) {
        session.messages = session.messages.slice(-50);
      }
    }
  }

  /**
   * 获取会话历史
   */
  getSessionHistory(sessionId: string): ChatMessage[] | null {
    const session = this.sessions.get(sessionId);
    return session ? [...session.messages] : null;
  }

  /**
   * 清除会话
   */
  clearSession(sessionId: string): boolean {
    return this.sessions.delete(sessionId);
  }

  /**
   * 使用工具进行对话（Function Calling）
   */
  async chatWithTools(
    messages: ChatMessage[],
    tools: ToolDefinition[],
    options?: ConversationOptions
  ): Promise<ChatCompletionResponse> {
    const fullMessages = this.buildMessages(messages, options);

    const request: ChatCompletionRequest = {
      model: this.config.model,
      messages: fullMessages,
      max_tokens: this.config.maxTokens,
      temperature: options?.temperature || this.config.temperature,
      stream: false,
      tools: tools,
      tool_choice: 'auto'
    };

    console.info(`[DeepSeek] 发送工具调用请求, 工具数量=${tools.length}`);

    return this.doHttpRequest(request);
  }

  /**
   * 获取统计信息
   */
  getStats(): { requestCount: number; errorCount: number; errorRate: number; activeSessions: number } {
    return {
      requestCount: this.requestCount,
      errorCount: this.errorCount,
      errorRate: this.requestCount > 0 ? this.errorCount / this.requestCount : 0,
      activeSessions: this.sessions.size
    };
  }

  // ==================== 私有方法 ====================

  /**
   * 构建完整消息列表
   */
  private buildMessages(messages: ChatMessage[], options?: ConversationOptions): ChatMessage[] {
    const fullMessages: ChatMessage[] = [];

    if (options?.systemPrompt) {
      fullMessages.push({
        role: 'system',
        content: options.systemPrompt
      });
    }

    fullMessages.push(...messages);

    return fullMessages;
  }

  /**
   * 执行HTTP请求
   */
  private async doHttpRequest(request: ChatCompletionRequest): Promise<ChatCompletionResponse> {
    return new Promise((resolve, reject) => {
      const httpRequest = http.createHttp();

      httpRequest.request(
        `${this.config.baseUrl}/chat/completions`,
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${this.config.apiKey}`
          },
          extraData: JSON.stringify(request),
          connectTimeout: this.config.timeout,
          readTimeout: this.config.timeout
        },
        (err, data) => {
          httpRequest.destroy();

          if (err) {
            reject(new Error(`HTTP请求失败: ${err.message}`));
            return;
          }

          try {
            const response = JSON.parse(data.result as string) as ChatCompletionResponse;

            if (response.error) {
              reject(new Error(`API错误: ${response.error.message}`));
              return;
            }

            resolve(response);
          } catch (parseError) {
            reject(new Error(`JSON解析失败: ${(parseError as Error).message}`));
          }
        }
      );
    });
  }

  /**
   * 执行流式HTTP请求
   */
  private async doStreamRequest(
    request: ChatCompletionRequest,
    callback: StreamCallback
  ): Promise<void> {
    return new Promise((resolve, reject) => {
      const httpRequest = http.createHttp();

      httpRequest.request(
        `${this.config.baseUrl}/chat/completions`,
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${this.config.apiKey}`
          },
          extraData: JSON.stringify(request),
          connectTimeout: this.config.timeout,
          readTimeout: this.config.timeout
        },
        (err, data) => {
          httpRequest.destroy();

          if (err) {
            reject(new Error(`流式请求失败: ${err.message}`));
            return;
          }

          try {
            // 处理SSE流式响应
            const lines = (data.result as string).split('\n');
            let fullContent = '';

            for (const line of lines) {
              if (line.startsWith('data: ') && line !== 'data: [DONE]') {
                try {
                  const chunk = JSON.parse(line.substring(6));

                  if (chunk.choices && chunk.choices.length > 0) {
                    const delta = chunk.choices[0].delta;
                    if (delta.content) {
                      fullContent += delta.content;
                      callback(delta.content, false);
                    }
                  }
                } catch (e) {
                  // 忽略解析错误的行
                }
              }
            }

            callback('', true); // 标记完成
            resolve();
          } catch (error) {
            reject(new Error(`流式响应处理失败: ${(error as Error).message}`));
          }
        }
      );
    });
  }
}

// 导出单例实例
export const siliconFlowClient = SiliconFlowClient.getInstance();
