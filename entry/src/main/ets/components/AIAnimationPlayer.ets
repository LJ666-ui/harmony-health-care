import { router } from '@kit.ArkUI';

export interface AIAnimationPlayerProps {
  originalUrl: string;
  restoreUrl: string;
  animationUrl: string;
  title: string;
  desc: string;
  onClose: () => void;
}

@Component
export struct AIAnimationPlayer {
  @Prop originalUrl: string = '';
  @Prop restoreUrl: string = '';
  @Prop animationUrl: string = '';
  @Prop title: string = '';
  @Prop desc: string = '';
  @Prop onClose: () => void = () => {};

  @State isPlaying: boolean = false;
  @State currentTime: number = 0;
  @State duration: number = 15;
  @State playbackSpeed: number = 1.0;
  @State showOriginal: boolean = false;
  @State animationMode: string = 'cinematic';
  @State selectedEffect: string = 'inkFlow';
  @State volume: number = 80;

  private playTimer: number = -1;

  aboutToAppear(): void {
    this.duration = this.calculateDuration();
  }

  aboutToDisappear(): void {
    this.stopPlayback();
  }

  calculateDuration(): number {
    if (this.desc && this.desc.length > 20) {
      return Math.min(30, Math.max(10, this.desc.length / 3));
    }
    return 15;
  }

  togglePlay(): void {
    if (this.isPlaying) {
      this.pausePlayback();
    } else {
      this.startPlayback();
    }
  }

  startPlayback(): void {
    this.isPlaying = true;
    if (this.playTimer === -1) {
      this.playTimer = setInterval(() => {
        if (this.currentTime < this.duration) {
          this.currentTime += 0.1 * this.playbackSpeed;
          if (this.currentTime >= this.duration) {
            this.currentTime = this.duration;
            this.pausePlayback();
          }
        }
      }, 100);
    }
  }

  pausePlayback(): void {
    this.isPlaying = false;
    if (this.playTimer !== -1) {
      clearInterval(this.playTimer);
      this.playTimer = -1;
    }
  }

  stopPlayback(): void {
    this.pausePlayback();
    this.currentTime = 0;
  }

  seekTo(time: number): void {
    this.currentTime = Math.max(0, Math.min(time, this.duration));
  }

  changeSpeed(speed: number): void {
    this.playbackSpeed = speed;
  }

  formatTime(seconds: number): string {
    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  }

  getProgressPercent(): number {
    if (this.duration === 0) return 0;
    return (this.currentTime / this.duration) * 100;
  }

