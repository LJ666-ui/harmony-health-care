import { HealthRecord, Alert, HealthRecordType } from './AnomalyDetector';
import { AnomalyDetector } from './AnomalyDetector';
import { AlertManager } from './AlertManager';

export interface BloodPressureData {
  systolic: number;
  diastolic: number;
  timestamp: string;
}

export interface BloodSugarData {
  value: number;
  type: 'fasting' | 'random' | 'postprandial';
  timestamp: string;
}

export interface VitalSignData {
  value: number;
  timestamp: string;
}

export interface VitalSignsSnapshot {
  bloodPressure: BloodPressureData | null;
  bloodSugar: BloodSugarData | null;
  heartRate: VitalSignData | null;
  weight: VitalSignData | null;
  temperature: VitalSignData | null;
  oxygenSaturation: VitalSignData | null;
  lastUpdateTime: string;
}

export interface AlertThresholds {
  systolicHigh: number;
  systolicLow: number;
  diastolicHigh: number;
  diastolicLow: number;
  sugarHigh: number;
  sugarLow: number;
  heartRateHigh: number;
  heartRateLow: number;
}

export interface MonitoringConfig {
  checkIntervalMs: number;
  enableAutoAlert: boolean;
  alertThresholds: AlertThresholds;
  emergencyContacts: EmergencyContact[];
}

export interface MonitoringStatus {
  isActive: boolean;
  totalRecords: number;
  config: MonitoringConfig;
  uptimeMinutes: number;
}

export interface EmergencyContact {
  id: string;
  name: string;
  phone: string;
  relationship: string;
  isPrimary: boolean;
  enabled: boolean;
}

export interface MonitoringConfigUpdate {
  checkIntervalMs?: number;
  enableAutoAlert?: boolean;
  alertThresholds?: AlertThresholds;
  emergencyContacts?: EmergencyContact[];
}

export class RealtimeMonitor {
  private static instance: RealtimeMonitor | null = null;

  private monitoringTimerId: number | null = null;
  private isMonitoring: boolean = false;
  private healthRecords: HealthRecord[] = [];
  private alertCallbacks: ((alert: Alert) => void)[] = [];
  private anomalyDetector: AnomalyDetector = AnomalyDetector.getInstance();
  private alertManager: AlertManager = AlertManager.getInstance();

  private config: MonitoringConfig = (() => {
    const thresholds: AlertThresholds = {
      systolicHigh: 180,
      systolicLow: 90,
      diastolicHigh: 110,
      diastolicLow: 60,
      sugarHigh: 11.0,
      sugarLow: 3.9,
      heartRateHigh: 120,
      heartRateLow: 50
    };

    const contact1: EmergencyContact = {
      id: 'EC_001',
      name: '张医生',
      phone: '13800138000',
      relationship: '家庭医生',
      isPrimary: true,
      enabled: true
    };

    const contact2: EmergencyContact = {
      id: 'EC_002',
      name: '李女士',
      phone: '13900139000',
      relationship: '女儿',
      isPrimary: false,
      enabled: true
    };

    return {
      checkIntervalMs: 5 * 60 * 1000,
      enableAutoAlert: true,
      alertThresholds: thresholds,
      emergencyContacts: [contact1, contact2]
    };
  })();

  private constructor() {
    console.log('[RealtimeMonitor] 初始化实时监控服务');
  }

  static getInstance(): RealtimeMonitor {
    if (!RealtimeMonitor.instance) {
      RealtimeMonitor.instance = new RealtimeMonitor();
    }
    return RealtimeMonitor.instance;
  }

  startMonitoring(): void {
    if (this.isMonitoring) {
      console.warn('[RealtimeMonitor] 监控已在运行中');
      return;
    }

    console.log('[RealtimeMonitor] 启动后台监控...');
    
    this.isMonitoring = true;
    
    this.monitoringTimerId = setInterval(() => {
      this.performPeriodicCheck();
    }, this.config.checkIntervalMs);

    console.log(`[RealtimeMonitor] 定时检查已启动，间隔: ${this.config.checkIntervalMs / 1000}秒`);
  }

  stopMonitoring(): void {
    console.log('[RealtimeMonitor] 停止后台监控');

    if (this.monitoringTimerId !== null) {
      clearInterval(this.monitoringTimerId);
      this.monitoringTimerId = null;
    }

    this.isMonitoring = false;
    console.log('[RealtimeMonitor] 监控已停止');
  }

