import { router } from '@kit.ArkUI';
import { AIOrchestrator } from '../ai/orchestrator/AIOrchestrator';
import { AIRequestBuilder } from '../ai/utils/AIRequestBuilder';
import { ToastUtil } from '../common/utils/ToastUtil';

export interface VoiceIntent {
  type: 'navigate' | 'query' | 'action';
  targetPage?: string;
  targetParams?: Record<string, string>;
  queryText?: string;
  actionType?: string;
  reply: string;
  confidence: number;
}

export interface PageRoute {
  keywords: string[];
  page: string;
  params?: Record<string, string>;
  reply: string;
}

export class VoiceIntentService {
  private static instance: VoiceIntentService | null = null;
  private orchestrator: AIOrchestrator = AIOrchestrator.getInstance();

  private pageRoutes: PageRoute[] = [
    { keywords: ['首页', '主页', '回家', '主页面'], page: 'pages/HomePage', reply: '已为您打开首页' },
    { keywords: ['挂号', '预约', '门诊预约'], page: 'pages/Appointments', reply: '已为您打开预约挂号页面' },
    { keywords: ['健康记录', '查记录', '历史数据', '体检记录'], page: 'pages/HealthRecords', reply: '已为您打开健康记录页面' },
    { keywords: ['用药', '吃药', '药物', '药品'], page: 'pages/Medications', reply: '已为您打开用药管理页面' },
    { keywords: ['风险评估', '风险', '评估'], page: 'pages/RiskAssessmentPage', reply: '已为您打开健康风险评估页面' },
    { keywords: ['医院', '诊所', '附近医院'], page: 'pages/HospitalPage', reply: '已为您搜索附近医院' },
    { keywords: ['康复', '训练', '运动'], page: 'pages/RehabListPage', reply: '已为您打开康复训练页面' },
    { keywords: ['科普', '文章', '知识'], page: 'pages/ScienceListPage', reply: '已为您打开科普文章页面' },
    { keywords: ['导航', 'AR', '找科室', '导诊'], page: 'pages/DestinationSelectPage', reply: '已为您打开AR导航页面' },
    { keywords: ['设备', '连接', '配对', '手环'], page: 'pages/DeviceDiscoveryPage', reply: '已为您打开设备连接页面' },
    { keywords: ['隐私', '权限', '设置'], page: 'pages/PrivacyPage', reply: '已为您打开隐私设置页面' },
    { keywords: ['AI助手', '智能助手', '聊天'], page: 'pages/VoiceAssistantPage', reply: '已为您打开AI语音助手' },
    { keywords: ['医生', '问诊', '在线问诊'], page: 'pages/ConsultationPage', reply: '已为您打开在线问诊页面' },
    { keywords: ['急救', '紧急', '求助', '120'], page: 'pages/EmergencyPage', reply: '紧急求助页面已打开' },
    { keywords: ['图像', '拍照', '影像', '诊断'], page: 'pages/ImageAnalysisPage', reply: '已为您打开AI影像分析页面' },
    { keywords: ['数字孪生', '人体模型', '3D人体'], page: 'pages/DigitalTwinPage', reply: '已为您打开数字孪生页面' },
    { keywords: ['中医', '体质', '草药'], page: 'pages/HerbalListPage', reply: '已为您打开中医草药页面' },
    { keywords: ['食物', '营养', '食疗'], page: 'pages/FoodEncyclopediaPage', reply: '已为您打开食物百科页面' },
    { keywords: ['知识图谱', '知识探索'], page: 'pages/KnowledgeGraphPage', reply: '已为您打开知识图谱页面' },
    { keywords: ['剂量', '计算', '药量'], page: 'pages/DosageCalc', reply: '已为您打开剂量计算页面' },
    { keywords: ['科室', '科室列表'], page: 'pages/DepartmentPage', reply: '已为您打开科室列表页面' },
    { keywords: ['医生列表', '找医生'], page: 'pages/DoctorListPage', reply: '已为您打开医生列表页面' },
    { keywords: ['护士', '护士台'], page: 'pages/NurseWorkbench', reply: '已为您打开护士工作台' },
    { keywords: ['家属', '家庭'], page: 'pages/FamilyHome', reply: '已为您打开家属首页' },
    { keywords: ['管理员', '后台'], page: 'pages/AdminDashboard', reply: '已为您打开管理后台' },
  ];

  private constructor() {}

  static getInstance(): VoiceIntentService {
    if (!VoiceIntentService.instance) {
      VoiceIntentService.instance = new VoiceIntentService();
    }
    return VoiceIntentService.instance;
  }

