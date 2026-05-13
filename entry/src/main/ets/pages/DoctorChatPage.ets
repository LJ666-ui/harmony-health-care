import { router } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { HttpUtil } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import { AuthManager, UserRole } from '../utils/AuthManager';
import promptAction from '@ohos.promptAction';
import { ConsultationService, ConsultationMessage } from '../services/ConsultationService';
import { WebSocketClient, MessageHandler, MessageData } from '../network/WebSocketClient';
import { ToastUtil } from '../common/utils/ToastUtil';
import { AIOrchestrator } from '../ai/orchestrator/AIOrchestrator';
import { AIRequestBuilder } from '../ai/utils/AIRequestBuilder';

const TAG: string = 'DoctorChatPage';

class ChatMsg {
  id: number = 0;
  senderId: number = 0;
  receiverId: number = 0;
  content: string = '';
  isRead: number = 0;
  createTime: string = '';
  expireTime: string = '';
}

class SendMessageRequest {
  senderId: number = 0;
  receiverId: number = 0;
  content: string = '';

  constructor(senderId?: number, receiverId?: number, content?: string) {
    if (senderId !== undefined) this.senderId = senderId;
    if (receiverId !== undefined) this.receiverId = receiverId;
    if (content !== undefined) this.content = content;
  }
}

class ChatParams {
  doctorId: number = 0;
  doctorName: string = '';
  currentUserId: number = 0;
  otherUserId?: number = 0;
  otherUserName?: string = '';
  isDoctor?: boolean = false;
  prefillMessage?: string = '';
}

class ChatMessageHandler implements MessageHandler {
  private page: DoctorChatPage;

  constructor(page: DoctorChatPage) {
    this.page = page;
  }

  onMessage(message: MessageData): void {
    const chatMsg = new ChatMsg();
    chatMsg.id = message.messageId || Date.now();
    chatMsg.senderId = message.senderId || 0;
    chatMsg.receiverId = this.page.getCurrentUserId();
    chatMsg.content = message.content || '';
    chatMsg.createTime = message.createTime || new Date().toISOString();

    this.page.addMessage(chatMsg);
  }

  onConnect(): void {
    hilog.info(0x0000, TAG, 'WebSocket连接成功');
    this.page.setWebSocketState(true);
  }

  onDisconnect(): void {
    hilog.warn(0x0000, TAG, 'WebSocket连接断开');
    this.page.setWebSocketState(false);
    ToastUtil.showWarning('连接已断开，正在重连...');
  }

  onError(error: Error): void {
    hilog.error(0x0000, TAG, 'WebSocket错误: %{public}s', error.message);
    this.page.setWebSocketState(false);
  }
}

