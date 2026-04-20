import { BaseResponse } from '../common/utils/HttpUtil';
import { registerMockHandler, USE_MOCK, CallbackHandler } from './index';

export interface DeviceInfo {
  deviceId: string;
  deviceName: string;
  deviceType: string;
  deviceModel: string;
  status: 'online' | 'offline' | 'error';
  batteryLevel: number;
  lastSyncTime: string;
  isBound: boolean;
  distance: number;
  signalStrength: number;
  rssi: number;
}

export interface BoundDevice extends DeviceInfo {
  bindTime: string;
  dataCount: number;
  dataPermission: 'allowed' | 'denied';
  permissionTypes: string[];
}

export interface DeviceDiscoverItem {
  id: string;
  deviceId: string;
  deviceName: string;
  deviceType: string;
  deviceModel: string;
  isOnline: boolean;
  signalStrength: number;
  distance: number;
  rssi: number;
}

interface BindResult {
  deviceId: string;
  bindTime: string;
}

interface SyncResult {
  syncCount: number;
  syncTime: string;
}

interface PermissionResult {
  deviceId: string;
  permission: string;
}

interface PermissionDetailResult {
  deviceId: string;
  deviceName: string;
  dataPermission: string;
  permissionTypes: string[];
}

interface EmptyResult {}

const mockDevices: DeviceInfo[] = [
  { deviceId: 'DEV001', deviceName: '智能血压计', deviceType: '血压监测仪', deviceModel: 'HM-BP100', status: 'online', batteryLevel: 85, lastSyncTime: '2026-04-19 08:30:00', isBound: true, distance: 1.2, signalStrength: 95, rssi: -45 },
  { deviceId: 'DEV002', deviceName: '血糖仪', deviceType: '血糖监测仪', deviceModel: 'HM-GL200', status: 'online', batteryLevel: 92, lastSyncTime: '2026-04-19 07:15:00', isBound: true, distance: 2.5, signalStrength: 88, rssi: -52 },
  { deviceId: 'DEV003', deviceName: '智能手环', deviceType: '智能手环', deviceModel: 'HM-Band3', status: 'offline', batteryLevel: 30, lastSyncTime: '2026-04-18 22:00:00', isBound: true, distance: 5.0, signalStrength: 0, rssi: -85 },
  { deviceId: 'DEV004', deviceName: '体重秤', deviceType: '体重秤', deviceModel: 'HM-WS50', status: 'online', batteryLevel: 100, lastSyncTime: '2026-04-19 06:45:00', isBound: false, distance: 3.8, signalStrength: 75, rssi: -62 },
  { deviceId: 'DEV005', deviceName: '血氧仪', deviceType: '血氧监测仪', deviceModel: 'HM-OX10', status: 'error', batteryLevel: 0, lastSyncTime: '2026-04-17 10:00:00', isBound: false, distance: 8.2, signalStrength: 30, rssi: -78 },
  { deviceId: 'DEV006', deviceName: '体温计', deviceType: '体温计', deviceModel: 'HM-Temp20', status: 'online', batteryLevel: 78, lastSyncTime: '2026-04-19 09:00:00', isBound: false, distance: 1.8, signalStrength: 90, rssi: -48 },
  { deviceId: 'DEV007', deviceName: '睡眠监测器', deviceType: '睡眠监测器', deviceModel: 'HM-Sleep15', status: 'online', batteryLevel: 65, lastSyncTime: '2026-04-19 08:00:00', isBound: false, distance: 4.2, signalStrength: 70, rssi: -65 }
];

function buildBoundDevices(): BoundDevice[] {
  const result: BoundDevice[] = [];
  for (let i = 0; i < mockDevices.length; i++) {
    const d = mockDevices[i];
    if (d.isBound) {
      result.push({
        deviceId: d.deviceId,
        deviceName: d.deviceName,
        deviceType: d.deviceType,
        deviceModel: d.deviceModel,
        status: d.status,
        batteryLevel: d.batteryLevel,
        lastSyncTime: d.lastSyncTime,
        isBound: d.isBound,
        distance: d.distance,
        signalStrength: d.signalStrength,
        rssi: d.rssi,
        bindTime: '2026-03-15 10:00:00',
        dataCount: Math.floor(Math.random() * 200) + 50,
        dataPermission: i % 2 === 0 ? 'allowed' : 'denied',
        permissionTypes: ['血压数据', '心率数据', '血氧数据', '睡眠数据'].slice(0, Math.floor(Math.random() * 4) + 1)
      });
    }
  }
  return result;
}

function buildDiscoverDevices(): DeviceDiscoverItem[] {
  const result: DeviceDiscoverItem[] = [];
  for (let i = 0; i < mockDevices.length; i++) {
    const d = mockDevices[i];
    if (!d.isBound) {
      result.push({
        id: d.deviceId,
        deviceId: d.deviceId,
        deviceName: d.deviceName,
        deviceType: d.deviceType,
        deviceModel: d.deviceModel,
        isOnline: d.status === 'online',
        signalStrength: d.signalStrength,
        distance: d.distance,
        rssi: d.rssi
      });
    }
  }
  return result;
}

function filterOnlineDevices(): DeviceInfo[] {
  const result: DeviceInfo[] = [];
  for (let i = 0; i < mockDevices.length; i++) {
    if (mockDevices[i].status === 'online') {
      result.push(mockDevices[i]);
    }
  }
  return result;
}

