import { router } from '@kit.ArkUI';
import { GlobalTheme } from '../global';
import { HttpUtil, BaseResponse, HttpMethod } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import { ToastUtil } from '../common/utils/ToastUtil';
import promptAction from '@ohos.promptAction';

const PRIMARY = '#1677FF';
const SUCCESS = '#52C41A';
const WARNING = '#FAAD14';
const DANGER = '#FF4D4F';
const PURPLE = '#8B5CF6';

interface UserInfo {
  id: number;
  username: string;
  phone?: string;
  age?: number;
  idCard?: string;
  userType?: number;
  createTime?: string;
}

interface ScheduleForm {
  doctorId: number | null;
  scheduleDate: string;
  schedulePeriod: number;
  maxCount: number;
}

interface DoctorOption {
  id: number;
  realName: string;
  department: string;
  hospital: string;
}

@Entry
@Component
struct AdminUsers {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State searchText: string = '';
  @State filterType: number = -1;
  @State users: UserInfo[] = [];
  @State totalRecords: number = 0;
  @State currentPage: number = 1;
  @State pageSize: number = 15;
  @State isLoading: boolean = false;
  @State showDetailModal: boolean = false;
  @State selectedUser: UserInfo | null = null;
  @State activeTab: number = 0;

  @State scheduleDoctorId: number | null = null;
  @State scheduleDate: string = '';
  @State schedulePeriod: number = 1;
  @State scheduleMaxCount: number = 20;
  @State scheduleLoading: boolean = false;
  @State doctors: DoctorOption[] = [];
  @State showSchedulePanel: boolean = false;
  @State doctorCurrentPage: number = 1;
  @State doctorPageSize: number = 15;

  aboutToAppear(): void {
    this.loadUsers();
    this.loadDoctors();
    const today = new Date();
    const y = today.getFullYear();
    const m = String(today.getMonth() + 1).padStart(2, '0');
    const d = String(today.getDate()).padStart(2, '0');
    this.scheduleDate = `${y}-${m}-${d}`;
    try {
      const params = router.getParams() as Record<string, Object>;
      if (params && params['activeTab'] !== undefined) {
        this.activeTab = Number(params['activeTab']);
      }
    } catch (e) {
      console.error('[AdminUsers] parseParams error:', e);
    }
  }

  async loadUsers(): Promise<void> {
    this.isLoading = true;
    try {
      const params: Record<string, Object> = {
        'page': String(this.currentPage),
        'size': String(this.pageSize)
      };
      if (this.searchText.trim()) {
        params['keyword'] = this.searchText.trim();
      }
      if (this.filterType >= 0) {
        params['userType'] = this.filterType;
      }

      const response: BaseResponse<Object> = await HttpUtil.request<Object>(
        HttpMethod.GET,
        ApiConstants.ADMIN_USER_LIST,
        undefined,
        params as Object
      );

      if (response.success && response.data) {
        const data = response.data as Record<string, Object>;
        const records = data['records'];
        if (Array.isArray(records)) {
          this.users = records.map((r: Object): UserInfo => {
            const item = r as Record<string, Object>;
            return {
              id: Number(item['id']) || 0,
              username: String(item['username'] || ''),
              phone: item['phone'] ? String(item['phone']) : undefined,
              age: item['age'] ? Number(item['age']) : undefined,
              idCard: item['idCard'] || item['id_card'] ? String(item['idCard'] || item['id_card']) : undefined,
              userType: item['userType'] || item['user_type'] ? Number(item['userType'] || item['user_type']) : undefined,
              createTime: item['createTime'] || item['create_time'] ? String(item['createTime'] || item['create_time']) : undefined
            };
          });
          this.totalRecords = Number(data['total']) || 0;
        }
      } else {
        ToastUtil.showError(response.message || '加载用户列表失败', 2000);
      }
    } catch (error) {
      console.error('[AdminUsers] 加载失败:', error);
      ToastUtil.showError('网络错误，请检查后端服务', 2000);
    } finally {
      this.isLoading = false;
    }
  }

