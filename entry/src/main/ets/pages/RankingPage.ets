import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';

interface RankingUser {
  id: string;
  name: string;
  avatar: string;
  value: number | string;
  unit: string;
  isMe: boolean;
}

interface Badge {
  id: string;
  icon: string;
  name: string;
  description: string;
  condition: string;
  earned: boolean;
  earnDate?: string;
}

const MOCK_EXPERT_RANKING: RankingUser[] = [
  { id: '1', name: '健康达人王', avatar: '🥇', value: 256, unit: '次', isMe: false },
  { id: '2', name: '养生小李', avatar: '🥈', value: 198, unit: '次', isMe: false },
  { id: '3', name: '运动健将张', avatar: '🥉', value: 167, unit: '次', isMe: false },
  { id: '4', name: '长寿奶奶刘', avatar: '4️⃣', value: 145, unit: '次', isMe: false },
  { id: '5', name: '我', avatar: '👤', value: 48, unit: '次', isMe: true },
  { id: '6', name: '活力老陈', avatar: '6️⃣', value: 42, unit: '次', isMe: false },
  { id: '7', name: '自律小周', avatar: '7️⃣', value: 38, unit: '次', isMe: false },
  { id: '8', name: '坚持者吴', avatar: '8️⃣', value: 35, unit: '次', isMe: false }
];

const MOCK_EXERCISE_RANKING: RankingUser[] = [
  { id: '1', name: '马拉松李叔', avatar: '🥇', value: 45.5, unit: '小时', isMe: false },
  { id: '2', name: '太极大师', avatar: '🥈', value: 38.2, unit: '小时', isMe: false },
  { id: '3', name: '广场舞王姐', avatar: '🥉', value: 32.0, unit: '小时', isMe: false },
  { id: '4', name: '瑜伽达人', avatar: '4️⃣', value: 28.5, unit: '小时', isMe: false },
  { id: '5', name: '我', avatar: '👤', value: 12.3, unit: '小时', isMe: true },
  { id: '6', name: '散步爱好者', avatar: '6️⃣', value: 10.1, unit: '小时', isMe: false },
  { id: '7', name: '慢跑新手', avatar: '7️⃣', value: 8.7, unit: '小时', isMe: false },
  { id: '8', name: '健身小白', avatar: '8️⃣', value: 6.2, unit: '小时', isMe: false }
];

const MOCK_LEARNING_RANKING: RankingUser[] = [
  { id: '1', name: '学霸爷爷', avatar: '🥇', value: 156, unit: '篇', isMe: false },
  { id: '2', name: '求知青年', avatar: '🥈', value: 134, unit: '篇', isMe: false },
  { id: '3', name: '知识海洋', avatar: '🥉', value: 112, unit: '篇', isMe: false },
  { id: '4', name: '学习委员', avatar: '4️⃣', value: 98, unit: '篇', isMe: false },
  { id: '5', name: '我', avatar: '👤', value: 23, unit: '篇', isMe: true },
  { id: '6', name: '阅读达人', avatar: '6️⃣', value: 19, unit: '篇', isMe: false },
  { id: '7', name: '好学宝宝', avatar: '7️⃣', value: 15, unit: '篇', isMe: false },
  { id: '8', name: '新手上路', avatar: '8️⃣', value: 11, unit: '篇', isMe: false }
];

const MOCK_ASSESSMENT_RANKING: RankingUser[] = [
  { id: '1', name: '评估狂人', avatar: '🥇', value: 89, unit: '次', isMe: false },
  { id: '2', name: '关注健康', avatar: '🥈', value: 76, unit: '次', isMe: false },
  { id: '3', name: '定期检查', avatar: '🥉', value: 65, unit: '次', isMe: false },
  { id: '4', name: '预防为主', avatar: '4️⃣', value: 54, unit: '次', isMe: false },
  { id: '5', name: '我', avatar: '👤', value: 12, unit: '次', isMe: true },
  { id: '6', name: '偶尔看看', avatar: '6️⃣', value: 9, unit: '次', isMe: false },
  { id: '7', name: '刚入门', avatar: '7️⃣', value: 5, unit: '次', isMe: false },
  { id: '8', name: '新人报到', avatar: '8️⃣', value: 3, unit: '次', isMe: false }
];

