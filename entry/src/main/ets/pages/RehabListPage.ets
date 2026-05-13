import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';
import BrowseTracker from '../utils/BrowseTracker';
import { AIOrchestrator } from '../ai/orchestrator/AIOrchestrator';
import { AIRequestBuilder } from '../ai/utils/AIRequestBuilder';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';

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
  videoUrl?: string;
}

interface RehabActionData {
  id: number;
  planId: number;
  actionName: string;
  actionDesc: string;
  duration: number;
  sets: number;
  reps: number;
  videoUrl: string;
  model3dUrl: string;
}

interface PageResult<T> {
  records: T[];
  total: number;
  size: number;
  current: number;
  pages: number;
}

@Entry
@Component
struct RehabListPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State recordId: number = 0;

  // AI 相关
  @State aiFilteredCourses: RehabCourse[] = [];
  @State aiRecommendation: string = '';
  @State userId: number = 1;
  private orchestrator: AIOrchestrator = AIOrchestrator.getInstance();

  // 课程数据（API + 本地兜底）
  @State courses: RehabCourse[] = [];
  @State localDefaultCourses: RehabCourse[] = [
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

  // 加载与分页
  @State isLoading: boolean = false;
  @State loadError: string = '';
  @State searchKeyword: string = '';
  @State currentPage: number = 1;
  @State pageSize: number = 20;
  @State totalCount: number = 0;
  @State totalPages: number = 0;
  @State isRefreshing: boolean = false;

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') || false;
    }

    // 加载网络课程
    this.loadCoursesFromAPI();
    // AI推荐
    this.getAICourseRecommendation();

    BrowseTracker.recordStart('REHAB_LIST', 'PAGE', 6, '康复课程列表').then(id => {
      this.recordId = id;
    });
  }

  aboutToDisappear(): void {
    if (this.recordId > 0) {
      BrowseTracker.recordEnd(this.recordId);
    }
  }

  // ==================== 下拉刷新 ====================
  handleRefresh(): void {
    this.isRefreshing = true;
    setTimeout(() => {
      this.currentPage = 1;
      this.loadCoursesFromAPI();
      this.isRefreshing = false;
      ToastUtil.refreshSuccess();
    }, 1000);
  }

  // ==================== API 加载课程 ====================
  async loadCoursesFromAPI(): Promise<void> {
    if (this.isLoading) return;

    this.isLoading = true;
    this.loadError = '';

    try {
      let url: string = ApiConstants.REHAB_ACTION_LIST + '?pageNum=' + this.currentPage + '&pageSize=' + this.pageSize;

      if (this.searchKeyword.trim()) {
        url += '&keyword=' + encodeURIComponent(this.searchKeyword.trim());
      }

      const response: BaseResponse<PageResult<RehabActionData>> = await HttpUtil.get<PageResult<RehabActionData>>(url);

      if (response.success && response.data) {
        const pageData: PageResult<RehabActionData> = response.data;
        this.totalCount = pageData.total ?? 0;
        this.totalPages = pageData.pages ?? Math.ceil(this.totalCount / this.pageSize);
        this.totalPages = Math.max(1, this.totalPages);

        if (pageData.records && pageData.records.length > 0) {
          const apiCourses: RehabCourse[] = pageData.records.map((action: RehabActionData): RehabCourse => {
            let fullVideoUrl = action.videoUrl || '';
            if (fullVideoUrl) {
              fullVideoUrl = fullVideoUrl.replace('localhost:8080', '10.0.2.2:8080');
            }
            return {
              id: String(action.id),
              icon: '🏃',
              title: action.actionName,
              description: action.actionDesc || '',
              duration: action.duration > 0 ? `${Math.floor(action.duration / 60)}分钟` : '待定',
              difficulty: this.calculateDifficulty(action.duration || 900, action.sets || 3),
              targetGroup: '康复训练',
              completedCount: 0,
              totalCount: Math.max(1, (action.sets || 3) * (action.reps || 10)),
              videoUrl: fullVideoUrl
            };
          });
          this.courses = apiCourses;
        } else {
          this.courses = this.localDefaultCourses;
          this.loadError = '暂无网络数据，已加载本地课程';
        }
      } else {
        this.courses = this.localDefaultCourses;
        this.loadError = response.message || '加载失败，已使用本地数据';
      }
    } catch (error) {
      console.error('加载课程异常:', error);
      this.courses = this.localDefaultCourses;
      this.loadError = '网络异常，已加载本地默认课程';
    } finally {
      this.isLoading = false;
    }
  }

  // ==================== AI 推荐 / 筛选 ====================
  async getAICourseRecommendation(): Promise<void> {
    try {
      const request = AIRequestBuilder.createDataRequest(
        '请根据我的健康状况推荐最适合的康复训练课程',
        'rehabilitation_guidance',
        String(this.userId)
      );
      const response = await this.orchestrator.process(request);
      this.aiRecommendation = typeof response.output.content === 'string'
        ? response.output.content
        : JSON.stringify(response.output.content);
    } catch (error) {
      console.error('AI推荐失败:', error);
      this.aiRecommendation = 'AI推荐暂时不可用';
    }
  }

  async filterCoursesWithAI(userCondition: string): Promise<void> {
    try {
      const request = AIRequestBuilder.createDataRequest(
        `我的情况：${userCondition}，请从以下课程中筛选适合我的：${this.courses.map(c => c.title).join('，')}`,
        'rehabilitation_guidance',
        String(this.userId)
      );
      const response = await this.orchestrator.process(request);
      const contentStr = typeof response.output.content === 'string'
        ? response.output.content
        : JSON.stringify(response.output.content);
      const recommendedTitles = contentStr.split('，').map(t => t.trim());
      this.aiFilteredCourses = this.courses.filter(course =>
      recommendedTitles.some(title => course.title.includes(title))
      );
    } catch (error) {
      console.error('AI筛选失败:', error);
      this.aiFilteredCourses = [];
    }
  }

  // ==================== 工具方法 ====================
  private calculateDifficulty(duration: number, sets: number): string {
    if (duration <= 600 && sets <= 2) return '初级';
    if (duration <= 1200 && sets <= 4) return '中级';
    return '高级';
  }

  // ==================== 搜索与分页 ====================
  handleSearch(): void {
    this.currentPage = 1;
    this.loadCoursesFromAPI();
  }

  handleClearSearch(): void {
    this.searchKeyword = '';
    this.currentPage = 1;
    this.loadCoursesFromAPI();
  }

  goToPage(page: number): void {
    if (page < 1 || page > this.totalPages || page === this.currentPage || this.isLoading) return;
    this.currentPage = page;
    this.loadCoursesFromAPI();
  }

  prevPage(): void {
    this.goToPage(this.currentPage - 1);
  }

  nextPage(): void {
    this.goToPage(this.currentPage + 1);
  }

  // ==================== 页面构建 ====================
  @Builder searchSection(): void {
    Row({ space: 8 }) {
      Row({ space: 6 }) {
        Text('\u{1F50E}')
          .fontSize(16)
        TextInput({ text: this.searchKeyword, placeholder: '搜索康复课程...' })
          .layoutWeight(1)
          .height(36)
          .fontSize(this.isElderMode ? 16 : 14)
          .backgroundColor('transparent')
          .border({ width: 0 })
          .onChange((value: string) => {
            this.searchKeyword = value;
          })
          .onSubmit(() => {
            this.handleSearch();
          })
        if (this.searchKeyword) {
          Text('\u2715')
            .fontSize(14)
            .fontColor('#999999')
            .padding(6)
            .onClick(() => {
              this.handleClearSearch();
            })
        }
      }
      .layoutWeight(1)
      .height(40)
      .backgroundColor('#F5F7FA')
      .borderRadius(20)
      .padding({ left: 12, right: 8 })

      Button('搜索')
        .height(36)
        .fontSize(14)
        .fontColor('#FFFFFF')
        .backgroundColor(GlobalTheme.THEME_COLOR)
        .borderRadius(18)
        .onClick(() => {
          this.handleSearch();
        });
    }
    .width('100%')
    .margin({ bottom: 12 })
  }

  @Builder paginationBar(): void {
    Row({ space: 8 }) {
      Text('共' + this.totalCount + '条')
        .fontSize(12)
        .fontColor('#999999')

      Text('\u25C0')
        .fontSize(14)
        .fontColor(this.currentPage <= 1 ? '#CCCCCC' : GlobalTheme.THEME_COLOR)
        .padding({ left: 10, right: 10, top: 6, bottom: 6 })
        .backgroundColor(this.currentPage <= 1 ? '#F5F5F5' : GlobalTheme.THEME_COLOR + '15')
        .borderRadius(6)
        .onClick(() => {
          this.prevPage();
        })

      Text(this.currentPage + ' / ' + this.totalPages)
        .fontSize(13)
        .fontColor('#333333')
        .fontWeight(FontWeight.Medium)
        .padding({ left: 12, right: 12, top: 6, bottom: 6 })

      Text('\u25B6')
        .fontSize(14)
        .fontColor(this.currentPage >= this.totalPages ? '#CCCCCC' : GlobalTheme.THEME_COLOR)
        .padding({ left: 10, right: 10, top: 6, bottom: 6 })
        .backgroundColor(this.currentPage >= this.totalPages ? '#F5F5F5' : GlobalTheme.THEME_COLOR + '15')
        .borderRadius(6)
        .onClick(() => {
          this.nextPage();
        })
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ top: 12, bottom: 12 })
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

          // 搜索栏
          this.searchSection();

          // 加载状态
          if (this.isLoading && this.courses.length === 0) {
            Column() {
              LoadingProgress().width(50).height(50).color(GlobalTheme.THEME_COLOR);
              Text('正在加载康复课程...')
                .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                .fontColor(GlobalTheme.TEXT_SECONDARY)
                .margin({ top: 10 });
            }
            .width('100%')
            .height(200)
            .justifyContent(FlexAlign.Center);
          }
          // 错误/空状态
          else if (this.loadError !== '' && this.courses.length === 0) {
            Column() {
              Text('\u{1F4ED}').fontSize(48).margin({ bottom: 12 });
              Text(this.loadError)
                .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                .fontColor('#FF6B6B')
                .textAlign(TextAlign.Center);
              Button('重新加载')
                .borderRadius(20)
                .backgroundColor(GlobalTheme.THEME_COLOR)
                .width(150)
                .height(40)
                .margin({ top: 15 })
                .onClick(() => this.loadCoursesFromAPI());
            }
            .width('100%')
            .padding(20);
          }
          // 正常展示
          else {
            List() {
              ForEach(this.aiFilteredCourses.length > 0 ? this.aiFilteredCourses : this.courses, (course: RehabCourse) => {
                ListItem() {
                  Row() {
                    // 图标
                    Column() {
                      Text(course.icon).fontSize(36)
                    }
                    .width(64)
                    .height(64)
                    .backgroundColor(GlobalTheme.THEME_COLOR + '20')
                    .borderRadius(32)
                    .justifyContent(FlexAlign.Center)
                    .margin({ right: GlobalTheme.getSpacingMD(this.isElderMode) });

                    // 信息
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
                        Text('⏱ ' + course.duration)
                          .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                          .fontColor(GlobalTheme.TEXT_HINT);
                        Text('📊 ' + course.difficulty)
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
                  // 优先跳视频页，无视频则跳3D页
                  if (course.videoUrl) {
                    router.pushUrl({
                      url: 'pages/RehabCourseVideoPage',
                      params: { ...course }
                    });
                  } else {
                    router.pushUrl({ url: 'pages/Rehab3DPage?courseId=' + course.id });
                  }
                });
              }, (course: RehabCourse) => course.id);

              // 分页
              ListItem() { this.paginationBar(); }
            }
            .width('100%')
            .layoutWeight(1);
          }
        }
        .width('85%')
        .padding({ bottom: GlobalTheme.getSpacingLG(this.isElderMode) });
      }
      .height(0)
      .layoutWeight(1)
      .scrollBar(BarState.Off);

      Footer({ activeIndex: 2 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor(GlobalTheme.BG_COLOR);
  }
}