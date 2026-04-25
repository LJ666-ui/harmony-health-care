/**
 * 智慧病房系统模拟数据生成器
 * 生成模拟的病房、设备、患者、护理任务数据
 */

import { SmartWardRoom, WardPatientInfo, EnvironmentData, WardOverviewInfo } from '../models/SmartWardModels';
import { DeviceInfo, DeviceStatus, DeviceType } from '../models/SmartWardDeviceModels';
import { AutomationRule } from '../models/SmartWardAutomationModels';
import { WardAlert, VitalSignSnapshot } from '../models/SmartWardAlertModels';
import { CareTask } from '../models/SmartWardTaskModels';
import { PatientRiskLevel, TaskStatus, AlertLevel, AlertCategory } from '../models/SmartWardEnums';
import { presetRules } from '../smartward/config/presetRules';

/**
 * 模拟数据生成器类
 */
export class MockDataGenerator {
  private static instance: MockDataGenerator;

  // 常见姓氏
  private surnames: string[] = ['张', '李', '王', '刘', '陈', '杨', '赵', '黄', '周', '吴'];

  // 常见名字
  private names: string[] = ['伟', '芳', '娜', '敏', '静', '强', '磊', '洋', '艳', '杰'];

  // 常见诊断
  private diagnoses: string[] = [
    '冠状动脉粥样硬化性心脏病',
    '高血压病',
    '2型糖尿病',
    '慢性阻塞性肺疾病',
    '脑梗死',
    '肺炎',
    '急性心肌梗死',
    '心力衰竭'
  ];

  private constructor() {
    console.log('MockDataGenerator initialized');
  }

  /**
   * 获取模拟数据生成器单例实例
   */
  public static getInstance(): MockDataGenerator {
    if (!MockDataGenerator.instance) {
      MockDataGenerator.instance = new MockDataGenerator();
    }
    return MockDataGenerator.instance;
  }

  /**
   * 生成指定数量的病房数据
   */
  public generateWardRooms(count: number): SmartWardRoom[] {
    const rooms: SmartWardRoom[] = [];

    for (let i = 0; i < count; i++) {
      const roomNumber = String(301 + i);
      const roomId = `ROOM_${roomNumber}`;

      const room: SmartWardRoom = {
        roomId: roomId,
        roomNumber: roomNumber,
        bedId: `BED_${roomNumber}_A`,
        patientInfo: this.generatePatientInfo(),
        devices: new Map(),
        environmentData: this.generateEnvironmentData(),
        lastUpdated: Date.now()
      };

      rooms.push(room);
    }

    console.log(`MockDataGenerator: Generated ${count} ward rooms`);
    return rooms;
  }

