import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { IconCard } from '../components/Card';

@Entry
@Component
struct RehabPage {
  build() : void {
    Column() {
      Header({ 
        title: '康复', 
        showBack: false
      });
      
      Column({
        space: 16
      }) {
        Text('康复模块')
          .fontSize(24)
          .fontWeight('bold')
          .fontColor('#1677FF')
          .margin({ top: 20, bottom: 16 });
        
        Column() {
          IconCard({
            icon: '🏃',
            iconColor: '#1677FF',
            iconBackgroundColor: '#1677FF20',
            title: '康复课程',
            description: '专业康复训练课程'
          })
        }
        .onClick(() => {
          router.pushUrl({ url: 'pages/RehabListPage' });
        });
      }
      .flexGrow(1)
      .width('80%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center);
      
      Footer({ activeIndex: 2 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }
}
