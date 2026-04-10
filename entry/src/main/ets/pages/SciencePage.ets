import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';

@Entry
@Component
struct SciencePage {
  build() : void {
    Column() {
      // 顶部导航栏
      Header({ 
        title: '科普', 
        showBack: false
      });
      
      // 中间内容区
      Column({
        space: 16
      }) {
        // 页面标题
        Text('科普模块')
          .fontSize(24)
          .fontWeight('bold')
          .fontColor('#1677FF')
          .margin({ top: 20, bottom: 16 });
        
        // 科普模块内容
        Text('科普模块页面')
          .fontSize(16)
          .fontColor('#666666')
          .margin({ top: 40 });
      }
      .flexGrow(1)
      .width('80%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center);
      
      // 底部Tab栏
      Footer({ activeIndex: 3 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }
}
