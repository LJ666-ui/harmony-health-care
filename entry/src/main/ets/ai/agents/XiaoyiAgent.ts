import { AIRequest, AIResponse, AgentId } from '../models/AITypes';
import { IntentType } from '../orchestrator/IntentRouter';

export interface XiaoyiSkillConfig {
  skillPackage: string;
  triggerWords: string[];
  supportedIntents: IntentType[];
}

export class XiaoyiAgent {
  private readonly agentId: AgentId = 'xiaoyi';
  private config: XiaoyiSkillConfig;

  private intentActionMap: Map<IntentType, (entities: Record<string, any>) => Promise<string>> = new Map();

  constructor() {
    this.config = {
      skillPackage: 'com.example.harmonyhealthcare.skill',
      triggerWords: ['小艺小艺', '你好小艺', '智慧康养'],
      supportedIntents: [
        IntentType.APPOINTMENT_BOOKING,
        IntentType.NAVIGATION,
        IntentType.HEALTH_QUERY,
        IntentType.EMERGENCY,
        IntentType.MEDICATION_REMINDER,
        IntentType.REHAB_TRAINING,
        IntentType.DEVICE_CONTROL
      ]
    };

    this.setupIntentActions();
    console.log('[XiaoyiAgent] 小艺智能体初始化完成');
    console.log('[XiaoyiAgent] 支持的意图:', this.config.supportedIntents.map(i => i));
  }

  private setupIntentActions(): void {
    this.intentActionMap.set(IntentType.APPOINTMENT_BOOKING, async (entities) => {
      const doctorName = entities.doctorName ? `${entities.doctorName}医生` : '';
      const time = entities.time || '最近';
      const period = entities.period || '';

      return `好的，我来帮您${doctorName ? `预约${doctorName}` : '挂号'}。\n` +
             `已为您打开预约页面，请选择：\n` +
             `- 就诊时间: ${time}${period ? ` ${period}` : ''}\n` +
             `- 科室分类: 内科 / 外科 / 妇科 / 儿科 / 其他\n\n` +
             `💡 您也可以直接说："预约张医生明天上午"`;
    });

    this.intentActionMap.set(IntentType.NAVIGATION, async (entities) => {
      const destination = entities.destination || '目标位置';

      return `正在为您启动AR导航到【${destination}】...\n\n` +
             `📍 请将手机摄像头对准前方\n` +
             `🚶‍♂️ 我会通过AR箭头指引您前往\n` +
             `⏱️ 预计步行时间: 2-5分钟\n\n` +
             `💡 提示: 导航过程中请注意安全，避免碰撞`;
    });

    this.intentActionMap.set(IntentType.HEALTH_QUERY, async (entities) => {
      const metric = entities.metric || '健康数据';

      return `正在查询您的${metric}记录...\n\n` +
             `📊 最近7天趋势:\n` +
             `- 最高值: --\n` +
             `- 最低值: --\n` +
             `- 平均值: --\n\n` +
             `📈 详细图表已在健康记录页面展示\n` +
             `💡 建议: 定期监测，保持健康生活方式`;
    });

    this.intentActionMap.set(IntentType.EMERGENCY, async (entities) => {
      const urgency = entities.urgency || 'high';

      let message = '⚠️ 检测到紧急情况！\n\n';
      
      if (urgency === 'critical') {
        message += `🚨 **危急情况** - 请立即采取以下行动:\n\n`;
        message += `1. **立即拨打120急救电话**\n`;
        message += `2. 保持患者呼吸道通畅\n`;
        message += `3. 不要随意移动患者\n`;
        message += `4. 等待专业救援到达\n\n`;
        message += `📞 正在尝试自动拨打120...\n`;
        message += `📍 已获取您的GPS定位并发送给紧急联系人`;
      } else {
        message += `⚡ **需要关注** - 建议您:\n\n`;
        message += `1. 立即休息，不要剧烈运动\n`;
        message += `2. 测量血压和心率\n`;
        message += `3. 如症状持续或加重，请拨打120\n`;
        message += `4. 联系家人告知情况\n\n`;
        message += `💊 如果有常备药物，按医嘱服用`;
      }

      return message;
    });

    this.intentActionMap.set(IntentType.MEDICATION_REMINDER, async () => {
      return `用药提醒页面已打开！\n\n` +
             `💊 今日待服药清单:\n` +
             `- [ ] 降压药 - 08:00 (早餐后)\n` +
             `- [ ] 降糖药 - 12:00 (午餐前)\n` +
             `- [ ] 钙片 - 20:00 (晚餐后)\n\n` +
             `⏰ 需要设置提醒吗？说"设置8点吃药提醒"即可`;
    });

    this.intentActionMap.set(IntentType.REHAB_TRAINING, async () => {
      return `康复训练课程列表已打开！\n\n` +
             `🏃‍♂️ 推荐今日训练计划:\n\n` +
             `1. **热身运动** (5分钟)\n` +
             `   - 颈部旋转 ×10次\n` +
             `   - 肩部环绕 ×10次\n\n` +
             `2. **核心训练** (15分钟)\n` +
             `   - 桥式运动 ×15次\n` +
             `   - 平板支撑 30秒×3组\n\n` +
             `3. **放松拉伸** (5分钟)\n` +
             `   - 全身静态拉伸\n\n` +
             `💪 准备开始吗？我会全程语音指导您`;
    });

    this.intentActionMap.set(IntentType.DEVICE_CONTROL, async () => {
      return `设备管理页面已打开！\n\n` +
             `🔍 正在搜索附近可连接设备...\n\n` +
             `发现以下设备:\n` +
             `- 💓 血压计 (蓝牙)\n` +
             `- ⌚ 智能手表 (蓝牙)\n` +
             `- ⚖️ 体脂秤 (WiFi)\n\n` +
             `说"连接血压计"即可配对设备`;
    });
  }

