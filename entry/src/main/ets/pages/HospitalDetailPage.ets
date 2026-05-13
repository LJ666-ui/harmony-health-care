import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { Loading } from '../components/Loading';
import { EmptyState } from '../components/EmptyState';
import { HttpUtil, BaseResponse, HttpMethod } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import { ToastUtil } from '../common/utils/ToastUtil';
import { Appointment } from '../models/HealthData';
import { GlobalTheme } from '../global';

interface HospitalDetail {
  id: number;
  name: string;
  address?: string;
  phone?: string;
  level?: string;
  department?: string;
  description?: string;
  departments?: DepartmentInfo[];
}

interface DepartmentInfo {
  id: number;
  hospitalId: number;
  deptName: string;
  deptIntro?: string;
  location?: string;
}

interface DepartmentQueryParams {
  hospitalId: number;
}

@Entry
@Component
struct HospitalDetailPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State hospitalId: number = 0;
  @State hospitalName: string = '';
  @State hospitalDetail: HospitalDetail | null = null;
  @State departments: DepartmentInfo[] = [];
  @State filteredDepartments: DepartmentInfo[] = [];
  @State searchKeyword: string = '';
  @State isLoading: boolean = true;
  @State hasError: boolean = false;
  @State errorMessage: string = '';
  @State selectedDepartment: DepartmentInfo | null = null;
  @State showAppointmentDialog: boolean = false;
  @State showCancelDialog: boolean = false;
  @State appointments: Appointment[] = [];
  @State selectedDate: string = '';
  @State selectedTime: string = '';

  private dates: string[] = [];
  private times: string[] = ['08:00', '08:30', '09:00', '09:30', '10:00', '10:30',
    '14:00', '14:30', '15:00', '15:30', '16:00', '16:30'];

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
          this.hospitalName = String(name);
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

    this.initDates();
    this.loadAppointments();
    this.loadHospitalDetail();
    this.loadDepartments();
  }

  initDates(): void {
    const today = new Date();
    for (let i = 0; i < 7; i++) {
      const date = new Date(today);
      date.setDate(today.getDate() + i);
      const year = date.getFullYear();
      const month = String(date.getMonth() + 1).padStart(2, '0');
      const day = String(date.getDate()).padStart(2, '0');
      this.dates.push(`${year}-${month}-${day}`);
    }
    if (this.dates.length > 0) {
      this.selectedDate = this.dates[0];
    }
    this.selectedTime = this.times[0];
  }

  async loadHospitalDetail(): Promise<void> {
    console.log('开始加载医院详情, hospitalId:', this.hospitalId);
    
    if (!this.hospitalId || this.hospitalId === 0) {
      console.warn('hospitalId 无效，跳过加载医院详情');
      return;
    }

    try {
      const url = `${ApiConstants.HOSPITAL_DETAIL}${this.hospitalId}`;
      console.log('请求URL:', url);
      
      const response: BaseResponse<HospitalDetail> = await HttpUtil.request<HospitalDetail>(
        HttpMethod.GET,
        url,
        undefined,
        undefined,
        { showLoading: false }
      );

      console.log('医院详情响应:', JSON.stringify(response));

      if (response.success && response.data) {
        this.hospitalDetail = response.data;
        console.log('医院详情加载成功');
      } else {
        console.warn('医院详情返回数据为空或失败');
      }
    } catch (error) {
      console.error('加载医院详情失败:', error);
    }
  }

  async loadDepartments(): Promise<void> {
    console.log('开始加载科室列表, hospitalId:', this.hospitalId);
    
    this.isLoading = true;
    this.hasError = false;

    if (!this.hospitalId || this.hospitalId === 0) {
      console.warn('hospitalId 无效，无法加载科室列表');
      this.hasError = true;
      this.errorMessage = '无效的医院ID';
      this.isLoading = false;
      return;
    }

    try {
      const queryParams: DepartmentQueryParams = { hospitalId: this.hospitalId };
      console.log('科室查询参数:', JSON.stringify(queryParams));
      
      const response: BaseResponse<DepartmentInfo[]> = await HttpUtil.request<DepartmentInfo[]>(
        HttpMethod.GET,
        ApiConstants.HOSPITAL_DEPARTMENT_LIST,
        undefined,
        queryParams as Object,
        { showLoading: true, loadingText: '加载科室信息...' }
      );

      console.log('科室列表响应:', JSON.stringify(response));

      if (response.success && response.data) {
        this.departments = response.data;
        this.filteredDepartments = response.data;
        console.log('科室列表加载成功, 数量:', this.departments.length);
        
        if (this.departments.length === 0) {
          this.errorMessage = '该医院暂无科室信息';
          console.warn('该医院暂无科室信息');
        }
      } else {
        this.hasError = true;
        this.errorMessage = response.message || '加载科室列表失败';
        console.error('科室列表加载失败:', this.errorMessage);
        ToastUtil.showError(this.errorMessage, 2000);
      }
    } catch (error) {
      this.hasError = true;
      this.errorMessage = '网络错误，请检查网络连接';
      console.error('加载科室列表异常:', error);
      ToastUtil.showError(this.errorMessage, 2000);
    } finally {
      this.isLoading = false;
      console.log('科室列表加载完成, isLoading:', this.isLoading);
    }
  }

  loadAppointments(): void {
    const storedAppointments = AppStorage.get<Appointment[]>('appointments');
    if (storedAppointments) {
      this.appointments = storedAppointments;
    } else {
      this.appointments = [];
    }
  }

  saveAppointments(): void {
    AppStorage.setOrCreate<Appointment[]>('appointments', this.appointments);
  }

  onDepartmentClick(department: DepartmentInfo): void {
    console.log('开始跳转到科室医生列表页面');
    console.log('医院ID:', this.hospitalId);
    console.log('医院名称:', this.hospitalName);
    console.log('科室名称:', department.deptName);
    console.log('科室位置:', department.location);

    try {
      router.pushUrl({
        url: 'pages/DepartmentDoctorsPage',
        params: {
          hospitalId: this.hospitalId,
          hospitalName: this.hospitalName,
          departmentId: department.id,
          departmentName: department.deptName,
          departmentLocation: department.location || `${department.deptName}诊室`,
          departmentIntro: department.deptIntro || ''
        }
      }).then(() => {
        console.log('成功跳转到科室医生列表页面');
      }).catch((error: Error) => {
        console.error('跳转失败:', error.message);
        ToastUtil.showError('页面跳转失败，请重试', 2000);
      });
    } catch (error) {
      console.error('路由异常:', error);
      ToastUtil.showError('系统错误，请稍后重试', 2000);
    }
  }

  onBookAppointment(): void {
    if (!this.selectedDepartment) {
      ToastUtil.showError('请选择科室', 1500);
      return;
    }

    if (!this.selectedDate || !this.selectedTime) {
      ToastUtil.showError('请选择预约时间', 1500);
      return;
    }

    const newAppointment: Appointment = {
      id: Date.now().toString(),
      doctor: '待分配',
      specialty: this.selectedDepartment.deptName,
      hospital: this.hospitalName,
      date: this.selectedDate,
      time: this.selectedTime,
      status: 'pending',
      location: this.selectedDepartment.location || `${this.selectedDepartment.deptName}诊室`,
      notes: '',
      avatarColor: '#1677FF',
      createdAt: Date.now(),
      updatedAt: Date.now()
    };

    this.appointments.push(newAppointment);
    this.saveAppointments();

    this.showAppointmentDialog = false;
    ToastUtil.showSuccess('预约成功！', 2000);
  }

  onCancelAppointment(): void {
    if (!this.selectedDepartment) return;

    const index = this.appointments.findIndex(apt =>
      apt.hospital === this.hospitalName &&
      apt.specialty === this.selectedDepartment!.deptName &&
      (apt.status === 'pending' || apt.status === 'confirmed')
    );

    if (index !== -1) {
      this.appointments[index].status = 'cancelled';
      this.saveAppointments();
      this.showCancelDialog = false;
      ToastUtil.showSuccess('已取消预约', 2000);
    } else {
      this.showCancelDialog = false;
      ToastUtil.showError('未找到可取消的预约', 1500);
    }
  }

  hasActiveAppointment(deptName: string): boolean {
    return this.appointments.some(apt =>
      apt.hospital === this.hospitalName &&
      apt.specialty === deptName &&
      (apt.status === 'pending' || apt.status === 'confirmed')
    );
  }

  onSearchInput(value: string): void {
    this.searchKeyword = value;
    this.filterDepartments();
  }

  filterDepartments(): void {
    if (!this.searchKeyword || this.searchKeyword.trim() === '') {
      this.filteredDepartments = this.departments;
      return;
    }

    const keyword = this.searchKeyword.trim().toLowerCase();
    const filtered: DepartmentInfo[] = [];
    for (let i = 0; i < this.departments.length; i++) {
      const department = this.departments[i];
      if (department.deptName.toLowerCase().includes(keyword) ||
          (department.location && department.location.toLowerCase().includes(keyword)) ||
          (department.deptIntro && department.deptIntro.toLowerCase().includes(keyword))) {
        filtered.push(department);
      }
    }
    this.filteredDepartments = filtered;
  }

  openARNavigation(): void {
    console.log('打开院内AR导航, 医院:', this.hospitalName);

    try {
      router.pushUrl({ url: 'pages/DestinationSelectPage' }).catch((error: Error) => {
        console.error('AR导航跳转失败:', error.message);
      });
    } catch (navError) {
      console.error('openARNavigation 异常:', navError);
    }
  }

  build() {
    Column() {
      Header({ title: this.hospitalName || '医院详情' })

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
          this.loadHospitalDetail();
          this.loadDepartments();
        })
      } else {
        Scroll() {
          Column() {
            if (this.hospitalDetail) {
              this.HospitalInfoCard()
            }

            Text('科室列表')
              .fontSize(this.isElderMode ? 22 : 18)
              .fontWeight(FontWeight.Bold)
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
                    this.filterDepartments();
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
            } else {
              List({ space: 12 }) {
                ForEach(this.filteredDepartments, (department: DepartmentInfo) => {
                  ListItem() {
                    this.DepartmentCard(department)
                  }
                })
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

      if (this.showAppointmentDialog) {
        this.AppointmentDialog()
      }

      if (this.showCancelDialog && this.selectedDepartment) {
        this.CancelConfirmDialog()
      }
    }
    .height('100%')
    .backgroundColor(GlobalTheme.BG_COLOR)
  }

  @Builder
  HospitalInfoCard() {
    Column() {
      Row() {
        Text('🏥')
          .fontSize(32)

        Column() {
          Text(this.hospitalDetail!.name)
            .fontSize(this.isElderMode ? 20 : 17)
            .fontWeight(FontWeight.Bold)
            .fontColor(GlobalTheme.TEXT_PRIMARY)

          if (this.hospitalDetail!.level) {
            Text(this.hospitalDetail!.level)
              .fontSize(this.isElderMode ? 16 : 13)
              .fontColor(GlobalTheme.THEME_COLOR)
              .margin({ top: 4 })
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        .margin({ left: 12 })
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)

      if (this.hospitalDetail!.address) {
        Row() {
          Text('📍')
            .fontSize(16)
          Text(this.hospitalDetail!.address)
            .fontSize(this.isElderMode ? 16 : 13)
            .fontColor(GlobalTheme.TEXT_SECONDARY)
            .margin({ left: 8 })
        }
        .width('100%')
        .margin({ top: 12 })
        .alignItems(VerticalAlign.Center)
      }

      if (this.hospitalDetail!.phone) {
        Row() {
          Text('📞')
            .fontSize(16)
          Text(this.hospitalDetail!.phone)
            .fontSize(this.isElderMode ? 16 : 13)
            .fontColor(GlobalTheme.TEXT_SECONDARY)
            .margin({ left: 8 })
        }
        .width('100%')
        .margin({ top: 8 })
        .alignItems(VerticalAlign.Center)
      }

      if (this.hospitalDetail!.description) {
        Text(this.hospitalDetail!.description)
          .fontSize(this.isElderMode ? 16 : 13)
          .fontColor(GlobalTheme.TEXT_SECONDARY)
          .width('100%')
          .margin({ top: 12 })
          .lineHeight(20)
      }

      Button('🧭 院内AR导航')
        .width('100%')
        .height(GlobalTheme.getButtonHeight(this.isElderMode))
        .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
        .fontWeight('bold')
        .fontColor('#FFFFFF')
        .backgroundColor(GlobalTheme.THEME_COLOR)
        .borderRadius(GlobalTheme.RADIUS_LG)
        .margin({ top: 12 })
        .onClick(() => {
          this.openARNavigation();
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(GlobalTheme.CARD_BG)
    .borderRadius(12)
    .margin({ left: 16, right: 16, top: 16 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  DepartmentCard(department: DepartmentInfo) {
    Column() {
      Row() {
        Column() {
          Text(department.deptName)
            .fontSize(this.isElderMode ? 19 : 16)
            .fontWeight(FontWeight.Medium)
            .fontColor(GlobalTheme.TEXT_PRIMARY)

          if (department.location) {
            Text(`位置：${department.location}`)
              .fontSize(this.isElderMode ? 15 : 12)
              .fontColor(GlobalTheme.TEXT_HINT)
              .margin({ top: 4 })
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Column({ space: 8 }) {
          Button('预约')
            .fontSize(this.isElderMode ? 15 : 12)
            .backgroundColor(GlobalTheme.THEME_COLOR)
            .fontColor(GlobalTheme.BUTTON_TEXT_COLOR)
            .height(this.isElderMode ? 40 : 32)
            .padding({ left: 16, right: 16 })
            .borderRadius(6)
            .onClick(() => {
              this.onDepartmentClick(department);
            })

          if (this.hasActiveAppointment(department.deptName)) {
            Button('取消预约')
              .fontSize(this.isElderMode ? 15 : 12)
              .backgroundColor(GlobalTheme.CARD_BG)
              .fontColor(GlobalTheme.ERROR_COLOR)
              .height(this.isElderMode ? 40 : 32)
              .padding({ left: 12, right: 12 })
              .borderRadius(6)
              .border({ width: 1, color: GlobalTheme.ERROR_COLOR })
              .onClick(() => {
                this.selectedDepartment = department;
                this.showCancelDialog = true;
              })
          }
        }
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      if (department.deptIntro) {
        Text(department.deptIntro)
          .fontSize(this.isElderMode ? 15 : 12)
          .fontColor(GlobalTheme.TEXT_SECONDARY)
          .width('100%')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 8 })
          .lineHeight(18)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(GlobalTheme.CARD_BG)
    .borderRadius(8)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  AppointmentDialog() {
    Column() {
      Text('预约挂号')
        .fontSize(this.isElderMode ? 22 : 19)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 20 })

      Text(`科室：${this.selectedDepartment?.deptName || ''}`)
        .fontSize(this.isElderMode ? 18 : 15)
        .fontColor(GlobalTheme.TEXT_PRIMARY)
        .width('100%')
        .margin({ bottom: 16 })

      Text('选择日期')
        .fontSize(this.isElderMode ? 17 : 14)
        .fontColor(GlobalTheme.TEXT_SECONDARY)
        .width('100%')
        .margin({ bottom: 8 })

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.dates, (date: string) => {
          Text(date.slice(5))
            .fontSize(this.isElderMode ? 16 : 13)
            .fontColor(this.selectedDate === date ? GlobalTheme.BUTTON_TEXT_COLOR : GlobalTheme.TEXT_PRIMARY)
            .backgroundColor(this.selectedDate === date ? GlobalTheme.THEME_COLOR : GlobalTheme.BG_COLOR)
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .borderRadius(6)
            .margin({ right: 8, bottom: 8 })
            .onClick(() => {
              this.selectedDate = date;
            })
        })
      }
      .width('100%')
      .margin({ bottom: 16 })

      Text('选择时间')
        .fontSize(this.isElderMode ? 17 : 14)
        .fontColor(GlobalTheme.TEXT_SECONDARY)
        .width('100%')
        .margin({ bottom: 8 })

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.times, (time: string) => {
          Text(time)
            .fontSize(this.isElderMode ? 16 : 13)
            .fontColor(this.selectedTime === time ? GlobalTheme.BUTTON_TEXT_COLOR : GlobalTheme.TEXT_PRIMARY)
            .backgroundColor(this.selectedTime === time ? GlobalTheme.THEME_COLOR : GlobalTheme.BG_COLOR)
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .borderRadius(6)
            .margin({ right: 8, bottom: 8 })
            .onClick(() => {
              this.selectedTime = time;
            })
        })
      }
      .width('100%')
      .margin({ bottom: 24 })

      Row() {
        Button('取消')
          .fontSize(this.isElderMode ? 17 : 14)
          .backgroundColor(GlobalTheme.BG_COLOR)
          .fontColor(GlobalTheme.TEXT_SECONDARY)
          .flexGrow(1)
          .height(this.isElderMode ? 48 : 40)
          .borderRadius(8)
          .onClick(() => {
            this.showAppointmentDialog = false;
          })

        Button('确认预约')
          .fontSize(this.isElderMode ? 17 : 14)
          .backgroundColor(GlobalTheme.THEME_COLOR)
          .fontColor(GlobalTheme.BUTTON_TEXT_COLOR)
          .flexGrow(1)
          .height(this.isElderMode ? 48 : 40)
          .borderRadius(8)
          .margin({ left: 12 })
          .onClick(() => {
            this.onBookAppointment();
          })
      }
      .width('100%')
    }
    .width('85%')
    .padding(24)
    .backgroundColor(GlobalTheme.CARD_BG)
    .borderRadius(16)
    .shadow({
      radius: 20,
      color: 'rgba(0,0,0,0.1)',
      offsetX: 0,
      offsetY: 4
    })
  }

  @Builder
  CancelConfirmDialog() {
    Column() {
      Text('确认取消')
        .fontSize(this.isElderMode ? 22 : 19)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 16 })

      Text(`确定要取消 ${this.selectedDepartment?.deptName} 的预约吗？`)
        .fontSize(this.isElderMode ? 17 : 14)
        .fontColor(GlobalTheme.TEXT_SECONDARY)
        .width('100%')
        .textAlign(TextAlign.Center)
        .margin({ bottom: 24 })

      Row() {
        Button('再想想')
          .fontSize(this.isElderMode ? 17 : 14)
          .backgroundColor(GlobalTheme.BG_COLOR)
          .fontColor(GlobalTheme.TEXT_SECONDARY)
          .flexGrow(1)
          .height(this.isElderMode ? 48 : 40)
          .borderRadius(8)
          .onClick(() => {
            this.showCancelDialog = false;
          })

        Button('确认取消')
          .fontSize(this.isElderMode ? 17 : 14)
          .backgroundColor(GlobalTheme.ERROR_COLOR)
          .fontColor(GlobalTheme.BUTTON_TEXT_COLOR)
          .flexGrow(1)
          .height(this.isElderMode ? 48 : 40)
          .borderRadius(8)
          .margin({ left: 12 })
          .onClick(() => {
            this.onCancelAppointment();
          })
      }
      .width('100%')
    }
    .width('80%')
    .padding(24)
    .backgroundColor(GlobalTheme.CARD_BG)
    .borderRadius(16)
    .shadow({
      radius: 20,
      color: 'rgba(0,0,0,0.1)',
      offsetX: 0,
      offsetY: 4
    })
  }
}
