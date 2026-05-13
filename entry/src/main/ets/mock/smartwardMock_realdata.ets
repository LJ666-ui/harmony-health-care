/**
 * 智慧病房系统真实数据（基于数据库 ward_device, device_alert, automation_rule, care_plan 表）
 *
 * 数据来源: new_tables_part3_smart_ward.sql
 * 包含:
 *   - 8台真实IoT设备（301病房完整生态系统）
 *   - 6条设备告警记录（涵盖所有告警类型和级别）
 *   - 5条自动化规则（时间/条件/事件触发）
 *   - 2份护理计划（术后康复+慢性病管理）
 */

import { SmartWardRoom, WardPatientInfo, EnvironmentData, WardOverviewInfo } from '../models/SmartWardModels';
import { DeviceInfo, DeviceType, ExtendedDeviceInfo, DeviceStatusEnum, VitalSignData } from '../models/SmartWardDeviceModels';
import { AutomationRule, ExtendedAutomationRule, RuleActionItem, TriggerConditionData, ActionParamItem, ConditionItem, TimeWindow } from '../models/SmartWardAutomationModels';
import { WardAlert, VitalSignSnapshot, ExtendedWardAlert } from '../models/SmartWardAlertModels';
import { CareTask } from '../models/SmartWardTaskModels';
import { PatientRiskLevel, TaskStatus, AlertLevel, AlertCategory } from '../models/SmartWardEnums';

export interface CarePlanData {
  planId: string;
  patientId: string;
  patientName: string;
  planName: string;
  planType: string;
  wardNumber: string;
  bedNumber: string;
  acuityLevel: string;
  status: string;
  startTime: number;
  endTime: number | null;
  nurseName: string;
  doctorName: string | null;
  keyGoals: string[];
  mainInterventions: string[];
}

/**
 * 真实数据生成器类（基于数据库示例数据）
 */
export class RealDataGenerator {
  private static instance: RealDataGenerator;

  private constructor() {
    console.log('RealDataGenerator initialized with database data');
  }

  private createBrightnessParams(brightness: number): Record<string, number | string | boolean | string[]> {
    const params: Record<string, number | string | boolean | string[]> = {};
    params['brightness'] = brightness;
    return params;
  }

  private createModeParams(mode: string): Record<string, number | string | boolean | string[]> {
    const params: Record<string, number | string | boolean | string[]> = {};
    params['mode'] = mode;
    return params;
  }

  private createPowerParams(power: string): Record<string, number | string | boolean | string[]> {
    const params: Record<string, number | string | boolean | string[]> = {};
    params['power'] = power;
    return params;
  }

  private createNotificationParams(channels: string[], message: string): Record<string, number | string | boolean | string[]> {
    const params: Record<string, number | string | boolean | string[]> = {};
    params['channels'] = channels;
    params['message'] = message;
    return params;
  }

  private createAlertParams(level: string, channels: string[]): Record<string, number | string | boolean | string[]> {
    const params: Record<string, number | string | boolean | string[]> = {};
    params['level'] = level;
    params['channels'] = channels;
    return params;
  }

  private createCategoryParams(category: string): Record<string, number | string | boolean | string[]> {
    const params: Record<string, number | string | boolean | string[]> = {};
    params['category'] = category;
    return params;
  }

  private createPositionParams(position: string): Record<string, number | string | boolean | string[]> {
    const params: Record<string, number | string | boolean | string[]> = {};
    params['position'] = position;
    return params;
  }

  /**
   * 获取真实数据生成器单例实例
   */
  public static getInstance(): RealDataGenerator {
    if (!RealDataGenerator.instance) {
      RealDataGenerator.instance = new RealDataGenerator();
    }
    return RealDataGenerator.instance;
  }

  /**
   * 获取301病房完整数据（包含8台设备和患者信息）
   */
  public generateRoom301(): SmartWardRoom {
    return {
      roomId: 'ROOM_301',
      roomNumber: '301',
      bedId: 'BED_301_B1',
      patientInfo: this.getPatient201(),
      devices: this.generateDevices301(),
      environmentData: this.getEnvironment301(),
      lastUpdated: Date.now()
    };
  }

