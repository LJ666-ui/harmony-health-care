import { router } from '@kit.ArkUI';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';

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
struct MyCollectPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State collectedArticles: ScienceArticle[] = [
    {
      id: '1',
      title: '高血压患者的日常饮食指南',
      coverIcon: '🩺',
      summary: '科学合理的饮食是控制血压的重要手段，本文详细介绍高血压患者应遵循的DASH饮食原则...',
      publishTime: '2026-04-08',
      category: '慢病护理',
      readCount: '3.2k'
    },
    {
      id: '2',
      title: '老年人如何预防跌倒？骨科专家支招',
      coverIcon: '🦴',
      summary: '跌倒是老年人致伤致残的主要原因之一，了解科学的预防措施可以有效降低风险...',
      publishTime: '2026-04-07',
      category: '康复训练',
      readCount: '2.8k'
    },
    {
      id: '3',
      title: '糖尿病患者的运动处方',
      coverIcon: '💊',
      summary: '适度运动对血糖控制有显著效果，但需掌握正确方法和注意事项，避免低血糖发生...',
      publishTime: '2026-04-06',
      category: '慢病护理',
      readCount: '4.1k'
    }
  ];

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    }
  }

  handleUncollect(articleId: string): void {
    let filtered: ScienceArticle[] = [];
    for (let i = 0; i < this.collectedArticles.length; i++) {
      if (this.collectedArticles[i].id !== articleId) {
        filtered.push(this.collectedArticles[i]);
      }
    }
    this.collectedArticles = filtered;
    // 调用后端接口
    // 模拟API调用
    setTimeout(() => {
      ToastUtil.showSuccess('取消收藏成功');
    }, 300);
  }

  build() {
    Column() {
      // 头部
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
        Text('我的收藏')
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

      // 收藏文章列表
      Scroll() {
        Column() {
          if (this.collectedArticles.length === 0) {
            // 空状态
            Column() {
              Text('❤️')
                .fontSize(48)
                .margin({ bottom: 16 });
              Text('暂无收藏')
                .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                .fontColor('#999999');
              Text('浏览文章时点击收藏按钮添加')
                .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                .fontColor('#BBBBBB')
                .margin({ top: 8 });
            }
            .width('100%')
            .height(400)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center);
          } else {
            ForEach(this.collectedArticles, (article: ScienceArticle) => {
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

                    Text('👁 ' + article.readCount)
                      .fontSize(11)
                      .fontColor('#999999')
                      .margin({ left: 12 })

                    Text(article.publishTime)
                      .fontSize(11)
                      .fontColor('#BBBBBB')
                    
                    Button('取消收藏')
                      .fontSize(11)
                      .fontColor('#FF4757')
                      .backgroundColor('transparent')
                      .border({ width: 1, color: '#FF4757' })
                      .padding({ left: 12, right: 12, top: 4, bottom: 4 })
                      .borderRadius(4)
                      .margin({ left: 'auto' })
                      .onClick(() => this.handleUncollect(article.id));
                  }
                  .width('100%')
                  .margin({ top: 8 })
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                .margin({ left: 12 })
              }
              .width('90%')
              .margin({ bottom: 10, left: '5%', right: '5%' })
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
        }
        .width('100%')
        .padding({ top: GlobalTheme.getSpacingLG(this.isElderMode), bottom: 100 });
      }
      .height(0)
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top);

      Footer({ activeIndex: 3 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor(GlobalTheme.BG_COLOR);
  }
}