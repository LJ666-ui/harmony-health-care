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
  { id: 6, title: '《金匮要略》药方页', description: '张仲景方剂记录页，字迹漫漶', imageUrl: '', status: 'FAILED', category: '方书', dynasty: '宋代', uploadTime: '2026-04-12 11:10:00' },
  { id: 7, title: '《千金要方》插图', description: '孙思邈医学巨著插图，保存较好', imageUrl: '', restoredImageUrl: '', status: 'COMPLETED', category: '方书', dynasty: '唐代', uploadTime: '2026-04-03 15:30:00', restoreTime: '2026-04-04 10:20:00' },
  { id: 8, title: '《神农本草经》图谱', description: '最早的本草专著图谱，残损严重', imageUrl: '', status: 'PENDING', category: '本草', dynasty: '汉代', uploadTime: '2026-04-20 08:45:00' }
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

/**
 * 获取Mock医学术语词典
 */
export function getMockMedicalTerms(): string[] {
  return [
    // 穴位名
    '合谷', '足三里', '百会', '涌泉', '内关', '外关', '曲池', '三阴交',
    '关元', '气海', '中脘', '膻中', '命门', '肾俞', '肺俞', '肝俞',
    // 药名
    '人参', '黄芪', '当归', '白术', '茯苓', '甘草', '川芎', '白芍',
    '熟地', '生地', '桂枝', '麻黄', '杏仁', '石膏', '黄芩', '黄连',
    '大黄', '芒硝', '半夏', '陈皮', '枳实', '厚朴', '柴胡', '葛根',
    // 病症名
    '感冒', '咳嗽', '发热', '头痛', '眩晕', '失眠', '心悸', '胸痹',
    '胃痛', '腹痛', '泄泻', '便秘', '黄疸', '水肿', '淋证', '消渴',
    // 经络名
    '手太阴肺经', '手阳明大肠经', '足阳明胃经', '足太阴脾经',
    '手少阴心经', '手太阳小肠经', '足太阳膀胱经', '足少阴肾经',
    '手厥阴心包经', '手少阳三焦经', '足少阳胆经', '足厥阴肝经',
    // 其他术语
    '气虚', '血虚', '阴虚', '阳虚', '气滞', '血瘀', '痰湿', '湿热'
  ];
}

/**
 * 获取Mock古籍来源信息
 */
export function getMockSourceBooks(): Array<{ name: string; author: string; dynasty: string; year: number }> {
  return [
    { name: '黄帝内经', author: '佚名', dynasty: '战国', year: -300 },
    { name: '伤寒论', author: '张仲景', dynasty: '东汉', year: 200 },
    { name: '金匮要略', author: '张仲景', dynasty: '东汉', year: 200 },
    { name: '神农本草经', author: '佚名', dynasty: '汉代', year: -100 },
    { name: '本草纲目', author: '李时珍', dynasty: '明代', year: 1578 },
    { name: '针灸甲乙经', author: '皇甫谧', dynasty: '晋代', year: 282 },
    { name: '千金要方', author: '孙思邈', dynasty: '唐代', year: 652 },
    { name: '脉诀', author: '王叔和', dynasty: '晋代', year: 280 }
  ];
}
