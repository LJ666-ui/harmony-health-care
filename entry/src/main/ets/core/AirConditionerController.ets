/**
 * 空调控制器
 * 控制空调的温度、模式和风速
 */

import { IDeviceController } from '../IDeviceController';
import { DeviceStatus, DeviceCommand, DeviceProperty, DeviceType } from '../models/SmartWardDeviceModels';

/**
 * 空调控制器类
 */
export class AirConditionerController implements IDeviceController {
  // 设备状态缓存
  private statusCache: Map<string, DeviceStatus> = new Map();

  // 订阅者回调集合
  private subscribers: Map<string, Array<(status: DeviceStatus) => void>> = new Map();

  constructor() {
    console.log('AirConditionerController initialized');
  }

  /**
   * 发送控制命令到空调设备
   */
  public async sendCommand(deviceId: string, command: DeviceCommand): Promise<void> {
    console.log(`AirConditionerController: Sending command to ${deviceId}`, command);

    // 解析命令参数
    const params = command.params;
    let temperature: number = 24;
    let mode: string = 'cool';
    let fanSpeed: string = 'auto';
    let isOn: boolean = false;

    if ('temperature' in params) {
      temperature = params.temperature as number;
    }
    if ('mode' in params) {
      mode = params.mode as string;
    }
    if ('fanSpeed' in params) {
      fanSpeed = params.fanSpeed as string;
    }
    if ('isOn' in params) {
      isOn = params.isOn as boolean;
    }

    // 更新设备状态
    const currentStatus = this.statusCache.get(deviceId);
    const properties: Map<string, DeviceProperty> = currentStatus?.properties || new Map();

    properties.set('temperature', {
      key: 'temperature',
      value: temperature,
      unit: '°C',
      min: 16,
      max: 30,
      readOnly: false,
      updatedAt: Date.now()
    });

    properties.set('mode', {
      key: 'mode',
      value: mode,
      readOnly: false,
      updatedAt: Date.now()
    });

    properties.set('fanSpeed', {
      key: 'fanSpeed',
      value: fanSpeed,
      readOnly: false,
      updatedAt: Date.now()
    });

    properties.set('isOn', {
      key: 'isOn',
      value: isOn,
      readOnly: false,
      updatedAt: Date.now()
    });

    const newStatus: DeviceStatus = {
      deviceId: deviceId,
      deviceType: DeviceType.AIR_CONDITIONER,
      deviceName: currentStatus?.deviceName || '空调',
      isOnline: true,
      properties: properties,
      lastHeartbeat: Date.now()
    };

    this.statusCache.set(deviceId, newStatus);

    // 通知订阅者
    this.notifySubscribers(deviceId, newStatus);

    console.log(`AirConditionerController: AC ${deviceId} updated - temperature: ${temperature}°C, mode: ${mode}, fanSpeed: ${fanSpeed}, isOn: ${isOn}`);
  }

  /**
   * 获取空调设备状态
   */
  public async getDeviceStatus(deviceId: string): Promise<DeviceStatus> {
    let status = this.statusCache.get(deviceId);

    // 如果没有缓存状态，创建默认状态
    if (!status) {
      const properties: Map<string, DeviceProperty> = new Map();
      properties.set('temperature', {
        key: 'temperature',
        value: 24,
        unit: '°C',
        min: 16,
        max: 30,
        readOnly: false,
        updatedAt: Date.now()
      });
      properties.set('mode', {
        key: 'mode',
        value: 'cool',
        readOnly: false,
        updatedAt: Date.now()
      });
      properties.set('fanSpeed', {
        key: 'fanSpeed',
        value: 'auto',
        readOnly: false,
        updatedAt: Date.now()
      });
      properties.set('isOn', {
        key: 'isOn',
        value: false,
        readOnly: false,
        updatedAt: Date.now()
      });

      status = {
        deviceId: deviceId,
        deviceType: DeviceType.AIR_CONDITIONER,
        deviceName: '空调',
        isOnline: true,
        properties: properties,
        lastHeartbeat: Date.now()
      };

      this.statusCache.set(deviceId, status);
    }

    return status;
  }

  /**
   * 订阅设备状态变化
   */
  public subscribeStatusChange(deviceId: string, callback: (status: DeviceStatus) => void): string {
    const callbacks = this.subscribers.get(deviceId) || [];
    callbacks.push(callback);
    this.subscribers.set(deviceId, callbacks);

    const subscriptionId = `ac_${deviceId}_${Date.now()}`;
    console.log(`AirConditionerController: Subscribed to ${deviceId}, subscriptionId: ${subscriptionId}`);
    return subscriptionId;
  }

  /**
   * 取消订阅设备状态变化
   */
  public unsubscribeStatusChange(subscriptionId: string): boolean {
    const parts = subscriptionId.split('_');
    if (parts.length < 2) return false;

    const deviceId = parts[1];
    const callbacks = this.subscribers.get(deviceId);

    if (callbacks && callbacks.length > 0) {
      callbacks.pop();
      console.log(`AirConditionerController: Unsubscribed from ${subscriptionId}`);
      return true;
    }

    return false;
  }

  /**
   * 通知订阅者状态变化
   */
  private notifySubscribers(deviceId: string, status: DeviceStatus): void {
    const callbacks = this.subscribers.get(deviceId);
    if (callbacks) {
      callbacks.forEach(callback => {
        try {
          callback(status);
        } catch (error) {
          console.error(`AirConditionerController: Error in subscriber callback for ${deviceId}`, error);
        }
      });
    }
  }

  /**
   * 清空缓存
   */
  public clear(): void {
    this.statusCache.clear();
    this.subscribers.clear();
    console.log('AirConditionerController cleared');
  }
}
