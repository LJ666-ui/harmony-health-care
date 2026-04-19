import { router } from '@kit.ArkUI';

interface RiskLevel {
  level: string;
  color: string;
  icon: string;
  message: string;
}

interface RiskItem {
  id: string;
  name: string;
  level: string;
  levelColor: string;
  icon: string;
  description: string;
}

@Entry
@Component
struct RiskResultPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State riskLevel: RiskLevel = {
    level: '中风险',
    color: '#FAAD14',
    icon: '🟡',
    message: '需要注意几点'
  };

  @State riskItems: RiskItem[] = [
    { id: '1', name: '高血压', level: '中风险', levelColor: '#FAAD14', icon: '🩺', description: '血压偏高，建议定期监测' },
    { id: '2', name: '糖尿病', level: '低风险', levelColor: '#52C41A', icon: '💉', description: '血糖在正常范围内' },
    { id: '3', name: '跌倒', level: '中风险', levelColor: '#FAAD14', icon: '🧓', description: '存在跌倒风险，建议加强平衡训练' },
    { id: '4', name: '衰弱', level: '低风险', levelColor: '#52C41A', icon: '💪', description: '身体状况良好' },
    { id: '5', name: '肌少症', level: '低风险', levelColor: '#52C41A', icon: '🏋️', description: '肌肉量正常' }
  ];

  @State aiSuggestions: string[] = [
    '建议每周进行至少150分钟的中等强度有氧运动，如散步、太极拳等',
    '饮食方面，建议减少盐的摄入，多吃新鲜蔬菜水果',
    '定期监测血压，建议每天固定时间测量并记录',
    '保持良好的作息习惯，保证充足的睡眠时间',
    '建议每年进行一次全面的健康体检'
  ];

  getLevelBgColor(levelColor: string): string {
    if (levelColor === '#52C41A') {
      return '#F6FFED';
    }
    if (levelColor === '#FAAD14') {
      return '#FFFBE6';
    }
    return '#FFF1F0';
  }

  handleViewReport() {
    console.log('查看详细报告');
  }

  handleShare() {
    console.log('分享给医生');
  }

  handleReassess() {
    router.push({ url: 'pages/RiskAssessmentPage' });
  }

  handleRehabPlan() {
    console.log('制定康复计划');
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text('← 返回')
          .fontSize(16)
          .fontColor('#1677FF')
          .padding(12)
          .onClick(() => {
            router.back();
          });
        Text('评估结果')
          .fontSize(18)
          .fontWeight('bold')
          .flexGrow(1)
          .textAlign(TextAlign.Center);
        Text('历史')
          .fontSize(16)
          .fontColor('#1677FF')
          .padding(12)
          .onClick(() => {
            router.push({ url: 'pages/RiskHistoryPage' });
          });
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
      .shadow({ radius: 4, color: '#00000010', offsetX: 0, offsetY: 2 });

      Scroll() {
        Column() {
          // 综合风险等级
          Column() {
            Text(this.riskLevel.icon)
              .fontSize(64)
              .margin({ bottom: 16 });
            Text(this.riskLevel.level)
              .fontSize(32)
              .fontWeight('bold')
              .fontColor(this.riskLevel.color)
              .margin({ bottom: 8 });
            Text(this.riskLevel.message)
              .fontSize(16)
              .fontColor('#666666');
          }
          .width('100%')
          .padding(32)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .alignItems(HorizontalAlign.Center)
          .margin({ top: 24, bottom: 24 });

          // 五项风险详情卡片
          Text('风险详情')
            .fontSize(20)
            .fontWeight('bold')
            .fontColor('#333333')
            .margin({ bottom: 16 });

          ForEach(this.riskItems, (item: RiskItem) => {
            Column() {
              Row() {
                Text(item.icon)
                  .fontSize(32)
                  .margin({ right: 16 });
                Column() {
                  Row() {
                    Text(item.name)
                      .fontSize(16)
                      .fontWeight('bold')
                      .fontColor('#333333')
                      .flexGrow(1);
                    Text(item.level)
                      .fontSize(14)
                      .fontWeight('bold')
                      .fontColor(item.levelColor)
                      .padding({ left: 12, right: 12, top: 4, bottom: 4 })
                      .backgroundColor(this.getLevelBgColor(item.levelColor))
                      .borderRadius(12);
                  }
                  Text(item.description)
                    .fontSize(14)
                    .fontColor('#666666')
                    .margin({ top: 4 });
                }
                .flexGrow(1);
              }
              .width('100%');
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .margin({ bottom: 12 });
          });

          // AI解读建议
          Column() {
            Row() {
              Text('🤖 AI解读建议')
                .fontSize(18)
                .fontWeight('bold')
                .fontColor('#333333');
            }
            .width('100%')
            .margin({ bottom: 16 });

            ForEach(this.aiSuggestions, (suggestion: string, index: number) => {
              Row() {
                Text((index + 1) + '.')
                  .fontSize(14)
                  .fontColor('#1677FF')
                  .fontWeight('bold')
                  .margin({ right: 8 });
                Text(suggestion)
                  .fontSize(14)
                  .fontColor('#666666')
                  .flexGrow(1);
              }
              .width('100%')
              .margin({ bottom: 8 });
            });
          }
          .width('100%')
          .padding(20)
          .backgroundColor('#F0F7FF')
          .borderRadius(16)
          .margin({ top: 24, bottom: 24 });

          // 操作按钮
          Column() {
            Row() {
              Button('查看详细报告')
                .width('48%')
                .height(48)
                .fontSize(14)
                .fontColor('#1677FF')
                .backgroundColor('#FFFFFF')
                .borderRadius(24)
                .border({ width: 1, color: '#1677FF' })
                .onClick(() => {
                  this.handleViewReport();
                });
              Button('分享给医生')
                .width('48%')
                .height(48)
                .fontSize(14)
                .fontColor('#1677FF')
                .backgroundColor('#FFFFFF')
                .borderRadius(24)
                .border({ width: 1, color: '#1677FF' })
                .margin({ left: 12 })
                .onClick(() => {
                  this.handleShare();
                });
            }
            .width('100%')
            .margin({ bottom: 12 });

            Row() {
              Button('重新评估')
                .width('48%')
                .height(48)
                .fontSize(14)
                .fontColor('#1677FF')
                .backgroundColor('#FFFFFF')
                .borderRadius(24)
                .border({ width: 1, color: '#1677FF' })
                .onClick(() => {
                  this.handleReassess();
                });
              Button('制定康复计划')
                .width('48%')
                .height(48)
                .fontSize(14)
                .fontColor('#FFFFFF')
                .backgroundColor('#1677FF')
                .borderRadius(24)
                .margin({ left: 12 })
                .onClick(() => {
                  this.handleRehabPlan();
                });
            }
            .width('100%');
          }
          .width('100%')
          .margin({ bottom: 48 });
        }
        .width('85%')
        .padding({ top: 24, bottom: 48 });
      }
      .height(0)
      .layoutWeight(1)

    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }
}
