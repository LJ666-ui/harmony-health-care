/**
 * 组件延迟加载器
 * 延迟加载非关键组件，优化启动性能
 * 
 * @author AI Assistant
 * @date 2026-04-27
 */

import { startupOptimizer } from '../StartupOptimizer';

/**
 * 延迟加载的组件配置
 */
export interface LazyComponent {
  id: string;
  name: string;
  loader: () => Promise<void>;
  priority: number;
}

/**
 * 组件延迟加载器
 */
export class ComponentLazyLoader {
  private static instance: ComponentLazyLoader | null = null;
  
  // 待加载组件列表
  private components: LazyComponent[] = [];
  
  // 已加载组件集合
  private loadedComponents: Set<string> = new Set();
  
  // 私有构造函数
  private constructor() {
    this.registerLazyComponents();
  }
  
  /**
   * 获取单例实例
   */
  public static getInstance(): ComponentLazyLoader {
    if (!ComponentLazyLoader.instance) {
      ComponentLazyLoader.instance = new ComponentLazyLoader();
    }
    return ComponentLazyLoader.instance;
  }
  
  /**
   * 注册延迟加载组件
   */
  private registerLazyComponents(): void {
    // 注册非关键组件的延迟加载任务
    const tasks = [
      {
        id: 'lazy_ai_components',
        name: '延迟加载AI组件',
        priority: 3,
        execute: async () => {
          console.info('[ComponentLazyLoader] 加载AI组件');
          // TODO: 动态导入AI相关组件
          // await import('../../ai/MedicalAgent');
        },
        timeout: 2000
      },
      {
        id: 'lazy_chart_components',
        name: '延迟加载图表组件',
        priority: 4,
        execute: async () => {
          console.info('[ComponentLazyLoader] 加载图表组件');
          // TODO: 动态导入图表组件
          // await import('../../components/RadarChart');
        },
        timeout: 2000
      },
      {
        id: 'lazy_map_components',
        name: '延迟加载地图组件',
        priority: 5,
        execute: async () => {
          console.info('[ComponentLazyLoader] 加载地图组件');
          // TODO: 动态导入地图相关组件
          // await import('../../ar/ARNavigationService');
        },
        timeout: 2000
      }
    ];
    
    startupOptimizer.registerLazyLoadTasks(tasks);
    console.info('[ComponentLazyLoader] 注册延迟加载组件任务');
  }
  
  /**
   * 注册组件
   */
  public registerComponent(component: LazyComponent): void {
    this.components.push(component);
    this.components.sort((a, b) => a.priority - b.priority);
  }
  
  /**
   * 加载组件
   */
  public async loadComponent(id: string): Promise<boolean> {
    if (this.loadedComponents.has(id)) {
      console.warn(`[ComponentLazyLoader] 组件 ${id} 已加载`);
      return true;
    }
    
    const component = this.components.find(c => c.id === id);
    if (!component) {
      console.error(`[ComponentLazyLoader] 组件 ${id} 未注册`);
      return false;
    }
    
    try {
      await component.loader();
      this.loadedComponents.add(id);
      console.info(`[ComponentLazyLoader] 组件 ${id} 加载成功`);
      return true;
    } catch (error) {
      console.error(`[ComponentLazyLoader] 组件 ${id} 加载失败:`, error);
      return false;
    }
  }
  
  /**
   * 检查组件是否已加载
   */
  public isLoaded(id: string): boolean {
    return this.loadedComponents.has(id);
  }
  
  /**
   * 获取已加载组件列表
   */
  public getLoadedComponents(): string[] {
    return Array.from(this.loadedComponents);
  }
}

// 导出单例
export const componentLazyLoader = ComponentLazyLoader.getInstance();
