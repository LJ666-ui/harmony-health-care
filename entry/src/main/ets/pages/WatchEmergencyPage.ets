/**
 * 手环手表紧急呼叫页面
 * 提供一键紧急呼叫和急救指南功能
 */
import { router } from '@kit.ArkUI';
import { call } from '@kit.TelephonyKit';
import { DeviceTypeUtil } from '../utils/DeviceTypeUtil';
import { AIOrchestrator } from '../ai/orchestrator/AIOrchestrator';

interface EmergencyContact {
  id: string;
  name: string;
  phone: string;
  relation: string;
  icon: string;
}

@Entry
@Component
struct WatchEmergencyPage {
  @State isSOSActive: boolean = false;
  @State sosCountDown: number = 5;
  @State emergencyContacts: EmergencyContact[] = [];
  @State aiEmergencyAnalysis: string = '';
  @State aiFirstAidGuide: string = '';
  @State aiTriageAdvice: string = '';
  private deviceUtil: DeviceTypeUtil = DeviceTypeUtil.getInstance();
  private sosTimer: number = -1;
  private orchestrator: AIOrchestrator = AIOrchestrator.getInstance();

  aboutToAppear(): void {
    this.loadEmergencyContacts();
  }

  aboutToDisappear(): void {
    if (this.sosTimer !== -1) {
      clearInterval(this.sosTimer);
    }
  }

  loadEmergencyContacts(): void {
    // 从AppStorage加载紧急联系人
    const stored = AppStorage.get<EmergencyContact[]>('emergencyContacts');
    if (stored && stored.length > 0) {
      this.emergencyContacts = stored;
    } else {
      // 默认紧急联系人
      this.emergencyContacts = [
        { id: '1', name: '急救中心', phone: '120', relation: '急救', icon: '🚑' },
        { id: '2', name: '报警', phone: '110', relation: '报警', icon: '🚔' },
        { id: '3', name: '家人', phone: '13800138000', relation: '家人', icon: '👨‍👩‍👧' }
      ];
    }
  }

  startSOS(): void {
    this.isSOSActive = true;
    this.sosCountDown = 5;

    this.sosTimer = setInterval(() => {
      this.sosCountDown--;
      if (this.sosCountDown <= 0) {
        clearInterval(this.sosTimer);
        this.executeSOS();
      }
    }, 1000);
  }

  cancelSOS(): void {
    if (this.sosTimer !== -1) {
      clearInterval(this.sosTimer);
    }
    this.isSOSActive = false;
    this.sosCountDown = 5;
  }

  executeSOS(): void {
    // 执行紧急呼叫
    this.isSOSActive = false;
    // 呼叫第一个紧急联系人（通常是急救中心）
    if (this.emergencyContacts.length > 0) {
      this.makeCall(this.emergencyContacts[0].phone);
    }
  }

  makeCall(phoneNumber: string): void {
    // 发起电话呼叫
    call.makeCall(phoneNumber, (err) => {
      if (err) {
        console.error('[WatchEmergencyPage] 呼叫失败:', err.message);
      }
    });
  }

  async analyzeEmergencyWithAI(emergencyType: string): Promise<void> {
    try {
      const response = await this.orchestrator.process({
        requestId: Date.now().toString(),
        userId: AppStorage.get('userId')?.toString() || '0',
        input: {
          type: 'text',
          content: `用户触发${emergencyType}紧急情况，请分析可能的危险程度和需要的救援措施`
        }
      });
      this.aiEmergencyAnalysis = response.output.content as string;
    } catch (error) {
      console.error('[WatchEmergencyPage] AI紧急分析失败:', error);
      this.aiEmergencyAnalysis = 'AI分析暂时不可用';
    }
  }

  async getFirstAidGuideFromAI(): Promise<void> {
    try {
      const response = await this.orchestrator.process({
        requestId: Date.now().toString(),
        userId: AppStorage.get('userId')?.toString() || '0',
        input: {
          type: 'text',
          content: '请提供紧急情况下的急救指导步骤'
        }
      });
      this.aiFirstAidGuide = response.output.content as string;
    } catch (error) {
      console.error('[WatchEmergencyPage] AI急救指导失败:', error);
      this.aiFirstAidGuide = '急救指导暂时不可用';
    }
  }

