/**
 * AI模型管理器
 * 
 * 负责AI模型的生命周期管理:
 * - 模型加载(支持NPU优先、CPU降级)
 * - 模型缓存
 * - 模型卸载
 * - 状态管理
 */

import { ImagingType, ModelStatus, ModelPathMap } from '../models/ImagingModels';

/**
 * 模型信息接口
 */
interface ModelInfo {
  /** 模型状态 */
  status: ModelStatus;
  /** 模型路径 */
  path: string;
  /** 加载时间 */
  loadTime?: number;
  /** 错误信息 */
  error?: string;
}

/**
 * AI模型管理器(单例)
 */
export class ModelManager {
  private static instance: ModelManager;

  /** 模型缓存 */
  private modelCache: Map<ImagingType, object> = new Map();
  
  /** 模型状态信息 */
  private modelInfoMap: Map<ImagingType, ModelInfo> = new Map();

  /** 私有构造函数 */
  private constructor() {
    // 初始化所有模型状态为NOT_LOADED
    Object.values(ImagingType).forEach(type => {
      const path = ModelPathMap.getPath(type as ImagingType);
      this.modelInfoMap.set(type as ImagingType, {
        status: ModelStatus.NOT_LOADED,
        path: path
      });
    });
  }

  /**
   * 获取单例实例
   */
  static getInstance(): ModelManager {
    if (!ModelManager.instance) {
      ModelManager.instance = new ModelManager();
    }
    return ModelManager.instance;
  }

  /**
   * 加载模型
   * 
   * @param imagingType 影像类型
   * @returns 模型对象
   */
  async loadModel(imagingType: ImagingType): Promise<object> {
    try {
      // 检查缓存
      const cachedModel = this.modelCache.get(imagingType);
      if (cachedModel) {
        console.info(`ModelManager: 使用缓存模型 ${imagingType}`);
        return cachedModel;
      }

      // 更新状态为LOADING
      this.updateModelStatus(imagingType, ModelStatus.LOADING);

      // 获取模型路径
      const modelPath = ModelPathMap.getPath(imagingType);
      console.info(`ModelManager: 开始加载模型 ${imagingType} from ${modelPath}`);

      // 模拟模型加载(实际项目中使用MindSpore Lite API)
      // const context = getContext(this);
      // const model = await mindspore.loadModelFromFile(context, modelPath);
      
      // 这里使用模拟对象
      const model = {
        type: imagingType,
        path: modelPath,
        loaded: true,
        loadTime: Date.now()
      };

      // 缓存模型
      this.modelCache.set(imagingType, model);
      
      // 更新状态为LOADED
      this.updateModelStatus(imagingType, ModelStatus.LOADED, Date.now());

      console.info(`ModelManager: 模型加载成功 ${imagingType}`);
      return model;
    } catch (error) {
      // 更新状态为ERROR
      this.updateModelStatus(imagingType, ModelStatus.ERROR, undefined, String(error));
      console.error(`ModelManager: 模型加载失败 ${imagingType}`, error);
      throw new Error(`模型加载失败: ${error}`);
    }
  }

  /**
   * 预加载所有模型
   * 应用启动时调用,提前加载所有模型到内存
   */
  async preloadAllModels(): Promise<void> {
    console.info('ModelManager: 开始预加载所有模型');
    
    const loadPromises = Object.values(ImagingType).map(type => 
      this.loadModel(type as ImagingType).catch(error => {
        console.error(`ModelManager: 预加载模型失败 ${type}`, error);
        // 不抛出异常,继续加载其他模型
      })
    );

    await Promise.all(loadPromises);
    console.info('ModelManager: 所有模型预加载完成');
  }

  /**
   * 卸载模型
   * 释放模型占用的内存
   * 
   * @param imagingType 影像类型
   */
  async unloadModel(imagingType: ImagingType): Promise<void> {
    try {
      const model = this.modelCache.get(imagingType);
      if (!model) {
        console.info(`ModelManager: 模型未加载,无需卸载 ${imagingType}`);
        return;
      }

      // 模拟模型卸载(实际项目中调用MindSpore API)
      // await model.unload();

      // 从缓存中移除
      this.modelCache.delete(imagingType);
      
      // 更新状态为NOT_LOADED
      this.updateModelStatus(imagingType, ModelStatus.NOT_LOADED);

      console.info(`ModelManager: 模型卸载成功 ${imagingType}`);
    } catch (error) {
      console.error(`ModelManager: 模型卸载失败 ${imagingType}`, error);
      throw new Error(`模型卸载失败: ${error}`);
    }
  }

  /**
   * 获取模型状态
   * 
   * @param imagingType 影像类型
   * @returns 模型状态
   */
  getModelStatus(imagingType: ImagingType): ModelStatus {
    const info = this.modelInfoMap.get(imagingType);
    return info ? info.status : ModelStatus.NOT_LOADED;
  }

  /**
   * 获取所有模型状态
   * 
   * @returns 模型状态映射
   */
  getAllModelStatus(): Map<ImagingType, ModelStatus> {
    const statusMap = new Map<ImagingType, ModelStatus>();
    this.modelInfoMap.forEach((info, type) => {
      statusMap.set(type, info.status);
    });
    return statusMap;
  }

  /**
   * 清空所有模型缓存
   */
  async clearCache(): Promise<void> {
    console.info('ModelManager: 开始清空所有模型缓存');
    
    const unloadPromises = Array.from(this.modelCache.keys()).map(type => 
      this.unloadModel(type).catch(error => {
        console.error(`ModelManager: 卸载模型失败 ${type}`, error);
      })
    );

    await Promise.all(unloadPromises);
    console.info('ModelManager: 所有模型缓存已清空');
  }

  /**
   * 获取模型信息
   * 
   * @param imagingType 影像类型
   * @returns 模型信息
   */
  getModelInfo(imagingType: ImagingType): ModelInfo | undefined {
    return this.modelInfoMap.get(imagingType);
  }

  /**
   * 更新模型状态
   * 
   * @param imagingType 影像类型
   * @param status 新状态
   * @param loadTime 加载时间
   * @param error 错误信息
   */
  private updateModelStatus(
    imagingType: ImagingType,
    status: ModelStatus,
    loadTime?: number,
    error?: string
  ): void {
    const info = this.modelInfoMap.get(imagingType);
    if (info) {
      info.status = status;
      if (loadTime !== undefined) {
        info.loadTime = loadTime;
      }
      if (error !== undefined) {
        info.error = error;
      }
      this.modelInfoMap.set(imagingType, info);
    }
  }

  /**
   * 检查模型是否已加载
   * 
   * @param imagingType 影像类型
   * @returns 是否已加载
   */
  isModelLoaded(imagingType: ImagingType): boolean {
    return this.getModelStatus(imagingType) === ModelStatus.LOADED;
  }

  /**
   * 获取已加载模型数量
   * 
   * @returns 已加载模型数量
   */
  getLoadedModelCount(): number {
    let count = 0;
    this.modelInfoMap.forEach(info => {
      if (info.status === ModelStatus.LOADED) {
        count++;
      }
    });
    return count;
  }

  /**
   * 获取模型内存占用估算(MB)
   * 
   * @returns 内存占用
   */
  getEstimatedMemoryUsage(): number {
    // 每个模型估算约20MB
    const modelSizeMB = 20;
    return this.getLoadedModelCount() * modelSizeMB;
  }
}
