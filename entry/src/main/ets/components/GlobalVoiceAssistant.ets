import { router } from '@kit.ArkUI';
import { VoiceIntentService, VoiceIntent } from '../services/VoiceIntentService';
import { ToastUtil } from '../common/utils/ToastUtil';

@Component
export struct GlobalVoiceAssistant {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @StorageLink('showGlobalAssistant') @Watch('onVisibilityChanged') showAssistant: boolean = false;
  @State isExpanded: boolean = false;
  @State isRecording: boolean = false;
  @State isLoading: boolean = false;
  @State inputText: string = '';
  @State recognizedText: string = '';
  @State replyText: string = '';
  @State pulseScale: number = 1.0;
  @State fabOffsetX: number = 0;
  @State fabOffsetY: number = 0;

  private intentService: VoiceIntentService = VoiceIntentService.getInstance();
  private pulseTimerId: number = -1;
  private recordTimerId: number = -1;

  onVisibilityChanged(): void {
    if (!this.showAssistant) {
      this.isExpanded = false;
      this.isRecording = false;
      this.isLoading = false;
      this.stopPulse();
    }
  }

  aboutToDisappear(): void {
    this.stopPulse();
    if (this.recordTimerId !== -1) {
      clearTimeout(this.recordTimerId);
    }
  }

  private startPulse(): void {
    this.stopPulse();
    this.pulseScale = 1.15;
    this.pulseTimerId = setInterval(() => {
      this.pulseScale = this.pulseScale > 1.05 ? 1.0 : 1.15;
    }, 600);
  }

  private stopPulse(): void {
    if (this.pulseTimerId !== -1) {
      clearInterval(this.pulseTimerId);
      this.pulseTimerId = -1;
    }
    this.pulseScale = 1.0;
  }

  private toggleExpand(): void {
    if (!this.isExpanded) {
      this.isExpanded = true;
      this.replyText = '';
      this.inputText = '';
      this.recognizedText = '';
    } else {
      this.isExpanded = false;
      this.isRecording = false;
      this.stopPulse();
    }
  }

  private startRecording(): void {
    if (this.isLoading) return;
    this.isRecording = true;
    this.recognizedText = '';
    this.replyText = '';
    this.startPulse();
    this.simulateRecognition();
  }

  private stopRecording(): void {
    if (!this.isRecording) return;
    this.isRecording = false;
    this.stopPulse();

    if (this.recognizedText.trim()) {
      this.processInput(this.recognizedText.trim());
    }
  }

  private simulateRecognition(): void {
    const phrases: string[] = [
      '打开健康记录',
      '查看风险评估',
      '我要挂号',
      '血压高怎么办',
      '打开用药提醒',
      '查找附近医院',
      '导航到内科',
      '打开康复训练'
    ];
    const phrase = phrases[Math.floor(Math.random() * phrases.length)];
    let display = '';

    for (let i = 0; i < phrase.length; i++) {
      const idx = i;
      setTimeout(() => {
        display += phrase[idx];
        this.recognizedText = display;
        if (idx === phrase.length - 1) {
          setTimeout(() => this.stopRecording(), 400);
        }
      }, 120 * (i + 1));
    }
  }

  private async processInput(text: string): Promise<void> {
    this.isLoading = true;
    this.replyText = '正在思考...';

    try {
      const intent: VoiceIntent = await this.intentService.parseIntent(text);

      if (intent.type === 'navigate' && intent.targetPage) {
        this.replyText = intent.reply;
        setTimeout(async () => {
          await this.intentService.executeIntent(intent);
          this.isExpanded = false;
        }, 800);
      } else if (intent.type === 'action') {
        this.replyText = intent.reply;
        await this.intentService.executeIntent(intent);
      } else {
        this.replyText = intent.reply;
      }
    } catch (error) {
      this.replyText = '抱歉，处理失败，请重试';
    } finally {
      this.isLoading = false;
    }
  }

  private sendTextInput(): void {
    if (!this.inputText.trim() || this.isLoading) return;
    const text = this.inputText.trim();
    this.inputText = '';
    this.processInput(text);
  }

  private openFullAssistant(): void {
    this.isExpanded = false;
    this.showAssistant = false;
    router.pushUrl({ url: 'pages/VoiceAssistantPage' });
  }

  build() {
    Column() {
      if (this.isExpanded) {
        this.ExpandedPanel()
      }

      this.FloatingButton()
    }
    .width('100%')
    .height('100%')
    .hitTestBehavior(HitTestMode.None)
  }

