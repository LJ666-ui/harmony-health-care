import { ToastUtil } from '../common/utils/ToastUtil';

export interface CommentData {
  id: number;
  userId: number;
  userName: string;
  userAvatar: string;
  content: string;
  createTime: string;
  likeCount: number;
  isLiked: boolean;
  replyTo?: string;
  replies?: CommentData[];
}

@Component
export struct CommentSection {
  @Prop articleId: string = '';
  @State comments: CommentData[] = [];
  @State inputText: string = '';
  @State isSubmitting: boolean = false;
  @State isLoading: boolean = true;

  private static readonly MAX_COMMENT_LENGTH: number = 200;
  private static readonly SENSITIVE_WORDS: string[] = ['敏感词1', '敏感词2', '广告', '推广', '违禁'];

  aboutToAppear(): void {
    this.loadComments();
  }

  async loadComments(): Promise<void> {
    this.isLoading = true;
    try {
      const mockComments: CommentData[] = [
        {
          id: 1,
          userId: 101,
          userName: '张医生',
          userAvatar: '',
          content: '这篇文章写得很详细，对高血压患者很有帮助！',
          createTime: '2026-04-19 14:30',
          likeCount: 12,
          isLiked: false
        },
        {
          id: 2,
          userId: 102,
          userName: '李阿姨',
          userAvatar: '',
          content: '感谢分享，我已经收藏了，会推荐给家人看。',
          createTime: '2026-04-19 15:20',
          likeCount: 8,
          isLiked: true,
          replies: [
            {
              id: 3,
              userId: 103,
              userName: '王护士',
              userAvatar: '',
              content: '是的，预防胜于治疗！',
              createTime: '2026-04-19 16:00',
              likeCount: 3,
              isLiked: false,
              replyTo: '李阿姨'
            }
          ]
        },
        {
          id: 4,
          userId: 104,
          userName: '赵先生',
          userAvatar: '',
          content: '请问这种情况下需要立即就医吗？',
          createTime: '2026-04-20 09:15',
          likeCount: 5,
          isLiked: false
        }
      ];
      this.comments = mockComments;
    } catch (e) {
      console.error('加载评论失败:', e);
      ToastUtil.showError('加载评论失败');
    } finally {
      this.isLoading = false;
    }
  }

  checkSensitiveWords(text: string): boolean {
    for (const word of CommentSection.SENSITIVE_WORDS) {
      if (text.indexOf(word) >= 0) {
        return true;
      }
    }
    return false;
  }

  async submitComment(): Promise<void> {
    if (!this.inputText.trim()) {
      ToastUtil.showInfo('请输入评论内容');
      return;
    }

    if (this.inputText.length > CommentSection.MAX_COMMENT_LENGTH) {
      ToastUtil.showInfo('评论内容不能超过' + CommentSection.MAX_COMMENT_LENGTH + '字');
      return;
    }

    if (this.checkSensitiveWords(this.inputText)) {
      ToastUtil.showInfo('评论包含敏感内容，请修改后重试');
      return;
    }

    this.isSubmitting = true;
    try {
      const newComment: CommentData = {
        id: Date.now(),
        userId: 999,
        userName: '我',
        userAvatar: '',
        content: this.inputText.trim(),
        createTime: new Date().toLocaleString('zh-CN'),
        likeCount: 0,
        isLiked: false
      };

      this.comments.unshift(newComment);
      this.inputText = '';
      ToastUtil.showSuccess('评论发表成功');
    } catch (e) {
      console.error('发表评论失败:', e);
      ToastUtil.showError('发表失败，请稍后重试');
    } finally {
      this.isSubmitting = false;
    }
  }

  async handleLike(comment: CommentData): Promise<void> {
    try {
      comment.isLiked = !comment.isLiked;
      comment.likeCount += comment.isLiked ? 1 : -1;
    } catch (e) {
      console.error('点赞失败:', e);
    }
  }

  handleReply(comment: CommentData): void {
    this.inputText = '@' + comment.userName + ' ';
    ToastUtil.showInfo('回复 ' + comment.userName);
  }

  formatTime(timeStr: string): string {
    if (!timeStr) return '';
    const date: Date = new Date(timeStr);
    const now: Date = new Date();
    const diff: number = now.getTime() - date.getTime();

    if (diff < 60000) {
      return '刚刚';
    } else if (diff < 3600000) {
      return Math.floor(diff / 60000) + '分钟前';
    } else if (diff < 86400000) {
      return Math.floor(diff / 3600000) + '小时前';
    } else if (diff < 604800000) {
      return Math.floor(diff / 86400000) + '天前';
    }
    return timeStr;
  }

