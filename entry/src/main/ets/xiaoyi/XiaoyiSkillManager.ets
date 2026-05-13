/**
 * 小艺Skill管理器
 * 负责注册、管理和调度所有医疗Skill
 * 实现MCP协议对接，提供统一的小艺交互入口
 */

import {
  XiaoyiSkillDefinition,
  XiaoyiSkillRequest,
  XiaoyiSkillResponse,
  MCPMessage,
  MCPCapability,
  XiaoyiSessionContext,
  XiaoyiMessage
} from './types/XiaoyiTypes';
import { HealthQuerySkill } from './skills/HealthQuerySkill';
import { RiskAssessSkill } from './skills/RiskAssessSkill';
import { MedicationReminderSkill } from './skills/MedicationReminderSkill';
import { NavigationSkill } from './skills/NavigationSkill';
import { AIConsultationSkill } from './skills/AIConsultationSkill';
import { EmergencySkill } from './skills/EmergencySkill';
import { DeviceConnectSkill } from './skills/DeviceConnectSkill';
import { RehabTrainingSkill } from './skills/RehabTrainingSkill';
import { toastUtil } from '../../common/utils/ToastUtil';
import { router } from '@kit.ArkUI';

export class XiaoyiSkillManager {
  private static instance: XiaoyiSkillManager | null = null;
  private skills: Map<string, XiaoyiSkillDefinition> = new Map();
  private sessions: Map<string, XiaoyiSessionContext> = new Map();
  private isInitialized: boolean = false;

  private constructor() {
    this.registerDefaultSkills();
  }

  public static getInstance(): XiaoyiSkillManager {
    if (XiaoyiSkillManager.instance === null) {
      XiaoyiSkillManager.instance = new XiaoyiSkillManager();
    }
    return XiaoyiSkillManager.instance;
  }

  /**
   * 初始化小艺Skill系统
   */
  async initialize(): Promise<boolean> {
    try {
      console.info('[Xiaoyi] 正在初始化Skill系统...');

      // 注册所有Skill
      this.registerDefaultSkills();

      // 声明MCP能力（向小艺平台注册）
      await this.declareMCPCapabilities();

      this.isInitialized = true;
      console.info('[Xiaoyi] Skill系统初始化完成');
      return true;
    } catch (error) {
      console.error('[Xiaoyi] Skill系统初始化失败:', error);
      return false;
    }
  }

  /**
   * 注册默认的8个医疗Skill
   */
  private registerDefaultSkills(): void {
    const defaultSkills: XiaoyiSkillDefinition[] = [
      new HealthQuerySkill().getDefinition(),
      new RiskAssessSkill().getDefinition(),
      new MedicationReminderSkill().getDefinition(),
      new NavigationSkill().getDefinition(),
      new AIConsultationSkill().getDefinition(),
      new EmergencySkill().getDefinition(),
      new DeviceConnectSkill().getDefinition(),
      new RehabTrainingSkill().getDefinition()
    ];

    for (const skill of defaultSkills) {
      this.registerSkill(skill);
    }

    console.info(`[Xiaoyi] 已注册 ${defaultSkills.length} 个医疗Skill`);
  }

  /**
   * 注册单个Skill
   */
  registerSkill(skill: XiaoyiSkillDefinition): void {
    this.skills.set(skill.config.skillId, skill);
    console.info(`[Xiaoyi] 注册Skill: ${skill.config.skillName} (${skill.config.skillId})`);
  }

  /**
   * 处理用户语音请求（主入口）
   * 这是小艺调用的核心方法
   */
  async processRequest(request: XiaoyiSkillRequest): Promise<XiaoyiSkillResponse> {
    const startTime = Date.now();

    console.info(`[Xiaoyi] 收到请求: skillId=${request.skillId}, query=${request.query}`);

    try {
      // 1. 获取或创建会话
      const session = this.getOrCreateSession(request.sessionId, request.userId);

      // 2. 记录用户消息到历史
      this.addMessageToSession(session, {
        role: 'user',
        content: request.query,
        timestamp: Date.now()
      });

      // 3. 查找Skill定义
      const skillDef = this.skills.get(request.skillId);
      if (!skillDef) {
        return this.createErrorResponse(request.skillId, 'SKILL_NOT_FOUND', `未找到Skill: ${request.skillId}`);
      }

      // 4. 权限检查（如果需要）
      if (skillDef.needAuth && !request.userId) {
        return this.createErrorResponse(request.skillId, 'AUTH_REQUIRED', '需要用户登录');
      }

      // 5. 调用Skill处理器
      const response = await this.invokeSkillHandler(skillDef, request);

      // 6. 记录助手响应到历史
      this.addMessageToSession(session, {
        role: 'assistant',
        content: response.voiceResponse,
        timestamp: Date.now(),
        skillId: request.skillId
      });

      // 7. 计算处理时间
      response.processingTime = Date.now() - startTime;

      console.info(`[Xiaoyi] 请求处理完成, 耗时=${response.processingTime}ms`);

      return response;
    } catch (error) {
      console.error('[Xiaoyi] 处理请求失败:', error);
      return this.createErrorResponse(
        request.skillId,
        'PROCESSING_ERROR',
        `处理失败: ${error.message}`
      );
    }
  }

