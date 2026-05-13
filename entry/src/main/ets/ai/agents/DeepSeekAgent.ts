import { AIRequest, AIResponse, AgentId } from '../models/AITypes';

export interface DeepSeekConfig {
  apiUrl: string;
  apiKey: string;
  model: string;
  maxTokens: number;
  temperature: number;
  timeout: number;
}

export class DeepSeekAgent {
  private readonly agentId: AgentId = 'deepseek';
  private config: DeepSeekConfig;
  private systemPrompt: string;

  constructor() {
    this.config = {
      apiUrl: 'https://api.siliconflow.cn/v1/chat/completions',
      apiKey: 'sk-nyvarnxvnqlheyvsvtqvkmdxjjsqaoacnududnkwjadpxhfv',
      model: 'deepseek-ai/DeepSeek-V3',
      maxTokens: 2048,
      temperature: 0.7,
      timeout: 30000
    };

    this.systemPrompt = this.buildSystemPrompt();
    console.log('[DeepSeekAgent] DeepSeek智能体初始化完成');
    console.log('[DeepSeekAgent] 模型:', this.config.model);
  }

  private buildSystemPrompt(): string {
    return `你是一位专业的智慧康养AI助手，名为"康小智"。你的职责是为老年人及其家属提供科学的健康管理服务。

## 核心能力
1. **健康咨询**: 解答常见健康问题，提供科学建议
2. **用药指导**: 解释药物作用、用法、注意事项（不开处方）
3. **营养建议**: 根据身体状况提供饮食指导
4. **心理支持**: 关注用户情绪，提供适当的心理疏导
5. **康复建议**: 提供适合老年人的运动和康复训练建议

## 回答原则
- **通俗易懂**: 避免过多专业术语，用老人能理解的语言解释
- **谨慎负责**: 对涉及诊断的问题要谨慎，始终建议就医确认
- **关怀体贴**: 语气温和，体现对老年人群体的关爱
- **结构清晰**: 分点陈述，重要信息加粗标注

## 约束条件
- ❌ 不开具任何药物处方
- ❌ 不替代专业医生的诊断结论
- ❌ 不提供具体的治疗方案
- ✅ 对紧急情况立即引导拨打120
- ✅ 保护用户隐私，不主动收集敏感信息
- ✅ 建议定期体检和专业医疗咨询

## 示例回复格式

**用户**: "高血压患者平时要注意什么？"

**你**: 
您好！关于高血压的日常管理，我有以下几点建议：

📋 **日常监测**
- 每天早晚各测量一次血压并记录
- 目标血压一般控制在140/90mmHg以下

🍎 **饮食调整**
- **低盐**: 每日盐摄入不超过6g（约一啤酒瓶盖）
- **低脂**: 少吃肥肉、动物内脏
- **多吃**: 蔬菜水果、全谷物、鱼类

💊 **用药提醒**
- 严格遵医嘱服药，不可自行停药
- 如有不适及时就医调整方案

🏃 **适量运动**
- 每周至少150分钟中等强度有氧运动
- 推荐：快走、太极拳、游泳

⚠️ **警示信号**
如出现以下症状请立即就医：
- 剧烈头痛、胸闷气短
- 视力模糊、言语不清
- 单侧肢体无力

希望这些建议对您有帮助！如有其他问题随时问我~ 😊`;
  }

  async process(request: AIRequest): Promise<AIResponse> {
    const startTime = Date.now();

    console.log(`[DeepSeekAgent] 🧠 处理请求: ${request.requestId}`);

    try {
      const inputText = this.extractInputText(request);
      const conversationHistory = request.conversationHistory || [];

      const apiResponse = await this.callDeepSeekAPI(inputText, conversationHistory);
      
      const content = this.extractContentFromResponse(apiResponse);
      const tokensUsed = this.extractTokensFromResponse(apiResponse);

      return {
        requestId: request.requestId,
        agentId: this.agentId,
        output: {
          type: 'text',
          content: content,
          confidence: this.calculateConfidence(content)
        },
        metadata: {
          processingTime: Date.now() - startTime,
          modelUsed: this.config.model,
          tokensUsed: tokensUsed,
          isOffline: false,
          agentVersion: '1.0.0'
        },
        suggestions: this.generateSuggestions(inputText, content)
      };

    } catch (error) {
      console.error('[DeepSeekAgent] API调用失败:', error);
      return this.createErrorResponse(request.requestId, error as string, startTime);
    }
  }

