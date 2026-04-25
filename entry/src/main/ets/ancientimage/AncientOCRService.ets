/**
 * 古籍OCR识别服务
 * 
 * 负责识别图像中的文字内容：
 * - 文字检测和定位
 * - 文字识别（模拟）
 * - 医学术语高亮
 * 
 * @version 1.0
 * @date 2025-01-20
 */

import {
  ImageData,
  OCRResult,
  OCRParams,
  RecognizedText,
  BoundingBox
} from '../models/AncientImageModels';

/**
 * 古籍OCR服务类
 */
export class AncientOCRService {
  // 医学术语词典
  private medicalTerms: Set<string> = new Set([
    // 穴位名
    '合谷', '足三里', '百会', '涌泉', '内关', '外关', '曲池', '三阴交',
    '关元', '气海', '中脘', '膻中', '命门', '肾俞', '肺俞', '肝俞',
    // 药名
    '人参', '黄芪', '当归', '白术', '茯苓', '甘草', '川芎', '白芍',
    '熟地', '生地', '桂枝', '麻黄', '杏仁', '石膏', '黄芩', '黄连',
    '大黄', '芒硝', '半夏', '陈皮', '枳实', '厚朴', '柴胡', '葛根',
    // 病症名
    '感冒', '咳嗽', '发热', '头痛', '眩晕', '失眠', '心悸', '胸痹',
    '胃痛', '腹痛', '泄泻', '便秘', '黄疸', '水肿', '淋证', '消渴',
    // 经络名
    '手太阴肺经', '手阳明大肠经', '足阳明胃经', '足太阴脾经',
    '手少阴心经', '手太阳小肠经', '足太阳膀胱经', '足少阴肾经',
    '手厥阴心包经', '手少阳三焦经', '足少阳胆经', '足厥阴肝经',
    // 其他术语
    '气虚', '血虚', '阴虚', '阳虚', '气滞', '血瘀', '痰湿', '湿热'
  ]);

  /**
   * 识别图像中的文字
   * 
   * @param imageData 输入图像数据
   * @param params OCR参数
   * @returns OCR识别结果
   */
  async recognize(imageData: ImageData, params?: OCRParams): Promise<OCRResult> {
    console.info('[AncientOCRService] 开始OCR识别');

    const startTime = Date.now();

    // 模拟OCR识别
    const textBlocks = this.generateMockTextBlocks();
    const fullText = textBlocks.map((block: RecognizedText) => block.text).join('\n');
    const avgConfidence = textBlocks.reduce((sum: number, block: RecognizedText) => sum + block.confidence, 0) / textBlocks.length;
    const medicalTermCount = textBlocks.filter((block: RecognizedText) => block.isMedicalTerm).length;

    const duration = Date.now() - startTime;
    console.info(`[AncientOCRService] OCR识别完成，耗时: ${duration}ms，识别文字块: ${textBlocks.length}`);

    return {
      fullText: fullText,
      textBlocks: textBlocks,
      averageConfidence: avgConfidence,
      medicalTermCount: medicalTermCount,
      duration: duration
    };
  }

  /**
   * 生成模拟文字块
   */
  private generateMockTextBlocks(): RecognizedText[] {
    const sampleTexts = [
      '人参味甘微寒',
      '主补五脏安精神',
      '定魂魄止惊悸',
      '除邪气明目',
      '开心益智',
      '久服轻身延年',
      '黄芪甘温',
      '补气固表',
      '当归甘辛温',
      '补血活血'
    ];

    const textBlocks: RecognizedText[] = [];

    for (let i = 0; i < sampleTexts.length; i++) {
      const text = sampleTexts[i];
      const isMedicalTerm = this.checkMedicalTerm(text);

      textBlocks.push({
        text: text,
        boundingBox: {
          x: 5 + Math.random() * 60,
          y: 5 + (i / sampleTexts.length) * 80,
          width: 20 + Math.random() * 30,
          height: 5 + Math.random() * 10
        },
        confidence: 0.85 + Math.random() * 0.15,
        isMedicalTerm: isMedicalTerm,
        isVertical: false
      });
    }

    return textBlocks;
  }

  /**
   * 检查是否包含医学术语
   */
  private checkMedicalTerm(text: string): boolean {
    for (const term of this.medicalTerms) {
      if (text.includes(term)) {
        return true;
      }
    }
    return false;
  }

  /**
   * 添加医学术语
   * 
   * @param term 术语
   */
  addMedicalTerm(term: string): void {
    this.medicalTerms.add(term);
  }

  /**
   * 批量添加医学术语
   * 
   * @param terms 术语列表
   */
  addMedicalTerms(terms: string[]): void {
    for (let i = 0; i < terms.length; i++) {
      this.medicalTerms.add(terms[i]);
    }
  }

  /**
   * 获取所有医学术语
   * 
   * @returns 医学术语列表
   */
  getMedicalTerms(): string[] {
    return Array.from(this.medicalTerms);
  }
}
