import { AIRequest, AIResponse, AgentId } from '../models/AITypes';
import { COZE_CONFIG, COZE_ENDPOINTS } from '../../common/constants/CozeConfig';
import http from '@ohos.net.http';

export class CozeAgent {
  private readonly agentId: AgentId = 'coze';
  private config = COZE_CONFIG;

  constructor() {
    console.log('[CozeAgent] Coze智能体初始化完成');
    console.log('[CozeAgent] Bot ID:', this.config.botId);
    console.log('[CozeAgent] Workflow ID:', this.config.workflowId);
  }

  async process(request: AIRequest): Promise<AIResponse> {
    const startTime = Date.now();
    console.log(`[CozeAgent] 处理请求: ${request.requestId}`);

    try {
      const userMessage = this.extractInputText(request);
      const result = await this.callCozeAPI(userMessage);

      return {
        requestId: request.requestId,
        agentId: this.agentId,
        output: {
          type: 'text',
          content: result.content,
          confidence: result.confidence
        },
        metadata: {
          processingTime: Date.now() - startTime,
          modelUsed: 'Coze-Medical-Workflow',
          tokensUsed: 0,
          isOffline: false,
          agentVersion: '1.0.0'
        },
        suggestions: this.generateSuggestions(userMessage, result.content)
      };

    } catch (error) {
      console.error('[CozeAgent] 调用失败:', error);
      return this.createErrorResponse(request.requestId, error as string, startTime);
    }
  }

  private extractInputText(request: AIRequest): string {
    if (typeof request.input.content === 'string') {
      return request.input.content;
    }
    return '';
  }

  async callCozeAPI(userMessage: string): Promise<{ content: string; confidence: number }> {
    const url = `${this.config.apiUrl}${COZE_ENDPOINTS.workflowRun}`;

    const requestBody = {
      workflow_id: this.config.workflowId,
      parameters: {
        query: userMessage
      }
    };

    console.log(`[CozeAgent] 🚀 调用Coze工作流...`);
    console.log(`[CozeAgent] URL: ${url}`);
    console.log(`[CozeAgent] Workflow ID: ${this.config.workflowId}`);
    console.log(`[CozeAgent] 消息: ${userMessage}`);

    const httpRequest = http.createHttp();

    try {
      const response = await httpRequest.request(
        url,
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${this.config.token}`
          },
          extraData: JSON.stringify(requestBody),
          connectTimeout: this.config.timeout,
          readTimeout: this.config.timeout
        }
      );

      console.log(`[CozeAgent] HTTP状态码: ${response.responseCode}`);
      console.log(`[CozeAgent] 原始响应: ${(response.result as string)?.substring(0, 500)}`);

      if (response.responseCode !== 200) {
        throw new Error(`Coze API错误 ${response.responseCode}: ${response.result}`);
      }

      const data = JSON.parse(response.result as string);
      console.log(`[CozeAgent] ✅ 解析成功:`, JSON.stringify(data).substring(0, 300));

      return this.parseCozeResponse(data);

    } catch (error) {
      console.error(`[CozeAgent] ❌ 调用失败:`, error);
      throw error;
    } finally {
      httpRequest.destroy();
    }
  }

  private parseCozeResponse(data: any): { content: string; confidence: number } {
    try {
      if (data.code === 0 && data.data) {
        let content = '';

        if (typeof data.data === 'string') {
          content = data.data;
        } else if (data.data.output) {
          content = data.data.output;
        } else if (data.data.content) {
          content = data.data.content;
        } else {
          content = JSON.stringify(data.data);
        }

        const confidence = content.length > 50 ? 0.9 : 0.6;
        return { content, confidence };
      }

      throw new Error(`Coze返回错误: ${data.msg || '未知错误'}`);

    } catch (error) {
      console.error('[CozeAgent] 解析响应失败:', error);
      return {
        content: '抱歉，知识库暂时无法回答您的问题，请稍后重试。',
        confidence: 0.3
      };
    }
  }

  private generateSuggestions(userMessage: string, assistantResponse: string): string[] {
    const suggestions: string[] = [];

    if (userMessage.includes('血压') || userMessage.includes('血糖')) {
      suggestions.push('查看健康记录', '设置测量提醒');
    }

    if (userMessage.includes('白内障') || userMessage.includes('眼科')) {
      suggestions.push('预约眼科检查', '了解更多眼健康知识');
    }

    if (userMessage.includes('康复') || userMessage.includes('骨折')) {
      suggestions.push('开始康复训练', '查看康复课程');
    }

    if (suggestions.length === 0) {
      suggestions.push('继续咨询', '换个问题', '结束对话');
    }

    return suggestions.slice(0, 3);
  }

  private createErrorResponse(requestId: string, error: string, startTime: number): AIResponse {
    return {
      requestId,
      agentId: this.agentId,
      output: {
        type: 'text',
        content: '抱歉，Coze知识库暂时无法连接。这可能是因为：\n\n' +
          '📡 网络连接不稳定\n' +
          '⏰ Coze服务正在维护\n' +
          '🔄 工作流配置需要更新\n\n' +
          '建议您：\n' +
          '• 检查网络连接\n' +
          '• 稍后重试\n' +
          '• 或使用其他健康咨询方式\n\n' +
          '给您带来不便请谅解！',
        confidence: 0.1
      },
      metadata: {
        processingTime: Date.now() - startTime,
        isOffline: false,
        agentVersion: '1.0.0'
      }
    };
  }
}
