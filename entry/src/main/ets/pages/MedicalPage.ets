import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { IconCard } from '../components/Card';

@Entry
@Component
struct MedicalPage {
  build() : void {
    Column() {
      // 顶部导航栏
      Header({ 
        title: '就医', 
        showBack: false
      });
      
      // 中间内容区
      Column({
        space: 16
      }) {
        // 页面标题
        Text('就医模块')
          .fontSize(24)
          .fontWeight('bold')
          .fontColor('#1677FF')
          .margin({ top: 20, bottom: 16 });
        
        // 就医模块内容
        IconCard({
          icon: '🏥',
          iconColor: '#1677FF',
          iconBackgroundColor: '#1677FF20',
          title: '就医服务',
          description: '提供便捷的就医服务'
        })
          .onClick(() => {
            router.pushUrl({ url: 'pages/HospitalPage' });
          });
      }
      .flexGrow(1)
      .width('80%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center);
      
      // 底部Tab栏
      Footer({ activeIndex: 1 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }
}
