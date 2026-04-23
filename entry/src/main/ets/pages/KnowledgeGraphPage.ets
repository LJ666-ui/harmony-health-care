import { Footer } from '../components/Footer';
import { Header } from '../components/Header';
import { GraphCanvas } from '../components/GraphCanvas';
import { GlobalTheme } from '../global';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import BrowseTracker from '../utils/BrowseTracker';

interface SearchNode {
  id: number;
  name: string;
  nodeType: string;
  description: string;
}

interface SearchRequestParams {
  keyword: string;
}

@Entry
@Component
struct KnowledgeGraphPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State searchText: string = '';
  @State showDropdown: boolean = false;
  @State searchResults: SearchNode[] = [];
  @State recordId: number = 0;
  @State isFullscreen: boolean = false;
  @State searchTimer: number = -1;
  @State navigateNodeId: number = -1;
  private graphCanvas: GraphCanvas | null = null;

  aboutToAppear(): void {
    BrowseTracker.recordStart('KNOWLEDGE_GRAPH', 'PAGE', 5, '中医知识图谱').then(id => {
      this.recordId = id;
    });
  }

  aboutToDisappear(): void {
    if (this.recordId > 0) {
      BrowseTracker.recordEnd(this.recordId);
    }
    if (this.searchTimer !== -1) {
      try {
        clearTimeout(this.searchTimer);
      } catch (e) {
        // 忽略清理定时器的异常
      }
    }
  }

  handleSearchInput(value: string): void {
    this.searchText = value;
    if (this.searchTimer !== -1) {
      try {
        clearTimeout(this.searchTimer);
      } catch (e) {
        // 忽略清理定时器的异常
      }
    }
    if (!value.trim()) {
      this.showDropdown = false;
      this.searchResults = [];
      return;
    }
    try {
      this.searchTimer = setTimeout(() => {
        this.fuzzySearch(value.trim());
      }, 300);
    } catch (e) {
      // 忽略启动定时器的异常
    }
  }

  fuzzySearch(keyword: string): void {
    const searchParams: SearchRequestParams = {
      keyword: keyword
    };

    HttpUtil.get<SearchNode[]>(ApiConstants.KNOWLEDGE_SEARCH, searchParams)
      .then((response: BaseResponse<SearchNode[]>) => {
        if (response.success && response.data) {
          this.searchResults = response.data.slice(0, 5);
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
  }

  handleSelectSearchResult(node: SearchNode): void {
    this.showDropdown = false;
    this.searchText = node.name;
    this.navigateNodeId = node.id;
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

  getTypeName(nodeType: string): string {
    if (nodeType === 'DISEASE') {
      return '疾病';
    }
    if (nodeType === 'SYMPTOM') {
      return '症状';
    }
    if (nodeType === 'HERBAL') {
      return '药材';
    }
    if (nodeType === 'PRESCRIPTION') {
      return '方剂';
    }
    if (nodeType === 'THERAPY') {
      return '疗法';
    }
    return '其他';
  }

  build(): void {
    Column() {
      if (!this.isFullscreen) {
        Header({
          title: '中医知识图谱',
          showBack: true
        });
      }

      Column({ space: 0 }) {
        Row({ space: 8 }) {
          Stack() {
            TextInput({ placeholder: '搜索疾病、症状、药材...', text: this.searchText })
              .layoutWeight(1)
              .height(40)
              .fontSize(14)
              .backgroundColor('#FFFFFF')
              .borderRadius(20)
              .padding({ left: 16, right: 36 })
              .onChange((value: string) => {
                this.handleSearchInput(value);
              })
              .onSubmit(() => {
                if (this.searchText.trim()) {
                  this.fuzzySearch(this.searchText.trim());
                }
              });

            if (this.searchText.length > 0) {
              Text('✕')
                .fontSize(14)
                .fontColor('#999999')
                .position({ x: '100%', y: '50%' })
                .translate({ x: -36, y: -7 })
                .onClick(() => {
                  this.searchText = '';
                  this.showDropdown = false;
                  this.searchResults = [];
                });
            }
          }
          .layoutWeight(1);

          Text(this.isFullscreen ? '退出' : '全屏')
            .fontSize(13)
            .fontColor('#1677FF')
            .backgroundColor('#E6F4FF')
            .padding({ left: 10, right: 10, top: 8, bottom: 8 })
            .borderRadius(16)
            .onClick(() => {
              this.isFullscreen = !this.isFullscreen;
            });
        }
        .width('100%')
        .padding({ left: 12, right: 12, top: 8, bottom: 4 });

        if (this.showDropdown && this.searchResults.length > 0) {
          Column({ space: 0 }) {
            ForEach(this.searchResults, (node: SearchNode, index: number) => {
              Row() {
                Text(this.getNodeIcon(node.nodeType))
                  .fontSize(18)
                  .margin({ right: 10 });
                Column({ space: 2 }) {
                  Text(node.name)
                    .fontSize(14)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#333333');
                  if (node.description) {
                    Text(node.description)
                      .fontSize(11)
                      .fontColor('#999999')
                      .maxLines(1);
                  }
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start);
                Text(this.getTypeName(node.nodeType))
                  .fontSize(10)
                  .fontColor('#1677FF')
                  .backgroundColor('#E6F4FF')
                  .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                  .borderRadius(8);
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 10, bottom: 10 })
              .onClick(() => {
                this.handleSelectSearchResult(node);
              });

              if (index < this.searchResults.length - 1) {
                Divider()
                  .width('90%')
                  .color('#F0F0F0');
              }
            }, (node: SearchNode) => 'search-' + node.id);
          }
          .width('92%')
          .margin({ left: '4%', right: '4%' })
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .shadow({ radius: 8, color: '#00000012', offsetX: 0, offsetY: 2 });
        }

        GraphCanvas({ startCenterId: 1 })
          .width('100%')
          .layoutWeight(1);
      }
      .width('100%')
      .layoutWeight(1);

      if (!this.isFullscreen) {
        Footer({ activeIndex: 3 });
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }
}
