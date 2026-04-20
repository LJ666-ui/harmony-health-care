import { RiskAssessmentResult, Suggestion } from './RiskAssessmentEngine';
import { OverallTrend } from './TrendAnalyzer';

export interface ReportSection {
  title: string;
  content: string;
  type: 'TEXT' | 'TABLE' | 'LIST' | 'CHART' | 'WARNING';
  priority: number;
}

export interface GeneratedReport {
  id: string;
  generatedAt: string;
  title: string;
  summary: string;
  sections: ReportSection[];
  overallRiskLevel: string;
  actionItems: ActionItem[];
}

export interface ActionItem {
  id: string;
  category: string;
  description: string;
  priority: 'IMMEDIATE' | 'SOON' | 'ROUTINE';
  deadline?: string;
  responsibleParty: string;
}

export class ReportGenerator {

  private static readonly REPORT_TEMPLATES = {
    header: `
═══════════════════════════════════════
    🏥 星云医疗助手 - AI健康风险评估报告
═══════════════════════════════════════
`,
    
    disclaimer: `
───────────────────────────────────────
⚠️ 重要声明：
本报告由AI辅助生成，基于您提供的健康数据和医学指南规则。
报告内容仅供参考，不能替代专业医疗诊断和建议。
如有任何健康问题，请及时咨询专业医生。
───────────────────────────────────────
`
  };

  private constructor() {}

  static generateComprehensiveReport(
    result: RiskAssessmentResult,
    trendData?: OverallTrend
  ): GeneratedReport {
    
    console.log('[ReportGenerator] 开始生成综合评估报告...');
    
    const sections: ReportSection[] = [];

    sections.push(this.generateBasicInfoSection(result));
    sections.push(this.generateOverallScoreSection(result));
    sections.push(this.generateDetailedRisksSection(result));
    
    if (result.featureInterpretations && result.featureInterpretations.length > 0) {
      sections.push(this.generateFeatureAnalysisSection(result));
    }

    if (result.suggestions && result.suggestions.length > 0) {
      sections.push(this.generateSuggestionsSection(result));
    }

    if (trendData) {
      sections.push(this.generateTrendSection(trendData));
    }

    sections.push(this.generateActionPlanSection(result));

    const summary = this.generateSummary(result);
    const actionItems = this.extractActionItems(result);

    const report: GeneratedReport = {
      id: `REPORT_${Date.now()}`,
      generatedAt: new Date().toISOString(),
      title: `AI共病风险评估报告 - ${new Date().toLocaleDateString('zh-CN')}`,
      summary: summary,
      sections: sections,
      overallRiskLevel: result.overallLevel,
      actionItems: actionItems
    };

    console.log(`[ReportGenerator] 报告生成完成，共${sections.length}个章节`);
    
    return report;
  }

  private static generateBasicInfoSection(result: RiskAssessmentResult): ReportSection {
    const content = `
评估编号：${result.assessmentId}
评估时间：${new Date(result.timestamp).toLocaleString('zh-CN')}
评估方法：${this.getMethodLabel(result.assessmentMethod)}
模型版本：${result.modelVersion}
处理耗时：${result.processingTimeMs}ms
置信度：${(result.confidence * 100).toFixed(0)}%
`;

    return {
      title: '📋 基本信息',
      content: content.trim(),
      type: 'TEXT',
      priority: 1
    };
  }

  private static generateOverallScoreSection(result: RiskAssessmentResult): ReportSection {
    const score = (result.overallScore * 100).toFixed(1);
    const levelEmoji = this.getLevelEmoji(result.overallLevel);
    const levelLabel = this.getLevelLabel(result.overallLevel);

    const content = `
┌──────────────────────────────────┐
│                                  │
│     综合风险评分：${score.padStart(6)}分       │
│     风险等级：${levelEmoji} ${levelLabel}        │
│                                  │
└──────────────────────────────────┘

风险等级说明：
• LOW（低风险）：0-35分 - 健康状况良好
• MEDIUM（中风险）：36-55分 - 存在可控风险
• HIGH（高风险）：56-75分 - 需要关注和干预
• CRITICAL（极高风险）：76-100分 - 建议尽快就医
`;

    return {
      title: '📊 综合风险评估',
      content: content.trim(),
      type: 'TEXT',
      priority: 2
    };
  }

  private static generateDetailedRisksSection(result: RiskAssessmentResult): ReportSection {
    let content = '';
    
    const diseases = [
      { key: 'hypertension', name: '高血压', icon: '💓' },
      { key: 'diabetes', name: '糖尿病', icon: '🩸' },
      { key: 'fall', name: '跌倒风险', icon: '⚠️' },
      { key: 'frailty', name: '衰弱综合征', icon: '👴' },
      { key: 'sarcopenia', name: '肌少症', icon: '💪' }
    ];

    for (const disease of diseases) {
      const risk = result.risks[disease.key as keyof typeof result.risks];
      
      content += `\n${disease.icon} ${disease.name}\n`;
      content += `${'─'.repeat(30)}\n`;
      content += `风险概率：${(risk.probability * 100).toFixed(1)}%\n`;
      content += `风险等级：${this.getLevelEmoji(risk.level)} ${this.getLevelLabel(risk.level)}\n`;
      content += `判定依据：${risk.evidence}\n`;
      
      if (risk.factors && risk.factors.length > 0) {
        content += `风险因素：\n`;
        risk.factors.forEach((factor, idx) => {
          content += `  ${idx + 1}. ${factor}\n`;
        });
      }
      content += '\n';
    }

    return {
      title: '🔍 各维度详细分析',
      content: content.trim(),
      type: 'LIST',
      priority: 3
    };
  }

