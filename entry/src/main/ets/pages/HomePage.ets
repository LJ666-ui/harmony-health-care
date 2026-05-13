import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';
import { AccessibilityConfig } from '../utils/AccessibilityConfig';
import { BreakpointSystem, BreakpointType, BreakpointConstants } from '../utils/BreakpointSystem';

@Entry
@Component
export struct HomePage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @StorageLink('currentBreakpoint') currentBreakpoint: BreakpointType = BreakpointType.SM;
  @State currentIndex: number = 0;
  private theme: AccessibilityConfig = new AccessibilityConfig();
  private breakpointSystem: BreakpointSystem = BreakpointSystem.getInstance();

  private quickActions: QuickAction[] = [
    // ===== 第一行：核心医疗服务 =====
    { id: 'appointment', icon: '📅', title: '预约挂号', color: '#3498DB', route: 'pages/HospitalPage' },
    { id: 'consultation', icon: '👨‍⚕️', title: '在线问诊', color: '#F39C12', route: 'pages/ConsultationPage' },
    { id: 'chat', icon: '💬', title: '我的聊天', color: '#13C2C2', route: 'pages/PatientChatListPage' },
    { id: 'medical_record', icon: '📋', title: '病历档案', color: '#9B59B6', route: 'pages/MedicalRecord' },
    { id: 'follow_up', icon: '🔔', title: '复诊通知', color: '#E74C3C', route: 'pages/PatientFollowUpPage' },
    { id: 'health_report', icon: '📊', title: '体检报告', color: '#2ECC71', route: 'pages/ReportPage' },
    { id: 'medication', icon: '💊', title: '用药提醒', color: '#E74C3C', route: 'pages/MedicationPage' },
    { id: 'family_doctor', icon: '🏥', title: '家庭医生', color: '#34495E', route: 'pages/FamilyDoctorPage' },

    // ===== 第二行：健康管理 =====
    { id: 'health_records', icon: '📝', title: '健康档案', color: '#1ABC9C', route: 'pages/HealthRecords' },
    { id: 'rehabilitation', icon: '🧘', title: '康复训练', color: '#16A085', route: 'pages/RehabilitationPage' },
    { id: 'ar_navigation', icon: '🗺️', title: 'AR导航', color: '#E67E22', route: 'pages/DestinationSelectPage' },
    { id: 'digital_twin', icon: '🫀', title: '数字孪生', color: '#C0392B', route: 'pages/DigitalTwinPage' },
    { id: 'ai_assistant', icon: '🤖', title: 'AI助手', color: '#2980B9', route: 'pages/AIAssistantPage' },
    { id: 'distributed', icon: '🔗', title: '跨院协同', color: '#D35400', route: 'pages/DistributedCollaborationPage' },
    { id: 'insurance', icon: '🛡️', title: '医保服务', color: '#8E44AD', route: 'pages/InsurancePage' },

    // ===== 第三行：智能应用 ⭐真实数据 =====
    { id: 'parking', icon: '🅿️', title: '智慧停车', color: '#34495E', route: 'pages/ParkingListPage' },
    { id: 'smart_ward', icon: '🏨', title: '智慧病房', color: '#27AE60', route: 'pages/SmartWardDevicesSimple' },
    { id: 'health_edu', icon: '📚', title: '健康科普', color: '#1ABC9C', route: 'pages/SciencePage' },
    { id: 'emergency', icon: '🚑', title: '急救指南', color: '#E67E22', route: 'pages/EmergencyPage' },
    { id: 'herbal', icon: '🌿', title: '中医百科', color: '#27AE60', route: 'pages/HerbalListPage' },
    { id: 'food', icon: '🍎', title: '食物营养', color: '#E74C3C', route: 'pages/FoodEncyclopediaPage' },
    { id: 'prescription', icon: '💉', title: '处方管理', color: '#9B59B6', route: 'pages/PrescriptionListPage' },
    { id: 'transfer', icon: '🔄', title: '转院申请', color: '#F39C12', route: 'pages/TransferApplyPage' },

    // ===== 第四行：工具与服务 =====
    { id: 'knowledge', icon: '🧠', title: '知识图谱', color: '#3498DB', route: 'pages/KnowledgeGraphPage' },
    { id: 'device_manage', icon: '📱', title: '设备管理', color: '#95A5A6', route: 'pages/DeviceManagePage' },
    { id: 'data_auth', icon: '🔐', title: '数据授权', color: '#2C3E50', route: 'pages/DataAuthPage' },
    { id: 'statistics', icon: '📈', title: '统计分析', color: '#16A085', route: 'pages/StatisticsPage' },
    { id: 'browse_history', icon: '🕐', title: '浏览历史', color: '#7F8C8D', route: 'pages/BrowseHistoryPage' },
    { id: 'daily_recommend', icon: '⭐', title: '每日推荐', color: '#F1C40F', route: 'pages/DailyRecommendPage' },
    { id: 'ancient_img', icon: '📜', title: '古医图谱', color: '#1ABC9C', route: 'pages/AncientMedicalImgPage' },
    { id: 'imaging', icon: '🔬', title: '医学影像', color: '#8E44AD', route: 'pages/ImageAnalysisPage' }
  ];

  aboutToAppear(): void {
    this.theme = AccessibilityConfig.getInstance();
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
    Column() {
      Header({ title: '智慧医疗健康平台' })

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
    .backgroundColor(AccessibilityConfig.getBackgroundColor())
  }

  @Builder buildWelcomeCard(): void {
    Row() {
      Column({ space: 8 }) {
        Text('欢迎使用')
          .fontSize(this.getTitleFontSize())
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')

        Text('为您提供全方位的智慧医疗服务')
          .fontSize(this.getBodyFontSize())
          .fontColor('#666666')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Text('👨‍⚕️')
        .fontSize(this.breakpointSystem.getIconSize(60))
    }
    .width('100%')
    .padding(this.getCardPadding())
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .border({ width: 1, color: '#F0F0F0' })
  }

  @Builder buildQuickActions(): void {
    Column({ space: 12 }) {
      Text('快捷服务')
        .fontSize(this.getSectionTitleFontSize())
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .width('100%')

      Grid() {
        ForEach(this.quickActions, (action: QuickAction) => {
          GridItem() {
            Column({ space: 8 }) {
              Text(action.icon)
                .fontSize(this.getIconFontSize())

              Text(action.title)
                .fontSize(this.isElderMode ? 14 : 12)
                .fontColor('#333333')
                .textAlign(TextAlign.Center)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .width('100%')
            .padding(this.getActionItemPadding())
            .backgroundColor('#FFFFFF')
            .borderRadius(8)
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
    }
  }

  @Builder buildHealthTips(): void {
    Column({ space: 12 }) {
      Text('健康提示')
        .fontSize(this.getSectionTitleFontSize())
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
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
      Text(tip.icon)
        .fontSize(this.breakpointSystem.getIconSize(32))

      Column({ space: 4 }) {
        Text(tip.title)
          .fontSize(Math.round(16 * this.breakpointSystem.getFontSizeScale()))
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')

        Text(tip.desc)
          .fontSize(Math.round(13 * this.breakpointSystem.getFontSizeScale()))
          .fontColor('#666666')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Text('>')
        .fontSize(18)
        .fontColor('#CCCCCC')
    }
    .width('100%')
    .padding(this.getCardPadding())
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
    .border({ width: 1, color: '#F0F0F0' })
  }

  private getHealthTips(): HealthTip[] {
    return [
      { icon: '💧', title: '记得多喝水', desc: '每天至少喝8杯水', color: '#3498DB' },
      { icon: '🚶', title: '适量运动', desc: '每天步行30分钟', color: '#2ECC71' },
      { icon: '😴', title: '充足睡眠', desc: '保证7-8小时睡眠', color: '#9B59B6' }
    ];
  }
}

interface QuickAction {
  id: string;
  icon: string;
  title: string;
  color: string;
  route: string;
}

interface HealthTip {
  icon: string;
  title: string;
  desc: string;
  color: string;
}
