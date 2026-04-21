import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { ToastUtil } from '../common/utils/ToastUtil';

class HerbalBasicInfo {
  id: string = '';
  name: string = '';
  pinyin: string = '';
  alias: string[] = [];
  category: string = '';
  nature: string = '';
  taste: string = '';
  meridian: string[] = [];
  efficacySummary: string = '';
  efficacyDetail: string = '';
  indication: string = '';
  usageDosage: string = '';
  contraindication: string = '';
  toxicity: string = '';

  constructor(id: string = '', name: string = '', pinyin: string = '', alias: string[] = [],
    category: string = '', nature: string = '', taste: string = '', meridian: string[] = [],
    efficacySummary: string = '', efficacyDetail: string = '', indication: string = '',
    usageDosage: string = '', contraindication: string = '', toxicity: string = '') {
    this.id = id;
    this.name = name;
    this.pinyin = pinyin;
    this.alias = alias;
    this.category = category;
    this.nature = nature;
    this.taste = taste;
    this.meridian = meridian;
    this.efficacySummary = efficacySummary;
    this.efficacyDetail = efficacyDetail;
    this.indication = indication;
    this.usageDosage = usageDosage;
    this.contraindication = contraindication;
    this.toxicity = toxicity;
  }
}

class CompareItem {
  label: string = '';
  icon: string = '';
  leftValue: string = '';
  rightValue: string = '';
  isSame: boolean = false;
  category: string = '';

  constructor(label: string = '', icon: string = '', leftValue: string = '', rightValue: string = '',
    isSame: boolean = false, category: string = '') {
    this.label = label;
    this.icon = icon;
    this.leftValue = leftValue;
    this.rightValue = rightValue;
    this.isSame = isSame;
    this.category = category;
  }
}

class HerbalListItem {
  id: string = '';
  name: string = '';
  category: string = '';

  constructor(id: string = '', name: string = '', category: string = '') {
    this.id = id;
    this.name = name;
    this.category = category;
  }
}

@Entry
@Component
struct HerbalCompare {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State leftHerbalId: string = '';
  @State rightHerbalId: string = '';
  @State leftHerbal: HerbalBasicInfo | null = null;
  @State rightHerbal: HerbalBasicInfo | null = null;
  @State showLeftPicker: boolean = false;
  @State showRightPicker: boolean = false;
  @State herbalList: HerbalListItem[] = [];
  @State compareItems: CompareItem[] = [];
  @State isLoading: boolean = false;
  @State searchKeyword: string = '';
  @State currentPage: number = 1;
  @State totalPages: number = 1;
  @State totalRecords: number = 0;
  @State isLoadAllComplete: boolean = false;
  private scroller: Scroller = new Scroller();

  aboutToAppear(): void {
    this.loadHerbalList();
  }

