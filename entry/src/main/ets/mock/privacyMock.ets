import { BaseResponse } from '../common/utils/HttpUtil';
import { registerMockHandler, USE_MOCK } from './index';

export interface PrivacySetting {
  id: number;
  key: string;
  label: string;
  description: string;
  value: boolean | string;
  category: string;
}

export interface AuthItem {
  id: number;
  targetName: string;
  targetType: string;
  authScope: string[];
  createTime: string;
  expireTime: string;
  status: 'active' | 'revoked' | 'expired';
}

export interface AccessLogItem {
  id: number;
  accessorName: string;
  accessType: string;
  accessTime: string;
  dataType: string;
  operation: string;
}

const mockPrivacySettings: PrivacySetting[] = [
  { id: 1, key: 'profile_visible', label: '个人资料可见', description: '控制其他用户是否可查看您的资料', value: true, category: 'basic' },
  { id: 2, key: 'health_data_share', label: '健康数据共享', description: '允许授权医生查看您的健康记录', value: false, category: 'data' },
  { id: 3, key: 'location_access', label: '位置信息访问', description: '允许应用获取位置以推荐附近医院', value: true, category: 'location' },
  { id: 4, key: 'browse_history', label: '浏览历史记录', description: '保存您的浏览记录用于个性化推荐', value: true, category: 'behavior' },
  { id: 5, key: 'ai_analysis', label: 'AI数据分析', description: '允许AI分析您的健康数据提供建议', value: true, category: 'data' }
];

const mockAuthItems: AuthItem[] = [
  { id: 1, targetName: '张医师', targetType: 'DOCTOR', authScope: ['健康记录', '体检报告'], createTime: '2026-03-20 10:00:00', expireTime: '2026-06-20 10:00:00', status: 'active' },
  { id: 2, targetName: '李康复中心', targetType: 'REHAB_CENTER', authScope: ['康复计划', '运动数据'], createTime: '2026-04-01 14:30:00', expireTime: '2026-07-01 14:30:00', status: 'active' },
  { id: 3, targetName: '王营养师', targetType: 'NUTRITIONIST', authScope: ['饮食记录', '体重数据'], createTime: '2026-02-15 09:00:00', expireTime: '2026-05-15 09:00:00', status: 'revoked' }
];

const mockAccessLogs: AccessLogItem[] = [
  { id: 1, accessorName: '张医师', accessType: '查看', accessTime: '2026-04-18 15:30:00', dataType: '血压记录', operation: 'READ' },
  { id: 2, accessorName: '系统', accessType: '分析', accessTime: '2026-04-18 12:00:00', dataType: '综合健康数据', operation: 'ANALYZE' },
  { id: 3, accessorName: '李康复中心', accessType: '同步', accessTime: '2026-04-17 16:45:00', dataType: '运动步数', operation: 'SYNC' },
  { id: 4, accessorName: '张医师', accessType: '查看', accessTime: '2026-04-17 10:20:00', dataType: '血糖记录', operation: 'READ' },
  { id: 5, accessorName: '王营养师(已撤销)', accessType: '访问被拒', accessTime: '2026-04-16 09:00:00', dataType: '饮食记录', operation: 'DENIED' }
];

if (USE_MOCK) {
  registerMockHandler('/privacy/settings', async () => ({
    success: true, message: '查询成功', code: 200, data: mockPrivacySettings
  }));
  registerMockHandler('/privacy/myAuths', async () => ({
    success: true, message: '查询成功', code: 200, data: mockAuthItems
  }));
  registerMockHandler('/privacy/accessLogs', async () => ({
    success: true, message: '查询成功', code: 200, data: mockAccessLogs
  }));
  registerMockHandler('/privacy/revokeAuth', async () => ({ success: true, message: '撤销成功', code: 200 }));
}

export function getMockPrivacySettings(): PrivacySetting[] {
  return mockPrivacySettings;
}
export function getMockAuthItems(): AuthItem[] {
  return mockAuthItems;
}