  /**
   * 生成患者信息
   */
  public generatePatientInfo(): WardPatientInfo {
    const surname = this.surnames[Math.floor(Math.random() * this.surnames.length)];
    const name = this.names[Math.floor(Math.random() * this.names.length)];
    const riskLevels = [PatientRiskLevel.LOW, PatientRiskLevel.MEDIUM, PatientRiskLevel.HIGH, PatientRiskLevel.CRITICAL];

    return {
      patientId: `P_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
      name: `${surname}${name}*`, // 脱敏显示
      age: Math.floor(Math.random() * 50) + 30, // 30-80岁
      gender: Math.random() > 0.5 ? 'male' : 'female',
      admissionDate: Date.now() - Math.random() * 7 * 24 * 3600 * 1000, // 过去7天内
      diagnosis: this.diagnoses[Math.floor(Math.random() * this.diagnoses.length)],
      attendingDoctor: '王主任',
      nurseName: '李护士',
      riskLevel: riskLevels[Math.floor(Math.random() * riskLevels.length)],
      allergies: Math.random() > 0.7 ? ['青霉素'] : [],
      dietRequirement: ['低盐低脂饮食', '糖尿病饮食', '普通饮食'][Math.floor(Math.random() * 3)],
      emergencyContact: '138****8888',
      notes: ''
    };
  }

  /**
   * 生成环境数据
   */
  public generateEnvironmentData(): EnvironmentData {
    return {
      temperature: Number((22 + Math.random() * 4).toFixed(1)), // 22-26℃
      humidity: Math.floor(50 + Math.random() * 20), // 50-70%
      lightLevel: Math.floor(200 + Math.random() * 300), // 200-500 lux
      noiseLevel: Math.floor(30 + Math.random() * 20), // 30-50 dB
      airQuality: Math.floor(50 + Math.random() * 50), // AQI 50-100
      updatedAt: Date.now()
    };
  }

  /**
   * 为病房生成设备
   */
  public generateDevices(roomId: string, roomNumber: string): DeviceInfo[] {
    const deviceTypes = [
      DeviceType.HOSPITAL_BED,
      DeviceType.PATIENT_MONITOR,
      DeviceType.SMART_LIGHT,
      DeviceType.SMART_CURTAIN,
      DeviceType.SMART_TV,
      DeviceType.AIR_CONDITIONER,
      DeviceType.CALL_BUTTON,
      DeviceType.INFUSION_PUMP
    ];

    const deviceNames = [
      '智能病床',
      '心电监护仪',
      '床头灯',
      '智能窗帘',
      '智能电视',
      '空调',
      '呼叫按钮',
      '输液泵'
    ];

    const devices: DeviceInfo[] = [];

    deviceTypes.forEach((type, index) => {
      const deviceId = `DEV_${roomNumber}_${index + 1}`;

      devices.push({
        deviceId: deviceId,
        deviceType: type,
        roomId: roomId,
        name: deviceNames[index],
        status: Math.random() > 0.9 ? 'offline' : 'online', // 10%概率离线
        lastUpdateTime: Date.now(),
        firmwareVersion: '1.0.0',
        manufacturer: '华为',
        model: 'HWS-001'
      });
    });

    console.log(`MockDataGenerator: Generated ${devices.length} devices for room ${roomNumber}`);
    return devices;
  }

  /**
   * 生成设备状态
   */
  public generateDeviceStatus(deviceInfo: DeviceInfo): DeviceStatus {
    const properties: Map<string, any> = new Map();

    switch (deviceInfo.deviceType) {
      case DeviceType.SMART_LIGHT:
        properties.set('brightness', { key: 'brightness', value: Math.floor(Math.random() * 100), unit: '%', min: 0, max: 100, readOnly: false, updatedAt: Date.now() });
        properties.set('colorTemp', { key: 'colorTemp', value: Math.floor(2700 + Math.random() * 3800), unit: 'K', min: 2700, max: 6500, readOnly: false, updatedAt: Date.now() });
        properties.set('isOn', { key: 'isOn', value: Math.random() > 0.3, readOnly: false, updatedAt: Date.now() });
        break;

      case DeviceType.HOSPITAL_BED:
        properties.set('headAngle', { key: 'headAngle', value: Math.floor(Math.random() * 45), unit: '度', min: 0, max: 90, readOnly: false, updatedAt: Date.now() });
        properties.set('footAngle', { key: 'footAngle', value: Math.floor(Math.random() * 15), unit: '度', min: 0, max: 45, readOnly: false, updatedAt: Date.now() });
        properties.set('isCalling', { key: 'isCalling', value: false, readOnly: false, updatedAt: Date.now() });
        break;

      case DeviceType.PATIENT_MONITOR:
        properties.set('heartRate', { key: 'heartRate', value: Math.floor(70 + Math.random() * 30), unit: 'bpm', min: 40, max: 150, readOnly: true, updatedAt: Date.now() });
        properties.set('oxygenSaturation', { key: 'oxygenSaturation', value: Math.floor(95 + Math.random() * 5), unit: '%', min: 70, max: 100, readOnly: true, updatedAt: Date.now() });
        properties.set('systolicBP', { key: 'systolicBP', value: Math.floor(110 + Math.random() * 30), unit: 'mmHg', min: 70, max: 180, readOnly: true, updatedAt: Date.now() });
        properties.set('diastolicBP', { key: 'diastolicBP', value: Math.floor(70 + Math.random() * 20), unit: 'mmHg', min: 40, max: 120, readOnly: true, updatedAt: Date.now() });
        break;

      case DeviceType.SMART_CURTAIN:
        properties.set('openPercentage', { key: 'openPercentage', value: Math.floor(Math.random() * 100), unit: '%', min: 0, max: 100, readOnly: false, updatedAt: Date.now() });
        break;

      case DeviceType.SMART_TV:
        properties.set('volume', { key: 'volume', value: Math.floor(Math.random() * 50), unit: '%', min: 0, max: 100, readOnly: false, updatedAt: Date.now() });
        properties.set('isOn', { key: 'isOn', value: Math.random() > 0.5, readOnly: false, updatedAt: Date.now() });
        break;

      case DeviceType.AIR_CONDITIONER:
        properties.set('temperature', { key: 'temperature', value: Math.floor(22 + Math.random() * 4), unit: '℃', min: 16, max: 30, readOnly: false, updatedAt: Date.now() });
        properties.set('mode', { key: 'mode', value: 'cool', readOnly: false, updatedAt: Date.now() });
        break;

      case DeviceType.CALL_BUTTON:
        properties.set('isPressed', { key: 'isPressed', value: false, readOnly: false, updatedAt: Date.now() });
        break;

      case DeviceType.INFUSION_PUMP:
        properties.set('flowRate', { key: 'flowRate', value: Math.floor(40 + Math.random() * 60), unit: 'ml/h', min: 0, max: 200, readOnly: false, updatedAt: Date.now() });
        properties.set('remainingVolume', { key: 'remainingVolume', value: Math.floor(Math.random() * 500), unit: 'ml', min: 0, max: 500, readOnly: true, updatedAt: Date.now() });
        break;
    }

    return {
      deviceId: deviceInfo.deviceId,
      deviceType: deviceInfo.deviceType,
      deviceName: deviceInfo.name,
      isOnline: deviceInfo.status === 'online',
      batteryLevel: Math.floor(80 + Math.random() * 20),
      properties: properties,
      lastHeartbeat: Date.now(),
      firmwareVersion: deviceInfo.firmwareVersion
    };
  }

  /**
   * 生成告警数据
   */
  public generateAlerts(count: number, roomIds: string[]): WardAlert[] {
    const alerts: WardAlert[] = [];
    const alertLevels = [AlertLevel.EMERGENCY, AlertLevel.URGENT, AlertLevel.WARNING, AlertLevel.INFO];
    const alertCategories = [
      AlertCategory.VITAL_SIGN_ANOMALY,
      AlertCategory.DEVICE_MALFUNCTION,
      AlertCategory.CALL_REQUEST,
      AlertCategory.INFUSION_ALERT,
      AlertCategory.SCHEDULE_REMINDER
    ];

    const messages = [
      '心率异常，请立即处理',
      '血氧饱和度下降',
      '患者呼叫请求',
      '输液即将完毕',
      '查房时间提醒',
      '设备离线',
      '血压异常'
    ];

    for (let i = 0; i < count; i++) {
      const roomId = roomIds[Math.floor(Math.random() * roomIds.length)];
      const roomNumber = roomId.replace('ROOM_', '');

      const alert: WardAlert = {
        alertId: `ALERT_${Date.now()}_${i}`,
        level: alertLevels[Math.floor(Math.random() * alertLevels.length)],
        category: alertCategories[Math.floor(Math.random() * alertCategories.length)],
        message: messages[Math.floor(Math.random() * messages.length)],
        roomId: roomId,
        roomNumber: roomNumber,
        sourceDeviceId: `DEV_${roomNumber}_${Math.floor(Math.random() * 8) + 1}`,
        triggeredAt: Date.now() - Math.random() * 24 * 3600 * 1000, // 过去24小时内
        isAcknowledged: Math.random() > 0.3, // 70%已确认
        isResolved: Math.random() > 0.5
      };

      alerts.push(alert);
    }

    console.log(`MockDataGenerator: Generated ${count} alerts`);
    return alerts;
  }

  /**
   * 生成护理任务
   */
  public generateCareTasks(count: number, roomIds: string[]): CareTask[] {
    const tasks: CareTask[] = [];
    const taskNames = [
      '测量血压',
      '测量体温',
      '输液更换',
      '协助翻身',
      '晨间护理',
      '晚间护理',
      '给药',
      '查房'
    ];
    const taskTypes = ['VITAL_SIGNS', 'MEDICATION', 'CARE', 'ROUND'];
    const frequencies = ['q4h', 'q6h', 'q8h', 'qd', 'prn'];
    const taskStatuses = [TaskStatus.PENDING, TaskStatus.IN_PROGRESS, TaskStatus.COMPLETED];

    for (let i = 0; i < count; i++) {
      const roomId = roomIds[Math.floor(Math.random() * roomIds.length)];
      const roomNumber = roomId.replace('ROOM_', '');

      const task: CareTask = {
        taskId: `TASK_${Date.now()}_${i}`,
        taskName: taskNames[Math.floor(Math.random() * taskNames.length)],
        taskType: taskTypes[Math.floor(Math.random() * taskTypes.length)],
        scheduledTime: Date.now() + Math.floor(Math.random() * 4) * 3600 * 1000, // 未来4小时内
        frequency: frequencies[Math.floor(Math.random() * frequencies.length)],
        assignedNurse: ['李护士', '王护士', '张护士'][Math.floor(Math.random() * 3)],
        roomId: roomId,
        roomNumber: roomNumber,
        patientId: `P_${roomNumber}_001`,
        patientName: `${this.surnames[Math.floor(Math.random() * this.surnames.length)]}**`,
        status: taskStatuses[Math.floor(Math.random() * taskStatuses.length)],
        isRecurring: Math.random() > 0.5,
        priority: Math.floor(Math.random() * 10) + 1
      };

      tasks.push(task);
    }

    console.log(`MockDataGenerator: Generated ${count} care tasks`);
    return tasks;
  }

  /**
   * 获取预设规则
   */
  public getPresetRules(): AutomationRule[] {
    return presetRules;
  }

  /**
   * 生成病房概览信息
   */
  public generateWardOverview(rooms: SmartWardRoom[]): WardOverviewInfo[] {
    return rooms.map(room => {
      const monitorStatus = room.devices.get(`DEV_${room.roomNumber}_2`);
      const heartRate = monitorStatus?.properties.get('heartRate')?.value as number || 75;
      const oxygenSaturation = monitorStatus?.properties.get('oxygenSaturation')?.value as number || 98;
      const systolicBP = monitorStatus?.properties.get('systolicBP')?.value as number || 120;
      const diastolicBP = monitorStatus?.properties.get('diastolicBP')?.value as number || 80;

      const onlineDevices = Array.from(room.devices.values()).filter(d => d.isOnline).length;

      return {
        roomId: room.roomId,
        roomNumber: room.roomNumber,
        bedId: room.bedId,
        patientName: room.patientInfo.name,
        patientAge: room.patientInfo.age,
        patientGender: room.patientInfo.gender,
        riskLevel: room.patientInfo.riskLevel,
        vitalSigns: {
          heartRate,
          oxygenSaturation,
          systolicBP,
          diastolicBP
        },
        deviceOnlineCount: onlineDevices,
        deviceTotalCount: room.devices.size
      };
    });
  }
}
