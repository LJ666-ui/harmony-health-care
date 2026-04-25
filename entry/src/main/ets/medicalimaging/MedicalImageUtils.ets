/**
 * 医学图像工具函数
 * 
 * 提供医学影像分析所需的各类工具函数:
 * - 颜色直方图计算
 * - 纹理特征提取
 * - 宽高比计算
 * - 图像特征提取
 */

import { image } from '@kit.ImageKit';

/**
 * 图像特征接口
 */
export interface ImageFeatures {
  /** 宽高比 */
  aspectRatio: number;
  /** 平均亮度 */
  averageBrightness: number;
  /** 颜色直方图 */
  colorHistogram: number[];
  /** 纹理特征 */
  textureFeatures: number[];
  /** 图像宽度 */
  width: number;
  /** 图像高度 */
  height: number;
}

/**
 * 医学图像工具类
 */
export class MedicalImageUtils {
  /**
   * 计算颜色直方图
   * 
   * @param pixelMap 图像
   * @param bins 直方图bin数量(默认16)
   * @returns 颜色直方图数组
   */
  static async calculateColorHistogram(
    pixelMap: image.PixelMap,
    bins: number = 16
  ): Promise<number[]> {
    try {
      // 获取图像信息
      const imageInfo = await pixelMap.getImageInfo();
      const width = imageInfo.size.width;
      const height = imageInfo.size.height;

      // 读取像素数据
      const pixelBytesNumber = pixelMap.getPixelBytesNumber();
      const buffer = new ArrayBuffer(pixelBytesNumber);
      await pixelMap.readPixelsToBuffer(buffer);
      const pixels = new Uint8Array(buffer);

      // 初始化直方图(灰度直方图)
      const histogram = new Array(bins).fill(0);
      const binSize = 256 / bins;

      // 计算直方图
      for (let i = 0; i < width * height; i++) {
        const pixelIndex = i * 4; // RGBA
        const r = pixels[pixelIndex];
        const g = pixels[pixelIndex + 1];
        const b = pixels[pixelIndex + 2];
        
        // 计算灰度值
        const gray = 0.299 * r + 0.587 * g + 0.114 * b;
        
        // 确定bin索引
        const binIndex = Math.min(Math.floor(gray / binSize), bins - 1);
        histogram[binIndex]++;
      }

      // 归一化直方图
      const totalPixels = width * height;
      return histogram.map(count => count / totalPixels);
    } catch (error) {
      console.error('MedicalImageUtils.calculateColorHistogram error:', error);
      return new Array(bins).fill(0);
    }
  }

  /**
   * 计算纹理特征
   * 使用简单的梯度统计作为纹理特征
   * 
   * @param pixelMap 图像
   * @returns 纹理特征数组
   */
  static async calculateTextureFeatures(pixelMap: image.PixelMap): Promise<number[]> {
    try {
      // 获取图像信息
      const imageInfo = await pixelMap.getImageInfo();
      const width = imageInfo.size.width;
      const height = imageInfo.size.height;

      // 读取像素数据
      const pixelBytesNumber = pixelMap.getPixelBytesNumber();
      const buffer = new ArrayBuffer(pixelBytesNumber);
      await pixelMap.readPixelsToBuffer(buffer);
      const pixels = new Uint8Array(buffer);

      // 转换为灰度图像
      const grayImage = new Float32Array(width * height);
      for (let i = 0; i < width * height; i++) {
        const pixelIndex = i * 4;
        const r = pixels[pixelIndex];
        const g = pixels[pixelIndex + 1];
        const b = pixels[pixelIndex + 2];
        grayImage[i] = 0.299 * r + 0.587 * g + 0.114 * b;
      }

      // 计算梯度
      const gradients: number[] = [];
      for (let y = 1; y < height - 1; y++) {
        for (let x = 1; x < width - 1; x++) {
          const idx = y * width + x;
          
          // Sobel算子
          const gx = 
            -grayImage[(y - 1) * width + (x - 1)] + grayImage[(y - 1) * width + (x + 1)] +
            -2 * grayImage[y * width + (x - 1)] + 2 * grayImage[y * width + (x + 1)] +
            -grayImage[(y + 1) * width + (x - 1)] + grayImage[(y + 1) * width + (x + 1)];
          
          const gy = 
            -grayImage[(y - 1) * width + (x - 1)] - 2 * grayImage[(y - 1) * width + x] - grayImage[(y - 1) * width + (x + 1)] +
            grayImage[(y + 1) * width + (x - 1)] + 2 * grayImage[(y + 1) * width + x] + grayImage[(y + 1) * width + (x + 1)];
          
          const gradient = Math.sqrt(gx * gx + gy * gy);
          gradients.push(gradient);
        }
      }

      // 计算梯度统计特征
      const mean = gradients.reduce((sum, g) => sum + g, 0) / gradients.length;
      const variance = gradients.reduce((sum, g) => sum + (g - mean) ** 2, 0) / gradients.length;
      const std = Math.sqrt(variance);
      
      // 返回纹理特征: [均值, 标准差, 方差, 最大梯度, 最小梯度]
      return [
        mean / 255,
        std / 255,
        variance / (255 * 255),
        Math.max(...gradients) / 255,
        Math.min(...gradients) / 255
      ];
    } catch (error) {
      console.error('MedicalImageUtils.calculateTextureFeatures error:', error);
      return [0, 0, 0, 0, 0];
    }
  }

  /**
   * 计算宽高比
   * 
   * @param width 宽度
   * @param height 高度
   * @returns 宽高比
   */
  static calculateAspectRatio(width: number, height: number): number {
    return width / height;
  }

