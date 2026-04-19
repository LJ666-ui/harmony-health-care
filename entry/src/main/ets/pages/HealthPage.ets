import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';

interface BackendHealthRecord {
  id: number;
  userId: number;
  bloodPressure: string | null;
  bloodSugar: string | null;
  heartRate: number | null;
  weight: string | null;
  height: string | null;
  stepCount: number | null;
  sleepDuration: string | null;
  recordTime: string;
  createTime: string;
}

interface HealthMetricStatus {
  text: string;
  color: string;
  icon: string;
}

interface HealthRecordInput {
  userId: number;
  bloodPressure: string | null;
  bloodSugar: string | null;
  heartRate: number | null;
  weight: string | null;
  stepCount: number | null;
  sleepDuration: string | null;
}

@Entry
@Component
struct HealthPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State bloodPressureSystolic: string = '';
  @State bloodPressureDiastolic: string = '';
  @State heartRate: string = '';
  @State weight: string = '';
  @State bloodSugar: string = '';
  @State stepCount: string = '';
  @State sleepDuration: string = '';

  @State isLoadingLatest: boolean = true;
  @State isSaving: boolean = false;
  @State saveMessage: string = '';

  @State latestRecord: BackendHealthRecord = {
    id: 0,
    userId: 0,
    bloodPressure: null,
    bloodSugar: null,
    heartRate: null,
    weight: null,
    height: null,
    stepCount: null,
    sleepDuration: null,
    recordTime: '',
    createTime: ''
  };
  @State hasRecord: boolean = false;

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    }
    this.loadLatestRecord();
  }

  loadLatestRecord(): void {
    this.isLoadingLatest = true;
    HttpUtil.get<BackendHealthRecord[]>(ApiConstants.HEALTH_RECORD_MY, {
      "userId": 1
    })
      .then((response: BaseResponse<BackendHealthRecord[]>) => {
        this.isLoadingLatest = false;
        if (response.success && response.data && response.data.length > 0) {
          const records: BackendHealthRecord[] = response.data;
          records.sort((a: BackendHealthRecord, b: BackendHealthRecord) => {
            return new Date(b.createTime).getTime() - new Date(a.createTime).getTime();
          });
          this.latestRecord = records[0];
          this.hasRecord = true;
        } else {
          this.hasRecord = false;
        }
      })
      .catch(() => {
        this.isLoadingLatest = false;
        this.hasRecord = false;
      });
  }

  validateInput(): boolean {
    if (!this.bloodPressureSystolic && !this.bloodPressureDiastolic &&
      !this.heartRate && !this.weight && !this.bloodSugar &&
      !this.stepCount && !this.sleepDuration) {
      this.saveMessage = '请至少填写一项健康数据';
      return false;
    }

    if ((this.bloodPressureSystolic && !this.bloodPressureDiastolic) ||
      (!this.bloodPressureSystolic && this.bloodPressureDiastolic)) {
      this.saveMessage = '血压请填写收缩压和舒张压两项';
      return false;
    }

    if (this.bloodPressureSystolic) {
      const val = Number(this.bloodPressureSystolic);
      if (isNaN(val) || val < 60 || val > 260) {
        this.saveMessage = '收缩压应在 60-260 范围内';
        return false;
      }
    }

    if (this.bloodPressureDiastolic) {
      const val = Number(this.bloodPressureDiastolic);
      if (isNaN(val) || val < 40 || val > 160) {
        this.saveMessage = '舒张压应在 40-160 范围内';
        return false;
      }
    }

    if (this.heartRate) {
      const val = Number(this.heartRate);
      if (isNaN(val) || val < 30 || val < 220) {
        this.saveMessage = '心率应在 30-220 范围内';
        return false;
      }
    }

    if (this.weight) {
      const val = Number(this.weight);
      if (isNaN(val) || val < 10 || val > 300) {
        this.saveMessage = '体重应在 10-300 kg 范围内';
        return false;
      }
    }

    if (this.bloodSugar) {
      const val = Number(this.bloodSugar);
      if (isNaN(val) || val < 1 || val > 40) {
        this.saveMessage = '血糖应在 1-40 mmol/L 范围内';
        return false;
      }
    }

    if (this.stepCount) {
      const val = Number(this.stepCount);
      if (isNaN(val) || val < 0 || val > 100000) {
        this.saveMessage = '步数应在合理范围内';
        return false;
      }
    }

    if (this.sleepDuration) {
      const val = Number(this.sleepDuration);
      if (isNaN(val) || val < 0 || val > 24) {
        this.saveMessage = '睡眠时长应在 0-24 小时范围内';
        return false;
      }
    }

    this.saveMessage = '';
    return true;
  }

  saveHealthData(): void {
    if (!this.validateInput()) {
      return;
    }

    this.isSaving = true;
    this.saveMessage = '';

    let bpValue: string | null = null;
    if (this.bloodPressureSystolic && this.bloodPressureDiastolic) {
      bpValue = '' + this.bloodPressureSystolic + '/' + this.bloodPressureDiastolic;
    }

    const recordData: HealthRecordInput = {
      "userId": 1,
      "bloodPressure": bpValue,
      "bloodSugar": this.bloodSugar ? this.bloodSugar : null,
      "heartRate": this.heartRate ? Number(this.heartRate) : null,
      "weight": this.weight ? this.weight : null,
      "stepCount": this.stepCount ? Number(this.stepCount) : null,
      "sleepDuration": this.sleepDuration ? this.sleepDuration : null
    };

    HttpUtil.post<string>(ApiConstants.HEALTH_RECORD_ADD, recordData)
      .then((response: BaseResponse<string>) => {
        this.isSaving = false;
        if (response.success) {
          this.saveMessage = '保存成功！';
          this.resetForm();
          this.loadLatestRecord();
        } else {
          this.saveMessage = response.message || '保存失败';
        }
      })
      .catch(() => {
        this.isSaving = false;
        this.saveMessage = '网络请求失败，请重试';
      });
  }

  resetForm(): void {
    this.bloodPressureSystolic = '';
    this.bloodPressureDiastolic = '';
    this.heartRate = '';
    this.weight = '';
    this.bloodSugar = '';
    this.stepCount = '';
    this.sleepDuration = '';
  }

  formatTime(timeStr: string): string {
    if (!timeStr) {
      return '--';
    }
    try {
      const date = new Date(timeStr);
      const month = String(date.getMonth() + 1).padStart(2, '0');
      const day = String(date.getDate()).padStart(2, '0');
      const hour = String(date.getHours()).padStart(2, '0');
      const minute = String(date.getMinutes()).padStart(2, '0');
      return '' + month + '-' + day + ' ' + hour + ':' + minute;
    } catch (e) {
      return timeStr.substring(0, 16);
    }
  }

  getBpStatus(bp: string | null): HealthMetricStatus {
    if (!bp) {
      const result: HealthMetricStatus = { text: '--', color: '#999999', icon: '' };
      return result;
    }
    const parts = bp.split('/');
    if (parts.length < 2) {
      const result2: HealthMetricStatus = { text: bp, color: '#999999', icon: '' };
      return result2;
    }
    const sys = Number(parts[0]);
    const dia = Number(parts[1]);
    if (sys >= 140 || dia >= 90) {
      const result3: HealthMetricStatus = { text: bp, color: '#FF4444', icon: '⚠️' };
      return result3;
    }
    if (sys <= 90 || dia <= 60) {
      const result4: HealthMetricStatus = { text: bp, color: '#FFA940', icon: '⚠️' };
      return result4;
    }
    const result5: HealthMetricStatus = { text: bp, color: '#52C41A', icon: '✅' };
    return result5;
  }

  getHeartRateStatus(hr: number | null): HealthMetricStatus {
    if (hr == null) {
      const result: HealthMetricStatus = { text: '--', color: '#999999', icon: '' };
      return result;
    }
    if (hr >= 100 || hr < 60) {
      const result2: HealthMetricStatus = { text: '' + hr, color: '#FF4444', icon: '⚠️' };
      return result2;
    }
    const result3: HealthMetricStatus = { text: '' + hr, color: '#52C41A', icon: '✅' };
    return result3;
  }

  build() {
    Column() {
      Header({ title: '我的健康', showBack: true })

      Scroll() {
        Column({ space: 16 }) {

          Text('手动录入')
            .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
            .fontWeight('bold')
            .fontColor('#1677FF')
            .margin({ top: 12, bottom: 8 });

          Column({ space: 14 }) {
            Row() {
              Text('📊 血压')
                .fontSize(15)
                .fontWeight('bold')
                .fontColor('#333333');
              Blank();
              TextInput({
                placeholder: '收缩压'
              })
                .width('25%')
                .height(36)
                .fontSize(13)
                .textAlign(TextAlign.Center)
                .backgroundColor('#F5F5F5')
                .borderRadius(8)
                .type(InputType.Number)
                .onChange((value: string) => {
                  this.bloodPressureSystolic = value;
                });
              Text('/')
                .fontSize(16)
                .fontColor('#666666')
                .margin({ left: 2, right: 2 });
              TextInput({
                placeholder: '舒张压'
              })
                .width('25%')
                .height(36)
                .fontSize(13)
                .textAlign(TextAlign.Center)
                .backgroundColor('#F5F5F5')
                .borderRadius(8)
                .type(InputType.Number)
                .onChange((value: string) => {
                  this.bloodPressureDiastolic = value;
                });
              Text('mmHg')
                .fontSize(12)
                .fontColor('#999999')
                .margin({ left: 4 });
            }
            .width('100%');

            Row() {
              Text('❤️ 心率')
                .fontSize(15)
                .fontWeight('bold')
                .fontColor('#333333');
              Blank();
              TextInput({
                placeholder: '如 75'
              })
                .width('35%')
                .height(36)
                .fontSize(13)
                .textAlign(TextAlign.Center)
                .backgroundColor('#F5F5F5')
                .borderRadius(8)
                .type(InputType.Number)
                .onChange((value: string) => {
                  this.heartRate = value;
                });
              Text('bpm')
                .fontSize(12)
                .fontColor('#999999')
                .margin({ left: 6 });
            }
            .width('100%');

            Row() {
              Text('🍬 血糖')
                .fontSize(15)
                .fontWeight('bold')
                .fontColor('#333333');
              Blank();
              TextInput({
                placeholder: '如 5.6'
              })
                .width('35%')
                .height(36)
                .fontSize(13)
                .textAlign(TextAlign.Center)
                .backgroundColor('#F5F5F5')
                .borderRadius(8)
                .type(InputType.Number)
                .onChange((value: string) => {
                  this.bloodSugar = value;
                });
              Text('mmol/L')
                .fontSize(12)
                .fontColor('#999999')
                .margin({ left: 6 });
            }
            .width('100%');

            Row() {
              Text('⚖️ 体重')
                .fontSize(15)
                .fontWeight('bold')
                .fontColor('#333333');
              Blank();
              TextInput({
                placeholder: '如 65.5'
              })
                .width('35%')
                .height(36)
                .fontSize(13)
                .textAlign(TextAlign.Center)
                .backgroundColor('#F5F5F5')
                .borderRadius(8)
                .type(InputType.Number)
                .onChange((value: string) => {
                  this.weight = value;
                });
              Text('kg')
                .fontSize(12)
                .fontColor('#999999')
                .margin({ left: 6 });
            }
            .width('100%');

            Row() {
              Text('👟 步数')
                .fontSize(15)
                .fontWeight('bold')
                .fontColor('#333333');
              Blank();
              TextInput({
                placeholder: '如 8000'
              })
                .width('35%')
                .height(36)
                .fontSize(13)
                .textAlign(TextAlign.Center)
                .backgroundColor('#F5F5F5')
                .borderRadius(8)
                .type(InputType.Number)
                .onChange((value: string) => {
                  this.stepCount = value;
                });
              Text('步')
                .fontSize(12)
                .fontColor('#999999')
                .margin({ left: 6 });
            }
            .width('100%');

            Row() {
              Text('😴 睡眠')
                .fontSize(15)
                .fontWeight('bold')
                .fontColor('#333333');
              Blank();
              TextInput({
                placeholder: '如 7.5'
              })
                .width('35%')
                .height(36)
                .fontSize(13)
                .textAlign(TextAlign.Center)
                .backgroundColor('#F5F5F5')
                .borderRadius(8)
                .type(InputType.Number)
                .onChange((value: string) => {
                  this.sleepDuration = value;
                });
              Text('小时')
                .fontSize(12)
                .fontColor('#999999')
                .margin({ left: 6 });
            }
            .width('100%');

            if (this.saveMessage) {
              Text(this.saveMessage)
                .fontSize(13)
                .fontColor(this.saveMessage.includes('成功') ? '#52C41A' : '#FF4444')
                .padding(8)
                .width('100%')
                .textAlign(TextAlign.Center)
                .backgroundColor(this.saveMessage.includes('成功') ? '#F6FFED' : '#FFF2F0')
                .borderRadius(8);
            }

            Button(this.isSaving ? '保存中...' : '保存数据')
              .width('100%')
              .height(44)
              .fontSize(16)
              .fontColor('#FFFFFF')
              .backgroundColor(this.isSaving ? '#CCCCCC' : '#1677FF')
              .borderRadius(22)
              .enabled(!this.isSaving)
              .onClick(() => this.saveHealthData());
          }
          .width('88%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12);

          Text('最新记录')
            .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
            .fontWeight('bold')
            .fontColor('#1677FF')
            .margin({ top: 8, bottom: 8 });

          if (this.isLoadingLatest) {
            Column() {
              LoadingProgress()
                .width(32)
                .height(32)
                .color('#1677FF');
              Text('加载中...')
                .fontSize(13)
                .fontColor('#999999')
                .margin({ top: 8 });
            }
            .width('88%')
            .height(140)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .backgroundColor('#FFFFFF')
            .borderRadius(12);
          } else if (!this.hasRecord) {
            Column() {
              Text('📭')
                .fontSize(36)
                .margin({ bottom: 8 });
              Text('暂无健康记录，请录入您的第一条数据')
                .fontSize(13)
                .fontColor('#999999')
                .textAlign(TextAlign.Center);
            }
            .width('88%')
            .height(120)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .backgroundColor('#FFFFFF')
            .borderRadius(12);
          } else {
            Column({ space: 12 }) {
              Row() {
                Text('更新时间: ' + this.formatTime(this.latestRecord.createTime))
                  .fontSize(12)
                  .fontColor('#999999');
                Blank();
                Text('查看详情 ›')
                  .fontSize(12)
                  .fontColor('#1677FF')
                  .onClick(() => {
                    router.pushUrl({ url: 'pages/HealthRecords' });
                  });
              }
              .width('100%');

              Row({ space: 8 }) {
                this.buildMetricCard(
                  '📊', '血压',
                  this.getBpStatus(this.latestRecord.bloodPressure),
                  'mmHg'
                );
                this.buildMetricCard(
                  '❤️', '心率',
                  this.getHeartRateStatus(this.latestRecord.heartRate),
                  'bpm'
                );
              }
              .width('100%');

              Row({ space: 8 }) {
                this.buildSimpleCard(
                  '🍬', '血糖',
                  this.latestRecord.bloodSugar != null ? '' + this.latestRecord.bloodSugar : '--',
                  'mmol/L'
                );
                this.buildSimpleCard(
                  '⚖️', '体重',
                  this.latestRecord.weight != null ? '' + this.latestRecord.weight : '--',
                  'kg'
                );
              }
              .width('100%');

              Row({ space: 8 }) {
                this.buildSimpleCard(
                  '👟', '步数',
                  this.latestRecord.stepCount != null ? '' + this.latestRecord.stepCount : '--',
                  '步'
                );
                this.buildSimpleCard(
                  '😴', '睡眠',
                  this.latestRecord.sleepDuration != null ? '' + this.latestRecord.sleepDuration : '--',
                  'h'
                );
              }
              .width('100%');
            }
            .width('88%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(12);

            Row() {
              Column() {
                Text('用药提醒')
                  .fontSize(14)
                  .fontWeight('bold')
                  .fontColor('#333333')
                  .margin({ bottom: 4 });
                Text('管理您的用药计划和提醒')
                  .fontSize(11)
                  .fontColor('#999999');
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start);
              Text('›')
                .fontSize(18)
                .fontColor('#999999');
            }
            .width('88%')
            .padding(14)
            .backgroundColor('#FFFFFF')
            .borderRadius(10)
            .margin({ top: 4 })
            .onClick(() => {
              router.pushUrl({ url: 'pages/Medications' });
            });

            Row() {
              Column() {
                Text('健康风险评估')
                  .fontSize(14)
                  .fontWeight('bold')
                  .fontColor('#333333')
                  .margin({ bottom: 4 });
                Text('评估您的健康风险状况')
                  .fontSize(11)
                  .fontColor('#999999');
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start);
              Text('›')
                .fontSize(18)
                .fontColor('#999999');
            }
            .width('88%')
            .padding(14)
            .backgroundColor('#FFFFFF')
            .borderRadius(10)
            .onClick(() => {
              router.pushUrl({ url: 'pages/RiskAssessmentPage' });
            });
          }
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .padding({ bottom: 80 });
      }
      .layoutWeight(1);

      Footer({ activeIndex: 4 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }

  @Builder
  buildMetricCard(icon: string, label: string, status: HealthMetricStatus, unit: string) {
    Column({ space: 4 }) {
      Row({ space: 3 }) {
        Text(status.icon)
          .fontSize(11);
        Text(status.text)
          .fontSize(18)
          .fontWeight('bold')
          .fontColor(status.color);
        Text(unit)
          .fontSize(10)
          .fontColor('#999999');
      }
      Text(label)
        .fontSize(11)
        .fontColor('#666666');
    }
    .layoutWeight(1)
    .padding(10)
    .backgroundColor('#F8F9FA')
    .borderRadius(10)
    .alignItems(HorizontalAlign.Center);
  }

  @Builder
  buildSimpleCard(icon: string, label: string, value: string, unit: string) {
    Column({ space: 4 }) {
      Row({ space: 3 }) {
        Text(value)
          .fontSize(18)
          .fontWeight('bold')
          .fontColor(value === '--' ? '#999999' : '#333333');
        Text(unit)
          .fontSize(10)
          .fontColor('#999999');
      }
      Text(label)
        .fontSize(11)
        .fontColor('#666666');
    }
    .layoutWeight(1)
    .padding(10)
    .backgroundColor('#F8F9FA')
    .borderRadius(10)
    .alignItems(HorizontalAlign.Center);
  }
}