  build() {
    Stack() {
      Column() {

        Row() {
          Text('🎬 AI动画播放器')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .layoutWeight(1);

          Button(this.showOriginal ? '查看复原图' : '查看原图')
            .height(28)
            .fontSize(12)
            .fontColor('#722ED1')
            .backgroundColor('#F9F0FF')
            .borderRadius(14)
            .onClick(() => {
              this.showOriginal = !this.showOriginal;
            });

          Text('✕')
            .fontSize(24)
            .fontColor('#999999')
            .margin({ left: 12 })
            .onClick(() => {
              this.onClose();
            });
        }
        .width('100%')
        .padding(16);

        Scroll() {
          Column({ space: 16 }) {

            Stack({ alignContent: Alignment.Bottom }) {
              Column()
                .width('100%')
                .height(280)
                .borderRadius(16)
                .linearGradient({
                  angle: 135,
                  colors: this.showOriginal
                    ? [['#FFF7F7', 0], ['#FFE4E1', 1]]
                    : [['#E6F7FF', 0], ['#BAE7FF', 1]]
                })
                .justifyContent(FlexAlign.Center)
                .shadow({ radius: 16, color: '#00000025', offsetX: 0, offsetY: 6 });

              if (!this.isPlaying) {
                Column()
                  .width(70)
                  .height(70)
                  .borderRadius(35)
                  .backgroundColor('#FFFFFF90')
                  .shadow({ radius: 12, color: '#00000040', offsetX: 0, offsetY: 4 })
                  .justifyContent(FlexAlign.Center)
                  .onClick(() => this.togglePlay());

                Text('▶️')
                  .fontSize(28)
                  .position({ x: 22, y: 21 });
              }

              Column() {
                Row() {
                  Text(this.formatTime(this.currentTime))
                    .fontSize(11)
                    .fontColor('#FFFFFF');

                  Slider({
                    value: this.getProgressPercent(),
                    min: 0,
                    max: 100,
                    step: 1,
                    style: SliderStyle.OutSet
                  })
                    .layoutWeight(1)
                    .blockColor('#FFFFFF')
                    .trackColor('#FFFFFF50')
                    .selectedColor('#FFFFFF')
                    .width('100%')
                    .onChange((value: number) => {
                      this.seekTo((value / 100) * this.duration);
                    });

                  Text(this.formatTime(this.duration))
                    .fontSize(11)
                    .fontColor('#FFFFFF');
                }
                .width('100%')
                .padding(12);
              }
              .width('100%')
              .linearGradient({
                angle: 180,
                colors: [['#00000000', 0], ['#00000080', 1]]
              })
              .borderRadius({ bottomLeft: 16, bottomRight: 16 });
            }
            .width('100%');

            Column({ space: 12 }) {
              Text('🎭 动画效果选择')
                .fontSize(15)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .width('100%');

              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach([
                  { key: 'inkFlow', name: '🌊 墨水流淌', desc: '水墨画流动效果' },
                  { key: 'breathe', name: '💫 呼吸动画', desc: '人物呼吸感' },
                  { key: 'particle', name: '✨ 粒子飘散', desc: '古风粒子特效' },
                  { key: 'cinematic', name: '🎥 电影镜头', desc: '电影级运镜' },
                  { key: 'scrollUnfold', name: '📜 卷轴展开', desc: '古画卷展开动画' },
                  { key: 'inkSplash', name: '🎨 墨迹晕染', desc: '墨迹扩散效果' }
                ], (effect: Record<string, Object>) => {
                  Column({ space: 4 }) {
                    Text(effect['name'] as string)
                      .fontSize(12)
                      .fontColor(this.selectedEffect === effect['key'] ? '#FFFFFF' : '#333333')
                      .fontWeight(this.selectedEffect === effect['key'] ? FontWeight.Medium : FontWeight.Normal);

                    Text(effect['desc'] as string)
                      .fontSize(10)
                      .fontColor(this.selectedEffect === effect['key'] ? '#FFFFFF90' : '#999999');
                  }
                  .backgroundColor(this.selectedEffect === effect['key'] ? '#722ED1' : '#F5F5F5')
                  .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                  .borderRadius(12)
                  .margin(6)
                  .onClick(() => {
                    this.selectedEffect = effect['key'];
                  });
                }, (effect: Record<string, Object>) => effect['key'] as string);
              }
              .width('100%');
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FAFBFC')
            .borderRadius(12);

            Row({ space: 8 }) {
              Button('⏮️')
                .width(44)
                .height(36)
                .fontSize(16)
                .fontColor('#666666')
                .backgroundColor('#F5F5F5')
                .borderRadius(8)
                .onClick(() => {
                  this.seekTo(0);
                  if (!this.isPlaying) this.togglePlay();
                });

              Button(this.isPlaying ? '⏸️ 暂停' : '▶️ 播放')
                .layoutWeight(2)
                .height(40)
                .fontSize(14)
                .fontColor('#FFFFFF')
                .backgroundColor('#722ED1')
                .borderRadius(20)
                .onClick(() => this.togglePlay());

              Button('⏹️ 停止')
                .layoutWeight(1)
                .height(40)
                .fontSize(13)
                .fontColor('#666666')
                .backgroundColor('#F5F5F5')
                .borderRadius(20)
                .onClick(() => this.stopPlayback());

              Button('⏭️')
                .width(44)
                .height(36)
                .fontSize(16)
                .fontColor('#666666')
                .backgroundColor('#F5F5F5')
                .borderRadius(8)
                .onClick(() => {
                  this.seekTo(this.duration);
                  this.pausePlayback();
                });
            }
            .width('100%')
            .padding({ left: 16, right: 16 });

            Column({ space: 10 }) {
              Text('⚡ 播放速度')
                .fontSize(13)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
                .width('100%');

              Row({ space: 8 }) {
                ForEach([0.5, 0.75, 1.0, 1.25, 1.5, 2.0], (speed: number) => {
                  Text(speed + 'x')
                    .fontSize(12)
                    .fontColor(this.playbackSpeed === speed ? '#FFFFFF' : '#666666')
                    .backgroundColor(this.playbackSpeed === speed ? '#722ED1' : '#F5F5F5')
                    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                    .borderRadius(14)
                    .onClick(() => this.changeSpeed(speed));
                }, (speed: number) => speed.toString());
              }
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FAFBFC')
            .borderRadius(12);

            Column({ space: 12 }) {
              Text('📝 动画信息')
                .fontSize(15)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .width('100%');

              Column({ space: 8 }) {
                this.buildInfoRow('🎬 标题', this.title);
                this.buildInfoRow('🎨 效果模式', this.getEffectName());
                this.buildInfoRow('⏱️ 时长', this.duration.toFixed(1) + '秒');
                this.buildInfoRow('🤖 AI引擎', 'HiAI Animation Engine');
                this.buildInfoRow('📊 分辨率', '1080P HD');
              }
              .width('100%')
              .padding(14)
              .backgroundColor('#F7F8FA')
              .borderRadius(12);

              if (this.desc) {
                Text(this.desc)
                  .fontSize(13)
                  .fontColor('#666666')
                  .lineHeight(20)
                  .width('100%')
                  .padding(14)
                  .backgroundColor('#FFFBF0')
                  .borderRadius(12)
                  .border({ width: 1, color: '#FFE58F' });
              }
            }
            .width('100%')
            .padding({ left: 16, right: 16 });

            Row({ space: 12 }) {
              Button('💾 保存动画')
                .layoutWeight(1)
                .height(42)
                .fontSize(14)
                .fontColor('#FFFFFF')
                .backgroundColor('#52C41A')
                .borderRadius(21)
                .onClick(() => {
                  console.info('保存AI动画');
                });

              Button('📤 分享')
                .layoutWeight(1)
                .height(42)
                .fontSize(14)
                .fontColor('#FFFFFF')
                .backgroundColor('#1677FF')
                .borderRadius(21)
                .onClick(() => {
                  console.info('分享动画');
                });

              Button('🔄 重新生成')
                .layoutWeight(1)
                .height(42)
                .fontSize(14)
                .fontColor('#722ED1')
                .backgroundColor('#F9F0FF')
                .borderRadius(21)
                .onClick(() => {
                  console.info('重新生成动画');
                });
            }
            .width('100%')
            .padding({ left: 16, right: 16, bottom: 32 });
          }
        }
        .scrollBar(BarState.Off)
        .width('100%')
        .layoutWeight(1);
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#FAFBFC');
    }
    .width('100%')
    .height('100%');
  }

  getEffectName(): string {
    const effectMap: Record<string, string> = {
      'inkFlow': '🌊 墨水流淌',
      'breathe': '💫 呼吸动画',
      'particle': '✨ 粒子飘散',
      'cinematic': '🎥 电影镜头',
      'scrollUnfold': '📜 卷轴展开',
      'inkSplash': '🎨 墨迹晕染'
    };
    return effectMap[this.selectedEffect] || this.selectedEffect;
  }

  @Builder
  buildInfoRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(13)
        .fontColor('#666666')
        .width(90);

      Text(value)
        .fontSize(13)
        .fontColor('#333333')
        .fontWeight(FontWeight.Medium)
        .layoutWeight(1)
        .textAlign(TextAlign.End);
    }
    .width('100%');
  }
}
