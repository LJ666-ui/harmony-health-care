/**
 * 患者监护仪控制器
 * 采集患者生命体征数据
 */

import { IDeviceController } from '../IDeviceController';
import { DeviceStatus, DeviceCommand, DeviceProperty, DeviceType, MonitorData } from '../models/SmartWardDeviceModels';

/**
 * 患者监护仪控制器类
 */
export class PatientMonitorController implements IDeviceController {
  // 设备状态缓存
  private statusCache: Map<string, DeviceStatus> = new Map();

  // 订阅者回调集合
  private subscribers: Map<string, Array<(status: DeviceStatus) => void>> = new Map();

  constructor() {
    console.log('PatientMonitorController initialized');
  }

  /**
   * 发送控制命令到监护仪设备
   * 监护仪主要是采集数据，不支持太多控制命令
   */
  public async sendCommand(deviceId: string, command: DeviceCommand): Promise<void> {
    console.log(`PatientMonitorController: Sending command to ${deviceId}`, command);

    // 监护仪主要支持重置、校准等操作
    const params = command.params;
    let action = command.action;

    if (action === 'reset') {
      // 重置监护仪
      console.log(`PatientMonitorController: Resetting monitor ${deviceId}`);
    } else if (action === 'calibrate') {
      // 校准监护仪
      console.log(`PatientMonitorController: Calibrating monitor ${deviceId}`);
    }

    // 更新设备状态
    const currentStatus = this.statusCache.get(deviceId);
    const properties: Map<string, DeviceProperty> = currentStatus?.properties || new Map();

    // 生成新的生命体征数据
    const vitalSigns = this.generateVitalSigns();

    properties.set('heartRate', {
      key: 'heartRate',
      value: vitalSigns.heartRate,
      unit: 'bpm',
      min: 40,
      max: 120,
      readOnly: true,
      updatedAt: Date.now()
    });

    properties.set('oxygenSaturation', {
      key: 'oxygenSaturation',
      value: vitalSigns.oxygenSaturation,
      unit: '%',
      min: 90,
      max: 100,
      readOnly: true,
      updatedAt: Date.now()
    });

    properties.set('systolicBP', {
      key: 'systolicBP',
      value: vitalSigns.systolicBP,
      unit: 'mmHg',
      min: 80,
      max: 180,
      readOnly: true,
      updatedAt: Date.now()
    });

    properties.set('diastolicBP', {
      key: 'diastolicBP',
      value: vitalSigns.diastolicBP,
      unit: 'mmHg',
      min: 50,
      max: 120,
      readOnly: true,
      updatedAt: Date.now()
    });

    properties.set('temperature', {
      key: 'temperature',
      value: vitalSigns.temperature,
      unit: '°C',
      min: 35,
      max: 42,
      readOnly: true,
      updatedAt: Date.now()
    });

    properties.set('respiratoryRate', {
      key: 'respiratoryRate',
      value: vitalSigns.respiratoryRate,
      unit: '/min',
      min: 8,
      max: 30,
      readOnly: true,
      updatedAt: Date.now()
    });

    const newStatus: DeviceStatus = {
      deviceId: deviceId,
      deviceType: DeviceType.PATIENT_MONITOR,
      deviceName: currentStatus?.deviceName || '患者监护仪',
      isOnline: true,
      properties: properties,
      lastHeartbeat: Date.now()
    };

    this.statusCache.set(deviceId, newStatus);

    // 通知订阅者
    this.notifySubscribers(deviceId, newStatus);

    console.log(`PatientMonitorController: Monitor ${deviceId} updated with new vital signs`);
  }

  /**
   * 获取监护仪设备状态
   */
  public async getDeviceStatus(deviceId: string): Promise<DeviceStatus> {
    let status = this.statusCache.get(deviceId);

    // 如果没有缓存状态，创建默认状态
    if (!status) {
      const properties: Map<string, DeviceProperty> = new Map();
      const vitalSigns = this.generateVitalSigns();

      properties.set('heartRate', {
        key: 'heartRate',
        value: vitalSigns.heartRate,
        unit: 'bpm',
        min: 40,
        max: 120,
        readOnly: true,
        updatedAt: Date.now()
      });

      properties.set('oxygenSaturation', {
        key: 'oxygenSaturation',
        value: vitalSigns.oxygenSaturation,
        unit: '%',
        min: 90,
        max: 100,
        readOnly: true,
        updatedAt: Date.now()
      });

      properties.set('systolicBP', {
        key: 'systolicBP',
        value: vitalSigns.systolicBP,
        unit: 'mmHg',
        min: 80,
        max: 180,
        readOnly: true,
        updatedAt: Date.now()
      });

      properties.set('diastolicBP', {
        key: 'diastolicBP',
        value: vitalSigns.diastolicBP,
        unit: 'mmHg',
        min: 50,
        max: 120,
        readOnly: true,
        updatedAt: Date.now()
      });

      properties.set('temperature', {
        key: 'temperature',
        value: vitalSigns.temperature,
        unit: '°C',
        min: 35,
        max: 42,
        readOnly: true,
        updatedAt: Date.now()
      });

      properties.set('respiratoryRate', {
        key: 'respiratoryRate',
        value: vitalSigns.respiratoryRate,
        unit: '/min',
        min: 8,
        max: 30,
        readOnly: true,
        updatedAt: Date.now()
      });

      status = {
        deviceId: deviceId,
        deviceType: DeviceType.PATIENT_MONITOR,
        deviceName: '患者监护仪',
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

    const subscriptionId = `monitor_${deviceId}_${Date.now()}`;
    console.log(`PatientMonitorController: Subscribed to ${deviceId}, subscriptionId: ${subscriptionId}`);
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
      console.log(`PatientMonitorController: Unsubscribed from ${subscriptionId}`);
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
          console.error(`PatientMonitorController: Error in subscriber callback for ${deviceId}`, error);
        }
      });
    }
  }

  /**
   * 生成模拟生命体征数据
   */
  private generateVitalSigns(): MonitorData {
    // 生成合理的随机生命体征数据
    const heartRate = Math.floor(70 + Math.random() * 30); // 70-100 bpm
    const oxygenSaturation = Math.floor(95 + Math.random() * 5); // 95-100%
    const systolicBP = Math.floor(110 + Math.random() * 30); // 110-140 mmHg
    const diastolicBP = Math.floor(70 + Math.random() * 20); // 70-90 mmHg
    const temperature = parseFloat((36.5 + Math.random() * 1.5).toFixed(1)); // 36.5-38.0°C
    const respiratoryRate = Math.floor(12 + Math.random() * 8); // 12-20 /min

    return {
      heartRate,
      oxygenSaturation,
      systolicBP,
      diastolicBP,
      temperature,
      respiratoryRate,
      timestamp: Date.now()
    };
  }

  /**
   * 清空缓存
   */
  public clear(): void {
    this.statusCache.clear();
    this.subscribers.clear();
    console.log('PatientMonitorController cleared');
  }
}
