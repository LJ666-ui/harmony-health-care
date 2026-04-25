/**
 * 图像复原主页面
 * 
 * 提供古医图AI复原的完整交互功能：
 * - 图片列表展示
 * - 分类筛选
 * - 图片上传
 * - 处理进度显示
 * - 对比查看
 * 
 * @version 1.0
 * @date 2025-01-20
 */

import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import BrowseTracker from '../utils/BrowseTracker';
import {
  AncientImage,
  ImageStatus,
  ImageCategory,
  ProcessingStage,
  ProcessingProgress
} from '../models/AncientImageModels';
import { ImageRestorationEngine } from '../ancientimage/ImageRestorationEngine';

const CATEGORY_OPTIONS: string[] = ['全部', '中医典籍', '针灸图谱', '本草图谱', '方剂配图'];

@Entry
@Component
struct ImageRestorationPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  // 页面状态
  @State images: AncientImage[] = [];
  @State currentCategory: string = '全部';
  @State showUploadDialog: boolean = false;
  @State showCompareDialog: boolean = false;
  @State selectedImage: AncientImage | null = null;
  @State isLoading: boolean = false;
  @State currentPage: number = 1;
  @State totalImages: number = 0;
  @State recordId: number = 0;

  // 上传相关
  @State newTitle: string = '';
  @State newDescription: string = '';
  @State newCategory: string = '中医典籍';
  @State isUploading: boolean = false;
  @State uploadProgress: number = 0;

  // 处理相关
  @State isProcessing: boolean = false;
  @State processingProgress: number = 0;
  @State currentStage: ProcessingStage = ProcessingStage.PREPROCESSING;
  @State processingImageId: number = 0;

  // 对比相关
  @State compareSliderPosition: number = 0.5;

  private scroller: Scroller = new Scroller();
  private restorationEngine: ImageRestorationEngine = ImageRestorationEngine.getInstance();

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      const elderMode = AppStorage.get<boolean>('isOldModeEnabled');
      this.isElderMode = elderMode ? elderMode : false;
    }
    this.loadImageList();
    BrowseTracker.recordStart('IMAGE_RESTORATION', 'PAGE', 7, '古医图复原').then((id: number) => {
      this.recordId = id;
    });
  }

  aboutToDisappear(): void {
    if (this.recordId > 0) {
      BrowseTracker.recordEnd(this.recordId);
    }
  }

  // 加载图片列表
  async loadImageList(): Promise<void> {
    this.isLoading = true;
    try {
      const url: string = ApiConstants.ANCIENT_IMAGE_LIST + '?page=' + this.currentPage + '&size=20';
      const response: BaseResponse<Record<string, Object>> = await HttpUtil.get<Record<string, Object>>(url);

      if (response.success && response.data) {
        const dataObj: Record<string, Object> = response.data;
        let records: Object[] = [];
        if (dataObj['records'] && Array.isArray(dataObj['records'])) {
          records = dataObj['records'] as Object[];
        }
        let total = 0;
        if (dataObj['total']) {
          total = dataObj['total'] as number;
        }

        this.totalImages = total;
        this.images = [];

        for (let i = 0; i < records.length; i++) {
          const record: Record<string, Object> = records[i] as Record<string, Object>;
          const item: AncientImage = {
            id: record['id'] as number || 0,
            title: record['title'] as string || '未命名图片',
            description: record['desc'] as string || '',
            category: this.parseCategory(record['category'] as string),
            status: this.parseStatus(record['status'] as string),
            originalUrl: record['originalUrl'] as string || '',
            restoredUrl: record['restoreUrl'] as string || '',
            thumbnailUrl: record['thumbnailUrl'] as string || '',
            metadata: {
              width: record['width'] as number || 1200,
              height: record['height'] as number || 1600,
              format: 'PNG',
              fileSize: record['fileSize'] as number || 0
            },
            progress: record['progress'] as number || 0,
            createdAt: new Date(record['createTime'] as string || '').getTime(),
            updatedAt: new Date(record['updateTime'] as string || '').getTime()
          };
          this.images.push(item);
        }
      }
    } catch (error) {
      ToastUtil.showError('加载图片列表失败');
      console.error('加载图片列表失败:', error);
    } finally {
      this.isLoading = false;
    }
  }

  // 解析分类
  private parseCategory(category: string): ImageCategory {
    switch (category) {
      case 'CLASSICS':
        return ImageCategory.CLASSICS;
      case 'ACUPUNCTURE':
        return ImageCategory.ACUPUNCTURE;
      case 'HERBAL':
        return ImageCategory.HERBAL;
      case 'PRESCRIPTION':
        return ImageCategory.PRESCRIPTION;
      default:
        return ImageCategory.CLASSICS;
    }
  }

  // 解析状态
  private parseStatus(status: string): ImageStatus {
    switch (status) {
      case 'PENDING':
        return ImageStatus.PENDING;
      case 'PROCESSING':
        return ImageStatus.PROCESSING;
      case 'COMPLETED':
        return ImageStatus.COMPLETED;
      case 'FAILED':
        return ImageStatus.FAILED;
      default:
        return ImageStatus.PENDING;
    }
  }

  // 开始复原处理
  async startRestoration(image: AncientImage): Promise<void> {
    this.isProcessing = true;
    this.processingImageId = image.id;
    this.processingProgress = 0;
    this.currentStage = ProcessingStage.PREPROCESSING;

    try {
      const result = await this.restorationEngine.processImage(
        image.id,
        image.originalUrl,
        undefined,
        (progress: ProcessingProgress) => {
          this.processingProgress = progress.progress;
          this.currentStage = progress.currentStage;
        }
      );

      if (result.success) {
        ToastUtil.showSuccess('复原完成');
        // 刷新列表
        await this.loadImageList();
      } else {
        ToastUtil.showError('复原失败: ' + (result.error?.message || '未知错误'));
      }
    } catch (error) {
      ToastUtil.showError('复原过程出错');
      console.error('复原过程出错:', error);
    } finally {
      this.isProcessing = false;
      this.processingImageId = 0;
    }
  }

  // 删除图片
  async deleteImage(image: AncientImage): Promise<void> {
    try {
      const url = ApiConstants.ANCIENT_IMAGE_DELETE + '?id=' + image.id;
      const response = await HttpUtil.delete<null>(url);

      if (response.success) {
        ToastUtil.showSuccess('删除成功');
        await this.loadImageList();
      } else {
        ToastUtil.showError('删除失败');
      }
    } catch (error) {
      ToastUtil.showError('删除失败');
      console.error('删除失败:', error);
    }
  }

  // 获取状态徽章颜色
  private getStatusColor(status: ImageStatus): string {
    switch (status) {
      case ImageStatus.PENDING:
        return '#FAAD14'; // 黄色
      case ImageStatus.PROCESSING:
        return '#1890FF'; // 蓝色
      case ImageStatus.COMPLETED:
        return '#52C41A'; // 绿色
      case ImageStatus.FAILED:
        return '#FF4D4F'; // 红色
      default:
        return '#8C8C8C';
    }
  }

  // 获取状态文本
  private getStatusText(status: ImageStatus): string {
    switch (status) {
      case ImageStatus.PENDING:
        return '等待处理';
      case ImageStatus.PROCESSING:
        return '处理中';
      case ImageStatus.COMPLETED:
        return '已完成';
      case ImageStatus.FAILED:
        return '处理失败';
      default:
        return '未知';
    }
  }

  // 获取阶段文本
  private getStageText(stage: ProcessingStage): string {
    switch (stage) {
      case ProcessingStage.PREPROCESSING:
        return '预处理';
      case ProcessingStage.DENOISING:
        return '降噪';
      case ProcessingStage.DEBLURRING:
        return '去模糊';
      case ProcessingStage.SUPER_RESOLUTION:
        return '超分辨率';
      case ProcessingStage.COLOR_RESTORATION:
        return '颜色恢复';
      case ProcessingStage.DETAIL_ENHANCEMENT:
        return '细节增强';
      case ProcessingStage.OCR_RECOGNITION:
        return 'OCR识别';
      case ProcessingStage.ANNOTATION:
        return '智能标注';
      default:
        return '未知阶段';
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      Header({ title: '古医图智能复原' })

      // 分类筛选
      Row() {
        ForEach(CATEGORY_OPTIONS, (category: string) => {
          Text(category)
            .fontSize(this.isElderMode ? 18 : 14)
            .fontColor(this.currentCategory === category ? '#1890FF' : '#595959')
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .borderRadius(16)
            .backgroundColor(this.currentCategory === category ? '#E6F7FF' : '#F5F5F5')
            .onClick(() => {
              this.currentCategory = category;
              this.loadImageList();
            })
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .justifyContent(FlexAlign.Start)

      // 图片列表
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(48)
            .height(48)
            .color('#1890FF')
          Text('加载中...')
            .fontSize(14)
            .fontColor('#8C8C8C')
            .margin({ top: 12 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else if (this.images.length === 0) {
        Column() {
          Text('暂无图片')
            .fontSize(16)
            .fontColor('#8C8C8C')
          Text('点击右下角按钮上传图片')
            .fontSize(14)
            .fontColor('#BFBFBF')
            .margin({ top: 8 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        List({ scroller: this.scroller }) {
          ForEach(this.images, (image: AncientImage) => {
            ListItem() {
              this.ImageCard(image)
            }
            .margin({ bottom: 12 })
          })
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16 })
        .divider({ strokeWidth: 0 })
      }

      // 上传按钮
      Button('上传图片')
        .width('90%')
        .height(this.isElderMode ? 56 : 48)
        .fontSize(this.isElderMode ? 18 : 16)
        .fontColor('#FFFFFF')
        .backgroundColor('#1890FF')
        .borderRadius(24)
        .margin({ bottom: 16 })
        .onClick(() => {
          this.showUploadDialog = true;
        })

      // 底部导航
      Footer({ activeIndex: 7 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
    .bindSheet($$this.showUploadDialog, this.UploadSheet(), {
      height: 400,
      backgroundColor: Color.White,
      dragBar: true
    } as SheetOptions)
    .bindSheet($$this.showCompareDialog, this.CompareSheet(), {
      height: 500,
      backgroundColor: Color.White,
      dragBar: true
    } as SheetOptions)
  }

  // 图片卡片组件
  @Builder
  ImageCard(image: AncientImage) {
    Column() {
      // 图片预览
      Stack() {
        Image(image.thumbnailUrl || image.originalUrl)
          .width('100%')
          .height(200)
          .objectFit(ImageFit.Cover)
          .borderRadius({ topLeft: 8, topRight: 8 })

        // 状态徽章
        Text(this.getStatusText(image.status))
          .fontSize(12)
          .fontColor('#FFFFFF')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .borderRadius(4)
          .backgroundColor(this.getStatusColor(image.status))
          .position({ x: 8, y: 8 })

        // 处理进度
        if (image.status === ImageStatus.PROCESSING || this.processingImageId === image.id) {
          Column() {
            Progress({ value: this.processingImageId === image.id ? this.processingProgress : (image.progress || 0), total: 100, type: ProgressType.Linear })
              .width('80%')
              .color('#1890FF')
            Text(this.processingImageId === image.id ? this.getStageText(this.currentStage) : '处理中')
              .fontSize(12)
              .fontColor('#FFFFFF')
              .margin({ top: 4 })
          }
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0, 0, 0, 0.5)')
          .justifyContent(FlexAlign.Center)
          .borderRadius({ topLeft: 8, topRight: 8 })
        }
      }
      .width('100%')
      .height(200)

      // 图片信息
      Column() {
        Text(image.title)
          .fontSize(this.isElderMode ? 18 : 16)
          .fontColor('#262626')
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        if (image.description) {
          Text(image.description)
            .fontSize(this.isElderMode ? 16 : 14)
            .fontColor('#8C8C8C')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ top: 4 })
        }

        // 操作按钮
        Row() {
          if (image.status === ImageStatus.PENDING) {
            Button('开始复原')
              .fontSize(14)
              .fontColor('#FFFFFF')
              .backgroundColor('#52C41A')
              .height(32)
              .onClick(() => {
                this.startRestoration(image);
              })
          } else if (image.status === ImageStatus.COMPLETED) {
            Button('对比查看')
              .fontSize(14)
              .fontColor('#FFFFFF')
              .backgroundColor('#1890FF')
              .height(32)
              .onClick(() => {
                this.selectedImage = image;
                this.showCompareDialog = true;
              })
          }

          Blank()

          Button('删除')
            .fontSize(14)
            .fontColor('#FF4D4F')
            .backgroundColor('#FFF1F0')
            .height(32)
            .onClick(() => {
              AlertDialog.show({
                title: '确认删除',
                message: '确定要删除这张图片吗？',
                primaryButton: {
                  value: '取消',
                  action: () => {}
                },
                secondaryButton: {
                  value: '删除',
                  fontColor: '#FF4D4F',
                  action: () => {
                    this.deleteImage(image);
                  }
                }
              });
            })
        }
        .width('100%')
        .margin({ top: 8 })
      }
      .width('100%')
      .padding(12)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(8)
    .shadow({ radius: 4, color: 'rgba(0, 0, 0, 0.1)', offsetX: 0, offsetY: 2 })
  }

  // 上传对话框
  @Builder
  UploadSheet() {
    Column() {
      Text('上传古医图')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 20 })

      // 标题输入
      TextInput({ placeholder: '请输入标题（必填）' })
        .width('90%')
        .height(this.isElderMode ? 56 : 48)
        .fontSize(this.isElderMode ? 18 : 16)
        .onChange((value: string) => {
          this.newTitle = value;
        })

      // 描述输入
      TextArea({ placeholder: '请输入描述（选填）' })
        .width('90%')
        .height(80)
        .fontSize(this.isElderMode ? 18 : 16)
        .margin({ top: 12 })
        .onChange((value: string) => {
          this.newDescription = value;
        })

      // 分类选择
      Row() {
        Text('分类：')
          .fontSize(this.isElderMode ? 18 : 16)
        ForEach(CATEGORY_OPTIONS.slice(1), (category: string) => {
          Radio({ value: category, group: 'categoryGroup' })
            .checked(this.newCategory === category)
            .onChange((isChecked: boolean) => {
              if (isChecked) {
                this.newCategory = category;
              }
            })
          Text(category)
            .fontSize(this.isElderMode ? 16 : 14)
            .margin({ left: 4, right: 12 })
        })
      }
      .width('90%')
      .margin({ top: 12 })

      // 上传按钮
      Button(this.isUploading ? '上传中...' : '上传')
        .width('90%')
        .height(this.isElderMode ? 56 : 48)
        .fontSize(this.isElderMode ? 18 : 16)
        .fontColor('#FFFFFF')
        .backgroundColor(this.newTitle ? '#1890FF' : '#BFBFBF')
        .enabled(!this.isUploading && !!this.newTitle)
        .margin({ top: 20 })
        .onClick(() => {
          // TODO: 实现图片上传功能
          ToastUtil.showInfo('图片上传功能开发中');
          this.showUploadDialog = false;
        })
    }
    .width('100%')
    .padding(16)
  }

  // 对比对话框
  @Builder
  CompareSheet() {
    Column() {
      Text('原图与复原图对比')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 16 })

      if (this.selectedImage) {
        Stack() {
          // 原图
          Image(this.selectedImage.originalUrl)
            .width('100%')
            .height(300)
            .objectFit(ImageFit.Contain)

          // 复原图（使用clip实现滑动对比）
          Image(this.selectedImage.restoredUrl)
            .width('100%')
            .height(300)
            .objectFit(ImageFit.Contain)
            .clip(new Rect({
              width: `${this.compareSliderPosition * 100}%`,
              height: '100%'
            }))

          // 分割线
          Column()
            .width(2)
            .height(300)
            .backgroundColor('#FFFFFF')
            .position({
              x: `${this.compareSliderPosition * 100}%`,
              y: 0
            })

          // 滑动手势区域
          Column()
            .width('100%')
            .height(300)
            .gesture(
              PanGesture()
                .onActionUpdate((event: GestureEvent) => {
                  const offsetX = event.offsetX;
                  const width = 300; // 实际应获取组件宽度
                  this.compareSliderPosition = Math.max(0, Math.min(1, this.compareSliderPosition + offsetX / width));
                })
            )
        }
        .width('100%')
        .height(300)
        .backgroundColor('#F5F5F5')
        .borderRadius(8)

        // 说明
        Row() {
          Text('原图')
            .fontSize(14)
            .fontColor('#8C8C8C')
          Blank()
          Text('复原图')
            .fontSize(14)
            .fontColor('#8C8C8C')
        }
        .width('100%')
        .margin({ top: 8 })

        // 下载按钮
        Button('下载复原图')
          .width('90%')
          .height(this.isElderMode ? 56 : 48)
          .fontSize(this.isElderMode ? 18 : 16)
          .fontColor('#FFFFFF')
          .backgroundColor('#52C41A')
          .margin({ top: 16 })
          .onClick(() => {
            ToastUtil.showInfo('下载功能开发中');
          })
      }
    }
    .width('100%')
    .padding(16)
  }
}
