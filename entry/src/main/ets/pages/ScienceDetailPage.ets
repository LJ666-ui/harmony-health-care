import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';

interface ArticleDetail {
  id: string;
  title: string;
  coverIcon: string;
  publishTime: string;
  category: string;
  content: string[];
}

@Entry
@Component
struct ScienceDetailPage {
  @State articleId: string = '';
  @State isFavorited: boolean = false;
  @State showFavoriteToast: boolean = false;

  private articlesMap: Record<string, ArticleDetail> = {
    '1': {
      id: '1',
      title: '高血压患者的日常饮食指南',
      coverIcon: '🩺',
      publishTime: '2026-04-08',
      category: '心血管健康',
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
      title: '颈椎病预防与康复锻炼方法',
      coverIcon: '🦴',
      publishTime: '2026-04-07',
      category: '骨科康复',
      content: [
        '颈椎病已成为现代人的"职业病"，长时间使用电脑、手机导致颈椎负担加重。以下预防和康复方法供您参考：',
        '一、正确的工作姿势',
        '电脑屏幕应与视线平齐或略低于视线，屏幕距离眼睛50-70厘米。座椅高度调整至双脚平放地面，大腿与地面平行。',
        '二、定时休息活动',
        '每工作45-60分钟应起身活动5-10分钟。做颈部伸展运动：缓慢将头向左右两侧倾斜，每侧保持15秒；前后点头各5次。',
        '三、颈部肌肉强化训练',
        '1. 等长收缩训练：用手掌抵住额头，头部用力向前顶，手掌给予阻力，保持10秒后放松，重复5次。\n2. 侧向抗阻训练：用手抵住一侧太阳穴，头部用力向同侧倾斜，保持10秒，双侧交替进行。',
        '四、睡眠姿势调整',
        '选择合适的枕头，高度以8-12厘米为宜。仰卧时枕头支撑颈曲，侧卧时枕头填充肩部与头部的空隙。',
        '五、日常习惯改善',
        '避免长时间低头看手机，尽量将手机举到与视线平行的高度。背包不要过重，双肩背包优于单肩包。',
        '六、热敷与理疗',
        '颈部不适时可用热毛巾敷15-20分钟，促进血液循环。严重时应及时就医，接受专业理疗。',
        '温馨提示：如出现手臂麻木、头晕、行走不稳等症状，请立即就医检查。'
      ]
    },
    '3': {
      id: '3',
      title: '糖尿病患者的运动处方',
      coverIcon: '🏃',
      publishTime: '2026-04-05',
      category: '内分泌',
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
    },
    '4': {
      id: '4',
      title: '老年人跌倒风险评估与预防',
      coverIcon: '🧓',
      publishTime: '2026-04-03',
      category: '老年医学',
      content: [
        '跌倒是65岁以上老年人伤害死亡的首位原因。据统计，我国每年约有4000万老人发生至少一次跌倒，预防跌倒至关重要。',
        '一、跌倒的高危因素',
        '内在因素：肌力下降、平衡功能减退、视力障碍、认知功能障碍、体位性低血压、服用多种药物等。\n外在因素：地面湿滑、照明不足、障碍物、不合适的鞋履、浴室无扶手等。',
        '二、居家环境改造',
        '1. 安装防滑地垫，尤其在卫生间和厨房\n2. 增加夜间感应灯\n3. 移除地面杂物和松动的地毯\n4. 浴室安装扶手和防滑椅\n5. 家具高度适中，便于起坐',
        '三、平衡能力训练',
        '单脚站立练习：手扶稳固物体，单脚站立10-30秒，逐渐延长时间和减少扶持。\n太极运动：研究证实太极可降低老年人跌倒风险约47%。',
        '四、肌力增强训练',
        '重点加强下肢力量：靠墙静蹲、坐站练习、提踵训练等。每周2-3次，每组8-12次重复。',
        '五、合理用药管理',
        '定期 review 用药清单，特别关注降压药、镇静催眠药、降糖药等可能增加跌倒风险的药物。',
        '六、视力与听力检查',
        '每年进行眼科检查，及时矫正视力。佩戴合适的老花镜，避免佩戴多焦点眼镜行走。',
        '七、合适的鞋履选择',
        '穿防滑底、包裹性好、鞋跟低而宽的鞋子。避免拖鞋、高跟鞋、底部磨损严重的旧鞋。',
        '温馨提示：如果老人已经发生过跌倒，务必就医查明原因，制定个性化预防方案。'
      ]
    },
    '5': {
      id: '5',
      title: '心理健康：焦虑与抑郁的自我调节',
      coverIcon: '🧠',
      publishTime: '2026-04-01',
      category: '心理健康',
      content: [
        '现代社会的快节奏生活和竞争压力使越来越多的人面临心理健康挑战。学会识别和自我调节情绪非常重要。',
        '一、如何识别焦虑症状',
        '过度担心、紧张不安、心跳加速、呼吸急促、失眠多梦、注意力难以集中、肌肉紧张、易激惹等。若持续超过6个月需重视。',
        '二、如何识别抑郁症状',
        '持续的情绪低落、兴趣减退、精力不足、睡眠障碍（失眠或嗜睡）、食欲改变、自我评价过低、甚至有消极念头。持续超2周需关注。',
        '三、实用的自我调节方法',
        '1. 正念冥想：每天10-15分钟，专注于当下感受，不加评判地接纳自己的情绪。\n2. 规律运动：运动可促进内啡肽分泌，改善情绪。推荐快走、游泳、瑜伽等。\n3. 保持社交：不要孤立自己，与信任的朋友家人倾诉交流。\n4. 规律作息：固定睡眠时间，保证7-8小时优质睡眠。',
        '四、认知行为技巧',
        '识别负面自动思维，用证据检验这些想法是否客观。用更平衡的想法替代极端思维模式。',
        '五、渐进式肌肉放松法',
        '从头到脚依次收紧再放松各部位肌肉群，体验紧张与放松的差异，达到全身放松状态。',
        '六、何时应该寻求专业帮助',
        '当自我调节方法效果不佳，或症状严重影响工作生活时，应及时寻求心理咨询师或精神科医生的帮助。',
        '七、建立支持系统',
        '了解身边的心理健康资源，包括心理热线、社区服务中心、医院心理科等。记住：求助不是软弱的表现。',
        '温馨提示：心理健康与身体健康同等重要。如果您或身边的人需要帮助，全国心理援助热线：400-161-9995'
      ]
    },
    '6': {
      id: '6',
      title: '春季过敏防治全攻略',
      coverIcon: '🌸',
      publishTime: '2026-03-28',
      category: '过敏防治',
      content: [
        '春暖花开的季节，对于过敏体质的人来说却是"受难季"。花粉、柳絮、尘螨等过敏原大量增加，引发一系列过敏反应。',
        '一、常见春季过敏原',
        '树花粉（柏树、杨树、柳树等）、草花粉、霉菌孢子、尘螨、柳絮、宠物皮屑等。不同地区主要致敏花粉种类有所不同。',
        '二、典型过敏症状',
        '鼻部：打喷嚏、流清涕、鼻塞、鼻痒\n眼部：眼痒、流泪、结膜充血\n皮肤：荨麻疹、湿疹加重\n呼吸道：咳嗽、喘息（哮喘患者尤甚）',
        '三、预防措施——环境控制',
        '1. 花粉浓度高时减少户外活动，尤其上午10点至下午4点\n2. 外出佩戴口罩和护目镜\n3. 回家后及时更换外衣、洗脸洗手\n4. 关闭门窗，使用空气净化器\n5. 定期清洁空调滤网和床上用品',
        '四、药物治疗方案',
        '1. 抗组胺药：氯雷他定、西替利嗪等，用于缓解打喷嚏、流涕、瘙痒\n2. 鼻用糖皮质激素：糠酸莫米松等，局部用药效果好\n3. 白三烯受体拮抗剂：孟鲁司特，适用于合并哮喘者\n4. 眼用制剂：奥洛他定滴眼液等缓解眼部症状',
        '五、脱敏治疗',
        '对于明确过敏原且药物控制不佳的患者，可考虑特异性免疫治疗（脱敏治疗），疗程通常3-5年。',
        '六、生活方式调整',
        '均衡营养、充足睡眠、适度运动可增强免疫力。戒烟限酒，减少呼吸道刺激。',
        '七、紧急情况处理',
        '如发生严重过敏反应（呼吸困难、喉头水肿、全身荨麻疹、血压下降），应立即就近就医或拨打急救电话。',
        '温馨提示：过敏症状反复发作建议到医院变态反应科做过敏原检测，明确致敏物质，针对性预防和治疗。'
      ]
    }
  };

