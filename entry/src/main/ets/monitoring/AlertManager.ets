import { HealthRecord, AnomalyDetectionResult, Alert, HealthRecordType, AlertSeverity, RiskLevelType } from './AnomalyDetector';
import { MonitoringConfig } from './RealtimeMonitor';

export interface AlertRule {
  id: string;
  name: string;
  description: string;
  enabled: boolean;
  conditions: AlertCondition[];
  action: AlertAction;
}

export interface AlertCondition {
  type: 'threshold' | 'deviation' | 'trend' | 'combination';
  metric: string;
  operator: '>' | '<' | '>=' | '<=' | '==' | '!=';
  value: number;
  unit?: string;
}

export interface AlertAction {
  notifyUser: boolean;
  notifyEmergencyContacts: boolean;
  soundAlert: boolean;
  vibration: boolean;
  autoCallDoctor: boolean;
  delayMinutes: number;
}

export interface SeverityInfo {
  severity: AlertSeverity;
  color: string;
  icon: string;
  description: string;
}

export interface AlertStatistics {
  total: number;
  unread: number;
  active: number;
  bySeverity: Record<string, number>;
  byType: Record<string, number>;
  todayCount: number;
  criticalCount: number;
}

export class AlertManager {
  private static instance: AlertManager | null = null;

  private alerts: Alert[] = [];
  private alertRules: AlertRule[] = [];
  private alertHistory: Alert[] = [];

  private static readonly SEVERITY_MAP: Record<string, SeverityInfo> = {
    'NORMAL': { severity: 'INFO', color: '#52C41A', icon: '✅', description: '正常' },
    'LOW': { severity: 'INFO', color: '#1890FF', icon: 'ℹ️', description: '轻微异常' },
    'MEDIUM': { severity: 'WARNING', color: '#FAAD14', icon: '⚠️', description: '中等风险' },
    'HIGH': { severity: 'DANGER', color: '#FF4D4F', icon: '🔴', description: '高风险' },
    'CRITICAL': { severity: 'CRITICAL', color: '#CF1322', icon: '⛔', description: '极高风险' }
  };

  private constructor() {
    console.log('[AlertManager] 初始化预警管理器');
    this.initializeDefaultRules();
  }

  static getInstance(): AlertManager {
    if (!AlertManager.instance) {
      AlertManager.instance = new AlertManager();
    }
    return AlertManager.instance;
  }

  async createAlert(
    record: HealthRecord,
    detectionResult: AnomalyDetectionResult,
    config: MonitoringConfig
  ): Promise<Alert> {
    
    const alertId = `ALERT_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    
    const severityInfo = AlertManager.SEVERITY_MAP[detectionResult.riskLevel] || 
                         AlertManager.SEVERITY_MAP['NORMAL'];

    const alert: Alert = {
      alertId: alertId,
      recordId: record.recordId || '',
      type: record.type,
      severity: severityInfo.severity as AlertSeverity,
      title: this.generateAlertTitle(record.type, detectionResult.riskLevel),
      message: this.generateAlertMessage(record, detectionResult),
      timestamp: new Date().toISOString(),
      isRead: false,
      isHandled: false,
      riskLevel: detectionResult.riskLevel,
      detectionDetails: detectionResult
    };

    this.alerts.push(alert);
    this.alertHistory.push(alert);

    await this.persistAlert(alert);

    console.log(`[AlertManager] 创建预警: ${alert.title} (${alert.severity})`);

    return alert;
  }

  getActiveAlerts(): Alert[] {
    return this.alerts.filter(a => !a.isHandled)
                      .sort((a, b) => new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime());
  }

  getUnreadAlertCount(): number {
    return this.alerts.filter(a => !a.isRead && !a.isHandled).length;
  }

  markAsRead(alertId: string): void {
    const alert = this.alerts.find(a => a.alertId === alertId);
    if (alert) {
      alert.isRead = true;
      console.log(`[AlertManager] 预警已标记为已读: ${alertId}`);
    }
  }

  markAllAsRead(): void {
    for (const alert of this.alerts) {
      alert.isRead = true;
    }
    console.log('[AlertManager] 所有预警已标记为已读');
  }

  handleAlert(alertId: string, notes?: string): void {
    const alert = this.alerts.find(a => a.alertId === alertId);
    if (alert) {
      alert.isHandled = true;
      alert.handlingNotes = notes || '';
      
      console.log(`[AlertManager] 预警已处理: ${alertId}`);
      console.log(`  处理备注: ${notes || '无'}`);
    }
  }

  dismissAlert(alertId: string): void {
    const index = this.alerts.findIndex(a => a.alertId === alertId);
    if (index > -1) {
      this.alerts.splice(index, 1);
      console.log(`[AlertManager] 预警已关闭: ${alertId}`);
    }
  }

  getAlertHistory(days: number = 30): Alert[] {
    const cutoffDate = new Date(Date.now() - days * 24 * 60 * 60 * 1000);
    
    return this.alertHistory
      .filter(a => new Date(a.timestamp) >= cutoffDate)
      .sort((a, b) => new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime());
  }

  getAlertStatistics(): AlertStatistics {
    const now = new Date();
    const todayStart = new Date(now.getFullYear(), now.getMonth(), now.getDate());

    return {
      total: this.alertHistory.length,
      unread: this.getUnreadAlertCount(),
      active: this.getActiveAlerts().length,
      bySeverity: this.groupBySeverity(),
      byType: this.groupByType(),
      todayCount: this.alertHistory.filter(a => new Date(a.timestamp) >= todayStart).length,
      criticalCount: this.alertHistory.filter(a => a.riskLevel === 'CRITICAL').length
    };
  }

  addCustomRule(rule: AlertRule): void {
    rule.id = `RULE_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    this.alertRules.push(rule);
    console.log(`[AlertManager] 添加自定义规则: ${rule.name}`);
  }