  async process(request: AIRequest): Promise<AIResponse> {
    const startTime = Date.now();

    console.log(`[XiaoyiAgent] 🎤 处理请求: ${request.requestId}`);

    try {
      const inputText = this.extractInputText(request);
      
      if (this.isWakeWord(inputText)) {
        return this.createWakeWordResponse(request.requestId, startTime);
      }

      const intent = await this.identifyIntent(inputText);
      console.log(`[XiaoyiAgent] 识别意图: ${intent.type} (${(intent.confidence * 100).toFixed(1)}%)`);

      if (this.intentActionMap.has(intent.type)) {
        const actionHandler = this.intentActionMap.get(intent.type)!;
        const content = await actionHandler(intent.entities);

        return {
          requestId: request.requestId,
          agentId: this.agentId,
          output: {
            type: 'text',
            content: content,
            confidence: intent.confidence
          },
          metadata: {
            processingTime: Date.now() - startTime,
            isOffline: true,
            agentVersion: '1.0.0'
          },
          suggestions: this.generateSuggestions(intent.type)
        };

      } else {
        return this.createDefaultResponse(request.requestId, inputText, startTime);
      }

    } catch (error) {
      console.error('[XiaoyiAgent] 处理错误:', error);
      return this.createErrorResponse(request.requestId, error as string, startTime);
    }
  }

  private extractInputText(request: AIRequest): string {
    if (typeof request.input.content === 'string') {
      return request.input.content;
    }
    return '';
  }

  private isWakeWord(text: string): boolean {
    return this.config.triggerWords.some(word => 
      text.toLowerCase().includes(word.toLowerCase())
    );
  }

  private createWakeWordResponse(requestId: string, startTime: number): AIResponse {
    return {
      requestId,
      agentId: this.agentId,
      output: {
        type: 'text',
        content: '我在，请问有什么可以帮您的？\n\n' +
               '您可以说:\n' +
               '- "帮我挂号"\n' +
               '- "打开AR导航"\n' +
               '- "查看血压记录"\n' +
               '- "评估健康风险"\n' +
               '- "开始康复训练"',
        confidence: 1.0
      },
      metadata: {
        processingTime: Date.now() - startTime,
        isOffline: true,
        agentVersion: '1.0.0'
      },
      suggestions: [
        '帮我挂号张医生',
        '导航去内科',
        '我的血压怎么样',
        '开始康复训练'
      ]
    };
  }

