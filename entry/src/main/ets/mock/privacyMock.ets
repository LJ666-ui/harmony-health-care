import { BaseResponse } from '../common/utils/HttpUtil';
import { registerMockHandler, USE_MOCK } from './index';

export interface PrivacySetting {
  locationEnabled: boolean;
  healthDataEnabled: boolean;
  browseHistoryEnabled: boolean;
  diagnosticReportEnabled: boolean;
}

export interface AuthItem {
  id: string;
  name: string;
  type: 'DOCTOR' | 'DEVICE' | 'APP' | 'REHAB_CENTER' | 'NUTRITIONIST';
  dataType: string;
  status: 'active' | 'expired' | 'revoked';
  startDate: string;
  endDate: string;
}

export interface AccessLogItem {
  id: number;
  accessUser: string;
  accessType: string;
  dataType: string;
  action: string;
  accessTime: string;
  detail: string;
}

const mockPrivacySettings: PrivacySetting = {
  locationEnabled: true,
  healthDataEnabled: true,
  browseHistoryEnabled: true,
  diagnosticReportEnabled: false
};

const mockAuthItems: AuthItem[] = [
  {
    id: 'auth_001',
    name: '张医师',
    type: 'DOCTOR',
    dataType: '血压记录,血糖记录,体检报告',
    status: 'active',
    startDate: '2026-03-20 10:00:00',
    endDate: '2026-06-20 10:00:00'
  },
  {
    id: 'auth_002',
    name: '李康复中心',
    type: 'REHAB_CENTER',
    dataType: '康复计划,运动数据,睡眠数据',
    status: 'active',
    startDate: '2026-04-01 14:30:00',
    endDate: '2026-07-01 14:30:00'
  },
  {
    id: 'auth_003',
    name: '王营养师',
    type: 'NUTRITIONIST',
    dataType: '饮食记录,体重数据',
    status: 'revoked',
    startDate: '2026-02-15 09:00:00',
    endDate: '2026-05-15 09:00:00'
  },
  {
    id: 'auth_004',
    name: '智能手环Pro',
    type: 'DEVICE',
    dataType: '心率数据,血氧数据,运动步数',
    status: 'active',
    startDate: '2026-04-10 08:00:00',
    endDate: '2027-04-10 08:00:00'
  },
  {
    id: 'auth_005',
    name: '健康数据分析App',
    type: 'APP',
    dataType: '综合健康数据',
    status: 'expired',
    startDate: '2025-12-01 00:00:00',
    endDate: '2026-03-01 00:00:00'
  }
];

const mockAccessLogs: AccessLogItem[] = [
  {
    id: 1,
    accessUser: '张医师',
    accessType: 'DOCTOR',
    dataType: '血压记录',
    action: '读取',
    accessTime: '2026-04-20 09:15:32',
    detail: '查看最近7天血压数据'
  },
  {
    id: 2,
    accessUser: '系统',
    accessType: 'SYSTEM',
    dataType: '综合健康数据',
    action: '分析',
    accessTime: '2026-04-19 22:00:00',
    detail: 'AI自动分析健康趋势'
  },
  {
    id: 3,
    accessUser: '李康复中心',
    accessType: 'REHAB_CENTER',
    dataType: '运动步数',
    action: '同步',
    accessTime: '2026-04-19 16:45:18',
    detail: '同步今日运动数据'
  },
  {
    id: 4,
    accessUser: '张医师',
    accessType: 'DOCTOR',
    dataType: '血糖记录',
    action: '读取',
    accessTime: '2026-04-18 14:20:05',
    detail: '查看餐后血糖数据'
  },
  {
    id: 5,
    accessUser: '王营养师(已撤销)',
    accessType: 'NUTRITIONIST',
    dataType: '饮食记录',
    action: '访问被拒',
    accessTime: '2026-04-17 11:30:00',
    detail: '权限已被撤销'
  },
  {
    id: 6,
    accessUser: '智能手环Pro',
    accessType: 'DEVICE',
    dataType: '心率数据',
    action: '写入',
    accessTime: '2026-04-17 08:15:42',
    detail: '上传实时心率监测数据'
  },
  {
    id: 7,
    accessUser: '用户本人',
    accessType: 'USER',
    dataType: '隐私设置',
    action: '修改',
    accessTime: '2026-04-16 20:33:18',
    detail: '关闭诊断报告共享开关'
  },
  {
    id: 8,
    accessUser: '健康数据分析App',
    accessType: 'APP',
    dataType: '综合健康数据',
    action: '读取',
    accessTime: '2026-04-15 18:45:00',
    detail: '授权已过期，访问被拒'
  },
  {
    id: 9,
    accessUser: '张医师',
    accessType: 'DOCTOR',
    dataType: '体检报告',
    action: '读取',
    accessTime: '2026-04-15 10:00:00',
    detail: '查看年度体检报告'
  },
  {
    id: 10,
    accessUser: '李康复中心',
    accessType: 'REHAB_CENTER',
    dataType: '睡眠数据',
    action: '读取',
    accessTime: '2026-04-14 23:59:59',
    detail: '分析昨晚睡眠质量'
  }
];

