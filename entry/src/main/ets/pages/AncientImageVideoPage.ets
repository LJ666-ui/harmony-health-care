import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { ToastUtil } from '../common/utils/ToastUtil';
import {
  InkParticle,
  KenBurnsSequence,
  KenBurnsKeyframe,
  ScrollUnrollState,
  ScrollUnrollPhase,
  MusicSyncController,
  MusicBeat,
  AncientFilterConfig
} from '../ancientimage/AncientImageAnimator';

interface AnimationImageInfo {
  id: number;
  imageUrl: string;
  title: string;
  desc: string;
  source: string;
}

type AnimationMode = 'kenBurns' | 'scrollUnroll' | 'fullShow';

@Entry
@Component
struct AncientImageVideoPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State imageInfo: AnimationImageInfo | null = null;
  @State isPlaying: boolean = false;
  @State animationMode: AnimationMode = 'fullShow';
  @State showControls: boolean = true;
  @State currentTime: number = 0;
  @State totalDuration: number = 30;
  @State showModeSelector: boolean = false;

  @State kbScaleX: number = 1;
  @State kbScaleY: number = 1;
  @State kbTranslateX: number = 0;
  @State kbTranslateY: number = 0;

  @State scrollProgress: number = 0;
  @State scrollPhase: ScrollUnrollPhase = ScrollUnrollPhase.IDLE;
  @State rodOffsetY: number = 0;
  @State shadowOpacity: number = 0.3;

  @State filterSepia: number = 0.12;
  @State filterVignette: number = 0.25;
  @State filterContrast: number = 1.05;

  @State beatIntensity: number = 0;
  @State bpmValue: number = 60;

  @State titleOpacity: number = 0;
  @State titleTranslateY: number = 30;
  @State descOpacity: number = 0;

  @State showEndingCard: boolean = false;
  @State endingOpacity: number = 0;

  private particles: InkParticle[] = [];
  @State particleRenderTick: number = 0;

  private animationTimer: number = -1;
  private startTime: number = 0;
  private lastFrameTime: number = 0;
  private kenBurnsSeq: KenBurnsSequence = KenBurnsSequence.createDefault();
  private scrollState: ScrollUnrollState = new ScrollUnrollState();
  private musicSync: MusicSyncController = new MusicSyncController(60);
  private filterConfig: AncientFilterConfig = AncientFilterConfig.createClassic();

  aboutToAppear(): void {
    const params: Record<string, Object> | undefined = router.getParams() as Record<string, Object> | undefined;
    if (params) {
      this.imageInfo = {
        id: (params['id'] as number) || 0,
        imageUrl: (params['imageUrl'] as string) || '',
        title: (params['title'] as string) || '古医图',
        desc: (params['desc'] as string) || '',
        source: (params['source'] as string) || ''
      };
    }
    this.initParticles();
  }

  aboutToDisappear(): void {
    this.stopAnimation();
  }

  private initParticles(): void {
    this.particles = [];
    const canvasW = 360;
    const canvasH = 700;
    for (let i = 0; i < 25; i++) {
      this.particles.push(new InkParticle(canvasW, canvasH, 'ink'));
    }
    for (let i = 0; i < 15; i++) {
      this.particles.push(new InkParticle(canvasW, canvasH, 'dust'));
    }
    for (let i = 0; i < 8; i++) {
      this.particles.push(new InkParticle(canvasW, canvasH, 'petal'));
    }
  }

  private startAnimation(): void {
    if (this.isPlaying) return;
    this.isPlaying = true;
    this.startTime = Date.now();
    this.lastFrameTime = this.startTime;
    this.currentTime = 0;
    this.showEndingCard = false;
    this.endingOpacity = 0;
    this.titleOpacity = 0;
    this.titleTranslateY = 30;
    this.descOpacity = 0;

    if (this.animationMode === 'scrollUnroll' || this.animationMode === 'fullShow') {
      this.scrollState = new ScrollUnrollState();
      this.scrollState.start();
      this.scrollProgress = 0;
      this.scrollPhase = ScrollUnrollPhase.UNROLLING;
    }

    if (this.animationMode === 'kenBurns' || this.animationMode === 'fullShow') {
      this.kenBurnsSeq = KenBurnsSequence.createDefault();
      this.kbScaleX = 1;
      this.kbScaleY = 1;
      this.kbTranslateX = 0;
      this.kbTranslateY = 0;
    }

    this.musicSync = new MusicSyncController(this.bpmValue);
    this.filterConfig = AncientFilterConfig.createClassic();
    this.filterSepia = this.filterConfig.sepiaIntensity;
    this.filterVignette = this.filterConfig.vignetteIntensity;
    this.filterContrast = this.filterConfig.contrast;

    this.runFrame();
  }

  private stopAnimation(): void {
    this.isPlaying = false;
    if (this.animationTimer !== -1) {
      clearTimeout(this.animationTimer);
      this.animationTimer = -1;
    }
  }

  private runFrame(): void {
    if (!this.isPlaying) return;

    const now = Date.now();
    const dt = (now - this.lastFrameTime) / 1000;
    this.lastFrameTime = now;
    this.currentTime = (now - this.startTime) / 1000;

    this.updateKenBurns();
    this.updateScrollUnroll(dt);
    this.updateParticles(dt);
    this.updateMusicSync(now);
    this.updateTitles();
    this.updateEnding();

    if (this.currentTime >= this.totalDuration) {
      this.isPlaying = false;
      this.showEndingCard = true;
      return;
    }

    this.animationTimer = setTimeout(() => {
      this.runFrame();
    }, 33) as number;
  }

  private updateKenBurns(): void {
    if (this.animationMode !== 'kenBurns' && this.animationMode !== 'fullShow') return;

    const totalDuration = this.kenBurnsSeq.getTotalDuration();
    const loopTime = this.currentTime % (totalDuration / 1000);
    const loopMs = loopTime * 1000;

    let accumulated = 0;
    let fromKf: KenBurnsKeyframe = this.kenBurnsSeq.keyframes[0];
    let toKf: KenBurnsKeyframe = this.kenBurnsSeq.keyframes[1];
    let segmentProgress = 0;

    for (let i = 1; i < this.kenBurnsSeq.keyframes.length; i++) {
      accumulated += this.kenBurnsSeq.keyframes[i].duration;
      if (loopMs <= accumulated) {
        fromKf = this.kenBurnsSeq.keyframes[i - 1];
        toKf = this.kenBurnsSeq.keyframes[i];
        const segmentStart = accumulated - toKf.duration;
        segmentProgress = (loopMs - segmentStart) / toKf.duration;
        break;
      }
    }

    const eased = this.easeInOutCubic(segmentProgress);
    this.kbScaleX = fromKf.scaleX + (toKf.scaleX - fromKf.scaleX) * eased;
    this.kbScaleY = fromKf.scaleY + (toKf.scaleY - fromKf.scaleY) * eased;
    this.kbTranslateX = fromKf.translateX + (toKf.translateX - fromKf.translateX) * eased;
    this.kbTranslateY = fromKf.translateY + (toKf.translateY - fromKf.translateY) * eased;

    const beatBoost = this.beatIntensity * 0.03;
    this.kbScaleX += beatBoost;
    this.kbScaleY += beatBoost;
  }

  private updateScrollUnroll(dt: number): void {
    if (this.animationMode !== 'scrollUnroll' && this.animationMode !== 'fullShow') return;

    this.scrollState.update(dt);
    this.scrollProgress = this.scrollState.progress;
    this.scrollPhase = this.scrollState.phase;
    this.rodOffsetY = this.scrollState.rodOffsetY;
    this.shadowOpacity = this.scrollState.shadowOpacity;
  }

  private updateParticles(dt: number): void {
    const canvasW = 360;
    const canvasH = 700;
    for (const p of this.particles) {
      p.update(dt, canvasW, canvasH);
    }
    this.particleRenderTick++;
  }

  private updateMusicSync(now: number): void {
    this.musicSync.update(now);
    this.beatIntensity = this.musicSync.getIntensity();
  }

  private updateTitles(): void {
    if (this.currentTime > 1 && this.currentTime < 8) {
      this.titleOpacity = Math.min(1, (this.currentTime - 1) * 0.8);
      this.titleTranslateY = Math.max(0, 30 - (this.currentTime - 1) * 20);
    } else if (this.currentTime >= 8) {
      this.titleOpacity = Math.max(0, 1 - (this.currentTime - 8) * 0.5);
    }

    if (this.currentTime > 2.5 && this.currentTime < 9) {
      this.descOpacity = Math.min(1, (this.currentTime - 2.5) * 0.6);
    } else if (this.currentTime >= 9) {
      this.descOpacity = Math.max(0, 1 - (this.currentTime - 9) * 0.5);
    }
  }

  private updateEnding(): void {
    if (this.currentTime > this.totalDuration - 3) {
      this.showEndingCard = true;
      this.endingOpacity = Math.min(1, (this.currentTime - (this.totalDuration - 3)) * 0.5);
    }
  }

  private easeInOutCubic(t: number): number {
    return t < 0.5 ? 4 * t * t * t : 1 - Math.pow(-2 * t + 2, 3) / 2;
  }

  private formatTime(seconds: number): string {
    const m = Math.floor(seconds / 60);
    const s = Math.floor(seconds % 60);
    return `${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`;
  }

  private getModeLabel(mode: AnimationMode): string {
    switch (mode) {
      case 'kenBurns': return '🎬 推拉摇移';
      case 'scrollUnroll': return '📜 画卷展开';
      case 'fullShow': return '✨ 完整演绎';
    }
  }

  build() {
    Stack() {
      Column() {
        Stack() {
          this.buildAnimationStage();

          this.buildParticleLayer();

          this.buildVignetteOverlay();

          this.buildTitleOverlay();

          this.buildEndingCard();
        }
        .width('100%')
        .layoutWeight(1)
        .clip(true)

        this.buildControlBar();
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#0a0a1a')

      if (this.showModeSelector) {
        this.buildModeSelector();
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  buildAnimationStage() {
    Stack() {
      if (this.imageInfo && this.imageInfo.imageUrl) {
        if (this.animationMode === 'scrollUnroll' || (this.animationMode === 'fullShow' && this.scrollPhase !== ScrollUnrollPhase.COMPLETE)) {
          this.buildScrollUnrollView();
        }

        if (this.animationMode === 'kenBurns') {
          this.buildKenBurnsView();
        }

        if (this.animationMode === 'fullShow' && this.scrollPhase === ScrollUnrollPhase.COMPLETE) {
          this.buildKenBurnsView();
        }

        if (!this.isPlaying && this.currentTime === 0) {
          Image(this.imageInfo.imageUrl)
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Cover)
            .colorFilter(this.buildSepiaFilter())
        }
      } else {
        Column() {
          Text('📜')
            .fontSize(64)
            .margin({ bottom: 16 })
          Text('古医图动画')
            .fontSize(20)
            .fontColor('#d4a574')
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  buildKenBurnsView() {
    Image(this.imageInfo!.imageUrl)
      .width('100%')
      .height('100%')
      .objectFit(ImageFit.Cover)
      .scale({ x: this.kbScaleX, y: this.kbScaleY })
      .translate({ x: this.kbTranslateX, y: this.kbTranslateY })
      .colorFilter(this.buildSepiaFilter())
      .animation({
        duration: 100,
        curve: Curve.Linear,
        iterations: 1,
        playMode: PlayMode.Normal
      })
  }

  @Builder
  buildScrollUnrollView() {
    Stack() {
      Column() {
        Image(this.imageInfo!.imageUrl)
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
          .colorFilter(this.buildSepiaFilter())
          .clip(true)
      }
      .width(`${this.scrollProgress * 100}%`)
      .height('100%')
      .alignItems(HorizontalAlign.Start)
      .clip(true)

      Column() {
        Row() {
          Column()
            .width(12)
            .height('100%')
            .linearGradient({
              angle: 90,
              colors: [['#8B7355', 0], ['#6B5340', 0.5], ['#8B7355', 1]]
            })

          Column()
            .width(4)
            .height('100%')
            .backgroundColor('#4a3728')
        }
        .width(16)
        .height('100%')
      }
      .width(16)
      .height('100%')
      .position({ x: `${this.scrollProgress * 100}%`, y: 0 })
      .translate({ x: -16 })
      .shadow({
        radius: 20,
        color: `rgba(0, 0, 0, ${this.shadowOpacity})`,
        offsetX: -10,
        offsetY: 0
      })

      Row() {
        Column()
          .width(14)
          .height('100%')
          .linearGradient({
            angle: 90,
            colors: [['#8B7355', 0], ['#6B5340', 0.5], ['#8B7355', 1]]
          })

        Column()
          .width(4)
          .height('100%')
          .backgroundColor('#4a3728')
      }
      .width(18)
      .height('100%')
      .position({ x: 0, y: 0 })
      .translate({ y: this.rodOffsetY })
    }
    .width('100%')
    .height('100%')
    .clip(true)
  }

  @Builder
  buildParticleLayer() {
    Stack() {
      ForEach(this.particles, (particle: InkParticle, index: number) => {
        Column()
          .width(particle.size)
          .height(particle.size)
          .borderRadius(particle.type === 'petal' ? particle.size / 2 : 2)
          .backgroundColor(particle.color)
          .opacity(particle.opacity)
          .position({ x: particle.x, y: particle.y })
          .rotate({ angle: particle.rotation })
          .shadow({
            radius: particle.type === 'ink' ? 4 : 2,
            color: particle.color,
            offsetX: 0,
            offsetY: 0
          })
      }, (particle: InkParticle, index: number) => `${index}_${this.particleRenderTick}`)
    }
    .width('100%')
    .height('100%')
    .hitTestBehavior(HitTestMode.Transparent)
  }

  @Builder
  buildVignetteOverlay() {
    Column()
      .width('100%')
      .height('100%')
      .linearGradient({
        angle: 0,
        colors: [
          [`rgba(0, 0, 0, ${this.filterVignette})`, 0],
          ['rgba(0, 0, 0, 0)', 0.3],
          ['rgba(0, 0, 0, 0)', 0.7],
          [`rgba(0, 0, 0, ${this.filterVignette})`, 1]
        ]
      })
      .hitTestBehavior(HitTestMode.Transparent)
  }

  @Builder
  buildTitleOverlay() {
    Column() {
      Blank()

      Column() {
        if (this.imageInfo) {
          Text(this.imageInfo.title)
            .fontSize(this.isElderMode ? 28 : 24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .textShadow({ radius: 8, color: '#000000', offsetX: 2, offsetY: 2 })
            .opacity(this.titleOpacity)
            .translate({ y: this.titleTranslateY })
            .animation({
              duration: 300,
              curve: Curve.EaseOut
            })

          if (this.imageInfo.source) {
            Text(`出处：${this.imageInfo.source}`)
              .fontSize(14)
              .fontColor('#d4a574')
              .textShadow({ radius: 4, color: '#000000', offsetX: 1, offsetY: 1 })
              .opacity(this.descOpacity)
              .margin({ top: 8 })
              .animation({
                duration: 300,
                curve: Curve.EaseOut
              })
          }

          if (this.imageInfo.desc) {
            Text(this.imageInfo.desc)
              .fontSize(13)
              .fontColor('#cccccc')
              .textShadow({ radius: 4, color: '#000000', offsetX: 1, offsetY: 1 })
              .opacity(this.descOpacity)
              .maxLines(3)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .margin({ top: 8 })
              .padding({ left: 20, right: 20 })
              .animation({
                duration: 300,
                curve: Curve.EaseOut
              })
          }
        }
      }
      .width('100%')
      .padding({ left: 24, right: 24, bottom: 40 })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height('100%')
    .hitTestBehavior(HitTestMode.Transparent)
  }

  @Builder
  buildEndingCard() {
    if (this.showEndingCard) {
      Column() {
        Text('📜')
          .fontSize(48)
          .margin({ bottom: 16 })

        Text(this.imageInfo?.title || '古医图')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#d4a574')
          .margin({ bottom: 8 })

        Text('— 古医图动画演绎 —')
          .fontSize(14)
          .fontColor('#8c7b6b')
          .margin({ bottom: 24 })

        Row({ space: 16 }) {
          Button('重新播放')
            .height(40)
            .fontSize(14)
            .fontColor('#d4a574')
            .backgroundColor('rgba(212, 165, 116, 0.15)')
            .border({ width: 1, color: '#d4a574' })
            .borderRadius(20)
            .padding({ left: 24, right: 24 })
            .onClick(() => {
              this.startAnimation();
            })

          Button('返回')
            .height(40)
            .fontSize(14)
            .fontColor('#FFFFFF')
            .backgroundColor('#722ED1')
            .borderRadius(20)
            .padding({ left: 24, right: 24 })
            .onClick(() => {
              router.back();
            })
        }
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor('rgba(10, 10, 26, 0.85)')
      .opacity(this.endingOpacity)
      .animation({
        duration: 500,
        curve: Curve.EaseOut
      })
    }
  }

  @Builder
  buildControlBar() {
    Column() {
      Row() {
        Text(this.formatTime(this.currentTime))
          .fontSize(12)
          .fontColor('#d4a574')
          .width(45)

        Progress({ value: this.currentTime, total: this.totalDuration, type: ProgressType.Linear })
          .layoutWeight(1)
          .color('#722ED1')
          .backgroundColor('rgba(114, 46, 209, 0.2)')

        Text(this.formatTime(this.totalDuration))
          .fontSize(12)
          .fontColor('#8c7b6b')
          .width(45)
          .textAlign(TextAlign.End)
      }
      .width('100%')
      .padding({ left: 16, right: 16 })

      Row() {
        Button() {
          Text(this.getModeLabel(this.animationMode))
            .fontSize(12)
            .fontColor('#d4a574')
        }
        .height(32)
        .backgroundColor('rgba(212, 165, 116, 0.1)')
        .border({ width: 1, color: 'rgba(212, 165, 116, 0.3)' })
        .borderRadius(16)
        .padding({ left: 12, right: 12 })
        .onClick(() => {
          this.showModeSelector = !this.showModeSelector;
        })

        Blank()

        Button() {
          Text('⏮')
            .fontSize(18)
            .fontColor('#d4a574')
        }
        .width(40)
        .height(40)
        .backgroundColor('transparent')
        .onClick(() => {
          this.stopAnimation();
          this.currentTime = 0;
          this.startAnimation();
        })

        Button() {
          Text(this.isPlaying ? '⏸' : '▶')
            .fontSize(22)
            .fontColor('#FFFFFF')
        }
        .width(48)
        .height(48)
        .backgroundColor('#722ED1')
        .borderRadius(24)
        .onClick(() => {
          if (this.isPlaying) {
            this.stopAnimation();
          } else {
            if (this.currentTime === 0 || this.currentTime >= this.totalDuration) {
              this.startAnimation();
            } else {
              this.isPlaying = true;
              this.lastFrameTime = Date.now();
              this.runFrame();
            }
          }
        })

        Button() {
          Text('⏭')
            .fontSize(18)
            .fontColor('#d4a574')
        }
        .width(40)
        .height(40)
        .backgroundColor('transparent')
        .onClick(() => {
          this.stopAnimation();
          this.showEndingCard = true;
          this.endingOpacity = 1;
          this.currentTime = this.totalDuration;
        })

        Blank()

        Row() {
          Text('🎵')
            .fontSize(14)

          Slider({
            value: this.bpmValue,
            min: 40,
            max: 120,
            step: 10,
            style: SliderStyle.InSet
          })
            .width(80)
            .height(32)
            .trackColor('rgba(114, 46, 209, 0.2)')
            .selectedColor('#722ED1')
            .onChange((value: number) => {
              this.bpmValue = value;
              this.musicSync.setBPM(value);
            })
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .padding({ top: 8, bottom: 12 })
    .backgroundColor('rgba(10, 10, 26, 0.9)')
  }

  @Builder
  buildModeSelector() {
    Column() {
      Column() {
        Text('选择动画模式')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#d4a574')
          .margin({ bottom: 16 })

        this.buildModeOption('kenBurns', '🎬 推拉摇移', 'Ken Burns式缓慢推拉摇移，纪录片风格')
        this.buildModeOption('scrollUnroll', '📜 画卷展开', '古画卷缓缓展开，墨迹粒子飘散')
        this.buildModeOption('fullShow', '✨ 完整演绎', '画卷展开+推拉摇移+粒子+配乐同步')
      }
      .width('85%')
      .padding(20)
      .backgroundColor('#1a1a2e')
      .borderRadius(16)
      .border({ width: 1, color: 'rgba(212, 165, 116, 0.3)' })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('rgba(0, 0, 0, 0.7)')
    .onClick(() => {
      this.showModeSelector = false;
    })
  }

  @Builder
  buildModeOption(mode: AnimationMode, title: string, desc: string) {
    Row() {
      Column() {
        Text(title)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.animationMode === mode ? '#d4a574' : '#cccccc')

        Text(desc)
          .fontSize(12)
          .fontColor('#8c7b6b')
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      if (this.animationMode === mode) {
        Text('✓')
          .fontSize(18)
          .fontColor('#722ED1')
      }
    }
    .width('100%')
    .padding(12)
    .borderRadius(8)
    .backgroundColor(this.animationMode === mode ? 'rgba(114, 46, 209, 0.15)' : 'transparent')
    .border({
      width: 1,
      color: this.animationMode === mode ? '#722ED1' : 'rgba(212, 165, 116, 0.15)'
    })
    .margin({ bottom: 8 })
    .onClick(() => {
      this.animationMode = mode;
      this.showModeSelector = false;
      this.stopAnimation();
      this.currentTime = 0;
    })
  }

  private buildSepiaFilter(): number[] {
    const s: number = this.filterSepia;
    const c: number = this.filterContrast;

    return [
      (1 - s) * c + s * 0.393, s * 0.769, s * 0.189, 0, s * 5,
      s * 0.349, (1 - s) * c + s * 0.686, s * 0.168, 0, s * 2,
      s * 0.272, s * 0.534, (1 - s) * c + s * 0.131, 0, 0,
      0, 0, 0, 1, 0
    ];
  }
}