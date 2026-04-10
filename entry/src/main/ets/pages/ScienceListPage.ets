import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
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

  build() {
    Column() {
      Header({ title: '健康科普', showBack: true });

      Scroll() {
        Column({ space: 14 }) {
          Text('健康科普')
            .fontSize(22)
            .fontWeight('bold')
            .fontColor('#1677FF')
            .margin({ top: 16, bottom: 8 });

          List({ space: 12 }) {
            ForEach(this.articles, (article: ScienceArticle) => {
              ListItem() {
                Column() {
                  Row({ space: 14 }) {
                    Column() {
                      Text(article.coverIcon)
                        .fontSize(40);
                    }
                    .width(72)
                    .height(72)
                    .backgroundColor('#F0F5FF')
                    .borderRadius(12)
                    .justifyContent(FlexAlign.Center)
                    .alignItems(HorizontalAlign.Center)
                    .flexShrink(0);

                    Column({ space: 6 }) {
                      Text(article.title)
                        .fontSize(16)
                        .fontWeight('bold')
                        .fontColor('#333333')
                        .maxLines(2)
                        .textOverflow({ overflow: TextOverflow.Ellipsis });

                      Text(article.summary)
                        .fontSize(13)
                        .fontColor('#888888')
                        .maxLines(2)
                        .textOverflow({ overflow: TextOverflow.Ellipsis });

                      Row({ space: 12 }) {
                        Text(article.category)
                          .fontSize(11)
                          .fontColor('#1677FF')
                          .backgroundColor('#1677FF10')
                          .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                          .borderRadius(4);

                        Text(`👁 ${article.readCount}`)
                          .fontSize(11)
                          .fontColor('#999999');

                        Blank();

                        Text(article.publishTime)
                          .fontSize(11)
                          .fontColor('#BBBBBB');
                      }
                      .width('100%');
                    }
                    .layoutWeight(1)
                    .alignItems(HorizontalAlign.Start);
                  }
                }
                .width('100%')
                .padding(16)
                .backgroundColor('#FFFFFF')
                .borderRadius(12)
                .border({ width: 1, color: '#F0F0F0' })
                .shadow({
                  radius: 8,
                  color: '#00000008',
                  offsetX: 0,
                  offsetY: 3
                })
                .onClick(() => {
                  router.pushUrl({
                    url: 'pages/ScienceDetailPage',
                    params: { articleId: article.id }
                  });
                });
              }
            }, (article: ScienceArticle) => article.id);
          }
          .width('100%')
          .layoutWeight(1);
        }
        .width('85%')
        .padding({ bottom: 24 });
      }
      .flexGrow(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top);

      Footer({ activeIndex: 3 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }
}
