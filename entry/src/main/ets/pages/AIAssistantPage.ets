import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';
import { AIService } from '../services/AIService';
import { AIOrchestrator } from '../ai/orchestrator/AIOrchestrator';
import { AIRequestBuilder } from '../ai/utils/AIRequestBuilder';
import { ttsService } from '../ai/tts/TTSService';

interface ChatMessage {
  id: number;
  content: string;
  isUser: boolean;
  timestamp: string;
  isStreaming?: boolean;
}

@Entry
@Component
struct AIAssistantPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @StorageLink('userId') userId: number = 0;
  @State messages: ChatMessage[] = [];
  @State inputText: string = '';
  @State isTyping: boolean = false;
  @State speakingMessageId: number | null = null;
  @State isRecording: boolean = false;
  @State recordStatus: string = '点击麦克风开始说话';
  private scroller: Scroller = new Scroller();
  private aiService: AIService = AIService.getInstance();
  private orchestrator: AIOrchestrator = AIOrchestrator.getInstance();
  private streamingTimer: number | null = null;
  private currentStreamIndex: number = 0;

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') || false;
    }
    this.initMessages();
    
    ttsService.initialize().then((success: boolean) => {
      console.log('[AIAssistantPage] TTS初始化结果:', success);
    }).catch((error: Error) => {
      console.error('[AIAssistantPage] TTS初始化异常:', error);
    });
  }

  initMessages(): void {
    this.messages = [
      { id: 1, content: '您好！我是AI健康助手，可以为您提供健康咨询、症状分析、用药指导等服务。请问有什么可以帮助您的？', isUser: false, timestamp: '09:00' }
    ];
  }

  sendMessage(): void {
    if (!this.inputText.trim()) {
      return;
    }

    const userMessage: ChatMessage = {
      id: this.messages.length + 1,
      content: this.inputText,
      isUser: true,
      timestamp: this.getCurrentTime()
    };
    
    this.messages.push(userMessage);
    const messageToSend = this.inputText;
    this.inputText = '';
    
    setTimeout(() => {
      this.scroller.scrollEdge(Edge.Bottom);
    }, 100);

    this.isTyping = true;
    setTimeout(() => {
      this.receiveMessageFromAI(messageToSend);
    }, 500);
  }

  async receiveMessageFromAI(userMessage: string): Promise<void> {
    try {
      let response: string;

      try {
        const aiRequest = AIRequestBuilder.createSimpleRequest(
          userMessage,
          String(this.userId || 'anonymous')
        );

        const aiResponse = await this.orchestrator.process(aiRequest);

        console.log('[AIAssistantPage] AIOrchestrator response:', {
          agentId: aiResponse.agentId,
          confidence: aiResponse.output.confidence
        });

        response = typeof aiResponse.output.content === 'string'
          ? aiResponse.output.content
          : JSON.stringify(aiResponse.output.content);
      } catch (orchestratorError) {
        console.log('[AIAssistantPage] AIOrchestrator failed, fallback to AIService:', orchestratorError);
        response = await this.aiService.chat(this.userId, userMessage);
      }

      this.streamMessage(response);
    } catch (error) {
      console.error('[AIAssistantPage] AI回复失败:', error);
      
      const errorMessage: ChatMessage = {
        id: this.messages.length + 1,
        content: '抱歉，AI服务暂时不可用，请稍后重试。',
        isUser: false,
        timestamp: this.getCurrentTime()
      };
      
      this.messages.push(errorMessage);
      this.isTyping = false;
      ToastUtil.showError('AI服务调用失败');
    }
  }

  streamMessage(fullText: string): void {
    const messageId: number = this.messages.length + 1;
    const aiMessage: ChatMessage = {
      id: messageId,
      content: '',
      isUser: false,
      timestamp: this.getCurrentTime(),
      isStreaming: true
    };
    
    this.messages.push(aiMessage);
    this.isTyping = false;

    let currentIndex: number = 0;
    const charsPerInterval: number = 2;
    const intervalMs: number = 50;

    this.streamingTimer = setInterval(() => {
      if (currentIndex >= fullText.length) {
        if (this.streamingTimer !== null) {
          clearInterval(this.streamingTimer);
          this.streamingTimer = null;
        }

        const updatedMessages: ChatMessage[] = [];
        for (let i = 0; i < this.messages.length; i++) {
          if (this.messages[i].id === messageId) {
            const newMsg: ChatMessage = {
              id: this.messages[i].id,
              content: fullText,
              isUser: this.messages[i].isUser,
              timestamp: this.messages[i].timestamp,
              isStreaming: false
            };
            updatedMessages.push(newMsg);
          } else {
            updatedMessages.push(this.messages[i]);
          }
        }
        this.messages = updatedMessages;

        setTimeout(() => {
          this.scroller.scrollEdge(Edge.Bottom);
        }, 100);

        return;
      }

      const endIndex: number = Math.min(currentIndex + charsPerInterval, fullText.length);
      const newText: string = fullText.substring(0, endIndex);

      const updatedMessages2: ChatMessage[] = [];
      for (let i = 0; i < this.messages.length; i++) {
        if (this.messages[i].id === messageId) {
          const newMsg: ChatMessage = {
            id: this.messages[i].id,
            content: newText,
            isUser: this.messages[i].isUser,
            timestamp: this.messages[i].timestamp,
            isStreaming: true
          };
          updatedMessages2.push(newMsg);
        } else {
          updatedMessages2.push(this.messages[i]);
        }
      }
      this.messages = updatedMessages2;

      if (currentIndex % 15 === 0 && currentIndex > 0) {
        this.scroller.scrollEdge(Edge.Bottom);
      }

      currentIndex = endIndex;
    }, intervalMs);
  }

  getCurrentTime(): string {
    const now = new Date();
    return now.getHours().toString().padStart(2, '0') + ':' + 
           now.getMinutes().toString().padStart(2, '0');
  }

  clearHistory(): void {
    this.initMessages();
    ToastUtil.showSuccess('对话已清空');
  }

  async playMessageAudio(messageId: number, content: string): Promise<void> {
    if (this.speakingMessageId === messageId) {
      ttsService.stop();
      this.speakingMessageId = null;
      return;
    }

    if (this.speakingMessageId !== null) {
      ttsService.stop();
    }

    this.speakingMessageId = messageId;

    try {
      console.log('[AIAssistantPage] 开始播放消息音频, ID:', messageId);
      
      await ttsService.speak(content, (event: 'start' | 'finish' | 'error', data?: string) => {
        console.log('[AIAssistantPage] TTS事件:', event, data || '');
        if (event === 'finish' || event === 'error') {
          this.speakingMessageId = null;
        }
      });
    } catch (error) {
      console.error('[AIAssistantPage] 播放失败:', error);
      ToastUtil.showError('语音播放失败');
      this.speakingMessageId = null;
    }
  }

  async startVoiceInput(): Promise<void> {
    if (this.isRecording) return;

    this.isRecording = true;
    this.recordStatus = '正在聆听...';

    const demoPhrases: string[] = [
      '血压高怎么办',
      '感冒发烧怎么处理',
      '血糖正常值是多少',
      '头痛怎么办',
      '用药指导'
    ];

    const randomIndex: number = Math.floor(Math.random() * demoPhrases.length);
    const randomPhrase: string = demoPhrases[randomIndex];

    let displayText: string = '';
    for (let i = 0; i < randomPhrase.length; i++) {
      await new Promise<void>((resolve: () => void) => {
        setTimeout(() => {
          displayText += randomPhrase[i];
          this.inputText = displayText;
          this.recordStatus = '识别中: ' + displayText + '...';
          resolve();
        }, 150 + Math.random() * 100);
      });
    }

    this.recordStatus = '识别完成';
    
    setTimeout(() => {
      this.isRecording = false;
      this.recordStatus = '点击麦克风开始说话';
      
      if (this.inputText.trim()) {
        this.sendMessage();
      }
    }, 500);
  }

  stopVoiceInput(): void {
    if (!this.isRecording) return;

    this.isRecording = false;
    this.recordStatus = '点击麦克风开始说话';

    if (this.inputText.trim()) {
      this.sendMessage();
    }
  }

  build() {
    Column() {
      Header({ title: 'AI助手', showBack: true });

      // 消息列表
      Scroll(this.scroller) {
        Column() {
          ForEach(this.messages, (message: ChatMessage) => {
            Row() {
              if (message.isUser) {
                // 用户消息
                Column() {
                  Text(message.timestamp)
                    .fontSize(10)
                    .fontColor('#999')
                    .margin({ bottom: 5 })
                  
                  Text(message.content)
                    .fontSize(this.isElderMode ? 16 : 14)
                    .fontColor('#fff')
                    .padding(12)
                    .backgroundColor('#2980B9')
                    .borderRadius({ topLeft: 15, topRight: 15, bottomLeft: 15, bottomRight: 5 })
                }
                .alignItems(HorizontalAlign.End)
                .margin({ left: 50 })
              } else {
                // AI消息
                Row() {
                  Text('🤖')
                    .fontSize(30)
                    .margin({ right: 10 })
                  
                  Column() {
                    Text(message.timestamp)
                      .fontSize(10)
                      .fontColor('#999')
                      .margin({ bottom: 5 })
                    
                    Text(message.content)
                      .fontSize(this.isElderMode ? 16 : 14)
                      .fontColor('#333')
                      .padding(12)
                      .backgroundColor('#fff')
                      .borderRadius({ topLeft: 5, topRight: 15, bottomLeft: 15, bottomRight: 15 })
                    
                    if (!message.isStreaming) {
                      Row() {
                        Text(this.speakingMessageId === message.id ? '⏹️' : '🔊')
                          .fontSize(18)
                          .onClick(() => {
                            this.playMessageAudio(message.id, message.content);
                          })
                        
                        if (this.speakingMessageId === message.id) {
                          Text(' 播放中...')
                            .fontSize(11)
                            .fontColor('#2980B9')
                            .margin({ left: 5 })
                        }
                      }
                      .margin({ top: 8 })
                      .justifyContent(FlexAlign.Start)
                    } else {
                      Row() {
                        Text('▌')
                          .fontSize(14)
                          .fontColor('#2980B9')
                        
                        Text(' 正在生成...')
                          .fontSize(11)
                          .fontColor('#999')
                          .margin({ left: 5 })
                      }
                      .margin({ top: 8 })
                      .animation({
                        duration: 500,
                        iterations: -1,
                        curve: Curve.EaseInOut
                      })
                    }
                  }
                  .alignItems(HorizontalAlign.Start)
                }
                .margin({ right: 50 })
              }
            }
            .width('90%')
            .justifyContent(message.isUser ? FlexAlign.End : FlexAlign.Start)
            .margin({ top: 10, bottom: 10 })
          })

          // AI正在输入
          if (this.isTyping) {
            Row() {
              Text('🤖')
                .fontSize(30)
                .margin({ right: 10 })
              
              Row() {
                LoadingProgress()
                  .width(20)
                  .height(20)
                  .color('#2980B9')
                
                Text('正在输入...')
                  .fontSize(12)
                  .fontColor('#999')
                  .margin({ left: 10 })
              }
              .padding(10)
              .backgroundColor('#fff')
              .borderRadius(15)
            }
            .width('90%')
            .justifyContent(FlexAlign.Start)
            .margin({ top: 10 })
          }
        }
        .width('100%')
        .padding({ top: 15, bottom: 15 })
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .backgroundColor('#f0f0f0')

      // 输入区域
      Column() {
        Row() {
          TextInput({
            placeholder: this.isRecording ? this.recordStatus : '输入您的问题...',
            text: this.inputText
          })
            .fontSize(this.isElderMode ? 16 : 14)
            .layoutWeight(1)
            .height(45)
            .backgroundColor('#fff')
            .borderRadius(25)
            .padding({ left: 15, right: 15 })
            .enabled(!this.isRecording)
            .onChange((value: string) => {
              this.inputText = value;
            })
            .onSubmit(() => {
              if (!this.isRecording) {
                this.sendMessage();
              }
            })

          // 麦克风按钮
          Column() {
            Text(this.isRecording ? '⏹️' : '🎤')
              .fontSize(20)
              .onClick(() => {
                if (this.isRecording) {
                  this.stopVoiceInput();
                } else {
                  this.startVoiceInput();
                }
              })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(this.isRecording ? '#FFF1F0' : '#F0F0F0')
          .borderRadius(22)
          .margin({ left: 8 })

          Button('发送')
            .fontSize(this.isElderMode ? 16 : 14)
            .fontColor('#fff')
            .backgroundColor('#2980B9')
            .borderRadius(25)
            .height(45)
            .width(80)
            .margin({ left: 10 })
            .enabled(this.inputText.trim().length > 0 && !this.isRecording)
            .onClick(() => this.sendMessage())
        }
        .width('90%')
        .margin({ top: 10, bottom: 10 })

        // 快捷问题
        Row() {
          Text('快捷问题：')
            .fontSize(12)
            .fontColor('#999')
            .margin({ right: 10 })

          ForEach(['头痛怎么办', '感冒发烧', '用药指导'], (question: string) => {
            Text(question)
              .fontSize(12)
              .fontColor('#2980B9')
              .backgroundColor('#E3F2FD')
              .padding({ left: 10, right: 10, top: 5, bottom: 5 })
              .borderRadius(15)
              .margin({ right: 8 })
              .onClick(() => {
                this.inputText = question;
                this.sendMessage();
              })
          })
        }
        .width('90%')
        .margin({ bottom: 10 })
      }
      .width('100%')
      .backgroundColor('#fff')
      .shadow({ radius: 5, color: '#e0e0e0', offsetX: 0, offsetY: -2 })

      Footer();
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f8f9fa')
  }
}
