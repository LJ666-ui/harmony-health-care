import { router } from '@kit.ArkUI';
import { HealthRecord } from '../models/HealthData';

@Entry
@Component
struct HealthRecordDetail {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State record: HealthRecord = this.getDefaultRecord();
  @State previousRecord: HealthRecord | null = null;

  getDefaultRecord(): HealthRecord {
    return {
      id: '',
      type: '血压',
      value: '0/0',
      unit: 'mmHg',
      date: new Date().toISOString().split('T')[0],
      time: new Date().toTimeString().substring(0, 5),
      notes: '',
      icon: '📊',
      color: '#1677FF',
      createdAt: Date.now(),
      updatedAt: Date.now()
    };
  }

  getStatusIcon(value: string, type: string): string {
    if (type === '血压') {
      const parts = value.split('/');
      const systolic = Number(parts[0]);
      const diastolic = Number(parts[1]);
      if (systolic >= 140 || diastolic >= 90) return '⚠️';
      if (systolic < 90 || diastolic < 60) return '⚠️';
      return '✅';
    } else if (type === '血糖') {
      const val = Number(value);
      if (val >= 7.0) return '⚠️';
      if (val < 3.9) return '⚠️';
      return '✅';
    } else if (type === '心率') {
      const val = Number(value);
      if (val >= 100 || val < 60) return '⚠️';
      return '✅';
    }
    return '✅';
  }

  getStatusText(value: string, type: string): string {
    if (type === '血压') {
      const parts = value.split('/');
      const systolic = Number(parts[0]);
      const diastolic = Number(parts[1]);
      if (systolic >= 140 || diastolic >= 90) return '偏高';
      if (systolic < 90 || diastolic < 60) return '偏低';
      return '正常';
    } else if (type === '血糖') {
      const val = Number(value);
      if (val >= 7.0) return '偏高';
      if (val < 3.9) return '偏低';
      return '正常';
    } else if (type === '心率') {
      const val = Number(value);
      if (val >= 100 || val < 60) return '异常';
      return '正常';
    }
    return '正常';
  }

  getStatusColor(value: string, type: string): string {
    if (type === '血压') {
      const parts = value.split('/');
      const systolic = Number(parts[0]);
      const diastolic = Number(parts[1]);
      if (systolic >= 140 || diastolic >= 90) return '#FF4444';
      if (systolic < 90 || diastolic < 60) return '#FF4444';
      return '#52C41A';
    } else if (type === '血糖') {
      const val = Number(value);
      if (val >= 7.0) return '#FF4444';
      if (val < 3.9) return '#FF4444';
      return '#52C41A';
    } else if (type === '心率') {
      const val = Number(value);
      if (val >= 100 || val < 60) return '#FF4444';
      return '#52C41A';
    }
    return '#52C41A';
  }

  editRecord() {
    router.push({
      url: 'pages/AddHealthRecord',
      params: { record: this.record }
    });
  }

  deleteRecord() {
    // 这里应该调用后端接口删除数据
    console.log('删除健康记录:', this.record.id);
    router.back();
  }

  aboutToAppear() {
    // 这里应该从后端获取上一条记录进行对比
    // 暂时模拟一条数据
    this.previousRecord = {
      id: 'prev1',
      type: this.record.type,
      value: this.record.type === '血压' ? '125/85' : this.record.type === '血糖' ? '5.8' : this.record.type === '心率' ? '78' : '66',
      unit: this.record.unit,
      date: '2026-04-14',
      time: '09:00',
      notes: '上次记录',
      icon: this.record.icon,
      color: this.record.color,
      createdAt: this.record.createdAt - 86400000,
      updatedAt: this.record.createdAt - 86400000
    };
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
          Text('记录详情')
            .fontSize(24)
            .fontWeight('bold')
            .fontColor('#1677FF')
            .margin({ bottom: 8 });

          Column() {
            Text(this.record.icon)
              .fontSize(48)
              .margin({ bottom: 16 });
            Text(this.record.type)
              .fontSize(18)
              .fontColor('#333333')
              .margin({ bottom: 16 });
            Text(`${this.record.value} ${this.record.unit}`)
              .fontSize(36)
              .fontWeight('bold')
              .fontColor(this.record.color)
              .margin({ bottom: 8 });
            Row() {
              Text(this.getStatusIcon(this.record.value, this.record.type))
                .fontSize(16)
                .margin({ right: 8 });
              Text(this.getStatusText(this.record.value, this.record.type))
                .fontSize(16)
                .fontColor(this.getStatusColor(this.record.value, this.record.type));
            }
          }
          .width('100%')
          .padding(24)
          .backgroundColor('#FFFFFF')
          .borderRadius(16);

          Column() {
            Text('详细信息')
              .fontSize(16)
              .fontWeight('bold')
              .fontColor('#333333')
              .margin({ bottom: 12 });

            Row() {
              Text('测量时间：')
                .fontSize(14)
                .fontColor('#666666')
                .width(80);
              Text(`${this.record.date} ${this.record.time}`)
                .fontSize(14)
                .fontColor('#333333')
                .layoutWeight(1);
            }
            .margin({ bottom: 8 });

            if (this.record.notes) {
              Row() {
                Text('备注：')
                  .fontSize(14)
                  .fontColor('#666666')
                  .width(80);
                Text(this.record.notes)
                  .fontSize(14)
                  .fontColor('#333333')
                  .layoutWeight(1);
              }
              .margin({ bottom: 8 });
            }

            Row() {
              Text('记录时间：')
                .fontSize(14)
                .fontColor('#666666')
                .width(80);
              Text(new Date(this.record.createdAt).toLocaleString())
                .fontSize(14)
                .fontColor('#333333')
                .layoutWeight(1);
            }
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12);

          if (this.previousRecord) {
            Column() {
              Text('与上次对比')
                .fontSize(16)
                .fontWeight('bold')
                .fontColor('#333333')
                .margin({ bottom: 12 });

              Row() {
                Text('上次数值：')
                  .fontSize(14)
                  .fontColor('#666666')
                  .width(80);
                Text(`${this.previousRecord.value} ${this.previousRecord.unit}`)
                  .fontSize(14)
                  .fontColor('#333333')
                  .layoutWeight(1);
              }
              .margin({ bottom: 8 });

              Row() {
                Text('上次时间：')
                  .fontSize(14)
                  .fontColor('#666666')
                  .width(80);
                Text(`${this.previousRecord.date} ${this.previousRecord.time}`)
                  .fontSize(14)
                  .fontColor('#333333')
                  .layoutWeight(1);
              }
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(12);
          }

          Row() {
            Button('编辑')
              .width('50%')
              .height(48)
              .fontSize(16)
              .fontColor('#FFFFFF')
              .backgroundColor('#1677FF')
              .borderRadius(24)
              .margin({ right: 12 })
              .onClick(() => {
                this.editRecord();
              });

            Button('删除')
              .width('50%')
              .height(48)
              .fontSize(16)
              .fontColor('#FFFFFF')
              .backgroundColor('#FF4444')
              .borderRadius(24)
              .onClick(() => {
                this.deleteRecord();
              });
          }
          .width('100%');
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
