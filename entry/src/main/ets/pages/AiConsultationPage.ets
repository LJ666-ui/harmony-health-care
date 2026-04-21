import { router } from '@kit.ArkUI';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';
import { Footer } from '../components/Footer';
import BrowseTracker from '../utils/BrowseTracker';
import { MultiAgentOrchestrator, ConsultationResult } from '../aiagent/MultiAgentOrchestrator';

export interface AgentChatMessage {
  id: string;
  type: 'user' | 'assistant' | 'system';
  content: string;
  timestamp: number;
  isLoading?: boolean;
  isError?: boolean;
  errorMessage?: string;
  agentName?: string;
  sources?: Array<{ title: string; similarity: number }>;
}

export interface AgentInfo {
  name: string;
  description: string;
  specialty: string;
  icon: string;
  color: string;
}

@Entry
@Component
struct AiConsultationPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State messages: AgentChatMessage[] = [];
  @State inputText: string = '';
  @State isLoading: boolean = false;
  @State showSuggestions: boolean = true;
  @State currentSessionId: string = '';
  @State activeAgentName: string = '';

  private scroller: Scroller = new Scroller();
  private orchestrator: MultiAgentOrchestrator = new MultiAgentOrchestrator();

  @State agentList: AgentInfo[] = [
    {
      name: '内科专家',
      description: '慢性病/症状分析',
      specialty: 'internal_medicine',
      icon: '🏥',
      color: '#1677FF'
    },
    {
      name: '外科专家',
      description: '外伤/手术咨询',
      specialty: 'surgery',
      icon: '🔪',
      color: '#52C41A'
    },
    {
      name: '中医专家',
      description: '中药/针灸/体质',
      specialty: 'tcm',
      icon: '🌿',
      color: '#722ED1'
    },
    {
      name: '营养师',
      description: '饮食/食疗/营养',
      specialty: 'nutrition',
      icon: '🥗',
      color: '#FA8C16'
    },
    {
      name: '康复治疗师',
      description: '运动处方/康复',
      specialty: 'rehab',
      icon: '💪',
      color: '#13C2C2'
    }
  ];

  @State suggestedQuestions: Array<{ id: string; question: string; icon: string; targetAgent?: string }> = [
    { id: '1', question: '血压多少算正常？', icon: '❤️', targetAgent: 'internal_medicine' },
    { id: '2', question: '老年人如何预防糖尿病？', icon: '💉', targetAgent: 'internal_medicine' },
    { id: '3', question: '外伤伤口如何正确处理？', icon: '🩹', targetAgent: 'surgery' },
    { id: '4', question: '中医体质辨识方法？', icon: '🌿', targetAgent: 'tcm' },
    { id: '5', question: '健康减肥的饮食方案', icon: '🥗', targetAgent: 'nutrition' },
    { id: '6', question: '颈椎保健操怎么做？', icon: '💪', targetAgent: 'rehab' }
  ];

  private recordId: number | undefined = undefined;

  aboutToAppear(): void {
    BrowseTracker.recordStart('AI_CONSULTATION', 'PAGE', 5, 'AI多智能体问诊').then(id => {
      this.recordId = id;
    });

    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    }

    this.initializeSession();

    this.addSystemMessage('您好！我是AI多智能体医疗问诊系统，拥有5位专科专家：\n\n🏥 内科专家 - 慢性病管理\n🔪 外科专家 - 外伤手术咨询\n🌿 中医专家 - 中医调理\n🥗 营养师 - 饮食营养指导\n💪 康复师 - 运动康复训练\n\n请描述您的健康问题，我会为您匹配最合适的专家！');
  }

  aboutToDisappear(): void {
    if (this.recordId) {
      BrowseTracker.recordEnd(this.recordId);
    }
  }

  private async initializeSession(): Promise<void> {
    try {
      this.currentSessionId = await this.orchestrator.createNewSession();
    } catch (e) {
      console.error('Initialize session error:', e);
    }
  }

  addMessage(type: 'user' | 'assistant' | 'system', content: string, options?: {
    isLoading?: boolean;
    isError?: boolean;
    errorMessage?: string;
    agentName?: string;
    sources?: Array<{ title: string; similarity: number }>;
  }): void {
    const message: AgentChatMessage = {
      id: Date.now().toString() + Math.random().toString(36).substring(2, 11),
      type,
      content,
      timestamp: Date.now(),
      isLoading: options?.isLoading || false,
      isError: options?.isError || false,
      errorMessage: options?.errorMessage,
      agentName: options?.agentName,
      sources: options?.sources
    };

    this.messages.push(message);

    setTimeout(() => {
      try {
        this.scroller.scrollEdge(Edge.Bottom);
      } catch (e) {
        console.error('scroll error:', e);
      }
    }, 100);
  }

  addSystemMessage(content: string): void {
    this.addMessage('system', content);
  }

  addUserMessage(content: string): void {
    this.addMessage('user', content);
    this.showSuggestions = false;
  }

  async handleSendMessage(): Promise<void> {
    const text: string = this.inputText.trim();
    if (!text || this.isLoading) return;

    this.inputText = '';
    this.addUserMessage(text);
    this.isLoading = true;

    const loadingId: string = this.addLoadingMessage();

    setTimeout(async () => {
      try {
        const result: ConsultationResult = await this.orchestrator.consult(
          text,
          this.currentSessionId
        );

        this.removeLoadingMessage(loadingId);

        if (result.success) {
          this.activeAgentName = result.agentName;
          this.addMessage('assistant', result.response, {
            agentName: result.agentName,
            sources: result.sources
          });
        } else {
          this.addMessage('assistant', '', {
            isError: true,
            errorMessage: result.response
          });
        }
      } catch (error) {
        console.error('Error:', error);
        this.removeLoadingMessage(loadingId);
        const errorMsg: string = error instanceof Error ? error.message : '抱歉，发生了未知错误，请重试';
        this.addMessage('assistant', '', {
          isError: true,
          errorMessage: errorMsg
        });
      } finally {
        this.isLoading = false;
      }
    }, 500);
  }

  addLoadingMessage(): string {
    const loadingId: string = Date.now().toString() + '_loading';
    const message: AgentChatMessage = {
      id: loadingId,
      type: 'assistant',
      content: '',
      timestamp: Date.now(),
      isLoading: true
    };
    this.messages.push(message);

    setTimeout(() => {
      try {
        this.scroller.scrollEdge(Edge.Bottom);
      } catch (e) {
        console.error('scroll error:', e);
      }
    }, 100);

    return loadingId;
  }

  removeLoadingMessage(loadingId: string): void {
    let filtered: AgentChatMessage[] = [];
    for (let i = 0; i < this.messages.length; i++) {
      if (this.messages[i].id !== loadingId) {
        filtered.push(this.messages[i]);
      }
    }
    this.messages = filtered;
  }

  handleSuggestionClick(question: string): void {
    this.inputText = question;
    this.handleSendMessage();
  }

  clearChatHistory(): void {
    this.messages = [];
    this.showSuggestions = true;
    this.activeAgentName = '';
    this.addSystemMessage('对话已清空。有什么我可以帮助您的？');
  }

  formatTime(timestamp: number): string {
    const date: Date = new Date(timestamp);
    const hours: string = date.getHours().toString().padStart(2, '0');
    const minutes: string = date.getMinutes().toString().padStart(2, '0');
    return '' + hours + ':' + minutes;
  }

  getAgentIcon(agentName: string): string {
    for (const agent of this.agentList) {
      if (agent.name === agentName) {
        return agent.icon;
      }
    }
    return '🤖';
  }

  getAgentColor(agentName: string): string {
    for (const agent of this.agentList) {
      if (agent.name === agentName) {
        return agent.color;
      }
    }
    return '#666666';
  }

  @Builder
  UserBubble(message: AgentChatMessage) {
    Row() {
      Blank();

      Column({ space: 4 }) {
        Text(message.content)
          .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('#1677FF')
          .borderRadius({ topLeft: 16, topRight: 16, bottomLeft: 16, bottomRight: 4 })
          .constraintSize({ maxWidth: '80%' });

        Text(this.formatTime(message.timestamp))
          .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
          .fontColor('#999999')
          .margin({ right: 8 });
      }
      .alignItems(HorizontalAlign.End);
    }
    .width('100%')
    .padding({ right: 12 });
  }

  @Builder
  AssistantBubble(message: AgentChatMessage) {
    Row() {
      Column({ space: 6 }) {
        if (message.isLoading) {
          this.ThinkingAnimation();
        } else if (message.isError) {
          this.ErrorMessageBubble(message);
        } else {
          if (message.agentName) {
            this.AgentBadge(message.agentName);
          }
          this.MarkdownContent(message.content);
          if (message.sources && message.sources.length > 0) {
            this.SourceReferences(message.sources);
          }
          this.DisclaimerText();
        }

        Text(this.formatTime(message.timestamp))
          .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
          .fontColor('#999999')
          .margin({ left: 8 });
      }
      .alignItems(HorizontalAlign.Start);

      Blank();
    }
    .width('100%')
    .padding({ left: 12 });
  }

  @Builder
  SystemBubble(message: AgentChatMessage) {
    Row() {
      Column() {
        Text(message.content)
          .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
          .fontColor('#666666')
          .textAlign(TextAlign.Center)
          .padding({ left: 20, right: 20, top: 12, bottom: 12 })
          .backgroundColor('#F0F0F0')
          .borderRadius(20)
          .margin({ top: 8, bottom: 8 });
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center);
    }
    .width('100%')
    .padding({ left: 32, right: 32 });
  }

  @Builder
  AgentBadge(agentName: string) {
    Row({ space: 6 }) {
      Text(this.getAgentIcon(agentName))
        .fontSize(18);

      Text(agentName)
        .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
        .fontWeight(FontWeight.Medium)
        .fontColor(this.getAgentColor(agentName));
    }
    .padding({ left: 12, right: 12, top: 4, bottom: 4 })
    .backgroundColor('#F0F5FF')
    .borderRadius(12)
    .margin({ bottom: 8 });
  }

  @Builder
  ThinkingAnimation() {
    Row({ space: 8 }) {
      Text('🤔')
        .fontSize(24);

      Column({ space: 4 }) {
        Text('正在调用专家分析...')
          .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
          .fontColor('#666666');

        Row({ space: 4 }) {
          ForEach([0, 1, 2], (index: number) => {
            Circle()
              .width(8)
              .height(8)
              .fill('#1677FF')
              .opacity(0.4 + index * 0.2)
              .animation({
                duration: 600,
                iterations: -1,
                curve: Curve.EaseInOut,
                delay: index * 200
              });
          });
        }
        .margin({ top: 8 });
      }
    }
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .backgroundColor('#F5F5F5')
    .borderRadius({ topLeft: 16, topRight: 16, bottomLeft: 4, bottomRight: 16 })
    .constraintSize({ maxWidth: '80%' });
  }

  @Builder
  ErrorMessageBubble(message: AgentChatMessage) {
    Column({ space: 8 }) {
      Text('⚠️')
        .fontSize(28);

      Text(message.errorMessage || '抱歉，出现了错误')
        .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
        .fontColor('#FF4D4F')
        .textAlign(TextAlign.Center);

      Button('重新发送')
        .height(36)
        .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
        .fontColor('#FFFFFF')
        .backgroundColor('#FF4D4F')
        .borderRadius(18)
        .onClick(() => {
          let lastUserMsg: AgentChatMessage | undefined;
          for (let i = this.messages.length - 1; i >= 0; i--) {
            if (this.messages[i].type === 'user') {
              lastUserMsg = this.messages[i];
              break;
            }
          }
          if (lastUserMsg) {
            let filteredMessages: AgentChatMessage[] = [];
            for (let i = 0; i < this.messages.length; i++) {
              if (this.messages[i].id !== message.id) {
                filteredMessages.push(this.messages[i]);
              }
            }
            this.messages = filteredMessages;
            this.inputText = lastUserMsg.content;
            this.handleSendMessage();
          }
        });
    }
    .padding({ left: 20, right: 20, top: 16, bottom: 16 })
    .backgroundColor('#FFF1F0')
    .border({ width: 1, color: '#FFCCC7' })
    .borderRadius({ topLeft: 16, topRight: 16, bottomLeft: 4, bottomRight: 16 })
    .constraintSize({ maxWidth: '80%' })
    .alignItems(HorizontalAlign.Center);
  }

  @Builder
  MarkdownContent(content: string) {
    Column({ space: 8 }) {
      ForEach(this.parseMarkdownToSegments(content), (segment: MarkdownSegment, index: number) => {
        if (segment.type === 'heading') {
          Text(segment.text)
            .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .margin({ top: 8, bottom: 4 });
        } else if (segment.type === 'bold') {
          Text(segment.text)
            .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333');
        } else if (segment.type === 'list') {
          Row({ space: 6 }) {
            Text('•')
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontColor('#1677FF');

            Text(segment.text)
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontColor('#333333')
              .layoutWeight(1);
          }
        } else if (segment.type === 'warning') {
          Text(segment.text)
            .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
            .fontColor('#FAAD14')
            .fontStyle(FontStyle.Italic)
            .margin({ top: 8 })
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .backgroundColor('#FFFBE6')
            .borderRadius(8);
        } else if (segment.type === 'divider') {
          Divider()
            .color('#F0F0F0')
            .margin({ top: 4, bottom: 4 });
        } else {
          Text(segment.text)
            .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
            .fontColor('#333333')
            .lineHeight(22);
        }
      });
    }
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor('#F5F5F5')
    .borderRadius({ topLeft: 16, topRight: 16, bottomLeft: 4, bottomRight: 16 })
    .constraintSize({ maxWidth: '85%' });
  }

  @Builder
  SourceReferences(sources: Array<{ title: string; similarity: number }>) {
    Column({ space: 4 }) {
      Text('📚 参考来源')
        .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
        .fontColor('#666666')
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 4 });

      ForEach(sources.slice(0, 3), (source: { title: string; similarity: number }, index: number) => {
        Row({ space: 6 }) {
          Text((index + 1).toString())
            .fontSize(10)
            .fontColor('#FFFFFF')
            .width(16)
            .height(16)
            .borderRadius(8)
            .backgroundColor('#1677FF')
            .textAlign(TextAlign.Center);

          Text(source.title)
            .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
            .fontColor('#666666')
            .layoutWeight(1)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis });

          Text((source.similarity * 100).toFixed(0) + '%')
            .fontSize(10)
            .fontColor('#999999');
        }
        .width('100%')
        .padding({ left: 8, right: 8, top: 2, bottom: 2 });
      });
    }
    .padding({ left: 12, right: 12, top: 8, bottom: 8 })
    .backgroundColor('#FAFAFA')
    .borderRadius(8)
    .margin({ top: 8 });
  }

  @Builder
  DisclaimerText() {
    Text('⚠️ 以上建议仅供参考，不能替代专业医疗诊断。如有不适请及时就医。')
      .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
      .fontColor('#999999')
      .fontStyle(FontStyle.Italic)
      .margin({ top: 6, left: 4 });
  }

  private isListItem(text: string): boolean {
    if (text.length < 3) return false;
    const firstChar = text.charAt(0);
    if (firstChar >= '1' && firstChar <= '9') {
      return text.charAt(1) === '.' && text.charAt(2) === ' ';
    }
    return false;
  }

  parseMarkdownToSegments(text: string): MarkdownSegment[] {
    const segments: MarkdownSegment[] = [];
    const lines: string[] = text.split('\n');

    for (let lineIdx = 0; lineIdx < lines.length; lineIdx++) {
      const trimmedLine: string = lines[lineIdx].trim();

      if (!trimmedLine) {
        continue;
      }

      if (trimmedLine.startsWith('### ')) {
        segments.push({ type: 'heading', text: trimmedLine.substring(4) });
      } else if (trimmedLine.startsWith('## ')) {
        segments.push({ type: 'heading', text: trimmedLine.substring(3) });
      } else if (trimmedLine.startsWith('# ')) {
        segments.push({ type: 'heading', text: trimmedLine.substring(2) });
      } else if (trimmedLine.startsWith('> ') || trimmedLine.indexOf('⚠️') >= 0) {
        let warningText = trimmedLine;
        if (warningText.startsWith('> ')) {
          warningText = warningText.substring(2);
        }
        segments.push({ type: 'warning', text: warningText });
      } else if (this.isListItem(trimmedLine) || trimmedLine.startsWith('• ') || trimmedLine.startsWith('- ')) {
        let listText: string = trimmedLine;
        if (this.isListItem(listText)) {
          if (listText.length >= 3 && listText.charAt(1) === '.' && listText.charAt(2) === ' ') {
            listText = listText.substring(3);
          }
        }
        if (listText.startsWith('• ')) {
          listText = listText.substring(2);
        }
        if (listText.startsWith('- ')) {
          listText = listText.substring(2);
        }
        segments.push({ type: 'list', text: listText });
      } else if (trimmedLine.indexOf('---') >= 0) {
        segments.push({ type: 'divider', text: '' });
      } else if (trimmedLine.indexOf('**') >= 0) {
        const parts: string[] = trimmedLine.split('**');
        for (let partIdx = 0; partIdx < parts.length; partIdx++) {
          const part: string = parts[partIdx];
          if (part.trim()) {
            if (partIdx % 2 === 1) {
              segments.push({ type: 'bold', text: part });
            } else {
              segments.push({ type: 'text', text: part });
            }
          }
        }
      } else if (trimmedLine.length > 0 && (trimmedLine.charAt(0) === '❌' || trimmedLine.charAt(0) === '✅')) {
        segments.push({ type: 'list', text: trimmedLine });
      } else {
        segments.push({ type: 'text', text: trimmedLine });
      }
    }

    return segments;
  }

  build() {
    Column() {
      Row() {
        Text('←')
          .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
          .fontColor('#1677FF')
          .margin({ left: 16 })
          .onClick(() => {
            router.back();
          });

        Text('AI多智能体问诊')
          .fontSize(GlobalTheme.getFontSizeTitle(this.isElderMode))
          .fontWeight('bold')
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center);

        Row({ space: 12 }) {
          Text('📋')
            .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
            .fontColor('#1677FF');

          Text('🗑️')
            .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
            .fontColor('#999999')
            .onClick(() => {
              AlertDialog.show({
                title: '清空对话',
                message: '确定要清空所有对话记录吗？',
                primaryButton: {
                  value: '取消',
                  action: () => {}
                },
                secondaryButton: {
                  value: '确定',
                  fontColor: '#FF4D4F',
                  action: () => {
                    this.clearChatHistory();
                  }
                }
              });
            });
        }
        .margin({ right: 16 });
      }
      .width('100%')
      .height(56)
      .backgroundColor('#FFFFFF')
      .justifyContent(FlexAlign.Center);

      this.AgentSelectorBar();

      if (this.messages.length === 0) {
        this.EmptyState();
      }

      Scroll(this.scroller) {
        Column({ space: 8 }) {
          ForEach(this.messages, (message: AgentChatMessage) => {
            if (message.type === 'user') {
              this.UserBubble(message);
            } else if (message.type === 'assistant') {
              this.AssistantBubble(message);
            } else if (message.type === 'system') {
              this.SystemBubble(message);
            }
          }, (message: AgentChatMessage) => message.id);
        }
        .width('100%')
        .padding({ top: 12, bottom: 12 });
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
      .backgroundColor('#FAFBFC')
      .edgeEffect(EdgeEffect.Spring);

      if (this.showSuggestions && this.messages.length <= 1) {
        this.SuggestionPanel();
      }

      this.InputArea();
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }

  @Builder
  AgentSelectorBar() {
    Scroll() {
      Row({ space: 10 }) {
        ForEach(this.agentList, (agent: AgentInfo) => {
          Column({ space: 4 }) {
            Text(agent.icon)
              .fontSize(24);

            Text(agent.name.replace('专家', '').replace('师', ''))
              .fontSize(10)
              .fontColor(this.activeAgentName === agent.name ? agent.color : '#666666');
          }
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          .backgroundColor(this.activeAgentName === agent.name ? agent.color + '15' : '#FFFFFF')
          .borderRadius(12)
          .border({
            width: this.activeAgentName === agent.name ? 1.5 : 1,
            color: this.activeAgentName === agent.name ? agent.color : '#EEEEEE'
          })
          .onClick(() => {
            this.inputText = '请帮我咨询关于' + agent.description + '的问题';
            ToastUtil.showInfo('已选择' + agent.name);
          });
        }, (agent: AgentInfo) => agent.specialty);
      }
      .padding({ left: 12, right: 12, top: 8, bottom: 8 });
    }
    .width('100%')
    .scrollBar(BarState.Off)
    .backgroundColor('#FFFFFF')
    .shadow({ radius: 2, color: '#00000008', offsetX: 0, offsetY: 1 });
  }

  @Builder
  EmptyState() {
    Column({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
      Text('🏥')
        .fontSize(64)
        .margin({ top: 40 });

      Text('AI多智能体医疗问诊')
        .fontSize(GlobalTheme.getFontSizeTitle(this.isElderMode))
        .fontWeight('bold')
        .fontColor('#1677FF');

      Text('5位专科专家为您服务\n内科、外科、中医、营养、康复')
        .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
        .fontColor('#666666')
        .textAlign(TextAlign.Center)
        .margin({ top: 8 });

      Column({ space: GlobalTheme.getSpacingSM(this.isElderMode) }) {
        ForEach(this.suggestedQuestions.slice(0, 3), (question: { id: string; question: string; icon: string }) => {
          Row({ space: 8 }) {
            Text(question.icon)
              .fontSize(20);

            Text(question.question)
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontColor('#1677FF')
              .layoutWeight(1);
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 12, bottom: 12 })
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 2 })
          .onClick(() => {
            this.handleSuggestionClick(question.question);
          });
        }, (question: { id: string; question: string; icon: string }) => question.id);
      }
      .width('85%')
      .margin({ top: 24 });
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center);
  }

  @Builder
  SuggestionPanel() {
    Scroll() {
      Column({ space: 8 }) {
        Text('常见问题')
          .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
          .fontWeight('bold')
          .fontColor('#666666')
          .margin({ left: 16, top: 8, bottom: 4 });

        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.suggestedQuestions, (question: { id: string; question: string; icon: string }) => {
            Text(question.question)
              .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
              .fontColor('#1677FF')
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              .backgroundColor('#E6F4FF')
              .borderRadius(16)
              .margin(4)
              .onClick(() => {
                this.handleSuggestionClick(question.question);
              });
          }, (question: { id: string; question: string; icon: string }) => question.id);
        }
        .padding({ left: 12, right: 12, bottom: 8 });
      }
    }
    .width('100%')
    .height(120)
    .backgroundColor('#FFFFFF')
    .shadow({ radius: 4, color: '#00000006', offsetX: 0, offsetY: -2 });
  }

  @Builder
  InputArea() {
    Column({ space: 8 }) {
      Row({ space: 8 }) {
        TextInput({ text: this.inputText, placeholder: '输入您的健康问题...' })
          .layoutWeight(1)
          .height(44)
          .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
          .backgroundColor('#FFFFFF')
          .borderRadius(22)
          .padding({ left: 16, right: 16 })
          .onChange((value: string) => {
            this.inputText = value;
          })
          .onSubmit(() => {
            this.handleSendMessage();
          });

        if (this.inputText.trim()) {
          Text('发送')
            .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
            .fontWeight('bold')
            .fontColor('#FFFFFF')
            .width(64)
            .height(44)
            .textAlign(TextAlign.Center)
            .backgroundColor('#1677FF')
            .borderRadius(22)
            .onClick(() => {
              this.handleSendMessage();
            });
        } else {
          Text('🎤')
            .fontSize(20)
            .width(44)
            .height(44)
            .textAlign(TextAlign.Center)
            .backgroundColor('#F0F0F0')
            .borderRadius(22)
            .onClick(() => {
              ToastUtil.showInfo('语音功能开发中...');
            });
        }
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 8, bottom: 8 });

      Text('AI回答仅供参考，不能替代医生诊断')
        .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
        .fontColor('#BBBBBB')
        .textAlign(TextAlign.Center)
        .margin({ bottom: 4 });
    }
    .width('100%')
    .backgroundColor('#FFFFFF');
  }
}

interface MarkdownSegment {
  type: 'text' | 'heading' | 'bold' | 'list' | 'warning' | 'divider';
  text: string;
}
