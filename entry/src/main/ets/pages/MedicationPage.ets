import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';

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
  @State reminderList: MedicationReminder[] = [];
  @State isLoading: boolean = true;

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
      await new Promise<void>(resolve => setTimeout(resolve, 500));
      
      this.reminderList = [
        { id: 1, name: '阿莫西林胶囊', dosage: '0.5g', frequency: '每日3次', time: '08:00, 14:00, 20:00', enabled: true, nextTime: '今天 14:00' },
        { id: 2, name: '布洛芬缓释胶囊', dosage: '0.3g', frequency: '每日2次', time: '09:00, 21:00', enabled: true, nextTime: '今天 21:00' },
        { id: 3, name: '维生素C片', dosage: '100mg', frequency: '每日1次', time: '08:00', enabled: false, nextTime: '已停用' },
        { id: 4, name: '奥美拉唑肠溶胶囊', dosage: '20mg', frequency: '每日1次', time: '07:00', enabled: true, nextTime: '明天 07:00' },
        { id: 5, name: '氯雷他定片', dosage: '10mg', frequency: '每日1次', time: '20:00', enabled: true, nextTime: '今天 20:00' }
      ];
    } catch (error) {
      console.error('[MedicationPage] 加载提醒数据异常:', error);
      ToastUtil.showError('加载失败，请重试');
    } finally {
      this.isLoading = false;
    }
  }

  toggleReminder(reminder: MedicationReminder): void {
    const index = this.reminderList.findIndex(r => r.id === reminder.id);
    if (index !== -1) {
      this.reminderList[index].enabled = !this.reminderList[index].enabled;
      ToastUtil.showSuccess(this.reminderList[index].enabled ? '已启用提醒' : '已停用提醒');
    }
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
