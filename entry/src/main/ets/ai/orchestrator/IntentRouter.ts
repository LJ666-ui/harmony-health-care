import { AIRequest, AgentId } from '../models/AITypes';

export enum IntentType {
  APPOINTMENT_BOOKING = 'appointment_booking',
  NAVIGATION = 'navigation',
  HEALTH_QUERY = 'health_query',
  RISK_ASSESSMENT = 'risk_assessment',
  EMERGENCY = 'emergency',
  MEDICATION_REMINDER = 'medication_reminder',
  REHAB_TRAINING = 'rehab_training',
  GENERAL_CHAT = 'general_chat',
  DEVICE_CONTROL = 'device_control',
  KNOWLEDGE_QUERY = 'knowledge_query'
}

export interface IntentResult {
  intent: IntentType;
  confidence: number;
  entities: Record<string, any>;
  suggestedAgent: AgentId;
  isSystemCommand: boolean;
}

export class IntentRouter {
  private keywordPatterns: Map<IntentType, { patterns: RegExp[]; keywords: string[]; agent: AgentId }> = new Map([
    [IntentType.APPOINTMENT_BOOKING, {
      patterns: [/挂号|预约|门诊|看病|看医生|排号/],
      keywords: ['挂号', '预约', '门诊', '医生', '看病'],
      agent: 'xiaoyi'
    }],
    [IntentType.NAVIGATION, {
      patterns: [/导航|怎么走|去.*科|找.*室|AR导航|路线/],
      keywords: ['导航', '怎么走', '去', '科室', 'AR'],
      agent: 'xiaoyi'
    }],
    [IntentType.HEALTH_QUERY, {
      patterns: [/血压|血糖|心率|体重|健康记录|体检报告|身体情况/],
      keywords: ['血压', '血糖', '心率', '健康', '体检', '记录'],
      agent: 'mindspore'
    }],
    [IntentType.RISK_ASSESSMENT, {
      patterns: [/风险|评估|检查|分析|预测|筛查/],
      keywords: ['风险', '评估', '检查', '分析', '预测'],
      agent: 'mindspore'
    }],
    [IntentType.EMERGENCY, {
      patterns: [/救命|急救|120|不舒服|晕倒|胸痛|呼吸困难/],
      keywords: ['救命', '急救', '120', '晕倒', '胸痛', '呼吸困难'],
      agent: 'xiaoyi'
    }],
    [IntentType.MEDICATION_REMINDER, {
      patterns: [/吃药|用药|药物|服药|提醒吃药|该吃/],
      keywords: ['吃药', '用药', '药物', '提醒', '服药'],
      agent: 'xiaoyi'
    }],
    [IntentType.REHAB_TRAINING, {
      patterns: [/康复|训练|运动|锻炼|太极|八段锦/],
      keywords: ['康复', '训练', '运动', '锻炼', '太极'],
      agent: 'xiaoyi'
    }],
    [IntentType.DEVICE_CONTROL, {
      patterns: [/打开|启动|连接设备|配对|蓝牙/],
      keywords: ['打开', '启动', '设备', '连接', '配对'],
      agent: 'xiaoyi'
    }],
    [IntentType.KNOWLEDGE_QUERY, {
      patterns: [/什么[是能可以]|怎么[办做治]|为什么|是否|能否|副作用|禁忌|饮食/],
      keywords: ['什么是', '怎么办', '为什么', '副作用', '禁忌', '饮食'],
      agent: 'deepseek'
    }]
  ]);

  async route(request: AIRequest): Promise<IntentResult> {
    const inputText = this.extractText(request);
    
    if (!inputText || inputText.trim().length === 0) {
      return {
        intent: IntentType.GENERAL_CHAT,
        confidence: 0.1,
        entities: {},
        suggestedAgent: 'deepseek',
        isSystemCommand: false
      };
    }

    let bestMatch: IntentResult = {
      intent: IntentType.GENERAL_CHAT,
      confidence: 0,
      entities: {},
      suggestedAgent: 'deepseek',
      isSystemCommand: false
    };

    for (const [intentType, config] of this.keywordPatterns) {
      const score = this.calculateMatchScore(inputText, config.patterns, config.keywords);
      
      if (score > bestMatch.confidence) {
        bestMatch = {
          intent: intentType,
          confidence: score,
          entities: this.extractEntities(inputText, intentType),
          suggestedAgent: config.agent,
          isSystemCommand: this.isSystemIntent(intentType)
        };
      }
    }

    if (bestMatch.confidence < 0.3) {
      bestMatch.intent = IntentType.GENERAL_CHAT;
      bestMatch.suggestedAgent = request.preferences?.preferredAgent || 'deepseek';
    }

    console.log(`[IntentRouter] 路由结果: ${bestMatch.intent} (${(bestMatch.confidence * 100).toFixed(1)}%) → ${bestMatch.suggestedAgent}`);
    
    return bestMatch;
  }

  private extractText(request: AIRequest): string {
    const input = request.input;
    if (typeof input.content === 'string') {
      return input.content;
    }
    return '';
  }

  private calculateMatchScore(text: string, patterns: RegExp[], keywords: string[]): number {
    let patternScore = 0;
    for (const pattern of patterns) {
      if (pattern.test(text)) {
        patternScore += 0.4;
      }
    }

    let keywordScore = 0;
    const lowerText = text.toLowerCase();
    for (const keyword of keywords) {
      if (lowerText.includes(keyword.toLowerCase())) {
        keywordScore += 0.15;
      }
    }

    return Math.min(patternScore + keywordScore, 1.0);
  }

  private extractEntities(text: string, intent: IntentType): Record<string, any> {
    const entities: Record<string, any> = {};

    switch (intent) {
      case IntentType.APPOINTMENT_BOOKING:
        const doctorMatch = text.match(/(\w+)医生/);
        if (doctorMatch) entities.doctorName = doctorMatch[1];
        
        const timeMatch = text.match(/(明天|后天|今天|下周\w)/);
        if (timeMatch) entities.time = timeMatch[1];
        
        const periodMatch = text.match /(上午|下午|晚上)/;
        if (periodMatch) entities.period = periodMatch[1];
        break;

      case IntentType.NAVIGATION:
        const deptMatch = text.match(/去(\w+科|\w+室)/);
        if (deptMatch) entities.destination = deptMatch[1];
        break;

      case IntentType.HEALTH_QUERY:
        const metricMatch = text.match /(血压|血糖|心率|体重|体温)/;
        if (metricMatch) entities.metric = metricMatch[1];
        break;

      case IntentType.EMERGENCY:
        entities.isEmergency = true;
        entities.urgency = this assessUrgency(text);
        break;
    }

    return entities;
  }

  private assessUrgency(text: string): 'critical' | 'high' | 'medium' {
    const criticalWords = ['救命', '昏迷', '停止呼吸', '大出血'];
    const highWords = ['胸痛', '呼吸困难', '晕倒', '剧烈疼痛'];
    
    if (criticalWords.some(w => text.includes(w))) return 'critical';
    if (highWords.some(w => text.includes(w))) return 'high';
    return 'medium';
  }

  private isSystemIntent(intent: IntentType): boolean {
    const systemIntents = [
      IntentType.APPOINTMENT_BOOKING,
      IntentType.NAVIGATION,
      IntentType.EMERGENCY,
      IntentType.MEDICATION_REMINDER,
      IntentType.REHAB_TRAINING,
      IntentType.DEVICE_CONTROL
    ];
    return systemIntents.includes(intent);
  }
}
