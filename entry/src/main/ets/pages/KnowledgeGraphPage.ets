import { Footer } from '../components/Footer';
import { Header } from '../components/Header';
import { GraphCanvas } from '../components/GraphCanvas';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import BrowseTracker from '../utils/BrowseTracker';

interface SearchNode {
  id: number;
  name: string;
  nodeType: string;
  description: string;
}

interface SidebarNode {
  id: number;
  name: string;
  nodeType: string;
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
  @State sidebarNodes: SidebarNode[] = [];
  @State allSidebarNodes: SidebarNode[] = [];
  @State showSidebar: boolean = true;
  @State activeCenterId: number = 1;
  @State filterType: string = '';
  @State expandCenterId: number = -1;

  aboutToAppear(): void {
    BrowseTracker.recordStart('KNOWLEDGE_GRAPH', 'PAGE', 5, '中医知识图谱').then(id => {
      this.recordId = id;
    });
    this.fetchAllNodes();
  }

  aboutToDisappear(): void {
    if (this.recordId > 0) {
      BrowseTracker.recordEnd(this.recordId);
    }
    if (this.searchTimer !== -1) {
      try {
        clearTimeout(this.searchTimer);
      } catch (e) {
      }
    }
  }

  handleSearchInput(value: string): void {
    this.searchText = value;
    if (this.searchTimer !== -1) {
      try {
        clearTimeout(this.searchTimer);
      } catch (e) {
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

  fetchAllNodes(): void {
    HttpUtil.get<SidebarNode[]>(ApiConstants.KNOWLEDGE_NODES)
      .then((response: BaseResponse<SidebarNode[]>) => {
        if (response.success && response.data) {
          this.allSidebarNodes = response.data;
          this.applyFilter();
        }
      })
      .catch(() => {});
  }

  applyFilter(): void {
    if (!this.filterType) {
      this.sidebarNodes = this.allSidebarNodes;
    } else {
      const filtered: SidebarNode[] = [];
      for (let i: number = 0; i < this.allSidebarNodes.length; i++) {
        if (this.allSidebarNodes[i].nodeType === this.filterType) {
          filtered.push(this.allSidebarNodes[i]);
        }
      }
      this.sidebarNodes = filtered;
    }
  }

  handleFilterClick(type: string): void {
    if (this.filterType === type) {
      this.filterType = '';
    } else {
      this.filterType = type;
    }
    this.applyFilter();
  }

  handleSidebarNodeClick(nodeId: number): void {
    if (this.activeCenterId === nodeId) {
      return;
    }
    this.activeCenterId = nodeId;
    this.expandCenterId = nodeId;
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
        Row({ space: 0 }) {
          if (this.showSidebar) {
            Column() {
              Column() {
                Text('📋 节点列表')
                  .fontSize(11)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                  .margin({ bottom: 4 });
                Text(this.sidebarNodes.length + '个')
                  .fontSize(9)
                  .fontColor('#FFFFFF99');
              }
              .width('100%')
              .padding({ top: 8, bottom: 6 })
              .linearGradient({
                angle: 135,
                colors: [['#1677FF', 0], ['#36CFC9', 1]]
              })
              .alignItems(HorizontalAlign.Center);

              Scroll() {
                Column({ space: 0 }) {
                  ForEach(this.sidebarNodes, (node: SidebarNode) => {
                    Column() {
                      Text(this.getNodeIcon(node.nodeType))
                        .fontSize(14);
                      Text(node.name.length > 3 ? node.name.substring(0, 3) + '..' : node.name)
                        .fontSize(9)
                        .fontColor('#333333')
                        .maxLines(1);
                    }
                    .width('100%')
                    .height(40)
                    .justifyContent(FlexAlign.Center)
                    .alignItems(HorizontalAlign.Center)
                    .backgroundColor(this.activeCenterId === node.id ? '#E6F4FF' : '#FAFBFC')
                    .border({
                      width: { left: 3, right: 0, top: 0, bottom: 0 },
                      color: this.activeCenterId === node.id ? '#1677FF' : 'transparent'
                    })
                    .gesture(
                      TapGesture()
                        .onAction(() => {
                          this.handleSidebarNodeClick(node.id);
                        })
                    );
                  }, (node: SidebarNode) => 'sidebar-' + node.id);
                }
                .width('100%');
              }
              .width('100%')
              .layoutWeight(1)
              .scrollBar(BarState.Off)
              .backgroundColor('#F5F7FA');

              Column() {
                Text('▶')
                  .fontSize(12)
                  .fontColor('#666666')
                  .padding(6)
                  .onClick(() => {
                    this.showSidebar = false;
                  });
              }
              .width('100%')
              .height(28)
              .justifyContent(FlexAlign.Center)
              .backgroundColor('#F0F0F0');
            }
            .width(52)
            .height('100%')
            .backgroundColor('#FFFFFF')
            .shadow({ radius: 4, color: '#00000010', offsetX: 2, offsetY: 0 })
            .clip(true);
          } else {
            Column() {
              Text('◀')
                .fontSize(12)
                .fontColor('#1677FF')
                .padding(8)
                .backgroundColor('#E6F4FF')
                .borderRadius({ topLeft: 0, topRight: 8, bottomRight: 8, bottomLeft: 0 })
                .onClick(() => {
                  this.showSidebar = true;
                });
            }
            .width(24)
            .height('100%')
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Start)
            .padding({ top: 20 });
          }

          Column({ space: 0 }) {
            Row({ space: 8 }) {
              Stack() {
                TextInput({ placeholder: '搜索疾病、症状、药材...', text: this.searchText })
                  .layoutWeight(1)
                  .height(36)
                  .fontSize(13)
                  .backgroundColor('#FFFFFF')
                  .borderRadius(18)
                  .padding({ left: 14, right: 34 })
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
                    .fontSize(13)
                    .fontColor('#999999')
                    .position({ x: '100%', y: '50%' })
                    .translate({ x: -32, y: -6 })
                    .onClick(() => {
                      this.searchText = '';
                      this.showDropdown = false;
                      this.searchResults = [];
                    });
                }
              }
              .layoutWeight(1);

              Text(this.isFullscreen ? '退出' : '全屏')
                .fontSize(12)
                .fontColor('#1677FF')
                .backgroundColor('#E6F4FF')
                .padding({ left: 9, right: 9, top: 7, bottom: 7 })
                .borderRadius(14)
                .onClick(() => {
                  this.isFullscreen = !this.isFullscreen;
                });
            }
            .width('100%')
            .padding({ left: 10, right: 8, top: 6, bottom: 2 });

            Row({ space: 6 }) {
              Text('🏥 疾病')
                .fontSize(11)
                .fontColor(this.filterType === 'DISEASE' ? '#FFFFFF' : '#FF4D4F')
                .backgroundColor(this.filterType === 'DISEASE' ? '#FF4D4F' : '#FFF1F0')
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                .borderRadius(12)
                .onClick(() => { this.handleFilterClick('DISEASE'); });
              Text('🩺 症状')
                .fontSize(11)
                .fontColor(this.filterType === 'SYMPTOM' ? '#FFFFFF' : '#FA8C16')
                .backgroundColor(this.filterType === 'SYMPTOM' ? '#FA8C16' : '#FFF7E6')
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                .borderRadius(12)
                .onClick(() => { this.handleFilterClick('SYMPTOM'); });
              Text('🌿 药材')
                .fontSize(11)
                .fontColor(this.filterType === 'HERBAL' ? '#FFFFFF' : '#52C41A')
                .backgroundColor(this.filterType === 'HERBAL' ? '#52C41A' : '#F6FFED')
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                .borderRadius(12)
                .onClick(() => { this.handleFilterClick('HERBAL'); });
              if (this.filterType) {
                Text('✕ 清除')
                  .fontSize(10)
                  .fontColor('#999999')
                  .padding({ left: 4, right: 4, top: 4, bottom: 4 })
                  .onClick(() => {
                    this.filterType = '';
                    this.applyFilter();
                  });
              }
            }
            .width('100%')
            .padding({ left: 10, right: 8, top: 2, bottom: 2 });

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

            GraphCanvas({ startCenterId: this.activeCenterId, expandCenterId: this.expandCenterId })
              .width('100%')
              .layoutWeight(1);
          }
          .layoutWeight(1);
        }
        .width('100%')
        .layoutWeight(1);
      }

      if (!this.isFullscreen) {
        Footer({ activeIndex: 3 });
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#EEF1F6');
  }
}