import { VitalSignsSnapshot } from '../monitoring/RealtimeMonitor';
import { Alert, AnomalyDetectionResult, HealthRecordType, AlertSeverity } from '../monitoring/AnomalyDetector';
import { Reminder, ReminderTemplate } from '../monitoring/ReminderScheduler';

export class MonitoringMock {
  private static instance: MonitoringMock | null = null;

  private constructor() {}

  static getInstance(): MonitoringMock {
    if (!MonitoringMock.instance) {
      MonitoringMock.instance = new MonitoringMock();
    }
    return MonitoringMock.instance;
  }

  getSampleVitalSigns(): VitalSignsSnapshot {
    const now = new Date().toISOString();

    const bpData: BloodPressureData = { systolic: 142, diastolic: 88, timestamp: now };
    const bsData: BloodSugarData = { value: 6.8, type: 'fasting', timestamp: now };
    const hrData: VitalSignData = { value: 78, timestamp: now };
    const wtData: VitalSignData = { value: 68.5, timestamp: now };
    const tmpData: VitalSignData = { value: 36.8, timestamp: now };
    const oxyData: VitalSignData = { value: 98, timestamp: now };

    const snapshot: VitalSignsSnapshot = {
      bloodPressure: bpData,
      bloodSugar: bsData,
      heartRate: hrData,
      weight: wtData,
      temperature: tmpData,
      oxygenSaturation: oxyData,
      lastUpdateTime: now
    };
    return snapshot;
  }

  getNormalVitalSigns(): VitalSignsSnapshot {
    const now = new Date().toISOString();

    return {
      bloodPressure: {
        systolic: 118,
        diastolic: 76,
        timestamp: now
      },
      bloodSugar: {
        value: 5.4,
        type: 'fasting',
        timestamp: now
      },
      heartRate: {
        value: 72,
        timestamp: now
      },
      weight: {
        value: 65.0,
        timestamp: now
      },
      temperature: {
        value: 36.5,
        timestamp: now
      },
      oxygenSaturation: {
        value: 99,
        timestamp: now
      },
      lastUpdateTime: now
    };
  }

  getDangerVitalSigns(): VitalSignsSnapshot {
    const now = new Date().toISOString();

    return {
      bloodPressure: {
        systolic: 185,
        diastolic: 115,
        timestamp: now
      },
      bloodSugar: {
        value: 12.5,
        type: 'random',
        timestamp: now
      },
      heartRate: {
        value: 125,
        timestamp: now
      },
      weight: {
        value: 70.2,
        timestamp: now
      },
      temperature: {
        value: 39.8,
        timestamp: now
      },
      oxygenSaturation: {
        value: 92,
        timestamp: now
      },
      lastUpdateTime: now
    };
  }

  getSampleAlerts(): Alert[] {
    const now = new Date();

    const alerts: Alert[] = [
      {
        alertId: 'ALERT_001',
        recordId: 'REC_001',
        type: 'blood_pressure',
        severity: 'WARNING',
        title: '血压偏高预警',
        message: '您的收缩压达到142mmHg，舒张压88mmHg，略高于正常范围（120-139/80-89mmHg）。建议监测血压变化，必要时咨询医生。',
        timestamp: new Date(now.getTime() - 15 * 60 * 1000).toISOString(),
        isRead: false,
        isHandled: false,
        riskLevel: 'MEDIUM',
        detectionDetails: {
          isAnomalous: true,
          riskLevel: 'MEDIUM',
          confidence: 0.85,
          detectionStrategies: [],
          summary: '血压142/88mmHg，略高于正常范围',
          recommendations: ['建议监测血压变化', '必要时咨询医生']
        } as AnomalyDetectionResult
      },
      {
        alertId: 'ALERT_002',
        recordId: 'REC_002',
        type: 'blood_sugar',
        severity: 'INFO',
        title: '血糖轻微升高',
        message: '空腹血糖6.8mmol/L，处于正常高值范围。建议控制饮食，减少糖分摄入，定期监测。',
        timestamp: new Date(now.getTime() - 45 * 60 * 1000).toISOString(),
        isRead: true,
        isHandled: false,
        riskLevel: 'LOW',
        detectionDetails: {
          isAnomalous: true,
          riskLevel: 'LOW',
          confidence: 0.72,
          detectionStrategies: [],
          summary: '空腹血糖6.8mmol/L，处于正常高值范围',
          recommendations: ['控制饮食，减少糖分摄入', '定期监测']
        } as AnomalyDetectionResult
      },
      {
        alertId: 'ALERT_003',
        recordId: 'REC_003',
        type: 'heart_rate',
        severity: 'DANGER',
        title: '心率过速警告',
        message: '静息心率125bpm，明显高于正常范围（60-100bpm）。可能原因：运动后、情绪激动、咖啡因摄入等。如持续异常请及时就医。',
        timestamp: new Date(now.getTime() - 2 * 60 * 1000).toISOString(),
        isRead: false,
        isHandled: false,
        riskLevel: 'HIGH',
        detectionDetails: {
          isAnomalous: true,
          riskLevel: 'HIGH',
          confidence: 0.90,
          detectionStrategies: [],
          summary: '静息心率125bpm，明显高于正常范围',
          recommendations: ['如持续异常请及时就医', '注意休息']
        } as AnomalyDetectionResult
      }
    ];

    return alerts.sort((a, b) => 
      new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime()
    );
  }

