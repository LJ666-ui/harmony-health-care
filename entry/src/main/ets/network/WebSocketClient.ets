import { WebSocketService, MessageType, WSMessage, ConnectionState } from '../services/WebSocketService';

export interface MessageData {
  messageId?: number;
  senderId?: number;
  receiverId?: number;
  content?: string;
  createTime?: string;
}

export interface MessageHandler {
  onMessage(message: MessageData): void;
  onConnect?(): void;
  onDisconnect?(): void;
  onError?(error: Error): void;
}

export class WebSocketClient {
  private static instances: Map<string, WebSocketClient> = new Map();
  private wsService: WebSocketService;
  private sessionId: string;
  private messageHandlers: MessageHandler[] = [];
  private reconnectTimer: number = 0;
  private heartbeatTimer: number = 0;
  private isConnected: boolean = false;
  private reconnectAttempts: number = 0;
  private maxReconnectAttempts: number = 5;
  private reconnectDelay: number = 3000;
  private heartbeatInterval: number = 30000;
  
  private constructor(sessionId: string) {
    this.sessionId = sessionId;
    this.wsService = WebSocketService.getInstance();
  }
  
  static getInstance(sessionId: string): WebSocketClient {
    if (!WebSocketClient.instances.has(sessionId)) {
      WebSocketClient.instances.set(sessionId, new WebSocketClient(sessionId));
    }
    return WebSocketClient.instances.get(sessionId)!;
  }
  
  async connect(userId: string, userRole: string): Promise<boolean> {
    try {
      console.info(`[WebSocketClient] 连接会话: ${this.sessionId}`);
      
      const success = await this.wsService.init(userId, userRole);
      
      if (success) {
        this.isConnected = true;
        this.reconnectAttempts = 0;
        this.startHeartbeat();
        this.notifyConnect();
        console.info('[WebSocketClient] 连接成功');
        return true;
      }
      
      return false;
    } catch (error) {
      console.error('[WebSocketClient] 连接失败:', error);
      this.handleError(error as Error);
      return false;
    }
  }
  
  disconnect(): void {
    console.info(`[WebSocketClient] 断开会话: ${this.sessionId}`);
    
    this.stopHeartbeat();
    this.isConnected = false;
    this.notifyDisconnect();
    
    WebSocketClient.instances.delete(this.sessionId);
  }
  
  send(message: MessageData): boolean {
    if (!this.isConnected) {
      console.warn('[WebSocketClient] 未连接，无法发送消息');
      return false;
    }
    
    try {
      const wsMessage: WSMessage = {
        type: MessageType.SEND_MESSAGE,
        data: JSON.stringify(message),
        timestamp: Date.now()
      };
      
      this.wsService.send(wsMessage);
      console.info('[WebSocketClient] 消息已发送');
      return true;
    } catch (error) {
      console.error('[WebSocketClient] 发送消息失败:', error);
      return false;
    }
  }
  
  addMessageHandler(handler: MessageHandler): void {
    this.messageHandlers.push(handler);
  }
  
  removeMessageHandler(handler: MessageHandler): void {
    const index = this.messageHandlers.indexOf(handler);
    if (index !== -1) {
      this.messageHandlers.splice(index, 1);
    }
  }
  
  private startHeartbeat(): void {
    this.stopHeartbeat();
    
    this.heartbeatTimer = setInterval(() => {
      if (this.isConnected) {
        this.wsService.send({
          type: MessageType.HEARTBEAT,
          data: '',
          timestamp: Date.now()
        });
        console.info('[WebSocketClient] 发送心跳');
      }
    }, this.heartbeatInterval);
  }
  
  private stopHeartbeat(): void {
    if (this.heartbeatTimer) {
      clearInterval(this.heartbeatTimer);
      this.heartbeatTimer = 0;
    }
  }
  
  private startReconnect(): void {
    if (this.reconnectAttempts >= this.maxReconnectAttempts) {
      console.error('[WebSocketClient] 达到最大重连次数');
      this.handleError(new Error('连接失败，请重新连接'));
      return;
    }
    
    this.reconnectAttempts++;
    console.info(`[WebSocketClient] 开始重连 (${this.reconnectAttempts}/${this.maxReconnectAttempts})`);
    
    this.reconnectTimer = setTimeout(() => {
      this.reconnect();
    }, this.reconnectDelay * this.reconnectAttempts);
  }
  
  private async reconnect(): Promise<void> {
    try {
      const success = await this.wsService.init('', '');
      
      if (success) {
        this.isConnected = true;
        this.reconnectAttempts = 0;
        this.startHeartbeat();
        this.notifyConnect();
        console.info('[WebSocketClient] 重连成功');
      } else {
        this.startReconnect();
      }
    } catch (error) {
      console.error('[WebSocketClient] 重连失败:', error);
      this.startReconnect();
    }
  }
  
  private notifyConnect(): void {
    this.messageHandlers.forEach(handler => {
      if (handler.onConnect) {
        handler.onConnect();
      }
    });
  }
  
  private notifyDisconnect(): void {
    this.messageHandlers.forEach(handler => {
      if (handler.onDisconnect) {
        handler.onDisconnect();
      }
    });
  }
  
  private notifyMessage(message: MessageData): void {
    this.messageHandlers.forEach(handler => {
      handler.onMessage(message);
    });
  }
  
  private handleError(error: Error): void {
    this.messageHandlers.forEach(handler => {
      if (handler.onError) {
        handler.onError(error);
      }
    });
  }
  
  getConnectionStatus(): boolean {
    return this.isConnected;
  }
  
  getSessionId(): string {
    return this.sessionId;
  }
}
