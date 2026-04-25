/**
 * 智能窗帘控制器
 * 控制窗帘的开关和开合程度
 */

import { IDeviceController } from '../IDeviceController';
import { DeviceStatus, DeviceCommand, DeviceProperty, DeviceType } from '../models/SmartWardDeviceModels';

/**
 * 智能窗帘控制器类
 */
export class SmartCurtainController implements IDeviceController {
  // 设备状态缓存
  private statusCache: Map<string, DeviceStatus> = new Map();

  // 订阅者回调集合
  private subscribers: Map<string, Array<(status: DeviceStatus) => void>> = new Map();

  constructor() {
    console.log('SmartCurtainController initialized');
  }

  /**
   * 发送控制命令到窗帘设备
   */
  public async sendCommand(deviceId: string, command: DeviceCommand): Promise<void> {
    console.log(`SmartCurtainController: Sending command to ${deviceId}`, command);

    // 解析命令参数
    const params = command.params;
    let openLevel: number = 0;
    let isOpen: boolean = false;

    if ('openLevel' in params) {
      openLevel = params.openLevel as number;
    }
    if ('isOpen' in params) {
      isOpen = params.isOpen as boolean;
    }

    // 更新设备状态
    const currentStatus = this.statusCache.get(deviceId);
    const properties: Map<string, DeviceProperty> = currentStatus?.properties || new Map();

    properties.set('openLevel', {
      key: 'openLevel',
      value: openLevel,
      unit: '%',
      min: 0,
      max: 100,
      readOnly: false,
      updatedAt: Date.now()
    });

    properties.set('isOpen', {
      key: 'isOpen',
      value: isOpen,
      readOnly: false,
      updatedAt: Date.now()
    });

    const newStatus: DeviceStatus = {
      deviceId: deviceId,
      deviceType: DeviceType.SMART_CURTAIN,
      deviceName: currentStatus?.deviceName || '智能窗帘',
      isOnline: true,
      properties: properties,
      lastHeartbeat: Date.now()
    };

    this.statusCache.set(deviceId, newStatus);

    // 通知订阅者
    this.notifySubscribers(deviceId, newStatus);

    console.log(`SmartCurtainController: Curtain ${deviceId} updated - openLevel: ${openLevel}%, isOpen: ${isOpen}`);
  }

  /**
   * 获取窗帘设备状态
   */
  public async getDeviceStatus(deviceId: string): Promise<DeviceStatus> {
    let status = this.statusCache.get(deviceId);

    // 如果没有缓存状态，创建默认状态
    if (!status) {
      const properties: Map<string, DeviceProperty> = new Map();
      properties.set('openLevel', {
        key: 'openLevel',
        value: 0,
        unit: '%',
        min: 0,
        max: 100,
        readOnly: false,
        updatedAt: Date.now()
      });
      properties.set('isOpen', {
        key: 'isOpen',
        value: false,
        readOnly: false,
        updatedAt: Date.now()
      });

      status = {
        deviceId: deviceId,
        deviceType: DeviceType.SMART_CURTAIN,
        deviceName: '智能窗帘',
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

    const subscriptionId = `curtain_${deviceId}_${Date.now()}`;
    console.log(`SmartCurtainController: Subscribed to ${deviceId}, subscriptionId: ${subscriptionId}`);
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
      console.log(`SmartCurtainController: Unsubscribed from ${subscriptionId}`);
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
          console.error(`SmartCurtainController: Error in subscriber callback for ${deviceId}`, error);
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
    console.log('SmartCurtainController cleared');
  }
}
