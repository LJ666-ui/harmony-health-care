/**
 * AR院内导航系统 - AR渲染引擎
 * 
 * 实现AR画面渲染,核心功能:
 * - 相机画面实时显示
 * - 3D方向箭头绘制和旋转
 * - 导航信息叠加
 * - 渲染性能优化
 * 
 * @version 1.0
 * @date 2025-01-18
 * @author SDD Agent
 */

import { ArrowColorConfig } from '../models/ARNavigationModels';

/**
 * 导航信息接口
 */
export interface NavigationInfo {
  instruction: string;      // 当前指令
  remainingDistance: number; // 剩余距离(米)
  estimatedTime: number;    // 预计时间(秒)
  progress: number;         // 进度(0-1)
}

/**
 * AR渲染引擎类(单例)
 */
export class ARRenderer {
  private static instance: ARRenderer | null = null;

  // 渲染上下文
  private canvasContext: CanvasRenderingContext2D | null = null;
  private canvasWidth: number = 1080;
  private canvasHeight: number = 1920;

  // 渲染状态
  private isRendering: boolean = false;
  private renderFrameId: number = 0;

  // 箭头状态
  private arrowDirection: number = 0; // 朝向角度(0-360度)
  private arrowColor: string = '#52C41A'; // 绿色
  private arrowScale: number = 1.0;

  // 导航信息
  private navigationInfo: NavigationInfo | null = null;

  // 性能监控
  private frameCount: number = 0;
  private lastFpsTime: number = 0;
  private currentFps: number = 0;

  // 箭头颜色配置
  private readonly arrowColors: ArrowColorConfig = {
    normal: '#52C41A',   // 绿色(正常)
    turn: '#FAAD14',     // 黄色(转弯)
    arrival: '#FF4D4F',  // 红色(到达)
    warning: '#FF7A45'   // 橙色(警告)
  };

  /**
   * 私有构造函数(单例模式)
   */
  private constructor() {}

  /**
   * 获取单例实例
   */
  public static getInstance(): ARRenderer {
    if (!ARRenderer.instance) {
      ARRenderer.instance = new ARRenderer();
    }
    return ARRenderer.instance;
  }

  /**
   * 初始化渲染引擎
   * @param context Canvas渲染上下文
   */
  public async initialize(context: CanvasRenderingContext2D): Promise<void> {
    this.canvasContext = context;
    this.canvasWidth = context.width;
    this.canvasHeight = context.height;

    console.log(
      '[ARRenderer] 初始化完成,画布尺寸:',
      this.canvasWidth,
      'x',
      this.canvasHeight
    );
  }

  /**
   * 启动渲染
   */
  public startRendering(): void {
    if (this.isRendering) {
      console.warn('[ARRenderer] 渲染已在运行');
      return;
    }

    this.isRendering = true;
    this.lastFpsTime = Date.now();
    this.frameCount = 0;

    // 启动渲染循环
    this.renderLoop();

    console.log('[ARRenderer] 渲染已启动');
  }

  /**
   * 停止渲染
   */
  public stopRendering(): void {
    this.isRendering = false;

    console.log('[ARRenderer] 渲染已停止,平均帧率:', this.currentFps, 'fps');
  }

  /**
   * 渲染循环
   */
  private renderLoop(): void {
    if (!this.isRendering || !this.canvasContext) {
      return;
    }

    // 渲染一帧
    this.renderFrame();

    // 更新帧率统计
    this.updateFps();

    // 请求下一帧(使用setTimeout替代requestAnimationFrame)
    this.renderFrameId = setTimeout(() => this.renderLoop(), 33); // 约30fps
  }

  /**
   * 渲染一帧
   */
  private renderFrame(): void {
    if (!this.canvasContext) return;

    const ctx = this.canvasContext;

    // 1. 清空画布
    ctx.clearRect(0, 0, this.canvasWidth, this.canvasHeight);

    // 2. 绘制背景(模拟相机画面)
    this.drawCameraBackground();

    // 3. 绘制3D方向箭头
    this.drawDirectionArrow();

    // 4. 绘制导航信息叠加
    if (this.navigationInfo) {
      this.drawNavigationInfo(this.navigationInfo);
    }

    // 5. 绘制帧率(调试)
    this.drawDebugInfo();
  }