  @Builder
  FloatingButton() {
    Stack() {
      if (this.isRecording) {
        Circle()
          .width(64)
          .height(64)
          .fill('#1677FF22')
          .scale({ x: this.pulseScale, y: this.pulseScale })
          .animation({ duration: 600, curve: Curve.EaseInOut })
      }

      Circle()
        .width(52)
        .height(52)
        .fill(this.isRecording ? '#F5222D' : '#1677FF')
        .shadow({
          radius: 12,
          color: this.isRecording ? '#F5222D44' : '#1677FF44',
          offsetX: 0,
          offsetY: 4
        })

      Text(this.isRecording ? '🎤' : '🎙️')
        .fontSize(24)
        .fontColor('#FFFFFF')
    }
    .width(64)
    .height(64)
    .position({ x: '78%', y: '82%' })
    .onClick(() => this.toggleExpand())
  }

  @Builder
  ExpandedPanel() {
    Column() {
      Row() {
        Text('🎙️ 语音助手')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1E293B')

        Blank()

        Text('展开')
          .fontSize(12)
          .fontColor('#1677FF')
          .margin({ right: 12 })
          .onClick(() => this.openFullAssistant())

        Text('✕')
          .fontSize(18)
          .fontColor('#94A3B8')
          .onClick(() => {
            this.isExpanded = false;
            this.isRecording = false;
            this.stopPulse();
          })
      }
      .width('100%')
      .padding({ left: 16, right: 12, top: 12, bottom: 8 })

      if (this.recognizedText || this.replyText) {
        Scroll() {
          Column({ space: 8 }) {
            if (this.recognizedText) {
              Row() {
                Text('👤')
                  .fontSize(14)
                  .margin({ right: 6 })
                Text(this.recognizedText)
                  .fontSize(14)
                  .fontColor('#1E293B')
                  .layoutWeight(1)
              }
              .width('100%')
              .padding(10)
              .backgroundColor('#F0F5FF')
              .borderRadius(10)
              .alignItems(VerticalAlign.Top)
            }

            if (this.replyText) {
              Row() {
                Text('🤖')
                  .fontSize(14)
                  .margin({ right: 6 })
                Text(this.replyText)
                  .fontSize(14)
                  .fontColor('#475569')
                  .layoutWeight(1)
              }
              .width('100%')
              .padding(10)
              .backgroundColor('#F8FAFC')
              .borderRadius(10)
              .alignItems(VerticalAlign.Top)
            }
          }
          .width('100%')
        }
        .width('100%')
        .height(120)
        .padding({ left: 16, right: 16 })
      } else {
        Column() {
          Text('试试说：')
            .fontSize(12)
            .fontColor('#94A3B8')
            .margin({ bottom: 8 })

          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
            ForEach(['打开健康记录', '我要挂号', '查看风险评估', '用药提醒', '附近医院', '康复训练'], (item: string) => {
              Text(item)
                .fontSize(12)
                .fontColor('#1677FF')
                .padding({ left: 10, right: 10, top: 5, bottom: 5 })
                .backgroundColor('#F0F5FF')
                .borderRadius(14)
                .margin({ right: 6, bottom: 6 })
                .onClick(() => {
                  this.recognizedText = item;
                  this.processInput(item);
                })
            })
          }
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 4, bottom: 8 })
      }

      Row() {
        TextInput({ placeholder: '输入指令或问题...', text: this.inputText })
          .type(InputType.Normal)
          .layoutWeight(1)
          .height(40)
          .fontSize(14)
          .backgroundColor('#F1F5F9')
          .borderRadius(20)
          .padding({ left: 16, right: 16 })
          .onChange((value: string) => {
            this.inputText = value;
          })
          .onSubmit(() => this.sendTextInput())

        Stack() {
          Circle()
            .width(40)
            .height(40)
            .fill(this.isRecording ? '#F5222D' : '#1677FF')

          if (this.isLoading) {
            LoadingProgress()
              .width(20)
              .height(20)
              .color('#FFFFFF')
          } else {
            Text(this.isRecording ? '⏹' : '🎤')
              .fontSize(18)
              .fontColor('#FFFFFF')
          }
        }
        .margin({ left: 8 })
        .onClick(() => {
          if (this.isLoading) return;
          if (this.isRecording) {
            this.stopRecording();
          } else {
            this.startRecording();
          }
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 8, bottom: 12 })
    }
    .width('92%')
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
    .shadow({
      radius: 24,
      color: '#0000001A',
      offsetX: 0,
      offsetY: 8
    })
    .position({ x: '4%', y: '58%' })
  }
}
