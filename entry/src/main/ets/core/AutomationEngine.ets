/**
 * 联动规则引擎
 * 管理联动规则的加载和触发检测
 */

import { AutomationRule, TriggerCondition, ConditionGroup, RuleCondition, RuleExecutionResult } from '../models/SmartWardAutomationModels';
import { TriggerType, RuleType } from '../models/SmartWardEnums';
import { EventData, EventType } from '../models/SmartWardDataModels';
import { DeviceStatus } from '../models/SmartWardDeviceModels';

/**
 * 联动规则引擎单例类
 */
export class AutomationEngine {
  private static instance: AutomationEngine;

  // 规则存储
  private rules: Map<string, AutomationRule> = new Map();

  // 规则冷却时间记录（规则ID → 最后触发时间）
  private cooldownMap: Map<string, number> = new Map();

  private constructor() {
    console.log('AutomationEngine initialized');
  }

  /**
   * 获取规则引擎单例实例
   */
  public static getInstance(): AutomationEngine {
    if (!AutomationEngine.instance) {
      AutomationEngine.instance = new AutomationEngine();
    }
    return AutomationEngine.instance;
  }

  /**
   * 加载规则
   */
  public loadRules(rules: AutomationRule[]): void {
    rules.forEach(rule => {
      this.rules.set(rule.ruleId, rule);
    });
    console.log(`AutomationEngine: Loaded ${rules.length} rules`);
  }

  /**
   * 添加规则
   */
  public addRule(rule: AutomationRule): void {
    this.rules.set(rule.ruleId, rule);
    console.log(`AutomationEngine: Rule added - ${rule.ruleName}`);
  }

  /**
   * 移除规则
   */
  public removeRule(ruleId: string): boolean {
    const removed = this.rules.delete(ruleId);
    if (removed) {
      console.log(`AutomationEngine: Rule removed - ${ruleId}`);
    }
    return removed;
  }

  /**
   * 启用规则
   */
  public enableRule(ruleId: string): boolean {
    const rule = this.rules.get(ruleId);
    if (rule) {
      rule.isEnabled = true;
      console.log(`AutomationEngine: Rule enabled - ${rule.ruleName}`);
      return true;
    }
    return false;
  }

  /**
   * 禁用规则
   */
  public disableRule(ruleId: string): boolean {
    const rule = this.rules.get(ruleId);
    if (rule) {
      rule.isEnabled = false;
      console.log(`AutomationEngine: Rule disabled - ${rule.ruleName}`);
      return true;
    }
    return false;
  }

  /**
   * 获取所有规则
   */
  public getAllRules(): AutomationRule[] {
    return Array.from(this.rules.values());
  }

  /**
   * 检查规则触发条件
   */
  public async checkRules(eventData: EventData): Promise<RuleExecutionResult[]> {
    const results: RuleExecutionResult[] = [];

    console.log(`AutomationEngine: Checking rules for event ${eventData.eventType}`);

    // 遍历所有启用的规则
    for (const rule of this.rules.values()) {
      if (!rule.isEnabled) {
        continue;
      }

      // 检查冷却时间
      if (this.isInCooldown(rule)) {
        continue;
      }

      // 判断规则是否触发
      const triggered = this.isRuleTriggered(rule, eventData);

      if (triggered) {
        console.log(`AutomationEngine: Rule triggered - ${rule.ruleName}`);

        // 更新规则触发信息
        rule.lastTriggered = Date.now();
        rule.triggerCount++;

        // 记录冷却时间
        this.cooldownMap.set(rule.ruleId, Date.now());

        // 添加到执行结果
        results.push({
          ruleId: rule.ruleId,
          ruleName: rule.ruleName,
          triggeredAt: Date.now(),
          actionsToExecute: rule.actions
        });
      }
    }

    return results;
  }

  /**
   * 判断单个规则是否触发
   */
  private isRuleTriggered(rule: AutomationRule, eventData: EventData): boolean {
    const trigger = rule.triggerCondition;

    // 检查触发类型
    if (trigger.triggerType === TriggerType.SCHEDULE) {
      // 定时触发
      return this.checkScheduleTrigger(trigger);
    } else if (trigger.triggerType === TriggerType.DEVICE_STATE_CHANGE) {
      // 设备状态变化触发
      return this.checkDeviceStateTrigger(trigger, eventData);
    } else if (trigger.triggerType === TriggerType.VITAL_THRESHOLD) {
      // 生命体征阈值触发
      return this.checkVitalSignTrigger(trigger, eventData);
    } else if (trigger.triggerType === TriggerType.MANUAL) {
      // 手动触发，需要额外参数
      return false;
    }

    return false;
  }

  /**
   * 检查定时触发
   */
  private checkScheduleTrigger(trigger: TriggerCondition): boolean {
    if (!trigger.time) {
      return false;
    }

    const now = new Date();
    const currentTime = `${String(now.getHours()).padStart(2, '0')}:${String(now.getMinutes()).padStart(2, '0')}`;

    return currentTime === trigger.time;
  }

  /**
   * 检查设备状态变化触发
   */
  private checkDeviceStateTrigger(trigger: TriggerCondition, eventData: EventData): boolean {
    if (eventData.eventType !== EventType.DEVICE_OFFLINE) {
      return false;
    }

    return this.evaluateConditionGroup(trigger.condition, eventData.data);
  }

  /**
   * 检查生命体征阈值触发
   */
  private checkVitalSignTrigger(trigger: TriggerCondition, eventData: EventData): boolean {
    if (eventData.eventType !== EventType.VITAL_SIGNS_CHANGE) {
      return false;
    }

    return this.evaluateConditionGroup(trigger.condition, eventData.data);
  }

  /**
   * 评估条件组
   */
  private evaluateConditionGroup(group: ConditionGroup, data: any): boolean {
    const results = group.conditions.map(condition =>
      this.evaluateCondition(condition, data)
    );

    if (group.logic === 'AND') {
      return results.every(result => result);
    } else {
      return results.some(result => result);
    }
  }

  /**
   * 评估单个条件
   */
  private evaluateCondition(condition: RuleCondition, data: any): boolean {
    const value = this.getValue(condition.propertyKey, data);

    if (value === undefined || value === null) {
      return false;
    }

    switch (condition.operator) {
      case '>':
        return value > condition.value;
      case '<':
        return value < condition.value;
      case '>=':
        return value >= condition.value;
      case '<=':
        return value <= condition.value;
      case '==':
        return value == condition.value;
      case '!=':
        return value != condition.value;
      case 'between':
        return value >= condition.value && value <= (condition.value2 || 0);
      default:
        return false;
    }
  }

  /**
   * 从数据中获取属性值
   */
  private getValue(key: string, data: any): any {
    if (typeof data === 'object' && data !== null) {
      return data[key];
    }
    return undefined;
  }

  /**
   * 检查规则是否在冷却期
   */
  private isInCooldown(rule: AutomationRule): boolean {
    const cooldownSeconds = rule.triggerCondition.cooldownSeconds || 60;
    const lastTriggered = this.cooldownMap.get(rule.ruleId);

    if (!lastTriggered) {
      return false;
    }

    const elapsed = Date.now() - lastTriggered;
    return elapsed < cooldownSeconds * 1000;
  }

  /**
   * 清空规则
   */
  public clear(): void {
    this.rules.clear();
    this.cooldownMap.clear();
    console.log('AutomationEngine cleared');
  }
}
