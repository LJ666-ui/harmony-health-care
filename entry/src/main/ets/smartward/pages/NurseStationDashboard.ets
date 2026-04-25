/**
 * 护士站监控大屏主页面
 * 包含病房概览、告警中心、护理计划三个区域
 */

import { SmartWardRoom, WardOverviewInfo } from '../../models/SmartWardModels';
import { WardAlert } from '../../models/SmartWardAlertModels';
import { CareTask } from '../../models/SmartWardTaskModels';
import { PatientRiskLevel } from '../../models/SmartWardEnums';
import { DeviceManager } from '../core/managers/DeviceManager';
import { AlertManager } from '../core/managers/AlertManager';
import { DataCollector } from '../core/collectors/DataCollector';

@Entry
@Component
struct NurseStationDashboard {
  @State rooms: WardOverviewInfo[] = [];
  @State alerts: WardAlert[] = [];
  @State tasks: CareTask[] = [];
  @State selectedTab: string = 'overview';
  @State currentTime: string = '';
  @State currentDate: string = '';
  @State alertCount: number = 0;
  @State patientCount: number = 0;
  @State autoRefreshEnabled: boolean = true;

  private deviceManager = DeviceManager.getInstance();
  private alertManager = AlertManager.getInstance();
  private dataCollector = DataCollector.getInstance();

  aboutToAppear(): void {
    console.log('NurseStationDashboard: aboutToAppear');

    // 初始化数据
    this.loadInitialData();

    // 更新时间
    this.updateTime();
    setInterval(() => {
      this.updateTime();
    }, 1000);

    // 订阅告警变化
    this.alertManager.subscribe((alerts) => {
      this.alerts = alerts;
      this.alertCount = this.alerts.filter(a => !a.isAcknowledged).length;
    });

    // 启动数据采集
    if (this.autoRefreshEnabled) {
      this.dataCollector.startCollection(5000);
    }
  }

  aboutToDisappear(): void {
    console.log('NurseStationDashboard: aboutToDisappear');

    // 停止数据采集
    this.dataCollector.stopCollection();

    // 取消订阅
    this.alertManager.unsubscribe(() => {});
  }

  /**
   * 加载初始数据
   */
  private loadInitialData(): void {
    // 这里应该从服务端加载数据
    // 暂时使用模拟数据
    console.log('NurseStationDashboard: Loading initial data');

    // 加载房间数据（模拟）
    this.rooms = this.generateMockRooms();

    // 加载告警数据
    this.alerts = this.alertManager.getAlerts();
    this.alertCount = this.alerts.filter(a => !a.isAcknowledged).length;

    // 加载护理任务（模拟）
    this.tasks = this.generateMockTasks();

    this.patientCount = this.rooms.length;
  }

