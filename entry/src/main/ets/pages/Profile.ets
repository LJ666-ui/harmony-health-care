import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';

@Entry
@Component
struct Profile {
  build(): void {
    Column() {
      Header({
        title: '个人中心',
        showBack: true
      });

      Column({
        space: 16
      }) {
        Text('个人中心')
          .fontSize(24)
          .fontWeight('bold')
          .fontColor('#1677FF')
          .margin({ top: 20, bottom: 16 });

        Column({
          space: 12
        }) {
          Row({
            space: 16
          }) {
            Circle()
              .width(80)
              .height(80)
              .fill('#4a90e220')
              .stroke('#1677FF');

            Column({
              space: 4
            }) {
              Text('星云用户')
                .fontSize(18)
                .fontWeight('bold')
                .fontColor('#333333');
              Text('138****1234')
                .fontSize(14)
                .fontColor('#666666');
            }
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .border({ width: 1, color: '#f0f0f0' });
        }

        Column({
          space: 1
        }) {
          Row({
            space: 12
          }) {
            Text('📱 设备绑定')
              .fontSize(16)
              .fontColor('#1677FF')
              .fontWeight('bold');
            Blank()
              .layoutWeight(1);
            Text('›')
              .fontSize(20)
              .fontColor('#999999');
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius({ topLeft: 12, topRight: 12 })
          .border({ width: 1, color: '#f0f0f0' })
          .onClick(() => {
            router.pushUrl({ url: 'pages/DeviceDiscoveryPage' });
          });

          Row({
            space: 12
          }) {
            Text('我的健康')
              .fontSize(16)
              .fontColor('#333333');
            Blank()
              .layoutWeight(1);
            Text('›')
              .fontSize(20)
              .fontColor('#999999');
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .onClick(() => {
            router.pushUrl({ url: 'pages/HealthPage' });
          });

          Row({
            space: 12
          }) {
            Text('我的病历')
              .fontSize(16)
              .fontColor('#333333');
            Blank()
              .layoutWeight(1);
            Text('›')
              .fontSize(20)
              .fontColor('#999999');
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .onClick(() => {
            router.pushUrl({ url: 'pages/MedicalRecord' });
          });



          Row({
            space: 12
          }) {
            Text('账号设置')
              .fontSize(16)
              .fontColor('#333333');
            Blank()
              .layoutWeight(1);
            Text('›')
              .fontSize(20)
              .fontColor('#999999');
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF');

          Row({
            space: 12
          }) {
            Text('隐私设置')
              .fontSize(16)
              .fontColor('#333333');
            Blank()
              .layoutWeight(1);
            Text('›')
              .fontSize(20)
              .fontColor('#999999');
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF');

          Row({
            space: 12
          }) {
            Text('关于我们')
              .fontSize(16)
              .fontColor('#333333');
            Blank()
              .layoutWeight(1);
            Text('›')
              .fontSize(20)
              .fontColor('#999999');
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius({ bottomLeft: 12, bottomRight: 12 })
          .border({ width: 1, color: '#f0f0f0' });
        }

        Button('退出登录')
          .width('100%')
          .height(48)
          .fontSize(16)
          .fontColor('#FFFFFF')
          .backgroundColor('#1677FF')
          .borderRadius(8)
          .margin({ top: 20, bottom: 20 })
          .onClick(() : void => {
            router.pushUrl({ url: 'pages/Index' });
          });
      }
      .flexGrow(1)
      .width('80%')
      .justifyContent(FlexAlign.Center);

      Footer({ activeIndex: 4 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }
}