  getCurrentArticle(): ArticleDetail {
    return this.articlesMap[this.articleId] ?? this.articlesMap['1'];
  }

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, string>;
    if (params?.articleId) {
      this.articleId = params.articleId;
    }
  }

  handleFavorite(): void {
    this.isFavorited = !this.isFavorited;
    this.showFavoriteToast = true;
    setTimeout(() => {
      this.showFavoriteToast = false;
    }, 1500);
  }

  build() {
    Column() {
      Header({ title: '文章详情', showBack: true });

      Scroll() {
        Column({ space: 16 }) {
          Column() {
            Text(this.getCurrentArticle().coverIcon)
              .fontSize(80)
              .margin({ bottom: 12 });

            Text(this.getCurrentArticle().title)
              .fontSize(22)
              .fontWeight('bold')
              .fontColor('#333333')
              .textAlign(TextAlign.Center)
              .margin({ bottom: 8 });

            Row({ space: 16 }) {
              Text(`📅 ${this.getCurrentArticle().publishTime}`)
                .fontSize(13)
                .fontColor('#999999');

              Text(`📁 ${this.getCurrentArticle().category}`)
                .fontSize(13)
                .fontColor('#1677FF')
                .backgroundColor('#1677FF10')
                .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                .borderRadius(4);
            }
            .justifyContent(FlexAlign.Center)
            .width('100%');
          }
          .width('100%')
          .padding(24)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .border({ width: 1, color: '#F0F0F0' })
          .alignItems(HorizontalAlign.Center);

          Column({ space: 14 }) {
            ForEach(this.getCurrentArticle().content, (paragraph: string, index: number) => {
              Text(paragraph)
                .fontSize(15)
                .fontColor('#444444')
                .lineHeight(24)
                .width('100%')
                .textAlign(TextAlign.Start);
            }, (paragraph: string, index: number) => `${this.articleId}-p-${index}`);
          }
          .width('100%')
          .padding(20)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .border({ width: 1, color: '#F0F0F0' })
          .alignItems(HorizontalAlign.Start);
        }
        .width('85%')
        .padding({ top: 16, bottom: 80 });
      }
      .flexGrow(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top);

      Column() {
        Button(this.isFavorited ? '❤️ 已收藏' : '🤍 收藏文章')
          .width('85%')
          .height(48)
          .fontSize(16)
          .fontColor(this.isFavorited ? '#FFFFFF' : '#1677FF')
          .backgroundColor(this.isFavorited ? '#FF4D4F' : '#FFFFFF')
          .borderRadius(24)
          .border({ width: this.isFavorited ? 0 : 1.5, color: '#1677FF' })
          .onClick(() => this.handleFavorite());
      }
      .width('100%')
      .padding({ top: 8, bottom: 16 })
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
    .backgroundColor('#F5F7FA');
  }
}
