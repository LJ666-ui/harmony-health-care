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

interface Position2D {
  x: number;
  y: number;
}

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
  private arrowDirection: number = 0;
  private arrowColor: string = '#52C41A';
  private arrowScale: number = 1.0;

  // 当前位置状态
  private currentPosition: Position2D | null = null;
  private targetPosition: Position2D | null = null;

  // 动画相关
  private animationTime: number = 0;

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
  public async initialize(context: CanvasRenderingContext2D, width?: number, height?: number): Promise<void> {
    this.canvasContext = context;
    this.canvasWidth = width ?? 1080;
    this.canvasHeight = height ?? 1920;

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

    if (this.renderFrameId !== 0) {
      clearTimeout(this.renderFrameId);
      this.renderFrameId = 0;
    }

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
    this.animationTime += 33;

    ctx.clearRect(0, 0, this.canvasWidth, this.canvasHeight);

    this.drawCameraBackground();

    this.drawMiniMap();

    this.drawCurrentPositionMarker();

    this.drawDirectionArrow();

    if (this.navigationInfo) {
      this.drawNavigationInfo(this.navigationInfo);
    }

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

  private drawDirectionArrow(): void {
    if (!this.canvasContext) return;

    const ctx = this.canvasContext;
    const centerX = this.canvasWidth / 2;
    const centerY = this.canvasHeight * 0.38;

    const arrowSize = Math.min(this.canvasWidth, this.canvasHeight) * 0.12 * this.arrowScale;

    ctx.save();
    ctx.translate(centerX, centerY);
    ctx.rotate((this.arrowDirection * Math.PI) / 180);

    const pulseScale = 1 + Math.sin(this.animationTime / 300) * 0.05;
    ctx.scale(pulseScale, pulseScale);

    ctx.shadowColor = 'rgba(0, 0, 0, 0.6)';
    ctx.shadowBlur = 30;
    ctx.shadowOffsetX = 4;
    ctx.shadowOffsetY = 4;

    const glowGradient = ctx.createRadialGradient(0, 0, arrowSize * 0.3, 0, 0, arrowSize * 1.5);
    glowGradient.addColorStop(0, this.arrowColor + '40');
    glowGradient.addColorStop(1, 'transparent');
    ctx.fillStyle = glowGradient;
    ctx.beginPath();
    ctx.arc(0, 0, arrowSize * 1.5, 0, Math.PI * 2);
    ctx.fill();

    ctx.beginPath();
    ctx.moveTo(0, -arrowSize);
    ctx.lineTo(-arrowSize * 0.55, arrowSize * 0.35);
    ctx.lineTo(-arrowSize * 0.2, arrowSize * 0.15);
    ctx.lineTo(-arrowSize * 0.2, arrowSize * 0.55);
    ctx.lineTo(arrowSize * 0.2, arrowSize * 0.55);
    ctx.lineTo(arrowSize * 0.2, arrowSize * 0.15);
    ctx.lineTo(arrowSize * 0.55, arrowSize * 0.35);
    ctx.closePath();

    const bodyGradient = ctx.createLinearGradient(0, -arrowSize, 0, arrowSize * 0.55);
    bodyGradient.addColorStop(0, this.arrowColor);
    bodyGradient.addColorStop(1, this.adjustColorBrightness(this.arrowColor, -30));
    ctx.fillStyle = bodyGradient;
    ctx.fill();

    ctx.strokeStyle = '#FFFFFF';
    ctx.lineWidth = 3;
    ctx.stroke();

    ctx.beginPath();
    ctx.moveTo(0, -arrowSize * 0.75);
    ctx.lineTo(-arrowSize * 0.25, arrowSize * 0.08);
    ctx.lineTo(arrowSize * 0.25, arrowSize * 0.08);
    ctx.closePath();
    ctx.fillStyle = 'rgba(255, 255, 255, 0.35)';
    ctx.fill();

    ctx.restore();

    ctx.save();
    ctx.translate(centerX, centerY);

    ctx.beginPath();
    ctx.arc(0, 0, arrowSize * 1.8, 0, Math.PI * 2);
    const ringAlpha = 0.15 + Math.sin(this.animationTime / 500) * 0.1;
    ctx.strokeStyle = `rgba(82, 196, 26, ${ringAlpha})`;
    ctx.lineWidth = 2;
    ctx.stroke();

    for (let i = 0; i < 8; i++) {
      const angle = (i * Math.PI * 2) / 8 + this.animationTime / 2000;
      const innerR = arrowSize * 1.9;
      const outerR = arrowSize * 2.1;
      ctx.beginPath();
      ctx.moveTo(Math.cos(angle) * innerR, Math.sin(angle) * innerR);
      ctx.lineTo(Math.cos(angle) * outerR, Math.sin(angle) * outerR);
      ctx.strokeStyle = `rgba(82, 196, 26, ${ringAlpha * 0.7})`;
      ctx.lineWidth = 2;
      ctx.stroke();
    }

    ctx.restore();
  }

  private adjustColorBrightness(hex: string, amount: number): string {
    let r = parseInt(hex.slice(1, 3), 16);
    let g = parseInt(hex.slice(3, 5), 16);
    let b = parseInt(hex.slice(5, 7), 16);
    r = Math.max(0, Math.min(255, r + amount));
    g = Math.max(0, Math.min(255, g + amount));
    b = Math.max(0, Math.min(255, b + amount));
    return '#' + ((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1);
  }

  private drawCurrentPositionMarker(): void {
    if (!this.canvasContext) return;

    const ctx = this.canvasContext;
    const centerX = this.canvasWidth / 2;
    const markerY = this.canvasHeight * 0.62;

    const baseRadius = 18;
    const pulsePhase = (this.animationTime % 1500) / 1500;
    const pulseRadius = baseRadius + pulsePhase * 20;
    const pulseAlpha = 1 - pulsePhase;

    ctx.save();

    for (let i = 0; i < 3; i++) {
      const phaseOffset = (i / 3);
      const currentPhase = ((pulsePhase + phaseOffset) % 1);
      const r = baseRadius + currentPhase * 25;
      const a = (1 - currentPhase) * 0.4;
      ctx.beginPath();
      ctx.arc(centerX, markerY, r, 0, Math.PI * 2);
      ctx.strokeStyle = `rgba(24, 144, 255, ${a})`;
      ctx.lineWidth = 2;
      ctx.stroke();
    }

    ctx.beginPath();
    ctx.arc(centerX, markerY, baseRadius + 6, 0, Math.PI * 2);
    const markerGlow = ctx.createRadialGradient(
      centerX, markerY, baseRadius,
      centerX, markerY, baseRadius + 10
    );
    markerGlow.addColorStop(0, 'rgba(24, 144, 255, 0.4)');
    markerGlow.addColorStop(1, 'transparent');
    ctx.fillStyle = markerGlow;
    ctx.fill();

    ctx.beginPath();
    ctx.arc(centerX, markerY, baseRadius, 0, Math.PI * 2);
    const markerGradient = ctx.createRadialGradient(
      centerX - baseRadius * 0.3, markerY - baseRadius * 0.3, 0,
      centerX, markerY, baseRadius
    );
    markerGradient.addColorStop(0, '#69C0FF');
    markerGradient.addColorStop(0.7, '#1890FF');
    markerGradient.addColorStop(1, '#096DD9');
    ctx.fillStyle = markerGradient;
    ctx.fill();

    ctx.strokeStyle = '#FFFFFF';
    ctx.lineWidth = 2.5;
    ctx.stroke();

    ctx.beginPath();
    ctx.arc(centerX - baseRadius * 0.25, markerY - baseRadius * 0.25, baseRadius * 0.35, 0, Math.PI * 2);
    ctx.fillStyle = 'rgba(255, 255, 255, 0.5)';
    ctx.fill();

    ctx.fillStyle = '#FFFFFF';
    ctx.font = 'bold 13px sans-serif';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    ctx.fillText('我', centerX, markerY + 1);

    ctx.restore();
  }

  private drawMiniMap(): void {
    if (!this.canvasContext || !this.currentPosition || !this.targetPosition) return;

    const ctx = this.canvasContext;
    const mapSize = Math.min(this.canvasWidth, this.canvasHeight) * 0.22;
    const mapX = this.canvasWidth - mapSize - 20;
    const mapY = this.canvasHeight * 0.28;

    ctx.save();

    ctx.fillStyle = 'rgba(0, 0, 0, 0.75)';
    this.roundRect(ctx, mapX, mapY, mapSize, mapSize, 16);
    ctx.fill();

    ctx.strokeStyle = 'rgba(255, 255, 255, 0.2)';
    ctx.lineWidth = 1.5;
    this.roundRect(ctx, mapX, mapY, mapSize, mapSize, 16);
    ctx.stroke();

    ctx.fillStyle = 'rgba(255, 255, 255, 0.6)';
    ctx.font = `${Math.round(mapSize * 0.09)}px sans-serif`;
    ctx.textAlign = 'center';
    ctx.fillText('导航地图', mapX + mapSize / 2, mapY + mapSize * 0.1);

    const padding = mapSize * 0.15;
    const innerSize = mapSize - padding * 2;

    const scaleX = (pos: Position2D) => {
      return mapX + padding + ((pos.x - 20) / 80) * innerSize;
    };
    const scaleY = (pos: Position2D) => {
      return mapY + padding + innerSize - ((pos.y + 10) / 60) * innerSize;
    };

    const pathLineX = scaleX(this.currentPosition);
    const pathLineY = scaleY(this.currentPosition);
    const targetLineX = scaleX(this.targetPosition);
    const targetLineY = scaleY(this.targetPosition);

    ctx.setLineDash([mapSize * 0.02, mapSize * 0.015]);
    ctx.strokeStyle = 'rgba(82, 196, 26, 0.5)';
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.moveTo(pathLineX, pathLineY);
    ctx.lineTo(targetLineX, targetLineY);
    ctx.stroke();
    ctx.setLineDash([]);

    ctx.beginPath();
    ctx.arc(targetLineX, targetLineY, mapSize * 0.06, 0, Math.PI * 2);
    ctx.fillStyle = '#FF4D4F';
    ctx.fill();
    ctx.strokeStyle = '#FFFFFF';
    ctx.lineWidth = 1.5;
    ctx.stroke();

    ctx.beginPath();
    ctx.arc(pathLineX, pathLineY, mapSize * 0.05, 0, Math.PI * 2);
    ctx.fillStyle = '#1890FF';
    ctx.fill();
    ctx.strokeStyle = '#FFFFFF';
    ctx.lineWidth = 1.5;
    ctx.stroke();

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

  public updateCurrentPosition(x: number, z: number): void {
    this.currentPosition = { x: x, y: z };
  }

  public updateTargetPosition(x: number, z: number): void {
    this.targetPosition = { x: x, y: z };
  }
}
