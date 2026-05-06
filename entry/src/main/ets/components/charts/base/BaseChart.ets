/**
 * 图表基类（抽象类）
 * 提供图表的公共属性和方法
 */

import {
  BaseChartConfig,
  ChartData,
  ChartEvent,
  ChartConfigChangeListener,
  ChartDataChangeListener,
  ChartEventListener,
  ChartRenderContext,
  InteractionState
} from '../types';

/**
 * 图表基类（抽象类）
 */
export abstract class BaseChart<T> {
  // 配置
  protected config: BaseChartConfig;
  
  // 数据
  protected data: ChartData<T>;
  
  // Canvas上下文
  protected ctx: CanvasRenderingContext2D | null = null;
  
  // 动画进度（0-1）
  protected animationProgress: number = 1;
  
  // 交互状态
  protected interaction: InteractionState = {
    zoom: 1,
    panX: 0,
    panY: 0,
    isInteracting: false
  };
  
  // 配置变更监听器
  protected configListeners: ChartConfigChangeListener[] = [];
  
  // 数据变更监听器
  protected dataListeners: ChartDataChangeListener<T>[] = [];
  
  // 事件监听器
  protected eventListeners: ChartEventListener[] = [];
  
  /**
   * 构造函数
   * @param config 初始配置
   * @param data 初始数据
   */
  constructor(config: BaseChartConfig, data: ChartData<T>) {
    this.config = config;
    this.data = data;
  }
  
  /**
   * 设置Canvas上下文
   * @param ctx Canvas渲染上下文
   */
  public setContext(ctx: CanvasRenderingContext2D): void {
    this.ctx = ctx;
  }
  
  /**
   * 更新配置
   * @param newConfig 部分新配置
   */
  public setConfig(newConfig: Partial<BaseChartConfig>): void {
    this.config = { ...this.config, ...newConfig };
    this.notifyConfigChange();
    this.refresh();
  }
  
  /**
   * 获取当前配置
   */
  public getConfig(): BaseChartConfig {
    return { ...this.config };
  }
  
  /**
   * 更新数据
   * @param newData 新数据
   */
  public setData(newData: ChartData<T>): void {
    this.data = newData;
    this.notifyDataChange();
    this.refresh();
  }
  
  /**
   * 获取当前数据
   */
  public getData(): ChartData<T> {
    return { ...this.data, data: [...this.data.data] };
  }
  
  /**
   * 刷新图表
   */
  public refresh(): void {
    if (!this.ctx) {
      console.warn('[BaseChart] Canvas上下文未设置');
      return;
    }
    
    if (this.config.animation && this.animationProgress < 1) {
      this.animateDraw();
    } else {
      this.draw();
    }
  }
  
  /**
   * 绘制图表（抽象方法，子类实现）
   */
  protected abstract draw(): void;
  
  /**
   * 计算坐标轴（抽象方法，子类实现）
   */
  protected abstract calculateAxis(): void;
  
  /**
   * 动画绘制
   */
  protected animateDraw(): void {
    const startTime = Date.now();
    const duration = this.config.animationDuration;
    
    const animate = () => {
      const elapsed = Date.now() - startTime;
      this.animationProgress = Math.min(elapsed / duration, 1);
      
      // 应用缓动函数
      const easedProgress = this.easeOutCubic(this.animationProgress);
      
      this.draw();
      
      if (this.animationProgress < 1) {
        // 继续动画
        requestAnimationFrame(animate);
      }
    };
    
    requestAnimationFrame(animate);
  }
  
  /**
   * 缓动函数：easeOutCubic
   */
  protected easeOutCubic(t: number): number {
    return 1 - Math.pow(1 - t, 3);
  }
  
  /**
   * 缓动函数：easeInOutCubic
   */
  protected easeInOutCubic(t: number): number {
    return t < 0.5
      ? 4 * t * t * t
      : 1 - Math.pow(-2 * t + 2, 3) / 2;
  }
  
  /**
   * 获取绘图区域（去除padding后的区域）
   */
  protected getPlotArea(): { x: number; y: number; width: number; height: number } {
    const [top, right, bottom, left] = this.config.padding;
    return {
      x: left,
      y: top,
      width: this.config.width - left - right,
      height: this.config.height - top - bottom
    };
  }
  
  /**
   * 获取渲染上下文
   */
  protected getRenderContext(): ChartRenderContext | null {
    if (!this.ctx) {
      return null;
    }
    
    return {
      ctx: this.ctx,
      width: this.config.width,
      height: this.config.height,
      plotArea: this.getPlotArea(),
      animationProgress: this.animationProgress,
      interaction: this.interaction
    };
  }
  
  /**
   * 绘制背景
   */
  protected drawBackground(): void {
    if (!this.ctx) return;
    
    this.ctx.fillStyle = this.config.backgroundColor;
    this.ctx.fillRect(0, 0, this.config.width, this.config.height);
  }
  
