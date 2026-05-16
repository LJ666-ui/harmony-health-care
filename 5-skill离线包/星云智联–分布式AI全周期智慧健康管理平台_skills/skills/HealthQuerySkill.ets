/**
 * S1 - 健康数据查询技能
 * 
 * 属性 | 属性值
 * Skill ID | 医疗.query.health
 * Skill 名称 | 健康数据查询
 * 触发描述 | "查血压"、"血糖多少"、"心率情况"、"健康报告"、"血氧率"
 * 支持指标 | 血压、血糖、心率、体重、血氧、体温、步数
 * 输出形式 | 图表 + 报告 + 引导补充详情
 * 所需权限 | ohos.permission.READ_HEALTH_DATA
 * 预计耗时 | ~500ms
 * 触发动作 | 调用 AddHealthRecord 实现页面引导用户录入
 */

import { HealthDataRecord, HealthDataType } from '../models/HealthDataModel';
import { healthDataStore } from '../stores/HealthDataStore';

export interface HealthQueryResult {
  dataType: HealthDataType;
  value: number | string;
  unit: string;
  timestamp: Date;
  trend: 'normal' | 'high' | 'low' | 'critical';
  suggestion?: string;
}

export class HealthQuerySkill {
  private static readonly SKILL_ID = '医疗.query.health';
  
  /**
   * 检查是否匹配该技能
   */
  static match(query: string): boolean {
    const triggers = [
      '查血压', '血压多少', '血压情况',
      '血糖', '血糖多少', '血糖值',
      '心率', '心跳', '脉搏',
      '体重', '体重多少',
      '血氧', '血氧率', '血氧饱和度',
      '体温', '发烧', '温度',
      '步数', '运动量', '走了多少',
      '健康报告', '健康数据', '身体状况'
    ];
    
    return triggers.some(trigger => query.includes(trigger));
  }

  /**
   * 执行健康数据查询
   */
  static async execute(query: string): Promise<HealthQueryResult> {
    const dataType = this.extractDataType(query);
    const latestRecord = await healthDataStore.getLatest(dataType);
    
    if (!latestRecord) {
      return {
        dataType,
        value: '暂无数据',
        unit: '',
        timestamp: new Date(),
        trend: 'normal',
        suggestion: `暂无${this.getDataTypeName(dataType)}数据，建议先录入数据`
      };
    }
    
    const analysis = this.analyzeValue(dataType, latestRecord.value);
    
    return {
      dataType,
      value: latestRecord.value,
      unit: latestRecord.unit,
      timestamp: latestRecord.timestamp,
      trend: analysis.trend,
      suggestion: analysis.suggestion
    };
  }

  /**
   * 从查询语句中提取数据类型
   */
  private static extractDataType(query: string): HealthDataType {
    if (query.includes('血压')) return 'blood_pressure';
    if (query.includes('血糖')) return 'blood_glucose';
    if (query.includes('心率') || query.includes('心跳') || query.includes('脉搏')) return 'heart_rate';
    if (query.includes('体重')) return 'weight';
    if (query.includes('血氧')) return 'blood_oxygen';
    if (query.includes('体温') || query.includes('发烧') || query.includes('温度')) return 'temperature';
    if (query.includes('步数') || query.includes('运动')) return 'steps';
    return 'health_report';
  }

  /**
   * 分析数值是否正常
   */
  private static analyzeValue(type: HealthDataType, value: number): { trend: 'normal' | 'high' | 'low' | 'critical'; suggestion: string } {
    const ranges = {
      blood_pressure: { low: 90, high: 140, critical_low: 60, critical_high: 180 },
      blood_glucose: { low: 3.9, high: 6.1, critical_low: 2.8, critical_high: 16.7 },
      heart_rate: { low: 60, high: 100, critical_low: 40, critical_high: 150 },
      blood_oxygen: { low: 95, high: 100, critical_low: 90, critical_high: 100 },
      temperature: { low: 36.0, high: 37.3, critical_low: 35.0, critical_high: 39.0 }
    };
    
    const range = ranges[type];
    if (!range) return { trend: 'normal', suggestion: '数据正常' };
    
    if (value <= range.critical_low || value >= range.critical_high) {
      return {
        trend: 'critical',
        suggestion: `⚠️ 数值异常！${type === 'temperature' ? '请立即就医或采取降温措施' : '建议尽快就医检查'}`
      };
    }
    
    if (value < range.low) {
      return {
        trend: 'low',
        suggestion: `数值偏低，建议${this.getLowSuggestion(type)}`
      };
    }
    
    if (value > range.high) {
      return {
        trend: 'high',
        suggestion: `数值偏高，建议${this.getHighSuggestion(type)}`
      };
    }
    
    return { trend: 'normal', suggestion: '✅ 数据在正常范围内' };
  }

  private static getLowSuggestion(type: HealthDataType): string {
    const suggestions = {
      blood_pressure: '适当休息，避免剧烈运动',
      blood_glucose: '补充适量糖分，监测血糖变化',
      heart_rate: '保持平静，如有不适请就医',
      blood_oxygen: '保持通风，深呼吸',
      temperature: '注意保暖，多喝温水'
    };
    return suggestions[type] || '注意观察';
  }

  private static getHighSuggestion(type: HealthDataType): string {
    const suggestions = {
      blood_pressure: '低盐饮食，按时服药，定期监测',
      blood_glucose: '控制饮食，适量运动，遵医嘱用药',
      heart_rate: '放松心情，避免刺激性饮料',
      blood_oxygen: '检查测量方式，如持续偏低请就医',
      temperature: '物理降温，多喝水，必要时服用退烧药'
    };
    return suggestions[type] || '注意观察';
  }

  private static getDataTypeName(type: HealthDataType): string {
    const names = {
      blood_pressure: '血压',
      blood_glucose: '血糖',
      heart_rate: '心率',
      weight: '体重',
      blood_oxygen: '血氧',
      temperature: '体温',
      steps: '步数',
      health_report: '健康报告'
    };
    return names[type] || type;
  }

  /**
   * 格式化输出结果
   */
  static formatResult(result: HealthQueryResult): string {
    const typeName = this.getDataTypeName(result.dataType);
    const timeStr = result.timestamp.toLocaleString('zh-CN');
    
    let output = `📊 **${typeName}查询结果**\n\n`;
    output += `📌 当前值: ${result.value} ${result.unit}\n`;
    output += `⏰ 记录时间: ${timeStr}\n`;
    output += `📈 状态: ${this.getTrendEmoji(result.trend)} ${this.getTrendText(result.trend)}\n\n`;
    
    if (result.suggestion) {
      output += `💡 建议: ${result.suggestion}\n\n`;
    }
    
    output += `➕ 如需录入新数据，请点击"添加健康记录"`;
    
    return output;
  }

  private static getTrendEmoji(trend: string): string {
    const emojis = {
      normal: '✅',
      high: '🔴',
      low: '🟡',
      critical: '⚠️'
    };
    return emojis[trend] || '❓';
  }

  private static getTrendText(trend: string): string {
    const texts = {
      normal: '正常',
      high: '偏高',
      low: '偏低',
      critical: '异常'
    };
    return texts[trend] || '未知';
  }
}