  private static generateFeatureAnalysisSection(result: RiskAssessmentResult): ReportSection {
    let content = '';

    if (result.featureInterpretations) {
      content = '\n特征向量解读（10维）：\n\n';
      
      result.featureInterpretations.forEach((feature, idx) => {
        const statusIcon = feature.status === 'normal' ? '✅' : 
                          feature.status === 'warning' ? '⚡' : '❌';
        
        content += `[${idx.toString().padStart(2, '0')}] ${statusIcon} ${feature.name}\n`;
        content += `    数值：${feature.value}\n`;
        content += `    状态：${this.getStatusLabel(feature.status)}\n\n`;
      });
    }

    return {
      title: '🔬 特征数据分析',
      content: content.trim(),
      type: 'TABLE',
      priority: 4
    };
  }

  private static generateSuggestionsSection(result: RiskAssessmentResult): ReportSection {
    let content = '';

    if (result.suggestions && result.suggestions.length > 0) {
      content = '\n个性化健康建议（按优先级排序）：\n\n';
      
      const highPriority = result.suggestions.filter(s => s.priority === 'HIGH');
      const mediumPriority = result.suggestions.filter(s => s.priority === 'MEDIUM');
      const lowPriority = result.suggestions.filter(s => s.priority === 'LOW');

      if (highPriority.length > 0) {
        content += '【🔴 高优先级】\n';
        highPriority.forEach((suggestion, idx) => {
          content += `${idx + 1}. [${suggestion.category}] ${suggestion.content}\n`;
          if (suggestion.targetDisease) {
            content += `   → 针对：${suggestion.targetDisease}\n`;
          }
          content += '\n';
        });
      }

      if (mediumPriority.length > 0) {
        content += '【🟡 中优先级】\n';
        mediumPriority.forEach((suggestion, idx) => {
          content += `${idx + 1}. [${suggestion.category}] ${suggestion.content}\n\n`;
        });
      }

      if (lowPriority.length > 0) {
        content += '【🟢 低优先级】\n';
        lowPriority.forEach((suggestion, idx) => {
          content += `${idx + 1}. [${suggestion.category}] ${suggestion.content}\n\n`;
        });
      }
    }

    return {
      title: '💡 个性化建议',
      content: content.trim(),
      type: 'LIST',
      priority: 5
    };
  }

  private static generateTrendSection(trendData: OverallTrend): ReportSection {
    let content = '';

    content += `\n趋势概览：\n`;
    content += `• 评估次数：${trendData.assessmentCount}次\n`;
    content += `• 时间跨度：${trendData.timeSpanDays}天\n`;
    content += `• 总体趋势：${trendData.overallTrend === 'IMPROVING' ? '改善 ✅' : 
               trendData.overallTrend === 'WORSENING' ? '恶化 ⚠️' : '稳定 ➡️'}\n`;
    content += `• 变化率：${(trendData.overallChangeRate * 100).toFixed(1)}%\n\n`;

    if (trendData.diseaseTrends.length > 0) {
      content += `各维度变化：\n`;
      trendData.diseaseTrends.forEach(trend => {
        const arrow = trend.trendDirection === 'IMPROVING' ? '↓' : 
                     trend.trendDirection === 'WORSENING' ? '↑' : '→';
        content += `• ${trend.label}: ${(trend.currentScore * 100).toFixed(1)}% ${arrow} `;
        content += `(变化: ${(trend.changeRate * 100 > 0 ? '+' : '')}${(trend.changeRate * 100).toFixed(1)}%)\n`;
      });
    }

    if (trendData.keyFindings.length > 0) {
      content += `\n关键发现：\n`;
      trendData.keyFindings.forEach((finding, idx) => {
        content += `${idx + 1}. ${finding}\n`;
      });
    }

    return {
      title: '📈 趋势分析',
      content: content.trim(),
      type: 'CHART',
      priority: 6
    };
  }

