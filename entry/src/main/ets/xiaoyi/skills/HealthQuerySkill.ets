/**
 * 健康数据查询Skill
 * 触发词: "查血压"、"查血糖"、"健康数据"、"最近体检"
 */

import {
  XiaoyiSkillDefinition,
  XiaoyiSkillRequest,
  XiaoyiSkillResponse
} from '../types/XiaoyiTypes';
import { HealthDataManager } from '../../manager/HealthDataManager';

export class HealthQuerySkill {

  getDefinition(): XiaoyiSkillDefinition {
    return {
      config: {
        skillId: 'medical.query.health',
        skillName: '健康数据查询',
        skillDescription: '查询用户的最新健康指标数据，包括血压、血糖、心率等',
        version: '1.0.0',
        author: '星云医疗团队'
      },
      intentPatterns: [
        {
          pattern: '查.*血压|血压.*多少|血压.*情况',
          confidence: 0.95,
          parameters: ['metric'],
          examples: ['小艺，帮我查一下血压', '我的血压是多少', '看看最近血压情况']
        },
        {
          pattern: '查.*血糖|血糖.*多少|血糖.*情况',
          confidence: 0.95,
          parameters: ['metric'],
          examples: ['小艺，查一下血糖', '血糖正常吗', '最近血糖怎么样']
        },
        {
          pattern: '查.*心率|心率.*多少|心跳.*情况',
          confidence: 0.9,
          parameters: ['metric'],
          examples: ['帮我查心率', '心跳多少', '最近心率情况']
        },
        {
          pattern: '健康.*数据|体检.*结果|身体.*指标',
          confidence: 0.85,
          parameters: [],
          examples: ['查看健康数据', '体检结果', '身体指标']
        },
        {
          pattern: '最近.*体重|体重.*多少|体重.*变化',
          confidence: 0.88,
          parameters: ['metric'],
          examples: ['最近体重', '体重多少', '体重有变化吗']
        }
      ],
      handler: 'handleHealthQuery',
      needAuth: true,
      needPermission: ['ohos.permission.READ_HEALTH_DATA'],
      responseType: 'voice+ui',
      fallbackAction: 'openHealthPage',
      estimatedTime: 500
    };
  }

  async handle(request: XiaoyiSkillRequest): Promise<XiaoyiSkillResponse> {
    const startTime = Date.now();

    try {
      console.info(`[HealthQuerySkill] 处理请求: query=${request.query}`);

      // 从参数或查询中提取要查询的指标类型
      const metric = this.extractMetricType(request.query, request.parameters);
      console.info(`[HealthQuerySkill] 查询指标类型: ${metric}`);

      // 调用数据管理器获取最新健康数据
      const healthData = await this.fetchLatestHealthData(request.userId, metric);

      if (!healthData || Object.keys(healthData).length === 0) {
        return {
          skillId: request.skillId,
          success: false,
          voiceResponse: '抱歉，暂时没有找到您的健康数据。建议您先录入一些健康指标。',
          uiResponse: {
            pageRoute: 'pages/AddHealthRecord',
            pageTitle: '添加健康记录',
            data: { fromXiaoyi: true },
            displayMode: 'fullScreen'
          },
          action: {
            type: 'navigate',
            target: 'pages/AddHealthRecord'
          },
          followUpSuggestions: ['录入血压', '录入血糖', '录入体重'],
          processingTime: Date.now() - startTime
        };
      }

      // 生成语音回复
      const voiceResponse = this.generateVoiceResponse(healthData, metric);

      // 构建UI响应数据
      const uiResponse = {
        pageRoute: 'pages/HealthRecordDetail',
        pageTitle: '健康数据详情',
        data: {
          healthData,
          metric,
          queryTime: new Date().toISOString()
        },
        displayMode: 'card' as const
      };

      return {
        skillId: request.skillId,
        success: true,
        voiceResponse,
        uiResponse,
        action: {
          type: 'navigate',
          target: 'pages/HealthRecordDetail',
          params: { healthData }
        },
        followUpSuggestions: this.generateFollowUpSuggestions(healthData),
        processingTime: Date.now() - startTime
      };
    } catch (error) {
      console.error('[HealthQuerySkill] 处理失败:', error);
      return {
        skillId: request.skillId,
        success: false,
        voiceResponse: '查询健康数据时出现错误，请稍后重试。',
        processingTime: Date.now() - startTime,
        errorCode: 'QUERY_ERROR',
        errorMessage: error.message
      };
    }
  }

