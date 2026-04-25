/**
 * 预设联动规则配置
 * 定义7条预设联动规则
 */

import { AutomationRule } from '../../models/SmartWardAutomationModels';
import { RuleType, TriggerType, ActionType, AlertLevel, AlertCategory, DeviceType } from '../../models/SmartWardEnums';

/**
 * 预设联动规则列表
 */
export const presetRules: AutomationRule[] = [
  // 规则1: 心率异常联动
  {
    ruleId: 'RULE_001',
    ruleName: '心率异常联动',
    ruleType: RuleType.SAFETY,
    triggerCondition: {
      triggerType: TriggerType.VITAL_THRESHOLD,
      condition: {
        logic: 'OR',
        conditions: [
          {
            propertyKey: 'heartRate',
            operator: '>',
            value: 120
          },
          {
            propertyKey: 'heartRate',
            operator: '<',
            value: 50
          }
        ]
      },
      cooldownSeconds: 60
    },
    actions: [
      {
        actionType: ActionType.CONTROL_DEVICE,
        targetDeviceId: '',
        deviceType: DeviceType.SMART_LIGHT,
        command: 'setBrightness',
        params: { brightness: 100 },
        order: 1
      },
      {
        actionType: ActionType.SEND_ALERT,
        alertLevel: AlertLevel.EMERGENCY,
        alertType: AlertCategory.VITAL_SIGN_ANOMALY,
        message: '检测到心率异常，请立即处理！',
        order: 2
      },
      {
        actionType: ActionType.RECORD_DATA,
        params: { duration: 600 }, // 录制前后各5分钟
        order: 3
      },
      {
        actionType: ActionType.VOICE_BROADCAST,
        message: '检测到心率异常',
        order: 4
      }
    ],
    isEnabled: true,
    priority: 10,
    triggerCount: 0,
    description: '当心率>120或<50时触发，开灯100%、推送紧急警报、录制数据、语音播报'
  },

  // 规则2: 血氧饱和度下降联动
  {
    ruleId: 'RULE_002',
    ruleName: '血氧饱和度下降联动',
    ruleType: RuleType.SAFETY,
    triggerCondition: {
      triggerType: TriggerType.VITAL_THRESHOLD,
      condition: {
        logic: 'AND',
        conditions: [
          {
            propertyKey: 'oxygenSaturation',
            operator: '<',
            value: 92
          }
        ]
      },
      cooldownSeconds: 60
    },
    actions: [
      {
        actionType: ActionType.CONTROL_DEVICE,
        targetDeviceId: '',
        deviceType: DeviceType.SMART_LIGHT,
        command: 'setBrightness',
        params: { brightness: 60, colorTemp: 2700 },
        order: 1
      },
      {
        actionType: ActionType.SEND_ALERT,
        alertLevel: AlertLevel.URGENT,
        alertType: AlertCategory.VITAL_SIGN_ANOMALY,
        message: '血氧饱和度下降，请检查患者状况！',
        order: 2
      },
      {
        actionType: ActionType.VOICE_BROADCAST,
        message: '血氧饱和度下降，请调整体位',
        order: 3
      }
    ],
    isEnabled: true,
    priority: 9,
    triggerCount: 0,
    description: '当血氧<92%时触发，开柔和灯光、推送二级警报、语音提醒'
  },

  // 规则3: 呼叫按钮响应联动
  {
    ruleId: 'RULE_003',
    ruleName: '呼叫按钮响应联动',
    ruleType: RuleType.SAFETY,
    triggerCondition: {
      triggerType: TriggerType.DEVICE_STATE_CHANGE,
      condition: {
        logic: 'AND',
        conditions: [
          {
            propertyKey: 'isPressed',
            operator: '==',
            value: true
          }
        ]
      },
      cooldownSeconds: 120
    },
    actions: [
      {
        actionType: ActionType.SEND_ALERT,
        alertLevel: AlertLevel.WARNING,
        alertType: AlertCategory.CALL_REQUEST,
        message: '患者呼叫请求',
        order: 1
      },
      {
        actionType: ActionType.LIGHT_FLASH,
        targetDeviceId: '',
        params: { duration: 3000 },
        order: 2
      }
    ],
    isEnabled: true,
    priority: 8,
    triggerCount: 0,
    description: '呼叫按钮按下时触发，推送告警、床头灯闪烁'
  },

  // 规则4: 输液即将完毕联动
  {
    ruleId: 'RULE_004',
    ruleName: '输液即将完毕联动',
    ruleType: RuleType.SAFETY,
    triggerCondition: {
      triggerType: TriggerType.DEVICE_STATE_CHANGE,
      condition: {
        logic: 'AND',
        conditions: [
          {
            propertyKey: 'remainingVolume',
            operator: '<',
            value: 50
          }
        ]
      },
      cooldownSeconds: 300
    },
    actions: [
      {
        actionType: ActionType.SEND_ALERT,
        alertLevel: AlertLevel.INFO,
        alertType: AlertCategory.INFUSION_ALERT,
        message: '输液即将完毕，请准备换药',
        order: 1
      },
      {
        actionType: ActionType.LIGHT_FLASH,
        targetDeviceId: '',
        params: { duration: 2000 },
        order: 2
      }
    ],
    isEnabled: true,
    priority: 7,
    triggerCount: 0,
    description: '输液余量<50ml时触发，推送换药提醒、床头灯闪烁'
  },

  // 规则5: 就寝时间舒适联动
  {
    ruleId: 'RULE_005',
    ruleName: '就寝时间舒适联动',
    ruleType: RuleType.SCHEDULE,
    triggerCondition: {
      triggerType: TriggerType.SCHEDULE,
      condition: {
        logic: 'AND',
        conditions: []
      },
      time: '21:00',
      cooldownSeconds: 86400 // 每天1次
    },
    actions: [
      {
        actionType: ActionType.CONTROL_DEVICE,
        targetDeviceId: '',
        deviceType: DeviceType.SMART_LIGHT,
        command: 'setBrightness',
        params: { brightness: 20, colorTemp: 2700 },
        order: 1
      },
      {
        actionType: ActionType.CLOSE_CURTAIN,
        targetDeviceId: '',
        order: 2
      },
      {
        actionType: ActionType.MUTE_TV,
        targetDeviceId: '',
        order: 3
      }
    ],
    isEnabled: true,
    priority: 5,
    triggerCount: 0,
    description: '21:00触发，调暗灯光、关窗帘、电视静音'
  },

  // 规则6: 查房时间提醒联动
  {
    ruleId: 'RULE_006',
    ruleName: '查房时间提醒联动',
    ruleType: RuleType.SCHEDULE,
    triggerCondition: {
      triggerType: TriggerType.SCHEDULE,
      condition: {
        logic: 'AND',
        conditions: []
      },
      time: '08:50',
      cooldownSeconds: 86400 // 每天1次
    },
    actions: [
      {
        actionType: ActionType.CONTROL_DEVICE,
        targetDeviceId: '',
        deviceType: DeviceType.SMART_LIGHT,
        command: 'setBrightness',
        params: { brightness: 80, colorTemp: 5000 },
        order: 1
      },
      {
        actionType: ActionType.SEND_ALERT,
        alertLevel: AlertLevel.INFO,
        alertType: AlertCategory.SCHEDULE_REMINDER,
        message: '查房时间临近，请做好准备',
        order: 2
      }
    ],
    isEnabled: true,
    priority: 4,
    triggerCount: 0,
    description: '08:50触发，调亮灯光、推送查房提醒'
  },

  // 规则7: 用餐时间舒适联动
  {
    ruleId: 'RULE_007',
    ruleName: '用餐时间舒适联动',
    ruleType: RuleType.SCHEDULE,
    triggerCondition: {
      triggerType: TriggerType.SCHEDULE,
      condition: {
        logic: 'AND',
        conditions: []
      },
      time: '11:30',
      cooldownSeconds: 86400 // 每天1次
    },
    actions: [
      {
        actionType: ActionType.ADJUST_BED,
        targetDeviceId: '',
        params: { headAngle: 45 },
        order: 1
      },
      {
        actionType: ActionType.SEND_ALERT,
        alertLevel: AlertLevel.INFO,
        alertType: AlertCategory.SCHEDULE_REMINDER,
        message: '用餐时间已到',
        order: 2
      }
    ],
    isEnabled: true,
    priority: 3,
    triggerCount: 0,
    description: '11:30触发，床头调节至45°、推送用餐提醒'
  }
];
