/**
 * AR院内导航系统 - 目的地选择页面
 * 
 * 提供目的地搜索、分类浏览、收藏功能
 * 
 * @version 1.0
 * @date 2025-01-18
 * @author SDD Agent
 */

import router from '@ohos.router';
import {
  NavigationDestination,
  DestinationCategory
} from '../models/ARNavigationModels';
import {
  getMockDestinations,
  getMockDestinationsByCategory,
  searchMockDestinations
} from '../mock/arMock';
import {
  DestinationCard,
  CategoryTab,
  SearchBar,
  LoadingView,
  EmptyView
} from '../components/ARNavigationComponents';

@Entry
@Component
struct DestinationSelectPage {
  // 状态变量
  @State searchKeyword: string = '';
  @State selectedCategory: DestinationCategory | null = null;
  @State destinationList: NavigationDestination[] = [];
  @State filteredList: NavigationDestination[] = [];
  @State favoriteIds: string[] = [];
  @State isLoading: boolean = true;
  @State showFavorites: boolean = false;

  // 分类配置
  private categories = [
    { category: DestinationCategory.DEPARTMENT, name: '科室', icon: $r('app.media.ic_department') },
    { category: DestinationCategory.PHARMACY, name: '药房', icon: $r('app.media.ic_pharmacy') },
    { category: DestinationCategory.LAB, name: '检验', icon: $r('app.media.ic_lab') },
    { category: DestinationCategory.ELEVATOR, name: '电梯', icon: $r('app.media.ic_elevator') },
    { category: DestinationCategory.RESTROOM, name: '洗手间', icon: $r('app.media.ic_restroom') },
    { category: DestinationCategory.PAYMENT, name: '缴费', icon: $r('app.media.ic_payment') },
    { category: DestinationCategory.EMERGENCY, name: '急诊', icon: $r('app.media.ic_emergency') },
    { category: DestinationCategory.REGISTRATION, name: '挂号', icon: $r('app.media.ic_registration') },
    { category: DestinationCategory.IMAGING, name: '影像', icon: $r('app.media.ic_imaging') },
    { category: DestinationCategory.WARD, name: '病房', icon: $r('app.media.ic_ward') }
  ];

  aboutToAppear() {
    // 加载数据
    this.loadData();
    
    // 加载收藏列表
    this.loadFavorites();
  }

  /**
   * 加载目的地数据
   */
  private loadData() {
    this.isLoading = true;
    
    // 模拟加载延迟
    setTimeout(() => {
      this.destinationList = getMockDestinations();
      this.filteredList = this.destinationList;
      this.isLoading = false;
    }, 500);
  }

  /**
   * 加载收藏列表
   */
  private loadFavorites() {
    // 实际实现需要从Preferences读取
    // 这里使用模拟数据
    this.favoriteIds = ['DEPT_INTERNAL_301', 'PHARMACY_WEST_101'];
  }

  /**
   * 保存收藏列表
   */
  private saveFavorites() {
    // 实际实现需要保存到Preferences
    console.log('[DestinationSelectPage] 保存收藏列表:', this.favoriteIds);
  }

  /**
   * 搜索处理
   */
  private handleSearch(keyword: string) {
    this.searchKeyword = keyword;
    
    if (keyword.length === 0) {
      this.applyFilter();
      return;
    }
    
    this.filteredList = searchMockDestinations(keyword);
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
    if (this.selectedCategory === null) {
      this.filteredList = this.destinationList;
    } else {
      this.filteredList = getMockDestinationsByCategory(this.selectedCategory);
    }
  }

  /**
   * 切换收藏
   */
  private toggleFavorite(destinationId: string) {
    const index = this.favoriteIds.indexOf(destinationId);
    
    if (index === -1) {
      // 添加收藏
      this.favoriteIds.push(destinationId);
    } else {
      // 移除收藏
      this.favoriteIds.splice(index, 1);
    }
    
    // 保存
    this.saveFavorites();
  }

  /**
   * 跳转到路径概览页
   */
  private navigateToSummary(destination: NavigationDestination) {
    router.pushUrl({
      url: 'pages/NavigationSummaryPage',
      params: {
        destinationId: destination.id,
        destinationName: destination.name
      }
    });
  }

