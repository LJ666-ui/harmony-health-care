import { router } from '@kit.ArkUI';
import { http } from '@kit.NetworkKit';
import { Header } from '../components/Header';
import { GlobalTheme } from '../global';
import { ApiConstants } from '../common/constants/ApiConstants';

class NurseScheduleItem {
  id: number = 0;
  nurseId: number = 0;
  nurseName: string = '';
  department: string = '';
  scheduleDate: string = '';
  shiftType: number = 0;
  wardArea: string = '';
  bedCount: number = 0;
  patientIds: string = '';
  status: number = 0;
  remark: string = '';
}

class DepartmentInfo {
  department: string = '';
  nurseCount: number = 0;
  totalPatients: number = 0;
}

class DailyOverview {
  date: string = '';
  totalCount: number = 0;
  shiftStats: Map<string, number> = new Map<string, number>();
  departments: DepartmentInfo[] = [];
  schedules: NurseScheduleItem[] = [];
}

class DayScheduleItem {
  date: string = '';
  weekday: string = '';
  schedules: NurseScheduleItem[] = [];
  hasWork: boolean = false;
  shiftText: string = '';
  wardAreas: string = '';
}

class WeeklySchedule {
  nurseId: number = 0;
  weekStart: string = '';
  schedule: DayScheduleItem[] = [];
}

