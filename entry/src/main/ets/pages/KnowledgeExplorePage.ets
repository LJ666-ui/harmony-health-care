import { Footer } from '../components/Footer';
import { Header } from '../components/Header';
import { GraphCanvas } from '../components/GraphCanvas';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import { GlobalTheme } from '../global';

class SearchNode {
  id: number = 0;
  name: string = '';
  nodeType: string = '';
  alias: string = '';
  description: string = '';
  isCoreNode: number = 0;
}

class SearchRequestParams {
  keyword: string = '';
}

@Entry
@Component
struct KnowledgeExplorePage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State searchKeyword: string = '';
  @State searchResults: SearchNode[] = [];
  @State showDropdown: boolean = false;
  @State graphKey: number = 0;
  @State currentCenterId: number = 1;
  @State currentCenterName: string = '';
  private searchTimer: number = -1;
  private graphCanvasRef: GraphCanvas | null = null;

  aboutToDisappear(): void {
    this.clearSearchTimer();
  }

  private clearSearchTimer(): void {
    if (this.searchTimer !== -1) {
      try { clearTimeout(this.searchTimer); } catch (e) {}
      this.searchTimer = -1;
    }
  }

  private doSearch(): void {
    this.clearSearchTimer();
    const keyword: string = this.searchKeyword.trim();
    if (keyword.length === 0) {
      this.searchResults = [];
      this.showDropdown = false;
      return;
    }
    this.searchTimer = setTimeout(() => {
      const searchParams: SearchRequestParams = new SearchRequestParams();
      searchParams.keyword = keyword;
      HttpUtil.get<SearchNode[]>(ApiConstants.KNOWLEDGE_SEARCH, searchParams)
        .then((response: BaseResponse<SearchNode[]>) => {
          if (response.success && response.data) {
            this.searchResults = response.data.slice(0, 3);
            this.showDropdown = this.searchResults.length > 0;
          } else {
            this.searchResults = [];
            this.showDropdown = false;
          }
        })
        .catch(() => {
          this.searchResults = [];
          this.showDropdown = false;
        });
    }, 300);
  }

  private selectSearchResult(node: SearchNode): void {
    this.searchKeyword = '';
    this.showDropdown = false;
    this.searchResults = [];
    this.currentCenterId = node.id;
    this.currentCenterName = node.name;
    this.graphKey++;
  }

  private getTypeIcon(nodeType: string): string {
    if (nodeType === 'DISEASE') { return '🏥'; }
    if (nodeType === 'SYMPTOM') { return '🩺'; }
    if (nodeType === 'HERBAL') { return '🌿'; }
    if (nodeType === 'PRESCRIPTION') { return '💊'; }
    if (nodeType === 'THERAPY') { return '💆'; }
    return '📋';
  }

  private getTypeName(nodeType: string): string {
    if (nodeType === 'DISEASE') { return '疾病'; }
    if (nodeType === 'SYMPTOM') { return '症状'; }
    if (nodeType === 'HERBAL') { return '药材'; }
    if (nodeType === 'PRESCRIPTION') { return '方剂'; }
    if (nodeType === 'THERAPY') { return '疗法'; }
    return '其他';
  }

  build(): void {
    Column() {
      Header({
        title: '知识图谱',
        showBack: true
      });

      Column({ space: 0 }) {
        Column() {
          Row({ space: 8 }) {
            Stack() {
              TextInput({ placeholder: '搜索节点名称...' })
                .layoutWeight(1)
                .height(40)
                .fontSize(14)
                .backgroundColor('#FFFFFF')
                .borderRadius(20)
                .padding({ left: 16, right: 16 })
                .onChange((value: string) => {
                  this.searchKeyword = value;
                  this.doSearch();
                })
                .onSubmit(() => {
                  this.showDropdown = false;
                });

              if (this.searchKeyword.length > 0) {
                Text('✕')
                  .fontSize(16)
                  .fontColor('#999999')
                  .position({ x: '100%', y: '50%' })
                  .translate({ x: -36, y: -8 })
                  .onClick(() => {
                    this.searchKeyword = '';
                    this.searchResults = [];
                    this.showDropdown = false;
                  });
              }
            }
          }
          .width('100%');

          if (this.showDropdown && this.searchResults.length > 0) {
            Column() {
              ForEach(this.searchResults, (item: SearchNode, index: number) => {
                Row({ space: 10 }) {
                  Text(this.getTypeIcon(item.nodeType))
                    .fontSize(18);
                  Column({ space: 2 }) {
                    Text(item.name)
                      .fontSize(14)
                      .fontColor('#333333')
                      .fontWeight(500);
                    Text(this.getTypeName(item.nodeType))
                      .fontSize(11)
                      .fontColor('#999999');
                  }
                  .alignItems(HorizontalAlign.Start);
                  Blank();
                  Text('›')
                    .fontSize(18)
                    .fontColor('#CCCCCC');
                }
                .width('100%')
                .padding({ left: 16, right: 16, top: 10, bottom: 10 })
                .onClick(() => {
                  this.selectSearchResult(item);
                });

                if (index < this.searchResults.length - 1) {
                  Divider().color('#F0F0F0');
                }
              }, (item: SearchNode, index: number) => 'search-' + item.id + '-' + index);
            }
            .width('100%')
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .border({ width: 1, color: '#F0F0F0' })
            .shadow({
              radius: 8,
              color: '#00000010',
              offsetX: 0,
              offsetY: 4
            })
            .margin({ top: 4 });
          }
        }
        .width('100%')
        .padding({ left: 12, right: 12, top: 8, bottom: 4 });

        if (this.currentCenterName) {
          Row() {
            Text('当前中心: ')
              .fontSize(12)
              .fontColor('#999999');
            Text(this.currentCenterName)
              .fontSize(12)
              .fontColor('#1677FF')
              .fontWeight(500);
          }
          .width('100%')
          .padding({ left: 16, top: 4, bottom: 4 });
        }

        GraphCanvas({ startCenterId: this.currentCenterId })
          .key('graph-' + this.graphKey)
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
}
