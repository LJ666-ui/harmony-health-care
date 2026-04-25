import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { Loading } from '../components/Loading';
import { EmptyState } from '../components/EmptyState';
import { GlobalStyles, ElderStyles } from '../styles/globalStyles';
import { DistributedManager } from '../distributed/DistributedManager';
import { DesensitizationUtil } from '../distributed/DesensitizationUtil';
import {
  DeviceInfo,
  SyncTask,
  SyncStatus,
  PermissionLevel,
  DeviceType
} from '../models/DistributedModels';
import { getMockDevices, getMockMedicalRecord } from '../mock/distributedMock';

interface SyncHistoryItem {
  syncId: string;
  recordId: string;
  targetDeviceName: string;
  status: SyncStatus;
  progress: number;
  startTime: number;
  completeTime?: number;
}

@Entry
@Component
struct MedicalRecordSyncPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State isLoading: boolean = false;
  @State hasError: boolean = false;
  @State devices: DeviceInfo[] = [];
  @State selectedDevice: DeviceInfo | null = null;
  @State isDiscovering: boolean = false;
  @State syncTasks: SyncHistoryItem[] = [];
  @State selectedRecordId: string = '';
  @State showDeviceDialog: boolean = false;
  @State showSyncDialog: boolean = false;
  @State isSyncing: boolean = false;
  @State currentProgress: number = 0;
  @State syncResultMessage: string = '';
  @State showSuccessToast: boolean = false;
  @State toastMessage: string = '';

  private distributedManager: DistributedManager = DistributedManager.getInstance();
  private refreshTimer: number = -1;

  aboutToAppear(): void {
    this.loadDevices();
    this.loadSyncHistory();
    this.initializeDistributed();
    this.startAutoRefresh();
  }

  aboutToDisappear(): void {
    this.stopAutoRefresh();
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

  startAutoRefresh(): void {
    this.refreshTimer = setInterval((): void => {
      this.refreshSyncStatus();
    }, 5000);
  }

  stopAutoRefresh(): void {
    if (this.refreshTimer !== -1) {
      clearInterval(this.refreshTimer);
      this.refreshTimer = -1;
    }
  }

  loadDevices(): void {
    this.isLoading = true;

    setTimeout(async (): Promise<void> => {
      try {
        const discoveredDevices: DeviceInfo[] =
          await this.distributedManager.discoverDevices(10000);
        this.devices = discoveredDevices;
        this.isLoading = false;
      } catch (error) {
        console.error('加载设备列表失败:', error);

        try {
          const mockDevices: DeviceInfo[] = getMockDevices();
          this.devices = mockDevices;
        } catch (mockError) {
          console.error('加载Mock设备失败:', mockError);
        }

        this.isLoading = false;
        this.hasError = true;
      }
    }, 1200);
  }

  async refreshDevices(): Promise<void> {
    this.isDiscovering = true;

    try {
      const discoveredDevices: DeviceInfo[] =
        await this.distributedManager.discoverDevices(8000);
      this.devices = discoveredDevices;
      this.showToast('设备列表已刷新');
    } catch (error) {
      console.error('刷新设备列表失败:', error);
      this.showToast('刷新失败，请重试');
    } finally {
      this.isDiscovering = false;
    }
  }

  loadSyncHistory(): void {
    const now: number = Date.now();

    const mockHistory: SyncHistoryItem[] = [
      {
        syncId: 'SYNC_20260423_001',
        recordId: 'MR20260420001',
        targetDeviceName: '协和医院终端-A',
        status: SyncStatus.COMPLETED,
        progress: 100,
        startTime: now - 3600000,
        completeTime: now - 3500000
      },
      {
        syncId: 'SYNC_20260422_002',
        recordId: 'MR20260418001',
        targetDeviceName: '同济医院终端-B',
        status: SyncStatus.COMPLETED,
        progress: 100,
        startTime: now - 86400000,
        completeTime: now - 86000000
      },
      {
        syncId: 'SYNC_20260424_003',
        recordId: 'MR20260415001',
        targetDeviceName: '协和医院终端-A',
        status: SyncStatus.FAILED,
        progress: 45,
        startTime: now - 1800000
      }
    ] as SyncHistoryItem[];

    this.syncTasks = mockHistory;
  }

  async refreshSyncStatus(): Promise<void> {
    for (let i: number = 0; i < this.syncTasks.length; i++) {
      if (this.syncTasks[i].status === SyncStatus.SYNCING) {
        const newProgress: number = Math.min(
          this.syncTasks[i].progress + Math.floor(Math.random() * 10),
          100
        );

        this.syncTasks[i].progress = newProgress;

        if (newProgress >= 100) {
          this.syncTasks[i].status = SyncStatus.COMPLETED;
          this.syncTasks[i].completeTime = Date.now();
        }
      }
    }
  }

  selectTargetDevice(device: DeviceInfo): void {
    this.selectedDevice = device;
    this.showDeviceDialog = false;
    this.showSyncDialog = true;
    this.selectedRecordId = 'MR20260420001';
    this.syncResultMessage = '';
  }

  async startSync(): Promise<void> {
    if (!this.selectedDevice || !this.selectedRecordId) {
      this.showToast('请选择目标设备和病历');
      return;
    }

    this.isSyncing = true;
    this.currentProgress = 0;
    this.syncResultMessage = '';

    try {
      console.log(`[MedicalRecordSync] 开始同步到设备: ${this.selectedDevice.deviceName}`);

      const newSyncTask: SyncHistoryItem = {
        syncId: `SYNC_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
        recordId: this.selectedRecordId,
        targetDeviceName: this.selectedDevice.deviceName,
        status: SyncStatus.SYNCING,
        progress: 0,
        startTime: Date.now()
      } as SyncHistoryItem;

      this.syncTasks.unshift(newSyncTask);

      const syncInterval: number = setInterval(async (): Promise<void> => {
        this.currentProgress += Math.floor(Math.random() * 15) + 5;
        newSyncTask.progress = Math.min(this.currentProgress, 100);

        if (this.currentProgress >= 100) {
          clearInterval(syncInterval);

          const result = await this.distributedManager.syncMedicalRecord(
            this.selectedRecordId,
            this.selectedDevice!.deviceId,
            PermissionLevel.DOCTOR
          );

          newSyncTask.status = result.success ? SyncStatus.COMPLETED : SyncStatus.FAILED;
          newSyncTask.completeTime = Date.now();

          if (result.success) {
            this.syncResultMessage = `同步成功！ID: ${result.syncId}`;
            this.showToast(this.syncResultMessage);
          } else {
            this.syncResultMessage = `同步失败: ${result.error}`;
            this.showToast(this.syncResultMessage);
          }

          this.isSyncing = false;
          this.showSyncDialog = false;
        }
      }, 800);
    } catch (error) {
      console.error('同步操作失败:', error);
      this.syncResultMessage = `同步异常: ${String(error)}`;
      this.isSyncing = false;
      this.showToast(this.syncResultMessage);
    }
  }

  cancelSync(): void {
    this.isSyncing = false;
    this.currentProgress = 0;
    this.showSyncDialog = false;
    this.showToast('已取消同步');
  }

  showToast(message: string): void {
    this.toastMessage = message;
    this.showSuccessToast = true;
    setTimeout((): void => {
      this.showSuccessToast = false;
    }, 3000);
  }

  getDeviceTypeIcon(deviceType: DeviceType): string {
    switch (deviceType) {
      case DeviceType.PHONE:
        return '📱';
      case DeviceType.TABLET:
        return '📱';
      case DeviceType.WATCH:
        return '⌚';
      case DeviceType.HOSPITAL_TERMINAL:
        return '🏥';
      default:
        return '📡';
    }
  }

  getStatusColor(status: SyncStatus): string {
    switch (status) {
      case SyncStatus.PENDING:
        return GlobalStyles.TEXT_HINT;
      case SyncStatus.SYNCING:
        return GlobalStyles.THEME_COLOR;
      case SyncStatus.COMPLETED:
        return GlobalStyles.SUCCESS_COLOR;
      case SyncStatus.FAILED:
        return GlobalStyles.ERROR_COLOR;
      default:
        return GlobalStyles.TEXT_SECONDARY;
    }
  }

  getStatusText(status: SyncStatus): string {
    switch (status) {
      case SyncStatus.PENDING:
        return '等待中';
      case SyncStatus.SYNCING:
        return '同步中';
      case SyncStatus.COMPLETED:
        return '已完成';
      case SyncStatus.FAILED:
        return '失败';
      default:
        return '未知';
    }
  }

  formatTimestamp(timestamp: number): string {
    const date: Date = new Date(timestamp);
    const month: string = String(date.getMonth() + 1).padStart(2, '0');
    const day: string = String(date.getDate()).padStart(2, '0');
    const hours: string = String(date.getHours()).padStart(2, '0');
    const minutes: string = String(date.getMinutes()).padStart(2, '0');
    return `${month}-${day} ${hours}:${minutes}`;
  }

  build() {
    Column() {
      Header({ title: '病历同步' })

      Scroll() {
        Column() {
          Row() {
            Text('可用设备')
              .fontSize(
                this.isElderMode ? ElderStyles.FONT_SIZE_BODY : GlobalStyles.FONT_SIZE_SUBTITLE
              )
              .fontWeight(FontWeight.Bold)
              .fontColor(GlobalStyles.TEXT_PRIMARY)

            Blank()

            Button(this.isDiscovering ? '发现中...' : '刷新设备')
              .fontSize(GlobalStyles.FONT_SIZE_SMALL)
              .fontColor(GlobalStyles.THEME_COLOR)
              .backgroundColor(Color.Transparent)
              .enabled(!this.isDiscovering)
              .onClick(async (): Promise<void> => {
                await this.refreshDevices();
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(VerticalAlign.Center)
          .margin({ bottom: GlobalStyles.SPACING_MD })

          if (this.isLoading) {
            Loading({ text: '正在发现附近设备...' })
          } else if (this.devices.length > 0) {
            ForEach(this.devices, (device: DeviceInfo) => {
              DeviceCard({ device: device, isElderMode: this.isElderMode, isSyncing: this.isSyncing, onSelectTargetDevice: (d: DeviceInfo): void => this.selectTargetDevice(d) })
            })
          } else {
            EmptyState({
              icon: '📡',
              title: '未发现可用设备',
              description: '点击下方按钮刷新设备列表',
              buttonText: '刷新',
              onAdd: async (): Promise<void> => {
                await this.refreshDevices();
              }
            })
          }

          Text('同步历史')
            .fontSize(
              this.isElderMode ? ElderStyles.FONT_SIZE_BODY : GlobalStyles.FONT_SIZE_SUBTITLE
            )
            .fontWeight(FontWeight.Bold)
            .fontColor(GlobalStyles.TEXT_PRIMARY)
            .width('100%')
            .margin({ top: GlobalStyles.SPACING_XL, bottom: GlobalStyles.SPACING_MD })

          if (this.syncTasks.length > 0) {
            ForEach(this.syncTasks, (task: SyncHistoryItem) => {
              SyncHistoryCard({ task: task })
            })
          } else {
            EmptyState({
              icon: '📋',
              title: '暂无同步记录'
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
    .bindSheet($$this.showDeviceDialog, this.DeviceSelectSheetContent(), {
      height: SheetSize.MEDIUM,
      backgroundColor: Color.Transparent,
      blurStyle: BlurStyle.Thin
    })
    .bindSheet($$this.showSyncDialog, this.SyncConfirmSheetContent(), {
      height: SheetSize.LARGE,
      backgroundColor: Color.Transparent,
      blurStyle: BlurStyle.Thin
    })
  }

  @Builder
  DeviceSelectSheetContent(): void {
    Column() {
      Text('选择目标设备')
        .fontSize(
          this.isElderMode ? ElderStyles.FONT_SIZE_SUBTITLE : GlobalStyles.FONT_SIZE_SUBTITLE
        )
        .fontWeight(FontWeight.Bold)
        .fontColor(GlobalStyles.TEXT_PRIMARY)
        .margin({ bottom: GlobalStyles.SPACING_LG })

      ForEach(this.devices, (device: DeviceInfo) => {
        Row() {
          Text(this.getDeviceTypeIcon(device.deviceType))
            .fontSize(20)

          Column() {
            Text(device.deviceName)
              .fontSize(GlobalStyles.FONT_SIZE_BODY)
              .fontColor(GlobalStyles.TEXT_PRIMARY)

            Text(device.isOnline ? '在线' : '离线')
              .fontSize(GlobalStyles.FONT_SIZE_TINY)
              .fontColor(
                device.isOnline ? GlobalStyles.SUCCESS_COLOR : GlobalStyles.TEXT_LIGHT
              )
          }
          .alignItems(HorizontalAlign.Start)
          .margin({ left: GlobalStyles.SPACING_SM })
          .layoutWeight(1)
        }
        .width('100%')
        .backgroundColor(
          this.selectedDevice?.deviceId === device.deviceId ? '#E6F7FF' : Color.White
        )
        .borderRadius(GlobalStyles.RADIUS_SM)
        .padding(GlobalStyles.SPACING_MD)
        .onClick((): void => {
          this.selectTargetDevice(device);
        })
      })

      Button('取消')
        .width('100%')
        .height(
          this.isElderMode ? ElderStyles.BUTTON_HEIGHT : GlobalStyles.BUTTON_HEIGHT
        )
        .fontSize(GlobalStyles.FONT_SIZE_BODY)
        .fontColor(GlobalStyles.TEXT_PRIMARY)
        .backgroundColor(GlobalStyles.BORDER_COLOR)
        .borderRadius(GlobalStyles.RADIUS_ROUND)
        .margin({ top: GlobalStyles.SPACING_LG })
        .onClick((): void => {
          this.showDeviceDialog = false;
        })
    }
    .width('90%')
    .constraintSize({ maxHeight: '70%' })
    .backgroundColor(Color.White)
    .borderRadius(GlobalStyles.RADIUS_LG)
    .padding(GlobalStyles.SPACING_LG)
  }

  @Builder
  SyncConfirmSheetContent(): void {
    Column() {
      Text('确认同步')
        .fontSize(
          this.isElderMode ? ElderStyles.FONT_SIZE_SUBTITLE : GlobalStyles.FONT_SIZE_SUBTITLE
        )
        .fontWeight(FontWeight.Bold)
        .fontColor(GlobalStyles.TEXT_PRIMARY)
        .margin({ bottom: GlobalStyles.SPACING_LG })

      if (this.selectedDevice != null) {
        InfoRow({ label: '目标设备', value: this.selectedDevice.deviceName })
        InfoRow({ label: '病历ID', value: this.selectedRecordId })
      }

      if (this.isSyncing) {
        Progress({ value: this.currentProgress, total: 100, type: ProgressType.Linear })
          .width('100%')
          .color(GlobalStyles.THEME_COLOR)
          .backgroundColor('#F0F0F0')
          .borderRadius(4)
          .margin({ top: GlobalStyles.SPACING_MD })

        Text(`同步进度: ${this.currentProgress}%`)
          .fontSize(GlobalStyles.FONT_SIZE_SMALL)
          .fontColor(GlobalStyles.THEME_COLOR)
          .width('100%')
          .textAlign(TextAlign.Center)
          .margin({ top: GlobalStyles.SPACING_SM })
      }

      if (this.syncResultMessage.length > 0 && !this.isSyncing) {
        Text(this.syncResultMessage)
          .fontSize(GlobalStyles.FONT_SIZE_SMALL)
          .fontColor(
            this.syncResultMessage.includes('成功')
              ? GlobalStyles.SUCCESS_COLOR
              : GlobalStyles.ERROR_COLOR
          )
          .width('100%')
          .textAlign(TextAlign.Center)
          .margin({ top: GlobalStyles.SPACING_MD })
      }

      Row() {
        Button('取消')
          .width('45%')
          .height(
            this.isElderMode ? ElderStyles.BUTTON_HEIGHT : GlobalStyles.BUTTON_HEIGHT
          )
          .fontSize(GlobalStyles.FONT_SIZE_BODY)
          .fontColor(GlobalStyles.TEXT_PRIMARY)
          .backgroundColor(GlobalStyles.BORDER_COLOR)
          .borderRadius(GlobalStyles.RADIUS_ROUND)
          .enabled(!this.isSyncing)
          .onClick((): void => {
            this.cancelSync();
          })

        Button('开始同步')
          .width('45%')
          .height(
            this.isElderMode ? ElderStyles.BUTTON_HEIGHT : GlobalStyles.BUTTON_HEIGHT
          )
          .fontSize(GlobalStyles.FONT_SIZE_BODY)
          .fontColor(Color.White)
          .backgroundColor(GlobalStyles.THEME_COLOR)
          .borderRadius(GlobalStyles.RADIUS_ROUND)
          .enabled(!this.isSyncing && this.selectedDevice != null)
          .onClick(async (): Promise<void> => {
            await this.startSync();
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: GlobalStyles.SPACING_LG })
    }
    .width('90%')
    .backgroundColor(Color.White)
    .borderRadius(GlobalStyles.RADIUS_LG)
    .padding(GlobalStyles.SPACING_LG)
  }
}

interface DeviceCardParams {
  device: DeviceInfo;
  isElderMode: boolean;
  isSyncing: boolean;
  onSelectTargetDevice: (d: DeviceInfo) => void;
}

@Builder
function DeviceCard($$: DeviceCardParams): void {
  Row() {
    Text(getDeviceTypeIconForCard($$.device.deviceType))
      .fontSize(24)

    Column() {
      Text($$.device.deviceName)
        .fontSize($$.isElderMode ? ElderStyles.FONT_SIZE_BODY : GlobalStyles.FONT_SIZE_BODY)
        .fontWeight(FontWeight.Medium)
        .fontColor(GlobalStyles.TEXT_PRIMARY)

      Row() {
        Text($$.device.isOnline ? '在线' : '离线')
          .fontSize(GlobalStyles.FONT_SIZE_TINY)
          .fontColor($$.device.isOnline ? GlobalStyles.SUCCESS_COLOR : GlobalStyles.TEXT_LIGHT)

        Text(` | ID: $${$$.device.deviceId.substring(0, 12)}...`)
          .fontSize(GlobalStyles.FONT_SIZE_TINY)
          .fontColor(GlobalStyles.TEXT_LIGHT)
          .margin({ left: GlobalStyles.SPACING_XS })
      }
      .width('100%')
      .margin({ top: 2 })
    }
    .alignItems(HorizontalAlign.Start)
    .layoutWeight(1)
    .margin({ left: GlobalStyles.SPACING_SM })

    Button('同步')
      .fontSize(GlobalStyles.FONT_SIZE_SMALL)
      .fontColor(Color.White)
      .backgroundColor(
        $$.device.isOnline ? GlobalStyles.THEME_COLOR : GlobalStyles.TEXT_LIGHT
      )
      .borderRadius(GlobalStyles.RADIUS_ROUND)
      .height(32)
      .enabled($$.device.isOnline && !$$.isSyncing)
      .onClick((): void => {
        $$.onSelectTargetDevice($$.device);
      })
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
  .justifyContent(FlexAlign.SpaceBetween)
  .alignItems(VerticalAlign.Center)
  .margin({ bottom: GlobalStyles.SPACING_SM })
}

function getDeviceTypeIconForCard(deviceType: DeviceType): string {
  switch (deviceType) {
    case DeviceType.PHONE:
      return '📱';
    case DeviceType.TABLET:
      return '📱';
    case DeviceType.WATCH:
      return '⌚';
    case DeviceType.HOSPITAL_TERMINAL:
      return '🏥';
    default:
      return '📡';
  }
}

interface SyncHistoryCardParams {
  task: SyncHistoryItem;
}

@Builder
function SyncHistoryCard($$: SyncHistoryCardParams): void {
  Column() {
    Row() {
      Text(getStatusTextForCard($$.task.status))
        .fontSize(GlobalStyles.FONT_SIZE_SMALL)
        .fontColor(getStatusColorForCard($$.task.status))
        .fontWeight(FontWeight.Medium)

      Blank()

      Text(formatTimestampForCard($$.task.startTime))
        .fontSize(GlobalStyles.FONT_SIZE_TINY)
        .fontColor(GlobalStyles.TEXT_LIGHT)
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)

    Text(`目标设备: $${$$.task.targetDeviceName}`)
      .fontSize(GlobalStyles.FONT_SIZE_SMALL)
      .fontColor(GlobalStyles.TEXT_SECONDARY)
      .width('100%')
      .margin({ top: GlobalStyles.SPACING_XS })

    Text(`病历ID: $${$$.task.recordId}`)
      .fontSize(GlobalStyles.FONT_SIZE_TINY)
      .fontColor(GlobalStyles.TEXT_LIGHT)
      .width('100%')

    if ($$.task.status === SyncStatus.SYNCING || $$.task.progress < 100) {
      Progress({ value: $$.task.progress, total: 100, type: ProgressType.Linear })
        .width('100%')
        .color(GlobalStyles.THEME_COLOR)
        .backgroundColor('#F0F0F0')
        .borderRadius(4)
        .margin({ top: GlobalStyles.SPACING_SM })

      Text(`${$$.task.progress}%`)
        .fontSize(GlobalStyles.FONT_SIZE_TINY)
        .fontColor(GlobalStyles.THEME_COLOR)
        .width('100%')
        .textAlign(TextAlign.Center)
        .margin({ top: GlobalStyles.SPACING_XS })
    }

    if ($$.task.completeTime != undefined) {
      Text(`完成时间: ${formatTimestampForCard($$.task.completeTime)}`)
        .fontSize(GlobalStyles.FONT_SIZE_TINY)
        .fontColor(GlobalStyles.TEXT_LIGHT)
        .width('100%')
        .margin({ top: GlobalStyles.SPACING_XS })
    }
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
  .margin({ bottom: GlobalStyles.SPACING_SM })
}

function getStatusTextForCard(status: SyncStatus): string {
  switch (status) {
    case SyncStatus.PENDING:
      return '等待中';
    case SyncStatus.SYNCING:
      return '同步中';
    case SyncStatus.COMPLETED:
      return '已完成';
    case SyncStatus.FAILED:
      return '失败';
    default:
      return '未知';
  }
}

function getStatusColorForCard(status: SyncStatus): string {
  switch (status) {
    case SyncStatus.PENDING:
      return GlobalStyles.TEXT_HINT;
    case SyncStatus.SYNCING:
      return GlobalStyles.THEME_COLOR;
    case SyncStatus.COMPLETED:
      return GlobalStyles.SUCCESS_COLOR;
    case SyncStatus.FAILED:
      return GlobalStyles.ERROR_COLOR;
    default:
      return GlobalStyles.TEXT_SECONDARY;
  }
}

function formatTimestampForCard(timestamp: number): string {
  const date: Date = new Date(timestamp);
  const month: string = String(date.getMonth() + 1).padStart(2, '0');
  const day: string = String(date.getDate()).padStart(2, '0');
  const hours: string = String(date.getHours()).padStart(2, '0');
  const minutes: string = String(date.getMinutes()).padStart(2, '0');
  return `${month}-${day} ${hours}:${minutes}`;
}

interface SyncInfoRowParams {
  label: string;
  value: string;
}

@Builder
function InfoRow($$: SyncInfoRowParams): void {
  Row() {
    Text($$.label)
      .fontSize(GlobalStyles.FONT_SIZE_SMALL)
      .fontColor(GlobalStyles.TEXT_SECONDARY)
      .width('80px')

    Text($$.value)
      .fontSize(GlobalStyles.FONT_SIZE_SMALL)
      .fontColor(GlobalStyles.TEXT_PRIMARY)
      .layoutWeight(1)
      .textAlign(TextAlign.End)
  }
  .width('100%')
  .margin({ bottom: GlobalStyles.SPACING_SM })
}
