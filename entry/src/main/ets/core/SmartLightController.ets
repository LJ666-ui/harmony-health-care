/**
 * 智能灯光控制器
 * 控制智能灯光的亮度、色温和开关
 */

import { IDeviceController } from '../IDeviceController';
import { DeviceStatus, DeviceCommand, LightCommand, DeviceProperty, DeviceType } from '../models/SmartWardDeviceModels';

/**
 * 智能灯光控制器类
 */
export class SmartLightController implements IDeviceController {
  // 设备状态缓存
  private statusCache: Map<string, DeviceStatus> = new Map();

  // 订阅者回调集合
  private subscribers: Map<string, Array<(status: DeviceStatus) => void>> = new Map();

  constructor() {
    console.log('SmartLightController initialized');
  }

  /**
   * 发送控制命令到灯光设备
   */
  public async sendCommand(deviceId: string, command: DeviceCommand): Promise<void> {
    console.log(`SmartLightController: Sending command to ${deviceId}`, command);

    // 解析命令参数
    const params = command.params;
    let brightness: number = 50;
    let colorTemp: number = 4000;
    let isOn: boolean = true;

    if ('brightness' in params) {
      brightness = params.brightness as number;
    }
    if ('colorTemp' in params) {
      colorTemp = params.colorTemp as number;
    }
    if ('isOn' in params) {
      isOn = params.isOn as boolean;
    }

    // 更新设备状态
    const currentStatus = this.statusCache.get(deviceId);
    const properties: Map<string, DeviceProperty> = currentStatus?.properties || new Map();

    properties.set('brightness', {
      key: 'brightness',
      value: brightness,
      unit: '%',
      min: 0,
      max: 100,
      readOnly: false,
      updatedAt: Date.now()
    });

    properties.set('colorTemp', {
      key: 'colorTemp',
      value: colorTemp,
      unit: 'K',
      min: 2700,
      max: 6500,
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
      deviceType: DeviceType.SMART_LIGHT,
      deviceName: currentStatus?.deviceName || '智能灯光',
      isOnline: true,
      properties: properties,
      lastHeartbeat: Date.now()
    };

    this.statusCache.set(deviceId, newStatus);

    // 通知订阅者
    this.notifySubscribers(deviceId, newStatus);

    console.log(`SmartLightController: Light ${deviceId} updated - brightness: ${brightness}%, colorTemp: ${colorTemp}K, isOn: ${isOn}`);
  }

  /**
   * 获取灯光设备状态
   */
  public async getDeviceStatus(deviceId: string): Promise<DeviceStatus> {
    let status = this.statusCache.get(deviceId);

    // 如果没有缓存状态，创建默认状态
    if (!status) {
      const properties: Map<string, DeviceProperty> = new Map();
      properties.set('brightness', {
        key: 'brightness',
        value: 50,
        unit: '%',
        min: 0,
        max: 100,
        readOnly: false,
        updatedAt: Date.now()
      });
      properties.set('colorTemp', {
        key: 'colorTemp',
        value: 4000,
        unit: 'K',
        min: 2700,
        max: 6500,
        readOnly: false,
        updatedAt: Date.now()
      });
      properties.set('isOn', {
        key: 'isOn',
        value: true,
        readOnly: false,
        updatedAt: Date.now()
      });

      status = {
        deviceId: deviceId,
        deviceType: DeviceType.SMART_LIGHT,
        deviceName: '智能灯光',
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

    const subscriptionId = `light_${deviceId}_${Date.now()}`;
    console.log(`SmartLightController: Subscribed to ${deviceId}, subscriptionId: ${subscriptionId}`);
    return subscriptionId;
  }

  /**
   * 取消订阅设备状态变化
   */
  public unsubscribeStatusChange(subscriptionId: string): boolean {
    // 解析设备ID
    const parts = subscriptionId.split('_');
    if (parts.length < 2) {
      return false;
    }

    const deviceId = parts[1];
    const callbacks = this.subscribers.get(deviceId);

    if (callbacks && callbacks.length > 0) {
      callbacks.pop();
      console.log(`SmartLightController: Unsubscribed from ${subscriptionId}`);
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
          console.error(`SmartLightController: Error in subscriber callback for ${deviceId}`, error);
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
    console.log('SmartLightController cleared');
  }
}
