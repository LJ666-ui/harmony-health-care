/**
 * 手环手表用药提醒页面
 * 显示今日用药提醒列表，支持快速标记已服用
 */
import { router } from '@kit.ArkUI';
import { DeviceTypeUtil } from '../utils/DeviceTypeUtil';
import { AIOrchestrator } from '../ai/orchestrator/AIOrchestrator';

interface MedicationReminder {
  id: string;
  medicineName: string;
  dosage: string;
  time: string;
  isTaken: boolean;
  icon: string;
}

@Entry
@Component
struct WatchMedicationPage {
  @State reminders: MedicationReminder[] = [];
  @State showAddDialog: boolean = false;
  @State aiMedicationGuidance: string = '';
  @State aiDrugInfo: string = '';
  private deviceUtil: DeviceTypeUtil = DeviceTypeUtil.getInstance();
  private orchestrator: AIOrchestrator = AIOrchestrator.getInstance();

  aboutToAppear(): void {
    this.loadReminders();
  }

  loadReminders(): void {
    // 从AppStorage加载用药提醒
    const stored = AppStorage.get<MedicationReminder[]>('watchMedicationReminders');
    if (stored && stored.length > 0) {
      this.reminders = stored;
    } else {
      // 模拟数据
      this.reminders = [
        {
          id: '1',
          medicineName: '降压药',
          dosage: '1片',
          time: '08:00',
          isTaken: true,
          icon: '💊'
        },
        {
          id: '2',
          medicineName: '降糖药',
          dosage: '2片',
          time: '12:00',
          isTaken: false,
          icon: '💊'
        },
        {
          id: '3',
          medicineName: '维生素',
          dosage: '1粒',
          time: '20:00',
          isTaken: false,
          icon: '💊'
        }
      ];
      this.saveReminders();
    }
  }

  saveReminders(): void {
    AppStorage.setOrCreate<MedicationReminder[]>('watchMedicationReminders', this.reminders);
  }

  toggleMedicationTaken(reminderId: string): void {
    const reminder = this.reminders.find(r => r.id === reminderId);
    if (reminder) {
      reminder.isTaken = !reminder.isTaken;
      this.saveReminders();
    }
  }

  getNextReminder(): MedicationReminder | null {
    const now = new Date();
    const currentMinutes = now.getHours() * 60 + now.getMinutes();

    for (let i = 0; i < this.reminders.length; i++) {
      const reminder = this.reminders[i];
      if (!reminder.isTaken) {
        const timeParts = reminder.time.split(':');
        const hours = parseInt(timeParts[0]);
        const minutes = parseInt(timeParts[1]);
        const reminderMinutes = hours * 60 + minutes;
        if (reminderMinutes >= currentMinutes) {
          return reminder;
        }
      }
    }
    return null;
  }

  async getMedicationGuidanceFromAI(medicineName: string): Promise<void> {
    try {
      const response = await this.orchestrator.process({
        requestId: Date.now().toString(),
        userId: AppStorage.get('userId')?.toString() || '0',
        input: {
          type: 'text',
          content: `请给出${medicineName}的用药指导`
        }
      });
      this.aiMedicationGuidance = response.output.content as string;
    } catch (error) {
      console.error('[WatchMedicationPage] AI用药指导失败:', error);
      this.aiMedicationGuidance = '用药指导暂时不可用';
    }
  }

