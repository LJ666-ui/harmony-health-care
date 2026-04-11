import { router } from '@kit.ArkUI';
import { GlobalTheme } from '../global';

@Entry
@Component
struct HealthRecords {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State selectedType: string = '血压';
  @State selectedTimeRange: string = '7天';

  private chartTypes: string[] = ['血压', '血糖'];
  private timeRanges: string[] = ['7天', '30天', '90天'];
  private recordTypes: string[] = ['全部', '血压', '血糖', '心率', '体温'];

  build() {
    Column() {
      Text('← 返回')
        .fontSize(16)
        .fontColor('#1677FF')
        .padding(12)
        .width('100%')
        .onClick(() => {
          router.back();
        });

      Scroll() {
        Column({ space: 16 }) {
          Text('健康记录')
            .fontSize(24)
            .fontWeight('bold')
            .fontColor('#1677FF')
            .margin({ top: 16, bottom: 12 });

          Column() {
            Text('📈 数据趋势')
              .fontSize(18)
              .fontWeight('bold')
              .fontColor('#333333')
              .margin({ bottom: 12 });

            Row({ space: 8 }) {
              ForEach(this.chartTypes, (type: string) => {
                Text(type)
                  .fontSize(14)
                  .fontColor(this.selectedType === type ? '#FFFFFF' : '#666666')
                  .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                  .backgroundColor(this.selectedType === type ? '#1677FF' : '#F0F0F0')
                  .borderRadius(16)
                  .onClick(() => { this.selectedType = type; });
              });

              Blank();

              ForEach(this.timeRanges, (range: string) => {
                Text(range)
                  .fontSize(12)
                  .fontColor(this.selectedTimeRange === range ? '#FFFFFF' : '#666666')
                  .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                  .backgroundColor(this.selectedTimeRange === range ? '#52C41A' : '#F5F5F5')
                  .borderRadius(14)
                  .onClick(() => { this.selectedTimeRange = range; });
              });
            }
            .width('100%');

            Column() {
              Text(`📊 ${this.selectedType} 数据 - ${this.selectedTimeRange}`)
                .fontSize(16)
                .fontWeight('bold')
                .fontColor('#333333')
                .margin({ bottom: 12 })

              ForEach(['04-11', '04-12', '04-13', '04-14', '04-15'], (date: string) => {
                Row() {
                  Text(date)
                    .fontSize(12)
                    .fontColor('#666666')
                    .width(60)

                  Column() {
                    Text(`${Math.floor(115 + Math.random() * 30)}/${Math.floor(60 + Math.random() * 20)}`)
                      .fontSize(14)
                      .fontWeight('bold')
                      .fontColor('#1677FF')

                    Text('正常')
                      .fontSize(11)
                      .fontColor('#52C41A');
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                }
                .width('100%')
                .padding(10)
                .backgroundColor('#FAFAFA')
                .borderRadius(8)
                .margin({ bottom: 6 });
              });
            }
            .width('100%')
            .padding(12)
            .backgroundColor('#FFFFFF')
            .borderRadius(12);
          }
          .width('85%');

          Column() {
            Text('📋 健康记录列表')
              .fontSize(18)
              .fontWeight('bold')
              .fontColor('#333333')
              .margin({ bottom: 12 });

            Scroll() {
              Row({ space: 8 }) {
                ForEach(this.recordTypes, (type: string) => {
                  Text(type)
                    .fontSize(13)
                    .fontColor('#666666')
                    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                    .backgroundColor('#F0F0F0')
                    .borderRadius(16)
                });
              }
            }
            .scrollable(ScrollDirection.Horizontal)
            .width('100%');

            ForEach([1, 2, 3], (_: number) => {
              Column() {
                Row() {
                  Text('📊 血压')
                    .fontSize(15)
                    .fontWeight('bold')
                    .fontColor('#333333');
                  Blank();
                  Text('120/80 mmHg')
                    .fontSize(14)
                    .fontWeight('bold')
                    .fontColor('#1677FF');
                }
                .width('100%');

                Text('2026-04-12 09:30')
                  .fontSize(12)
                  .fontColor('#999999')
                  .width('100%')
                  .margin({ top: 4 });

                Text('备注：血压正常范围')
                  .fontSize(12)
                  .fontColor('#666666')
                  .width('100%')
                  .margin({ top: 4 });
              }
              .width('100%')
              .padding(12)
              .backgroundColor('#FFFFFF')
              .borderRadius(10)
              .margin({ top: 8 });
            });
          }
          .width('85%');

          Button('+ 添加记录')
            .width('85%')
            .height(48)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
            .backgroundColor('#1677FF')
            .borderRadius(24)
            .margin({ top: 16 });

          Button('📊 健康风险评估')
            .width('85%')
            .height(48)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
            .backgroundColor('#52C41A')
            .borderRadius(24)
            .margin({ top: 8 });
        }
        .width('100%')
        .padding({ bottom: 80 });
      }
      .height(0)
      .layoutWeight(1)
      .scrollBar(BarState.Off);

      Row() {
        Text('🏠').fontSize(20).margin(8);
        Text('📋').fontSize(20).margin(8).fontColor('#1677FF');
        Text('💊').fontSize(20).margin(8);
        Text('📚').fontSize(20).margin(8);
        Text('👤').fontSize(20).margin(8);
      }
      .justifyContent(FlexAlign.SpaceEvenly)
      .width('100%')
      .padding(8)
      .backgroundColor('#FFFFFF')
      .shadow({ radius: 4, color: '#00000010', offsetX: 0, offsetY: -2 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }
}
