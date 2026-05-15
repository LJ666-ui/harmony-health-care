import { router } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { DeviceTypeUtil } from '../utils/DeviceTypeUtil';
import { AIOrchestrator } from '../ai/orchestrator/AIOrchestrator';

interface ChatMessage {
  id: string;
  role: 'user' | 'ai';
  content: string;
  timestamp: number;
}

interface QuickSymptom {
  id: string;
  label: string;
  icon: string;
}

const TAG = 'WatchAIConsultPage';

@Entry
@Component
struct WatchAIConsultPage {
  @State symptomsInput: string = '';
  @State isLoading: boolean = false;
  @State chatMessages: ChatMessage[] = [];
  @State showResult: boolean = false;
  @State aiResult: string = '';
  @State suggestedDept: string = '';
  @State triageAdvice: string = '';
  private deviceUtil: DeviceTypeUtil = DeviceTypeUtil.getInstance();
  private orchestrator: AIOrchestrator = AIOrchestrator.getInstance();

  quickSymptoms: QuickSymptom[] = [
    { id: 'headache', label: '头痛', icon: '🤕' },
    { id: 'fever', label: '发热', icon: '🌡️' },
    { id: 'cough', label: '咳嗽', icon: '🤧' },
    { id: 'stomach', label: '胃痛', icon: '🤢' },
    { id: 'dizzy', label: '头晕', icon: '😵' },
    { id: 'fatigue', label: '疲劳', icon: '😴' }
  ];

  aboutToAppear(): void {
    this.chatMessages.push({
      id: 'welcome',
      role: 'ai',
      content: '您好！我是AI健康助手，请描述您的症状或点击快捷症状。',
      timestamp: Date.now()
    });
  }

  async sendToAI(): Promise<void> {
    const query = this.symptomsInput.trim();
    if (!query && !this.showResult) {
      return;
    }
    if (this.isLoading) {
      return;
    }

    this.chatMessages.push({
      id: Date.now().toString(),
      role: 'user',
      content: query,
      timestamp: Date.now()
    });

    this.symptomsInput = '';
    this.isLoading = true;
    this.showResult = false;

    try {
      const response = await this.orchestrator.process({
        requestId: Date.now().toString(),
        userId: AppStorage.get('userId')?.toString() || '0',
        input: {
          type: 'text',
          content: `症状描述：${query}，请进行智能预问诊分析，包括：1)可能原因 2)建议科室 3)注意事项。回答请简洁精炼，适合手表屏幕阅读（控制在200字以内）。`
        }
      });

      const content = response.output.content as string;
      this.aiResult = content;

      this.chatMessages.push({
        id: (Date.now() + 1).toString(),
        role: 'ai',
        content: content,
        timestamp: Date.now()
      });

      this.suggestedDept = response.suggestions?.[0] || '';
      this.triageAdvice = response.suggestions?.[1] || '';
      this.showResult = true;
    } catch (error) {
      hilog.error(0x0000, TAG, 'AI问诊失败 %{public}s', String(error));
      this.chatMessages.push({
        id: (Date.now() + 1).toString(),
        role: 'ai',
        content: '抱歉，AI服务暂时不可用，请稍后重试或前往医院就诊。',
        timestamp: Date.now()
      });
    } finally {
      this.isLoading = false;
    }
  }

  selectQuickSymptom(symptom: QuickSymptom): void {
    this.symptomsInput = symptom.label;
    this.sendToAI();
  }

