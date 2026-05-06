/**
 * AR院内导航系统 - 语音引导服务
 * 
 * 实现TTS语音引导,核心功能:
 * - 导航指令语音播报
 * - 播报时机控制
 * - 静音切换
 * - 播报队列管理
 * 
 * @version 1.0
 * @date 2025-01-18
 * @author SDD Agent
 */

import {
  Position3D,
  Waypoint,
  WaypointType
} from '../models/ARNavigationModels';

/**
 * 语音引导服务类(单例)
 */
export class VoiceGuide {
  private static instance: VoiceGuide | null = null;

  // TTS配置
  private isMuted: boolean = false;
  private language: string = 'zh-CN';
  private speed: number = 1.0; // 播报速度(0.5-2.0)
  private pitch: number = 1.0; // 音调(0.5-2.0)

  // 播报状态
  private lastAnnouncedWaypointId: string | null = null;
  private isSpeaking: boolean = false;
  private announcementQueue: string[] = [];

  // 播报距离阈值(米)
  private readonly announceDistances: Map<WaypointType, number> = new Map([
    [WaypointType.TURN_LEFT, 5],      // 转弯提前5米
    [WaypointType.TURN_RIGHT, 5],     // 转弯提前5米
    [WaypointType.TAKE_ELEVATOR, 10], // 电梯提前10米
    [WaypointType.TAKE_STAIRS, 10],   // 楼梯提前10米
    [WaypointType.ARRIVAL, 3],        // 到达提前3米
    [WaypointType.GO_STRAIGHT, 20]    // 直行提前20米(较少播报)
  ]);

  // 播报间隔(毫秒)
  private readonly minAnnounceInterval: number = 3000; // 最少间隔3秒
  private lastAnnounceTime: number = 0;

  /**
   * 私有构造函数(单例模式)
   */
  private constructor() {}

  /**
   * 获取单例实例
   */
  public static getInstance(): VoiceGuide {
    if (!VoiceGuide.instance) {
      VoiceGuide.instance = new VoiceGuide();
    }
    return VoiceGuide.instance;
  }

  /**
   * 初始化语音引导服务
   */
  public async initialize(): Promise<void> {
    console.log('[VoiceGuide] 初始化语音引导服务');

    // 初始化TTS引擎
    // 实际实现需要调用HarmonyOS TTS API
    // await tts.createEngine(this.language);

    console.log('[VoiceGuide] 初始化完成');
  }

  /**
   * 播报文本
   * @param text 播报文本
   */
  public async announce(text: string): Promise<void> {
    // 检查静音状态
    if (this.isMuted) {
      console.log('[VoiceGuide] 静音模式,跳过播报:', text);
      return;
    }

    // 检查播报间隔
    const now = Date.now();
    if (now - this.lastAnnounceTime < this.minAnnounceInterval) {
      console.log('[VoiceGuide] 播报间隔过短,加入队列:', text);
      this.announcementQueue.push(text);
      return;
    }

    // 如果正在播报,加入队列
    if (this.isSpeaking) {
      console.log('[VoiceGuide] 正在播报,加入队列:', text);
      this.announcementQueue.push(text);
      return;
    }

    // 执行播报
    await this.speak(text);
  }

  /**
   * 执行TTS播报
   * @param text 播报文本
   */
  private async speak(text: string): Promise<void> {
    console.log('[VoiceGuide] 播报:', text);

    this.isSpeaking = true;
    this.lastAnnounceTime = Date.now();

    try {
      // 实际实现需要调用HarmonyOS TTS API
      // await tts.speak(text, {
      //   speed: this.speed,
      //   pitch: this.pitch
      // });

      // 模拟播报延迟
      await this.simulateSpeakDelay(text);
    } catch (error) {
      console.error('[VoiceGuide] 播报失败:', error);
    } finally {
      this.isSpeaking = false;

      // 处理队列中的下一条
      this.processQueue();
    }
  }

  /**
   * 模拟播报延迟
   */
  private async simulateSpeakDelay(text: string): Promise<void> {
    // 根据文本长度估算播报时间
    const duration = text.length * 100; // 约100ms/字
    await new Promise<void>((resolve: () => void) => {
      setTimeout(() => {
        resolve();
      }, duration);
    });
  }

  /**
   * 处理播报队列
   */
  private processQueue(): void {
    if (this.announcementQueue.length > 0 && !this.isSpeaking) {
      const nextText = this.announcementQueue.shift()!;
      this.speak(nextText);
    }
  }

