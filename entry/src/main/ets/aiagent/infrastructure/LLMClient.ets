/**
 * LLM客户端基础类
 * 提供与大语言模型服务交互的能力
 */

/**
 * LLM使用情况
 */
export interface LLMUsage {
  promptTokens: number;
  completionTokens: number;
  totalTokens: number;
}

/**
 * LLM配置
 */
export interface LLMConfig {
  apiKey: string;
  baseUrl: string;
  model: string;
  maxTokens?: number;
  temperature?: number;
  timeout?: number;
  maxRetries?: number;
}

/**
 * LLM请求
 */
export interface LLMRequest {
  prompt: string;
  maxTokens?: number;
  temperature?: number;
  stopSequences?: string[];
}

/**
 * LLM响应
 */
export interface LLMResponse {
  content: string;
  usage?: LLMUsage;
  finishReason?: string;
}

/**
 * 流式响应回调
 */
export type StreamCallback = (chunk: string, done: boolean) => void;

/**
 * LLM客户端类
 */
export class LLMClient {
  private config: LLMConfig;
  private requestCount: number = 0;
  private errorCount: number = 0;

  constructor(config: LLMConfig) {
    const defaultConfig: LLMConfig = {
      apiKey: config.apiKey,
      baseUrl: config.baseUrl,
      model: config.model,
      maxTokens: config.maxTokens || 2048,
      temperature: config.temperature || 0.7,
      timeout: config.timeout || 30000,
      maxRetries: config.maxRetries || 3
    };
    this.config = defaultConfig;
  }

  async generate(request: LLMRequest): Promise<LLMResponse> {
    const startTime = Date.now();
    let lastError: Error | null = null;
    const maxRetries = this.config.maxRetries || 3;

    for (let attempt = 0; attempt < maxRetries; attempt++) {
      try {
        this.requestCount++;
        const response = await this.doGenerate(request);
        return response;
      } catch (error) {
        lastError = error as Error;
        this.errorCount++;

        if (this.isRetryableError(error) && attempt < maxRetries - 1) {
          await this.delay(this.getRetryDelay(attempt));
          continue;
        }

        throw this.handleError(error);
      }
    }

    throw this.handleError(lastError);
  }

  async generateStream(request: LLMRequest, callback: StreamCallback): Promise<void> {
    const maxRetries = this.config.maxRetries || 3;

    for (let attempt = 0; attempt < maxRetries; attempt++) {
      try {
        this.requestCount++;
        await this.doGenerateStream(request, callback);
        return;
      } catch (error) {
        this.errorCount++;

        if (this.isRetryableError(error) && attempt < maxRetries - 1) {
          await this.delay(this.getRetryDelay(attempt));
          continue;
        }

        throw this.handleError(error);
      }
    }
  }

  private async doGenerate(request: LLMRequest): Promise<LLMResponse> {
    const prompt = request.prompt;
    const maxTokens = request.maxTokens || this.config.maxTokens || 2048;
    const temperature = request.temperature || this.config.temperature || 0.7;

    await this.delay(500 + Math.random() * 1000);

    const content = this.simulateGeneration(prompt, maxTokens);

    const usage: LLMUsage = {
      promptTokens: Math.ceil(prompt.length / 4),
      completionTokens: Math.ceil(content.length / 4),
      totalTokens: Math.ceil((prompt.length + content.length) / 4)
    };

    const response: LLMResponse = {
      content: content,
      usage: usage,
      finishReason: 'stop'
    };

    return response;
  }

  private async doGenerateStream(request: LLMRequest, callback: StreamCallback): Promise<void> {
    const content = await this.doGenerate(request);
    const chunks = this.splitIntoChunks(content.content, 10);

    for (let i = 0; i < chunks.length; i++) {
      await this.delay(100);
      callback(chunks[i], false);
    }

    callback('', true);
  }

  private simulateGeneration(prompt: string, maxTokens: number): string {
    if (prompt.includes('症状') || prompt.includes('头痛') || prompt.includes('发烧')) {
      return '根据您描述的症状，建议您注意休息，多饮水。如果症状持续或加重，建议及时就医检查。请注意，这只是一般性建议，具体诊断需要专业医生进行。';
    } else if (prompt.includes('用药') || prompt.includes('药物')) {
      return '关于用药问题，建议您咨询专业医生或药师。不同药物有不同的适应症和禁忌症，需要根据具体情况确定。请勿自行调整用药剂量。';
    } else if (prompt.includes('康复') || prompt.includes('运动')) {
      return '康复训练需要循序渐进，建议在专业康复师指导下进行。初期可以从轻度活动开始，逐步增加强度。注意观察身体反应，如有不适及时停止。';
    } else if (prompt.includes('饮食') || prompt.includes('营养')) {
      return '健康饮食应均衡多样，建议多摄入蔬菜水果，适量优质蛋白，控制油脂和盐分摄入。具体饮食方案可根据个人情况调整。';
    } else {
      return '感谢您的咨询。建议您详细描述具体问题，以便我提供更准确的建议。如有紧急情况，请及时就医。';
    }
  }

  private splitIntoChunks(content: string, chunkSize: number): string[] {
    const chunks: string[] = [];
    for (let i = 0; i < content.length; i += chunkSize) {
      chunks.push(content.slice(i, i + chunkSize));
    }
    return chunks;
  }

  private isRetryableError(error: Error | null): boolean {
    if (error === null) {
      return false;
    }
    const message = error.message.toLowerCase();
    return message.includes('timeout') ||
           message.includes('network') ||
           message.includes('connection') ||
           message.includes('503') ||
           message.includes('502');
  }

  private getRetryDelay(attempt: number): number {
    return Math.min(1000 * Math.pow(2, attempt), 10000);
  }

  private delay(ms: number): Promise<void> {
    return new Promise<void>((resolve: Function) => {
      setTimeout(() => {
        resolve();
      }, ms);
    });
  }

  private handleError(error: Error | null): Error {
    if (error !== null) {
      return error;
    }
    return new Error('LLM服务调用失败');
  }

  getStats(): { requestCount: number; errorCount: number; errorRate: number } {
    const stats = {
      requestCount: this.requestCount,
      errorCount: this.errorCount,
      errorRate: this.requestCount > 0 ? this.errorCount / this.requestCount : 0
    };
    return stats;
  }

  resetStats(): void {
    this.requestCount = 0;
    this.errorCount = 0;
  }
}