  /**
   * 更新时间
   */
  private updateTime(): void {
    const now = new Date();
    this.currentTime = `${String(now.getHours()).padStart(2, '0')}:${String(now.getMinutes()).padStart(2, '0')}:${String(now.getSeconds()).padStart(2, '0')}`;
    this.currentDate = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}`;
  }

  /**
   * 生成模拟房间数据
   */
  private generateMockRooms(): WardOverviewInfo[] {
    return [
      {
        roomId: 'ROOM_301',
        roomNumber: '301',
        bedId: 'BED_301_A',
        patientName: '张**',
        patientAge: 65,
        patientGender: 'male',
        riskLevel: PatientRiskLevel.HIGH,
        vitalSigns: {
          heartRate: 72,
          oxygenSaturation: 98,
          systolicBP: 120,
          diastolicBP: 80
        },
        deviceOnlineCount: 4,
        deviceTotalCount: 4,
        lastAlertMessage: '心率异常',
        lastAlertTime: Date.now() - 3600000
      },
      {
        roomId: 'ROOM_302',
        roomNumber: '302',
        bedId: 'BED_302_A',
        patientName: '李**',
        patientAge: 58,
        patientGender: 'female',
        riskLevel: PatientRiskLevel.MEDIUM,
        vitalSigns: {
          heartRate: 85,
          oxygenSaturation: 94,
          systolicBP: 135,
          diastolicBP: 88
        },
        deviceOnlineCount: 4,
        deviceTotalCount: 4
      }
    ];
  }

  /**
   * 生成模拟护理任务
   */
  private generateMockTasks(): CareTask[] {
    return [
      {
        taskId: 'TASK_001',
        taskName: '测量血压',
        taskType: 'VITAL_SIGNS',
        scheduledTime: Date.now() + 3600000,
        frequency: 'q4h',
        assignedNurse: '李护士',
        roomId: 'ROOM_301',
        roomNumber: '301',
        patientId: 'P001',
        patientName: '张**',
        status: 'pending' as any,
        isRecurring: true,
        priority: 8
      }
    ];
  }

  build() {
    Column() {
      // 顶部状态栏
      this.TopStatusBar()

      // 主内容区
      Row() {
        // 左侧：病房概览
        Column() {
          this.WardOverviewSection()
        }
        .layoutWeight(2)
        .margin({ right: 10 })

        // 右侧：告警中心和护理计划
        Column() {
          // 告警中心
          this.AlertCenterSection()

          // 护理计划
          this.CarePlanSection()
        }
        .layoutWeight(1)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  /**
   * 顶部状态栏
   */
  @Builder TopStatusBar() {
    Row() {
      // 时间和日期
      Column() {
        Text(this.currentTime)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')

        Text(this.currentDate)
          .fontSize(14)
          .fontColor('#666666')
          .margin({ top: 5 })
      }
      .alignItems(HorizontalAlign.Start)

      Blank()

      // 统计信息
      Row() {
        this.StatItem('在院患者', `${this.patientCount}人`)
        this.StatItem('待处理告警', `${this.alertCount}`, this.alertCount > 0)
      }
      .margin({ right: 20 })

      // 快捷操作按钮
      Row() {
        Button('全病区广播')
          .fontSize(14)
          .margin({ right: 10 })

        Button('夜间模式')
          .fontSize(14)
          .margin({ right: 10 })

        Button('交接班报告')
          .fontSize(14)
      }
    }
    .width('100%')
    .height(80)
    .padding({ left: 20, right: 20 })
    .backgroundColor('#FFFFFF')
    .shadow({ radius: 2, color: '#00000010' })
  }

  /**
   * 统计项组件
   */
  @Builder StatItem(label: string, value: string, isUrgent: boolean = false) {
    Column() {
      Text(label)
        .fontSize(12)
        .fontColor('#666666')

      Text(value)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(isUrgent ? '#FF0000' : '#333333')
        .margin({ top: 5 })
    }
    .margin({ right: 20 })
  }

  /**
   * 病房概览区域
   */
  @Builder WardOverviewSection() {
    Column() {
      Text('病房概览')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 15 })

      // 病房卡片列表
      List() {
        ForEach(this.rooms, (room: WardOverviewInfo) => {
          ListItem() {
            this.WardCard(room)
          }
        })
      }
      .layoutWeight(1)
      .divider({ strokeWidth: 1, color: '#EEEEEE' })
    }
    .width('100%')
    .height('100%')
    .padding(15)
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
    .shadow({ radius: 2, color: '#00000010' })
  }

  /**
   * 病房卡片组件
   */
  @Builder WardCard(room: WardOverviewInfo) {
    Row() {
      // 房间号和患者信息
      Column() {
        Row() {
          Text(`${room.roomNumber}病房`)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)

          Text(`${room.patientName} (${room.patientAge}岁)`)
            .fontSize(14)
            .margin({ left: 10 })
        }

        // 风险等级标签
        Row() {
          this.RiskLevelTag(room.riskLevel)
        }
        .margin({ top: 10 })

        // 生命体征
        Row() {
          this.VitalSignItem('心率', `${room.vitalSigns.heartRate}bpm`)
          this.VitalSignItem('血氧', `${room.vitalSigns.oxygenSaturation}%`)
          this.VitalSignItem('血压', `${room.vitalSigns.systolicBP}/${room.vitalSigns.diastolicBP}`)
        }
        .margin({ top: 10 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 设备状态
      Text(`设备 ${room.deviceOnlineCount}/${room.deviceTotalCount}`)
        .fontSize(12)
        .fontColor('#666666')

      // 查看按钮
      Button('查看')
        .fontSize(12)
        .margin({ left: 10 })
    }
    .width('100%')
    .padding(15)
    .backgroundColor('#FAFAFA')
    .borderRadius(6)
  }

  /**
   * 风险等级标签
   */
  @Builder RiskLevelTag(level: PatientRiskLevel) {
    Text(this.getRiskLevelText(level))
      .fontSize(10)
      .fontColor('#FFFFFF')
      .padding({ left: 8, right: 8, top: 4, bottom: 4 })
      .borderRadius(4)
      .backgroundColor(this.getRiskLevelColor(level))
  }

  /**
   * 生命体征项
   */
  @Builder VitalSignItem(label: string, value: string) {
    Column() {
      Text(label)
        .fontSize(10)
        .fontColor('#999999')

      Text(value)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .margin({ top: 5 })
    }
    .margin({ right: 20 })
  }

  /**
   * 告警中心区域
   */
  @Builder AlertCenterSection() {
    Column() {
      Row() {
        Text('告警中心')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)

        Blank()

        Text('查看全部')
          .fontSize(12)
          .fontColor('#1890FF')
      }
      .width('100%')
      .margin({ bottom: 10 })

      // 告警列表
      List() {
        ForEach(this.alerts.slice(0, 5), (alert: WardAlert) => {
          ListItem() {
            this.AlertCard(alert)
          }
        })
      }
      .layoutWeight(1)
      .divider({ strokeWidth: 1, color: '#EEEEEE' })
    }
    .width('100%')
    .height('50%')
    .padding(15)
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
    .shadow({ radius: 2, color: '#00000010' })
    .margin({ bottom: 10 })
  }

  /**
   * 告警卡片组件
   */
  @Builder AlertCard(alert: WardAlert) {
    Row() {
      // 告警等级标识
      Text(this.getAlertLevelText(alert.level))
        .fontSize(10)
        .fontColor('#FFFFFF')
        .padding({ left: 6, right: 6, top: 3, bottom: 3 })
        .borderRadius(3)
        .backgroundColor(this.getAlertLevelColor(alert.level))

      // 告警消息
      Column() {
        Text(alert.message)
          .fontSize(12)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(`${alert.roomNumber}病房`)
          .fontSize(10)
          .fontColor('#999999')
          .margin({ top: 5 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 10 })
    }
    .width('100%')
    .padding(10)
    .backgroundColor(alert.isAcknowledged ? '#F9F9F9' : '#FFF5F5')
    .borderRadius(4)
  }

  /**
   * 护理计划区域
   */
  @Builder CarePlanSection() {
    Column() {
      Row() {
        Text('护理计划')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)

        Blank()

        Text('查看全部')
          .fontSize(12)
          .fontColor('#1890FF')
      }
      .width('100%')
      .margin({ bottom: 10 })

      // 护理任务列表
      List() {
        ForEach(this.tasks.slice(0, 5), (task: CareTask) => {
          ListItem() {
            this.TaskCard(task)
          }
        })
      }
      .layoutWeight(1)
      .divider({ strokeWidth: 1, color: '#EEEEEE' })
    }
    .width('100%')
    .layoutWeight(1)
    .padding(15)
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
    .shadow({ radius: 2, color: '#00000010' })
  }

  /**
   * 任务卡片组件
   */
  @Builder TaskCard(task: CareTask) {
    Row() {
      // 任务信息
      Column() {
        Text(task.taskName)
          .fontSize(12)

        Text(`${task.roomNumber}病房 - ${task.assignedNurse}`)
          .fontSize(10)
          .fontColor('#999999')
          .margin({ top: 5 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 状态标签
      Text(this.getTaskStatusText(task.status))
        .fontSize(10)
        .fontColor('#FFFFFF')
        .padding({ left: 6, right: 6, top: 3, bottom: 3 })
        .borderRadius(3)
        .backgroundColor(this.getTaskStatusColor(task.status))
    }
    .width('100%')
    .padding(10)
    .backgroundColor('#FAFAFA')
    .borderRadius(4)
  }

  // 辅助方法
  private getRiskLevelText(level: PatientRiskLevel): string {
    const map: Record<PatientRiskLevel, string> = {
      [PatientRiskLevel.CRITICAL]: '重症',
      [PatientRiskLevel.HIGH]: '高危',
      [PatientRiskLevel.MEDIUM]: '中等',
      [PatientRiskLevel.LOW]: '低危'
    };
    return map[level];
  }

  private getRiskLevelColor(level: PatientRiskLevel): string {
    const map: Record<PatientRiskLevel, string> = {
      [PatientRiskLevel.CRITICAL]: '#FF0000',
      [PatientRiskLevel.HIGH]: '#FF6600',
      [PatientRiskLevel.MEDIUM]: '#FFAA00',
      [PatientRiskLevel.LOW]: '#00AA00'
    };
    return map[level];
  }

  private getAlertLevelText(level: string): string {
    const map: Record<string, string> = {
      'EMERGENCY': '急救',
      'URGENT': '紧急',
      'WARNING': '警告',
      'INFO': '信息'
    };
    return map[level] || level;
  }

  private getAlertLevelColor(level: string): string {
    const map: Record<string, string> = {
      'EMERGENCY': '#FF0000',
      'URGENT': '#FF6600',
      'WARNING': '#FFAA00',
      'INFO': '#1890FF'
    };
    return map[level] || '#999999';
  }

  private getTaskStatusText(status: string): string {
    const map: Record<string, string> = {
      'PENDING': '待处理',
      'IN_PROGRESS': '进行中',
      'COMPLETED': '已完成'
    };
    return map[status] || status;
  }

  private getTaskStatusColor(status: string): string {
    const map: Record<string, string> = {
      'PENDING': '#FFAA00',
      'IN_PROGRESS': '#1890FF',
      'COMPLETED': '#00AA00'
    };
    return map[status] || '#999999';
  }
}
