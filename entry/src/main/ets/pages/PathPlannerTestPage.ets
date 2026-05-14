/**
 * PathPlanner 功能测试页面
 * 
 * 用于测试和演示PathPlanner的所有功能:
 * - 系统状态监控
 * - POI搜索和浏览
 * - 路径计算和显示
 * - 缓存管理
 * - 历史记录查看
 * - 统计信息展示
 * 
 * @version 1.0
 * @date 2025-01-18
 */

import { PathPlanner } from '../ar/PathPlanner';
import {
  Position3D,
  NavigationPath,
  NavigationDestination,
  DestinationCategory,
  PathPlanningOptions,
  SearchResultItem,
  NavigationHistory,
  NavigationInstruction,
  SystemStatusInfo,
  StatisticsInfo
} from '../models/ARNavigationModels';

// ==================== 接口定义 ====================

interface TabInfo {
  name: string;
  index: number;
}

@Entry
@Component
struct PathPlannerTestPage {
  // ==================== 实例引用 ====================
  private planner: PathPlanner = PathPlanner.getInstance();

  // ==================== 系统状态 ====================
  @State isInitialized: boolean = false;
  @State isInitializing: boolean = false;
  @State systemStatus: SystemStatusInfo | null = null;

  // ==================== 搜索相关 ====================
  @State searchKeyword: string = '';
  @State searchResults: SearchResultItem[] = [];
  @State isSearching: boolean = false;
  @State showSearchResults: boolean = false;

  // ==================== 选择状态 ====================
  @State selectedStartPOI: NavigationDestination | null = null;
  @State selectedEndPOI: NavigationDestination | null = null;
  @State showStartSelector: boolean = false;
  @State showEndSelector: boolean = false;
  @State categoryList: NavigationDestination[] = [];
  @State selectedCategory: DestinationCategory | null = null;

  // ==================== 路径计算 ====================
  @State isCalculatingPath: boolean = false;
  @State calculatedPath: NavigationPath | null = null;
  @State pathError: string = '';
  @State pathOptions: PathPlanningOptions = {
    avoidElevators: false,
    avoidStairs: false,
    accessibilityMode: false,
    preferElevator: true
  };

  // ==================== 显示选项 ====================
  @State activeTab: number = 0;  // 0:搜索, 1:热门, 2:分类, 3:统计, 4:历史, 5:缓存
  @State popularDestinations: NavigationDestination[] = [];
  @State allCategories: DestinationCategory[] = [];
  @State categoryPOIs: NavigationDestination[] = [];
  @State navigationHistory: NavigationHistory[] = [];

  // ==================== 统计信息 ====================
  @State statistics: StatisticsInfo | null = null;

  aboutToAppear() {
    this.checkInitializationStatus();
  }

  // ==================== 初始化方法 ====================
  
  async checkInitializationStatus() {
    this.isInitialized = this.planner.isReady();
    if (this.isInitialized) {
      this.updateSystemStatus();
      this.loadInitialData();
    }
  }

  async initializeSystem() {
    if (this.isInitializing || this.isInitialized) return;
    
    this.isInitializing = true;
    
    try {
      await this.planner.autoInitialize();
      this.isInitialized = true;
      this.updateSystemStatus();
      this.loadInitialData();
      
      console.log('✅ PathPlanner初始化成功');
    } catch (error) {
      console.error('❌ PathPlanner初始化失败:', error);
    } finally {
      this.isInitializing = false;
    }
  }

  updateSystemStatus() {
    this.systemStatus = this.planner.getSystemStatus();
  }

  loadInitialData() {
    this.popularDestinations = this.planner.getPopularDestinations(10);
    this.allCategories = this.planner.getAvailableCategories();
    this.navigationHistory = this.planner.getNavigationHistory(10);
    this.statistics = this.planner.getStatistics();
  }

  // ==================== 搜索方法 ====================
  
  performSearch() {
    if (!this.searchKeyword.trim()) return;
    
    this.isSearching = true;
    this.showSearchResults = true;
    
    setTimeout(() => {
      this.searchResults = this.planner.searchDestinations(this.searchKeyword, 15);
      this.isSearching = false;
    }, 100);
  }

