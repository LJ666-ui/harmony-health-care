import { distributedDeviceManager, distributedKVStore } from './DistributedKitStubs';
import { DeviceInfo, PairingResult, SyncResult, PermissionLevel, DesensitizeLevel, SyncStatus } from '../models/DistributedModels';
import { DesensitizationUtil } from './DesensitizationUtil';
import { DevicePairingService } from './DevicePairingService';
import { DataTransferService } from './DataTransferService';
import { PermissionManager } from './PermissionManager';
import { getMockDevices, getMockMedicalRecord } from '../mock/distributedMock';

interface KVStore {
  put(key: string, value: distributedKVStore.ValueType): Promise<void>;
  get(key: string): Promise<distributedKVStore.ValueType>;
  delete(key: string): Promise<void>;
  on(type: 'dataChange' | 'syncComplete', callback: Function): void;
  off(type: 'dataChange' | 'syncComplete', callback?: Function): void;
}

class MockKVStore implements KVStore {
  async put(key: string, value: distributedKVStore.ValueType): Promise<void> {
    console.log(`[DistributedManager] KVStore写入: ${key}`);
  }

  async get(key: string): Promise<distributedKVStore.ValueType> {
    console.log(`[DistributedManager] KVStore读取: ${key}`);
    return '' as distributedKVStore.ValueType;
  }

  async delete(key: string): Promise<void> {
    console.log(`[DistributedManager] KVStore删除: ${key}`);
  }

  on(type: 'dataChange' | 'syncComplete', callback: Function): void {}

  off(type: 'dataChange' | 'syncComplete', callback?: Function): void {}
}

export class DistributedManager {
  private static instance: DistributedManager | null = null;
  private deviceManager: distributedDeviceManager.DeviceManager | null = null;
  private kvStores: Map<string, KVStore> = new Map<string, KVStore>();
  private isInitialized: boolean = false;
  private currentAESKey: string = '';
  private devicePairingService: DevicePairingService;
  private dataTransferService: DataTransferService;
  private permissionManager: PermissionManager;

  private constructor() {
    this.devicePairingService = new DevicePairingService();
    this.dataTransferService = new DataTransferService();
    this.permissionManager = new PermissionManager();
  }

  static getInstance(): DistributedManager {
    if (!DistributedManager.instance) {
      DistributedManager.instance = new DistributedManager();
    }
    return DistributedManager.instance;
  }

  async initialize(): Promise<void> {
    if (this.isInitialized) {
      console.log('[DistributedManager] 已经初始化，跳过重复初始化');
      return;
    }

    try {
      console.log('[DistributedManager] 开始初始化分布式管理器...');

      this.currentAESKey = await DesensitizationUtil.generateAESKey();
      console.log('[DistributedManager] AES密钥生成成功');

      const deviceManager = distributedDeviceManager.createDeviceManager('com.example.medical');
      if (deviceManager) {
        this.deviceManager = deviceManager as distributedDeviceManager.DeviceManager;
        console.log('[DistributedManager] 设备管理器创建成功');
      }

      await this.registerDeviceStateListener();
      console.log('[DistributedManager] 设备状态监听注册成功');

      this.isInitialized = true;
      console.log('[DistributedManager] 初始化完成');
    } catch (error) {
      console.error('[DistributedManager] 初始化失败:', error);
      throw new Error(String(error));
    }
  }

  async registerDeviceStateListener(): Promise<void> {
    try {
      if (this.deviceManager) {
        (this.deviceManager as distributedDeviceManager.DeviceManager).on('deviceStateChange', (data: object) => {
          console.log('[DistributedManager] 设备状态变化:', JSON.stringify(data));
        });
      }
    } catch (error) {
      console.error('[DistributedManager] 注册设备状态监听失败:', error);
    }
  }

  async discoverDevices(timeoutMs?: number): Promise<DeviceInfo[]> {
    if (!this.isInitialized) {
      await this.initialize();
    }

    const timeout: number = timeoutMs || 10000;

    try {
      console.log(`[DistributedManager] 开始发现设备，超时时间: ${timeoutMs || 10000}ms`);

      return new Promise<DeviceInfo[]>((resolve: Function, reject: Function) => {
        setTimeout(() => {
          try {
            const mockDevices: DeviceInfo[] = getMockDevices();
            console.log(`[DistributedManager] 发现 ${mockDevices.length} 台设备`);
            resolve(mockDevices);
          } catch (err) {
            reject(err);
          }
        }, Math.min(timeout, 1500));
      });
    } catch (error) {
      console.error('[DistributedManager] 发现设备失败:', error);
      return [];
    }
  }