  async getTriageAdviceFromAI(symptoms: string): Promise<void> {
    try {
      const response = await this.orchestrator.process({
        requestId: Date.now().toString(),
        userId: AppStorage.get('userId')?.toString() || '0',
        input: {
          type: 'text',
          content: `患者症状：${symptoms}，请给出分诊建议和优先级`
        }
      });
      this.aiTriageAdvice = response.output.content as string;
    } catch (error) {
      console.error('[WatchEmergencyPage] AI分诊建议失败:', error);
      this.aiTriageAdvice = '分诊建议暂时不可用';
    }
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text('←')
          .fontSize(this.deviceUtil.getAdaptiveFontSize(20))
          .fontColor('#FFFFFF')
          .onClick(() => {
            router.back();
          })

        Text('紧急呼叫')
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
        colors: [['#E67E22', 0], ['#D35400', 1]]
      })

      // SOS按钮
      Column() {
        if (this.isSOSActive) {
          // 倒计时状态
          Column() {
            Text('SOS')
              .fontSize(this.deviceUtil.getAdaptiveFontSize(36))
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Bold)

            Text(`${this.sosCountDown}秒后呼叫`)
              .fontSize(this.deviceUtil.getAdaptiveFontSize(14))
              .fontColor('#FFFFFF')
              .margin({ top: 8 })

            Button('取消')
              .width('60%')
              .height(this.deviceUtil.getAdaptiveButtonHeight(36))
              .backgroundColor('#FFFFFF')
              .fontColor('#E67E22')
              .margin({ top: 16 })
              .onClick(() => {
                this.cancelSOS();
              })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
        } else {
          // 正常状态
          Column() {
            Text('🆘')
              .fontSize(this.deviceUtil.getAdaptiveFontSize(48))

            Text('SOS')
              .fontSize(this.deviceUtil.getAdaptiveFontSize(24))
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Bold)
              .margin({ top: 8 })

            Text('长按紧急呼叫')
              .fontSize(this.deviceUtil.getAdaptiveFontSize(12))
              .fontColor('#FFFFFF')
              .opacity(0.8)
              .margin({ top: 4 })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .gesture(
            LongPressGesture({ repeat: false })
              .onAction(() => {
                this.startSOS();
              })
          )
        }
      }
      .width('80%')
      .height(this.deviceUtil.getAdaptiveSpacing(150))
      .margin({ top: this.deviceUtil.getAdaptiveSpacing(20) })
      .linearGradient({
        angle: 135,
        colors: [['#E74C3C', 0], ['#C0392B', 1]]
      })
      .borderRadius(this.deviceUtil.getAdaptiveSpacing(75))
      .shadow({
        radius: 8,
        color: 'rgba(231, 76, 60, 0.4)',
        offsetX: 0,
        offsetY: 4
      })

      // 紧急联系人列表
      Column() {
        Text('紧急联系人')
          .fontSize(this.deviceUtil.getAdaptiveFontSize(14))
          .fontColor('#666666')
          .margin({ bottom: this.deviceUtil.getAdaptiveSpacing(8) })

        ForEach(this.emergencyContacts, (contact: EmergencyContact) => {
          this.buildContactItem(contact)
        }, (contact: EmergencyContact) => contact.id)
      }
      .width('95%')
      .margin({ top: this.deviceUtil.getAdaptiveSpacing(20) })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder buildContactItem(contact: EmergencyContact) {
    Row() {
      Text(contact.icon)
        .fontSize(this.deviceUtil.getAdaptiveFontSize(20))

      Column() {
        Text(contact.name)
          .fontSize(this.deviceUtil.getAdaptiveFontSize(14))
          .fontColor('#333333')
          .fontWeight(FontWeight.Bold)

        Text(contact.phone)
          .fontSize(this.deviceUtil.getAdaptiveFontSize(11))
          .fontColor('#999999')
          .margin({ top: 2 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 8 })

      Text('📞')
        .fontSize(this.deviceUtil.getAdaptiveFontSize(20))
    }
    .width('100%')
    .padding(this.deviceUtil.getAdaptiveSpacing(12))
    .backgroundColor('#FFFFFF')
    .borderRadius(this.deviceUtil.getAdaptiveSpacing(10))
    .margin({ bottom: this.deviceUtil.getAdaptiveSpacing(8) })
    .onClick(() => {
      this.makeCall(contact.phone);
    })
  }
}
