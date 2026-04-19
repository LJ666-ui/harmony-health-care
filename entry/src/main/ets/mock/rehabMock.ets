import { BaseResponse } from '../common/utils/HttpUtil';
import { registerMockHandler, USE_MOCK } from './index';

export interface RehabPlan {
  id: number;
  name: string;
  description: string;
  targetBodyPart: string;
  difficulty: 'BEGINNER' | 'INTERMEDIATE' | 'ADVANCED';
  durationWeeks: number;
  sessionsPerWeek: number;
  actions: RehabAction[];
  coverImage: string;
  tags: string[];
}

export interface RehabAction {
  id: number;
  name: string;
  description: string;
  duration: number;
  repetitions: number;
  restTime: number;
  videoUrl?: string;
  imageUrl?: string;
  instructions: string[];
  precautions: string[];
}

export interface ActionDetailResponse {
  action: RehabAction;
  relatedActions: RehabAction[];
}

const a101: RehabAction = { id: 101, name: '直腿抬高训练', description: '增强股四头肌力量，改善膝关节稳定性', duration: 300, repetitions: 15, restTime: 30, instructions: ['仰卧位，健侧膝屈曲', '患侧腿伸直并抬高至30°', '保持5秒后缓慢放下'], precautions: ['动作要缓慢控制', '避免腰部代偿'] };
const a102: RehabAction = { id: 102, name: '踝泵运动', description: '促进下肢血液循环，预防血栓形成', duration: 180, repetitions: 20, restTime: 10, instructions: ['坐位或卧位', '用力勾脚尖至极限', '再用力下踩脚尖'], precautions: ['每日多次练习', '幅度尽量做大'] };
const a201: RehabAction = { id: 201, name: '钟摆运动', description: '利用重力放松肩关节，增加活动范围', duration: 240, repetitions: 10, restTime: 20, instructions: ['弯腰90°，手扶桌沿', '患侧手臂自然下垂', '轻轻做画圈运动'], precautions: ['不要主动发力', '依靠惯性摆动'] };
const a202: RehabAction = { id: 202, name: '爬墙练习', description: '逐步提高肩关节前屈和外展活动度', duration: 300, repetitions: 8, restTime: 30, instructions: ['面向墙壁站立', '手指沿墙向上爬行', '到最高点保持10秒'], precautions: ['疼痛不超过3分', '循序渐进'] };
const a301: RehabAction = { id: 301, name: '麦肯基伸展', description: '减轻椎间盘压力，改善姿势', duration: 240, repetitions: 10, restTime: 15, instructions: ['俯卧位', '双手撑起上半身', '骨盆不离床面'], precautions: ['急性期慎用', '避免过度后伸'] };
const a302: RehabAction = { id: 302, name: '死虫式训练', description: '激活核心肌群，增强脊柱稳定性', duration: 360, repetitions: 12, restTime: 20, instructions: ['仰卧位，四肢抬起', '对侧手脚同时缓慢伸出', '保持腰背贴紧地面'], precautions: ['动作要慢', '保持呼吸均匀'] };

const mockRehabPlans: RehabPlan[] = [
  { id: 1, name: '膝关节康复计划', description: '针对膝关节术后或损伤后的系统性康复训练方案', targetBodyPart: '膝关节', difficulty: 'BEGINNER', durationWeeks: 8, sessionsPerWeek: 3, coverImage: '', tags: ['关节', '术后', '初级'], actions: [a101, a102] },
  { id: 2, name: '肩周炎康复训练', description: '改善肩关节活动度，缓解疼痛僵硬', targetBodyPart: '肩关节', difficulty: 'INTERMEDIATE', durationWeeks: 12, sessionsPerWeek: 4, coverImage: '', tags: ['肩部', '炎症', '中级'], actions: [a201, a202] },
  { id: 3, name: '腰椎间盘突出康复', description: '通过核心稳定训练和伸展运动缓解腰痛', targetBodyPart: '腰椎', difficulty: 'ADVANCED', durationWeeks: 16, sessionsPerWeek: 5, coverImage: '', tags: ['腰椎', '突出', '高级'], actions: [a301, a302] }
];

function findPlanById(id: number): RehabPlan | undefined {
  for (let i = 0; i < mockRehabPlans.length; i++) {
    if (mockRehabPlans[i].id === id) { return mockRehabPlans[i]; }
  }
  return undefined;
}

function findActionById(actionId: number): { action: RehabAction, plan: RehabPlan } | null {
  for (let pi = 0; pi < mockRehabPlans.length; pi++) {
    const plan = mockRehabPlans[pi];
    for (let ai = 0; ai < plan.actions.length; ai++) {
      if (plan.actions[ai].id === actionId) {
        return { action: plan.actions[ai], plan: plan };
      }
    }
  }
  return null;
}

function getRelatedActions(plan: RehabAction[], excludeId: number): RehabAction[] {
  const r: RehabAction[] = [];
  let c = 0;
  for (let i = 0; i < plan.length && c < 2; i++) {
    if (plan[i].id !== excludeId) { r.push(plan[i]); c++; }
  }
  return r;
}

function searchPlans(keyword: string): RehabPlan[] {
  if (!keyword || keyword.length === 0) { return mockRehabPlans; }
  const r: RehabPlan[] = [];
  for (let i = 0; i < mockRehabPlans.length; i++) {
    const p = mockRehabPlans[i];
    if (p.name.indexOf(keyword) >= 0 || p.description.indexOf(keyword) >= 0 || p.targetBodyPart.indexOf(keyword) >= 0) {
      r.push(p);
      continue;
    }
    for (let ti = 0; ti < p.tags.length; ti++) {
      if (p.tags[ti].indexOf(keyword) >= 0) { r.push(p); break; }
    }
  }
  return r;
}

if (USE_MOCK) {
  registerMockHandler('/rehab/list', async () => ({ success: true, message: '查询成功', code: 200, data: mockRehabPlans }));
  registerMockHandler('/rehab/get/', async (url) => {
    const parts = url.split('/');
    const id = parseInt(parts[parts.length - 1]);
    const plan = findPlanById(id);
    return { success: !!plan, message: plan ? '查询成功' : '计划不存在', code: plan ? 200 : 404, data: plan || null };
  });
  registerMockHandler('/rehab/action/detail/', async (url) => {
    const parts = url.split('/');
    const aid = parseInt(parts[parts.length - 1]);
    const found = findActionById(aid);
    if (found) {
      const respData: ActionDetailResponse = { action: found.action, relatedActions: getRelatedActions(found.plan.actions, aid) };
      return { success: true, message: '查询成功', code: 200, data: respData };
    }
    return { success: false, message: '动作不存在', code: 404 };
  });
  registerMockHandler('/rehab/search', async (url, data, params) => {
    let kw = '';
    if (params) {
      const p = params as Record<string, Object>;
      if (p['keyword']) { kw = String(p['keyword']); }
    }
    return { success: true, message: '查询成功', code: 200, data: searchPlans(kw) };
  });
}

export function getMockRehabPlans(): RehabPlan[] {
  return mockRehabPlans;
}
