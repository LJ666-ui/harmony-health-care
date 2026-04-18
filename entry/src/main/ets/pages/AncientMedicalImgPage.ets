import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import BrowseTracker from '../utils/BrowseTracker';

export interface AncientImageItem {
  id: number;
  originalUrl: string;
  restoreUrl: string;
  model3dUrl: string;
  title: string;
  desc: string;
  source: string;
  createTime: string;
  updateTime: string;
  isDeleted: number;
}

const CATEGORY_OPTIONS: string[] = ['全部', '中医典籍', '针灸图谱', '本草图谱', '方剂配图'];

@Entry
@Component
struct AncientMedicalImgPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State images: AncientImageItem[] = [];
  @State currentCategory: string = '全部';
  @State showUploadDialog: boolean = false;
  @State showCompareDialog: boolean = false;
  @State selectedImage: AncientImageItem | null = null;
  @State newTitle: string = '';
  @State newDescription: string = '';
  @State newCategory: string = '中医典籍';
  @State compareSliderPosition: number = 0.5;
  @State isLoading: boolean = false;
  @State isUploading: boolean = false;
  @State uploadProgress: number = 0;
  @State currentPage: number = 1;
  @State totalImages: number = 0;
  @State recordId: number = 0;

  private scroller: Scroller = new Scroller();

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') ?? false;
    }
    this.loadImageList();
    BrowseTracker.recordStart('ANCIENT_IMAGE', 'PAGE', 7, '古医图管理').then((id: number) => {
      this.recordId = id;
    });
  }

  aboutToDisappear(): void {
    if (this.recordId > 0) {
      BrowseTracker.recordEnd(this.recordId);
    }
  }

  async loadImageList(): Promise<void> {
    this.isLoading = true;
    try {
      const url: string = ApiConstants.ANCIENT_IMAGE_LIST + '?page=' + this.currentPage + '&size=20';
      const response: BaseResponse<Record<string, Object>> = await HttpUtil.get<Record<string, Object>>(url);

      if (response.success && response.data) {
        const dataObj: Record<string, Object> = response.data;
        const records: Object[] = dataObj['records'] as Object[] || [];
        const total: number = dataObj['total'] as number || 0;

        this.totalImages = total;
        this.images = [];

        for (let i = 0; i < records.length; i++) {
          const record: Record<string, Object> = records[i] as Record<string, Object>;
          const item: AncientImageItem = {
            id: record['id'] as number || 0,
            originalUrl: record['originalUrl'] as string || '',
            restoreUrl: record['restoreUrl'] as string || '',
            model3dUrl: record['model3dUrl'] as string || '',
            title: record['title'] as string || '未命名图片',
            desc: record['desc'] as string || '',
            source: record['source'] as string || '',
            createTime: record['createTime'] as string || '',
            updateTime: record['updateTime'] as string || '',
            isDeleted: record['isDeleted'] as number || 0
          };
          this.images.push(item);
        }
      }
    } catch (e) {
      console.error('加载古医图列表失败:', e);
      ToastUtil.showInfo('加载失败，请检查网络');
    } finally {
      this.isLoading = false;
    }
  }

  getFilteredImages(): AncientImageItem[] {
    if (this.currentCategory === '全部') {
      return this.images;
    }
    return this.images.filter((img: AncientImageItem) => {
      if (!img.desc) {
        return false;
      }
      return img.desc.indexOf(this.currentCategory) >= 0 || img.title.indexOf(this.currentCategory) >= 0;
    });
  }

  getStatusText(image: AncientImageItem): string {
    if (image.restoreUrl && image.restoreUrl.length > 0) {
      return '已完成';
    }
    return '等待复原';
  }

  getStatusColor(status: string): string {
    switch (status) {
      case '已完成': return '#52C41A';
      case '复原中': return '#1677FF';
      default: return '#FAAD14';
    }
  }

  getStatusIcon(status: string): string {
    switch (status) {
      case '已完成': return '\u2705';
      case '复原中': return '\uD83D\uDD04';
      default: return '\u23F3';
    }
  }

  openUploadDialog(): void {
    this.newTitle = '';
    this.newDescription = '';
    this.newCategory = '中医典籍';
    this.uploadProgress = 0;
    this.showUploadDialog = true;
  }

  async simulateUpload(): Promise<void> {
    if (!this.newTitle.trim()) {
      ToastUtil.showInfo('\u8BF7\u8F93\u5165\u56FE\u7247\u6807\u9898');
      return;
    }

    this.isUploading = true;
    this.uploadProgress = 10;

    try {
      ToastUtil.showInfo('\u6B63\u5728\u4E0A\u4F20...');

      this.uploadProgress = 30;

      const formData: Record<string, Object> = {};
      formData['title'] = this.newTitle.trim();
      formData['desc'] = this.newDescription.trim() + '[' + this.newCategory + ']';

      this.uploadProgress = 60;

      const response: BaseResponse<AncientImageItem> = await HttpUtil.post<AncientImageItem>(ApiConstants.ANCIENT_IMAGE_UPLOAD, formData);

      this.uploadProgress = 90;

      if (response.success && response.data) {
        const newItem: AncientImageItem = response.data;
        this.images.unshift(newItem);
        this.totalImages += 1;
        this.showUploadDialog = false;
        this.uploadProgress = 100;
        ToastUtil.operationSuccess('\u56FE\u7247\u4E0A\u4F20\u6210\u529F\uFF01');

        setTimeout(() => {
          this.isUploading = false;
          this.uploadProgress = 0;
        }, 500);
      } else {
        throw new Error(response.message ? response.message : '\u4E0A\u4F20\u5931\u8D25');
      }
    } catch (e) {
      console.error('\u4E0A\u4F20\u53D1\u751F\u9519\u8BEF:', e);
      this.isUploading = false;
      this.uploadProgress = 0;
      ToastUtil.showInfo('\u4E0A\u4F20\u5931\u8D25\uFF0C\u8BF7\u91CD\u8BD5');
    }
  }

  async triggerRestore(image: AncientImageItem): Promise<void> {
    if (image.restoreUrl && image.restoreUrl.length > 0) {
      ToastUtil.showInfo('\u8BE5\u56FE\u7247\u5DF2\u5B8C\u6210\u590D\u539F');
      return;
    }

    try {
      ToastUtil.operationSuccess('\u6B63\u5728\u542F\u52A8AI\u590D\u539F...');

      const url: string = ApiConstants.ANCIENT_IMAGE_RESTORE + image.id + '/restore';
      const response: BaseResponse<string> = await HttpUtil.post<string>(url, {} as Record<string, Object>);

      if (response.success) {
        ToastUtil.operationSuccess('\u590D\u539F\u4EFB\u52A1\u5DF2\u542F\u52A8\uFF0C\u8BF7\u7A0D\u5019...');
        setTimeout(() => {
          this.loadImageList();
        }, 5000);
      } else {
        throw new Error(response.message ? response.message : '\u542F\u52A8\u5931\u8D25');
      }
    } catch (e) {
      console.error('\u590D\u539F\u64CD\u4F5C\u9519\u8BEF:', e);
      ToastUtil.showInfo('\u542F\u52A8\u590D\u539F\u5931\u8D25');
    }
  }

  openCompare(image: AncientImageItem): void {
    if (!image.restoreUrl || image.restoreUrl.length === 0) {
      ToastUtil.showInfo('\u8BF7\u7B49\u5F85\u590D\u539F\u5B8C\u6210\u540E\u67E5\u770B\u5BF9\u6BD4');
      return;
    }
    this.selectedImage = image;
    this.compareSliderPosition = 0.5;
    this.showCompareDialog = true;
  }

  shareResult(image: AncientImageItem): void {
    promptAction.showDialog({
      title: '\u5206\u4EAB\u590D\u539F\u6210\u679C',
      message: '\u5206\u4EAB\u300C' + image.title + '\u300D\u7684\u590D\u539F\u7ED3\u679C',
      buttons: [
        { text: '\u590D\u5236\u94FE\u63A5', color: '#1677FF' },
        { text: '\u4FDD\u5B58\u56FE\u7247', color: '#1677FF' },
        { text: '\u53D6\u6D88', color: '#999999' }
      ]
    }).then((result: promptAction.ShowDialogSuccessResponse) => {
      if (result.index === 0) {
        ToastUtil.operationSuccess('\u94FE\u63A5\u5DF2\u590D\u5236\u5230\u526A\u8D34\u677F');
      } else if (result.index === 1) {
        ToastUtil.operationSuccess('\u56FE\u7247\u5DF2\u4FDD\u5B58\u5230\u76F8\u518C');
      }
    });
  }

  async deleteImage(image: AncientImageItem): Promise<void> {
    promptAction.showDialog({
      title: '\u5220\u9664\u56FE\u7247',
      message: '\u786E\u5B9A\u8981\u5220\u9664\u300C' + image.title + '\u300D\u5417\uFF1F\u6B64\u64CD\u4F5C\u4E0D\u53EF\u6062\u590D\u3002',
      buttons: [{ text: '\u53D6\u6D88', color: '#999999' }, { text: '\u5220\u9664', color: '#FF4D4F' }]
    }).then(async (result: promptAction.ShowDialogSuccessResponse) => {
      if (result.index === 1) {
        try {
          const url: string = ApiConstants.ANCIENT_IMAGE_DELETE + image.id;
          const response: BaseResponse<string> = await HttpUtil.delete<string>(url);

          if (response.success) {
            const index: number = this.images.findIndex((img: AncientImageItem) => img.id === image.id);
            if (index > -1) {
              this.images.splice(index, 1);
              this.totalImages -= 1;
            }
            ToastUtil.operationSuccess('\u5DF2\u5220\u9664');
          } else {
            throw new Error(response.message ? response.message : '\u5220\u9664\u5931\u8D25');
          }
        } catch (e) {
          console.error('\u5220\u9664\u5931\u8D25:', e);
          ToastUtil.showInfo('\u5220\u9664\u5931\u8D25\uFF0C\u8BF7\u91CD\u8BD5');
        }
      }
    });
  }

  build() {
    Stack() {
      Column() {
        Header({ title: '\u53E4\u533B\u56FE\u7BA1\u7406', showBack: true });

        Scroll(this.scroller) {
          Column({ space: 16 }) {

            Row({ space: 12 }) {
              Text('\uD83D\uDCDA \u53E4\u533B\u56FE\u5E93')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .layoutWeight(1);

              Text(this.totalImages + ' \u5F20')
                .fontSize(12)
                .fontColor('#1677FF')
                .backgroundColor('#E6F7FF')
                .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                .borderRadius(12);

              Button('+ \u4E0A\u4F20')
                .height(32)
                .fontSize(12)
                .fontColor('#FFFFFF')
                .backgroundColor('#722ED1')
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

            if (this.isLoading) {
              Column({ space: 12 }) {
                Text('\uD83D\uDD04')
                  .fontSize(40);

                Text('\u6B63\u5728\u52A0\u8F7D...')
                  .fontSize(14)
                  .fontColor('#666666');
              }
              .width('100%')
              .height(250)
              .justifyContent(FlexAlign.Center);
            } else if (this.getFilteredImages().length === 0) {
              Column({ space: 16 }) {
                Text('\uD83D\uDCDC')
                  .fontSize(64);

                Text('\u6682\u65E0\u56FE\u7247')
                  .fontSize(16)
                .fontColor('#666666');

                Text('\u70B9\u51FB\u201C\u4E0A\u4F201D\u6309\u94AE\u6DFB\u52A0\u53E4\u533B\u56FE\u7247')
                  .fontSize(13)
                  .fontColor('#999999');
              }
              .width('100%')
              .height(300)
              .justifyContent(FlexAlign.Center);
            } else {
              ForEach(this.getFilteredImages(), (image: AncientImageItem) => {
                this.buildImageCard(image);
              }, (image: AncientImageItem) => image.id.toString());
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
  buildImageCard(image: AncientImageItem) {
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
          Text('\uD83D\uDCDC')
            .fontSize(48);

          if (image.desc && image.desc.indexOf('[') >= 0) {
            if (image.desc.lastIndexOf('[') >= 0 && image.desc.lastIndexOf(']') > image.desc.lastIndexOf('[')) {
              Text(image.desc.substring(image.desc.lastIndexOf('[') + 1, image.desc.lastIndexOf(']')))
                .fontSize(11)
                .fontColor('#FFFFFF')
                .backgroundColor('#722ED1')
                .padding({ left: 8, right: 8, top: 3, bottom: 3 })
                .borderRadius(8)
                .margin({ top: 8 });
            }
          }
        }

        Row({ space: 6 }) {
          Text(this.getStatusIcon(this.getStatusText(image)))
            .fontSize(14);

          Text(this.getStatusText(image))
            .fontSize(11)
            .fontColor(this.getStatusColor(this.getStatusText(image)))
            .fontWeight(FontWeight.Medium)
            .backgroundColor(this.getStatusColor(this.getStatusText(image)) + '15')
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

        Text(image.desc)
          .fontSize(12)
          .fontColor('#666666')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .lineHeight(18);

        Row({ space: 8 }) {
          Text('\uD83D\uDCC5 ' + (image.createTime ? image.createTime.substring(0, 10) : ''))
            .fontSize(10)
            .fontColor('#999999')
            .layoutWeight(1);

          if (image.updateTime && image.updateTime !== image.createTime) {
            Text('\u2728 ' + image.updateTime.substring(0, 10))
              .fontSize(10)
              .fontColor('#52C41A');
          }
        }
        .width('100%');

        Row({ space: 8 }) {
          if (!image.restoreUrl || image.restoreUrl.length === 0) {
            Button('\u5F00\u59CB\u590D\u539F')
              .layoutWeight(1)
              .height(32)
              .fontSize(12)
              .fontColor('#FFFFFF')
              .backgroundColor('#722ED1')
              .borderRadius(16)
              .onClick(() => this.triggerRestore(image));
          }

          if (image.restoreUrl && image.restoreUrl.length > 0) {
            Button('\u5BF9\u6BD4\u67E5\u770B')
              .layoutWeight(1)
              .height(32)
              .fontSize(12)
              .fontColor('#722ED1')
              .backgroundColor('#F9F0FF')
              .borderRadius(16)
              .onClick(() => this.openCompare(image));

            Button('\u5206\u4EAB')
              .layoutWeight(1)
              .height(32)
              .fontSize(12)
              .fontColor('#FFFFFF')
              .backgroundColor('#52C41A')
              .borderRadius(16)
              .onClick(() => this.shareResult(image));
          }

          Button('\u5220\u9664')
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
          Text('\u4E0A\u4F20\u53E4\u533B\u56FE\u7247')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .layoutWeight(1);

          Text('\u2715')
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
              ToastUtil.showInfo('\u9009\u62E9\u56FE\u7247\u6765\u6E90\uFF1A\u62CD\u7167\u6216\u76F8\u518C');
            });

          Column({ space: 4 }) {
            Text('\u70B9\u51FB\u9009\u62E9\u56FE\u7247')
              .fontSize(14)
              .fontColor('#666666');

            Text('\u652F\u6301 JPG\u3001PNG \u683C\u5F0F\uFF0C\u6700\u5927 10MB')
              .fontSize(11)
              .fontColor('#999999');
          }

          if (this.isUploading) {
            Column({ space: 8 }) {
              Row() {
                Text('\u4E0A\u4F20\u8FDB\u5EA6 ' + this.uploadProgress + '%')
                  .fontSize(12)
                  .fontColor('#722ED1')
                  .layoutWeight(1);

                Text(this.uploadProgress + '%')
                  .fontSize(12)
                  .fontColor('#722ED1')
                  .fontWeight(FontWeight.Bold);
              }
              .width('100%');

              Progress({ value: this.uploadProgress, total: 100, type: ProgressType.Linear })
                .width('100%')
                .height(8)
                .color('#722ED1')
                .backgroundColor('#F9F0FF')
                .borderRadius(4);
            }
            .width('100%');
          }
        }

        TextInput({ placeholder: '\u8F93\u5165\u56FE\u7247\u6807\u9898\uFF08\u5982\uFF1A\u672C\u8349\u7EB2\u76EE\u63D2\u56FE\uFF09', text: this.newTitle })
          .width('100%')
          .height(44)
          .fontSize(14)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .onChange((value: string) => {
            this.newTitle = value;
          });

        TextArea({ placeholder: '\u8F93\u5165\u56FE\u7247\u63CF\u8FF0\uFF08\u53EF\u9009\uFF09', text: this.newDescription })
          .width('100%')
          .height(80)
          .fontSize(13)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .onChange((value: string) => {
            this.newDescription = value;
          });

        Column({ space: 8 }) {
          Text('\u5206\u7C7B *')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .width('100%');

          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(['\u4E2D\u533B\u5178\u7BB1', '\u9488\u7078\u56FE\u8C31', '\u672C\u8349\u56FE\u8C31', '\u65B9\u5242\u914D\u56FE'], (cat: string) => {
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
          Button('\u53D6\u6D88')
            .layoutWeight(1)
            .height(44)
            .fontSize(15)
            .fontColor('#666666')
            .backgroundColor('#F5F5F5')
            .borderRadius(22)
            .onClick(() => {
              this.showUploadDialog = false;
            });

          Button('\u4E0A\u4F20\u5E76\u590D\u539F')
            .layoutWeight(1)
            .height(44)
            .fontSize(15)
            .fontColor('#FFFFFF')
            .backgroundColor('#722ED1')
            .borderRadius(22)
            .enabled(!this.isUploading)
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
          Text('\uD83D\uDD0D \u590D\u539F\u7ED3\u679C\u5BF9\u6BD4')
            .fontSize(17)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .layoutWeight(1);

          Text('\u2715')
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
            Text('\u539F\u56FE')
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

            Text('\u6A21\u7CCA/\u7834\u635F')
              .fontSize(10)
              .fontColor('#999999');
          }

          Text('\u2192')
            .fontSize(24)
            .fontColor('#52C41A');

          Column({ space: 6 }) {
            Text('\u590D\u539F\u56FE')
              .fontSize(12)
              .fontColor('#52C41A')
              .fontWeight(FontWeight.Medium);

            Column()
              .width(60)
              .height(60)
              .backgroundColor('#F6FFED')
              .borderRadius(8)
              .border({ width: 1, color: '#B7EB8F' })
              .justifyContent(FlexAlign.Center)
              .clip(true);

            Text('\u6E05\u6670/\u5B8C\u6574')
              .fontSize(10)
              .fontColor('#999999');
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.Center);

        if (this.selectedImage?.desc) {
          Text(this.selectedImage.desc)
            .fontSize(13)
            .fontColor('#666666')
            .lineHeight(20)
            .width('100%')
            .padding(12)
            .backgroundColor('#FAFAFA')
            .borderRadius(8);
        }

        Row({ space: 12 }) {
          Button('\u5173\u95ED')
            .layoutWeight(1)
            .height(40)
            .fontSize(14)
            .fontColor('#666666')
            .backgroundColor('#F5F5F5')
            .borderRadius(20)
            .onClick(() => {
              this.showCompareDialog = false;
            });

          Button('\u4E0B\u8F7D\u590D\u539F\u56FE')
            .layoutWeight(1)
            .height(40)
            .fontSize(14)
            .fontColor('#FFFFFF')
            .backgroundColor('#52C41A')
            .borderRadius(20)
            .onClick(() => {
              ToastUtil.operationSuccess('\u5DF2\u4FDD\u5B58\u5230\u76F8\u518C');
            });
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
}
