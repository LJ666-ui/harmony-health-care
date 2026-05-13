import { router } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { Loading } from '../components/Loading';
import { EmptyState } from '../components/EmptyState';
import { HttpUtil, BaseResponse, HttpMethod } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import { ToastUtil } from '../common/utils/ToastUtil';
import { GlobalTheme } from '../global';
import hospitalCacheManager, { HospitalCacheItem } from '../utils/HospitalCacheManager';
import { convertLevelToDbValue } from '../constants/DataDictionary';
import type { Hospital, HospitalPageData } from '../models/Hospital';

const TAG = 'HospitalPage';

class HospitalItem {
  id: number = 0;
  name: string = '';
  address: string = '';
  phone: string = '';
  level: string = '';
  department: string = '';
  description: string = '';
}

interface RawHospitalItem {
  id?: number;
  name?: string;
  address?: string;
  phone?: string;
  level?: string;
  department?: string;
  description?: string;
}

@Entry
@Component
struct HospitalPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State hospitals: HospitalItem[] = [];
  @State filteredHospitals: HospitalItem[] = [];
  @State selectedLevel: string = '全部';
  @State isLoading: boolean = true;
  @State hasError: boolean = false;
  @State errorMessage: string = '';
  @State searchKeyword: string = '';

  private levels: string[] = ['全部', '三级甲等', '综合医院', '社区医院', '专科医院', '卫生院', '保健机构', '诊所'];
  private isRequesting: boolean = false;

  generateUniqueKey(item: HospitalItem, index: number): string {
    const id = item.id ?? 0;
    const name = item.name || 'unknown';
    return `${id}_${name}_${index}`;
  }

  validateHospitalItem(item: RawHospitalItem | null): HospitalItem | null {
    try {
      if (!item) {
        hilog.warn(0x0000, TAG, 'validateHospitalItem: item is null');
        return null;
      }

      const validated: HospitalItem = new HospitalItem();
      validated.id = (typeof item.id === 'number' && !isNaN(item.id)) ? item.id : 0;
      validated.name = (typeof item.name === 'string' && item.name.trim() !== '') ? item.name.trim() : '未知医院';
      validated.address = (typeof item.address === 'string') ? item.address : '';
      validated.phone = (typeof item.phone === 'string') ? item.phone : '';
      validated.level = (typeof item.level === 'string') ? item.level : '';
      validated.department = (typeof item.department === 'string') ? item.department : '';
      validated.description = (typeof item.description === 'string') ? item.description : '';

      return validated;
    } catch (error) {
      hilog.error(0x0000, TAG, 'validateHospitalItem exception: %{public}s', JSON.stringify(error));
      return null;
    }
  }

  // 将前端显示的筛选标签转换为数据库中实际存储的值
  private convertLevelToDbValue(level: string): string {
    return convertLevelToDbValue(level);
  }

  async loadHospitalList(filterLevel?: string): Promise<void> {
    hilog.info(0x0000, TAG, 'loadHospitalList 开始加载, filterLevel=%{public}s', filterLevel || '全部');

    if (this.isRequesting) {
      hilog.info(0x0000, TAG, '请求进行中，跳过重复请求');
      return;
    }

    this.isRequesting = true;
    this.isLoading = true;
    this.hasError = false;

    try {
      let cachedHospitals: HospitalCacheItem[] = [];
      let isCacheValid = false;

      try {
        cachedHospitals = await hospitalCacheManager.getHospitalsByLevel(filterLevel || '全部');
        isCacheValid = await hospitalCacheManager.isCacheValid();
        hilog.info(0x0000, TAG, '缓存查询完成, 数量=%{public}d, 有效=%{public}s', cachedHospitals.length, String(isCacheValid));
      } catch (cacheError) {
        hilog.error(0x0000, TAG, '缓存查询失败: %{public}s', JSON.stringify(cacheError));
        cachedHospitals = [];
        isCacheValid = false;
      }

      if (cachedHospitals.length > 0 && isCacheValid) {
        hilog.info(0x0000, TAG, '使用缓存数据，数量：', cachedHospitals.length);

        const validHospitals: HospitalItem[] = [];
        for (const item of cachedHospitals) {
          try {
            const hospital: HospitalItem = new HospitalItem();
            hospital.id = item.id;
            hospital.name = item.name || '未知医院';
            hospital.address = item.address || '';
            hospital.phone = item.phone || '';
            hospital.level = item.level || '';
            hospital.department = item.department || '';
            hospital.description = item.description || '';
            validHospitals.push(hospital);
          } catch (convertError) {
            hilog.warn(0x0000, TAG, '缓存数据转换失败: %{public}s', JSON.stringify(convertError));
          }
        }

        this.hospitals = validHospitals;
        this.filterHospitals();
        this.isLoading = false;
        this.isRequesting = false;
        hilog.info(0x0000, TAG, '缓存数据验证完成, 有效数量=%{public}d', validHospitals.length);
        return;
      }

      hilog.info(0x0000, TAG, '缓存无效，从服务器获取数据');

      let url: string = ApiConstants.HOSPITAL_LIST;
      let queryParams: Record<string, string> | undefined = undefined;

      if (filterLevel && filterLevel !== '全部') {
        url = ApiConstants.HOSPITAL_PAGE;
        queryParams = {
          'level': this.convertLevelToDbValue(filterLevel),
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

      hilog.info(0x0000, TAG, '服务器响应 success=%{public}s, data存在=%{public}s',
        String(response.success), String(response.data != null));

      if (response.success && response.data) {
        let rawHospitalList: RawHospitalItem[] = [];
        const data: Object = response.data;

        if (Array.isArray(data)) {
          rawHospitalList = data as RawHospitalItem[];
        } else if (data && typeof data === 'object') {
          try {
            const pageData = data as HospitalPageData;
            if (pageData.records && Array.isArray(pageData.records)) {
              rawHospitalList = pageData.records as RawHospitalItem[];
            }
          } catch (parseError) {
            hilog.error(0x0000, TAG, '解析分页数据失败: %{public}s', JSON.stringify(parseError));
          }
        }

        hilog.info(0x0000, TAG, '原始数据数量=%{public}d', rawHospitalList.length);

        const validHospitals: HospitalItem[] = [];
        for (const rawItem of rawHospitalList) {
          const validated = this.validateHospitalItem(rawItem);
          if (validated) {
            validHospitals.push(validated);
          }
        }

        hilog.info(0x0000, TAG, '数据验证完成, 有效=%{public}d, 过滤=%{public}d',
          validHospitals.length, rawHospitalList.length - validHospitals.length);

        if (validHospitals.length > 0) {
          this.hospitals = validHospitals;
          this.filterHospitals();

          try {
            const cacheItems: HospitalCacheItem[] = validHospitals.map((item: HospitalItem): HospitalCacheItem => ({
              id: item.id,
              name: item.name,
              address: item.address || '',
              phone: item.phone || '',
              level: item.level || '',
              department: item.department || '',
              description: item.description || '',
              longitude: 0,
              latitude: 0,
              cached_time: Date.now(),
              data_source: 'server'
            }));

            await hospitalCacheManager.saveHospitals(cacheItems);
            hilog.info(0x0000, TAG, '已保存到缓存，数量：%{public}d', cacheItems.length);
          } catch (saveError) {
            hilog.warn(0x0000, TAG, '保存缓存失败（不影响展示）: %{public}s', JSON.stringify(saveError));
          }
        } else {
          this.hospitals = [];
          this.filteredHospitals = [];
          this.errorMessage = filterLevel && filterLevel !== '全部'
            ? `暂无${filterLevel}医院`
            : '暂无医院数据';
          hilog.info(0x0000, TAG, '无有效数据, 提示: %{public}s', this.errorMessage);
        }
      } else {
        this.hasError = true;
        this.errorMessage = response.message || '加载医院列表失败';
        hilog.error(0x0000, TAG, '请求失败: %{public}s', this.errorMessage);
        ToastUtil.showError(this.errorMessage, 2000);
      }
    } catch (error) {
      this.hasError = true;
      const err = error as Error;
      this.errorMessage = err?.message || '网络错误，请检查网络连接';
      hilog.error(0x0000, TAG, 'loadHospitalList 异常: %{public}s', this.errorMessage);
      ToastUtil.showError(this.errorMessage, 2000);
    } finally {
      this.isLoading = false;
      this.isRequesting = false;
      hilog.info(0x0000, TAG, 'loadHospitalList 完成, hospitals数量=%{public}d', this.hospitals.length);
    }
  }

  onLevelSelect(level: string): void {
    hilog.info(0x0000, TAG, 'onLevelSelect 选择分类: %{public}s', level);

    if (this.selectedLevel === level) {
      hilog.info(0x0000, TAG, '重复选择相同分类，跳过');
      return;
    }

    this.selectedLevel = level;
    this.loadHospitalList(level);
  }

  onSearchInput(value: string): void {
    this.searchKeyword = value;
    this.filterHospitals();
  }

  filterHospitals(): void {
    if (!this.searchKeyword || this.searchKeyword.trim() === '') {
      this.filteredHospitals = this.hospitals;
      return;
    }

    const keyword = this.searchKeyword.trim().toLowerCase();
    const filtered: HospitalItem[] = [];

    for (let i = 0; i < this.hospitals.length; i++) {
      const item = this.hospitals[i];
      if (item.name.toLowerCase().includes(keyword) ||
        (item.address && item.address.toLowerCase().includes(keyword)) ||
        (item.level && item.level.toLowerCase().includes(keyword)) ||
        (item.department && item.department.toLowerCase().includes(keyword))) {
        filtered.push(item);
      }
    }

    this.filteredHospitals = filtered;
  }

  aboutToAppear(): void {
    hilog.info(0x0000, TAG, 'aboutToAppear 页面初始化开始');

    try {
      if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
        AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
      } else {
        this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') || false;
      }

      this.loadHospitalList();
      hilog.info(0x0000, TAG, 'aboutToAppear 初始化完成');
    } catch (initError) {
      hilog.error(0x0000, TAG, 'aboutToAppear 初始化异常: %{public}s', JSON.stringify(initError));
      this.hasError = true;
      this.errorMessage = '页面初始化失败';
    }
  }

  openARNavigation(): void {
    hilog.info(0x0000, TAG, 'openARNavigation 打开AR导航');

    try {
      router.pushUrl({ url: 'pages/DestinationSelectPage' }).catch((error: Error) => {
        hilog.error(0x0000, TAG, 'AR导航跳转失败: %{public}s', error.message);
      });
    } catch (navError) {
      hilog.error(0x0000, TAG, 'openARNavigation 异常: %{public}s', JSON.stringify(navError));
    }
  }

  navigateToDepartment(hospitalId: number, hospitalName: string): void {
    hilog.info(0x0000, TAG, 'navigateToDepartment 跳转科室选择页, id=%{public}d, name=%{public}s', hospitalId, hospitalName);

    try {
      router.pushUrl({
        url: 'pages/DepartmentListPage',
        params: {
          hospitalId: hospitalId,
          hospitalName: hospitalName
        }
      }).catch((err: Error) => {
        hilog.error(0x0000, TAG, '科室选择页面跳转失败: %{public}s', err.message);
      });
    } catch (navError) {
      hilog.error(0x0000, TAG, 'navigateToDepartment 异常: %{public}s', JSON.stringify(navError));
    }
  }

  build() {
    Column() {
      Header({ title: '医院列表', showBack: true });

      if (this.isLoading) {
        Loading({ text: '加载中...' })
      } else if (this.hasError) {
        Column() {
          EmptyState({
            title: '加载失败',
            description: this.errorMessage,
            buttonText: '重新加载',
            showButton: true
          })
        }
        .width('100%')
        .layoutWeight(1)
        .onClick(() => this.loadHospitalList(this.selectedLevel !== '全部' ? this.selectedLevel : undefined))
      } else {
        Scroll() {
          Column({ space: GlobalTheme.getSpacingLG(this.isElderMode) }) {
            Text('医院列表')
              .fontSize(GlobalTheme.getFontSizeTitle(this.isElderMode))
              .fontWeight('bold')
              .fontColor(GlobalTheme.THEME_COLOR)
              .margin({ top: GlobalTheme.getSpacingLG(this.isElderMode), bottom: GlobalTheme.getSpacingMD(this.isElderMode) });

            Row() {
              TextInput({ placeholder: '搜索医院名称、地址、等级...', text: this.searchKeyword })
                .fontSize(this.isElderMode ? 17 : 14)
                .height(this.isElderMode ? 44 : 36)
                .backgroundColor('#FFFFFF')
                .borderRadius(20)
                .padding({ left: 16, right: 16 })
                .layoutWeight(1)
                .onChange((value: string) => {
                  this.onSearchInput(value);
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
                    this.filterHospitals();
                  })
              }
            }
            .width('100%')

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
              }, (level: string, index: number) => `level_${index}_${level}`)
            }
            .width('100%')

            if (this.searchKeyword.trim().length > 0) {
              Text(`搜索结果: ${this.filteredHospitals.length}家 (共${this.hospitals.length}家)`)
                .fontSize(12)
                .fontColor('#999')
                .margin({ top: 4 })
            } else {
              Text(`当前显示: ${this.selectedLevel} (${this.hospitals.length}家)`)
                .fontSize(12)
                .fontColor('#999')
                .margin({ top: 4 })
            }

            if (this.filteredHospitals.length === 0) {
              EmptyState({
                icon: '🏥',
                title: '暂无数据',
                description: this.searchKeyword.trim().length > 0
                  ? `未找到与"${this.searchKeyword}"相关的医院`
                  : this.selectedLevel === '全部' ? '暂无医院数据' : `暂无${this.selectedLevel}医院`
              })
                .width('100%')
                .height(200)
            } else {
              List({ space: 10 }) {
                ForEach(this.filteredHospitals, (item: HospitalItem, index: number) => {
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
                      this.navigateToDepartment(item.id, item.name);
                    })
                  }
                }, (item: HospitalItem, index: number) => this.generateUniqueKey(item, index))
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