/**
 * 复原报告生成器
 * 
 * 负责生成详细的处理报告：
 * - 总处理时长
 * - 各阶段耗时明细
 * - 质量评估分数
 * - 处理参数记录
 * 
 * @version 1.0
 * @date 2025-01-20
 */

import {
  StageResult,
  ProcessingParams,
  ProcessingReport,
  StageDetail,
  QualityAssessment,
  ProcessingStage
} from '../models/AncientImageModels';

/**
 * 报告生成器类
 */
export class ReportGenerator {
  /**
   * 生成处理报告
   * 
   * @param imageId 图像ID
   * @param stageResults 各阶段结果
   * @param params 处理参数
   * @param originalQuality 原始质量
   * @param finalQuality 最终质量
   * @returns 处理报告
   */
  async generate(
    imageId: number,
    stageResults: StageResult[],
    params: ProcessingParams,
    originalQuality: QualityAssessment,
    finalQuality: QualityAssessment
  ): Promise<ProcessingReport> {
    console.info('[ReportGenerator] 开始生成处理报告');

    // 计算总耗时
    let totalDuration = 0;
    for (let i = 0; i < stageResults.length; i++) {
      totalDuration += stageResults[i].duration;
    }

    // 生成各阶段详情
    const stageDetails = this.generateStageDetails(stageResults);

    // 计算总体改善程度
    const overallImprovement = this.calculateOverallImprovement(originalQuality, finalQuality);

    // 构建报告对象
    const report: ProcessingReport = {
      id: this.generateReportId(),
      imageId: imageId,
      totalDuration: totalDuration,
      stageDetails: stageDetails,
      originalQuality: originalQuality,
      finalQuality: finalQuality,
      overallImprovement: overallImprovement,
      params: params,
      generatedAt: Date.now()
    };

    console.info(`[ReportGenerator] 报告生成完成，总耗时: ${totalDuration}ms，改善程度: ${overallImprovement}%`);
    return report;
  }

  /**
   * 生成各阶段详情
   * 
   * @param stageResults 各阶段结果
   * @returns 阶段详情列表
   */
  private generateStageDetails(stageResults: StageResult[]): StageDetail[] {
    const stageDescriptions: Map<ProcessingStage, string> = new Map();
    stageDescriptions.set(ProcessingStage.PREPROCESSING, '预处理：格式转换、尺寸调整、质量评估');
    stageDescriptions.set(ProcessingStage.DENOISING, '降噪：去除图像噪点');
    stageDescriptions.set(ProcessingStage.DEBLURRING, '去模糊：恢复图像清晰度');
    stageDescriptions.set(ProcessingStage.SUPER_RESOLUTION, '超分辨率：提升图像分辨率');
    stageDescriptions.set(ProcessingStage.COLOR_RESTORATION, '颜色恢复：恢复褪色颜色');
    stageDescriptions.set(ProcessingStage.DETAIL_ENHANCEMENT, '细节增强：增强图像细节');
    stageDescriptions.set(ProcessingStage.OCR_RECOGNITION, 'OCR识别：识别文字内容');
    stageDescriptions.set(ProcessingStage.ANNOTATION, '智能标注：生成标注信息');

    const details: StageDetail[] = [];
    for (let i = 0; i < stageResults.length; i++) {
      const result = stageResults[i];
      const description = stageDescriptions.get(result.stage) || result.stage;
      
      const detail: StageDetail = {
        stage: result.stage,
        description: description,
        duration: result.duration,
        inputQuality: result.inputQuality,
        outputQuality: result.outputQuality,
        improvement: result.improvement
      };
      details.push(detail);
    }

    return details;
  }

  /**
   * 计算总体改善程度
   * 
   * @param originalQuality 原始质量
   * @param finalQuality 最终质量
   * @returns 改善程度（百分比）
   */
  private calculateOverallImprovement(
    originalQuality: QualityAssessment,
    finalQuality: QualityAssessment
  ): number {
    const improvement = ((finalQuality.overall - originalQuality.overall) / originalQuality.overall) * 100;
    return Math.round(improvement * 10) / 10;
  }

  /**
   * 生成报告ID
   * 
   * @returns 唯一报告ID
   */
  private generateReportId(): string {
    return `RPT_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  /**
   * 导出报告为JSON
   * 
   * @param report 处理报告
   * @returns JSON字符串
   */
  exportToJson(report: ProcessingReport): string {
    return JSON.stringify(report, null, 2);
  }

  /**
   * 格式化时长
   * 
   * @param ms 毫秒数
   * @returns 格式化字符串
   */
  private formatDuration(ms: number): string {
    if (ms < 1000) {
      return `${ms}ms`;
    } else if (ms < 60000) {
      return `${(ms / 1000).toFixed(2)}s`;
    } else {
      const minutes = Math.floor(ms / 60000);
      const seconds = ((ms % 60000) / 1000).toFixed(2);
      return `${minutes}m ${seconds}s`;
    }
  }
}
