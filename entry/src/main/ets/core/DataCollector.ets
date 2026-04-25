/**
 * 数据采集模块
 * 定期采集所有设备的状态数据
 */

import { DeviceManager } from '../core/DeviceManager';
import { DeviceStatus } from '../models/SmartWardDeviceModels';
import { DataCollectionRecord } from '../models/SmartWardDataModels';

/**
 * 数据采集器单例类
 */
export class DataCollector {
  private static instance: DataCollector;

  // 采集间隔（毫秒）
  private collectionInterval: number = 5000;

  // 定时器ID
  private timerId: number | null = null;

  // 是否正在采集
  private isCollecting: boolean = false;

  // 数据订阅者
  private subscribers: Array<(data: Map<string, DeviceStatus>) => void> = [];

  private constructor() {
    console.log('DataCollector initialized');
  }

  /**
   * 获取数据采集器单例实例
   */
  public static getInstance(): DataCollector {
    if (!DataCollector.instance) {
      DataCollector.instance = new DataCollector();
    }
    return DataCollector.instance;
  }

  /**
   * 启动数据采集
   */
  public startCollection(interval?: number): void {
    if (this.isCollecting) {
      console.log('DataCollector: Already collecting');
      return;
    }

    if (interval) {
      this.collectionInterval = interval;
    }

    this.isCollecting = true;
    this.timerId = setInterval(() => {
      this.collectAllDevices();
    }, this.collectionInterval);

    console.log(`DataCollector: Started collection with interval ${this.collectionInterval}ms`);
  }

  /**
   * 停止数据采集
   */
  public stopCollection(): void {
    if (!this.isCollecting) {
      return;
    }

    if (this.timerId !== null) {
      clearInterval(this.timerId);
      this.timerId = null;
    }

    this.isCollecting = false;
    console.log('DataCollector: Stopped collection');
  }

  /**
   * 批量采集所有设备状态
   */
  public async collectAllDevices(): Promise<Map<string, DeviceStatus>> {
    const deviceManager = DeviceManager.getInstance();
    const devices = deviceManager.getAllDevices();

    if (devices.length === 0) {
      console.log('DataCollector: No devices to collect');
      return new Map();
    }

    console.log(`DataCollector: Collecting ${devices.length} devices...`);

    const startTime = Date.now();
    const deviceStatuses: Map<string, DeviceStatus> = new Map();
    const collectionRecords: DataCollectionRecord[] = [];

    // 并发采集所有设备状态
    const promises = devices.map(async (device) => {
      try {
        // 通过DeviceManager获取设备状态
        const status = await deviceManager.getDeviceStatus(device.deviceId as string);
        if (status) {
          deviceStatuses.set(device.deviceId, status);

          const record: DataCollectionRecord = {
            collectionId: `COLL_${Date.now()}_${device.deviceId}`,
            deviceId: device.deviceId,
            deviceType: device.deviceType,
            collectedAt: Date.now(),
            data: status,
            collectionDuration: Date.now() - startTime,
            status: 'success'
          };
          collectionRecords.push(record);
        }
      } catch (error) {
        console.error(`DataCollector: Error collecting device ${device.deviceId}`, error);

        const record: DataCollectionRecord = {
          collectionId: `COLL_${Date.now()}_${device.deviceId}`,
          deviceId: device.deviceId,
          deviceType: device.deviceType,
          collectedAt: Date.now(),
          data: null,
          collectionDuration: Date.now() - startTime,
          status: 'failed',
          errorMessage: error instanceof Error ? error.message : String(error)
        };
        collectionRecords.push(record);
      }
    });

    await Promise.all(promises);

    const duration = Date.now() - startTime;
    console.log(`DataCollector: Collected ${deviceStatuses.size}/${devices.length} devices in ${duration}ms`);

    // 通知订阅者
    this.notifySubscribers(deviceStatuses);

    return deviceStatuses;
  }

  /**
   * 订阅数据更新
   */
  public subscribe(callback: (data: Map<string, DeviceStatus>) => void): void {
    this.subscribers.push(callback);
    console.log('DataCollector: New subscriber added');
  }

  /**
   * 取消订阅数据更新
   */
  public unsubscribe(callback: (data: Map<string, DeviceStatus>) => void): void {
    const index = this.subscribers.indexOf(callback);
    if (index > -1) {
      this.subscribers.splice(index, 1);
      console.log('DataCollector: Subscriber removed');
    }
  }

  /**
   * 通知订阅者数据更新
   */
  private notifySubscribers(data: Map<string, DeviceStatus>): void {
    this.subscribers.forEach(callback => {
      try {
        callback(data);
      } catch (error) {
        console.error('DataCollector: Error in subscriber callback', error);
      }
    });
  }

  /**
   * 设置采集间隔
   */
  public setCollectionInterval(interval: number): void {
    this.collectionInterval = interval;
    console.log(`DataCollector: Collection interval set to ${interval}ms`);
  }

  /**
   * 获取采集间隔
   */
  public getCollectionInterval(): number {
    return this.collectionInterval;
  }

  /**
   * 检查是否正在采集
   */
  public isRunning(): boolean {
    return this.isCollecting;
  }
}