  async loadHerbalList(): Promise<void> {
    this.isLoading = true;
    this.isLoadAllComplete = false;
    try {
      const allData: HerbalListItem[] = [];
      
      const params: Record<string, string | number | boolean> = {};
      params['page'] = 1;
      params['size'] = 100;

      console.log('[药材对比] 开始加载第 1 页...');
      const firstResponse: BaseResponse<Object> = await HttpUtil.get<Object>('/herbal/page', params);
      
      if (firstResponse.success && firstResponse.data) {
        const pageData: Record<string, Object> = firstResponse.data as Record<string, Object>;
        
        if (pageData['records'] && Array.isArray(pageData['records'])) {
          const records: Object[] = pageData['records'] as Object[];
          
          for (let i = 0; i < records.length; i++) {
            const item: Record<string, Object> = records[i] as Record<string, Object>;
            const listItem: HerbalListItem = new HerbalListItem(
              String(item['id'] || ''),
              (item['name'] as string) || '',
              (item['category'] as string) || ''
            );
            allData.push(listItem);
          }
        }

        const totalValue: Object | undefined = pageData['total'];
        this.totalRecords = typeof totalValue === 'number' ? totalValue : 0;
        
        const pagesValue: Object | undefined = pageData['pages'];
        this.totalPages = typeof pagesValue === 'number' ? pagesValue : 1;

        console.log('[药材对比] 第1页加载完成，总数:', this.totalRecords, '总页数:', this.totalPages);

        if (this.totalPages > 1) {
          for (let page = 2; page <= this.totalPages; page++) {
            this.currentPage = page;
            console.log('[药材对比] 正在加载第', page, '/', this.totalPages, '页...');
            
            const pageParams: Record<string, string | number | boolean> = {};
            pageParams['page'] = page;
            pageParams['size'] = 100;

            const pageResponse: BaseResponse<Object> = await HttpUtil.get<Object>('/herbal/page', pageParams);
            
            if (pageResponse.success && pageResponse.data) {
              const pageDataInner: Record<string, Object> = pageResponse.data as Record<string, Object>;
              
              if (pageDataInner['records'] && Array.isArray(pageDataInner['records'])) {
                const pageRecords: Object[] = pageDataInner['records'] as Object[];
                
                for (let j = 0; j < pageRecords.length; j++) {
                  const item: Record<string, Object> = pageRecords[j] as Record<string, Object>;
                  const listItem: HerbalListItem = new HerbalListItem(
                    String(item['id'] || ''),
                    (item['name'] as string) || '',
                    (item['category'] as string) || ''
                  );
                  allData.push(listItem);
                }
              }
              console.log('[药材对比] 第', page, '页加载完成，当前累计:', allData.length, '条');
            }
          }
        }

        this.herbalList = allData;
        this.isLoadAllComplete = true;
        console.log('[药材对比] ✅ 全部数据加载完成！共', allData.length, '条药材');
      }
    } catch (e) {
      console.error('加载药材列表失败:', e);
      ToastUtil.showError('加载药材列表失败，请重试');
    } finally {
      this.isLoading = false;
    }
  }

  getFilteredHerbals(): HerbalListItem[] {
    if (!this.searchKeyword.trim()) {
      return this.herbalList;
    }

    const filtered: HerbalListItem[] = [];
    const keyword: string = this.searchKeyword.trim().toLowerCase();

    for (let i = 0; i < this.herbalList.length; i++) {
      const herbal: HerbalListItem = this.herbalList[i];
      if (herbal.name.toLowerCase().indexOf(keyword) >= 0 ||
          herbal.category.toLowerCase().indexOf(keyword) >= 0) {
        filtered.push(herbal);
      }
    }

    return filtered;
  }

  async loadHerbalDetail(herbalId: string, isLeft: boolean): Promise<void> {
    if (!herbalId) return;

    this.isLoading = true;
    try {
      const response: BaseResponse<Object> = await HttpUtil.get<Object>('/herbal/info/' + herbalId);
      if (response.success && response.data) {
        const data: Record<string, Object> = response.data as Record<string, Object>;
        const herbalInfo: HerbalBasicInfo = new HerbalBasicInfo(
          String(data['id'] || ''),
          (data['name'] as string) || '',
          (data['pinyin'] as string) || '',
          data['alias'] ? (data['alias'] as string).split(',') : [],
          (data['category'] as string) || '',
          (data['nature'] as string) || '',
          (data['taste'] as string) || '',
          data['meridian'] ? (data['meridian'] as string).split(',') : [],
          (data['efficacySummary'] as string) || '',
          (data['efficacyDetail'] as string) || '',
          (data['indication'] as string) || '',
          (data['usageDosage'] as string) || '',
          (data['contraindication'] as string) || '',
          (data['toxicity'] as string) || ''
        );

        if (isLeft) {
          this.leftHerbal = herbalInfo;
        } else {
          this.rightHerbal = herbalInfo;
        }

        if (this.leftHerbal && this.rightHerbal) {
          this.generateCompareItems();
          setTimeout(() => {
            this.scroller.scrollTo({ xOffset: 0, yOffset: 500, animation: { duration: 300 } });
          }, 100);
        }
      }
    } catch (e) {
      console.error('加载药材详情失败:', e);
      ToastUtil.showError('加载失败');
    } finally {
      this.isLoading = false;
    }
  }

