import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { AccessibilityConfig } from '../utils/AccessibilityConfig';

interface MetricData {
  label: string;
  value: string;
  unit: string;
  isNormal: boolean;
}

interface OrganInfo {
  id: string;
  name: string;
  icon: string;
  healthScore: number;
  status: string;
  statusColor: string;
  metrics: MetricData[];
}

interface RiskPredictionItem {
  disease: string;
  risk: string;
  riskLevel: number;
  color: string;
}

interface StatItem {
  label: string;
  value: string;
  color: string;
}

@Entry
@Component
struct DigitalTwinPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  organList: OrganInfo[] = [
    {
      id: 'heart',
      name: '心脏',
      icon: '❤️',
      healthScore: 95,
      status: '正常',
      statusColor: '#E74C3C',
      metrics: [
        { label: '心率', value: '72', unit: 'bpm', isNormal: true },
        { label: '血压', value: '128/82', unit: 'mmHg', isNormal: true }
      ]
    },
    {
      id: 'lungs',
      name: '肺部',
      icon: '🫁',
      healthScore: 88,
      status: '良好',
      statusColor: '#3498DB',
      metrics: [
        { label: '血氧', value: '96', unit: '%', isNormal: true },
        { label: '肺活量', value: '3.2', unit: 'L', isNormal: false }
      ]
    },
    {
      id: 'liver',
      name: '肝脏',
      icon: '🟤',
      healthScore: 92,
      status: '正常',
      statusColor: '#9B59B6',
      metrics: [
        { label: 'ALT', value: '28', unit: 'U/L', isNormal: true }
      ]
    },
    {
      id: 'kidney',
      name: '肾脏',
      icon: '🫘',
      healthScore: 90,
      status: '良好',
      statusColor: '#27AE60',
      metrics: [
        { label: '肌酐', value: '78', unit: 'μmol/L', isNormal: true }
      ]
    }
  ];

  riskPredictions: RiskPredictionItem[] = [
    { disease: '心血管疾病', risk: '中等风险', riskLevel: 35, color: '#E74C3C' },
    { disease: '糖尿病', risk: '低风险', riskLevel: 15, color: '#9B59B6' },
    { disease: '高血压', risk: '较低风险', riskLevel: 25, color: '#3498DB' }
  ];

  statItems: StatItem[] = [
    { label: '整体健康分', value: '91', color: '#4CAF50' },
    { label: '器官数量', value: '4', color: '#3498DB' },
    { label: '上次更新', value: '刚刚', color: '#9B59B6' }
  ];

  build(): void {
    Column() {
      Header({
        title: '数字孪生系统',
        showBack: true
      });

      Scroll() {
        Column({ space: AccessibilityConfig.getSpacingMD() }) {
          this.buildHeroSection()
          this.buildOrganGridSection()
          this.buildPredictionSection()
          this.buildActionButtons()
        }
        .width('85%')
        .padding({
          top: AccessibilityConfig.getSpacingLG(),
          bottom: AccessibilityConfig.getSpacingLG()
        })
      }
      .height(0)
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top);

      Footer({ activeIndex: -1 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AccessibilityConfig.getBgColor())
  }

  @Builder buildHeroSection() {
    Column({ space: 16 }) {
      Row({ space: 12 }) {
        Text('👤🔄')
          .fontSize(this.isElderMode ? 36 : 28)

        Column({ space: 4 }) {
          Text('您的3D数字分身')
            .fontSize(this.isElderMode ? 20 : 16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')

          Text('实时同步 · 器官可视化 · 预测模拟')
            .fontSize(this.isElderMode ? 13 : 11)
            .fontColor('#666666')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }

      Stack({ alignContent: Alignment.Center }) {
        Row() {
          Text('')
        }
        .width('100%')
        .height(200)
        .backgroundColor('#F8F9FF')
        .borderRadius(16)

        Column({ space: 8 }) {
          Text('🔄')
            .fontSize(64)
            .fontColor(AccessibilityConfig.getThemeColor())

          Text('3D人体模型渲染区')
            .fontSize(14)
            .fontColor('#999999')

          Text('点击查看完整模型 →')
              .fontSize(12)
              .fontColor(AccessibilityConfig.getThemeColor())
              .backgroundColor(AccessibilityConfig.getThemeColor() + '20')
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .borderRadius(16)
              .onClick(() => {
                router.pushUrl({ url: 'pages/DigitalTwinViewer' });
              })
        }
      }

      Row({ space: 8 }) {
        ForEach(this.statItems, (statItem: StatItem) => {
          Column({ space: 4 }) {
            Text(statItem.value)
              .fontSize(this.isElderMode ? 22 : 18)
              .fontWeight(FontWeight.Bold)
              .fontColor(statItem.color)

            Text(statItem.label)
              .fontSize(this.isElderMode ? 11 : 9)
              .fontColor('#999999')
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        }, (statItem: StatItem) => statItem.label)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .border({ width: 1, color: '#F0F0F0' })
  }

  @Builder buildOrganGridSection() {
    Column({ space: 12 }) {
      Row({ space: 8 }) {
        Text('🫀')
          .fontSize(20)

        Text('器官健康状态')
          .fontSize(this.isElderMode ? 16 : 14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')

        Text(`共 ${this.organList.length} 个器官`)
          .fontSize(this.isElderMode ? 12 : 10)
          .fontColor('#999999')
          .layoutWeight(1)
          .textAlign(TextAlign.End)
      }

      Grid() {
        ForEach(this.organList, (organ: OrganInfo) => {
          GridItem() {
            Column({ space: 8 }) {
              Row({ space: 6 }) {
                Text(organ.icon)
                  .fontSize(this.isElderMode ? 24 : 20)

                Text(organ.name)
                  .fontSize(this.isElderMode ? 15 : 13)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#333333')
                  .layoutWeight(1)

                Text(`${organ.healthScore}%`)
                  .fontSize(this.isElderMode ? 18 : 15)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(organ.statusColor)
              }
              .width('100%')

              Text(organ.status)
                .fontSize(this.isElderMode ? 12 : 10)
                .fontColor(organ.statusColor)
                .backgroundColor(organ.statusColor + '20')
                .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                .borderRadius(8)

              Divider().color('#F0F0F0').strokeWidth(1)

              Column({ space: 4 }) {
                ForEach(organ.metrics, (metric: MetricData) => {
                  Row() {
                    Text(metric.label)
                      .fontSize(this.isElderMode ? 11 : 9)
                      .fontColor('#666666')

                    Text(metric.value + metric.unit)
                      .fontSize(this.isElderMode ? 11 : 9)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(metric.isNormal ? '#4CAF50' : '#E74C3C')
                      .layoutWeight(1)
                      .textAlign(TextAlign.End)
                  }
                  .width('100%')
                }, (metric: MetricData) => metric.label)
              }
              .width('100%')
            }
            .width('100%')
            .padding(12)
            .backgroundColor('#FAFAFA')
            .borderRadius(10)
            .onClick(() => {
              router.pushUrl({
                url: 'pages/OrganDetailPage',
                params: { organId: organ.id }
              });
            })
          }
        }, (organ: OrganInfo) => organ.id)
      }
      .columnsTemplate('1fr 1fr')
      .columnsGap(10)
      .rowsGap(10)
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .border({ width: 1, color: '#F0F0F0' })
  }

  @Builder buildPredictionSection() {
    Column({ space: 12 }) {
      Row({ space: 8 }) {
        Text('🔮')
          .fontSize(20)

        Text('疾病风险预测')
          .fontSize(this.isElderMode ? 16 : 14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
      }

      Column({ space: 8 }) {
        ForEach(this.riskPredictions, (item: RiskPredictionItem) => {
          Row({ space: 12 }) {
            Column({ space: 4 }) {
              Text(item.disease)
                .fontSize(this.isElderMode ? 13 : 11)
                .fontColor('#333333')
                .fontWeight(FontWeight.Medium)

              Text(item.risk)
                .fontSize(this.isElderMode ? 11 : 9)
                .fontColor(item.color)
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            Column({ space: 4 }) {
              Text(`${item.riskLevel}%`)
                .fontSize(this.isElderMode ? 16 : 14)
                .fontWeight(FontWeight.Bold)
                .fontColor(item.color)

              Stack({ alignContent: Alignment.Start }) {
                Row()
                  .width(80)
                  .height(4)
                  .backgroundColor('#E0E0E0')
                  .borderRadius(2)

                Row()
                  .width(`${item.riskLevel}%`)
                  .height(4)
                  .backgroundColor(item.color)
                  .borderRadius(2)
              }
              .width(80)
            }
          }
          .width('100%')
          .padding(12)
          .backgroundColor('#FAFAFA')
          .borderRadius(8)
        }, (item: RiskPredictionItem) => item.disease)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .border({ width: 1, color: '#F0F0F0' })
  }

  @Builder buildActionButtons() {
    Row({ space: 12 }) {
      Button('查看完整3D模型')
        .flexGrow(1)
        .height(42)
        .fontSize(this.isElderMode ? 14 : 13)
        .backgroundColor(AccessibilityConfig.getThemeColor())
        .onClick(() => {
          router.pushUrl({ url: 'pages/DigitalTwinViewer' });
        })

      Button('生成预测报告')
        .flexGrow(1)
        .height(42)
        .fontSize(this.isElderMode ? 14 : 13)
        .backgroundColor('#F5F5F5')
        .fontColor('#666666')
        .onClick(() => {
          router.pushUrl({ url: 'pages/PredictionReportPage' });
        })
    }
    .width('100%')
  }
}
