import { router } from '@kit.ArkUI';
import { HttpUtil } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';

class ChatMsg {
  id: number = 0;
  senderId: number = 0;
  receiverId: number = 0;
  content: string = '';
  isRead: number = 0;
  createTime: string = '';
}

interface MessageRequest {
  userA: string;
  userB: string;
}

interface SendMessageRequest {
  senderId: number;
  receiverId: number;
  content: string;
}

class ChatParams {
  doctorId: number = 0;
  doctorName: string = '';
  currentUserId: number = 0;
}

@Entry
@Component
struct DoctorChatPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State messages: ChatMsg[] = [];
  @State inputText: string = '';
  @State isLoading: boolean = true;
  @State sending: boolean = false;

  private scroller: Scroller = new Scroller();
  private doctorId: number = 0;
  private doctorName: string = '';
  private currentUserId: number = 0;

  aboutToAppear(): void {
    const params = router.getParams() as ChatParams;
    if (params) {
      this.doctorId = params.doctorId;
      this.doctorName = params.doctorName || '医生';
      this.currentUserId = params.currentUserId || 1;
    }
    this.loadHistory();
  }

  private loadHistory(): void {
    this.isLoading = true;
    const requestParams: MessageRequest = {
      userA: this.currentUserId.toString(),
      userB: this.doctorId.toString()
    };
    HttpUtil.get<ChatMsg[]>(ApiConstants.MESSAGE_HISTORY, requestParams)
      .then((response) => {
        if (response.success && response.data) {
          const rawData: Object[] = response.data as Object[];
          const list: ChatMsg[] = [];
          for (let i: number = 0; i < rawData.length; i++) {
            const msg: ChatMsg = new ChatMsg();
            const raw: Record<string, Object> = rawData[i] as Record<string, Object>;
            if (raw['id']) { msg.id = raw['id'] as number; }
            if (raw['senderId']) { msg.senderId = raw['senderId'] as number; }
            if (raw['receiverId']) { msg.receiverId = raw['receiverId'] as number; }
            if (raw['content']) { msg.content = raw['content'] as string; }
            if (raw['createTime']) { msg.createTime = raw['createTime'] as string; }
            list.push(msg);
          }
          this.messages = list;
        }
      })
      .catch((err: Error) => {
        console.error('[DoctorChatPage] 加载消息失败:', err.message);
      })
      .finally(() => {
        this.isLoading = false;
        setTimeout(() => {
          try { this.scroller.scrollEdge(Edge.Bottom); } catch (e) {}
        }, 200);
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
    this.messages.push(localMsg);

    setTimeout(() => {
      try { this.scroller.scrollEdge(Edge.Bottom); } catch (e) {}
    }, 100);

    const sendRequest: SendMessageRequest = {
      senderId: this.currentUserId,
      receiverId: this.doctorId,
      content: text
    };

    HttpUtil.post<Record<string, Object>>(ApiConstants.MESSAGE_SEND, sendRequest)
      .then(() => {})
      .catch((err: Error) => {
        console.error('[DoctorChatPage] 发送失败:', err.message);
      })
      .finally(() => {
        this.sending = false;
      });
  }

  build() {
    Column() {
      Row() {
        Button()
          .width(40)
          .height(40)
          .type(ButtonType.Circle)
          .backgroundColor('#FFFFFF')
          .onClick(() => router.back());

        Text(this.doctorName + ' 医生')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ left: 12 });
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)
      .backgroundColor('#FFFFFF');

      Divider().color('#EEEEEE');

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
                    Text(this.formatTime(msg.createTime))
                      .fontSize(10)
                      .fontColor('#BBBBBB')
                      .margin({ bottom: 2 });

                    Text(msg.content)
                      .fontSize(15)
                      .fontColor('#333333')
                      .constraintSize({ maxWidth: '70%' })
                      .padding({ top: 10, bottom: 10, left: 14, right: 14 })
                      .borderRadius(16)
                      .backgroundColor('#F0F2F5');
                  }
                  .alignItems(HorizontalAlign.Start);
                }

                Blank();

                if (this.isMine(msg)) {
                  Column() {
                    Text(this.formatTime(msg.createTime))
                      .fontSize(10)
                      .fontColor('#BBBBBB')
                      .margin({ bottom: 2 });

                    Text(msg.content)
                      .fontSize(15)
                      .fontColor('#FFFFFF')
                      .constraintSize({ maxWidth: '70%' })
                      .padding({ top: 10, bottom: 10, left: 14, right: 14 })
                      .borderRadius(16)
                      .backgroundColor('#1677FF');
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
          .backgroundColor('#1677FF')
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
      .alignItems(VerticalAlign.Center);
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }
}
