import { WebSocketService, MessageType, EmergencyNotification } from './WebSocketService';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';

/**
 * 普通通知接口
 */
export interface Notification {
  id: string;
  type: string;
  receiverId: string;
  receiverRole: string;
  title: string;
  content: string;
  data: string;
  priority: string;
  status: string;
  readAt: number;
  createdAt: number;
}

/**
 * 通知服务类（符合ArkTS规范）
 */
export class NotificationService {
  private static instance: NotificationService | null = null;
  private wsService: WebSocketService;
  private notifications: Map<string, Notification> = new Map();
  private emergencyNotifications: Map<string, EmergencyNotification> = new Map();
  private currentUserId: string = '';
  private currentUserRole: string = '';
  
  private constructor() {
    this.wsService = WebSocketService.getInstance();
  }
  
  static getInstance(): NotificationService {
    if (!NotificationService.instance) {
      NotificationService.instance = new NotificationService();
    }
    return NotificationService.instance;
  }
  
  /**
   * 初始化通知服务
   */
  async init(userId: string, userRole: string): Promise<void> {
    this.currentUserId = userId;
    this.currentUserRole = userRole;
    
    this.wsService.send({
      type: MessageType.SUBSCRIBE,
      data: JSON.stringify({ userId: userId })
    });
    
    await this.loadNotifications();
  }
  
  /**
   * 加载通知列表
   */
  private async loadNotifications(): Promise<void> {
    try {
      const response = await HttpUtil.get<Notification[]>('/notifications', {
        userId: this.currentUserId,
        limit: 100
      });
      
      if (response.success && response.data) {
        response.data.forEach((notification: Notification) => {
          this.notifications.set(notification.id, notification);
        });
      }
    } catch (error) {
      console.error('加载通知列表失败:', error);
    }
  }
  
  /**
   * 发送紧急通知
   */
  async sendEmergencyNotification(notificationData: string): Promise<EmergencyNotification | null> {
    try {
      const response = await HttpUtil.post<EmergencyNotification>('/notifications/emergency', notificationData);
      
      if (response.success && response.data) {
        const savedNotification = response.data;
        this.wsService.sendEmergencyNotification(savedNotification);
        return savedNotification;
      }
      return null;
    } catch (error) {
      console.error('发送紧急通知失败:', error);
      return null;
    }
  }
  
  /**
   * 发送普通通知
   */
  async sendNotification(notificationData: string): Promise<Notification | null> {
    try {
      const response = await HttpUtil.post<Notification>('/notifications', notificationData);
      
      if (response.success && response.data) {
        return response.data;
      }
      return null;
    } catch (error) {
      console.error('发送通知失败:', error);
      return null;
    }
  }
  
  /**
   * 获取通知列表
   */
  getNotifications(type?: string, status?: string): Notification[] {
    let notifications = Array.from(this.notifications.values());
    
    if (type) {
      notifications = notifications.filter((n: Notification) => n.type === type);
    }
    
    if (status) {
      notifications = notifications.filter((n: Notification) => n.status === status);
    }
    
    return notifications.sort((a: Notification, b: Notification) => b.createdAt - a.createdAt);
  }
  
  /**
   * 获取紧急通知列表
   */
  getEmergencyNotifications(): EmergencyNotification[] {
    return Array.from(this.emergencyNotifications.values())
      .sort((a: EmergencyNotification, b: EmergencyNotification) => b.timestamp - a.timestamp);
  }
  
  /**
   * 获取未读通知数量
   */
  getUnreadCount(): number {
    return Array.from(this.notifications.values())
      .filter((n: Notification) => n.status === 'UNREAD').length;
  }
  
  /**
   * 标记通知已读
   */
  async markAsRead(notificationId: string): Promise<boolean> {
    try {
      const response = await HttpUtil.post(`/notifications/${notificationId}/read`);
      
      if (response.success) {
        const notification = this.notifications.get(notificationId);
        if (notification) {
          notification.status = 'READ';
          notification.readAt = Date.now();
        }
        return true;
      }
      return false;
    } catch (error) {
      console.error('标记已读失败:', error);
      return false;
    }
  }
  
  /**
   * 标记所有通知已读
   */
  async markAllAsRead(): Promise<boolean> {
    try {
      const response = await HttpUtil.post('/notifications/read-all', {
        userId: this.currentUserId
      });
      
      if (response.success) {
        this.notifications.forEach((notification: Notification) => {
          notification.status = 'READ';
          notification.readAt = Date.now();
        });
        return true;
      }
      return false;
    } catch (error) {
      console.error('标记所有已读失败:', error);
      return false;
    }
  }
  
  /**
   * 删除通知
   */
  async deleteNotification(notificationId: string): Promise<boolean> {
    try {
      const response = await HttpUtil.delete(`/notifications/${notificationId}`);
      
      if (response.success) {
        this.notifications.delete(notificationId);
        return true;
      }
      return false;
    } catch (error) {
      console.error('删除通知失败:', error);
      return false;
    }
  }
  
  /**
   * 销毁
   */
  destroy(): void {
    this.notifications.clear();
    this.emergencyNotifications.clear();
    NotificationService.instance = null;
  }
}
