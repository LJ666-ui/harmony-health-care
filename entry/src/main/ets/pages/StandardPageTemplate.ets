/**
 * 标准ArkTS页面模板示例
 * Standard ArkTS Page Template Example
 *
 * 本页面展示了符合HarmonyOS开发规范的标准页面结构
 * 适用于DevEco Studio 6.0.2, SDK API 22
 *
 * @author Nebula Medical Team
 * @date 2026-05-06
 */

import { router } from '@kit.ArkUI';
import { http } from '@kit.NetworkKit';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { AccessibilityConfig } from '../utils/AccessibilityConfig';

/**
 * 数据项接口定义
 * 遵循类型安全原则，避免使用any
 */
interface DataItem {
  id: string;
  title: string;
  description: string;
  createTime: string;
  status: 'active' | 'inactive';
}

/**
 * API响应接口
 */
interface ApiResponse<T> {
  code: number;
  message: string;
  data: T[];
}

/**
 * 标准页面模板
 * 展示完整的页面开发规范
 */
@Entry
@Component
export struct StandardPageTemplate {
  // ==================== 状态管理 ====================

  /** 全局状态：老年模式 */
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  /** 页面状态：加载中 */
  @State isLoading: boolean = false;

  /** 页面状态：数据列表 */
  @State dataList: DataItem[] = [];

  /** 页面状态：错误信息 */
  @State errorMessage: string = '';

  /** 页面状态：当前页码 */
  @State currentPage: number = 1;

  /** 页面状态：是否有更多数据 */
  @State hasMore: boolean = true;

  // ==================== 配置实例 ====================

  /** 无障碍配置 */
  private theme: AccessibilityConfig = new AccessibilityConfig();

  /** API基础路径 */
  private readonly API_BASE_URL: string = 'http://localhost:8080/api';

  // ==================== 生命周期函数 ====================

  /**
   * 页面即将显示
   * 用于初始化数据和配置
   */
  aboutToAppear(): void {
    console.info('[StandardPageTemplate] aboutToAppear');
    this.theme = AccessibilityConfig.getInstance();
    this.loadData();
  }

  /**
   * 页面即将消失
   * 用于清理资源
   */
  aboutToDisappear(): void {
    console.info('[StandardPageTemplate] aboutToDisappear');
    // 清理定时器、取消网络请求等
  }

  /**
   * 页面显示
   */
  onPageShow(): void {
    console.info('[StandardPageTemplate] onPageShow');
  }

  /**
   * 页面隐藏
   */
  onPageHide(): void {
    console.info('[StandardPageTemplate] onPageHide');
  }

  /**
   * 返回键拦截
   * @returns true表示拦截，false表示默认处理
   */
  onBackPress(): boolean {
    console.info('[StandardPageTemplate] onBackPress');
    // 可以在这里实现：未保存提示、双击退出等
    return false;
  }

  // ==================== 数据加载 ====================

