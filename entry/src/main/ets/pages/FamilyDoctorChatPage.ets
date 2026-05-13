import { router } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { HttpUtil } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import { AuthManager, UserRole } from '../utils/AuthManager';
import promptAction from '@ohos.promptAction';
import { AIOrchestrator } from '../ai/orchestrator/AIOrchestrator';

const TAG: string = 'FamilyDoctorChatPage';

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
  senderType: string = '';
  receiverType: string = '';

  constructor(senderId?: number, receiverId?: number, content?: string, senderType?: string, receiverType?: string) {
    if (senderId !== undefined) this.senderId = senderId;
    if (receiverId !== undefined) this.receiverId = receiverId;
    if (content !== undefined) this.content = content;
    if (senderType !== undefined) this.senderType = senderType;
    if (receiverType !== undefined) this.receiverType = receiverType;
  }
}

class ChatParams {
  familyId: number = 0;
  doctorId: number = 0;
  doctorName: string = '';
  relatedPatientName?: string = '';
}

@Entry
@Component
struct FamilyDoctorChatPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @StorageLink('userId') currentUserId: number = 0;

  @State messages: ChatMsg[] = [];
  @State inputText: string = '';
  @State isLoading: boolean = true;
  @State sending: boolean = false;
  @State canSend: boolean = true;
  @State remainHours: number = 48;
  @State expireWarning: string = '';
  @State hasAccess: boolean = false;
  @State aiHealthConsultation: string = '';
  @State aiMedicalAdvice: string = '';
  private orchestrator: AIOrchestrator = AIOrchestrator.getInstance();
  @State relatedPatientName: string = '';

  private scroller: Scroller = new Scroller();
  private familyId: number = 0;
  private doctorId: number = 0;
  private doctorName: string = '';
  private pollTimerId: number = -1;
  private countdownTimerId: number = -1;
  private pendingLocalMsgs: ChatMsg[] = [];

  aboutToAppear(): void {
    this.checkAccess();
  }

  private checkAccess(): void {
    const authManager: AuthManager = AuthManager.getInstance();
    const currentRole: UserRole = authManager.getCurrentRole();

    if (currentRole === UserRole.GUEST) {
      promptAction.showToast({ message: '请先登录' });
      router.replaceUrl({ url: 'pages/Login' });
      return;
    }

    if (currentRole !== UserRole.FAMILY) {
      promptAction.showToast({ message: '只有家属可以访问此页面' });
      router.back();
      return;
    }

    this.hasAccess = true;
    this.initParams();
  }

  private initParams(): void {
    const params: ChatParams = router.getParams() as ChatParams;
    hilog.info(0x0000, TAG, 'aboutToAppear params=%{public}s', JSON.stringify(params));
    if (params) {
      this.familyId = params.familyId || this.currentUserId;
      this.currentUserId = this.familyId;
      this.doctorId = params.doctorId || 0;
      this.doctorName = params.doctorName || '医生';
      this.relatedPatientName = params.relatedPatientName || '';
    }
    hilog.info(0x0000, TAG, 'init done currentUserId=%{public}d doctorId=%{public}d',
      this.currentUserId, this.doctorId);
    this.loadHistory();
    this.startPolling();
    this.startCountdown();
  }

  aboutToDisappear(): void {
    this.stopPolling();
    this.stopCountdown();
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
    } else {
      this.remainHours = Math.floor(diffMs / (60 * 60 * 1000));
      if (this.remainHours < 6) {
        this.expireWarning = '对话即将过期';
      } else {
        this.expireWarning = '';
      }
    }
  }

  private loadHistory(): void {
    this.isLoading = true;
    this.pollNewMessages();
  }

  private pollNewMessages(): void {
    if (this.currentUserId === 0 || this.doctorId === 0) {
      hilog.error(0x0000, TAG, 'ID缺失');
      if (this.isLoading) { this.isLoading = false; }
      return;
    }
    const requestParams: Record<string, string> = {
      'userA': this.currentUserId.toString(),
      'userB': this.doctorId.toString()
    };
    HttpUtil.get<ChatMsg[]>(ApiConstants.MESSAGE_HISTORY, requestParams as Object)
      .then((response) => {
        if (response.success && response.data) {
          const rawData: Object[] = response.data as Object[];
          const serverList: ChatMsg[] = [];
          for (let i: number = 0; i < rawData.length; i++) {
            const msg: ChatMsg = new ChatMsg();
            const raw: Record<string, Object> = rawData[i] as Record<string, Object>;
            if (raw['id'] !== undefined) { msg.id = Number(raw['id']); }
            if (raw['senderId'] !== undefined) { msg.senderId = Number(raw['senderId']); }
            if (raw['receiverId'] !== undefined) { msg.receiverId = Number(raw['receiverId']); }
            if (raw['content'] !== undefined) { msg.content = String(raw['content']); }
            if (raw['createTime'] !== undefined) { msg.createTime = String(raw['createTime']); }
            if (raw['expireTime'] !== undefined) { msg.expireTime = String(raw['expireTime']); }
            if (msg.content) { serverList.push(msg); }
          }
          const merged: ChatMsg[] = this.pendingLocalMsgs.length > 0
            ? [...serverList, ...this.pendingLocalMsgs]
            : serverList;
          this.messages = merged;
          setTimeout(() => {
            try { this.scroller.scrollEdge(Edge.Bottom); } catch (e) {}
          }, 100);
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
    this.sending = true;
    this.inputText = '';

    const localMsg: ChatMsg = new ChatMsg();
    localMsg.id = -Date.now();
    localMsg.senderId = this.currentUserId;
    localMsg.receiverId = this.doctorId;
    localMsg.content = text;
    localMsg.createTime = new Date().toISOString();
    this.pendingLocalMsgs = [...this.pendingLocalMsgs, localMsg];
    this.refreshDisplay();

    const sendRequest: SendMessageRequest = new SendMessageRequest(this.currentUserId, this.doctorId, text, 'family', 'doctor');

    HttpUtil.post<Record<string, Object>>(ApiConstants.MESSAGE_SEND, sendRequest as object)
      .then((response) => {
        if (response.success) {
          this.pendingLocalMsgs = [];
          this.pollNewMessages();
        } else {
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

  async consultWithAI(question: string): Promise<void> {
    try {
      const response = await this.orchestrator.process({
        type: 'text',
        content: `家庭成员健康咨询：${question}`,
        intent: 'health_consultation'
      });
      this.aiHealthConsultation = response.output.content;
    } catch (error) {
      console.error('[FamilyDoctorChatPage] AI健康咨询失败:', error);
      this.aiHealthConsultation = 'AI健康咨询暂时不可用';
    }
  }

  async getMedicalAdviceFromAI(symptom: string): Promise<void> {
    try {
      const response = await this.orchestrator.process({
        type: 'text',
        content: `家庭成员症状：${symptom}，请给出医疗建议`,
        intent: 'health_consultation'
      });
      this.aiMedicalAdvice = response.output.content;
    } catch (error) {
      console.error('[FamilyDoctorChatPage] AI医疗建议失败:', error);
      this.aiMedicalAdvice = 'AI医疗建议暂时不可用';
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

        Column() {
          Text(this.doctorName + ' 医生')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333');

          if (this.relatedPatientName !== '') {
            Text('患者: ' + this.relatedPatientName)
              .fontSize(12)
              .fontColor('#13C2C2')
              .margin({ top: 2 });
          }
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 8 })
        .layoutWeight(1);

        Row() {
          Text('⏱️ ' + this.formatRemainDisplay())
            .fontSize(11)
            .fontColor(this.remainHours < 6 ? '#FF4D4F' : '#52C41A')
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .borderRadius(10)
            .backgroundColor(this.remainHours < 6 ? '#FFF1F0' : '#F6FFED');
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
            Text('暂无消息，发送第一条消息开始对话吧')
              .fontSize(14)
              .fontColor('#999999');
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
                      .backgroundColor('#F5A623');

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

      Row() {
        TextInput({ placeholder: '输入消息...', text: this.inputText })
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

        Button('发送')
          .width(64)
          .height(36)
          .fontSize(14)
          .fontColor('#FFFFFF')
          .backgroundColor('#F5A623')
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
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }
}
