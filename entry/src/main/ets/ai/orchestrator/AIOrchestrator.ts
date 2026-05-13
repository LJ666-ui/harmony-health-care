import { AIRequest, AIResponse, AgentId, ConversationMessage } from '../models/AITypes';
import { AgentConfig } from '../models/AgentConfig';
import { IntentRouter, IntentType } from './IntentRouter';
import { XiaoyiAgent } from '../agents/XiaoyiAgent';
import { DeepSeekAgent, StreamCallback } from '../agents/DeepSeekAgent';
import { CozeAgent } from '../agents/CozeAgent';
import { HiAIAgent } from '../agents/HiAIAgent';

export class AIOrchestrator {
  private static instance: AIOrchestrator | null = null;
  
  private intentRouter: IntentRouter;
  private agents: Map<AgentId, any> = new Map();
  private conversationHistory: Map<string, ConversationMessage[]> = new Map();
  
  private maxRetryCount: number = 3;
  private timeoutMs: number = 30000;

  private constructor() {
    this.intentRouter = new IntentRouter();
    this.initializeAgents();
    console.log('[AIOrchestrator] 初始化完成，已加载', this.agents.size, '个智能体');
  }

  static getInstance(): AIOrchestrator {
    if (!AIOrchestrator.instance) {
      AIOrchestrator.instance = new AIOrchestrator();
    }
    return AIOrchestrator.instance;
  }

  private initializeAgents(): void {
    try {
      this.agents.set('xiaoyi', new XiaoyiAgent());
      console.log('[AIOrchestrator] ✅ 小艺智能体已加载');
    } catch (e) {
      console.error('[AIOrchestrator] ❌ 小艺智能体加载失败:', e);
      AgentConfig.updateAvailability('xiaoyi', false);
    }

    try {
      this.agents.set('deepseek', new DeepSeekAgent());
      console.log('[AIOrchestrator] ✅ DeepSeek智能体已加载');
    } catch (e) {
      console.error('[AIOrchestrator] ❌ DeepSeek智能体加载失败:', e);
      AgentConfig.updateAvailability('deepseek', false);
    }

    try {
      this.agents.set('coze', new CozeAgent());
      console.log('[AIOrchestrator] ✅ Coze智能体已加载');
    } catch (e) {
      console.error('[AIOrchestrator] ❌ Coze智能体加载失败:', e);
      AgentConfig.updateAvailability('coze', false);
    }

    try {
      this.agents.set('hiai', new HiAIAgent());
      console.log('[AIOrchestrator] ✅ HiAI智能体已加载');
    } catch (e) {
      console.error('[AIOrchestrator] ❌ HiAI智能体加载失败:', e);
      AgentConfig.updateAvailability('hiai', false);
    }
  }

  async process(request: AIRequest): Promise<AIResponse> {
    const startTime = Date.now();
    
    console.log(`[AIOrchestrator] 📥 收到请求: ${request.requestId}`);
    console.log(`[AIOrchestrator] 输入类型: ${request.input.type}`);
    console.log(`[AIOrchestrator] 偏好设置:`, request.preferences);

    let targetAgentId: AgentId = request.preferences?.preferredAgent || 'deepseek';

    try {
      const intentResult = await this.intentRouter.route(request);
      
      targetAgentId = intentResult.suggestedAgent;
      
      if (request.preferences?.preferredAgent) {
        targetAgentId = request.preferences.preferredAgent;
        console.log(`[AIOrchestrator] 用户指定使用: ${targetAgentId}`);
      } else if (intentResult.isSystemCommand) {
        targetAgentId = 'xiaoyi';
        console.log(`[AIOrchestrator] 系统命令路由到小艺`);
      }

      const response = await this.executeWithFallback(request, targetAgentId);
      
      this.updateConversationHistory(request.userId, {
        role: 'user',
        content: typeof request.input.content === 'string' ? request.input.content : '',
        timestamp: Date.now()
      });

      this.updateConversationHistory(request.userId, {
        role: 'assistant',
        content: typeof response.output.content === 'string' ? response.output.content : JSON.stringify(response.output.content),
        timestamp: Date.now(),
        agentId: response.agentId
      });

      response.metadata.processingTime = Date.now() - startTime;
      
      console.log(`[AIOrchestrator] ✅ 处理完成 (${response.metadata.processingTime}ms)`);
      console.log(`[AIOrchestrator] 使用智能体: ${response.agentId}, 置信度: ${(response.output.confidence * 100).toFixed(1)}%`);

      return response;

    } catch (error) {
      console.error('[AIOrchestrator] ❌ 处理失败:', error);
      return this.createErrorResponse(request.requestId, error as string, targetAgentId);
    }
  }

  async processStream(request: AIRequest, onChunk: StreamCallback): Promise<AIResponse> {
    const startTime = Date.now();
    
    console.log(`[AIOrchestrator] 🌊 流式请求: ${request.requestId}`);

    let targetAgentId: AgentId = request.preferences?.preferredAgent || 'deepseek';

    try {
      const agent = this.agents.get(targetAgentId);
      
      if (!agent) {
        throw new Error(`智能体 ${targetAgentId} 未注册`);
      }

      if (targetAgentId === 'deepseek' && typeof (agent as DeepSeekAgent).processStream === 'function') {
        console.log(`[AIOrchestrator] 🌊 使用DeepSeek流式模式`);
        const response = await (agent as DeepSeekAgent).processStream(request, onChunk);
        response.metadata.processingTime = Date.now() - startTime;
        return response;
      } else {
        console.log(`[AIOrchestrator] 📋 智能体 ${targetAgentId} 不支持流式，使用普通模式`);
        const response = await this.process(request);
        
        const content = typeof response.output.content === 'string' 
          ? response.output.content 
          : JSON.stringify(response.output.content);
        
        for (let i = 0; i < content.length; i += 4) {
          onChunk(content.substring(i, Math.min(i + 4, content.length)), false);
          await new Promise(resolve => setTimeout(resolve, 10));
        }
        onChunk('', true);
        
        return response;
      }
    } catch (error) {
      console.error('[AIOrchestrator] ❌ 流式处理失败:', error);
      return this.createErrorResponse(request.requestId, error as string, targetAgentId);
    }
  }