  @Builder
  buildCommentItem(comment: CommentData, isReply: boolean = false) {
    Column({ space: 8 }) {
      Row({ space: 10 }) {
        if (comment.userAvatar && comment.userAvatar.length > 0) {
          Image(comment.userAvatar)
            .width(36)
            .height(36)
            .borderRadius(18)
            .objectFit(ImageFit.Cover);
        } else {
          Text(comment.userName.charAt(0))
            .width(36)
            .height(36)
            .fontSize(16)
            .fontColor('#FFFFFF')
            .backgroundColor('#1677FF')
            .borderRadius(18)
            .textAlign(TextAlign.Center);
        }

        Column({ space: 4 }) {
          Row({ space: 8 }) {
            Text(comment.userName)
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333');

            if (comment.replyTo) {
              Text('回复 @' + comment.replyTo)
                .fontSize(12)
                .fontColor('#999999');
            }
          }

          Text(comment.content)
            .fontSize(14)
            .fontColor('#444444')
            .lineHeight(20)
            .maxLines(3)
            .textOverflow({ overflow: TextOverflow.Ellipsis });

          Row({ space: 16 }) {
            Text(this.formatTime(comment.createTime))
              .fontSize(12)
              .fontColor('#999999');

            Row({ space: 4 }) {
              Text(comment.isLiked ? '👍' : '👍🏻')
                .fontSize(14);

              Text(comment.likeCount.toString())
                .fontSize(12)
                .fontColor(comment.isLiked ? '#1677FF' : '#999999');
            }
            .onClick(() => this.handleLike(comment));

            if (!isReply) {
              Text('回复')
                .fontSize(12)
                .fontColor('#1677FF')
                .onClick(() => this.handleReply(comment));
            }
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start);
      }
      .width('100%')
      .alignItems(VerticalAlign.Top);

      if (comment.replies && comment.replies.length > 0) {
        Column({ space: 8 }) {
          ForEach(comment.replies, (reply: CommentData) => {
            this.buildCommentItem(reply, true);
          }, (reply: CommentData) => reply.id.toString());
        }
        .padding({ left: 46 })
        .width('100%');
      }
    }
    .width('100%')
    .padding(12)
    .alignItems(HorizontalAlign.Start);
  }

  build() {
    Column({ space: 16 }) {
      Text('评论区 (' + this.comments.length + ')')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .width('100%');

      Column({ space: 12 }) {
        Row({ space: 10 }) {
          TextInput({ placeholder: '写下你的想法...', text: this.inputText })
            .layoutWeight(1)
            .height(80)
            .fontSize(14)
            .backgroundColor('#F5F7FA')
            .borderRadius(12)
            .padding(12)
            .maxLength(CommentSection.MAX_COMMENT_LENGTH)
            .onChange((value: string) => {
              this.inputText = value;
            });

          Column({ space: 4 }) {
            Text((CommentSection.MAX_COMMENT_LENGTH - this.inputText.length).toString())
              .fontSize(11)
              .fontColor(this.inputText.length > CommentSection.MAX_COMMENT_LENGTH * 0.8 ? '#FF4D4F' : '#999999');

            Button('发送')
              .width('100%')
              .height(32)
              .fontSize(13)
              .fontColor('#FFFFFF')
              .backgroundColor(this.inputText.trim().length > 0 ? '#1677FF' : '#CCCCCC')
              .borderRadius(16)
              .enabled(!this.isSubmitting && this.inputText.trim().length > 0)
              .onClick(() => this.submitComment());
          }
          .width(60);
        }
        .width('100%')
        .alignItems(VerticalAlign.Center);
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#FAFAFA')
      .borderRadius(12);

      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(32)
            .height(32)
            .color('#1677FF');
          Text('加载评论中...')
            .fontSize(13)
            .fontColor('#999999')
            .margin({ top: 8 });
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center);
      } else if (this.comments.length === 0) {
        Column({ space: 12 }) {
          Text('💬')
            .fontSize(48);
          Text('暂无评论，快来发表第一条评论吧！')
            .fontSize(14)
            .fontColor('#999999');
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center);
      } else {
        Scroll() {
          Column({ space: 12 }) {
            ForEach(this.comments, (comment: CommentData) => {
              Column() {
                this.buildCommentItem(comment);
              }
              .width('100%')
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 2 });
            }, (comment: CommentData) => comment.id.toString());
          }
          .width('100%')
          .padding(8);
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top);
      }
    }
    .width('100%')
    .layoutWeight(1)
    .padding(16)
    .alignItems(HorizontalAlign.Start);
  }
}
