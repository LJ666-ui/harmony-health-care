/**
 * AR院内导航系统 - 目的地选择页面(增强版)
 * 
 * 集成PathPlanner真实数据,提供:
 * - 70+个真实医院POI数据
 * - 智能模糊搜索
 * - 分类浏览(10+分类)
 * - 实时路径计算和距离显示
 * - 收藏功能
 * - 跳转AR导航
 * 
 * @version 2.0 (增强版)
 * @date 2025-01-18
 * @author SDD Agent
 */

import router from '@ohos.router';
import vibrator from '@ohos.vibrator';
import {
  NavigationDestination,
  DestinationCategory,
  Position3D,
  NavigationPath,
  SearchResultItem
} from '../models/ARNavigationModels';
import { PathPlanner } from '../ar/PathPlanner';

/**
 * 分类配置接口
 */
interface CategoryConfig {
  category: DestinationCategory;
  name: string;
  count: number;  // 该分类下的POI数量
}

@Entry
@Component
struct DestinationSelectPage {
  // ==================== PathPlanner实例 ====================
  private planner: PathPlanner = PathPlanner.getInstance();

  // ==================== 状态变量 ====================
  @State searchKeyword: string = '';
  @State selectedCategory: DestinationCategory | null = null;
  @State destinationList: NavigationDestination[] = [];
  @State filteredList: NavigationDestination[] = [];
  @State favoriteIds: string[] = [];
  @State isLoading: boolean = true;
  @State showFavorites: boolean = false;
  
  // 增强功能状态
  @State isInitialized: boolean = false;
  @State isCalculating: boolean = false;
  @State currentDistance: Map<string, number> = new Map();  // 存储每个POI到当前位置的距离
  @State currentPosition: Position3D = { x: 40, y: 0, z: 5 };  // 默认位置(主入口)

  // 分类配置
  @State categories: CategoryConfig[] = [];

  aboutToAppear() {
    this.initializeWithRealData();
    this.loadFavorites();
  }