  /**
   * 加载数据
   * 遵循异步错误处理规范
   */
  private async loadData(): Promise<void> {
    try {
      this.isLoading = true;
      this.errorMessage = '';

      // 模拟网络请求
      // 实际项目中替换为真实API
      const response = await this.fetchDataFromApi();

      if (response.code === 200) {
        this.dataList = response.data;
        this.hasMore = response.data.length >= 10;
      } else {
        this.errorMessage = response.message || '数据加载失败';
      }
    } catch (error) {
      console.error('[StandardPageTemplate] 数据加载失败:', error);
      this.errorMessage = '网络异常，请检查网络连接';
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 从API获取数据
   * @returns API响应数据
   */
  private async fetchDataFromApi(): Promise<ApiResponse<DataItem>> {
    // 实际项目中使用真实API
    // const response = await http.request(
    //   `${this.API_BASE_URL}/data/list`,
    //   {
    //     method: http.RequestMethod.GET,
    //     header: {
    //       'Content-Type': 'application/json',
    //       'Authorization': 'Bearer token'
    //     }
    //   }
    // );

    // 模拟数据
    return new Promise((resolve) => {
      setTimeout(() => {
        resolve({
          code: 200,
          message: 'success',
          data: [
            {
              id: '1',
              title: '示例数据1',
              description: '这是示例数据描述',
              createTime: '2026-05-06',
              status: 'active'
            },
            {
              id: '2',
              title: '示例数据2',
              description: '这是示例数据描述',
              createTime: '2026-05-06',
              status: 'active'
            }
          ]
        });
      }, 1000);
    });
  }

  /**
   * 加载更多数据
   */
  private async loadMoreData(): Promise<void> {
    if (!this.hasMore || this.isLoading) {
      return;
    }

    try {
      this.currentPage++;
      // 加载更多逻辑...
    } catch (error) {
      console.error('[StandardPageTemplate] 加载更多失败:', error);
      this.currentPage--;
    }
  }

  // ==================== 事件处理 ====================

  /**
   * 处理列表项点击
   * @param item 点击的数据项
   */
  private handleItemClick(item: DataItem): void {
    console.info('[StandardPageTemplate] 点击项目:', item.id);

    // 使用router.pushUrl进行页面跳转
    router.pushUrl({
      url: 'pages/DetailPage',
      params: {
        id: item.id,
        title: item.title
      }
    }).catch((error: Error) => {
      console.error('[StandardPageTemplate] 页面跳转失败:', error);
      // 可以在这里显示错误提示
    });
  }

  /**
   * 处理刷新
   */
  private handleRefresh(): void {
    this.currentPage = 1;
    this.dataList = [];
    this.loadData();
  }

  /**
   * 处理重试
   */
  private handleRetry(): void {
    this.loadData();
  }

  // ==================== UI构建 ====================

  /**
   * 页面主构建函数
   */
  build() {
    Column() {
      // 页头
      Header({ title: '标准页面模板' })

      // 内容区域
      if (this.isLoading && this.dataList.length === 0) {
        // 首次加载状态
        this.buildLoadingState()
      } else if (this.errorMessage !== '') {
        // 错误状态
        this.buildErrorState()
      } else if (this.dataList.length === 0) {
        // 空数据状态
        this.buildEmptyState()
      } else {
        // 正常内容
        this.buildContent()
      }

      // 页脚
      Footer({ activeIndex: 0 })
    }
    .height('100%')
    .backgroundColor(AccessibilityConfig.getBackgroundColor())
  }

  /**
   * 构建加载状态
   */
  @Builder buildLoadingState(): void {
    Column() {
      LoadingProgress()
        .width(50)
        .height(50)
        .color('#3498DB')

      Text('加载中...')
        .fontSize(this.isElderMode ? 18 : 16)
        .fontColor('#999999')
        .margin({ top: 16 })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  /**
   * 构建错误状态
   */
  @Builder buildErrorState(): void {
    Column() {
      Text('❌')
        .fontSize(60)

      Text(this.errorMessage)
        .fontSize(this.isElderMode ? 18 : 16)
        .fontColor('#999999')
        .margin({ top: 16 })
        .textAlign(TextAlign.Center)

      Button('重试')
        .fontSize(this.isElderMode ? 18 : 16)
        .width(120)
        .height(this.isElderMode ? 50 : 44)
        .margin({ top: 24 })
        .onClick(() => {
          this.handleRetry();
        })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .padding({ left: 32, right: 32 })
  }

  /**
   * 构建空数据状态
   */
  @Builder buildEmptyState(): void {
    Column() {
      Text('📭')
        .fontSize(60)

      Text('暂无数据')
        .fontSize(this.isElderMode ? 18 : 16)
        .fontColor('#999999')
        .margin({ top: 16 })

      Button('刷新')
        .fontSize(this.isElderMode ? 18 : 16)
        .width(120)
        .height(this.isElderMode ? 50 : 44)
        .margin({ top: 24 })
        .onClick(() => {
          this.handleRefresh();
        })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  /**
   * 构建正常内容
   */
  @Builder buildContent(): void {
    Scroll() {
      Column({ space: this.isElderMode ? 16 : 12 }) {
        // 顶部提示卡片
        this.buildTipCard()

        // 数据列表
        ForEach(this.dataList, (item: DataItem) => {
          this.buildItemCard(item)
        }, (item: DataItem) => item.id)

        // 加载更多
        if (this.hasMore) {
          this.buildLoadMore()
        }
      }
      .padding({
        left: this.isElderMode ? 20 : 16,
        right: this.isElderMode ? 20 : 16,
        top: 12,
        bottom: 12
      })
    }
    .layoutWeight(1)
    .scrollBar(BarState.Auto)
    .edgeEffect(EdgeEffect.Spring)
  }

  /**
   * 构建提示卡片
   */
  @Builder buildTipCard(): void {
    Row() {
      Text('💡')
        .fontSize(this.isElderMode ? 28 : 24)

      Text('这是一个标准页面模板示例')
        .fontSize(this.isElderMode ? 16 : 14)
        .fontColor('#666666')
        .margin({ left: 8 })
        .layoutWeight(1)
    }
    .width('100%')
    .padding(this.isElderMode ? 20 : 16)
    .backgroundColor('#FFF9E6')
    .borderRadius(12)
    .border({ width: 1, color: '#FFE58F' })
  }

  /**
   * 构建列表项卡片
   * @param item 数据项
   */
  @Builder buildItemCard(item: DataItem): void {
    Column() {
      Row() {
        Text(item.title)
          .fontSize(this.isElderMode ? 20 : 18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1)

        Text(item.status === 'active' ? '✅' : '❌')
          .fontSize(this.isElderMode ? 24 : 20)
      }
      .width('100%')

      Text(item.description)
        .fontSize(this.isElderMode ? 16 : 14)
        .fontColor('#666666')
        .margin({ top: 8 })
        .width('100%')

      Row() {
        Text(`创建时间: ${item.createTime}`)
          .fontSize(this.isElderMode ? 14 : 12)
          .fontColor('#999999')

        Blank()

        Text('查看详情 >')
          .fontSize(this.isElderMode ? 14 : 12)
          .fontColor('#3498DB')
      }
      .width('100%')
      .margin({ top: 12 })
    }
    .width('100%')
    .padding(this.isElderMode ? 20 : 16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .border({ width: 1, color: '#F0F0F0' })
    .shadow({
      radius: 4,
      color: '#00000010',
      offsetX: 0,
      offsetY: 2
    })
    .onClick(() => {
      this.handleItemClick(item);
    })
  }

  /**
   * 构建加载更多
   */
  @Builder buildLoadMore(): void {
    Row() {
      if (this.isLoading) {
        LoadingProgress()
          .width(20)
          .height(20)
          .color('#3498DB')
          .margin({ right: 8 })
      }

      Text(this.isLoading ? '加载中...' : '上拉加载更多')
        .fontSize(this.isElderMode ? 16 : 14)
        .fontColor('#999999')
    }
    .width('100%')
    .height(50)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      if (!this.isLoading) {
        this.loadMoreData();
      }
    })
  }
}
