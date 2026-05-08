import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { Loading } from '../components/Loading';
import { EmptyState } from '../components/EmptyState';
import { HttpUtil, BaseResponse, HttpMethod } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import { ToastUtil } from '../common/utils/ToastUtil';
import { GlobalTheme } from '../global';

class HospitalItem {
  id: number = 0;
  name: string = '';
  address: string = '';
  phone: string = '';
  level: string = '';
  department: string = '';
  description: string = '';
}

interface HospitalPageData {
  records: HospitalItem[];
}

@Entry
@Component
struct HospitalPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State hospitals: HospitalItem[] = [];
  @State selectedLevel: string = '全部';
  @State isLoading: boolean = true;
  @State hasError: boolean = false;
  @State errorMessage: string = '';

  private levels: string[] = ['全部', '三级甲等', '综合医院', '社区医院', '专科医院', '卫生院', '保健机构', '诊所'];
  private isRequesting: boolean = false;

  async loadHospitalList(filterLevel?: string): Promise<void> {
    if (this.isRequesting) {
      console.log('[HospitalPage] 请求进行中，跳过重复请求');
      return;
    }

    this.isRequesting = true;
    this.isLoading = true;
    this.hasError = false;

    try {
      let url: string = ApiConstants.HOSPITAL_LIST;
      let queryParams: Record<string, string> | undefined = undefined;
      
      if (filterLevel && filterLevel !== '全部') {
        url = ApiConstants.HOSPITAL_PAGE;
        queryParams = {
          'level': filterLevel,
          'page': '1',
          'size': '500'
        };
      }

      let response: BaseResponse<HospitalItem[]>;
      
      if (queryParams) {
        response = await HttpUtil.request<HospitalItem[]>(
          HttpMethod.GET,
          url,
          undefined,
          queryParams,
          { showLoading: false, loadingText: '加载医院列表...' }
        );
      } else {
        response = await HttpUtil.request<HospitalItem[]>(
          HttpMethod.GET,
          url,
          undefined,
          undefined,
          { showLoading: false, loadingText: '加载医院列表...' }
        );
      }

      if (response.success && response.data) {
        let hospitalList: HospitalItem[] = [];
        const data: Object = response.data;
        
        if (Array.isArray(data)) {
          hospitalList = data;
        } else if (data && typeof data === 'object') {
          const pageData = data as HospitalPageData;
          if (pageData.records && Array.isArray(pageData.records)) {
            hospitalList = pageData.records;
          }
        }
        
        if (hospitalList.length > 0) {
          this.hospitals = hospitalList;
        } else {
          this.hospitals = [];
          this.errorMessage = '暂无医院数据';
        }
      } else {
        this.hasError = true;
        this.errorMessage = response.message || '加载医院列表失败';
        ToastUtil.showError(this.errorMessage, 2000);
      }
    } catch (error) {
      this.hasError = true;
      const err = error as Error;
      this.errorMessage = err?.message || '网络错误，请检查网络连接';
      console.error('[HospitalPage] 加载医院列表失败:', error);
      ToastUtil.showError(this.errorMessage, 2000);
    } finally {
      this.isLoading = false;
      this.isRequesting = false;
    }
  }

  onLevelSelect(level: string): void {
    this.selectedLevel = level;
    this.loadHospitalList(level);
  }

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') || false;
    }
    this.loadHospitalList();
  }

  openARNavigation(): void {
    router.pushUrl({ url: 'pages/DestinationSelectPage' }).catch((error: Error) => {
      console.error('导航失败:', error.message);
    });
  }

  build() {
    Column() {
      Header({ title: '医院列表', showBack: true });

      if (this.isLoading) {
        Loading({ text: '加载中...' })
      } else if (this.hasError) {
        EmptyState({
          title: '加载失败',
          description: this.errorMessage,
          buttonText: '重新加载',
          onAdd: () => this.loadHospitalList(this.selectedLevel !== '全部' ? this.selectedLevel : undefined)
        })
      } else {
        Scroll() {
          Column({ space: GlobalTheme.getSpacingLG(this.isElderMode) }) {
            Text('医院列表')
              .fontSize(GlobalTheme.getFontSizeTitle(this.isElderMode))
              .fontWeight('bold')
              .fontColor(GlobalTheme.THEME_COLOR)
              .margin({ top: GlobalTheme.getSpacingLG(this.isElderMode), bottom: GlobalTheme.getSpacingMD(this.isElderMode) });

            Button('🧭 院内AR导航')
              .width('100%')
              .height(GlobalTheme.getButtonHeight(this.isElderMode))
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontWeight('bold')
              .fontColor('#FFFFFF')
              .backgroundColor(GlobalTheme.THEME_COLOR)
              .borderRadius(GlobalTheme.RADIUS_LG)
              .onClick(() => this.openARNavigation());

            Text('按等级筛选')
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontColor(GlobalTheme.TEXT_SECONDARY)
              .margin({ top: GlobalTheme.getSpacingSM(this.isElderMode), bottom: GlobalTheme.getSpacingXS(this.isElderMode) })
              .alignSelf(ItemAlign.Start)

            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.levels, (level: string, index: number) => {
                Text(level)
                  .fontSize(this.isElderMode ? 16 : 14)
                  .fontColor(this.selectedLevel === level ? '#FFFFFF' : GlobalTheme.THEME_COLOR)
                  .backgroundColor(this.selectedLevel === level ? GlobalTheme.THEME_COLOR : '#F5F5F5')
                  .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                  .borderRadius(20)
                  .margin({ right: 8, bottom: 8 })
                  .onClick(() => {
                    this.onLevelSelect(level);
                  })
              }, (level: string, index: number) => `${index}_${level}`)
            }
            .width('100%')

            Text(`当前显示: ${this.selectedLevel} (${this.hospitals.length}家)`)
              .fontSize(12)
              .fontColor('#999')
              .margin({ top: 4 })

            if (this.hospitals.length === 0) {
              EmptyState({
                icon: '🏥',
                title: '暂无数据',
                description: this.selectedLevel === '全部' ? '暂无医院数据' : `暂无${this.selectedLevel}医院`
              })
                .width('100%')
                .height(200)
            } else {
              List({ space: 10 }) {
                ForEach(this.hospitals, (item: HospitalItem, index: number) => {
                  ListItem() {
                    Button() {
                      Column() {
                        Row() {
                          Text(item.name || '未知医院')
                            .fontSize(this.isElderMode ? 17 : 14)
                            .fontWeight(FontWeight.Bold)
                            .fontColor('#333333')
                            .textAlign(TextAlign.Start)
                          Blank()
                          Text('查看科室 >')
                            .fontSize(this.isElderMode ? 14 : 12)
                            .fontColor('#1677FF')
                        }
                        .width('100%')

                        if (item.level && item.level !== '') {
                          Text(item.level)
                            .fontSize(this.isElderMode ? 13 : 11)
                            .fontColor('#1677FF')
                            .width('100%')
                            .textAlign(TextAlign.Start)
                            .margin({ top: 4 })
                        }

                        if (item.address && item.address !== '') {
                          Text(item.address)
                            .fontSize(this.isElderMode ? 13 : 11)
                            .fontColor('#666666')
                            .width('100%')
                            .textAlign(TextAlign.Start)
                            .margin({ top: 2 })
                        }
                      }
                      .alignItems(HorizontalAlign.Start)
                    }
                    .width('100%')
                    .height('auto')
                    .backgroundColor('#FFFFFF')
                    .borderRadius(10)
                    .padding(14)
                    .type(ButtonType.Normal)
                    .onClick(() => {
                      router.pushUrl({
                        url: 'pages/HospitalDepartmentPage',
                        params: {
                          hospitalId: item.id,
                          hospitalName: item.name
                        }
                      }).catch((err: Error) => {
                        console.error('[跳转失败]', err.message);
                      });
                    })
                  }
                }, (item: HospitalItem, index: number) => `${item.id}_${index}`)
              }
              .width('100%')
              .layoutWeight(1)
              .padding({ left: 8, right: 8 })
            }
          }
          .width('85%')
          .padding({ top: GlobalTheme.getSpacingLG(this.isElderMode), bottom: GlobalTheme.getSpacingLG(this.isElderMode) });
        }
        .height(0)
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top);
      }

      Footer({ activeIndex: 1 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor(GlobalTheme.BG_COLOR);
  }
}
