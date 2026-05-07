import { SettingsUtil } from '../utils/SettingsUtil';

/**
 * WebSocket消息类型
 */
export enum MessageType {
  SEND_MESSAGE = 'SEND_MESSAGE',
  MESSAGE_RECEIVED = 'MESSAGE_RECEIVED',
  MARK_READ = 'MARK_READ',
  TYPING = 'TYPING',
  NOTIFICATION = 'NOTIFICATION',
  EMERGENCY = 'EMERGENCY',
  SUBSCRIBE = 'SUBSCRIBE',
  PRESCRIPTION_CREATED = 'PRESCRIPTION_CREATED',
  MEDICATION_REMINDER = 'MEDICATION_REMINDER',
  MEDICATION_CONFIRMED = 'MEDICATION_CONFIRMED',
  DATA_SYNC = 'DATA_SYNC',
  SYNC_REQUEST = 'SYNC_REQUEST',
  HEARTBEAT = 'HEARTBEAT',
  CONNECT = 'CONNECT',
  DISCONNECT = 'DISCONNECT'
}

/**
 * 消息内容接口
 */
export interface MessageContent {
  type: string;
  text?: string;
  mediaUrl?: string;
  duration?: number;
  fileSize?: number;
  fileName?: string;
}

/**
 * 聊天消息接口
 */
export interface ChatMessage {
  messageId: string;
  sessionId: string;
  senderId: string;
  senderRole: string;
  senderName: string;
  receiverId: string;
  receiverRole: string;
  content: MessageContent;
  timestamp: number;
  status: string;
  patientId?: string;
}

/**
 * 紧急通知接口
 */
export interface EmergencyNotification {
  id: string;
  type: string;
  patientId: string;
  patientName: string;
  severity: string;
  title: string;
  content: string;
  timestamp: number;
}

/**
 * 用药提醒接口
 */
export interface MedicationReminder {
  id: string;
  prescriptionId: string;
  patientId: string;
  medicationName: string;
  medicationDosage: string;
  medicationInstructions: string;
  scheduledTime: number;
  status: string;
}

/**
 * WebSocket消息接口
 */
export interface WSMessage {
  type: MessageType;
  data: string;
  timestamp?: number;
  senderId?: string;
  senderRole?: string;
}

/**
 * WebSocket连接状态
 */
export enum ConnectionState {
  CONNECTING = 'CONNECTING',
  CONNECTED = 'CONNECTED',
  DISCONNECTED = 'DISCONNECTED',
  RECONNECTING = 'RECONNECTING'
}

/**
 * WebSocket服务类（简化版）
 * 注意：HarmonyOS需要使用@ohos.net.webSocket API
 */
export class WebSocketService {
  private static instance: WebSocketService | null = null;
  private connectionState: ConnectionState = ConnectionState.DISCONNECTED;
  private reconnectAttempts: number = 0;
  private maxReconnectAttempts: number = 5;
  private heartbeatInterval: number = 30000;
  private heartbeatTimer: number = 0;
  private messageQueue: WSMessage[] = [];
  private listeners: Map<string, ((data: string) => void)[]> = new Map();
  private userId: string = '';
  private userRole: string = '';
  private serverUrl: string = 'ws://localhost:8080/ws';
  
  private constructor() {}
  
  static getInstance(): WebSocketService {
    if (!WebSocketService.instance) {
      WebSocketService.instance = new WebSocketService();
    }
    return WebSocketService.instance;
  }
  
  /**
   * 初始化WebSocket连接
   */
  async init(userId: string, userRole: string): Promise<boolean> {
    this.userId = userId;
    this.userRole = userRole;
    
    console.info('WebSocket服务初始化');
    console.info('用户ID:', userId);
    console.info('用户角色:', userRole);
    
    // 注意：实际WebSocket连接需要使用@ohos.net.webSocket
    // 这里仅作为服务层示例
    this.connectionState = ConnectionState.CONNECTED;
    
    return true;
  }
  
  /**
   * 发送消息
   */
  send(message: WSMessage): void {
    if (this.connectionState !== ConnectionState.CONNECTED) {
      this.messageQueue.push(message);
      console.warn('WebSocket未连接，消息已加入队列');
      return;
    }
    
    console.info('发送WebSocket消息:', message.type);
    // 实际发送逻辑需要使用@ohos.net.webSocket
  }
  
  /**
   * 发送聊天消息
   */
  sendChatMessage(chatMessage: ChatMessage): void {
    const message: WSMessage = {
      type: MessageType.SEND_MESSAGE,
      data: JSON.stringify(chatMessage),
      senderId: this.userId,
      senderRole: this.userRole
    };
    this.send(message);
  }
  
  /**
   * 发送紧急通知
   */
  sendEmergencyNotification(notification: EmergencyNotification): void {
    const message: WSMessage = {
      type: MessageType.EMERGENCY,
      data: JSON.stringify(notification),
      senderId: this.userId,
      senderRole: this.userRole
    };
    this.send(message);
  }
  
  /**
   * 发送用药提醒
   */
  sendMedicationReminder(reminder: MedicationReminder): void {
    const message: WSMessage = {
      type: MessageType.MEDICATION_REMINDER,
      data: JSON.stringify(reminder),
      senderId: this.userId,
      senderRole: this.userRole
    };
    this.send(message);
  }
  
  /**
   * 订阅消息
   */
  subscribe(messageType: MessageType, callback: (data: string) => void): void {
    const type = messageType as string;
    if (!this.listeners.has(type)) {
      this.listeners.set(type, []);
    }
    this.listeners.get(type)?.push(callback);
  }
  
  /**
   * 取消订阅
   */
  unsubscribe(messageType: MessageType, callback: (data: string) => void): void {
    const type = messageType as string;
    const listeners = this.listeners.get(type);
    if (listeners) {
      const index = listeners.indexOf(callback);
      if (index > -1) {
        listeners.splice(index, 1);
      }
    }
  }
  
  /**
   * 获取连接状态
   */
  getState(): ConnectionState {
    return this.connectionState;
  }
  
  /**
   * 是否已连接
   */
  isConnected(): boolean {
    return this.connectionState === ConnectionState.CONNECTED;
  }
  
  /**
   * 关闭连接
   */
  close(): void {
    if (this.heartbeatTimer) {
      clearInterval(this.heartbeatTimer);
      this.heartbeatTimer = 0;
    }
    this.connectionState = ConnectionState.DISCONNECTED;
    this.messageQueue = [];
    this.listeners.clear();
    console.info('WebSocket连接已关闭');
  }
  
  /**
   * 销毁单例
   */
  static destroy(): void {
    if (WebSocketService.instance) {
      WebSocketService.instance.close();
      WebSocketService.instance = null;
    }
  }
}