  private static generateActionPlanSection(result: RiskAssessmentResult): ReportSection {
    let content = '';

    const immediateActions: string[] = [];
    const soonActions: string[] = [];
    const routineActions: string[] = [];

    if (result.risks.hypertension.probability > 0.7) {
      immediateActions.push('立即测量血压并记录数值');
      immediateActions.push('如血压持续偏高，联系家庭医生');
    }
    if (result.risks.diabetes.probability > 0.65) {
      immediateActions.push('检测空腹血糖');
      soonActions.push('预约内分泌科检查');
    }
    if (result.risks.fall.probability > 0.5) {
      soonActions.push('进行居家安全检查');
      routineActions.push('开始平衡训练计划');
    }

    if (immediateActions.length > 0) {
      content += '\n【🔴 需立即执行】\n';
      immediateActions.forEach((action, idx) => {
        content += `${idx + 1}. ${action}\n`;
      });
    }

    if (soonActions.length > 0) {
      content += '\n【🟡 本周内完成】\n';
      soonActions.forEach((action, idx) => {
        content += `${idx + 1}. ${action}\n`;
      });
    }

    if (routineActions.length > 0) {
      content += '\n【🟢 常规维护】\n';
      routineActions.forEach((action, idx) => {
        content += `${idx + 1}. ${action}\n`;
      });
    }

    if (content === '') {
      content = '\n当前健康状况良好，继续保持现有生活习惯即可。';
    }

    return {
      title: '🎯 行动计划',
      content: content.trim(),
      type: 'WARNING',
      priority: 7
    };
  }

  private static generateSummary(result: RiskAssessmentResult): string {
    const score = (result.overallScore * 100).toFixed(1);
    const level = result.overallLevel;

    let summary = `本次AI共病风险评估于${new Date(result.timestamp).toLocaleDateString('zh-CN')}完成，`;
    summary += `综合得分为${score}分，风险等级为${this.getLevelLabel(level)}。`;

    const highRiskDiseases = Object.values(result.risks)
      .filter(risk => risk.probability > 0.6)
      .map(risk => risk.label);

    if (highRiskDiseases.length > 0) {
      summary += `主要风险集中在${highRiskDiseases.join('、')}方面，`;
      summary += `需要重点关注并采取相应措施。`;
    } else {
      summary += `各项指标总体在可控范围内，建议保持良好的生活方式。`;
    }

    return summary;
  }

  private static extractActionItems(result: RiskAssessmentResult): ActionItem[] {
    const items: ActionItem[] = [];
    let itemId = 1;

    if (result.suggestions) {
      for (const suggestion of result.suggestions) {
        let priority: 'IMMEDIATE' | 'SOON' | 'ROUTINE';
        
        switch (suggestion.priority) {
          case 'HIGH':
            priority = 'IMMEDIATE';
            break;
          case 'MEDIUM':
            priority = 'SOON';
            break;
          default:
            priority = 'ROUTINE';
        }

        items.push({
          id: `ACTION_${itemId++}`,
          category: suggestion.category,
          description: suggestion.content,
          priority: priority,
          responsibleParty: '用户/家属'
        });
      }
    }

    return items.slice(0, 8);
  }

  static formatReportForDisplay(report: GeneratedReport): string {
    let formattedReport = this.REPORT_TEMPLATES.header;
    
    formattedReport += `\n${report.title}\n`;
    formattedReport += `生成时间：${new Date(report.generatedAt).toLocaleString('zh-CN')}\n`;
    formattedReport += `报告编号：${report.id}\n\n`;

    formattedReport += `【摘要】\n${report.summary}\n\n`;

    report.sections.sort((a, b) => a.priority - b.priority);
    
    for (const section of report.sections) {
      formattedReport += `${'═'.repeat(40)}\n`;
      formattedReport += `${section.title}\n`;
      formattedReport += `${'═'.repeat(40)}\n`;
      formattedReport += `${section.content}\n\n`;
    }

    if (report.actionItems.length > 0) {
      formattedReport += `${'─'.repeat(40)}\n`;
      formattedReport += '📝 待办事项清单\n';
      formattedReport += `${'─'.repeat(40)}\n`;
      
      report.actionItems.forEach((item, idx) => {
        const priorityIcon = item.priority === 'IMMEDIATE' ? '🔴' :
                            item.priority === 'SOON' ? '🟡' : '🟢';
        formattedReport += `${idx + 1}. ${priorityIcon} [${item.category}] ${item.description}\n`;
        formattedReport += `   责任方：${item.responsibleParty}\n\n`;
      });
    }

    formattedReport += this.REPORT_TEMPLATES.disclaimer;

    return formattedReport;
  }

  private static getMethodLabel(method: string): string {
    switch (method) {
      case 'AI_MODEL': return 'AI深度学习模型';
      case 'RULE_BASED': return '医学指南规则引擎';
      case 'HYBRID': return '混合模式（AI+规则）';
      case 'ERROR': return '错误状态';
      default: return method;
    }
  }

  private static getLevelEmoji(level: string): string {
    switch (level) {
      case 'LOW': return '🟢';
      case 'MEDIUM': return '🟡';
      case 'HIGH': return '🔴';
      case 'CRITICAL': return '⛔';
      default: return '❓';
    }
  }

  private static getLevelLabel(level: string): string {
    switch (level) {
      case 'LOW': return '低风险';
      case 'MEDIUM': return '中等风险';
      case 'HIGH': return '高风险';
      case 'CRITICAL': return '极高风险';
      default: return '未知';
    }
  }

  private static getStatusLabel(status: string): string {
    switch (status) {
      case 'normal': return '正常 ✅';
      case 'warning': return '注意 ⚡';
      case 'abnormal': return '异常 ❌';
      default: return status;
    }
  }
}
