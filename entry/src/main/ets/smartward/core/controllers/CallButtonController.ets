/**
 * 呼叫按钮控制器
 * 响应患者呼叫按钮
 */

import { IDeviceController } from '../interfaces/IDeviceController';
import { DeviceStatus, DeviceCommand, DeviceProperty, DeviceType } from '../../../models/SmartWardDeviceModels';

export class CallButtonController implements IDeviceController {
  private statusCache: Map<string, DeviceStatus> = new Map();
  private subscribers: Map<string, Array<(status: DeviceStatus) => void>> = new Map();

  public async sendCommand(deviceId: string, command: DeviceCommand): Promise<void> {
    console.log(`CallButtonController: Sending command to ${deviceId}`, command);
    const params = command.params;
    let isPressed: boolean = false;

    if ('isPressed' in params) {
      isPressed = params.isPressed as boolean;
    }

    const currentStatus = this.statusCache.get(deviceId);
    const properties: Map<string, DeviceProperty> = currentStatus?.properties || new Map();

    properties.set('isPressed', {
      key: 'isPressed',
      value: isPressed,
      readOnly: false,
      updatedAt: Date.now()
    });

    properties.set('pressTime', {
      key: 'pressTime',
      value: isPressed ? Date.now() : 0,
      readOnly: true,
      updatedAt: Date.now()
    });

    const newStatus: DeviceStatus = {
      deviceId: deviceId,
      deviceType: DeviceType.CALL_BUTTON,
      deviceName: currentStatus?.deviceName || '呼叫按钮',
      isOnline: true,
      properties: properties,
      lastHeartbeat: Date.now()
    };

    this.statusCache.set(deviceId, newStatus);
    this.notifySubscribers(deviceId, newStatus);
    console.log(`CallButtonController: Button ${deviceId} updated - isPressed: ${isPressed}`);
  }

  public async getDeviceStatus(deviceId: string): Promise<DeviceStatus> {
    let status = this.statusCache.get(deviceId);
    if (!status) {
      const properties: Map<string, DeviceProperty> = new Map();
      properties.set('isPressed', { key: 'isPressed', value: false, readOnly: false, updatedAt: Date.now() });
      properties.set('pressTime', { key: 'pressTime', value: 0, readOnly: true, updatedAt: Date.now() });

      status = {
        deviceId: deviceId,
        deviceType: DeviceType.CALL_BUTTON,
        deviceName: '呼叫按钮',
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
    return `call_${deviceId}_${Date.now()}`;
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
