/**
 * 输液泵控制器
 * 监控输液状态
 */

import { IDeviceController } from '../interfaces/IDeviceController';
import { DeviceStatus, DeviceCommand, DeviceProperty, DeviceType } from '../../../models/SmartWardDeviceModels';

export class InfusionPumpController implements IDeviceController {
  private statusCache: Map<string, DeviceStatus> = new Map();
  private subscribers: Map<string, Array<(status: DeviceStatus) => void>> = new Map();

  public async sendCommand(deviceId: string, command: DeviceCommand): Promise<void> {
    console.log(`InfusionPumpController: Sending command to ${deviceId}`, command);
    const params = command.params;
    let flowRate: number = 50;
    let isPaused: boolean = false;

    if ('flowRate' in params) {
      flowRate = params.flowRate as number;
    }
    if ('isPaused' in params) {
      isPaused = params.isPaused as boolean;
    }

    const currentStatus = this.statusCache.get(deviceId);
    const properties: Map<string, DeviceProperty> = currentStatus?.properties || new Map();

    properties.set('flowRate', {
      key: 'flowRate',
      value: flowRate,
      unit: 'ml/h',
      min: 0,
      max: 200,
      readOnly: false,
      updatedAt: Date.now()
    });

    properties.set('isPaused', {
      key: 'isPaused',
      value: isPaused,
      readOnly: false,
      updatedAt: Date.now()
    });

    // 模拟剩余液量变化
    const currentRemaining = properties.get('remainingVolume')?.value as number || 200;
    const newRemaining = isPaused ? currentRemaining : Math.max(0, currentRemaining - (flowRate / 60) * 0.1);

    properties.set('remainingVolume', {
      key: 'remainingVolume',
      value: newRemaining,
      unit: 'ml',
      min: 0,
      max: 500,
      readOnly: true,
      updatedAt: Date.now()
    });

    const newStatus: DeviceStatus = {
      deviceId: deviceId,
      deviceType: DeviceType.INFUSION_PUMP,
      deviceName: currentStatus?.deviceName || '输液泵',
      isOnline: true,
      properties: properties,
      lastHeartbeat: Date.now()
    };

    this.statusCache.set(deviceId, newStatus);
    this.notifySubscribers(deviceId, newStatus);
    console.log(`InfusionPumpController: Pump ${deviceId} updated - flowRate: ${flowRate}ml/h, isPaused: ${isPaused}, remaining: ${newRemaining}ml`);
  }

  public async getDeviceStatus(deviceId: string): Promise<DeviceStatus> {
    let status = this.statusCache.get(deviceId);
    if (!status) {
      const properties: Map<string, DeviceProperty> = new Map();
      properties.set('flowRate', { key: 'flowRate', value: 50, unit: 'ml/h', min: 0, max: 200, readOnly: false, updatedAt: Date.now() });
      properties.set('isPaused', { key: 'isPaused', value: false, readOnly: false, updatedAt: Date.now() });
      properties.set('remainingVolume', { key: 'remainingVolume', value: 200, unit: 'ml', min: 0, max: 500, readOnly: true, updatedAt: Date.now() });

      status = {
        deviceId: deviceId,
        deviceType: DeviceType.INFUSION_PUMP,
        deviceName: '输液泵',
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
    return `pump_${deviceId}_${Date.now()}`;
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
