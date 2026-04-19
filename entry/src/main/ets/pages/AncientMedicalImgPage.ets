import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';

interface AncientImage {
  id: string;
  title: string;
  description: string;
  originalImage: string;
  restoredImage: string;
  status: 'pending' | 'processing' | 'completed' | 'failed';
  progress: number;
  uploadTime: string;
  restoreTime?: string;
  category: string;
}

const MOCK_IMAGES: AncientImage[] = [
  {
    id: '1',
    title: '《黄帝内经》残页',
    description: '明代抄本，部分文字模糊不清，需要AI复原',
    originalImage: '',
    restoredImage: '',
    status: 'completed',
    progress: 100,
    uploadTime: '2026-04-08 10:30',
    restoreTime: '2026-04-08 10:35',
    category: '中医典籍'
  } as AncientImage,
  {
    id: '2',
    title: '《伤寒论》手稿',
    description: '清代医家批注本，字迹褪色严重',
    originalImage: '',
    restoredImage: '',
    status: 'processing',
    progress: 65,
    uploadTime: '2026-04-10 14:20',
    category: '中医典籍'
  } as AncientImage,
  {
    id: '3',
    title: '针灸穴位图',
    description: '宋代铜人穴位图拓片，线条断裂',
    originalImage: '',
    restoredImage: '',
    status: 'pending',
    progress: 0,
    uploadTime: '2026-04-12 09:15',
    category: '针灸图谱'
  } as AncientImage,
  {
    id: '4',
    title: '本草纲目插图',
    description: '植物手绘图，色彩需要还原',
    originalImage: '',
    restoredImage: '',
    status: 'completed',
    progress: 100,
    uploadTime: '2026-04-05 16:45',
    restoreTime: '2026-04-05 16:50',
    category: '本草图谱'
  } as AncientImage
];

const CATEGORY_OPTIONS: string[] = ['全部', '中医典籍', '针灸图谱', '本草图谱', '方剂配图'];

