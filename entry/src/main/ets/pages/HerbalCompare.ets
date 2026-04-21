import { router } from '@kit.ArkUI';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { ToastUtil } from '../common/utils/ToastUtil';

class HerbalBasicInfo {
  id: string = '';
  name: string = '';
  nature: string = '';
  taste: string = '';
  meridian: string = '';
  efficacySummary: string = '';
  indication: string = '';
  usageDosage: string = '';
  contraindication: string = '';

  constructor(id: string = '', name: string = '', nature: string = '', taste: string = '',
    meridian: string = '', efficacySummary: string = '', indication: string = '',
    usageDosage: string = '', contraindication: string = '') {
    this.id = id;
    this.name = name;
    this.nature = nature;
    this.taste = taste;
    this.meridian = meridian;
    this.efficacySummary = efficacySummary;
    this.indication = indication;
    this.usageDosage = usageDosage;
    this.contraindication = contraindication;
  }
}

class CompareItem {
  label: string = '';
  leftValue: string = '';
  rightValue: string = '';
  isSame: boolean = false;

  constructor(label: string = '', leftValue: string = '', rightValue: string = '', isSame: boolean = false) {
    this.label = label;
    this.leftValue = leftValue;
    this.rightValue = rightValue;
    this.isSame = isSame;
  }
}

class HerbalListItem {
  id: string = '';
  name: string = '';

