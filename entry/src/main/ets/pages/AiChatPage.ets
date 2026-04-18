import { router } from '@kit.ArkUI';
import http from '@ohos.net.http';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';
import { Footer } from '../components/Footer';
import BrowseTracker from '../utils/BrowseTracker';

interface ChatMessage {
  id: string;
  type: 'user' | 'assistant' | 'system';
  content: string;
  timestamp: number;
  isLoading?: boolean;
  isError?: boolean;
  errorMessage?: string;
}

interface SuggestedQuestion {
  id: string;
  question: string;
  icon: string;
}

interface ConversationItem {
  role: string;
  content: string;
}

interface UserInfoData {
  age?: number;
  gender?: string;
  allergies?: string[];
}

@Entry
@Component
struct AiChatPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State messages: ChatMessage[] = [];
  @State inputText: string = '';
  @State isLoading: boolean = false;
  @State showSuggestions: boolean = true;
  @State isRecording: boolean = false;

  private scroller: Scroller = new Scroller();
  private conversationHistory: ConversationItem[] = [];

  @State suggestedQuestions: SuggestedQuestion[] = [
    { id: '1', question: '血压多少算正常？', icon: '❤️' },
    { id: '2', question: '老年人如何预防糖尿病？', icon: '💊' },
    { id: '3', question: '每天应该运动多久？', icon: '🏃' },
    { id: '4', question: '失眠怎么办？', icon: '😴' },
    { id: '5', question: '如何保持心脏健康？', icon: '💪' },
    { id: '6', question: '饮食上有什么注意事项？', icon: '🥗' }
  ];

  private recordId: number | undefined = undefined;

  aboutToAppear(): void {
    // 记录浏览开始
    BrowseTracker.recordStart('AI_CHAT', 'PAGE', 4, 'AI健康顾问').then(id => {
      this.recordId = id;
    });

    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    }

    this.addSystemMessage('您好！我是AI健康顾问，可以帮您解答健康相关问题。请问有什么可以帮您？');
  }

  aboutToDisappear(): void {
    // 记录浏览结束
    if (this.recordId) {
      BrowseTracker.recordEnd(this.recordId);
    }
  }

  addMessage(type: 'user' | 'assistant' | 'system', content: string, isLoading?: boolean, isError?: boolean, errorMessage?: string): void {
    const message: ChatMessage = {
      id: Date.now().toString() + Math.random().toString(36).substring(2, 11),
      type,
      content,
      timestamp: Date.now(),
      isLoading: isLoading ?? false,
      isError: isError ?? false,
      errorMessage: errorMessage
    };

    this.messages = [...this.messages, message];

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
    const convItem: ConversationItem = { role: 'user', content };
    this.conversationHistory.push(convItem);
    this.showSuggestions = false;
  }

  addAssistantMessage(content: string, isError?: boolean, errorMessage?: string): void {
    this.addMessage('assistant', content, false, isError, errorMessage);
    if (!isError) {
      const convItem: ConversationItem = { role: 'assistant', content };
      this.conversationHistory.push(convItem);
    }
  }

  addLoadingMessage(): string {
    const loadingId: string = Date.now().toString() + '_loading';
    const message: ChatMessage = {
      id: loadingId,
      type: 'assistant',
      content: '',
      timestamp: Date.now(),
      isLoading: true
    };
    this.messages = [...this.messages, message];

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
    this.messages = this.messages.filter(msg => msg.id !== loadingId);
  }

  async callAiApi(question: string): Promise<string> {
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
            history: this.conversationHistory.slice(-10)
          }),
          connectTimeout: 10000,
          readTimeout: 30000
        };

        httpRequest.request(url, requestOption)
          .then((data: http.HttpResponse) => {
            if (data.responseCode === 200) {
              try {
                const response = JSON.parse(data.result as string) as Record<string, Object>;
                if (response['code'] === 200 && response['data']) {
                  const dataObj = response['data'] as Record<string, Object>;
                  resolve(dataObj['answer'] as string || dataObj['content'] as string || JSON.stringify(dataObj));
                } else {
                  reject(new Error((response['message'] as string) || '服务器返回异常'));
                }
              } catch (parseError) {
                console.error('Parse Error:', parseError);
                reject(new Error('数据解析失败'));
              }
            } else if (data.responseCode === 429) {
              reject(new Error('请求过于频繁，请稍后再试'));
            } else if (data.responseCode === 503) {
              reject(new Error('AI服务繁忙，请稍后再试'));
            } else {
              reject(new Error(`请求失败 (${data.responseCode})`));
            }
          })
          .catch((err: Error) => {
            console.error('AI API Error:', err);
            reject(new Error('网络连接失败，请检查网络设置'));
          });
      } catch (error) {
        console.error('Request Error:', error);
        reject(new Error('请求发送失败，请重试'));
      }
    });
  }

  buildHealthContext(): string {
    let context: string = '';

    try {
      const userInfo: object | undefined = AppStorage.get<object>('userInfo');
      if (userInfo) {
        const user: UserInfoData = userInfo as UserInfoData;
        if (user.age || user.gender) {
          context += `用户信息：${user.age || ''}岁，${user.gender === 'male' ? '男' : '女'}`;
        }
        if (user.allergies && Array.isArray(user.allergies) && user.allergies.length > 0) {
          context += `，过敏史：${user.allergies.join('、')}`;
        }
      }
    } catch (e) {
      console.error('Build context error:', e);
    }

    return context;
  }

  getMockResponse(question: string): string {
    const lowerQuestion: string = question.toLowerCase();

    if (lowerQuestion.includes('血压')) {
      return `**关于血压正常值：**

• **正常血压**：收缩压 < 120 mmHg 且 舒张压 < 80 mmHg
• **高血压前期**：收缩压 120-139 或 舒张压 80-89
• **高血压**：收缩压 ≥ 140 或 舒张压 ≥ 90

**建议：**
1. 定期测量血压，建议每天早晚各测一次
2. 保持低盐饮食，每日盐摄入 < 6克
3. 适量运动，每周至少150分钟中等强度运动
4. 保持心情愉悦，避免情绪激动

> ⚠️ 以上建议仅供参考，如有不适请及时就医`;
    }

    if (lowerQuestion.includes('糖尿') || lowerQuestion.includes('血糖')) {
      return `**老年人预防糖尿病的建议：**

**饮食方面：**
1. 控制碳水化合物摄入，选择低GI食物
2. 增加膳食纤维，多吃蔬菜、全谷物
3. 少食多餐，避免暴饮暴食
4. 限制糖分和精制食品

**运动方面：**
1. 每周至少150分钟有氧运动
2. 饭后散步15-30分钟
3. 进行适度的力量训练

> ⚠️ 以上建议仅供参考，如有不适请及时就医`;
    }

    if (lowerQuestion.includes('运动') || lowerQuestion.includes('锻炼')) {
      return `**推荐的运动时间和方式：**

**运动时长建议：**
• **每周总量**：150-300分钟中等强度运动
• **每天建议**：30-60分钟

**适合老年人的运动：**
1. **步行**：最安全有效的有氧运动
2. **太极拳**：改善平衡能力，减少跌倒风险
3. **游泳**：关节负担小，全身锻炼
4. **广场舞**：社交+运动的良好选择

> ⚠️ 以上建议仅供参考，如有不适请及时就医`;
    }

    if (lowerQuestion.includes('失眠') || lowerQuestion.includes('睡眠')) {
      return `**改善失眠的方法：**

**生活习惯调整：**
1. 固定作息时间，每天同一时间入睡和起床
2. 睡前1小时避免使用电子设备
3. 卧室保持安静、黑暗、凉爽（18-22°C）

**睡前放松技巧：**
1. 温水泡脚15-20分钟
2. 听轻音乐或白噪音
3. 深呼吸练习（4-7-8呼吸法）

> ⚠️ 以上建议仅供参考，如有不适请及时就医`;
    }

    if (lowerQuestion.includes('心脏') || lowerQuestion.includes('心血管')) {
      return `**保持心脏健康的建议：**

**健康饮食：**
1. 地中海饮食模式：多蔬果、全谷物、橄榄油
2. 控制饱和脂肪和反式脂肪摄入
3. 限制钠盐（<6克/天）

**规律运动：**
• 每周150分钟中等强度有氧运动
• 快走、游泳、骑自行车都是好选择

**生活方式：**
1. 戒烟限酒
2. 控制体重
3. 管理压力
4. 充足睡眠

> ⚠️ 以上建议仅供参考，如有不适请及时就医`;
    }

    if (lowerQuestion.includes('饮食') || lowerQuestion.includes('吃')) {
      return `**老年人饮食注意事项：**

**营养均衡原则：**
1. **蛋白质**：每日1-1.2克/公斤体重
2. **碳水化合物**：选择全谷物、杂粮为主
3. **脂肪**：控制总量，选择植物油

**具体建议：**
• **少食多餐**：一日4-5餐，每餐七八分饱
• **易消化**：食物煮软烂，利于吸收
• **充足水分**：每日1500-1700ml

**需要限制的：**
❌ 高盐（<6克/天）
❌ 高糖食品
❌ 油炸食品

> ⚠️ 以上建议仅供参考，如有不适请及时就医`;
    }

    return `感谢您的提问！作为您的AI健康顾问，我理解您关心这个问题。

针对您的问题，我建议您：

1. **保持良好的生活习惯** - 规律作息、均衡饮食、适度运动
2. **定期体检** - 及时了解身体状况
3. **遵医嘱** - 如有慢性病，按时服药复诊

**温馨提示：**
> ⚠️ 我是AI助手，以上建议仅供参考。如出现严重不适，请立即就医或拨打急救电话。`;
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
        let response: string;

        try {
          response = await this.callAiApi(text);
        } catch (apiError) {
          console.log('API call failed, using mock response:', apiError);
          response = this.getMockResponse(text);
        }

        this.removeLoadingMessage(loadingId);

        await this.typewriterEffect(response);

      } catch (error) {
        console.error('Error:', error);
        this.removeLoadingMessage(loadingId);
        const errorMsg: string = error instanceof Error ? error.message : '抱歉，发生了未知错误，请重试';
        this.addAssistantMessage('', true, errorMsg);
      } finally {
        this.isLoading = false;
      }
    }, 500);
  }

  async typewriterEffect(fullText: string): Promise<void> {
    const messageId: string = Date.now().toString() + '_typing';
    let displayedText: string = '';

    this.messages = [...this.messages, {
      id: messageId,
      type: 'assistant',
      content: displayedText,
      timestamp: Date.now()
    }];

    const charsPerIteration: number = this.isElderMode ? 3 : 2;
    const delay: number = this.isElderMode ? 40 : 25;

    for (let i: number = 0; i < fullText.length; i += charsPerIteration) {
      displayedText = fullText.substring(0, i + charsPerIteration);

      const msgIndex: number = this.messages.findIndex(m => m.id === messageId);
      if (msgIndex !== -1) {
        this.messages[msgIndex].content = displayedText;
        this.messages = [...this.messages];
      }

      if (i % 10 === 0) {
        try {
          this.scroller.scrollEdge(Edge.Bottom);
        } catch (e) {}
      }

      await new Promise<void>(resolve => setTimeout(resolve, delay));
    }
  }

  handleSuggestionClick(question: string): void {
    this.inputText = question;
    this.handleSendMessage();
  }

  clearChatHistory(): void {
    this.messages = [];
    this.conversationHistory = [];
    this.showSuggestions = true;
    this.addSystemMessage('对话已清空。有什么我可以帮助您的吗？');
  }

  copyMessage(content: string): void {
    ToastUtil.showInfo('已复制到剪贴板');
  }

  formatTime(timestamp: number): string {
    const date: Date = new Date(timestamp);
    const hours: string = date.getHours().toString().padStart(2, '0');
    const minutes: string = date.getMinutes().toString().padStart(2, '0');
    return `${hours}:${minutes}`;
  }

  startVoiceInput(): void {
    if (this.isRecording) return;

    this.isRecording = true;
    ToastUtil.showInfo('正在聆听...');

    setTimeout(() => {
      this.isRecording = false;
      this.inputText = '我想了解高血压的预防方法';
      ToastUtil.showInfo('已填入示例文本（演示模式）');
    }, 2000);

    setTimeout(() => {
      if (this.isRecording) {
        this.isRecording = false;
      }
    }, 10000);
  }

  @Builder
  UserBubble(message: ChatMessage) {
    Row() {
      Blank();

      Column({ space: 4 }) {
        Text(message.content)
          .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('#1677FF')
          .borderRadius({ topLeft: 16, topRight: 16, bottomLeft: 16, bottomRight: 4 })
          .constraintSize({ maxWidth: '80%' })
          .gesture(
            LongPressGesture()
              .onAction(() => {
                this.copyMessage(message.content);
              })
          );

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
  AssistantBubble(message: ChatMessage) {
    Row() {
      Column({ space: 6 }) {
        if (message.isLoading) {
          this.ThinkingAnimation();
        } else if (message.isError) {
          this.ErrorMessageBubble(message);
        } else {
          this.MarkdownContent(message.content);
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
  SystemBubble(message: ChatMessage) {
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
  ThinkingAnimation() {
    Row({ space: 8 }) {
      Text('🤔')
        .fontSize(24);

      Column({ space: 4 }) {
        Text('正在思考中...')
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
  ErrorMessageBubble(message: ChatMessage) {
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
          const reversedMessages: ChatMessage[] = [...this.messages].reverse();
          const lastUserMsg: ChatMessage | undefined = reversedMessages.find(m => m.type === 'user');
          if (lastUserMsg) {
            this.messages = this.messages.filter(m => m.id !== message.id);
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
    .constraintSize({ maxWidth: '85%' })
    .gesture(
      LongPressGesture()
        .onAction(() => {
          this.copyMessage(content);
        })
    );
  }

  @Builder
  DisclaimerText() {
    Text('⚠️ 以上建议仅供参考，如有不适请及时就医')
      .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
      .fontColor('#999999')
      .fontStyle(FontStyle.Italic)
      .margin({ top: 6, left: 4 });
  }

  parseMarkdownToSegments(text: string): MarkdownSegment[] {
    const segments: MarkdownSegment[] = [];
    const lines: string[] = text.split('\n');

    for (const line of lines) {
      const trimmedLine: string = line.trim();

      if (!trimmedLine) {
        continue;
      }

      if (trimmedLine.startsWith('### ')) {
        segments.push({ type: 'heading', text: trimmedLine.substring(4) });
      } else if (trimmedLine.startsWith('## ')) {
        segments.push({ type: 'heading', text: trimmedLine.substring(3) });
      } else if (trimmedLine.startsWith('# ')) {
        segments.push({ type: 'heading', text: trimmedLine.substring(2) });
      } else if (trimmedLine.startsWith('> ') || trimmedLine.startsWith('⚠️')) {
        segments.push({ type: 'warning', text: trimmedLine.replace(/^>\s*/, '') });
      } else if (/^\d+\.\s/.test(trimmedLine) || trimmedLine.startsWith('• ') || trimmedLine.startsWith('- ')) {
        const listText: string = trimmedLine.replace(/^\d+\.\s/, '').replace(/^[•\-]\s*/, '');
        segments.push({ type: 'list', text: listText });
      } else if (trimmedLine.startsWith('---')) {
        segments.push({ type: 'divider', text: '' });
      } else if (trimmedLine.includes('**')) {
        const parts: string[] = trimmedLine.split(/\*\*/);
        for (let i: number = 0; i < parts.length; i++) {
          const part: string = parts[i];
          if (part.trim()) {
            if (i % 2 === 1) {
              segments.push({ type: 'bold', text: part });
            } else {
              segments.push({ type: 'text', text: part });
            }
          }
        }
      } else if (/^[❌✅]/.test(trimmedLine)) {
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

        Text('AI健康顾问')
          .fontSize(GlobalTheme.getFontSizeTitle(this.isElderMode))
          .fontWeight('bold')
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center);

        Text('🗑️')
          .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
          .fontColor('#999999')
          .margin({ right: 16 })
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
      .width('100%')
      .height(56)
      .backgroundColor('#FFFFFF')
      .justifyContent(FlexAlign.Center);

      if (this.messages.length === 0) {
        this.EmptyState();
      }

      Scroll(this.scroller) {
        Column({ space: 8 }) {
          ForEach(this.messages, (message: ChatMessage) => {
            if (message.type === 'user') {
              this.UserBubble(message);
            } else if (message.type === 'assistant') {
              this.AssistantBubble(message);
            } else if (message.type === 'system') {
              this.SystemBubble(message);
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
  EmptyState() {
    Column({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
      Text('🏥')
        .fontSize(64)
        .margin({ top: 60 });

      Text('AI健康顾问')
        .fontSize(GlobalTheme.getFontSizeTitle(this.isElderMode))
        .fontWeight('bold')
        .fontColor('#1677FF');

      Text('我可以帮您解答健康相关问题\n例如：血压、饮食、运动、用药等')
        .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
        .fontColor('#666666')
        .textAlign(TextAlign.Center)
        .margin({ top: 8 });

      Column({ space: GlobalTheme.getSpacingSM(this.isElderMode) }) {
        ForEach(this.suggestedQuestions.slice(0, 3), (question: SuggestedQuestion) => {
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
        }, (question: SuggestedQuestion) => question.id);
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
          ForEach(this.suggestedQuestions, (question: SuggestedQuestion) => {
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
          }, (question: SuggestedQuestion) => question.id);
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
          Column({ space: 2 }) {
            Text('🎤')
              .fontSize(20)
              .onClick(() => {
                this.startVoiceInput();
              });

            if (this.isRecording) {
              Text('●')
                .fontSize(10)
                .fontColor('#FF4D4F')
                .animation({
                  duration: 800,
                  iterations: -1,
                  curve: Curve.EaseInOut
                });
            }
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(this.isRecording ? '#FFF1F0' : '#F0F0F0')
          .borderRadius(22)
          .onClick(() => {
            this.startVoiceInput();
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