  /**
   * 智能路由：根据用户输入自动匹配最佳Skill
   * 当用户没有明确指定Skill时调用此方法
   */
  async autoRouteAndProcess(query: string, userId: string, sessionId?: string): Promise<XiaoyiSkillResponse> {
    console.info(`[Xiaoyi] 自动路由: query=${query}`);

    let bestMatch: { skillId: string; confidence: number } | null = null;

    // 遍历所有Skill，找到最佳匹配
    for (const [skillId, skillDef] of this.skills) {
      for (const pattern of skillDef.intentPatterns) {
        const confidence = this.calculatePatternMatch(query, pattern.pattern);

        if (confidence > (bestMatch?.confidence || 0) && confidence > 0.5) {
          bestMatch = { skillId, confidence };
        }
      }
    }

    if (!bestMatch) {
      // 没有匹配的Skill，返回默认响应
      return {
        skillId: 'default',
        success: true,
        voiceResponse: '抱歉，我没有理解您的意思。您可以说"查血压"、"评估风险"、"导航到XX科室"等指令。',
        followUpSuggestions: ['查血压', '评估健康风险', 'AI问诊', '用药提醒'],
        processingTime: 10
      };
    }

    console.info(`[Xiaoyi] 路由到Skill: ${bestMatch.skillId}, 置信度=${bestMatch.confidence}`);

    // 构造请求并处理
    const request: XiaoyiSkillRequest = {
      skillId: bestMatch.skillId,
      sessionId: sessionId || this.generateSessionId(),
      userId: userId,
      query: query,
      intentText: query,
      parameters: this.extractParameters(query, bestMatch.skillId),
      timestamp: Date.now(),
      sourceDevice: 'phone'
    };

    return this.processRequest(request);
  }

  /**
   * 处理MCP协议消息（供小艺平台调用）
   */
  async handleMCPMessage(message: MCPMessage): Promise<MCPMessage> {
    console.info(`[Xiaoyi-MCP] 收到消息: type=${message.type}, method=${message.method}`);

    switch (message.type) {
      case 'request':
        return await this.handleMCPRequest(message);
      case 'notification':
        this.handleMCPNotification(message);
        return { ...message, type: 'response', result: { status: 'ok' }, timestamp: Date.now() };
      default:
        return {
          id: message.id,
          type: 'response',
          method: message.method,
          error: { code: -32600, message: '不支持的请求类型' },
          timestamp: Date.now()
        };
    }
  }

  /**
   * 处理MCP请求
   */
  private async handleMCPRequest(message: MCPMessage): Promise<MCPMessage> {
    const { method, params } = message;

    switch (method) {
      case 'tools/list':
        return {
          id: message.id,
          type: 'response',
          method,
          result: this.getMCPCapabilities().tools,
          timestamp: Date.now()
        };

      case 'tools/call':
        return await this.handleToolCall(message.id, params);

      case 'resources/list':
        return {
          id: message.id,
          type: 'response',
          method,
          result: this.getMCPCapabilities().resources,
          timestamp: Date.now()
        };

      case 'resources/read':
        return await this.handleResourceRead(message.id, params);

      case 'prompts/list':
        return {
          id: message.id,
          type: 'response',
          method,
          result: this.getMCPCapabilities().prompts,
          timestamp: Date.now()
        };

      default:
        return {
          id: message.id,
          type: 'response',
          method,
          error: { code: -32601, message: `未知方法: ${method}` },
          timestamp: Date.now()
        };
    }
  }

  /**
   * 处理工具调用（核心MCP方法）
   */
  private async handleToolCall(messageId: string, params: any): Promise<MCPMessage> {
    const { name, arguments: args } = params;

    console.info(`[Xiaoyi-MCP] 工具调用: name=${name}`);

    // 将MCP工具名映射到Skill ID
    const skillId = this.mapToolNameToSkillId(name);
    if (!skillId) {
      return {
        id: messageId,
        type: 'response',
        method: 'tools/call',
        error: { code: -32602, message: `未知工具: ${name}` },
        timestamp: Date.now()
      };
    }

    // 构造Skill请求
    const request: XiaoyiSkillRequest = {
      skillId: skillId,
      sessionId: args?.sessionId || this.generateSessionId(),
      userId: args?.userId || 'guest',
      query: args?.query || '',
      intentText: args?.query || '',
      parameters: args || {},
      context: args?.context,
      timestamp: Date.now(),
      sourceDevice: args?.sourceDevice || 'phone'
    };

    // 调用Skill并返回结果
    const response = await this.processRequest(request);

    return {
      id: messageId,
      type: 'response',
      method: 'tools/call',
      result: {
        content: [{
          type: 'text',
          text: response.voiceResponse
        }],
        isSuccess: response.success,
        uiData: response.uiResponse,
        action: response.action
      },
      timestamp: Date.now()
    };
  }