  async loadDoctors(): Promise<void> {
    try {
      const response: BaseResponse<Object[]> = await HttpUtil.request<Object[]>(
        HttpMethod.GET,
        ApiConstants.DOCTOR_LIST,
        undefined,
        undefined
      );
      if (response.success && Array.isArray(response.data)) {
        this.doctors = response.data.map((d: Object): DoctorOption => {
          const item = d as Record<string, Object>;
          return {
            id: Number(item['id']) || 0,
            realName: String(item['realName'] || item['real_name'] || item['name'] || ''),
            department: String(item['department'] || ''),
            hospital: String(item['hospital'] || '')
          };
        }).filter((d: DoctorOption) => d.id > 0);
      }
    } catch (e) {
      console.error('[AdminUsers] 加载医生列表失败:', e);
    }
  }

  onSearchChange(value: string): void {
    this.searchText = value;
    this.currentPage = 1;
    this.loadUsers();
  }

  onFilterChange(type: number): void {
    this.filterType = type;
    this.currentPage = 1;
    this.loadUsers();
  }

  getTotalPages(): number {
    return Math.max(1, Math.ceil(this.totalRecords / this.pageSize));
  }

  getDoctorTotalPages(): number {
    return Math.max(1, Math.ceil(this.doctors.length / this.doctorPageSize));
  }

  getPagedDoctors(): DoctorOption[] {
    const start: number = (this.doctorCurrentPage - 1) * this.doctorPageSize;
    const end: number = start + this.doctorPageSize;
    return this.doctors.slice(start, end);
  }

  getUserTypeName(type: number | undefined): string {
    if (type === 1) return '医生';
    if (type === 2) return '管理员';
    return '普通用户';
  }

  getUserTypeColor(type: number | undefined): string {
    if (type === 1) return PRIMARY;
    if (type === 2) return PURPLE;
    return SUCCESS;
  }

  formatTime(time: string | undefined): string {
    if (!time) return '-';
    return time.replace('T', ' ').substring(0, 16);
  }

  async addSchedule(): Promise<void> {
    if (!this.scheduleDoctorId) {
      ToastUtil.showError('请选择医生', 1500);
      return;
    }
    if (!this.scheduleDate) {
      ToastUtil.showError('请选择日期', 1500);
      return;
    }
    if (this.scheduleMaxCount <= 0) {
      ToastUtil.showError('号源数必须大于0', 1500);
      return;
    }

    this.scheduleLoading = true;
    try {
      const body: Record<string, Object> = {
        'doctorId': this.scheduleDoctorId,
        'scheduleDate': this.scheduleDate,
        'schedulePeriod': this.schedulePeriod,
        'maxCount': this.scheduleMaxCount
      };

      const response: BaseResponse<Object> = await HttpUtil.request<Object>(
        HttpMethod.POST,
        ApiConstants.SCHEDULE_ADD,
        body as Object
      );

      if (response.success) {
        ToastUtil.showSuccess('放号成功！', 2000);
        this.schedulePeriod = 1;
        this.scheduleMaxCount = 20;
      } else {
        ToastUtil.showError(response.message || '放号失败', 2000);
      }
    } catch (error) {
      console.error('[AdminUsers] 放号失败:', error);
      ToastUtil.showError('网络错误', 2000);
    } finally {
      this.scheduleLoading = false;
    }
  }

