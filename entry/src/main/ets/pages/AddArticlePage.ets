import { router } from '@kit.ArkUI';
import { ToastUtil } from '../common/utils/ToastUtil';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';

interface ArticleCategory {
  id: number;
  categoryName: string;
  categoryCode: string;
}

interface ArticleSubmitData {
  title: string;
  content: string;
  summary: string;
  author: string;
  categoryId: number;
  status: number;
  viewCount: number;
  likeCount: number;
  collectCount: number;
}

@Entry
@Component
struct AddArticlePage {
  @State title: string = '';
  @State content: string = '';
  @State summary: string = '';
  @State author: string = '';
  @State selectedCategoryId: number = 0;
  @State categories: ArticleCategory[] = [];
  @State isSubmitting: boolean = false;
  @State isLoadingCategories: boolean = true;

  private static readonly MAX_TITLE_LENGTH: number = 100;
  private static readonly MAX_CONTENT_LENGTH: number = 10000;
  private static readonly MAX_SUMMARY_LENGTH: number = 500;

  aboutToAppear(): void {
    this.loadCategories();
    const userInfo = AppStorage.get<Object>('userInfo');
    if (userInfo) {
      const user = userInfo as Record<string, Object>;
      if (user['username']) {
        this.author = user['username'] as string;
      }
    }
  }

  async loadCategories(): Promise<void> {
    this.isLoadingCategories = true;
    try {
      const response: BaseResponse<ArticleCategory[]> = await HttpUtil.get<ArticleCategory[]>(ApiConstants.ARTICLE_CATEGORIES_PARENT);
      if (response.success && response.data) {
        this.categories = response.data;
      }
    } catch (e) {
      console.error('加载分类失败:', e);
    } finally {
      this.isLoadingCategories = false;
    }
  }

  async submitArticle(): Promise<void> {
    if (!this.title.trim()) {
      ToastUtil.showInfo('请输入文章标题');
      return;
    }

    if (this.title.length > AddArticlePage.MAX_TITLE_LENGTH) {
      ToastUtil.showInfo('标题不能超过' + AddArticlePage.MAX_TITLE_LENGTH + '字');
      return;
    }

    if (!this.content.trim()) {
      ToastUtil.showInfo('请输入文章内容');
      return;
    }

    if (this.content.length > AddArticlePage.MAX_CONTENT_LENGTH) {
      ToastUtil.showInfo('内容不能超过' + AddArticlePage.MAX_CONTENT_LENGTH + '字');
      return;
    }

    if (this.selectedCategoryId === 0) {
      ToastUtil.showInfo('请选择文章分类');
      return;
    }

    this.isSubmitting = true;
    try {
      let articleSummary: string = this.summary.trim();
      if (!articleSummary && this.content.length > 0) {
        articleSummary = this.content.substring(0, Math.min(200, this.content.length));
      }

      const articleData: ArticleSubmitData = {
        title: this.title.trim(),
        content: this.content.trim(),
        summary: articleSummary,
        author: this.author.trim() || '健康达人',
        categoryId: this.selectedCategoryId,
        status: 1,
        viewCount: 0,
        likeCount: 0,
        collectCount: 0
      };

      const response: BaseResponse<Object> = await HttpUtil.post<Object>(ApiConstants.ARTICLE_ADD, articleData);

      if (response.success) {
        ToastUtil.showSuccess('文章发布成功！');
        setTimeout(() => {
          router.back();
        }, 1500);
      } else {
        ToastUtil.showError(response.message || '发布失败，请稍后重试');
      }
    } catch (e) {
      console.error('发布文章失败:', e);
      ToastUtil.showError('发布失败，请检查网络连接');
    } finally {
      this.isSubmitting = false;
    }
  }

  getCategoryName(): string {
    for (let i = 0; i < this.categories.length; i++) {
      if (this.categories[i].id === this.selectedCategoryId) {
        return this.categories[i].categoryName;
      }
    }
    return '选择分类';
  }