  async queryDrugInfoFromAI(drugName: string): Promise<void> {
    try {
      const response = await this.orchestrator.process({
        requestId: Date.now().toString(),
        userId: AppStorage.get('userId')?.toString() || '0',
        input: {
          type: 'text',
          content: `查询${drugName}的药物信息、作用和副作用`
        }
      });
      this.aiDrugInfo = response.output.content as string;
    } catch (error) {
      console.error('[WatchMedicationPage] AI药物信息查询失败:', error);
      this.aiDrugInfo = '药物信息暂时不可用';
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

        Text('用药提醒')
          .fontSize(this.deviceUtil.getAdaptiveFontSize(16))
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Text('+')
          .fontSize(this.deviceUtil.getAdaptiveFontSize(24))
          .fontColor('#FFFFFF')
          .onClick(() => {
            this.showAddDialog = true;
          })
      }
      .width('100%')
      .height(this.deviceUtil.getAdaptiveSpacing(50))
      .padding({ left: 12, right: 12 })
      .linearGradient({
        angle: 135,
        colors: [['#3498DB', 0], ['#2980B9', 1]]
      })

      // 下一次用药提醒
      this.buildNextReminder()

      // 用药列表
      Scroll() {
        Column({ space: this.deviceUtil.getAdaptiveSpacing(8) }) {
          ForEach(this.reminders, (reminder: MedicationReminder) => {
            this.buildMedicationItem(reminder)
          }, (reminder: MedicationReminder) => reminder.id)
        }
        .width('95%')
        .padding(this.deviceUtil.getAdaptiveSpacing(8))
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
    .bindSheet($$this.showAddDialog, this.buildAddDialog(), {
      height: 300,
      backgroundColor: Color.White,
      dragBar: true
    })
  }

  @Builder buildNextReminder() {
    if (this.getNextReminder()) {
      Column() {
        Text('下一次用药')
          .fontSize(this.deviceUtil.getAdaptiveFontSize(12))
          .fontColor('#FFFFFF')
          .opacity(0.8)

        Row() {
          Text(this.getNextReminder()!.icon)
            .fontSize(this.deviceUtil.getAdaptiveFontSize(20))

          Text(this.getNextReminder()!.medicineName)
            .fontSize(this.deviceUtil.getAdaptiveFontSize(16))
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
            .margin({ left: 8 })

          Text(this.getNextReminder()!.time)
            .fontSize(this.deviceUtil.getAdaptiveFontSize(14))
            .fontColor('#FFFFFF')
            .margin({ left: 8 })
        }
        .margin({ top: 4 })
      }
      .width('95%')
      .padding(this.deviceUtil.getAdaptiveSpacing(12))
      .margin({ top: this.deviceUtil.getAdaptiveSpacing(8) })
      .linearGradient({
        angle: 135,
        colors: [['#3498DB', 0], ['#2980B9', 1]]
      })
      .borderRadius(this.deviceUtil.getAdaptiveSpacing(12))
    }
  }

  @Builder buildMedicationItem(reminder: MedicationReminder) {
    Row() {
      Text(reminder.icon)
        .fontSize(this.deviceUtil.getAdaptiveFontSize(20))

      Column() {
        Text(reminder.medicineName)
          .fontSize(this.deviceUtil.getAdaptiveFontSize(14))
          .fontColor(reminder.isTaken ? '#999999' : '#333333')
          .fontWeight(FontWeight.Bold)

        Text(`${reminder.dosage} · ${reminder.time}`)
          .fontSize(this.deviceUtil.getAdaptiveFontSize(11))
          .fontColor('#999999')
          .margin({ top: 2 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 8 })

      Text(reminder.isTaken ? '✓' : '○')
        .fontSize(this.deviceUtil.getAdaptiveFontSize(20))
        .fontColor(reminder.isTaken ? '#4CAF50' : '#CCCCCC')
    }
    .width('100%')
    .padding(this.deviceUtil.getAdaptiveSpacing(12))
    .backgroundColor('#FFFFFF')
    .borderRadius(this.deviceUtil.getAdaptiveSpacing(10))
    .opacity(reminder.isTaken ? 0.6 : 1)
    .onClick(() => {
      this.toggleMedicationTaken(reminder.id);
    })
  }

  @Builder buildAddDialog() {
    Column() {
      Text('添加用药提醒')
        .fontSize(this.deviceUtil.getAdaptiveFontSize(16))
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 20 })

      Text('请在手机端添加详细用药提醒')
        .fontSize(this.deviceUtil.getAdaptiveFontSize(14))
        .fontColor('#666666')
        .textAlign(TextAlign.Center)

      Button('关闭')
        .width('80%')
        .height(this.deviceUtil.getAdaptiveButtonHeight(40))
        .backgroundColor('#3498DB')
        .margin({ top: 20 })
        .onClick(() => {
          this.showAddDialog = false;
        })
    }
    .width('100%')
    .padding(20)
  }
}