  async pairDevice(deviceId: string, pinCode?: string): Promise<PairingResult> {
    if (!this.isInitialized) {
      await this.initialize();
    }

    try {
      console.log(`[DistributedManager] 开始配对设备: ${deviceId}`);
      const result: PairingResult = await this.devicePairingService.pairDevice(deviceId, pinCode);

      if (result.success) {
        console.log(`[DistributedManager] 设备配对成功: ${deviceId}`);
      } else {
        console.error(`[DistributedManager] 设备配对失败: ${result.message}`);
      }

      return result;
    } catch (error) {
      console.error('[DistributedManager] 配对设备异常:', error);
      return {
        success: false,
        message: '配对过程发生异常',
        errorCode: -1
      };
    }
  }

  async createDataStore(storeId: string): Promise<KVStore> {
    if (!this.isInitialized) {
      await this.initialize();
    }

    try {
      if (this.kvStores.has(storeId)) {
        console.log(`[DistributedManager] KVStore已存在: ${storeId}`);
        return this.kvStores.get(storeId)!;
      }

      console.log(`[DistributedManager] 创建分布式KVStore: ${storeId}`);

      const config: distributedKVStore.Options = {
        createIfMissing: true,
        encrypt: true,
        securityLevel: distributedKVStore.SecurityLevel.S1
      };

      const store: KVStore = new MockKVStore();

      this.kvStores.set(storeId, store);
      console.log(`[DistributedManager] KVStore创建成功: ${storeId}`);

      return store;
    } catch (error) {
      console.error('[DistributedManager] 创建KVStore失败:', error);
      throw new Error(String(error));
    }
  }

  async syncMedicalRecord(
    recordId: string,
    targetDeviceId: string,
    permissionLevel: PermissionLevel
  ): Promise<SyncResult> {
    if (!this.isInitialized) {
      await this.initialize();
    }

    const syncId: string = `SYNC_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;

    try {
      console.log(`[DistributedManager] 开始同步病历: ${recordId} -> ${targetDeviceId}`);
      console.log(`[DistributedManager] 权限级别: ${permissionLevel}, 同步ID: ${syncId}`);

      let desensitizeLevel: DesensitizeLevel;
      switch (permissionLevel) {
        case PermissionLevel.DOCTOR:
          desensitizeLevel = DesensitizeLevel.MINIMAL;
          break;
        case PermissionLevel.FAMILY:
          desensitizeLevel = DesensitizeLevel.FULL;
          break;
        case PermissionLevel.PATIENT:
          desensitizeLevel = DesensitizeLevel.FULL;
          break;
        default:
          desensitizeLevel = DesensitizeLevel.PARTIAL;
      }

      const medicalRecord = getMockMedicalRecord();

      const hasPermission: boolean = await this.permissionManager.checkPermission(
        recordId,
        targetDeviceId,
        permissionLevel
      );

      if (!hasPermission) {
        return {
          success: false,
          syncId: syncId,
          timestamp: Date.now(),
          targetDevice: targetDeviceId,
          error: '无权限访问该病历数据'
        };
      }

      const recordJson: string = JSON.stringify(medicalRecord);
      const desensitizedContent: string = DesensitizationUtil.desensitizeMedicalRecord(
        recordJson,
        desensitizeLevel
      );

      console.log('[DistributedManager] 病历脱敏完成');

      const encryptedData: string = await DesensitizationUtil.encryptData(
        desensitizedContent,
        this.currentAESKey
      );

      console.log('[DistributedManager] 病历加密完成');

      const storeId: string = `medical_record_${recordId}`;
      const kvStore: KVStore = await this.createDataStore(storeId);

      await kvStore.put(`record_${syncId}`, encryptedData);

      await this.dataTransferService.transferToTarget(targetDeviceId, encryptedData, syncId);

      const result: SyncResult = {
        success: true,
        syncId: syncId,
        timestamp: Date.now(),
        targetDevice: targetDeviceId
      };

      console.log(`[DistributedManager] 病历同步成功: ${syncId}`);
      return result;
    } catch (error) {
      console.error(`[DistributedManager] 病历同步失败 (${syncId}):`, error);
      return {
        success: false,
        syncId: syncId,
        timestamp: Date.now(),
        targetDevice: targetDeviceId,
        error: String(error)
      };
    }
  }

  async unpairDevice(deviceId: string): Promise<boolean> {
    try {
      console.log(`[DistributedManager] 解除配对设备: ${deviceId}`);
      return await this.devicePairingService.unpairDevice(deviceId);
    } catch (error) {
      console.error('[DistributedManager] 解除配对失败:', error);
      return false;
    }
  }

  getInitializationStatus(): boolean {
    return this.isInitialized;
  }

  getCurrentAESKey(): string {
    return this.currentAESKey;
  }

  async destroy(): Promise<void> {
    try {
      console.log('[DistributedManager] 销毁分布式管理器');

      this.kvStores.clear();
      this.currentAESKey = '';
      this.deviceManager = null;
      this.isInitialized = false;
      DistributedManager.instance = null;

      console.log('[DistributedManager] 销毁完成');
    } catch (error) {
      console.error('[DistributedManager] 销毁失败:', error);
    }
  }
}
