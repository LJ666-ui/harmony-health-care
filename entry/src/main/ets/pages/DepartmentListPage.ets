import { router } from '@kit.ArkUI';
import { HttpUtil, BaseResponse, HttpMethod } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import { ToastUtil } from '../common/utils/ToastUtil';

interface DepartmentInfo {
  id: number;
  hospitalId: number;
  deptName: string;
  deptIntro?: string;
  location?: string;
}

interface DoctorWithSchedule {
  id: number;
  userId: number;
  realName: string;
  phone: string;
  hospital: string;
  department: string;
  licenseNumber: string;
  title: string;
  specialty: string;
  avatar: string;
  description: string;
  rating: number;
  status: number;
  createTime: string;
  updateTime: string;
  scheduleId?: number;
  remainingStock?: number;
  scheduleDate?: string;
}

@Entry
@Component
struct DepartmentListPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State hospitalId: number = 0;
  @State hospitalName: string = '挂号选择科室';
  @State departments: DepartmentInfo[] = [];
  @State selectedDeptIndex: number = 0;
  @State searchKeyword: string = '';
  @State isLoading: boolean = false;
  @State doctors: DoctorWithSchedule[] = [];
  @State isLoadingDoctors: boolean = false;

  aboutToAppear(): void {
    try {
      const params: Object | undefined = router.getParams();
      if (params) {
        const p: Record<string, Object> = params as Record<string, Object>;
        this.hospitalId = Number(p['hospitalId'] || '0');
        this.hospitalName = String(p['hospitalName'] || '挂号选择科室');
      }
    } catch (error) {
      console.error('获取参数失败:', error);
    }

    this.loadDepartments();
  }

  async loadDepartments(): Promise<void> {
    this.isLoading = true;
    try {
      const queryParams: Record<string, string> = { 'hospitalId': String(this.hospitalId) };
      const response: BaseResponse<DepartmentInfo[]> = await HttpUtil.request<DepartmentInfo[]>(
        HttpMethod.GET,
        ApiConstants.HOSPITAL_DEPARTMENT_LIST,
        undefined,
        queryParams as Object
      );

      if (response.success && response.data && response.data.length > 0) {
        this.departments = response.data;
        if (this.departments.length > 0) {
          this.selectedDeptIndex = 0;
          this.loadDoctorsForDepartment(this.departments[0]);
        }
      } else {
        this.loadDefaultDepartments();
      }
    } catch (error) {
      console.error('加载科室列表失败:', error);
      this.loadDefaultDepartments();
    } finally {
      this.isLoading = false;
    }
  }

  loadDefaultDepartments(): void {
    this.departments = [
      { id: 1, hospitalId: this.hospitalId || 1, deptName: '心血管内科', location: '门诊楼3层' },
      { id: 2, hospitalId: this.hospitalId || 1, deptName: '血液/肿瘤科', location: '门诊楼3层' },
      { id: 3, hospitalId: this.hospitalId || 1, deptName: '神经内科(脑病科)', location: '门诊楼4层' },
      { id: 4, hospitalId: this.hospitalId || 1, deptName: '睡眠医学科门诊', location: '门诊楼5层' },
      { id: 5, hospitalId: this.hospitalId || 1, deptName: '精神医学科', location: '门诊楼5层' },
      { id: 6, hospitalId: this.hospitalId || 1, deptName: '全科', location: '门诊楼2层' },
      { id: 7, hospitalId: this.hospitalId || 1, deptName: '外科', location: '门诊楼6层' },
      { id: 8, hospitalId: this.hospitalId || 1, deptName: '神经外科中心', location: '住院部8层' },
      { id: 9, hospitalId: this.hospitalId || 1, deptName: '妇孺国医堂', location: '住院部3层' },
      { id: 10, hospitalId: this.hospitalId || 1, deptName: '妇产科/生殖/男性', location: '住院部4层' },
      { id: 11, hospitalId: this.hospitalId || 1, deptName: '儿科', location: '门诊楼2层' },
      { id: 12, hospitalId: this.hospitalId || 1, deptName: '眼科', location: '门诊楼3层' },
      { id: 13, hospitalId: this.hospitalId || 1, deptName: '口腔科', location: '门诊楼4层' },
      { id: 14, hospitalId: this.hospitalId || 1, deptName: '耳鼻咽喉科', location: '门诊楼4层' },
      { id: 15, hospitalId: this.hospitalId || 1, deptName: '皮肤/医美', location: '门诊楼5层' }
    ];

    if (this.departments.length > 0) {
      this.selectedDeptIndex = 0;
      this.loadDoctorsForDepartment(this.departments[0]);
    }
  }

  onDepartmentSelected(index: number): void {
    if (index !== this.selectedDeptIndex) {
      this.selectedDeptIndex = index;
      this.loadDoctorsForDepartment(this.departments[index]);
    }
  }

  async loadDoctorsForDepartment(department: DepartmentInfo): Promise<void> {
    this.isLoadingDoctors = true;
    this.doctors = [];

    try {
      const today = new Date();
      const year = today.getFullYear();
      const month = String(today.getMonth() + 1).padStart(2, '0');
      const day = String(today.getDate()).padStart(2, '0');
      const todayStr = `${year}-${month}-${day}`;

      const futureDate = new Date(today);
      futureDate.setDate(today.getDate() + 7);
      const futureYear = futureDate.getFullYear();
      const futureMonth = String(futureDate.getMonth() + 1).padStart(2, '0');
      const futureDay = String(futureDate.getDate()).padStart(2, '0');
      const futureStr = `${futureYear}-${futureMonth}-${futureDay}`;

      const queryParams: Record<string, string> = {
        'department': department.deptName,
        'hospitalId': String(this.hospitalId),
        'startDate': todayStr,
        'endDate': futureStr
      };

      const res: BaseResponse<Object[]> = await HttpUtil.request<Object[]>(
        HttpMethod.GET,
        ApiConstants.SCHEDULE_LIST,
        undefined,
        queryParams as Object,
        { showLoading: false }
      );

      if (res.success && res.data && res.data.length > 0) {
        const doctorMap: Map<string, DoctorWithSchedule> = new Map();

        for (let i = 0; i < res.data.length; i++) {
          const raw = res.data[i] as Record<string, Object>;
          const doctorId = String(raw['doctorId'] || raw['id'] || '0');
          const doctorName = String(raw['doctorName'] || raw['realName'] || '未知医生');
          const remainingStock = Number(raw['remainingStock'] || raw['stock'] || '0');
          const scheduleDate = String(raw['scheduleDate'] || todayStr);

          if (!doctorMap.has(doctorId) || remainingStock > (doctorMap.get(doctorId)?.remainingStock || 0)) {
            const doctor: DoctorWithSchedule = {
              id: Number(raw['doctorId'] || raw['id'] || '0'),
              userId: Number(raw['userId'] || '0'),
              realName: doctorName,
              phone: String(raw['phone'] || ''),
              hospital: String(raw['hospital'] || this.hospitalName),
              department: String(raw['department'] || department.deptName),
              licenseNumber: String(raw['licenseNumber'] || ''),
              title: String(raw['title'] || '主治医师'),
              specialty: String(raw['specialty'] || ''),
              avatar: String(raw['avatar'] || ''),
              description: String(raw['description'] || ''),
              rating: Number(raw['rating'] || '5.0'),
              status: Number(raw['status'] || '1'),
              createTime: String(raw['createTime'] || ''),
              updateTime: String(raw['updateTime'] || ''),
              scheduleId: Number(raw['scheduleId'] || raw['id'] || '0'),
              remainingStock: remainingStock,
              scheduleDate: scheduleDate
            };
            doctorMap.set(doctorId, doctor);
          }
        }

        this.doctors = Array.from(doctorMap.values());
      } else {
        console.log(`科室 ${department.deptName} 近期暂无排班医生`);
      }
    } catch (e) {
      console.error('加载排班医生列表失败:', e);
    } finally {
      this.isLoadingDoctors = false;
    }
  }

  onDoctorClick(doctor: DoctorWithSchedule): void {
    const selectedDept = this.departments.length > this.selectedDeptIndex ? this.departments[this.selectedDeptIndex] : null;

    router.pushUrl({
      url: 'pages/DoctorDetailPage',
      params: {
        doctorId: doctor.id || 0,
        doctorName: doctor.realName || '医生',
        hospitalId: this.hospitalId,
        hospitalName: this.hospitalName,
        departmentId: selectedDept?.id || 0,
        departmentName: selectedDept?.deptName || doctor.department || '',
        departmentLocation: selectedDept?.location || '',
        scheduleId: doctor.scheduleId || 0,
        remainingStock: doctor.remainingStock || 0
      }
    }).then(() => {
      console.log('跳转到医生详情页成功');
    }).catch((err: Error) => {
      console.error('跳转失败:', err.message);
      ToastUtil.showError('页面跳转失败', 1500);
    });
  }

  getFilteredDepartments(): DepartmentInfo[] {
    if (!this.searchKeyword || this.searchKeyword.trim() === '') {
      return this.departments;
    }

    const keyword = this.searchKeyword.trim().toLowerCase();
    return this.departments.filter(dept =>
      dept.deptName.toLowerCase().includes(keyword)
    );
  }

  build() {
    Column() {
      this.TitleBar();

      this.SearchBar();

      if (this.isLoading) {
        this.LoadingView()
      } else {
        Row() {
          this.DepartmentListPanel();

          this.DoctorListPanel();
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }

  @Builder
  TitleBar() {
    Row() {
      Button({ type: ButtonType.Normal }) {
        Text('✕')
          .fontSize(18)
          .fontColor('#333333');
      }
      .width(40)
      .height(40)
      .backgroundColor('transparent')
      .onClick(() => router.back());

      Column() {
        Text(this.hospitalName)
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333');

        Text('mp.mhealth100.com')
          .fontSize(11)
          .fontColor('#999999')
          .margin({ top: 2 });
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center);

      Button({ type: ButtonType.Normal }) {
        Text('···')
          .fontSize(18)
          .fontColor('#333333');
      }
      .width(40)
      .height(40)
      .backgroundColor('transparent');
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  SearchBar() {
    Row() {
      Text('🔍')
        .fontSize(14)
        .fontColor('#BBBBBB')
        .margin({ right: 8 });

      TextInput({
        placeholder: '科室、医生姓名或拼音首字母',
        text: this.searchKeyword
      })
        .layoutWeight(1)
        .height(36)
        .fontSize(14)
        .backgroundColor('#F5F5F5')
        .borderRadius(18)
        .placeholderFont({ size: 13 })
        .padding({ left: 12, right: 12 })
        .onChange((value: string) => {
          this.searchKeyword = value;
        });
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor('#FFFFFF');
  }

  @Builder
  DepartmentListPanel() {
    Column() {
      Scroll() {
        Column() {
          ForEach(this.getFilteredDepartments(), (dept: DepartmentInfo, index: number) => {
            this.DepartmentItem(dept, index);
          }, (dept: DepartmentInfo) => `${dept.id}`);
        }
        .width('100%');
      }
      .scrollBar(BarState.Off)
      .width('100%')
      .layoutWeight(1);
    }
    .width('35%')
    .height('100%')
    .backgroundColor('#F8F9FA');
  }

  @Builder
  DepartmentItem(dept: DepartmentInfo, index: number) {
    Row() {
      Text(dept.deptName)
        .fontSize(14)
        .fontColor(this.selectedDeptIndex === index ? '#1677FF' : '#333333')
        .fontWeight(this.selectedDeptIndex === index ? FontWeight.Medium : FontWeight.Normal)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .layoutWeight(1);
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 14, bottom: 14 })
    .backgroundColor(this.selectedDeptIndex === index ? '#FFFFFF' : '#F8F9FA')
    .border({
      width: { left: this.selectedDeptIndex === index ? 3 : 0, right: 0, top: 0, bottom: 0.5 },
      color: { left: '#1677FF', right: 'transparent', top: 'transparent', bottom: '#EEEEEE' }
    })
    .onClick(() => {
      const realIndex = this.departments.indexOf(dept);
      if (realIndex >= 0) {
        this.onDepartmentSelected(realIndex);
      }
    });
  }

  @Builder
  DoctorListPanel() {
    Column() {
      Column() {
        Text(this.departments.length > 0 ? this.departments[this.selectedDeptIndex].deptName : '')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .width('100%')
          .padding({ left: 20, top: 20, bottom: 16 });
      }
      .width('100%')
      .backgroundColor('#FFFFFF');

      if (this.isLoadingDoctors) {
        this.LoadingView()
      } else if (this.doctors.length === 0) {
        this.EmptyDoctorsView()
      } else {
        Scroll() {
          Column({ space: 0 }) {
            ForEach(this.doctors, (doctor: DoctorWithSchedule) => {
              this.DoctorItem(doctor);
            }, (doc: DoctorWithSchedule) => `${doc.id}`);
          }
          .width('100%')
          .padding({ bottom: 20 });
        }
        .scrollBar(BarState.Off)
        .width('100%')
        .width('100%')
        .layoutWeight(1)
        .backgroundColor('#FFFFFF');
      }
    }
    .width('65%')
    .height('100%')
    .backgroundColor('#FFFFFF');
  }

  @Builder
  DoctorItem(doctor: DoctorWithSchedule) {
    Row() {
      Column({ space: 6 }) {
        Text(doctor.realName || '未知医生')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333');

        if (doctor.title) {
          Text(doctor.title)
            .fontSize(12)
            .fontColor('#666666');
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1);

      Text('>')
        .fontSize(14)
        .fontColor('#CCCCCC')
        .margin({ left: 4 });
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 16, bottom: 16 })
    .border({ width: { bottom: 0.5 }, color: '#F0F0F0' })
    .onClick(() => {
      if (doctor.remainingStock !== undefined && doctor.remainingStock > 0) {
        this.onDoctorClick(doctor);
      } else {
        ToastUtil.showError('该医生今日号源已满', 1500);
      }
    });
  }

  @Builder
  LoadingView() {
    Column({ space: 12 }) {
      LoadingProgress()
        .width(36)
        .height(36)
        .color('#1677FF');

      Text('加载中...')
        .fontSize(14)
        .fontColor('#999999');
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#FFFFFF');
  }

  @Builder
  EmptyDoctorsView() {
    Column({ space: 20 }) {
      Column({ space: 16 }) {
        Text('🏥')
          .fontSize(56);

        Column({ space: 8 }) {
          Text('该科室暂无医生排号')
            .fontSize(17)
            .fontColor('#333333')
            .fontWeight(FontWeight.Bold);

          Text('当前科室未安排出诊医生或号源已全部约满')
            .fontSize(13)
            .fontColor('#999999')
            .textAlign(TextAlign.Center)
            .width('80%');
        }
        .alignItems(HorizontalAlign.Center);
      }

      Column({ space: 12 }) {
        Button('刷新列表')
          .width(140)
          .height(40)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .backgroundColor('#1677FF')
          .borderRadius(20)
          .onClick(() => {
            if (this.departments.length > this.selectedDeptIndex) {
              this.loadDoctorsForDepartment(this.departments[this.selectedDeptIndex]);
            }
          });

        Button('选择其他科室')
          .width(140)
          .height(40)
          .fontSize(14)
          .fontColor('#666666')
          .backgroundColor('#F5F5F5')
          .borderRadius(20)
          .onClick(() => {
            ToastUtil.showInfo('请在左侧选择其他科室', 1500);
          });
      }
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#FAFBFC')
    .padding({ left: 24, right: 24 });
  }
}
