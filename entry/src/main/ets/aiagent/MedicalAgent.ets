export interface AgentConfig {
  name: string;
  description: string;
  specialty: string;
  systemPrompt: string;
  maxTokens?: number;
  temperature?: number;
}

export interface AgentResponse {
  content: string;
  sources: RAGSource[];
  confidence: number;
  agentName: string;
  timestamp: number;
}

export interface RAGSource {
  id: string;
  title: string;
  content: string;
  similarity: number;
  category: string;
}

export interface ConversationContext {
  sessionId: string;
  userId?: string;
  history: MessageItem[];
  metadata: Record<string, string>;
}

export interface MessageItem {
  role: 'user' | 'assistant' | 'system';
  content: string;
  timestamp: number;
  agentType?: string;
}

export abstract class MedicalAgent {
  protected config: AgentConfig;
  protected ragRetriever: RAGRetriever | null = null;
  protected conversationMemory: ConversationMemory | null = null;

  constructor(config: AgentConfig) {
    this.config = config;
  }

  setRAGRetriever(retriever: RAGRetriever): void {
    this.ragRetriever = retriever;
  }

  setConversationMemory(memory: ConversationMemory): void {
    this.conversationMemory = memory;
  }

  getName(): string {
    return this.config.name;
  }

  getSpecialty(): string {
    return this.config.specialty;
  }

  getDescription(): string {
    return this.config.description;
  }

  abstract canHandle(query: string): boolean;

  async processQuery(query: string, context?: ConversationContext): Promise<AgentResponse> {
    const startTime: number = Date.now();

    let relevantContext: string = '';
    let sources: RAGSource[] = [];

    if (this.ragRetriever) {
      try {
        const ragResult = await this.ragRetriever.search(query, this.config.specialty);
        relevantContext = ragResult.context;
        sources = ragResult.sources;
      } catch (e) {
        console.error(`${this.config.name} RAG检索失败:`, e);
      }
    }

    const conversationHistory: string = this.buildConversationHistory(context);

    const prompt: string = this.buildPrompt(query, relevantContext, conversationHistory);

    const responseContent: string = await this.generateResponse(prompt);

    const confidence: number = this.calculateConfidence(responseContent, sources.length > 0);

    const response: AgentResponse = {
      content: responseContent,
      sources: sources,
      confidence: confidence,
      agentName: this.config.name,
      timestamp: Date.now()
    };

    if (this.conversationMemory && context) {
      await this.conversationMemory.addMessage(context.sessionId, {
        role: 'assistant',
        content: responseContent,
        timestamp: response.timestamp,
        agentType: this.config.specialty
      });
    }

    return response;
  }

  private buildPrompt(query: string, ragContext: string, history: string): string {
    let prompt: string = `${this.config.systemPrompt}\n\n`;

    if (history) {
      prompt += `【对话历史】\n${history}\n\n`;
    }

    if (ragContext) {
      prompt += `【相关知识库内容】\n${ragContext}\n\n`;
    }

    prompt += `【用户问题】\n${query}\n\n`;
    prompt += `请基于以上信息，以${this.config.name}的身份，用专业但易懂的语言回答用户问题。`;

    return prompt;
  }

  private buildConversationHistory(context?: ConversationContext): string {
    if (!context || !context.history || context.history.length === 0) {
      return '';
    }

    let historyStr: string = '';
    const recentHistory: MessageItem[] = context.history.slice(-10);

    for (const item of recentHistory) {
      const roleLabel: string = item.role === 'user' ? '用户' : (item.agentType || 'AI助手');
      historyStr += `${roleLabel}: ${item.content}\n`;
    }

    return historyStr.trim();
  }

  protected abstract generateResponse(prompt: string): Promise<string>;

  protected calculateConfidence(response: string, hasSources: boolean): number {
    let confidence: number = 0.5;

    if (response && response.length > 50) {
      confidence += 0.2;
    }

    if (hasSources) {
      confidence += 0.2;
    }

    const professionalTerms: string[] = ['建议', '注意', '症状', '治疗', '预防', '诊断', '康复', '调理'];
    for (const term of professionalTerms) {
      if (response.indexOf(term) >= 0) {
        confidence += 0.05;
      }
    }

    return Math.min(confidence, 1.0);
  }

  getDisclaimer(): string {
    return '\n\n⚠️ **温馨提示**: 以上建议仅供参考，不能替代专业医疗诊断。如有不适请及时就医。';
  }
}
