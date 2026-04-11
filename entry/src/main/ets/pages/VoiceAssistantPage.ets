import { router } from '@kit.ArkUI';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';

interface VoiceCommand {
  id: string;
  icon: string;
  title: string;
  description: string;
  targetPage?: string;
  isEmergency?: boolean;
  reply: string;
}

interface ChatMessage {
  id: string;
  type: 'user' | 'assistant';
  content: string;
  timestamp: number;
  isEmergency?: boolean;
}

@Entry
@Component
struct VoiceAssistantPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State isRecording: boolean = false;
  @State recordStatus: string = '点击开始语音交互';
  @State scaleValue: number = 1.0;
  @State rippleOpacity: number = 0;
  @State chatMessages: ChatMessage[] = [];
  @State inputText: string = '';
  @State showEmergencyDialog: boolean = false;
  @State showChatHistory: boolean = true;

  private scroller: Scroller = new Scroller();

  @State voiceCommands: VoiceCommand[] = [
    { id: '1', icon: '📋', title: '挂号/预约', description: '快速预约医生门诊', targetPage: 'pages/Appointments', reply: '已为您打开预约页面，您可以选择医生和时间进行预约。' },
    { id: '2', icon: '🗺️', title: '打开院内AR导航', description: '智能导航到科室位置', targetPage: 'pages/ARNavigationPage', reply: '正在启动AR导航，请将手机对准前方，我会为您指引路线。' },
    { id: '3', icon: '📊', title: '查询健康记录', description: '查看历史健康数据', targetPage: 'pages/HealthRecords', reply: '已为您打开健康记录页面，您可以查看血压、血糖等历史数据趋势图。' },
    { id: '4', icon: '💊', title: '设置用药提醒', description: '管理药物服用时间', targetPage: 'pages/Medications', reply: '用药提醒页面已打开，您可以查看今日待服用的药物并设置提醒时间。' },
    { id: '5', icon: '⚠️', title: '查看健康风险评估', description: '获取个性化风险报告', targetPage: 'pages/RiskAssessmentPage', reply: '正在为您生成健康风险评估报告，包含多维度风险分析。' },
    { id: '6', icon: '🏥', title: '查找附近医院', description: '搜索周边医疗机构', targetPage: 'pages/HospitalPage', reply: '已为您搜索附近医院，按距离排序，您可以根据需要选择就诊医院。' },
    { id: '7', icon: '🧘', title: '开始康复训练', description: '进入康复课程列表', targetPage: 'pages/RehabListPage', reply: '康复课程列表已打开，推荐您从颈椎康复训练开始，适合日常练习。' },
    { id: '8', icon: '📖', title: '阅读健康科普文章', description: '浏览医学知识库', targetPage: 'pages/ScienceListPage', reply: '科普文章库已为您打开，涵盖心血管、骨科、营养学等多个领域。' },
    { id: '9', icon: '⌚', title: '连接智能设备', description: '配对健康监测设备', targetPage: 'pages/DeviceDiscoveryPage', reply: '设备发现页面已打开，请在附近搜索可连接的健康监测设备。' },
    { id: '10', icon: '🔒', title: '查看隐私设置', description: '管理数据访问权限', targetPage: 'pages/PrivacyPage', reply: '隐私设置页面已打开，您可以查看和管理您的数据使用权限。' },
    { id: '11', icon: '🆘', title: '紧急求助', description: '一键拨打120急救电话', isEmergency: true, reply: '检测到紧急求助指令！正在为您准备拨打120急救电话...' }
  ];

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    }

    const storedMessages = AppStorage.get<ChatMessage[]>('chatMessages');
    if (storedMessages && storedMessages.length > 0) {
      this.chatMessages = storedMessages;
    } else {
      this.addMessage('assistant', '您好！我是小艺语音助手，可以帮您预约挂号、查询健康记录、导航找科室等，请问有什么可以帮您？');
    }
  }

  addMessage(type: 'user' | 'assistant', content: string, isEmergency?: boolean): void {
    const message: ChatMessage = {
      id: Date.now().toString(),
      type: type,
      content: content,
      timestamp: Date.now(),
      isEmergency: isEmergency
    };

    this.chatMessages = [...this.chatMessages, message];
    AppStorage.setOrCreate<ChatMessage[]>('chatMessages', this.chatMessages);

    setTimeout(() => {
      this.scroller.scrollEdge(Edge.Bottom);
    }, 100);
  }

  handleCommandClick(command: VoiceCommand): void {
    this.addMessage('user', command.title);

    if (command.isEmergency) {
      this.showEmergencyDialog = true;
      this.addMessage('assistant', command.reply, true);
      return;
    }

    setTimeout(() => {
      this.addMessage('assistant', command.reply);
      if (command.targetPage) {
        setTimeout(() => {
          try {
            router.pushUrl({ url: command.targetPage! });
          } catch (e) {
            console.error('路由跳转失败:', e);
          }
        }, 800);
      }
    }, 500);
  }

  handleSendMessage(): void {
    if (!this.inputText.trim()) return;

    const userInput = this.inputText.trim();
    this.addMessage('user', userInput);
    this.inputText = '';

    let matchedCommand: VoiceCommand | undefined;
    for (const cmd of this.voiceCommands) {
      if (userInput.includes(cmd.title) || userInput.includes(cmd.description.substring(0, 4))) {
        matchedCommand = cmd;
        break;
      }
    }

    setTimeout(() => {
      if (matchedCommand !== undefined) {
        const cmd = matchedCommand;
        if (cmd.isEmergency) {
          this.showEmergencyDialog = true;
          this.addMessage('assistant', cmd.reply, true);
        } else {
          this.addMessage('assistant', cmd.reply);
          if (cmd.targetPage) {
            setTimeout(() => {
              try {
                router.pushUrl({ url: cmd.targetPage });
              } catch (e) {
                console.error('路由跳转失败:', e);
              }
            }, 800);
          }
        }
      } else {
        this.addMessage('assistant', '抱歉，我没有完全理解您的意思。您可以尝试说"挂号"、"查健康记录"、"导航"等指令，或者点击下方的快捷指令按钮。');
      }
    }, 800);
  }

  handleEmergencyCall(): void {
    ToastUtil.emergencyCall();

    this.showEmergencyDialog = false;

    setTimeout(() => {
      this.addMessage('assistant', '已为您模拟拨打120急救电话。请注意：这是模拟功能，真实紧急情况请直接拨打120。');
    }, 2000);
  }

  clearChatHistory(): void {
    this.chatMessages = [];
    AppStorage.setOrCreate<ChatMessage[]>('chatMessages', []);
    this.addMessage('assistant', '对话历史已清空。有什么我可以帮助您的吗？');
  }

  startRecording(): void {
    if (this.isRecording) return;

    this.isRecording = true;
    this.recordStatus = '正在聆听...';
    this.scaleValue = 1.1;
    this.rippleOpacity = 0.6;

    setTimeout(() => {
      this.recordStatus = '识别中...';
      this.scaleValue = 0.95;
    }, 1500);

    setTimeout(() => {
      this.recordStatus = '指令执行中';
      this.scaleValue = 1.05;
    }, 3000);

    setTimeout(() => {
      this.resetRecording();
    }, 4500);
  }

  resetRecording(): void {
    this.isRecording = false;
    this.recordStatus = '点击开始语音交互';
    this.scaleValue = 1.0;
    this.rippleOpacity = 0;
  }

  executeCommand(command: VoiceCommand): void {
    this.handleCommandClick(command);
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

        Text('小艺语音助手')
          .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
          .fontWeight('bold')
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center);

        Text('🗑️')
          .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
          .fontColor('#999999')
          .margin({ right: 16 })
          .onClick(() => {
            this.clearChatHistory();
          });
      }
      .width('100%')
      .height(56)
      .backgroundColor('#FFFFFF')
      .justifyContent(FlexAlign.Center);

      if (this.showChatHistory) {
        Column({ space: 0 }) {
          Scroll(this.scroller) {
            Column({ space: 12 }) {
              ForEach(this.chatMessages, (message: ChatMessage) => {
                if (message.type === 'user') {
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
                    }
                    .alignItems(HorizontalAlign.End);
                  }
                  .width('100%')
                  .padding({ right: 12 });
                } else {
                  Row() {
                    Column({ space: 4 }) {
                      if (message.isEmergency) {
                        Column({ space: 8 }) {
                          Text('🚨 紧急求助')
                            .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                            .fontWeight('bold')
                            .fontColor('#FFFFFF')
                            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                            .backgroundColor('#FF4D4F')
                            .borderRadius(8);

                          Text(message.content)
                            .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                            .fontColor('#333333')
                            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
                            .backgroundColor('#FFF1F0')
                            .border({ width: 1, color: '#FFCCC7' })
                            .borderRadius({ topLeft: 16, topRight: 16, bottomLeft: 4, bottomRight: 16 });

                          Button('拨打120')
                            .height(GlobalTheme.getButtonHeight(this.isElderMode) - 8)
                            .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                            .fontWeight('bold')
                            .fontColor('#FFFFFF')
                            .backgroundColor('#FF4D4F')
                            .borderRadius(20)
                            .onClick(() => {
                              this.handleEmergencyCall();
                            });
                        }
                        .padding(12)
                        .backgroundColor('#FFFFFF')
                        .borderRadius(12)
                        .shadow({ radius: 8, color: '#FF4D4F30', offsetX: 0, offsetY: 2 });
                      } else {
                        Text(message.content)
                          .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                          .fontColor('#333333')
                          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
                          .backgroundColor('#F5F5F5')
                          .borderRadius({ topLeft: 16, topRight: 16, bottomLeft: 4, bottomRight: 16 })
                          .constraintSize({ maxWidth: '80%' });
                      }
                    }
                    .alignItems(HorizontalAlign.Start);

                    Blank();
                  }
                  .width('100%')
                  .padding({ left: 12 });
                }
              }, (message: ChatMessage) => message.id);
            }
            .width('100%')
            .padding({ top: 12, bottom: 12 });
          }
          .width('100%')
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .align(Alignment.Top)
          .backgroundColor('#FAFBFC');

          Row({ space: 8 }) {
            TextInput({ text: this.inputText, placeholder: '输入消息或语音指令...' })
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
          }
          .width('100%')
          .padding(12)
          .backgroundColor('#FFFFFF');
        }
        .layoutWeight(1);
      }

      Scroll() {
        Column({ space: GlobalTheme.getSpacingLG(this.isElderMode) }) {
          Text('语音助手')
            .fontSize(GlobalTheme.getFontSizeTitle(this.isElderMode))
            .fontWeight('bold')
            .fontColor('#1677FF')
            .margin({ top: GlobalTheme.getSpacingLG(this.isElderMode), bottom: GlobalTheme.getSpacingMD(this.isElderMode) });

          Column({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
            Stack({ alignContent: Alignment.Center }) {
              if (this.rippleOpacity > 0) {
                Circle()
                  .width(this.isElderMode ? 160 : 140)
                  .height(this.isElderMode ? 160 : 140)
                  .fill('#1677FF15')
                  .opacity(this.rippleOpacity)
                  .animation({
                    duration: 1000,
                    curve: Curve.EaseInOut,
                    iterations: -1,
                    playMode: PlayMode.Alternate
                  });
              }

              Circle()
                .width(this.isElderMode ? 120 : 100)
                .height(this.isElderMode ? 120 : 100)
                .fill('#1677FF')
                .scale({ x: this.scaleValue, y: this.scaleValue })
                .animation({
                  duration: 300,
                  curve: Curve.EaseInOut
                })
                .onClick(() => {
                  this.startRecording();
                });

              Column({ space: 4 }) {
                Text('🎤')
                  .fontSize(this.isElderMode ? 36 : 28);

                Text(this.isRecording ? '●' : '')
                  .fontSize(12)
                  .fontColor('#FFFFFF');
              }
            }
            .width(this.isElderMode ? 180 : 160)
            .height(this.isElderMode ? 180 : 160)
            .margin({ top: GlobalTheme.getSpacingMD(this.isElderMode), bottom: GlobalTheme.getSpacingMD(this.isElderMode) });

            Text(this.recordStatus)
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontColor(this.isRecording ? '#1677FF' : '#666666')
              .fontWeight(this.isRecording ? FontWeight.Bold : FontWeight.Normal)
              .margin({ bottom: GlobalTheme.getSpacingMD(this.isElderMode) });
          }
          .width('85%')
          .padding(GlobalTheme.getSpacingMD(this.isElderMode))
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .shadow({ radius: 12, color: '#00000008', offsetX: 0, offsetY: 4 });

          Column({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
            Text('支持的语音指令')
              .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
              .fontWeight('bold')
              .fontColor('#333333')
              .margin({ bottom: this.isElderMode ? 12 : 8 });

            ForEach(this.voiceCommands, (command: VoiceCommand) => {
              Row({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
                Text(command.icon)
                  .fontSize(this.isElderMode ? 32 : 24);

                Column({ space: 4 }) {
                  Text(command.title)
                    .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                    .fontWeight('bold')
                    .fontColor('#333333');

                  Text(command.description)
                    .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                    .fontColor('#999999');
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1);

                Text('›')
                  .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                  .fontColor('#CCCCCC');
              }
              .width('100%')
              .padding(GlobalTheme.getSpacingMD(this.isElderMode))
              .backgroundColor('#FAFBFC')
              .borderRadius(12)
              .border({ width: 1, color: '#F0F0F0' })
              .onClick(() => {
                this.executeCommand(command);
              });
            }, (command: VoiceCommand) => command.id);
          }
          .width('85%')
          .padding(GlobalTheme.getSpacingMD(this.isElderMode))
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .shadow({ radius: 12, color: '#00000008', offsetX: 0, offsetY: 4 });
        }
        .width('100%')
        .padding({ top: GlobalTheme.getSpacingLG(this.isElderMode), bottom: GlobalTheme.getSpacingLG(this.isElderMode) });
      }
      .height(0)
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top);

      Footer({ activeIndex: 4 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }
}