function filterUnboundDevices(): DeviceInfo[] {
  const result: DeviceInfo[] = [];
  for (let i = 0; i < mockDevices.length; i++) {
    if (!mockDevices[i].isBound) {
      result.push(mockDevices[i]);
    }
  }
  return result;
}

const mockBoundDevices: BoundDevice[] = buildBoundDevices();
const mockDiscoverDevices: DeviceDiscoverItem[] = buildDiscoverDevices();

if (USE_MOCK) {
  registerMockHandler<DeviceDiscoverItem[]>('/api/device/discover', new CallbackHandler<DeviceDiscoverItem[]>(
    async (_url: string, _data?: object, _params?: Object): Promise<BaseResponse<DeviceDiscoverItem[]>> => {
      return makeResponse<DeviceDiscoverItem[]>(true, '查询成功', 200, mockDiscoverDevices);
    }
  ));

  registerMockHandler<BindResult>('/api/device/bind', new CallbackHandler<BindResult>(
    async (_url: string, data?: object, _params?: Object): Promise<BaseResponse<BindResult>> => {
      const bd = data as Record<string, Object>;
      const deviceId = String(bd['deviceId'] || '');
      const bindResult: BindResult = { deviceId: deviceId, bindTime: new Date().toISOString() };
      return makeResponse<BindResult>(true, '绑定成功', 200, bindResult);
    }
  ));

  registerMockHandler<EmptyResult>('/api/device/unbind', new CallbackHandler<EmptyResult>(
    async (_url: string, _data?: object, _params?: Object): Promise<BaseResponse<EmptyResult>> => {
      return makeResponse<EmptyResult>(true, '解绑成功', 200, {} as EmptyResult);
    }
  ));

  registerMockHandler<DeviceInfo[]>('/device/discover', new CallbackHandler<DeviceInfo[]>(
    async (_url: string, _data?: object, _params?: Object): Promise<BaseResponse<DeviceInfo[]>> => {
      return makeResponse<DeviceInfo[]>(true, '查询成功', 200, filterUnboundDevices());
    }
  ));
  registerMockHandler<BoundDevice[]>('/device/list', new CallbackHandler<BoundDevice[]>(
    async (_url: string, _data?: object, _params?: Object): Promise<BaseResponse<BoundDevice[]>> => {
      return makeResponse<BoundDevice[]>(true, '查询成功', 200, mockBoundDevices);
    }
  ));
  registerMockHandler<DeviceInfo[]>('/device/online', new CallbackHandler<DeviceInfo[]>(
    async (_url: string, _data?: object, _params?: Object): Promise<BaseResponse<DeviceInfo[]>> => {
      return makeResponse<DeviceInfo[]>(true, '查询成功', 200, filterOnlineDevices());
    }
  ));
  registerMockHandler<BindResult>('/device/bind', new CallbackHandler<BindResult>(
    async (_url: string, data?: object, _params?: Object): Promise<BaseResponse<BindResult>> => {
      const bd = data as Record<string, Object>;
      const bindResult: BindResult = { deviceId: String(bd['deviceId'] || ''), bindTime: new Date().toISOString() };
      return makeResponse<BindResult>(true, '绑定成功', 200, bindResult);
    }
  ));
  registerMockHandler<EmptyResult>('/device/unbind', new CallbackHandler<EmptyResult>(
    async (_url: string, _data?: object, _params?: Object): Promise<BaseResponse<EmptyResult>> => {
      return makeResponse<EmptyResult>(true, '解绑成功', 200, {} as EmptyResult);
    }
  ));
  registerMockHandler<SyncResult>('/device/sync', new CallbackHandler<SyncResult>(
    async (_url: string, _data?: object, _params?: Object): Promise<BaseResponse<SyncResult>> => {
      const syncResult: SyncResult = { syncCount: Math.floor(Math.random() * 20) + 1, syncTime: new Date().toISOString() };
      return makeResponse<SyncResult>(true, '同步成功', 200, syncResult);
    }
  ));

  registerMockHandler<PermissionResult>('/device/permission/set', new CallbackHandler<PermissionResult>(
    async (_url: string, data?: object, _params?: Object): Promise<BaseResponse<PermissionResult>> => {
      const pd = data as Record<string, Object>;
      const deviceId = String(pd['deviceId'] || '');
      const permission = String(pd['permission'] || 'allowed');
      const permResult: PermissionResult = { deviceId: deviceId, permission: permission };
      return makeResponse<PermissionResult>(true, '权限设置成功', 200, permResult);
    }
  ));

  registerMockHandler<PermissionDetailResult>('/device/permission/get', new CallbackHandler<PermissionDetailResult>(
    async (_url: string, _data?: object, params?: Object): Promise<BaseResponse<PermissionDetailResult>> => {
      const p = params as Record<string, Object>;
      const deviceId = String(p['deviceId'] || '');
      const device = mockBoundDevices.find(d => d.deviceId === deviceId);
      if (device) {
        const detailResult: PermissionDetailResult = {
          deviceId: device.deviceId,
          deviceName: device.deviceName,
          dataPermission: device.dataPermission,
          permissionTypes: device.permissionTypes
        };
        return makeResponse<PermissionDetailResult>(true, '查询成功', 200, detailResult);
      }
      return makeResponse<PermissionDetailResult>(false, '设备未找到', 404, {} as PermissionDetailResult);
    }
  ));
}

function makeResponse<T>(success: boolean, message: string, code: number, data: T): BaseResponse<T> {
  const result: BaseResponse<T> = { success: success, message: message, code: code, data: data };
  return result;
}

export function getMockDevices(): DeviceInfo[] {
  return mockDevices;
}
