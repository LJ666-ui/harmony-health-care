import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';
import { AIService } from '../services/AIService';

interface ChatMessage {
  id: number;
  content: string;
  isUser: boolean;
  timestamp: string;
}

@Entry
@Component
struct AIAssistantPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @StorageLink('userId') userId: number = 0;
  @State messages: ChatMessage[] = [];
  @State inputText: string = '';
  @State isTyping: boolean = false;
  private scroller: Scroller = new Scroller();
  private aiService: AIService = AIService.getInstance();

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') || false;
    }
    this.initMessages();
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
      const response = await this.aiService.chat(this.userId, userMessage);
      
      const aiMessage: ChatMessage = {
        id: this.messages.length + 1,
        content: response,
        isUser: false,
        timestamp: this.getCurrentTime()
      };
      
      this.messages.push(aiMessage);
      this.isTyping = false;
      
      setTimeout(() => {
        this.scroller.scrollEdge(Edge.Bottom);
      }, 100);
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

  getCurrentTime(): string {
    const now = new Date();
    return now.getHours().toString().padStart(2, '0') + ':' + 
           now.getMinutes().toString().padStart(2, '0');
  }

  clearHistory(): void {
    this.initMessages();
    ToastUtil.showSuccess('对话已清空');
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
            placeholder: '输入您的问题...',
            text: this.inputText
          })
            .fontSize(this.isElderMode ? 16 : 14)
            .layoutWeight(1)
            .height(45)
            .backgroundColor('#fff')
            .borderRadius(25)
            .padding({ left: 15, right: 15 })
            .onChange((value: string) => {
              this.inputText = value;
            })
            .onSubmit(() => {
              this.sendMessage();
            })

          Button('发送')
            .fontSize(this.isElderMode ? 16 : 14)
            .fontColor('#fff')
            .backgroundColor('#2980B9')
            .borderRadius(25)
            .height(45)
            .width(80)
            .margin({ left: 10 })
            .enabled(this.inputText.trim().length > 0)
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