@Entry
@Component
struct DoctorChatPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @StorageLink('userId') currentUserId: number = 0;

  @State messages: ChatMsg[] = [];
  @State inputText: string = '';
  @State isLoading: boolean = true;
  @State sending: boolean = false;
  @State isDoctor: boolean = false;
  @State canSend: boolean = true;
  @State remainHours: number = 48;
  @State expireWarning: string = '';
  @State hasAccess: boolean = false;
  @State aiDiagnosisSuggestion: string = '';
  @State aiSymptomAnalysis: string = '';
  @State aiRecommendedQuestions: string[] = [];
  @State isAIAnalyzing: boolean = false;

  private scroller: Scroller = new Scroller();
  private doctorId: number = 0;
  private doctorName: string = '';
  private otherUserId: number = 0;
  private otherUserName: string = '';
  private pollTimerId: number = -1;
  private countdownTimerId: number = -1;
  private pendingLocalMsgs: ChatMsg[] = [];
  private consultationService: ConsultationService = ConsultationService.getInstance();
  private wsClient: WebSocketClient | null = null;
  private sessionId: string = '';
  private useWebSocket: boolean = false;
  private orchestrator: AIOrchestrator = AIOrchestrator.getInstance();

  aboutToAppear(): void {
    this.checkAccess();
  }

  private checkAccess(): void {
    const authManager: AuthManager = AuthManager.getInstance();
    const currentRole: UserRole = authManager.getCurrentRole();

    hilog.info(0x0000, TAG, 'checkAccess - currentRole=%{public}s, userId from Storage=%{public}d', 
      currentRole, this.currentUserId);

    if (currentRole === UserRole.GUEST && this.currentUserId === 0) {
      promptAction.showToast({ message: '请先登录' });
      router.replaceUrl({ url: 'pages/Login' });
      return;
    }

    if (this.currentUserId === 0) {
      const storedUserId: number | undefined = AppStorage.get<number>('userId');
      if (storedUserId && storedUserId > 0) {
        this.currentUserId = storedUserId;
        hilog.info(0x0000, TAG, '从AppStorage恢复userId=%{public}d', storedUserId);
      }
    }

    this.hasAccess = true;
    this.initParams();
  }

  private initParams(): void {
    try {
      const params: ChatParams = router.getParams() as ChatParams;
      hilog.info(0x0000, TAG, 'aboutToAppear params=%{public}s', JSON.stringify(params));
      if (params) {
        this.isDoctor = params.isDoctor === true;
        this.doctorId = params.doctorId || 0;
        this.doctorName = params.doctorName || '医生';
        this.currentUserId = params.currentUserId || this.currentUserId || 1;

        if (this.isDoctor) {
          this.otherUserId = params.otherUserId || 0;
          this.otherUserName = params.otherUserName || '患者';
        } else {
          this.otherUserId = this.doctorId;
          this.otherUserName = this.doctorName;
        }

        if (this.isDoctor) {
          this.checkCanSend();
        } else {
          this.canSend = true;
        }

        if (params.prefillMessage && params.prefillMessage.trim() !== '') {
          this.inputText = params.prefillMessage;
        }
      } else {
        hilog.error(0x0000, TAG, '未接收到页面参数');
      }
    } catch (error) {
      hilog.error(0x0000, TAG, '初始化参数异常: %{public}s', error instanceof Error ? error.message : '未知错误');
    }
    
    hilog.info(0x0000, TAG, 'init done isDoctor=%{public}b currentUserId=%{public}d otherUserId=%{public}d doctorId=%{public}d',
      this.isDoctor, this.currentUserId, this.otherUserId, this.doctorId);
      
    if (this.currentUserId > 0 && this.otherUserId > 0) {
      this.loadHistory();
      this.startPolling();
      this.startCountdown();
    } else {
      hilog.warn(0x0000, TAG, '用户ID缺失，跳过加载历史消息');
      this.isLoading = false;
    }
  }

  aboutToDisappear(): void {
    this.stopPolling();
    this.stopCountdown();
    this.disconnectWebSocket();
  }

  public getCurrentUserId(): number {
    return this.currentUserId;
  }

  public addMessage(chatMsg: ChatMsg): void {
    this.messages.push(chatMsg);
    setTimeout(() => {
      try { this.scroller.scrollEdge(Edge.Bottom); } catch (e) {}
    }, 100);
  }

  public setWebSocketState(connected: boolean): void {
    this.useWebSocket = connected;
  }

  private async initWebSocket(): Promise<void> {
    try {
      const session = await this.consultationService.createConsultationSession(this.doctorId, 'text');

      if (session) {
        this.sessionId = session.sessionId.toString();

        this.wsClient = WebSocketClient.getInstance(this.sessionId);

        const handler = new ChatMessageHandler(this);

        this.wsClient.addMessageHandler(handler);
        
        const connected = await this.wsClient.connect(this.currentUserId.toString(), 'patient');
        
        if (connected) {
          hilog.info(0x0000, TAG, 'WebSocket初始化成功');
        } else {
          hilog.warn(0x0000, TAG, 'WebSocket连接失败，降级为HTTP轮询');
          this.useWebSocket = false;
        }
      }
    } catch (error) {
      hilog.error(0x0000, TAG, 'WebSocket初始化失败: %{public}s', JSON.stringify(error));
      this.useWebSocket = false;
    }
  }

  private disconnectWebSocket(): void {
    if (this.wsClient) {
      this.wsClient.disconnect();
      this.wsClient = null;
      this.useWebSocket = false;
    }
  }

  private startPolling(): void {
    this.pollTimerId = setInterval(() => {
      this.pollNewMessages();
    }, 3000);
  }

  private stopPolling(): void {
    if (this.pollTimerId !== -1) {
      clearInterval(this.pollTimerId);
      this.pollTimerId = -1;
    }
  }

  private startCountdown(): void {
    this.updateCountdown();
    this.countdownTimerId = setInterval(() => {
      this.updateCountdown();
    }, 60000);
  }

  private stopCountdown(): void {
    if (this.countdownTimerId !== -1) {
      clearInterval(this.countdownTimerId);
      this.countdownTimerId = -1;
    }
  }

  private updateCountdown(): void {
    if (this.messages.length === 0) {
      this.remainHours = 48;
      this.expireWarning = '';
      return;
    }
    let latestExpire: string = '';
    for (let i: number = 0; i < this.messages.length; i++) {
      if (this.messages[i].expireTime && this.messages[i].expireTime !== '') {
        latestExpire = this.messages[i].expireTime;
      }
    }
    if (latestExpire === '') {
      this.remainHours = 48;
      this.expireWarning = '';
      return;
    }
    const expireDate: Date = new Date(latestExpire);
    const now: Date = new Date();
    const diffMs: number = expireDate.getTime() - now.getTime();
    if (diffMs <= 0) {
      this.remainHours = 0;
      this.expireWarning = '对话已过期';
      this.canSend = false;
    } else {
      this.remainHours = Math.floor(diffMs / (60 * 60 * 1000));
      if (this.remainHours < 6) {
        this.expireWarning = '对话即将过期';
      } else if (this.remainHours < 12) {
        this.expireWarning = '';
      } else {
        this.expireWarning = '';
      }
    }
  }

  private checkCanSend(): void {
    const params: Record<string, string> = {
      'senderId': this.currentUserId.toString(),
      'receiverId': this.otherUserId.toString()
    };
    HttpUtil.get<Record<string, Object>>(ApiConstants.MESSAGE_CAN_SEND, params as Object)
      .then((response) => {
        if (response.success && response.data) {
          const data: Record<string, Object> = response.data as Record<string, Object>;
          if (data['canSend'] !== undefined) {
            this.canSend = data['canSend'] as boolean;
          }
        }
      })
      .catch(() => {});
  }

  private loadHistory(): void {
    this.isLoading = true;
    this.pollNewMessages();
  }

  private pollNewMessages(): void {
    if (this.currentUserId === 0 || this.otherUserId === 0) {
      hilog.error(0x0000, TAG, 'ID缺失 currentUserId=%{public}d otherUserId=%{public}d', this.currentUserId, this.otherUserId);
      if (this.isLoading) { this.isLoading = false; }
      return;
    }
    const requestParams: Record<string, string> = {
      'userA': this.currentUserId.toString(),
      'userB': this.otherUserId.toString()
    };
    hilog.info(0x0000, TAG, 'pollNewMessages 请求 userA=%{public}s userB=%{public}s', requestParams['userA'], requestParams['userB']);
    HttpUtil.get<ChatMsg[]>(ApiConstants.MESSAGE_HISTORY, requestParams as Object)
      .then((response) => {
        hilog.info(0x0000, TAG, '响应 success=%{public}b', response.success);
        if (response.success && response.data) {
          const rawData: Object[] = response.data as Object[];
          hilog.info(0x0000, TAG, '原始数据条数=%{public}d', rawData.length);
          const serverList: ChatMsg[] = [];
          for (let i: number = 0; i < rawData.length; i++) {
            const msg: ChatMsg = new ChatMsg();
            const raw: Record<string, Object> = rawData[i] as Record<string, Object>;
            if (raw['id'] !== undefined && raw['id'] !== null) { msg.id = Number(raw['id']); }
            if (raw['senderId'] !== undefined && raw['senderId'] !== null) { msg.senderId = Number(raw['senderId']); }
            if (raw['receiverId'] !== undefined && raw['receiverId'] !== null) { msg.receiverId = Number(raw['receiverId']); }
            if (raw['content'] !== undefined && raw['content'] !== null) { msg.content = String(raw['content']); }
            if (raw['createTime'] !== undefined && raw['createTime'] !== null) { msg.createTime = String(raw['createTime']); }
            if (raw['expireTime'] !== undefined && raw['expireTime'] !== null) { msg.expireTime = String(raw['expireTime']); }
            if (msg.content) { serverList.push(msg); }
          }
          hilog.info(0x0000, TAG, '解析后 serverList 条数=%{public}d messages最终条数=%{public}d',
            serverList.length, serverList.length + this.pendingLocalMsgs.length);
          const merged: ChatMsg[] = this.pendingLocalMsgs.length > 0
            ? [...serverList, ...this.pendingLocalMsgs]
            : serverList;
          this.messages = merged;
          setTimeout(() => {
            try { this.scroller.scrollEdge(Edge.Bottom); } catch (e) {}
          }, 100);
        } else {
          hilog.warn(0x0000, TAG, '响应为空或失败 success=%{public}b msg=%{public}s', response.success, response.message);
        }
      })
      .catch((err: Error) => {
        hilog.error(0x0000, TAG, 'pollNewMessages 异常: %{public}s', err.message);
      })
      .finally(() => {
        if (this.isLoading) {
          this.isLoading = false;
        }
      });
  }

  isMine(msg: ChatMsg): boolean {
    return msg.senderId === this.currentUserId;
  }

  formatTime(timeStr: string): string {
    if (!timeStr) { return ''; }
    const date: Date = new Date(timeStr);
    const h: string = date.getHours().toString().padStart(2, '0');
    const m: string = date.getMinutes().toString().padStart(2, '0');
    return h + ':' + m;
  }

  formatRemainDisplay(): string {
    if (this.remainHours <= 0) { return '已过期'; }
    if (this.remainHours < 1) { return '不足1小时'; }
    if (this.remainHours < 24) { return this.remainHours + '小时'; }
    const days: number = Math.floor(this.remainHours / 24);
    const h: number = this.remainHours % 24;
    return days + '天' + (h > 0 ? h + '小时' : '');
  }

  sendMsg(): void {
    const text: string = this.inputText.trim();
    if (!text) { return; }
    if (this.sending) { return; }
    if (!this.canSend) { return; }
    this.sending = true;
    this.inputText = '';

    const localMsg: ChatMsg = new ChatMsg();
    localMsg.id = -Date.now();
    localMsg.senderId = this.currentUserId;
    localMsg.receiverId = this.otherUserId;
    localMsg.content = text;
    localMsg.createTime = new Date().toISOString();
    this.pendingLocalMsgs = [...this.pendingLocalMsgs, localMsg];
    this.refreshDisplay();

    const sendRequest: SendMessageRequest = new SendMessageRequest(this.currentUserId, this.otherUserId, text);

    HttpUtil.post<Record<string, Object>>(ApiConstants.MESSAGE_SEND, sendRequest as object)
      .then((response) => {
        if (response.success) {
          this.pendingLocalMsgs = [];
          this.pollNewMessages();
        } else {
          if (this.isDoctor && response.message) {
            this.canSend = false;
          }
          this.pendingLocalMsgs = this.pendingLocalMsgs.filter((m: ChatMsg) => m.id !== localMsg.id);
          this.refreshDisplay();
        }
      })
      .catch((err: Error) => {
        hilog.error(0x0000, TAG, '发送失败: %{public}s', err.message);
        this.pendingLocalMsgs = this.pendingLocalMsgs.filter((m: ChatMsg) => m.id !== localMsg.id);
        this.refreshDisplay();
      })
      .finally(() => {
        this.sending = false;
      });
  }

  private refreshDisplay(): void {
    this.messages = [...this.messages];
    setTimeout(() => {
      try { this.scroller.scrollEdge(Edge.Bottom); } catch (e) {}
    }, 50);
  }

  async analyzeSymptomsWithAI(symptomDescription: string): Promise<void> {
    this.isAIAnalyzing = true;
    try {
      const request = AIRequestBuilder.createWithIntent(
        `患者症状描述：${symptomDescription}，请分析可能的病因并给出诊断建议`,
        'pre_diagnosis'
      );
      const response = await this.orchestrator.process(request);
      const content = response.output.content;
      this.aiSymptomAnalysis = typeof content === 'string' ? content : JSON.stringify(content);
      this.aiDiagnosisSuggestion = response.suggestions?.[0] || '';
      this.aiRecommendedQuestions = response.suggestions || [];
    } catch (error) {
      console.error('[DoctorChatPage] AI症状分析失败:', error);
      this.aiSymptomAnalysis = 'AI症状分析暂时不可用';
    } finally {
      this.isAIAnalyzing = false;
    }
  }

  async getAIDiagnosisHelp(): Promise<void> {
    const recentMessages = this.messages.slice(-5).map(m => m.content).join('\n');
    try {
      const request = AIRequestBuilder.createWithIntent(
        `基于以下聊天记录，请给出辅助诊断建议：\n${recentMessages}`,
        'pre_diagnosis'
      );
      const response = await this.orchestrator.process(request);
      const content = response.output.content;
      this.aiDiagnosisSuggestion = typeof content === 'string' ? content : JSON.stringify(content);
    } catch (error) {
      console.error('[DoctorChatPage] AI诊断辅助失败:', error);
      this.aiDiagnosisSuggestion = 'AI诊断辅助暂时不可用';
    }
  }

  async suggestFollowUpQuestions(): Promise<void> {
    const lastUserMessage = this.messages.slice().reverse().find(m => m.senderId === this.currentUserId);
    if (!lastUserMessage) return;

    try {
      const request = AIRequestBuilder.createWithIntent(
        `患者说：${lastUserMessage.content}，请建议医生应该追问的3个问题`,
        'pre_diagnosis'
      );
      const response = await this.orchestrator.process(request);
      const content = response.output.content;
      const contentStr = typeof content === 'string' ? content : JSON.stringify(content);
      this.aiRecommendedQuestions = contentStr.split('\n').filter((q: string) => q.trim());
    } catch (error) {
      console.error('[DoctorChatPage] AI追问建议失败:', error);
      this.aiRecommendedQuestions = [];
    }
  }

  build() {
    Column() {
      Row() {
        Text('←')
          .fontSize(20)
          .fontColor('#333333')
          .padding(10)
          .onClick(() => router.back());

        if (this.isDoctor) {
          Text(this.otherUserName + ' 患者')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .margin({ left: 8 })
            .layoutWeight(1);
        } else {
          Text(this.otherUserName + ' 医生')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .margin({ left: 8 })
            .layoutWeight(1);
        }

        Row() {
          Text('⏱️ ' + this.formatRemainDisplay())
            .fontSize(11)
            .fontColor(this.remainHours < 6 ? '#FF4D4F' : (this.remainHours < 12 ? '#FAAD14' : '#52C41A'))
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .borderRadius(10)
            .backgroundColor(this.remainHours < 6 ? '#FFF1F0' : (this.remainHours < 12 ? '#FFFBE6' : '#F6FFED'));
        }
        .padding({ right: 12 });
      }
      .width('100%')
      .height(56)
      .padding({ left: 8, right: 8 })
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)
      .backgroundColor('#FFFFFF')
      .shadow({ radius: 2, color: '#00000010', offsetX: 0, offsetY: 2 });

      if (this.expireWarning !== '') {
        Row() {
          Text('⚠️ ' + this.expireWarning)
            .fontSize(12)
            .fontColor('#FF4D4F')
            .padding({ left: 16, right: 16, top: 6, bottom: 6 });
        }
        .width('100%')
        .backgroundColor('#FFF1F0');
      }

      if (this.isDoctor && !this.canSend) {
        Row() {
          Text('🔒 该患者尚未联系您，您无法主动发起对话')
            .fontSize(12)
            .fontColor('#FAAD14')
            .padding({ left: 16, right: 16, top: 6, bottom: 6 });
        }
        .width('100%')
        .backgroundColor('#FFFBE6');
      }

      Scroll(this.scroller) {
        if (this.isLoading) {
          Column() {
            Text('加载中...')
              .fontSize(14)
              .fontColor('#999999');
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center);
        } else if (this.messages.length === 0) {
          Column() {
            Text('💬')
              .fontSize(48)
              .margin({ bottom: 12 });
            if (this.isDoctor) {
              Text('等待患者发起咨询')
                .fontSize(14)
                .fontColor('#999999');
            } else {
              Text('暂无消息，发送第一条消息开始对话吧')
                .fontSize(14)
                .fontColor('#999999');
            }
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center);
        } else {
          Column({ space: 8 }) {
            ForEach(this.messages, (msg: ChatMsg) => {
              Row() {
                if (!this.isMine(msg)) {
                  Column() {
                    Text(msg.content)
                      .fontSize(15)
                      .fontColor('#333333')
                      .constraintSize({ maxWidth: '70%' })
                      .padding({ top: 10, bottom: 10, left: 14, right: 14 })
                      .borderRadius({ topLeft: 4, topRight: 16, bottomLeft: 16, bottomRight: 16 })
                      .backgroundColor('#F0F2F5');

                    Text(this.formatTime(msg.createTime))
                      .fontSize(10)
                      .fontColor('#BBBBBB')
                      .margin({ top: 4 });
                  }
                  .alignItems(HorizontalAlign.Start);
                }

                Blank();

                if (this.isMine(msg)) {
                  Column() {
                    Text(msg.content)
                      .fontSize(15)
                      .fontColor('#FFFFFF')
                      .constraintSize({ maxWidth: '70%' })
                      .padding({ top: 10, bottom: 10, left: 14, right: 14 })
                      .borderRadius({ topLeft: 16, topRight: 4, bottomLeft: 16, bottomRight: 16 })
                      .backgroundColor(this.isDoctor ? '#36CFC9' : '#1677FF');

                    Text(this.formatTime(msg.createTime))
                      .fontSize(10)
                      .fontColor('#BBBBBB')
                      .margin({ top: 4 });
                  }
                  .alignItems(HorizontalAlign.End);
                }
              }
              .width('100%')
              .padding({ left: 12, right: 12, top: 4, bottom: 4 });
            }, (msg: ChatMsg) => msg.id.toString());
          }
          .width('100%')
          .padding({ top: 12, bottom: 24 });
        }
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring);

      Divider().color('#EEEEEE');

      if (this.canSend) {
        Row() {
          TextInput({ placeholder: this.isDoctor ? '回复患者...' : '输入消息...', text: this.inputText })
            .layoutWeight(1)
            .height(40)
            .fontSize(15)
            .placeholderFont({ size: 14 })
            .backgroundColor('#F5F5F5')
            .borderRadius(20)
            .padding({ left: 16, right: 16 })
            .onChange((value: string) => {
              this.inputText = value;
            })
            .onSubmit(() => {
              this.sendMsg();
            });

          Button(this.isDoctor ? '回复' : '发送')
            .width(64)
            .height(36)
            .fontSize(14)
            .fontColor('#FFFFFF')
            .backgroundColor(this.isDoctor ? '#36CFC9' : '#1677FF')
            .borderRadius(18)
            .enabled(!this.sending)
            .opacity(this.sending ? 0.5 : 1)
            .margin({ left: 8 })
            .onClick(() => {
              this.sendMsg();
            });
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 8, bottom: 28 })
        .alignItems(VerticalAlign.Center)
        .backgroundColor('#FFFFFF');
      } else {
        Row() {
          Text('🔒 无法发送消息')
            .fontSize(14)
            .fontColor('#999999')
            .padding({ top: 12, bottom: 28 });
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#FAFAFA');
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }
}