  selectSearchResult(item: SearchResultItem, asStart: boolean = false) {
    if (asStart) {
      this.selectedStartPOI = item.poi;
      this.showStartSelector = false;
    } else {
      this.selectedEndPOI = item.poi;
      this.showEndSelector = false;
    }
    this.showSearchResults = false;
    this.searchKeyword = '';
  }

  // ==================== 分类浏览方法 ====================
  
  selectCategory(category: DestinationCategory) {
    this.selectedCategory = category;
    this.categoryPOIs = this.planner.getDestinationsByCategory(category);
  }

  selectCategoryPOI(poi: NavigationDestination, asStart: boolean = false) {
    if (asStart) {
      this.selectedStartPOI = poi;
    } else {
      this.selectedEndPOI = poi;
    }
  }

  // ==================== 路径计算方法 ====================
  
  async calculatePath() {
    if (!this.selectedStartPOI || !this.selectedEndPOI) {
      this.pathError = '请选择起点和终点';
      return;
    }

    this.isCalculatingPath = true;
    this.pathError = '';
    this.calculatedPath = null;

    try {
      const result = await this.planner.safeCalculatePath(
        this.selectedStartPOI.position,
        this.selectedEndPOI.position,
        this.pathOptions
      );

      if (result.success && result.path) {
        this.calculatedPath = result.path;
        
        // 记录到历史
        this.planner.startNavigation(result.path, this.selectedEndPOI.name);
        
        // 更新历史记录显示
        this.navigationHistory = this.planner.getNavigationHistory(10);
        this.updateSystemStatus();
        
        console.log(`✅ 路径计算成功: ${result.path.totalDistance}米`);
      } else {
        this.pathError = result.error || '路径计算失败';
      }
    } catch (error) {
      this.pathError = `计算出错: ${error}`;
    } finally {
      this.isCalculatingPath = false;
    }
  }

  getDurationText(history: NavigationHistory): string {
    if (history.endTime > 0) {
      const duration = ((history.endTime - history.startTime) / 1000).toFixed(1);
      return `耗时: ${duration}秒`;
    }
    return '';
  }

  clearSelection() {
    this.selectedStartPOI = null;
    this.selectedEndPOI = null;
    this.calculatedPath = null;
    this.pathError = '';
  }

  // ==================== 缓存管理方法 ====================
  
  clearCache() {
    this.planner.clearCache();
    this.updateSystemStatus();
    console.log('🗑️ 已清空缓存');
  }

  clearHistory() {
    this.planner.clearHistory();
    this.navigationHistory = [];
    this.updateSystemStatus();
    console.log('🗑️ 已清空历史');
  }

  resetSystem() {
    this.planner.reset();
    this.isInitialized = false;
    this.systemStatus = null;
    this.clearSelection();
    console.log('🔄 系统已重置');
  }

