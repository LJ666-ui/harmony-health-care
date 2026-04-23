import { router } from '@kit.ArkUI';
import { HttpUtil } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';

class HealthStandard {
  id: number = 0;
  indicatorName: string = '';
  minValue: string = '';
  maxValue: string = '';
  unit: string = '';
  ageGroup: string = '';
  gender: number = 0;
  standardDesc: string = '';
}

class AssessmentData {
  age: string = '';
  gender: string = '男';
  height: string = '';
  weight: string = '';
  bmi: number = 0;
  systolic: string = '';
  diastolic: string = '';
  fastingGlucose: string = '';
  postprandialGlucose: string = '';
  smoking: string = '否';
  drinking: string = '否';
  exercise: string = '每周1-2次';
  medicalHistory: string[] = [];
}

class PageParams {
  assessmentData: AssessmentData = new AssessmentData();
}

@Entry
@Component
struct RiskDetailPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State standards: HealthStandard[] = [];
  @State isLoading: boolean = true;
  @State assessmentData: AssessmentData = new AssessmentData();

  aboutToAppear(): void {
    const params = router.getParams() as PageParams;
    if (params && params.assessmentData) {
      this.assessmentData = params.assessmentData;
    }
    this.loadStandards();
  }

  private loadStandards(): void {
    this.isLoading = true;
    HttpUtil.get<HealthStandard[]>(ApiConstants.HEALTH_STANDARD_LIST, undefined, { showLoading: true, loadingText: '加载评分标准...' })
      .then((response) => {
        if (response.success && response.data) {
          this.standards = response.data as HealthStandard[];
        }
      })
      .catch((err: Error) => {
        console.error('[RiskDetailPage] 加载评分标准失败:', err.message);
      })
      .finally(() => {
        this.isLoading = false;
      });
  }

  getStandardForIndicator(indicatorName: string): HealthStandard | null {
    for (let i: number = 0; i < this.standards.length; i++) {
      const s: HealthStandard = this.standards[i];
      if (s.indicatorName === indicatorName || s.indicatorName.indexOf(indicatorName) >= 0) {
        return s;
      }
    }
    return null;
  }

  getUserValue(indicatorName: string): string {
    const data: AssessmentData = this.assessmentData;
    switch (indicatorName) {
      case '收缩压': return data.systolic || '--';
      case '舒张压': return data.diastolic || '--';
      case '空腹血糖': return data.fastingGlucose || '--';
      case '餐后血糖': return data.postprandialGlucose || '--';
      case 'BMI': return data.bmi > 0 ? data.bmi.toString() : '--';
      default: return '--';
    }
  }

  getValueStatusColor(indicatorName: string): string {
    const valueStr: string = this.getUserValue(indicatorName);
    if (valueStr === '--') { return '#999999'; }
    const value: number = parseFloat(valueStr);
    const std: HealthStandard | null = this.getStandardForIndicator(indicatorName);
    if (!std) { return '#52C41A'; }
    const minV: number = parseFloat(std.minValue);
    const maxV: number = parseFloat(std.maxValue);
    if (value < minV || value > maxV) { return '#FF4D4F'; }
    return '#52C41A';
  }

  getStatusText(color: string): string {
    if (color === '#FF4D4F') { return '偏高' };
    if (color === '#FAAD14') { return '临界' };
    return '正常';
  }

  build() {
    Column() {
      Row() {
        Text('← 返回')
          .fontSize(16)
          .fontColor('#1677FF')
          .padding(12)
          .onClick(() => {
            router.back();
          });
        Text('详细报告')
          .fontSize(18)
          .fontWeight('bold')
          .flexGrow(1)
          .textAlign(TextAlign.Center);
        Text('')
          .fontSize(16)
          .padding(12);
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
      .shadow({ radius: 4, color: '#00000010', offsetX: 0, offsetY: 2 });

      if (this.isLoading) {
        Column() {
          Text('加载中...')
            .fontSize(16)
            .fontColor('#999999');
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center);
      } else {
        Scroll() {
          Column() {
            Text('健康指标评分标准')
              .fontSize(20)
              .fontWeight('bold')
              .fontColor('#333333')
              .margin({ bottom: 8 });
            Text('以下数据来源于权威医学标准，供您参考')
              .fontSize(13)
              .fontColor('#999999')
              .margin({ bottom: 24 });

            ForEach(this.standards, (standard: HealthStandard) => {
              Column() {
                Row() {
                  Text('📊')
                    .fontSize(24)
                    .margin({ right: 12 });
                  Column() {
                    Row() {
                      Text(standard.indicatorName)
                        .fontSize(17)
                        .fontWeight('bold')
                        .fontColor('#333333')
                        .flexGrow(1);
                      Text(this.getStatusText(this.getValueStatusColor(standard.indicatorName)))
                        .fontSize(13)
                        .fontWeight('bold')
                        .fontColor(this.getValueStatusColor(standard.indicatorName))
                        .padding({ left: 10, right: 10, top: 3, bottom: 3 })
                        .backgroundColor(this.getValueStatusColor(standard.indicatorName) + '15')
                        .borderRadius(10);
                    }
                    .width('100%');

                    if (this.getUserValue(standard.indicatorName) !== '--') {
                      Row() {
                        Text('您的数值：')
                          .fontSize(14)
                          .fontColor('#666666');
                        Text(this.getUserValue(standard.indicatorName) + ' ' + standard.unit)
                          .fontSize(14)
                          .fontWeight('bold')
                          .fontColor(this.getValueStatusColor(standard.indicatorName));
                      }
                      .width('100%')
                      .margin({ top: 6, bottom: 10 });
                    }

                    Row() {
                      Column() {
                        Text('正常下限')
                          .fontSize(12)
                          .fontColor('#999999');
                        Text(standard.minValue + ' ' + standard.unit)
                          .fontSize(16)
                          .fontWeight('bold')
                          .fontColor('#333333')
                          .margin({ top: 4 });
                      }
                      .layoutWeight(1);

                      Column() {
                        Text('正常上限')
                          .fontSize(12)
                          .fontColor('#999999');
                        Text(standard.maxValue + ' ' + standard.unit)
                          .fontSize(16)
                          .fontWeight('bold')
                          .fontColor('#333333')
                          .margin({ top: 4 });
                      }
                      .layoutWeight(1);
                    }
                    .width('100%');

                    if (standard.standardDesc && standard.standardDesc !== '') {
                      Text('📌 ' + standard.standardDesc)
                        .fontSize(13)
                        .fontColor('#666666')
                        .width('100%')
                        .margin({ top: 10 })
                        .lineHeight(18);
                    }

                    if (standard.ageGroup && standard.ageGroup !== '') {
                      Row() {
                        Text('适用人群：')
                          .fontSize(12)
                          .fontColor('#999999');
                        Text(standard.ageGroup)
                          .fontSize(12)
                          .fontColor('#1677FF');
                      }
                      .width('100%')
                      .margin({ top: 8 });
                    }
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start);
                }
                .width('100%')
                .alignItems(VerticalAlign.Top);
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .margin({ bottom: 12 })
              .shadow({ radius: 6, color: '#00000008', offsetX: 0, offsetY: 2 });
            }, (standard: HealthStandard) => standard.id.toString());
          }
          .width('85%')
          .padding({ top: 24, bottom: 48 });
        }
        .height(0)
        .layoutWeight(1)
        .scrollBar(BarState.Off);
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }
}
