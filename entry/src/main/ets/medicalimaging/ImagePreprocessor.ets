/**
 * 图像预处理器
 * 
 * 负责医学影像的预处理工作,包括:
 * - 图像缩放(resize)
 * - 像素值归一化(normalize)
 * - 格式转换
 * - 张量准备
 */

import { image } from '@kit.ImageKit';
import { ImagingType } from '../models/ImagingModels';

/**
 * 图像预处理器类
 */
export class ImagePreprocessor {
  /**
   * 不同影像类型的目标尺寸配置
   */
  private readonly targetSizeMap: Map<ImagingType, { width: number; height: number }> = new Map([
    [ImagingType.CHEST_XRAY, { width: 224, height: 224 }],
    [ImagingType.BONE_XRAY, { width: 224, height: 224 }],
    [ImagingType.SKIN_PHOTO, { width: 224, height: 224 }],
    [ImagingType.EYE_FUNDUS, { width: 224, height: 224 }],
    [ImagingType.BREAST_ULTRASOUND, { width: 224, height: 224 }]
  ]);

  /**
   * 预处理图像
   * 
   * @param pixelMap 原始图像
   * @param imagingType 影像类型
   * @returns 预处理后的图像
   */
  async preprocess(
    pixelMap: image.PixelMap,
    imagingType: ImagingType
  ): Promise<image.PixelMap> {
    try {
      // 1. 获取目标尺寸
      const targetSize = this.getTargetSize(imagingType);
      
      // 2. 缩放图像到目标尺寸
      const resized = await this.resize(pixelMap, targetSize.width, targetSize.height);
      
      // 3. 归一化像素值
      const normalized = await this.normalize(resized);
      
      return normalized;
    } catch (error) {
      console.error('ImagePreprocessor.preprocess error:', error);
      throw new Error(`图像预处理失败: ${error}`);
    }
  }

  /**
   * 获取目标尺寸
   * 
   * @param imagingType 影像类型
   * @returns 目标宽高
   */
  private getTargetSize(imagingType: ImagingType): { width: number; height: number } {
    const size = this.targetSizeMap.get(imagingType);
    if (!size) {
      // 默认尺寸
      return { width: 224, height: 224 };
    }
    return size;
  }

  /**
   * 缩放图像
   * 
   * @param pixelMap 原始图像
   * @param targetWidth 目标宽度
   * @param targetHeight 目标高度
   * @returns 缩放后的图像
   */
  async resize(
    pixelMap: image.PixelMap,
    targetWidth: number,
    targetHeight: number
  ): Promise<image.PixelMap> {
    try {
      // 获取原始图像信息
      const imageInfo = await pixelMap.getImageInfo();
      const originalWidth = imageInfo.size.width;
      const originalHeight = imageInfo.size.height;

      // 如果尺寸已经匹配,直接返回
      if (originalWidth === targetWidth && originalHeight === targetHeight) {
        return pixelMap;
      }

      // 使用PixelMap的scale方法进行缩放
      const scaleX = targetWidth / originalWidth;
      const scaleY = targetHeight / originalHeight;
      
      await pixelMap.scale(scaleX, scaleY);
      
      return pixelMap;
    } catch (error) {
      console.error('ImagePreprocessor.resize error:', error);
      throw new Error(`图像缩放失败: ${error}`);
    }
  }

  /**
   * 归一化像素值
   * 将像素值从[0, 255]归一化到[0, 1]
   * 
   * @param pixelMap 原始图像
   * @returns 归一化后的图像
   */
  async normalize(pixelMap: image.PixelMap): Promise<image.PixelMap> {
    try {
      // 注意: HarmonyOS PixelMap不直接支持像素值修改
      // 这里我们返回原图,实际的归一化在转换为张量时进行
      // 在convertToTensor方法中会将像素值除以255
      
      return pixelMap;
    } catch (error) {
      console.error('ImagePreprocessor.normalize error:', error);
      throw new Error(`图像归一化失败: ${error}`);
    }
  }

  /**
   * 将PixelMap转换为模型输入张量
   * 
   * @param pixelMap 图像
   * @returns 张量数据(Float32Array)
   */
  async convertToTensor(pixelMap: image.PixelMap): Promise<Float32Array> {
    try {
      // 获取图像信息
      const imageInfo = await pixelMap.getImageInfo();
      const width = imageInfo.size.width;
      const height = imageInfo.size.height;

      // 读取像素数据
      const pixelBytesNumber = pixelMap.getPixelBytesNumber();
      const buffer = new ArrayBuffer(pixelBytesNumber);
      await pixelMap.readPixelsToBuffer(buffer);

      // 转换为Uint8Array
      const pixels = new Uint8Array(buffer);

      // 创建Float32Array用于模型输入
      // 格式: [Batch, Height, Width, Channels] = [1, H, W, 3]
      const tensorSize = 1 * height * width * 3;
      const tensor = new Float32Array(tensorSize);

      // 转换像素值并归一化到[0, 1]
      // 假设输入是RGBA格式,我们只取RGB通道
      for (let i = 0; i < height * width; i++) {
        const pixelIndex = i * 4; // RGBA每个像素4字节
        const tensorIndex = i * 3; // RGB每个像素3个值

        // R通道
        tensor[tensorIndex] = pixels[pixelIndex] / 255.0;
        // G通道
        tensor[tensorIndex + 1] = pixels[pixelIndex + 1] / 255.0;
        // B通道
        tensor[tensorIndex + 2] = pixels[pixelIndex + 2] / 255.0;
      }

      return tensor;
    } catch (error) {
      console.error('ImagePreprocessor.convertToTensor error:', error);
      throw new Error(`图像转张量失败: ${error}`);
    }
  }

  /**
   * 验证图像格式
   * 
   * @param imageUri 图像URI
   * @returns 是否为支持的格式
   */
  validateImageFormat(imageUri: string): boolean {
    const supportedFormats = ['.jpg', '.jpeg', '.png', '.bmp'];
    const lowerUri = imageUri.toLowerCase();
    
    return supportedFormats.some(format => lowerUri.endsWith(format));
  }

  /**
   * 验证图像大小
   * 
   * @param imageSizeBytes 图像大小(字节)
   * @returns 是否符合要求(≤10MB)
   */
  validateImageSize(imageSizeBytes: number): boolean {
    const maxSizeBytes = 10 * 1024 * 1024; // 10MB
    return imageSizeBytes <= maxSizeBytes;
  }

  /**
   * 计算缩放比例
   * 保持宽高比缩放到目标尺寸内
   * 
   * @param originalWidth 原始宽度
   * @param originalHeight 原始高度
   * @param targetWidth 目标宽度
   * @param targetHeight 目标高度
   * @returns 缩放比例
   */
  calculateScaleRatio(
    originalWidth: number,
    originalHeight: number,
    targetWidth: number,
    targetHeight: number
  ): number {
    const scaleX = targetWidth / originalWidth;
    const scaleY = targetHeight / originalHeight;
    
    // 取较小的缩放比例,保持宽高比
    return Math.min(scaleX, scaleY);
  }
}
