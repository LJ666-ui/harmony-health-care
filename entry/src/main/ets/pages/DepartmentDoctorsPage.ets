import { router } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Header } from '../components/Header';
import { Loading } from '../components/Loading';
import { EmptyState } from '../components/EmptyState';
import { HttpUtil, BaseResponse, HttpMethod } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import { ToastUtil } from '../common/utils/ToastUtil';
import { DoctorInfo, DoctorInfoHelper } from '../models/DoctorModel';
import { GlobalTheme } from '../global';

const TAG = 'DepartmentDoctorsPage';

@Entry
@Component
struct DepartmentDoctorsPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State hospitalId: number = 0;
  @State hospitalName: string = '';
  @State departmentId: number = 0;
  @State departmentName: string = '';
  @State departmentLocation: string = '';
  @State departmentIntro: string = '';
  @State doctors: DoctorInfo[] = [];
  @State filteredDoctors: DoctorInfo[] = [];
  @State searchKeyword: string = '';
  @State isLoading: boolean = true;
  @State hasError: boolean = false;
  @State errorMessage: string = '';

  private scroller: Scroller = new Scroller();

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') || false;
    }

    try {
      const params = router.getParams() as Record<string, Object> | undefined;
      if (params) {
        if (params['hospitalId'] !== undefined) {
          this.hospitalId = typeof params['hospitalId'] === 'number' ? params['hospitalId'] : Number(params['hospitalId']);
        }
        if (params['hospitalName'] !== undefined && params['hospitalName'] !== '') {
          this.hospitalName = String(params['hospitalName']);
        }
        if (params['departmentId'] !== undefined) {
          this.departmentId = typeof params['departmentId'] === 'number' ? params['departmentId'] : Number(params['departmentId']);
        }
        if (params['departmentName'] !== undefined && params['departmentName'] !== '') {
          this.departmentName = String(params['departmentName']);
        }
        if (params['departmentLocation'] !== undefined && params['departmentLocation'] !== '') {
          this.departmentLocation = String(params['departmentLocation']);
        }
        if (params['departmentIntro'] !== undefined && params['departmentIntro'] !== '') {
          this.departmentIntro = String(params['departmentIntro']);
        }
      }
    } catch (error) {
      console.error('获取路由参数失败:', error);
    }

    hilog.info(0x0000, TAG, '科室参数: hospitalId=%{public}d, deptName=%{public}s', this.hospitalId, this.departmentName);
    this.loadDoctors();
  }

  async loadDoctors(): Promise<void> {
    hilog.info(0x0000, TAG, '开始加载科室医生列表');
    
    this.isLoading = true;
    this.hasError = false;

    try {
      const queryParams: Record<string, string> = {
        'department': this.departmentName
      };

      const response: BaseResponse<Object[]> = await HttpUtil.request<Object[]>(
        HttpMethod.GET,
        ApiConstants.DOCTOR_LIST,
        undefined,
        queryParams as Object,
        { showLoading: true, loadingText: '加载医生信息...' }
      );

      hilog.info(0x0000, TAG, '医生列表响应: success=%{public}s', response.success ? 'true' : 'false');

      if (response.success && response.data) {
        const rawData: Object[] = response.data;
        const list: DoctorInfo[] = [];
        
        for (let i = 0; i < rawData.length; i++) {
          const raw = rawData[i] as Record<string, Object>;
          const doctor: DoctorInfo = DoctorInfoHelper.fromJson(raw);
          
          if (doctor.status === 1) {
            list.push(doctor);
          }
        }

        this.doctors = list;
        this.filteredDoctors = list;
        hilog.info(0x0000, TAG, '医生列表加载成功, 数量=%{public}d', this.doctors.length);

        if (this.doctors.length === 0) {
          this.errorMessage = `该科室暂无医生`;
          hilog.warn(0x0000, TAG, '该科室暂无医生');
        }
      } else {
        this.hasError = true;
        this.errorMessage = response.message || '加载医生列表失败';
        hilog.error(0x0000, TAG, '医生列表加载失败: %{public}s', this.errorMessage);
        ToastUtil.showError(this.errorMessage, 2000);
      }
    } catch (error) {
      this.hasError = true;
      this.errorMessage = '网络错误，请检查网络连接';
      hilog.error(0x0000, TAG, '加载医生列表异常: %{public}s', JSON.stringify(error));
      ToastUtil.showError(this.errorMessage, 2000);
    } finally {
      this.isLoading = false;
    }
  }

  onSearchInput(value: string): void {
    this.searchKeyword = value;
    this.filterDoctors();
  }

  filterDoctors(): void {
    if (!this.searchKeyword || this.searchKeyword.trim() === '') {
      this.filteredDoctors = this.doctors;
      return;
    }

    const keyword = this.searchKeyword.trim().toLowerCase();
    const filtered: DoctorInfo[] = [];

    for (let i = 0; i < this.doctors.length; i++) {
      const doctor = this.doctors[i];
      const name = DoctorInfoHelper.getDisplayName(doctor).toLowerCase();
      const title = (doctor.title || '').toLowerCase();
      const specialty = (doctor.specialty || '').toLowerCase();

      if (name.includes(keyword) || title.includes(keyword) || specialty.includes(keyword)) {
        filtered.push(doctor);
      }
    }

    this.filteredDoctors = filtered;
  }

  onDoctorClick(doctor: DoctorInfo): void {
    hilog.info(0x0000, TAG, '点击医生: id=%{public}d, name=%{public}s', doctor.id, DoctorInfoHelper.getDisplayName(doctor));

    try {
      router.pushUrl({
        url: 'pages/DoctorDetailPage',
        params: {
          doctorId: doctor.id,
          hospitalId: this.hospitalId,
          hospitalName: this.hospitalName,
          departmentId: this.departmentId,
          departmentName: this.departmentName,
          departmentLocation: this.departmentLocation,
          departmentIntro: this.departmentIntro
        }
      }).then(() => {
        hilog.info(0x0000, TAG, '成功跳转到医生详情页');
      }).catch((error: Error) => {
        hilog.error(0x0000, TAG, '跳转失败: %{public}s', error.message);
        ToastUtil.showError('页面跳转失败，请重试', 2000);
      });
    } catch (error) {
      hilog.error(0x0000, TAG, '路由异常: %{public}s', JSON.stringify(error));
      ToastUtil.showError('系统错误，请稍后重试', 2000);
    }
  }

  build() {
    Column() {
      Header({ title: this.departmentName || '科室医生' })

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
          this.loadDoctors();
        })
      } else {
        Column() {
          this.DepartmentInfoCard()

          Row() {
            TextInput({ placeholder: '搜索医生姓名、职称...', text: this.searchKeyword })
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
                  this.filterDoctors();
                })
            }
          }
          .width('100%')
          .padding({ left: 16, right: 16, bottom: 12 })

          if (this.doctors.length === 0) {
            EmptyState({
              icon: '👨‍⚕️',
              title: '暂无医生',
              description: this.errorMessage || '该科室暂无可用医生'
            })
          } else {
            List({ space: 10, initialIndex: 0 }) {
              ForEach(this.filteredDoctors, (doctor: DoctorInfo, index: number) => {
                ListItem() {
                  this.DoctorCard(doctor, index)
                }
              }, (doctor: DoctorInfo, index: number) => `${doctor.id}_${index}`)
            }
            .width('100%')
            .height('100%')
            .padding({ left: 16, right: 16, bottom: 20 })
            .layoutWeight(1)
            .divider({ strokeWidth: 0.5, color: '#F0F0F0', startMargin: 16, endMargin: 16 })
          }
        }
        .layoutWeight(1)
      }
    }
    .height('100%')
    .backgroundColor(GlobalTheme.BG_COLOR)
  }

  @Builder
  DepartmentInfoCard() {
    Column() {
      Row() {
        Column({ space: 4 }) {
          Text(this.departmentName)
            .fontSize(this.isElderMode ? 20 : 17)
            .fontWeight(FontWeight.Bold)
            .fontColor(GlobalTheme.TEXT_PRIMARY)

          Text(this.hospitalName)
            .fontSize(this.isElderMode ? 15 : 13)
            .fontColor(GlobalTheme.THEME_COLOR)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Text(`${this.doctors.length}位医生`)
          .fontSize(this.isElderMode ? 15 : 12)
          .fontColor('#666666')
          .backgroundColor('#F5F5F5')
          .padding({ left: 12, right: 12, top: 4, bottom: 4 })
          .borderRadius(12)
      }
      .width('100%')

      if (this.departmentLocation) {
        Row({ space: 6 }) {
          Text('📍')
            .fontSize(14)
          Text(`位置：${this.departmentLocation}`)
            .fontSize(this.isElderMode ? 15 : 13)
            .fontColor(GlobalTheme.TEXT_SECONDARY)
        }
        .width('100%')
        .margin({ top: 8 })
      }

      if (this.departmentIntro) {
        Text(this.departmentIntro)
          .fontSize(this.isElderMode ? 15 : 13)
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
    .backgroundColor(GlobalTheme.CARD_BG)
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
    .margin({ left: 16, right: 16, top: 12 })
  }

  @Builder
  DoctorCard(doctor: DoctorInfo, index: number) {
    Row({ space: 14 }) {
      Stack({ alignContent: Alignment.Center }) {
        Circle()
          .width(52)
          .height(52)
          .fill(GlobalTheme.THEME_COLOR);

        Text(DoctorInfoHelper.getDisplayName(doctor).charAt(0))
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF');
      }
      .margin({ right: 2 });

      Column({ space: 6 }) {
        Row({ space: 10 }) {
          Text(DoctorInfoHelper.getDisplayName(doctor))
            .fontSize(this.isElderMode ? 18 : 16)
            .fontWeight(FontWeight.Bold)
            .fontColor(GlobalTheme.TEXT_PRIMARY);

          if (doctor.title && doctor.title.trim() !== '') {
            Text(doctor.title)
              .fontSize(this.isElderMode ? 14 : 12)
              .fontColor('#FFFFFF')
              .backgroundColor('#52C41A')
              .padding({ left: 8, right: 8, top: 2, bottom: 2 })
              .borderRadius(4);
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)

        if (doctor.specialty && doctor.specialty.trim() !== '') {
          Text(doctor.specialty)
            .fontSize(this.isElderMode ? 15 : 13)
            .fontColor(GlobalTheme.TEXT_SECONDARY)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis });
        }

        Row({ space: 16 }) {
          if (doctor.rating && doctor.rating > 0) {
            Row({ space: 4 }) {
              Text('⭐')
                .fontSize(13);
              Text(`${doctor.rating.toFixed(1)}分`)
                .fontSize(this.isElderMode ? 14 : 12)
                .fontColor('#F39C12');
            }
          }

          Text('查看详情')
            .fontSize(this.isElderMode ? 14 : 12)
            .fontColor(GlobalTheme.THEME_COLOR)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Text('>')
        .fontSize(18)
        .fontColor('#CCCCCC')
        .margin({ left: 4 })
    }
    .width('100%')
    .padding(14)
    .backgroundColor(GlobalTheme.CARD_BG)
    .borderRadius(10)
    .onClick(() => {
      this.onDoctorClick(doctor);
    })
  }
}
