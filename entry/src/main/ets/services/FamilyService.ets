import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { MedicalService, MedicalRecord } from './MedicalService';

/**
 * 家属-患者关系接口
 */
export interface FamilyPatientRelation {
  patientId: string;
  patientName: string;
  relationship: string;
  authorizationLevel: number;
  authorizedAt: number;
}

/**
 * 患者健康摘要接口
 */
export interface PatientHealthSummary {
  patientId: string;
  patientName: string;
  currentHealthStatus: string;
  recentMedicalRecords: string;
  currentMedications: string;
  upcomingAppointments: string;
  lastVisitDate: number;
}

/**
 * 家属服务类（符合ArkTS规范）
 */
export class FamilyService {
  private static instance: FamilyService | null = null;
  private medicalService: MedicalService;
  private relations: Map<string, FamilyPatientRelation> = new Map();
  private currentFamilyId: string = '';
  
  private constructor() {
    this.medicalService = MedicalService.getInstance();
  }
  
  static getInstance(): FamilyService {
    if (!FamilyService.instance) {
      FamilyService.instance = new FamilyService();
    }
    return FamilyService.instance;
  }
  
  /**
   * 初始化家属服务
   */
  async init(familyId: string): Promise<void> {
    this.currentFamilyId = familyId;
    await this.loadRelations();
  }
  
  /**
   * 加载家属-患者关系
   */
  private async loadRelations(): Promise<void> {
    try {
      const params: Record<string, string> = {
        'familyId': this.currentFamilyId
      };
      const response = await HttpUtil.get<FamilyPatientRelation[]>('/family/relations', params);
      
      if (response.success && response.data) {
        response.data.forEach((relation: FamilyPatientRelation) => {
          this.relations.set(relation.patientId, relation);
        });
      }
    } catch (error) {
      console.error('加载家属关系失败:', error);
    }
  }
  
  /**
   * 获取关联患者列表
   */
  getRelatedPatients(): FamilyPatientRelation[] {
    return Array.from(this.relations.values());
  }
  
  /**
   * 查看患者详情
   */
  async viewPatientDetail(patientId: string): Promise<PatientHealthSummary | null> {
    const relation = this.relations.get(patientId);
    if (!relation) {
      console.error('无权查看该患者信息');
      return null;
    }
    
    try {
      const params: Record<string, string> = {
        'familyId': this.currentFamilyId,
        'authorizationLevel': relation.authorizationLevel.toString()
      };
      const response = await HttpUtil.get<PatientHealthSummary>(`/family/patient/${patientId}/detail`, params);
      
      if (response.success && response.data) {
        return response.data;
      }
      return null;
    } catch (error) {
      console.error('查看患者详情失败:', error);
      return null;
    }
  }
  
  /**
   * 查看患者病历
   */
  async viewPatientMedicalRecord(patientId: string): Promise<MedicalRecord | null> {
    const relation = this.relations.get(patientId);
    if (!relation) {
      console.error('无权查看该患者病历');
      return null;
    }
    
    if (relation.authorizationLevel < 2) {
      console.error('授权等级不足，无法查看完整病历');
      return null;
    }
    
    return await this.medicalService.getMedicalRecord(patientId);
  }
  
  /**
   * 提交家属健康信息
   */
  async submitHealthInfo(infoData: string): Promise<boolean> {
    return await this.medicalService.submitFamilyHealthInfo(infoData);
  }
  
  /**
   * 设置患者授权
   */
  async setAuthorization(patientId: string, familyId: string, authorizationLevel: number): Promise<boolean> {
    try {
      const data: Record<string, string> = {
        'familyId': familyId,
        'authorizationLevel': authorizationLevel.toString()
      };
      const response = await HttpUtil.post<boolean>(`/patients/${patientId}/authorization`, data);
      
      return response.success;
    } catch (error) {
      console.error('设置授权失败:', error);
      return false;
    }
  }
  
  /**
   * 获取授权等级说明
   */
  getAuthorizationLevelDescription(level: number): string {
    if (level === 1) {
      return '基础查看：可查看患者基本健康状态和用药情况';
    } else if (level === 2) {
      return '详细查看：可查看患者完整病历、检查报告和诊断记录';
    } else if (level === 3) {
      return '完全访问：可查看所有信息并提交健康信息';
    } else {
      return '未知授权等级';
    }
  }
  
  /**
   * 请求查看授权
   */
  async requestAuthorization(patientId: string): Promise<boolean> {
    try {
      const data: Record<string, string> = {
        'familyId': this.currentFamilyId,
        'patientId': patientId
      };
      const response = await HttpUtil.post<boolean>('/family/request-authorization', data);
      
      return response.success;
    } catch (error) {
      console.error('请求授权失败:', error);
      return false;
    }
  }
  
  /**
   * 销毁
   */
  destroy(): void {
    this.relations.clear();
    FamilyService.instance = null;
  }
}
