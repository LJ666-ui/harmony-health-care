import { router } from '@kit.ArkUI';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';

interface MedicalRecordDetail {
  id: number;
  userId: number;
  hospitalId?: number;
  doctorId?: number;
  hospitalName?: string;
  doctorName?: string;
  department?: string;
  diagnosis: string;
  treatment: string;
  medication?: string;
  recordTime: string;
  isDesensitized?: number;
  createTime: string;
  updateTime: string;
}

@Entry
@Component
struct MedicalRecordDetailPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State record: MedicalRecordDetail | null = null;
  @State isLoading: boolean = true;

  aboutToAppear(): void {
    const params = router.getParams();
    if (params !== null && params !== undefined) {
      const paramRecord = params as Record<string, Object>;
      const recordData = paramRecord['record'];
      if (recordData !== null && recordData !== undefined) {
        this.record = recordData as MedicalRecordDetail;
      }
    }
    this.isLoading = false;
  }

  private formatDateTime(dateStr: string): string {
    if (!dateStr) return '-';
    try {
      const date = new Date(dateStr);
      const year = date.getFullYear();
      const month = String(date.getMonth() + 1).padStart(2, '0');
      const day = String(date.getDate()).padStart(2, '0');
      const hour = String(date.getHours()).padStart(2, '0');
      const minute = String(date.getMinutes()).padStart(2, '0');
      return `${year}-${month}-${day} ${hour}:${minute}`;
    } catch (e) {
      return dateStr;
    }
  }

  private handleExport(): void {
    ToastUtil.showSuccess('导出功能开发中');
  }

  private handleShare(): void {
    ToastUtil.showSuccess('分享功能开发中');
  }

  build() {
    Column() {
      Row({ space: 8 }) {
        Column()
          .width(40)
          .height(40)
          .borderRadius(20)
          .backgroundColor('#3498DB15')
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            router.back();
          }) {
            Text('←')
              .fontSize(18)
              .fontColor('#3498DB');
          }

        Text('病历详情')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center);

        Blank().width(40);
      }
      .width('100%')
      .height(56)
      .backgroundColor('#FFFFFF')
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .shadow({
        radius: 2,
        color: '#1A00000020',
        offsetX: 0,
        offsetY: 1
      });

      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(50)
            .height(50)
            .color('#3498DB');
          Text('加载中...')
            .fontSize(16)
            .fontColor('#999999')
            .margin({ top: 12 });
        }
        .layoutWeight(1)
        .width('100%')
        .justifyContent(FlexAlign.Center);
      } else if (this.record === null) {
        Column() {
          Text('❌')
            .fontSize(48)
            .margin({ bottom: 16 });
          Text('未找到病历信息')
            .fontSize(16)
            .fontColor('#999999');
        }
        .layoutWeight(1)
        .width('100%')
        .justifyContent(FlexAlign.Center);
      } else {
        Scroll() {
          Column({ space: 16 }) {
            Column() {
              Row() {
                Text(`病历 #${this.record!.id}`)
                  .fontSize(this.isElderMode ? 22 : 20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(GlobalTheme.TEXT_PRIMARY);

                Blank();

                Text(this.formatDateTime(this.record!.recordTime))
                  .fontSize(12)
                  .fontColor('#999999');
              }
              .width('100%');
            }
            .width('100%')
            .padding(20)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 });

            Column() {
              Text('诊断信息')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#E74C3C')
                .margin({ bottom: 12 });

              Text(this.record!.diagnosis || '暂无诊断信息')
                .fontSize(this.isElderMode ? 18 : 16)
                .fontColor(GlobalTheme.TEXT_PRIMARY)
                .lineHeight(24);
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .padding(20)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 });

            Column() {
              Text('治疗方案')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#3498DB')
                .margin({ bottom: 12 });

              Text(this.record!.treatment || '暂无治疗方案')
                .fontSize(this.isElderMode ? 18 : 16)
                .fontColor(GlobalTheme.TEXT_PRIMARY)
                .lineHeight(24);
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .padding(20)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 });

            if (this.record!.medication && this.record!.medication.length > 0) {
              Column() {
                Text('用药建议')
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#27AE60')
                  .margin({ bottom: 12 });

                Text(this.record!.medication)
                  .fontSize(this.isElderMode ? 18 : 16)
                  .fontColor(GlobalTheme.TEXT_PRIMARY)
                  .lineHeight(24);
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
              .padding(20)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 });
            }

            Column() {
              Text('详细信息')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .margin({ bottom: 12 });

              Column({ space: 8 }) {
                Row() {
                  Text('患者ID：')
                    .fontSize(14)
                    .fontColor('#666666')
                    .width(80);
                  Text(String(this.record!.userId))
                    .fontSize(14)
                    .fontColor(GlobalTheme.TEXT_PRIMARY)
                    .layoutWeight(1);
                }
                .width('100%');

                if (this.record!.hospitalName) {
                  Row() {
                    Text('医院：')
                      .fontSize(14)
                      .fontColor('#666666')
                      .width(80);
                    Text(this.record!.hospitalName)
                      .fontSize(14)
                      .fontColor(GlobalTheme.TEXT_PRIMARY)
                      .layoutWeight(1);
                  }
                  .width('100%');
                }

                if (this.record!.department) {
                  Row() {
                    Text('科室：')
                      .fontSize(14)
                      .fontColor('#666666')
                      .width(80);
                    Text(this.record!.department)
                      .fontSize(14)
                      .fontColor(GlobalTheme.TEXT_PRIMARY)
                      .layoutWeight(1);
                  }
                  .width('100%');
                }

                if (this.record!.doctorName) {
                  Row() {
                    Text('医生：')
                      .fontSize(14)
                      .fontColor('#666666')
                      .width(80);
                    Text(this.record!.doctorName)
                      .fontSize(14)
                      .fontColor(GlobalTheme.TEXT_PRIMARY)
                      .layoutWeight(1);
                  }
                  .width('100%');
                }

                Row() {
                  Text('创建时间：')
                    .fontSize(14)
                    .fontColor('#666666')
                    .width(80);
                  Text(this.formatDateTime(this.record!.createTime))
                    .fontSize(14)
                    .fontColor(GlobalTheme.TEXT_PRIMARY)
                    .layoutWeight(1);
                }
                .width('100%');

                Row() {
                  Text('更新时间：')
                    .fontSize(14)
                    .fontColor('#666666')
                    .width(80);
                  Text(this.formatDateTime(this.record!.updateTime))
                    .fontSize(14)
                    .fontColor(GlobalTheme.TEXT_PRIMARY)
                    .layoutWeight(1);
                }
                .width('100%');
              }
              .width('100%');
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .padding(20)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 });

            Row({ space: 12 }) {
              Button('导出')
                .fontSize(16)
                .height(48)
                .fontColor('#FFFFFF')
                .backgroundColor('#3498DB')
                .borderRadius(24)
                .layoutWeight(1)
                .onClick(() => {
                  this.handleExport();
                });

              Button('分享')
                .fontSize(16)
                .height(48)
                .fontColor('#FFFFFF')
                .backgroundColor('#27AE60')
                .borderRadius(24)
                .layoutWeight(1)
                .onClick(() => {
                  this.handleShare();
                });
            }
            .width('100%')
            .margin({ top: 8, bottom: 20 });
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 16 });
        }
        .layoutWeight(1)
        .width('100%')
        .scrollBar(BarState.Off);
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5');
  }
}
