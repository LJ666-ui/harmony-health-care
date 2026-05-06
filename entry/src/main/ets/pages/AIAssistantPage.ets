import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';

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
  @State messages: ChatMessage[] = [];
  @State inputText: string = '';
  @State isTyping: boolean = false;
  private scroller: Scroller = new Scroller();

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
    
    // 滚动到底部
    setTimeout(() => {
      this.scroller.scrollEdge(Edge.Bottom);
    }, 100);

    // 模拟AI回复
    this.isTyping = true;
    setTimeout(() => {
      this.receiveMessage(messageToSend);
    }, 1500);
  }

  receiveMessage(userMessage: string): void {
    let aiResponse = '';
    
    // 简单的回复逻辑
    if (userMessage.includes('头痛') || userMessage.includes('头疼')) {
      aiResponse = '头痛可能由多种原因引起，如紧张、疲劳、感冒等。建议您：\n1. 保证充足休息\n2. 避免过度用眼\n3. 适当按摩太阳穴\n如果症状持续或加重，建议及时就医检查。';
    } else if (userMessage.includes('感冒') || userMessage.includes('发烧')) {
      aiResponse = '感冒发烧期间建议：\n1. 多喝温水，保持充足休息\n2. 监测体温变化\n3. 如体温超过38.5°C，可考虑服用退烧药\n4. 饮食清淡，多吃水果蔬菜\n如症状严重或持续不退，请及时就医。';
    } else if (userMessage.includes('用药') || userMessage.includes('吃药')) {
      aiResponse = '用药安全提示：\n1. 请遵医嘱或按说明书用药\n2. 注意药物禁忌和不良反应\n3. 不要随意增减剂量\n4. 如有不适，立即停药并咨询医生\n需要了解具体药品信息，请告诉我药品名称。';
    } else {
      aiResponse = '感谢您的咨询。为了给您提供更准确的建议，请详细描述您的症状或问题。您也可以：\n• 描述具体症状\n• 询问用药指导\n• 了解健康知识\n• 查询检查报告解读';
    }

    const aiMessage: ChatMessage = {
      id: this.messages.length + 1,
      content: aiResponse,
      isUser: false,
      timestamp: this.getCurrentTime()
    };
    
    this.messages.push(aiMessage);
    this.isTyping = false;
    
    setTimeout(() => {
      this.scroller.scrollEdge(Edge.Bottom);
    }, 100);
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
