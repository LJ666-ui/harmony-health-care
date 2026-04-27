import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';

interface HerbalCompareItem {
  id: string;
  name: string;
  pinyin?: string;
  alias: string[];
  category: string;
  nature: string;
  taste: string;
  meridian: string[];
  efficacy: string[];
  indications: string[];
  usage: string;
  dosage: string;
  caution: string;
}

@Entry
@Component
struct HerbalComparePage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State herbalList: HerbalCompareItem[] = [];
  @State isLoading: boolean = true;

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') || false;
    }

    try {
      const params = router.getParams() as Record<string, Object> | undefined;
      if (params && params['herbalIds']) {
        const herbalIdsStr = String(params['herbalIds']);
        const herbalIds: string[] = herbalIdsStr.split(',');
        this.loadHerbals(herbalIds);
      }
    } catch (error) {
      console.error('获取参数失败:', error);
      this.isLoading = false;
    }
  }

  async loadHerbals(herbalIds: string[]): Promise<void> {
    this.isLoading = true;

    try {
      const loadedHerbals: HerbalCompareItem[] = [];

      for (let i = 0; i < herbalIds.length; i++) {
        try {
          const response: BaseResponse<Object> = await HttpUtil.get<Object>('/herbal/info/' + herbalIds[i]);
          if (response.success && response.data) {
            const data = response.data as Record<string, Object>;
            const herbal: HerbalCompareItem = {
              id: String(data['id'] || ''),
              name: String(data['name'] || '未知'),
              pinyin: String(data['pinyin'] || ''),
              alias: (data['alias'] as string) ? String(data['alias']).split(',') : [],
              category: String(data['category'] || '未分类'),
              nature: String(data['nature'] || '-'),
              taste: String(data['taste'] || '-'),
              meridian: (data['meridian'] as string) ? String(data['meridian']).split(',').map((m: string) => m.trim()) : [],
              efficacy: (data['efficacySummary'] as string) ? this.parseList(String(data['efficacySummary'])) : [],
              indications: (data['indication'] as string) ? this.parseList(String(data['indication'])) : [],
              usage: String(data['usageDosage'] || '-'),
              dosage: String(data['usageDosage'] || '-'),
              caution: String(data['contraindication'] || '-')
            };
            loadedHerbals.push(herbal);
          }
        } catch (error) {
          console.error('加载药材失败:', error);
        }
      }

      this.herbalList = loadedHerbals;
    } catch (error) {
      console.error('加载药材数据异常:', error);
    } finally {
      this.isLoading = false;
    }
  }

  parseList(str: string): string[] {
    let result = str.replace(/，/g, ',');
    result = result.replace(/;/g, ',');
    result = result.replace(/；/g, ',');
    return result.split(',').map(item => item.trim()).filter(item => item.length > 0);
  }

  build() {
    Column() {
      Header({ title: '药材对比', showBack: true });

      if (this.isLoading) {
        Column() {
          Text('⏳')
            .fontSize(48)
            .margin({ bottom: 16 });
          Text('正在加载药材信息...')
            .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
            .fontColor('#666666');
        }
        .width('100%')
        .height(400)
        .justifyContent(FlexAlign.Center);
      } else if (this.herbalList.length === 0) {
        Column() {
          Text('🌿')
            .fontSize(48)
            .margin({ bottom: 16 });
          Text('未选择要对比的药材')
            .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
            .fontColor('#999999');
        }
        .width('100%')
        .height(400)
        .justifyContent(FlexAlign.Center);
      } else {
        Scroll() {
          Column() {
            Text(`已选择 ${this.herbalList.length} 种药材进行对比`)
              .fontSize(14)
              .fontColor('#666666')
              .width('90%')
              .margin({ top: 16, bottom: 12 })
              .textAlign(TextAlign.Center);

            Flex({ direction: FlexDirection.Row }) {
              ForEach(this.herbalList, (herbal: HerbalCompareItem, index: number) => {
                Column() {
                  Text('🌿')
                    .fontSize(40)
                    .margin({ bottom: 8 });
                  Text(herbal.name)
                    .fontSize(this.isElderMode ? 18 : 16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#1677FF')
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .width('100%');
                  if (herbal.pinyin && herbal.pinyin.length > 0) {
                    Text(herbal.pinyin)
                      .fontSize(11)
                      .fontColor('#999999')
                      .margin({ top: 4 });
                  }
                }
                .width(`${Math.floor(100 / this.herbalList.length)}%`)
                .padding(12)
                .backgroundColor(index % 2 === 0 ? '#E6F4FF' : '#F0FFF4')
                .borderRadius(8)
                .alignItems(HorizontalAlign.Center);
              }, (herbal: HerbalCompareItem) => herbal.id);
            }
            .width('90%')
            .margin({ bottom: 20 });

            this.buildCompareTable();
          }
          .width('100%')
          .padding({ bottom: 80 });
        }
        .scrollable(ScrollDirection.Vertical)
        .scrollBar(BarState.Off)
        .layoutWeight(1);
      }

      Footer({ activeIndex: 2 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor(GlobalTheme.BG_COLOR);
  }

  @Builder
  buildCompareTable(): void {
    Column({ space: 0 }) {
      this.buildCompareRow('基本信息', undefined);

      this.buildCompareRow('别名', (herbal: HerbalCompareItem): string => {
        return herbal.alias.length > 0 ? herbal.alias.join('、') : '-';
      });

      this.buildCompareRow('分类', (herbal: HerbalCompareItem): string => herbal.category);

      this.buildCompareRow('药性（四气）', (herbal: HerbalCompareItem): string => herbal.nature);

      this.buildCompareRow('五味', (herbal: HerbalCompareItem): string => herbal.taste);

      this.buildCompareRow('归经', (herbal: HerbalCompareItem): string => {
        return herbal.meridian.length > 0 ? herbal.meridian.join('、') : '-';
      });

      this.buildCompareRow('功效', (herbal: HerbalCompareItem): string => {
        return herbal.efficacy.length > 0 ? herbal.efficacy.join('\n') : '-';
      });

      this.buildCompareRow('适应症', (herbal: HerbalCompareItem): string => {
        return herbal.indications.length > 0 ? herbal.indications.join('\n') : '-';
      });

      this.buildCompareRow('用法用量', (herbal: HerbalCompareItem): string => herbal.usage);

      this.buildCompareRow('禁忌', (herbal: HerbalCompareItem): string => herbal.caution);
    }
    .width('90%')
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .border({ width: 1, color: '#F0F0F0' });
  }

  @Builder
  buildCompareRow(label: string, getValue?: (herbal: HerbalCompareItem) => string): void {
    Column() {
      Row() {
        Text(label)
          .fontSize(this.isElderMode ? 15 : 13)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .width(80);

        Flex({ direction: FlexDirection.Row }) {
          ForEach(this.herbalList, (herbal: HerbalCompareItem, index: number) => {
            Column() {
              if (getValue) {
                Text(getValue(herbal))
                  .fontSize(this.isElderMode ? 14 : 12)
                  .fontColor(index % 2 === 0 ? '#1677FF' : '#52C41A')
                  .lineHeight(18)
                  .textAlign(TextAlign.Start);
              } else {
                Text('')
                  .fontSize(12);
              }
            }
            .layoutWeight(1)
            .padding({ left: 8, right: 8 })
            .alignItems(HorizontalAlign.Start);
          }, (herbal: HerbalCompareItem) => herbal.id);
        }
        .layoutWeight(1);
      }
      .width('100%');

      Row()
        .width('100%')
        .height(1)
        .backgroundColor('#F5F5F5');
    }
    .width('100%')
    .padding({ left: 12, right: 12, top: 12 })
    .alignItems(HorizontalAlign.Start);
  }
}
