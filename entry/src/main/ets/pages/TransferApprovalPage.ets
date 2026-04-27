import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { Loading } from '../components/Loading';
import { EmptyState } from '../components/EmptyState';
import { GlobalStyles, ElderStyles } from '../styles/globalStyles';
import { DistributedManager } from '../distributed/DistributedManager';
import { DesensitizationUtil } from '../distributed/DesensitizationUtil';
import {
  TransferApplication,
  MedicalRecordData,
  TransferStatus,
  PermissionLevel,
  DesensitizeLevel
} from '../models/DistributedModels';
import {
  getMockTransferApplications,
  getMockMedicalRecord
} from '../mock/distributedMock';

@Entry
@Component
struct TransferApprovalPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State isLoading: boolean = false;
  @State hasError: boolean = false;
  @State applications: TransferApplication[] = [];
  @State selectedApplication: TransferApplication | null = null;
  @State showDetailDialog: boolean = false;
  @State reviewOpinion: string = '';
  @State isSubmitting: boolean = false;
  @State showSuccessToast: boolean = false;
  @State toastMessage: string = '';
  @State medicalRecord: MedicalRecordData | null = null;
  @State desensitizedRecord: string = '';
  @State syncStatus: string = '';
  @State isSyncing: boolean = false;

  private distributedManager: DistributedManager = DistributedManager.getInstance();

  aboutToAppear(): void {
    this.loadApplications();
    this.initializeDistributed();
  }

  async initializeDistributed(): Promise<void> {
    try {
      if (!this.distributedManager.getInitializationStatus()) {
        await this.distributedManager.initialize();
      }
    } catch (error) {
      console.error('初始化分布式管理器失败:', error);
    }
  }

  loadApplications(): void {
    this.isLoading = true;
    this.hasError = false;

    setTimeout((): void => {
      try {
        const allApps: TransferApplication[] = getMockTransferApplications();
        this.applications = allApps.filter(
          (app: TransferApplication): boolean => app.status === TransferStatus.PENDING
        );
        this.isLoading = false;
      } catch (error) {
        console.error('加载转院申请失败:', error);
        this.isLoading = false;
        this.hasError = true;
      }
    }, 1000);
  }

  showApplicationDetail(application: TransferApplication): void {
    this.selectedApplication = application;
    this.reviewOpinion = '';
    this.syncStatus = '';

    try {
      const record: MedicalRecordData = getMockMedicalRecord();
      this.medicalRecord = record;

      const recordJson: string = JSON.stringify(record, null, 2);
      this.desensitizedRecord = DesensitizationUtil.desensitizeMedicalRecord(
        recordJson,
        DesensitizeLevel.PARTIAL
      );
    } catch (error) {
      console.error('加载病历数据失败:', error);
      this.desensitizedRecord = '病历数据加载失败';
    }

    this.showDetailDialog = true;
  }

  closeDetailDialog(): void {
    this.showDetailDialog = false;
    this.selectedApplication = null;
    this.medicalRecord = null;
    this.desensitizedRecord = '';
    this.reviewOpinion = '';
    this.syncStatus = '';
  }

  async approveTransfer(): Promise<void> {
    if (!this.selectedApplication || !this.reviewOpinion.trim()) {
      this.showToast('请填写审批意见');
      return;
    }

    this.isSubmitting = true;

    try {
      console.log(`[TransferApproval] 审批通过: ${this.selectedApplication.applicationId}`);

      await this.simulateAPIcall(1500);

      if (this.selectedApplication != null) {
        this.selectedApplication.status = TransferStatus.APPROVED;
        this.selectedApplication.reviewDoctorName = '当前医生';
        this.selectedApplication.reviewOpinion = this.reviewOpinion;
        this.selectedApplication.reviewTime = Date.now();

        this.isSyncing = true;
        this.syncStatus = '正在同步病历数据...';

        const syncResult = await this.distributedManager.syncMedicalRecord(
          this.selectedApplication.medicalRecordId,
          'device_002_hospital_b',
          PermissionLevel.DOCTOR
        );

        this.isSyncing = false;

        if (syncResult.success) {
          this.syncStatus = `病历同步完成 (ID: ${syncResult.syncId})`;
          console.log(`[TransferApproval] 病历同步成功: ${syncResult.syncId}`);
        } else {
          this.syncStatus = `病历同步失败: ${syncResult.error}`;
          console.error(`[TransferApproval] 病历同步失败: ${syncResult.error}`);
        }
      }

      this.showToast(`审批通过！${this.syncStatus}`);
      this.closeDetailDialog();
      this.loadApplications();
    } catch (error) {
      console.error('审批操作失败:', error);
      this.showToast('审批操作失败，请重试');
    } finally {
      this.isSubmitting = false;
    }
  }

  async rejectTransfer(): Promise<void> {
    if (!this.selectedApplication || !this.reviewOpinion.trim()) {
      this.showToast('请填写拒绝原因');
      return;
    }

    this.isSubmitting = true;

    try {
      console.log(`[TransferApproval] 审批拒绝: ${this.selectedApplication.applicationId}`);

      await this.simulateAPIcall(1000);

      if (this.selectedApplication != null) {
        this.selectedApplication.status = TransferStatus.REJECTED;
        this.selectedApplication.reviewDoctorName = '当前医生';
        this.selectedApplication.reviewOpinion = this.reviewOpinion;
        this.selectedApplication.reviewTime = Date.now();
      }

      this.showToast('已拒绝转院申请');
      this.closeDetailDialog();
      this.loadApplications();
    } catch (error) {
      console.error('拒绝操作失败:', error);
      this.showToast('操作失败，请重试');
    } finally {
      this.isSubmitting = false;
    }
  }

  showToast(message: string): void {
    this.toastMessage = message;
    this.showSuccessToast = true;
    setTimeout((): void => {
      this.showSuccessToast = false;
    }, 3000);
  }

  private simulateAPIcall(ms: number): Promise<void> {
    return new Promise<void>((resolve: Function) => {
      setTimeout(resolve, ms);
    });
  }

  formatDate(timestamp: number): string {
    const date: Date = new Date(timestamp);
    const year: number = date.getFullYear();
    const month: string = String(date.getMonth() + 1).padStart(2, '0');
    const day: string = String(date.getDate()).padStart(2, '0');
    const hours: string = String(date.getHours()).padStart(2, '0');
    const minutes: string = String(date.getMinutes()).padStart(2, '0');
    return `${year}-${month}-${day} ${hours}:${minutes}`;
  }

  getStatusColor(status: TransferStatus): string {
    switch (status) {
      case TransferStatus.PENDING:
        return GlobalStyles.WARNING_COLOR;
      case TransferStatus.APPROVED:
        return GlobalStyles.SUCCESS_COLOR;
      case TransferStatus.REJECTED:
        return GlobalStyles.ERROR_COLOR;
      default:
        return GlobalStyles.TEXT_SECONDARY;
    }
  }

  getStatusText(status: TransferStatus): string {
    switch (status) {
      case TransferStatus.PENDING:
        return '待审批';
      case TransferStatus.APPROVED:
        return '已通过';
      case TransferStatus.REJECTED:
        return '已拒绝';
      default:
        return '未知';
    }
  }

  build() {
    Column() {
      Header({ title: '转院审批' })

      Scroll() {
        Column() {
          if (this.isLoading) {
            Loading({ text: '加载转院申请...' })
          } else if (this.hasError) {
            EmptyState({
              icon: '❌',
              title: '加载失败',
              description: '点击下方按钮重试',
              buttonText: '重试',
              onAdd: (): void => this.loadApplications()
            })
          } else if (this.applications.length === 0) {
            EmptyState({
              icon: '📋',
              title: '暂无待审批的转院申请'
            })
          } else {
            ForEach(this.applications, (application: TransferApplication) => {
              ApplicationCard({ application: application, isElderMode: this.isElderMode, onShowDetail: (app: TransferApplication): void => this.showApplicationDetail(app), formatDateFn: (ts: number): string => this.formatDate(ts), getStatusTextFn: (s: TransferStatus): string => this.getStatusText(s), getColorFn: (s: TransferStatus): string => this.getStatusColor(s) })
            })
          }
        }
        .width(GlobalStyles.PAGE_WIDTH)
        .padding({
          top: GlobalStyles.SPACING_MD,
          bottom: GlobalStyles.SPACING_XL
        })
      }
      .layoutWeight(1)

      Footer()
    }
    .height('100%')
    .backgroundColor(GlobalStyles.BG_COLOR)
    .bindSheet($$this.showDetailDialog, this.DetailSheetContent(), {
      height: SheetSize.LARGE,
      backgroundColor: Color.Transparent,
      blurStyle: BlurStyle.Thin
    })
  }

  @Builder
  DetailSheetContent(): void {
    Column() {
      Text('转院申请详情')
        .fontSize(this.isElderMode ? ElderStyles.FONT_SIZE_SUBTITLE : GlobalStyles.FONT_SIZE_SUBTITLE)
        .fontWeight(FontWeight.Bold)
        .fontColor(GlobalStyles.TEXT_PRIMARY)
        .margin({ bottom: GlobalStyles.SPACING_MD })

      Scroll() {
        Column() {
          if (this.selectedApplication != null) {
            InfoRow({ label: '患者姓名', value: this.selectedApplication.patientName })
            InfoRow({ label: '来源医院', value: this.selectedApplication.sourceHospitalName })
            InfoRow({ label: '目标医院', value: this.selectedApplication.targetHospitalName })
            InfoRow({ label: '转院原因', value: this.selectedApplication.reason })
            InfoRow({ label: '申请时间', value: this.formatDate(this.selectedApplication.submitTime) })

            if (this.desensitizedRecord.length > 0) {
              Text('病历信息（已脱敏）')
                .fontSize(GlobalStyles.FONT_SIZE_BODY)
                .fontWeight(FontWeight.Medium)
                .fontColor(GlobalStyles.THEME_COLOR)
                .width('100%')
                .margin({ top: GlobalStyles.SPACING_LG, bottom: GlobalStyles.SPACING_SM })

              Text(this.desensitizedRecord)
                .fontSize(GlobalStyles.FONT_SIZE_SMALL)
                .fontColor(GlobalStyles.TEXT_SECONDARY)
                .width('100%')
                .backgroundColor('#F5F5F5')
                .borderRadius(GlobalStyles.RADIUS_SM)
                .padding(GlobalStyles.SPACING_MD)
            }

            if (this.isSyncing || this.syncStatus.length > 0) {
              Text(this.syncStatus || '正在同步...')
                .fontSize(GlobalStyles.FONT_SIZE_SMALL)
                .fontColor(GlobalStyles.THEME_COLOR)
                .width('100%')
                .margin({ top: GlobalStyles.SPACING_MD })
                .textAlign(TextAlign.Center)
            }
          }

          Text('审批意见')
            .fontSize(GlobalStyles.FONT_SIZE_BODY)
            .fontWeight(FontWeight.Medium)
            .fontColor(GlobalStyles.TEXT_PRIMARY)
            .width('100%')
            .margin({ top: GlobalStyles.SPACING_LG, bottom: GlobalStyles.SPACING_SM })

          TextArea({ text: this.reviewOpinion, placeholder: '请输入审批意见...' })
            .width('100%')
            .height(100)
            .fontSize(GlobalStyles.FONT_SIZE_BODY)
            .fontColor(GlobalStyles.TEXT_PRIMARY)
            .backgroundColor('#F5F5F5')
            .borderRadius(GlobalStyles.RADIUS_SM)
            .padding(GlobalStyles.SPACING_SM)
            .onChange((value: string): void => {
              this.reviewOpinion = value;
            })

          Row() {
            Button('拒绝')
              .width('45%')
              .height(this.isElderMode ? ElderStyles.BUTTON_HEIGHT : GlobalStyles.BUTTON_HEIGHT)
              .fontSize(GlobalStyles.FONT_SIZE_BODY)
              .fontColor(GlobalStyles.ERROR_COLOR)
              .backgroundColor('#FFF0F0')
              .borderRadius(GlobalStyles.RADIUS_ROUND)
              .enabled(!this.isSubmitting)
              .onClick(async (): Promise<void> => {
                await this.rejectTransfer();
              })

            Button('通过')
              .width('45%')
              .height(this.isElderMode ? ElderStyles.BUTTON_HEIGHT : GlobalStyles.BUTTON_HEIGHT)
              .fontSize(GlobalStyles.FONT_SIZE_BODY)
              .fontColor(Color.White)
              .backgroundColor(GlobalStyles.SUCCESS_COLOR)
              .borderRadius(GlobalStyles.RADIUS_ROUND)
              .enabled(!this.isSubmitting)
              .onClick(async (): Promise<void> => {
                await this.approveTransfer();
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .margin({ top: GlobalStyles.SPACING_LG })
        }
        .width('100%')
      }
      .flexShrink(1)

      Button('关闭')
        .width('100%')
        .height(this.isElderMode ? ElderStyles.BUTTON_HEIGHT : GlobalStyles.BUTTON_HEIGHT)
        .fontSize(GlobalStyles.FONT_SIZE_BODY)
        .fontColor(GlobalStyles.TEXT_PRIMARY)
        .backgroundColor(GlobalStyles.BORDER_COLOR)
        .borderRadius(GlobalStyles.RADIUS_ROUND)
        .margin({ top: GlobalStyles.SPACING_MD })
        .onClick((): void => {
          this.closeDetailDialog();
        })
    }
    .width('90%')
    .constraintSize({ maxHeight: '85%' })
    .backgroundColor(Color.White)
    .borderRadius(GlobalStyles.RADIUS_LG)
    .padding(GlobalStyles.SPACING_LG)
  }
}

interface ApplicationCardParams {
  application: TransferApplication;
  isElderMode: boolean;
  onShowDetail: (app: TransferApplication) => void;
  formatDateFn: (ts: number) => string;
  getStatusTextFn: (s: TransferStatus) => string;
  getColorFn: (s: TransferStatus) => string;
}

@Builder
function ApplicationCard($$: ApplicationCardParams): void {
  Column() {
    Row() {
      Column() {
        Text($$.application.patientName)
          .fontSize($$.isElderMode ? ElderStyles.FONT_SIZE_BODY : GlobalStyles.FONT_SIZE_BODY)
          .fontWeight(FontWeight.Bold)
          .fontColor(GlobalStyles.TEXT_PRIMARY)

        Text(`目标医院: $${$$.application.targetHospitalName}`)
          .fontSize(GlobalStyles.FONT_SIZE_SMALL)
          .fontColor(GlobalStyles.TEXT_SECONDARY)
          .margin({ top: GlobalStyles.SPACING_XS })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Column() {
        Text($$.getStatusTextFn($$.application.status))
          .fontSize(GlobalStyles.FONT_SIZE_SMALL)
          .fontColor($$.getColorFn($$.application.status))
          .fontWeight(FontWeight.Medium)
      }
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)

    Text($$.application.reason)
      .fontSize(GlobalStyles.FONT_SIZE_SMALL)
      .fontColor(GlobalStyles.TEXT_HINT)
      .maxLines(2)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .width('100%')
      .margin({ top: GlobalStyles.SPACING_SM })

    Row() {
      Text(`申请时间: $${$$.formatDateFn($$.application.submitTime)}`)
        .fontSize(GlobalStyles.FONT_SIZE_TINY)
        .fontColor(GlobalStyles.TEXT_LIGHT)
    }
    .width('100%')
    .margin({ top: GlobalStyles.SPACING_SM })
  }
  .width('100%')
  .backgroundColor(GlobalStyles.CARD_BG)
  .borderRadius(GlobalStyles.RADIUS_MD)
  .padding(GlobalStyles.SPACING_MD)
  .shadow({
    radius: GlobalStyles.RADIUS_SM,
    color: GlobalStyles.SHADOW_COLOR,
    offsetX: 0,
    offsetY: 2
  })
  .onClick((): void => {
    $$.onShowDetail($$.application);
  })
  .margin({ bottom: GlobalStyles.SPACING_MD })
}

interface InfoRowParams {
  label: string;
  value: string;
}

@Builder
function InfoRow($$: InfoRowParams): void {
  Row() {
    Text(`${$$.label}:`)
      .fontSize(GlobalStyles.FONT_SIZE_SMALL)
      .fontColor(GlobalStyles.TEXT_SECONDARY)
      .width(80)

    Text($$.value)
      .fontSize(GlobalStyles.FONT_SIZE_SMALL)
      .fontColor(GlobalStyles.TEXT_PRIMARY)
      .layoutWeight(1)
      .textAlign(TextAlign.Start)
  }
  .width('100%')
  .alignItems(VerticalAlign.Top)
  .margin({ bottom: GlobalStyles.SPACING_SM })
}
