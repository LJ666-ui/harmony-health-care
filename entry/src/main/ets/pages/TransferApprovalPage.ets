/**
 * 转院审批页面
 * 
 * 功能：
 * 1. 展示待审批的转院申请列表
 * 2. 点击申请卡片 → 弹窗显示脱敏后的患者病历详情
 * 3. 医生填写审批意见 → 点击"通过"或"拒绝"
 * 4. 审批通过后自动调用DistributedManager.syncMedicalRecord()触发数据同步
 */

import { DistributedManager } from '../distributed/DistributedManager';
import { DesensitizationUtil, DesensitizeLevel } from '../distributed/DesensitizationUtil';
import {
  TransferApplication,
  ApplicationStatus,
  UrgencyLevel,
  PermissionLevel,
  MedicalRecordForSync,
  SyncResult
} from '../distributed/DistributedModels';

@Entry
@Component
struct TransferApprovalPage {
  @State applications: TransferApplication[] = [];
  @State isLoading: boolean = true;
  @State selectedApplication: TransferApplication | null = null;
  @State showDetailDialog: boolean = false;
  @State medicalRecord: MedicalRecordForSync | null = null;
  @State approvalComment: string = '';
  @State isApproving: boolean = false;
  @State toastMessage: string = '';

  private distributedManager: DistributedManager = DistributedManager.getInstance();

  aboutToAppear(): void {
    this.loadApplications();
  }

