import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';

@Entry
@Component
struct ARNavigationPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State targetDept: string = '内科·302诊室';
  @State distance: string = '85米 | 约2分钟';

  @State routeSteps: string[] = [
    '当前位置',
    '直行 50米',
    '左转',
    '直行 35米',
    '到达目标科室'
  ];

  @State currentStep: number = 1;

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') ?? false;
    }
  }

  handleBack(): void {
    router.back();
  }

  build() {
    Column() {
      Column() {
        Row() {
          Text('←')
            .fontSize(28)
            .fontColor('#FFFFFF')
            .width(44)
            .height(44)
            .textAlign(TextAlign.Center)
            .backgroundColor('#00000040')
            .borderRadius(22)
            .onClick(() => this.handleBack());

          Blank();

          Column({ space: 4 }) {
            Text(this.targetDept)
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontWeight('bold')
              .fontColor('#FFFFFF')
              .textAlign(TextAlign.Center);

            Text(this.distance)
              .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
              .fontColor('#FFFFFF99')
              .textAlign(TextAlign.Center);
          }
          .alignItems(HorizontalAlign.Center);

          Blank();
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 12 });
      }
      .width('100%')
      .backgroundColor('#00000060');

      Stack({ alignContent: Alignment.Center }) {
        Column()
          .width('100%')
          .height('100%')
          .linearGradient({
            angle: 180,
            colors: [['#0A1628', 0], ['#1A3A5C', 0.5], ['#0D2137', 1]]
          });

        Column({ space: 24 }) {
          Column() {
            Text('↑')
              .fontSize(this.isElderMode ? 80 : 64)
              .fontColor('#1677FF')
              .fontWeight('bold');

            Text('直行 50米')
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Medium);
          }
          .alignItems(HorizontalAlign.Center);

          Column({ space: 8 }) {
            Row({ space: 8 }) {
              ForEach([1, 2, 3], (item: number) => {
                Text('—')
                  .fontSize(20)
                  .fontColor('#1677FF80');
              })
            }

            Text('◀ 左转')
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontColor('#52C41A')
              .fontWeight(FontWeight.Bold);
          }
          .alignItems(HorizontalAlign.Center);

          Column() {
            Text('↑')
              .fontSize(this.isElderMode ? 80 : 64)
              .fontColor('#1677FF')
              .fontWeight('bold');

            Text('直行 35米')
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Medium);
          }
          .alignItems(HorizontalAlign.Center);

          Column({ space: 12 }) {
            Text('🏥')
              .fontSize(this.isElderMode ? 56 : 48);

            Text('到达目标科室')
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontColor('#52C41A')
              .fontWeight('bold');
          }
          .alignItems(HorizontalAlign.Center);
        }
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center);

        Column() {
          ForEach(['📍 您的位置', '', '', '', '🏥 目的地'], (label: string, index: number) => {
            if (label) {
              Text(label)
                .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                .fontColor(index === 0 ? '#1677FF' : '#52C41A')
                .backgroundColor(index === 0 ? '#1677FF20' : '#52C41A20')
                .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                .borderRadius(12);
            } else {
              Column().height(80);
            }
          });
        }
        .position({ x: 20, y: 80 });
      }
      .layoutWeight(1)
      .width('100%');

      Column() {
        Column({ space: 12 }) {
          Text('路线指引')
            .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
            .fontWeight('bold')
            .fontColor('#333333')
            .width('100%')
            .textAlign(TextAlign.Center);

          Row({ space: 8 }) {
            ForEach(this.routeSteps, (step: string, index: number) => {
              Column({ space: 4 }) {
                if (index < this.routeSteps.length - 1) {
                  Text(step)
                    .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                    .fontColor(index === this.currentStep ? '#1677FF' : index < this.currentStep ? '#999999' : '#666666')
                    .fontWeight(index === this.currentStep ? FontWeight.Bold : FontWeight.Normal);

                  Text('↓')
                    .fontSize(14)
                    .fontColor('#CCCCCC');
                } else {
                  Text(step)
                    .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                    .fontColor('#52C41A')
                    .fontWeight(FontWeight.Bold);
                }
              }
              .alignItems(HorizontalAlign.Center);
            });
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .padding({ left: 8, right: 8 });
        }
        .width('85%')
        .padding(GlobalTheme.getSpacingMD(this.isElderMode))
        .backgroundColor('#FFFFFF')
        .borderRadius(16)
        .shadow({ radius: 12, color: '#00000015', offsetX: 0, offsetY: 4 });
      }
      .width('100%')
      .padding({ top: 12, bottom: 12 });

      Footer({ activeIndex: 1 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }
}
