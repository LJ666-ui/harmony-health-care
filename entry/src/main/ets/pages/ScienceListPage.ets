import { router } from '@kit.ArkUI';
import { Footer } from '../components/Footer';
import { ToastUtil } from '../common/utils/ToastUtil';
import { GlobalTheme } from '../global';

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
      summary: '科学合理的饮食是控制血压的重要手段，本文详细介绍高血压患者应遵循的DASH饮食原则...',
      publishTime: '2026-04-08',
      category: '心血管健康',
      readCount: '3.2k'
    },
    {
      id: '2',
      title: '老年人如何预防跌倒？骨科专家支招',
      coverIcon: '🦴',
      summary: '跌倒是老年人致伤致残的主要原因之一，了解科学的预防措施可以有效降低风险...',
      publishTime: '2026-04-07',
      category: '骨科健康',
      readCount: '2.8k'
    },
    {
      id: '3',
      title: '糖尿病患者的运动处方',
      coverIcon: '💊',
      summary: '适度运动对血糖控制有显著效果，但需掌握正确方法和注意事项，避免低血糖发生...',
      publishTime: '2026-04-06',
      category: '内分泌管理',
      readCount: '4.1k'
    },
    {
      id: '4',
      title: '颈椎病的康复训练方法',
      coverIcon: '🧘',
      summary: '长期低头看手机导致颈椎问题日益年轻化，这套康复训练动作每天10分钟有效缓解...',
      publishTime: '2026-04-05',
      category: '骨科健康',
      readCount: '5.3k'
    },
    {
      id: '5',
      title: '如何正确测量血压？家庭自测指南',
      coverIcon: '📊',
      summary: '血压测量的时间、姿势、频率都会影响结果准确性，学会正确的自测方法至关重要...',
      publishTime: '2026-04-04',
      category: '心血管健康',
      readCount: '3.7k'
    },
    {
      id: '6',
      title: '骨质疏松的早期信号与防治',
      coverIcon: '🦴',
      summary: '骨质疏松被称为"沉默的杀手"，早期发现并干预可有效预防骨折风险...',
      publishTime: '2026-04-03',
      category: '骨科健康',
      readCount: '2.9k'
    },
    {
      id: '7',
      title: '老年痴呆症的预防与早期识别',
      coverIcon: '🧠',
      summary: '阿尔茨海默病发病率逐年上升，保持社交活动、规律运动和脑力训练可延缓认知衰退...',
      publishTime: '2026-04-02',
      category: '神经科',
      readCount: '4.5k'
    },
    {
      id: '8',
      title: '合理用药：避免药物相互作用的实用指南',
      coverIcon: '💉',
      summary: '老年人常服用多种药物，了解药物相互作用机制，避免不良反应的发生...',
      publishTime: '2026-04-01',
      category: '用药安全',
      readCount: '3.0k'
    },
    {
      id: '9',
      title: '膝关节疼痛的自我康复方案',
      coverIcon: '🦵',
      summary: '膝关节炎是最常见的关节疾病之一，通过肌肉强化训练和生活方式调整可明显改善症状...',
      publishTime: '2026-03-30',
      category: '骨科健康',
      readCount: '3.8k'
    },
    {
      id: '10',
      title: '失眠怎么办？中医调理睡眠质量的方法',
      coverIcon: '😴',
      summary: '长期失眠影响身心健康，中医通过穴位按摩、药膳调理等方法帮助改善睡眠...',
      publishTime: '2026-03-28',
      category: '中医养生',
      readCount: '4.2k'
    },
    {
      id: '11',
      title: '心血管疾病的风险因素筛查清单',
      coverIcon: '❤️',
      summary: '高血压、高血脂、糖尿病、吸烟等都是心血管疾病的危险因素，定期筛查早预防...',
      publishTime: '2026-03-25',
      category: '心血管健康',
      readCount: '2.7k'
    },
    {
      id: '12',
      title: '腰椎间盘突出的保守治疗方法',
      coverIcon: '🔙',
      summary: '80%的腰椎间盘突出可通过保守治疗缓解，包括卧床休息、物理治疗和康复训练...',
      publishTime: '2026-03-22',
      category: '骨科健康',
      readCount: '5.1k'
    },
    {
      id: '13',
      title: '疫苗接种：老年人的免疫保护伞',
      coverIcon: '💉',
      summary: '流感疫苗、肺炎球菌疫苗、带状疱疹疫苗等对老年人尤为重要，建议按时接种...',
      publishTime: '2026-03-20',
      category: '疾病预防',
      readCount: '3.4k'
    },
    {
      id: '14',
      title: '如何选择合适的助行器？康复师教你选',
      coverIcon: '🚶',
      summary: '拐杖、助行器、轮椅各有适用场景，根据身体状况和需求选择最合适的辅助器具...',
      publishTime: '2026-03-18',
      category: '康复护理',
      readCount: '2.5k'
    },
    {
      id: '15',
      title: '春季过敏季：过敏性鼻炎的应对策略',
      coverIcon: '🌸',
      summary: '花粉、尘螨等过敏原在春季活跃，通过环境控制和药物治疗可有效缓解症状...',
      publishTime: '2026-03-15',
      category: '耳鼻喉科',
      readCount: '3.6k'
    }
  ];

  @State isRefreshing: boolean = false;

  handleRefresh(): void {
    this.isRefreshing = true;

    setTimeout(() => {
      this.isRefreshing = false;

      ToastUtil.refreshSuccess();
    }, 1500);
  }

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    }
  }

  build() {
    Column() {
      Row() {
        Text('←')
          .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
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

      Scroll() {
        Column() {
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
            .height(0)
            .layoutWeight(1);
          }
        .width('85%')
        .padding({ top: GlobalTheme.getSpacingLG(this.isElderMode), bottom: GlobalTheme.getSpacingLG(this.isElderMode) });
      }
      .height(0)
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top);

      Footer({ activeIndex: 3 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }
}
