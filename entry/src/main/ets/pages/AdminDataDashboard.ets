import { router } from '@kit.ArkUI';
import { GlobalTheme } from '../global';
import { AdminMock, UserInfo, FamilyMemberInfo } from '../mock/adminMock';
import { AuthManager, UserRole } from '../utils/AuthManager';
import EventPersistenceManager from '../utils/EventPersistenceManager';
import promptAction from '@ohos.promptAction';

interface DashboardMetric {
  label: string;
  value: string | number;
  change: number;
  color: string;
  icon: string;
}

interface TrendItem {
  date: string;
  value: number;
}

interface ActivityItem {
  id: number;
  type: string;
  user: string;
  action: string;
  target: string;
  time: string;
  color: string;
}

interface DepartmentStat {
  name: string;
  count: number;
  color: string;
}

interface RiskDistribution {
  level: string;
  count: number;
  color: string;
}

@Entry
@Component
struct AdminDataDashboard {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State metrics: DashboardMetric[] = [];
  @State userGrowthData: TrendItem[] = [];
  @State healthRecordTrend: TrendItem[] = [];
  @State appointmentTrend: TrendItem[] = [];
  @State recentActivities: ActivityItem[] = [];
  @State departmentStats: DepartmentStat[] = [];
  @State riskDistribution: RiskDistribution[] = [];
  @State isLoading: boolean = true;

  aboutToAppear(): void {
    this.checkAccess();
    this.loadDashboardData();
  }

  private checkAccess(): void {
    const authManager: AuthManager = AuthManager.getInstance();
    const currentRole: UserRole = authManager.getCurrentRole();

    if (currentRole === UserRole.GUEST) {
      promptAction.showToast({ message: '请先登录管理员账号' });
      router.replaceUrl({ url: 'pages/AdminLogin' });
      return;
    }

    if (currentRole !== UserRole.ADMIN && currentRole !== UserRole.SUPER_ADMIN) {
      promptAction.showToast({ message: '无权访问数据大屏' });
      router.back();
      return;
    }
  }

  async loadDashboardData(): Promise<void> {
    this.isLoading = true;

    try {
      const users: UserInfo[] = AdminMock.users;
      const familyMembers: FamilyMemberInfo[] = AdminMock.familyMembers;
      const doctorCount: number = users.filter(u => u.user_type === 1).length;
      const patientCount: number = users.filter(u => u.user_type === 0).length;

      const todayActiveUsers: number = Math.floor(users.length * 0.35);
      const weekNewUsers: number = 5;
      const totalHealthRecords: number = 1248;
      const todayRecords: number = 67;
      const totalAppointments: number = 892;
      const pendingAppointments: number = 23;
      const totalArticles: number = 356;
      const totalCollections: number = 1284;
      const avgHealthScore: number = 76;
      const highRiskCount: number = 18;
      const mediumRiskCount: number = 42;
      const lowRiskCount: number = users.length - highRiskCount - mediumRiskCount;

      this.metrics = [
        { label: '注册用户', value: users.length, change: 12.5, color: '#1677FF', icon: '👥' },
        { label: '今日活跃', value: todayActiveUsers, change: 8.3, color: '#52C41A', icon: '📈' },
        { label: '医生用户', value: doctorCount, change: 3.2, color: '#FAAD14', icon: '🏥' },
        { label: '患者用户', value: patientCount, change: 15.7, color: '#722ED1', icon: '❤️' },
        { label: '健康记录', value: totalHealthRecords, change: 22.1, color: '#13C2C2', icon: '📊' },
        { label: '预约总数', value: totalAppointments, change: -5.4, color: '#EB2F96', icon: '📅' },
        { label: '科普文章', value: totalArticles, change: 6.8, color: '#F5222D', icon: '📰' },
        { label: '收藏总量', value: totalCollections, change: 18.2, color: '#FA8C16', icon: '⭐' }
      ];

      this.userGrowthData = [
        { date: '01', value: 12 }, { date: '02', value: 19 }, { date: '03', value: 15 },
        { date: '04', value: 25 }, { date: '05', value: 22 }, { date: '06', value: 30 },
        { date: '07', value: 28 }, { date: '08', value: 35 }, { date: '09', value: 31 },
        { date: '10', value: 38 }, { date: '11', value: 42 }, { date: '12', value: 36 },
        { date: '13', value: 45 }, { date: '14', value: 40 }
      ];

      this.healthRecordTrend = [
        { date: '周一', value: 85 }, { date: '周二', value: 92 },
        { date: '周三', value: 78 }, { date: '周四', value: 105 },
        { date: '周五', value: 98 }, { date: '周六', value: 62 },
        { date: '周日', value: 55 }
      ];

      this.appointmentTrend = [
        { date: '第1周', value: 120 }, { date: '第2周', value: 145 },
        { date: '第3周', value: 132 }, { date: '第4周', value: 158 }
      ];

      this.departmentStats = [
        { name: '内科', count: 245, color: '#1677FF' },
        { name: '外科', count: 189, color: '#52C41A' },
        { name: '儿科', count: 156, color: '#FAAD14' },
        { name: '妇产科', count: 134, color: '#EB2F96' },
        { name: '中医科', count: 98, color: '#722ED1' },
        { name: '康复科', count: 70, color: '#13C2C2' }
      ];

      this.riskDistribution = [
        { level: '高风险', count: highRiskCount, color: '#FF4D4F' },
        { level: '中风险', count: mediumRiskCount, color: '#FAAD14' },
        { level: '低风险', count: lowRiskCount, color: '#52C41A' }
      ];

      this.recentActivities = [
        { id: 1, type: '注册', user: '邓丽芳', action: '完成注册', target: '患者账号', time: '2分钟前', color: '#1677FF' },
        { id: 2, type: '记录', user: '王建国', action: '上传健康记录', target: '血压 135/85', time: '5分钟前', color: '#13C2C2' },
        { id: 3, type: '预约', user: '李淑琴', action: '创建预约', target: '心内科·张医生', time: '12分钟前', color: '#FAAD14' },
        { id: 4, type: '收藏', user: '张志强', action: '收藏文章', target: '高血压日常护理指南', time: '18分钟前', color: '#EB2F96' },
        { id: 5, type: '搜索', user: '刘美华', action: '搜索关键词', target: '糖尿病饮食', time: '25分钟前', color: '#722ED1' },
        { id: 6, type: '登录', user: '陈海涛', action: '登录系统', target: '', time: '30分钟前', color: '#999999' },
        { id: 7, type: '评价', user: '杨桂兰', action: '提交评价', target: '康复训练满意度', time: '45分钟前', color: '#52C41A' },
        { id: 8, type: '导出', user: '赵伟明', action: '导出健康报告', target: 'PDF格式', time: '1小时前', color: '#F5222D' }
      ];
    } catch (error) {
      console.error('AdminDataDashboard: 加载数据失败', error);
    } finally {
      this.isLoading = false;
    }
  }

