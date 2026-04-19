import { BaseResponse } from '../common/utils/HttpUtil';
import { registerMockHandler, USE_MOCK } from './index';

export interface DeviceInfo {
  deviceId: string;
  deviceName: string;
  deviceType: string;
  status: 'online' | 'offline' | 'error';
  batteryLevel: number;
  lastSyncTime: string;
  isBound: boolean;
}

export interface BoundDevice extends DeviceInfo {
  bindTime: string;
  dataCount: number;
}

const mockDevices: DeviceInfo[] = [
  { deviceId: 'DEV001', deviceName: '智能血压计', deviceType: 'BLOOD_PRESSURE', status: 'online', batteryLevel: 85, lastSyncTime: '2026-04-19 08:30:00', isBound: true },
  { deviceId: 'DEV002', deviceName: '血糖仪', deviceType: 'BLOOD_GLUCOSE', status: 'online', batteryLevel: 92, lastSyncTime: '2026-04-19 07:15:00', isBound: true },
  { deviceId: 'DEV003', deviceName: '智能手环', deviceType: 'SMART_BAND', status: 'offline', batteryLevel: 30, lastSyncTime: '2026-04-18 22:00:00', isBound: true },
  { deviceId: 'DEV004', deviceName: '体重秤', deviceType: 'WEIGHT_SCALE', status: 'online', batteryLevel: 100, lastSyncTime: '2026-04-19 06:45:00', isBound: false },
  { deviceId: 'DEV005', deviceName: '血氧仪', deviceType: 'OXIMETER', status: 'error', batteryLevel: 0, lastSyncTime: '2026-04-17 10:00:00', isBound: false }
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
        status: d.status,
        batteryLevel: d.batteryLevel,
        lastSyncTime: d.lastSyncTime,
        isBound: d.isBound,
        bindTime: '2026-03-15 10:00:00',
        dataCount: Math.floor(Math.random() * 200) + 50
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

if (USE_MOCK) {
  registerMockHandler('/device/discover', async () => ({
    success: true, message: '查询成功', code: 200, data: filterUnboundDevices()
  }));
  registerMockHandler('/device/list', async () => ({
    success: true, message: '查询成功', code: 200, data: mockBoundDevices
  }));
  registerMockHandler('/device/online', async () => ({
    success: true, message: '查询成功', code: 200, data: filterOnlineDevices()
  }));
  registerMockHandler('/device/bind', async (url, data) => {
    const bd = data as Record<string, Object>;
    return { success: true, message: '绑定成功', code: 200, data: { deviceId: String(bd['deviceId'] || ''), bindTime: new Date().toISOString() } };
  });
  registerMockHandler('/device/unbind', async () => ({ success: true, message: '解绑成功', code: 200 }));
  registerMockHandler('/device/sync', async () => ({
    success: true, message: '同步成功', code: 200, data: { syncCount: Math.floor(Math.random() * 20) + 1, syncTime: new Date().toISOString() }
  }));
}

export function getMockDevices(): DeviceInfo[] {
  return mockDevices;
}
