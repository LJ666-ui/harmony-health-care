import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { ButtonWithFeedback } from '../components/ClickFeedback';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import { ToastUtil } from '../common/utils/ToastUtil';
import { GlobalTheme } from '../global';

class HospitalItem {
  id: string = '';
  name: string = '';
  department: string = '';

  constructor(id: string = '', name: string = '', department: string = '') {
    this.id = id;
    this.name = name;
    this.department = department;
  }
}

class DepartmentItem {
  id: string = '';
  hospitalId: string = '';
  deptName: string = '';

  constructor(id: string = '', hospitalId: string = '', deptName: string = '') {
    this.id = id;
    this.hospitalId = hospitalId;
    this.deptName = deptName;
  }
}

@Entry
@Component
struct AddAppointmentPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State selectedHospitalId: string = '';
  @State selectedHospitalName: string = '';
  @State selectedDeptId: string = '';
  @State selectedDeptName: string = '';
  @State selectedDate: string = '';
  @State selectedTimeSlot: string = '';
  @State errorMessage: string = '';
  @State showSuccessDialog: boolean = false;
  @State appointmentNo: string = '';

  @State hospitalList: HospitalItem[] = [];
  @State departmentList: DepartmentItem[] = [];
  @State isLoading: boolean = false;

  private dates: string[] = [];
  private timeSlots: string[] = ['上午', '下午'];

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') || false;
    }

    const today = new Date();
    for (let i = 0; i < 7; i++) {
      const date = new Date(today);
      date.setDate(today.getDate() + i);
      this.dates.push('' + date.getFullYear() + '-' + this.padZero(date.getMonth() + 1) + '-' + this.padZero(date.getDate()));
    }
    if (this.dates.length > 0) {
      this.selectedDate = this.dates[0];
    }
    this.selectedTimeSlot = this.timeSlots[0];

    this.loadHospitals();
  }

  async loadHospitals(): Promise<void> {
    this.isLoading = true;
    try {
      const response: BaseResponse<Object> = await HttpUtil.get<Object>(ApiConstants.HOSPITAL_LIST);
      if (response.success && response.data && Array.isArray(response.data)) {
        const dataArr = response.data as Object[];
        const list: HospitalItem[] = [];
        for (let i = 0; i < dataArr.length; i++) {
          const item = dataArr[i] as Record<string, Object>;
          if (item && typeof item === 'object') {
            list.push(new HospitalItem(
              String(item['id'] || ''),
              (item['name'] as string) || '',
              (item['department'] as string) || ''
            ));
          }
        }
        this.hospitalList = list;
        if (list.length === 0) {
          ToastUtil.showError('暂无医院数据');
        }
      } else {
        console.error('[预约] 加载医院列表失败:', response.message);
        this.hospitalList = [];
        ToastUtil.showError('加载医院失败');
      }
    } catch (e) {
      console.error('[预约] 加载医院异常:', e);
      this.hospitalList = [];
      ToastUtil.showError('网络异常，请检查后端服务是否启动');
    } finally {
      this.isLoading = false;
    }
  }

  async loadDepartments(hospitalId: string): Promise<void> {
    try {
      const deptParams: Record<string, string> = { 'hospitalId': hospitalId };
      const response: BaseResponse<Object> = await HttpUtil.get<Object>(ApiConstants.HOSPITAL_DEPARTMENT_ALL, deptParams);
      if (response.success && response.data && Array.isArray(response.data)) {
        const dataArr = response.data as Object[];
        const list: DepartmentItem[] = [];
        for (let i = 0; i < dataArr.length; i++) {
          const item = dataArr[i] as Record<string, Object>;
          if (item && typeof item === 'object') {
            list.push(new DepartmentItem(
              String(item['id'] || ''),
              String(item['hospital_id'] || ''),
              (item['dept_name'] as string) || ''
            ));
          }
        }
        this.departmentList = list;
      } else {
        this.departmentList = [];
      }
    } catch (e) {
      console.error('[预约] 加载科室异常:', e);
      this.departmentList = [];
    }
  }

  getFilteredDepartments(): DepartmentItem[] {
    if (!this.selectedHospitalId) return [];
    return this.departmentList.filter(d => d.hospitalId === this.selectedHospitalId);
  }

  validateForm(): boolean {
    this.errorMessage = '';

    if (!this.selectedHospitalId) {
      this.errorMessage = '请选择医院';
      return false;
    }

    if (!this.selectedDeptId) {
      this.errorMessage = '请选择科室';
      return false;
    }

    if (!this.selectedDate) {
      this.errorMessage = '请选择日期';
      return false;
    }

    if (!this.selectedTimeSlot) {
      this.errorMessage = '请选择时段';
      return false;
    }

    const selectedDateObj = new Date(this.selectedDate);
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    if (selectedDateObj < today) {
      this.errorMessage = '预约日期不能早于今天';
      return false;
    }

    return true;
  }

  async handleSubmit(): Promise<void> {
    if (!this.validateForm()) {
      ToastUtil.showError(this.errorMessage, 2000);
      return;
    }

    this.isLoading = true;
    try {
      const postData: Record<string, string> = {
        'hospitalId': this.selectedHospitalId,
        'hospitalName': this.selectedHospitalName,
        'departmentId': this.selectedDeptId,
        'departmentName': this.selectedDeptName,
        'appointmentDate': this.selectedDate,
        'timeSlot': this.selectedTimeSlot
      };

      const response: BaseResponse<Object> = await HttpUtil.post<Object>(ApiConstants.APPOINTMENT_CREATE, postData);

      if (response.success && response.data) {
        const data = response.data as Record<string, Object>;
        if (data && typeof data === 'object') {
          const no = data['appointmentNo'] ? String(data['appointmentNo']) : String(data['id'] || '');
          this.appointmentNo = no;
          this.showSuccessDialog = true;
        } else {
          ToastUtil.showError('预约响应数据异常');
        }
      } else {
        ToastUtil.showError(response.message || '预约提交失败');
      }
    } catch (e) {
      console.error('[预约] 提交异常:', e);
      ToastUtil.showError('网络异常，请重试');
    } finally {
      this.isLoading = false;
    }
  }

  @Builder
  buildSuccessDialogContent() {
    Column({ space: 16 }) {
      Text('✅ 预约成功')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#52C41A');

      Column({ space: 10 }) {
        Text('您的预约号')
          .fontSize(13)
          .fontColor('#999999');

        Text(this.appointmentNo)
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1677FF')
          .letterSpacing(3);

        Divider()
          .color('#F0F0F0');

        Row({ space: 8 }) {
          Text('科室：')
            .fontSize(14)
            .fontColor('#666666');
          Text(this.selectedDeptName)
            .fontSize(14)
            .fontColor('#333333')
            .fontWeight(FontWeight.Medium);
        }
        .width('100%')
        .justifyContent(FlexAlign.Start);

        Row({ space: 8 }) {
          Text('日期：')
            .fontSize(14)
            .fontColor('#666666');
          Text(this.selectedDate)
            .fontSize(14)
            .fontColor('#333333')
            .fontWeight(FontWeight.Medium);
        }
        .width('100%')
        .justifyContent(FlexAlign.Start);

        Row({ space: 8 }) {
          Text('时段：')
            .fontSize(14)
            .fontColor('#666666');
          Text(this.selectedTimeSlot)
            .fontSize(14)
            .fontColor('#333333')
            .fontWeight(FontWeight.Medium);
        }
        .width('100%')
        .justifyContent(FlexAlign.Start);

        Row({ space: 8 }) {
          Text('医院：')
            .fontSize(14)
            .fontColor('#666666');
          Text(this.selectedHospitalName)
            .fontSize(14)
            .fontColor('#333333')
            .fontWeight(FontWeight.Medium);
        }
        .width('100%')
        .justifyContent(FlexAlign.Start);
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FAFAFA')
      .borderRadius(12);

      ButtonWithFeedback({
        text: '确定',
        type: 'primary',
        btnSize: 'large',
        onItemClick: () => {
          this.showSuccessDialog = false;
          router.back();
        }
      })
        .width('100%');
    }
    .width('85%')
    .padding(24)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .shadow({ radius: 20, color: '#00000020', offsetX: 0, offsetY: 8 });
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column() {
        Header({ title: '新增预约', showBack: true });

        Scroll() {
          Column({ space: GlobalTheme.getSpacingLG(this.isElderMode) }) {
            Text('填写预约信息')
              .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
              .fontWeight('bold')
              .fontColor(GlobalTheme.THEME_COLOR)
              .margin({ top: GlobalTheme.getSpacingLG(this.isElderMode), bottom: GlobalTheme.getSpacingMD(this.isElderMode) });

            Column({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
              Text('选择医院 *')
                .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                .fontColor(GlobalTheme.TEXT_PRIMARY)
                .alignSelf(ItemAlign.Start);

              Row() {
                if (this.isLoading && this.hospitalList.length === 0) {
                  LoadingProgress()
                    .width(16)
                    .height(16)
                    .color('#1677FF');
                  Text('加载中...')
                    .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                    .fontColor('#999999')
                    .margin({ left: 8 });
                } else {
                  Text(this.selectedHospitalName || '请选择')
                    .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                    .fontColor(this.selectedHospitalName ? GlobalTheme.THEME_COLOR : GlobalTheme.TEXT_HINT);
                }
                Blank();
                Text('▼')
                  .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                  .fontColor(GlobalTheme.TEXT_HINT);
              }
              .width('100%')
              .height(GlobalTheme.getButtonHeight(this.isElderMode))
              .padding({ left: GlobalTheme.getSpacingMD(this.isElderMode), right: GlobalTheme.getSpacingMD(this.isElderMode) })
              .backgroundColor(GlobalTheme.CARD_BG)
              .borderRadius(GlobalTheme.RADIUS_MD)
              .border({ width: 1, color: GlobalTheme.BORDER_COLOR })
              .justifyContent(FlexAlign.Center)
              .onClick(() => {
                if (this.hospitalList.length === 0) return;
                const currentIndex = this.hospitalList.findIndex(h => h.id === this.selectedHospitalId);
                const nextIndex = (currentIndex + 1) % this.hospitalList.length;
                const hosp = this.hospitalList[nextIndex];
                this.selectedHospitalId = hosp.id;
                this.selectedHospitalName = hosp.name;
                this.selectedDeptId = '';
                this.selectedDeptName = '';
                if (this.departmentList.length === 0) {
                  this.loadDepartments(hosp.id);
                }
              });

              Text('选择科室 *')
                .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                .fontColor(GlobalTheme.TEXT_PRIMARY)
                .alignSelf(ItemAlign.Start);

              Row() {
                Text(this.selectedDeptName || '请先选择医院')
                  .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                  .fontColor(this.selectedDeptName ? GlobalTheme.THEME_COLOR : GlobalTheme.TEXT_HINT);
                Blank();
                Text('▼')
                  .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                  .fontColor(GlobalTheme.TEXT_HINT);
              }
              .width('100%')
              .height(GlobalTheme.getButtonHeight(this.isElderMode))
              .padding({ left: GlobalTheme.getSpacingMD(this.isElderMode), right: GlobalTheme.getSpacingMD(this.isElderMode) })
              .backgroundColor(GlobalTheme.CARD_BG)
              .borderRadius(GlobalTheme.RADIUS_MD)
              .border({ width: 1, color: GlobalTheme.BORDER_COLOR })
              .justifyContent(FlexAlign.Center)
              .onClick(() => {
                const filtered = this.getFilteredDepartments();
                if (filtered.length === 0) return;
                const currentIndex = filtered.findIndex(d => d.id === this.selectedDeptId);
                const nextIndex = (currentIndex + 1) % filtered.length;
                const dept = filtered[nextIndex];
                this.selectedDeptId = dept.id;
                this.selectedDeptName = dept.deptName;
              });

              Text('选择日期（未来7天）*')
                .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                .fontColor(GlobalTheme.TEXT_PRIMARY)
                .alignSelf(ItemAlign.Start);

              Row() {
                Text(this.selectedDate || '请选择')
                  .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                  .fontColor(this.selectedDate ? GlobalTheme.THEME_COLOR : GlobalTheme.TEXT_HINT);
                Blank();
                Text('▼')
                  .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                  .fontColor(GlobalTheme.TEXT_HINT);
              }
              .width('100%')
              .height(GlobalTheme.getButtonHeight(this.isElderMode))
              .padding({ left: GlobalTheme.getSpacingMD(this.isElderMode), right: GlobalTheme.getSpacingMD(this.isElderMode) })
              .backgroundColor(GlobalTheme.CARD_BG)
              .borderRadius(GlobalTheme.RADIUS_MD)
              .border({ width: 1, color: GlobalTheme.BORDER_COLOR })
              .justifyContent(FlexAlign.Center)
              .onClick(() => {
                const currentIndex = this.dates.indexOf(this.selectedDate);
                const nextIndex = (currentIndex + 1) % this.dates.length;
                this.selectedDate = this.dates[nextIndex];
              });

              Text('选择时段（上午/下午）*')
                .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                .fontColor(GlobalTheme.TEXT_PRIMARY)
                .alignSelf(ItemAlign.Start);

              Row() {
                Text(this.selectedTimeSlot || '请选择')
                  .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                  .fontColor(this.selectedTimeSlot ? GlobalTheme.THEME_COLOR : GlobalTheme.TEXT_HINT);
                Blank();
                Text('▼')
                  .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                  .fontColor(GlobalTheme.TEXT_HINT);
              }
              .width('100%')
              .height(GlobalTheme.getButtonHeight(this.isElderMode))
              .padding({ left: GlobalTheme.getSpacingMD(this.isElderMode), right: GlobalTheme.getSpacingMD(this.isElderMode) })
              .backgroundColor(GlobalTheme.CARD_BG)
              .borderRadius(GlobalTheme.RADIUS_MD)
              .border({ width: 1, color: GlobalTheme.BORDER_COLOR })
              .justifyContent(FlexAlign.Center)
              .onClick(() => {
                const currentIndex = this.timeSlots.indexOf(this.selectedTimeSlot);
                const nextIndex = (currentIndex + 1) % this.timeSlots.length;
                this.selectedTimeSlot = this.timeSlots[nextIndex];
              });
            }
            .width('100%')
            .padding(GlobalTheme.getSpacingMD(this.isElderMode))
            .backgroundColor(GlobalTheme.CARD_BG)
            .borderRadius(GlobalTheme.RADIUS_LG);

            if (this.errorMessage) {
              Text(this.errorMessage)
                .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                .fontColor('#FF4D4F')
                .width('100%')
                .padding(8)
                .backgroundColor('#FFF2F0')
                .borderRadius(8)
                .textAlign(TextAlign.Center);
            }

            ButtonWithFeedback({
              text: '提交预约',
              type: 'primary',
              btnSize: 'large',
              onItemClick: () => this.handleSubmit()
            })
              .width('100%');

            ButtonWithFeedback({
              text: '取消',
              type: 'secondary',
              btnSize: 'large',
              onItemClick: () => router.back()
            })
              .width('100%')
              .margin({ top: 8 });
          }
          .width('85%')
          .padding({ bottom: GlobalTheme.getSpacingLG(this.isElderMode) });
        }
        .height(0)
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top);

        Footer({ activeIndex: 0 });
      }
      .width('100%')
      .height('100%')
      .backgroundColor(GlobalTheme.BG_COLOR);

      if (this.showSuccessDialog) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#00000060')
          .onClick(() => {});

        this.buildSuccessDialogContent();
      }
    }
    .width('100%')
    .height('100%');
  }

  private padZero(num: number): string {
    return num < 10 ? '0' + num : '' + num;
  }
}