  /**
   * 使用真实的PathPlanner数据初始化
   */
  private async initializeWithRealData() {
    this.isLoading = true;
    
    try {
      console.log('[DestinationSelectPage] 正在初始化PathPlanner...');
      
      await this.planner.autoInitialize();
      this.isInitialized = true;
      
      // 加载所有POI
      this.destinationList = this.planner.getAllPOIs();
      this.filteredList = [...this.destinationList];
      
      // 计算分类统计
      this.calculateCategoryStats();
      
      // 预计算距离
      this.preCalculateDistances();
      
      console.log(`[DestinationSelectPage] 加载完成,共${this.destinationList.length}个POI`);
      
    } catch (error) {
      console.error('[DestinationSelectPage] 初始化失败:', error);
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 计算各分类的POI数量
   */
  private calculateCategoryStats() {
    const stats = this.planner.getStatistics();
    
    this.categories = [
      { category: DestinationCategory.DEPARTMENT, name: '科室', count: stats.categoryDistribution['DEPARTMENT'] || 0 },
      { category: DestinationCategory.PHARMACY, name: '药房', count: stats.categoryDistribution['PHARMACY'] || 0 },
      { category: DestinationCategory.LAB, name: '检验', count: stats.categoryDistribution['LAB'] || 0 },
      { category: DestinationCategory.ELEVATOR, name: '电梯', count: stats.categoryDistribution['ELEVATOR'] || 0 },
      { category: DestinationCategory.RESTROOM, name: '洗手间', count: stats.categoryDistribution['RESTROOM'] || 0 },
      { category: DestinationCategory.PAYMENT, name: '缴费', count: stats.categoryDistribution['PAYMENT'] || 0 },
      { category: DestinationCategory.EMERGENCY, name: '急诊', count: stats.categoryDistribution['EMERGENCY'] || 0 },
      { category: DestinationCategory.REGISTRATION, name: '挂号', count: stats.categoryDistribution['REGISTRATION'] || 0 },
      { category: DestinationCategory.IMAGING, name: '影像', count: stats.categoryDistribution['IMAGING'] || 0 },
      { category: DestinationCategory.WARD, name: '病房', count: stats.categoryDistribution['WARD'] || 0 }
    ];
    
    // 按数量降序排列
    this.categories.sort((a, b) => b.count - a.count);
  }

  /**
   * 预计算所有POI到当前位置的距离
   */
  private preCalculateDistances() {
    const newDistances = new Map<string, number>();
    
    for (const poi of this.destinationList) {
      const distance = this.planner.getDistance(this.currentPosition, poi.position);
      newDistances.set(poi.id, distance);
    }
    
    this.currentDistance = newDistances;
  }

  /**
   * 加载收藏列表
   */
  private loadFavorites() {
    try {
      const savedFavorites = AppStorage.Get<string[]>('favorite_destinations');
      if (savedFavorites && Array.isArray(savedFavorites)) {
        this.favoriteIds = savedFavorites;
        console.log('[DestinationSelectPage] 加载收藏列表:', this.favoriteIds.length, '项');
      } else {
        this.favoriteIds = ['ENTRANCE_MAIN', 'INFO_DESK_001'];  // 默认收藏
      }
    } catch (e) {
      this.favoriteIds = [];
    }
  }

  /**
   * 保存收藏列表
   */
  private saveFavorites() {
    try {
      AppStorage.SetOrCreate('favorite_destinations', this.favoriteIds);
      console.log('[DestinationSelectPage] 保存收藏列表:', this.favoriteIds.length, '项');
    } catch (e) {
      console.error('[DestinationSelectPage] 保存失败:', e);
    }
  }

  /**
   * 智能搜索处理(使用PathPlanner的真实搜索)
   */
  private handleSearch(keyword: string) {
    this.searchKeyword = keyword;
    
    if (!this.isInitialized || keyword.trim().length === 0) {
      this.applyFilter();
      return;
    }
    
    // 使用PathPlanner的模糊搜索
    const searchResults = this.planner.searchDestinations(keyword, 20);
    this.filteredList = searchResults.map(item => item.poi);
    
    console.log(`[DestinationSelectPage] 搜索"${keyword}",找到${this.filteredList.length}个结果`);
  }

  /**
   * 分类选择处理
   */
  private handleCategorySelect(category: DestinationCategory | null) {
    this.selectedCategory = category;
    this.applyFilter();
  }

  /**
   * 应用筛选
   */
  private applyFilter() {
    if (!this.isInitialized) return;

    if (this.selectedCategory === null) {
      this.filteredList = [...this.destinationList];
    } else {
      this.filteredList = this.planner.getDestinationsByCategory(this.selectedCategory);
    }
  }

  /**
   * 切换收藏
   */
  private toggleFavorite(destinationId: string) {
    const index = this.favoriteIds.indexOf(destinationId);
    
    if (index === -1) {
      this.favoriteIds.push(destinationId);
    } else {
      this.favoriteIds.splice(index, 1);
    }
    
    this.saveFavorites();
  }

  /**
   * 选择目的地并跳转到导航
   */
  private async selectAndNavigate(destination: NavigationDestination) {
    console.log(`[DestinationSelectPage] ===== 开始选择目的地 =====`);
    console.log(`[DestinationSelectPage] 目的地: ${destination.name}`);
    console.log(`[DestinationSelectPage] ID: ${destination.id}`);
    console.log(`[DestinationSelectPage] 系统初始化状态: ${this.isInitialized}`);
    
    if (!this.isInitialized) {
      console.warn('[DestinationSelectPage] ❌ 系统未初始化，尝试重新初始化...');
      
      // 尝试重新初始化
      try {
        await this.planner.autoInitialize();
        this.isInitialized = true;
        console.log('[DestinationSelectPage] ✅ 重新初始化成功');
      } catch (error) {
        console.error('[DestinationSelectPage] ❌ 初始化失败:', error);
        this.showErrorDialog('系统初始化失败', '请稍后重试');
        return;
      }
    }

    this.isCalculating = true;
    
    try {
      console.log(`[DestinationSelectPage] 📍 计算路径到: ${destination.name}`);
      console.log(`[DestinationSelectPage] 起始位置:`, this.currentPosition);
      console.log(`[DestinationSelectPage] 目标位置:`, destination.position);
      
      // 使用PathPlanner计算路径
      const result = await this.planner.safeCalculatePath(
        this.currentPosition,
        destination.position
      );

      console.log(`[DestinationSelectPage] 计算结果: success=${result.success}`);

      if (result.success && result.path) {
        // 记录导航历史
        const historyId = this.planner.startNavigation(result.path, destination.name);
        console.log(`[DestinationSelectPage] ✅ 导航历史已记录, ID: ${historyId}`);
        
        console.log(`[DestinationSelectPage] 🚀 准备跳转到AR导航页面...`);
        console.log(`[DestinationSelectPage] 参数:`);
        console.log(`  - destinationId: ${destination.id}`);
        console.log(`  - destinationName: ${destination.name}`);
        
        // 安全访问 path 属性
        const navPath = result.path;
        console.log(`  - totalDistance: ${navPath.totalDistance}m`);
        console.log(`  - estimatedTime: ${navPath.estimatedTime}s`);
        
        // 显示成功提示（短暂延迟）
        setTimeout(() => {
          // 跳转到AR导航页面或导航摘要页
          router.pushUrl({
            url: 'pages/ARNavigationPage',
            params: {
              destinationId: destination.id,
              destinationName: destination.name,
              pathData: JSON.stringify(navPath),
              totalDistance: navPath.totalDistance,
              estimatedTime: navPath.estimatedTime
            }
          }).then(() => {
            console.log('[DestinationSelectPage] ✅ 成功跳转到AR导航页面');
          }).catch((error: Error) => {
            console.error('[DestinationSelectPage] ❌ 页面跳转失败:', error.message);
            this.showErrorDialog('跳转失败', error.message || '无法打开导航页面');
          });
        }, 300);  // 短暂延迟让用户看到选中效果
        
      } else {
        console.error('[DestinationSelectPage] ❌ 路径计算失败:', result.error);
        this.showErrorDialog('路径计算失败', result.error || '无法找到可行路径');
      }
      
    } catch (error) {
      console.error('[DestinationSelectPage] ❌ 导航过程出错:', error);
      this.showErrorDialog('导航出错', error instanceof Error ? error.message : '未知错误');
    } finally {
      setTimeout(() => {
        this.isCalculating = false;
      }, 500);  // 延迟隐藏loading，避免闪烁
    }
  }

  /**
   * 显示错误对话框
   */
  private showErrorDialog(title: string, message: string) {
    AlertDialog.show({
      title: title,
      message: message,
      confirm: { value: '确定', action: () => {} }
    });
  }

  /**
   * 测试点击功能（用于调试）
   */
  private testClick() {
    console.log('========================================');
    console.log('[DestinationSelectPage] ✅ 点击功能正常！');
    console.log('[DestinationSelectPage] 当前状态:');
    console.log(`  - isInitialized: ${this.isInitialized}`);
    console.log(`  - POI总数: ${this.destinationList.length}`);
    console.log(`  - 当前显示数: ${this.filteredList.length}`);
    console.log('========================================');
    
    AlertDialog.show({
      title: '✅ 点击功能正常',
      message: `系统状态:\n• 已初始化: ${this.isInitialized ? '是' : '否'}\n• POI数量: ${this.destinationList.length}\n• 显示数量: ${this.filteredList.length}`,
      confirm: { value: '好的', action: () => {} }
    });
  }

  /**
   * 获取格式化的距离文本
   */
  private getFormattedDistance(destinationId: string): string {
    const distance = this.currentDistance.get(destinationId);
    if (distance === undefined) return '';
    
    if (distance < 50) {
      return `${Math.round(distance)}m`;
    } else if (distance < 1000) {
      return `${distance.toFixed(0)}m`;
    } else {
      return `${(distance / 1000).toFixed(1)}km`;
    }
  }

  /**
   * 获取预计时间
   */
  private getEstimatedTime(destinationId: string): string {
    const distance = this.currentDistance.get(destinationId);
    if (distance === undefined) return '';
    
    // 步行速度约1.2m/s, 即72米/分钟
    const minutes = Math.ceil(distance / 72);
    
    if (minutes < 1) return '1分钟内';
    if (minutes < 60) return `约${minutes}分钟`;
    
    const hours = Math.floor(minutes / 60);
    const remainMinutes = minutes % 60;
    return `${hours}小时${remainMinutes > 0 ? remainMinutes + '分钟' : ''}`;
  }

  build() {
    Column() {
      // 顶部标题栏
      this.TitleBar()
      
      // 搜索框
      this.SearchBar()
      
      // 分类标签
      this.CategoryTabs()
      
      // 内容区域
      if (this.isLoading) {
        this.LoadingView()
      } else if (this.filteredList.length === 0) {
        this.EmptyView()
      } else {
        this.DestinationList()
      }
      
      // 底部收藏快捷入口
      this.FavoriteBar()
      
      // 加载中遮罩
      if (this.isCalculating) {
        this.CalculatingOverlay()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  // ==================== UI组件构建方法 ====================

  @Builder
  TitleBar() {
    Row() {
      Text('←')
        .fontSize(24)
        .fontColor('#333333')
        .onClick(() => {
          router.back();
        })
      
      Blank().width(15)
      
      Text('选择目的地')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .layoutWeight(1)
      
      // 状态指示 + 测试按钮
      Row() {
        if (this.isInitialized) {
          Text('●')
            .fontSize(12)
            .fontColor('#4CAF50')
            .margin({ right: 4 })
          Text('已连接')
            .fontSize(11)
            .fontColor('#4CAF50')
        } else {
          Text('●')
            .fontSize(12)
            .fontColor('#FF9800')
            .margin({ right: 4 })
          Text('连接中...')
            .fontSize(11)
            .fontColor('#FF9800')
        }
        
        // 测试按钮（调试用）
        Button('🔧')
          .width(32)
          .height(32)
          .backgroundColor('#E8E8E8')
          .fontSize(14)
          .margin({ left: 10 })
          .onClick(() => {
            this.testClick();
          })
      }
    }
    .width('100%')
    .height(56)
    .padding({ left: 20, right: 20 })
    .backgroundColor('#FFFFFF')
  }

  @Builder
  SearchBar() {
    Row() {
      Text('🔍')
        .fontSize(16)
        .margin({ left: 12, right: 8 })
      
      TextInput({ 
        placeholder: '搜索科室、药房、检验科...', 
        text: this.searchKeyword 
      })
        .layoutWeight(1)
        .height(40)
        .backgroundColor('#F5F5F5')
        .borderRadius(20)
        .padding({ left: 8, right: 8 })
        .onChange((value: string) => {
          this.handleSearch(value);
        })
        .onSubmit(() => {
          this.handleSearch(this.searchKeyword);
        })

      if (this.searchKeyword.length > 0) {
        Text('✕')
          .fontSize(16)
          .fontColor('#999999')
          .margin({ right: 12 })
          .onClick(() => {
            this.searchKeyword = '';
            this.handleSearch('');
          })
      }
    }
    .width('90%')
    .height(48)
    .backgroundColor('#FFFFFF')
    .borderRadius(24)
    .margin({ top: 15, bottom: 15 })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  CategoryTabs() {
    Scroll() {
      Row() {
        // 全部分类
        this.CategoryTab(null, '全部', this.destinationList.length)

        ForEach(this.categories.slice(0, 6), (item: CategoryConfig) => {
          Blank().width(8)
          this.CategoryTab(item.category, item.name + `(${item.count})`, item.count)
        })
      }
      .padding({ left: 16, right: 16 })
    }
    .width('100%')
    .height(90)
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .backgroundColor('#FFFFFF')
    .margin({ bottom: 10 })
  }

  @Builder
  CategoryTab(category: DestinationCategory | null, label: string, count: number) {
    Text(label)
      .fontSize(13)
      .fontColor(this.selectedCategory === category ? '#FFFFFF' : '#333333')
      .fontWeight(this.selectedCategory === category ? FontWeight.Medium : FontWeight.Normal)
      .backgroundColor(this.selectedCategory === category ? '#52C41A' : '#F0F0F0')
      .borderRadius(16)
      .padding({ left: 14, right: 14, top: 7, bottom: 7 })
      .onClick(() => {
        this.handleCategorySelect(category);
      })
  }

  @Builder
  LoadingView() {
    Column() {
      LoadingProgress()
        .width(40)
        .height(40)
        .color('#52C41A')
      
      Text('正在加载医院数据...')
        .fontSize(14)
        .fontColor('#666666')
        .margin({ top: 16 })
      
      Text(`${this.destinationList.length > 0 ? this.destinationList.length : 0}/70+ 个POI`)
        .fontSize(12)
        .fontColor('#999999')
        .margin({ top: 8 })
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  EmptyView() {
    Column() {
      Text('😅')
        .fontSize(48)
        .margin({ bottom: 16 })
      
      Text('未找到相关目的地')
        .fontSize(16)
        .fontColor('#666666')
      
      Text('试试其他关键词或切换分类')
        .fontSize(13)
        .fontColor('#999999')
        .margin({ top: 8 })
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  DestinationList() {
    List() {
      ForEach(this.filteredList, (destination: NavigationDestination, index: number) => {
        ListItem() {
          this.DestinationCard(destination, index)
        }
        .margin({ bottom: 8 })
      })
    }
    .width('100%')
    .layoutWeight(1)
    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
    .backgroundColor('#F5F5F5')
    .divider({ strokeWidth: 0.5, color: '#EEEEEE', startMargin: 16, endMargin: 16 })
  }

  @Builder
  DestinationCard(destination: NavigationDestination, index: number) {
    Row() {
      // 左侧图标区域
      Column() {
        Text(this.getCategoryIcon(destination.category))
          .fontSize(28)
        
        Text(`${destination.floor}F`)
          .fontSize(11)
          .fontColor('#666666')
          .fontWeight(FontWeight.Medium)
          .margin({ top: 2 })
      }
      .width(56)
      .height(56)
      .backgroundColor('#F0F5FF')
      .borderRadius(12)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)

      // 中间信息区
      Column() {
        // 名称行
        Row() {
          Text(destination.name)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)

          if (destination.isAccessible) {
            Text('♿')
              .fontSize(14)
              .margin({ left: 4 })
          }
        }
        .width('100%')

        // 描述/位置行
        Text(destination.description || `${destination.building} ${destination.floor}层`)
          .fontSize(12)
          .fontColor('#888888')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .margin({ top: 3 })

        // 底部信息行(距离和时间)
        Row() {
          // 距离
          if (this.getFormattedDistance(destination.id)) {
            Text(`📍 ${this.getFormattedDistance(destination.id)}`)
              .fontSize(11)
              .fontColor('#1890FF')
              .backgroundColor('#E6F7FF')
              .borderRadius(8)
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          }

          Blank().width(8)

          // 时间
          if (this.getEstimatedTime(destination.id)) {
            Text(`⏱️ ${this.getEstimatedTime(destination.id)}`)
              .fontSize(11)
              .fontColor('#FA8C16')
              .backgroundColor('#FFF7E6')
              .borderRadius(8)
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          }

          Blank()

          // 标签
          ForEach(destination.tags.slice(0, 2), (tag: string) => {
            Text(tag)
              .fontSize(10)
              .fontColor('#666666')
              .backgroundColor('#F5F5F5')
              .borderRadius(6)
              .padding({ left: 5, right: 5, top: 2, bottom: 2 })
              .margin({ left: 4 })
          })
        }
        .width('100%')
        .margin({ top: 5 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 12 })

      // 右侧操作区
      Column() {
        // 收藏按钮
        Text(this.favoriteIds.includes(destination.id) ? '⭐' : '☆')
          .fontSize(24)
          .fontColor(this.favoriteIds.includes(destination.id) ? '#FFB800' : '#CCCCCC')
          .onClick(() => {
            console.log(`[DestinationSelectPage] 点击收藏: ${destination.name}`);
            this.toggleFavorite(destination.id);
          })

        // 导航按钮 - 改为更明显的按钮
        Button('导航')
          .backgroundColor('#52C41A')
          .fontSize(12)
          .height(32)
          .width(60)
          .borderRadius(16)
          .margin({ top: 10 })
          .onClick(() => {
            console.log(`[DestinationSelectPage] 点击导航按钮: ${destination.name}`);
            this.selectAndNavigate(destination);
          })
      }
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Start)
      .margin({ left: 8 })
    }
    .width('100%')
    .height(96)
    .padding(12)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 2, color: '#00000008', offsetY: 1 })
    .onClick(() => {
      // 整个卡片可点击
      console.log(`[DestinationSelectPage] 点击POI卡片: ${destination.name} (${destination.id})`);
      
      // 触觉反馈（如果设备支持）
      try {
        vibrator.startVibration({
          type: 'time',
          duration: 20
        }, {
          id: 0,
          usage: 'touch'
        });
      } catch (e) {
        // 忽略震动错误
      }
      
      this.selectAndNavigate(destination);
    })
    // 添加点击效果
    .stateStyles({
      normal: {
        .scale({ x: 1.0, y: 1.0 })
        .backgroundColor('#FFFFFF')
      },
      pressed: {
        .scale({ x: 0.98, y: 0.98 })  // 按下时轻微缩小
        .backgroundColor('#F5F5F5')     // 背景变灰
      }
    })
  }

  @Builder
  FavoriteBar() {
    Row() {
      Text('⭐')
        .fontSize(20)
        .fontColor('#FF4D4F')
      
      Blank().width(10)
      
      Text(`我的收藏 (${this.favoriteIds.length})`)
        .fontSize(16)
        .fontColor('#333333')
        .layoutWeight(1)
      
      if (this.favoriteIds.length > 0) {
        Row() {
          Text('查看')
            .fontSize(14)
            .fontColor('#52C41A')
          
          Text('→')
            .fontSize(16)
            .fontColor('#52C41A')
        }
        .onClick(() => {
          this.showFavorites = !this.showFavorites;
          if (this.showFavorites) {
            this.filteredList = this.destinationList.filter(
              dest => this.favoriteIds.includes(dest.id)
            );
          } else {
            this.applyFilter();
          }
        })
      }
    }
    .width('100%')
    .height(56)
    .padding({ left: 20, right: 20 })
    .backgroundColor('#FFFFFF')
    .shadow({ radius: 2, color: '#00000008', offsetY: -1 })
  }

  @Builder
  CalculatingOverlay() {
    Column() {
      LoadingProgress()
        .width(50)
        .height(50)
        .color('#52C41A')
      
      Text('正在计算最优路径...')
        .fontSize(15)
        .fontColor('#333333')
        .fontWeight(FontWeight.Medium)
        .margin({ top: 20 })
      
      Text('使用A*算法规划路线')
        .fontSize(12)
        .fontColor('#999999')
        .margin({ top: 8 })
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
    .backgroundColor('#FFFFFF99')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .zIndex(100)
  }

  /**
   * 根据分类获取图标emoji
   */
  private getCategoryIcon(category: DestinationCategory): string {
    switch (category) {
      case DestinationCategory.DEPARTMENT: return '🏥';
      case DestinationCategory.PHARMACY: return '💊';
      case DestinationCategory.LAB: return '🔬';
      case DestinationCategory.ELEVATOR: return '🛗';
      case DestinationCategory.RESTROOM: return '🚻';
      case DestinationCategory.PAYMENT: return '💰';
      case DestinationCategory.EMERGENCY: return '🚑';
      case DestinationCategory.REGISTRATION: return '📋';
      case DestinationCategory.IMAGING: return '📷';
      case DestinationCategory.WARD: return '🛏️';
      case DestinationCategory.ENTRANCE: return '🚪';
      case DestinationCategory.INFO_DESK: return 'ℹ️';
      case DestinationCategory.PARKING: return '🅿️';
      case DestinationCategory.STAIRS: return '🪜';
      case DestinationCategory.ESCALATOR: return '🔼';
      default: return '📍';
    }
  }
}