@Entry
@Component
struct AncientMedicalImgPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State images: AncientImage[] = [...MOCK_IMAGES];
  @State currentCategory: string = '全部';
  @State showUploadDialog: boolean = false;
  @State showCompareDialog: boolean = false;
  @State selectedImage: AncientImage | null = null;
  @State newTitle: string = '';
  @State newDescription: string = '';
  @State newCategory: string = '中医典籍';
  @State compareSliderPosition: number = 0.5;

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') ?? false;
    }
  }

  getFilteredImages(): AncientImage[] {
    if (this.currentCategory === '全部') {
      return this.images;
    }
    return this.images.filter((img: AncientImage) => img.category === this.currentCategory);
  }

  getStatusIcon(status: string): string {
    switch (status) {
      case 'pending': return '⏳';
      case 'processing': return '🔄';
      case 'completed': return '✅';
      case 'failed': return '❌';
      default: return '❓';
    }
  }

  getStatusText(status: string): string {
    switch (status) {
      case 'pending': return '等待处理';
      case 'processing': return '复原中...';
      case 'completed': return '已完成';
      case 'failed': return '复原失败';
      default: return '未知';
    }
  }

  getStatusColor(status: string): string {
    switch (status) {
      case 'pending': return '#FAAD14';
      case 'processing': return '#1677FF';
      case 'completed': return '#52C41A';
      case 'failed': return '#FF4D4F';
      default: return '#999999';
    }
  }

  getCategoryColor(category: string): string {
    const colorMap: Record<string, string> = {
      '中医典籍': '#722ED1',
      '针灸图谱': '#13C2C2',
      '本草图谱': '#52C41A',
      '方剂配图': '#FA8C16'
    };
    return colorMap[category] || '#999999';
  }

  openUploadDialog(): void {
    this.newTitle = '';
    this.newDescription = '';
    this.newCategory = '中医典籍';
    this.showUploadDialog = true;
  }

  simulateUpload(): void {
    if (!this.newTitle.trim()) {
      ToastUtil.showInfo('请输入图片标题');
      return;
    }

    const newImage: AncientImage = {
      id: `${Date.now()}`,
      title: this.newTitle,
      description: this.newDescription || '暂无描述',
      originalImage: '',
      restoredImage: '',
      status: 'pending',
      progress: 0,
      uploadTime: new Date().toLocaleString(),
      category: this.newCategory
    };

    this.images.unshift(newImage);
    this.showUploadDialog = false;
    ToastUtil.operationSuccess('图片已上传，等待AI复原');

    setTimeout(() => {
      newImage.status = 'processing';
      newImage.progress = 30;
    }, 1000);

    setTimeout(() => {
      newImage.progress = 60;
    }, 2000);

    setTimeout(() => {
      newImage.progress = 90;
    }, 3000);

    setTimeout(() => {
      newImage.status = 'completed';
      newImage.progress = 100;
      newImage.restoreTime = new Date().toLocaleString();
      ToastUtil.operationSuccess(`${newImage.title} 复原完成！`);
    }, 4000);
  }

  triggerRestore(image: AncientImage): void {
    if (image.status === 'processing') {
      ToastUtil.showInfo('正在复原中，请稍候...');
      return;
    }
    if (image.status === 'completed') {
      ToastUtil.showInfo('该图片已完成复原');
      return;
    }

    image.status = 'processing';
    image.progress = 20;
    ToastUtil.operationSuccess('开始AI复原...');

    const interval: number = setInterval(() => {
      if (image.progress < 90) {
        image.progress += 10;
      } else {
        clearInterval(interval);
        image.status = 'completed';
        image.progress = 100;
        image.restoreTime = new Date().toLocaleString();
        ToastUtil.operationSuccess(`${image.title} 复原完成！`);
      }
    }, 500);
  }

  openCompare(image: AncientImage): void {
    if (image.status !== 'completed') {
      ToastUtil.showInfo('请等待复原完成后查看对比');
      return;
    }
    this.selectedImage = image;
    this.compareSliderPosition = 0.5;
    this.showCompareDialog = true;
  }

  shareResult(image: AncientImage): void {
    promptAction.showDialog({
      title: '分享复原成果',
      message: `分享「${image.title}」的复原结果`,
      buttons: [{ text: '复制链接', color: '#1677FF' }, { text: '保存图片', color: '#1677FF' }, { text: '取消', color: '#999999' }]
    }).then((result: promptAction.ShowDialogSuccessResponse) => {
      if (result.index === 0) {
        ToastUtil.operationSuccess('链接已复制到剪贴板');
      } else if (result.index === 1) {
        ToastUtil.operationSuccess('图片已保存到相册');
      }
    }).catch((error: Error) => {
      console.error('显示分享对话框失败:', error.message);
    });
  }

  deleteImage(image: AncientImage): void {
    promptAction.showDialog({
      title: '删除图片',
      message: `确定要删除「${image.title}」吗？此操作不可恢复。`,
      buttons: [{ text: '取消', color: '#999999' }, { text: '删除', color: '#FF4D4F' }]
    }).then((result: promptAction.ShowDialogSuccessResponse) => {
      if (result.index === 1) {
        const index: number = this.images.findIndex((img: AncientImage) => img.id === image.id);
        if (index > -1) {
          this.images.splice(index, 1);
          ToastUtil.operationSuccess('已删除');
        }
      }
    });
  }

  build() {
    Stack() {
      Column() {
        Header({ title: '古医图管理', showBack: true });

        Scroll() {
          Column({ space: 16 }) {

            Row({ space: 12 }) {
              Text('📚 古医图库')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .layoutWeight(1);

              Text(`${this.images.length} 张`)
                .fontSize(12)
                .fontColor('#1677FF')
                .backgroundColor('#E6F7FF')
                .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                .borderRadius(12);

              Button('+ 上传')
                .height(32)
                .fontSize(12)
                .fontColor('#FFFFFF')
                .backgroundColor('#1677FF')
                .borderRadius(16)
                .onClick(() => this.openUploadDialog());
            }
            .width('100%');

            Scroll() {
              Row({ space: 10 }) {
                ForEach(CATEGORY_OPTIONS, (category: string) => {
                  Text(category)
                    .fontSize(13)
                    .fontColor(this.currentCategory === category ? '#FFFFFF' : '#666666')
                    .backgroundColor(this.currentCategory === category ? '#722ED1' : '#F5F5F5')
                    .padding({ left: 14, right: 14, top: 7, bottom: 7 })
                    .borderRadius(16)
                    .onClick(() => {
                      this.currentCategory = category;
                    });
                }, (category: string) => category);
              }
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .width('100%');

            if (this.getFilteredImages().length === 0) {
              Column({ space: 16 }) {
                Text('📜')
                  .fontSize(64);

                Text('暂无图片')
                  .fontSize(16)
                  .fontColor('#666666');

                Text('点击"上传"按钮添加古医图片')
                  .fontSize(13)
                  .fontColor('#999999');
              }
              .width('100%')
              .height(300)
              .justifyContent(FlexAlign.Center);
            } else {
              ForEach(this.getFilteredImages(), (image: AncientImage) => {
                this.buildImageCard(image);
              }, (image: AncientImage) => image.id);
            }
          }
          .width('85%')
          .padding({ top: 16, bottom: 100 });
        }
        .height(0)
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top);

        Footer({ activeIndex: 4 });
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F7FA');

      if (this.showUploadDialog) {
        this.buildUploadDialog();
      }

      if (this.showCompareDialog && this.selectedImage) {
        this.buildCompareDialog();
      }
    }
    .width('100%')
    .height('100%');
  }

  @Builder
  buildImageCard(image: AncientImage) {
    Column({ space: 12 }) {
      Stack({ alignContent: Alignment.TopEnd }) {
        Column()
          .width('100%')
          .height(180)
          .linearGradient({
            angle: 135,
            colors: [['#F9F0FF', 0], ['#E6F7FF', 1]]
          })
          .borderRadius({ topLeft: 12, topRight: 12 })
          .justifyContent(FlexAlign.Center);

        Column() {
          Text('📜')
            .fontSize(48);

          Text(image.category)
            .fontSize(11)
            .fontColor('#FFFFFF')
            .backgroundColor(this.getCategoryColor(image.category))
            .padding({ left: 8, right: 8, top: 3, bottom: 3 })
            .borderRadius(8)
            .margin({ top: 8 });
        }

        Row({ space: 6 }) {
          Text(this.getStatusIcon(image.status))
            .fontSize(14);

          Text(this.getStatusText(image.status))
            .fontSize(11)
            .fontColor(this.getStatusColor(image.status))
            .fontWeight(FontWeight.Medium)
            .backgroundColor(this.getStatusColor(image.status) + '15')
            .padding({ left: 8, right: 8, top: 3, bottom: 3 })
            .borderRadius(10);
        }
        .margin({ top: 10, right: 10 });
      }

      Column({ space: 8 }) {
        Text(image.title)
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis });

        Text(image.description)
          .fontSize(12)
          .fontColor('#666666')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .lineHeight(18);

        if (image.status === 'processing') {
          Column({ space: 6 }) {
            Row() {
              Text(`复原进度 ${image.progress}%`)
                .fontSize(11)
                .fontColor('#1677FF')
                .layoutWeight(1);

              Text(`${image.progress}%`)
                .fontSize(11)
                .fontColor('#1677FF')
                .fontWeight(FontWeight.Bold);
            }
            .width('100%');

            Progress({ value: image.progress, total: 100, type: ProgressType.Linear })
              .width('100%')
              .height(6)
              .color('#1677FF')
              .backgroundColor('#E6F7FF')
              .borderRadius(3);
          }
          .width('100%');
        }

        Row({ space: 8 }) {
          Text(`📅 ${image.uploadTime}`)
            .fontSize(10)
            .fontColor('#999999')
            .layoutWeight(1);

          if (image.restoreTime) {
            Text(`✨ ${image.restoreTime}`)
              .fontSize(10)
              .fontColor('#52C41A');
          }
        }
        .width('100%');

        Row({ space: 8 }) {
          if (image.status === 'pending' || image.status === 'failed') {
            Button('开始复原')
              .layoutWeight(1)
              .height(32)
              .fontSize(12)
              .fontColor('#FFFFFF')
              .backgroundColor('#722ED1')
              .borderRadius(16)
              .onClick(() => this.triggerRestore(image));
          }

          if (image.status === 'completed') {
            Button('对比查看')
              .layoutWeight(1)
              .height(32)
              .fontSize(12)
              .fontColor('#722ED1')
              .backgroundColor('#F9F0FF')
              .borderRadius(16)
              .onClick(() => this.openCompare(image));

            Button('分享')
              .layoutWeight(1)
              .height(32)
              .fontSize(12)
              .fontColor('#FFFFFF')
              .backgroundColor('#52C41A')
              .borderRadius(16)
              .onClick(() => this.shareResult(image));
          }

          Button('删除')
            .height(32)
            .fontSize(12)
            .fontColor('#FF4D4F')
            .backgroundColor('#FFF1F0')
            .borderRadius(16)
            .onClick(() => this.deleteImage(image));
        }
        .width('100%');
      }
      .width('100%')
      .padding(12)
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 2 });
  }

  @Builder
  buildUploadDialog() {
    Column() {
      Blank();

      Column({ space: 20 }) {
        Row() {
          Text('上传古医图片')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .layoutWeight(1);

          Text('✕')
            .fontSize(22)
            .fontColor('#999999')
            .onClick(() => {
              this.showUploadDialog = false;
            });
        }
        .width('100%');

        Column({ space: 24 }) {
          Column()
            .width('100%')
            .height(160)
            .border({ width: 2, style: BorderStyle.Dashed, color: '#D9D9D9' })
            .borderRadius(12)
            .justifyContent(FlexAlign.Center)
            .backgroundColor('#FAFAFA')
            .onClick(() => {
              ToastUtil.showInfo('选择图片来源：拍照或相册');
            });

          Column({ space: 4 }) {
            Text('点击选择图片')
              .fontSize(14)
              .fontColor('#666666');

            Text('支持 JPG、PNG 格式，最大 10MB')
              .fontSize(11)
              .fontColor('#999999');
          }
        }

        TextInput({ placeholder: '输入图片标题（如：本草纲目插图）', text: this.newTitle })
          .width('100%')
          .height(44)
          .fontSize(14)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .onChange((value: string) => {
            this.newTitle = value;
          });

        TextArea({ placeholder: '输入图片描述（可选）', text: this.newDescription })
          .width('100%')
          .height(80)
          .fontSize(13)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .onChange((value: string) => {
            this.newDescription = value;
          });

        Column({ space: 8 }) {
          Text('分类 *')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .width('100%');

          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(['中医典籍', '针灸图谱', '本草图谱', '方剂配图'], (cat: string) => {
              Text(cat)
                .fontSize(12)
                .fontColor(this.newCategory === cat ? '#FFFFFF' : '#666666')
                .backgroundColor(this.newCategory === cat ? '#722ED1' : '#F5F5F5')
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .borderRadius(14)
                .margin(4)
                .onClick(() => {
                  this.newCategory = cat;
                });
            }, (cat: string) => cat);
          }
          .width('100%');
        }
        .width('100%');

        Row({ space: 12 }) {
          Button('取消')
            .layoutWeight(1)
            .height(44)
            .fontSize(15)
            .fontColor('#666666')
            .backgroundColor('#F5F5F5')
            .borderRadius(22)
            .onClick(() => {
              this.showUploadDialog = false;
            });

          Button('上传并复原')
            .layoutWeight(1)
            .height(44)
            .fontSize(15)
            .fontColor('#FFFFFF')
            .backgroundColor('#722ED1')
            .borderRadius(22)
            .onClick(() => this.simulateUpload());
        }
        .width('100%');
      }
      .width('90%')
      .padding(20)
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
      .shadow({ radius: 20, color: '#00000030', offsetX: 0, offsetY: 10 });

      Blank();
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#00000060')
    .justifyContent(FlexAlign.Center);
  }

  @Builder
  buildCompareDialog() {
    Column() {
      Blank();

      Column({ space: 16 }) {
        Row() {
          Text('🔍 复原结果对比')
            .fontSize(17)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .layoutWeight(1);

          Text('✕')
            .fontSize(22)
            .fontColor('#999999')
            .onClick(() => {
              this.showCompareDialog = false;
            });
        }
        .width('100%');

        Text(this.selectedImage?.title ?? '')
          .fontSize(14)
          .fontColor('#666666')
          .width('100%');

        Column()
          .width('100%')
          .height(300)
          .borderRadius(12)
          .linearGradient({
            angle: 135,
            colors: [['#FFF7F7', 0], ['#F6FFED', 1]]
          })
          .justifyContent(FlexAlign.Center);

        Row({ space: 24 }) {
          Column({ space: 6 }) {
            Text('原图')
              .fontSize(12)
              .fontColor('#FF4D4F')
              .fontWeight(FontWeight.Medium);

            Column()
              .width(60)
              .height(60)
              .backgroundColor('#FFF7F7')
              .borderRadius(8)
              .border({ width: 1, color: '#FFCCC7' })
              .justifyContent(FlexAlign.Center)
              .clip(true);

            Text('模糊/破损')
              .fontSize(10)
              .fontColor('#999999');
          }

          Text('→')
            .fontSize(24)
            .fontColor('#52C41A');

          Column({ space: 6 }) {
            Text('复原图')
              .fontSize(12)
              .fontColor('#52C41A')
              .fontWeight(FontWeight.Medium);

            Column()
              .width(60)
              .height(60)
              .backgroundColor('#F6FFED')
              .borderRadius(8)
              .border({ width: 1, color:'#B7EB8F' })
              .justifyContent(FlexAlign.Center)
              .clip(true);

            Text('清晰完整')
              .fontSize(10)
              .fontColor('#999999');
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.Center);

        Row({ space: 12 }) {
          Button('💾 保存复原图')
            .layoutWeight(1)
            .height(42)
            .fontSize(14)
            .fontColor('#FFFFFF')
            .backgroundColor('#52C41A')
            .borderRadius(21)
            .onClick(() => {
              ToastUtil.operationSuccess('复原图已保存');
            });

          Button('📤 分享成果')
            .layoutWeight(1)
            .height(42)
            .fontSize(14)
            .fontColor('#722ED1')
            .backgroundColor('#F9F0FF')
            .borderRadius(21)
            .onClick(() => {
              if (this.selectedImage) {
                this.shareResult(this.selectedImage);
              }
            });
        }
        .width('100%');
      }
      .width('92%')
      .padding(20)
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
      .shadow({ radius: 20, color: '#00000030', offsetX: 0, offsetY: 10 });

      Blank();
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#00000060')
    .justifyContent(FlexAlign.Center);
  }
}