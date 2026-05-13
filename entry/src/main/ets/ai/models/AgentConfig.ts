import { AgentId, AgentCapability } from './AITypes';

export class AgentConfig {
  private static readonly CONFIGS: Map<AgentId, AgentCapability> = new Map([
    ['xiaoyi', {
      id: 'xiaoyi',
      name: '小艺智能体',
      description: 'HarmonyOS原生语音助手，处理系统级命令和多设备联动',
      supportedInputTypes: ['text', 'voice'],
      maxLatency: 500,
      requiresNetwork: false,
      privacyLevel: 'high',
      isAvailable: true,
      currentLoad: 0
    }],
    ['deepseek', {
      id: 'deepseek',
      name: '硅基流动DeepSeek',
      description: '云端大语言模型，提供复杂语义理解和多轮对话能力',
      supportedInputTypes: ['text', 'image'],
      maxLatency: 2000,
      requiresNetwork: true,
      privacyLevel: 'medium',
      isAvailable: true,
      currentLoad: 0
    }],
    ['coze', {
      id: 'coze',
      name: 'Coze智能体',
      description: '字节跳动AI平台，提供知识库问答和工作流自动化',
      supportedInputTypes: ['text', 'image'],
      maxLatency: 3000,
      requiresNetwork: true,
      privacyLevel: 'medium',
      isAvailable: true,
      currentLoad: 0
    }],
    ['mindspore', {
      id: 'mindspore',
      name: 'MindSpore Lite',
      description: '华为端侧推理引擎，本地执行风险评估和健康监测',
      supportedInputTypes: ['text', 'sensor'],
      maxLatency: 100,
      requiresNetwork: false,
      privacyLevel: 'extreme',
      isAvailable: true,
      currentLoad: 0
    }],
    ['hiai', {
      id: 'hiai',
      name: 'HiAI NPU加速器',
      description: '华为NPU硬件加速，极致性能的端侧AI推理',
      supportedInputTypes: ['sensor', 'image'],
      maxLatency: 50,
      requiresNetwork: false,
      privacyLevel: 'extreme',
      isAvailable: true,
      currentLoad: 0
    }]
  ]);

  static getCapability(agentId: AgentId): AgentCapability | undefined {
    return this.CONFIGS.get(agentId);
  }

  static getAllCapabilities(): AgentCapability[] {
    return Array.from(this.CONFIGS.values());
  }

  static getAvailableAgents(): AgentCapability[] {
    return this.getAllCapabilities().filter(agent => agent.isAvailable);
  }

  static updateAvailability(agentId: AgentId, isAvailable: boolean): void {
    const config = this.CONFIGS.get(agentId);
    if (config) {
      config.isAvailable = isAvailable;
    }
  }

  static getBestAgentForTask(
    inputType: string,
    requiresPrivacy: boolean,
    hasNetwork: boolean,
    preferredLatency?: number
  ): AgentId {
    const availableAgents = this.getAvailableAgents()
      .filter(agent => {
        const supportsInput = agent.supportedInputTypes.includes(inputType as any);
        const meetsPrivacy = !requiresPrivacy || agent.privacyLevel === 'extreme' || agent.privacyLevel === 'high';
        const meetsNetwork = !agent.requiresNetwork || hasNetwork;
        return supportsInput && meetsPrivacy && meetsNetwork;
      })
      .sort((a, b) => a.maxLatency - b.maxLatency);

    if (availableAgents.length === 0) {
      console.warn('[AgentConfig] No suitable agent found, using default fallback');
      return 'deepseek';
    }

    if (preferredLatency) {
      const fastEnough = availableAgents.find(agent => agent.maxLatency <= preferredLatency);
      if (fastEnough) {
        return fastEnough.id;
      }
    }

    return availableAgents[0].id;
  }

  static getFallbackChain(agentId: AgentId): AgentId[] {
    const fallbackMap: Record<AgentId, AgentId[]> = {
      xiaoyi: ['deepseek', 'mindspore'],
      deepseek: ['xiaoyi', 'mindspore'],
      coze: ['deepseek', 'xiaoyi', 'mindspore'],
      mindspore: ['hiai', 'xiaoyi', 'deepseek'],
      hiai: ['mindspore', 'xiaoyi', 'deepseek']
    };
    return fallbackMap[agentId] || ['deepseek'];
  }
}