  generateCompareItems(): void {
    if (!this.leftHerbal || !this.rightHerbal) return;

    const items: CompareItem[] = [];

    items.push(new CompareItem(
      '性味归经',
      '⚖️',
      this.formatNatureTaste(this.leftHerbal.nature, this.leftHerbal.taste, this.leftHerbal.meridian),
      this.formatNatureTaste(this.rightHerbal.nature, this.rightHerbal.taste, this.rightHerbal.meridian),
      this.isNatureTasteSame(),
      'basic'
    ));

    items.push(new CompareItem(
      '功效差异',
      '✨',
      this.leftHerbal.efficacySummary || '-',
      this.rightHerbal.efficacySummary || '-',
      this.leftHerbal.efficacySummary === this.rightHerbal.efficacySummary,
      'efficacy'
    ));

    items.push(new CompareItem(
      '用法区别',
      '📋',
      this.leftHerbal.usageDosage || '-',
      this.rightHerbal.usageDosage || '-',
      this.leftHerbal.usageDosage === this.rightHerbal.usageDosage,
      'usage'
    ));

    items.push(new CompareItem(
      '禁忌注意',
      '⚠️',
      this.leftHerbal.contraindication || '-',
      this.rightHerbal.contraindication || '-',
      this.leftHerbal.contraindication === this.rightHerbal.contraindication,
      'caution'
    ));

    items.push(new CompareItem(
      '毒性信息',
      '☠️',
      this.leftHerbal.toxicity || '无毒',
      this.rightHerbal.toxicity || '无毒',
      this.leftHerbal.toxicity === this.rightHerbal.toxicity,
      'toxicity'
    ));

    items.push(new CompareItem(
      '主治病症',
      '💊',
      this.truncateText(this.leftHerbal.indication, 50),
      this.truncateText(this.rightHerbal.indication, 50),
      this.leftHerbal.indication === this.rightHerbal.indication,
      'indication'
    ));

    items.push(new CompareItem(
      '药材类别',
      '🏷️',
      this.leftHerbal.category || '-',
      this.rightHerbal.category || '-',
      this.leftHerbal.category === this.rightHerbal.category,
      'category'
    ));

    this.compareItems = items;
  }

  formatNatureTaste(nature: string, taste: string, meridian: string[]): string {
    let result: string = '';
    if (nature) result = result + nature + ' ';
    if (taste) result = result + taste + '\n';
    if (meridian && meridian.length > 0) {
      result = result + '归经：' + meridian.join('、');
    }
    return result.trim();
  }

  isNatureTasteSame(): boolean {
    if (!this.leftHerbal || !this.rightHerbal) return false;

    return this.leftHerbal.nature === this.rightHerbal.nature &&
           this.leftHerbal.taste === this.rightHerbal.taste &&
           JSON.stringify(this.leftHerbal.meridian.sort()) === JSON.stringify(this.rightHerbal.meridian.sort());
  }

