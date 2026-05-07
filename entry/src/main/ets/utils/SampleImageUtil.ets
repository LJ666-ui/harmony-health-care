/**
 * 示例图片工具类
 * 
 * 用于在模拟器环境下提供测试图片，解决模拟器无法拍照和相册无图片的问题
 */

import { ImagingType } from '../models/ImagingModels';

/**
 * 示例图片信息
 */
export interface SampleImageInfo {
  /** 图片名称 */
  name: string;
  
  /** 图片描述 */
  description: string;
  
  /** 图片资源路径（rawfile路径） */
  resourcePath: string;
  
  /** 对应的影像类型 */
  imagingType: ImagingType;
}

/**
 * 示例图片管理类
 */
export class SampleImageManager {
  /**
   * 获取所有可用的示例图片
   */
  static getAllSampleImages(): SampleImageInfo[] {
    const images: SampleImageInfo[] = [
      {
        name: '胸部X光示例1',
        description: '正常胸部X光片',
        resourcePath: 'sample_images/chest_xray_normal.jpg',
        imagingType: ImagingType.CHEST_XRAY
      },
      {
        name: '胸部X光示例2',
        description: '肺部感染示例',
        resourcePath: 'sample_images/chest_xray_infection.jpg',
        imagingType: ImagingType.CHEST_XRAY
      },
      {
        name: '骨骼X光示例',
        description: '手部骨骼X光片',
        resourcePath: 'sample_images/bone_xray_hand.jpg',
        imagingType: ImagingType.BONE_XRAY
      },
      {
        name: '皮肤照片示例',
        description: '皮肤病变示例',
        resourcePath: 'sample_images/skin_lesion.jpg',
        imagingType: ImagingType.SKIN_PHOTO
      },
      {
        name: '眼底照片示例',
        description: '正常眼底照片',
        resourcePath: 'sample_images/fundus_normal.jpg',
        imagingType: ImagingType.EYE_FUNDUS
      },
      {
        name: '乳腺超声示例',
        description: '乳腺超声影像',
        resourcePath: 'sample_images/breast_ultrasound.jpg',
        imagingType: ImagingType.BREAST_ULTRASOUND
      }
    ];
    return images;
  }

  /**
   * 根据影像类型获取示例图片
   */
  static getSampleImageByType(imagingType: ImagingType): SampleImageInfo | null {
    const images = SampleImageManager.getAllSampleImages();
    const found = images.find((img: SampleImageInfo) => img.imagingType === imagingType);
    return found || null;
  }

  /**
   * 获取示例图片的资源路径
   * 如果本地资源不存在，返回一个占位图片URL
   */
  static getSampleImagePath(imagingType: ImagingType): string {
    const sampleImage = SampleImageManager.getSampleImageByType(imagingType);
    
    if (sampleImage) {
      // 尝试使用本地资源
      // 注意：需要确保rawfile目录下有对应的图片文件
      return sampleImage.resourcePath;
    }
    
    // 如果没有找到，返回占位图片
    return SampleImageManager.getPlaceholderImage(imagingType);
  }

  /**
   * 获取占位图片URL（用于测试）
   */
  static getPlaceholderImage(imagingType: ImagingType): string {
    // 使用Map来存储占位图片URL
    const placeholderMap = new Map<ImagingType, string>();
    placeholderMap.set(ImagingType.CHEST_XRAY, 'https://via.placeholder.com/280x280/4A90E2/FFFFFF?text=胸部X光示例');
    placeholderMap.set(ImagingType.BONE_XRAY, 'https://via.placeholder.com/280x280/50C878/FFFFFF?text=骨骼X光示例');
    placeholderMap.set(ImagingType.SKIN_PHOTO, 'https://via.placeholder.com/280x280/FF9800/FFFFFF?text=皮肤照片示例');
    placeholderMap.set(ImagingType.EYE_FUNDUS, 'https://via.placeholder.com/280x280/9C27B0/FFFFFF?text=眼底照片示例');
    placeholderMap.set(ImagingType.BREAST_ULTRASOUND, 'https://via.placeholder.com/280x280/E91E63/FFFFFF?text=乳腺超声示例');
    
    const url = placeholderMap.get(imagingType);
    return url || 'https://via.placeholder.com/280x280/CCCCCC/FFFFFF?text=示例图片';
  }

  /**
   * 检查示例图片资源是否存在
   * 注意：这个方法在运行时可能无法准确判断，建议在开发时确保资源文件存在
   */
  static checkSampleImageExists(imagingType: ImagingType): boolean {
    // 简单返回true，实际项目中应该检查文件是否存在
    return true;
  }
}