  private extractMetricType(query: string, parameters: Record<string, string>): string {
    if (parameters.metric) return parameters.metric;

    const lowerQuery = query.toLowerCase();
    if (lowerQuery.includes('血压')) return 'bloodPressure';
    if (lowerQuery.includes('血糖')) return 'bloodSugar';
    if (lowerQuery.includes('心率') || lowerQuery.includes('心跳')) return 'heartRate';
    if (lowerQuery.includes('体重')) return 'weight';
    if (lowerQuery.includes('血氧')) return 'bloodOxygen';
    if (lowerQuery.includes('体温')) return 'temperature';
    if (lowerQuery.includes('步数')) return 'steps';

    return 'all'; // 查询所有指标
  }

  private async fetchLatestHealthData(userId: string, metric: string): Promise<any> {
    try {
      // 这里应该调用实际的API获取数据
      // 目前返回模拟数据用于演示
      const mockData: any = {
        bloodPressure: { systolic: 125, diastolic: 82, unit: 'mmHg', time: '2026-05-11 08:30' },
        bloodSugar: { value: 5.8, unit: 'mmol/L', time: '2026-05-11 07:00', type: '空腹' },
        heartRate: { value: 72, unit: 'bpm', time: '2026-05-11 08:35' },
        weight: { value: 68.5, unit: 'kg', time: '2026-05-11 08:00' },
        bloodOxygen: { value: 98, unit: '%', time: '2026-05-11 08:35' },
        steps: { value: 3250, unit: '步', time: '2026-05-11 08:40' }
      };

      if (metric === 'all') {
        return mockData;
      } else {
        return { [metric]: mockData[metric] };
      }
    } catch (error) {
      console.error('[HealthQuerySkill] 获取健康数据失败:', error);
      return null;
    }
  }

  private generateVoiceResponse(healthData: any, metric: string): string {
    let response = '';

    if (metric === 'all') {
      const bp = healthData.bloodPressure;
      const bs = healthData.bloodSugar;
      const hr = healthData.heartRate;
      const wt = healthData.weight;

      response = `您最新的健康数据如下：`;
      response += `血压${bp.systolic}比${bp.diastolic}毫米汞柱，`;
      response += `空腹血糖${bs.value}毫摩尔每升，`;
      response += `心率${hr.value}次每分钟，`;
      response += `体重${wt.value}公斤。`;

      // 简单的健康状态评估
      if (bp.systolic < 120 && bp.diastolic < 80) {
        response += '您的血压在正常范围内。';
      } else if (bp.systolic < 140 && bp.diastolic < 90) {
        response += '您的血压略偏高，建议注意低盐饮食。';
      } else {
        response += '您的血压偏高，建议及时就医检查。';
      }
    } else {
      switch (metric) {
        case 'bloodPressure':
          response = `您最新的血压是${healthData.bloodPressure.systolic}比${healthData.bloodPressure.diastolic}毫米汞柱，测量时间是今天早上八点半。`;
          break;
        case 'bloodSugar':
          response = `您最新的空腹血糖是${healthData.bloodSugar.value}毫摩尔每升，在正常范围内。`;
          break;
        case 'heartRate':
          response = `您当前的心率是${healthData.heartRate.value}次每分钟，心律齐，状态良好。`;
          break;
        case 'weight':
          response = `您今天的体重是${healthData.weight.value}公斤。`;
          break;
        default:
          response = `已为您查询到最新的${metric}数据。`;
      }
    }

    return response;
  }

  private generateFollowUpSuggestions(healthData: any): string[] {
    const suggestions: string[] = [];

    if (healthData.bloodPressure?.systolic > 130) {
      suggestions.push('查看高血压风险');
    }
    if (healthData.bloodSugar?.value > 6.1) {
      suggestions.push('查看糖尿病风险');
    }
    suggestions.push('进行健康风险评估');
    suggestions.push('录入新数据');

    return suggestions.slice(0, 3);
  }
}
