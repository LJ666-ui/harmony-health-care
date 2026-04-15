import { router } from '@kit.ArkUI';
import { HealthRecord } from '../models/HealthData';

interface RecordType {
  label: string;
  unit: string;
  icon: string;
  color: string;
  range: string;
}

@Entry
@Component
struct AddHealthRecord {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State selectedType: string = '血压';
  @State value: string = '';
  @State notes: string = '';
  @State selectedDate: string = new Date().toISOString().split('T')[0];
  @State selectedTime: string = new Date().toTimeString().substring(0, 5);
  @State errorMessage: string = '';

  private recordTypes: RecordType[] = [
    { label: '血压', unit: 'mmHg', icon: '📊', color: '#1677FF', range: '收缩压 90-140，舒张压 60-90' },
    { label: '血糖', unit: 'mmol/L', icon: '🍬', color: '#FF7F50', range: '空腹 3.9-6.1，餐后 4.4-7.8' },
    { label: '心率', unit: 'bpm', icon: '❤️', color: '#FF4444', range: '60-100' },
    { label: '体重', unit: 'kg', icon: '⚖️', color: '#9370DB', range: '根据身高计算' },
    { label: '其他', unit: '', icon: '📝', color: '#666666', range: '请输入合适的值' }
  ];

  private getCurrentTypeInfo() {
    return this.recordTypes.find(type => type.label === this.selectedType) || this.recordTypes[0];
  }

  validateForm(): boolean {
    this.errorMessage = '';

    if (!this.value.trim()) {
      this.errorMessage = '请输入数值';
    } else if (this.selectedType === '血压') {
      const parts = this.value.split('/');
      const systolic = parts[0];
      const diastolic = parts[1];
      if (!systolic || !diastolic) {
        this.errorMessage = '请输入正确的血压格式，如 120/80';
      } else if (isNaN(Number(systolic)) || isNaN(Number(diastolic))) {
        this.errorMessage = '请输入有效的数字';
      }
    } else if (isNaN(Number(this.value))) {
      this.errorMessage = '请输入有效的数字';
    }

    return this.errorMessage === '';
  }

  saveRecord() {
    if (this.validateForm()) {
      const typeInfo = this.getCurrentTypeInfo();
      const newRecord: HealthRecord = {
        id: Date.now().toString(),
        type: this.selectedType,
        value: this.value,
        unit: typeInfo.unit,
        date: this.selectedDate,
        time: this.selectedTime,
        notes: this.notes,
        icon: typeInfo.icon,
        color: typeInfo.color,
        createdAt: Date.now(),
        updatedAt: Date.now()
      };

      // 这里应该调用后端接口保存数据
      console.log('保存健康记录:', newRecord);

      // 保存成功后返回列表页
      router.back();
    }
  }

  build() {
    Column() {
      Text('← 返回')
        .fontSize(16)
        .fontColor('#1677FF')
        .padding(12)
        .width('100%')
        .onClick(() => {
          router.back();
        });

      Scroll() {
        Column() {
          Text('添加健康记录')
            .fontSize(24)
            .fontWeight('bold')
            .fontColor('#1677FF')
            .margin({ bottom: 8 });

          Column() {
            Text('记录类型')
              .fontSize(14)
              .fontColor('#666666')
              .margin({ bottom: 8 });
            Scroll() {
              Row() {
                ForEach(this.recordTypes, (type: RecordType) => {
                  Column() {
                    Text(type.icon)
                      .fontSize(24)
                      .margin({ bottom: 4 });
                    Text(type.label)
                      .fontSize(12)
                      .fontColor('#333333');
                  }
                  .padding(12)
                  .backgroundColor(this.selectedType === type.label ? type.color + '20' : '#F5F5F5')
                  .borderRadius(12)
                  .margin({ right: 12 })
                  .onClick(() => {
                    this.selectedType = type.label;
                    this.value = '';
                    this.errorMessage = '';
                  });
                });
              }
            }
            .width('100%');
          }

          Column() {
            Text('数值')
              .fontSize(14)
              .fontColor('#666666')
              .margin({ bottom: 8 });
            Row() {
              TextInput({
                placeholder: this.selectedType === '血压' ? '如 120/80' : '请输入数值'
              })
                .width('70%')
                .height(48)
                .padding(12)
                .backgroundColor('#F5F5F5')
                .borderRadius(8)
                .onChange((value) => {
                  this.value = value;
                  if (this.errorMessage) {
                    this.errorMessage = '';
                  }
                });
              Text(this.getCurrentTypeInfo().unit)
                .fontSize(16)
                .fontColor('#333333')
                .margin({ left: 12 });
            }
            if (this.errorMessage) {
              Text(this.errorMessage)
                .fontSize(12)
                .fontColor('#FF4444')
                .margin({ top: 4 });
            }
            Text(`正常范围：${this.getCurrentTypeInfo().range}`)
              .fontSize(12)
              .fontColor('#999999')
              .margin({ top: 4 });
          }

          Column() {
            Text('测量时间')
              .fontSize(14)
              .fontColor('#666666')
              .margin({ bottom: 8 });
            Row() {
              TextInput({
                placeholder: 'YYYY-MM-DD'
              })
                .width('45%')
                .height(48)
                .padding(12)
                .backgroundColor('#F5F5F5')
                .borderRadius(8)
                .onChange((value) => {
                  this.selectedDate = value;
                });
              TextInput({
                placeholder: 'HH:MM'
              })
                .width('45%')
                .height(48)
                .padding(12)
                .backgroundColor('#F5F5F5')
                .borderRadius(8)
                .margin({ left: 12 })
                .onChange((value) => {
                  this.selectedTime = value;
                });
            }
          }

          Column() {
            Text('备注')
              .fontSize(14)
              .fontColor('#666666')
              .margin({ bottom: 8 });
            TextInput({
              placeholder: '请输入备注（可选）'
            })
              .width('100%')
              .height(80)
              .padding(12)
              .backgroundColor('#F5F5F5')
              .borderRadius(8)
              .onChange((value) => {
                this.notes = value;
              });
          }

          Button('保存')
            .width('100%')
            .height(48)
            .fontSize(16)
            .fontColor('#FFFFFF')
            .backgroundColor('#1677FF')
            .borderRadius(24)
            .onClick(() => {
              this.saveRecord();
            });
        }
        .width('85%')
        .padding({ top: 16, bottom: 80 });
      }
      .height(0)
      .layoutWeight(1);
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }
}
