import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';

export interface RehabCourse {
  id: string;
  icon: string;
  title: string;
  description: string;
  duration: string;
  difficulty: string;
  targetGroup: string;
  completedCount: number;
  totalCount: number;
}

@Entry
@Component
struct RehabListPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State courses: RehabCourse[] = [
    {
      id: '1',
      title: '颈椎康复训练',
      duration: '15分钟',
      difficulty: '初级',
      targetGroup: '上班族、低头族',
      description: '缓解颈椎僵硬，改善颈部活动度，预防颈椎病',
      icon: '🧘',
      completedCount: 0,
      totalCount: 12
    },
    {
      id: '2',
      title: '膝关节强化训练',
      duration: '20分钟',
      difficulty: '中级',
      targetGroup: '中老年人、关节炎患者',
      description: '增强膝关节稳定性，减轻关节疼痛，提升行走能力',
      icon: '🦵',
      completedCount: 3,
      totalCount: 15
    },
    {
      id: '3',
      title: '腰椎间盘突出康复',
      duration: '25分钟',
      difficulty: '高级',
      targetGroup: '久坐人群、腰痛患者',
      description: '科学锻炼核心肌群，缓解腰椎压力，促进椎间盘修复',
      icon: '🔙',
      completedCount: 0,
      totalCount: 18
    },
    {
      id: '4',
      title: '肩周炎功能恢复训练',
      duration: '18分钟',
      difficulty: '中级',
      targetGroup: '中老年人、肩部不适者',
      description: '改善肩关节活动范围，增强肩袖肌群力量，缓解疼痛',
      icon: '💪',
      completedCount: 0,
      totalCount: 14
    },
    {
      id: '5',
      title: '平衡能力训练',
      duration: '12分钟',
      difficulty: '初级',
      targetGroup: '老年人、易跌倒者',
      description: '提高身体平衡感，增强下肢力量，有效预防跌倒',
      icon: '⚖️',
      completedCount: 7,
      totalCount: 10
    },
    {
      id: '6',
      title: '帕金森病康复操',
      duration: '30分钟',
      difficulty: '高级',
      targetGroup: '帕金森患者、运动障碍者',
      description: '改善运动迟缓，增强协调性，提高生活质量',
      icon: '🎯',
      completedCount: 2,
      totalCount: 20
    },
    {
      id: '7',
      title: '呼吸系统康复训练',
      duration: '15分钟',
      difficulty: '初级',
      targetGroup: '慢阻肺患者、老年人',
      description: '强化呼吸肌功能，改善肺活量，增强心肺耐力',
      icon: '🫁',
      completedCount: 0,
      totalCount: 12
    },
    {
      id: '8',
      title: '中风后遗症肢体康复',
      duration: '35分钟',
      difficulty: '高级',
      targetGroup: '脑卒中康复期患者',
      description: '循序渐进恢复肢体功能，重建神经通路，提升生活自理能力',
      icon: '🤸',
      completedCount: 1,
      totalCount: 24
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
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') ?? false;
    }
  }

  build() {
    Column() {
      Header({ title: '康复课程', showBack: true });

      Scroll() {
        Column({ space: GlobalTheme.getSpacingLG(this.isElderMode) }) {
          Text('选择康复课程')
            .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
            .fontWeight('bold')
            .fontColor(GlobalTheme.THEME_COLOR)
            .margin({ top: GlobalTheme.getSpacingLG(this.isElderMode), bottom: GlobalTheme.getSpacingMD(this.isElderMode) });

          List() {
            ForEach(this.courses, (course: RehabCourse) => {
              ListItem() {
                Column() {
                  Row() {
                    Column() {
                      Text(course.icon)
                        .fontSize(36)
                    }
                    .width(64)
                    .height(64)
                    .backgroundColor(GlobalTheme.THEME_COLOR + '20')
                    .borderRadius(32)
                    .justifyContent(FlexAlign.Center)
                    .alignItems(HorizontalAlign.Center)
                    .margin({ right: GlobalTheme.getSpacingMD(this.isElderMode) });

                    Column({ space: GlobalTheme.getSpacingXS(this.isElderMode) }) {
                      Text(course.title)
                        .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                        .fontWeight('bold')
                        .fontColor(GlobalTheme.TEXT_PRIMARY);

                      Text(course.description)
                        .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                        .fontColor(GlobalTheme.TEXT_SECONDARY)
                        .maxLines(2);

                      Row({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
                        Text(`⏱ ${course.duration}`)
                          .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                          .fontColor(GlobalTheme.TEXT_HINT);
                        Text(`📊 ${course.difficulty}`)
                          .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                          .fontColor(GlobalTheme.THEME_COLOR);
                      }
                    }
                    .layoutWeight(1);
                  }
                }
                .width('100%')
                .padding(GlobalTheme.getSpacingMD(this.isElderMode))
                .backgroundColor(GlobalTheme.CARD_BG)
                .borderRadius(GlobalTheme.RADIUS_LG)
                .border({ width: 1, color: GlobalTheme.BORDER_COLOR })
                .onClick(() => {
                  router.pushUrl({ url: 'pages/Rehab3DPage' });
                });
              }
              .padding({ bottom: GlobalTheme.getSpacingSM(this.isElderMode) });
            }, (course: RehabCourse) => course.id);
          }
          .width('100%')
          .layoutWeight(1);
        }
        .width('85%')
        .padding({ bottom: GlobalTheme.getSpacingLG(this.isElderMode) });
      }
      .height(0)
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top);

      Footer({ activeIndex: 2 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor(GlobalTheme.BG_COLOR);
  }
}