  build() {
    Column() {
      // ==================== 标题栏 ====================
      this.buildHeader()

      Scroll() {
        Column() {
          // ==================== 系统状态卡片 ====================
          this.buildSystemStatusCard()

          if (!this.isInitialized) {
            // 未初始化提示
            this.buildInitPrompt()
          } else {
            // ==================== Tab切换栏 ====================
            this.buildTabBar()

            // ==================== Tab内容区 ====================
            if (this.activeTab === 0) {
              this.buildSearchTab()
            } else if (this.activeTab === 1) {
              this.buildPopularTab()
            } else if (this.activeTab === 2) {
              this.buildCategoryTab()
            } else if (this.activeTab === 3) {
              this.buildStatisticsTab()
            } else if (this.activeTab === 4) {
              this.buildHistoryTab()
            } else if (this.activeTab === 5) {
              this.buildCacheTab()
            }

            // ==================== 路径选择和计算区 ====================
            this.buildPathCalculationArea()

            // ==================== 路径结果展示区 ====================
            if (this.calculatedPath) {
              this.buildPathResultPanel()
            }
          }
        }
        .width('100%')
        .padding({ left: 12, right: 12 })
      }
      .scrollable(ScrollDirection.Vertical)
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }

  // ==================== UI组件构建方法 ====================

  @Builder
  buildHeader() {
    Row() {
      Text('🧭 PathPlanner 测试控制台')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333')
      
      Blank()
      
      if (this.isInitialized) {
        Text('● 已连接')
          .fontSize(12)
          .fontColor('#4CAF50')
      }
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#fff')
    .shadow({ radius: 2, color: '#00000010', offsetY: 1 })
  }

  @Builder
  buildSystemStatusCard() {
    Column() {
      Row() {
        Text('系统状态')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
        
        Blank()
        
        if (!this.isInitialized && !this.isInitializing) {
          Button('初始化系统')
            .type(ButtonType.Normal)
            .backgroundColor('#2196F3')
            .fontSize(13)
            .height(32)
            .onClick(() => this.initializeSystem())
        }
        
        if (this.isInitializing) {
          LoadingProgress()
            .width(16)
            .height(16)
          Text('初始化中...')
            .fontSize(12)
            .fontColor('#666')
            .margin({ left: 8 })
        }
      }
      .width('100%')
      .margin({ bottom: 12 })

      if (this.systemStatus) {
        Grid() {
          GridItem() {
            this.buildStatItem('POI数量', `${this.systemStatus.poiCount}`, '#2196F3')
          }
          GridItem() {
            this.buildStatItem('图节点', `${this.systemStatus.graphSize}`, '#4CAF50')
          }
          GridItem() {
            this.buildStatItem('缓存数', `${this.systemStatus.cacheSize}`, '#FF9800')
          }
          GridItem() {
            this.buildStatItem('历史数', `${this.systemStatus.historySize}`, '#9C27B0')
          }
        }
        .columnsTemplate('1fr 1fr 1fr 1fr')
        .rowsGap(8)
        .columnsGap(8)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#fff')
    .borderRadius(12)
    .margin({ top: 12 })
    .shadow({ radius: 4, color: '#00000008', offsetY: 2 })
  }

  @Builder
  buildStatItem(label: string, value: string, color: string) {
    Column() {
      Text(value)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
      Text(label)
        .fontSize(11)
        .fontColor('#666')
        .margin({ top: 4 })
    }
    .width('100%')
    .padding(8)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildInitPrompt() {
    Column() {
      Text('🚀 请先初始化PathPlanner系统')
        .fontSize(16)
        .fontColor('#666')
        .margin({ bottom: 16 })
      
      Text('初始化将加载医院建筑数据、POI信息和楼层平面图，以便进行路径规划和导航测试。')
        .fontSize(13)
        .fontColor('#999')
        .textAlign(TextAlign.Center)
        .lineHeight(18)
    }
    .width('100%')
    .padding(24)
    .margin({ top: 12 })
    .backgroundColor('#fff')
    .borderRadius(12)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildTabBar() {
    Flex({ wrap: FlexWrap.Wrap }) {
      ForEach([
        { name: '🔍 搜索', index: 0 } as TabInfo,
        { name: '🔥 热门', index: 1 } as TabInfo,
        { name: '📂 分类', index: 2 } as TabInfo,
        { name: '📊 统计', index: 3 } as TabInfo,
        { name: '📜 历史', index: 4 } as TabInfo,
        { name: '💾 缓存', index: 5 } as TabInfo
      ], (tab: TabInfo) => {
        Text(tab.name)
          .fontSize(13)
          .fontColor(this.activeTab === tab.index ? '#fff' : '#666')
          .backgroundColor(this.activeTab === tab.index ? '#2196F3' : '#f0f0f0')
          .borderRadius(16)
          .padding({ left: 14, right: 14, top: 7, bottom: 7 })
          .margin({ right: 8, bottom: 8 })
          .onClick(() => { this.activeTab = tab.index })
      })
    }
    .width('100%')
    .margin({ top: 12 })
  }

  @Builder
  buildSearchTab() {
    Column() {
      // 搜索框
      Row() {
        TextInput({ placeholder: '输入关键词搜索POI...', text: this.searchKeyword })
          .layoutWeight(1)
          .height(40)
          .backgroundColor('#f5f5f5')
          .borderRadius(20)
          .onChange((value: string) => {
            this.searchKeyword = value
          })
          .onSubmit(() => this.performSearch())
        
        Button('搜索')
          .type(ButtonType.Normal)
          .backgroundColor('#2196F3')
          .height(40)
          .width(70)
          .margin({ left: 8 })
          .onClick(() => this.performSearch())
      }
      .width('100%')

      // 搜索结果列表
      if (this.showSearchResults && this.searchResults.length > 0) {
        Column() {
          Text(`找到 ${this.searchResults.length} 个结果`)
            .fontSize(13)
          .fontColor('#666')
            .width('100%')
            .margin({ bottom: 8 })

          ForEach(this.searchResults, (item: SearchResultItem, index: number) => {
            this.buildSearchResultItem(item, index)
          })
        }
        .width('100%')
        .margin({ top: 12 })
        .padding(12)
        .backgroundColor('#fafafa')
        .borderRadius(8)
      }

      if (this.showSearchResults && this.searchResults.length === 0 && !this.isSearching) {
        Text('😅 未找到匹配的POI')
          .fontSize(14)
          .fontColor('#999')
          .margin({ top: 12 })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#fff')
    .borderRadius(12)
    .margin({ top: 12 })
  }

  @Builder
  buildSearchResultItem(item: SearchResultItem, index: number) {
    Column() {
      Row() {
        Column() {
          Text(item.poi.name)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333')
          
          Text(`${item.poi.building} - ${item.poi.floor}层`)
            .fontSize(12)
            .fontColor('#999')
            .margin({ top: 2 })

          if (item.matchFields.length > 0) {
            Text(`匹配: ${item.matchFields.join(', ')}`)
              .fontSize(11)
              .fontColor('#2196F3')
              .margin({ top: 2 })
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Text(`${item.relevanceScore}分`)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FF9800')
          .margin({ right: 12 })
      }
      .width('100%')

      Row() {
        Button('设为起点')
          .type(ButtonType.Normal)
          .backgroundColor('#4CAF50')
          .fontSize(12)
          .height(30)
          .layoutWeight(1)
          .margin({ right: 6 })
          .onClick(() => this.selectSearchResult(item, true))

        Button('设为终点')
          .type(ButtonType.Normal)
          .backgroundColor('#2196F3')
          .fontSize(12)
          .height(30)
          .layoutWeight(1)
          .onClick(() => this.selectSearchResult(item, false))
      }
      .width('100%')
      .margin({ top: 8 })
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#fff')
    .borderRadius(8)
    .margin({ bottom: index < this.searchResults.length - 1 ? 8 : 0 })
  }

  @Builder
  buildPopularTab() {
    Column() {
      Text('热门目的地推荐')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .margin({ bottom: 12 })

      ForEach(this.popularDestinations, (poi: NavigationDestination, index: number) => {
        this.buildPOICard(poi, index)
      })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#fff')
    .borderRadius(12)
    .margin({ top: 12 })
  }

  @Builder
  buildCategoryTab() {
    Column() {
      // 分类选择器
      Text('选择分类浏览')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .margin({ bottom: 12 })

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.allCategories, (category: DestinationCategory) => {
          Text(category.toString().replace('_', ' '))
            .fontSize(12)
            .fontColor(this.selectedCategory === category ? '#fff' : '#666')
            .backgroundColor(this.selectedCategory === category ? '#2196F3' : '#f0f0f0')
            .borderRadius(14)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .margin({ right: 6, bottom: 6 })
            .onClick(() => this.selectCategory(category))
        })
      }
      .width('100%')

      // 该分类下的POI列表
      if (this.categoryPOIs.length > 0) {
        Column() {
          Text(`${this.selectedCategory?.toString()} (${this.categoryPOIs.length}个)`)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .width('100%')
            .margin({ top: 16, bottom: 8 })

          ForEach(this.categoryPOIs.slice(0, 10), (poi: NavigationDestination, index: number) => {
            this.buildPOICard(poi, index)
          })
        }
        .width('100%')
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#fff')
    .borderRadius(12)
    .margin({ top: 12 })
  }

  @Builder
  buildPOICard(poi: NavigationDestination, index: number) {
    Row() {
      Column() {
        Text(poi.name)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333')
        
        Row() {
          Text(`${poi.building}`)
            .fontSize(11)
            .fontColor('#999')
          Text(`${poi.floor}F`)
            .fontSize(11)
            .fontColor('#2196F3')
            .margin({ left: 8 })
          if (poi.isAccessible) {
            Text('♿')
              .fontSize(12)
              .margin({ left: 4 })
          }
        }
        .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Row() {
        Button('起点')
          .type(ButtonType.Normal)
          .backgroundColor('#4CAF50')
          .fontSize(11)
          .height(28)
          .width(55)
          .margin({ right: 6 })
          .onClick(() => this.selectCategoryPOI(poi, true))

        Button('终点')
          .type(ButtonType.Normal)
          .backgroundColor('#2196F3')
          .fontSize(11)
          .height(28)
          .width(55)
          .onClick(() => this.selectCategoryPOI(poi, false))
      }
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#fafafa')
    .borderRadius(8)
    .margin({ bottom: 8 })
  }

  @Builder
  buildStatisticsTab() {
    Column() {
      Text('📊 系统统计数据')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .margin({ bottom: 16 })

      if (this.statistics) {
        // 总体统计
        Text(`总POI数量: ${this.statistics.totalPOIs}`)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .width('100%')
          .margin({ bottom: 12 })

        // 分类分布
        Text('分类分布:')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .width('100%')
          .margin({ bottom: 8 })
        
        ForEach(Object.entries(this.statistics.categoryDistribution).slice(0, 8), 
          (entry: [string, number]) => {
            Row() {
              Text(entry[0].replace('_', ' '))
                .fontSize(13)
                .fontColor('#333')
                .layoutWeight(1)
              
              Text(`${entry[1]}个`)
                .fontSize(13)
                .fontWeight(FontWeight.Medium)
                .fontColor('#2196F3')
            }
            .width('100%')
            .padding({ top: 6, bottom: 6 })
            .border({ width: { bottom: 1 }, color: '#f0f0f0' })
          })

        // 楼层分布（前5个）
        Text('\n楼层分布(Top5):')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .width('100%')
          .margin({ top: 16, bottom: 8 })
        
        ForEach(
          Object.entries(this.statistics.floorDistribution)
            .sort((a, b) => b[1] - a[1])
            .slice(0, 5),
          (entry: [string, number]) => {
            Row() {
              Text(entry[0])
                .fontSize(13)
                .fontColor('#333')
                .layoutWeight(1)
              
              Text(`${entry[1]}个`)
                .fontSize(13)
                .fontWeight(FontWeight.Medium)
                .fontColor('#4CAF50')
            }
            .width('100%')
            .padding({ top: 6, bottom: 6 })
            .border({ width: { bottom: 1 }, color: '#f0f0f0' })
          })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#fff')
    .borderRadius(12)
    .margin({ top: 12 })
  }

  @Builder
  buildHistoryTab() {
    Column() {
      Row() {
        Text('📜 导航历史记录')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
        
        Blank()
        
        Button('清空')
          .type(ButtonType.Normal)
          .backgroundColor('#f44336')
          .fontSize(12)
          .height(28)
          .onClick(() => this.clearHistory())
      }
      .width('100%')
      .margin({ bottom: 12 })

      if (this.navigationHistory.length > 0) {
        ForEach(this.navigationHistory, (history: NavigationHistory, index: number) => {
          Row() {
            Column() {
              Text(history.destinationName)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333')

              Text(new Date(history.startTime).toLocaleString())
                .fontSize(11)
                .fontColor('#999')
                .margin({ top: 2 })

              Text(this.getDurationText(history))
                .fontSize(11)
                .fontColor('#666')
                .margin({ top: 2 })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            Text(history.completed ? '✅ 完成' : '⏳ 进行中')
              .fontSize(12)
              .fontColor(history.completed ? '#4CAF50' : '#FF9800')
              .backgroundColor(history.completed ? '#E8F5E9' : '#FFF3E0')
              .borderRadius(10)
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          }
          .width('100%')
          .padding(12)
          .backgroundColor('#fafafa')
          .borderRadius(8)
          .margin({ bottom: 8 })
        })
      } else {
        Text('暂无导航历史记录')
          .fontSize(14)
          .fontColor('#999')
          .padding(20)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#fff')
    .borderRadius(12)
    .margin({ top: 12 })
  }

  @Builder
  buildCacheTab() {
    Column() {
      Row() {
        Text('💾 路径缓存管理')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
        
        Blank()
        
        Button('清空缓存')
          .type(ButtonType.Normal)
          .backgroundColor('#f44336')
          .fontSize(12)
          .height(28)
          .onClick(() => this.clearCache())

        Button('重置系统')
          .type(ButtonType.Normal)
          .backgroundColor('#9E9E9E')
          .fontSize(12)
          .height(28)
          .margin({ left: 8 })
          .onClick(() => this.resetSystem())
      }
      .width('100%')
      .margin({ bottom: 12 })

      Column() {
        Text('缓存说明:')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .width('100%')
          .margin({ bottom: 8 })

        Text('• 自动缓存最近计算的路径(最多50条)')
          .fontSize(13)
          .fontColor('#666')
          .width('100%')
        Text('• 缓存有效期30分钟')
          .fontSize(13)
          .fontColor('#666')
          .width('100%')
        Text('• 相同起终点的查询直接返回缓存结果')
          .fontSize(13)
          .fontColor('#666')
          .width('100%')
        Text('• 可显著提升重复查询的性能')
          .fontSize(13)
          .fontColor('#666')
          .width('100%')

        Text('\n当前缓存状态:')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .width('100%')
          .margin({ top: 16, bottom: 8 })

        if (this.systemStatus) {
          Row() {
            Text('已缓存路径数:')
              .fontSize(13)
              .fontColor('#333')
              .layoutWeight(1)
            
            Text(`${this.systemStatus.cacheSize} 条`)
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor('#2196F3')
          }
          .width('100%')
          .padding(12)
          .backgroundColor('#E3F2FD')
          .borderRadius(8)
        }
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#fafafa')
      .borderRadius(8)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#fff')
    .borderRadius(12)
    .margin({ top: 12 })
  }

  @Builder
  buildPathCalculationArea() {
    Column() {
      Text('📍 路径规划')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .margin({ bottom: 12 })

      // 起点
      Row() {
        Text('起点:')
          .fontSize(14)
          .fontColor('#333')
          .width(50)

        if (this.selectedStartPOI) {
          Text(this.selectedStartPOI.name)
            .fontSize(13)
            .fontColor('#4CAF50')
            .layoutWeight(1)
          
          Text('✕')
            .fontSize(16)
            .fontColor('#999')
            .onClick(() => { this.selectedStartPOI = null })
        } else {
          Text('未选择')
            .fontSize(13)
            .fontColor('#999')
            .layoutWeight(1)
        }
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#f9f9f9')
      .borderRadius(8)
      .margin({ bottom: 8 })

      // 终点
      Row() {
        Text('终点:')
          .fontSize(14)
          .fontColor('#333')
          .width(50)

        if (this.selectedEndPOI) {
          Text(this.selectedEndPOI.name)
            .fontSize(13)
            .fontColor('#2196F3')
            .layoutWeight(1)
          
          Text('✕')
            .fontSize(16)
            .fontColor('#999')
            .onClick(() => { this.selectedEndPOI = null })
        } else {
          Text('未选择')
            .fontSize(13)
            .fontColor('#999')
            .layoutWeight(1)
        }
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#f9f9f9')
      .borderRadius(8)
      .margin({ bottom: 12 })

      // 规划选项
      Text('规划选项:')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .margin({ bottom: 8 })

      Row() {
        Toggle({ type: ToggleType.Switch, isOn: this.pathOptions.avoidStairs })
          .onChange((isOn: boolean) => {
            this.pathOptions.avoidStairs = isOn
          })
        Text('避开楼梯')
          .fontSize(13)
          .fontColor('#333')
          .margin({ left: 8 })
        
        Blank()
        
        Toggle({ type: ToggleType.Switch, isOn: this.pathOptions.accessibilityMode })
          .onChange((isOn: boolean) => {
            this.pathOptions.accessibilityMode = isOn
          })
        Text('无障碍模式')
          .fontSize(13)
          .fontColor('#333')
          .margin({ left: 8 })
      }
      .width('100%')
      .margin({ bottom: 12 })

      // 操作按钮
      Row() {
        Button('计算路径')
          .type(ButtonType.Normal)
          .backgroundColor('#2196F3')
          .fontSize(15)
          .height(44)
          .layoutWeight(1)
          .enabled(!this.isCalculatingPath && !!this.selectedStartPOI && !!this.selectedEndPOI)
          .onClick(() => this.calculatePath())

        Button('清除选择')
          .type(ButtonType.Normal)
          .backgroundColor('#757575')
          .fontSize(15)
          .height(44)
          .width(120)
          .margin({ left: 12 })
          .onClick(() => this.clearSelection())
      }
      .width('100%')

      // 错误提示
      if (this.pathError) {
        Text(`❌ ${this.pathError}`)
          .fontSize(13)
          .fontColor('#f44336')
          .width('100%')
          .margin({ top: 8 })
          .padding(10)
          .backgroundColor('#FFEBEE')
          .borderRadius(6)
      }

      // 加载中提示
      if (this.isCalculatingPath) {
        Row() {
          LoadingProgress()
            .width(20)
            .height(20)
          Text('正在计算最优路径...')
            .fontSize(13)
            .fontColor('#666')
            .margin({ left: 10 })
        }
        .width('100%')
        .margin({ top: 8 })
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#fff')
    .borderRadius(12)
    .margin({ top: 12 })
  }

  @Builder
  buildPathResultPanel() {
    Column() {
      // 结果头部
      Row() {
        Text('✅ 路径计算成功!')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#4CAF50')
        
        Blank()
        
        Text(`${this.calculatedPath!.totalDistance.toFixed(1)}m`)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2196F3')
        
        Text(`约${Math.round(this.calculatedPath!.estimatedTime / 60)}分钟`)
          .fontSize(14)
          .fontColor('#666')
          .margin({ left: 12 })
      }
      .width('100%')
      .padding({ bottom: 12 })
      .border({ width: { bottom: 1 }, color: '#e0e0e0' })

      // 路径摘要
      Row() {
        this.buildInfoChip('途经点', `${this.calculatedPath!.waypoints.length}个`, '#4CAF50')
        this.buildInfoChip('楼层切换', `${this.calculatedPath!.floorChanges.length}次`, '#FF9800')
        this.buildInfoChip('导航指令', `${this.calculatedPath!.instructions.length}条`, '#9C27B0')
      }
      .width('100%')
      .margin({ bottom: 12 })

      // 导航指令列表
      Text('📍 详细导航指令:')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .margin({ bottom: 8 })

      List({ space: 8 }) {
        ForEach(this.calculatedPath!.instructions, (inst: NavigationInstruction, index: number) => {
          ListItem() {
            Row() {
              // 步骤编号
              Text(`${index + 1}`)
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor('#fff')
                .width(28)
                .height(28)
                .backgroundColor('#2196F3')
                .borderRadius(14)
                .textAlign(TextAlign.Center)

              // 指令内容
              Column() {
                Text(inst.text)
                  .fontSize(14)
                  .fontColor('#333')
                
                if (inst.floorHint) {
                  Text(inst.floorHint)
                    .fontSize(11)
                    .fontColor('#FF9800')
                    .margin({ top: 2 })
                }
                
                Text(`${inst.distance.toFixed(1)}米`)
                  .fontSize(11)
                  .fontColor('#999')
                  .margin({ top: 2 })
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
              .margin({ left: 12 })
            }
            .width('100%')
            .padding(12)
            .backgroundColor('#fafafa')
            .borderRadius(8)
          }
        })
      }
      .width('100%')
      .height(250)
      .divider({ strokeWidth: 1, color: '#f0f0f0' })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#E8F5E9')
    .borderRadius(12)
    .margin({ top: 12 })
  }

  @Builder
  buildInfoChip(label: string, value: string, color: string) {
    Row() {
      Text(label)
        .fontSize(12)
        .fontColor('#666')
      Text(value)
        .fontSize(13)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
        .margin({ left: 4 })
    }
    .padding({ left: 10, right: 10, top: 6, bottom: 6 })
    .backgroundColor('#f5f5f5')
    .borderRadius(12)
  }
}