  build() {
    Column() {
      Row() {
        Text('\u2190')
          .fontSize(20)
          .fontColor('#1677FF')
          .width(40)
          .height(40)
          .textAlign(TextAlign.Center)
          .backgroundColor('#E6F4FF')
          .borderRadius(20)
          .onClick(() => {
            router.back();
          })

        Text('发表文章')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Text('   ')
          .width(40);
      }
      .width('100%')
      .height(56)
      .backgroundColor('#FFFFFF')
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.Center)

      Scroll() {
        Column({ space: 16 }) {
          Column({ space: 12 }) {
            Text('文章标题')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .width('100%');

            TextInput({ placeholder: '请输入文章标题（最多100字）', text: this.title })
              .width('100%')
              .height(48)
              .fontSize(15)
              .backgroundColor('#F5F7FA')
              .borderRadius(8)
              .padding({ left: 12, right: 12 })
              .maxLength(AddArticlePage.MAX_TITLE_LENGTH)
              .onChange((value: string) => {
                this.title = value;
              });

            Text(this.title.length + '/' + AddArticlePage.MAX_TITLE_LENGTH)
              .fontSize(12)
              .fontColor(this.title.length > AddArticlePage.MAX_TITLE_LENGTH * 0.8 ? '#FF4D4F' : '#999999')
              .width('100%')
              .textAlign(TextAlign.End);
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12);

          Column({ space: 12 }) {
            Text('文章分类')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .width('100%');

            if (this.isLoadingCategories) {
              Text('加载分类中...')
                .fontSize(14)
                .fontColor('#999999');
            } else {
              Row() {
                Text(this.getCategoryName())
                  .fontSize(15)
                  .fontColor(this.selectedCategoryId > 0 ? '#333333' : '#999999')
                  .layoutWeight(1);

                Text('>')
                  .fontSize(16)
                  .fontColor('#999999');
              }
              .width('100%')
              .height(48)
              .padding({ left: 12, right: 12 })
              .backgroundColor('#F5F7FA')
              .borderRadius(8)
              .onClick(() => {
                this.showCategorySelector();
              });

              if (this.categories.length > 0) {
                Flex({ wrap: FlexWrap.Wrap }) {
                  ForEach(this.categories, (category: ArticleCategory) => {
                    Text(category.categoryName)
                      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                      .fontSize(13)
                      .fontColor(this.selectedCategoryId === category.id ? '#FFFFFF' : '#666666')
                      .backgroundColor(this.selectedCategoryId === category.id ? '#1677FF' : '#F5F7FA')
                      .borderRadius(16)
                      .margin({ right: 8, bottom: 8 })
                      .onClick(() => {
                        this.selectedCategoryId = category.id;
                      });
                  }, (category: ArticleCategory) => category.id.toString());
                }
                .width('100%');
              }
            }
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12);

          Column({ space: 12 }) {
            Text('文章摘要（选填）')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .width('100%');

            TextArea({ placeholder: '请输入文章摘要，不填将自动提取前200字...', text: this.summary })
              .width('100%')
              .height(80)
              .fontSize(14)
              .backgroundColor('#F5F7FA')
              .borderRadius(8)
              .padding(12)
              .maxLength(AddArticlePage.MAX_SUMMARY_LENGTH)
              .onChange((value: string) => {
                this.summary = value;
              });

            Text(this.summary.length + '/' + AddArticlePage.MAX_SUMMARY_LENGTH)
              .fontSize(12)
              .fontColor(this.summary.length > AddArticlePage.MAX_SUMMARY_LENGTH * 0.8 ? '#FF4D4F' : '#999999')
              .width('100%')
              .textAlign(TextAlign.End);
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12);

          Column({ space: 12 }) {
            Row() {
              Text('文章内容')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
                .layoutWeight(1);

              Text(this.content.length + '/' + AddArticlePage.MAX_CONTENT_LENGTH)
                .fontSize(12)
                .fontColor(this.content.length > AddArticlePage.MAX_CONTENT_LENGTH * 0.8 ? '#FF4D4F' : '#999999');
            }
            .width('100%');

            TextArea({ placeholder: '请输入文章内容...\n支持 Markdown 格式\n# 标题\n## 二级标题\n**加粗文字**\n- 列表项', text: this.content })
              .width('100%')
              .height(350)
              .fontSize(14)
              .backgroundColor('#F5F7FA')
              .borderRadius(8)
              .padding(12)
              .maxLength(AddArticlePage.MAX_CONTENT_LENGTH)
              .onChange((value: string) => {
                this.content = value;
              });
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12);

          Column({ space: 12 }) {
            Text('作者昵称')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .width('100%');

            TextInput({ placeholder: '请输入作者昵称', text: this.author })
              .width('100%')
              .height(48)
              .fontSize(15)
              .backgroundColor('#F5F7FA')
              .borderRadius(8)
              .padding({ left: 12, right: 12 })
              .maxLength(50)
              .onChange((value: string) => {
                this.author = value;
              });
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12);
        }
        .width('90%')
        .padding({ top: 16, bottom: 120 });
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top);

      Column() {
        Button(this.isSubmitting ? '发布中...' : '发布文章')
          .width('90%')
          .height(48)
          .fontSize(16)
          .fontColor('#FFFFFF')
          .backgroundColor(this.canSubmit() ? '#1677FF' : '#CCCCCC')
          .borderRadius(24)
          .enabled(!this.isSubmitting && this.canSubmit())
          .onClick(() => {
            this.submitArticle();
          });
      }
      .width('100%')
      .height(80)
      .padding({ top: 16, bottom: 16 })
      .backgroundColor('#FFFFFF')
      .shadow({
        radius: 12,
        color: '#00000012',
        offsetX: 0,
        offsetY: -4
      })
      .justifyContent(FlexAlign.Center);
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }

  canSubmit(): boolean {
    return this.title.trim().length > 0 &&
           this.content.trim().length > 0 &&
           this.selectedCategoryId > 0;
  }

  showCategorySelector(): void {
  }
}