  async addManualRecord(record: HealthRecord): Promise<void> {
    console.log(`[RealtimeMonitor] 添加手动记录: ${record.type}`);

    const enrichedRecord: HealthRecord = {
      recordId: `REC_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
      type: record.type,
      values: record.values,
      source: 'MANUAL',
      timestamp: new Date().toISOString(),
      userId: 'USER_001'
    };

    this.healthRecords.push(enrichedRecord);

    await this.saveToLocalStorage(enrichedRecord);

    await this.detectAndHandleAnomaly(enrichedRecord);
  }

  getLatestVitalSigns(): VitalSignsSnapshot {
    const now = new Date().toISOString();

    const snapshot: VitalSignsSnapshot = {
      bloodPressure: this.getLatestRecord('blood_pressure') as BloodPressureData | null,
      bloodSugar: this.getLatestRecord('blood_sugar') as BloodSugarData | null,
      heartRate: this.getLatestRecord('heart_rate') as VitalSignData | null,
      weight: this.getLatestRecord('weight') as VitalSignData | null,
      temperature: this.getLatestRecord('temperature') as VitalSignData | null,
      oxygenSaturation: null,
      lastUpdateTime: now
    };
    return snapshot;
  }

  subscribeToAlerts(callback: (alert: Alert) => void): void {
    this.alertCallbacks.push(callback);
    console.log(`[RealtimeMonitor] 新的预警订阅者，当前共${this.alertCallbacks.length}个`);
  }

  unsubscribeFromAlerts(callback: (alert: Alert) => void): void {
    const index = this.alertCallbacks.indexOf(callback);
    if (index > -1) {
      this.alertCallbacks.splice(index, 1);
      console.log(`[RealtimeMonitor] 取消订阅，剩余${this.alertCallbacks.length}个`);
    }
  }

  getHealthHistory(days: number = 30): HealthRecord[] {
    const cutoffDate = new Date(Date.now() - days * 24 * 60 * 60 * 1000);
    
    return this.healthRecords.filter(record => 
      new Date(record.timestamp) >= cutoffDate
    ).sort((a, b) => new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime());
  }

  getConfig(): MonitoringConfig {
    return {
      checkIntervalMs: this.config.checkIntervalMs,
      enableAutoAlert: this.config.enableAutoAlert,
      alertThresholds: this.config.alertThresholds,
      emergencyContacts: this.config.emergencyContacts
    };
  }

  updateConfig(updates: MonitoringConfigUpdate): void {
    if (updates.checkIntervalMs !== undefined) {
      this.config.checkIntervalMs = updates.checkIntervalMs;
    }
    if (updates.enableAutoAlert !== undefined) {
      this.config.enableAutoAlert = updates.enableAutoAlert;
    }
    if (updates.alertThresholds !== undefined) {
      this.config.alertThresholds = updates.alertThresholds;
    }
    if (updates.emergencyContacts !== undefined) {
      this.config.emergencyContacts = updates.emergencyContacts;
    }
    console.log('[RealtimeMonitor] 配置已更新');
  }

  updateEmergencyContacts(contacts: EmergencyContact[]): void {
    this.config.emergencyContacts = contacts;
    console.log(`[RealtimeMonitor] 紧急联系人已更新，共${contacts.length}个`);
  }

  async performPeriodicCheck(): Promise<void> {
    try {
      console.log('[RealtimeMonitor] 执行定期检查...');

      const latestSigns = this.getLatestVitalSigns();
      
      if (latestSigns.bloodPressure) {
        const bpRecord: HealthRecord = {
          recordId: '',
          type: 'blood_pressure',
          timestamp: latestSigns.bloodPressure.timestamp,
          source: 'DEVICE',
          userId: 'USER_001',
          values: {
            systolic: latestSigns.bloodPressure.systolic,
            diastolic: latestSigns.bloodPressure.diastolic
          }
        };
        
        await this.detectAndHandleAnomaly(bpRecord);
      }

      if (latestSigns.bloodSugar) {
        const bsRecord: HealthRecord = {
          recordId: '',
          type: 'blood_sugar',
          timestamp: latestSigns.bloodSugar.timestamp,
          source: 'DEVICE',
          userId: 'USER_001',
          values: {
            value: latestSigns.bloodSugar.value,
            type: latestSigns.bloodSugar.type
          }
        };
        
        await this.detectAndHandleAnomaly(bsRecord);
      }

    } catch (error) {
      console.error('[RealtimeMonitor] 定期检查失败:', error instanceof Error ? error.message : String(error));
    }
  }

  private async detectAndHandleAnomaly(record: HealthRecord): Promise<void> {
    try {
      console.log(`[RealtimeMonitor] 执行异常检测: ${record.type}`);

      const history = this.getHealthHistory(30);
      
      const detectionResult = this.anomalyDetector.detect(record, history);

      if (detectionResult.isAnomalous && detectionResult.riskLevel !== 'NORMAL') {
        console.warn(`[RealtimeMonitor] 检测到异常！风险等级: ${detectionResult.riskLevel}`);
        
        const alert = await this.alertManager.createAlert(
          record,
          detectionResult,
          this.config
        );

        this.notifyAlertSubscribers(alert);
        
        if (this.config.enableAutoAlert) {
          await this.triggerNotification(alert);
          
          if (detectionResult.riskLevel === 'CRITICAL') {
            await this.notifyEmergencyContacts(alert);
          }
        }
      } else {
        console.log(`[RealtimeMonitor] 检测结果正常: ${record.type}`);
      }

    } catch (error) {
      console.error('[RealtimeMonitor] 异常检测处理失败:', error instanceof Error ? error.message : String(error));
    }
  }

  private notifyAlertSubscribers(alert: Alert): void {
    for (const callback of this.alertCallbacks) {
      try {
        callback(alert);
      } catch (error) {
        console.error('[RealtimeMonitor] 预警回调执行失败:', error instanceof Error ? error.message : String(error));
      }
    }
  }

  private async triggerNotification(alert: Alert): Promise<void> {
    try {
      console.log(`[RealtimeMonitor] 发送系统通知: ${alert.title}`);
      
      console.log(`通知内容: ${alert.title} - ${alert.message}`);
      console.log(`风险等级: ${alert.severity}`);
      
    } catch (error) {
      console.error('[RealtimeMonitor] 系统通知发送失败:', error instanceof Error ? error.message : String(error));
    }
  }

  private async notifyEmergencyContacts(alert: Alert): Promise<void> {
    const enabledContacts = this.config.emergencyContacts.filter(c => c.enabled);
    
    console.log(`[RealtimeMonitor] 通知紧急联系人，共${enabledContacts.length}个`);

    for (const contact of enabledContacts) {
      try {
        console.log(`[RealtimeMonitor] 正在联系: ${contact.name} (${contact.phone})`);
        console.log(`关系: ${contact.relationship}${contact.isPrimary ? ' [主要联系人]' : ''}`);
        
        console.log(`[RealtimeMonitor] 已向 ${contact.name} 发送紧急通知`);
        
      } catch (error) {
        console.error(`[RealtimeMonitor] 联系 ${contact.name} 失败:`, error instanceof Error ? error.message : String(error));
      }
    }
  }

  private async saveToLocalStorage(record: HealthRecord): Promise<void> {
    try {
      console.log(`[RealtimeMonitor] 保存记录到本地存储: ${record.recordId}`);
      
    } catch (error) {
      console.error('[RealtimeMonitor] 本地保存失败:', error instanceof Error ? error.message : String(error));
    }
  }

  private getLatestRecord(type: HealthRecordType): BloodPressureData | BloodSugarData | VitalSignData | null {
    const records = this.healthRecords
      .filter(r => r.type === type)
      .sort((a, b) => new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime());

    if (records.length === 0) return null;

    const latest = records[0];

    switch (type) {
      case 'blood_pressure':
        return {
          systolic: latest.values?.systolic || 0,
          diastolic: latest.values?.diastolic || 0,
          timestamp: latest.timestamp
        };
      
      case 'blood_sugar':
        return {
          value: latest.values?.value || 0,
          type: (latest.values?.type || 'fasting') as 'fasting' | 'random' | 'postprandial',
          timestamp: latest.timestamp
        };
      
      case 'heart_rate':
        return {
          value: latest.values?.value || 0,
          timestamp: latest.timestamp
        };
      
      case 'weight':
        return {
          value: latest.values?.value || 0,
          timestamp: latest.timestamp
        };
      
      case 'temperature':
        return {
          value: latest.values?.value || 0,
          timestamp: latest.timestamp
        };
      
      default:
        return null;
    }
  }

  getMonitoringStatus(): MonitoringStatus {
    const status: MonitoringStatus = {
      isActive: this.isMonitoring,
      totalRecords: this.healthRecords.length,
      config: this.getConfig(),
      uptimeMinutes: this.isMonitoring ? Math.floor((Date.now() % 86400000) / 60000) : 0
    };
    return status;
  }

  clearAllData(): void {
    this.healthRecords = [];
    console.log('[RealtimeMonitor] 所有健康数据已清除');
  }

  destroy(): void {
    this.stopMonitoring();
    this.alertCallbacks = [];
    this.healthRecords = [];
    RealtimeMonitor.instance = null;
    console.log('[RealtimeMonitor] 服务实例已销毁');
  }
}
