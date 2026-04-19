import { BaseResponse } from '../common/utils/HttpUtil';
import { registerMockHandler, USE_MOCK } from './index';

export interface FoodItem {
  id: number;
  name: string;
  category: string;
  efficacy: string[];
  nutrition: Record<string, string>;
  suitableFor: string[];
  avoidFor: string[];
  recipe: string;
  isCollected: boolean;
}

const mockFoods: FoodItem[] = [
  {
    id: 1,
    name: '山药粥',
    category: '药膳粥品',
    efficacy: ['健脾益胃', '补肺益肾', '降低血糖'],
    nutrition: { '热量': '85kcal/100g', '蛋白质': '1.9g', '碳水': '18.2g', '纤维': '0.8g' },
    suitableFor: ['脾胃虚弱', '糖尿病', '慢性腹泻'],
    avoidFor: ['便秘严重者'],
    recipe: '鲜山药100g切丁，大米50g，加水煮粥，早晚温服',
    isCollected: false
  },
  {
    id: 2,
    name: '红枣枸杞茶',
    category: '养生茶饮',
    efficacy: ['补血养颜', '安神助眠', '增强免疫'],
    nutrition: { '热量': '35kcal/杯', '维生素C': '丰富', '铁': '适量' },
    suitableFor: ['贫血', '失眠', '体虚'],
    avoidFor: ['糖尿病患者', '湿热体质'],
    recipe: '红枣5枚去核，枸杞10g，沸水冲泡代茶饮',
    isCollected: true
  },
  {
    id: 3,
    name: '银耳莲子羹',
    category: '滋补甜品',
    efficacy: ['滋阴润肺', '美容养颜', '润肠通便'],
    nutrition: { '热量': '65kcal/100g', '胶原蛋白': '丰富', '膳食纤维': '3g' },
    suitableFor: ['干咳', '皮肤干燥', '便秘'],
    avoidFor: ['风寒咳嗽', '腹泻'],
    recipe: '银耳15g泡发撕碎，莲子20g去心，冰糖适量，炖煮1小时至胶状',
    isCollected: true
  },
  {
    id: 4,
    name: '当归生姜羊肉汤',
    category: '温补汤膳',
    efficacy: ['温中补血', '祛寒止痛', '调经散寒'],
    nutrition: { '热量': '180kcal/100g', '蛋白质': '18g', '脂肪': '12g' },
    suitableFor: ['血虚寒凝', '痛经', '产后虚寒'],
    avoidFor: ['阴虚火旺', '发热患者'],
    recipe: '羊肉500g切块焯水，当归10g，生姜30g，小火慢炖2小时',
    isCollected: false
  },
  {
    id: 5,
    name: '菊花决明子茶',
    category: '养生茶饮',
    efficacy: ['清肝明目', '降压降脂', '润肠通便'],
    nutrition: { '热量': '5kcal/杯', '黄酮类': '丰富' },
    suitableFor: ['高血压', '高血脂', '用眼过度'],
    avoidFor: ['低血压', '腹泻', '脾胃虚寒'],
    recipe: '菊花5g，决明子10g，沸水冲泡焖10分钟饮用',
    isCollected: false
  },
  {
    id: 6,
    name: '百合绿豆汤',
    category: '清热解暑',
    efficacy: ['清热解毒', '安神除烦', '消暑止渴'],
    nutrition: { '热量': '45kcal/100g', '维生素B': '丰富' },
    suitableFor: ['暑热烦渴', '心烦失眠', '疮疡肿毒'],
    avoidFor: ['脾胃虚寒', '腹泻者'],
    recipe: '百合30g，绿豆50g，冰糖适量，煮至豆烂即可',
    isCollected: true
  }
];

function findFoodById(id: number): FoodItem | undefined {
  for (let i = 0; i < mockFoods.length; i++) {
    if (mockFoods[i].id === id) {
      return mockFoods[i];
    }
  }
  return undefined;
}

if (USE_MOCK) {
  registerMockHandler('/healthFood/page', async (url, data, params) => {
    let pageVal = 1;
    let sizeVal = 6;
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

    const pageData = {
      records: mockFoods.slice(start, start + sizeVal),
      total: mockFoods.length,
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

  registerMockHandler('/healthFood/list', async () => {
    return {
      success: true,
      message: '查询成功',
      code: 200,
      data: mockFoods
    };
  });

  registerMockHandler('/healthFood/detail/', async (url) => {
    const parts = url.split('/');
    const lastPart = parts[parts.length - 1];
    const id = parseInt(lastPart);
    const food = findFoodById(id);
    return {
      success: !!food,
      message: food ? '查询成功' : '食材不存在',
      code: food ? 200 : 404,
      data: food || null
    };
  });
}

export function getMockFoods(): FoodItem[] {
  return mockFoods;
}
