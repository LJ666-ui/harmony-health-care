import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { EfficacyTag } from '../components/EfficacyTag';
import { ToastUtil } from '../common/utils/ToastUtil';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';

interface BackendHerbalDetail {
  id?: number;
  name?: string;
  pinyin?: string;
  alias?: string;
  category?: string;
  nature?: string;
  taste?: string;
  meridian?: string;
  efficacySummary?: string;
  efficacyDetail?: string;
  indication?: string;
  usageDosage?: string;
  contraindication?: string;
  toxicity?: string;
  processingMethod?: string;
  sourceOrigin?: string;
  appearance?: string;
  imageUrl?: string;
}

interface HerbalInfo {
  id: string;
  name: string;
  pinyin: string;
  alias: string[];
  category: string;
  nature: string;
  taste: string;
  meridian: string[];
  efficacySummary: string;
  efficacyDetail: string;
  indication: string;
  usageDosage: string;
  contraindication: string;
  toxicity: string;
  processingMethod: string;
  sourceOrigin: string;
  appearance: string;
  imageUrl: string;
  efficacy: string[];
  indications: string[];
  usage: string;
  dosage: string;
  caution: string;
}

@Entry
@Component
struct HerbalDetailPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State herbal: HerbalInfo | undefined = undefined;
  @State isCollected: boolean = false;
  @State isLoading: boolean = true;
  @State showBackToTop: boolean = false;
  private scroller: Scroller = new Scroller();
  private herbalId: string = '';

  async aboutToAppear(): Promise<void> {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') ?? false;
    }

    const params: Record<string, Object> | undefined = router.getParams() as Record<string, Object> | undefined;
    if (params && params['herbalId']) {
      this.herbalId = params['herbalId'] as string;

      try {
        const response: BaseResponse<Object> = await HttpUtil.get<Object>(`/herbal/info/${this.herbalId}`);
        if (response.success && response.data) {
          const data: Record<string, Object> = response.data as Record<string, Object>;
          this.herbal = {
            id: String(data['id'] || 0),
            name: (data['name'] as string) || '',
            pinyin: (data['pinyin'] as string) || '',
            alias: data['alias'] ? (data['alias'] as string).split(',') : [],
            category: (data['category'] as string) || '',
            nature: (data['nature'] as string) || '',
            taste: (data['taste'] as string) || '',
            meridian: data['meridian'] ? (data['meridian'] as string).split(',') : [],
            efficacySummary: (data['efficacySummary'] as string) || '',
            efficacyDetail: (data['efficacyDetail'] as string) || '',
            indication: (data['indication'] as string) || '',
            usageDosage: (data['usageDosage'] as string) || '',
            contraindication: (data['contraindication'] as string) || '',
            toxicity: (data['toxicity'] as string) || '',
            processingMethod: (data['processingMethod'] as string) || '',
            sourceOrigin: (data['sourceOrigin'] as string) || '',
            appearance: (data['appearance'] as string) || '',
            imageUrl: (data['imageUrl'] as string) || '',
            efficacy: data['efficacySummary'] ? (data['efficacySummary'] as string).split(',') : [],
            indications: data['indication'] ? (data['indication'] as string).split(',') : [],
            usage: (data['usageDosage'] as string) || '',
            dosage: (data['usageDosage'] as string) || '',
            caution: (data['contraindication'] as string) || ''
          } as HerbalInfo;
        }
      } catch (error) {
        console.error('加载药材详情失败:', error);
      } finally {
        this.isLoading = false;
      }
    } else {
      this.isLoading = false;
    }
  }

  async toggleCollect(): Promise<void> {
    if (this.herbal && this.herbalId) {
      try {
        if (!this.isCollected) {
          const response: BaseResponse<Object> = await HttpUtil.post<Object>(`/herbal/${this.herbalId}/collect`);
          if (response.success) {
            this.isCollected = true;
            ToastUtil.operationSuccess();
          } else {
            ToastUtil.showError(response.message || '收藏失败', 2000);
          }
        } else {
          const deleteRes: BaseResponse<Object> = await HttpUtil.delete<Object>(`/herbal/${this.herbalId}/collect`);
          if (deleteRes.success) {
            this.isCollected = false;
            ToastUtil.showInfo('已取消收藏');
          } else {
            ToastUtil.showError(deleteRes.message || '取消收藏失败', 2000);
          }
        }
      } catch (error) {
        console.error('操作收藏失败:', error);
        ToastUtil.showError('网络请求失败', 2000);
      }
    }
  }

  scrollToTop(): void {
    this.scroller.scrollTo({
      xOffset: 0,
      yOffset: 0,
      animation: { duration: 300, curve: Curve.EaseOut }
    });
  }

  build() {
    Stack() {
      Column() {
        Header({ title: '药材详情', showBack: true });

        Scroll(this.scroller) {
          if (!this.herbal) {
            Column({ space: 20 }) {
              Text('🔍')
                .fontSize(64);

              Text('未找到药材信息')
                .fontSize(18)
                .fontColor('#333333')
                .fontWeight(FontWeight.Bold);

              Text('该药材可能已被删除或ID无效')
                .fontSize(14)
                .fontColor('#666666');

              Button('返回列表')
                .height(44)
                .fontSize(15)
                .fontColor('#FFFFFF')
                .backgroundColor('#1677FF')
                .borderRadius(22)
                .padding({ left: 32, right: 32 })
                .onClick(() => {
                  router.back();
                });
            }
            .width('100%')
            .height(500)
            .justifyContent(FlexAlign.Center);
          } else {
            Column({ space: 20 }) {
              Stack({ alignContent: Alignment.Bottom }) {
                Column()
                  .width('100%')
                  .height(220)
                  .linearGradient({
                    angle: 135,
                    colors: [['#F6FFED', 0], ['#E6F7FF', 1]]
                  })
                  .justifyContent(FlexAlign.Center);

                Column() {
                  Text(this.getHerbalIcon(this.herbal!.name))
                    .fontSize(96);

                  Text(this.herbal!.category)
                    .fontSize(13)
                    .fontColor('#1677FF')
                    .backgroundColor('#FFFFFF')
                    .padding({ left: 12, right: 12, top: 4, bottom: 4 })
                    .borderRadius(12)
                    .margin({ top: 8 });
                }
              }

              Row() {
                Text(this.herbal!.name)
                  .fontSize(28)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#333333')
                  .layoutWeight(1);

                Button(this.isCollected ? '❤️' : '🤍')
                  .width(48)
                  .height(48)
                  .fontSize(22)
                  .backgroundColor('#FFFFFF')
                  .borderRadius(24)
                  .shadow({ radius: 8, color: '#00000015', offsetX: 0, offsetY: 2 })
                  .border({ width: 1, color: this.isCollected ? '#FF4D4F' : '#F0F0F0' })
                  .onClick(() => this.toggleCollect());
              }
              .width('100%')
              .alignItems(VerticalAlign.Bottom);

              this.buildInfoSection(
                '别名',
                this.herbal!.alias.length > 0
                  ? this.herbal!.alias.map((alias: string) => `「${alias}」`).join('')
                  : '暂无别名记录',
                '📝'
              );

              this.buildFourPropertiesSection();

              this.buildInfoSection(
                '归经',
                this.herbal!.meridian.join(' → '),
                '🎯'
              );

              this.buildEfficacySection();

              this.buildIndicationsSection();

              this.buildUsageDosageSection();

              this.buildCautionSection();
            }
            .width('100%')
            .padding({ left: 16, right: 16, bottom: 80 });
          }
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
        .onScrollStop(() => {
          const currentYOffset: number = this.scroller.currentOffset().yOffset;
          this.showBackToTop = currentYOffset > 600;
        });

        Footer({ activeIndex: 2 });
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F7FA');

      if (this.showBackToTop) {
        Button('↑')
          .width(48)
          .height(48)
          .fontSize(18)
          .fontColor('#FFFFFF')
          .backgroundColor('#1677FF')
          .borderRadius(24)
          .shadow({ radius: 10, color: '#00000030', offsetX: 0, offsetY: 4 })
          .position({ x: '87%', y: '82%' })
          .onClick(() => this.scrollToTop());
      }
    }
    .width('100%')
    .height('100%');
  }

  @Builder
  buildInfoSection(title: string, content: string, icon?: string) {
    Column({ space: 12 }) {
      Row() {
        if (icon) {
          Text(icon)
            .fontSize(18);
        }

        Text(title)
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1);
      }
      .width('100%');

      Text(content)
        .fontSize(14)
        .fontColor('#555555')
        .lineHeight(22)
        .width('100%');
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 2 });
  }

  @Builder
  buildFourPropertiesSection() {
    Column({ space: 16 }) {
      Row() {
        Text('⚖️')
          .fontSize(18);

        Text('四气五味')
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1);
      }
      .width('100%');

      Row({ space: 12 }) {
        Column({ space: 8 }) {
          Text('药性')
            .fontSize(12)
            .fontColor('#999999');

          Text(this.herbal!.nature)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1677FF');

          Text(this.getNatureDesc(this.herbal!.nature))
            .fontSize(11)
            .fontColor('#999999');
        }
        .layoutWeight(1)
        .padding(16)
        .backgroundColor('#F0F5FF')
        .borderRadius(12)
        .alignItems(HorizontalAlign.Center)
        .border({ width: 1.5, color: '#D6E4FF' });

        Column({ space: 8 }) {
          Text('药味')
            .fontSize(12)
            .fontColor('#999999');

          Text(this.herbal!.taste)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#52C41A');

          Text(this.getTasteDesc(this.herbal!.taste))
            .fontSize(11)
            .fontColor('#999999');
        }
        .layoutWeight(1)
        .padding(16)
        .backgroundColor('#F6FFED')
        .borderRadius(12)
        .alignItems(HorizontalAlign.Center)
        .border({ width: 1.5, color: '#B7EB8F' });
      }
      .width('100%');
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 2 });
  }

  @Builder
  buildEfficacySection() {
    Column({ space: 12 }) {
      Row() {
        Text('✨')
          .fontSize(18);

        Text('主要功效')
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1);
      }
      .width('100%');

      EfficacyTag({ efficacies: this.herbal!.efficacy });
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 2 });
  }

  @Builder
  buildIndicationsSection() {
    Column({ space: 12 }) {
      Row() {
        Text('💊')
          .fontSize(18);

        Text('主治病症')
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1);
      }
      .width('100%');

      ForEach(this.herbal!.indications, (indication: string) => {
        Row({ space: 10 }) {
          Text('▸')
            .fontSize(14)
            .fontColor('#1677FF')
            .fontWeight(FontWeight.Medium);

          Text(indication)
            .fontSize(14)
            .fontColor('#555555')
            .lineHeight(20)
            .layoutWeight(1);
        }
        .width('100%')
        .padding({ top: 8, bottom: 8, left: 4, right: 4 })
        .backgroundColor(indication === this.herbal!.indications[0] ? '#FAFAFA' : 'transparent')
        .borderRadius(6);
      }, (indication: string) => indication);
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 2 });
  }

  @Builder
  buildUsageDosageSection() {
    Column({ space: 16 }) {
      Row() {
        Text('📋')
          .fontSize(18);

        Text('用法用量')
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1);
      }
      .width('100%');

      Row({ space: 12 }) {
        Column({ space: 8 }) {
          Text('用法')
            .fontSize(12)
            .fontColor('#999999')
            .width('100%');

          Text(this.herbal!.usage)
            .fontSize(13)
            .fontColor('#333333')
            .lineHeight(19)
            .width('100%');
        }
        .layoutWeight(1.2)
        .padding(14)
        .backgroundColor('#FAFAFA')
        .borderRadius(10)
        .alignItems(HorizontalAlign.Start);

        Column({ space: 8 }) {
          Text('剂量')
            .fontSize(12)
            .fontColor('#999999')
            .width('100%');

          Text(this.herbal!.dosage)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1677FF')
            .width('100%');
        }
        .layoutWeight(0.8)
        .padding(14)
        .backgroundColor('#F0F5FF')
        .borderRadius(10)
        .alignItems(HorizontalAlign.Center)
        .border({ width: 1.5, color: '#D6E4FF' });
      }
      .width('100%');
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 2 });
  }

  @Builder
  buildCautionSection() {
    Column({ space: 12 }) {
      Row() {
        Text('⚠️')
          .fontSize(18);

        Text('注意事项')
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FF4D4F')
          .layoutWeight(1);
      }
      .width('100%');

      Text(this.herbal!.caution)
        .fontSize(14)
        .fontColor('#666666')
        .lineHeight(22)
        .width('100%');

      Text('⛔ 请在医师指导下使用，切勿自行用药')
        .fontSize(12)
        .fontColor('#FF7875')
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .textAlign(TextAlign.Center)
        .margin({ top: 4 });
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFF7F7')
    .borderRadius(12)
    .border({ width: 1.5, color: '#FFCCC7', style: BorderStyle.Dashed });
  }

  private getNatureDesc(nature: string): string {
    const descMap: Record<string, string> = {
      '寒': '清热泻火',
      '热': '温里散寒',
      '温': '温中散寒',
      '凉': '清热凉血',
      '平': '作用缓和'
    };
    return descMap[nature] || '';
  }

  private getTasteDesc(taste: string): string {
    const mainTaste: string = taste.split('、')[0];
    const descMap: Record<string, string> = {
      '甘': '补益和中',
      '苦': '泄降燥湿',
      '辛': '发散行气',
      '酸': '收敛固涩',
      '咸': '软坚泻下',
      '淡': '渗湿利尿',
      '涩': '收敛固涩'
    };
    return descMap[mainTaste] || '';
  }

  private getHerbalIcon(name: string): string {
    const iconMap: Record<string, string> = {
      '人参': '🌿',
      '黄芪': '🌾',
      '当归': '🌸',
      '熟地黄': '🫒',
      '阿胶': '🩸',
      '麦冬': '🌱',
      '枸杞子': '🔴',
      '鹿茸': '🦌',
      '杜仲': '🍂',
      '金银花': '🌼',
      '菊花': '🌻',
      '甘草': '🍃',
      '白术': '🌿',
      '山药': '🥔',
      '何首乌': '🖤',
      '淫羊藿': '🌿',
      '石斛': '🎋',
      '茯苓': '🍄',
      '连翘': '💮',
      '肉苁蓉': '🌵'
    };
    return iconMap[name] || '🌿';
  }
}