  build() {
    Column() {
      this.HeaderBar();

      Tabs({ index: this.activeTab }) {
        TabContent() {
          this.UserManagementTab()
        }.tabBar(this.TabBarBuilder('👥 用户管理', 0));

        TabContent() {
          this.ScheduleTab()
        }.tabBar(this.TabBarBuilder('📅 放号管理', 1));
      }
      .layoutWeight(1)
      .barPosition(BarPosition.Start)
      .barBackgroundColor('#FFFFFF')
      .barMode(BarMode.Fixed)
      .onChange((index: number) => {
        this.activeTab = index;
      });

      if (this.showDetailModal && this.selectedUser) {
        this.DetailModal();
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F0F2F5');
  }

  @Builder
  HeaderBar() {
    Row() {
      Button({ type: ButtonType.Normal }) {
        Text('←')
          .fontSize(18)
          .fontColor('#FFFFFF');
      }
      .width(38)
      .height(38)
      .backgroundColor('rgba(255,255,255,0.15)')
      .borderRadius(10)
      .onClick(() => router.back());

      Text('用户管理中心')
        .fontSize(17)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .layoutWeight(1)
        .textAlign(TextAlign.Center);

      Row({ space: 4 }) {
        Text(`共${this.totalRecords}人`)
          .fontSize(12)
          .fontColor('rgba(255,255,255,0.7)')
          .backgroundColor('rgba(255,255,255,0.12)')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .borderRadius(10);
      }
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .linearGradient({
      direction: GradientDirection.Right,
      colors: [[PRIMARY, 0], ['#722ED1', 1]]
    })
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  TabBarBuilder(title: string, index: number) {
    Column({ space: 4 }) {
      Text(title)
        .fontSize(13)
        .fontColor(this.activeTab === index ? PRIMARY : '#999')
        .fontWeight(this.activeTab === index ? FontWeight.Bold : FontWeight.Normal);

      if (this.activeTab === index) {
        Row()
          .width(20)
          .height(3)
          .borderRadius(2)
          .backgroundColor(PRIMARY);
      } else {
        Row().width(20).height(3);
      }
    }
    .width('100%')
    .height(48)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  UserManagementTab() {
    Column({ space: 0 }) {
      this.SearchAndFilterSection();

      if (this.isLoading) {
        this.LoadingView();
      } else if (this.users.length === 0) {
        this.EmptyView();
      } else {
        this.UserListSection();
        this.PaginationBar();
      }
    }
    .width('100%')
    .height('100%')
    .layoutWeight(1);
  }

  @Builder
  SearchAndFilterSection() {
    Column({ space: 12 }) {
      Row() {
        TextInput({ placeholder: '搜索用户名 / 手机号 / 身份证...', text: this.searchText })
          .layoutWeight(1)
          .height(40)
          .backgroundColor('#F5F7FA')
          .borderRadius(10)
          .placeholderFont({ size: 13 })
          .fontSize(14)
          .padding({ left: 36, right: 12 })
          .onChange((v: string) => this.onSearchChange(v));

        if (this.searchText.length > 0) {
          Button({ type: ButtonType.Normal }) {
            Text('✕').fontSize(14).fontColor('#999');
          }
            .width(34).height(34)
            .backgroundColor('#EEE')
            .borderRadius(8)
            .margin({ left: 8 })
            .onClick(() => { this.searchText = ''; this.loadUsers(); });
        }
      }

      Scroll() {
        Row({ space: 8 }) {
          this.FilterChip('全部', -1);
          this.FilterChip('普通用户', 0);
          this.FilterChip('医生', 1);
          this.FilterChip('管理员', 2);
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%');

      Row() {
        Text(`找到 ${this.totalRecords} 条记录`)
          .fontSize(12)
          .fontColor('#999');
        Blank();
        Text(`第 ${this.currentPage}/${this.getTotalPages()} 页`)
          .fontSize(12)
          .fontColor('#999');
      }
      .width('100%');
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .margin({ top: 12, left: 12, right: 12 })
    .borderRadius(14);
  }

  @Builder
  FilterChip(label: string, type: number) {
    Text(label)
      .fontSize(13)
      .fontColor(this.filterType === type ? '#FFFFFF' : '#555')
      .padding({ left: 16, right: 16, top: 6, bottom: 6 })
      .borderRadius(20)
      .backgroundColor(this.filterType === type ? PRIMARY : '#F0F0F0')
      .onClick(() => this.onFilterChange(type));
  }

  @Builder
  LoadingView() {
    Column({ space: 12 }) {
      LoadingProgress().width(36).height(36).color(PRIMARY);
      Text('加载中...').fontSize(13).fontColor('#999');
    }
    .width('100%')
    .height(300)
    .justifyContent(FlexAlign.Center);
  }

  @Builder
  EmptyView() {
    Column({ space: 12 }) {
      Text('📋').fontSize(48);
      Text('暂无用户数据').fontSize(15).fontColor('#666').fontWeight(FontWeight.Medium);
      Text(this.searchText ? '尝试更换搜索关键词' : '数据库中暂无注册用户')
        .fontSize(12).fontColor('#AAA');
    }
    .width('100%')
    .height(280)
    .justifyContent(FlexAlign.Center);
  }

  @Builder
  UserListSection() {
    List({ space: 10 }) {
      ForEach(this.users, (user: UserInfo) => {
        ListItem() {
          Row() {
            Column({ space: 6 }) {
              Text(user.username)
                .fontSize(15)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1A1A2E')
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis });

              Row({ space: 8 }) {
                Text(this.getUserTypeName(user.userType))
                  .fontSize(11)
                  .fontColor(this.getUserTypeColor(user.userType))
                  .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                  .backgroundColor(this.getUserTypeColor(user.userType) + '18')
                  .borderRadius(4);

                if (user.phone) {
                  Text(`📱 ${user.phone}`)
                    .fontSize(12)
                    .fontColor('#888');
                }
              }

              Row({ space: 12 }) {
                if (user.age != null) {
                  Text(`${user.age}岁`).fontSize(11).fontColor('#AAA');
                }
                Text(`🕐 ${this.formatTime(user.createTime)}`)
                  .fontSize(11)
                  .fontColor('#BBB')
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis });
              }
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
            .margin({ right: 8 });

            Button({ type: ButtonType.Normal }) {
              Text('详情').fontSize(12).fontColor(PRIMARY);
            }
            .height(32)
            .padding({ left: 14, right: 14 })
            .backgroundColor(PRIMARY + '12')
            .borderRadius(8)
            .onClick(() => { this.selectedUser = user; this.showDetailModal = true; });
          }
          .width('100%')
          .padding(14)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .shadow({ radius: 8, color: '#00000008', offsetX: 0, offsetY: 2 });
        }
      }, (user: UserInfo) => `${user.id}_${user.username}`);
    }
    .width('100%')
    .layoutWeight(1)
    .padding({ left: 12, right: 12, top: 8 });
  }

  @Builder
  PaginationBar() {
    Row({ space: 10 }) {
      Button({ type: ButtonType.Normal }) {
        Text('◀ 上一页').fontSize(12);
      }
      .height(34)
      .fontSize(12)
      .padding({ left: 14, right: 14 })
      .backgroundColor(this.currentPage > 1 ? PRIMARY : '#E8ECF2')
      .fontColor(this.currentPage > 1 ? '#FFF' : '#BBB')
      .borderRadius(8)
      .enabled(this.currentPage > 1)
      .onClick(() => { if (this.currentPage > 1) { this.currentPage--; this.loadUsers(); } });

      Text(`${this.currentPage} / ${this.getTotalPages()}`)
        .fontSize(13)
        .fontColor('#666')
        .width(60)
        .textAlign(TextAlign.Center);

      Button({ type: ButtonType.Normal }) {
        Text('下一页 ▶').fontSize(12);
      }
      .height(34)
      .fontSize(12)
      .padding({ left: 14, right: 14 })
      .backgroundColor(this.currentPage < this.getTotalPages() ? PRIMARY : '#E8ECF2')
      .fontColor(this.currentPage < this.getTotalPages() ? '#FFF' : '#BBB')
      .borderRadius(8)
      .enabled(this.currentPage < this.getTotalPages())
      .onClick(() => { if (this.currentPage < this.getTotalPages()) { this.currentPage++; this.loadUsers(); } });
    }
    .width('100%')
    .height(56)
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#FFFFFF')
    .padding({ left: 16, right: 16 })
    .border({ width: { top: 0.5 }, color: '#EEE' });
  }

  @Builder
  ScheduleTab() {
    Scroll() {
      Column({ space: 16 }) {
        this.ScheduleHeader();
        this.ScheduleFormCard();
        this.DoctorListPreview();
      }
      .width('100%')
      .padding(16);
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring);
  }

  @Builder
  ScheduleHeader() {
    Row() {
      Column({ space: 4 }) {
        Text('放号管理')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A2E');
        Text('为医生设置排班和号源，支持上午/下午/晚上三个时段')
          .fontSize(12)
          .fontColor('#888');
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1);

      Text(`可分配 ${this.doctors.length} 位医生`)
        .fontSize(12)
        .fontColor(PRIMARY)
        .backgroundColor(PRIMARY + '12')
        .padding({ left: 10, right: 10, top: 5, bottom: 5 })
        .borderRadius(10);
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(14)
    .linearGradient({
      angle: 135,
      colors: [['#FFFFFF', 0], ['#F0F5FF', 1]]
    });
  }

  @Builder
  ScheduleFormCard() {
    Column({ space: 16 }) {
      Text('新增排班')
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1A1A2E')
        .width('100%');

      Column({ space: 6 }) {
        Text('选择医生 *')
          .fontSize(12)
          .fontColor('#666')
          .width('100%');

        if (this.doctors.length === 0) {
          Text('暂无医生数据，无法放号')
            .fontSize(13)
            .fontColor('#999')
            .width('100%')
            .height(44)
            .textAlign(TextAlign.Center)
            .backgroundColor('#F5F7FA')
            .borderRadius(8);
        } else {
          Row() {
            Text(this.scheduleDoctorId
              ? (this.doctors.find((d: DoctorOption) => d.id === this.scheduleDoctorId)?.realName || '请选择')
              : '请选择医生')
              .fontSize(14)
              .fontColor(this.scheduleDoctorId ? '#333' : '#BBB')
              .layoutWeight(1);

            Text('▼').fontSize(12).fontColor('#999').margin({ left: 8 });
          }
          .width('100%')
          .height(44)
          .padding({ left: 14, right: 14 })
          .backgroundColor('#F5F7FA')
          .borderRadius(8)
          .border({ width: 1, color: this.scheduleDoctorId ? PRIMARY : '#E0E0E0' })
          .onClick(() => { this.showSchedulePanel = !this.showSchedulePanel; });
        }
      }

      if (this.showSchedulePanel && this.doctors.length > 0) {
        Column({ space: 2 }) {
          ForEach(this.doctors, (doc: DoctorOption) => {
            Row() {
              Text(doc.realName)
                .fontSize(13)
                .fontColor(this.scheduleDoctorId === doc.id ? PRIMARY : '#333')
                .fontWeight(this.scheduleDoctorId === doc.id ? FontWeight.Bold : FontWeight.Normal)
                .layoutWeight(1);

              Text(doc.department)
                .fontSize(11)
                .fontColor('#AAA');

              if (this.scheduleDoctorId === doc.id) {
                Text('✓').fontSize(14).fontColor(PRIMARY).margin({ left: 6 });
              }
            }
            .width('100%')
            .padding({ left: 14, right: 14, top: 10, bottom: 10 })
            .backgroundColor(this.scheduleDoctorId === doc.id ? PRIMARY + '0A' : '#FAFAFA')
            .borderRadius(8)
            .onClick(() => { this.scheduleDoctorId = doc.id; this.showSchedulePanel = false; });
          }, (doc: DoctorOption) => `${doc.id}`);
        }
        .width('100%')
        .constraintSize({ maxHeight: 180 })
        .border({ width: 1, color: '#EEE', style: BorderStyle.Solid })
        .borderRadius(8);
      }

      Column({ space: 6 }) {
        Text('排班日期 *')
          .fontSize(12)
          .fontColor('#666')
          .width('100%');
        TextInput({ placeholder: 'YYYY-MM-DD', text: this.scheduleDate })
          .height(44)
          .fontSize(14)
          .backgroundColor('#F5F7FA')
          .borderRadius(8)
          .padding({ left: 14 })
          .onChange((v: string) => { this.scheduleDate = v; });
      }

      Column({ space: 6 }) {
        Text('时段 *')
          .fontSize(12)
          .fontColor('#666')
          .width('100%');
        Row({ space: 8 }) {
          this.PeriodButton('上午 8:00-12:00', 1);
          this.PeriodButton('下午 14:00-18:00', 2);
          this.PeriodButton('晚上 19:00-21:00', 3);
        }
      }

      Column({ space: 6 }) {
        Text(`号源数量 (${this.scheduleMaxCount})`)
          .fontSize(12)
          .fontColor('#666')
          .width('100%');

        Row({ space: 12 }) {
          Button({ type: ButtonType.Normal }) {
            Text('-').fontSize(18).fontColor(PRIMARY).fontWeight(FontWeight.Bold);
          }
            .width(38).height(38)
            .backgroundColor('#F0F5FF')
            .borderRadius(8)
            .enabled(this.scheduleMaxCount > 1)
            .onClick(() => { if (this.scheduleMaxCount > 1) this.scheduleMaxCount--; });

          Text(`${this.scheduleMaxCount}`)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1A1A2E')
            .width(50)
            .textAlign(TextAlign.Center);

          Button({ type: ButtonType.Normal }) {
            Text('+').fontSize(18).fontColor('#FFF').fontWeight(FontWeight.Bold);
          }
            .width(38).height(38)
            .backgroundColor(PRIMARY)
            .borderRadius(8)
            .enabled(this.scheduleMaxCount < 99)
            .onClick(() => { if (this.scheduleMaxCount < 99) this.scheduleMaxCount++; });

          Blank();

          Text('个号源')
            .fontSize(13)
            .fontColor('#888');
        }
        .width('100%')
        .alignItems(VerticalAlign.Center);
      }

      Button(this.scheduleLoading ? '提交中...' : '确认放号')
        .width('100%')
        .height(46)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .linearGradient(this.scheduleLoading
          ? { angle: 90, colors: [['#AAC', 0], ['#99B', 1]] }
          : { angle: 135, colors: [[PRIMARY, 0], ['#69B1FF', 1]] })
        .borderRadius(12)
        .enabled(!this.scheduleLoading)
        .onClick(() => this.addSchedule());
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(14)
    .shadow({ radius: 12, color: '#0000000A', offsetX: 0, offsetY: 4 });
  }

  @Builder
  PeriodButton(label: string, period: number) {
    Text(label)
      .fontSize(12)
      .fontColor(this.schedulePeriod === period ? '#FFFFFF' : '#555')
      .padding({ left: 14, right: 14, top: 8, bottom: 8 })
      .borderRadius(8)
      .backgroundColor(this.schedulePeriod === period ? PRIMARY : '#F5F5F5')
      .onClick(() => { this.schedulePeriod = period; });
  }

  @Builder
  DoctorListPreview() {
    Column({ space: 12 }) {
      Row() {
        Text('可用医生列表')
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A2E');
        Blank();
        Text(`共 ${this.doctors.length} 位`)
          .fontSize(12)
          .fontColor('#999');
      }
      .width('100%');

      if (this.doctors.length === 0) {
        Column({ space: 8 }) {
          Text('📭').fontSize(36);
          Text('暂无医生数据')
            .fontSize(13)
            .fontColor('#AAA');
          Text('请先在系统中添加医生信息')
            .fontSize(11)
            .fontColor('#CCC');
        }
        .width('100%')
        .padding(30)
        .backgroundColor('#FAFAFA')
        .borderRadius(10)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center);
      } else {
        Column({ space: 6 }) {
          ForEach(this.getPagedDoctors(), (doc: DoctorOption) => {
            Row({ space: 10 }) {
              Column() {
                Text(String(doc.realName.charAt(0)))
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                  .width(34)
                  .height(34)
                  .borderRadius(10)
                  .backgroundColor(PRIMARY);
              }
              .width(34)
              .height(34)
              .justifyContent(FlexAlign.Center);

              Column({ space: 2 }) {
                Text(doc.realName)
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#333');
                Text(`${doc.department} · ${doc.hospital}`)
                  .fontSize(11)
                  .fontColor('#AAA')
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis });
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1);

              Text('ID:' + doc.id)
                .fontSize(11)
                .fontColor('#CCC');
            }
            .width('100%')
            .padding(12)
            .backgroundColor('#FAFAFA')
            .borderRadius(10);
          }, (doc: DoctorOption) => `${doc.id}`);
        }

        Row({ space: 10 }) {
          Button({ type: ButtonType.Normal }) {
            Text('◀ 上一页').fontSize(12);
          }
          .height(34)
          .fontSize(12)
          .padding({ left: 14, right: 14 })
          .backgroundColor(this.doctorCurrentPage > 1 ? PRIMARY : '#E8ECF2')
          .fontColor(this.doctorCurrentPage > 1 ? '#FFF' : '#BBB')
          .borderRadius(8)
          .enabled(this.doctorCurrentPage > 1)
          .onClick(() => {
            if (this.doctorCurrentPage > 1) {
              this.doctorCurrentPage--;
            }
          });

          Text(`${this.doctorCurrentPage} / ${this.getDoctorTotalPages()}`)
            .fontSize(13)
            .fontColor('#666')
            .width(60)
            .textAlign(TextAlign.Center);

          Button({ type: ButtonType.Normal }) {
            Text('下一页 ▶').fontSize(12);
          }
          .height(34)
          .fontSize(12)
          .padding({ left: 14, right: 14 })
          .backgroundColor(this.doctorCurrentPage < this.getDoctorTotalPages() ? PRIMARY : '#E8ECF2')
          .fontColor(this.doctorCurrentPage < this.getDoctorTotalPages() ? '#FFF' : '#BBB')
          .borderRadius(8)
          .enabled(this.doctorCurrentPage < this.getDoctorTotalPages())
          .onClick(() => {
            if (this.doctorCurrentPage < this.getDoctorTotalPages()) {
              this.doctorCurrentPage++;
            }
          });
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ top: 8 });
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(14);
  }

  @Builder
  DetailModal() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#00000055')
        .onClick(() => { this.showDetailModal = false; });

      Column({ space: 16 }) {
        Row() {
          Text('用户详情')
            .fontSize(17)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1A1A2E');
          Blank();
          Button({ type: ButtonType.Normal }) {
            Text('✕').fontSize(16).fontColor('#999');
          }
          .width(32).height(32)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .onClick(() => { this.showDetailModal = false; });
        }
        .width('100%');

        Column({ space: 12 }) {
          this.InfoRow('用户ID', String(this.selectedUser!.id));
          this.InfoRow('用户名', this.selectedUser!.username);
          this.InfoRow('手机号', this.selectedUser!.phone || '-');
          this.InfoRow('年龄', this.selectedUser!.age != null ? `${this.selectedUser!.age}岁` : '-');
          this.InfoRow('身份证', this.selectedUser!.idCard || '-');
          this.InfoRow('用户类型', this.getUserTypeName(this.selectedUser!.userType), this.getUserTypeColor(this.selectedUser!.userType));
          this.InfoRow('注册时间', this.formatTime(this.selectedUser!.createTime));
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#F8FAFC')
        .borderRadius(12);

        Button('关闭')
          .width('100%')
          .height(42)
          .fontSize(15)
          .backgroundColor('#F0F0F0')
          .fontColor('#555')
          .borderRadius(10)
          .onClick(() => { this.showDetailModal = false; });
      }
      .width('88%')
      .padding(20)
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
      .shadow({ radius: 24, color: '#00000025', offsetX: 0, offsetY: 8 });
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 });
  }

  @Builder
  InfoRow(label: string, value: string, valueColor?: string) {
    Row() {
      Text(label)
        .fontSize(13)
        .fontColor('#888')
        .width(80);
      Text(value)
        .fontSize(13)
        .fontColor(valueColor || '#333')
        .fontWeight(FontWeight.Medium)
        .layoutWeight(1);
    }
    .width('100%')
    .alignItems(VerticalAlign.Top);
  }
}