  /**
   * 获取患者张三(ID:201)的真实信息
   */
  public getPatient201(): WardPatientInfo {
    return {
      patientId: '201',
      name: '张三*',
      age: 65,
      gender: 'male',
      admissionDate: Date.now() - 2 * 24 * 3600 * 1000, // 2天前入院
      diagnosis: '左膝关节骨性关节炎(KL III级)',
      attendingDoctor: '王主任',
      nurseName: '李护士',
      riskLevel: PatientRiskLevel.HIGH,
      allergies: ['青霉素'],
      dietRequirement: '高蛋白饮食(鸡蛋、鱼肉、牛奶)，控制盐摄入(<6g/日)',
      emergencyContact: '138****8888(儿子)',
      notes: '膝关节置换术后第2天，疼痛VAS评分3分，DVT低风险'
    };
  }

  /**
   * 获取301病房8台真实IoT设备数据
   */
  public generateDevices301(): Map<string, ExtendedDeviceInfo> {
    const devices = new Map<string, ExtendedDeviceInfo>();

    // 1. 智能LED主灯
    devices.set('LIGHT-301-001', {
      deviceId: 'LIGHT-301-001',
      deviceName: '301病房主灯',
      deviceType: DeviceType.SMART_LIGHT,
      status: DeviceStatusEnum.ONLINE,
      isControllable: true,
      lastHeartbeat: Date.now() - 5000,
      properties: new Map([
        ['brightness', '80'],
        ['colorTemp', '4000'],
        ['colorMode', 'white'],
        ['sceneMode', 'reading']
      ]),
      capabilities: ['setBrightness', 'setColorTemp', 'setColor', 'toggle', 'setScene'],
      location: '天花板中央',
      manufacturer: '华为智选',
      model: 'HL-SmartLED-Pro V3',
      firmwareVersion: 'v2.1.5',
      networkType: 'WiFi',
      ipAddress: '192.168.1.101'
    });

    // 2. 智能窗帘
    devices.set('CURTAIN-301-001', {
      deviceId: 'CURTAIN-301-001',
      deviceName: '301病房智能窗帘',
      deviceType: DeviceType.SMART_CURTAIN,
      status: DeviceStatusEnum.ONLINE,
      isControllable: true,
      lastHeartbeat: Date.now() - 30000,
      properties: new Map([
        ['position', '70'],
        ['mode', 'partial'],
        ['direction', 'stop']
      ]),
      capabilities: ['open', 'close', 'stop', 'setPosition'],
      location: '病房南侧窗户',
      manufacturer: '绿米联创',
      model: 'HL-Curtain-Motor V2',
      firmwareVersion: 'v1.8.3',
      networkType: 'Zigbee'
    });

    // 3. 多参数监护仪（关联患者201）
    devices.set('MONITOR-301-B1', {
      deviceId: 'MONITOR-301-B1',
      deviceName: '床1多参数监护仪',
      deviceType: DeviceType.PATIENT_MONITOR,
      status: DeviceStatusEnum.ONLINE,
      isControllable: true,
      lastHeartbeat: Date.now() - 3000,
      patientId: '201',
      properties: new Map([
        ['heartRate', '78'],
        ['spo2', '97'],
        ['bloodPressure', '145/92'],
        ['respiratoryRate', '16'],
        ['temperature', '36.8']
      ]),
      vitalSigns: {
        heartRate: 78,
        spo2: 97,
        systolicBP: 145,
        diastolicBP: 92,
        respiratoryRate: 16,
        temperature: 36.8,
        timestamp: Date.now()
      },
      capabilities: ['getVitals', 'setAlarmLimits', 'startMonitoring', 'stopMonitoring', 'exportData'],
      location: '床1床头支架',
      manufacturer: '迈瑞医疗',
      model: 'HL-Monitor-Elite X1',
      firmwareVersion: 'v3.2.1',
      networkType: 'Ethernet',
      ipAddress: '192.168.1.103'
    });

    // 4. 智能输液泵
    devices.set('PUMP-301-B1', {
      deviceId: 'PUMP-301-B1',
      deviceName: '床1智能输液泵',
      deviceType: DeviceType.INFUSION_PUMP,
      status: DeviceStatusEnum.ONLINE,
      isControllable: true,
      lastHeartbeat: Date.now() - 2000,
      patientId: '201',
      properties: new Map([
        ['rate', '60'],
        ['volume', '500'],
        ['remainingVolume', '320'],
        ['drugName', '0.9%氯化钠注射液'],
        ['mode', 'volume']
      ]),
      capabilities: ['setRate', 'setVolume', 'start', 'stop', 'pause', 'setDrugInfo', 'clearAlarm'],
      location: '床1输液架',
      manufacturer: '科曼医疗',
      model: 'HL-Infusion-Smart V2',
      firmwareVersion: 'v2.0.8',
      networkType: 'WiFi',
      ipAddress: '192.168.1.104'
    });

    // 5. 电动护理床
    devices.set('BED-301-B1', {
      deviceId: 'BED-301-B1',
      deviceName: '床1电动护理床',
      deviceType: DeviceType.HOSPITAL_BED,
      status: DeviceStatusEnum.ONLINE,
      isControllable: true,
      lastHeartbeat: Date.now() - 10000,
      patientId: '201',
      properties: new Map([
        ['headAngle', '30'],
        ['footAngle', '15'],
        ['height', '45'],
        ['position', 'fowler'],
        ['backMassage', 'false'],
        ['sideRail', 'up']
      ]),
      capabilities: ['setHeadAngle', 'setFootAngle', 'setHeight', 'setPosition', 'toggleMassage', 'setSideRail', 'callNurse', 'emergencyStop'],
      location: '床1主体',
      manufacturer: '鱼跃医疗',
      model: 'HL-Bed-Electric Pro V4',
      firmwareVersion: 'v2.5.2',
      networkType: 'Zigbee'
    });

    // 6. 变频空调
    devices.set('AC-301-001', {
      deviceId: 'AC-301-001',
      deviceName: '301病房空调',
      deviceType: DeviceType.AIR_CONDITIONER,
      status: DeviceStatusEnum.ONLINE,
      isControllable: true,
      lastHeartbeat: Date.now() - 25000,
      properties: new Map([
        ['temperature', '24'],
        ['mode', 'cool'],
        ['fanSpeed', 'low'],
        ['swing', 'true'],
        ['ecoMode', 'false'],
        ['quietMode', 'true']
      ]),
      capabilities: ['setTemperature', 'setMode', 'setFanSpeed', 'toggleSwing', 'toggleEco', 'toggleQuiet', 'togglePower'],
      location: '病房墙上',
      manufacturer: '格力',
      model: 'HL-AC-Inverter Plus V2',
      firmwareVersion: 'v1.9.7',
      networkType: 'WiFi',
      ipAddress: '192.168.1.106'
    });

    // 7. 无线呼叫按钮
    devices.set('CALL-301-B1', {
      deviceId: 'CALL-301-B1',
      deviceName: '床1呼叫按钮',
      deviceType: DeviceType.CALL_BUTTON,
      status: DeviceStatusEnum.ONLINE,
      isControllable: true,
      lastHeartbeat: Date.now() - 15000,
      batteryLevel: 95,
      patientId: '201',
      properties: new Map([
        ['buttonType', 'nurse_call'],
        ['ledColor', 'green'],
        ['volume', '80'],
        ['vibration', 'true']
      ]),
      capabilities: ['press', 'cancel', 'setVolume', 'setLedColor', 'test'],
      location: '床1床头扶手',
      manufacturer: '华为智选',
      model: 'HL-CallButton-Wireless V1',
      firmwareVersion: 'v1.2.3',
      networkType: 'Bluetooth'
    });

    // 8. 智能电视
    devices.set('TV-301-001', {
      deviceId: 'TV-301-001',
      deviceName: '301病房智能电视',
      deviceType: DeviceType.SMART_TV,
      status: DeviceStatusEnum.ONLINE,
      isControllable: true,
      lastHeartbeat: Date.now() - 60000,
      properties: new Map([
        ['power', 'standby'],
        ['volume', '30'],
        ['channel', '1'],
        ['inputSource', 'hdmi1'],
        ['childLock', 'true']
      ]),
      capabilities: ['togglePower', 'setVolume', 'setChannel', 'setInput', 'setChildLock'],
      location: '床尾对面墙壁',
      manufacturer: '海信',
      model: 'HL-TV-Smart 55"',
      firmwareVersion: 'v2.3.1',
      networkType: 'WiFi',
      ipAddress: '192.168.1.107'
    });

    return devices;
  }

