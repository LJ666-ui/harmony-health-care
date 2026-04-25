/**
 * 智能窗帘控制器
 * 控制窗帘的开合度
 */

import { IDeviceController } from '../interfaces/IDeviceController';
import { DeviceStatus, DeviceCommand, DeviceProperty, DeviceType } from '../../../models/SmartWardDeviceModels';

export class SmartCurtainController implements IDeviceController {
  private statusCache: Map<string, DeviceStatus> = new Map();
  private subscribers: Map<string, Array<(status: DeviceStatus) => void>> = new Map();

  public async sendCommand(deviceId: string, command: DeviceCommand): Promise<void> {
    console.log(`SmartCurtainController: Sending command to ${deviceId}`, command);
    const params = command.params;
    let openPercentage: number = 50;
    let isOn: boolean = true;

    if ('openPercentage' in params) {
      openPercentage = params.openPercentage as number;
    }
    if ('isOn' in params) {
      isOn = params.isOn as boolean;
    }

    const currentStatus = this.statusCache.get(deviceId);
    const properties: Map<string, DeviceProperty> = currentStatus?.properties || new Map();

    properties.set('openPercentage', {
      key: 'openPercentage',
      value: openPercentage,
      unit: '%',
      min: 0,
      max: 100,
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
      deviceType: DeviceType.SMART_CURTAIN,
      deviceName: currentStatus?.deviceName || '智能窗帘',
      isOnline: true,
      properties: properties,
      lastHeartbeat: Date.now()
    };

    this.statusCache.set(deviceId, newStatus);
    this.notifySubscribers(deviceId, newStatus);
    console.log(`SmartCurtainController: Curtain ${deviceId} updated - openPercentage: ${openPercentage}%, isOn: ${isOn}`);
  }

  public async getDeviceStatus(deviceId: string): Promise<DeviceStatus> {
    let status = this.statusCache.get(deviceId);
    if (!status) {
      const properties: Map<string, DeviceProperty> = new Map();
      properties.set('openPercentage', {
        key: 'openPercentage',
        value: 50,
        unit: '%',
        min: 0,
        max: 100,
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

  public subscribeStatusChange(deviceId: string, callback: (status: DeviceStatus) => void): string {
    const callbacks = this.subscribers.get(deviceId) || [];
    callbacks.push(callback);
    this.subscribers.set(deviceId, callbacks);
    return `curtain_${deviceId}_${Date.now()}`;
  }

  public unsubscribeStatusChange(subscriptionId: string): boolean {
    const parts = subscriptionId.split('_');
    if (parts.length < 2) return false;
    const deviceId = parts[1];
    const callbacks = this.subscribers.get(deviceId);
    if (callbacks && callbacks.length > 0) {
      callbacks.pop();
      return true;
    }
    return false;
  }

  private notifySubscribers(deviceId: string, status: DeviceStatus): void {
    const callbacks = this.subscribers.get(deviceId);
    if (callbacks) {
      callbacks.forEach(callback => callback(status));
    }
  }

  public clear(): void {
    this.statusCache.clear();
    this.subscribers.clear();
  }
}
