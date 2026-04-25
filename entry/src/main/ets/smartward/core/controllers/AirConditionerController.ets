/**
 * 空调控制器
 * 控制空调的温度和模式
 */

import { IDeviceController } from '../interfaces/IDeviceController';
import { DeviceStatus, DeviceCommand, DeviceProperty, DeviceType } from '../../../models/SmartWardDeviceModels';

export class AirConditionerController implements IDeviceController {
  private statusCache: Map<string, DeviceStatus> = new Map();
  private subscribers: Map<string, Array<(status: DeviceStatus) => void>> = new Map();

  public async sendCommand(deviceId: string, command: DeviceCommand): Promise<void> {
    console.log(`AirConditionerController: Sending command to ${deviceId}`, command);
    const params = command.params;
    let temperature: number = 24;
    let mode: 'cool' | 'heat' | 'auto' | 'fan' = 'cool';
    let isOn: boolean = true;

    if ('temperature' in params) {
      temperature = params.temperature as number;
    }
    if ('mode' in params) {
      mode = params.mode as 'cool' | 'heat' | 'auto' | 'fan';
    }
    if ('isOn' in params) {
      isOn = params.isOn as boolean;
    }

    const currentStatus = this.statusCache.get(deviceId);
    const properties: Map<string, DeviceProperty> = currentStatus?.properties || new Map();

    properties.set('temperature', {
      key: 'temperature',
      value: temperature,
      unit: '℃',
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
    this.notifySubscribers(deviceId, newStatus);
    console.log(`AirConditionerController: AC ${deviceId} updated - temperature: ${temperature}℃, mode: ${mode}, isOn: ${isOn}`);
  }

  public async getDeviceStatus(deviceId: string): Promise<DeviceStatus> {
    let status = this.statusCache.get(deviceId);
    if (!status) {
      const properties: Map<string, DeviceProperty> = new Map();
      properties.set('temperature', { key: 'temperature', value: 24, unit: '℃', min: 16, max: 30, readOnly: false, updatedAt: Date.now() });
      properties.set('mode', { key: 'mode', value: 'cool', readOnly: false, updatedAt: Date.now() });
      properties.set('isOn', { key: 'isOn', value: true, readOnly: false, updatedAt: Date.now() });

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

  public subscribeStatusChange(deviceId: string, callback: (status: DeviceStatus) => void): string {
    const callbacks = this.subscribers.get(deviceId) || [];
    callbacks.push(callback);
    this.subscribers.set(deviceId, callbacks);
    return `ac_${deviceId}_${Date.now()}`;
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
