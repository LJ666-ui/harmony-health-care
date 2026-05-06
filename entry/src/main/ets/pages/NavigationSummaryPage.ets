/**
 * AR院内导航系统 - 路径概览页面
 * 
 * 显示导航路径摘要和"开始导航"按钮
 * 
 * @version 1.0
 * @date 2025-01-18
 * @author SDD Agent
 */

import router from '@ohos.router';
import {
  NavigationDestination,
  NavigationPath,
  Position3D
} from '../models/ARNavigationModels';
import {
  getMockDestinationById,
  getMockNavigationPath
} from '../mock/arMock';
import { PathPlanner } from '../ar/PathPlanner';
import { LoadingView } from '../components/ARNavigationComponents';

@Entry
@Component
struct NavigationSummaryPage {
  // 路由参数
  private destinationId: string = '';
  private destinationName: string = '';

  // 状态变量
  @State destination: NavigationDestination | null = null;
  @State navigationPath: NavigationPath | null = null;
  @State isLoading: boolean = true;
  @State errorMessage: string = '';

  // 当前位置(模拟)
  private currentPosition: Position3D = { x: 0, y: 0, z: 0 };

  async aboutToAppear() {
    // 解析路由参数
    this.parseRouteParams();
    
    // 加载数据
    await this.loadData();
  }

  /**
   * 解析路由参数
   */
  private parseRouteParams() {
    const params = router.getParams() as any;
    
    if (params) {
      this.destinationId = params.destinationId || '';
      this.destinationName = params.destinationName || '';
    }
  }

  /**
   * 加载数据
   */
  private async loadData() {
    this.isLoading = true;
    this.errorMessage = '';

    try {
      // 1. 获取目的地信息
      this.destination = getMockDestinationById(this.destinationId);
      
      if (!this.destination) {
        this.errorMessage = '未找到目的地信息';
        this.isLoading = false;
        return;
      }

      // 2. 初始化路径规划器
      const pathPlanner = PathPlanner.getInstance();
      
      // 3. 计算导航路径
      // 使用模拟路径(实际应该调用pathPlanner.calculatePath)
      this.navigationPath = getMockNavigationPath();
      
      // 模拟计算延迟
      await this.simulateCalculation();
      
      this.isLoading = false;
    } catch (error) {
      console.error('[NavigationSummaryPage] 加载数据失败:', error);
      this.errorMessage = '路径计算失败,请重试';
      this.isLoading = false;
    }
  }

  /**
   * 模拟路径计算延迟
   */
  private async simulateCalculation(): Promise<void> {
    return new Promise<void>(resolve => {
      setTimeout(resolve, 1000);
    });
  }

  /**
   * 开始导航
   */
  private startNavigation() {
    if (!this.destination || !this.navigationPath) {
      return;
    }

    // 跳转到AR导航页面
    router.pushUrl({
      url: 'pages/ARNavigationPage',
      params: {
        destinationId: this.destination.id,
        destinationName: this.destination.name,
        pathData: JSON.stringify(this.navigationPath)
      }
    });
  }

  build() {
    Column() {
      // 顶部标题栏
      this.TitleBar()
      
      // 内容区域
      if (this.isLoading) {
        // 加载状态
        LoadingView({ message: '正在计算最优路径...' })
          .layoutWeight(1)
      } else if (this.errorMessage.length > 0) {
        // 错误状态
        this.ErrorView()
      } else {
        // 正常显示
        this.ContentArea()
      }
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
      Text('路径概览')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .layoutWeight(1)
    }
    .width('100%')
    .height(56)
    .padding({ left: 20, right: 20 })
    .backgroundColor('#FFFFFF')
  }