  /**
   * 计算平均亮度
   * 
   * @param pixelMap 图像
   * @returns 平均亮度(0-1)
   */
  static async calculateAverageBrightness(pixelMap: image.PixelMap): Promise<number> {
    try {
      // 获取图像信息
      const imageInfo = await pixelMap.getImageInfo();
      const width = imageInfo.size.width;
      const height = imageInfo.size.height;

      // 读取像素数据
      const pixelBytesNumber = pixelMap.getPixelBytesNumber();
      const buffer = new ArrayBuffer(pixelBytesNumber);
      await pixelMap.readPixelsToBuffer(buffer);
      const pixels = new Uint8Array(buffer);

      // 计算平均亮度
      let totalBrightness = 0;
      for (let i = 0; i < width * height; i++) {
        const pixelIndex = i * 4;
        const r = pixels[pixelIndex];
        const g = pixels[pixelIndex + 1];
        const b = pixels[pixelIndex + 2];
        
        // 计算亮度
        const brightness = (0.299 * r + 0.587 * g + 0.114 * b) / 255;
        totalBrightness += brightness;
      }

      return totalBrightness / (width * height);
    } catch (error) {
      console.error('MedicalImageUtils.calculateAverageBrightness error:', error);
      return 0.5;
    }
  }

  /**
   * 提取图像特征
   * 
   * @param pixelMap 图像
   * @returns 图像特征对象
   */
  static async extractFeatures(pixelMap: image.PixelMap): Promise<ImageFeatures> {
    try {
      // 获取图像信息
      const imageInfo = await pixelMap.getImageInfo();
      const width = imageInfo.size.width;
      const height = imageInfo.size.height;

      // 并行计算各项特征
      const [colorHistogram, textureFeatures, averageBrightness] = await Promise.all([
        this.calculateColorHistogram(pixelMap),
        this.calculateTextureFeatures(pixelMap),
        this.calculateAverageBrightness(pixelMap)
      ]);

      return {
        aspectRatio: this.calculateAspectRatio(width, height),
        averageBrightness,
        colorHistogram,
        textureFeatures,
        width,
        height
      };
    } catch (error) {
      console.error('MedicalImageUtils.extractFeatures error:', error);
      throw new Error(`图像特征提取失败: ${error}`);
    }
  }

  /**
   * 验证图像格式
   * 
   * @param imageUri 图像URI
   * @returns 是否为支持的格式
   */
  static validateImageFormat(imageUri: string): boolean {
    const supportedFormats = ['.jpg', '.jpeg', '.png', '.bmp', '.dcm'];
    const lowerUri = imageUri.toLowerCase();
    
    return supportedFormats.some(format => lowerUri.endsWith(format));
  }

  /**
   * 验证图像大小
   * 
   * @param imageSizeBytes 图像大小(字节)
   * @returns 是否符合要求(≤10MB)
   */
  static validateImageSize(imageSizeBytes: number): boolean {
    const maxSizeBytes = 10 * 1024 * 1024; // 10MB
    return imageSizeBytes <= maxSizeBytes;
  }

  /**
   * 计算两个特征向量的余弦相似度
   * 
   * @param vector1 向量1
   * @param vector2 向量2
   * @returns 相似度(0-1)
   */
  static calculateCosineSimilarity(vector1: number[], vector2: number[]): number {
    if (vector1.length !== vector2.length) {
      return 0;
    }

    let dotProduct = 0;
    let norm1 = 0;
    let norm2 = 0;

    for (let i = 0; i < vector1.length; i++) {
      dotProduct += vector1[i] * vector2[i];
      norm1 += vector1[i] * vector1[i];
      norm2 += vector2[i] * vector2[i];
    }

    if (norm1 === 0 || norm2 === 0) {
      return 0;
    }

    return dotProduct / (Math.sqrt(norm1) * Math.sqrt(norm2));
  }

  /**
   * 计算图像的清晰度(使用拉普拉斯方差)
   * 
   * @param pixelMap 图像
   * @returns 清晰度分数
   */
  static async calculateSharpness(pixelMap: image.PixelMap): Promise<number> {
    try {
      // 获取图像信息
      const imageInfo = await pixelMap.getImageInfo();
      const width = imageInfo.size.width;
      const height = imageInfo.size.height;

      // 读取像素数据
      const pixelBytesNumber = pixelMap.getPixelBytesNumber();
      const buffer = new ArrayBuffer(pixelBytesNumber);
      await pixelMap.readPixelsToBuffer(buffer);
      const pixels = new Uint8Array(buffer);

      // 转换为灰度图像
      const grayImage = new Float32Array(width * height);
      for (let i = 0; i < width * height; i++) {
        const pixelIndex = i * 4;
        const r = pixels[pixelIndex];
        const g = pixels[pixelIndex + 1];
        const b = pixels[pixelIndex + 2];
        grayImage[i] = 0.299 * r + 0.587 * g + 0.114 * b;
      }

      // 计算拉普拉斯方差
      let sumLaplacian = 0;
      let count = 0;

      for (let y = 1; y < height - 1; y++) {
        for (let x = 1; x < width - 1; x++) {
          const idx = y * width + x;
          
          // 拉普拉斯算子
          const laplacian = 
            -4 * grayImage[idx] +
            grayImage[idx - 1] +
            grayImage[idx + 1] +
            grayImage[idx - width] +
            grayImage[idx + width];
          
          sumLaplacian += laplacian * laplacian;
          count++;
        }
      }

      return sumLaplacian / count;
    } catch (error) {
      console.error('MedicalImageUtils.calculateSharpness error:', error);
      return 0;
    }
  }
}
