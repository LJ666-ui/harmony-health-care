import { router } from '@kit.ArkUI';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import RdbHelper from '../utils/RdbHelper';
import {
  TABLE_ARTICLE_DRAFT,
  COLUMN_ID,
  COLUMN_DRAFT_TITLE,
  COLUMN_DRAFT_CONTENT,
  COLUMN_DRAFT_CATEGORY_ID,
  COLUMN_DRAFT_COVER_IMAGE,
  COLUMN_DRAFT_LAST_EDIT_TIME
} from '../utils/DatabaseConstants';
import relationalStore from '@ohos.data.relationalStore';

interface CategoryOption {
  id: number;
  name: string;
}

interface ArticlePostData {
  title: string;
  content: string;
  categoryId: number;
  categoryName: string;
  author: string;
  coverImage: string;
}

@Entry
@Component
struct PublishArticlePage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @StorageLink('userId') currentUserId: number = 0;
  @StorageLink('isLoggedIn') isLoggedIn: boolean = false;

  @State articleTitle: string = '';
  @State articleContent: string = '';
  @State selectedCategoryIndex: number = 0;
  @State isPublishing: boolean = false;
  @State showSaveDraftConfirm: boolean = false;

  private categories: CategoryOption[] = [
    { id: 1, name: '中医养生' },
    { id: 2, name: '慢病管理' },
    { id: 3, name: '康复指导' },
    { id: 4, name: '运动健康' },
    { id: 5, name: '老年健康' }
  ];

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    }
    this.loadDraft();
  }

  async loadDraft(): Promise<void> {
    try {
      const predicates = new relationalStore.RdbPredicates(TABLE_ARTICLE_DRAFT);
      predicates.orderByDesc(COLUMN_DRAFT_LAST_EDIT_TIME);
      predicates.limitAs(1);

      const result = await RdbHelper.queryByPredicates(predicates,
        [COLUMN_DRAFT_TITLE, COLUMN_DRAFT_CONTENT, COLUMN_DRAFT_CATEGORY_ID]);

      if (result && result.goToFirstRow()) {
        const title = result.getString(0);
        const content = result.getString(1);
        const categoryId = result.getLong(2);

        if (title && title.length > 0) {
          this.articleTitle = title;
        }
        if (content && content.length > 0) {
          this.articleContent = content;
        }

        for (let i = 0; i < this.categories.length; i++) {
          if (this.categories[i].id === categoryId) {
            this.selectedCategoryIndex = i;
            break;
          }
        }
        result.close();
      }
    } catch (e) {
      console.error('加载草稿失败:', e);
    }
  }

  async saveDraft(): Promise<void> {
    try {
      const values: relationalStore.ValuesBucket = {};
      values[COLUMN_DRAFT_TITLE] = this.articleTitle;
      values[COLUMN_DRAFT_CONTENT] = this.articleContent;
      values[COLUMN_DRAFT_CATEGORY_ID] = this.categories[this.selectedCategoryIndex].id;
      values[COLUMN_DRAFT_COVER_IMAGE] = '';
      values[COLUMN_DRAFT_LAST_EDIT_TIME] = Date.now();

      await RdbHelper.insertOrUpdate(TABLE_ARTICLE_DRAFT, values, COLUMN_ID, 1);
      ToastUtil.showSuccess('草稿已保存');
    } catch (e) {
      console.error('保存草稿失败:', e);
      ToastUtil.showSuccess('草稿保存失败');
    }
  }

  async publishArticle(): Promise<void> {
    console.info('发布按钮被点击');
    console.info('登录状态:', this.isLoggedIn, '用户ID:', this.currentUserId);
    
    if (!this.isLoggedIn || !this.currentUserId || this.currentUserId === 0) {
      console.error('未登录或用户ID无效');
      ToastUtil.showSuccess('请先登录');
      return;
    }
    
    if (!this.articleTitle.trim()) {
      console.error('标题为空');
      ToastUtil.showSuccess('请输入文章标题');
      return;
    }
    if (this.articleTitle.trim().length < 5) {
      console.error('标题长度不足:', this.articleTitle.trim().length);
      ToastUtil.showSuccess('文章标题至少需要5个字');
      return;
    }
    if (!this.articleContent.trim()) {
      console.error('内容为空');
      ToastUtil.showSuccess('请输入文章内容');
      return;
    }
    if (this.articleContent.trim().length < 20) {
      console.error('内容长度不足:', this.articleContent.trim().length);
      ToastUtil.showSuccess('文章内容至少需要20个字');
      return;
    }

    if (this.isPublishing) {
      console.warn('正在发布中，请勿重复点击');
      return;
    }

    this.isPublishing = true;
    try {
      const postData: ArticlePostData = {
        title: this.articleTitle.trim(),
        content: this.articleContent.trim(),
        categoryId: this.categories[this.selectedCategoryIndex].id,
        categoryName: this.categories[this.selectedCategoryIndex].name,
        author: '当前用户',
        coverImage: ''
      };

      console.info('发布文章请求:', JSON.stringify(postData));
      const response: BaseResponse<Object> = await HttpUtil.post<Object>(ApiConstants.ARTICLE_ADD, postData);
      console.info('发布文章响应:', JSON.stringify(response));

      if (response.success) {
        this.clearDraft();
        ToastUtil.showSuccess('发布成功！');
        setTimeout(() => {
          router.back();
        }, 1000);
      } else {
        const errorMsg = response.message || '发布失败，请重试';
        console.error('发布失败:', errorMsg, '响应码:', response.code);
        ToastUtil.showSuccess(errorMsg);
      }
    } catch (e) {
      console.error('发布文章异常:', e);
      const error = e as Error;
      let errorMsg = '网络异常，请检查连接';
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
      this.isPublishing = false;
    }
  }

  async clearDraft(): Promise<void> {
    try {
      const predicates = new relationalStore.RdbPredicates(TABLE_ARTICLE_DRAFT);
      await RdbHelper.delete(predicates);
    } catch (e) {
      console.error('清除草稿失败:', e);
    }
  }

  handleBackWithSaveCheck(): void {
    if (this.articleTitle.trim().length > 0 || this.articleContent.trim().length > 0) {
      this.showSaveDraftConfirm = true;
    } else {
      router.back();
    }
  }

  confirmLeaveWithoutSaving(): void {
    this.showSaveDraftConfirm = false;
    router.back();
  }

  async confirmSaveAndLeave(): Promise<void> {
    await this.saveDraft();
    this.showSaveDraftConfirm = false;
    router.back();
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
          .onClick(() => this.handleBackWithSaveCheck())

        Text('发布文章')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Button(this.isPublishing ? '发布中...' : '发布')
          .fontSize(14)
          .fontColor('#FFFFFF')
          .backgroundColor(this.isPublishing ? '#CCCCCC' : '#1677FF')
          .borderRadius(16)
          .height(36)
          .enabled(!this.isPublishing)
          .onClick(() => this.publishArticle())
      }
      .width('100%')
      .height(56)
      .backgroundColor('#FFFFFF')
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.Center)

      Scroll() {
        Column({ space: this.isElderMode ? 20 : 16 }) {
          Column({ space: 12 }) {
            Text('文章标题')
              .fontSize(this.isElderMode ? 16 : 14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#666666')
              .width('100%')

            TextInput({
              placeholder: '请输入文章标题（5-50字）',
              text: this.articleTitle
            })
              .width('100%')
              .height(48)
              .fontSize(this.isElderMode ? 18 : 16)
              .backgroundColor('#F8F9FA')
              .borderRadius(10)
              .padding({ left: 16, right: 16 })
              .maxLength(50)
              .onChange((value: string) => {
                this.articleTitle = value;
              })

            Text((this.articleTitle.length.toString()) + '/50')
              .fontSize(12)
              .fontColor(this.articleTitle.length > 45 ? '#E74C3C' : '#999999')
              .alignSelf(ItemAlign.End)
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .border({ width: 1, color: '#F0F0F0' })

          Column({ space: 12 }) {
            Text('选择分类')
              .fontSize(this.isElderMode ? 16 : 14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#666666')
              .width('100%')

            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.categories, (category: CategoryOption, index: number) => {
                Text(category.name)
                  .fontSize(this.isElderMode ? 15 : 13)
                  .fontColor(this.selectedCategoryIndex === index ? '#1677FF' : '#666666')
                  .padding({ left: 18, right: 18, top: 10, bottom: 10 })
                  .backgroundColor(this.selectedCategoryIndex === index ? '#E6F4FF' : '#F5F7FA')
                  .borderRadius(20)
                  .border({
                    width: 1,
                    color: this.selectedCategoryIndex === index ? '#1677FF' : '#EEEEEE'
                  })
                  .onClick(() => {
                    this.selectedCategoryIndex = index;
                  })
              }, (category: CategoryOption) => category.id.toString())
            }
            .width('100%')
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .border({ width: 1, color: '#F0F0F0' })

          Column({ space: 12 }) {
            Row() {
              Text('文章内容')
                .fontSize(this.isElderMode ? 16 : 14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#666666')

              Blank()

              Text(this.articleContent.length + ' 字')
                .fontSize(12)
                .fontColor('#999999')
            }
            .width('100%')

            TextArea({
              placeholder: '请输入文章内容，支持 Markdown 格式\n\n提示：\n- # 标题\n- **加粗**\n- 列表项',
              text: this.articleContent
            })
              .width('100%')
              .height(350)
              .fontSize(this.isElderMode ? 17 : 15)
              .backgroundColor('#F8F9FA')
              .borderRadius(10)
              .padding({ left: 16, right: 16, top: 12, bottom: 12 })
              .onChange((value: string) => {
                this.articleContent = value;
              })

            Text('支持 Markdown 格式，内容不少于 20 字')
              .fontSize(12)
              .fontColor('#BBBBBB')

            Row({ space: 12 }) {
              Button('💾 保存草稿')
                .layoutWeight(1)
                .height(42)
                .fontSize(14)
                .fontColor('#1677FF')
                .backgroundColor('#E6F4FF')
                .borderRadius(10)
                .onClick(() => this.saveDraft())

              Button('🗑️ 清空草稿')
                .layoutWeight(1)
                .height(42)
                .fontSize(14)
                .fontColor('#E74C3C')
                .backgroundColor('#FEF2F2')
                .borderRadius(10)
                .onClick(async () => {
                  await this.clearDraft();
                  this.articleTitle = '';
                  this.articleContent = '';
                  this.selectedCategoryIndex = 0;
                  ToastUtil.showSuccess('草稿已清空');
                })
            }
            .width('100%')
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .border({ width: 1, color: '#F0F0F0' })

          Column({ space: 12 }) {
            Text('📝 发布须知')
              .fontSize(this.isElderMode ? 16 : 14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#666666')
              .width('100%')

            ForEach([
              '标题需在 5-50 个字符之间',
              '正文内容不少于 20 个字符',
              '请确保内容健康、积极向上',
              '禁止发布虚假医疗信息或广告',
              '发布后可在"我的"页面管理已发布的文章'
            ], (tip: string) => {
              Row({ space: 8 }) {
                Text('•')
                  .fontSize(14)
                  .fontColor('#1677FF')
                Text(tip)
                  .fontSize(this.isElderMode ? 14 : 13)
                  .fontColor('#888888')
              }
              .width('100%')
            }, (tip: string) => tip.substring(0, 10))
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFBEA')
          .borderRadius(12)
          .border({ width: 1, color: '#FFE58F' })
        }
        .width('85%')
        .padding({ top: 16, bottom: 32 });
      }
      .height(0)
      .layoutWeight(1)
      .scrollBar(BarState.Auto)

      if (this.showSaveDraftConfirm) {
        Column() {
          Blank()
          Column({ space: 20 }) {
            Text('💡 提示')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')

            Text('您有未保存的内容，是否保存为草稿？')
              .fontSize(15)
              .fontColor('#666666')
              .textAlign(TextAlign.Center)

            Row({ space: 16 }) {
              Button('不保存')
                .layoutWeight(1)
                .height(44)
                .fontSize(15)
                .fontColor('#666666')
                .backgroundColor('#F5F7FA')
                .borderRadius(10)
                .onClick(() => this.confirmLeaveWithoutSaving())

              Button('保存草稿')
                .layoutWeight(1)
                .height(44)
                .fontSize(15)
                .fontColor('#FFFFFF')
                .backgroundColor('#1677FF')
                .borderRadius(10)
                .onClick(() => this.confirmSaveAndLeave())
            }
            .width('100%')
          }
          .width('85%')
          .padding(24)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .shadow({ radius: 20, color: '#00000022', offsetX: 0, offsetY: 4 })
          Blank()
        }
        .width('100%')
        .height('100%')
        .position({ x: 0, y: 0 })
        .backgroundColor('#00000055')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }
}
