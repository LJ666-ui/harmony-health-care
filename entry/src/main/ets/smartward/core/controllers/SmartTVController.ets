/**
 * 智能电视控制器
 * 控制电视的音量、频道和开关
 */

import { IDeviceController } from '../interfaces/IDeviceController';
import { DeviceStatus, DeviceCommand, DeviceProperty, DeviceType } from '../../../models/SmartWardDeviceModels';

export class SmartTVController implements IDeviceController {
  private statusCache: Map<string, DeviceStatus> = new Map();
  private subscribers: Map<string, Array<(status: DeviceStatus) => void>> = new Map();

  public async sendCommand(deviceId: string, command: DeviceCommand): Promise<void> {
    console.log(`SmartTVController: Sending command to ${deviceId}`, command);
    const params = command.params;
    let volume: number = 30;
    let channel: number = 1;
    let isOn: boolean = true;
    let isMuted: boolean = false;

    if ('volume' in params) {
      volume = params.volume as number;
    }
    if ('channel' in params) {
      channel = params.channel as number;
    }
    if ('isOn' in params) {
      isOn = params.isOn as boolean;
    }
    if ('isMuted' in params) {
      isMuted = params.isMuted as boolean;
    }

    const currentStatus = this.statusCache.get(deviceId);
    const properties: Map<string, DeviceProperty> = currentStatus?.properties || new Map();

    properties.set('volume', {
      key: 'volume',
      value: volume,
      unit: '%',
      min: 0,
      max: 100,
      readOnly: false,
      updatedAt: Date.now()
    });

    properties.set('channel', {
      key: 'channel',
      value: channel,
      readOnly: false,
      updatedAt: Date.now()
    });

    properties.set('isOn', {
      key: 'isOn',
      value: isOn,
      readOnly: false,
      updatedAt: Date.now()
    });

    properties.set('isMuted', {
      key: 'isMuted',
      value: isMuted,
      readOnly: false,
      updatedAt: Date.now()
    });

    const newStatus: DeviceStatus = {
      deviceId: deviceId,
      deviceType: DeviceType.SMART_TV,
      deviceName: currentStatus?.deviceName || '智能电视',
      isOnline: true,
      properties: properties,
      lastHeartbeat: Date.now()
    };

    this.statusCache.set(deviceId, newStatus);
    this.notifySubscribers(deviceId, newStatus);
    console.log(`SmartTVController: TV ${deviceId} updated - volume: ${volume}%, channel: ${channel}, isOn: ${isOn}, isMuted: ${isMuted}`);
  }

  public async getDeviceStatus(deviceId: string): Promise<DeviceStatus> {
    let status = this.statusCache.get(deviceId);
    if (!status) {
      const properties: Map<string, DeviceProperty> = new Map();
      properties.set('volume', { key: 'volume', value: 30, unit: '%', min: 0, max: 100, readOnly: false, updatedAt: Date.now() });
      properties.set('channel', { key: 'channel', value: 1, readOnly: false, updatedAt: Date.now() });
      properties.set('isOn', { key: 'isOn', value: true, readOnly: false, updatedAt: Date.now() });
      properties.set('isMuted', { key: 'isMuted', value: false, readOnly: false, updatedAt: Date.now() });

      status = {
        deviceId: deviceId,
        deviceType: DeviceType.SMART_TV,
        deviceName: '智能电视',
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
    return `tv_${deviceId}_${Date.now()}`;
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
