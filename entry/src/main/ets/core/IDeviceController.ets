/**
 * 设备控制器接口
 * 定义设备控制的标准行为
 */

import { DeviceCommand, DeviceStatus } from '../../models/SmartWardDeviceModels';

/**
 * 设备控制器接口
 * 所有设备控制器都需要实现此接口
 */
export interface IDeviceController {
  /**
   * 发送控制命令到设备
   * @param deviceId 设备ID
   * @param command 设备命令
   * @returns Promise<void>
   */
  sendCommand(deviceId: string, command: DeviceCommand): Promise<void>;

  /**
   * 获取设备状态
   * @param deviceId 设备ID
   * @returns Promise<DeviceStatus> 设备状态
   */
  getDeviceStatus(deviceId: string): Promise<DeviceStatus>;

  /**
   * 订阅设备状态变化
   * @param deviceId 设备ID
   * @param callback 状态变化回调函数
   * @returns string 订阅ID
   */
  subscribeStatusChange(deviceId: string, callback: (status: DeviceStatus) => void): string;

  /**
   * 取消订阅设备状态变化
   * @param subscriptionId 订阅ID
   * @returns boolean 是否取消成功
   */
  unsubscribeStatusChange(subscriptionId: string): boolean;
}
