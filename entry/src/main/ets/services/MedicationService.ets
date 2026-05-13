import { HttpUtil } from '../common/utils/HttpUtil';
import { ToastUtil } from '../common/utils/ToastUtil';

export interface MedicationPlan {
  id: number;
  userId: number;
  medicationName: string;
  dosage: string;
  frequency: string;
  times: string[];
  startDate: string;
  endDate?: string;
  reminderEnabled: boolean;
  reminderType: 'notification' | 'alarm';
  status: 'active' | 'paused' | 'completed';
  note?: string;
  createTime: string;
}

export interface MedicationRecord {
  recordId: number;
  reminderId: number;
  userId: number;
  medicationName: string;
  dosage: string;
  medicationTime: string;
  status: 'taken' | 'skipped' | 'missed';
  note?: string;
  createTime: string;
}

export interface MedicationStatistics {
  totalDays: number;
  takenDays: number;
  skippedDays: number;
  missedDays: number;
  adherenceRate: number;
  trend: 'improving' | 'declining' | 'stable';
}

interface RecordMedicationRequest {
  reminderId: number;
  medicationName: string;
  dosage: string;
  status: 'taken' | 'skipped' | 'missed';
  note?: string;
}

interface ToggleReminderRequest {
  reminderEnabled: boolean;
}

export class MedicationService {
  private static instance: MedicationService | null = null;
  
  private constructor() {}
  
  static getInstance(): MedicationService {
    if (!MedicationService.instance) {
      MedicationService.instance = new MedicationService();
    }
    return MedicationService.instance;
  }
  
  async getMedicationPlans(userId: number): Promise<MedicationPlan[]> {
    try {
      const response = await HttpUtil.get<MedicationPlan[]>(`/medication/plans?userId=${userId}`);
      
      if (response.success && response.data) {
        return response.data;
      }
      
      return [];
    } catch (error) {
      console.error('[MedicationService] 获取用药计划失败:', error);
      ToastUtil.showError('获取用药计划失败');
      return [];
    }
  }
  
  async addMedicationPlan(plan: Partial<MedicationPlan>): Promise<MedicationPlan | null> {
    try {
      const response = await HttpUtil.post<MedicationPlan>('/medication/add', plan);
      
      if (response.success && response.data) {
        ToastUtil.showSuccess('添加用药计划成功');
        return response.data;
      }
      
      ToastUtil.showError('添加用药计划失败');
      return null;
    } catch (error) {
      console.error('[MedicationService] 添加用药计划失败:', error);
      ToastUtil.showError('添加用药计划失败');
      return null;
    }
  }
  
  async updateMedicationPlan(planId: number, plan: Partial<MedicationPlan>): Promise<boolean> {
    try {
      const response = await HttpUtil.put<boolean>(`/medication/${planId}`, plan);
      
      if (response.success) {
        ToastUtil.showSuccess('更新用药计划成功');
        return true;
      }
      
      ToastUtil.showError('更新用药计划失败');
      return false;
    } catch (error) {
      console.error('[MedicationService] 更新用药计划失败:', error);
      ToastUtil.showError('更新用药计划失败');
      return false;
    }
  }
  
  async deleteMedicationPlan(planId: number): Promise<boolean> {
    try {
      const response = await HttpUtil.delete<boolean>(`/medication/${planId}`);
      
      if (response.success) {
        ToastUtil.showSuccess('删除用药计划成功');
        return true;
      }
      
      ToastUtil.showError('删除用药计划失败');
      return false;
    } catch (error) {
      console.error('[MedicationService] 删除用药计划失败:', error);
      ToastUtil.showError('删除用药计划失败');
      return false;
    }
  }
  
  async recordMedication(
    reminderId: number,
    medicationName: string,
    dosage: string,
    status: 'taken' | 'skipped' | 'missed',
    note?: string
  ): Promise<MedicationRecord | null> {
    try {
      const request: RecordMedicationRequest = {
        reminderId: reminderId,
        medicationName: medicationName,
        dosage: dosage,
        status: status,
        note: note
      };
      const response = await HttpUtil.post<MedicationRecord>('/medication/record', request);
      
      if (response.success && response.data) {
        if (status === 'taken') {
          ToastUtil.showSuccess('已记录服药');
        }
        return response.data;
      }
      
      return null;
    } catch (error) {
      console.error('[MedicationService] 记录服药失败:', error);
      ToastUtil.showError('记录服药失败');
      return null;
    }
  }
  
  async getMedicationRecords(userId: number, days: number = 7): Promise<MedicationRecord[]> {
    try {
      const response = await HttpUtil.get<MedicationRecord[]>(
        `/medication/records?userId=${userId}&days=${days}`
      );
      
      if (response.success && response.data) {
        return response.data;
      }
      
      return [];
    } catch (error) {
      console.error('[MedicationService] 获取用药记录失败:', error);
      return [];
    }
  }
  
  async getMedicationStatistics(userId: number, days: number = 30): Promise<MedicationStatistics | null> {
    try {
      const response = await HttpUtil.get<MedicationStatistics>(
        `/medication/statistics?userId=${userId}&days=${days}`
      );
      
      if (response.success && response.data) {
        return response.data;
      }
      
      return null;
    } catch (error) {
      console.error('[MedicationService] 获取用药统计失败:', error);
      return null;
    }
  }
  
  async toggleReminder(planId: number, enabled: boolean): Promise<boolean> {
    try {
      const request: ToggleReminderRequest = {
        reminderEnabled: enabled
      };
      const response = await HttpUtil.put<boolean>(`/medication/${planId}/reminder`, request);
      
      if (response.success) {
        ToastUtil.showSuccess(enabled ? '已启用提醒' : '已停用提醒');
        return true;
      }
      
      return false;
    } catch (error) {
      console.error('[MedicationService] 切换提醒状态失败:', error);
      return false;
    }
  }
}