  /**
   * 获取301病房当前环境数据
   */
  public getEnvironment301(): EnvironmentData {
    return {
      temperature: 23.5,
      humidity: 55,
      lightLevel: 350,
      noiseLevel: 35,
      airQuality: 68,
      updatedAt: Date.now()
    };
  }

  /**
   * 获取6条真实告警记录（涵盖所有类型和状态）
   */
  public generateAlerts(): ExtendedWardAlert[] {
    const now = Date.now();

    return [
      // 告警1: 心率过高(CRITICAL) - 已解决
      {
        alertId: '1',
        deviceId: 'MONITOR-301-B1',
        deviceName: '床1多参数监护仪',
        category: AlertCategory.VITAL_SIGN,
        level: AlertLevel.CRITICAL,
        title: '心率过高报警',
        message: '患者张三(ID:201)心率异常升高至125 bpm，超过上限阈值(120 bpm)，持续时间超过3分钟。',
        timestamp: now - 15 * 60 * 1000, // 15分钟前
        status: 'RESOLVED',
        acknowledgedBy: '李护士',
        acknowledgedAt: now - 13 * 60 * 1000,
        resolvedAt: now - 7 * 60 * 1000,
        resolvedBy: '李护士',
        resolutionNote: '护士到场评估，患者因疼痛导致心率加快，已通知医生并给予镇痛处理'
      },

      // 告警2: 输液泵堵塞(WARNING) - 已解决
      {
        alertId: '2',
        deviceId: 'PUMP-301-B1',
        deviceName: '床1智能输液泵',
        category: AlertCategory.DEVICE_FAULT,
        level: AlertLevel.WARNING,
        title: '输液泵堵塞报警',
        message: '床1输液泵检测到管路堵塞，压力异常。当前输液速率已自动暂停。',
        timestamp: now - 10 * 60 * 1000, // 10分钟前
        status: 'RESOLVED',
        acknowledgedBy: '李护士',
        acknowledgedAt: now - 9 * 60 * 1000,
        resolvedAt: now - 5 * 60 * 1000,
        resolvedBy: '李护士',
        resolutionNote: '检查发现输液管路在床栏处被压折，重新整理管路后恢复正常'
      },

      // 告警3: 血氧过低(CRITICAL) - 处理中
      {
        alertId: '3',
        deviceId: 'MONITOR-301-B1',
        deviceName: '床1多参数监护仪',
        category: AlertCategory.VITAL_SIGN,
        level: AlertLevel.CRITICAL,
        title: '血氧饱和度过低报警',
        message: '患者张三血氧饱和度降至88%，低于下限阈值(90%)。可能存在缺氧风险！',
        timestamp: now - 3 * 60 * 1000, // 3分钟前
        status: 'IN_PROGRESS',
        acknowledgedBy: '李护士',
        acknowledgedAt: now - 2.5 * 60 * 1000,
        resolvedAt: null,
        resolvedBy: null,
        resolutionNote: null
      },

      // 告警4: 患者呼叫(INFO) - 已关闭
      {
        alertId: '4',
        deviceId: 'CALL-301-B1',
        deviceName: '床1呼叫按钮',
        category: AlertCategory.PATIENT_REQUEST,
        level: AlertLevel.INFO,
        title: '患者呼叫请求',
        message: '床1患者按下呼叫按钮，请求协助翻身。',
        timestamp: now - 5 * 60 * 1000, // 5分钟前
        status: 'CLOSED',
        acknowledgedBy: '李护士',
        acknowledgedAt: now - 4 * 60 * 1000,
        resolvedAt: now - 2 * 60 * 1000,
        resolvedBy: '李护士',
        resolutionNote: '护士到场协助患者翻身并调整舒适体位'
      },

      // 告警5: 灯光通信故障(WARNING) - 已确认待处理
      {
        alertId: '5',
        deviceId: 'LIGHT-301-001',
        deviceName: '301病房主灯',
        category: AlertCategory.NETWORK_ISSUE,
        level: AlertLevel.WARNING,
        title: '灯光设备通信不稳定',
        message: '301病房主灯最近5分钟内有3次心跳超时。可能是网络信号问题或设备硬件故障。',
        timestamp: now - 8 * 60 * 1000, // 8分钟前
        status: 'ACKNOWLEDGED',
        acknowledgedBy: null,
        acknowledgedAt: null,
        resolvedAt: null,
        resolvedBy: null,
        resolutionNote: null
      },

      // 告警6: 空调维护提醒(INFO) - 活跃
      {
        alertId: '6',
        deviceId: 'AC-301-001',
        deviceName: '301病房空调',
        category: AlertCategory.MAINTENANCE,
        level: AlertLevel.INFO,
        title: '空调滤网更换提醒',
        message: '301病房空调已连续运行720小时，需要清洗或更换滤网。建议在本周内安排维护。',
        timestamp: now, // 刚刚触发
        status: 'ACTIVE',
        acknowledgedBy: null,
        acknowledgedAt: null,
        resolvedAt: null,
        resolvedBy: null,
        resolutionNote: null
      }
    ];
  }

