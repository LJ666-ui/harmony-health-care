import { BaseResponse } from '../common/utils/HttpUtil';
import { registerMockHandler, USE_MOCK } from './index';

export interface BackendHealthRecord {
  id: number;
  userId: number;
  recordType: string;
  recordDate: string;
  value: string | number;
  unit: string;
  notes: string;
  createTime: string;
}

const mockHealthRecords: BackendHealthRecord[] = [
  { id: 1, userId: 1, recordType: 'BLOOD_PRESSURE', recordDate: '2026-04-19', value: '135/85', unit: 'mmHg', notes: '晨起测量', createTime: '2026-04-19 07:30:00' },
  { id: 2, userId: 1, recordType: 'BLOOD_PRESSURE', recordDate: '2026-04-18', value: '128/82', unit: 'mmHg', notes: '', createTime: '2026-04-18 07:25:00' },
  { id: 3, userId: 1, recordType: 'BLOOD_GLUCOSE', recordDate: '2026-04-19', value: 6.2, unit: 'mmol/L', notes: '空腹', createTime: '2026-04-19 06:30:00' },
  { id: 4, userId: 1, recordType: 'BLOOD_GLUCOSE', recordDate: '2026-04-18', value: 7.8, unit: 'mmol/L', notes: '餐后2小时', createTime: '2026-04-18 12:30:00' },
  { id: 5, userId: 1, recordType: 'WEIGHT', recordDate: '2026-04-19', value: 68.5, unit: 'kg', notes: '', createTime: '2026-04-19 08:00:00' },
  { id: 6, userId: 1, recordType: 'HEART_RATE', recordDate: '2026-04-19', value: 72, unit: 'bpm', notes: '静息心率', createTime: '2026-04-19 08:05:00' },
  { id: 7, userId: 1, recordType: 'SLEEP_DURATION', recordDate: '2026-04-18', value: 6.5, unit: 'h', notes: '睡眠质量一般', createTime: '2026-04-19 07:00:00' },
  { id: 8, userId: 1, recordType: 'STEPS', recordDate: '2026-04-18', value: 6520, unit: '步', notes: '', createTime: '2026-04-18 22:00:00' }
];

function filterByType(type: string): BackendHealthRecord[] {
  const r: BackendHealthRecord[] = [];
  for (let i = 0; i < mockHealthRecords.length; i++) {
    if (mockHealthRecords[i].recordType === type) {
      r.push(mockHealthRecords[i]);
    }
  }
  return r;
}

if (USE_MOCK) {
  registerMockHandler('/healthRecord/my', async (url, data, params) => {
    let typeStr = '';
    let lim = 10;
    if (params) {
      const p = params as Record<string, Object>;
      if (p['type']) { typeStr = String(p['type']); }
      if (p['limit']) { lim = Number(p['limit']); }
    }
    let filtered = typeStr.length > 0 ? filterByType(typeStr) : mockHealthRecords;
    return { success: true, message: '查询成功', code: 200, data: filtered.slice(0, lim) };
  });
  registerMockHandler('/healthRecord/add', async (url, data) => {
    const d = data as Record<string, Object>;
    return {
      success: true, message: '添加成功', code: 200,
      data: {
        id: mockHealthRecords.length + 1, userId: 1,
        recordType: String(d['recordType'] || ''), recordDate: String(d['recordDate'] || ''),
        value: d['value'] as string | number, unit: String(d['unit'] || ''),
        notes: String(d['notes'] || ''), createTime: new Date().toISOString()
      }
    };
  });
  registerMockHandler('/healthRecord/page', async (url, data, params) => {
    let pg = 1, sz = 10;
    if (params) {
      const p = params as Record<string, Object>;
      if (p['page']) { pg = Number(p['page']); }
      if (p['size']) { sz = Number(p['size']); }
    }
    return {
      success: true, message: '查询成功', code: 200,
      data: { records: mockHealthRecords.slice((pg - 1) * sz, pg * sz), total: mockHealthRecords.length, page: pg, size: sz }
    };
  });
}

export function getMockHealthRecords(): BackendHealthRecord[] {
  return mockHealthRecords;
}
