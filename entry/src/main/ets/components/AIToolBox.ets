import { router } from '@kit.ArkUI';
import { AccessibilityConfig } from '../utils/AccessibilityConfig';

export interface AIToolItem {
  id: string;
  icon: string;
  title: string;
  subtitle: string;
  gradientColors: [string, string];
  route: string;
}

@Component
export struct AIToolCard {
  @Prop tool: AIToolItem;
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  build() {
    Column({ space: 10 }) {
      Text(this.tool.icon)
        .fontSize(36)

      Text(this.tool.title)
        .fontSize(this.isElderMode ? 15 : 13)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .textAlign(TextAlign.Center)
        .maxLines(1)

      Text(this.tool.subtitle)
        .fontSize(this.isElderMode ? 11 : 10)
        .fontColor('#FFFFFF99')
        .textAlign(TextAlign.Center)
        .maxLines(1)
    }
    .width('100%')
    .height(100)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .linearGradient({
      angle: 135,
      colors: [[this.tool.gradientColors[0], 0], [this.tool.gradientColors[1], 1]]
    })
    .borderRadius(12)
    .onClick(() => {
      try {
        router.pushUrl({ url: this.tool.route });
      } catch (error) {
        console.error('导航失败:', error);
      }
    })
  }
}

@Component
export struct AIToolBox {
  @Prop tools: AIToolItem[] = [];
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  private defaultTools: AIToolItem[] = [
    {
      id: 'imaging_ai',
      icon: '🔬🏥',
      title: '影像AI病灶识别分析',
      subtitle: 'X光/CT/MRI智能诊断',
      gradientColors: ['#9B59B6', '#8E44AD'],
      route: 'pages/ImageAnalysisPage'
    },
    {
      id: 'risk_assessment',
      icon: '🧠⚡',
      title: '智能风险评估工具',
      subtitle: '端侧AI·本地隐私保护',
      gradientColors: ['#E74C3C', '#C0392B'],
      route: 'pages/RiskAssessmentPage'
    },
    {
      id: 'ancient_restore',
      icon: '📜✨',
      title: '古医图复原增强工具',
      subtitle: '高清复原·OCR识别',
      gradientColors: ['#1ABC9C', '#16A085'],
      route: 'pages/ImageRestorationPage'
    },
    {
      id: 'ai_chat',
      icon: '🤖💬',
      title: 'AI智能问答助手',
      subtitle: '健康咨询·用药指导',
      gradientColors: ['#3498DB', '#2980B9'],
      route: 'pages/AiChatPage'
    }
  ];

  build() {
    Column({ space: 16 }) {
      Row() {
        Text('AI工具箱')
          .fontSize(this.isElderMode ? 18 : 16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')

        Blank()

        Text('查看全部 >')
          .fontSize(this.isElderMode ? 14 : 12)
          .fontColor('#1677FF')
          .onClick(() => {
            try {
              router.pushUrl({ url: 'pages/AIAssistantPage' });
            } catch (error) {
              console.error('导航失败:', error);
            }
          })
      }
      .width('100%')

      Grid() {
        ForEach(this.tools.length > 0 ? this.tools : this.defaultTools, (tool: AIToolItem) => {
          GridItem() {
            AIToolCard({ tool: tool })
          }
        }, (tool: AIToolItem) => tool.id)
      }
      .columnsTemplate('1fr 1fr')
      .rowsGap(12)
      .columnsGap(12)
      .width('100%')
    }
    .padding({ left: 16, right: 16 })
  }
}