  private extractInputText(request: AIRequest): string {
    if (typeof request.input.content === 'string') {
      return request.input.content;
    }
    return '';
  }

  private async callDeepSeekAPI(userMessage: string, history: any[]): Promise<any> {
    const messages = [
      { role: 'system', content: this.systemPrompt },
      ...history.slice(-6).map(msg => ({
        role: msg.role,
        content: msg.content
      })),
      { role: 'user', content: userMessage }
    ];

    const requestBody = {
      model: this.config.model,
      messages: messages,
      max_tokens: this.config.maxTokens,
      temperature: this.config.temperature,
      stream: false
    };

    console.log(`[DeepSeekAgent] 发送请求到硅基流动API...`);
    console.log(`[DeepSeekAgent] 用户消息长度: ${userMessage.length}字符`);

    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), this.config.timeout);

    try {
      const response = await fetch(this.config.apiUrl, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${this.config.apiKey}`
        },
        body: JSON.stringify(requestBody),
        signal: controller.signal
      });

      clearTimeout(timeoutId);

      if (!response.ok) {
        const errorText = await response.text();
        throw new Error(`API错误 ${response.status}: ${errorText}`);
      }

      const data = await response.json();
      console.log(`[DeepSeekAgent] API响应成功`);
      return data;

    } catch (error) {
      clearTimeout(timeoutId);
      throw error;
    }
  }

  private extractContentFromResponse(response: any): string {
    try {
      if (response.choices && response.choices.length > 0) {
        const choice = response.choices[0];
        if (choice.message && choice.message.content) {
          return choice.message.content;
        }
      }
      throw new Error('无效的响应格式');
    } catch (error) {
      console.error('[DeepSeekAgent] 解析响应失败:', error);
      return '抱歉，我暂时无法生成回复。请稍后重试。';
    }
  }

  private extractTokensFromResponse(response: any): number {
    try {
      return response.usage?.total_tokens || 0;
    } catch {
      return 0;
    }
  }

  private calculateConfidence(content: string): number {
    if (!content || content.length < 10) return 0.3;
    if (content.includes('抱歉') || content.includes('无法')) return 0.5;
    if (content.length > 200 && (content.includes('**') || content.includes('📋'))) return 0.95;
    return 0.85;
  }

  private generateSuggestions(userMessage: string, assistantResponse: string): string[] {
    const suggestions: string[] = [];

    if (userMessage.includes('血压') || userMessage.includes('血糖')) {
      suggestions.push('查看我的健康记录', '设置测量提醒');
    }

    if (userMessage.includes('药') || userMessage.includes('治疗')) {
      suggestions.push('查看用药提醒', '咨询在线医生');
    }

    if (userMessage.includes('运动') || userMessage.includes('锻炼')) {
      suggestions.push('开始康复训练', '查看运动课程');
    }

    if (userMessage.includes('饮食') || userMessage.includes('吃')) {
      suggestions.push('获取营养建议', '查看食谱推荐');
    }

    if (suggestions.length === 0) {
      suggestions.push('继续追问', '换个话题', '结束对话');
    }

    return suggestions.slice(0, 3);
  }

  private createErrorResponse(requestId: string, error: string, startTime: number): AIResponse {
    return {
      requestId,
      agentId: this.agentId,
      output: {
        type: 'text',
        content: '抱歉，AI助手暂时无法连接。这可能是因为：\n\n' +
               '1. 网络连接不稳定\n' +
               '2. 服务器负载较高\n' +
               '3. API配额已用尽\n\n' +
               '建议您稍后重试，或者使用离线功能。',
        confidence: 0
      },
      metadata: {
        processingTime: Date.now() - startTime,
        isOffline: false,
        agentVersion: '1.0.0'
      },
      error: error,
      suggestions: ['稍后重试', '使用离线模式', '联系客服']
    };
  }

  updateConfig(partialConfig: Partial<DeepSeekConfig>): void {
    this.config = { ...this.config, ...partialConfig };
    console.log('[DeepSeekAgent] 配置已更新');
  }

  getConfig(): DeepSeekConfig {
    return { ...this.config };
  }
}
