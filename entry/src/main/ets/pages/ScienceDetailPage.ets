import { router } from '@kit.ArkUI';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import BrowseTracker from '../utils/BrowseTracker';
import RdbHelper from '../utils/RdbHelper';
import {
  TABLE_COLLECTION_CACHE,
  COLUMN_COLLECT_TYPE,
  COLUMN_TARGET_ID,
  COLUMN_TARGET_TITLE,
  COLUMN_TARGET_IMAGE,
  COLUMN_COLLECT_TIME,
  COLUMN_IS_SYNCED,
  TABLE_ARTICLE_CACHE,
  COLUMN_ARTICLE_ID,
  COLUMN_TITLE,
  COLUMN_CONTENT_SUMMARY,
  COLUMN_COVER_IMAGE,
  COLUMN_CATEGORY_ID,
  COLUMN_CACHED_TIME,
  COLUMN_LAST_READ_TIME
} from '../utils/DatabaseConstants';
import relationalStore from '@ohos.data.relationalStore';

interface ArticleDetailData {
  id: number;
  title: string;
  content: string;
  categoryId: number;
  author: string;
  coverImage: string;
  originUrl: string;
  publishTime: string;
  viewCount: number;
  collectCount: number;
}

export interface RelatedArticle {
  id: number;
  title: string;
  coverImage: string;
  summary: string;
  publishTime: string;
  category: string;
  readCount: number;
}

export interface CommentData {
  id: number;
  articleId: number;
  userId: number;
  userName: string;
  userAvatar: string;
  content: string;
  likeCount: number;
  parentId: number;
  status: number;
  createTime: string;
  updateTime: string;
  isDeleted: number;
}

interface CommentPostData {
  articleId: number;
  content: string;
  userId: number;
  parentId: number;
}

interface LikeResponseData {
  likeCount: number;
}

