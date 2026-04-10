import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';

@Entry
@Component
struct DepartmentPage {
  @State departments: string[] = ['内科', '外科', '老年病科', '骨科', '康复科'];
  @State selectedDept: number = -1;

  build() {
    Column() {
      Header({ title: '科室选择', showBack: true });

      Column({ space: 16 }) {
        Text('选择科室')
          .fontSize(24)
          .fontWeight('bold')
          .fontColor('#1677FF')
          .margin({ top: 20, bottom: 16 });

        ForEach(this.departments, (item: string, index: number) => {
          Row() {
            Column() {
              Text(item)
                .fontSize(18)
                .fontWeight('bold')
                .fontColor(this.selectedDept === index ? '#FFFFFF' : '#1677FF');
            }
            .width(56)
            .height(56)
            .backgroundColor(this.selectedDept === index ? '#1677FF' : '#1677FF20')
            .borderRadius(28)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)

            Column() {
              Text(item)
                .fontSize(16)
                .fontWeight('bold')
                .fontColor('#333333')
                .margin({ bottom: 4 });
              Text('点击进入' + item + '预约管理')
                .fontSize(13)
                .fontColor('#666666');
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
            .margin({ left: 16 });

            Text('›')
              .fontSize(22)
              .fontColor('#999999');
          }
          .width('100%')
          .padding(16)
          .backgroundColor(this.selectedDept === index ? '#E6F4FF' : '#FFFFFF')
          .borderRadius(8)
          .border({ width: 1, color: this.selectedDept === index ? '#1677FF' : '#f0f0f0' })
          .onClick(() => {
            this.selectedDept = index;
            router.pushUrl({ url: 'pages/Appointments' });
          });
        }, (item: string, index: number) => item + '_' + index.toString());
      }
      .flexGrow(1)
      .width('80%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center);

      Footer({ activeIndex: 1 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }
}