  /**
   * 加载待审批的转院申请列表
   */
  async loadApplications(): Promise<void> {
    try {
      this.isLoading = true;
      console.log('[TransferApproval] 加载转院申请...');

      const mockData = await import('../mock/distributedMock');
      this.applications = mockData.getPendingApplications();

      console.log('[TransferApproval] 加载完成，共 ' + this.applications.length + ' 条申请');
    } catch (error) {
      console.error('[TransferApproval] 加载失败:', error.message);
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      // 标题栏
      this.buildHeader()

      Divider().height(1).color('#E5E5E5')

      if (this.isLoading) {
        this.buildLoadingState()
      } else if (this.applications.length === 0) {
        this.buildEmptyState()
      } else {
        this.buildApplicationList()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  /**
   * 构建标题栏
   */
  @Builder
  buildHeader() {
    Row() {
      Text('转院审批')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')

      Blank()

      Text('待审批 (' + this.applications.filter(app => app.status === ApplicationStatus.PENDING).length + ')')
        .fontSize(14)
        .fontColor('#666666')
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor('#FFFFFF')
  }

  /**
   * 构建Loading状态
   */
  @Builder
  buildLoadingState() {
    Column() {
      LoadingProgress()
        .width(40)
        .height(40)
        .color('#007AFF')

      Text('加载中...')
        .fontSize(14)
        .fontColor('#666666')
        .margin({ top: 12 })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  /**
   * 构建空状态
   */
  @Builder
  buildEmptyState() {
    Column() {
      Text('暂无待审批的转院申请')
        .fontSize(16)
        .fontColor('#999999')

      Text('新的转院申请会在这里显示')
        .fontSize(14)
        .fontColor('#CCCCCC')
        .margin({ top: 8 })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  /**
   * 构建申请列表
   */
  @Builder
  buildApplicationList() {
    List({ space: 12 }) {
      ForEach(this.applications, (application: TransferApplication, index: number) => {
        ListItem() {
          this.buildApplicationCard(application)
        }
      }, (application: TransferApplication) => application.applicationId)
    }
    .width('100%')
    .layoutWeight(1)
    .padding(16)
    .scrollBar(BarState.Off)
  }

  /**
   * 构建单个申请卡片
   */
  @Builder
  buildApplicationCard(application: TransferApplication) {
    Column() {
      Row() {
        // 紧急程度标签
        Text(this.getUrgencyLabel(application.urgencyLevel))
          .fontSize(12)
          .fontColor(this.getUrgencyColor(application.urgencyLevel))
          .backgroundColor(this.getUrgencyBgColor(application.urgencyLevel))
          .borderRadius(4)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })

        Blank()

        // 状态标签
        Text(this.getStatusLabel(application.status))
          .fontSize(12)
          .fontColor(this.getStatusColor(application.status))
          .backgroundColor(this.getStatusBgColor(application.status))
          .borderRadius(4)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
      }
      .width('100%')

      Column() {
        // 患者信息
        Row() {
          Text('患者：')
            .fontSize(14)
            .fontColor('#666666')
          Text(application.patientName)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
        }
        .width('100%')
        .margin({ top: 12 })

        // 转出医院 → 接收医院
        Row() {
          Text(application.sourceHospitalName)
            .fontSize(13)
            .fontColor('#007AFF')

          Text('→')
            .fontSize(14)
            .fontColor('#CCCCCC')
            .margin({ left: 8, right: 8 })

          Text(application.targetHospitalName)
            .fontSize(13)
            .fontColor('#FF9500')
        }
        .width('100%')
        .margin({ top: 8 })

        // 转院原因（截断显示）
        Text(application.applyReason)
          .fontSize(13)
          .fontColor('#666666')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .margin({ top: 8 })

        // 申请时间和申请人
        Row() {
          Text('申请人：' + application.applicantName)
            .fontSize(12)
            .fontColor('#999999')

          Blank()

          Text(application.applyTime.substring(0, 10))
            .fontSize(12)
            .fontColor('#999999')
        }
        .width('100%')
        .margin({ top: 12 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      // 操作按钮（仅待审批状态显示）
      if (application.status === ApplicationStatus.PENDING) {
        Row() {
          Button('查看详情')
            .type(ButtonType.Normal)
            .fontSize(14)
            .fontColor('#007AFF')
            .backgroundColor('#FFFFFF')
            .borderRadius(8)
            .border({ width: 1, color: '#007AFF' })
            .onClick(() => {
              this.showApplicationDetail(application);
            })

          Blank()

          Button('快速审批通过')
            .type(ButtonType.Normal)
            .fontSize(14)
            .fontColor('#FFFFFF')
            .backgroundColor('#34C759')
            .borderRadius(8)
            .onClick(() => {
              this.quickApprove(application);
            })
        }
        .width('100%')
        .margin({ top: 12 })
      }
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .padding(16)
    .shadow({
      radius: 4,
      color: 'rgba(0,0,0,0.05)',
      offsetX: 0,
      offsetY: 2
    })
    .onClick(() => {
      if (application.status === ApplicationStatus.PENDING) {
        this.showApplicationDetail(application);
      }
    })
  }

  /**
   * 显示申请详情弹窗
   */
  showApplicationDetail(application: TransferApplication): void {
    this.selectedApplication = application;
    this.showDetailDialog = true;
    this.loadMedicalRecord(application);
  }

  /**
   * 加载患者病历数据
   */
  async loadMedicalRecord(application: TransferApplication): Promise<void> {
    try {
      console.log('[TransferApproval] 加载病历数据...');
      
      const mockData = await import('../mock/distributedMock');
      this.medicalRecord = mockData.getMedicalRecordForPatient(application.patientId);
      
      console.log('[TransferApproval] 病历加载完成');
    } catch (error) {
      console.error('[TransferApproval] 病历加载失败:', error.message);
      this.medicalRecord = null;
    }
  }

  /**
   * 快速审批通过
   */
  async quickApprove(application: TransferApplication): Promise<void> {
    try {
      this.isApproving = true;
      console.log('[TransferApproval] 快速审批通过:', application.applicationId);

      const syncResult = await this.distributedManager.syncMedicalRecord(
        'record_' + application.patientId,
        'device_target_hospital',
        PermissionLevel.DOCTOR_PARTIAL
      );

      if (syncResult.success) {
        this.showToast('审批成功，病历已同步到接收医院');
        
        application.status = ApplicationStatus.APPROVED;
        this.selectedApplication = null;
        this.showDetailDialog = false;
      } else {
        this.showToast('审批失败: ' + (syncResult.error || '未知错误'));
      }
    } catch (error) {
      console.error('[TransferApproval] 审批失败:', error.message);
      this.showToast('审批异常: ' + error.message);
    } finally {
      this.isApproving = false;
    }
  }

  /**
   * 提交审批（带意见）
   */
  async submitApproval(isApproved: boolean): Promise<void> {
    if (!this.selectedApplication) return;

    try {
      this.isApproving = true;

      if (isApproved) {
        const syncResult = await this.distributedManager.syncMedicalRecord(
          'record_' + this.selectedApplication.patientId,
          'device_target_hospital',
          PermissionLevel.DOCTOR_PARTIAL
        );

        if (syncResult.success) {
          this.showToast('审批成功，病历已同步');
          this.selectedApplication.status = ApplicationStatus.APPROVED;
        } else {
          this.showToast('同步失败: ' + (syncResult.error || '未知错误'));
          return;
        }
      } else {
        this.showToast('已拒绝该转院申请');
        this.selectedApplication.status = ApplicationStatus.REJECTED;
      }

      this.showDetailDialog = false;
      this.selectedApplication = null;
      this.approvalComment = '';

    } catch (error) {
      console.error('[TransferApproval] 提交审批失败:', error.message);
      this.showToast('操作失败: ' + error.message);
    } finally {
      this.isApproving = false;
    }
  }

  /**
   * 显示Toast提示
   */
  showToast(message: string): void {
    this.toastMessage = message;
    setTimeout(() => {
      this.toastMessage = '';
    }, 2000);
  }

  // ==================== 辅助方法 ====================

  getUrgencyLabel(level: UrgencyLevel): string {
    switch (level) {
      case UrgencyLevel.NORMAL:
        return '普通';
      case UrgencyLevel.URGENT:
        return '紧急';
      case UrgencyLevel.EMERGENCY:
        return '急诊';
      default:
        return '未知';
    }
  }

  getUrgencyColor(level: UrgencyLevel): string {
    switch (level) {
      case UrgencyLevel.NORMAL:
        return '#34C759';
      case UrgencyLevel.URGENT:
        return '#FF9500';
      case UrgencyLevel.EMERGENCY:
        return '#FF3B30';
      default:
        return '#999999';
    }
  }

  getUrgencyBgColor(level: UrgencyLevel): string {
    switch (level) {
      case UrgencyLevel.NORMAL:
        return 'rgba(52,199,89,0.1)';
      case UrgencyLevel.URGENT:
        return 'rgba(255,149,0,0.1)';
      case UrgencyLevel.EMERGENCY:
        return 'rgba(255,59,48,0.1)';
      default:
        return '#F5F5F5';
    }
  }

  getStatusLabel(status: ApplicationStatus): string {
    switch (status) {
      case ApplicationStatus.PENDING:
        return '待审批';
      case ApplicationStatus.APPROVED:
        return '已通过';
      case ApplicationStatus.REJECTED:
        return '已拒绝';
      case ApplicationStatus.CANCELLED:
        return '已取消';
      default:
        return '未知';
    }
  }

  getStatusColor(status: ApplicationStatus): string {
    switch (status) {
      case ApplicationStatus.PENDING:
        return '#FF9500';
      case ApplicationStatus.APPROVED:
        return '#34C759';
      case ApplicationStatus.REJECTED:
        return '#FF3B30';
      case ApplicationStatus.CANCELLED:
        return '#999999';
      default:
        return '#999999';
    }
  }

  getStatusBgColor(status: ApplicationStatus): string {
    switch (status) {
      case ApplicationStatus.PENDING:
        return 'rgba(255,149,0,0.1)';
      case ApplicationStatus.APPROVED:
        return 'rgba(52,199,89,0.1)';
      case ApplicationStatus.REJECTED:
        return 'rgba(255,59,48,0.1)';
      case ApplicationStatus.CANCELLED:
        return '#F5F5F5';
      default:
        return '#F5F5F5';
    }
  }
}
