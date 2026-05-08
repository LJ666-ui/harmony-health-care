import { WebSocketService, MessageType, ChatMessage, MessageContent } from './WebSocketService';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';

/**
 * 参与者接口
 */
export interface Participant {
  id: string;
  role: string;
  name: string;
  avatar?: string;
}

/**
 * 聊天会话接口
 */
export interface ChatSession {
  id: string;
  type: string;
  participants: Participant[];
  lastMessage?: ChatMessage;
  unreadCount: number;
  relatedPatientId?: string;
  createdAt: number;
  updatedAt: number;
}

/**
 * 聊天服务类
 */
export class ChatService {
  private static instance: ChatService | null = null;
  private wsService: WebSocketService;
  private sessions: Map<string, ChatSession> = new Map();
  private messages: Map<string, ChatMessage[]> = new Map();
  private currentUserId: string = '';
  private currentUserRole: string = '';
  
  private constructor() {
    this.wsService = WebSocketService.getInstance();
  }
  
  static getInstance(): ChatService {
    if (!ChatService.instance) {
      ChatService.instance = new ChatService();
    }
    return ChatService.instance;
  }
  
  /**
   * 初始化聊天服务
   */
  async init(userId: string, userRole: string): Promise<void> {
    this.currentUserId = userId;
    this.currentUserRole = userRole;
    console.info('聊天服务初始化完成');
  }
  
  /**
   * 获取会话列表
   */
  getSessions(): ChatSession[] {
    return Array.from(this.sessions.values())
      .sort((a, b) => b.updatedAt - a.updatedAt);
  }
  
  /**
   * 获取会话
   */
  getSession(sessionId: string): ChatSession | undefined {
    return this.sessions.get(sessionId);
  }
  
  /**
   * 创建会话
   */
  async createSession(participants: Participant[], patientId?: string): Promise<ChatSession | null> {
    try {
      const response = await HttpUtil.post<ChatSession>('/chat/sessions', {
        participants: participants,
        relatedPatientId: patientId
      });
      
      if (response.success && response.data) {
        this.sessions.set(response.data.id, response.data);
        return response.data;
      }
      return null;
    } catch (error) {
      console.error('创建会话失败:', error);
      return null;
    }
  }
  
  /**
   * 发送消息
   */
  async sendMessage(
    sessionId: string,
    receiverId: string,
    receiverRole: string,
    content: MessageContent
  ): Promise<ChatMessage | null> {
    const session = this.sessions.get(sessionId);
    if (!session) {
      console.error('会话不存在');
      return null;
    }
    
    const message: ChatMessage = {
      messageId: this.generateMessageId(),
      sessionId: sessionId,
      senderId: this.currentUserId,
      senderRole: this.currentUserRole,
      senderName: '',
      receiverId: receiverId,
      receiverRole: receiverRole,
      content: content,
      timestamp: Date.now(),
      status: 'SENDING',
      patientId: session.relatedPatientId
    };
    
    if (!this.messages.has(sessionId)) {
      this.messages.set(sessionId, []);
    }
    this.messages.get(sessionId)?.push(message);
    
    this.wsService.sendChatMessage(message);
    
    session.lastMessage = message;
    session.updatedAt = Date.now();
    
    return message;
  }
  
  /**
   * 获取聊天历史
   */
  async getChatHistory(sessionId: string, before?: number, limit: number = 50): Promise<ChatMessage[]> {
    try {
      const params: Map<string, Object> = new Map();
      params.set('limit', limit);
      if (before) {
        params.set('before', before);
      }
      
      const response = await HttpUtil.get<ChatMessage[]>(`/chat/messages/${sessionId}`, params);
      
      if (response.success && response.data) {
        const localMessages = this.messages.get(sessionId) || [];
        const allMessages: ChatMessage[] = [];
        
        for (let i = 0; i < response.data.length; i++) {
          allMessages.push(response.data[i]);
        }
        for (let i = 0; i < localMessages.length; i++) {
          allMessages.push(localMessages[i]);
        }
        
        this.messages.set(sessionId, allMessages);
        return allMessages;
      }
      return [];
    } catch (error) {
      console.error('获取聊天历史失败:', error);
      return this.messages.get(sessionId) || [];
    }
  }
  
  /**
   * 标记消息已读
   */
  markAsRead(sessionId: string, messageId: string): void {
    this.wsService.send({
      type: MessageType.MARK_READ,
      data: JSON.stringify({ sessionId: sessionId, messageId: messageId })
    });
    
    const session = this.sessions.get(sessionId);
    if (session && session.unreadCount > 0) {
      session.unreadCount = 0;
    }
  }
  
  /**
   * 生成消息ID
   */
  private generateMessageId(): string {
    return `msg_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }
  
  /**
   * 销毁
   */
  destroy(): void {
    this.sessions.clear();
    this.messages.clear();
    ChatService.instance = null;
  }
}
