import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Loading } from '../components/Loading';
import { EmptyState } from '../components/EmptyState';
import { HttpUtil, BaseResponse, HttpMethod } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import { ToastUtil } from '../common/utils/ToastUtil';
import { Appointment } from '../models/HealthData';
import { DoctorInfo, DoctorInfoHelper } from '../models/DoctorModel';
import { GlobalTheme } from '../global';

interface DepartmentInfo {
  id: number;
  hospitalId: number;
  deptName: string;
  deptIntro?: string;
  location?: string;
}

interface DepartmentPageRouteParams {
  hospitalId: number | string;
  hospitalName: string;
}

interface DepartmentQueryParams {
  hospitalId: number;
}

@Entry
@Component
struct DepartmentListPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State hospitalId: number = 0;
  @State hospitalName: string = '医院科室列表';
  @State departments: DepartmentInfo[] = [];
  @State filteredDepartments: DepartmentInfo[] = [];
  @State searchKeyword: string = '';
  @State isLoading: boolean = false;
  @State hasError: boolean = false;
  @State errorMessage: string = '';
  @State isInitialized: boolean = false;
  @State appointments: Appointment[] = [];
  @State bookedDepartments: number[] = [];
  @State showDoctorPicker: boolean = false;
  @State deptDoctors: DoctorInfo[] = [];
  @State selectedDeptForBooking: DepartmentInfo | null = null;
  @State isLoadingDoctors: boolean = false;

  aboutToAppear(): void {
    console.log('DepartmentListPage aboutToAppear 开始');

    try {
      const params: DepartmentPageRouteParams = router.getParams() as DepartmentPageRouteParams;
      console.log('路由参数:', params);

      if (params) {
        const id: number | string = params.hospitalId;
        const name: string = params.hospitalName;

        console.log('原始ID:', id, '类型:', typeof id);
        console.log('原始名称:', name);

        if (id !== undefined && id !== null) {
          this.hospitalId = typeof id === 'number' ? id : Number(id);
          console.log('转换后hospitalId:', this.hospitalId);
        }

        if (name && name.length > 0) {
          this.hospitalName = name;
          console.log('设置hospitalName:', this.hospitalName);
        }
      }
    } catch (error) {
      console.error('获取参数失败:', error);
    }

    console.log('DepartmentListPage aboutToAppear 完成');
    console.log('最终hospitalId:', this.hospitalId, 'hospitalName:', this.hospitalName);
  }

  onPageShow(): void {
    console.log('DepartmentListPage onPageShow');

    this.loadAppointments();

    if (!this.isInitialized) {
      this.isInitialized = true;
      this.loadDepartments();
    }
  }

  loadAppointments(): void {
    const storedAppointments = AppStorage.get<Appointment[]>('appointments');
    if (storedAppointments && storedAppointments.length > 0) {
      this.appointments = storedAppointments;
      this.bookedDepartments = [];
      for (let i = 0; i < this.appointments.length; i++) {
        const apt = this.appointments[i];
        if (apt.hospital === this.hospitalName &&
            (apt.status === 'pending' || apt.status === 'confirmed')) {
          const deptId = this.findDepartmentIdByName(apt.specialty);
          if (deptId > 0 && !this.bookedDepartments.includes(deptId)) {
            this.bookedDepartments.push(deptId);
          }
        }
      }
      console.log('已加载预约数量:', this.appointments.length, '当前医院已预约科室:', this.bookedDepartments.length);
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
    this.selectedDeptForBooking = department;
    this.showDoctorPicker = true;
    this.loadDoctorsForDepartment(department);
  }

  async loadDoctorsForDepartment(department: DepartmentInfo): Promise<void> {
    this.isLoadingDoctors = true;
    this.deptDoctors = [];
    try {
      const queryParams: Record<string, string> = { 'department': department.deptName };
      const res: BaseResponse<Object[]> = await HttpUtil.request<Object[]>(
        HttpMethod.GET,
        ApiConstants.DOCTOR_LIST,
        undefined,
        queryParams as Object,
        { showLoading: false }
      );
      if (res.code === 200 && res.data && res.data.length > 0) {
        const list: DoctorInfo[] = [];
        for (let i = 0; i < res.data.length; i++) {
          list.push(DoctorInfoHelper.fromJson(res.data[i] as Record<string, Object>));
        }
        this.deptDoctors = list;
      } else {
        const fallback: DoctorInfo = new DoctorInfo();
        fallback.realName = department.deptName + '医生';
        fallback.department = department.deptName;
        fallback.title = '主治医师';
        fallback.hospital = this.hospitalName;
        fallback.id = -1;
        this.deptDoctors = [fallback];
      }
    } catch (e) {
      console.error('加载医生列表失败:', e);
      const fallback: DoctorInfo = new DoctorInfo();
      fallback.realName = department.deptName + '医生';
      fallback.department = department.deptName;
      fallback.title = '主治医师';
      fallback.hospital = this.hospitalName;
      fallback.id = -1;
      this.deptDoctors = [fallback];
    } finally {
      this.isLoadingDoctors = false;
    }
  }

  onDoctorSelected(doctor: DoctorInfo): void {
    this.showDoctorPicker = false;
    try {
      router.pushUrl({
        url: 'pages/BookingPage',
        params: {
          doctorId: doctor.id || 0,
          doctorName: doctor.realName || '医生',
          fee: 10
        }
      }).then(() => {
        console.log('跳转到挂号页面成功');
      }).catch((err: Error) => {
        console.error('跳转失败:', err.message);
        ToastUtil.showError('页面跳转失败', 1500);
      });
    } catch (error) {
      console.error('路由异常:', error);
      ToastUtil.showError('系统错误', 1500);
    }
  }

  onCancelAppointment(department: DepartmentInfo): void {
    let index = -1;
    for (let i = 0; i < this.appointments.length; i++) {
      const apt = this.appointments[i];
      if (apt.hospital === this.hospitalName &&
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
      console.log('取消预约成功');
    } else {
      ToastUtil.showError('未找到可取消的预约', 1500);
    }
  }

  async loadDepartments(): Promise<void> {
    console.log('loadDepartments 开始, hospitalId:', this.hospitalId);

    if (!this.hospitalId || this.hospitalId <= 0) {
      console.warn('hospitalId无效，使用默认值');
      this.hasError = true;
      this.errorMessage = '正在加载科室信息...';
      this.loadDefaultDepartments();
      return;
    }

    this.isLoading = true;
    this.hasError = false;

    try {
      const queryParams: DepartmentQueryParams = { hospitalId: this.hospitalId };
      console.log('发送请求参数:', JSON.stringify(queryParams));

      const response: BaseResponse<DepartmentInfo[]> = await HttpUtil.request<DepartmentInfo[]>(
        HttpMethod.GET,
        ApiConstants.HOSPITAL_DEPARTMENT_LIST,
        undefined,
        queryParams,
        { showLoading: false }
      );

      console.log('API响应成功:', response.success, '数据长度:', response.data?.length);

      if (response.success && response.data && response.data.length > 0) {
        this.departments = response.data;
        this.filteredDepartments = response.data;
        console.log('科室列表加载成功，数量:', this.departments.length);
      } else {
        console.warn('API返回空数据或失败，使用默认数据');
        this.errorMessage = response.message || '';
        this.loadDefaultDepartments();
      }
    } catch (error) {
      console.error('API请求异常:', error);
      this.hasError = true;
      this.errorMessage = '网络连接异常';
      console.log('使用默认科室数据作为备选');
      this.loadDefaultDepartments();
    } finally {
      this.isLoading = false;
    }
  }

  loadDefaultDepartments(): void {
    console.log('加载默认科室数据');

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
    this.isLoading = false;

    console.log('默认科室数据加载完成，数量:', this.departments.length);
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
    Stack() {
      Column() {
        Header({ title: this.hospitalName + ' - 科室' })

        if (this.isLoading) {
          Loading({ text: '加载中...' })
            .layoutWeight(1)
        } else if (this.departments.length === 0 && this.hasError) {
          EmptyState({
            icon: '🏥',
            title: '暂无科室',
            description: this.errorMessage || '该医院暂无可用科室',
            buttonText: '重新加载',
            onAdd: () => {
              this.loadDepartments();
            }
          })
            .layoutWeight(1)
        } else {
        Column() {
          Row() {
            Text(`${this.hospitalName}`)
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

          Scroll() {
            List({ space: 12 }) {
              ForEach(this.filteredDepartments, (department: DepartmentInfo) => {
                ListItem() {
                  this.DepartmentCard(department)
                }
              }, (dept: DepartmentInfo) => dept.id.toString())
            }
            .width('100%')
            .height('100%')
            .padding({ left: 16, right: 16, bottom: 20 })
          }
          .scrollBar(BarState.Off)
          .layoutWeight(1)
        }
        .layoutWeight(1)
        }
      }
      .width('100%')
      .height('100%')

      if (this.showDoctorPicker) {
        this.buildDoctorPickerDialog();
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(GlobalTheme.BG_COLOR)
  }

  @Builder
  buildDoctorPickerDialog() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#00000080')
        .onClick(() => { this.showDoctorPicker = false; });

      Column({ space: 16 }) {
        Text('选择医生')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333');

        if (this.isLoadingDoctors) {
          Text('加载医生列表...')
            .fontSize(14)
            .fontColor('#999999')
            .padding({ top: 20, bottom: 20 })
            .width('100%')
            .textAlign(TextAlign.Center);
        } else {
          Scroll() {
            Column({ space: 10 }) {
              ForEach(this.deptDoctors, (doctor: DoctorInfo) => {
                Row() {
                  Column() {
                    Text(doctor.realName || '未知医生')
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)
                      .fontColor('#333333');
                    if (doctor.title) {
                      Text(doctor.title)
                        .fontSize(12)
                        .fontColor('#999999')
                        .margin({ top: 2 });
                    }
                    if (doctor.specialty) {
                      Text('擅长: ' + doctor.specialty)
                        .fontSize(11)
                        .fontColor('#BBBBBB')
                        .margin({ top: 2 })
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis });
                    }
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1);

                  Text('选择 >')
                    .fontSize(14)
                    .fontColor('#1677FF')
                    .fontWeight(FontWeight.Medium);
                }
                .width('100%')
                .padding(14)
                .backgroundColor('#F8F9FA')
                .borderRadius(10)
                .onClick(() => this.onDoctorSelected(doctor));
              }, (doc: DoctorInfo) => '' + doc.id);
            }
            .width('100%')
            .constraintSize({ maxHeight: 300 });
          }

          Button('取消')
            .width('100%')
            .height(40)
            .fontSize(14)
            .fontColor('#666666')
            .backgroundColor('#F5F5F5')
            .borderRadius(20)
            .onClick(() => { this.showDoctorPicker = false; });
        }
      }
      .width('85%')
      .constraintSize({ maxHeight: '70%' })
      .padding(20)
      .backgroundColor('#FFFFFF')
      .borderRadius(16);
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 });
  }
}
