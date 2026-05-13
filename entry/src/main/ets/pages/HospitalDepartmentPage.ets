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

interface DepartmentInfo {
  id: number;
  hospitalId: number;
  deptName: string;
  deptIntro?: string;
  location?: string;
}

@Entry
@Component
struct HospitalDepartmentPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State hospitalId: number = 0;
  @State hospitalNameDisplay: string = '';
  @State departments: DepartmentInfo[] = [];
  @State filteredDepartments: DepartmentInfo[] = [];
  @State searchKeyword: string = '';
  @State isLoading: boolean = true;
  @State hasError: boolean = false;
  @State errorMessage: string = '';
  @State appointments: Appointment[] = [];
  @State bookedDepartments: number[] = [];

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

  onPageShow(): void {
    this.loadAppointments();
  }

  loadAppointments(): void {
    const storedAppointments = AppStorage.get<Appointment[]>('appointments');
    if (storedAppointments && storedAppointments.length > 0) {
      this.appointments = storedAppointments;
      this.bookedDepartments = [];
      for (let i = 0; i < this.appointments.length; i++) {
        const apt = this.appointments[i];
        if (apt.hospital === this.hospitalNameDisplay &&
            (apt.status === 'pending' || apt.status === 'confirmed')) {
          const deptId = this.findDepartmentIdByName(apt.specialty);
          if (deptId > 0 && !this.bookedDepartments.includes(deptId)) {
            this.bookedDepartments.push(deptId);
          }
        }
      }
    } else {
      this.appointments = [];
      this.bookedDepartments = [];
    }
  }

  findDepartmentIdByName(deptName: string): number {
    for (let i = 0; i < this.departments.length; i++) {
      if (this.departments[i].deptName === deptName) {
        return this.departments[i].id;
      }
    }
    return 0;
  }

  isDepartmentBooked(department: DepartmentInfo): boolean {
    return this.bookedDepartments.includes(department.id);
  }

  onBookAppointment(department: DepartmentInfo): void {
    console.log('开始跳转到预约时间选择页面');
    console.log('医院名称:', this.hospitalNameDisplay);
    console.log('科室名称:', department.deptName);

    try {
      router.pushUrl({
        url: 'pages/AppointmentTimeSelectPage',
        params: {
          hospitalName: this.hospitalNameDisplay,
          departmentName: department.deptName,
          departmentLocation: department.location || `${department.deptName}诊室`
        }
      }).then(() => {
        console.log('成功跳转到预约时间选择页面');
      }).catch((error: Error) => {
        console.error('跳转失败:', error.message);
        ToastUtil.showError('页面跳转失败，请重试', 2000);
      });
    } catch (error) {
      console.error('路由异常:', error);
      ToastUtil.showError('系统错误，请稍后重试', 2000);
    }
  }

  onCancelAppointment(department: DepartmentInfo): void {
    let index = -1;
    for (let i = 0; i < this.appointments.length; i++) {
      const apt = this.appointments[i];
      if (apt.hospital === this.hospitalNameDisplay &&
          apt.specialty === department.deptName &&
          (apt.status === 'pending' || apt.status === 'confirmed')) {
        index = i;
        break;
      }
    }

    if (index !== -1) {
      this.appointments[index].status = 'cancelled';
      AppStorage.setOrCreate<Appointment[]>('appointments', this.appointments);

      const bookedIndex = this.bookedDepartments.indexOf(department.id);
      if (bookedIndex > -1) {
        this.bookedDepartments.splice(bookedIndex, 1);
      }

      ToastUtil.showSuccess(`已取消 ${department.deptName} 预约`, 2000);
    } else {
      ToastUtil.showError('未找到可取消的预约', 1500);
    }
  }

  async loadDepartments(): Promise<void> {
    this.isLoading = true;

    try {
      const queryParams: Record<string, number> = { 'hospitalId': this.hospitalId };

      const response: BaseResponse<DepartmentInfo[]> = await HttpUtil.request<DepartmentInfo[]>(
        HttpMethod.GET,
        ApiConstants.HOSPITAL_DEPARTMENT_LIST,
        undefined,
        queryParams as Object,
        { showLoading: true, loadingText: '加载科室信息...' }
      );

      if (response.success && response.data) {
        this.departments = response.data;
        this.filteredDepartments = response.data;

        if (this.departments.length === 0) {
          console.warn('API返回空科室数据，使用默认数据');
          this.loadDefaultDepartments();
        }
      } else {
        console.warn('API请求失败，使用默认科室数据');
        this.loadDefaultDepartments();
      }
    } catch (error) {
      console.error('API请求异常:', error);
      console.log('使用默认科室数据作为备选');
      this.loadDefaultDepartments();
    } finally {
      this.isLoading = false;
    }
  }

  loadDefaultDepartments(): void {
    const defaultDepts: DepartmentInfo[] = [
      {
        id: 1,
        hospitalId: this.hospitalId || 1,
        deptName: '内科',
        location: '门诊楼3层',
        deptIntro: '诊治各种内科疾病'
      },
      {
        id: 2,
        hospitalId: this.hospitalId || 1,
        deptName: '外科',
        location: '门诊楼5层',
        deptIntro: '开展各类外科手术'
      },
      {
        id: 3,
        hospitalId: this.hospitalId || 1,
        deptName: '儿科',
        location: '门诊楼2层',
        deptIntro: '儿童疾病诊疗中心'
      },
      {
        id: 4,
        hospitalId: this.hospitalId || 1,
        deptName: '妇产科',
        location: '住院部4层',
        deptIntro: '妇女儿童健康服务'
      },
      {
        id: 5,
        hospitalId: this.hospitalId || 1,
        deptName: '骨科',
        location: '门诊楼6层',
        deptIntro: '骨关节疾病诊疗'
      },
      {
        id: 6,
        hospitalId: this.hospitalId || 1,
        deptName: '眼科',
        location: '门诊楼3层',
        deptIntro: '眼部疾病诊断与治疗'
      }
    ];

    this.departments = defaultDepts;
    this.filteredDepartments = defaultDepts;
    this.hasError = false;
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
    this.filteredDepartments = this.departments.filter(dept =>
      dept.deptName.toLowerCase().includes(keyword) ||
      (dept.location && dept.location.toLowerCase().includes(keyword))
    );
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

        if (this.isDepartmentBooked(department)) {
          Button('取消预约')
            .fontSize(this.isElderMode ? 15 : 12)
            .backgroundColor('#FFFFFF')
            .fontColor(GlobalTheme.ERROR_COLOR)
            .height(this.isElderMode ? 40 : 32)
            .padding({ left: 12, right: 12 })
            .borderRadius(6)
            .border({ width: 1, color: GlobalTheme.ERROR_COLOR })
            .onClick(() => {
              this.onCancelAppointment(department);
            })
        } else {
          Button('预约')
            .fontSize(this.isElderMode ? 15 : 12)
            .backgroundColor(GlobalTheme.THEME_COLOR)
            .fontColor('#FFFFFF')
            .height(this.isElderMode ? 40 : 32)
            .padding({ left: 16, right: 16 })
            .borderRadius(6)
            .onClick(() => {
              this.onBookAppointment(department);
            })
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
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(GlobalTheme.CARD_BG)
    .borderRadius(8)
    .alignItems(HorizontalAlign.Start)
  }

  build() {
    Column() {
      Header({ title: this.hospitalNameDisplay + ' - 科室', showBack: true })

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
        .onClick(() => this.loadDepartments())
      } else {
        Scroll() {
          Column() {
            Row() {
              Text(`${this.hospitalNameDisplay}`)
                .fontSize(this.isElderMode ? 20 : 17)
                .fontWeight(FontWeight.Bold)
                .fontColor(GlobalTheme.THEME_COLOR)
                .layoutWeight(1)

              Text(`共 ${this.departments.length} 个科室`)
                .fontSize(this.isElderMode ? 16 : 13)
                .fontColor(GlobalTheme.TEXT_HINT)
            }
            .width('100%')
            .padding({ left: 16, top: 16, right: 16, bottom: 12 })

            Row() {
              TextInput({ placeholder: '搜索科室...', text: this.searchKeyword })
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
                    this.filteredDepartments = this.departments;
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
                ForEach(this.filteredDepartments, (department: DepartmentInfo) => {
                  ListItem() {
                    this.DepartmentCard(department)
                  }
                }, (department: DepartmentInfo) => department.id.toString())
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
