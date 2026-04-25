/**
 * 规则执行器接口
 * 定义规则执行的标准行为
 */

import { RuleAction } from '../../../models/SmartWardAutomationModels';

/**
 * 规则执行结果接口
 */
export interface ExecutionResult {
  actionType: string;
  success: boolean;
  errorMessage?: string;
  executionTime: number;
}

/**
 * 规则执行器接口
 */
export interface IRuleExecutor {
  /**
   * 执行动作列表
   * @param actions 动作列表
   * @param roomId 房间ID
   * @returns Promise<ExecutionResult[]> 执行结果列表
   */
  executeActions(actions: RuleAction[], roomId: string): Promise<ExecutionResult[]>;

  /**
   * 控制设备
   * @param deviceId 设备ID
   * @param command 命令
   * @returns Promise<void>
   */
  controlDevice(deviceId: string, command: any): Promise<void>;

  /**
   * 发送告警
   * @param alertLevel 告警等级
   * @param alertType 告警类型
   * @param message 告警消息
   * @param roomId 房间ID
   * @returns Promise<void>
   */
  sendAlert(alertLevel: string, alertType: string, message: string, roomId: string): Promise<void>;

  /**
   * 录制数据
   * @param data 数据
   * @returns Promise<void>
   */
  recordData(data: any): Promise<void>;

  /**
   * 语音播报
   * @param message 播报内容
   * @returns Promise<void>
   */
  voiceBroadcast(message: string): Promise<void>;

  /**
   * 灯光闪烁
   * @param deviceId 设备ID
   * @param duration 闪烁时长（毫秒）
   * @returns Promise<void>
   */
  lightFlash(deviceId: string, duration: number): Promise<void>;
}
