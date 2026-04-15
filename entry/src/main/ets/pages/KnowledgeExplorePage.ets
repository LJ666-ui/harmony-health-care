import http from '@ohos.net.http';
import { Footer } from '../components/Footer';
import { GraphCanvas } from '../components/GraphCanvas';
import { Header } from '../components/Header';

@Entry
@Component
struct KnowledgeExplorePage {
  @State inputText: string = '';
  @State isLoading: boolean = false;
  @State graphVersion: number = 0;

  build(): void {
    Column() {
      Header({
        title: 'AI 知识探索',
        showBack: true
      });

      Column({ space: 12 }) {
        Row({ space: 8 }) {
          TextInput({ placeholder: '输入问题，如：高血压怎么治？' })
            .layoutWeight(1)
            .height(40)
            .fontSize(14)
            .backgroundColor('#FFFFFF')
            .borderRadius(20)
            .onChange((value: string) => {
              this.inputText = value;
            });

          Button('发送')
            .height(40)
            .fontSize(14)
            .fontColor('#FFFFFF')
            .backgroundColor('#1677FF')
            .borderRadius(20)
            .onClick(() => {
              if (this.inputText.length > 0) {
                this.isLoading = true;
                setTimeout(() => {
                  this.isLoading = false;
                  this.graphVersion++;
                }, 500);
              }
            });
        }
        .width('100%')
        .padding({ left: 12, right: 12 });

        if (this.isLoading) {
          Text('正在分析...')
            .fontSize(14)
            .fontColor('#666')
            .width('100%')
            .height(200)
            .textAlign(TextAlign.Center);
        } else {
          GraphCanvas()
            .width('100%')
            .height(400);

          Text('AI探索功能开发中...')
            .fontSize(13)
            .fontColor('#999')
            .padding(16);
        }
      }
      .width('88%')
      .layoutWeight(1);

      Footer({ activeIndex: 3 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }
}