  constructor(id: string = '', name: string = '') {
    this.id = id;
    this.name = name;
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

  aboutToAppear(): void {
    this.loadHerbalList();
  }

  async loadHerbalList(): Promise<void> {
    try {
      const response: BaseResponse<Object[]> = await HttpUtil.get<Object[]>('/herbal/list');
      if (response.success && response.data) {
        const tempList: HerbalListItem[] = [];
        const dataArray: Object[] = response.data;
        for (let i = 0; i < dataArray.length; i++) {
          const item: Record<string, Object> = dataArray[i] as Record<string, Object>;
          const listItem: HerbalListItem = new HerbalListItem(
            String(item['id'] || ''),
            (item['name'] as string) || ''
          );
          tempList.push(listItem);
        }
        this.herbalList = tempList;
      }
    } catch (e) {
      console.error('加载药材列表失败:', e);
      this.loadMockHerbalList();
    }
  }

  loadMockHerbalList(): void {
    const mockList: HerbalListItem[] = [];
    mockList.push(new HerbalListItem('1', '人参'));
    mockList.push(new HerbalListItem('2', '黄芪'));
    mockList.push(new HerbalListItem('3', '当归'));
    mockList.push(new HerbalListItem('4', '枸杞'));
    mockList.push(new HerbalListItem('5', '甘草'));
    mockList.push(new HerbalListItem('6', '茯苓'));
    mockList.push(new HerbalListItem('7', '白术'));
    mockList.push(new HerbalListItem('8', '山药'));
    this.herbalList = mockList;
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
          (data['nature'] as string) || '',
          (data['taste'] as string) || '',
          (data['meridian'] as string) || '',
          (data['efficacySummary'] as string) || '',
          (data['indication'] as string) || '',
          (data['usageDosage'] as string) || '',
          (data['contraindication'] as string) || ''
        );

        if (isLeft) {
          this.leftHerbal = herbalInfo;
        } else {
          this.rightHerbal = herbalInfo;
        }

        if (this.leftHerbal && this.rightHerbal) {
          this.generateCompareItems();
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
    items.push(new CompareItem('药性', this.leftHerbal.nature || '-', this.rightHerbal.nature || '-',
      this.leftHerbal.nature === this.rightHerbal.nature));
    items.push(new CompareItem('药味', this.leftHerbal.taste || '-', this.rightHerbal.taste || '-',
      this.leftHerbal.taste === this.rightHerbal.taste));
    items.push(new CompareItem('归经', this.leftHerbal.meridian || '-', this.rightHerbal.meridian || '-',
      this.leftHerbal.meridian === this.rightHerbal.meridian));
    items.push(new CompareItem('功效', this.leftHerbal.efficacySummary || '-', this.rightHerbal.efficacySummary || '-',
      this.leftHerbal.efficacySummary === this.rightHerbal.efficacySummary));
    items.push(new CompareItem('主治', this.leftHerbal.indication || '-', this.rightHerbal.indication || '-',
      this.leftHerbal.indication === this.rightHerbal.indication));
    items.push(new CompareItem('用法用量', this.leftHerbal.usageDosage || '-', this.rightHerbal.usageDosage || '-',
      this.leftHerbal.usageDosage === this.rightHerbal.usageDosage));
    items.push(new CompareItem('禁忌注意', this.leftHerbal.contraindication || '-', this.rightHerbal.contraindication || '-',
      this.leftHerbal.contraindication === this.rightHerbal.contraindication));

    this.compareItems = items;
  }

  selectLeftHerbal(id: string): void {
    this.leftHerbalId = id;
    this.showLeftPicker = false;
    this.loadHerbalDetail(id, true);
  }

  selectRightHerbal(id: string): void {
    this.rightHerbalId = id;
    this.showRightPicker = false;
    this.loadHerbalDetail(id, false);
  }

  @Builder
  buildCompareRow(item: CompareItem) {
    Column() {
      Row() {
        Text(item.label)
          .fontSize(this.isElderMode ? 15 : 14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .width(80);

        Column() {
          Text(item.leftValue)
            .fontSize(this.isElderMode ? 14 : 13)
            .fontColor(item.isSame ? '#52C41A' : '#FF4D4F')
            .lineHeight(20);
        }
        .layoutWeight(1)
        .padding(10)
        .backgroundColor(item.isSame ? '#F6FFED' : '#FFF2F0')
        .borderRadius(8)
        .alignItems(HorizontalAlign.Center);

        Column() {
          Text(item.rightValue)
            .fontSize(this.isElderMode ? 14 : 13)
            .fontColor(item.isSame ? '#52C41A' : '#FF4D4F')
            .lineHeight(20);
        }
        .layoutWeight(1)
        .padding(10)
        .backgroundColor(item.isSame ? '#F6FFED' : '#FFF2F0')
        .borderRadius(8)
        .alignItems(HorizontalAlign.Center);
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)
      .padding({ bottom: 8 });

      if (!item.isSame) {
        Row() {
          Text('⚠️ 差异')
            .fontSize(12)
            .fontColor('#FAAD14')
            .margin({ left: 80 });
        }
        .width('100%');
      }
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#FFFFFF')
    .borderRadius(8);
  }

  build() {
    Column() {
      Row() {
        Text('←')
          .fontSize(20)
          .fontColor('#1677FF')
          .onClick(() => router.back());

        Text('药材对比')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center);
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .justifyContent(FlexAlign.Center);

      Scroll() {
        Column({ space: 16 }) {
          Text('选择两味药材进行对比')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .width('100%');

          Row({ space: 12 }) {
            Column({ space: 8 }) {
              Text('药材 A')
                .fontSize(13)
                .fontColor('#666666')
                .width('100%');

              Stack({ alignContent: Alignment.End }) {
                Text(this.leftHerbal ? this.leftHerbal.name : '请选择药材')
                  .fontSize(this.isElderMode ? 16 : 15)
                  .fontColor(this.leftHerbal ? '#333333' : '#999999')
                  .width('100%')
                  .padding(12)
                  .backgroundColor('#F5F7FA')
                  .borderRadius(8);

                Text('▼')
                  .fontSize(12)
                  .fontColor('#666666')
                  .margin({ right: 12 });
              }
              .width('100%')
              .onClick(() => {
                this.showLeftPicker = !this.showLeftPicker;
                this.showRightPicker = false;
              });

              if (this.showLeftPicker) {
                Scroll() {
                  Column() {
                    ForEach(this.herbalList, (herbal: HerbalListItem) => {
                      Text(herbal.name)
                        .fontSize(14)
                        .fontColor('#333333')
                        .width('100%')
                        .height(40)
                        .padding({ left: 12 })
                        .backgroundColor(this.leftHerbalId === herbal.id ? '#E6F4FF' : '#FFFFFF')
                        .onClick(() => this.selectLeftHerbal(herbal.id));
                    }, (herbal: HerbalListItem) => herbal.id);
                  }
                }
                .width('100%')
                .height(200)
                .border({ width: 1, color: '#E0E0E0', radius: 8 })
                .constraintSize({ maxHeight: 200 })
                .shadow({ radius: 4, color: '#00000015' });
              }
            }
            .layoutWeight(1);

            Text('VS')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1677FF')
              .margin({ top: 20 });

            Column({ space: 8 }) {
              Text('药材 B')
                .fontSize(13)
                .fontColor('#666666')
                .width('100%');

              Stack({ alignContent: Alignment.End }) {
                Text(this.rightHerbal ? this.rightHerbal.name : '请选择药材')
                  .fontSize(this.isElderMode ? 16 : 15)
                  .fontColor(this.rightHerbal ? '#333333' : '#999999')
                  .width('100%')
                  .padding(12)
                  .backgroundColor('#F5F7FA')
                  .borderRadius(8);

                Text('▼')
                  .fontSize(12)
                  .fontColor('#666666')
                  .margin({ right: 12 });
              }
              .width('100%')
              .onClick(() => {
                this.showRightPicker = !this.showRightPicker;
                this.showLeftPicker = false;
              });

              if (this.showRightPicker) {
                Scroll() {
                  Column() {
                    ForEach(this.herbalList, (herbal: HerbalListItem) => {
                      Text(herbal.name)
                        .fontSize(14)
                        .fontColor('#333333')
                        .width('100%')
                        .height(40)
                        .padding({ left: 12 })
                        .backgroundColor(this.rightHerbalId === herbal.id ? '#E6F4FF' : '#FFFFFF')
                        .onClick(() => this.selectRightHerbal(herbal.id));
                    }, (herbal: HerbalListItem) => herbal.id);
                  }
                }
                .width('100%')
                .height(200)
                .border({ width: 1, color: '#E0E0E0', radius: 8 })
                .constraintSize({ maxHeight: 200 })
                .shadow({ radius: 4, color: '#00000015' });
              }
            }
            .layoutWeight(1);
          }
          .width('100%');

          if (this.isLoading) {
            Column() {
              LoadingProgress()
                .width(40)
                .height(40)
                .color('#1677FF');
              Text('加载中...')
                .fontSize(14)
                .fontColor('#666666')
                .margin({ top: 12 });
            }
            .width('100%')
            .height(300)
            .justifyContent(FlexAlign.Center);
          } else if (this.compareItems.length > 0) {
            Column({ space: 2 }) {
              Row() {
                Text('对比项')
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#666666')
                  .width(80);

                Text(this.leftHerbal != null ? this.leftHerbal.name : '药材 A')
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#1677FF')
                  .layoutWeight(1)
                  .textAlign(TextAlign.Center);

                Text(this.rightHerbal != null ? this.rightHerbal.name : '药材 B')
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#1677FF')
                  .layoutWeight(1)
                  .textAlign(TextAlign.Center);
              }
              .width('100%')
              .padding(12)
              .backgroundColor('#FAFAFA')
              .borderRadius({ topLeft: 8, topRight: 8 });

              ForEach(this.compareItems, (item: CompareItem) => {
                this.buildCompareRow(item);
              }, (item: CompareItem) => item.label);
            }
            .width('100%')
            .border({ width: 1, color: '#F0F0F0', radius: 12 });

            Row({ space: 8 }) {
              Text('💡 提示：')
                .fontSize(13)
                .fontColor('#666666');

              Text('绿色表示相同，红色表示差异')
                .fontSize(13)
                .fontColor('#999999');
            }
            .width('100%')
            .padding(12)
            .backgroundColor('#FFFBE6')
            .borderRadius(8);
          } else {
            Column({ space: 16 }) {
              Text('⚖️')
                .fontSize(64);

              Text('请选择两味药材进行对比')
                .fontSize(16)
                .fontColor('#666666');

              Text('支持从性味归经、功效用法等多维度对比')
                .fontSize(13)
                .fontColor('#999999');
            }
            .width('100%')
            .height(400)
            .justifyContent(FlexAlign.Center);
          }
        }
        .width('90%')
        .padding({ top: 20, bottom: 40 });
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top);
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }
}