  truncateText(text: string, maxLength: number): string {
    if (!text) return '-';
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength) + '...';
  }

  selectLeftHerbal(id: string): void {
    this.leftHerbalId = id;
    this.showLeftPicker = false;
    this.searchKeyword = '';
    this.loadHerbalDetail(id, true);
  }

  selectRightHerbal(id: string): void {
    this.rightHerbalId = id;
    this.showRightPicker = false;
    this.searchKeyword = '';
    this.loadHerbalDetail(id, false);
  }

  swapHerbals(): void {
    const tempId: string = this.leftHerbalId;
    const tempHerbal: HerbalBasicInfo | null = this.leftHerbal;

    this.leftHerbalId = this.rightHerbalId;
    this.leftHerbal = this.rightHerbal;

    this.rightHerbalId = tempId;
    this.rightHerbal = tempHerbal;

    if (this.leftHerbal && this.rightHerbal) {
      this.generateCompareItems();
    }

    ToastUtil.showSuccess('已交换位置');
  }

  goToDetail(herbalId: string, _herbalName: string): void {
    try {
      router.pushUrl({
        url: 'pages/HerbalDetailPage',
        params: { herbalId: herbalId }
      });
    } catch (e) {
      console.error('跳转详情失败:', e);
    }
  }

  @Builder
  buildCompareRow(item: CompareItem) {
    Column({ space: 8 }) {
      Row() {
        Text(item.icon)
          .fontSize(16)
          .margin({ right: 6 });

        Text(item.label)
          .fontSize(this.isElderMode ? 15 : 14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1);

        if (item.isSame) {
          Text('相同')
            .fontSize(11)
            .fontColor('#52C41A')
            .backgroundColor('#F6FFED')
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .borderRadius(10);
        } else {
          Text('不同')
            .fontSize(11)
            .fontColor('#FF4D4F')
            .backgroundColor('#FFF2F0')
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .borderRadius(10);
        }
      }
      .width('100%');

      Row({ space: 10 }) {
        Column({ space: 6 }) {
          Text(this.leftHerbal != null ? this.leftHerbal!.name : '药材 A')
            .fontSize(12)
            .fontColor('#1677FF')
            .fontWeight(FontWeight.Medium)
            .width('100%');

          Text(item.leftValue)
            .fontSize(this.isElderMode ? 14 : 13)
            .fontColor(item.isSame ? '#52C41A' : '#FF4D4F')
            .lineHeight(20)
            .width('100%');
        }
        .layoutWeight(1)
        .padding(12)
        .backgroundColor(item.isSame ? '#F6FFED' : '#FFF2F0')
        .borderRadius(10)
        .border({ width: 1.5, color: item.isSame ? '#B7EB8F' : '#FFCCC7', style: BorderStyle.Solid })
        .alignItems(HorizontalAlign.Start);

        Column({ space: 6 }) {
          Text(this.rightHerbal != null ? this.rightHerbal!.name : '药材 B')
            .fontSize(12)
            .fontColor('#1677FF')
            .fontWeight(FontWeight.Medium)
            .width('100%');

          Text(item.rightValue)
            .fontSize(this.isElderMode ? 14 : 13)
            .fontColor(item.isSame ? '#52C41A' : '#FF4D4F')
            .lineHeight(20)
            .width('100%');
        }
        .layoutWeight(1)
        .padding(12)
        .backgroundColor(item.isSame ? '#F6FFED' : '#FFF2F0')
        .borderRadius(10)
        .border({ width: 1.5, color: item.isSame ? '#B7EB8F' : '#FFCCC7', style: BorderStyle.Solid })
        .alignItems(HorizontalAlign.Start);
      }
      .width('100%')
      .alignItems(VerticalAlign.Top);
    }
    .width('100%')
    .padding(14)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 2 });
  }

  @Builder
  buildHerbalSelector(title: string, herbal: HerbalBasicInfo | null, isLeft: boolean) {
    Column({ space: 8 }) {
      Text(title)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor('#666666')
        .width('100%');

      Stack({ alignContent: Alignment.End }) {
        Column() {
          if (herbal) {
            Text(herbal.name)
              .fontSize(this.isElderMode ? 17 : 16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1677FF')
              .width('100%');

            Text(herbal.category)
              .fontSize(12)
              .fontColor('#999999')
              .width('100%')
              .margin({ top: 2 });
          } else {
            Text('请选择药材')
              .fontSize(this.isElderMode ? 16 : 15)
              .fontColor('#999999')
              .width('100%');
          }
        }
        .width('100%')
        .padding(14)
        .backgroundColor(herbal ? '#E6F4FF' : '#F5F7FA')
        .borderRadius(10)
        .border({
          width: herbal ? 1.5 : 1,
          color: herbal ? '#1677FF' : '#E0E0E0'
        })
        .alignItems(HorizontalAlign.Start);

        Text('▼')
          .fontSize(12)
          .fontColor('#666666')
          .margin({ right: 14 });
      }
      .width('100%')
      .onClick(() => {
        if (isLeft) {
          this.showLeftPicker = !this.showLeftPicker;
          this.showRightPicker = false;
        } else {
          this.showRightPicker = !this.showRightPicker;
          this.showLeftPicker = false;
        }
      });

      if ((isLeft && this.showLeftPicker) || (!isLeft && this.showRightPicker)) {
        Column({ space: 8 }) {
          TextInput({ placeholder: '搜索药材...', text: this.searchKeyword })
            .width('100%')
            .height(36)
            .fontSize(13)
            .backgroundColor('#FAFAFA')
            .borderRadius(8)
            .onChange((value: string) => {
              this.searchKeyword = value;
            });

          Scroll() {
            Column() {
              ForEach(this.getFilteredHerbals(), (herbal: HerbalListItem) => {
                Row() {
                  Column({ space: 2 }) {
                    Text(herbal.name)
                      .fontSize(14)
                      .fontWeight(FontWeight.Medium)
                      .fontColor('#333333');

                    Text(herbal.category)
                      .fontSize(11)
                      .fontColor('#999999');
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start);

                  if ((isLeft && this.leftHerbalId === herbal.id) ||
                      (!isLeft && this.rightHerbalId === herbal.id)) {
                    Text('✓')
                      .fontSize(16)
                      .fontColor('#1677FF');
                  }
                }
                .width('100%')
                .height(52)
                .padding({ left: 12, right: 12 })
                .backgroundColor(((isLeft && this.leftHerbalId === herbal.id) ||
                                 (!isLeft && this.rightHerbalId === herbal.id)) ? '#E6F4FF' : '#FFFFFF')
                .borderRadius(8)
                .onClick(() => {
                  if (isLeft) {
                    this.selectLeftHerbal(herbal.id);
                  } else {
                    this.selectRightHerbal(herbal.id);
                  }
                });
              }, (herbal: HerbalListItem) => herbal.id);

              if (this.isLoading && !this.isLoadAllComplete && this.getFilteredHerbals().length > 0) {
                Row({ space: 6 }) {
                  LoadingProgress()
                    .width(14)
                    .height(14)
                    .color('#1677FF');

                  Text('正在加载第 ' + this.currentPage + '/' + this.totalPages + ' 页...')
                    .fontSize(11)
                    .fontColor('#999999');
                }
                .width('100%')
                .padding(10)
                .justifyContent(FlexAlign.Center);
              }
            }
          }
          .width('100%')
          .constraintSize({ maxHeight: 240 })
          .border({ width: 1, color: '#E0E0E0', radius: 8 })
          .shadow({ radius: 8, color: '#00000018', offsetX: 0, offsetY: 4 });
        }
        .width('100%')
        .padding(8)
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
        .shadow({ radius: 12, color: '#00000015', offsetX: 0, offsetY: 4 });
      }
    }
    .layoutWeight(1);
  }

  build() {
    Column() {
      Header({ title: '药材对比', showBack: true });

      Scroll(this.scroller) {
        Column({ space: 20 }) {
          Column({ space: 16 }) {
            Text('选择两味药材进行对比分析')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .width('100%');

            if (this.isLoading && !this.isLoadAllComplete) {
              Row({ space: 8 }) {
                LoadingProgress()
                  .width(16)
                  .height(16)
                  .color('#1677FF');

                Text('正在加载药材数据 (' + this.currentPage + '/' + this.totalPages + '页)... 已加载 ' + this.herbalList.length + '/' + this.totalRecords + ' 条')
                  .fontSize(12)
                  .fontColor('#666666');
              }
              .width('100%')
              .padding(12)
              .backgroundColor('#E6F4FF')
              .borderRadius(8)
              .justifyContent(FlexAlign.Center);
            } else if (this.isLoadAllComplete) {
              Row({ space: 8 }) {
                Text('✅')
                  .fontSize(14);

                Text('数据加载完成，共 ' + this.herbalList.length + ' 种药材可选')
                  .fontSize(12)
                  .fontColor('#52C41A')
                  .fontWeight(FontWeight.Medium);
              }
              .width('100%')
              .padding(10)
              .backgroundColor('#F6FFED')
              .borderRadius(8);
            }

            Row({ space: 12 }) {
              this.buildHerbalSelector('药材 A', this.leftHerbal, true);

              Column({ space: 8 }) {
                Text('')
                  .width('100%')
                  .height(13);

                Button('⇄')
                  .width(44)
                  .height(44)
                  .fontSize(18)
                  .fontColor('#1677FF')
                  .backgroundColor('#E6F4FF')
                  .borderRadius(22)
                  .enabled(this.leftHerbal !== null && this.rightHerbal !== null)
                  .onClick(() => this.swapHerbals());

                Text('交换')
                  .fontSize(10)
                  .fontColor('#999999')
                  .width('100%')
                  .textAlign(TextAlign.Center);
              }
              .width(50)
              .justifyContent(FlexAlign.Center);

              this.buildHerbalSelector('药材 B', this.rightHerbal, false);
            }
            .width('100%')
            .alignItems(VerticalAlign.Top);
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .shadow({ radius: 6, color: '#0000000A', offsetX: 0, offsetY: 2 });

          if (this.isLoading) {
            Column({ space: 16 }) {
              LoadingProgress()
                .width(48)
                .height(48)
                .color('#1677FF');

              Text('正在加载药材详情...')
                .fontSize(14)
                .fontColor('#666666');
            }
            .width('100%')
            .height(400)
            .justifyContent(FlexAlign.Center)
            .backgroundColor('#FFFFFF')
            .borderRadius(12);
          } else if (this.compareItems.length > 0) {
            Column({ space: 16 }) {
              Row({ space: 12 }) {
                if (this.leftHerbal) {
                  Column({ space: 4 }) {
                    Text(this.leftHerbal.name)
                      .fontSize(16)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#1677FF');

                    Text(this.leftHerbal.category)
                      .fontSize(12)
                      .fontColor('#999999');
                  }
                  .layoutWeight(1)
                  .padding(12)
                  .backgroundColor('#E6F4FF')
                  .borderRadius(10)
                  .alignItems(HorizontalAlign.Center)
                  .onClick(() => this.goToDetail(this.leftHerbal!.id, this.leftHerbal!.name));
                }

                Text('VS')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FAAD14');

                if (this.rightHerbal) {
                  Column({ space: 4 }) {
                    Text(this.rightHerbal.name)
                      .fontSize(16)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#1677FF');

                    Text(this.rightHerbal.category)
                      .fontSize(12)
                      .fontColor('#999999');
                  }
                  .layoutWeight(1)
                  .padding(12)
                  .backgroundColor('#E6F4FF')
                  .borderRadius(10)
                  .alignItems(HorizontalAlign.Center)
                  .onClick(() => this.goToDetail(this.rightHerbal!.id, this.rightHerbal!.name));
                }
              }
              .width('100%');

              Column({ space: 2 }) {
                ForEach(this.compareItems, (item: CompareItem) => {
                  this.buildCompareRow(item);
                }, (item: CompareItem) => item.label);
              }

              Row({ space: 10 }) {
                Text('💡 图例说明：')
                  .fontSize(13)
                  .fontColor('#666666')
                  .fontWeight(FontWeight.Medium);

                Row({ space: 6 }) {
                  Text('')
                    .width(12)
                    .height(12)
                    .backgroundColor('#52C41A')
                    .borderRadius(3);

                  Text('相同')
                    .fontSize(12)
                    .fontColor('#666666');
                }

                Row({ space: 6 }) {
                  Text('')
                    .width(12)
                    .height(12)
                    .backgroundColor('#FF4D4F')
                    .borderRadius(3);

                  Text('差异')
                    .fontSize(12)
                    .fontColor('#666666');
                }
              }
              .width('100%')
              .padding(14)
              .backgroundColor('#FFFBE6')
              .borderRadius(10)
              .border({ width: 1, color: '#FFE58F', style: BorderStyle.Dashed });
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .shadow({ radius: 6, color: '#0000000A', offsetX: 0, offsetY: 2 });
          } else {
            Column({ space: 20 }) {
              Text('⚖️')
                .fontSize(72);

              Text('请选择两味药材开始对比')
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333');

              Text('支持多维度对比分析\n• 性味归经 • 功效差异 • 用法区别 • 禁忌注意')
                .fontSize(13)
                .fontColor('#999999')
                .lineHeight(22)
                .textAlign(TextAlign.Center);
            }
            .width('100%')
            .height(450)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .backgroundColor('#FFFFFF')
            .borderRadius(12);
          }
        }
        .width('90%')
        .padding({ top: 20, bottom: 40 });
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top);

      Footer({ activeIndex: 2 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }
}
