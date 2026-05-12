/**
 * DeepSeek 对话管理器
 * 封装医疗场景的常用Prompt模板和对话管理逻辑
 *
 * 使用示例:
 * ```typescript
 * const manager = new DeepSeekChatManager();
 *
 * // 症状分析
 * const result = await manager.analyzeSymptom('头疼，持续3天', 35, '男');
 *
 * // 用药咨询
 * const advice = await manager.consultMedication('阿司匹林', '高血压', ['过敏史: 无']);
 * ```
 */

import { siliconFlowClient } from './SiliconFlowClient';
import { ChatMessage, ConversationSession } from './types/DeepSeekTypes';

export class DeepSeekChatManager {
  private defaultSystemPrompt: string = `你是一位专业的AI医疗助手"星云医生"，具备以下能力：
1. 基于用户描述的症状进行初步分析和建议
2. 提供用药咨询和安全指导
3. 制定个性化的康复方案
4. 解读医学检验报告

重要原则：
- 你的回答仅供参考，不能替代专业医生的诊断
- 对于紧急情况（如胸痛、呼吸困难、严重外伤），立即建议就医或拨打急救电话
- 回答要通俗易懂，避免过多专业术语
- 每次回答都要包含免责声明`;

  /**
   * 分析症状
   */
  async analyzeSymptom(
    symptomDescription: string,
    age: number,
    gender: string,
    additionalInfo?: string
  ): Promise<string> {
    const prompt = `请分析以下患者的症状：

【患者信息】
- 年龄：${age}岁
- 性别：${gender}
- ${additionalInfo || '无特殊信息'}

【症状描述】
${symptomDescription}

请按以下格式回答：
1. 可能的原因（列出2-3种可能，按可能性排序）
2. 需要关注的情况（哪些情况需要立即就医）
3. 初步建议（生活调理、观察要点等）
4. 建议就诊科室（如需要）

注意：在回答末尾加上"⚠️ 以上为AI分析结果，仅供参考，具体诊断请以医生意见为准。"`;

    return await siliconFlowClient.chatSimple(prompt, this.defaultSystemPrompt);
  }

  /**
   * 用药咨询
   */
  async consultMedication(
    drugName: string,
    purpose: string,
    patientInfo?: string[]
  ): Promise<string> {
    const patientContext = patientInfo ? patientInfo.join('\n') : '无特殊信息';

    const prompt = `请提供以下药物的用药指导：

【药物名称】
${drugName}

【使用目的】
${purpose}

【患者信息】
${patientContext}

请按以下格式回答：
1. 药物基本信息（适应症、常见剂量）
2. 正确用法用量（服用时间、方式、剂量）
3. 注意事项（饮食禁忌、不良反应、药物相互作用）
4. 特殊人群提醒（儿童/孕妇/老年人/肝肾功能不全者）
5. 存储条件

重要：如果该药物有严重风险或禁忌，必须明确指出！`;

    return await siliconFlowClient.chatSimple(prompt, this.defaultSystemPrompt);
  }

  /**
   * 生成康复方案
   */
  async generateRehabPlan(
    condition: string,
    surgeryOrDisease: string,
    daysAfterSurgery?: number,
    currentStatus?: string
  ): Promise<string> {
    const prompt = `请为以下患者制定康复方案：

【疾病/手术】
${surgeryOrDisease}

【当前状况】
- ${condition}
- 术后/发病时间：${daysAfterSurgery ? `${daysAfterSurgery}天` : '未知'}
- 当前状态：${currentStatus || '未提供'}

请制定分阶段康复计划：

第一阶段（第1-7天）：
- 目标
- 可进行的活动
- 注意事项

第二阶段（第8-30天）：
- 目标
- 康复训练项目
- 强度和频率

第三阶段（31天以后）：
- 目标
- 进阶训练
- 复查时间点

每个阶段都要包含：
✅ 可以做的事
❌ 避免做的事
⚠️ 警告信号（何时需要联系医生）`;

    return await siliconFlowClient.chatSimple(prompt, this.defaultSystemPrompt);
  }

