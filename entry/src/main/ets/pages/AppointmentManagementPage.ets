import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Loading } from '../components/Loading';
import { EmptyState } from '../components/EmptyState';
import { HttpUtil, BaseResponse, HttpMethod } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import { ToastUtil } from '../common/utils/ToastUtil';
import { GlobalTheme } from '../global';

interface HospitalInfo {
  id: number;
  name: string;
  address?: string;
  phone?: string;
  level?: string;
  department?: string;
  description?: string;
}

@Entry
@Component
struct AppointmentManagementPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State hospitals: HospitalInfo[] = [];
  @State filteredHospitals: HospitalInfo[] = [];
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
    this.loadHospitalList();
  }

  async loadHospitalList(): Promise<void> {
    this.isLoading = true;
    this.hasError = false;

    try {
      const response: BaseResponse<HospitalInfo[]> = await HttpUtil.request<HospitalInfo[]>(
        HttpMethod.GET,
        ApiConstants.HOSPITAL_LIST,
        undefined,
        undefined,
        { showLoading: true, loadingText: '加载医院列表...' }
      );

      if (response.success && response.data) {
        this.hospitals = response.data;
        this.filteredHospitals = response.data;
        if (this.hospitals.length === 0) {
          this.errorMessage = '暂无医院数据';
        }
      } else {
        this.hasError = true;
        this.errorMessage = response.message || '加载医院列表失败';
        ToastUtil.showError(this.errorMessage, 2000);
      }
    } catch (error) {
      this.hasError = true;
      this.errorMessage = '网络错误，请检查网络连接';
      ToastUtil.showError(this.errorMessage, 2000);
      console.error('加载医院列表失败:', error);
    } finally {
      this.isLoading = false;
    }
  }

  onHospitalClick(hospital: HospitalInfo): void {
    console.log('点击医院:', hospital.name, 'ID:', hospital.id);

    if (!hospital.id || hospital.id <= 0) {
      console.error('医院ID无效');
      ToastUtil.showError('医院信息不完整', 1500);
      return;
    }

    try {
      router.pushUrl({
        url: 'pages/DepartmentListPage',
        params: {
          hospitalId: hospital.id,
          hospitalName: hospital.name || '未知医院'
        }
      }).then(() => {
        console.log('跳转到科室列表成功');
      }).catch((err: Error) => {
        console.error('跳转科室列表失败:', err.message);
        ToastUtil.showError('页面跳转失败', 1500);
      });
    } catch (error) {
      console.error('跳转异常:', error);
      ToastUtil.showError('页面跳转异常', 1500);
    }
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
    const filtered: HospitalInfo[] = [];
    for (let i = 0; i < this.hospitals.length; i++) {
      const hospital = this.hospitals[i];
      if (hospital.name.toLowerCase().includes(keyword) ||
          (hospital.address && hospital.address.toLowerCase().includes(keyword)) ||
          (hospital.level && hospital.level.toLowerCase().includes(keyword))) {
        filtered.push(hospital);
      }
    }
    this.filteredHospitals = filtered;
  }

  @Builder
  HospitalCard(hospital: HospitalInfo) {
    Row() {
      Column() {
        Text(hospital.name)
          .fontSize(this.isElderMode ? 20 : 16)
          .fontWeight(FontWeight.Medium)
          .fontColor(GlobalTheme.TEXT_PRIMARY)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        if (hospital.level) {
          Text(hospital.level)
            .fontSize(this.isElderMode ? 16 : 13)
            .fontColor(GlobalTheme.THEME_COLOR)
            .margin({ top: 4 })
        }

        if (hospital.address) {
          Text(hospital.address)
            .fontSize(this.isElderMode ? 15 : 12)
            .fontColor(GlobalTheme.TEXT_HINT)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ top: 2 })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ right: 12 })

      Text('>')
        .fontSize(18)
        .fontColor(GlobalTheme.TEXT_LIGHT)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(GlobalTheme.CARD_BG)
    .borderRadius(8)
    .onClick(() => {
      this.onHospitalClick(hospital);
    })
  }

  build() {
    Column() {
      Header({ title: '预约管理' })

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
        .onClick(() => {
          this.loadHospitalList();
        })
      } else if (this.hospitals.length === 0) {
        EmptyState({
          icon: '🏥',
          title: '暂无医院数据',
          description: this.errorMessage || '暂无可用医院信息'
        })
      } else {
        Column() {
          Row() {
            Text('选择医院')
              .fontSize(this.isElderMode ? 22 : 18)
              .fontWeight(FontWeight.Bold)
              .layoutWeight(1)

            Button('我的预约')
              .fontSize(this.isElderMode ? 16 : 13)
              .backgroundColor(GlobalTheme.THEME_COLOR)
              .fontColor(GlobalTheme.BUTTON_TEXT_COLOR)
              .height(this.isElderMode ? 40 : 32)
              .padding({ left: 16, right: 16 })
              .borderRadius(6)
              .onClick(() => {
                router.pushUrl({
                  url: 'pages/Appointments'
                }).catch((err: Error) => {
                  console.error('跳转我的预约失败:', err.message);
                  ToastUtil.showError('页面跳转失败', 1500);
                });
              })
          }
          .width('100%')
          .padding({ left: 16, top: 16, right: 16, bottom: 12 })
          .justifyContent(FlexAlign.SpaceBetween)

          Row() {
            TextInput({ placeholder: '搜索医院名称、地址...', text: this.searchKeyword })
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
          .padding({ left: 16, right: 16, bottom: 12 })

          Scroll() {
            List({ space: 12 }) {
              ForEach(this.filteredHospitals, (hospital: HospitalInfo) => {
                ListItem() {
                  this.HospitalCard(hospital)
                }
              })
            }
            .width('100%')
            .padding({ left: 16, right: 16, bottom: 20 })
          }
          .scrollBar(BarState.Off)
          .layoutWeight(1)
        }
        .layoutWeight(1)
      }
    }
    .height('100%')
    .backgroundColor(GlobalTheme.BG_COLOR)
  }
}