  /**
   * 绘制相机背景
   * 简化实现:使用渐变色模拟
   */
  private drawCameraBackground(): void {
    if (!this.canvasContext) return;

    const ctx = this.canvasContext;

    // 创建渐变背景(模拟相机画面)
    const gradient = ctx.createLinearGradient(
      0,
      0,
      0,
      this.canvasHeight
    );
    gradient.addColorStop(0, '#1a1a1a');
    gradient.addColorStop(0.5, '#2a2a2a');
    gradient.addColorStop(1, '#1a1a1a');

    ctx.fillStyle = gradient;
    ctx.fillRect(0, 0, this.canvasWidth, this.canvasHeight);

    // 添加网格线(辅助定位)
    ctx.strokeStyle = 'rgba(255, 255, 255, 0.1)';
    ctx.lineWidth = 1;

    const gridSize = 50;
    for (let x = 0; x < this.canvasWidth; x += gridSize) {
      ctx.beginPath();
      ctx.moveTo(x, 0);
      ctx.lineTo(x, this.canvasHeight);
      ctx.stroke();
    }

    for (let y = 0; y < this.canvasHeight; y += gridSize) {
      ctx.beginPath();
      ctx.moveTo(0, y);
      ctx.lineTo(this.canvasWidth, y);
      ctx.stroke();
    }
  }

  /**
   * 绘制3D方向箭头
   */
  private drawDirectionArrow(): void {
    if (!this.canvasContext) return;

    const ctx = this.canvasContext;
    const centerX = this.canvasWidth / 2;
    const centerY = this.canvasHeight / 2;

    // 箭头大小
    const arrowSize = 80 * this.arrowScale;

    ctx.save();

    // 移动到中心
    ctx.translate(centerX, centerY);

    // 旋转(根据朝向)
    ctx.rotate((this.arrowDirection * Math.PI) / 180);

    // 绘制箭头阴影
    ctx.shadowColor = 'rgba(0, 0, 0, 0.5)';
    ctx.shadowBlur = 20;
    ctx.shadowOffsetX = 5;
    ctx.shadowOffsetY = 5;

    // 绘制箭头形状
    ctx.beginPath();
    ctx.moveTo(0, -arrowSize);        // 箭头尖端
    ctx.lineTo(-arrowSize * 0.6, arrowSize * 0.3);  // 左侧
    ctx.lineTo(-arrowSize * 0.2, arrowSize * 0.15); // 左侧内凹
    ctx.lineTo(-arrowSize * 0.2, arrowSize * 0.5);  // 左侧底部
    ctx.lineTo(arrowSize * 0.2, arrowSize * 0.5);   // 右侧底部
    ctx.lineTo(arrowSize * 0.2, arrowSize * 0.15);  // 右侧内凹
    ctx.lineTo(arrowSize * 0.6, arrowSize * 0.3);   // 右侧
    ctx.closePath();

    // 填充颜色
    ctx.fillStyle = this.arrowColor;
    ctx.fill();

    // 边框
    ctx.strokeStyle = '#FFFFFF';
    ctx.lineWidth = 3;
    ctx.stroke();

    // 绘制箭头内部高光
    ctx.beginPath();
    ctx.moveTo(0, -arrowSize * 0.8);
    ctx.lineTo(-arrowSize * 0.3, arrowSize * 0.1);
    ctx.lineTo(arrowSize * 0.3, arrowSize * 0.1);
    ctx.closePath();

    ctx.fillStyle = 'rgba(255, 255, 255, 0.3)';
    ctx.fill();

    ctx.restore();
  }

  /**
   * 绘制导航信息叠加
   */
  private drawNavigationInfo(info: NavigationInfo): void {
    if (!this.canvasContext) return;

    const ctx = this.canvasContext;
    const panelHeight = 200;
    const panelY = this.canvasHeight - panelHeight - 50;

    // 绘制半透明背景面板
    ctx.fillStyle = 'rgba(0, 0, 0, 0.7)';
    this.roundRect(
      ctx,
      50,
      panelY,
      this.canvasWidth - 100,
      panelHeight,
      20
    );
    ctx.fill();

    // 绘制边框
    ctx.strokeStyle = 'rgba(255, 255, 255, 0.3)';
    ctx.lineWidth = 2;
    this.roundRect(
      ctx,
      50,
      panelY,
      this.canvasWidth - 100,
      panelHeight,
      20
    );
    ctx.stroke();

    // 绘制指令文本
    ctx.fillStyle = '#FFFFFF';
    ctx.font = 'bold 36px sans-serif';
    ctx.textAlign = 'center';
    ctx.fillText(
      info.instruction,
      this.canvasWidth / 2,
      panelY + 50
    );

    // 绘制剩余距离
    ctx.font = '28px sans-serif';
    ctx.fillStyle = '#FAAD14';
    ctx.fillText(
      `剩余 ${Math.round(info.remainingDistance)} 米`,
      this.canvasWidth / 2,
      panelY + 90
    );

    // 绘制预计时间
    ctx.fillStyle = '#73D13D';
    ctx.fillText(
      `约 ${Math.round(info.estimatedTime / 60)} 分钟`,
      this.canvasWidth / 2,
      panelY + 125
    );

    // 绘制进度条
    const progressBarWidth = this.canvasWidth - 200;
    const progressBarHeight = 10;
    const progressBarX = 100;
    const progressBarY = panelY + 160;

    // 进度条背景
    ctx.fillStyle = 'rgba(255, 255, 255, 0.2)';
    this.roundRect(
      ctx,
      progressBarX,
      progressBarY,
      progressBarWidth,
      progressBarHeight,
      5
    );
    ctx.fill();

    // 进度条前景
    const progressWidth = progressBarWidth * info.progress;
    if (progressWidth > 0) {
      const gradient = ctx.createLinearGradient(
        progressBarX,
        0,
        progressBarX + progressWidth,
        0
      );
      gradient.addColorStop(0, '#52C41A');
      gradient.addColorStop(1, '#73D13D');

      ctx.fillStyle = gradient;
      this.roundRect(
        ctx,
        progressBarX,
        progressBarY,
        progressWidth,
        progressBarHeight,
        5
      );
      ctx.fill();
    }
  }

