/**
 * Coze API 客户端
 * 用于对接Coze智能体平台，调用专业医疗Bot和工作流
 *
 * 使用场景:
 * 1. 专科会诊（内科/眼科/康复等）
 * 2. 标准化诊疗流程执行
 * 3. 工作流自动化（预问诊/随访/急救）
 */

import { http } from '@kit.NetworkKit';
import { COZE_CONFIG } from '../common/constants/CozeConfig';

export interface CozeConfig {
  apiKey: string;
  baseUrl: string;
  botId?: string;
}

export interface CozeMessage {
  role: 'user' | 'assistant';
  content: string;
  contentType?: 'text' | 'object_string' | 'card';
}

export interface CozeRequest {
  botId: string;
  userId: string;
  messages: CozeMessage[];
  stream?: boolean;
  autoSaveHistory?: boolean;
  additionalMessages?: CozeMessage[];
}

export interface CozeResponse {
  code: number;
  msg: string;
  data: {
    conversationId: string;
    id: string;
    type: 'answer' | 'followUp' | 'functionCall';
    content: string;
    contentType: string;
  };
}

export class CozeApiClient {
  private config: CozeConfig;

  constructor(config: Partial<CozeConfig> = {}) {
    this.config = {
      apiKey: config.apiKey || 'YOUR_COZE_API_KEY', // 需要替换为真实的Coze API Key
      baseUrl: config.baseUrl || 'https://api.coze.cn/v3',
      botId: config.botId
    };
  }

  /**
   * 发送消息给Coze Bot
   */
  async sendMessage(
    message: string,
    userId: string,
    botId?: string,
    history?: CozeMessage[]
  ): Promise<string> {
    const request: CozeRequest = {
      botId: botId || this.config.botId || '',
      userId: userId,
      messages: [
        ...(history || []),
        { role: 'user', content: message, contentType: 'text' }
      ],
      stream: false,
      autoSaveHistory: true
    };

    console.info(`[Coze] 发送消息到Bot: ${request.botId}`);

    try {
      const response = await this.doHttpRequest('/chat', request);

      if (response.code === 0) {
        return response.data.content;
      } else {
        throw new Error(`Coze API错误: ${response.msg}`);
      }
    } catch (error) {
      console.error('[Coze] 发送消息失败:', error);
      throw error;
    }
  }

  /**
   * 调用内科智能体
   */
  async consultInternalMedicine(symptoms: string, patientInfo: object): Promise<string> {
    const prompt = `患者信息：${JSON.stringify(patientInfo)}
症状描述：${symptoms}

请作为内科专家进行初步分析：
1. 可能的诊断
2. 建议的检查项目
3. 初步处理建议
4. 是否需要转诊专科`;

    return this.sendMessage(prompt, 'internal_medicine_bot', this.getBotId('internalMedicine'));
  }

  /**
   * 调用眼科智能体
   */
  async consultOphthalmology(eyeSymptoms: string, visionData?: object): Promise<string> {
    const prompt = `眼部症状：${eyeSymptoms}
${visionData ? `视力数据：${JSON.stringify(visionData)}` : ''}

请作为眼科专家进行分析：
1. 眼部问题初步判断
2. 视力状况评估
3. 用眼建议
4. 就医建议`;

    return this.sendMessage(prompt, 'ophthalmology_bot', this.getBotId('ophthalmology'));
  }

  /**
   * 调用康复智能体
   */
  async consultRehabilitation(condition: string, surgeryInfo?: string): Promise<string> {
    const prompt = `疾病/手术情况：${condition}
${surgeryInfo ? `手术详情：${surgeryInfo}` : ''}

请制定康复方案：
1. 康复阶段划分
2. 各阶段训练内容
3. 注意事项
4. 预期效果`;

    return this.sendMessage(prompt, 'rehabilitation_bot', this.getBotId('rehabilitation'));
  }

  private getBotId(type: string): string {
    const botIds: Record<string, string> = {
      internalMedicine: 'YOUR_INTERNAL_MEDICINE_BOT_ID',
      ophthalmology: 'YOUR_OPHTHALMOLOGY_BOT_ID',
      rehabilitation: 'YOUR_REHABILITATION_BOT_ID'
    };

    return botIds[type] || '';
  }

  private async doHttpRequest(path: string, data: any): Promise<any> {
    const httpRequest = http.createHttp();

    try {
      const response = await httpRequest.request(
        `${this.config.baseUrl}${path}`,
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${this.config.apiKey}`
          },
          extraData: JSON.stringify(data),
          connectTimeout: 10000,
          readTimeout: 30000
        }
      );

      if (response.responseCode !== 200) {
        throw new Error(`HTTP错误 ${response.responseCode}: ${response.result}`);
      }

      return JSON.parse(response.result as string);
    } catch (error) {
      throw error;
    } finally {
      httpRequest.destroy();
    }
  }
}

// 导出实例 - 使用真实配置
export const cozeApiClient = new CozeApiClient({
  apiKey: COZE_CONFIG.token,
  baseUrl: COZE_CONFIG.apiUrl,
  botId: COZE_CONFIG.botId
});
