import { router } from '@kit.ArkUI';
import { Footer } from '../components/Footer';

export interface ScienceArticle {
  id: string;
  title: string;
  coverIcon: string;
  summary: string;
  publishTime: string;
  category: string;
  readCount: string;
}

@Entry
@Component
struct ScienceListPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State articles: ScienceArticle[] = [
    {
      id: '1',
      title: '高血压患者的日常饮食指南',
      coverIcon: '🩺',
      summary: '科学合理的饮食是控制血压的重要手段，本文详细介绍高血压患者应遵循的饮食原则和注意事项。',
      publishTime: '2026-04-08',
      category: '心血管健康',
      readCount: '3.2k'
    },
    {
      id: '2',
      title: '颈椎病预防与康复锻炼方法',
      coverIcon: '🦴',
      summary: '长期伏案工作容易导致颈椎问题，学习正确的坐姿和颈部锻炼方法，有效预防和缓解颈椎病。',
      publishTime: '2026-04-07',
      category: '骨科康复',
      readCount: '2.8k'
    },
    {
      id: '3',
      title: '糖尿病患者的运动处方',
      coverIcon: '🏃',
      summary: '适度运动对糖尿病患者血糖控制有显著帮助，了解适合的运动类型、强度和时间安排。',
      publishTime: '2026-04-05',
      category: '内分泌',
      readCount: '4.1k'
    },
    {
      id: '4',
      title: '老年人跌倒风险评估与预防',
      coverIcon: '🧓',
      summary: '老年人跌倒是常见的意外伤害，掌握风险评估方法和预防措施，保护家人安全。',
      publishTime: '2026-04-03',
      category: '老年医学',
      readCount: '1.9k'
    },
    {
      id: '5',
      title: '心理健康：焦虑与抑郁的自我调节',
      coverIcon: '🧠',
      summary: '现代生活压力下，心理问题日益普遍。学会识别情绪信号，掌握科学的自我调节方法。',
      publishTime: '2026-04-01',
      category: '心理健康',
      readCount: '5.6k'
    },
    {
      id: '6',
      title: '春季过敏防治全攻略',
      coverIcon: '🌸',
      summary: '花粉、柳絮等过敏原在春季活跃，了解过敏症状识别、预防措施及合理用药建议。',
      publishTime: '2026-03-28',
      category: '过敏防治',
      readCount: '2.3k'
    }
  ];

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    }
  }

  build() {
    Column() {
      Row() {
        Text('←')
          .fontSize(24)
          .fontColor('#1677FF')
          .width(40)
          .height(40)
          .textAlign(TextAlign.Center)
          .backgroundColor('#E6F4FF')
          .borderRadius(20)
          .onClick(() => {
            router.back();
          })
        Text('健康科普')
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

      List() {
        ForEach(this.articles, (article: ScienceArticle) => {
          ListItem() {
            Row() {
              Column() {
                Text(article.coverIcon).fontSize(36)
              }
              .width(64)
              .height(64)
              .backgroundColor('#F0F5FF')
              .borderRadius(12)
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)

              Column() {
                Text(article.title)
                  .fontSize(this.isElderMode ? 20 : 16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#333333')
                  .maxLines(2)

                Text(article.summary)
                  .fontSize(this.isElderMode ? 16 : 13)
                  .fontColor('#999999')
                  .maxLines(2)
                  .margin({ top: 6 })

                Row() {
                  Text(article.category)
                    .fontSize(11)
                    .fontColor('#1677FF')
                    .backgroundColor('#E6F4FF')
                    .padding({ left: 8, right: 8, top: 3, bottom: 3 })
                    .borderRadius(4)

                  Text(`👁 ${article.readCount}`)
                    .fontSize(11)
                    .fontColor('#999999')
                    .margin({ left: 12 })

                  Text(article.publishTime)
                    .fontSize(11)
                    .fontColor('#BBBBBB')
                }
                .width('100%')
                .margin({ top: 8 })
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
              .margin({ left: 12 })
            }
          }
          .width('100%')
          .margin({ bottom: 10 })
          .padding(14)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .border({ width: 1, color: '#F0F0F0' })
          .onClick(() => {
            router.pushUrl({
              url: 'pages/ScienceDetailPage',
              params: { articleId: article.id }
            });
          });
        }, (article: ScienceArticle) => article.id);
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: '7.5%', right: '7.5%' })

      Footer({ activeIndex: 3 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }
}