  getCriticalAlerts(): Alert[] {
    const now = new Date();

    const criticalAlert: Alert = {
      alertId: 'ALERT_CRIT_001',
      recordId: 'REC_CRIT_001',
      type: 'blood_pressure',
      severity: 'CRITICAL',
      title: '⛔ 血压危急值警报',
      message: '检测到血压危急值：收缩压185mmHg，舒张压115mmHg！这可能提示高血压急症风险。请立即：\n\n1. 保持安静休息\n2. 立即测量确认\n3. 如持续高于180/120mmHg，请立即就医或拨打急救电话\n\n⚠️ 本系统仅为辅助工具，不能替代专业医疗诊断。',
      timestamp: new Date(now.getTime() - 3 * 60 * 1000).toISOString(),
      isRead: false,
      isHandled: false,
      riskLevel: 'CRITICAL',
      detectionDetails: {
        isAnomalous: true,
        riskLevel: 'CRITICAL',
        confidence: 0.98,
        detectionStrategies: [],
        summary: '血压危急值185/115mmHg',
        recommendations: ['保持安静休息', '立即测量确认', '如持续高于180/120请立即就医']
      } as AnomalyDetectionResult
    };

    return [criticalAlert];
  }

  getUpcomingReminders(): Reminder[] {
    const now = new Date();
    
    const reminders: Reminder[] = [
      {
        id: 'REM_001',
        title: '服用降压药（氨氯地平）',
        description: '每日一次，每次5mg，早餐后服用',
        type: 'MEDICATION',
        scheduledTime: new Date(now.getTime() + 30 * 60 * 1000).toISOString(),
        repeatPattern: 'DAILY',
        isActive: true,
        isCompleted: false,
        priority: 'HIGH',
        soundEnabled: true,
        vibrationEnabled: true,
        advanceNoticeMinutes: 5,
        createdAt: new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000).toISOString()
      },
      {
        id: 'REM_002',
        title: '测量血压',
        description: '记录收缩压和舒张压数值',
        type: 'MEASUREMENT',
        scheduledTime: new Date(now.getTime() + 55 * 60 * 1000).toISOString(),
        repeatPattern: 'DAILY',
        isActive: true,
        isCompleted: false,
        priority: 'MEDIUM',
        soundEnabled: true,
        vibrationEnabled: true,
        advanceNoticeMinutes: 10,
        createdAt: new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000).toISOString()
      },
      {
        id: 'REM_003',
        title: '下午运动时间',
        description: '建议进行30分钟中等强度有氧运动（散步、太极）',
        type: 'EXERCISE',
        scheduledTime: new Date(now.getTime() + 4 * 60 * 60 * 1000).toISOString(),
        repeatPattern: 'DAILY',
        isActive: true,
        isCompleted: false,
        priority: 'MEDIUM',
        soundEnabled: true,
        vibrationEnabled: false,
        advanceNoticeMinutes: 15,
        createdAt: new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000).toISOString()
      },
      {
        id: 'REM_004',
        title: '复诊预约提醒',
        description: '心内科门诊复诊，携带近期检查报告',
        type: 'APPOINTMENT',
        scheduledTime: new Date(now.getTime() + 3 * 24 * 60 * 60 * 1000).toISOString(),
        repeatPattern: 'ONCE',
        isActive: true,
        isCompleted: false,
        priority: 'HIGH',
        soundEnabled: true,
        vibrationEnabled: true,
        advanceNoticeMinutes: 60,
        createdAt: new Date(now.getTime() - 5 * 24 * 60 * 60 * 1000).toISOString()
      },
      {
        id: 'REM_005',
        title: '睡前血糖测量',
        description: '记录睡前血糖值，评估全天血糖控制情况',
        type: 'MEASUREMENT',
        scheduledTime: new Date(now.getTime() + 9 * 60 * 60 * 1000).toISOString(),
        repeatPattern: 'DAILY',
        isActive: true,
        isCompleted: false,
        priority: 'MEDIUM',
        soundEnabled: true,
        vibrationEnabled: false,
        advanceNoticeMinutes: 5,
        createdAt: new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000).toISOString()
      }
    ];

    return reminders.sort((a, b) => 
      new Date(a.scheduledTime).getTime() - new Date(b.scheduledTime).getTime()
    );
  }

  getCompletedReminders(): Reminder[] {
    const now = new Date();

    return [
      {
        id: 'REM_COMP_001',
        title: '早晨服药',
        description: '已按时服用降压药',
        type: 'MEDICATION',
        scheduledTime: new Date(now.getTime() - 8 * 60 * 60 * 1000).toISOString(),
        repeatPattern: 'DAILY',
        isActive: true,
        isCompleted: true,
        completedAt: new Date(now.getTime() - 8 * 60 * 60 * 1000 + 5 * 60 * 1000).toISOString(),
        priority: 'HIGH',
        soundEnabled: true,
        vibrationEnabled: true,
        advanceNoticeMinutes: 5,
        createdAt: new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000).toISOString()
      }
    ];
  }

  getReminderTemplates(): ReminderTemplate[] {
    return [
      {
        id: 'TPL_MED_001',
        name: '服药提醒',
        category: 'MEDICATION',
        defaultTitle: '该吃药了',
        defaultDescription: '请按时服用医生开具的药物',
        suggestedTimes: ['08:00', '12:00', '18:00', '22:00'],
        icon: '💊',
        color: '#1677FF'
      },
      {
        id: 'TPL_MEAS_001',
        name: '血压测量',
        category: 'MEASUREMENT',
        defaultTitle: '测量血压',
        defaultDescription: '请记录您的血压数据（收缩压/舒张压）',
        suggestedTimes: ['07:00', '19:00'],
        icon: '🩸',
        color: '#FF4D4F'
      },
      {
        id: 'TPL_MEAS_002',
        name: '血糖测量',
        category: 'MEASUREMENT',
        defaultTitle: '测量血糖',
        defaultDescription: '请记录您的血糖值',
        suggestedTimes: ['07:30', '11:30', '17:30', '21:00'],
        icon: '🍬',
        color: '#FAAD14'
      },
      {
        id: 'TPL_EXE_001',
        name: '运动提醒',
        category: 'EXERCISE',
        defaultTitle: '运动时间到了',
        defaultDescription: '建议进行30分钟中等强度运动',
        suggestedTimes: ['09:00', '16:00'],
        icon: '🏃',
        color: '#52C41A'
      },
      {
        id: 'TPL_APT_001',
        name: '复诊预约',
        category: 'APPOINTMENT',
        defaultTitle: '复诊预约',
        defaultDescription: '别忘了按时去医院复诊',
        suggestedTimes: [],
        icon: '🏥',
        color: '#722ED1'
      }
    ];
  }

  getVitalSignsHistory(days: number = 7): VitalSignsSnapshot[] {
    const history: VitalSignsSnapshot[] = [];
    const now = new Date();

    for (let i = days; i >= 0; i--) {
      const date = new Date(now.getTime() - i * 24 * 60 * 60 * 1000);
      
      const baseBP = 130 + Math.random() * 20 - 10;
      const baseBS = 5.5 + Math.random() * 1.5 - 0.75;
      const baseHR = 72 + Math.random() * 12 - 6;

      history.push({
        bloodPressure: {
          systolic: Math.round(baseBP),
          diastolic: Math.round(baseBP * 0.62),
          timestamp: date.toISOString()
        },
        bloodSugar: {
          value: parseFloat((baseBS).toFixed(1)),
          type: 'fasting',
          timestamp: date.toISOString()
        },
        heartRate: {
          value: Math.round(baseHR),
          timestamp: date.toISOString()
        },
        weight: {
          value: parseFloat((67 + Math.random() * 3 - 1.5).toFixed(1)),
          timestamp: date.toISOString()
        },
        temperature: {
          value: parseFloat((36.4 + Math.random() * 0.6 - 0.3).toFixed(1)),
          timestamp: date.toISOString()
        },
        oxygenSaturation: {
          value: Math.round(96 + Math.random() * 4),
          timestamp: date.toISOString()
        },
        lastUpdateTime: date.toISOString()
      });
    }

    return history;
  }

  generateRandomAlert(): Alert {
    const types = ['blood_pressure', 'blood_sugar', 'heart_rate', 'temperature'];
    const severities = ['INFO', 'WARNING', 'DANGER'];
    const titles = [
      '血压波动提醒',
      '血糖趋势异常',
      '心率不规律',
      '体温偏高',
      '指标正常恢复'
    ];
    
    const randomType = types[Math.floor(Math.random() * types.length)] as HealthRecordType;
    const randomSeverity = severities[Math.floor(Math.random() * severities.length)] as AlertSeverity;
    const randomTitle = titles[Math.floor(Math.random() * titles.length)];

    return {
      alertId: `ALERT_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
      recordId: `REC_${Date.now()}`,
      type: randomType,
      severity: randomSeverity,
      title: randomTitle,
      message: `系统检测到${randomTitle}，请注意观察并采取相应措施。`,
      timestamp: new Date().toISOString(),
      isRead: false,
      isHandled: false,
      riskLevel: randomSeverity === 'DANGER' ? 'HIGH' : 
                randomSeverity === 'WARNING' ? 'MEDIUM' : 'LOW',
      detectionDetails: {
        isAnomalous: false,
        riskLevel: randomSeverity === 'DANGER' ? 'HIGH' : 
                  randomSeverity === 'WARNING' ? 'MEDIUM' : 'LOW',
        confidence: 0.7,
        detectionStrategies: [],
        summary: `系统检测到${randomTitle}`,
        recommendations: []
      } as AnomalyDetectionResult
    };
  }
}

export const monitoringMock = MonitoringMock.getInstance();