  /**
   * 检查并播报导航指令
   * @param currentPosition 当前位置
   * @param currentWaypoint 当前途经点
   * @param distanceToWaypoint 到途经点的距离
   */
  public checkAndAnnounce(
    currentPosition: Position3D,
    currentWaypoint: Waypoint,
    distanceToWaypoint: number
  ): void {
    // 检查是否应该播报
    if (!this.shouldAnnounce(currentWaypoint, distanceToWaypoint)) {
      return;
    }

    // 生成播报文本
    const text = this.generateAnnouncementText(currentWaypoint);

    // 执行播报
    this.announce(text);

    // 记录已播报的途经点
    this.lastAnnouncedWaypointId = currentWaypoint.id;
  }

  /**
   * 判断是否应该播报
   * @param waypoint 途经点
   * @param distance 距离
   */
  private shouldAnnounce(waypoint: Waypoint, distance: number): boolean {
    // 已播报过的节点不再播报
    if (this.lastAnnouncedWaypointId === waypoint.id) {
      return false;
    }

    // 获取播报距离阈值
    const threshold = this.announceDistances.get(waypoint.type) ?? 5;

    // 距离小于阈值时播报
    return distance <= threshold;
  }

  /**
   * 生成播报文本
   * @param waypoint 途经点
   */
  private generateAnnouncementText(waypoint: Waypoint): string {
    // 使用途经点的instruction字段
    // 如果有ttsText,使用ttsText(更精简)
    // 否则使用instruction

    const text = waypoint.instruction;

    // 简化播报文本
    return this.simplifyText(text);
  }

  /**
   * 简化播报文本
   * @param text 原始文本
   */
  private simplifyText(text: string): string {
    // 移除"约"、"左右"等模糊词
    let simplified = text
      .replace(/约/g, '')
      .replace(/左右/g, '')
      .replace(/大约/g, '');

    // 简化数字
    simplified = simplified.replace(/(\d+)米/g, (match: string, num: string): string => {
      const n = parseInt(num);
      if (n >= 100) {
        return `${Math.round(n / 10) * 10}米`;
      }
      return match;
    });

    return simplified;
  }

  /**
   * 设置静音状态
   * @param muted 是否静音
   */
  public setMuted(muted: boolean): void {
    this.isMuted = muted;
    console.log('[VoiceGuide] 静音状态:', muted);

    // 如果静音,清空队列
    if (muted) {
      this.announcementQueue = [];
    }
  }

  /**
   * 获取静音状态
   */
  public isMutedState(): boolean {
    return this.isMuted;
  }

  /**
   * 设置播报速度
   * @param speed 速度(0.5-2.0)
   */
  public setSpeed(speed: number): void {
    this.speed = Math.max(0.5, Math.min(2.0, speed));
    console.log('[VoiceGuide] 播报速度:', this.speed);
  }

  /**
   * 设置音调
   * @param pitch 音调(0.5-2.0)
   */
  public setPitch(pitch: number): void {
    this.pitch = Math.max(0.5, Math.min(2.0, pitch));
    console.log('[VoiceGuide] 音调:', this.pitch);
  }

  /**
   * 停止当前播报
   */
  public stopCurrentAnnouncement(): void {
    if (this.isSpeaking) {
      // 实际实现需要调用TTS API停止
      // tts.stop();

      this.isSpeaking = false;
      console.log('[VoiceGuide] 停止当前播报');
    }
  }

  /**
   * 清空播报队列
   */
  public clearQueue(): void {
    this.announcementQueue = [];
    console.log('[VoiceGuide] 清空播报队列');
  }

  /**
   * 重置播报状态
   */
  public reset(): void {
    this.lastAnnouncedWaypointId = null;
    this.announcementQueue = [];
    this.stopCurrentAnnouncement();
    console.log('[VoiceGuide] 重置播报状态');
  }

  /**
   * 获取播报队列长度
   */
  public getQueueLength(): number {
    return this.announcementQueue.length;
  }

  /**
   * 获取播报状态
   */
  public isCurrentlySpeaking(): boolean {
    return this.isSpeaking;
  }

  /**
   * 播报到达提示
   */
  public async announceArrival(destinationName: string): Promise<void> {
    const text = `已到达${destinationName}`;
    await this.announce(text);
  }

  /**
   * 播报偏航提示
   */
  public async announceDeviation(): Promise<void> {
    const text = '您已偏离路线,正在重新规划';
    await this.announce(text);
  }

  /**
   * 播报信号丢失提示
   */
  public async announceSignalLost(): Promise<void> {
    const text = '定位信号弱,请移动到开阔区域';
    await this.announce(text);
  }
}
