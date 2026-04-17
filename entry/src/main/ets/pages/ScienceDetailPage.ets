import { router } from '@kit.ArkUI';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';

interface ArticleDetail {
  id: string;
  title: string;
  coverIcon: string;
  publishTime: string;
  category: string;
  content: string[];
  readCount: string;
  author: string;
}

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
struct ScienceDetailPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State articleId: string = '';
  @State isFavorited: boolean = false;
  @State fontSize: number = 16;
  @State isLiked: boolean = false;
  @State likeCount: number = 0;

  private articlesMap: Record<string, ArticleDetail> = {
    '1': {
      id: '1',
      title: '高血压患者的日常饮食指南',
      coverIcon: '🩺',
      publishTime: '2026-04-08',
      category: '慢病护理',
      readCount: '3.2k',
      author: '张医生',
      content: [
        '高血压是一种常见的慢性疾病，合理的饮食管理对控制血压至关重要。以下是高血压患者需要遵循的饮食原则：',
        '一、限制钠盐摄入',
        '每日食盐摄入量应控制在5克以下，相当于一啤酒瓶盖的量。减少腌制食品、加工食品的摄入，如咸菜、火腿、方便面等。',
        '二、增加钾的摄入',
        '多吃富含钾的食物，如香蕉、土豆、菠菜、豆类等。钾有助于平衡体内钠的作用，帮助降低血压。',
        '三、控制脂肪摄入',
        '选择低脂乳制品、瘦肉、鱼类，避免动物内脏和高脂肪食物。烹饪时少用油炸方式，多用蒸、煮、炖等方法。',
        '四、适量补充蛋白质',
        '优质蛋白质来源包括鱼类、禽肉、蛋类、豆制品。每周至少吃2-3次鱼类，尤其是富含Omega-3脂肪酸的深海鱼。',
        '五、多吃蔬菜水果',
        '每天至少摄入400-500克蔬菜和200-300克水果，它们富含膳食纤维、维生素和矿物质，有助于血压控制。',
        '六、限制饮酒',
        '男性每日酒精摄入不超过25克，女性不超过15克。最好完全戒酒或严格限量。',
        '七、规律进餐，避免暴饮暴食',
        '保持三餐规律，避免过饱或过饥，晚餐不宜过晚且要清淡。',
        '温馨提示：饮食调整应在医生指导下进行，定期监测血压变化，必要时配合药物治疗。'
      ]
    },
    '2': {
      id: '2',
      title: '老年人如何预防跌倒？骨科专家支招',
      coverIcon: '🦴',
      publishTime: '2026-04-07',
      category: '康复训练',
      readCount: '2.8k',
      author: '李医生',
      content: [
        '跌倒是老年人致伤致残的主要原因之一，了解科学的预防措施可以有效降低风险。',
        '一、居家环境改造',
        '1. 安装防滑地垫，尤其在卫生间和厨房\n2. 增加夜间感应灯\n3. 移除地面杂物和松动的地毯\n4. 浴室安装扶手和防滑椅\n5. 家具高度适中，便于起坐',
        '二、平衡能力训练',
        '单脚站立练习：手扶稳固物体，单脚站立10-30秒，逐渐延长时间和减少扶持。\n太极运动：研究证实太极可降低老年人跌倒风险约47%。',
        '三、肌力增强训练',
        '重点加强下肢力量：靠墙静蹲、坐站练习、提踵训练等。每周2-3次，每组8-12次重复。',
        '四、合理用药管理',
        '定期 review 用药清单，特别关注降压药、镇静催眠药、降糖药等可能增加跌倒风险的药物。',
        '五、视力与听力检查',
        '每年进行眼科检查，及时矫正视力。佩戴合适的老花镜，避免佩戴多焦点眼镜行走。',
        '六、合适的鞋履选择',
        '穿防滑底、包裹性好、鞋跟低而宽的鞋子。避免拖鞋、高跟鞋、底部磨损严重的旧鞋。',
        '温馨提示：如果老人已经发生过跌倒，务必就医查明原因，制定个性化预防方案。'
      ]
    },
    '3': {
      id: '3',
      title: '糖尿病患者的运动处方',
      coverIcon: '💊',
      publishTime: '2026-04-06',
      category: '慢病护理',
      readCount: '4.1k',
      author: '王医生',
      content: [
        '运动是糖尿病管理的五大基石之一（饮食、运动、药物、监测、教育）。科学的运动可以显著改善血糖控制。',
        '一、运动前的准备',
        '开始运动计划前，请咨询医生进行全面评估。测量血糖，确保血糖值在安全范围内（一般5.5-16.7mmol/L）。',
        '二、推荐的运动类型',
        '1. 有氧运动：快走、慢跑、游泳、骑自行车、太极拳等\n2. 抗阻训练：弹力带练习、哑铃训练、俯卧撑等\n3. 柔韧性训练：瑜伽、拉伸运动',
        '三、运动强度与时间',
        '中等强度运动最为适宜，心率保持在最大心率的50%-70%。每次运动30-60分钟，包括5-10分钟热身和整理活动。',
        '四、运动频率',
        '每周至少150分钟中等强度有氧运动，可分配为每周5次、每次30分钟。抗阻训练每周2-3次，间隔48小时以上。',
        '五、最佳运动时间',
        '餐后1小时是运动的最佳时机，此时血糖较高，不易发生低血糖。避免空腹运动和睡前剧烈运动。',
        '六、运动中的注意事项',
        '随身携带糖果或葡萄糖片以防低血糖。穿着舒适透气的运动鞋袜。注意足部保护，避免受伤。',
        '七、不适合运动的情况',
        '血糖>16.7mmol/L伴酮体、<3.9mmol/L、严重心脑血管并发症、急性感染期间均不宜运动。',
        '温馨提示：运动效果因人而异，请根据自身情况调整，定期复查糖化血红蛋白评估效果。'
      ]
    }
  };

  private relatedArticles: ScienceArticle[] = [
    {
      id: '4',
      title: '颈椎病的康复训练方法',
      coverIcon: '🧘',
      summary: '长期低头看手机导致颈椎问题日益年轻化，这套康复训练动作每天10分钟有效缓解...',
      publishTime: '2026-04-05',
      category: '康复训练',
      readCount: '5.3k'
    },
    {
      id: '5',
      title: '如何正确测量血压？家庭自测指南',
      coverIcon: '📊',
      summary: '血压测量的时间、姿势、频率都会影响结果准确性，学会正确的自测方法至关重要...',
      publishTime: '2026-04-04',
      category: '慢病护理',
      readCount: '3.7k'
    }
  ];

  getCurrentArticle(): ArticleDetail {
    return this.articlesMap[this.articleId] ?? this.articlesMap['1'];
  }

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') ?? false;
    }

    const params = router.getParams() as Record<string, string>;
    if (params?.articleId) {
      this.articleId = params.articleId;
    }
    
    // 初始化字体大小
    this.fontSize = this.isElderMode ? 18 : 16;
  }

  handleFavorite(): void {
    this.isFavorited = !this.isFavorited;
    // 调用后端接口
    // 模拟API调用
    setTimeout(() => {
      ToastUtil.showSuccess(this.isFavorited ? '收藏成功' : '取消收藏');
    }, 300);
  }

  handleLike(): void {
    this.isLiked = !this.isLiked;
    this.likeCount += this.isLiked ? 1 : -1;
  }

  adjustFontSize(direction: 'increase' | 'decrease'): void {
    if (direction === 'increase' && this.fontSize < 24) {
      this.fontSize += 2;
    } else if (direction === 'decrease' && this.fontSize > 12) {
      this.fontSize -= 2;
    }
  }

  handleShare(): void {
    // 分享功能
    ToastUtil.showSuccess('分享功能已触发');
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
        Text('文章详情')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Text('📤')
          .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
          .fontColor('#1677FF')
          .width(40)
          .height(40)
          .textAlign(TextAlign.Center)
          .onClick(() => this.handleShare());
      }
      .width('100%')
      .height(56)
      .backgroundColor('#FFFFFF')
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.Center)

      Scroll() {
        Column({ space: GlobalTheme.getSpacingLG(this.isElderMode) }) {
          // 文章头部
          Column() {
            Text(this.getCurrentArticle().coverIcon)
              .fontSize(this.isElderMode ? 96 : 80)
              .margin({ bottom: GlobalTheme.getSpacingMD(this.isElderMode) });

            Text(this.getCurrentArticle().title)
              .fontSize(this.isElderMode ? 24 : 20)
              .fontWeight('bold')
              .fontColor('#333333')
              .textAlign(TextAlign.Center)
              .margin({ bottom: GlobalTheme.getSpacingSM(this.isElderMode) })
              .maxLines(3);

            Row({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
              Text(`作者：${this.getCurrentArticle().author}`)
                .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                .fontColor('#999999');

              Text(`📅 ${this.getCurrentArticle().publishTime}`)
                .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                .fontColor('#999999');

              Text(`👁 ${this.getCurrentArticle().readCount}`)
                .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                .fontColor('#999999');
            }
            .justifyContent(FlexAlign.Center)
            .width('100%');
          }
          .width('100%')
          .padding(GlobalTheme.getSpacingLG(this.isElderMode))
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .border({ width: 1, color: '#F0F0F0' })
          .alignItems(HorizontalAlign.Center);

          // 正文
          Column({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
            ForEach(this.getCurrentArticle().content, (text: string, i: number) => {
              Text(text)
                .fontSize(this.fontSize)
                .fontColor('#444444')
                .lineHeight(this.fontSize * 1.8)
                .width('100%')
                .textAlign(TextAlign.Start);
            }, (text: string, i: number) => `${this.articleId}-p-${i}`);
          }
          .width('100%')
          .padding(GlobalTheme.getSpacingLG(this.isElderMode))
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .border({ width: 1, color: '#F0F0F0' })
          .alignItems(HorizontalAlign.Start);

          // 相关推荐
          Column() {
            Text('相关推荐')
              .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .margin({ bottom: GlobalTheme.getSpacingMD(this.isElderMode) })
              .width('100%')
              .textAlign(TextAlign.Start);

            ForEach(this.relatedArticles, (article: ScienceArticle) => {
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
                    .fontSize(this.isElderMode ? 18 : 16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#333333')
                    .maxLines(2)

                  Text(article.summary)
                    .fontSize(this.isElderMode ? 14 : 13)
                    .fontColor('#999999')
                    .maxLines(2)
                    .margin({ top: 4 })

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
                  }
                  .width('100%')
                  .margin({ top: 4 })
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                .margin({ left: 12 })
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
          .padding(GlobalTheme.getSpacingLG(this.isElderMode))
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .border({ width: 1, color: '#F0F0F0' })
          .alignItems(HorizontalAlign.Start);
        }
        .width('85%')
        .padding({ top: GlobalTheme.getSpacingMD(this.isElderMode), bottom: 120 });
      }
      .height(0)
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top);

      // 底部操作栏
      Column() {
        Row() {
          Button(this.isFavorited ? '❤️' : '🤍')
            .width(56)
            .height(56)
            .fontSize(24)
            .backgroundColor('transparent')
            .border({ width: 0 })
            .onClick(() => this.handleFavorite());

          Button(this.isLiked ? '👍' : '👍🏻')
            .width(56)
            .height(56)
            .fontSize(24)
            .backgroundColor('transparent')
            .border({ width: 0 })
            .onClick(() => this.handleLike());

          Row() {
            Button('A-')
              .width(48)
              .height(48)
              .fontSize(16)
              .fontColor('#666666')
              .backgroundColor('#F5F7FA')
              .borderRadius(24)
              .border({ width: 0 })
              .onClick(() => this.adjustFontSize('decrease'));

            Text(`${this.fontSize}px`)
              .fontSize(14)
              .fontColor('#666666')
              .margin({ left: 8, right: 8 })
              .alignSelf(ItemAlign.Center);

            Button('A+')
              .width(48)
              .height(48)
              .fontSize(16)
              .fontColor('#666666')
              .backgroundColor('#F5F7FA')
              .borderRadius(24)
              .border({ width: 0 })
              .onClick(() => this.adjustFontSize('increase'));
          }
          .margin({ left: 'auto' });
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center);
      }
      .width('100%')
      .height(80)
      .padding({ top: 12, bottom: 12 })
      .backgroundColor('#FFFFFF')
      .shadow({
        radius: 12,
        color: '#00000012',
        offsetX: 0,
        offsetY: -4
      });

      Footer({ activeIndex: 3 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor(GlobalTheme.BG_COLOR);
  }
}