@Entry
@Component
struct NurseSchedulePage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @StorageLink('nurseInfo') nurseInfo: object | null = null;

  @State currentView: 'daily' | 'weekly' = 'daily';
  @State loading: boolean = false;
  @State dailyOverview: DailyOverview | null = null;
  @State weeklySchedule: WeeklySchedule | null = null;
  @State selectedDate: Date = new Date();
  @State selectedShift: number = -1;
  @State filteredSchedules: NurseScheduleItem[] = [];
  @State useMockData: boolean = false;
  @State errorMessage: string = '';

  private baseUrl: string = `${ApiConstants.BASE_URL}/api/nurse/schedule`;

  aboutToAppear(): void {
    this.loadData();
  }

  async loadData(): Promise<void> {
    this.loading = true;
    this.errorMessage = '';
    this.useMockData = false;
    
    try {
      await this.loadDailyOverviewFromNetwork();
      await this.loadWeeklyScheduleFromNetwork();
      this.updateFilteredSchedules();
    } catch (error) {
      console.error('Load data error:', error);
      this.errorMessage = '连接后端服务失败，请确保数据库已初始化于护士排班数据';
      console.error('提示: 请执行 init-yu-nurse-schedule.sql 初始化数据');
    } finally {
      this.loading = false;
    }
  }

  private getShortShiftName(shiftType: number): string {
    switch (shiftType) {
      case 1: return '\u65E9\u73ED';
      case 2: return '\u4E2D\u73ED';
      case 3: return '\u591C\u73ED';
      default: return '\u672A\u77E5';
    }
  }

  async loadDailyOverviewFromNetwork(): Promise<void> {
    const nurseToken: string | undefined = AppStorage.get<string>('nurseToken');
    const header: Record<string, string> = {
      'Content-Type': 'application/json'
    };
    if (nurseToken && nurseToken.length > 0) {
      header['Token'] = nurseToken;
    }
    
    const response: http.HttpResponse = await http.createHttp().request(
      `${this.baseUrl}/daily?date=${this.formatDate(this.selectedDate)}`,
      {
        method: http.RequestMethod.GET,
        header: header,
        connectTimeout: 5000,
        readTimeout: 5000
      }
    );
    
    if (response.responseCode === 200) {
      const resultObj: Record<string, Object> = JSON.parse(response.result as string) as Record<string, Object>;
      if (resultObj['code'] === 200 && resultObj['data'] !== undefined) {
        const data: Record<string, Object> = resultObj['data'] as Record<string, Object>;
        this.dailyOverview = this.parseDailyOverview(data);
      } else {
        throw new Error('Invalid response format');
      }
    } else {
      throw new Error(`HTTP ${response.responseCode}`);
    }
  }

  async loadWeeklyScheduleFromNetwork(): Promise<void> {
    const nurseId: number = this.getNurseId();
    if (nurseId <= 0) {
      return;
    }
    
    const nurseToken: string | undefined = AppStorage.get<string>('nurseToken');
    const header: Record<string, string> = {
      'Content-Type': 'application/json'
    };
    if (nurseToken && nurseToken.length > 0) {
      header['Token'] = nurseToken;
    }
    
    const response: http.HttpResponse = await http.createHttp().request(
      `${this.baseUrl}/weekly/${nurseId}`,
      {
        method: http.RequestMethod.GET,
        header: header,
        connectTimeout: 5000,
        readTimeout: 5000
      }
    );
    
    if (response.responseCode === 200) {
      const resultObj: Record<string, Object> = JSON.parse(response.result as string) as Record<string, Object>;
      if (resultObj['code'] === 200 && resultObj['data'] !== undefined) {
        const data: Record<string, Object> = resultObj['data'] as Record<string, Object>;
        this.weeklySchedule = this.parseWeeklySchedule(data);
      } else {
        throw new Error('Invalid response format');
      }
    } else {
      throw new Error(`HTTP ${response.responseCode}`);
    }
  }

  private formatDate(date: Date): string {
    const year: number = date.getFullYear();
    const month: string = String(date.getMonth() + 1).padStart(2, '0');
    const day: string = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  private getNurseId(): number {
    if (this.nurseInfo == null) {
      return 0;
    }
    const info: Record<string, Object> = this.nurseInfo as Record<string, Object>;
    const idVal: Object | undefined = info['id'];
    if (idVal === undefined) {
      return 0;
    }
    return idVal as number;
  }

  private getNurseName(): string {
    if (this.nurseInfo == null) {
      return '-';
    }
    const info: Record<string, Object> = this.nurseInfo as Record<string, Object>;
    const nameVal: Object | undefined = info['name'];
    if (nameVal === undefined) {
      return '-';
    }
    return nameVal as string;
  }

  private parseDailyOverview(data: Record<string, Object>): DailyOverview {
    const overview: DailyOverview = new DailyOverview();
    
    if (data['date'] !== undefined) {
      overview.date = data['date'] as string;
    }
    if (data['totalCount'] !== undefined) {
      overview.totalCount = data['totalCount'] as number;
    }
    
    if (data['shiftStats'] !== undefined) {
      const stats: Record<string, Object> = data['shiftStats'] as Record<string, Object>;
      const keys: string[] = Object.keys(stats);
      for (let i: number = 0; i < keys.length; i++) {
        const key: string = keys[i];
        overview.shiftStats.set(key, stats[key] as number);
      }
    }
    
    if (data['departments'] !== undefined) {
      const deptArray: Object[] = data['departments'] as Object[];
      deptArray.forEach((item: Object) => {
        const dept: Record<string, Object> = item as Record<string, Object>;
        const deptInfo: DepartmentInfo = new DepartmentInfo();
        if (dept['department'] !== undefined) {
          deptInfo.department = dept['department'] as string;
        }
        if (dept['nurseCount'] !== undefined) {
          deptInfo.nurseCount = dept['nurseCount'] as number;
        }
        if (dept['totalPatients'] !== undefined) {
          deptInfo.totalPatients = dept['totalPatients'] as number;
        }
        overview.departments.push(deptInfo);
      });
    }
    
    if (data['schedules'] !== undefined) {
      const schedArray: Object[] = data['schedules'] as Object[];
      schedArray.forEach((item: Object) => {
        overview.schedules.push(this.parseScheduleItem(item));
      });
    }
    
    return overview;
  }

  private parseScheduleItem(item: Object): NurseScheduleItem {
    const schedule: NurseScheduleItem = new NurseScheduleItem();
    const record: Record<string, Object> = item as Record<string, Object>;
    
    if (record['id'] !== undefined) schedule.id = record['id'] as number;
    if (record['nurseId'] !== undefined) schedule.nurseId = record['nurseId'] as number;
    if (record['nurseName'] !== undefined) schedule.nurseName = record['nurseName'] as string;
    if (record['department'] !== undefined) schedule.department = record['department'] as string;
    if (record['scheduleDate'] !== undefined) schedule.scheduleDate = record['scheduleDate'] as string;
    if (record['shiftType'] !== undefined) schedule.shiftType = record['shiftType'] as number;
    if (record['wardArea'] !== undefined) schedule.wardArea = record['wardArea'] as string;
    if (record['bedCount'] !== undefined) schedule.bedCount = record['bedCount'] as number;
    if (record['patientIds'] !== undefined) schedule.patientIds = record['patientIds'] as string;
    if (record['status'] !== undefined) schedule.status = record['status'] as number;
    if (record['remark'] !== undefined) schedule.remark = record['remark'] as string;
    
    return schedule;
  }

  private parseWeeklySchedule(data: Record<string, Object>): WeeklySchedule {
    const ws: WeeklySchedule = new WeeklySchedule();
    
    if (data['nurseId'] !== undefined) {
      ws.nurseId = data['nurseId'] as number;
    }
    if (data['weekStart'] !== undefined) {
      ws.weekStart = data['weekStart'] as string;
    }
    
    if (data['schedule'] !== undefined) {
      const schedArray: Object[] = data['schedule'] as Object[];
      schedArray.forEach((item: Object) => {
        ws.schedule.push(this.parseDayScheduleItem(item));
      });
    }
    
    return ws;
  }

  private parseDayScheduleItem(item: Object): DayScheduleItem {
    const day: DayScheduleItem = new DayScheduleItem();
    const record: Record<string, Object> = item as Record<string, Object>;
    
    if (record['date'] !== undefined) day.date = record['date'] as string;
    if (record['weekday'] !== undefined) day.weekday = record['weekday'] as string;
    if (record['hasWork'] !== undefined) day.hasWork = record['hasWork'] as boolean;
    if (record['shiftText'] !== undefined) day.shiftText = record['shiftText'] as string;
    if (record['wardArea'] !== undefined) day.wardAreas = record['wardArea'] as string;
    
    if (record['schedules'] !== undefined) {
      const schedArray: Object[] = record['schedules'] as Object[];
      schedArray.forEach((sched: Object) => {
        day.schedules.push(this.parseScheduleItem(sched));
      });
    }
    
    return day;
  }

  private updateFilteredSchedules(): void {
    if (this.dailyOverview === null) {
      this.filteredSchedules = [];
      return;
    }
    
    let schedules: NurseScheduleItem[] = this.dailyOverview.schedules;
    if (this.selectedShift >= 1) {
      schedules = schedules.filter((s: NurseScheduleItem) => s.shiftType === this.selectedShift);
    }
    this.filteredSchedules = schedules;
  }

  private onShiftFilterChange(shiftType: number): void {
    if (this.selectedShift === shiftType) {
      this.selectedShift = -1;
    } else {
      this.selectedShift = shiftType;
    }
    this.updateFilteredSchedules();
  }

  private getShiftName(shiftType: number): string {
    switch (shiftType) {
      case 1: return '\u65E9\u73ED(07:00-15:00)';
      case 2: return '\u4E2D\u73ED(15:00-23:00)';
      case 3: return '\u591C\u73ED(23:00-07:00)';
      default: return '\u672A\u77E5';
    }
  }

  private getShiftColor(shiftType: number): string {
    switch (shiftType) {
      case 1: return '#3498DB';
      case 2: return '#F39C12';
      case 3: return '#9B59B6';
      default: return '#95A5A6';
    }
  }

  private getStatusText(status: number): string {
    switch (status) {
      case 0: return '\u8BF7\u5047/\u8C03\u4F11';
      case 1: return '\u6B63\u5E38';
      case 2: return '\u66FF\u73ED';
      case 3: return '\u52A0\u73ED';
      default: return '\u672A\u77E5';
    }
  }

  private getStatusColor(status: number): string {
    switch (status) {
      case 0: return '#95A5A6';
      case 1: return '#2ECC71';
      case 2: return '#3498DB';
      case 3: return '#E74C3C';
      default: return '#95A5A6';
    }
  }

  private changeDate(days: number): void {
    const newDate: Date = new Date(this.selectedDate.getTime());
    newDate.setDate(newDate.getDate() + days);
    this.selectedDate = newDate;

    this.loadDailyOverviewFromNetwork()
      .then(() => this.updateFilteredSchedules())
      .catch((error: Error) => {
        console.error('Date change error:', error);
        this.errorMessage = '加载失败，请重试';
      });
  }

  build() {
    Column() {
      Header({ title: '\u6392\u73ED\u67E5\u770B' })

      if (this.loading) {
        Column() {
          LoadingProgress()
            .width(50)
            .height(50)
            .color(GlobalTheme.THEME_COLOR)
          Text('\u52A0\u8F7D\u4E2D...')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 10 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.errorMessage.length > 0 && this.dailyOverview === null) {
        Column() {
          Text(this.errorMessage)
            .fontSize(16)
            .fontColor('#FF6B6B')
          Button('\u91CD\u8BD5')
            .fontSize(14)
            .margin({ top: 20 })
            .onClick(() => this.loadData())
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: 12 }) {
            this.ViewToggleSection()
            
            if (this.currentView === 'daily') {
              this.DailyViewSection()
            } else {
              this.WeeklyViewSection()
            }
          }
          .width('100%')
          .padding(16)
        }
        .layoutWeight(1)
        .width('100%')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder ViewToggleSection() {
    Row() {
      Row() {
        Text(this.currentView === 'daily' ? '\u{1F4C5}' : '')
          .fontSize(18)
          .margin({ right: 6 })
        Text('\u65E5\u89C6\u56FE')
          .fontSize(this.currentView === 'daily' ? 16 : 14)
          .fontWeight(this.currentView === 'daily' ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(this.currentView === 'daily' ? GlobalTheme.THEME_COLOR : '#666666')
      }
      .padding(10)
      .backgroundColor(this.currentView === 'daily' ? '#E8F4FD' : '#FFFFFF')
      .borderRadius(8)
      .onClick(() => { this.currentView = 'daily' })

      Row() {
        Text(this.currentView === 'weekly' ? '\u{1F4C6}' : '')
          .fontSize(18)
          .margin({ right: 6 })
        Text('\u5468\u89C6\u56FE')
          .fontSize(this.currentView === 'weekly' ? 16 : 14)
          .fontWeight(this.currentView === 'weekly' ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(this.currentView === 'weekly' ? GlobalTheme.THEME_COLOR : '#666666')
      }
      .padding(10)
      .backgroundColor(this.currentView === 'weekly' ? '#E8F4FD' : '#FFFFFF')
      .borderRadius(8)
      .onClick(() => { this.currentView = 'weekly' })

      Blank()

      Text(`\u62A4\u58EB: ${this.getNurseName()}`)
        .fontSize(14)
        .fontColor('#666666')
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
  }

  @Builder DailyViewSection() {
    Column({ space: 12 }) {
      this.DateSelectorSection()

      if (this.dailyOverview !== null) {
        this.StatsCardsSection()
        this.ShiftFilterSection()
        this.ScheduleListSection()
      }
    }
    .width('100%')
  }

  @Builder DateSelectorSection() {
    Row() {
      Button('<')
        .fontSize(16)
        .width(40)
        .height(36)
        .backgroundColor('#F0F0F0')
        .fontColor('#333333')
        .onClick(() => this.changeDate(-1))

      Column() {
        Text(this.formatDate(this.selectedDate))
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')

        Text(this.getWeekDayText(this.selectedDate))
          .fontSize(12)
          .fontColor('#999999')
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)

      Button('\u4ECA\u5929')
        .fontSize(13)
        .height(32)
        .backgroundColor('#E8F4FD')
        .fontColor(GlobalTheme.THEME_COLOR)
        .margin({ right: 8 })
        .onClick(() => {
          this.selectedDate = new Date();
          this.loadDailyOverviewFromNetwork()
            .then(() => this.updateFilteredSchedules())
            .catch((error: Error) => {
              console.error('Today button error:', error);
              this.errorMessage = '加载失败，请重试';
            });
        })

      Button('>')
        .fontSize(16)
        .width(40)
        .height(36)
        .backgroundColor('#F0F0F0')
        .fontColor('#333333')
        .onClick(() => this.changeDate(1))
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
  }

  @Builder StatsCardsSection() {
    Row({ space: 10 }) {
      ForEach(Array.from(this.dailyOverview!.shiftStats.entries()), (entry: [string, number]) => {
        Column() {
          Text(`${entry[1]}`)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
          Text(entry[0].split('(')[0])
            .fontSize(11)
            .fontColor('#999999')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .padding(12)
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .alignItems(HorizontalAlign.Center)
      })
    }
    .width('100%')
  }

  @Builder ShiftFilterSection() {
    Scroll() {
      Row({ space: 8 }) {
        Text('\u5168\u90E8')
          .fontSize(13)
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .borderRadius(16)
          .backgroundColor(this.selectedShift < 0 ? GlobalTheme.THEME_COLOR : '#F0F0F0')
          .fontColor(this.selectedShift < 0 ? '#FFFFFF' : '#666666')
          .onClick(() => { this.selectedShift = -1; this.updateFilteredSchedules(); })

        Text('\u65E9\u73ED')
          .fontSize(13)
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .borderRadius(16)
          .backgroundColor(this.selectedShift === 1 ? '#3498DB' : '#F0F0F0')
          .fontColor(this.selectedShift === 1 ? '#FFFFFF' : '#666666')
          .onClick(() => this.onShiftFilterChange(1))

        Text('\u4E2D\u73ED')
          .fontSize(13)
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .borderRadius(16)
          .backgroundColor(this.selectedShift === 2 ? '#F39C12' : '#F0F0F0')
          .fontColor(this.selectedShift === 2 ? '#FFFFFF' : '#666666')
          .onClick(() => this.onShiftFilterChange(2))

        Text('\u591C\u73ED')
          .fontSize(13)
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .borderRadius(16)
          .backgroundColor(this.selectedShift === 3 ? '#9B59B6' : '#F0F0F0')
          .fontColor(this.selectedShift === 3 ? '#FFFFFF' : '#666666')
          .onClick(() => this.onShiftFilterChange(3))
      }
    }
    .scrollable(ScrollDirection.Horizontal)
    .width('100%')
  }

  @Builder ScheduleListSection() {
    Column() {
      Text('\u6392\u73ED\u8BE6\u60C5')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .width('100%')
        .margin({ bottom: 12 })

      if (this.filteredSchedules.length === 0) {
        Column() {
          Text('\u6682\u65E0\u6392\u73ED\u6570\u636E')
            .fontSize(14)
            .fontColor('#999999')
        }
        .width('100%')
        .height(120)
        .justifyContent(FlexAlign.Center)
      } else {
        List() {
          ForEach(this.filteredSchedules, (schedule: NurseScheduleItem, index: number) => {
            ListItem() {
              this.ScheduleCard(schedule)
            }
          }, (schedule: NurseScheduleItem) => `${schedule.id}`)
        }
        .divider({ strokeWidth: 1, color: '#F0F0F0' })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
  }

  @Builder ScheduleCard(schedule: NurseScheduleItem) {
    Column() {
      Row() {
        Text(this.getShiftName(schedule.shiftType))
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.getShiftColor(schedule.shiftType))

        Blank()

        Text(this.getStatusText(schedule.status))
          .fontSize(11)
          .fontColor('#FFFFFF')
          .padding({ left: 8, right: 8, top: 3, bottom: 3 })
          .borderRadius(10)
          .backgroundColor(this.getStatusColor(schedule.status))
      }
      .width('100%')
      .margin({ bottom: 10 })

      Row() {
        this.InfoItem('\u62A4\u58EB', schedule.nurseName || '-')
        this.InfoItem('\u79D1\u5BA4', schedule.department || '-')
        this.InfoItem('\u75C5\u533A', schedule.wardArea || '-')
      }
      .width('100%')
      .margin({ bottom: 8 })

      Row() {
        this.InfoItem('\u8D1F\u8D23\u5E8A\u4F4D', `${schedule.bedCount || 0}\u5F20`)
        this.InfoItem('\u8D1F\u8D23\u60A3\u8005', `${this.getPatientCount(schedule.patientIds)}\u4EBA`)
      }
      .width('100%')

      if (schedule.remark && schedule.remark.length > 0) {
        Text(`\u5907\u6CE8: ${schedule.remark}`)
          .fontSize(12)
          .fontColor('#F39C12')
          .width('100%')
          .margin({ top: 8 })
          .padding(8)
          .backgroundColor('#FFF9E6')
          .borderRadius(4)
      }
    }
    .width('100%')
    .padding(14)
    .backgroundColor('#FAFAFA')
    .borderRadius(8)
  }

  @Builder InfoItem(label: string, value: string) {
    Column() {
      Text(value)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
      Text(label)
        .fontSize(10)
        .fontColor('#999999')
        .margin({ top: 2 })
    }
    .alignItems(HorizontalAlign.Start)
    .margin({ right: 20 })
  }

  @Builder WeeklyViewSection() {
    Column({ space: 12 }) {
      if (this.weeklySchedule !== null) {
        Text(`\u672C\u5468\u6392\u73ED (${this.weeklySchedule!.weekStart} \u8D77)`)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .width('100%')
          .margin({ bottom: 8 })

        Grid() {
          ForEach(this.weeklySchedule!.schedule, (day: DayScheduleItem, index: number) => {
            GridItem() {
              Column() {
                Text(day.weekday || '')
                  .fontSize(12)
                  .fontColor('#999999')

                Text(day.date ? day.date.substring(5) : '')
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(day.hasWork ? '#333333' : '#CCCCCC')
                  .margin({ top: 4 })

                if (day.hasWork) {
                  Text(day.shiftText || '')
                    .fontSize(11)
                    .fontColor(GlobalTheme.THEME_COLOR)
                    .margin({ top: 6 })
                    .padding({ left: 6, right: 6, top: 3, bottom: 3 })
                    .backgroundColor('#E8F4FD')
                    .borderRadius(4)

                  Text(day.wardAreas || '')
                    .fontSize(10)
                    .fontColor('#666666')
                    .margin({ top: 4 })
                } else {
                  Text('\u4F11\u606F')
                    .fontSize(11)
                    .fontColor('#999999')
                    .margin({ top: 6 })
                }
              }
              .width('100%')
              .height('100%')
              .padding(10)
              .backgroundColor(day.hasWork ? '#FFFFFF' : '#F9F9F9')
              .borderRadius(8)
              .border({ width: day.hasWork ? 1 : 0, color: '#E8F4FD' })
            }
          }, (day: DayScheduleItem) => day.date)
        }
        .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr')
        .rowsTemplate('1fr')
        .columnsGap(8)
        .rowsGap(8)
        .width('100%')
        .height(140)

        this.WeeklyDetailList()
      } else {
        Column() {
          Text('\u6682\u65E0\u5468\u6392\u73ED\u6570\u636E')
            .fontSize(14)
            .fontColor('#999999')
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
  }

  @Builder WeeklyDetailList() {
    Column() {
      Text('\u8BE6\u7EC6\u6392\u73ED\u5217\u8868')
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .width('100%')
        .margin({ bottom: 10 })

      List() {
        ForEach(this.getWorkingDays(), (day: DayScheduleItem, index: number) => {
          ListItem() {
            Column() {
              Row() {
                Text(`${day.date} ${day.weekday}`)
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#333333')
                Blank()
                Text(day.shiftText)
                  .fontSize(12)
                  .fontColor(GlobalTheme.THEME_COLOR)
              }
              .width('100%')
              .margin({ bottom: 8 })

              ForEach(day.schedules, (schedule: NurseScheduleItem, sIndex: number) => {
                Row() {
                  Text(`${schedule.nurseName} - ${schedule.department}`)
                    .fontSize(12)
                    .fontColor('#666666')
                  Blank()
                  Text(`${schedule.wardArea} | ${schedule.bedCount}\u5E8A`)
                    .fontSize(11)
                    .fontColor('#999999')
                }
                .width('100%')
                .padding({ top: 4, bottom: 4 })
              }, (schedule: NurseScheduleItem) => `${schedule.id}_${schedule.shiftType}`)
            }
            .width('100%')
            .padding(12)
            .backgroundColor('#FAFAFA')
            .borderRadius(6)
          }
        }, (day: DayScheduleItem) => day.date)
      }
      .divider({ strokeWidth: 1, color: '#F0F0F0' })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
  }

  private getWorkingDays(): DayScheduleItem[] {
    if (this.weeklySchedule === null) {
      return [];
    }
    return this.weeklySchedule.schedule.filter((d: DayScheduleItem) => d.hasWork);
  }

  private getPatientCount(patientIds: string): number {
    if (!patientIds || patientIds.length === 0) {
      return 0;
    }
    return patientIds.split(',').length;
  }

  private getWeekDayText(date: Date): string {
    const days: string[] = ['\u5468\u65E5', '\u5468\u4E00', '\u5468\u4E8C', '\u5468\u4E09', '\u5468\u56DB', '\u5468\u4E94', '\u5468\u516D'];
    return days[date.getDay()];
  }
}
