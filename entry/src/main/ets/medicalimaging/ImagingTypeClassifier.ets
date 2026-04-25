/**
 * 影像类型自动分类器
 * 
 * 基于图像特征自动识别影像类型
 */

import { image } from '@kit.ImageKit';
import { ImagingType, ClassificationResult } from '../models/ImagingModels';
import { MedicalImageUtils, ImageFeatures } from './MedicalImageUtils';

/**
 * 影像类型分类器
 */
export class ImagingTypeClassifier {
  /**
   * 各影像类型的特征模板
   */
  private readonly typeFeatures: Map<ImagingType, Partial<ImageFeatures>> = new Map([
    [ImagingType.CHEST_XRAY, {
      aspectRatio: 1.0,  // 正方形
      averageBrightness: 0.4  // 较暗
    }],
    [ImagingType.BONE_XRAY, {
      aspectRatio: 0.8,  // 略高
      averageBrightness: 0.5
    }],
    [ImagingType.SKIN_PHOTO, {
      aspectRatio: 1.2,  // 略宽
      averageBrightness: 0.6  // 较亮
    }],
    [ImagingType.EYE_FUNDUS, {
      aspectRatio: 1.0,  // 正方形
      averageBrightness: 0.3  // 较暗
    }],
    [ImagingType.BREAST_ULTRASOUND, {
      aspectRatio: 1.0,
      averageBrightness: 0.5
    }]
  ]);

  /**
   * 分类影像类型
   * 
   * @param pixelMap 图像
   * @returns 分类结果
   */
  async classify(pixelMap: image.PixelMap): Promise<ClassificationResult> {
    try {
      // 提取图像特征
      const features = await MedicalImageUtils.extractFeatures(pixelMap);
      
      // 基于特征判断影像类型
      const result = this.classifyByFeatures(features);
      
      return result;
    } catch (error) {
      console.error('ImagingTypeClassifier.classify error:', error);
      // 默认返回胸部X光
      return {
        imagingType: ImagingType.CHEST_XRAY,
        confidence: 0.5,
        needsConfirmation: true
      };
    }
  }

  /**
   * 基于特征分类
   * 
   * @param features 图像特征
   * @returns 分类结果
   */
  private classifyByFeatures(features: ImageFeatures): ClassificationResult {
    // 计算与各类型的相似度
    const scores: { type: ImagingType; score: number }[] = [];

    this.typeFeatures.forEach((template, type) => {
      let score = 0;
      let weightSum = 0;

      // 宽高比相似度
      if (template.aspectRatio) {
        const ratioDiff = Math.abs(features.aspectRatio - template.aspectRatio);
        const ratioScore = Math.max(0, 1 - ratioDiff);
        score += ratioScore * 0.4;  // 权重0.4
        weightSum += 0.4;
      }

      // 亮度相似度
      if (template.averageBrightness) {
        const brightnessDiff = Math.abs(features.averageBrightness - template.averageBrightness);
        const brightnessScore = Math.max(0, 1 - brightnessDiff);
        score += brightnessScore * 0.3;  // 权重0.3
        weightSum += 0.3;
      }

      // 归一化分数
      const normalizedScore = weightSum > 0 ? score / weightSum : 0;
      scores.push({ type, score: normalizedScore });
    });

    // 按分数降序排序
    scores.sort((a, b) => b.score - a.score);

    // 取最高分
    const best = scores[0];
    
    return {
      imagingType: best.type,
      confidence: best.score,
      needsConfirmation: best.score < 0.7
    };
  }
}