  build() {
    Column() {
      // 顶部标题栏
      this.TitleBar()
      
      // 搜索框
      SearchBar({
        keyword: $searchKeyword,
        placeholder: '搜索科室、药房、检验科...'
      })
        .width('90%')
        .margin({ top: 15, bottom: 15 })
        .onSearch((keyword: string) => {
          this.handleSearch(keyword);
        })
        .onClear(() => {
          this.handleSearch('');
        })
      
      // 分类标签
      this.CategoryTabs()
      
      // 内容区域
      if (this.isLoading) {
        // 加载状态
        LoadingView({ message: '加载目的地数据...' })
          .layoutWeight(1)
      } else if (this.filteredList.length === 0) {
        // 空状态
        EmptyView({ message: '未找到相关目的地' })
          .layoutWeight(1)
      } else {
        // 目的地列表
        this.DestinationList()
      }
      
      // 底部收藏快捷入口
      this.FavoriteBar()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  /**
   * 标题栏
   */
  @Builder
  TitleBar() {
    Row() {
      // 返回按钮
      Image($r('app.media.ic_back'))
        .width(24)
        .height(24)
        .fillColor('#333333')
        .onClick(() => {
          router.back();
        })
      
      Blank().width(15)
      
      // 标题
      Text('选择目的地')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .layoutWeight(1)
      
      // 收藏按钮
      Image($r('app.media.ic_favorite'))
        .width(24)
        .height(24)
        .fillColor(this.showFavorites ? '#FF4D4F' : '#999999')
        .onClick(() => {
          this.showFavorites = !this.showFavorites;
          if (this.showFavorites) {
            // 显示收藏列表
            this.filteredList = this.destinationList.filter(
              dest => this.favoriteIds.includes(dest.id)
            );
          } else {
            // 显示全部
            this.applyFilter();
          }
        })
    }
    .width('100%')
    .height(56)
    .padding({ left: 20, right: 20 })
    .backgroundColor('#FFFFFF')
  }

  /**
   * 分类标签
   */
  @Builder
  CategoryTabs() {
    Scroll() {
      Row() {
        // 全部分类
        CategoryTab({
          category: DestinationCategory.DEPARTMENT,
          name: '全部',
          icon: $r('app.media.ic_all'),
          count: this.destinationList.length,
          isSelected: this.selectedCategory === null
        })
          .onClick(() => {
            this.handleCategorySelect(null);
          })
        
        Blank().width(10)
        
        // 各分类
        ForEach(this.categories, (item: any) => {
          CategoryTab({
            category: item.category,
            name: item.name,
            icon: item.icon,
            count: getMockDestinationsByCategory(item.category).length,
            isSelected: this.selectedCategory === item.category
          })
            .onClick(() => {
              this.handleCategorySelect(item.category);
            })
          
          Blank().width(10)
        })
      }
      .padding({ left: 20, right: 20 })
    }
    .width('100%')
    .height(90)
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .backgroundColor('#FFFFFF')
    .margin({ bottom: 10 })
  }

  /**
   * 目的地列表
   */
  @Builder
  DestinationList() {
    List() {
      ForEach(this.filteredList, (destination: NavigationDestination) => {
        ListItem() {
          DestinationCard({
            destination: destination,
            isFavorite: this.favoriteIds.includes(destination.id),
            distance: 0,
            showDistance: false
          })
            .onFavoriteToggle(() => {
              this.toggleFavorite(destination.id);
            })
            .onClick(() => {
              this.navigateToSummary(destination);
            })
        }
        .margin({ bottom: 10 })
      })
    }
    .width('100%')
    .layoutWeight(1)
    .padding({ left: 20, right: 20, top: 10, bottom: 10 })
    .backgroundColor('#F5F5F5')
  }

  /**
   * 底部收藏栏
   */
  @Builder
  FavoriteBar() {
    Row() {
      // 收藏图标
      Image($r('app.media.ic_favorite_filled'))
        .width(20)
        .height(20)
        .fillColor('#FF4D4F')
      
      Blank().width(10)
      
      // 收藏数量
      Text(`我的收藏 (${this.favoriteIds.length})`)
        .fontSize(16)
        .fontColor('#333333')
        .layoutWeight(1)
      
      // 查看按钮
      if (this.favoriteIds.length > 0) {
        Row() {
          Text('查看')
            .fontSize(14)
            .fontColor('#52C41A')
          
          Image($r('app.media.ic_arrow_right'))
            .width(16)
            .height(16)
            .fillColor('#52C41A')
        }
        .onClick(() => {
          this.showFavorites = true;
          this.filteredList = this.destinationList.filter(
            dest => this.favoriteIds.includes(dest.id)
          );
        })
      }
    }
    .width('100%')
    .height(60)
    .padding({ left: 20, right: 20 })
    .backgroundColor('#FFFFFF')
    .border({ width: { top: 1 }, color: '#E5E5E5' })
  }
}