  removeCustomRule(ruleId: string): void {
    const index = this.alertRules.findIndex(r => r.id === ruleId);
    if (index > -1) {
      this.alertRules.splice(index, 1);
      console.log(`[AlertManager] 删除规则: ${ruleId}`);
    }
  }

  toggleRule(ruleId: string, enabled: boolean): void {
    const rule = this.alertRules.find(r => r.id === ruleId);
    if (rule) {
      rule.enabled = enabled;
      console.log(`[AlertManager] 规则${rule.name} 已${enabled ? '启用' : '禁用'}`);
    }
  }

  getAlertRules(): AlertRule[] {
    const result: AlertRule[] = [];
    for (let i = 0; i < this.alertRules.length; i++) {
      result.push(this.alertRules[i]);
    }
    return result;
  }

  shouldTriggerAlert(
    record: HealthRecord,
    detectionResult: AnomalyDetectionResult
  ): boolean {
    if (detectionResult.riskLevel === 'NORMAL') {
      return false;
    }

    for (const rule of this.alertRules.filter(r => r.enabled)) {
      if (this.evaluateRule(rule, record, detectionResult)) {
        console.log(`[AlertManager] 触发规则: ${rule.name}`);
        return true;
      }
    }

    return detectionResult.riskLevel === 'CRITICAL' || 
           detectionResult.riskLevel === 'HIGH';
  }

  clearAllAlerts(): void {
    this.alerts = [];
    console.log('[AlertManager] 所有活跃预警已清除');
  }

  clearHistory(): void {
    this.alertHistory = [];
    console.log('[AlertManager] 预警历史已清除');
  }

  private initializeDefaultRules(): void {
    this.alertRules = [
      {
        id: 'RULE_DEFAULT_001',
        name: '血压危险阈值',
        description: '收缩压>180或<90，或舒张压>110或<60时触发',
        enabled: true,
        conditions: [
          { type: 'threshold', metric: 'blood_pressure_systolic', operator: '>', value: 180, unit: 'mmHg' },
          { type: 'threshold', metric: 'blood_pressure_systolic', operator: '<', value: 90, unit: 'mmHg' },
          { type: 'threshold', metric: 'blood_pressure_diastolic', operator: '>', value: 110, unit: 'mmHg' },
          { type: 'threshold', metric: 'blood_pressure_diastolic', operator: '<', value: 60, unit: 'mmHg' }
        ],
        action: {
          notifyUser: true,
          notifyEmergencyContacts: true,
          soundAlert: true,
          vibration: true,
          autoCallDoctor: false,
          delayMinutes: 0
        }
      },
      {
        id: 'RULE_DEFAULT_002',
        name: '血糖危险值',
        description: '空腹血糖>11或<3.9时触发',
        enabled: true,
        conditions: [
          { type: 'threshold', metric: 'blood_sugar_fasting', operator: '>', value: 11.0, unit: 'mmol/L' },
          { type: 'threshold', metric: 'blood_sugar_fasting', operator: '<', value: 3.9, unit: 'mmol/L' }
        ],
        action: {
          notifyUser: true,
          notifyEmergencyContacts: false,
          soundAlert: true,
          vibration: true,
          autoCallDoctor: false,
          delayMinutes: 0
        }
      },
      {
        id: 'RULE_DEFAULT_003',
        name: '心率异常',
        description: '静息心率>120或<50时触发',
        enabled: true,
        conditions: [
          { type: 'threshold', metric: 'heart_rate', operator: '>', value: 120, unit: 'bpm' },
          { type: 'threshold', metric: 'heart_rate', operator: '<', value: 50, unit: 'bpm' }
        ],
        action: {
          notifyUser: true,
          notifyEmergencyContacts: true,
          soundAlert: true,
          vibration: true,
          autoCallDoctor: false,
          delayMinutes: 0
        }
      },
      {
        id: 'RULE_DEFAULT_004',
        name: '趋势恶化警告',
        description: '连续3次测量呈恶化趋势时触发',
        enabled: true,
        conditions: [
          { type: 'trend', metric: 'any', operator: '==', value: 3 }
        ],
        action: {
          notifyUser: true,
          notifyEmergencyContacts: false,
          soundAlert: false,
          vibration: true,
          autoCallDoctor: false,
          delayMinutes: 5
        }
      }
    ];

    console.log(`[AlertManager] 初始化${this.alertRules.length}条默认预警规则`);
  }

