import { router } from '@kit.ArkUI';
import { Footer } from '../components/Footer';
import { GlobalVoiceAssistant } from '../components/GlobalVoiceAssistant';
import { GlobalTheme } from '../global';
import { AccessibilityConfig } from '../utils/AccessibilityConfig';
import { BreakpointSystem, BreakpointType, BreakpointConstants } from '../utils/BreakpointSystem';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';

@Entry
@Component
export struct HomePage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @StorageLink('currentBreakpoint') currentBreakpoint: BreakpointType = BreakpointType.SM;
  @State currentIndex: number = 0;
  @State appointmentCount: string = '0';
  @State consultationCount: string = '0';
  @State healthConsultCount: string = '0';
  @State todayServiceCount: string = '0';
  private theme: AccessibilityConfig = new AccessibilityConfig();
  private breakpointSystem: BreakpointSystem = BreakpointSystem.getInstance();

  private quickActions: QuickAction[] = [
    // ===== 第一行：核心医疗服务 =====
    { id: 'appointment', icon: '📅', title: '预约挂号', color: '#1677FF', bgColor: '#E6F4FF', route: 'pages/HospitalPage' },
    { id: 'consultation', icon: '💬', title: '在线问诊', color: '#FA8C16', bgColor: '#FFF7E6', route: 'pages/ConsultationPage' },
    { id: 'chat', icon: '👥', title: '我的聊天', color: '#13C2C2', bgColor: '#E6FFFB', route: 'pages/PatientChatListPage' },
    { id: 'medical_record', icon: '📋', title: '病历档案', color: '#722ED1', bgColor: '#F9F0FF', route: 'pages/MedicalRecord' },
    { id: 'follow_up', icon: '🔔', title: '复诊通知', color: '#F5222D', bgColor: '#FFF1F0', route: 'pages/PatientFollowUpPage' },
    { id: 'health_report', icon: '📊', title: '体检报告', color: '#52C41A', bgColor: '#F6FFED', route: 'pages/ReportPage' },
    { id: 'medication', icon: '💊', title: '用药提醒', color: '#EB2F96', bgColor: '#FFF0F6', route: 'pages/MedicationPage' },
    { id: 'family_doctor', icon: '🏥', title: '家庭医生', color: '#1890FF', bgColor: '#E6F7FF', route: 'pages/FamilyDoctorPage' },

    // ===== 第二行：健康管理 =====
    { id: 'health_records', icon: '📝', title: '健康档案', color: '#13C2C2', bgColor: '#E6FFFB', route: 'pages/HealthRecords' },
    { id: 'rehabilitation', icon: '🧘', title: '康复训练', color: '#52C41A', bgColor: '#F6FFED', route: 'pages/RehabilitationPage' },
    { id: 'ar_navigation', icon: '🗺️', title: 'AR导航', color: '#FA8C16', bgColor: '#FFF7E6', route: 'pages/DestinationSelectPage' },
    { id: 'digital_twin', icon: '🫀', title: '数字孪生', color: '#F5222D', bgColor: '#FFF1F0', route: 'pages/DigitalTwinPage' },
    { id: 'ai_assistant', icon: '🤖', title: 'AI助手', color: '#1677FF', bgColor: '#E6F4FF', route: 'pages/AIAssistantPage' },
    { id: 'ai_consultation', icon: '🧠', title: 'AI多科会诊', color: '#722ED1', bgColor: '#F9F0FF', route: 'pages/AIConsultationPage' },
    { id: 'distributed', icon: '🔗', title: '跨院协同', color: '#FA541C', bgColor: '#FFF2E8', route: 'pages/DistributedCollaborationPage' },
    { id: 'insurance', icon: '🛡️', title: '医保服务', color: '#722ED1', bgColor: '#F9F0FF', route: 'pages/InsurancePage' },

    // ===== 第三行：智能应用 ⭐真实数据 =====
    { id: 'parking', icon: '🅿️', title: '智慧停车', color: '#595959', bgColor: '#F5F5F5', route: 'pages/ParkingListPage' },
    { id: 'smart_ward', icon: '🏨', title: '智慧病房', color: '#52C41A', bgColor: '#F6FFED', route: 'pages/SmartWardDevicesSimple' },
    { id: 'health_edu', icon: '📚', title: '健康科普', color: '#13C2C2', bgColor: '#E6FFFB', route: 'pages/SciencePage' },
    { id: 'emergency', icon: '🚑', title: '急救指南', color: '#FA8C16', bgColor: '#FFF7E6', route: 'pages/EmergencyPage' },
    { id: 'herbal', icon: '🌿', title: '中医百科', color: '#52C41A', bgColor: '#F6FFED', route: 'pages/HerbalListPage' },
    { id: 'food', icon: '🍎', title: '食物营养', color: '#F5222D', bgColor: '#FFF1F0', route: 'pages/FoodEncyclopediaPage' },
    { id: 'prescription', icon: '💉', title: '处方管理', color: '#722ED1', bgColor: '#F9F0FF', route: 'pages/PrescriptionListPage' },
    { id: 'transfer', icon: '🔄', title: '转院申请', color: '#FA8C16', bgColor: '#FFF7E6', route: 'pages/TransferApplyPage' },

    // ===== 第四行：工具与服务 =====
    { id: 'knowledge', icon: '🧠', title: '知识图谱', color: '#1677FF', bgColor: '#E6F4FF', route: 'pages/KnowledgeGraphPage' },
    { id: 'device_manage', icon: '📱', title: '设备管理', color: '#8C8C8C', bgColor: '#FAFAFA', route: 'pages/DeviceManagePage' },
    { id: 'data_auth', icon: '🔐', title: '数据授权', color: '#262626', bgColor: '#F5F5F5', route: 'pages/DataAuthPage' },
    { id: 'statistics', icon: '📈', title: '统计分析', color: '#13C2C2', bgColor: '#E6FFFB', route: 'pages/StatisticsPage' },
    { id: 'browse_history', icon: '🕐', title: '浏览历史', color: '#8C8C8C', bgColor: '#FAFAFA', route: 'pages/BrowseHistoryPage' },
    { id: 'daily_recommend', icon: '⭐', title: '每日推荐', color: '#FAAD14', bgColor: '#FFFBE6', route: 'pages/DailyRecommendPage' },
    { id: 'ancient_img', icon: '📜', title: '古医图谱', color: '#13C2C2', bgColor: '#E6FFFB', route: 'pages/AncientMedicalImgPage' },
    { id: 'imaging', icon: '🔬', title: '医学影像', color: '#722ED1', bgColor: '#F9F0FF', route: 'pages/ImageAnalysisPage' },
    { id: 'ai_test', icon: '🧪', title: 'AI功能测试', color: '#F5222D', bgColor: '#FFF1F0', route: 'pages/AITestPage' }
  ];

  async aboutToAppear(): Promise<void> {
    this.theme = AccessibilityConfig.getInstance();
    await this.loadHomeStatistics();
  }

  private async loadHomeStatistics(): Promise<void> {
    try {
      const userId = AppStorage.get<number>('userId');
      if (userId) {
        const appointmentResp = await HttpUtil.get<Object>(ApiConstants.APPOINTMENT_STATISTICS + userId);
        if (appointmentResp.success && appointmentResp.data) {
          const data = appointmentResp.data as Record<string, Object>;
          this.appointmentCount = String(data['totalCount'] ?? data['count'] ?? 0);
          this.consultationCount = String(data['consultationCount'] ?? 0);
          this.healthConsultCount = String(data['healthConsultCount'] ?? 0);
          this.todayServiceCount = String(data['todayServiceCount'] ?? 0);
        }
      }
      
      const systemStatsResp = await HttpUtil.get<Object>(ApiConstants.HEALTH_STATS_SYSTEM);
      if (systemStatsResp.success && systemStatsResp.data) {
        const data = systemStatsResp.data as Record<string, Object>;
        if (this.appointmentCount === '0') {
          this.appointmentCount = String(data['appointmentCount'] ?? 0);
        }
        if (this.consultationCount === '0') {
          this.consultationCount = String(data['consultationCount'] ?? 0);
        }
        if (this.healthConsultCount === '0') {
          this.healthConsultCount = String(data['healthConsultCount'] ?? 0);
        }
        if (this.todayServiceCount === '0') {
          this.todayServiceCount = String(data['todayServiceCount'] ?? data['totalUsers'] ?? 0);
        }
      }
    } catch (error) {
      console.error('[HomePage] 加载统计数据失败:', error);
    }
  }

  private getGridColumnsTemplate(): string {
    const columns = BreakpointConstants.QUICK_ACTION_COLUMNS[this.currentBreakpoint] ?? 4;
    return `1fr `.repeat(columns).trim();
  }

  private getContentMaxWidth(): number | string {
    if (this.currentBreakpoint === BreakpointType.LG) {
      return 840;
    } else if (this.currentBreakpoint === BreakpointType.MD) {
      return 600;
    }
    return '100%';
  }

  private getHorizontalPadding(): number {
    return this.breakpointSystem.getScaledPadding(16);
  }

  private getCardPadding(): number {
    return this.breakpointSystem.getScaledPadding(20);
  }

  private getActionItemPadding(): number {
    return this.breakpointSystem.getScaledPadding(12);
  }

  private getIconFontSize(): number {
    const base = this.isElderMode ? 36 : 28;
    return this.breakpointSystem.getIconSize(base);
  }

  private getTitleFontSize(): number {
    const base = this.isElderMode ? 24 : 20;
    return Math.round(base * this.breakpointSystem.getFontSizeScale());
  }

  private getBodyFontSize(): number {
    const base = this.isElderMode ? 16 : 14;
    return Math.round(base * this.breakpointSystem.getFontSizeScale());
  }

  private getSectionTitleFontSize(): number {
    const base = this.isElderMode ? 18 : 16;
    return Math.round(base * this.breakpointSystem.getFontSizeScale());
  }

  build() {
    Stack() {
      Column() {
        Scroll() {
          Column({ space: this.isElderMode ? 16 : 12 }) {
            this.buildWelcomeCard()
            this.buildQuickActions()
            this.buildHealthTips()
          }
          .width('100%')
          .constraintSize({ maxWidth: this.getContentMaxWidth() })
          .padding({
            left: this.getHorizontalPadding(),
            right: this.getHorizontalPadding()
          })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
        .width('100%')
        .align(Alignment.Top)

        Footer({ activeIndex: this.currentIndex })
      }
      .height('100%')
      .backgroundColor('#F5F7FA')

      GlobalVoiceAssistant()
    }
    .height('100%')
  }

  @Builder buildWelcomeCard(): void {
    Column() {
      Row() {
        Column({ space: 10 }) {
          Text('您好，欢迎使用')
            .fontSize(this.getTitleFontSize())
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')

          Text('智慧医疗健康平台为您提供全方位服务')
            .fontSize(this.getBodyFontSize())
            .fontColor('#FFFFFF')
            .opacity(0.9)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Column({ space: 8 }) {
          Text('👥')
            .fontSize(40)

          Text('今日已服务')
            .fontSize(11)
            .fontColor('#FFFFFF')
            .opacity(0.85)

          Text(`${this.todayServiceCount} 人`)
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
        }
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')

      Row({ space: 12 }) {
        this.buildStatItem('预约挂号', this.appointmentCount, '次')
        this.buildStatItem('在线问诊', this.consultationCount, '人')
        this.buildStatItem('健康咨询', this.healthConsultCount, '条')
      }
      .width('100%')
      .margin({ top: 20 })
      .padding({ top: 16 })
      .border({ width: { top: 1 }, color: '#FFFFFF30' })
    }
    .width('100%')
    .padding(this.getCardPadding())
    .linearGradient({
      angle: 135,
      colors: [['#1677FF', 0], ['#0958D9', 0.5], ['#003A8C', 1]],
      direction: GradientDirection.RightBottom
    })
    .borderRadius(16)
    .shadow({
      radius: 20,
      color: '#1677FF20',
      offsetX: 0,
      offsetY: 8
    })
  }

  @Builder buildStatItem(title: string, value: string, unit: string): void {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(this.isElderMode ? 24 : 20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')

      Text(`${title}${unit}`)
        .fontSize(12)
        .fontColor('#FFFFFF')
        .opacity(0.85)
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder buildQuickActions(): void {
    Column({ space: 16 }) {
      Column({ space: 16 }) {
        Row() {
          Text('🏥 医疗服务')
            .fontSize(this.getSectionTitleFontSize())
            .fontWeight(FontWeight.Bold)
            .fontColor('#1677FF')

          Blank()

          Text('常用医疗功能')
            .fontSize(13)
            .fontColor('#999999')
        }
        .width('100%')

        Row({ space: 12 }) {
          ForEach(this.getMedicalServices(), (action: QuickAction) => {
            Column({ space: 10 }) {
              Text(action.icon)
                .fontSize(32)

              Text(action.title)
                .fontSize(13)
                .fontColor('#333333')
                .fontWeight(FontWeight.Medium)
                .textAlign(TextAlign.Center)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .layoutWeight(1)
            .padding({ top: 16, bottom: 14 })
            .backgroundColor(action.bgColor)
            .borderRadius(12)
            .onClick(() => {
              try {
                router.pushUrl({ url: action.route });
              } catch (error) {
                console.error('导航失败:', error);
              }
            })
          }, (action: QuickAction) => action.id)
        }
        .width('100%')
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
      .shadow({ radius: 8, color: '#00000008', offsetX: 0, offsetY: 2 })

      Column({ space: 16 }) {
        Row() {
          Text('⚡ 快捷服务')
            .fontSize(this.getSectionTitleFontSize())
            .fontWeight(FontWeight.Bold)
            .fontColor('#262626')
        }
        .width('100%')

        Grid() {
          ForEach(this.getQuickServices(), (action: QuickAction) => {
            GridItem() {
              Column({ space: 10 }) {
                Text(action.icon)
                  .fontSize(this.getIconFontSize())

                Text(action.title)
                  .fontSize(this.isElderMode ? 14 : 12)
                  .fontColor('#333333')
                  .fontWeight(FontWeight.Medium)
                  .textAlign(TextAlign.Center)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .width('100%')
              .padding({ top: 16, bottom: 12 })
              .backgroundColor(action.bgColor)
              .borderRadius(12)
              .onClick(() => {
                try {
                  router.pushUrl({ url: action.route });
                } catch (error) {
                  console.error('导航失败:', error);
                }
              })
            }
          }, (action: QuickAction) => action.id)
        }
        .columnsTemplate(this.getGridColumnsTemplate())
        .rowsGap(12)
        .columnsGap(12)
        .width('100%')

        Column({ space: 12 }) {
          Text('更多服务')
            .fontSize(this.getSectionTitleFontSize())
            .fontWeight(FontWeight.Bold)
            .fontColor('#262626')
            .width('100%')

          Grid() {
            ForEach(this.getMoreServices(), (action: QuickAction) => {
              GridItem() {
                Column({ space: 10 }) {
                  Text(action.icon)
                    .fontSize(this.isElderMode ? 32 : 24)

                  Text(action.title)
                    .fontSize(this.isElderMode ? 13 : 11)
                    .fontColor('#666666')
                    .textAlign(TextAlign.Center)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }
                .width('100%')
                .padding({ top: 12, bottom: 10 })
                .backgroundColor('#FFFFFF')
                .borderRadius(10)
                .border({ width: 1, color: '#F0F0F0' })
                .onClick(() => {
                  try {
                    router.pushUrl({ url: action.route });
                  } catch (error) {
                    console.error('导航失败:', error);
                  }
                })
              }
            }, (action: QuickAction) => action.id)
          }
          .columnsTemplate(this.getGridColumnsTemplate())
          .rowsGap(10)
          .columnsGap(10)
          .width('100%')
        }
      }
    }
  }

  private getMedicalServices(): QuickAction[] {
    return this.quickActions.filter((action: QuickAction) =>
      ['appointment', 'follow_up', 'health_report', 'medical_record'].includes(action.id)
    );
  }

  private getQuickServices(): QuickAction[] {
    const excludeIds: string[] = ['appointment', 'follow_up', 'health_report', 'medical_record'];
    return this.quickActions.slice(0, 8).filter((action: QuickAction) =>
      !excludeIds.includes(action.id)
    );
  }

  private getMoreServices(): QuickAction[] {
    const excludeIds: string[] = ['appointment', 'follow_up', 'health_report', 'medical_record'];
    return this.quickActions.slice(8).filter((action: QuickAction) =>
      !excludeIds.includes(action.id)
    );
  }

  @Builder buildHealthTips(): void {
    Column({ space: 16 }) {
      Row() {
        Text('健康提示')
          .fontSize(this.getSectionTitleFontSize())
          .fontWeight(FontWeight.Bold)
          .fontColor('#262626')

        Blank()

        Text('更多')
          .fontSize(13)
          .fontColor('#999999')
      }
      .width('100%')

      if (this.currentBreakpoint === BreakpointType.LG) {
        Row({ space: 12 }) {
          ForEach(this.getHealthTips(), (tip: HealthTip) => {
            this.buildHealthTipCard(tip)
          }, (tip: HealthTip) => tip.title)
        }
        .width('100%')
      } else {
        Column({ space: 12 }) {
          ForEach(this.getHealthTips(), (tip: HealthTip) => {
            this.buildHealthTipCard(tip)
          }, (tip: HealthTip) => tip.title)
        }
        .width('100%')
      }
    }
  }

  @Builder buildHealthTipCard(tip: HealthTip): void {
    Row({ space: 12 }) {
      Column() {
        Text(tip.icon)
          .fontSize(this.breakpointSystem.getIconSize(32))
      }
      .width(48)
      .height(48)
      .backgroundColor(tip.color + '15')
      .borderRadius(12)
      .justifyContent(FlexAlign.Center)

      Column({ space: 6 }) {
        Text(tip.title)
          .fontSize(Math.round(16 * this.breakpointSystem.getFontSizeScale()))
          .fontWeight(FontWeight.Medium)
          .fontColor('#262626')

        Text(tip.desc)
          .fontSize(Math.round(13 * this.breakpointSystem.getFontSizeScale()))
          .fontColor('#8C8C8C')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Column() {
        Text('查看详情')
          .fontSize(12)
          .fontColor(tip.color)
      }
      .backgroundColor(tip.color + '10')
      .borderRadius(12)
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({
      radius: 8,
      color: '#00000008',
      offsetX: 0,
      offsetY: 2
    })
  }

  private getHealthTips(): HealthTip[] {
    return [
      { icon: '💧', title: '记得多喝水', desc: '每天至少喝8杯水保持水分平衡', color: '#1677FF' },
      { icon: '🚶', title: '适量运动', desc: '每天步行30分钟增强体质', color: '#52C41A' },
      { icon: '😴', title: '充足睡眠', desc: '保证7-8小时高质量睡眠', color: '#722ED1' }
    ];
  }
}

interface QuickAction {
  id: string;
  icon: string;
  title: string;
  color: string;
  bgColor: string;
  route: string;
}

interface HealthTip {
  icon: string;
  title: string;
  desc: string;
  color: string;
}
