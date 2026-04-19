import { Footer } from '../components/Footer';
import { Header } from '../components/Header';
import { GraphCanvas } from '../components/GraphCanvas';
import { GlobalTheme } from '../global';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';

interface SearchNode {
  id: number;
  name: string;
  nodeType: string;
  description: string;
}

@Entry
@Component
struct KnowledgeGraphPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State searchText: string = '';
  @State showSearch: boolean = false;
  @State searchResults: SearchNode[] = [];

  handleSearch(): void {
    if (!this.searchText.trim()) {
      this.showSearch = false;
      return;
    }

    HttpUtil.get<SearchNode[]>(ApiConstants.KNOWLEDGE_SEARCH, {
      "keyword": this.searchText.trim()
    })
      .then((response: BaseResponse<SearchNode[]>) => {
        if (response.success && response.data) {
          this.searchResults = response.data;
          this.showSearch = this.searchResults.length > 0;
        }
      })
      .catch(() => {
        this.searchResults = [];
        this.showSearch = false;
      });
  }

  build(): void {
    Column() {
      Header({
        title: '中医知识图谱',
        showBack: true
      });

      Column({ space: 8 }) {
        Row({ space: 8 }) {
          TextInput({ placeholder: '搜索疾病、症状、药材...' })
            .layoutWeight(1)
            .height(40)
            .fontSize(14)
            .backgroundColor('#FFFFFF')
            .borderRadius(20)
            .onChange((value: string) => {
              this.searchText = value;
            })
            .onSubmit(() => this.handleSearch());

          Button('搜索')
            .height(40)
            .fontSize(14)
            .fontColor('#FFFFFF')
            .backgroundColor('#1677FF')
            .borderRadius(20)
            .onClick(() => this.handleSearch());
        }
        .width('100%')
        .padding({ left: 12, right: 12, top: 8 });

        if (this.showSearch && this.searchResults.length > 0) {
          Scroll() {
            Column({ space: 6 }) {
              ForEach(this.searchResults, (node: SearchNode) => {
                Row() {
                  Text(this.getNodeIcon(node.nodeType))
                    .fontSize(18)
                    .margin({ right: 8 });
                  Column({ space: 2 }) {
                    Text(node.name)
                      .fontSize(14)
                      .fontWeight('bold')
                      .fontColor(GlobalTheme.TEXT_PRIMARY);
                    if (node.description) {
                      Text(node.description)
                        .fontSize(11)
                        .fontColor(GlobalTheme.TEXT_SECONDARY)
                        .maxLines(1);
                    }
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start);
                  Text('查看')
                    .fontSize(12)
                    .fontColor('#1677FF');
                }
                .width('100%')
                .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                .backgroundColor(GlobalTheme.CARD_BG)
                .borderRadius(GlobalTheme.RADIUS_MD)
                .onClick(() => {
                  this.showSearch = false;
                });
              }, (node: SearchNode) => `search-${node.id}`);
            }
            .padding({ left: 12, right: 12 });
          }
          .height(120)
          .scrollBar(BarState.Auto);
        }

        GraphCanvas()
          .width('100%')
          .layoutWeight(1);
      }
      .width('100%')
      .layoutWeight(1);

      Footer({ activeIndex: 3 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }

  getNodeIcon(nodeType: string): string {
    if (nodeType === 'DISEASE') {
      return '🏥';
    }
    if (nodeType === 'SYMPTOM') {
      return '🩺';
    }
    if (nodeType === 'HERBAL') {
      return '🌿';
    }
    if (nodeType === 'PRESCRIPTION') {
      return '💊';
    }
    if (nodeType === 'THERAPY') {
      return '💆';
    }
    return '📋';
  }
}
