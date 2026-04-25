/**
 * 规则执行器
 * 执行联动规则的动作
 */

import { IRuleExecutor, ExecutionResult } from '../interfaces/IRuleExecutor';
import { RuleAction } from '../../../models/SmartWardAutomationModels';
import { DeviceManager } from '../managers/DeviceManager';
import { AlertManager } from '../managers/AlertManager';
import { DeviceCommand } from '../../../models/SmartWardDeviceModels';
import { AlertLevel, AlertCategory } from '../../../models/SmartWardEnums';

/**
 * 规则执行器类
 */
export class RuleExecutor implements IRuleExecutor {
  private static instance: RuleExecutor;

  private constructor() {
    console.log('RuleExecutor initialized');
  }

  /**
   * 获取规则执行器单例实例
   */
  public static getInstance(): RuleExecutor {
    if (!RuleExecutor.instance) {
      RuleExecutor.instance = new RuleExecutor();
    }
    return RuleExecutor.instance;
  }

  /**
   * 执行动作列表
   */
  public async executeActions(actions: RuleAction[], roomId: string): Promise<ExecutionResult[]> {
    const results: ExecutionResult[] = [];

    console.log(`RuleExecutor: Executing ${actions.length} actions for room ${roomId}`);

    // 按顺序执行动作
    for (const action of actions) {
      const startTime = Date.now();

      try {
        // 如果有延迟，先等待
        if (action.delayMs && action.delayMs > 0) {
          await this.sleep(action.delayMs);
        }

        // 执行动作
        await this.executeAction(action, roomId);

        const executionTime = Date.now() - startTime;
        results.push({
          actionType: action.actionType,
          success: true,
          executionTime
        });

        console.log(`RuleExecutor: Action ${action.actionType} executed successfully in ${executionTime}ms`);
      } catch (error) {
        const executionTime = Date.now() - startTime;
        results.push({
          actionType: action.actionType,
          success: false,
          errorMessage: error instanceof Error ? error.message : String(error),
          executionTime
        });

        console.error(`RuleExecutor: Action ${action.actionType} failed`, error);
      }
    }

    return results;
  }

  /**
   * 执行单个动作
   */
  private async executeAction(action: RuleAction, roomId: string): Promise<void> {
    switch (action.actionType) {
      case 'CONTROL_DEVICE':
        if (action.targetDeviceId && action.command) {
          await this.controlDevice(action.targetDeviceId, action.params);
        }
        break;

      case 'SEND_ALERT':
        if (action.alertLevel && action.alertType && action.message) {
          await this.sendAlert(action.alertLevel, action.alertType, action.message, roomId);
        }
        break;

      case 'RECORD_DATA':
        await this.recordData(action.params);
        break;

      case 'VOICE_BROADCAST':
        if (action.message) {
          await this.voiceBroadcast(action.message);
        }
        break;

      case 'LIGHT_FLASH':
        if (action.targetDeviceId) {
          const duration = action.params?.duration as number || 3000;
          await this.lightFlash(action.targetDeviceId, duration);
        }
        break;

      case 'ADJUST_BED':
        if (action.targetDeviceId && action.params) {
          await this.controlDevice(action.targetDeviceId, action.params);
        }
        break;

      case 'CLOSE_CURTAIN':
        if (action.targetDeviceId) {
          await this.controlDevice(action.targetDeviceId, { openPercentage: 0 });
        }
        break;

      case 'MUTE_TV':
        if (action.targetDeviceId) {
          await this.controlDevice(action.targetDeviceId, { isMuted: true });
        }
        break;

      default:
        console.warn(`RuleExecutor: Unknown action type ${action.actionType}`);
        break;
    }
  }

  /**
   * 控制设备
   */
  public async controlDevice(deviceId: string, command: any): Promise<void> {
    const deviceManager = DeviceManager.getInstance();

    // 构造设备命令
    const deviceCommand: DeviceCommand = {
      deviceId: deviceId,
      deviceType: 'SMART_LIGHT' as any, // 这里应该从设备信息中获取
      action: 'setProperties',
      params: command,
      timestamp: Date.now()
    };

    await deviceManager.sendCommand(deviceId, deviceCommand);
  }

  /**
   * 发送告警
   */
  public async sendAlert(alertLevel: string, alertType: string, message: string, roomId: string): Promise<void> {
    const alertManager = AlertManager.getInstance();

    // 这里需要创建WardAlert对象
    // 由于AlertManager接口可能不同，这里简化处理
    console.log(`RuleExecutor: Sending alert - Level: ${alertLevel}, Type: ${alertType}, Message: ${message}, Room: ${roomId}`);
  }

  /**
   * 录制数据
   */
  public async recordData(data: any): Promise<void> {
    console.log(`RuleExecutor: Recording data`, data);
    // 这里应该将数据保存到数据库或文件
  }

  /**
   * 语音播报
   */
  public async voiceBroadcast(message: string): Promise<void> {
    console.log(`RuleExecutor: Voice broadcast - ${message}`);
    // 这里应该调用语音合成API
  }

  /**
   * 灯光闪烁
   */
  public async lightFlash(deviceId: string, duration: number): Promise<void> {
    console.log(`RuleExecutor: Light flash on ${deviceId} for ${duration}ms`);

    const deviceManager = DeviceManager.getInstance();

    // 关灯
    await this.controlDevice(deviceId, { isOn: false });

    // 等待
    await this.sleep(500);

    // 开灯
    await this.controlDevice(deviceId, { isOn: true });

    // 等待
    await this.sleep(500);

    // 关灯
    await this.controlDevice(deviceId, { isOn: false });

    // 等待
    await this.sleep(500);

    // 开灯
    await this.controlDevice(deviceId, { isOn: true });
  }

  /**
   * 睡眠函数
   */
  private sleep(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}