  private generateAlertTitle(type: HealthRecordType, riskLevel: string): string {
    const typeLabels: Record<string, string> = {
      'blood_pressure': '血压异常',
      'blood_sugar': '血糖异常',
      'heart_rate': '心率异常',
      'weight': '体重变化',
      'temperature': '体温异常'
    };

    const levelPrefixes: Record<string, string> = {
      'LOW': '⚡',
      'MEDIUM': '⚠️',
      'HIGH': '🔴',
      'CRITICAL': '⛔'
    };

    const prefix = levelPrefixes[riskLevel] || '';
    const label = typeLabels[type] || '健康数据异常';

    return `${prefix} ${label}`;
  }

  private generateAlertMessage(
    record: HealthRecord,
    detectionResult: AnomalyDetectionResult
  ): string {
    let message = '';

    switch (record.type) {
      case 'blood_pressure':
        message = `血压：${record.values?.systolic || '-'}/${record.values?.diastolic || '-'} mmHg`;
        break;
      case 'blood_sugar':
        message = `血糖：${record.values?.value?.toFixed(1) || '-'} mmol/L`;
        break;
      case 'heart_rate':
        message = `心率：${record.values?.value || '-'} bpm`;
        break;
      case 'weight':
        message = `体重：${record.values?.value || '-'} kg`;
        break;
      case 'temperature':
        message = `体温：${record.values?.value?.toFixed(1) || '-'} °C`;
        break;
      default:
        message = '检测到异常健康数据';
    }

    message += `\n\n检测结果：${detectionResult.summary}`;

    if (detectionResult.recommendations.length > 0) {
      message += '\n\n建议措施：\n';
      detectionResult.recommendations.slice(0, 3).forEach((rec, idx) => {
        message += `${idx + 1}. ${rec}\n`;
      });
    }

    return message.trim();
  }

  private async persistAlert(alert: Alert): Promise<void> {
    try {
      console.log(`[AlertManager] 持久化预警记录: ${alert.alertId}`);
    } catch (error) {
      console.error('[AlertManager] 预警持久化失败:', error instanceof Error ? error.message : String(error));
    }
  }

  private evaluateRule(
    rule: AlertRule,
    record: HealthRecord,
    detectionResult: AnomalyDetectionResult
  ): boolean {
    for (const condition of rule.conditions) {
      let currentValue: number = 0;

      switch (condition.metric) {
        case 'blood_pressure_systolic':
          currentValue = record.values?.systolic || 0;
          break;
        case 'blood_pressure_diastolic':
          currentValue = record.values?.diastolic || 0;
          break;
        case 'blood_sugar_fasting':
          currentValue = record.values?.value || 0;
          break;
        case 'heart_rate':
          currentValue = record.values?.value || 0;
          break;
        default:
          continue;
      }

      if (this.compareValues(currentValue, condition.operator, condition.value)) {
        return true;
      }
    }

    return false;
  }

  private compareValues(actual: number, operator: string, expected: number): boolean {
    switch (operator) {
      case '>': return actual > expected;
      case '<': return actual < expected;
      case '>=': return actual >= expected;
      case '<=': return actual <= expected;
      case '==': return actual === expected;
      case '!=': return actual !== expected;
      default: return false;
    }
  }

  private groupBySeverity(): Record<string, number> {
    const groups: Record<string, number> = {};
    
    for (const alert of this.alerts) {
      groups[alert.severity] = (groups[alert.severity] || 0) + 1;
    }

    return groups;
  }

  private groupByType(): Record<string, number> {
    const groups: Record<string, number> = {};

    for (const alert of this.alerts) {
      groups[alert.type] = (groups[alert.type] || 0) + 1;
    }

    return groups;
  }

  destroy(): void {
    this.clearAllAlerts();
    this.clearHistory();
    this.alertRules = [];
    AlertManager.instance = null;
    console.log('[AlertManager] 预警管理器实例已销毁');
  }
}