  private async executeWithFallback(request: AIRequest, primaryAgentId: AgentId): Promise<AIResponse> {
    console.log(`[AIOrchestrator] 📋 executeWithFallback - preferredAgent: ${request.preferences?.preferredAgent}, primaryAgent: ${primaryAgentId}`);
    
    if (request.preferences?.preferredAgent) {
      console.log(`[AIOrchestrator] ✅ 强制使用用户指定智能体: ${request.preferences.preferredAgent}`);
      return this.executeSingleAgent(request, request.preferences.preferredAgent);
    }

    const fallbackChain = AgentConfig.getFallbackChain(primaryAgentId);
    const agentsToTry = [primaryAgentId, ...fallbackChain];

    for (const agentId of agentsToTry) {
      try {
        const response = await this.tryAgent(request, agentId);
        return response;
      } catch (error) {
        console.warn(`[AIOrchestrator] ⚠️ 智能体 ${agentId} 调用失败:`, error);
        continue;
      }
    }

    throw new Error('所有智能体均不可用');
  }

  private async executeSingleAgent(request: AIRequest, agentId: AgentId): Promise<AIResponse> {
    console.log(`[AIOrchestrator] 🎯 用户指定使用: ${agentId}，不进行Fallback`);
    const response = await this.tryAgent(request, agentId);
    return response;
  }

  private async tryAgent(request: AIRequest, agentId: AgentId): Promise<AIResponse> {
    const agent = this.agents.get(agentId);

    if (!agent) {
      throw new Error(`智能体 ${agentId} 未注册`);
    }

    const capability = AgentConfig.getCapability(agentId);
    if (!capability?.isAvailable) {
      throw new Error(`智能体 ${agentId} 不可用`);
    }

    if (capability.requiresNetwork && request.preferences?.offlineMode) {
      throw new Error(`离线模式无法使用 ${agentId}`);
    }

    console.log(`[AIOrchestrator] 🎯 尝试调用: ${capability.name}...`);

    const response = await Promise.race([
      agent.process(request),
      this.createTimeoutPromise(agentId)
    ]);

    return response;
  }

  private createTimeoutPromise(agentId: AgentId): Promise<never> {
    return new Promise((_, reject) => {
      setTimeout(() => {
        reject(new Error(`${agentId} 响应超时`));
      }, this.timeoutMs);
    });
  }

  async processMultiAgent(request: AIRequest, agentIds: AgentId[]): Promise<AIResponse[]> {
    console.log(`[AIOrchestrator] 🚀 多智能体并行处理: ${agentIds.join(', ')}`);

    const promises = agentIds.map(async (agentId) => {
      try {
        const agent = this.agents.get(agentId);
        if (!agent) {
          throw new Error(`智能体 ${agentId} 不存在`);
        }
        return await agent.process(request);
      } catch (error) {
        return this.createErrorResponse(request.requestId, `${agentId}: ${error}`);
      }
    });

    const results = await Promise.allSettled(promises);
    
    return results
      .filter((result): result is PromiseFulfilledResult<AIResponse> => result.status === 'fulfilled')
      .map(result => result.value);
  }

  getConversationHistory(userId: string, limit?: number): ConversationMessage[] {
    const history = this.conversationHistory.get(userId) || [];
    return limit ? history.slice(-limit) : history;
  }

  clearConversationHistory(userId: string): void {
    this.conversationHistory.delete(userId);
    console.log(`[AIOrchestrator] 已清除用户 ${userId} 的对话历史`);
  }

  private updateConversationHistory(userId: string, message: ConversationMessage): void {
    if (!this.conversationHistory.has(userId)) {
      this.conversationHistory.set(userId, []);
    }
    
    const history = this.conversationHistory.get(userId)!;
    history.push(message);

    if (history.length > 50) {
      history.splice(0, history.length - 50);
    }
  }

  private createErrorResponse(requestId: string, error: string, failedAgentId?: AgentId): AIResponse {
    return {
      requestId,
      agentId: failedAgentId || 'xiaoyi',
      output: {
        type: 'text',
        content: `抱歉，我暂时无法回答您的问题。您可以尝试：\n1. 检查网络连接\n2. 稍后再试\n3. 联系客服`,
        confidence: 0
      },
      metadata: {
        processingTime: 0,
        isOffline: false,
        agentVersion: '1.0.0'
      },
      error: error,
      suggestions: ['检查网络连接', '稍后重试', '联系技术支持']
    };
  }

  getSystemStatus(): object {
    return {
      orchestrator: 'active',
      loadedAgents: Array.from(this.agents.keys()),
      agentStatuses: AgentConfig.getAllCapabilities().map(cap => ({
        id: cap.id,
        name: cap.name,
        available: cap.isAvailable,
        load: cap.currentLoad
      })),
      uptime: Date.now() / 1000
    };
  }
}
