import { HttpUtil } from '../common/utils/HttpUtil';
import { ToastUtil } from '../common/utils/ToastUtil';

export interface HealthData {
  recordId: number;
  userId: number;
  dataType: 'blood_pressure' | 'blood_sugar' | 'weight' | 'heart_rate' | 'temperature';
  value: number;
  unit: string;
  systolic?: number;
  diastolic?: number;
  recordDate: string;
  recordTime: string;
  dataSource: 'manual' | 'device';
  note?: string;
  createTime: string;
}

export interface HealthTrend {
  dataType: string;
  dataPoints: TrendPoint[];
  trend: 'rising' | 'falling' | 'stable';
  average: number;
  min: number;
  max: number;
}

export interface TrendPoint {
  date: string;
  value: number;
  systolic?: number;
  diastolic?: number;
}

export interface CheckupReport {
  reportId: number;
  userId: number;
  reportNo: string;
  reportType: 'annual' | 'special' | 'follow_up';
  hospitalId: number;
  hospitalName: string;
  checkupDate: string;
  reportUrl: string;
  reportSummary: string;
  abnormalItems: CheckupItem[];
  doctorAdvice: string;
  status: 'pending' | 'completed' | 'reviewed';
  createTime: string;
}

export interface CheckupItem {
  itemName: string;
  result: string;
  unit: string;
  referenceRange: string;
  status: 'normal' | 'abnormal' | 'attention';
}

export class HealthService {
  private static instance: HealthService | null = null;
  
  private constructor() {}
  
  static getInstance(): HealthService {
    if (!HealthService.instance) {
      HealthService.instance = new HealthService();
    }
    return HealthService.instance;
  }
  
  async getHealthData(userId: number, dataType?: string): Promise<HealthData[]> {
    try {
      const url = dataType 
        ? `/health/data?userId=${userId}&dataType=${dataType}` 
        : `/health/data?userId=${userId}`;
      const response = await HttpUtil.get<HealthData[]>(url);
      
      if (response.success && response.data) {
        return response.data;
      }
      
      return [];
    } catch (error) {
      console.error('[HealthService] 获取健康数据失败:', error);
      ToastUtil.showError('获取健康数据失败');
      return [];
    }
  }
  
  async addHealthRecord(record: Partial<HealthData>): Promise<HealthData | null> {
    try {
      const response = await HttpUtil.post<HealthData>('/health/record', record);
      
      if (response.success && response.data) {
        ToastUtil.showSuccess('添加健康记录成功');
        return response.data;
      }
      
      ToastUtil.showError('添加健康记录失败');
      return null;
    } catch (error) {
      console.error('[HealthService] 添加健康记录失败:', error);
      ToastUtil.showError('添加健康记录失败');
      return null;
    }
  }
  
  async getHealthTrend(
    userId: number,
    dataType: string,
    days: number = 30
  ): Promise<HealthTrend | null> {
    try {
      const response = await HttpUtil.get<HealthTrend>(
        `/health/trend?userId=${userId}&dataType=${dataType}&days=${days}`
      );
      
      if (response.success && response.data) {
        return response.data;
      }
      
      return null;
    } catch (error) {
      console.error('[HealthService] 获取健康趋势失败:', error);
      return null;
    }
  }
  
  async getCheckupReports(userId: number): Promise<CheckupReport[]> {
    try {
      const response = await HttpUtil.get<CheckupReport[]>(`/checkup/list?userId=${userId}`);
      
      if (response.success && response.data) {
        return response.data;
      }
      
      return [];
    } catch (error) {
      console.error('[HealthService] 获取体检报告列表失败:', error);
      ToastUtil.showError('获取体检报告失败');
      return [];
    }
  }
  
  async getCheckupReportDetail(reportId: number): Promise<CheckupReport | null> {
    try {
      const response = await HttpUtil.get<CheckupReport>(`/checkup/${reportId}`);
      
      if (response.success && response.data) {
        return response.data;
      }
      
      ToastUtil.showError('获取体检报告详情失败');
      return null;
    } catch (error) {
      console.error('[HealthService] 获取体检报告详情失败:', error);
      ToastUtil.showError('获取体检报告详情失败');
      return null;
    }
  }
  
  async getLatestHealthData(userId: number): Promise<Map<string, HealthData>> {
    const healthDataMap = new Map<string, HealthData>();
    
    try {
      const dataTypes = ['blood_pressure', 'blood_sugar', 'weight', 'heart_rate', 'temperature'];
      
      const promises = dataTypes.map(async (type) => {
        const data = await this.getHealthData(userId, type);
        if (data && data.length > 0) {
          healthDataMap.set(type, data[0]);
        }
      });
      
      await Promise.all(promises);
    } catch (error) {
      console.error('[HealthService] 获取最新健康数据失败:', error);
    }
    
    return healthDataMap;
  }
  
  async deleteHealthRecord(recordId: number): Promise<boolean> {
    try {
      const response = await HttpUtil.delete<boolean>(`/health/record/${recordId}`);
      
      if (response.success) {
        ToastUtil.showSuccess('删除成功');
        return true;
      }
      
      return false;
    } catch (error) {
      console.error('[HealthService] 删除健康记录失败:', error);
      ToastUtil.showError('删除失败');
      return false;
    }
  }
  
  async exportHealthData(userId: number, startDate: string, endDate: string): Promise<string | null> {
    try {
      const response = await HttpUtil.get<string>(
        `/health/export?userId=${userId}&startDate=${startDate}&endDate=${endDate}`
      );
      
      if (response.success && response.data) {
        return response.data;
      }
      
      return null;
    } catch (error) {
      console.error('[HealthService] 导出健康数据失败:', error);
      ToastUtil.showError('导出失败');
      return null;
    }
  }
}