  build() {
    Column() {
      Row() {
        Text('←')
          .fontSize(this.deviceUtil.getAdaptiveFontSize(20))
          .fontColor('#FFFFFF')
          .onClick(() => {
            router.back();
          })

        Text('AI 智能问诊')
          .fontSize(this.deviceUtil.getAdaptiveFontSize(16))
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Text(' ')
          .fontSize(this.deviceUtil.getAdaptiveFontSize(20))
      }
      .width('100%')
      .height(this.deviceUtil.getAdaptiveSpacing(50))
      .padding({ left: 12, right: 12 })
      .linearGradient({
        angle: 135,
        colors: [['#6366F1', 0], ['#4F46E5', 1]]
      })

      if (this.isLoading) {
        Column() {
          Text('🤖')
            .fontSize(40)
          Text('AI正在分析中...')
            .fontSize(this.deviceUtil.getAdaptiveFontSize(14))
            .fontColor('#666666')
            .margin({ top: 12 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: this.deviceUtil.getAdaptiveSpacing(10) }) {
            this.buildChatArea()

            if (!this.showResult) {
              this.buildQuickSymptoms()
            }

            if (this.showResult) {
              this.buildResultCard()
            }
          }
          .width('95%')
          .padding({ top: 8, bottom: 8 })
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }

      this.buildInputBar()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8FAFC')
  }

  @Builder buildChatArea() {
    Column({ space: 6 }) {
      ForEach(this.chatMessages.slice(-6), (msg: ChatMessage) => {
        Row() {
          if (msg.role === 'ai') {
            Column() {
              Text('🤖')
                .fontSize(16)
              Text(msg.content)
                .fontSize(this.deviceUtil.getAdaptiveFontSize(12))
                .fontColor('#333333')
                .lineHeight(18)
                .margin({ left: 6 })
                .maxLines(6)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
            .padding(this.deviceUtil.getAdaptiveSpacing(10))
            .backgroundColor('#EEF2FF')
            .borderRadius(this.deviceUtil.getAdaptiveSpacing(12))
          } else {
            Blank()
            Column() {
              Text(msg.content)
                .fontSize(this.deviceUtil.getAdaptiveFontSize(12))
                .fontColor('#FFFFFF')
                .lineHeight(18)
                .maxLines(3)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .alignItems(HorizontalAlign.End)
            .padding(this.deviceUtil.getAdaptiveSpacing(10))
            .backgroundColor('#6366F1')
            .borderRadius(this.deviceUtil.getAdaptiveSpacing(12))
          }
        }
        .width('100%')
      }, (msg: ChatMessage) => msg.id)
    }
    .width('100%')
  }

  @Builder buildQuickSymptoms() {
    Column() {
      Text('快捷症状')
        .fontSize(this.deviceUtil.getAdaptiveFontSize(13))
        .fontColor('#666666')
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 6 })

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.quickSymptoms, (symptom: QuickSymptom) => {
          Text(`${symptom.icon} ${symptom.label}`)
            .fontSize(this.deviceUtil.getAdaptiveFontSize(12))
            .fontColor('#4F46E5')
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .backgroundColor('#EEF2FF')
            .borderRadius(16)
            .margin(3)
            .onClick(() => {
              this.selectQuickSymptom(symptom);
            })
        }, (symptom: QuickSymptom) => symptom.id)
      }
      .width('100%')
    }
    .width('100%')
    .padding(this.deviceUtil.getAdaptiveSpacing(10))
    .backgroundColor('#FFFFFF')
    .borderRadius(this.deviceUtil.getAdaptiveSpacing(12))
  }

  @Builder buildResultCard() {
    Column({ space: 8 }) {
      Row() {
        Text('✅ AI 分析结果')
          .fontSize(this.deviceUtil.getAdaptiveFontSize(14))
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .padding(this.deviceUtil.getAdaptiveSpacing(10))
      .linearGradient({
        angle: 135,
        colors: [['#10B981', 0], ['#059669', 1]]
      })
      .borderRadius({ topLeft: 10, topRight: 10 })

      Text(this.aiResult)
        .fontSize(this.deviceUtil.getAdaptiveFontSize(12))
        .fontColor('#374151')
        .lineHeight(18)

      if (this.suggestedDept) {
        Row() {
          Text('🏥 建议科室:')
            .fontSize(this.deviceUtil.getAdaptiveFontSize(11))
            .fontColor('#666666')
          Text(this.suggestedDept)
            .fontSize(this.deviceUtil.getAdaptiveFontSize(12))
            .fontColor('#6366F1')
            .fontWeight(FontWeight.Bold)
            .margin({ left: 6 })
        }
        .width('100%')
        .margin({ top: 4 })
      }

      Row() {
        Button('继续问诊')
          .height(this.deviceUtil.getAdaptiveButtonHeight(32))
          .fontSize(this.deviceUtil.getAdaptiveFontSize(12))
          .backgroundColor('#6366F1')
          .layoutWeight(1)
          .onClick(() => {
            this.showResult = false;
            this.aiResult = '';
          })

        Button('返回首页')
          .height(this.deviceUtil.getAdaptiveButtonHeight(32))
          .fontSize(this.deviceUtil.getAdaptiveFontSize(12))
          .backgroundColor('#E5E7EB')
          .fontColor('#374151')
          .layoutWeight(1)
          .margin({ left: 8 })
          .onClick(() => {
            router.back();
          })
      }
      .width('100%')
      .margin({ top: 8 })
    }
    .width('100%')
    .padding(this.deviceUtil.getAdaptiveSpacing(12))
    .backgroundColor('#FFFFFF')
    .borderRadius(this.deviceUtil.getAdaptiveSpacing(12))
    .shadow({ radius: 4, color: 'rgba(0,0,0,0.06)', offsetX: 0, offsetY: 2 })
  }

  @Builder buildInputBar() {
    Row() {
      TextInput({ placeholder: '输入症状...', text: this.symptomsInput })
        .layoutWeight(1)
        .height(this.deviceUtil.getAdaptiveButtonHeight(36))
        .fontSize(this.deviceUtil.getAdaptiveFontSize(13))
        .backgroundColor('#FFFFFF')
        .borderRadius(18)
        .padding({ left: 14 })
        .onChange((value: string) => {
          this.symptomsInput = value;
        })
        .onSubmit(() => {
          this.sendToAI();
        })

      Text('发送')
        .fontSize(this.deviceUtil.getAdaptiveFontSize(14))
        .fontColor('#FFFFFF')
        .fontWeight(FontWeight.Bold)
        .width(this.deviceUtil.getAdaptiveSpacing(56))
        .height(this.deviceUtil.getAdaptiveButtonHeight(36))
        .textAlign(TextAlign.Center)
        .backgroundColor('#6366F1')
        .borderRadius(18)
        .onClick(() => {
          this.sendToAI();
        })
    }
    .width('95%')
    .padding({ bottom: 8 })
  }
}
