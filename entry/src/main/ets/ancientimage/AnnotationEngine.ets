/**
 * 智能标注引擎
 * 
 * 负责基于OCR结果生成智能标注：
 * - 生成文字边界框标注
 * - 高亮医学术语
 * - 支持不同样式
 * 
 * @version 1.0
 * @date 2025-01-20
 */

import {
  OCRResult,
  AnnotationParams,
  ImageAnnotation,
  AnnotationType,
  AnnotationStyle,
  BoundingBox,
  RecognizedText
} from '../models/AncientImageModels';

/**
 * 智能标注引擎类
 */
export class AnnotationEngine {
  // 默认样式
  private readonly DEFAULT_TEXT_STYLE: AnnotationStyle = {
    borderColor: '#52C41A',
    borderWidth: 2,
    backgroundColor: 'rgba(82, 196, 26, 0.1)',
    textColor: '#000000',
    fontSize: 14
  };

  private readonly DEFAULT_MEDICAL_STYLE: AnnotationStyle = {
    borderColor: '#722ED1',
    borderWidth: 3,
    backgroundColor: 'rgba(114, 46, 209, 0.2)',
    textColor: '#722ED1',
    fontSize: 16
  };

  /**
   * 生成标注
   * 
   * @param ocrResult OCR识别结果
   * @param params 标注参数
   * @returns 标注列表
   */
  async generateAnnotations(ocrResult: OCRResult, params?: AnnotationParams): Promise<ImageAnnotation[]> {
    console.info('[AnnotationEngine] 开始生成标注');

    const annotations: ImageAnnotation[] = [];

    // 生成文字框标注
    if (params?.generateTextBoxes !== false) {
      for (let i = 0; i < ocrResult.textBlocks.length; i++) {
        const textBlock = ocrResult.textBlocks[i];
        const annotation = this.createTextAnnotation(textBlock, params);
        annotations.push(annotation);
      }
    }

    console.info(`[AnnotationEngine] 标注生成完成，共 ${annotations.length} 个标注`);
    return annotations;
  }

  /**
   * 创建文字标注
   * 
   * @param textBlock 文字块
   * @param params 标注参数
   * @returns 文字标注
   */
  private createTextAnnotation(textBlock: RecognizedText, params?: AnnotationParams): ImageAnnotation {
    // 确定样式
    let style: AnnotationStyle;
    if (textBlock.isMedicalTerm && params?.highlightMedicalTerms !== false) {
      style = params?.style ?? this.DEFAULT_MEDICAL_STYLE;
    } else {
      style = params?.style ?? this.DEFAULT_TEXT_STYLE;
    }

    return {
      id: this.generateAnnotationId(),
      type: AnnotationType.TEXT_BOX,
      label: textBlock.text,
      boundingBox: textBlock.boundingBox,
      description: textBlock.isMedicalTerm ? '医学术语' : undefined,
      style: style,
      confidence: textBlock.confidence,
      editable: true,
      createdAt: Date.now()
    };
  }

  /**
   * 生成标注ID
   * 
   * @returns 唯一标注ID
   */
  private generateAnnotationId(): string {
    return `ANN_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  /**
   * 创建自定义标注
   * 
   * @param type 标注类型
   * @param label 标注标签
   * @param boundingBox 边界框
   * @param description 描述
   * @returns 自定义标注
   */
  createCustomAnnotation(
    type: AnnotationType,
    label: string,
    boundingBox: BoundingBox,
    description?: string
  ): ImageAnnotation {
    return {
      id: this.generateAnnotationId(),
      type: type,
      label: label,
      boundingBox: boundingBox,
      description: description,
      style: this.DEFAULT_TEXT_STYLE,
      confidence: 1.0,
      editable: true,
      createdAt: Date.now()
    };
  }

  /**
   * 更新标注样式
   * 
   * @param annotation 标注
   * @param style 新样式
   * @returns 更新后的标注
   */
  updateAnnotationStyle(annotation: ImageAnnotation, style: AnnotationStyle): ImageAnnotation {
    const updated: ImageAnnotation = {
      id: annotation.id,
      type: annotation.type,
      label: annotation.label,
      boundingBox: annotation.boundingBox,
      description: annotation.description,
      style: style,
      confidence: annotation.confidence,
      editable: annotation.editable,
      createdAt: annotation.createdAt
    };
    return updated;
  }

  /**
   * 更新标注位置
   * 
   * @param annotation 标注
   * @param boundingBox 新边界框
   * @returns 更新后的标注
   */
  updateAnnotationPosition(annotation: ImageAnnotation, boundingBox: BoundingBox): ImageAnnotation {
    const updated: ImageAnnotation = {
      id: annotation.id,
      type: annotation.type,
      label: annotation.label,
      boundingBox: boundingBox,
      description: annotation.description,
      style: annotation.style,
      confidence: annotation.confidence,
      editable: annotation.editable,
      createdAt: annotation.createdAt
    };
    return updated;
  }
}
