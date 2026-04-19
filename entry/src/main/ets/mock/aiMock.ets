import { BaseResponse } from '../common/utils/HttpUtil';
import { registerMockHandler, USE_MOCK } from './index';

export interface AiChatMessage {
  role: 'user' | 'assistant';
  content: string;
  timestamp: number;
}

export interface AiChatSession {
  sessionId: string;
  title: string;
  messages: AiChatMessage[];
  createTime: number;
  updateTime: number;
}

export interface HealthConsultRequest {
  question: string;
  symptoms?: string[];
  age?: number;
  gender?: string;
}

const mockSessions: AiChatSession[] = [
  {
    sessionId: 'session_001',
    title: '关于高血压的咨询',
    messages: [
      { role: 'user', content: '我最近血压偏高，有什么建议吗？', timestamp: Date.now() - 86400000 },
      { role: 'assistant', content: '血压偏高需要注意以下几点：\n1. 低盐饮食：每日盐摄入不超过6克\n2. 规律运动：每天30分钟有氧运动\n3. 控制体重：BMI保持在18.5-24之间\n4. 戒烟限酒\n5. 保持心情舒畅\n建议您定期监测血压，如持续偏高请及时就医。', timestamp: Date.now() - 86300000 }
    ],
    createTime: Date.now() - 86400000,
    updateTime: Date.now() - 86300000
  },
  {
    sessionId: 'session_002',
    title: '失眠调理方法',
    messages: [
      { role: 'user', content: '最近总是睡不着，有什么中医方法可以改善？', timestamp: Date.now() - 172800000 },
      { role: 'assistant', content: '从中医角度来看，失眠多与心神不宁、肝火旺盛有关。推荐以下方法：\n\n【穴位按摩】\n- 神门穴（手腕横纹尺侧端）：每晚睡前按揉3-5分钟\n- 内关穴（腕横纹上2寸）：按揉可安神定志\n- 涌泉穴（足底前1/3处）：睡前搓热涌泉\n\n【食疗方】\n- 酸枣仁汤：酸枣仁15g，水煎服\n- 百合莲子粥：百合30g，莲子20g煮粥\n\n【生活习惯】\n- 睡前1小时避免使用电子设备\n- 保持卧室安静黑暗\n- 固定作息时间', timestamp: Date.now() - 172790000 }
    ],
    createTime: Date.now() - 172800000,
    updateTime: Date.now() - 172790000
  }
];

let mockMessageId: number = 0;

function generateAiResponse(question: string): string {
  const lowerQ = question.toLowerCase();

  if (lowerQ.indexOf('血压') >= 0 || lowerQ.indexOf('高血压') >= 0) {
    return '关于您的血压问题，以下是一些建议：\n\n**日常管理**\n- 每日盐摄入控制在5-6克以内\n- 增加钾元素摄入（香蕉、土豆、菠菜）\n- 有氧运动每周至少150分钟\n- 保持充足睡眠（7-8小时）\n\n**监测提醒**\n- 每日早晚各测一次血压并记录\n- 正常血压范围：<140/90 mmHg\n- 如连续3天超过此值请就医\n\n**危险信号**⚠️\n- 剧烈头痛、胸闷气短\n- 视力模糊、言语不清\n- 出现以上症状请立即就医';
  }

  if (lowerQ.indexOf('糖尿病') >= 0 || lowerQ.indexOf('血糖') >= 0) {
    return '关于血糖管理，请注意以下几点：\n\n**饮食原则**\n- 控制碳水化合物总量，选择低GI食物\n- 少食多餐，定时定量进餐\n- 避免精制糖和含糖饮料\n\n**监测频率**\n- 空腹血糖目标：4.4-7.0 mmol/L\n- 餐后2小时目标：<10.0 mmol/L\n- 建议每周监测2-4次\n\n**运动建议**\n- 餐后1小时进行中等强度运动\n- 每次20-30分钟为宜\n- 避免空腹运动以防低血糖';
  }

  if (lowerQ.indexOf('失眠') >= 0 || lowerQ.indexOf('睡眠') >= 0) {
    return '针对睡眠问题，为您提供以下建议：\n\n🌙 **睡前准备**\n- 睡前1小时远离手机电脑\n- 保持卧室温度在18-22°C\n- 可使用薰衣草香薰助眠\n\n💆 **放松技巧**\n- 4-7-8呼吸法：吸气4秒→屏息7秒→呼气8秒\n- 渐进式肌肉放松：从头到脚依次紧绷再放松\n- 冥想或正念练习10分钟\n\n🍵 **助眠茶饮**\n- 酸枣仁+百合+茯苓泡水\n- 莲子心茶（少量）\n- 洋甘菊茶\n\n⚠️ 如果长期失眠（>2周），建议咨询专业医生。';
  }

  return '感谢您的咨询！作为AI健康助手，我可以帮您：\n\n📋 **健康知识问答** - 中医理论、疾病预防、用药指导\n🍎 **营养膳食建议** - 根据体质和需求推荐食谱\n🏃 **运动康复指导** - 适合的运动方案和注意事项\n💊 **药物相互作用** - 中西药搭配禁忌提醒\n\n您的具体问题是："' + question + '"\n\n建议您提供更多详细信息（如年龄、性别、主要症状等），以便给出更精准的建议。\n\n如有紧急健康问题，请立即拨打120或前往医院就诊。';
}

if (USE_MOCK) {
  registerMockHandler('/ai/chat', async (url, data) => {
    const requestData = data as Record<string, Object>;
    const msg = requestData['message'] ? String(requestData['message']) : '';
    const responseContent = generateAiResponse(msg);

    return {
      success: true,
      message: '对话成功',
      code: 200,
      data: {
        reply: responseContent,
        sessionId: 'mock_session_' + Date.now()
      }
    };
  });

  registerMockHandler('/ai/health-consult', async (url, data) => {
    const consultData = data as HealthConsultRequest;
    const responseContent = generateAiResponse(consultData.question || '');

    return {
      success: true,
      message: '咨询成功',
      code: 200,
      data: {
        reply: responseContent,
        suggestions: ['定期体检', '保持良好作息', '合理饮食']
      }
    };
  });

  registerMockHandler('/ai/history', async (url, data, params) => {
    return {
      success: true,
      message: '查询成功',
      code: 200,
      data: {
        sessions: mockSessions,
        total: mockSessions.length
      }
    };
  });
}

export function getMockSessions(): AiChatSession[] {
  return mockSessions;
}
