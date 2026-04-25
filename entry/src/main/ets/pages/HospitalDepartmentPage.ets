import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { Loading } from '../components/Loading';
import { EmptyState } from '../components/EmptyState';
import { HttpUtil, BaseResponse, HttpMethod } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import { GlobalTheme } from '../global';

@Entry
@Component
struct HospitalDepartmentPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State hospitalId: number = 0;
  @State hospitalNameDisplay: string = '';
  @State departments: object[] = [];
  @State searchKeyword: string = '';
  @State isLoading: boolean = true;
  @State hasError: boolean = false;
  @State errorMessage: string = '';

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') || false;
    }

    try {
      const params = router.getParams() as Record<string, Object> | undefined;
      
      if (params && params['hospitalId']) {
        const id = params['hospitalId'];
        const name = params['hospitalName'];
        
        if (id !== undefined && id !== null) {
          this.hospitalId = typeof id === 'number' ? id : Number(id);
        }
        
        if (name !== undefined && name !== null && name !== '') {
          this.hospitalNameDisplay = String(name);
        }
      }
    } catch (error) {
      console.error('获取路由参数失败:', error);
    }

    if (!this.hospitalId || this.hospitalId <= 0) {
      this.hasError = true;
      this.errorMessage = '无效的医院ID';
      this.isLoading = false;
      return;
    }

    this.loadDepartments();
  }

  async loadDepartments(): Promise<void> {
    this.isLoading = true;

    try {
      const queryParams: Record<string, number> = { 'hospitalId': this.hospitalId };
      
      const response: BaseResponse<object[]> = await HttpUtil.request<object[]>(
        HttpMethod.GET,
        ApiConstants.HOSPITAL_DEPARTMENT_LIST,
        undefined,
        queryParams as Object,
        { showLoading: true, loadingText: '加载科室信息...' }
      );

      if (response.success && response.data) {
        this.departments = response.data;
        
        if (this.departments.length === 0) {
          this.errorMessage = '该医院暂无科室信息';
        }
      } else {
        this.hasError = true;
        this.errorMessage = response.message || '加载科室列表失败';
      }
    } catch (error) {
      this.hasError = true;
      this.errorMessage = '网络错误，请检查网络连接';
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      Header({ title: this.hospitalNameDisplay || '医院科室', showBack: true })

      if (this.isLoading) {
        Loading({ text: '加载中...' })
      } else if (this.hasError) {
        EmptyState({
          title: '加载失败',
          description: this.errorMessage,
          buttonText: '重新加载',
          onAdd: () => this.loadDepartments()
        })
      } else {
        Scroll() {
          Column() {
            Text('科室列表')
              .fontSize(this.isElderMode ? 22 : 18)
              .fontWeight(FontWeight.Bold)
              .fontColor(GlobalTheme.TEXT_PRIMARY)
              .margin({ left: 16, top: 20, bottom: 12 })
              .alignSelf(ItemAlign.Start)

            Row() {
              TextInput({ placeholder: '搜索科室名称...', text: this.searchKeyword })
                .fontSize(this.isElderMode ? 17 : 14)
                .height(this.isElderMode ? 44 : 36)
                .backgroundColor('#FFFFFF')
                .borderRadius(20)
                .padding({ left: 16, right: 16 })
                .layoutWeight(1)
                .onChange((value: string) => {
                  this.searchKeyword = value;
                })

              if (this.searchKeyword.length > 0) {
                Button('清除')
                  .fontSize(this.isElderMode ? 15 : 12)
                  .backgroundColor('#F5F5F5')
                  .fontColor('#666666')
                  .height(this.isElderMode ? 44 : 36)
                  .borderRadius(6)
                  .margin({ left: 8 })
                  .onClick(() => {
                    this.searchKeyword = '';
                  })
              }
            }
            .width('100%')
            .padding({ left: 16, right: 16, bottom: 12 })

            if (this.departments.length === 0) {
              EmptyState({
                icon: '🏥',
                title: '暂无科室信息',
                description: this.errorMessage || '该医院暂无可用科室'
              })
                .width('100%')
                .height(200)
            } else {
              List({ space: 12 }) {
                ForEach(this.departments, (dept: object, index: number) => {
                  ListItem() {
                    Column() {
                      Text((dept as Record<string, string>)['deptName'] || '未知科室')
                        .fontSize(this.isElderMode ? 19 : 16)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(GlobalTheme.TEXT_PRIMARY)
                        .width('100%')
                        .textAlign(TextAlign.Start)

                      Row() {
                        if ((dept as Record<string, string>)['location']) {
                          Text(`📍 ${(dept as Record<string, string>)['location']}`)
                            .fontSize(this.isElderMode ? 15 : 12)
                            .fontColor(GlobalTheme.THEME_COLOR)
                        }
                      }
                      .width('100%')
                      .margin({ top: 8 })

                      if ((dept as Record<string, string>)['deptIntro']) {
                        Text((dept as Record<string, string>)['deptIntro'] || '')
                          .fontSize(this.isElderMode ? 15 : 12)
                          .fontColor(GlobalTheme.TEXT_SECONDARY)
                          .width('100%')
                          .maxLines(3)
                          .textOverflow({ overflow: TextOverflow.Ellipsis })
                          .margin({ top: 8 })
                          .lineHeight(18)
                      }
                    }
                    .width('100%')
                    .padding(16)
                    .backgroundColor('#FFFFFF')
                    .borderRadius(8)
                    .alignItems(HorizontalAlign.Start)
                  }
                }, (dept: object, index: number) => `${index}`)
              }
              .width('100%')
              .height('100%')
              .padding({ left: 16, right: 16, bottom: 20 })
              .layoutWeight(1)
            }
          }
        }
        .scrollBar(BarState.Off)
        .layoutWeight(1)
      }

      Footer({ activeIndex: 1 });
    }
    .height('100%')
    .backgroundColor(GlobalTheme.BG_COLOR)
  }
}
