import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';
import { MedicationService, MedicationPlan } from '../services/MedicationService';
import { AIOrchestrator } from '../ai/orchestrator/AIOrchestrator';
import { AIRequestBuilder } from '../ai/utils/AIRequestBuilder';

interface MedicationReminder {
  id: number;
  name: string;
  dosage: string;
  frequency: string;
  time: string;
  enabled: boolean;
  nextTime: string;
}

@Entry
@Component
struct MedicationPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @StorageLink('userId') userId: number = 0;
  @State reminderList: MedicationReminder[] = [];
  @State isLoading: boolean = true;
  @State aiOptimizedSchedule: string = '';
  @State aiMedicationAdvice: string = '';
  private medicationService: MedicationService = MedicationService.getInstance();
  private orchestrator: AIOrchestrator = AIOrchestrator.getInstance();

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') || false;
    }
    this.loadReminders();
  }

  async loadReminders(): Promise<void> {
    this.isLoading = true;
    
    try {
      const plans = await this.medicationService.getMedicationPlans(this.userId);
      
      const reminders: MedicationReminder[] = [];
      for (let i = 0; i < plans.length; i++) {
        const plan = plans[i];
        const reminder: MedicationReminder = {
          id: plan.id,
          name: plan.medicationName,
          dosage: plan.dosage,
          frequency: plan.frequency,
          time: plan.times.join(', '),
          enabled: plan.reminderEnabled,
          nextTime: this.calculateNextTime(plan.times, plan.reminderEnabled)
        };
        reminders.push(reminder);
      }
      this.reminderList = reminders;
    } catch (error) {
      console.error('[MedicationPage] 加载提醒数据异常:', error);
      ToastUtil.showError('加载失败，请重试');
    } finally {
      this.isLoading = false;
    }
  }

  async toggleReminder(reminder: MedicationReminder): Promise<void> {
    try {
      const success = await this.medicationService.toggleReminder(reminder.id, !reminder.enabled);
      
      if (success) {
        const index = this.reminderList.findIndex(r => r.id === reminder.id);
        if (index !== -1) {
          this.reminderList[index].enabled = !this.reminderList[index].enabled;
          this.reminderList[index].nextTime = this.calculateNextTime(
            this.reminderList[index].time.split(', '),
            this.reminderList[index].enabled
          );
        }
      }
    } catch (error) {
      console.error('[MedicationPage] 切换提醒状态失败:', error);
    }
  }

  private calculateNextTime(times: string[], enabled: boolean): string {
    if (!enabled) {
      return '已停用';
    }

    const now = new Date();
    const currentTime = now.getHours() * 60 + now.getMinutes();

    for (const timeStr of times) {
      const parts = timeStr.split(':');
      const hours = Number(parts[0]);
      const minutes = Number(parts[1]);
      const timeInMinutes = hours * 60 + minutes;
      
      if (timeInMinutes > currentTime) {
        return `今天 ${timeStr}`;
      }
    }

    return `明天 ${times[0]}`;
  }

  addReminder(): void {
    router.pushUrl({ url: 'pages/MedicationReminderEditPage' }).catch((error: Error) => {
      console.error('跳转添加提醒页失败:', error.message);
      ToastUtil.showError('功能开发中');
    });
  }

  editReminder(reminder: MedicationReminder): void {
    router.pushUrl({ 
      url: 'pages/MedicationReminderEditPage',
      params: { reminderId: reminder.id }
    }).catch((error: Error) => {
      console.error('跳转编辑提醒页失败:', error.message);
      ToastUtil.showError('功能开发中');
    });
  }

  async optimizeScheduleWithAI(): Promise<void> {
    try {
      const medicationList = this.reminderList.map(r => `${r.name}(${r.dosage})-${r.time}`).join(', ');
      const request = AIRequestBuilder.createWithIntent(
        `我的用药清单：${medicationList}，请优化服药时间安排，避免药物相互作用`,
        'medication_guidance'
      );
      const response = await this.orchestrator.process(request);
      const content = response.output.content;
      this.aiOptimizedSchedule = typeof content === 'string' ? content : JSON.stringify(content);
    } catch (error) {
      console.error('[MedicationPage] AI优化失败:', error);
      this.aiOptimizedSchedule = 'AI优化暂时不可用';
    }
  }

  async getMedicationAdviceFromAI(): Promise<void> {
    try {
      const medicationNames = this.reminderList.map(r => r.name).join(', ');
      const request = AIRequestBuilder.createWithIntent(
        `我正在服用以下药物：${medicationNames}，请给出用药注意事项和建议`,
        'medication_guidance'
      );
      const response = await this.orchestrator.process(request);
      const content = response.output.content;
      this.aiMedicationAdvice = typeof content === 'string' ? content : JSON.stringify(content);
    } catch (error) {
      console.error('[MedicationPage] AI建议失败:', error);
      this.aiMedicationAdvice = 'AI建议暂时不可用';
    }
  }

  build() {
    Column() {
      Header({ title: '用药提醒', showBack: true });

      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(50)
            .height(50)
            .color('#E74C3C')
          Text('加载中...')
            .fontSize(14)
            .fontColor('#999')
            .margin({ top: 10 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.reminderList.length === 0) {
        Column() {
          Text('💊')
            .fontSize(60)
          Text('暂无用药提醒')
            .fontSize(16)
            .fontColor('#999')
            .margin({ top: 10 })
          Text('点击右下角按钮添加')
            .fontSize(14)
            .fontColor('#ccc')
            .margin({ top: 5 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column() {
            ForEach(this.reminderList, (reminder: MedicationReminder) => {
              Row() {
                Column() {
                  Row() {
                    Text(reminder.name)
                      .fontSize(this.isElderMode ? 18 : 16)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#333')
                      .layoutWeight(1)
                    
                    Toggle({ type: ToggleType.Switch, isOn: reminder.enabled })
                      .onChange((isOn: boolean) => {
                        this.toggleReminder(reminder);
                      })
                      .selectedColor('#E74C3C')
                  }
                  .width('100%')
                  .margin({ bottom: 8 })

                  Row() {
                    Text('剂量：' + reminder.dosage)
                      .fontSize(this.isElderMode ? 14 : 12)
                      .fontColor('#666')
                    
                    Text('频率：' + reminder.frequency)
                      .fontSize(this.isElderMode ? 14 : 12)
                      .fontColor('#666')
                      .margin({ left: 15 })
                  }
                  .width('100%')

                  Row() {
                    Text('⏰ ' + reminder.time)
                      .fontSize(this.isElderMode ? 14 : 12)
                      .fontColor('#999')
                      .layoutWeight(1)
                    
                    Text(reminder.enabled ? '下次：' + reminder.nextTime : '已停用')
                      .fontSize(this.isElderMode ? 14 : 12)
                      .fontColor(reminder.enabled ? '#E74C3C' : '#999')
                  }
                  .width('100%')
                  .margin({ top: 6 })
                }
                .width('100%')
                .padding(15)
                .alignItems(HorizontalAlign.Start)
              }
              .width('90%')
              .backgroundColor('#fff')
              .borderRadius(12)
              .shadow({ radius: 3, color: '#e0e0e0', offsetX: 0, offsetY: 2 })
              .margin({ bottom: 12 })
              .onClick(() => this.editReminder(reminder))
            })
          }
          .width('100%')
          .padding({ top: 10, bottom: 80 })
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }

      // 添加按钮
      Row() {
        Text('+')
          .fontSize(32)
          .fontColor('#fff')
      }
      .width(60)
      .height(60)
      .backgroundColor('#E74C3C')
      .borderRadius(30)
      .justifyContent(FlexAlign.Center)
      .position({ x: '85%', y: '85%' })
      .shadow({ radius: 8, color: '#E74C3C', offsetX: 0, offsetY: 4 })
      .onClick(() => this.addReminder())

      Footer();
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f8f9fa')
  }
}
