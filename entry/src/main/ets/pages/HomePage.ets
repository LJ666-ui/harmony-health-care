import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';
import { AccessibilityConfig } from '../utils/AccessibilityConfig';

@Entry
@Component
export struct HomePage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State currentIndex: number = 0;
  private theme: AccessibilityConfig = new AccessibilityConfig();

  // 清理冲突，统一路由（匹配项目已配置页面）
  private quickActions: QuickAction[] = [
    { id: 'appointment', icon: '📅', title: '预约挂号', color: '#3498DB', route: 'pages/HospitalPage' },
    { id: 'medical_record', icon: '📋', title: '病历档案', color: '#9B59B6', route: 'pages/MedicalRecord' },
    { id: 'health_report', icon: '📊', title: '体检报告', color: '#2ECC71', route: 'pages/ReportPage' },
    { id: 'medication', icon: '💊', title: '用药提醒', color: '#E74C3C', route: 'pages/MedicationPage' },
    { id: 'consultation', icon: '👨‍⚕️', title: '在线问诊', color: '#F39C12', route: 'pages/ConsultationPage' },
    { id: 'emergency', icon: '🚑', title: '急救指南', color: '#E67E22', route: 'pages/EmergencyPage' },
    { id: 'health_edu', icon: '📚', title: '健康科普', color: '#1ABC9C', route: 'pages/SciencePage' },
    { id: 'family_doctor', icon: '🏥', title: '家庭医生', color: '#34495E', route: 'pages/FamilyDoctorPage' },
    { id: 'insurance', icon: '🛡️', title: '医保服务', color: '#8E44AD', route: 'pages/InsurancePage' },
    { id: 'rehabilitation', icon: '🧘', title: '康复训练', color: '#16A085', route: 'pages/RehabilitationPage' },
    { id: 'ai_assistant', icon: '🤖', title: 'AI助手', color: '#2980B9', route: 'pages/AIAssistantPage' },
    { id: 'distributed', icon: '🔗', title: '跨院协同', color: '#D35400', route: 'pages/DistributedCollaborationPage' },
    { id: 'digital_twin', icon: '🫀', title: '数字孪生', color: '#C0392B', route: 'pages/DigitalTwinPage' }
  ];

  aboutToAppear(): void {
    this.theme = AccessibilityConfig.getInstance();
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
        .padding({ left: 16, right: 16 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)

      Footer({ activeIndex: this.currentIndex })
    }
    .height('100%')
    .backgroundColor(AccessibilityConfig.getBackgroundColor())
  }

  @Builder buildWelcomeCard(): void {
    Row() {
      Column({ space: 8 }) {
        Text('欢迎使用')
          .fontSize(this.isElderMode ? 24 : 20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')

        Text('为您提供全方位的智慧医疗服务')
          .fontSize(this.isElderMode ? 16 : 14)
          .fontColor('#666666')
      }
      .alignItems(HorizontalAlign.Start)

      Blank()

      Text('👨‍⚕️')
        .fontSize(60)
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .border({ width: 1, color: '#F0F0F0' })
  }

  @Builder buildQuickActions(): void {
    Column({ space: 12 }) {
      Text('快捷服务')
        .fontSize(this.isElderMode ? 18 : 16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .width('100%')

      Grid() {
        ForEach(this.quickActions, (action: QuickAction) => {
          GridItem() {
            Column({ space: 8 }) {
              Text(action.icon)
                .fontSize(this.isElderMode ? 36 : 28)

              Text(action.title)
                .fontSize(this.isElderMode ? 14 : 12)
                .fontColor('#333333')
                .textAlign(TextAlign.Center)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .width('100%')
            .padding(12)
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
      .columnsTemplate('1fr 1fr 1fr 1fr')
      .rowsGap(12)
      .columnsGap(12)
      .width('100%')
    }
  }

  @Builder buildHealthTips(): void {
    Column({ space: 12 }) {
      Text('健康提示')
        .fontSize(this.isElderMode ? 18 : 16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .width('100%')

      ForEach([
        { icon: '💧', title: '记得多喝水', desc: '每天至少喝8杯水', color: '#3498DB' },
        { icon: '🚶', title: '适量运动', desc: '每天步行30分钟', color: '#2ECC71' },
        { icon: '😴', title: '充足睡眠', desc: '保证7-8小时睡眠', color: '#9B59B6' }
      ], (tip: HealthTip) => {
        Row({ space: 12 }) {
          Text(tip.icon)
            .fontSize(32)

          Column({ space: 4 }) {
            Text(tip.title)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')

            Text(tip.desc)
              .fontSize(13)
              .fontColor('#666666')
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Text('>')
            .fontSize(18)
            .fontColor('#CCCCCC')
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .border({ width: 1, color: '#F0F0F0' })
      }, (tip: HealthTip) => tip.title)
    }
  }
}

// 类型接口定义
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