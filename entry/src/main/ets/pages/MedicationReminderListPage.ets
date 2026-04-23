import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';

interface MedicationReminder {
  id: string;
  medicineName: string;
  dosage: string;
  times: string[];
  isActive: boolean;
  createdAt: number;
}

@Entry
@Component
struct MedicationReminderListPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State reminders: MedicationReminder[] = [];
  @State isLoading: boolean = true;

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    }
    this.loadReminders();
  }

  loadReminders(): void {
    const stored = AppStorage.get<MedicationReminder[]>('medicationReminders');
    if (stored && stored.length > 0) {
      this.reminders = stored;
    } else {
      this.reminders = [];
    }
    this.isLoading = false;
  }

  saveReminders(): void {
    AppStorage.setOrCreate<MedicationReminder[]>('medicationReminders', this.reminders);
  }

  navigateToAddReminder(): void {
    router.pushUrl({
      url: 'pages/MedicationReminderEditPage'
    }).catch((error: Error) => {
      console.error('跳转新建提醒失败:', error.message);
    });
  }

  navigateToEditReminder(reminder: MedicationReminder): void {
    router.pushUrl({
      url: 'pages/MedicationReminderEditPage',
      params: { reminderId: reminder.id }
    }).catch((error: Error) => {
      console.error('跳转编辑提醒失败:', error.message);
    });
  }

  deleteReminder(reminderId: string): void {
    const index = this.reminders.findIndex(r => r.id === reminderId);
    if (index !== -1) {
      this.reminders.splice(index, 1);
      this.saveReminders();
      ToastUtil.showSuccess('删除成功');
    }
  }

  toggleReminderActive(reminderId: string): void {
    const reminder = this.reminders.find(r => r.id === reminderId);
    if (reminder) {
      reminder.isActive = !reminder.isActive;
      this.saveReminders();
      ToastUtil.showSuccess(reminder.isActive ? '已开启提醒' : '已关闭提醒');
    }
  }

  formatTimes(times: string[]): string {
    return times.join(', ');
  }

  build() {
    Column() {
      Header({ title: '用药提醒', showBack: true });

      Column() {
        Text('💊 用药提醒管理')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ bottom: 8 });
        Text('设置服药时间，按时吃药不忘记')
          .fontSize(14)
          .fontColor('#666666')
          .margin({ bottom: 24 });
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 20 })
      .alignItems(HorizontalAlign.Start);

      Button('+ 新建用药提醒')
        .width('85%')
        .height(48)
        .fontSize(16)
        .fontColor('#FFFFFF')
        .backgroundColor('#1677FF')
        .borderRadius(24)
        .margin({ bottom: 20, left: '7.5%', right: '7.5%' })
        .onClick(() => this.navigateToAddReminder());

      Scroll() {
        Column() {
          if (this.isLoading) {
            Column() {
              Text('⏳')
                .fontSize(48)
                .margin({ bottom: 16 });
              Text('加载中...')
                .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                .fontColor('#999999');
            }
            .width('100%')
            .height(300)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center);
          } else if (this.reminders.length === 0) {
            Column() {
              Text('⏰')
                .fontSize(64)
                .margin({ bottom: 16 });
              Text('暂无用药提醒')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .margin({ bottom: 8 });
              Text('点击上方按钮添加您的第一个用药提醒')
                .fontSize(14)
                .fontColor('#999999')
                .textAlign(TextAlign.Center);
            }
            .width('100%')
            .height(350)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center);
          } else {
            ForEach(this.reminders, (reminder: MedicationReminder) => {
              Column() {
                Row() {
                  Column() {
                    Row() {
                      Text('💊')
                        .fontSize(20)
                        .margin({ right: 8 });
                      Text(reminder.medicineName)
                        .fontSize(16)
                        .fontWeight(FontWeight.Bold)
                        .fontColor('#333333')
                    }
                    .margin({ bottom: 6 });
                    
                    Text('用量: ' + reminder.dosage)
                      .fontSize(13)
                      .fontColor('#666666')
                      .margin({ bottom: 4 });
                      
                    Text('时间: ' + this.formatTimes(reminder.times))
                      .fontSize(13)
                      .fontColor('#1677FF')
                      .margin({ bottom: 4 });
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)

                  Column() {
                    Text(reminder.isActive ? '已开启' : '已关闭')
                      .fontSize(11)
                      .fontColor(reminder.isActive ? '#52C41A' : '#999999')
                      .backgroundColor(reminder.isActive ? '#F6FFED' : '#F5F5F5')
                      .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                      .borderRadius(10);
                  }
                }
                .width('100%')
                .margin({ bottom: 12 })

                Row({ space: 12 }) {
                  Button(reminder.isActive ? '关闭提醒' : '开启提醒')
                    .height(32)
                    .fontSize(13)
                    .backgroundColor(reminder.isActive ? '#FF4D4F' : '#52C41A')
                    .borderRadius(16)
                    .onClick(() => this.toggleReminderActive(reminder.id));
                  
                  Button('编辑')
                    .height(32)
                    .fontSize(13)
                    .backgroundColor('#1677FF')
                    .borderRadius(16)
                    .onClick(() => this.navigateToEditReminder(reminder));
                  
                  Button('删除')
                    .height(32)
                    .fontSize(13)
                    .backgroundColor('#FF4D4F')
                    .borderRadius(16)
                    .onClick(() => this.deleteReminder(reminder.id));
                }
                .width('100%')
              }
              .width('85%')
              .margin({ bottom: 20, left: '7.5%', right: '7.5%' })
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .border({ width: 1, color: '#F0F0F0' })
              .shadow({
                radius: 8,
                color: 'rgba(0, 0, 0, 0.05)',
                offsetX: 0,
                offsetY: 2
              })
              .onClick(() => this.navigateToEditReminder(reminder));
            }, (reminder: MedicationReminder) => reminder.id);
            
            Text('共 ' + this.reminders.length + ' 条提醒')
              .fontSize(12)
              .fontColor('#999999')
              .margin({ top: 8, bottom: 100 })
              .textAlign(TextAlign.Center);
          }
        }
        .width('100%')
        .padding({ top: 8, bottom: 100 });
      }
      .height(0)
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top);

      Footer({ activeIndex: 0 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor(GlobalTheme.BG_COLOR);
  }
}