  getMaxValue(items: TrendItem[]): number {
    let max: number = 0;
    for (let i = 0; i < items.length; i++) {
      if (items[i].value > max) max = items[i].value;
    }
    return max || 1;
  }

  build() {
    Column() {
      this.TitleBar();

      if (this.isLoading) {
        Column() {
          LoadingProgress().width(40).height(40).color('#1677FF');
          Text('加载大屏数据中...')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 12 });
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center);
      } else {
        Scroll() {
          Column({ space: 12 }) {
            this.MetricsGrid();
            Row({ space: 12 }) {
              Column() {
                this.UserGrowthChart();
              }
              .layoutWeight(1);

              Column() {
                this.HealthRecordChart();
              }
              .layoutWeight(1);
            };

            Row({ space: 12 }) {
              Column() {
                this.DepartmentDistribution();
              }
              .layoutWeight(1);

              Column() {
                this.RiskOverview();
              }
              .layoutWeight(1);
            };

            this.AppointmentTrendSection();
            this.RecentActivityFeed();
          }
          .padding(12)
          .width('100%');
        }
        .height(0)
        .layoutWeight(1)
        .scrollBar(BarState.Auto);
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#0B1120');
  }

  @Builder
  TitleBar() {
    Row() {
      Button({ type: ButtonType.Normal }) {
        Text('← 返回')
          .fontSize(14)
          .fontColor('#94A3B8');
      }
      .height(36)
      .backgroundColor('#1E293B')
      .borderRadius(8)
      .onClick(() => {
        router.back();
      });

      Column({ space: 2 }) {
        Text('📊 数据大屏')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#F1F5F9');

        Text('Harmony Health Care · 全局运营监控中心')
          .fontSize(11)
          .fontColor('#64748B');
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center);

      Row({ space: 6 }) {
        Circle().width(8).height(8).fill('#52C41A');
        Text('实时')
          .fontSize(11)
          .fontColor('#52C41A');
      }
      .padding({ left: 8, right: 8, top: 4, bottom: 4 })
      .backgroundColor('#064E3B20')
      .borderRadius(10);
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#0F172A')
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  MetricsGrid() {
    Grid() {
      ForEach(this.metrics, (metric: DashboardMetric) => {
        GridItem() {
          Column({ space: 8 }) {
            Row({ space: 8 }) {
              Text(metric.icon)
                .fontSize(22);

              Column({ space: 2 }) {
                Text(metric.label)
                  .fontSize(11)
                  .fontColor('#94A3B8');

                Row({ space: 4 }) {
                  Text(String(metric.change >= 0 ? '+' : '') + metric.change + '%')
                    .fontSize(10)
                    .fontColor(metric.change >= 0 ? '#52C41A' : '#FF4D4F');
                  Text(metric.change >= 0 ? '↑' : '↓')
                    .fontSize(10)
                    .fontColor(metric.change >= 0 ? '#52C41A' : '#FF4D4F');
                }
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start);
            }
            .width('100%');

            Text(typeof metric.value === 'number' ? String(metric.value) : metric.value)
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor(metric.color);
          }
          .width('100%')
          .height('100%')
          .padding(12)
          .backgroundColor('#1E293B')
          .borderRadius(12)
          .alignItems(HorizontalAlign.Start)
          .justifyContent(FlexAlign.SpaceBetween);
        }
      }, (metric: DashboardMetric) => metric.label);
    }
    .columnsTemplate('1fr 1fr 1fr 1fr')
    .rowsTemplate('1fr 1fr')
    .columnsGap(10)
    .rowsGap(10)
    .width('100%')
    .height(220);
  }

  @Builder
  UserGrowthChart() {
    Column({ space: 10 }) {
      Row() {
        Text('📈 用户增长趋势（近14天）')
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor('#F1F5F9')
          .layoutWeight(1);

        Text('+12.5%')
          .fontSize(11)
          .fontColor('#52C41A')
          .backgroundColor('#064E3B20')
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .borderRadius(6);
      }
      .width('100%');

      Column({ space: 4 }) {
        Flex({ justifyContent: FlexAlign.End }) {
          ForEach(this.userGrowthData, (item: TrendItem) => {
            Column() {
              Text(String(item.value))
                .fontSize(9)
                .fontColor('#64748B');
              Column()
                .width(14)
                .height(Math.max(item.value / this.getMaxValue(this.userGrowthData) * 80, 4))
                .linearGradient({
                  angle: 180,
                  colors: [['#1677FF', 0], ['#3B82F660', 1]]
                })
                .borderRadius({ topLeft: 4, topRight: 4 })
                .margin({ top: 2 });

              Text(item.date)
                .fontSize(8)
                .fontColor('#475569');
            }
            .alignItems(HorizontalAlign.Center);
          });
        }
        .width('100%')
        .height(110);
      }
      .width('100%')
      .padding(8)
      .backgroundColor('#1E293B')
      .borderRadius(8);
    }
    .width('100%')
    .padding(14)
    .backgroundColor('#0F172A')
    .borderRadius(12);
  }

  @Builder
  HealthRecordChart() {
    Column({ space: 10 }) {
      Row() {
        Text('🩺 健康记录趋势（本周）')
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor('#F1F5F9')
          .layoutWeight(1);

        Text('今日 +67')
          .fontSize(11)
          .fontColor('#13C2C2')
          .backgroundColor('#134E4A20')
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .borderRadius(6);
      }
      .width('100%');

      Column({ space: 4 }) {
        Flex({ justifyContent: FlexAlign.End }) {
          ForEach(this.healthRecordTrend, (item: TrendItem) => {
            Column() {
              Text(String(item.value))
                .fontSize(9)
                .fontColor('#64748B');
              Column()
                .width(18)
                .height(Math.max(item.value / this.getMaxValue(this.healthRecordTrend) * 80, 4))
                .linearGradient({
                  angle: 180,
                  colors: [['#13C2C2', 0], ['#36D39960', 1]]
                })
                .borderRadius({ topLeft: 4, topRight: 4 })
                .margin({ top: 2 });

              Text(item.date)
                .fontSize(8)
                .fontColor('#475569');
            }
            .alignItems(HorizontalAlign.Center);
          });
        }
        .width('100%')
        .height(110);
      }
      .width('100%')
      .padding(8)
      .backgroundColor('#1E293B')
      .borderRadius(8);
    }
    .width('100%')
    .padding(14)
    .backgroundColor('#0F172A')
    .borderRadius(12);
  }

  @Builder
  DepartmentDistribution() {
    Column({ space: 10 }) {
      Text('🏥 科室预约分布')
        .fontSize(13)
        .fontWeight(FontWeight.Bold)
        .fontColor('#F1F5F9')
        .width('100%');

      Column({ space: 8 }) {
        ForEach(this.departmentStats, (dept: DepartmentStat) => {
          Column({ space: 4 }) {
            Row() {
              Text(dept.name)
                .fontSize(11)
                .fontColor('#CBD5E1')
                .width(50);

              Stack({ alignContent: Alignment.End }) {
                Row()
                  .width((dept.count / 260) * 100 + '%')
                  .height(16)
                  .backgroundColor(dept.color + '40')
                  .borderRadius(8);

                Text(dept.count + '次')
                  .fontSize(10)
                  .fontColor(dept.color)
                  .margin({ right: 4 });
              }
              .layoutWeight(1);
            }
            .width('100%')
            .alignItems(VerticalAlign.Center);
          };
        });
      }
      .width('100%')
      .padding(10)
      .backgroundColor('#1E293B')
      .borderRadius(8);
    }
    .width('100%')
    .padding(14)
    .backgroundColor('#0F172A')
    .borderRadius(12);
  }

  @Builder
  RiskOverview() {
    Column({ space: 10 }) {
      Text('⚠️ 风险评估分布')
        .fontSize(13)
        .fontWeight(FontWeight.Bold)
        .fontColor('#F1F5F9')
        .width('100%');

      Column({ space: 10 }) {
        ForEach(this.riskDistribution, (risk: RiskDistribution) => {
          Row({ space: 10 }) {
            Column()
              .width(12)
              .height(12)
              .borderRadius(6)
              .backgroundColor(risk.color);

            Column({ space: 2 }) {
              Text(risk.level)
                .fontSize(12)
                .fontColor('#CBD5E1');

              Text(risk.count + ' 人')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor(risk.color);
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start);

            Text(((risk.count / AdminMock.users.length) * 100).toFixed(1) + '%')
              .fontSize(12)
              .fontColor('#64748B');
          }
          .width('100%')
          .alignItems(VerticalAlign.Center);
        });
      }
      .width('100%')
      .padding(10)
      .backgroundColor('#1E293B')
      .borderRadius(8);
    }
    .width('100%')
    .padding(14)
    .backgroundColor('#0F172A')
    .borderRadius(12);
  }

  @Builder
  AppointmentTrendSection() {
    Column({ space: 10 }) {
      Row() {
        Text('📅 月度预约趋势')
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor('#F1F5F9')
          .layoutWeight(1);

        Text('待处理 23')
          .fontSize(11)
          .fontColor('#FAAD14')
          .backgroundColor('#78350F20')
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .borderRadius(6);
      }
      .width('100%');

      Row({ space: 8 }) {
        ForEach(this.appointmentTrend, (item: TrendItem) => {
          Column({ space: 6 }) {
            Text(item.date)
              .fontSize(10)
              .fontColor('#64748B');
            Text(String(item.value))
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#EB2F96');
            Column()
              .width(40)
              .height(4)
              .backgroundColor('#EB2F9640')
              .borderRadius(2);
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)
          .padding(8)
          .backgroundColor('#1E293B')
          .borderRadius(8);
        });
      }
      .width('100%');
    }
    .width('100%')
    .padding(14)
    .backgroundColor('#0F172A')
    .borderRadius(12);
  }

  @Builder
  RecentActivityFeed() {
    Column({ space: 10 }) {
      Row() {
        Text('⚡ 实时动态流')
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor('#F1F5F9')
          .layoutWeight(1);

        Row({ space: 4 }) {
          Circle().width(6).height(6).fill('#52C41A');
          Text('LIVE')
            .fontSize(10)
            .fontColor('#52C41A')
            .fontWeight(FontWeight.Bold);
        }
      }
      .width('100%');

      Column({ space: 6 }) {
        ForEach(this.recentActivities, (activity: ActivityItem) => {
          Row({ space: 10 }) {
            Column()
              .width(3)
              .height(32)
              .borderRadius(2)
              .backgroundColor(activity.color);

            Column({ space: 3 }) {
              Row({ space: 8 }) {
                Text(activity.type)
                  .fontSize(10)
                  .fontColor(activity.color)
                  .backgroundColor(activity.color + '15')
                  .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                  .borderRadius(4);

                Text(activity.user)
                  .fontSize(12)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#E2E8F0');

                Text(activity.action)
                  .fontSize(12)
                  .fontColor('#94A3B8');
              }
              .width('100%');

              Row({ space: 6 }) {
                if (activity.target) {
                  Text(activity.target)
                    .fontSize(11)
                    .fontColor('#64748B')
                    .maxLines(1);
                }

                Blank();

                Text(activity.time)
                  .fontSize(10)
                  .fontColor('#475569');
              }
              .width('100%');
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start);
          }
          .width('100%')
          .padding(8)
          .backgroundColor('#1E293B30')
          .borderRadius(8)
          .alignItems(VerticalAlign.Center);
        });
      }
      .width('100%')
      .padding(10)
      .backgroundColor('#1E293B')
      .borderRadius(8);
    }
    .width('100%')
    .padding(14)
    .backgroundColor('#0F172A')
    .borderRadius(12);
  }
}
