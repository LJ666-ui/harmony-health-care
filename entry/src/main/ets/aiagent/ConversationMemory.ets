import { MessageItem } from './MedicalAgent';

export interface SessionInfo {
  sessionId: string;
  userId?: string;
  title: string;
  createTime: number;
  updateTime: number;
  messageCount: number;
}

export class ConversationMemory {
  private sessions: Map<string, MessageItem[]> = new Map();
  private sessionInfos: Map<string, SessionInfo> = new Map();
  private maxHistoryLength: number = 50;
  private maxSessions: number = 20;

  constructor(maxHistoryLength: number = 50) {
    this.maxHistoryLength = maxHistoryLength;
  }

  async createSession(userId?: string, initialTitle: string = '新对话'): Promise<string> {
    const sessionId: string = this.generateSessionId();

    const sessionInfo: SessionInfo = {
      sessionId,
      userId,
      title: initialTitle,
      createTime: Date.now(),
      updateTime: Date.now(),
      messageCount: 0
    };

    this.sessions.set(sessionId, []);
    this.sessionInfos.set(sessionId, sessionInfo);

    return sessionId;
  }

  async addMessage(sessionId: string, message: MessageItem): Promise<boolean> {
    let messages: MessageItem[] | undefined = this.sessions.get(sessionId);
    if (!messages) {
      messages = [];
      this.sessions.set(sessionId, messages);
    }

    messages.push(message);

    if (messages.length > this.maxHistoryLength) {
      messages = messages.slice(-this.maxHistoryLength);
      this.sessions.set(sessionId, messages);
    }

    const sessionInfo: SessionInfo | undefined = this.sessionInfos.get(sessionId);
    if (sessionInfo) {
      sessionInfo.updateTime = Date.now();
      sessionInfo.messageCount = messages.length;

      if (message.role === 'user' && sessionInfo.title === '新对话') {
        sessionInfo.title = message.content.substring(0, 30) + (message.content.length > 30 ? '...' : '');
      }
    }

    return true;
  }

  async getConversationHistory(sessionId: string, limit?: number): Promise<MessageItem[]> {
    const messages: MessageItem[] | undefined = this.sessions.get(sessionId);
    if (!messages) {
      return [];
    }

    if (limit && limit < messages.length) {
      return messages.slice(-limit);
    }

    return [...messages];
  }

  async getSessionInfo(sessionId: string): Promise<SessionInfo | null> {
    const info: SessionInfo | undefined = this.sessionInfos.get(sessionId);
    return info ? { ...info } : null;
  }

  async getAllSessions(userId?: string): Promise<SessionInfo[]> {
    const allSessions: SessionInfo[] = [];

    for (const info of this.sessionInfos.values()) {
      if (!userId || info.userId === userId) {
        allSessions.push({ ...info });
      }
    }

    allSessions.sort((a, b) => b.updateTime - a.updateTime);

    return allSessions;
  }

  async clearSession(sessionId: string): Promise<boolean> {
    this.sessions.delete(sessionId);
    this.sessionInfos.delete(sessionId);
    return true;
  }

  async clearAllSessions(): Promise<void> {
    this.sessions.clear();
    this.sessionInfos.clear();
  }

  getRecentContext(sessionId: string, contextWindow: number = 10): ConversationContext {
    const messages: MessageItem[] | undefined = this.sessions.get(sessionId);
    const sessionInfo: SessionInfo | undefined = this.sessionInfos.get(sessionId);

    const recentMessages: MessageItem[] = messages ? messages.slice(-contextWindow) : [];

    return {
      sessionId,
      userId: sessionInfo?.userId,
      history: recentMessages,
      metadata: {}
    };
  }

  getSessionCount(): number {
    return this.sessions.size;
  }

  getTotalMessageCount(): number {
    let total: number = 0;
    for (const messages of this.sessions.values()) {
      total += messages.length;
    }
    return total;
  }

  private generateSessionId(): string {
    return 'session_' + Date.now() + '_' + Math.random().toString(36).substring(2, 10);
  }
}
