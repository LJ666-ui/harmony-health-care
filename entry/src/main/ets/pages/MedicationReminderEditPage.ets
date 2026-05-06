import { router } from '@kit.ArkUI';
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
struct MedicationReminderEditPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  
  @State medicineName: string = '';
  @State dosage: string = '';
  @State times: string[] = ['08:00'];
  @State showTimePicker: boolean = false;
  @State currentTimeIndex: number = -1;
  @State isEditMode: boolean = false;
  @State editingReminderId: string = '';

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    }
    
    const params = router.getParams() as Record<string, string>;
    if (params && params.reminderId) {
      this.isEditMode = true;
      this.editingReminderId = params.reminderId;
      this.loadExistingReminder(params.reminderId);
    }
  }

  loadExistingReminder(reminderId: string): void {
    const stored = AppStorage.get<MedicationReminder[]>('medicationReminders');
    if (stored) {
      const reminder = stored.find(r => r.id === reminderId);
      if (reminder) {
        this.medicineName = reminder.medicineName;
        this.dosage = reminder.dosage;
        this.times = [...reminder.times];
      }
    }
  }

  addTime(): void {
    if (this.times.length < 6) {
      this.times.push('12:00');
    } else {
      ToastUtil.showWarning('最多只能添加6个服药时间');
    }
  }

  removeTime(index: number): void {
    if (this.times.length > 1) {
      this.times.splice(index, 1);
    } else {
      ToastUtil.showWarning('至少需要保留一个服药时间');
    }
  }

  openTimePicker(index: number): void {
    this.currentTimeIndex = index;
    this.showTimePicker = true;
  }

  onTimeConfirm(value: string): void {
    if (this.currentTimeIndex >= 0 && this.currentTimeIndex < this.times.length) {
      this.times[this.currentTimeIndex] = value;
    }
    this.showTimePicker = false;
    this.currentTimeIndex = -1;
  }

  onTimeCancel(): void {
    this.showTimePicker = false;
    this.currentTimeIndex = -1;
  }

  generateId(): string {
    return Date.now().toString() + Math.random().toString(36).substr(2, 9);
  }

  saveReminder(): Promise<void> {
    return new Promise<void>((resolve) => {
      if (!this.medicineName.trim()) {
        ToastUtil.showError('请输入药品名称');
        resolve();
        return;
      }

      if (!this.dosage.trim()) {
        ToastUtil.showError('请输入用量');
        resolve();
        return;
      }

      const stored = AppStorage.get<MedicationReminder[]>('medicationReminders') || [];
      
      if (this.isEditMode && this.editingReminderId) {
        const index = stored.findIndex(r => r.id === this.editingReminderId);
        if (index !== -1) {
          stored[index].medicineName = this.medicineName.trim();
          stored[index].dosage = this.dosage.trim();
          stored[index].times = [...this.times];
        }
        ToastUtil.showSuccess('修改成功');
      } else {
        const newReminder: MedicationReminder = {
          id: this.generateId(),
          medicineName: this.medicineName.trim(),
          dosage: this.dosage.trim(),
          times: [...this.times],
          isActive: true,
          createdAt: Date.now()
        };
        stored.push(newReminder);
        ToastUtil.showSuccess('创建成功');
      }

      AppStorage.setOrCreate<MedicationReminder[]>('medicationReminders', stored);
      
      setTimeout(() => {
        router.back();
        resolve();
      }, 500);
    });
  }

  build() {
    Column() {
      Row() {
        Text('←')
          .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
          .fontColor('#1677FF')
          .width(40)
          .height(40)
          .textAlign(TextAlign.Center)
          .backgroundColor('#E6F4FF')
          .borderRadius(20)
          .onClick(() => {
            router.back();
          })
        Text(this.isEditMode ? '编辑用药提醒' : '新建用药提醒')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Text('').width(40)
      }
      .width('100%')
      .height(56)
      .backgroundColor('#FFFFFF')
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.Center)

      Scroll() {
        Column() {
          Column() {
            Text('💊 药品信息')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .margin({ bottom: 20 })
              .width('100%');

            Text('药品名称 *')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .margin({ bottom: 8 })
              .width('100%')
              .textAlign(TextAlign.Start);

            TextInput({
              placeholder: '请输入药品名称，如：阿莫西林',
              text: this.medicineName
            })
              .width('100%')
              .height(48)
              .fontSize(16)
              .padding({ left: 12, right: 12 })
              .backgroundColor('#F5F7FA')
              .borderRadius(8)
              .onChange((value: string) => {
                this.medicineName = value;
              });

            Text('用量 *')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .margin({ top: 20, bottom: 8 })
              .width('100%')
              .textAlign(TextAlign.Start);

            TextInput({
              placeholder: '请输入用量，如：每次1片',
              text: this.dosage
            })
              .width('100%')
              .height(48)
              .fontSize(16)
              .padding({ left: 12, right: 12 })
              .backgroundColor('#F5F7FA')
              .borderRadius(8)
              .onChange((value: string) => {
                this.dosage = value;
              });
          }
          .width('85%')
          .margin({ top: 24, bottom: 24, left: '7.5%', right: '7.5%' })
          .padding(20)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .border({ width: 1, color: '#F0F0F0' });

          Column() {
            Row() {
              Text('⏰ 服药时间 *')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .layoutWeight(1);
              
              Button('+ 添加时间')
                .height(32)
                .fontSize(13)
                .backgroundColor('#1677FF')
                .borderRadius(16)
                .onClick(() => this.addTime());
            }
            .width('100%')
            .margin({ bottom: 16 });

            ForEach(this.times, (time: string, index: number) => {
              Row() {
                Text('⏱️')
                  .fontSize(18)
                  .margin({ right: 10 });
                
                Text(time)
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#1677FF')
                  .layoutWeight(1)
                  .onClick(() => this.openTimePicker(index));
                
                Button('选择时间')
                  .height(32)
                  .fontSize(12)
                  .backgroundColor('#E6F4FF')
                  .fontColor('#1677FF')
                  .borderRadius(16)
                  .margin({ right: 8 })
                  .onClick(() => this.openTimePicker(index));
                
                if (this.times.length > 1) {
                  Button('✕')
                    .width(32)
                    .height(32)
                    .fontSize(14)
                    .backgroundColor('#FFF1F0')
                    .fontColor('#FF4D4F')
                    .borderRadius(16)
                    .onClick(() => this.removeTime(index));
                } else {
                  Blank()
                    .width(32)
                    .height(32);
                }
              }
              .width('100%')
              .height(56)
              .backgroundColor('#F5F7FA')
              .borderRadius(8)
              .alignItems(VerticalAlign.Center)
              .justifyContent(FlexAlign.Start)
              .padding({ left: 12, right: 8 })
              .margin({ bottom: 12 });
            }, (time: string, index: number) => time + index.toString());

            Text('提示：点击时间可以修改，建议设置早中晚三个时间段')
              .fontSize(12)
              .fontColor('#999999')
              .margin({ top: 8 });
          }
          .width('85%')
          .margin({ bottom: 24, left: '7.5%', right: '7.5%' })
          .padding(20)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .border({ width: 1, color: '#F0F0F0' });

          Column() {
            Text('📝 温馨提示')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .margin({ bottom: 12 });
            
            Text('• 请如实填写药品名称和用量')
              .fontSize(13)
              .fontColor('#666666')
              .margin({ bottom: 6 });
            Text('• 可以设置多个服药时间点')
              .fontSize(13)
              .fontColor('#666666')
              .margin({ bottom: 6 });
            Text('• 到达指定时间会收到用药提醒')
              .fontSize(13)
              .fontColor('#666666');
          }
          .width('85%')
          .margin({ bottom: 120, left: '7.5%', right: '7.5%' })
          .padding(16)
          .backgroundColor('#FEFFE6')
          .borderRadius(12)
          .border({ width: 1, color: '#FFF58F' });
        }
        .width('100%')
        .padding({ top: 16 });
      }
      .height(0)
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top);

      Column() {
        Button(this.isEditMode ? '保存修改' : '保存提醒')
          .width('90%')
          .height(50)
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .backgroundColor('#1677FF')
          .borderRadius(25)
          .onClick(() => this.saveReminder());
      }
      .width('100%')
      .padding({ bottom: 30, top: 16 })
      .backgroundColor('#FFFFFF')
      .shadow({
        radius: 10,
        color: 'rgba(0, 0, 0, 0.08)',
        offsetX: 0,
        offsetY: -2
      });

      if (this.showTimePicker) {
        Column() {
          Text('')
            .width('100%')
            .height('100%')
            .backgroundColor('rgba(0, 0, 0, 0.5)')
            .onClick(() => this.onTimeCancel());

          Column() {
            Text('选择服药时间')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .margin({ bottom: 24 });

            TimePicker({
              selected: new Date(`2024-01-01 ${this.times[this.currentTimeIndex] || '08:00'}`)
            })
              .useMilitaryTime(true)
              .width(280)
              .height(200)
              .onChange((value: TimePickerResult) => {
                const hour = value.hour < 10 ? '0' + value.hour : '' + value.hour;
                const minute = value.minute < 10 ? '0' + value.minute : '' + value.minute;
                this.onTimeConfirm(hour + ':' + minute);
              });

            Row({ space: 16 }) {
              Button('取消')
                .layoutWeight(1)
                .height(44)
                .fontSize(15)
                .backgroundColor('#F5F5F5')
                .fontColor('#666666')
                .borderRadius(22)
                .onClick(() => this.onTimeCancel());
              
              Button('确定')
                .layoutWeight(1)
                .height(44)
                .fontSize(15)
                .backgroundColor('#1677FF')
                .fontColor('#FFFFFF')
                .borderRadius(22)
                .onClick(() => {
                  const now = new Date();
                  const hour = now.getHours() < 10 ? '0' + now.getHours() : '' + now.getHours();
                  const minute = now.getMinutes() < 10 ? '0' + now.getMinutes() : '' + now.getMinutes();
                  this.onTimeConfirm(hour + ':' + minute);
                });
            }
            .width('100%')
            .margin({ top: 24 });
          }
          .width('80%')
          .padding(24)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .position({ x: '10%', y: '35%' });
        }
        .width('100%')
        .height('100%')
        .position({ x: 0, y: 0 });
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(GlobalTheme.BG_COLOR);
  }
}
