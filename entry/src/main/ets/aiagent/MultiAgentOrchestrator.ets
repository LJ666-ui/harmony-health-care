import { MedicalAgent, AgentResponse, ConversationContext, MessageItem } from './MedicalAgent';
import { RAGRetriever } from './RAGRetriever';
import { ConversationMemory } from './ConversationMemory';
import { InternalMedicineAgent, SurgeryAgent, TCMAgent, NutritionAgent, RehabAgent } from './SpecialistAgents';

export interface OrchestratorConfig {
  enableRAG: boolean;
  enableMemory: boolean;
  maxConcurrentAgents: number;
  defaultConfidenceThreshold: number;
}

export interface IntentClassificationResult {
  primaryIntent: string;
  confidence: number;
  matchedAgents: MedicalAgent[];
  suggestedFollowUp: string[];
}

export interface ConsultationResult {
  success: boolean;
  response: string;
  agentName: string;
  sources: Array<{ title: string; similarity: number }>;
  confidence: number;
  processingTime: number;
  timestamp: number;
}

export class MultiAgentOrchestrator {
  private agents: Map<string, MedicalAgent> = new Map();
  private ragRetriever: RAGRetriever | null = null;
  private conversationMemory: ConversationMemory | null = null;
  private config: OrchestratorConfig;

  constructor(config?: Partial<OrchestratorConfig>) {
    this.config = {
      enableRAG: true,
      enableMemory: true,
      maxConcurrentAgents: 3,
      defaultConfidenceThreshold: 0.3,
      ...config
    };

    this.initializeAgents();
    this.initializeServices();
  }

  private initializeAgents(): void {
    const internalMedicineAgent: InternalMedicineAgent = new InternalMedicineAgent();
    const surgeryAgent: SurgeryAgent = new SurgeryAgent();
    const tcmAgent: TCMAgent = new TCMAgent();
    const nutritionAgent: NutritionAgent = new NutritionAgent();
    const rehabAgent: RehabAgent = new RehabAgent();

    this.agents.set('internal_medicine', internalMedicineAgent);
    this.agents.set('surgery', surgeryAgent);
    this.agents.set('tcm', tcmAgent);
    this.agents.set('nutrition', nutritionAgent);
    this.agents.set('rehab', rehabAgent);
  }

  private initializeServices(): void {
    if (this.config.enableRAG) {
      this.ragRetriever = new RAGRetriever();
    }

    if (this.config.enableMemory) {
      this.conversationMemory = new ConversationMemory();
    }

    for (const agent of this.agents.values()) {
      if (this.ragRetriever) {
        agent.setRAGRetriever(this.ragRetriever);
      }
      if (this.conversationMemory) {
        agent.setConversationMemory(this.conversationMemory);
      }
    }
  }

  classifyIntent(query: string): IntentClassificationResult {
    const lowerQuery: string = query.toLowerCase();
    const matchedAgents: MedicalAgent[] = [];
    let maxConfidence: number = 0;
    let primaryIntent: string = 'general';

    for (const [agentType, agent] of this.agents) {
      if (agent.canHandle(query)) {
        matchedAgents.push(agent);

        const confidence: number = this.calculateIntentConfidence(lowerQuery, agentType);
        if (confidence > maxConfidence) {
          maxConfidence = confidence;
          primaryIntent = agentType;
        }
      }
    }

    if (matchedAgents.length === 0) {
      const defaultAgent: MedicalAgent | undefined = this.agents.get('internal_medicine');
      if (defaultAgent) {
        matchedAgents.push(defaultAgent);
        primaryIntent = 'internal_medicine';
        maxConfidence = 0.2;
      }
    }

    const suggestedFollowUp: string[] = this.generateSuggestedFollowUps(primaryIntent);

    return {
      primaryIntent,
      confidence: maxConfidence,
      matchedAgents,
      suggestedFollowUp
    };
  }

  private calculateIntentConfidence(query: string, agentType: string): number {
    const intentKeywords: Record<string, string[]> = {
      internal_medicine: ['血压', '血糖', '糖尿病', '高血压', '心脏病', '感冒', '发烧', '咳嗽', '头痛', '头晕', '失眠'],
      surgery: ['外伤', '伤口', '出血', '手术', '骨折', '扭伤', '烫伤', '划伤', '摔伤'],
      tcm: ['中医', '中药', '针灸', '体质', '调理', '穴位', '食疗', '养生'],
      nutrition: ['营养', '饮食', '维生素', '蛋白质', '减肥', '膳食', '热量', '食谱'],
      rehab: ['康复', '运动', '锻炼', '训练', '颈椎', '腰椎', '膝盖', '疼痛']
    };

    const keywords: string[] | undefined = intentKeywords[agentType];
    if (!keywords) return 0.3;

    let matchCount: number = 0;
    for (const keyword of keywords) {
      if (query.indexOf(keyword) >= 0) {
        matchCount++;
      }
    }

    return Math.min(0.3 + matchCount * 0.15, 1.0);
  }