  /**
   * 绘制网格
   */
  protected drawGrid(): void {
    if (!this.ctx || !this.config.showGrid) return;
    
    const plotArea = this.getPlotArea();
    
    this.ctx.strokeStyle = this.config.gridColor;
    this.ctx.lineWidth = 1;
    
    // 绘制水平网格线
    const horizontalLines = 5;
    const verticalStep = plotArea.height / horizontalLines;
    
    for (let i = 0; i <= horizontalLines; i++) {
      const y = plotArea.y + i * verticalStep;
      this.ctx.beginPath();
      this.ctx.moveTo(plotArea.x, y);
      this.ctx.lineTo(plotArea.x + plotArea.width, y);
      this.ctx.stroke();
    }
    
    // 绘制垂直网格线
    const verticalLines = 5;
    const horizontalStep = plotArea.width / verticalLines;
    
    for (let i = 0; i <= verticalLines; i++) {
      const x = plotArea.x + i * horizontalStep;
      this.ctx.beginPath();
      this.ctx.moveTo(x, plotArea.y);
      this.ctx.lineTo(x, plotArea.y + plotArea.height);
      this.ctx.stroke();
    }
  }
  
  /**
   * 清空画布
   */
  protected clearCanvas(): void {
    if (!this.ctx) return;
    
    this.ctx.clearRect(0, 0, this.config.width, this.config.height);
  }
  
  /**
   * 添加配置变更监听器
   */
  public addConfigListener(listener: ChartConfigChangeListener): void {
    if (!this.configListeners.includes(listener)) {
      this.configListeners.push(listener);
    }
  }
  
  /**
   * 移除配置变更监听器
   */
  public removeConfigListener(listener: ChartConfigChangeListener): void {
    const index = this.configListeners.indexOf(listener);
    if (index !== -1) {
      this.configListeners.splice(index, 1);
    }
  }
  
  /**
   * 添加数据变更监听器
   */
  public addDataListener(listener: ChartDataChangeListener<T>): void {
    if (!this.dataListeners.includes(listener)) {
      this.dataListeners.push(listener);
    }
  }
  
  /**
   * 移除数据变更监听器
   */
  public removeDataListener(listener: ChartDataChangeListener<T>): void {
    const index = this.dataListeners.indexOf(listener);
    if (index !== -1) {
      this.dataListeners.splice(index, 1);
    }
  }
  
  /**
   * 添加事件监听器
   */
  public addEventListener(listener: ChartEventListener): void {
    if (!this.eventListeners.includes(listener)) {
      this.eventListeners.push(listener);
    }
  }
  
  /**
   * 移除事件监听器
   */
  public removeEventListener(listener: ChartEventListener): void {
    const index = this.eventListeners.indexOf(listener);
    if (index !== -1) {
      this.eventListeners.splice(index, 1);
    }
  }
  
  /**
   * 通知配置变更
   */
  protected notifyConfigChange(): void {
    const config = this.getConfig();
    this.configListeners.forEach(listener => {
      try {
        listener(config);
      } catch (error) {
        console.error('[BaseChart] 配置监听器执行失败:', error);
      }
    });
  }
  
  /**
   * 通知数据变更
   */
  protected notifyDataChange(): void {
    const data = this.getData();
    this.dataListeners.forEach(listener => {
      try {
        listener(data);
      } catch (error) {
        console.error('[BaseChart] 数据监听器执行失败:', error);
      }
    });
  }
  
  /**
   * 触发事件
   */
  protected emitEvent(event: ChartEvent): void {
    this.eventListeners.forEach(listener => {
      try {
        listener(event);
      } catch (error) {
        console.error('[BaseChart] 事件监听器执行失败:', error);
      }
    });
  }
  
  /**
   * 处理缩放
   * @param scale 缩放比例
   */
  public zoom(scale: number): void {
    this.interaction.zoom = Math.max(0.5, Math.min(3, scale));
    this.interaction.isInteracting = true;
    this.refresh();
    
    this.emitEvent({
      type: 'zoom',
      timestamp: Date.now()
    });
  }
  
  /**
   * 处理平移
   * @param deltaX X方向偏移
   * @param deltaY Y方向偏移
   */
  public pan(deltaX: number, deltaY: number): void {
    this.interaction.panX += deltaX;
    this.interaction.panY += deltaY;
    this.interaction.isInteracting = true;
    this.refresh();
    
    this.emitEvent({
      type: 'pan',
      position: [deltaX, deltaY],
      timestamp: Date.now()
    });
  }
  
  /**
   * 重置交互状态
   */
  public resetInteraction(): void {
    this.interaction = {
      zoom: 1,
      panX: 0,
      panY: 0,
      isInteracting: false
    };
    this.refresh();
  }
  
  /**
   * 销毁图表
   */
  public destroy(): void {
    this.ctx = null;
    this.configListeners = [];
    this.dataListeners = [];
    this.eventListeners = [];
  }
}