const MOCK_BADGES: Badge[] = [
  {
    id: '1',
    icon: '🔥',
    name: '连续打卡7天',
    description: '连续7天记录健康数据',
    condition: '连续记录 ≥ 7天',
    earned: true,
    earnDate: '2026-04-10'
  },
  {
    id: '2',
    icon: '💪',
    name: '运动达人',
    description: '本月累计运动超过30小时',
    condition: '月运动时长 ≥ 30h',
    earned: true,
    earnDate: '2026-04-08'
  },
  {
    id: '3',
    icon: '📚',
    name: '博学多才',
    description: '阅读科普文章超过50篇',
    condition: '阅读量 ≥ 50篇',
    earned: false
  },
  {
    id: '4',
    icon: '⭐',
    name: '连续打卡30天',
    description: '连续30天记录健康数据',
    condition: '连续记录 ≥ 30天',
    earned: false
  },
  {
    id: '5',
    icon: '🏆',
    name: '健康之星',
    description: '健康评分达到90分以上',
    condition: '健康评分 ≥ 90分',
    earned: false
  },
  {
    id: '6',
    icon: '🎯',
    name: '康复先锋',
    description: '完成康复训练计划100%',
    condition: '康复完成率 = 100%',
    earned: false
  }
];

@Entry
@Component
struct RankingPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State currentTab: number = 0;
  @State showBadgeDetail: boolean = false;
  @State selectedBadge: Badge | null = null;

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') ?? false;
    }
  }

  getRankColor(rank: number): string {
    if (rank === 0) return '#FFD700';
    if (rank === 1) return '#C0C0C0';
    if (rank === 2) return '#CD7F32';
    return '#999999';
  }

  build() {
    Column() {
      Header({ title: '社区排行榜', showBack: true });

      Scroll() {
        Column({ space: 20 }) {

          Row({ space: 12 }) {
            this.buildTabButton('🏅 健康达人榜', 0);
            this.buildTabButton('📖 学习之星榜', 1);
            this.buildTabButton('🎖️ 我的徽章', 2);
          }
          .width('100%')
          .justifyContent(FlexAlign.Center);

          if (this.currentTab < 2) {
            Column({ space: 16 }) {

              if (this.currentTab === 0) {
                Text('📊 记录次数排名')
                  .fontSize(15)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#333333')
                  .width('100%');

                this.buildRankingList(MOCK_EXPERT_RANKING);

                Text('🏃 运动时长排名')
                  .fontSize(15)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#333333')
                  .width('100%')
                  .margin({ top: 8 });

                this.buildRankingList(MOCK_EXERCISE_RANKING);
              } else {
                Text('📚 科普阅读排名')
                  .fontSize(15)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#333333')
                  .width('100%');

                this.buildRankingList(MOCK_LEARNING_RANKING);

                Text('🔍 健康评估排名')
                  .fontSize(15)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#333333')
                  .width('100%')
                  .margin({ top: 8 });

                this.buildRankingList(MOCK_ASSESSMENT_RANKING);
              }
            }
            .width('100%');
          } else {
            Column({ space: 14 }) {
              Row() {
                Text(`已获得 ${MOCK_BADGES.filter((b: Badge) => b.earned).length}/${MOCK_BADGES.length} 枚徽章`)
                  .fontSize(13)
                  .fontColor('#666666')
                  .layoutWeight(1);

                Text(`${Math.round(MOCK_BADGES.filter((b: Badge) => b.earned).length / MOCK_BADGES.length * 100)}%`)
                  .fontSize(13)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#1677FF');
              }
              .width('100%');

              ForEach(MOCK_BADGES, (badge: Badge) => {
                this.buildBadgeCard(badge);
              }, (badge: Badge) => badge.id);
            }
            .width('100%');
          }

        }
        .width('85%')
        .padding({ top: 16, bottom: 100 });
      }
      .height(0)
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top);

      Footer({ activeIndex: 4 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }

  @Builder
  buildTabButton(label: string, index: number) {
    Text(label)
      .fontSize(this.currentTab === index ? 14 : 13)
      .fontWeight(this.currentTab === index ? FontWeight.Bold : FontWeight.Normal)
      .fontColor(this.currentTab === index ? '#FFFFFF' : '#666666')
      .backgroundColor(this.currentTab === index ? '#1677FF' : '#F5F5F5')
      .padding({ left: 16, right: 16, top: 9, bottom: 9 })
      .borderRadius(18)
      .onClick(() => {
        this.currentTab = index;
      });
  }

  @Builder
  buildRankingList(users: RankingUser[]) {
    Column({ space: 0 }) {
      ForEach(users, (user: RankingUser, index: number) => {
        Row({ space: 12 }) {
          Text(user.avatar)
            .fontSize(index < 3 ? 24 : 18);

          Text(`${index + 1}`)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getRankColor(index))
            .width(28)
            .textAlign(TextAlign.Center);

          Column({ space: 2 }) {
            Text(user.name)
              .fontSize(14)
              .fontWeight(user.isMe ? FontWeight.Bold : FontWeight.Normal)
              .fontColor(user.isMe ? '#1677FF' : '#333333');

            if (user.isMe) {
              Text('（我的排名）')
                .fontSize(11)
                .fontColor('#1677FF');
            }
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start);

          Column({ space: 2 }) {
            Text(typeof user.value === 'number' ? `${user.value}${user.unit}` : user.value as string)
              .fontSize(15)
              .fontWeight(FontWeight.Bold)
              .fontColor(user.isMe ? '#1677FF' : '#333333');

            if (index < 3 && !user.isMe) {
              Text(['👑', '🎖️', '🏅'][index])
                .fontSize(12);
            }
          }
          .alignItems(HorizontalAlign.End);
        }
        .width('100%')
        .padding(14)
        .backgroundColor(user.isMe ? '#E6F7FF' : index % 2 === 0 ? '#FFFFFF' : '#FAFAFA')
        .borderRadius(8)
        .border(user.isMe ? { width: 1.5, color: '#1677FF' } : { width: 0, color: 'transparent' });
      }, (user: RankingUser, index: number) => `rank_${index}`);
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 2 });
  }

  @Builder
  buildBadgeCard(badge: Badge) {
    Row({ space: 14 }) {
      Column()
        .width(52)
        .height(52)
        .borderRadius(26)
        .backgroundColor(badge.earned ? '#FFFBE6' : '#F5F5F5')
        .justifyContent(FlexAlign.Center)
        .opacity(badge.earned ? 1 : 0.5) {
          Text(badge.icon)
            .fontSize(26);
        }

      Column({ space: 4 }) {
        Row({ space: 8 }) {
          Text(badge.name)
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor(badge.earned ? '#333333' : '#999999');

          if (badge.earned) {
            Text('✅ 已获得')
              .fontSize(11)
              .fontColor('#52C41A')
              .backgroundColor('#F6FFED')
              .padding({ left: 8, right: 8, top: 2, bottom: 2 })
              .borderRadius(8);
          } else {
            Text('未解锁')
              .fontSize(11)
              .fontColor('#999999')
              .backgroundColor('#F5F5F5')
              .padding({ left: 8, right: 8, top: 2, bottom: 2 })
              .borderRadius(8);
          }
        }
        .width('100%');

        Text(badge.description)
          .fontSize(12)
          .fontColor('#666666')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis });

        Text(badge.condition)
          .fontSize(11)
          .fontColor('#999999');

        if (badge.earned && badge.earnDate) {
          Text(`获得时间：${badge.earnDate}`)
            .fontSize(10)
            .fontColor('#52C41A');
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start);
    }
    .width('100%')
    .padding(14)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 2 })
    .onClick(() => {
      this.selectedBadge = badge;
      this.showBadgeDetail = true;
    });

    if (this.showBadgeDetail && this.selectedBadge?.id === badge.id) {
      this.buildBadgeDetailDialog();
    }
  }

  @Builder
  buildBadgeDetailDialog() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#00000060')
        .onClick(() => {
          this.showBadgeDetail = false;
          this.selectedBadge = null;
        });

      Column({ space: 20 }) {
        Text(this.selectedBadge!.icon)
          .fontSize(48);

        Text(this.selectedBadge!.name)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333');

        Text(this.selectedBadge!.description)
          .fontSize(14)
          .fontColor('#666666')
          .textAlign(TextAlign.Center);

        Column({ space: 8 }) {
          Text('解锁条件')
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333');

          Text(this.selectedBadge!.condition)
            .fontSize(14)
            .fontColor('#1677FF')
            .backgroundColor('#E6F7FF')
            .padding(12)
            .borderRadius(8);
        }
        .width('100%');

        if (this.selectedBadge!.earned) {
          Text(`✅ 已于 ${this.selectedBadge!.earnDate} 获得`)
            .fontSize(13)
            .fontColor('#52C41A');
        } else {
          Text('继续努力，即将获得！💪')
            .fontSize(13)
            .fontColor('#FAAD14');
        }

        Button('知道了')
          .width('100%')
          .height(44)
          .fontSize(15)
          .backgroundColor('#1677FF')
          .borderRadius(22)
          .onClick(() => {
            this.showBadgeDetail = false;
            this.selectedBadge = null;
          });
      }
      .width('80%')
      .padding(24)
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
      .alignItems(HorizontalAlign.Center);
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 });
  }
}