  /**
   * 获取5条真实自动化规则
   */
  public generateAutomationRules(): ExtendedAutomationRule[] {
    return [
      {
        ruleId: 'RULE_NIGHT_001',
        ruleName: '夜间安静模式(22:00-06:00)',
        description: '每晚22点自动将病房调整为夜间模式：灯光调暗、空调静音、窗帘关闭、电视待机',
        isEnabled: true,
        triggerType: 'TIME_BASED',
        triggerCondition: {
          timeWindow: { start: '22:00', end: '06:00' },
          timezone: 'Asia/Shanghai',
          repeat: ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun']
        },
        actions: [
          { action: 'setBrightness', params: this.createBrightnessParams(20) } as ActionParamItem,
          { action: 'setMode', params: this.createModeParams('night') } as ActionParamItem,
          { action: 'close' } as ActionParamItem,
          { action: 'togglePower', params: this.createPowerParams('standby') } as ActionParamItem
        ],
        priority: 'HIGH',
        targetDeviceIds: ['LIGHT-301-001', 'CURTAIN-301-001', 'AC-301-001', 'TV-301-001'],
        executionCount: 45,
        lastExecutionTime: Date.now() - 12 * 60 * 60 * 1000,
        cooldownSeconds: 3600
      },

      {
        ruleId: 'RULE_EMERGENCY_002',
        ruleName: '紧急呼叫响应',
        description: '当患者按下呼叫按钮时，自动调亮床头灯并打开房门指示灯引导护士快速定位',
        isEnabled: true,
        triggerType: 'DEVICE_EVENT',
        triggerCondition: {
          eventType: 'BUTTON_PRESS',
          deviceIdPattern: 'CALL-*',
          debounceMs: 30000
        },
        actions: [
          { action: 'setBrightness', params: this.createBrightnessParams(80) } as ActionParamItem,
          { action: 'sendNotification', params: this.createNotificationParams(['app_push', 'screen'], '患者呼叫请求') } as ActionParamItem
        ],
        priority: 'CRITICAL',
        targetDeviceIds: ['LIGHT-301-001', 'CALL-301-B1'],
        executionCount: 128,
        lastExecutionTime: Date.now() - 2 * 60 * 60 * 1000,
        cooldownSeconds: 30
      },

      {
        ruleId: 'RULE_ROUNDS_003',
        ruleName: '查房准备模式(08:45)',
        description: '每日上午08:45自动为查房做准备：打开窗帘、调整病床角度、调亮灯光、开启监护仪大字体显示',
        isEnabled: true,
        triggerType: 'TIME_BASED',
        triggerCondition: {
          time: '08:45',
          repeat: ['mon', 'tue', 'wed', 'thu', 'fri']
        },
        actions: [
          { action: 'open' } as ActionParamItem,
          { action: 'setPosition', params: this.createPositionParams('flat') } as ActionParamItem,
          { action: 'setBrightness', params: this.createBrightnessParams(70) } as ActionParamItem,
          { action: 'setDisplayMode', params: this.createModeParams('rounds') } as ActionParamItem
        ],
        priority: 'MEDIUM',
        targetDeviceIds: ['CURTAIN-301-001', 'BED-301-B1', 'LIGHT-301-001', 'MONITOR-301-B1'],
        executionCount: 18,
        lastExecutionTime: Date.now() - 18 * 60 * 60 * 1000,
        cooldownSeconds: 86400
      },

      {
        ruleId: 'RULE_VITALS_004',
        ruleName: '生命体征异常联动',
        description: '当监护仪监测到生命体征异常时，自动提高灯光亮度并发送多渠道告警通知',
        isEnabled: true,
        triggerType: 'CONDITION_BASED',
        triggerCondition: {
          conditions: [
            { metric: 'heart_rate', operator: '>', value: 120 },
            { metric: 'heart_rate', operator: '<', value: 50 },
            { metric: 'sp_o2', operator: '<', value: 90 }
          ],
          logic: 'OR',
          durationSeconds: 180
        },
        actions: [
          { action: 'setBrightness', params: this.createBrightnessParams(100) } as ActionParamItem,
          { action: 'sendAlert', params: this.createAlertParams('CRITICAL', ['app_push', 'sms', 'call', 'screen']) } as ActionParamItem,
          { action: 'logEvent', params: this.createCategoryParams('vital_signs_abnormal') } as ActionParamItem
        ],
        priority: 'CRITICAL',
        targetDeviceIds: ['LIGHT-301-001', 'MONITOR-301-B1'],
        executionCount: 56,
        lastExecutionTime: Date.now() - 30 * 60 * 1000,
        cooldownSeconds: 300
      },

      {
        ruleId: 'RULE_ENERGY_005',
        ruleName: '节能模式(无人在场)',
        description: '当病房连续30分钟无人活动且非治疗时段，自动关闭灯光、降低空调功率、关闭电视',
        isEnabled: true,
        triggerType: 'CONDITION_BASED',
        triggerCondition: {
          conditions: [
            { sensorType: 'motion', operator: '==', value: 'no_motion', durationMinutes: 30 },
            { timeRange: { start: '09:00', end: '17:00' } }
          ],
          logic: 'AND'
        },
        actions: [
          { action: 'togglePower', params: this.createPowerParams('off') } as ActionParamItem,
          { action: 'setMode', params: this.createModeParams('eco') } as ActionParamItem,
          { action: 'togglePower', params: this.createPowerParams('off') } as ActionParamItem
        ],
        priority: 'LOW',
        targetDeviceIds: ['LIGHT-301-001', 'AC-301-001', 'TV-301-001'],
        executionCount: 23,
        lastExecutionTime: Date.now() - 2 * 60 * 60 * 1000,
        cooldownSeconds: 1800
      }
    ];
  }