  /**
   * 解读检验报告
   */
  async interpretLabReport(
    reportType: string,
    results: Array<{ item: string; value: string; unit: string; referenceRange: string }>,
    patientAge?: number
  ): Promise<string> {
    const resultsText = results.map(r =>
      `- ${r.item}: ${r.value} ${r.unit} (参考范围: ${r.referenceRange})`
    ).join('\n');

    const prompt = `请解读以下${reportType}报告：

【基本信息】
- 报告类型：${reportType}
- 患者年龄：${patientAge || '未知'}岁

【检验结果】
${resultsText}

请按以下格式解读：
1. 总体评价（正常/异常/需关注）
2. 异常指标详解（逐项说明偏高/偏低的意义）
3. 可能的原因分析
4. 生活建议（饮食、运动、作息等）
5. 就医建议（是否需要复诊、多久复查）

对于明显异常的指标，用 ⚠️ 标记并重点说明。`;

    return await siliconFlowClient.chatSimple(prompt, this.defaultSystemPrompt);
  }

  /**
   * 生成健康科普内容
   */
  async generateHealthEducation(
    topic: string,
    targetAudience: string = '中老年人群',
    style: string = '通俗易懂'
  ): Promise<string> {
    const prompt = `请生成一篇关于"${topic}"的健康科普文章：

【目标读者】
${targetAudience}

【写作风格】
${style}

要求：
1. 标题吸引人且准确
2. 开头用简短案例引入
3. 分章节讲解（使用小标题）
4. 适当使用比喻让复杂概念易懂
5. 提供3-5条可操作的建议
6. 结尾总结要点
7. 字数控制在800-1200字

文章结构建议：
- 引言（为什么这个话题重要）
- 基础知识（是什么、为什么）
- 危害/影响（不重视会怎样）
- 预防/改善方法（具体怎么做）
- 常见误区澄清
- 总结与行动清单`;

    return await siliconFlowClient.chatSimple(prompt, this.defaultSystemPrompt);
  }

  /**
   * 多轮对话 - 创建会话
   */
  createConversation(userId: string): ConversationSession {
    const sessionId = `conv_${Date.now()}_${Math.random().toString(36).substring(2, 8)}`;
    return siliconFlowClient.createOrGetSession(sessionId, userId);
  }

  /**
   * 多轮对话 - 发送消息
   */
  async sendMessage(
    sessionId: string,
    userMessage: string,
    systemPrompt?: string
  ): Promise<string> {
    // 添加用户消息到历史
    siliconFlowClient.addMessageToSession(sessionId, {
      role: 'user',
      content: userMessage
    });

    // 获取历史消息
    const history = siliconFlowClient.getSessionHistory(sessionId) || [];

    // 调用API
    const response = await siliconFlowClient.chat(history, { systemPrompt });

    // 提取助手回复
    let assistantMessage = '';
    if (response.choices && response.choices.length > 0) {
      const content = response.choices[0].message.content;
      assistantMessage = typeof content === 'string' ? content : '';
    }

    // 添加助手回复到历史
    if (assistantMessage) {
      siliconFlowClient.addMessageToSession(sessionId, {
        role: 'assistant',
        content: assistantMessage
      });
    }

    return assistantMessage;
  }

  /**
   * 流式对话 - 实时返回生成的内容
   */
  async sendMessageStream(
    sessionId: string,
    userMessage: string,
    onChunk: (chunk: string) => void,
    onComplete: () => void,
    onError: (error: Error) => void,
    systemPrompt?: string
  ): Promise<void> {
    try {
      // 添加用户消息到历史
      siliconFlowClient.addMessageToSession(sessionId, {
        role: 'user',
        content: userMessage
      });

      // 获取历史消息
      const history = siliconFlowClient.getSessionHistory(sessionId) || [];

      // 流式调用
      let fullResponse = '';
      await siliconFlowClient.chatStream(
        history,
        (chunk, done) => {
          if (!done && chunk) {
            fullResponse += chunk;
            onChunk(chunk);
          }
          if (done) {
            // 添加完整回复到历史
            if (fullResponse) {
              siliconFlowClient.addMessageToSession(sessionId, {
                role: 'assistant',
                content: fullResponse
              });
            }
            onComplete();
          }
        },
        { systemPrompt }
      );
    } catch (error) {
      onError(error as Error);
    }
  }
}

// 导出实例
export const deepSeekChatManager = new DeepSeekChatManager();
