import { GlobalTheme } from '../global';
import { MultiAgentOrchestrator, ConsultationResult, IntentClassificationResult } from './MultiAgentOrchestrator';
import { MedicalAgent } from './MedicalAgent';

export interface ChatMessage {
  id: string;
  role: 'user' | 'assistant' | 'system';
  content: string;
  timestamp: number;
  isLoading?: boolean;
  isError?: boolean;
  agentName?: string;
  specialty?: string;
  sources?: Array<{ title: string; similarity: number; category: string }>;
}

export interface AgentCardInfo {
  name: string;
  specialty: string;
  description: string;
  icon: string;
  color: string;
  isActive: boolean;
  confidence: number;
}

@Component
export struct AgentChatInterface {
  @Prop orchestrator: MultiAgentOrchestrator | null = null;
  @State messages: ChatMessage[] = [];
  @State inputText: string = '';
  @State isLoading: boolean = false;
  @State sessionId: string = '';
  @State activeAgentName: string = '';
  @State showAgentPanel: boolean = false;
  @State currentIntent: IntentClassificationResult | null = null;

  private scroller: Scroller = new Scroller();

  aboutToAppear(): void {
    this.initializeSession();
  }

  private async initializeSession(): Promise<void> {
    if (this.orchestrator) {
      try {
        this.sessionId = await this.orchestrator.createNewSession();
      } catch (e) {
        console.error('Init session error:', e);
      }
    }
  }

  async sendMessage(text: string): Promise<void> {
    if (!text.trim() || this.isLoading || !this.orchestrator) return;

    const userMessage: ChatMessage = {
      id: Date.now().toString() + '_user',
      role: 'user',
      content: text,
      timestamp: Date.now()
    };
    this.messages.push(userMessage);
    this.inputText = '';
    this.isLoading = true;

    const loadingId: string = Date.now().toString() + '_loading';
    this.messages.push({
      id: loadingId,
      role: 'assistant',
      content: '',
      timestamp: Date.now(),
      isLoading: true
    });

    setTimeout(async () => {
      try {
        this.currentIntent = this.orchestrator.classifyIntent(text);

        const result: ConsultationResult = await this.orchestrator.consult(
          text,
          this.sessionId
        );

        this.messages = this.messages.filter(m => m.id !== loadingId);

        if (result.success) {
          this.activeAgentName = result.agentName;
          this.messages.push({
            id: Date.now().toString() + '_resp',
            role: 'assistant',
            content: result.response,
            timestamp: result.timestamp,
            agentName: result.agentName,
            sources: result.sources.map(s => ({
              ...s,
              category: ''
            }))
          });
        } else {
          this.messages.push({
            id: Date.now().toString() + '_err',
            role: 'assistant',
            content: '',
            timestamp: Date.now(),
            isError: true
          });
        }
      } catch (error) {
        console.error('Send message error:', error);
        this.messages = this.messages.filter(m => m.id !== loadingId);
        this.messages.push({
          id: Date.now().toString() + '_err',
          role: 'assistant',
          content: '',
          timestamp: Date.now(),
          isError: true
        });
      } finally {
        this.isLoading = false;
      }

      setTimeout(() => {
        try {
          this.scroller.scrollEdge(Edge.Bottom);
        } catch (e) {}
      }, 100);
    }, 300);
  }

  clearMessages(): void {
    this.messages = [];
    this.activeAgentName = '';
    this.currentIntent = null;
  }

  getMessages(): ChatMessage[] {
    return this.messages;
  }