  /**
   * 获取2份真实护理计划
   */
  public generateCarePlans(): CarePlanData[] {
    return [
      {
        planId: '1',
        patientId: '201',
        patientName: '张三*',
        planName: '膝关节置换术后康复护理计划',
        planType: 'POST_OPERATIVE',
        wardNumber: '301',
        bedNumber: '床1',
        acuityLevel: 'HIGH',
        status: 'ACTIVE',
        startTime: Date.now() - 2 * 24 * 3600 * 1000, // 2天前开始
        endTime: Date.now() + 10 * 24 * 3600 * 1000,  // 预计10天后结束
        nurseName: '李护士',
        doctorName: '王主任',
        keyGoals: [
          '术后3天VAS评分<4分',
          '术后7天主动屈膝达90°',
          '术后14天独立完成ADL',
          '无DVT、感染等并发症'
        ],
        mainInterventions: [
          '疼痛评估与干预(Q4H)',
          '冰敷护理(Q2H)',
          'CPM机训练(BID)',
          '踝泵运动指导(TID)',
          '抗凝药物给药(QD)',
          'DVT风险评估(QD)'
        ]
      },
      {
        planId: '2',
        patientId: '202',
        patientName: '李四*',
        planName: '2型糖尿病综合管理护理计划',
        planType: 'CHRONIC_DISEASE',
        wardNumber: '302',
        bedNumber: '床2',
        acuityLevel: 'MODERATE',
        status: 'ACTIVE',
        startTime: Date.now() - 9 * 24 * 3600 * 1000, // 9天前开始
        endTime: null, // 长期计划
        nurseName: '赵护士',
        doctorName: '陈主任',
        keyGoals: [
          '糖化血红蛋白(HbA1c)<7.0%',
          '空腹血糖达标率>80%',
          '无严重低血糖事件',
          '体重下降5-10%',
          '掌握自我管理技能'
        ],
        mainInterventions: [
          '血糖监测技术指导',
          '饮食教育(QW)',
          '运动处方制定与监督',
          '低血糖识别与处理教育',
          '足部护理指导(QD)',
          '心理支持(BIW)'
        ]
      }
    ];
  }

  /**
   * 获取病房概览统计信息
   */
  public getWardOverview(): WardOverviewInfo {
    return {
      totalRooms: 10,
      occupiedRooms: 7,
      totalPatients: 7,
      criticalPatients: 2,
      activeAlerts: 6,
      onlineDevices: 48,
      offlineDevices: 2,
      avgEnvironmentScore: 85.5,
      lastUpdated: Date.now()
    };
  }
}