@Entry
@Component
struct ScienceDetailPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @StorageLink('userId') currentUserId: number = 0;
  @StorageLink('username') currentUsername: string = '';
  @State articleId: string = '';
  @State articleTitle: string = '';
  @State isFavorited: boolean = false;
  @State fontSize: number = 16;
  @State isLiked: boolean = false;
  @State likeCount: number = 0;

  @State articleDetail: ArticleDetailData | null = null;
  @State isLoading: boolean = true;
  @State contentSections: string[] = [];
  @State isCollecting: boolean = false;

  @State comments: CommentData[] = [];
  @State commentInputText: string = '';
  @State isSubmittingComment: boolean = false;
  @State replyToCommentId: number = 0;
  @State replyToUserName: string = '';
  @State showCommentInput: boolean = false;

  private browseRecordId: number | undefined = undefined;

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') || false;
    }

    const params = router.getParams() as Record<string, Object>;
    if (params && params['articleId']) {
      this.articleId = params['articleId'] as string;
    }
    if (params && params['articleTitle']) {
      this.articleTitle = params['articleTitle'] as string;
    }

    this.fontSize = this.isElderMode ? 18 : 16;

    this.loadArticleDetail();
    this.checkCollectionStatus();
    this.loadComments();
  }

  aboutToDisappear(): void {
    if (this.browseRecordId) {
      BrowseTracker.recordEnd(this.browseRecordId);
    }
  }

  async loadArticleDetail(): Promise<void> {
    this.isLoading = true;
    try {
      console.info('开始加载文章详情，文章ID:', this.articleId);
      const url: string = ApiConstants.ARTICLE_DETAIL + this.articleId;
      const response: BaseResponse<ArticleDetailData> = await HttpUtil.get<ArticleDetailData>(url);
      console.info('文章详情响应:', JSON.stringify(response));

      if (response.success && response.data) {
        this.articleDetail = response.data;
        this.contentSections = this.parseContent(response.data.content);

        BrowseTracker.recordStart('ARTICLE_DETAIL', 'ARTICLE', Number(this.articleId), this.articleDetail.title)
          .then(id => {
            this.browseRecordId = id;
          });

        this.cacheArticleLocally();
      } else {
        console.error('加载文章详情失败:', response.message);
        ToastUtil.showSuccess(response.message || '加载失败');
      }
    } catch (e) {
      console.error('加载文章详情异常:', e);
      const error = e as Error;
      ToastUtil.showSuccess(error.message || '网络异常，请检查连接');
    } finally {
      this.isLoading = false;
    }
  }

  parseContent(content: string): string[] {
    if (!content) return ['暂无内容'];

    const sections: string[] = [];

    const paragraphs: string[] = content.split('\n');
    for (let i = 0; i < paragraphs.length; i++) {
      const para: string = paragraphs[i].trim();
      if (para.length === 0) continue;

      if (para.indexOf('# ') === 0) {
        sections.push(para.substring(2));
      } else if (para.indexOf('## ') === 0) {
        sections.push(para.substring(3));
      } else if (para.indexOf('### ') === 0) {
        sections.push(para.substring(4));
      } else if (this.isNumberedListItem(para)) {
        sections.push(para);
      } else if (para.length > 5) {
        let cleaned: string = para;
        cleaned = cleaned.replace('**', '').replace('**', '');
        sections.push(cleaned.trim());
      }
    }

    if (sections.length > 0) {
      return sections;
    }
    let fallback: string = content;
    fallback = fallback.replace('#', '');
    fallback = fallback.replace('*', '');
    fallback = fallback.replace('[', '');
    fallback = fallback.replace(']', '');
    fallback = fallback.replace('(', '');
    fallback = fallback.replace(')', '');
    return [fallback.substring(0, 500)];
  }

  private isNumberedListItem(text: string): boolean {
    const numChars = '1234567890一二三四五六七八九十';
    for (let i = 0; i < text.length; i++) {
      if (numChars.indexOf(text.charAt(i)) >= 0) {
        if (i + 1 < text.length && (text.charAt(i + 1) === '.' || text.charAt(i + 1) === '、')) {
          return true;
        }
      }
    }
    return false;
  }

  async cacheArticleLocally(): Promise<void> {
    if (!this.articleDetail) return;

    try {
      const values: relationalStore.ValuesBucket = {};
      values[COLUMN_ARTICLE_ID] = this.articleDetail.id;
      values[COLUMN_TITLE] = this.articleDetail.title;
      let contentSummary: string = '';
      if (this.articleDetail.content && this.articleDetail.content.length > 200) {
        contentSummary = this.articleDetail.content.substring(0, 200);
      } else if (this.articleDetail.content) {
        contentSummary = this.articleDetail.content;
      }
      values[COLUMN_CONTENT_SUMMARY] = contentSummary;
      values[COLUMN_COVER_IMAGE] = this.articleDetail.coverImage ? this.articleDetail.coverImage : '';
      values[COLUMN_CATEGORY_ID] = this.articleDetail.categoryId ? this.articleDetail.categoryId : 0;
      values[COLUMN_CACHED_TIME] = Date.now();
      values[COLUMN_LAST_READ_TIME] = Date.now();

      await RdbHelper.insertOrUpdate(TABLE_ARTICLE_CACHE, values, COLUMN_ARTICLE_ID, this.articleDetail.id);
    } catch (e) {
      console.error('缓存文章到本地失败:', e);
    }
  }

  async checkCollectionStatus(): Promise<void> {
    try {
      const response: BaseResponse<Object[]> = await HttpUtil.get<Object[]>(ApiConstants.ARTICLE_MY_COLLECTS);
      if (response.success && response.data && Array.isArray(response.data)) {
        this.isFavorited = false;
        for (let i = 0; i < response.data.length; i++) {
          const item = response.data[i] as Record<string, Object>;
          const collectedArticleId = String(item['articleId'] || item['id'] || '');
          if (collectedArticleId === this.articleId) {
            this.isFavorited = true;
            break;
          }
        }
      }
    } catch (e) {
      console.error('查询收藏状态失败:', e);
      try {
        const predicates = new relationalStore.RdbPredicates(TABLE_COLLECTION_CACHE);
        predicates.equalTo(COLUMN_COLLECT_TYPE, 'ARTICLE');
        predicates.equalTo(COLUMN_TARGET_ID, Number(this.articleId));
        const result = await RdbHelper.queryByPredicates(predicates, ['id']);
        if (result && result.rowCount > 0) {
          this.isFavorited = true;
          result.close();
        }
      } catch (localError) {
        console.error('本地查询收藏状态也失败:', localError);
      }
    }
  }

  async handleFavorite(): Promise<void> {
    if (this.isCollecting || !this.articleDetail) return;

    this.isCollecting = true;

    try {
      if (this.isFavorited) {
        const uncollectUrl: string = ApiConstants.ARTICLE_UNCOLLECT + this.articleId + '/collect';
        const response: BaseResponse<Object> = await HttpUtil.delete<Object>(uncollectUrl);

        if (response.success) {
          this.isFavorited = false;
          ToastUtil.showSuccess('取消收藏成功');

          const predicates = new relationalStore.RdbPredicates(TABLE_COLLECTION_CACHE);
          predicates.equalTo(COLUMN_COLLECT_TYPE, 'ARTICLE');
          predicates.equalTo(COLUMN_TARGET_ID, Number(this.articleId));
          await RdbHelper.delete(predicates);
        } else {
          console.error('取消收藏失败:', response.message);
          this.isFavorited = false;
          const predicates = new relationalStore.RdbPredicates(TABLE_COLLECTION_CACHE);
          predicates.equalTo(COLUMN_COLLECT_TYPE, 'ARTICLE');
          predicates.equalTo(COLUMN_TARGET_ID, Number(this.articleId));
          await RdbHelper.delete(predicates);
          ToastUtil.showSuccess('已同步收藏状态');
        }
      } else {
        const collectUrl: string = ApiConstants.ARTICLE_COLLECT + this.articleId + '/collect';
        const response: BaseResponse<Object> = await HttpUtil.post<Object>(collectUrl);

        if (response.success) {
          this.isFavorited = true;
          ToastUtil.showSuccess('收藏成功');

          const collectValues: relationalStore.ValuesBucket = {};
          collectValues[COLUMN_COLLECT_TYPE] = 'ARTICLE';
          collectValues[COLUMN_TARGET_ID] = this.articleDetail.id;
          collectValues[COLUMN_TARGET_TITLE] = this.articleDetail.title;
          collectValues[COLUMN_TARGET_IMAGE] = this.articleDetail.coverImage ? this.articleDetail.coverImage : '';
          collectValues[COLUMN_COLLECT_TIME] = Date.now();
          collectValues[COLUMN_IS_SYNCED] = 1;

          await RdbHelper.insert(TABLE_COLLECTION_CACHE, collectValues);
        } else {
          ToastUtil.showSuccess('收藏失败，请稍后重试');
        }
      }
    } catch (e) {
      console.error('收藏操作失败:', e);
      ToastUtil.showSuccess('操作失败，请检查网络');
    } finally {
      this.isCollecting = false;
    }
  }

  handleLike(): void {
    this.isLiked = !this.isLiked;
    this.likeCount += this.isLiked ? 1 : -1;
  }

  adjustFontSize(direction: 'increase' | 'decrease'): void {
    if (direction === 'increase' && this.fontSize < 24) {
      this.fontSize += 2;
    } else if (direction === 'decrease' && this.fontSize > 12) {
      this.fontSize -= 2;
    }
  }

  handleShare(): void {
    if (this.articleDetail) {
      ToastUtil.showSuccess('分享功能已触发');
    }
  }

  async loadComments(): Promise<void> {
    if (!this.articleId) {
      console.warn('文章ID为空，跳过加载评论');
      return;
    }
    try {
      console.info('开始加载评论，文章ID:', this.articleId);
      const url: string = ApiConstants.COMMENT_LIST + this.articleId;
      const response: BaseResponse<CommentData[]> = await HttpUtil.get<CommentData[]>(url);
      console.info('评论加载响应:', JSON.stringify(response));
      
      if (response.success && response.data) {
        this.comments = response.data;
        console.info('成功加载评论数量:', this.comments.length);
      } else {
        console.warn('评论加载失败:', response.message);
        this.comments = [];
      }
    } catch (e) {
      console.error('加载评论异常:', e);
      this.comments = [];
    }
  }

  async postComment(): Promise<void> {
    console.info('评论按钮被点击');
    console.info('用户ID:', this.currentUserId, '文章ID:', this.articleId);
    
    if (!this.commentInputText.trim()) {
      console.error('评论内容为空');
      ToastUtil.showSuccess('请输入评论内容');
      return;
    }
    if (this.isSubmittingComment) {
      console.warn('正在提交评论，请勿重复点击');
      return;
    }
    
    if (!this.currentUserId || this.currentUserId === 0) {
      console.error('未登录或用户ID无效');
      ToastUtil.showSuccess('请先登录');
      return;
    }

    this.isSubmittingComment = true;
    try {
      const postData: CommentPostData = {
        articleId: Number(this.articleId),
        content: this.commentInputText.trim(),
        userId: this.currentUserId,
        parentId: this.replyToCommentId
      };
      console.info('发送评论请求:', JSON.stringify(postData));
      const response: BaseResponse<CommentData> = await HttpUtil.post<CommentData>(ApiConstants.COMMENT_ADD, postData);
      console.info('评论响应:', JSON.stringify(response));
      if (response.success && response.data) {
        this.comments.unshift(response.data);
        this.commentInputText = '';
        this.replyToCommentId = 0;
        this.replyToUserName = '';
        this.showCommentInput = false;
        ToastUtil.showSuccess('评论发布成功');
      } else {
        const errorMsg = response.message || '评论发布失败';
        console.error('评论发布失败:', errorMsg, '响应码:', response.code);
        ToastUtil.showSuccess(errorMsg);
      }
    } catch (e) {
      console.error('发布评论异常:', e);
      const error = e as Error;
      let errorMsg = '发布失败，请检查网络';
      if (error.message) {
        if (error.message.includes('timeout')) {
          errorMsg = '请求超时，请稍后重试';
        } else if (error.message.includes('network')) {
          errorMsg = '网络连接失败';
        } else if (error.message.includes('401')) {
          errorMsg = '登录已过期，请重新登录';
        } else {
          errorMsg = '发布失败: ' + error.message;
        }
      }
      ToastUtil.showSuccess(errorMsg);
    } finally {
      this.isSubmittingComment = false;
    }
  }

  async deleteComment(commentId: number): Promise<void> {
    try {
      const url: string = ApiConstants.COMMENT_DELETE + commentId;
      const response: BaseResponse<Object> = await HttpUtil.delete<Object>(url);
      if (response.success) {
        this.comments = this.comments.filter(c => c.id !== commentId);
        ToastUtil.showSuccess('删除成功');
      } else {
        ToastUtil.showSuccess('删除失败');
      }
    } catch (e) {
      console.error('删除评论失败:', e);
      ToastUtil.showSuccess('操作失败');
    }
  }

  async likeComment(commentId: number): Promise<void> {
    try {
      const url: string = ApiConstants.COMMENT_LIKE + commentId;
      const response: BaseResponse<LikeResponseData> = await HttpUtil.post<LikeResponseData>(url);
      if (response.success && response.data) {
        const idx = this.comments.findIndex(c => c.id === commentId);
        if (idx >= 0) {
          this.comments[idx].likeCount = response.data.likeCount;
        }
      }
    } catch (e) {
      console.error('点赞失败:', e);
    }
  }

  startReply(comment: CommentData): void {
    this.replyToCommentId = comment.id;
    this.replyToUserName = comment.userName;
    this.commentInputText = '';
    this.showCommentInput = true;
  }

  cancelReply(): void {
    this.replyToCommentId = 0;
    this.replyToUserName = '';
    this.commentInputText = '';
    this.showCommentInput = false;
  }

  getParentUserName(parentId: number): string {
    for (let i = 0; i < this.comments.length; i++) {
      if (this.comments[i].id === parentId) {
        return this.comments[i].userName;
      }
    }
    return '';
  }

  formatDate(dateStr: string | Date): string {
    if (!dateStr) return '';
    const date: Date = new Date(dateStr);
    const year: number = date.getFullYear();
    const month: string = String(date.getMonth() + 1).padStart(2, '0');
    const day: string = String(date.getDate()).padStart(2, '0');
    return year + '-' + month + '-' + day;
  }

  formatReadCount(count: number): string {
    if (count >= 10000) {
      return (count / 10000).toFixed(1) + 'w';
    } else if (count >= 1000) {
      return (count / 1000).toFixed(1) + 'k';
    }
    return count.toString();
  }

  @Builder buildCommentSection(): void {
    Column({ space: 12 }) {
      Row() {
        Text('💬 评论 (' + this.comments.length + ')')
          .fontSize(this.isElderMode ? 18 : 16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
        Blank()
        Button('写评论')
          .fontSize(13)
          .fontColor('#1677FF')
          .backgroundColor('#E6F4FF')
          .borderRadius(16)
          .height(32)
          .onClick(() => {
            this.showCommentInput = true;
            this.replyToCommentId = 0;
            this.replyToUserName = '';
            this.commentInputText = '';
          })
      }
      .width('100%')

      if (this.showCommentInput) {
        Column({ space: 10 }) {
          if (this.replyToUserName && this.replyToUserName.length > 0) {
            Row({ space: 8 }) {
              Text('回复 @' + this.replyToUserName)
                .fontSize(13)
                .fontColor('#1677FF')
              Text('取消')
                .fontSize(13)
                .fontColor('#999999')
                .onClick(() => this.cancelReply())
            }
            .width('100%')
          }

          Row({ space: 8 }) {
            TextInput({
              placeholder: this.replyToUserName ? '回复 @' + this.replyToUserName + '...' : '写下你的看法...',
              text: this.commentInputText
            })
              .layoutWeight(1)
              .height(40)
              .fontSize(14)
              .backgroundColor('#F5F7FA')
              .borderRadius(20)
              .padding({ left: 16, right: 12 })
              .onChange((value: string) => {
                this.commentInputText = value;
              })

            Button('发送')
              .height(40)
              .fontSize(14)
              .fontColor('#FFFFFF')
              .backgroundColor(this.commentInputText.trim().length > 0 ? '#1677FF' : '#CCCCCC')
              .borderRadius(20)
              .enabled(!this.isSubmittingComment && this.commentInputText.trim().length > 0)
              .onClick(() => this.postComment())
          }
          .width('100%')
        }
        .width('100%')
        .padding(14)
        .backgroundColor('#FAFAFA')
        .borderRadius(12)
        .border({ width: 1, color: '#EEEEEE' })
      }

      if (this.comments.length === 0) {
        Column({ space: 8 }) {
          Text('💭')
            .fontSize(36)
          Text('暂无评论，快来发表第一条吧~')
            .fontSize(14)
            .fontColor('#999999')
        }
        .width('100%')
        .height(120)
        .justifyContent(FlexAlign.Center)
      } else {
        ForEach(this.comments, (comment: CommentData) => {
          Column({ space: 10 }) {
            Row({ space: 10 }) {
              if (comment.userAvatar && comment.userAvatar.indexOf('http') === 0) {
                Image(comment.userAvatar)
                  .width(36)
                  .height(36)
                  .borderRadius(18)
                  .objectFit(ImageFit.Cover)
              } else {
                Text(comment.userName.charAt(0))
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                  .width(36)
                  .height(36)
                  .borderRadius(18)
                  .backgroundColor('#1677FF')
                  .textAlign(TextAlign.Center)
              }

              Column({ space: 6 }) {
                Row({ space: 8 }) {
                  Text(comment.userName)
                    .fontSize(this.isElderMode ? 15 : 13)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#333333')

                  if (comment.parentId > 0) {
                    Text('回复 @' + this.getParentUserName(comment.parentId))
                      .fontSize(11)
                      .fontColor('#1677FF')
                  }

                  Blank()

                  Text(this.formatTimeAgo(comment.createTime))
                    .fontSize(11)
                    .fontColor('#BBBBBB')
                }
                .width('100%')

                Text(comment.content)
                  .fontSize(this.isElderMode ? 15 : 13)
                  .fontColor('#444444')
                  .lineHeight(20)
                  .maxLines(5)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .width('100%')

                Row({ space: 16 }) {
                  Row({ space: 4 }) {
                    Text('👍')
                      .fontSize(14)
                    Text(comment.likeCount.toString())
                      .fontSize(12)
                      .fontColor('#999999')
                  }
                  .onClick(() => this.likeComment(comment.id))

                  Text('回复')
                    .fontSize(12)
                    .fontColor('#666666')
                    .onClick(() => this.startReply(comment))

                  if (comment.userName === '当前用户') {
                    Text('删除')
                      .fontSize(12)
                      .fontColor('#E74C3C')
                      .onClick(() => this.deleteComment(comment.id))
                  }
                }
                .width('100%')
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
          }
          .width('100%')
          .padding(14)
          .backgroundColor('#FFFFFF')
          .borderRadius(10)
          .border({ width: 1, color: '#F0F0F0' })
        }, (comment: CommentData) => comment.id.toString());
      }
    }
    .width('100%')
    .padding(GlobalTheme.getSpacingLG(this.isElderMode))
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .border({ width: 1, color: '#F0F0F0' })
  }

  formatTimeAgo(dateStr: string): string {
    if (!dateStr) return '';
    const date: Date = new Date(dateStr);
    const now: number = Date.now();
    const diff: number = now - date.getTime();
    const minutes: number = Math.floor(diff / 60000);
    if (minutes < 1) return '刚刚';
    if (minutes < 60) return minutes + '分钟前';
    const hours: number = Math.floor(minutes / 60);
    if (hours < 24) return hours + '小时前';
    const days: number = Math.floor(hours / 24);
    if (days < 30) return days + '天前';
    return this.formatDate(dateStr);
  }

  build() {
    Column() {
      Row() {
        Text('\u2190')
          .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
          .fontColor('#1677FF')
          .width(40)
          .height(40)
          .textAlign(TextAlign.Center)
          .backgroundColor('#E6F4FF')
          .borderRadius(20)
          .onClick(() => {
            router.back();
          })
        Text('文章详情')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Text('\u{1F4E4}')
          .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
          .fontColor('#1677FF')
          .width(40)
          .height(40)
          .textAlign(TextAlign.Center)
          .onClick(() => this.handleShare());
      }
      .width('100%')
      .height(56)
      .backgroundColor('#FFFFFF')
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.Center)

      Scroll() {
        Column({ space: GlobalTheme.getSpacingLG(this.isElderMode) }) {
          if (this.isLoading) {
            Column() {
              LoadingProgress()
                .width(40)
                .height(40)
                .color('#1677FF');
              Text('正在加载文章...')
                .fontSize(14)
                .fontColor('#666666')
                .margin({ top: 12 });
            }
            .width('100%')
            .height(400)
            .justifyContent(FlexAlign.Center);
          } else if (this.articleDetail) {
            Column() {
              if (this.articleDetail.coverImage && this.articleDetail.coverImage.length > 0 &&
                  this.articleDetail.coverImage.indexOf('http') === 0) {
                Image(this.articleDetail.coverImage)
                  .width('100%')
                  .height(200)
                  .objectFit(ImageFit.Cover)
                  .borderRadius({ topLeft: 12, topRight: 12 })
                  .alt('\u{1F4F0}')
              } else {
                Text('\u{1F4F0}')
                  .fontSize(this.isElderMode ? 96 : 80)
                  .margin({ bottom: GlobalTheme.getSpacingMD(this.isElderMode) });
              }

              Text(this.articleDetail.title)
                .fontSize(this.isElderMode ? 24 : 20)
                .fontWeight('bold')
                .fontColor('#333333')
                .textAlign(TextAlign.Start)
                .margin({ top: GlobalTheme.getSpacingMD(this.isElderMode), left: GlobalTheme.getSpacingMD(this.isElderMode), right: GlobalTheme.getSpacingMD(this.isElderMode) })
                .maxLines(3);

              Row({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
                Text('\u4F5C\u8005\uFF1A' + (this.articleDetail.author ? this.articleDetail.author : '\u5065\u5EBB\u4E13\u5BB6'))
                  .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                  .fontColor('#999999');

                Text('\u{1F4C5} ' + this.formatDate(this.articleDetail.publishTime))
                  .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                  .fontColor('#999999');

                Text('\u{1F441} ' + this.formatReadCount(this.articleDetail.viewCount))
                  .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                  .fontColor('#999999');
              }
              .justifyContent(FlexAlign.Start)
              .width('100%')
              .padding({ left: GlobalTheme.getSpacingMD(this.isElderMode), right: GlobalTheme.getSpacingMD(this.isElderMode), bottom: GlobalTheme.getSpacingMD(this.isElderMode) });
            }
            .width('100%')
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .border({ width: 1, color: '#F0F0F0' })
            .alignItems(HorizontalAlign.Start);

            Column({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
              ForEach(this.contentSections, (text: string, i: number) => {
                Text(text)
                  .fontSize(this.fontSize)
                  .fontColor('#444444')
                  .lineHeight(this.fontSize * 1.8)
                  .width('100%')
                  .textAlign(TextAlign.Start);
              }, (text: string, i: number) => this.articleId + '-p-' + i.toString());
            }
            .width('100%')
            .padding(GlobalTheme.getSpacingLG(this.isElderMode))
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .border({ width: 1, color: '#F0F0F0' })
            .alignItems(HorizontalAlign.Start);

            this.buildCommentSection();
          }
        }
        .width('85%')
        .padding({ top: GlobalTheme.getSpacingMD(this.isElderMode), bottom: 140 });
      }
      .height(0)
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top);

      Column() {
        Row() {
          Button(this.isFavorited ? '\u2764\uFE0F' : '\u{1F90D}')
            .width(56)
            .height(56)
            .fontSize(24)
            .backgroundColor('transparent')
            .border({ width: 0 })
            .onClick(() => {
              this.handleFavorite();
            });

          Button(this.isLiked ? '\u{1F44D}' : '\u{1F44F}\u{1F3FC}')
            .width(56)
            .height(56)
            .fontSize(24)
            .backgroundColor('transparent')
            .border({ width: 0 })
            .onClick(() => this.handleLike());

          Row({ space: 4 }) {
            Text('💬')
              .fontSize(20)
            Text(this.comments.length.toString())
              .fontSize(12)
              .fontColor('#666666')
          }
          .padding({ left: 12, right: 8, top: 8, bottom: 8 })
          .backgroundColor('#F5F7FA')
          .borderRadius(20)
          .onClick(() => {
            this.showCommentInput = !this.showCommentInput;
            if (this.showCommentInput) {
              this.replyToCommentId = 0;
              this.replyToUserName = '';
            }
          })

          Row() {
            Button('A-')
              .width(48)
              .height(48)
              .fontSize(16)
              .fontColor('#666666')
              .backgroundColor('#F5F7FA')
              .borderRadius(24)
              .border({ width: 0 })
              .onClick(() => this.adjustFontSize('decrease'));

            Text(this.fontSize.toString() + 'px')
              .fontSize(14)
              .fontColor('#666666')
              .margin({ left: 8, right: 8 })
              .alignSelf(ItemAlign.Center);

            Button('A+')
              .width(48)
              .height(48)
              .fontSize(16)
              .fontColor('#666666')
              .backgroundColor('#F5F7FA')
              .borderRadius(24)
              .border({ width: 0 })
              .onClick(() => this.adjustFontSize('increase'));
          }
          .margin({ left: 'auto' });
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center);
      }
      .width('100%')
      .height(80)
      .padding({ top: 12, bottom: 12 })
      .backgroundColor('#FFFFFF')
      .shadow({
        radius: 12,
        color: '#00000012',
        offsetX: 0,
        offsetY: -4
      });

      Footer({ activeIndex: 3 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor(GlobalTheme.BG_COLOR);
  }
}