if (USE_MOCK) {

  registerMockHandler('/privacy/settings', async () => {
    console.info('[PrivacyMock] GET /privacy/settings 返回隐私设置');
    return {
      success: true,
      message: '查询成功',
      code: 200,
      data: mockPrivacySettings
    } as BaseResponse<PrivacySetting>;
  });

  registerMockHandler('/privacy/settings', async (method: string, data?: Object) => {
    console.info('[PrivacyMock] PUT /privacy/settings 更新隐私设置');
    console.info('[PrivacyMock] 接收到的设置数据:', JSON.stringify(data));

    if (data && typeof data === 'object') {
      const settings = data as Record<string, Object>;
      if ('locationEnabled' in settings) {
        mockPrivacySettings.locationEnabled = settings['locationEnabled'] as boolean;
      }
      if ('healthDataEnabled' in settings) {
        mockPrivacySettings.healthDataEnabled = settings['healthDataEnabled'] as boolean;
      }
      if ('browseHistoryEnabled' in settings) {
        mockPrivacySettings.browseHistoryEnabled = settings['browseHistoryEnabled'] as boolean;
      }
      if ('diagnosticReportEnabled' in settings) {
        mockPrivacySettings.diagnosticReportEnabled = settings['diagnosticReportEnabled'] as boolean;
      }

      console.info('[PrivacyMock] 隐私设置已更新:',
        'location=' + mockPrivacySettings.locationEnabled,
        'health=' + mockPrivacySettings.healthDataEnabled,
        'browse=' + mockPrivacySettings.browseHistoryEnabled,
        'diagnostic=' + mockPrivacySettings.diagnosticReportEnabled);
    }

    return {
      success: true,
      message: '保存成功',
      code: 200,
      data: mockPrivacySettings
    } as BaseResponse<PrivacySetting>;
  }, 'PUT');

  registerMockHandler('/privacy/myAuths', async () => {
    console.info('[PrivacyMock] GET /privacy/myAuths 返回授权列表, 数量:', mockAuthItems.length);
    return {
      success: true,
      message: '查询成功',
      code: 200,
      data: mockAuthItems
    } as BaseResponse<AuthItem[]>;
  });

  registerMockHandler('/privacy/approve', async (method: string, data?: Object) => {
    console.info('[PrivacyMock] POST /privacy/approve 批准授权申请');
    console.info('[PrivacyMock] 请求数据:', JSON.stringify(data));

    if (!data || !Object.keys(data).length) {
      return {
        success: false,
        message: '缺少必要参数',
        code: 400
      } as BaseResponse<Object>;
    }

    const requestData = data as Record<string, Object>;
    const requestId = requestData['requestId'];
    const applicantName = requestData['applicantName'];
    const dataType = requestData['dataType'];

    console.info('[PrivacyMock] 批准授权: requestId=' + requestId +
      ' applicantName=' + applicantName +
      ' dataType=' + dataType);

    const newAuth: AuthItem = {
      id: 'auth_' + Date.now(),
      name: String(applicantName || '未知申请人'),
      type: 'DOCTOR',
      dataType: String(dataType || ''),
      status: 'active',
      startDate: new Date().toISOString().replace('T', ' ').substring(0, 19),
      endDate: new Date(Date.now() + 90 * 24 * 60 * 60 * 1000).toISOString().replace('T', ' ').substring(0, 19)
    };

    mockAuthItems.unshift(newAuth);

    const newLog: AccessLogItem = {
      id: mockAccessLogs.length + 1,
      accessUser: String(applicantName || '未知'),
      accessType: 'DOCTOR',
      dataType: String(dataType || ''),
      action: '授权批准',
      accessTime: new Date().toISOString().replace('T', ' ').substring(0, 19),
      detail: '用户批准了数据访问申请'
    };
    mockAccessLogs.unshift(newLog);

    console.info('[PrivacyMock] ✓ 授权已批准并添加到列表');

    return {
      success: true,
      message: '授权已批准',
      code: 200,
      data: { authId: newAuth.id }
    } as BaseResponse<Record<string, Object>>;
  });

  registerMockHandler('/privacy/revoke', async (method: string, params?: Record<string, string>) => {
    console.info('[PrivacyMock] POST /privacy/revoke 撤销授权');

    const authId = params?.['authId'];
    console.info('[PrivacyMock] 撤销的授权ID:', authId);

    if (!authId) {
      return {
        success: false,
        message: '缺少授权ID',
        code: 400
      } as BaseResponse<Object>;
    }

    let revokedItem: AuthItem | undefined;
    for (let i = 0; i < mockAuthItems.length; i++) {
      if (mockAuthItems[i].id === authId) {
        revokedItem = mockAuthItems[i];
        mockAuthItems[i].status = 'revoked';
        break;
      }
    }

    if (revokedItem) {
      const newLog: AccessLogItem = {
        id: mockAccessLogs.length + 1,
        accessUser: revokedItem.name,
        accessType: revokedItem.type,
        dataType: revokedItem.dataType,
        action: '撤销授权',
        accessTime: new Date().toISOString().replace('T', ' ').substring(0, 19),
        detail: '用户主动撤销了数据授权'
      };
      mockAccessLogs.unshift(newLog);

      console.info('[PrivacyMock] ✓ 授权已撤销: ' + revokedItem.name);

      return {
        success: true,
        message: '撤销成功',
        code: 200
      } as BaseResponse<Object>;
    } else {
      console.warn('[PrivacyMock] 未找到授权ID: ' + authId);
      return {
        success: false,
        message: '未找到该授权记录',
        code: 404
      } as BaseResponse<Object>;
    }
  });

  registerMockHandler('/privacy/accessLogs', async () => {
    console.info('[PrivacyMock] GET /privacy/accessLogs 返回审计日志, 数量:', mockAccessLogs.length);
    return {
      success: true,
      message: '查询成功',
      code: 200,
      data: mockAccessLogs
    } as BaseResponse<AccessLogItem[]>;
  });
}

export function getMockPrivacySettings(): PrivacySetting {
  return { ...mockPrivacySettings };
}

export function getMockAuthItems(): AuthItem[] {
  return [...mockAuthItems];
}

export function getMockAccessLogs(): AccessLogItem[] {
  return [...mockAccessLogs];
}
