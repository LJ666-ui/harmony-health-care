import { BaseResponse } from '../common/utils/HttpUtil';
import { registerMockHandler, USE_MOCK } from './index';

export interface ArticleItem {
  id: number;
  title: string;
  summary: string;
  coverImage: string;
  categoryId: number;
  categoryName: string;
  author: string;
  readCount: number;
  isCollected: boolean;
  createTime: string;
}

export interface ArticleCategory {
  id: number;
  name: string;
  icon: string;
  count: number;
}

const mockArticles: ArticleItem[] = [
  {
    id: 1,
    title: '中医养生：四季调养之道',
    summary: '根据春夏秋冬四季节气变化，调整饮食起居，达到养生保健的目的。春季养肝、夏季养心、秋季养肺、冬季养肾...',
    coverImage: '',
    categoryId: 1,
    categoryName: '中医养生',
    author: '张医师',
    readCount: 1523,
    isCollected: false,
    createTime: '2026-04-15 10:00:00'
  },
  {
    id: 2,
    title: '高血压患者的饮食指南',
    summary: '控制盐摄入量，每日不超过6克；多吃富含钾的食物如香蕉、土豆；限制脂肪和胆固醇摄入...',
    coverImage: '',
    categoryId: 2,
    categoryName: '慢病管理',
    author: '李营养师',
    readCount: 2341,
    isCollected: true,
    createTime: '2026-04-14 14:30:00'
  },
  {
    id: 3,
    title: '老年人跌倒预防与康复训练',
    summary: '跌倒是老年人常见的意外伤害之一。通过平衡训练、肌力增强和环境改善可有效预防...',
    coverImage: '',
    categoryId: 3,
    categoryName: '康复指导',
    author: '王康复师',
    readCount: 987,
    isCollected: false,
    createTime: '2026-04-13 09:15:00'
  },
  {
    id: 4,
    title: '糖尿病饮食管理的五个原则',
    summary: '1. 控制总热量输入 2. 定时定量进餐 3. 选择低GI食物 4. 增加膳食纤维 5. 限制精制糖...',
    coverImage: '',
    categoryId: 2,
    categoryName: '慢病管理',
    author: '赵内分泌科',
    readCount: 3102,
    isCollected: true,
    createTime: '2026-04-12 16:45:00'
  },
  {
    id: 5,
    title: '太极拳对心血管健康的益处',
    summary: '研究表明，长期练习太极拳可降低血压、改善心肺功能、减少心血管疾病风险...',
    coverImage: '',
    categoryId: 4,
    categoryName: '运动健康',
    author: '陈教练',
    readCount: 1756,
    isCollected: false,
    createTime: '2026-04-11 11:20:00'
  },
  {
    id: 6,
    title: '失眠的中医疗法：穴位按摩与药膳调理',
    summary: '失眠多因心神不宁所致。推荐神门穴、内关穴按摩配合酸枣仁汤调理...',
    coverImage: '',
    categoryId: 1,
    categoryName: '中医养生',
    author: '孙中医师',
    readCount: 2234,
    isCollected: false,
    createTime: '2026-04-10 08:30:00'
  },
  {
    id: 7,
    title: '骨质疏松症的早期识别与预防',
    summary: '骨质疏松早期症状不明显，建议50岁以上人群定期检测骨密度。预防措施包括补钙、维生素D和适量运动...',
    coverImage: '',
    categoryId: 5,
    categoryName: '老年健康',
    author: '周骨科',
    readCount: 1456,
    isCollected: true,
    createTime: '2026-04-09 13:00:00'
  },
  {
    id: 8,
    title: '中药煎煮的正确方法',
    summary: '中药材需先用冷水浸泡30分钟，大火煮沸后转小火煎煮20-30分钟。特殊药材需特殊处理...',
    coverImage: '',
    categoryId: 1,
    categoryName: '中医养生',
    author: '吴药师',
    readCount: 1890,
    isCollected: false,
    createTime: '2026-04-08 10:45:00'
  }
];

const mockCategories: ArticleCategory[] = [
  { id: 1, name: '中医养生', icon: '\ud83c\udf3f', count: 24 },
  { id: 2, name: '慢病管理', icon: '\ud83d\udc8a', count: 18 },
  { id: 3, name: '康复指导', icon: '\ud83c\udfc3', count: 12 },
  { id: 4, name: '运动健康', icon: '\ud83d\udcaa', count: 15 },
  { id: 5, name: '老年健康', icon: '\ud83d\udc74', count: 9 }
];

function findArticleById(id: number): ArticleItem | undefined {
  for (let i = 0; i < mockArticles.length; i++) {
    if (mockArticles[i].id === id) {
      return mockArticles[i];
    }
  }
  return undefined;
}

function filterCollectedArticles(): ArticleItem[] {
  const result: ArticleItem[] = [];
  for (let i = 0; i < mockArticles.length; i++) {
    if (mockArticles[i].isCollected) {
      result.push(mockArticles[i]);
    }
  }
  return result;
}

if (USE_MOCK) {
  registerMockHandler('/healthArticle/page', async (url, data, params) => {
    let pageVal = 1;
    let sizeVal = 8;
    if (params) {
      const p = params as Record<string, Object>;
      if (p['page']) {
        pageVal = Number(p['page']);
      }
      if (p['size']) {
        sizeVal = Number(p['size']);
      }
    }
    const start = (pageVal - 1) * sizeVal;
    const end = start + sizeVal;

    const pageData = {
      records: mockArticles.slice(start, end),
      total: mockArticles.length,
      page: pageVal,
      size: sizeVal
    };

    return {
      success: true,
      message: '查询成功',
      code: 200,
      data: pageData
    };
  });

  registerMockHandler('/healthArticle/list', async () => {
    return {
      success: true,
      message: '查询成功',
      code: 200,
      data: mockArticles
    };
  });

  registerMockHandler('/healthArticle/detail/', async (url) => {
    const parts = url.split('/');
    const lastPart = parts[parts.length - 1];
    const id = parseInt(lastPart);
    const article = findArticleById(id);
    return {
      success: !!article,
      message: article ? '查询成功' : '文章不存在',
      code: article ? 200 : 404,
      data: article || null
    };
  });

  registerMockHandler('/healthArticle/categories/parent', async () => {
    return {
      success: true,
      message: '查询成功',
      code: 200,
      data: mockCategories
    };
  });

  registerMockHandler('/api/article/my-collects', async () => {
    const collected = filterCollectedArticles();
    return {
      success: true,
      message: '查询成功',
      code: 200,
      data: collected
    };
  });
}

export function getMockArticles(): ArticleItem[] {
  return mockArticles;
}

export function getMockCategories(): ArticleCategory[] {
  return mockCategories;
}
