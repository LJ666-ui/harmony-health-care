import { router } from '@kit.ArkUI';

@Entry
@Component
struct SplashPage {
  @State opacityValue: number = 0;

  aboutToAppear(): void {
    setTimeout(() => {
      this.opacityValue = 1;
    }, 100);

    setTimeout(() => {
      router.replaceUrl({ url: 'pages/Login' });
    }, 2500);
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Image($r('app.media.login_bg'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover);

      Column() {
        Text('星云医联')
          .fontSize(42)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .textShadow({
            radius: 20,
            color: '#00D4FF90',
            offsetX: 0,
            offsetY: 0
          })
          .letterSpacing(6);

        Text('智慧医疗 · 健康守护')
          .fontSize(16)
          .fontColor('#FFFFFFCC')
          .margin({ top: 12 })
          .letterSpacing(2);
      }
      .opacity(this.opacityValue)
      .animation({
        duration: 800,
        curve: Curve.EaseOut
      });
    }
    .width('100%')
    .height('100%');
  }
}