  private async identifyIntent(text: string): Promise<{ type: IntentType; confidence: number; entities: Record<string, any> }> {
    const patterns: Array<{ type: IntentType; pattern: RegExp; extractor?: (text: string) => Record<string, any> }> = [
      { type: IntentType.APPOINTMENT_BOOKING, pattern: /(挂号|预约|门诊|看医生)/, 
        extractor: (t) => ({ doctorName: t.match(/(\w+)医生/)?.[1], time: t.match(/(明天|后天|今天)/)?.[1] })},
      { type: IntentType.NAVIGATION, pattern: /(导航|怎么走|去.*科|AR导航)/,
        extractor: (t) => ({ destination: t.match(/去(\w+科|\w+室)/)?.[1] })},
      { type: IntentType.HEALTH_QUERY, pattern: /(血压|血糖|心率|体重|健康记录|体检)/,
        extractor: (t) => ({ metric: t.match(/(血压|血糖|心率|体重|体温)/)?.[1] })},
      { type: IntentType.RISK_ASSESSMENT, pattern: /(风险|评估|检查|分析|预测)/ },
      { type: IntentType.EMERGENCY, pattern: /(救命|急救|120|晕倒|胸痛|呼吸困难)/,
        extractor: () => ({ urgency: 'high', isEmergency: true })},
      { type: IntentType.MEDICATION_REMINDER, pattern: /(吃药|用药|药物|提醒吃药)/ },
      { type: IntentType.REHAB_TRAINING, pattern: /(康复|训练|运动|锻炼|太极)/ },
      { type: IntentType.DEVICE_CONTROL, pattern: /(打开|启动|连接设备|配对)/ }
    ];

    for (const { type, pattern, extractor } of patterns) {
      if (pattern.test(text)) {
        return {
          type,
          confidence: 0.85,
          entities: extractor ? extractor(text) : {}
        };
      }
    }

    return {
      type: IntentType.GENERAL_CHAT,
      confidence: 0.3,
      entities: {}
    };
  }

  private createDefaultResponse(requestId: string, text: string, startTime: number): AIResponse {
    return {
      requestId,
      agentId: this.agentId,
      output: {
        type: 'text',
        content: `我理解您说的是"${text}"，这个问题可能需要更专业的AI助手来解答。` +
                 `\n\n让我为您转接到DeepSeek大模型进行分析...`,
        confidence: 0.4
      },
      metadata: {
        processingTime: Date.now() - startTime,
        isOffline: true,
        agentVersion: '1.0.0'
      },
      suggestions: ['转接DeepSeek分析', '查看常见问题']
    };
  }

  private createErrorResponse(requestId: string, error: string, startTime: number): AIResponse {
    return {
      requestId,
      agentId: this.agentId,
      output: {
        type: 'text',
        content: '抱歉，小艺暂时无法处理您的请求。请稍后重试。',
        confidence: 0
      },
      metadata: {
        processingTime: Date.now() - startTime,
        isOffline: true,
        agentVersion: '1.0.0'
      },
      error: error
    };
  }

  private generateSuggestions(intent: IntentType): string[] {
    const suggestionMap: Record<IntentType, string[]> = {
      [IntentType.APPOINTMENT_BOOKING]: ['选择医生', '选择时间段', '确认预约'],
      [IntentType.NAVIGATION]: ['开始导航', '切换目的地', '取消导航'],
      [IntentType.HEALTH_QUERY]: ['查看详细报告', '导出数据', '分享给医生'],
      [IntentType.RISK_ASSESSMENT]: ['开始评估', '查看历史报告', '获取改善建议'],
      [IntentType.EMERGENCY]: ['立即拨打120', '通知紧急联系人', '发送位置信息'],
      [IntentType.MEDICATION_REMINDER]: ['标记已服用', '设置提醒', '查看用药说明'],
      [IntentType.REHAB_TRAINING]: ['开始训练', '查看课程详情', '调整难度'],
      [IntentType.GENERAL_CHAT]: ['继续对话', '转接专家', '结束对话'],
      [IntentType.DEVICE_CONTROL]: ['连接设备', '查看设备状态', '同步数据'],
      [IntentType.KNOWLEDGE_QUERY]: ['查看相关知识', '保存问题', '咨询医生']
    };

    return suggestionMap[intent] || [];
  }

  getConfig(): XiaoyiSkillConfig {
    return this.config;
  }
}
