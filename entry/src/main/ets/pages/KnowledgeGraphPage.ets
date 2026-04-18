import { Footer } from '../components/Footer';
import { Header } from '../components/Header';
import { GraphCanvas } from '../components/GraphCanvas';
import BrowseTracker from '../utils/BrowseTracker';

@Entry
@Component
struct KnowledgeGraphPage {
  @State recordId: number = 0;

  aboutToAppear(): void {
    BrowseTracker.recordStart('KNOWLEDGE_GRAPH', 'PAGE', 5, '中医知识图谱').then(id => {
      this.recordId = id;
    });
  }

  aboutToDisappear(): void {
    if (this.recordId > 0) {
      BrowseTracker.recordEnd(this.recordId);
    }
  }

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
