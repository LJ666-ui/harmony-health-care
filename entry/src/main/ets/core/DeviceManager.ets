/**
 * 设备管理器
 * 单例类，管理所有设备的注册、移除和查询
 */

import { DeviceInfo, DeviceStatus, DeviceCommand } from '../models/SmartWardDeviceModels';
import { IDeviceController } from './IDeviceController';

/**
 * 设备管理器单例类
 */
export class DeviceManager {
  private static instance: DeviceManager;

  // 设备信息存储（设备ID → 设备信息）
  private devices: Map<string, DeviceInfo> = new Map();

  // 设备状态存储（设备ID → 设备状态）
  private deviceStatuses: Map<string, DeviceStatus> = new Map();

  // 设备控制器存储（设备类型 → 控制器）
  private controllers: Map<string, IDeviceController> = new Map();

  // 房间到设备的映射（房间ID → 设备ID列表）
  private roomToDeviceMap: Map<string, string[]> = new Map();

  // 订阅者回调存储（设备ID → 回调函数列表）
  private subscribers: Map<string, Array<(status: DeviceStatus) => void>> = new Map();

  private constructor() {
    console.log('DeviceManager initialized');
  }

  /**
   * 获取设备管理器单例实例
   */
  public static getInstance(): DeviceManager {
    if (!DeviceManager.instance) {
      DeviceManager.instance = new DeviceManager();
    }
    return DeviceManager.instance;
  }

  /**
   * 注册设备
   * @param deviceInfo 设备信息
   */
  public registerDevice(deviceInfo: DeviceInfo): void {
    this.devices.set(deviceInfo.deviceId, deviceInfo);

    // 更新房间到设备的映射
    const deviceIds = this.roomToDeviceMap.get(deviceInfo.roomId) || [];
    if (!deviceIds.includes(deviceInfo.deviceId)) {
      deviceIds.push(deviceInfo.deviceId);
      this.roomToDeviceMap.set(deviceInfo.roomId, deviceIds);
    }

    console.log(`Device registered: ${deviceInfo.deviceId} (${deviceInfo.name})`);
  }

  /**
   * 移除设备
   * @param deviceId 设备ID
   * @returns boolean 是否移除成功
   */
  public unregisterDevice(deviceId: string): boolean {
    const deviceInfo = this.devices.get(deviceId);
    if (!deviceInfo) {
      return false;
    }

    // 从房间映射中移除
    const deviceIds = this.roomToDeviceMap.get(deviceInfo.roomId);
    if (deviceIds) {
      const index = deviceIds.indexOf(deviceId);
      if (index > -1) {
        deviceIds.splice(index, 1);
      }
    }

    this.devices.delete(deviceId);
    this.deviceStatuses.delete(deviceId);
    this.subscribers.delete(deviceId);

    console.log(`Device unregistered: ${deviceId}`);
    return true;
  }

  /**
   * 注册设备控制器
   * @param deviceType 设备类型
   * @param controller 设备控制器
   */
  public registerController(deviceType: string, controller: IDeviceController): void {
    this.controllers.set(deviceType, controller);
    console.log(`Controller registered for device type: ${deviceType}`);
  }

  /**
   * 获取设备信息
   * @param deviceId 设备ID
   * @returns DeviceInfo | undefined 设备信息
   */
  public getDevice(deviceId: string): DeviceInfo | undefined {
    return this.devices.get(deviceId);
  }

  /**
   * 获取所有设备
   * @returns DeviceInfo[] 设备列表
   */
  public getAllDevices(): DeviceInfo[] {
    return Array.from(this.devices.values());
  }

  /**
   * 根据房间ID获取设备列表
   * @param roomId 房间ID
   * @returns DeviceInfo[] 设备列表
   */
  public getDevicesByRoom(roomId: string): DeviceInfo[] {
    const deviceIds = this.roomToDeviceMap.get(roomId) || [];
    return deviceIds
      .map(id => this.devices.get(id))
      .filter(device => device !== undefined) as DeviceInfo[];
  }

  /**
   * 根据设备类型获取设备列表
   * @param deviceType 设备类型
   * @returns DeviceInfo[] 设备列表
   */
  public getDevicesByType(deviceType: string): DeviceInfo[] {
    return Array.from(this.devices.values()).filter(
      device => device.deviceType === deviceType
    );
  }

  /**
   * 更新设备状态
   * @param status 设备状态
   */
  public updateDeviceStatus(status: DeviceStatus): void {
    this.deviceStatuses.set(status.deviceId, status);

    // 通知订阅者
    const callbacks = this.subscribers.get(status.deviceId);
    if (callbacks) {
      callbacks.forEach(callback => callback(status));
    }
  }

  /**
   * 获取设备状态
   * @param deviceId 设备ID
   * @returns DeviceStatus | undefined 设备状态
   */
  public getDeviceStatus(deviceId: string): DeviceStatus | undefined {
    return this.deviceStatuses.get(deviceId);
  }

  /**
   * 获取所有设备状态
   * @returns Map<string, DeviceStatus> 设备状态映射
   */
  public getAllDeviceStatuses(): Map<string, DeviceStatus> {
    return new Map(this.deviceStatuses);
  }

  /**
   * 发送命令到设备
   * @param deviceId 设备ID
   * @param command 设备命令
   * @returns Promise<void>
   */
  public async sendCommand(deviceId: string, command: DeviceCommand): Promise<void> {
    const deviceInfo = this.devices.get(deviceId);
    if (!deviceInfo) {
      throw new Error(`Device not found: ${deviceId}`);
    }

    const controller = this.controllers.get(deviceInfo.deviceType);
    if (!controller) {
      throw new Error(`Controller not found for device type: ${deviceInfo.deviceType}`);
    }

    await controller.sendCommand(deviceId, command);
  }

  /**
   * 订阅设备状态变化
   * @param deviceId 设备ID
   * @param callback 状态变化回调函数
   * @returns string 订阅ID
   */
  public subscribeStatusChange(deviceId: string, callback: (status: DeviceStatus) => void): string {
    const callbacks = this.subscribers.get(deviceId) || [];
    callbacks.push(callback);
    this.subscribers.set(deviceId, callbacks);

    const subscriptionId = `${deviceId}_${Date.now()}`;
    console.log(`Subscribed to device status change: ${deviceId}, subscriptionId: ${subscriptionId}`);
    return subscriptionId;
  }

  /**
   * 取消订阅设备状态变化
   * @param subscriptionId 订阅ID
   * @returns boolean 是否取消成功
   */
  public unsubscribeStatusChange(subscriptionId: string): boolean {
    // 解析设备ID
    const deviceId = subscriptionId.split('_')[0];
    const callbacks = this.subscribers.get(deviceId);

    if (callbacks && callbacks.length > 0) {
      callbacks.pop();
      console.log(`Unsubscribed from device status change: ${subscriptionId}`);
      return true;
    }

    return false;
  }

  /**
   * 清空所有设备数据
   */
  public clear(): void {
    this.devices.clear();
    this.deviceStatuses.clear();
    this.roomToDeviceMap.clear();
    this.subscribers.clear();
    console.log('DeviceManager cleared');
  }
}
