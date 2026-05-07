import { WebSocketService, MessageType, MedicationReminder } from './WebSocketService';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';

/**
 * 病历接口
 */
export interface MedicalRecord {
  id: string;
  patientId: string;
  basicInfo: string;
  medicalHistory: string;
  diagnoses: string;
  prescriptions: string;
  testReports: string;
  surgeries: string;
  familyHealthInfo: string;
  createdAt: number;
  updatedAt: number;
}

/**
 * 处方接口
 */
export interface Prescription {
  id: string;
  patientId: string;
  patientName: string;
  doctorId: string;
  doctorName: string;
  medications: string;
  diagnosis: string;
  notes: string;
  status: string;
  createdAt: number;
  validUntil: number;
}

/**
 * 诊断接口
 */
export interface Diagnosis {
  id: string;
  patientId: string;
  doctorId: string;
  doctorName: string;
  symptoms: string;
  examinationResults: string;
  diagnosis: string;
  treatmentPlan: string;
  createdAt: number;
}

/**
 * 医疗服务类（符合ArkTS规范）
 */
export class MedicalService {
  private static instance: MedicalService | null = null;
  private wsService: WebSocketService;
  private reminders: Map<string, MedicationReminder> = new Map();
  
  private constructor() {
    this.wsService = WebSocketService.getInstance();
  }
  
  static getInstance(): MedicalService {
    if (!MedicalService.instance) {
      MedicalService.instance = new MedicalService();
    }
    return MedicalService.instance;
  }
  
  /**
   * 获取患者病历
   */
  async getMedicalRecord(patientId: string): Promise<MedicalRecord | null> {
    try {
      const response = await HttpUtil.get<MedicalRecord>(`/medical/records/${patientId}`);
      if (response.success && response.data) {
        return response.data;
      }
      return null;
    } catch (error) {
      console.error('获取病历失败:', error);
      return null;
    }
  }
  
  /**
   * 开具处方
   */
  async createPrescription(prescriptionData: string): Promise<Prescription | null> {
    try {
      const data: Record<string, string> = {
        'data': prescriptionData
      };
      const response = await HttpUtil.post<Prescription>('/medical/prescriptions', data);
      
      if (response.success && response.data) {
        const prescription = response.data;
        
        // 发送处方创建事件
        this.wsService.send({
          type: MessageType.PRESCRIPTION_CREATED,
          data: JSON.stringify(prescription)
        });
        
        return prescription;
      }
      return null;
    } catch (error) {
      console.error('开具处方失败:', error);
      return null;
    }
  }
  
  /**
   * 获取用药提醒列表
   */
  async getMedicationReminders(patientId: string): Promise<MedicationReminder[]> {
    try {
      const response = await HttpUtil.get<MedicationReminder[]>(`/medical/reminders/${patientId}`);
      if (response.success && response.data) {
        response.data.forEach((reminder: MedicationReminder) => {
          this.reminders.set(reminder.id, reminder);
        });
        return response.data;
      }
      return [];
    } catch (error) {
      console.error('获取用药提醒失败:', error);
      return Array.from(this.reminders.values());
    }
  }
  
  /**
   * 确认服药
   */
  async confirmMedication(reminderId: string, action: string): Promise<boolean> {
    try {
      const confirmData: Record<string, string> = {
        'action': action
      };
      const response = await HttpUtil.post<boolean>(`/medical/reminders/${reminderId}/confirm`, confirmData);
      
      if (response.success) {
        const reminder = this.reminders.get(reminderId);
        if (reminder) {
          reminder.status = action;
        }
        
        // 发送确认事件
        this.wsService.send({
          type: MessageType.MEDICATION_CONFIRMED,
          data: JSON.stringify({ reminderId: reminderId, action: action })
        });
        
        return true;
      }
      return false;
    } catch (error) {
      console.error('确认服药失败:', error);
      return false;
    }
  }
  
  /**
   * 记录诊断
   */
  async recordDiagnosis(diagnosisData: string): Promise<Diagnosis | null> {
    try {
      const data: Record<string, string> = {
        'data': diagnosisData
      };
      const response = await HttpUtil.post<Diagnosis>('/medical/diagnoses', data);
      if (response.success && response.data) {
        return response.data;
      }
      return null;
    } catch (error) {
      console.error('记录诊断失败:', error);
      return null;
    }
  }
  
  /**
   * 提交家属健康信息
   */
  async submitFamilyHealthInfo(infoData: string): Promise<boolean> {
    try {
      const data: Record<string, string> = {
        'data': infoData
      };
      const response = await HttpUtil.post<boolean>('/medical/family-health', data);
      return response.success;
    } catch (error) {
      console.error('提交家属健康信息失败:', error);
      return false;
    }
  }
  
  /**
   * 销毁
   */
  destroy(): void {
    this.reminders.clear();
    MedicalService.instance = null;
  }
}
