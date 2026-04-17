import { Footer } from '../components/Footer';
import { Header } from '../components/Header';
import { GraphCanvas } from '../components/GraphCanvas';

@Entry
@Component
struct KnowledgeGraphPage {
  build(): void {
    Column() {
      Header({
        title: '中医知识图谱',
        showBack: true
      });

      GraphCanvas()
        .width('100%')
        .layoutWeight(1);

      Footer({ activeIndex: 3 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }
}