  /**
   * 声明MCP能力（向小艺平台注册所有可用工具）
   */
  async declareMCPCapabilities(): Promise<void> {
    const capabilities = this.getMCPCapabilities();

    console.info(`[Xiaoyi-MCP] 声明能力:`);
    console.info(`  - 工具数量: ${capabilities.tools.length}`);
    console.info(`  - 资源数量: ${capabilities.resources.length}`);
    console.info(`  - 提示词数量: ${capabilities.prompts.length});

    // 这里实际应该调用小艺平台的API进行注册
    // 目前仅做日志记录，正式环境需要实现真实注册逻辑
  }

  /**
   * 获取MCP能力声明
   */
  getMCPCapabilities(): MCPCapability {
    const tools = [];
    const resources = [];
    const prompts = [];

    // 遍历所有Skill，生成MCP工具定义
    for (const [skillId, skillDef] of this.skills) {
      tools.push({
        name: `medical_${skillId.replace(/\./g, '_')}`,
        description: skillDef.config.skillDescription,
        inputSchema: {
          type: 'object',
          properties: {
            query: { type: 'string', description: '用户查询内容' },
            sessionId: { type: 'string', description: '会话ID' },
            userId: { type: 'string', description: '用户ID' },
            context: { type: 'object', description: '上下文信息' }
          },
          required: ['query']
        }
      });
    }

    // 添加资源定义
    resources.push(
      {
        uri: 'medical://health/data/latest',
        name: '最新健康数据',
        description: '获取用户的最新健康指标数据',
        mimeType: 'application/json'
      },
      {
        uri: 'medical://risk/assessment',
        name: '风险评估报告',
        description: '获取最新的风险评估结果',
        mimeType: 'application/json'
      }
    );

    // 添加提示词模板
    prompts.push(
      {
        name: 'symptom_analysis',
        description: '症状分析提示词模板'
      },
      {
        name: 'medication_consult',
        description: '用药咨询提示词模板'
      }
    );

    return { tools, resources, prompts };
  }

  /**
   * 获取所有已注册的Skill列表
   */
  getRegisteredSkills(): XiaoyiSkillDefinition[] {
    return Array.from(this.skills.values());
  }

  /**
   * 获取会话历史
   */
  getSessionHistory(sessionId: string): XiaoyiMessage[] | null {
    const session = this.sessions.get(sessionId);
    return session ? session.messageHistory : null;
  }

  /**
   * 清除会话
   */
  clearSession(sessionId: string): boolean {
    return this.sessions.delete(sessionId);
  }

  // ==================== 私有辅助方法 ====================

  /**
   * 获取或创建会话
   */
  private getOrCreateSession(sessionId: string, userId: string): XiaoyiSessionContext {
    let session = this.sessions.get(sessionId);

    if (!session) {
      session = {
        sessionId,
        userId,
        startTime: Date.now(),
        lastActivityTime: Date.now(),
        messageHistory: [],
        accumulatedContext: {}
      };
      this.sessions.set(sessionId, session);
    } else {
      session.lastActivityTime = Date.now();
    }

    return session;
  }

  /**
   * 添加消息到会话
   */
  private addMessageToSession(session: XiaoyiSessionContext, message: XiaoyiMessage): void {
    session.messageHistory.push(message);

    // 保持最近20条消息
    if (session.messageHistory.length > 20) {
      session.messageHistory = session.messageHistory.slice(-20);
    }
  }

  /**
   * 调用Skill处理器
   */
  private async invokeSkillHandler(
    skillDef: XiaoyiSkillDefinition,
    request: XiaoyiSkillRequest
  ): Promise<XiaoyiSkillResponse> {
    // 根据handler名称动态调用对应的Skill实例方法
    switch (skillDef.handler) {
      case 'handleHealthQuery':
        return new HealthQuerySkill().handle(request);
      case 'handleRiskAssess':
        return new RiskAssessSkill().handle(request);
      case 'handleMedicationReminder':
        return new MedicationReminderSkill().handle(request);
      case 'handleNavigation':
        return new NavigationSkill().handle(request);
      case 'handleAIConsultation':
        return new AIConsultationSkill().handle(request);
      case 'handleEmergency':
        return new EmergencySkill().handle(request);
      case 'handleDeviceConnect':
        return new DeviceConnectSkill().handle(request);
      case 'handleRehabTraining':
        return new RehabTrainingSkill().handle(request);
      default:
        return this.createErrorResponse(
          request.skillId,
          'HANDLER_NOT_FOUND',
          `未知的处理器: ${skillDef.handler}`
        );
    }
  }

  /**
   * 计算模式匹配度
   */
  private calculatePatternMatch(query: string, pattern: string): number {
    // 简单的关键词匹配（实际项目可使用更复杂的NLP）
    if (pattern.startsWith('^') && pattern.endsWith('$')) {
      // 正则表达式匹配
      const regex = new RegExp(pattern);
      return regex.test(query) ? 1.0 : 0.0;
    } else {
      // 关键词包含匹配
      const lowerQuery = query.toLowerCase();
      const lowerPattern = pattern.toLowerCase();

      if (lowerQuery.includes(lowerPattern)) {
        return 0.9;
      }

      // 计算关键词重叠度
      const queryWords = lowerQuery.split(/\s+/);
      const patternWords = lowerPattern.split(/\s+/);
      let matchCount = 0;

      for (const pWord of patternWords) {
        if (queryWords.some(qWord => qWord.includes(pWord) || pWord.includes(qWord))) {
          matchCount++;
        }
      }

      return matchCount / patternWords.length;
    }
  }

  /**
   * 从查询中提取参数
   */
  private extractParameters(query: string, skillId: string): Record<string, string> {
    const params: Record<string, string> = {};
    const skillDef = this.skills.get(skillId);

    if (!skillDef) return params;

    for (const pattern of skillDef.intentPatterns) {
      if (pattern.parameters) {
        // 简单的参数提取（实际可使用正则捕获组）
        for (const param of pattern.parameters) {
          params[param] = query; // 简化处理，实际应提取具体值
        }
      }
    }

    return params;
  }

  /**
   * 将MCP工具名映射到Skill ID
   */
  private mapToolNameToSkillId(toolName: string): string | null {
    const mapping: Record<string, string> = {
      'medical_query_health': 'medical.query.health',
      'medical_risk_assess': 'medical.risk.assess',
      'medical_medication_remind': 'medical.medication.remind',
      'medical_navigation_start': 'medical.navigation.start',
      'medical_ai_consultation': 'medical.ai.consultation',
      'medical_emergency_sos': 'medical.emergency.sos',
      'medical_device_connect': 'medical.device.connect',
      'medical_rehab_start': 'medical.rehab.start'
    };

    return mapping[toolName] || null;
  }

  /**
   * 创建错误响应
   */
  private createErrorResponse(
    skillId: string,
    errorCode: string,
    errorMessage: string
  ): XiaoyiSkillResponse {
    return {
      skillId,
      success: false,
      voiceResponse: `抱歉，${errorMessage}`,
      processingTime: 0,
      errorCode,
      errorMessage
    };
  }

  /**
   * 生成会话ID
   */
  private generateSessionId(): string {
    return `xy_session_${Date.now()}_${Math.random().toString(36).substring(2, 8)}`;
  }

  /**
   * 处理资源读取
   */
  private async handleResourceRead(messageId: string, params: any): Promise<MCPMessage> {
    const { uri } = params;

    console.info(`[Xiaoyi-MCP] 读取资源: uri=${uri}`);

    // 根据URI返回对应数据
    let data: any = null;

    switch (uri) {
      case 'medical://health/data/latest':
        // 返回最新健康数据（需从数据库读取）
        data = { bloodPressure: '120/80', heartRate: 72, bloodSugar: 5.6 };
        break;
      case 'medical://risk/assessment':
        // 返回风险评估结果
        data = { overallRisk: 0.35, level: 'medium', suggestions: [] };
        break;
      default:
        return {
          id: messageId,
          type: 'response',
          method: 'resources/read',
          error: { code: -32602, message: `未知资源: ${uri}` },
          timestamp: Date.now()
        };
    }

    return {
      id: messageId,
      type: 'response',
      method: 'resources/read',
      result: {
        contents: [{
          uri,
        mimeType: 'application/json',
          data: JSON.stringify(data)
        }]
      },
      timestamp: Date.now()
    };
  }

  /**
   * 处理MCP通知
   */
  private handleMCPNotification(message: MCPMessage): void {
    console.info(`[Xiaoyi-MCP] 收到通知: method=${message.method}`);
    // 处理来自小艺平台的通知（如会话结束、设备状态变化等）
  }
}

// 导出单例实例
export const xiaoyiSkillManager = XiaoyiSkillManager.getInstance();
