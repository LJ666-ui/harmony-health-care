/**
 * 智慧病房自动化规则相关接口定义
 * 包含自动化规则、触发条件、规则动作等接口
 */

import { RuleType, TriggerType, ActionType, AlertLevel, DeviceType } from './SmartWardEnums';

/**
 * 规则条件接口
 * 描述单个触发条件
 */
export interface RuleCondition {
  propertyKey: string;                 // 属性键名（如 "heartRate"、"bloodOxygen"）
  operator: '>' | '<' | '>=' | '<=' | '==' | '!=' | 'between';  // 比较操作符
  value: number | string | boolean;    // 比较值
  value2?: number;                     // 第二个比较值（用于between操作符）
}

/**
 * 条件组接口
 * 描述一组条件及其逻辑关系
 */
export interface ConditionGroup {
  logic: 'AND' | 'OR';                 // 逻辑关系
  conditions: RuleCondition[];         // 条件列表
}

/**
 * 触发条件接口
 * 描述规则的触发条件
 */
export interface TriggerCondition {
  triggerType: TriggerType;            // 触发类型
  deviceId?: string;                   // 触发设备ID
  condition: ConditionGroup;           // 条件组
  cooldownSeconds?: number;            // 冷却时间（秒），防止重复触发
  time?: string;                       // 触发时间（格式："HH:mm"）
}

/**
 * 规则动作接口
 * 描述规则触发后执行的动作
 */
export interface RuleAction {
  actionType: ActionType;              // 动作类型
  targetDeviceId?: string;             // 目标设备ID
  deviceType?: DeviceType;             // 目标设备类型
  command?: string;                    // 设备命令
  params?: Record<string, any>;        // 动作参数
  alertLevel?: AlertLevel;             // 告警等级
  alertType?: string;                  // 告警类型
  message?: string;                    // 告警消息
  delayMs?: number;                    // 延迟执行时间（毫秒）
  order: number;                       // 执行顺序
}

/**
 * 自动化规则接口
 * 描述完整的自动化规则
 */
export interface AutomationRule {
  ruleId: string;                      // 规则唯一ID
  ruleName: string;                    // 规则名称
  ruleType: RuleType;                  // 规则类型
  triggerCondition: TriggerCondition;  // 触发条件
  actions: RuleAction[];               // 动作列表
  isEnabled: boolean;                  // 是否启用
  priority: number;                    // 优先级（1-10，越高越优先）
  lastTriggered?: number;              // 最后触发时间戳
  triggerCount: number;                // 触发次数
  description?: string;                // 规则描述
}

/**
 * 规则执行结果接口
 * 描述规则执行的结果
 */
export interface RuleExecutionResult {
  ruleId: string;                      // 规则ID
  ruleName: string;                    // 规则名称
  triggeredAt: number;                 // 触发时间戳
  actionsToExecute: RuleAction[];      // 待执行的动作列表
}

/**
 * 规则触发历史接口
 * 描述规则的触发历史记录
 */
export interface RuleTriggerHistory {
  ruleId: string;
  ruleName: string;
  triggeredAt: number;
  eventData?: any;                     // 触发时的事件数据
  executionStatus: 'success' | 'partial' | 'failed';  // 执行状态
  errorMessage?: string;               // 错误消息
}
