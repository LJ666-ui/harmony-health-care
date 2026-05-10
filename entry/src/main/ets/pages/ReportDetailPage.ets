import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { HealthService, CheckupReport, CheckupItem } from '../services/HealthService';
import { ToastUtil } from '../common/utils/ToastUtil';

interface ReportRouterParams {
  reportId: number;
}

@Entry
@Component
struct ReportDetailPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State report: CheckupReport | null = null;
  @State isLoading: boolean = true;
  
  private healthService: HealthService = HealthService.getInstance();

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') || false;
    }
    
    const params = router.getParams() as ReportRouterParams;
    if (params && params.reportId) {
      this.loadReport(params.reportId);
    } else {
      ToastUtil.showError('报告ID缺失');
      router.back();
    }
  }

  async loadReport(reportId: number): Promise<void> {
    this.isLoading = true;
    try {
      const data = await this.healthService.getCheckupReportDetail(reportId);
      if (data) {
        this.report = data;
      } else {
        ToastUtil.showError('加载报告失败');
      }
    } catch (error) {
      console.error('[ReportDetailPage] 加载报告异常:', error);
      ToastUtil.showError('加载报告失败');
    } finally {
      this.isLoading = false;
    }
  }

  private getTitleFontSize(): number {
    return this.isElderMode ? 18 : 16;
  }

  private getBodyFontSize(): number {
    return this.isElderMode ? 14 : 12;
  }

  build() {
    Column() {
      Header({ title: '体检报告详情', showBack: true });

      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(50)
            .height(50)
            .color('#27AE60')
          Text('加载中...')
            .fontSize(14)
            .fontColor('#999')
            .margin({ top: 10 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.report) {
        Scroll() {
          Column({ space: 15 }) {
            this.buildBasicInfo();
            this.buildSummary();
            this.buildCheckupItems();
            this.buildDoctorAdvice();
          }
          .width('100%')
          .padding(15);
        }
        .layoutWeight(1)
        .scrollBar(BarState.Auto);
      } else {
        Column() {
          Text('📊')
            .fontSize(60)
          Text('报告信息加载失败')
            .fontSize(16)
            .fontColor('#999')
            .margin({ top: 10 })
          Text('请返回重试')
            .fontSize(14)
            .fontColor('#CCCCCC')
            .margin({ top: 5 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center);
      }
    }
    .height('100%')
    .backgroundColor('#F5F5F5');
  }

  @Builder buildBasicInfo(): void {
    Column({ space: 10 }) {
      Text('报告信息')
        .fontSize(this.getTitleFontSize())
        .fontWeight(FontWeight.Bold)
        .fontColor('#333')
        .width('100%');

      Row() {
        Text('报告编号：')
          .fontSize(this.getBodyFontSize())
          .fontColor('#666');
        Text(this.report!.reportNo)
          .fontSize(this.getBodyFontSize())
          .fontColor('#333')
          .layoutWeight(1);
      }
      .width('100%');

      Row() {
        Text('体检人：')
          .fontSize(this.getBodyFontSize())
          .fontColor('#666');
        Text('本人')
          .fontSize(this.getBodyFontSize())
          .fontColor('#333')
          .layoutWeight(1);
      }
      .width('100%');

      Row() {
        Text('体检日期：')
          .fontSize(this.getBodyFontSize())
          .fontColor('#666');
        Text(this.report!.checkupDate)
          .fontSize(this.getBodyFontSize())
          .fontColor('#333')
          .layoutWeight(1);
      }
      .width('100%');

      Row() {
        Text('体检机构：')
          .fontSize(this.getBodyFontSize())
          .fontColor('#666');
        Text(this.report!.hospitalName)
          .fontSize(this.getBodyFontSize())
          .fontColor('#333')
          .layoutWeight(1);
      }
      .width('100%');

      Row() {
        Text('报告类型：')
          .fontSize(this.getBodyFontSize())
          .fontColor('#666');
        Text(this.getReportTypeText(this.report!.reportType))
          .fontSize(this.getBodyFontSize())
          .fontColor('#333')
          .layoutWeight(1);
      }
      .width('100%');
    }
    .width('100%')
    .padding(15)
    .backgroundColor('#FFFFFF')
    .borderRadius(8);
  }

  @Builder buildSummary(): void {
    Column({ space: 10 }) {
      Text('报告摘要')
        .fontSize(this.getTitleFontSize())
        .fontWeight(FontWeight.Bold)
        .fontColor('#333')
        .width('100%');

      Text(this.report!.reportSummary || '暂无摘要信息')
        .fontSize(this.getBodyFontSize())
        .fontColor('#333')
        .width('100%')
        .lineHeight(20);

      Row() {
        Text(`异常项：${this.report!.abnormalItems.length}项`)
          .fontSize(this.getBodyFontSize())
          .fontColor(this.report!.abnormalItems.length > 0 ? '#E74C3C' : '#27AE60')
          .fontWeight(FontWeight.Medium);
      }
      .width('100%')
      .margin({ top: 5 });
    }
    .width('100%')
    .padding(15)
    .backgroundColor('#FFFFFF')
    .borderRadius(8);
  }

  @Builder buildCheckupItems(): void {
    Column({ space: 10 }) {
      Row() {
        Text('体检项目')
          .fontSize(this.getTitleFontSize())
          .fontWeight(FontWeight.Bold)
          .fontColor('#333')
          .layoutWeight(1);

        Row({ space: 8 }) {
          Row() {
            Text('正常')
              .fontSize(10)
              .fontColor('#FFFFFF')
              .backgroundColor('#27AE60')
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .borderRadius(3);
          }

          Row() {
            Text('异常')
              .fontSize(10)
              .fontColor('#FFFFFF')
              .backgroundColor('#E74C3C')
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .borderRadius(3);
          }

          Row() {
            Text('注意')
              .fontSize(10)
              .fontColor('#FFFFFF')
              .backgroundColor('#F39C12')
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .borderRadius(3);
          }
        }
      }
      .width('100%');

      if (this.report!.abnormalItems.length > 0) {
        ForEach(this.report!.abnormalItems, (item: CheckupItem) => {
          Row() {
            Column() {
              Text(item.itemName)
                .fontSize(this.getBodyFontSize())
                .fontColor('#333')
                .fontWeight(FontWeight.Medium)
                .width('100%');

              Row() {
                Text(`结果：${item.result} ${item.unit}`)
                  .fontSize(this.isElderMode ? 12 : 10)
                  .fontColor('#666');

                Text(`  参考：${item.referenceRange}`)
                  .fontSize(this.isElderMode ? 12 : 10)
                  .fontColor('#999');
              }
              .width('100%')
              .margin({ top: 4 });
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1);

            this.buildStatusTag(item.status);
          }
          .width('100%')
          .padding(12)
          .backgroundColor(this.getStatusBackgroundColor(item.status))
          .borderRadius(8);
        });
      } else {
        Text('暂无体检项目数据')
          .fontSize(this.getBodyFontSize())
          .fontColor('#999')
          .width('100%')
          .textAlign(TextAlign.Center)
          .padding({ top: 20, bottom: 20 });
      }
    }
    .width('100%')
    .padding(15)
    .backgroundColor('#FFFFFF')
    .borderRadius(8);
  }

  @Builder buildStatusTag(status: string): void {
    if (status === 'abnormal') {
      Text('异常')
        .fontSize(this.isElderMode ? 12 : 10)
        .fontColor('#FFFFFF')
        .backgroundColor('#E74C3C')
        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
        .borderRadius(4);
    } else if (status === 'attention') {
      Text('注意')
        .fontSize(this.isElderMode ? 12 : 10)
        .fontColor('#FFFFFF')
        .backgroundColor('#F39C12')
        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
        .borderRadius(4);
    } else {
      Text('正常')
        .fontSize(this.isElderMode ? 12 : 10)
        .fontColor('#FFFFFF')
        .backgroundColor('#27AE60')
        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
        .borderRadius(4);
    }
  }

  @Builder buildDoctorAdvice(): void {
    Column({ space: 10 }) {
      Text('医生建议')
        .fontSize(this.getTitleFontSize())
        .fontWeight(FontWeight.Bold)
        .fontColor('#333')
        .width('100%');

      Text(this.report!.doctorAdvice || '暂无医生建议')
        .fontSize(this.getBodyFontSize())
        .fontColor('#333')
        .width('100%')
        .lineHeight(20);
    }
    .width('100%')
    .padding(15)
    .backgroundColor('#FFFFFF')
    .borderRadius(8);
  }

  private getReportTypeText(type: string): string {
    switch (type) {
      case 'annual':
        return '年度体检';
      case 'special':
        return '专项检查';
      case 'follow_up':
        return '复查';
      default:
        return type;
    }
  }

  private getStatusBackgroundColor(status: string): string {
    switch (status) {
      case 'abnormal':
        return '#FFF3E0';
      case 'attention':
        return '#FFF8E1';
      default:
        return '#FFFFFF';
    }
  }
}
