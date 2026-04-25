import { distributedDeviceManager } from './DistributedKitStubs';
import { PairingResult } from '../models/DistributedModels';

interface DeviceAuthInfo {
  deviceId: string;
  deviceName: string;
  authType: string;
  authTime: number;
  isValid: boolean;
}

interface PairingRequestEntry {
  resolve: Function;
  reject: Function;
  timeout: number;
}

export class DevicePairingService {
  private pairedDevices: Map<string, DeviceAuthInfo> = new Map<string, DeviceAuthInfo>();
  private pairingRequests: Map<string, PairingRequestEntry> = new Map<string, PairingRequestEntry>();

  async pairDevice(deviceId: string, pinCode?: string): Promise<PairingResult> {
    try {
      console.log(`[DevicePairingService] 开始配对设备: ${deviceId}`);

      if (this.pairedDevices.has(deviceId)) {
        const existingInfo: DeviceAuthInfo | undefined = this.pairedDevices.get(deviceId);
        if (existingInfo && existingInfo.isValid) {
          return {
            success: true,
            message: '设备已配对',
            deviceId: deviceId
          };
        }
      }

      const isTrusted: boolean = await this.verifyDeviceTrust(deviceId);
      if (!isTrusted) {
        return {
          success: false,
          message: '设备不在信任列表中，需要手动确认配对',
          deviceId: deviceId,
          errorCode: 1001
        };
      }

      const authResult: boolean = await this.authenticateDevice(deviceId, pinCode);
      if (!authResult) {
        return {
          success: false,
          message: '设备认证失败，PIN码不匹配或已过期',
          deviceId: deviceId,
          errorCode: 1002
        };
      }

      const authInfo: DeviceAuthInfo = {
        deviceId: deviceId,
        deviceName: `医疗终端-${deviceId.substring(0, 8)}`,
        authType: pinCode ? 'PIN_CODE' : 'TRUSTED',
        authTime: Date.now(),
        isValid: true
      };

      this.pairedDevices.set(deviceId, authInfo);

      console.log(`[DevicePairingService] 设备配对成功: ${deviceId}`);
      return {
        success: true,
        message: '设备配对成功',
        deviceId: deviceId
      };
    } catch (error) {
      console.error('[DevicePairingService] 配对过程异常:', error);
      return {
        success: false,
        message: `配对异常: ${String(error)}`,
        deviceId: deviceId,
        errorCode: -1
      };
    }
  }

  async unpairDevice(deviceId: string): Promise<boolean> {
    try {
      console.log(`[DevicePairingService] 解除配对设备: ${deviceId}`);

      if (!this.pairedDevices.has(deviceId)) {
        console.warn(`[DevicePairingService] 设备未配对: ${deviceId}`);
        return false;
      }

      const authInfo: DeviceAuthInfo | undefined = this.pairedDevices.get(deviceId);
      if (authInfo) {
        authInfo.isValid = false;
        this.pairedDevices.set(deviceId, authInfo);
      }

      this.pairedDevices.delete(deviceId);

      console.log(`[DevicePairingService] 设备解除配对成功: ${deviceId}`);
      return true;
    } catch (error) {
      console.error('[DevicePairingService] 解除配对失败:', error);
      return false;
    }
  }

  async verifyDeviceTrust(deviceId: string): Promise<boolean> {
    try {
      console.log(`[DevicePairingService] 验证设备信任状态: ${deviceId}`);

      await this.simulateNetworkDelay(500);

      const trustedDevicePrefixes: string[] = [
        'device_',
        'hospital_',
        'terminal_',
        'medical_'
      ];

      for (let i = 0; i < trustedDevicePrefixes.length; i++) {
        if (deviceId.startsWith(trustedDevicePrefixes[i])) {
          console.log(`[DevicePairingService] 设备在信任列表中: ${deviceId}`);
          return true;
        }
      }

      console.warn(`[DevicePairingService] 设备不在信任列表中: ${deviceId}`);
      return false;
    } catch (error) {
      console.error('[DevicePairingService] 验证设备信任失败:', error);
      return false;
    }
  }

  async authenticateDevice(deviceId: string, pinCode?: string): Promise<boolean> {
    try {
      console.log(`[DevicePairingService] 认证设备: ${deviceId}`);

      await this.simulateNetworkDelay(800);

      if (pinCode && pinCode.length > 0) {
        if (pinCode === '123456' || pinCode === '000000') {
          console.log(`[DevicePairingService] PIN码验证通过`);
          return true;
        }
        console.warn(`[DevicePairingService] PIN码验证失败`);
        return false;
      }

      console.log(`[DevicePairingService] 免PIN码认证通过（受信任设备）`);
      return true;
    } catch (error) {
      console.error('[DevicePairingService] 设备认证失败:', error);
      return false;
    }
  }

  getPairedDevices(): DeviceAuthInfo[] {
    const devices: DeviceAuthInfo[] = [];
    this.pairedDevices.forEach((value: DeviceAuthInfo) => {
      if (value.isValid) {
        devices.push(value);
      }
    });
    return devices;
  }

  isDevicePaired(deviceId: string): boolean {
    const authInfo: DeviceAuthInfo | undefined = this.pairedDevices.get(deviceId);
    return authInfo ? authInfo.isValid : false;
  }

  async refreshDeviceAuth(deviceId: string): Promise<boolean> {
    try {
      console.log(`[DevicePairingService] 刷新设备认证: ${deviceId}`);

      const authInfo: DeviceAuthInfo | undefined = this.pairedDevices.get(deviceId);
      if (!authInfo || !authInfo.isValid) {
        console.warn(`[DevicePairingService] 设备未配对或已失效: ${deviceId}`);
        return false;
      }

      const authAge: number = Date.now() - authInfo.authTime;
      const maxAuthAge: number = 24 * 60 * 60 * 1000;

      if (authAge > maxAuthAge) {
        console.warn(`[DevicePairingService] 设备认证已过期，需要重新配对: ${deviceId}`);
        authInfo.isValid = false;
        this.pairedDevices.set(deviceId, authInfo);
        return false;
      }

      authInfo.authTime = Date.now();
      this.pairedDevices.set(deviceId, authInfo);

      console.log(`[DevicePairingService] 设备认证刷新成功: ${deviceId}`);
      return true;
    } catch (error) {
      console.error('[DevicePairingService] 刷新设备认证失败:', error);
      return false;
    }
  }

  private simulateNetworkDelay(ms: number): Promise<void> {
    return new Promise<void>((resolve) => {
      setTimeout(resolve, ms);
    });
  }
}
