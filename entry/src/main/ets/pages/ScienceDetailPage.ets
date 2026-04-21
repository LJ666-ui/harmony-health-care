import { router } from '@kit.ArkUI';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import BrowseTracker from '../utils/BrowseTracker';
import RdbHelper from '../utils/RdbHelper';
import { SettingsUtil } from '../utils/SettingsUtil';
import { CommentSection } from '../components/CommentSection';
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
  COLUMN_ID,
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

@Entry
@Component
struct ScienceDetailPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
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
  @State isOfflineAvailable: boolean = false;
  @State isDownloading: boolean = false;
  @State downloadProgress: number = 0;
  @State settingsUtil: SettingsUtil = SettingsUtil.getInstance();

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

    this.loadSavedFontSize();
    this.loadArticleDetail();
    this.checkCollectionStatus();
    this.checkOfflineStatus();
  }

  async loadSavedFontSize(): Promise<void> {
    try {
      const savedSize: number = await this.settingsUtil.getFontSize();
      if (savedSize >= 12 && savedSize <= 24) {
        this.fontSize = savedSize;
      } else {
        this.fontSize = this.isElderMode ? 18 : 16;
      }
    } catch (e) {
      console.error('加载字体设置失败:', e);
      this.fontSize = this.isElderMode ? 18 : 16;
    }
  }

  async checkOfflineStatus(): Promise<void> {
    try {
      const predicates = new relationalStore.RdbPredicates(TABLE_ARTICLE_CACHE);
      predicates.equalTo(COLUMN_ARTICLE_ID, Number(this.articleId));

      const result = await RdbHelper.queryByPredicates(predicates, [COLUMN_ID]);
      if (result && result.rowCount > 0) {
        this.isOfflineAvailable = true;
        result.close();
      }
    } catch (e) {
      console.error('检查离线状态失败:', e);
    }
  }

  aboutToDisappear(): void {
    if (this.browseRecordId) {
      BrowseTracker.recordEnd(this.browseRecordId);
    }
  }

  async loadArticleDetail(): Promise<void> {
    this.isLoading = true;
    try {
      const url: string = ApiConstants.ARTICLE_DETAIL + this.articleId;
      const response: BaseResponse<ArticleDetailData> = await HttpUtil.get<ArticleDetailData>(url);

      if (response.success && response.data) {
        this.articleDetail = response.data;
        this.contentSections = this.parseContent(response.data.content);

        BrowseTracker.recordStart('ARTICLE_DETAIL', 'ARTICLE', Number(this.articleId), this.articleDetail.title)
          .then(id => {
            this.browseRecordId = id;
          });

        this.cacheArticleLocally();
      } else {
        ToastUtil.showSuccess('加载失败');
      }
    } catch (e) {
      console.error('加载文章详情失败:', e);
      ToastUtil.showSuccess('网络异常，请检查连接');
    } finally {
      this.isLoading = false;
    }
  }

  parseContent(content: string): string[] {
    if (!content) return ['暂无内容'];

    const sections: string[] = [];

    const paragraphs: string[] = content.split('\n');
    for (let idx = 0; idx < paragraphs.length; idx++) {
      const para: string = paragraphs[idx].trim();
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
    for (let charIdx = 0; charIdx < text.length; charIdx++) {
      if (numChars.indexOf(text.charAt(charIdx)) >= 0) {
        if (charIdx + 1 < text.length && (text.charAt(charIdx + 1) === '.' || text.charAt(charIdx + 1) === '、')) {
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
      const predicates = new relationalStore.RdbPredicates(TABLE_COLLECTION_CACHE);
      predicates.equalTo(COLUMN_COLLECT_TYPE, 'ARTICLE');
      predicates.equalTo(COLUMN_TARGET_ID, Number(this.articleId));

      const result = await RdbHelper.queryByPredicates(predicates, ['id']);
      if (result && result.rowCount > 0) {
        this.isFavorited = true;
        result.close();
      }
    } catch (e) {
      console.error('查询收藏状态失败:', e);
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
          ToastUtil.showSuccess('取消收藏失败');
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

    this.saveFontSizeSetting();
  }

  async saveFontSizeSetting(): Promise<void> {
    try {
      await this.settingsUtil.setFontSize(this.fontSize);
      console.info('字体大小已保存:', this.fontSize);
    } catch (e) {
      console.error('保存字体设置失败:', e);
    }
  }

  async downloadForOffline(): Promise<void> {
    if (!this.articleDetail || this.isDownloading) return;

    this.isDownloading = true;
    this.downloadProgress = 0;

    try {
      const totalSteps: number = 5;

      for (let step = 1; step <= totalSteps; step++) {
        await new Promise<void>(resolve => setTimeout(() => resolve(), 300));
        this.downloadProgress = Math.round((step / totalSteps) * 100);
      }

      const values: relationalStore.ValuesBucket = {};
      values[COLUMN_ARTICLE_ID] = this.articleDetail.id;
      values[COLUMN_TITLE] = this.articleDetail.title;
      let fullContent: string = '';
      if (this.articleDetail.content && this.articleDetail.content.length > 1000) {
        fullContent = this.articleDetail.content.substring(0, 1000);
      } else if (this.articleDetail.content) {
        fullContent = this.articleDetail.content;
      }
      values[COLUMN_CONTENT_SUMMARY] = fullContent;
      values[COLUMN_COVER_IMAGE] = this.articleDetail.coverImage ? this.articleDetail.coverImage : '';
      values[COLUMN_CATEGORY_ID] = this.articleDetail.categoryId ? this.articleDetail.categoryId : 0;
      values[COLUMN_CACHED_TIME] = Date.now();
      values[COLUMN_LAST_READ_TIME] = Date.now();

      await RdbHelper.insertOrUpdate(TABLE_ARTICLE_CACHE, values, COLUMN_ARTICLE_ID, this.articleDetail.id);

      this.isOfflineAvailable = true;
      ToastUtil.showSuccess('离线下载完成 ✓');
    } catch (e) {
      console.error('离线下载失败:', e);
      ToastUtil.showError('下载失败，请检查存储空间');
    } finally {
      this.isDownloading = false;
      this.downloadProgress = 0;
    }
  }

  handleShare(): void {
    if (this.articleDetail) {
      ToastUtil.showSuccess('分享功能已触发');
    }
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
              ForEach(this.contentSections, (item: string, index: number) => {
                Text(item)
                  .fontSize(this.fontSize)
                  .fontColor('#444444')
                  .lineHeight(this.fontSize * 1.8)
                  .width('100%')
                  .textAlign(TextAlign.Start);
              }, (item: string, index: number) => this.articleId + '-p-' + index.toString());
            }
            .width('100%')
            .padding(GlobalTheme.getSpacingLG(this.isElderMode))
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .border({ width: 1, color: '#F0F0F0' })
            .alignItems(HorizontalAlign.Start);

            CommentSection({ articleId: this.articleId })
              .margin({ top: 16 })
              .constraintSize({ minHeight: 400 });
          }
        }
        .width('85%')
        .padding({ top: GlobalTheme.getSpacingMD(this.isElderMode), bottom: 120 });
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

          if (this.isOfflineAvailable) {
            Text('✓ 已离线')
              .height(40)
              .fontSize(12)
              .fontColor('#52C41A')
              .padding({ left: 10, right: 10 })
              .backgroundColor('#F6FFED')
              .borderRadius(16)
              .alignSelf(ItemAlign.Center);
          } else {
            Column() {
              if (this.isDownloading) {
                Column({ space: 4 }) {
                  Progress({ value: this.downloadProgress, total: 100, type: ProgressType.Ring })
                    .width(32)
                    .height(32)
                    .color('#1677FF')
                    .backgroundColor('#E6F4FF');

                  Text(this.downloadProgress + '%')
                    .fontSize(9)
                    .fontColor('#1677FF');
                }
                .width(40)
                .height(40);
              } else {
                Button('⬇ 离线')
                  .height(36)
                  .fontSize(11)
                  .fontColor('#1677FF')
                  .backgroundColor('#E6F4FF')
                  .borderRadius(18)
                  .onClick(() => this.downloadForOffline());
              }
            }
            .alignSelf(ItemAlign.Center);
          }

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