  /**
   * 错误视图
   */
  @Builder
  ErrorView() {
    Column() {
      Image($r('app.media.ic_error'))
        .width(80)
        .height(80)
        .fillColor('#FF4D4F')
      
      Blank().height(20)
      
      Text(this.errorMessage)
        .fontSize(16)
        .fontColor('#666666')
      
      Blank().height(30)
      
      Button('重新计算')
        .width(150)
        .height(45)
        .fontSize(16)
        .fontColor('#FFFFFF')
        .backgroundColor('#52C41A')
        .borderRadius(22)
        .onClick(() => {
          this.loadData();
        })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  /**
   * 内容区域
   */
  @Builder
  ContentArea() {
    Scroll() {
      Column() {
        // 目的地信息卡片
        this.DestinationCard()
        
        Blank().height(15)
        
        // 路径信息卡片
        this.PathInfoCard()
        
        Blank().height(15)
        
        // 途经点列表
        this.WaypointList()
        
        Blank().height(20)
        
        // 开始导航按钮
        this.StartNavigationButton()
      }
      .width('100%')
      .padding(20)
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Auto)
  }

  /**
   * 目的地信息卡片
   */
  @Builder
  DestinationCard() {
    Column() {
      Row() {
        // 目的地图标
        Column() {
          Image($r('app.media.ic_location'))
            .width(40)
            .height(40)
            .fillColor('#52C41A')
        }
        .width(60)
        .height(60)
        .backgroundColor('#F0FFF0')
        .borderRadius(30)
        .justifyContent(FlexAlign.Center)
        
        Blank().width(15)
        
        // 目的地信息
        Column() {
          Text(this.destination?.name || '')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          
          Blank().height(8)
          
          Text(this.destination?.description || '')
            .fontSize(14)
            .fontColor('#666666')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding(20)
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(15)
    .shadow({
      radius: 5,
      color: 'rgba(0, 0, 0, 0.1)',
      offsetX: 0,
      offsetY: 2
    })
  }

  /**
   * 路径信息卡片
   */
  @Builder
  PathInfoCard() {
    Column() {
      // 标题
      Row() {
        Text('路径信息')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
      }
      .width('100%')
      .margin({ bottom: 15 })
      
      // 路径统计
      Row() {
        // 总距离
        Column() {
          Text(`${Math.round(this.navigationPath?.totalDistance || 0)}`)
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#52C41A')
          
          Blank().height(5)
          
          Text('米')
            .fontSize(14)
            .fontColor('#666666')
        }
        .layoutWeight(1)
        
        // 分隔线
        Column()
          .width(1)
          .height(50)
          .backgroundColor('#E5E5E5')
        
        // 预计时间
        Column() {
          Text(`${Math.round((this.navigationPath?.estimatedTime || 0) / 60)}`)
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1890FF')
          
          Blank().height(5)
          
          Text('分钟')
            .fontSize(14)
            .fontColor('#666666')
        }
        .layoutWeight(1)
        
        // 分隔线
        Column()
          .width(1)
          .height(50)
          .backgroundColor('#E5E5E5')
        
        // 途经点数
        Column() {
          Text(`${this.navigationPath?.waypoints.length || 0}`)
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FAAD14')
          
          Blank().height(5)
          
          Text('途经点')
            .fontSize(14)
            .fontColor('#666666')
        }
        .layoutWeight(1)
      }
      .width('100%')
      
      // 楼层切换信息
      if (this.navigationPath && this.navigationPath.floorChanges.length > 0) {
        Blank().height(15)
        
        Row() {
          Image($r('app.media.ic_elevator'))
            .width(20)
            .height(20)
            .fillColor('#1890FF')
          
          Blank().width(10)
          
          Text('需要换乘楼层')
            .fontSize(14)
            .fontColor('#666666')
            .layoutWeight(1)
          
          Text(`${this.navigationPath.floorChanges.length}次`)
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1890FF')
        }
        .width('100%')
        .padding(10)
        .backgroundColor('#F0F5FF')
        .borderRadius(8)
      }
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(15)
    .shadow({
      radius: 5,
      color: 'rgba(0, 0, 0, 0.1)',
      offsetX: 0,
      offsetY: 2
    })
  }

  /**
   * 途经点列表
   */
  @Builder
  WaypointList() {
    Column() {
      // 标题
      Row() {
        Text('途经点')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1)
        
        Text(`共${this.navigationPath?.waypoints.length || 0}个`)
          .fontSize(14)
          .fontColor('#999999')
      }
      .width('100%')
      .margin({ bottom: 15 })
      
      // 途经点列表
      if (this.navigationPath) {
        ForEach(
          this.navigationPath.waypoints.slice(0, 5),
          (waypoint: any, index: number) => {
            Row() {
              // 序号
              Column() {
                Text(`${index + 1}`)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
              }
              .width(30)
              .height(30)
              .backgroundColor('#52C41A')
              .borderRadius(15)
              .justifyContent(FlexAlign.Center)
              
              Blank().width(15)
              
              // 指令
              Text(waypoint.instruction)
                .fontSize(14)
                .fontColor('#333333')
                .layoutWeight(1)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
              
              // 距离
              if (waypoint.distanceFromPrev > 0) {
                Text(`${Math.round(waypoint.distanceFromPrev)}m`)
                  .fontSize(12)
                  .fontColor('#999999')
              }
            }
            .width('100%')
            .padding({ top: 10, bottom: 10 })
            
            if (index < Math.min(this.navigationPath.waypoints.length, 5) - 1) {
              Column()
                .width(1)
                .height(20)
                .backgroundColor('#E5E5E5')
                .margin({ left: 15 })
            }
          }
        )
        
        // 更多提示
        if (this.navigationPath.waypoints.length > 5) {
          Row() {
            Text(`还有${this.navigationPath.waypoints.length - 5}个途经点`)
              .fontSize(12)
              .fontColor('#999999')
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .margin({ top: 10 })
        }
      }
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(15)
    .shadow({
      radius: 5,
      color: 'rgba(0, 0, 0, 0.1)',
      offsetX: 0,
      offsetY: 2
    })
  }

  /**
   * 开始导航按钮
   */
  @Builder
  StartNavigationButton() {
    Column() {
      Button('开始导航')
        .width('100%')
        .height(50)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .backgroundColor('#52C41A')
        .borderRadius(25)
        .onClick(() => {
          this.startNavigation();
        })
      
      Blank().height(10)
      
      Row() {
        Image($r('app.media.ic_info'))
          .width(16)
          .height(16)
          .fillColor('#999999')
        
        Blank().width(5)
        
        Text('导航过程中请保持网络连接和定位服务开启')
          .fontSize(12)
          .fontColor('#999999')
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
  }
}
