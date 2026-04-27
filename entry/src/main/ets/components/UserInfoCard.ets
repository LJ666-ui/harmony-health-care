import { AccessibilityConfig } from '../utils/AccessibilityConfig';

@Component
export struct UserInfoCard {
  @Prop avatar: string = '';
  @Prop username: string = '星云用户';
  @Prop phone: string = '138****1234';
  @Prop userId: number = 10086;
  @StorageLink('isOldModeEnabled') isOldModeEnabled: boolean = false;

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 135,
          colors: [['#1677FF', 0], ['#36CFC9', 1]]
        });

      Row() {
        Column() {
          Row() {
            Row() {
              Text('👤')
                .fontSize(32)
                .fontColor('#FFFFFF');
            }
            .width(64)
            .height(64)
            .backgroundColor('#FFFFFF33')
            .borderRadius(32)
            .border({ width: 3, color: '#FFFFFF' });
          }
          .margin({ bottom: 8 });

          Text(this.username)
            .fontSize(AccessibilityConfig.getFontSizeTitle())
            .fontColor('#FFFFFF')
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 4 });

          Text(this.phone)
            .fontSize(AccessibilityConfig.getFontSizeSmall())
            .fontColor('#FFFFFF')
            .fontFamily('HarmonyHeiTi')
            .margin({ bottom: 4 });

          Text('ID:' + this.userId)
            .fontSize(AccessibilityConfig.getFontSizeSmall())
            .fontColor('#FFFFFF')
            .fontFamily('HarmonyHeiTi');
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1);

        Text('编辑')
          .fontSize(12)
          .fontColor('#FFFFFF')
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor('#FFFFFF22')
          .borderRadius(14);
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 20, bottom: 20 });
    }
    .width('85%')
    .height(140)
    .borderRadius({
      topLeft: 20,
      topRight: 20,
      bottomLeft: 16,
      bottomRight: 16
    });
  }
}