  /**
   * 绘制调试信息
   */
  private drawDebugInfo(): void {
    if (!this.canvasContext) return;

    const ctx = this.canvasContext;

    // 绘制帧率
    ctx.fillStyle = 'rgba(255, 255, 255, 0.5)';
    ctx.font = '20px monospace';
    ctx.textAlign = 'left';
    ctx.fillText(`FPS: ${this.currentFps}`, 20, 30);
    ctx.fillText(
      `方向: ${Math.round(this.arrowDirection)}°`,
      20,
      55
    );
  }

  /**
   * 绘制圆角矩形
   */
  private roundRect(
    ctx: CanvasRenderingContext2D,
    x: number,
    y: number,
    width: number,
    height: number,
    radius: number
  ): void {
    ctx.beginPath();
    ctx.moveTo(x + radius, y);
    ctx.lineTo(x + width - radius, y);
    ctx.quadraticCurveTo(x + width, y, x + width, y + radius);
    ctx.lineTo(x + width, y + height - radius);
    ctx.quadraticCurveTo(
      x + width,
      y + height,
      x + width - radius,
      y + height
    );
    ctx.lineTo(x + radius, y + height);
    ctx.quadraticCurveTo(x, y + height, x, y + height - radius);
    ctx.lineTo(x, y + radius);
    ctx.quadraticCurveTo(x, y, x + radius, y);
    ctx.closePath();
  }

  /**
   * 更新帧率统计
   */
  private updateFps(): void {
    this.frameCount++;

    const now = Date.now();
    const elapsed = now - this.lastFpsTime;

    if (elapsed >= 1000) {
      this.currentFps = Math.round(
        (this.frameCount * 1000) / elapsed
      );
      this.frameCount = 0;
      this.lastFpsTime = now;
    }
  }

  /**
   * 更新箭头朝向
   * @param direction 朝向角度(0-360度)
   */
  public updateArrowDirection(direction: number): void {
    // 归一化到0-360度
    this.arrowDirection = ((direction % 360) + 360) % 360;
  }

  /**
   * 更新箭头颜色
   * @param color 颜色
   */
  public updateArrowColor(color: string): void {
    this.arrowColor = color;
  }

  /**
   * 根据状态设置箭头颜色
   * @param status 状态('normal'|'turn'|'arrival'|'warning')
   */
  public setArrowStatus(status: 'normal' | 'turn' | 'arrival' | 'warning'): void {
    switch (status) {
      case 'normal':
        this.arrowColor = this.arrowColors.normal;
        break;
      case 'turn':
        this.arrowColor = this.arrowColors.turn;
        break;
      case 'arrival':
        this.arrowColor = this.arrowColors.arrival;
        break;
      case 'warning':
        this.arrowColor = this.arrowColors.warning;
        break;
    }
  }

  /**
   * 更新箭头缩放
   * @param scale 缩放比例
   */
  public updateArrowScale(scale: number): void {
    this.arrowScale = Math.max(0.5, Math.min(2.0, scale));
  }

  /**
   * 更新导航信息
   * @param info 导航信息
   */
  public updateNavigationInfo(info: NavigationInfo): void {
    this.navigationInfo = info;
  }

  /**
   * 获取当前帧率
   */
  public getCurrentFps(): number {
    return this.currentFps;
  }

  /**
   * 获取渲染状态
   */
  public isCurrentlyRendering(): boolean {
    return this.isRendering;
  }
}
