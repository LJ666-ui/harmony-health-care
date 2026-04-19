import { BaseResponse } from '../common/utils/HttpUtil';
import { registerMockHandler, USE_MOCK } from './index';

export interface AncientImageItem {
  id: number;
  title: string;
  description: string;
  imageUrl: string;
  restoredImageUrl?: string;
  status: 'PENDING' | 'PROCESSING' | 'COMPLETED' | 'FAILED';
  category: string;
  dynasty: string;
  uploadTime: string;
  restoreTime?: string;
}

const mockAncientImages: AncientImageItem[] = [
  { id: 1, title: '《黄帝内经·素问》残页', description: '明代抄本残页，部分文字模糊需修复', imageUrl: '', restoredImageUrl: '', status: 'COMPLETED', category: '医经', dynasty: '明代', uploadTime: '2026-04-10 14:30:00', restoreTime: '2026-04-11 09:15:00' },
  { id: 2, title: '《伤寒论》手抄本', description: '清代手抄本，边缘破损严重', imageUrl: '', status: 'PROCESSING', category: '方书', dynasty: '清代', uploadTime: '2026-04-15 10:20:00' },
  { id: 3, title: '《本草纲目》插图', description: '彩色植物图谱，颜色褪色明显', imageUrl: '', restoredImageUrl: '', status: 'COMPLETED', category: '本草', dynasty: '明代', uploadTime: '2026-04-08 16:45:00', restoreTime: '2026-04-09 11:30:00' },
  { id: 4, title: '《针灸甲乙经》穴位图', description: '人体经络穴位图，线条断裂', imageUrl: '', status: 'PENDING', category: '针灸', dynasty: '宋代', uploadTime: '2026-04-18 09:00:00' },
  { id: 5, title: '《脉诀》诊脉图', description: '古代脉诊示意图，墨迹晕染', imageUrl: '', restoredImageUrl: '', status: 'COMPLETED', category: '诊断', dynasty: '元代', uploadTime: '2026-04-05 13:20:00', restoreTime: '2026-04-06 08:45:00' },
  { id: 6, title: '《金匮要略》药方页', description: '张仲景方剂记录页，字迹漫漶', imageUrl: '', status: 'FAILED', category: '方书', dynasty: '宋代', uploadTime: '2026-04-12 11:10:00' }
];

function findImageById(id: number): AncientImageItem | undefined {
  for (let i = 0; i < mockAncientImages.length; i++) {
    if (mockAncientImages[i].id === id) { return mockAncientImages[i]; }
  }
  return undefined;
}

if (USE_MOCK) {
  registerMockHandler('/ancient-image/list', async (url, data, params) => {
    let pg = 1, sz = 10;
    if (params) {
      const p = params as Record<string, Object>;
      if (p['page']) { pg = Number(p['page']); }
      if (p['size']) { sz = Number(p['size']); }
    }
    return {
      success: true, message: '查询成功', code: 200,
      data: { records: mockAncientImages.slice((pg - 1) * sz, pg * sz), total: mockAncientImages.length, page: pg, size: sz }
    };
  });

  registerMockHandler('/ancient-image/detail/', async (url) => {
    const parts = url.split('/');
    const idStr = parts[parts.length - 1];
    if (!idStr || idStr.length === 0) { return { success: false, message: '无效请求', code: 400 }; }
    const id = parseInt(idStr);
    const img = findImageById(id);
    return { success: !!img, message: img ? '查询成功' : '图像不存在', code: img ? 200 : 404, data: img || null };
  });

  registerMockHandler('/ancient-image/upload', async () => ({
    success: true, message: '上传成功', code: 200,
    data: { id: mockAncientImages.length + 1, status: 'PENDING', uploadTime: new Date().toISOString() }
  }));

  registerMockHandler('/ancient-image/restore', async (url, data, params) => {
    let imageId = 0;
    if (params) {
      const p = params as Record<string, Object>;
      if (p['imageId']) { imageId = Number(p['imageId']); }
    }
    return {
      success: true, message: '已启动图像复原任务', code: 200,
      data: { imageId: imageId, taskId: 'task_' + Date.now(), estimatedTime: '约30分钟' }
    };
  });
}

export function getMockAncientImages(): AncientImageItem[] {
  return mockAncientImages;
}