  private generateSuggestedFollowUps(primaryIntent: string): string[] {
    const followUpMap: Record<string, string[]> = {
      internal_medicine: [
        '这种情况需要做哪些检查？',
        '日常生活中需要注意什么？',
        '有哪些预防措施？'
      ],
      surgery: [
        '如何判断伤情严重程度？',
        '什么时候需要去医院？',
        '伤口如何护理避免感染？'
      ],
      tcm: [
        '有什么食疗方可以配合？',
        '可以按摩哪些穴位？',
        '不同体质的人有什么区别？'
      ],
      nutrition: [
        '有什么推荐的食谱？',
        '需要补充哪些营养素？',
        '一日三餐怎么安排？'
      ],
      rehab: [
        '有什么简单的康复动作？',
        '每天需要练习多长时间？',
        '运动时需要注意什么？'
      ]
    };

    return followUpMap[primaryIntent] || [
      '还有其他问题吗？',
      '需要更详细的解释吗？',
      '想了解相关的预防措施吗？'
    ];
  }

  async consult(query: string, sessionId?: string, context?: Record<string, string>): Promise<ConsultationResult> {
    const startTime: number = Date.now();

    try {
      if (!sessionId && this.conversationMemory) {
        sessionId = await this.conversationMemory.createSession(context?.userId);
      }

      const classification: IntentClassificationResult = this.classifyIntent(query);

      let conversationContext: ConversationContext | undefined;
      if (sessionId && this.conversationMemory) {
        conversationContext = this.conversationMemory.getRecentContext(sessionId);

        await this.conversationMemory.addMessage(sessionId, {
          role: 'user' as const,
          content: query,
          timestamp: Date.now()
        });
      }

      const bestAgent: MedicalAgent = classification.matchedAgents[0];
      const agentResponse: AgentResponse = await bestAgent.processQuery(query, conversationContext);

      const result: ConsultationResult = {
        success: true,
        response: agentResponse.content,
        agentName: agentResponse.agentName,
        sources: agentResponse.sources.map(s => ({
          title: s.title,
          similarity: s.similarity
        })),
        confidence: Math.max(classification.confidence, agentResponse.confidence),
        processingTime: Date.now() - startTime,
        timestamp: Date.now()
      };

      return result;

    } catch (error) {
      console.error('Consultation error:', error);
      return {
        success: false,
        response: '抱歉，处理您的问题时出现了错误，请稍后重试。',
        agentName: '系统',
        sources: [],
        confidence: 0,
        processingTime: Date.now() - startTime,
        timestamp: Date.now()
      };
    }
  }

  getAvailableAgents(): Array<{ name: string; description: string; specialty: string }> {
    const agentList: Array<{ name: string; description: string; specialty: string }> = [];

    for (const agent of this.agents.values()) {
      agentList.push({
        name: agent.getName(),
        description: agent.getDescription(),
        specialty: agent.getSpecialty()
      });
    }

    return agentList;
  }

  async createNewSession(userId?: string): Promise<string> {
    if (!this.conversationMemory) {
      throw new Error('Conversation memory not initialized');
    }
    return this.conversationMemory.createSession(userId);
  }

  async getSessionHistory(sessionId: string): Promise<MessageItem[]> {
    if (!this.conversationMemory) {
      return [];
    }
    return this.conversationMemory.getConversationHistory(sessionId);
  }

  async clearSession(sessionId: string): Promise<boolean> {
    if (!this.conversationMemory) {
      return false;
    }
    return this.conversationMemory.clearSession(sessionId);
  }

  getConfig(): OrchestratorConfig {
    return { ...this.config };
  }

  updateConfig(newConfig: Partial<OrchestratorConfig>): void {
    this.config = { ...this.config, ...newConfig };
  }

  getStatistics(): {
    totalAgents: number;
    knowledgeBaseSize: number;
    activeSessions: number;
    totalMessages: number;
  } {
    return {
      totalAgents: this.agents.size,
      knowledgeBaseSize: this.ragRetriever?.getKnowledgeBaseSize() || 0,
      activeSessions: this.conversationMemory?.getSessionCount() || 0,
      totalMessages: this.conversationMemory?.getTotalMessageCount() || 0
    };
  }
}