  async parseIntent(text: string): Promise<VoiceIntent> {
    const trimmed = text.trim();
    if (!trimmed) {
      return {
        type: 'query',
        queryText: trimmed,
        reply: '请说出您的需求',
        confidence: 0
      };
    }

    const navIntent = this.matchNavigationIntent(trimmed);
    if (navIntent) {
      return navIntent;
    }

    const actionIntent = this.matchActionIntent(trimmed);
    if (actionIntent) {
      return actionIntent;
    }

    return await this.matchQueryIntent(trimmed);
  }

  private matchNavigationIntent(text: string): VoiceIntent | null {
    const lowerText = text.toLowerCase();

    for (const route of this.pageRoutes) {
      for (const keyword of route.keywords) {
        if (lowerText.includes(keyword.toLowerCase())) {
          const openWords = ['打开', '去', '跳转', '前往', '进入', '到', '查看', '找', '我要'];
          const hasOpenIntent = openWords.some(w => lowerText.includes(w)) || lowerText.length <= keyword.length + 2;

          if (hasOpenIntent) {
            return {
              type: 'navigate',
              targetPage: route.page,
              targetParams: route.params,
              reply: route.reply,
              confidence: 0.9
            };
          }
        }
      }
    }

    return null;
  }

  private matchActionIntent(text: string): VoiceIntent | null {
    const lowerText = text.toLowerCase();

    if (lowerText.includes('紧急') || lowerText.includes('求救') || lowerText.includes('120') || lowerText.includes('救命')) {
      return {
        type: 'action',
        actionType: 'emergency',
        reply: '检测到紧急求助！正在为您拨打急救电话...',
        confidence: 0.95
      };
    }

    if (lowerText.includes('提醒') && (lowerText.includes('吃药') || lowerText.includes('用药'))) {
      return {
        type: 'navigate',
        targetPage: 'pages/Medications',
        reply: '已为您打开用药提醒页面',
        confidence: 0.85
      };
    }

    if (lowerText.includes('测量') || lowerText.includes('记录') && (lowerText.includes('血压') || lowerText.includes('血糖') || lowerText.includes('心率'))) {
      return {
        type: 'navigate',
        targetPage: 'pages/AddHealthRecord',
        reply: '已为您打开健康数据记录页面',
        confidence: 0.85
      };
    }

    return null;
  }

  private async matchQueryIntent(text: string): Promise<VoiceIntent> {
    try {
      const userId = String(AppStorage.get('userId') || 'anonymous');
      const request = AIRequestBuilder.createWithIntent(text, 'voice_query', userId);
      const response = await this.orchestrator.process(request);

      const answer = typeof response.output.content === 'string'
        ? response.output.content
        : JSON.stringify(response.output.content);

      return {
        type: 'query',
        queryText: text,
        reply: answer,
        confidence: response.output.confidence
      };
    } catch (error) {
      console.error('[VoiceIntentService] AI解析失败:', error);
      return {
        type: 'query',
        queryText: text,
        reply: this.getFallbackReply(text),
        confidence: 0.3
      };
    }
  }

  private getFallbackReply(text: string): string {
    const healthKeywords: Record<string, string> = {
      '血压': '成人正常血压范围：收缩压90-139mmHg，舒张压60-89mmHg。建议您打开健康记录查看历史数据。',
      '血糖': '空腹血糖正常值：3.9-6.1mmol/L。建议您定期监测并记录血糖变化。',
      '心率': '成人静息心率正常范围：60-100次/分。如心率异常请及时就医。',
      '头痛': '头痛可能由多种原因引起，建议您记录症状持续时间并咨询医生。',
      '失眠': '改善睡眠建议：保持规律作息，睡前避免使用电子设备，适当运动。',
      '感冒': '感冒期间建议多饮水、注意休息，如症状持续请及时就医。'
    };

    const keys: string[] = Object.keys(healthKeywords);
    for (let i = 0; i < keys.length; i++) {
      if (text.includes(keys[i])) {
        return healthKeywords[keys[i]];
      }
    }

    return '我已收到您的指令，正在为您处理。您也可以说"打开首页"、"查看健康记录"等来快速跳转页面。';
  }

  async executeIntent(intent: VoiceIntent): Promise<boolean> {
    switch (intent.type) {
      case 'navigate':
        if (intent.targetPage) {
          try {
            await router.pushUrl({
              url: intent.targetPage,
              params: intent.targetParams
            });
            ToastUtil.showSuccess(intent.reply);
            return true;
          } catch (error) {
            console.error('[VoiceIntentService] 页面跳转失败:', error);
            ToastUtil.showError('页面跳转失败，请手动操作');
            return false;
          }
        }
        break;

      case 'action':
        if (intent.actionType === 'emergency') {
          ToastUtil.emergencyCall();
          return true;
        }
        break;

      case 'query':
        return true;
    }

    return false;
  }
}