  @Builder
  ChatBubble(message: ChatMessage) {
    if (message.role === 'user') {
      Row() {
        Blank();
        Column({ space: 4 }) {
          Text(message.content)
            .fontSize(15)
            .fontColor('#FFFFFF')
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor('#1677FF')
            .borderRadius({ topLeft: 16, topRight: 16, bottomLeft: 16, bottomRight: 4 })
            .constraintSize({ maxWidth: '80%' });

          Text(this.formatTime(message.timestamp))
            .fontSize(11)
            .fontColor('#999999')
            .margin({ right: 8 });
        }
        .alignItems(HorizontalAlign.End);
      }
      .width('100%')
      .padding({ right: 12 });
    } else if (message.role === 'assistant') {
      Row() {
        Column({ space: 6 }) {
          if (message.isLoading) {
            this.ThinkingIndicator();
          } else if (message.isError) {
            this.ErrorIndicator();
          } else {
            if (message.agentName) {
              this.AgentTag(message.agentName, message.specialty || '');
            }
            this.ResponseContent(message.content);
            if (message.sources && message.sources.length > 0) {
              this.SourceList(message.sources);
            }
          }

          Text(this.formatTime(message.timestamp))
            .fontSize(11)
            .fontColor('#999999')
            .margin({ left: 8 });
        }
        .alignItems(HorizontalAlign.Start);
        Blank();
      }
      .width('100%')
      .padding({ left: 12 });
    } else {
      Row() {
        Text(message.content)
          .fontSize(13)
          .fontColor('#666666')
          .textAlign(TextAlign.Center)
          .padding(12)
          .backgroundColor('#F5F5F5')
          .borderRadius(16);
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .padding({ left: 32, right: 32 });
    }
  }

  @Builder
  ThinkingIndicator() {
    Row({ space: 8 }) {
      Text('🤔').fontSize(20);
      Column({ space: 4 }) {
        Text('专家正在分析中...')
          .fontSize(14)
          .fontColor('#666666');
        Row({ space: 4 }) {
          ForEach([0, 1, 2], (i: number) => {
            Circle()
              .width(8)
              .height(8)
              .fill('#1677FF')
              .opacity(0.4 + i * 0.2)
              .animation({
                duration: 600,
                iterations: -1,
                curve: Curve.EaseInOut,
                delay: i * 200
              });
          });
        }.margin({ top: 6 });
      }
    }
    .padding(16)
    .backgroundColor('#F8F8F8')
    .borderRadius(12);
  }

  @Builder
  ErrorIndicator() {
    Column({ space: 8 }) {
      Text('⚠️').fontSize(24);
      Text('处理失败，请重试')
        .fontSize(14)
        .fontColor('#FF4D4F');
      Button('重试')
        .height(32)
        .fontSize(13)
        .onClick(() => {
          const lastUserMsg = [...this.messages].reverse().find(m => m.role === 'user');
          if (lastUserMsg) {
            this.messages = this.messages.filter(m => !m.isError);
            this.sendMessage(lastUserMsg.content);
          }
        });
    }
    .padding(16)
    .backgroundColor('#FFF1F0')
    .borderRadius(12)
    .alignItems(HorizontalAlign.Center);
  }

  @Builder
  AgentTag(name: string, specialty: string) {
    Row({ space: 6 }) {
      Text(this.getAgentIcon(name)).fontSize(16);
      Text(name).fontSize(12).fontWeight(FontWeight.Medium).fontColor('#1677FF');
    }
    .padding({ left: 10, right: 10, top: 4, bottom: 4 })
    .backgroundColor('#E6F4FF')
    .borderRadius(10)
    .margin({ bottom: 6 });
  }

  @Builder
  ResponseContent(content: string) {
    Text(content)
      .fontSize(14)
      .fontColor('#333333')
      .lineHeight(22)
      .padding({ left: 14, right: 14, top: 12, bottom: 12 })
      .backgroundColor('#FAFAFA')
      .borderRadius(12)
      .constraintSize({ maxWidth: '85%' });
  }

  @Builder
  SourceList(sources: Array<{ title: string; similarity: number; category: string }>) {
    Column({ space: 4 }) {
      Text('📚 知识来源').fontSize(11).fontColor('#888').margin({ bottom: 2 });
      ForEach(sources.slice(0, 3), (source: { title: string; similarity: number; category: string }, idx: number) => {
        Row({ space: 6 }) {
          Text((idx + 1).toString())
            .fontSize(9)
            .fontColor('#FFF')
            .width(14)
            .height(14)
            .borderRadius(7)
            .backgroundColor('#1677FF')
            .textAlign(TextAlign.Center);
          Text(source.title).fontSize(11).fontColor('#666').layoutWeight(1).maxLines(1);
          Text((source.similarity * 100).toFixed(0) + '%').fontSize(9).fontColor('#AAA');
        }
        .width('100%').padding({ left: 6, right: 6, top: 2, bottom: 2 });
      });
    }
    .padding(10)
    .backgroundColor('#FAFAFA')
    .borderRadius(8)
    .margin({ top: 6 })
    .constraintSize({ maxWidth: '85%' });
  }

  private getAgentIcon(name: string): string {
    const iconMap: Record<string, string> = {
      '内科专家': '🏥', '外科专家': '🔪', '中医专家': '🌿',
      '营养师': '🥗', '康复治疗师': '💪'
    };
    return iconMap[name] || '🤖';
  }

  private formatTime(timestamp: number): string {
    const d = new Date(timestamp);
    return d.getHours().toString().padStart(2, '0') + ':' + d.getMinutes().toString().padStart(2, '0');
  }

  build() {
    Column() {
      Scroll(this.scroller) {
        Column({ space: 8 }) {
          ForEach(this.messages, (msg: ChatMessage) => {
            this.ChatBubble(msg);
          }, (msg: ChatMessage) => msg.id);
        }
        .width('100%')
        .padding(12);
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .backgroundColor('#FAFBFC');

      Row({ space: 8 }) {
        TextInput({
          text: this.inputText,
          placeholder: '输入您的问题...'
        })
          .layoutWeight(1)
          .height(42)
          .fontSize(14)
          .backgroundColor('#FFFFFF')
          .borderRadius(21)
          .padding({ left: 16, right: 16 })
          .onChange((v: string) => { this.inputText = v; })
          .onSubmit(() => { this.sendMessage(this.inputText); });

        if (this.inputText.trim()) {
          Text('发送')
            .fontSize(14)
            .fontWeight('bold')
            .fontColor('#FFFFFF')
            .width(60)
            .height(42)
            .textAlign(TextAlign.Center)
            .backgroundColor('#1677FF')
            .borderRadius(21)
            .onClick(() => { this.sendMessage(this.inputText); });
        } else {
          Text('🎤')
            .fontSize(18)
            .width(42)
            .height(42)
            .textAlign(TextAlign.Center)
            .backgroundColor('#F0F0F0')
            .borderRadius(21);
        }
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor('#FFFFFF');
    }
    .width('100%')
    .height('100%');
  }
}
