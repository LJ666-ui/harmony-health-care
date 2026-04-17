import { router } from '@kit.ArkUI';
import http from '@ohos.net.http';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';

interface VoiceCommand {
  id: string;
  icon: string;
  title: string;
  keywords: string[];
  description: string;
  targetPage?: string;
  isEmergency?: boolean;
  reply: string;
  mode: 'health' | 'command';
}

interface ChatMessage {
  id: string;
  type: 'user' | 'assistant' | 'system';
  content: string;
  timestamp: number;
  isEmergency?: boolean;
  isVoice?: boolean;
}

interface ConversationItem {
  role: string;
  content: string;
}

interface RecognitionListenerInfo {
  onStart: () => void;
  onResult: (result: string) => void;
  onComplete: (result: string) => void;
  onError: (error: string) => void;
}

@Entry
@Component
struct VoiceAssistantPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State currentMode: 'health' | 'command' = 'command';
  @State isRecording: boolean = false;
  @State recordStatus: string = '点击或按住麦克风开始说话';
  @State recognizedText: string = '';
  @State scaleValue: number = 1.0;
  @State rippleOpacity1: number = 0;
  @State rippleOpacity2: number = 0;
  @State rippleOpacity3: number = 0;
  @State chatMessages: ChatMessage[] = [];
  @State showEmergencyDialog: boolean = false;
  @State isTtsEnabled: boolean = true;
  @State isLoading: boolean = false;

  private scroller: Scroller = new Scroller();
  private conversationHistory: ConversationItem[] = [];
  private retryCount: number = 0;
  private maxRetryCount: number = 3;

  @State voiceCommands: VoiceCommand[] = [
    { id: '1', icon: '📋', title: '挂号/预约', keywords: ['挂号', '预约', '门诊'], description: '快速预约医生门诊', targetPage: 'pages/Appointments', reply: '已为您打开预约页面，您可以选择医生和时间进行预约。', mode: 'command' },
    { id: '2', icon: '🗺️', title: '打开AR导航', keywords: ['导航', '找科室', 'AR'], description: '智能导航到科室位置', targetPage: 'pages/ARNavigationPage', reply: '正在启动AR导航，请将手机对准前方，我会为您指引路线。', mode: 'command' },
    { id: '3', icon: '📊', title: '查询健康记录', keywords: ['健康记录', '查记录', '历史数据'], description: '查看历史健康数据', targetPage: 'pages/HealthRecords', reply: '已为您打开健康记录页面，您可以查看血压、血糖等历史数据趋势图。', mode: 'command' },
    { id: '4', icon: '💊', title: '设置用药提醒', keywords: ['用药', '吃药', '药物'], description: '管理药物服用时间', targetPage: 'pages/Medications', reply: '用药提醒页面已打开，您可以查看今日待服用的药物并设置提醒时间。', mode: 'command' },
    { id: '5', icon: '⚠️', title: '健康风险评估', keywords: ['风险评估', '风险', '评估'], description: '获取个性化风险报告', targetPage: 'pages/RiskAssessmentPage', reply: '正在为您生成健康风险评估报告，包含多维度风险分析。', mode: 'command' },
    { id: '6', icon: '🏥', title: '查找附近医院', keywords: ['医院', '诊所', '附近'], description: '搜索周边医疗机构', targetPage: 'pages/HospitalPage', reply: '已为您搜索附近医院，按距离排序，您可以根据需要选择就诊医院。', mode: 'command' },
    { id: '7', icon: '🧘', title: '康复训练', keywords: ['康复', '训练', '运动'], description: '进入康复课程列表', targetPage: 'pages/RehabListPage', reply: '康复课程列表已打开，推荐您从颈椎康复训练开始，适合日常练习。', mode: 'command' },
    { id: '8', icon: '📖', title: '阅读科普文章', keywords: ['科普', '文章', '知识'], description: '浏览医学知识库', targetPage: 'pages/ScienceListPage', reply: '科普文章库已为您打开，涵盖心血管、骨科、营养学等多个领域。', mode: 'command' },
    { id: '9', icon: '⌚', title: '连接设备', keywords: ['设备', '连接', '配对'], description: '配对健康监测设备', targetPage: 'pages/DeviceDiscoveryPage', reply: '设备发现页面已打开，请在附近搜索可连接的健康监测设备。', mode: 'command' },
    { id: '10', icon: '🔒', title: '隐私设置', keywords: ['隐私', '权限', '设置'], description: '管理数据访问权限', targetPage: 'pages/PrivacyPage', reply: '隐私设置页面已打开，您可以查看和管理您的数据使用权限。', mode: 'command' },
    { id: '11', icon: '🆘', title: '紧急求助', keywords: ['紧急', '求助', '120', '救命'], description: '一键拨打120急救电话', isEmergency: true, reply: '检测到紧急求助指令！正在为您准备拨打120急救电话...', mode: 'command' }
  ];

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    }

    const storedMessages = AppStorage.get<ChatMessage[]>('voiceChatMessages');
    if (storedMessages && storedMessages.length > 0) {
      this.chatMessages = storedMessages;
    } else {
      this.addMessage('system', '欢迎使用小艺语音助手！\n\n💡 使用提示：\n• 点击麦克风按钮开始录音\n• 说"血压高怎么办"进行健康咨询\n• 说"打开健康记录"执行操作指令\n\n请问有什么可以帮您？');
    }
  }

  addMessage(type: 'user' | 'assistant' | 'system', content: string, isEmergency?: boolean, isVoice?: boolean): void {
    const message: ChatMessage = {
      id: Date.now().toString() + Math.random().toString(36).substring(2, 11),
      type,
      content,
      timestamp: Date.now(),
      isEmergency,
      isVoice
    };

    const newMessages: ChatMessage[] = [...this.chatMessages, message];
    this.chatMessages = newMessages;
    AppStorage.setOrCreate<ChatMessage[]>('voiceChatMessages', newMessages);

    setTimeout(() => {
      try {
        this.scroller.scrollEdge(Edge.Bottom);
      } catch (e) {
        console.error('scroll error:', e);
      }
    }, 100);
  }

  async startRecording(): Promise<void> {
    if (this.isRecording || this.isLoading) return;

    this.isRecording = true;
    this.recordStatus = '正在聆听...';
    this.recognizedText = '';
    this.scaleValue = 1.15;
    this.rippleOpacity1 = 0.6;
    this.retryCount = 0;

    setTimeout(() => {
      this.rippleOpacity2 = 0.4;
    }, 200);

    setTimeout(() => {
      this.rippleOpacity3 = 0.2;
    }, 400);

    await this.startDemoRecognition();
  }

  stopRecording(): void {
    if (!this.isRecording) return;

    this.isRecording = false;
    this.recordStatus = '处理中...';
    this.scaleValue = 0.95;
    this.rippleOpacity1 = 0;
    this.rippleOpacity2 = 0;
    this.rippleOpacity3 = 0;

    if (this.recognizedText.trim()) {
      this.processRecognizedText(this.recognizedText.trim());
    } else {
      this.handleRecognitionFailure('未检测到语音输入，请重试');
    }
  }

  async startDemoRecognition(): Promise<void> {
    const demoPhrases: string[] = [
      '血压高怎么办',
      '打开健康记录',
      '查找附近医院',
      '预约挂号',
      '血糖正常值是多少'
    ];

    const randomIndex: number = Math.floor(Math.random() * demoPhrases.length);
    const randomPhrase: string = demoPhrases[randomIndex];

    let displayText: string = '';
    for (let i = 0; i < randomPhrase.length; i++) {
      await new Promise<void>((resolve: () => void) => {
        setTimeout(() => {
          displayText += randomPhrase[i];
          this.recognizedText = displayText;
          this.recordStatus = `识别中: ${displayText}...`;
          resolve();
        }, 150 + Math.random() * 100);
      });
    }

    this.recordStatus = `识别完成: ${randomPhrase}`;

    setTimeout(() => {
      this.stopRecording();
    }, 500);
  }

  handleRecognitionFailure(errorMsg: string): void {
    this.retryCount++;

    if (this.retryCount <= this.maxRetryCount) {
      this.addMessage('system', `❌ 识别失败（${this.retryCount}/${this.maxRetryCount}）: ${errorMsg}\n请点击麦克风重新尝试`);
    } else {
      this.addMessage('system', `❌ 连续${this.maxRetryCount}次识别失败\n\n可能原因：\n• 麦克风权限未开启\n• 网络连接异常\n• 说话声音太小\n\n建议：\n• 检查麦克风权限设置\n• 在安静环境重试\n• 或使用文字输入代替`);
      this.resetRecordingUI();
    }
  }

  resetRecordingUI(): void {
    this.isRecording = false;
    this.recordStatus = '点击或按住麦克风开始说话';
    this.scaleValue = 1.0;
    this.rippleOpacity1 = 0;
    this.rippleOpacity2 = 0;
    this.rippleOpacity3 = 0;
    this.recognizedText = '';
  }

  processRecognizedText(text: string): void {
    this.addMessage('user', text, false, true);

    const convItem: ConversationItem = { role: 'user', content: text };
    this.conversationHistory.push(convItem);

    const matchedCommand: VoiceCommand | undefined = this.matchCommand(text);

    if (matchedCommand !== undefined) {
      this.executeCommand(matchedCommand);
    } else if (this.currentMode === 'health' || this.isHealthQuestion(text)) {
      this.callAiForHealthAdvice(text);
    } else {
      this.showUnsupportedCommandHelp(text);
    }
  }

  matchCommand(input: string): VoiceCommand | undefined {
    const lowerInput: string = input.toLowerCase();

    for (const cmd of this.voiceCommands) {
      for (const keyword of cmd.keywords) {
        if (lowerInput.includes(keyword.toLowerCase())) {
          return cmd;
        }
      }
    }

    return undefined;
  }

  isHealthQuestion(text: string): boolean {
    const healthKeywords: string[] = [
      '血压', '血糖', '心脏', '头痛', '发烧', '感冒', '失眠',
      '怎么', '为什么', '什么', '如何', '是否', '能否', '可以吗',
      '症状', '治疗', '预防', '注意', '饮食', '运动', '药物',
      '正常值', '多少', '怎么办', '好不好', '行不行'
    ];

    for (const keyword of healthKeywords) {
      if (text.includes(keyword)) {
        return true;
      }
    }

    return false;
  }

  executeCommand(command: VoiceCommand): void {
    if (command.isEmergency) {
      this.showEmergencyDialog = true;
      this.addMessage('assistant', command.reply, true);
      return;
    }

    this.isLoading = true;
    this.addMessage('assistant', command.reply);

    setTimeout(() => {
      this.isLoading = false;
      if (command.targetPage) {
        setTimeout(() => {
          try {
            router.pushUrl({ url: command.targetPage! });
          } catch (e) {
            console.error('路由跳转失败:', e);
            this.addMessage('system', '⚠️ 页面跳转失败，请手动从首页进入');
          }
        }, 800);
      }
    }, 500);
  }

  async callAiForHealthAdvice(question: string): Promise<void> {
    this.isLoading = true;
    this.addMessage('assistant', '🤔 正在思考中...');

    try {
      const answer: string = await this.fetchAiResponse(question);
      this.updateLastAssistantMessage(answer);

      const convItem: ConversationItem = { role: 'assistant', content: answer };
      this.conversationHistory.push(convItem);

    } catch (error) {
      const errorMsg: string = error instanceof Error ? error.message : 'AI服务暂时不可用';
      this.updateLastAssistantMessage(`抱歉，获取健康建议失败：${errorMsg}\n\n您可以稍后重试，或直接联系专业医生咨询。`);
    } finally {
      this.isLoading = false;
    }
  }

  updateLastAssistantMessage(newContent: string): void {
    const messages: ChatMessage[] = [];
    for (let i = 0; i < this.chatMessages.length; i++) {
      if (i === this.chatMessages.length - 1 && this.chatMessages[i].type === 'assistant') {
        const updatedMsg: ChatMessage = {
          id: this.chatMessages[i].id,
          type: this.chatMessages[i].type,
          content: newContent,
          timestamp: this.chatMessages[i].timestamp,
          isEmergency: this.chatMessages[i].isEmergency,
          isVoice: this.chatMessages[i].isVoice
        };
        messages.push(updatedMsg);
      } else {
        messages.push(this.chatMessages[i]);
      }
    }
    this.chatMessages = messages;
    AppStorage.setOrCreate<ChatMessage[]>('voiceChatMessages', messages);
  }

  async fetchAiResponse(question: string): Promise<string> {
    return new Promise<string>((resolve: (value: string) => void, reject: (reason: Error) => void) => {
      try {
        let baseUrl: string = AppStorage.get<string>('apiBaseUrl') || '';
        if (!baseUrl) {
          baseUrl = 'http://localhost:8080';
        }

        const url: string = `${baseUrl}/ai/chat`;
        const healthContext: string = this.buildHealthContext();

        const httpRequest: http.HttpRequest = http.createHttp();

        const headerObj: Record<string, string> = {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${AppStorage.get<string>('token') || ''}`
        };

        const requestOption: http.HttpRequestOptions = {
          method: http.RequestMethod.POST,
          header: headerObj,
          extraData: JSON.stringify({
            question: question,
            context: healthContext,
            history: this.getHistoryArray()
          }),
          connectTimeout: 10000,
          readTimeout: 30000
        };

        httpRequest.request(url, requestOption)
          .then((data: http.HttpResponse) => {
            if (data.responseCode === 200) {
              try {
                const response = JSON.parse(data.result as string) as Record<string, Object>;
                const content: string = response['content'] as string || response['answer'] as string || '';
                const disclaimer: string = '\n\n---\n⚕️ **温馨提示**: 以上建议仅供参考，如有不适请及时就医。';
                resolve(content + disclaimer);
              } catch (parseError) {
                reject(new Error('解析响应数据失败'));
              }
            } else {
              reject(new Error(`服务器返回错误: ${data.responseCode}`));
            }
          })
          .catch((err: Error) => {
            reject(err);
          });

      } catch (error) {
        const mockAnswers: Record<string, string> = {
          '血压': '关于血压问题：\n\n✅ **成人正常血压范围：**\n• 收缩压（高压）：90-139 mmHg\n• 舒张压（低压）：60-89 mmHg\n\n💡 **高血压建议：**\n1. 低盐饮食（每日<5g盐）\n2. 规律运动（每周150分钟中等强度）\n3. 控制体重（BMI保持在18.5-24）\n4. 戒烟限酒\n5. 定期监测血压\n\n⚠️ **何时就医：**\n• 血压持续≥140/90 mmHg\n• 出现头痛、头晕等症状\n• 有家族高血压史',
          '血糖': '关于血糖问题：\n\n✅ **正常血糖参考值：**\n• 空腹血糖：3.9-6.1 mmol/L\n• 餐后2小时：<7.8 mmol/L\n\n💡 **糖尿病预防：**\n1. 控制碳水化合物摄入\n2. 增加膳食纤维\n3. 规律运动\n4. 保持健康体重\n5. 定期体检筛查',
          'default': '感谢您的健康提问！\n\n基于您的描述，我建议：\n\n1. 📋 **观察症状变化** - 记录出现的时间和频率\n2. 💊 **保持良好作息** - 充足睡眠，规律饮食\n3. 🏃 **适度运动** - 每天保持30分钟活动\n4. ⚠️ **及时就医** - 如症状持续或加重\n\n如需更详细的个性化建议，建议您提供更多具体信息，或前往医院就诊。'
        };

        let mockAnswer: string = mockAnswers['default'];
        const keys: string[] = Object.keys(mockAnswers);
        for (let i = 0; i < keys.length; i++) {
          if (question.includes(keys[i])) {
            mockAnswer = mockAnswers[keys[i]];
            break;
          }
        }

        const disclaimer: string = '\n\n---\n⚕️ **温馨提示**: 以上建议仅供参考，如有不适请及时就医。';
        resolve(mockAnswer + disclaimer);
      }
    });
  }

  getHistoryArray(): ConversationItem[] {
    const result: ConversationItem[] = [];
    const startIndex: number = Math.max(0, this.conversationHistory.length - 10);
    for (let i = startIndex; i < this.conversationHistory.length; i++) {
      result.push(this.conversationHistory[i]);
    }
    return result;
  }

  buildHealthContext(): string {
    let context: string = '用户基本信息：';

    try {
      const appStore: Record<string, Object> | undefined = AppStorage.get<Record<string, Object>>('appStore');
      const userInfo: Record<string, Object> = (appStore !== undefined) ? (appStore['userInfo'] as Record<string, Object>) : {};

      if (userInfo['age']) {
        context += `\n年龄: ${userInfo['age']}`;
      }
      if (userInfo['gender']) {
        context += `\n性别: ${userInfo['gender']}`;
      }
      if (userInfo['allergies']) {
        context += `\n过敏史: ${JSON.stringify(userInfo['allergies'])}`;
      }
    } catch (error) {
      console.error('构建健康上下文失败:', error);
    }

    return context;
  }

  showUnsupportedCommandHelp(input: string): void {
    const suggestions: string[] = [];

    if (input.includes('血压') || input.includes('血糖')) {
      suggestions.push('💡 您可以问："血压多少算正常"、"血糖高怎么办"');
    }

    if (input.includes('怎么') || input.includes('如何')) {
      suggestions.push('💡 您可以说："怎么预防感冒"、"如何改善睡眠"');
    }

    suggestions.push('\n\n📋 **常用操作指令示例：**\n• "打开健康记录"\n• "查找附近医院"\n• "预约挂号"\n• "开始康复训练"');

    let helpMessage: string = `抱歉，我没有完全理解"${input}"。\n\n`;
    helpMessage += suggestions.join('\n');

    this.addMessage('assistant', helpMessage);
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
    this.conversationHistory = [];
    AppStorage.setOrCreate<ChatMessage[]>('voiceChatMessages', []);
    this.resetRecordingUI();
    this.addMessage('system', '对话历史已清空。有什么我可以帮助您的吗？');
  }

  switchMode(mode: 'health' | 'command'): void {
    this.currentMode = mode;
    const modeName: string = mode === 'health' ? '健康咨询模式' : '操作指令模式';
    ToastUtil.showInfo(`已切换至${modeName}`);
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

      Scroll(this.scroller) {
        Column({ space: 12 }) {
          ForEach(this.chatMessages, (message: ChatMessage) => {
            if (message.type === 'system') {
              Column() {
                Text(message.content)
                  .fontSize(this.isElderMode ? 14 : 12)
                  .fontColor('#666666')
                  .lineHeight(this.isElderMode ? 22 : 18)
                  .padding(12)
                  .backgroundColor('#F0F5FF')
                  .borderRadius(8)
                  .border({ width: 1, color: '#D4E3FF' });
              }
              .width('92%')
              .alignItems(HorizontalAlign.Center)
              .margin({ top: 8 });
            } else if (message.type === 'user') {
              Row() {
                Blank();

                Column({ space: 4 }) {
                  Row({ space: 4 }) {
                    Text(message.content)
                      .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                      .fontColor('#FFFFFF')
                      .padding({ left: 16, right: 16, top: 10, bottom: 10 })
                      .backgroundColor('#1677FF')
                      .borderRadius({ topLeft: 16, topRight: 16, bottomLeft: 16, bottomRight: 4 })
                      .constraintSize({ maxWidth: '75%' });

                    if (message.isVoice) {
                      Text('🎤')
                        .fontSize(16);
                    }
                  }
                }
                .alignItems(HorizontalAlign.End);
              }
              .width('100%')
              .padding({ right: 12 });
            } else {
              Row() {
                Column({ space: 8 }) {
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
                      .lineHeight(this.isElderMode ? 26 : 22)
                      .padding({ left: 16, right: 16, top: 10, bottom: 10 })
                      .backgroundColor('#F5F5F5')
                      .borderRadius({ topLeft: 16, topRight: 16, bottomLeft: 4, bottomRight: 16 })
                      .constraintSize({ maxWidth: '85%' });
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
        .padding({ top: 12, bottom: 120 });
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
      .backgroundColor('#FAFBFC');

      Column({ space: 12 }) {
        Row({ space: 8 }) {
          Button('💬 操作指令')
            .height(36)
            .fontSize(this.isElderMode ? 14 : 12)
            .fontColor(this.currentMode === 'command' ? '#FFFFFF' : '#1677FF')
            .backgroundColor(this.currentMode === 'command' ? '#1677FF' : '#FFFFFF')
            .border({ width: 1, color: '#1677FF' })
            .borderRadius(18)
            .layoutWeight(1)
            .onClick(() => {
              this.switchMode('command');
            });

          Button('🏥 健康咨询')
            .height(36)
            .fontSize(this.isElderMode ? 14 : 12)
            .fontColor(this.currentMode === 'health' ? '#FFFFFF' : '#1677FF')
            .backgroundColor(this.currentMode === 'health' ? '#1677FF' : '#FFFFFF')
            .border({ width: 1, color: '#1677FF' })
            .borderRadius(18)
            .layoutWeight(1)
            .onClick(() => {
              this.switchMode('health');
            });
        }
        .width('100%');

        Stack({ alignContent: Alignment.Center }) {
          if (this.rippleOpacity3 > 0) {
            Circle()
              .width(this.isElderMode ? 220 : 190)
              .height(this.isElderMode ? 220 : 190)
              .fill('#1677FF08')
              .opacity(this.rippleOpacity3)
              .animation({
                duration: 1500,
                curve: Curve.EaseInOut,
                iterations: -1,
                playMode: PlayMode.Alternate
              });
          }

          if (this.rippleOpacity2 > 0) {
            Circle()
              .width(this.isElderMode ? 180 : 155)
              .height(this.isElderMode ? 180 : 155)
              .fill('#1677FF12')
              .opacity(this.rippleOpacity2)
              .animation({
                duration: 1200,
                curve: Curve.EaseInOut,
                iterations: -1,
                playMode: PlayMode.Alternate
              });
          }

          if (this.rippleOpacity1 > 0) {
            Circle()
              .width(this.isElderMode ? 140 : 120)
              .height(this.isElderMode ? 140 : 120)
              .fill('#1677FF18')
              .opacity(this.rippleOpacity1)
              .animation({
                duration: 900,
                curve: Curve.EaseInOut,
                iterations: -1,
                playMode: PlayMode.Alternate
              });
          }

          Circle()
            .width(this.isElderMode ? 110 : 95)
            .height(this.isElderMode ? 110 : 95)
            .fill(this.isRecording ? '#FF4D4F' : '#1677FF')
            .scale({ x: this.scaleValue, y: this.scaleValue })
            .animation({
              duration: 300,
              curve: Curve.EaseInOut
            })
            .gesture(
              LongPressGesture({ repeat: false, duration: 300 })
                .onAction(() => {
                  this.startRecording();
                })
                .onActionEnd(() => {
                  this.stopRecording();
                })
            )
            .onClick(() => {
              if (!this.isRecording) {
                this.startRecording();
                setTimeout(() => {
                  if (this.isRecording) {
                    this.stopRecording();
                  }
                }, 5000);
              }
            });

          Column({ space: 4 }) {
            Text(this.isRecording ? '⬛' : '🎤')
              .fontSize(this.isElderMode ? 40 : 32);

            Text(this.isRecording ? '' : '')
              .fontSize(11)
              .fontColor('#FFFFFF');
          }
        }
        .width(this.isElderMode ? 240 : 210)
        .height(this.isElderMode ? 240 : 210)
        .margin({ top: 8, bottom: 8 });

        Text(this.recordStatus)
          .fontSize(this.isElderMode ? 16 : 14)
          .fontColor(this.isRecording ? '#FF4D4F' : '#666666')
          .fontWeight(this.isRecording ? FontWeight.Bold : FontWeight.Normal)
          .textAlign(TextAlign.Center)
          .maxLines(2)
          .margin({ bottom: 8 });

        if (this.recognizedText && !this.isRecording) {
          Text(`"${this.recognizedText}"`)
            .fontSize(this.isElderMode ? 15 : 13)
            .fontColor('#1677FF')
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 8 });
        }

        Row({ space: 12 }) {
          Button(this.isTtsEnabled ? '🔊 TTS开' : '🔇 TTS关')
            .height(36)
            .fontSize(this.isElderMode ? 14 : 12)
            .fontColor(this.isTtsEnabled ? '#1677FF' : '#999999')
            .backgroundColor('#FFFFFF')
            .border({ width: 1, color: this.isTtsEnabled ? '#1677FF' : '#CCCCCC' })
            .borderRadius(18)
            .onClick(() => {
              this.isTtsEnabled = !this.isTtsEnabled;
              ToastUtil.showInfo(this.isTtsEnabled ? 'TTS语音播报已开启' : 'TTS语音播报已关闭');
            });
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor('#FFFFFF')
      .shadow({ radius: 8, color: '#00000006', offsetX: 0, offsetY: -2 });

      Scroll() {
        Column({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
          Text('📋 支持的语音指令')
            .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
            .fontWeight('bold')
            .fontColor('#333333')
            .margin({ bottom: this.isElderMode ? 12 : 8 });

          Grid() {
            ForEach(this.voiceCommands.filter((cmd: VoiceCommand) => cmd.mode === this.currentMode), (command: VoiceCommand) => {
              GridItem() {
                Column({ space: 8 }) {
                  Text(command.icon)
                    .fontSize(this.isElderMode ? 32 : 24);

                  Text(command.title)
                    .fontSize(this.isElderMode ? 14 : 12)
                    .fontWeight('bold')
                    .fontColor('#333333')
                    .textAlign(TextAlign.Center)
                    .maxLines(1);

                  Text(command.description)
                    .fontSize(this.isElderMode ? 11 : 10)
                    .fontColor('#999999')
                    .textAlign(TextAlign.Center)
                    .maxLines(2);
                }
                .width('100%')
                .padding({ top: 12, bottom: 12 })
                .backgroundColor('#FAFBFC')
                .borderRadius(12)
                .border({ width: 1, color: '#F0F0F0' })
                .onClick(() => {
                  this.executeCommand(command);
                });
              }
            }, (command: VoiceCommand) => command.id);
          }
          .columnsTemplate(this.isElderMode ? '1fr 1fr' : '1fr 1fr 1fr')
          .rowsGap(12)
          .columnsGap(12)
          .width('100%');

          if (this.currentMode === 'health') {
            Column({ space: 12 }) {
              Text('💡 健康咨询示例')
                .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
                .fontWeight('bold')
                .fontColor('#1677FF')
                .margin({ bottom: 8 });

              ForEach([
                { q: '血压多少算正常？', icon: '❤️' },
                { q: '老年人如何预防糖尿病？', icon: '💊' },
                { q: '每天应该运动多久？', icon: '🏃' },
                { q: '失眠怎么办？', icon: '😴' },
                { q: '如何保持心脏健康？', icon: '💪' },
                { q: '饮食上有什么注意事项？', icon: '🥗' }
              ], (item: Record<string, string>) => {
                Row({ space: 8 }) {
                  Text(item.icon)
                    .fontSize(20);

                  Text(item.q)
                    .fontSize(this.isElderMode ? 14 : 13)
                    .fontColor('#333333')
                    .layoutWeight(1);
                }
                .width('100%')
                .padding(12)
                .backgroundColor('#F0F5FF')
                .borderRadius(8)
                .onClick(() => {
                  this.processRecognizedText(item.q);
                });
              }, (item: Record<string, string>) => item.q);
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .shadow({ radius: 8, color: '#00000008', offsetX: 0, offsetY: 2 });
          }
        }
        .width('100%')
        .padding({ top: GlobalTheme.getSpacingLG(this.isElderMode), bottom: GlobalTheme.getSpacingLG(this.isElderMode), left: 16, right: 16 });
      }
      .height(0)
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
      .backgroundColor('#F5F7FA');

      Footer({ activeIndex: 4 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }
}
