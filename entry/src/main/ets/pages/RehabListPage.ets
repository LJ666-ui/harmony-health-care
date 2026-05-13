import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';
import BrowseTracker from '../utils/BrowseTracker';
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
  videoUrl: string;
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

  @State courses: RehabCourse[] = [];

  @State isLoading: boolean = false;
  @State loadError: string = '';

  @State searchKeyword: string = '';
  @State currentPage: number = 1;
  @State pageSize: number = 20;
  @State totalCount: number = 0;
  @State totalPages: number = 0;

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') || false;
    }

    this.loadCoursesFromAPI();

    BrowseTracker.recordStart('REHAB_LIST', 'PAGE', 6, '康复课程列表').then(id => {
      this.recordId = id;
    });
  }

  async loadCoursesFromAPI(): Promise<void> {
    if (this.isLoading) return;

    this.isLoading = true;
    this.loadError = '';

    try {
      let url: string = ApiConstants.REHAB_ACTION_LIST + '?pageNum=' + this.currentPage + '&pageSize=' + this.pageSize;

      if (this.searchKeyword.trim()) {
        url = url + '&keyword=' + encodeURIComponent(this.searchKeyword.trim());
      }

      console.info('=== 开始加载康复课程 ===');
      console.info('API URL:', url);

      const response: BaseResponse<PageResult<RehabActionData>> = await HttpUtil.get<PageResult<RehabActionData>>(url);

      console.info('API响应成功:', JSON.stringify(response));

      if (response.success && response.data) {
        const pageData: PageResult<RehabActionData> = response.data;
        console.info('分页数据:', `total=${pageData.total}, records长度=${pageData.records?.length}`);

        this.totalCount = pageData.total ? pageData.total : 0;
        this.totalPages = pageData.pages ? pageData.pages : Math.ceil(this.totalCount / this.pageSize);
        if (this.totalPages < 1) {
          this.totalPages = 1;
        }

        if (pageData.records && Array.isArray(pageData.records) && pageData.records.length > 0) {
          console.info(`开始转换 ${pageData.records.length} 条数据...`);

          const apiCourses: RehabCourse[] = pageData.records.map((action: RehabActionData, idx: number): RehabCourse => {

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

          console.info(`转换完成，共 ${apiCourses.length} 个课程`);
          this.courses = apiCourses;
        } else {
          console.warn('⚠️ API返回的records为空或不是数组');
          this.loadError = '暂无康复课程数据';
          this.courses = [];
        }
      } else {
        console.warn('⚠️ API返回失败或data为空:', response.message);
        this.loadError = response.message || '加载失败';
      }
    } catch (error) {
      console.error('❌ 加载康复课程异常:', error);
      this.loadError = '网络错误：' + (error as Error).message;
    } finally {
      this.isLoading = false;
    }
  }

  private calculateDifficulty(duration: number, sets: number): string {
    if (duration <= 600 && sets <= 2) return '初级';
    if (duration <= 1200 && sets <= 4) return '中级';
    return '高级';
  }

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

  aboutToDisappear(): void {
    if (this.recordId > 0) {
      BrowseTracker.recordEnd(this.recordId);
    }
  }

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

          this.searchSection();

          if (this.isLoading && this.courses.length === 0) {
            Column() {
              LoadingProgress()
                .width(50)
                .height(50)
                .color(GlobalTheme.THEME_COLOR);

              Text('正在加载康复课程...')
                .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                .fontColor(GlobalTheme.TEXT_SECONDARY)
                .margin({ top: 10 });
            }
            .width('100%')
            .height(200)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center);
          } else if (this.loadError !== '' && this.courses.length === 0) {
            Column() {
              Text('\u{1F4ED}')
                .fontSize(48)
                .margin({ bottom: 12 });
              Text(this.loadError)
                .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                .fontColor('#FF6B6B')
                .textAlign(TextAlign.Center);

              Button('重新加载')
                .type(ButtonType.Normal)
                .borderRadius(20)
                .backgroundColor(GlobalTheme.THEME_COLOR)
                .width(150)
                .height(40)
                .margin({ top: 15 })
                .onClick(() => this.loadCoursesFromAPI());
            }
            .width('100%')
            .padding(20);
          } else if (this.courses.length === 0) {
            Column() {
              Text('\u{1F4ED}')
                .fontSize(48)
                .margin({ bottom: 12 });
              Text(this.searchKeyword.trim() ? '未找到相关课程' : '暂无康复课程')
                .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                .fontColor(GlobalTheme.TEXT_SECONDARY);
            }
            .width('100%')
            .height(200)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center);
          } else {
            List() {
              ForEach(this.courses, (course: RehabCourse) => {
                ListItem() {
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
                        Text('\u23F1 ' + course.duration)
                          .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                          .fontColor(GlobalTheme.TEXT_HINT);
                        Text('\U0001F4CA ' + course.difficulty)
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
                  router.pushUrl({
                    url: 'pages/RehabCourseVideoPage',
                    params: {
                      courseId: course.id,
                      courseTitle: course.title,
                      courseIcon: course.icon,
                      courseDescription: course.description,
                      courseDuration: course.duration,
                      courseDifficulty: course.difficulty,
                      courseTargetGroup: course.targetGroup,
                      videoUrl: course.videoUrl
                    }
                  });
                });
              }, (course: RehabCourse) => course.id);

              ListItem() {
                this.paginationBar();
              }
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
      .scrollBar(BarState.Off)
      .align(Alignment.Top);

      Footer({ activeIndex: 2 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor(GlobalTheme.BG_COLOR);
  }
}
