import { HttpUtil } from '../common/utils/HttpUtil';
import { ToastUtil } from '../common/utils/ToastUtil';

export interface ConsultationSession {
  sessionId: number;
  userId: number;
  doctorId: number;
  consultationType: 'text' | 'voice' | 'video';
  status: 'active' | 'ended' | 'cancelled';
  startTime: string;
  endTime?: string;
  lastMessageTime?: string;
  consultationFee?: number;
  rating?: number;
  ratingComment?: string;
}

interface CreateSessionRequest {
  doctorId: number;
  consultationType: string;
}

interface SendMessageRequest {
  sessionId: number;
  content: string;
  messageType: string;
  mediaUrl?: string;
  duration?: number;
}

interface EndConsultationRequest {
  rating?: number;
  ratingComment?: string;
}

export interface ConsultationMessage {
  messageId: number;
  sessionId: number;
  senderId: number;
  senderType: 'patient' | 'doctor';
  content: string;
  messageType: 'text' | 'image' | 'voice' | 'video';
  mediaUrl?: string;
  duration?: number;
  status: 'sending' | 'sent' | 'failed';
  createTime: string;
}

export interface OnlineDoctor {
  doctorId: number;
  doctorName: string;
  title: string;
  department: string;
  avatar: string;
  isOnline: boolean;
  consultationCount: number;
  rating: number;
  consultationFee: number;
}

export interface Prescription {
  prescriptionId: number;
  sessionId: number;
  userId: number;
  doctorId: number;
  prescriptionNo: string;
  diagnosis: string;
  prescriptionContent: string;
  usageInstruction: string;
  validDays: number;
  status: 'active' | 'expired' | 'cancelled';
  createTime: string;
}

export class ConsultationService {
  private static instance: ConsultationService | null = null;
  
  private constructor() {}
  
  static getInstance(): ConsultationService {
    if (!ConsultationService.instance) {
      ConsultationService.instance = new ConsultationService();
    }
    return ConsultationService.instance;
  }
  
  async getOnlineDoctors(departmentId?: number): Promise<OnlineDoctor[]> {
    try {
      const url = departmentId 
        ? `/doctor/online?departmentId=${departmentId}` 
        : '/doctor/online';
      const response = await HttpUtil.get<OnlineDoctor[]>(url);
      
      if (response.success && response.data) {
        return response.data;
      }
      
      return [];
    } catch (error) {
      console.error('[ConsultationService] 获取在线医生失败:', error);
      ToastUtil.showError('获取在线医生失败');
      return [];
    }
  }
  
  async createConsultationSession(
    doctorId: number,
    consultationType: 'text' | 'voice' | 'video'
  ): Promise<ConsultationSession | null> {
    try {
      const request: CreateSessionRequest = {
        doctorId: doctorId,
        consultationType: consultationType
      };
      const response = await HttpUtil.post<ConsultationSession>('/consultation/create', request);
      
      if (response.success && response.data) {
        return response.data;
      }
      
      ToastUtil.showError('创建问诊会话失败');
      return null;
    } catch (error) {
      console.error('[ConsultationService] 创建问诊会话失败:', error);
      ToastUtil.showError('创建问诊会话失败');
      return null;
    }
  }
  
  async sendMessage(
    sessionId: number,
    content: string,
    messageType: 'text' | 'image' | 'voice' | 'video' = 'text',
    mediaUrl?: string,
    duration?: number
  ): Promise<ConsultationMessage | null> {
    try {
      const request: SendMessageRequest = {
        sessionId: sessionId,
        content: content,
        messageType: messageType,
        mediaUrl: mediaUrl,
        duration: duration
      };
      const response = await HttpUtil.post<ConsultationMessage>('/consultation/message', request);
      
      if (response.success && response.data) {
        return response.data;
      }
      
      return null;
    } catch (error) {
      console.error('[ConsultationService] 发送消息失败:', error);
      return null;
    }
  }
  
  async getChatHistory(sessionId: number, page: number = 1, size: number = 50): Promise<ConsultationMessage[]> {
    try {
      const response = await HttpUtil.get<ConsultationMessage[]>(
        `/consultation/${sessionId}/messages?page=${page}&size=${size}`
      );
      
      if (response.success && response.data) {
        return response.data;
      }
      
      return [];
    } catch (error) {
      console.error('[ConsultationService] 获取聊天记录失败:', error);
      return [];
    }
  }
  
  async endConsultation(sessionId: number, rating?: number, ratingComment?: string): Promise<boolean> {
    try {
      const request: EndConsultationRequest = {
        rating: rating,
        ratingComment: ratingComment
      };
      const response = await HttpUtil.post<boolean>(`/consultation/${sessionId}/end`, request);
      
      if (response.success) {
        ToastUtil.showSuccess('问诊已结束');
        return true;
      }
      
      return false;
    } catch (error) {
      console.error('[ConsultationService] 结束问诊失败:', error);
      ToastUtil.showError('结束问诊失败');
      return false;
    }
  }
  
  async getPrescription(prescriptionId: number): Promise<Prescription | null> {
    try {
      const response = await HttpUtil.get<Prescription>(`/prescription/${prescriptionId}`);
      
      if (response.success && response.data) {
        return response.data;
      }
      
      return null;
    } catch (error) {
      console.error('[ConsultationService] 获取处方失败:', error);
      ToastUtil.showError('获取处方失败');
      return null;
    }
  }
  
  async getUserPrescriptions(userId: number): Promise<Prescription[]> {
    try {
      const response = await HttpUtil.get<Prescription[]>(`/prescription/user/${userId}`);
      
      if (response.success && response.data) {
        return response.data;
      }
      
      return [];
    } catch (error) {
      console.error('[ConsultationService] 获取用户处方列表失败:', error);
      return [];
    }
  }
  
  async getConsultationSessions(userId: number, status?: string): Promise<ConsultationSession[]> {
    try {
      const url = status 
        ? `/consultation/sessions?userId=${userId}&status=${status}` 
        : `/consultation/sessions?userId=${userId}`;
      const response = await HttpUtil.get<ConsultationSession[]>(url);
      
      if (response.success && response.data) {
        return response.data;
      }
      
      return [];
    } catch (error) {
      console.error('[ConsultationService] 获取问诊会话列表失败:', error);
      return [];
    }
  }
}
