# 页面导航增强功能 - 任务清单

**版本**: v1.0
**创建日期**: 2025-01-14
**最后更新**: 2025-01-14
**关联需求**: spec.md v1.0
**关联设计**: design.md v1.0

## 任务概览

本文档将页面导航增强功能分解为可执行的编码任务，按照依赖关系和优先级排序。

**任务统计**:
- 主任务总数: 8
- 子任务总数: 24
- 预计工时: 16-20小时
- 优先级分布: P0(12个), P1(12个)

---

## 任务1: 创建导航基础设施 (P0)

**任务描述**: 创建导航管理相关的核心类和工具模块，为后续页面改造提供基础设施。

**输入**:
- 技术设计文档中的类设计规范
- 类型定义规范

**输出**:
- NavigationManager.ets
- NavigationTypes.ets
- NavigationErrorHandler.ets
- RouteConfigManager.ets

**验收标准**:
- 所有类文件创建完成
- 类型定义完整且类型安全
- 单元测试通过

### 子任务1.1: 创建NavigationTypes类型定义文件 (P0)

**描述**: 创建导航相关的TypeScript接口和类型定义。

**实施步骤**:
1. 在 `entry/src/main/ets/types/` 目录下创建 `NavigationTypes.ets`
2. 定义基础接口 `NavigationParams`
3. 定义各页面的参数接口：
   - HospitalDetailParams
   - DoctorDetailParams
   - ScienceDetailParams
   - HerbalDetailParams
   - FoodDetailParams
   - RehabCourseParams
   - RiskAssessmentParams
4. 定义错误类型枚举 `NavigationErrorType`
5. 定义路由配置接口 `RouteConfig` 和 `RouteMeta`

**代码生成提示**:
```typescript
// 创建文件: entry/src/main/ets/types/NavigationTypes.ets

/**
 * 导航参数基础接口
 */
export interface NavigationParams {
  [key: string]: string | number | boolean | object;
}

/**
 * 导航错误类型枚举
 */
export enum NavigationErrorType {
  ROUTE_NOT_FOUND = 'ROUTE_NOT_FOUND',
  INVALID_PARAMS = 'INVALID_PARAMS',
  NAVIGATION_FAILED = 'NAVIGATION_FAILED',
  PERMISSION_DENIED = 'PERMISSION_DENIED'
}

// ... 其他接口定义
```

**验证方法**: 编译通过，无类型错误

---

### 子任务1.2: 创建NavigationErrorHandler错误处理类 (P0)

**描述**: 创建统一的导航错误处理器。

**实施步骤**:
1. 在 `entry/src/main/ets/utils/` 目录下创建 `NavigationErrorHandler.ets`
2. 实现 `NavigationError` 错误类
3. 实现 `NavigationErrorHandler` 处理器类
4. 实现错误分类和用户提示映射
5. 实现错误日志记录

**代码生成提示**:
```typescript
// 创建文件: entry/src/main/ets/utils/NavigationErrorHandler.ets

import { NavigationErrorType } from '../types/NavigationTypes';

/**
 * 导航错误类
 */
export class NavigationError extends Error {
  public type: NavigationErrorType;
  public url: string;
  public timestamp: number;
  
  constructor(message: string, type: NavigationErrorType, url: string) {
    super(message);
    this.type = type;
    this.url = url;
    this.timestamp = Date.now();
  }
}

/**
 * 导航错误处理器
 */
export class NavigationErrorHandler {
  private static readonly ERROR_MESSAGES = {
    [NavigationErrorType.ROUTE_NOT_FOUND]: '页面不存在，请检查路由配置',
    [NavigationErrorType.INVALID_PARAMS]: '导航参数错误',
    [NavigationErrorType.NAVIGATION_FAILED]: '页面跳转失败，请重试',
    [NavigationErrorType.PERMISSION_DENIED]: '权限不足，无法访问该页面'
  };
  
  public static handle(error: Error, url: string): void {
    // 错误处理逻辑
  }
}
```

**验证方法**: 单元测试覆盖所有错误类型

---

### 子任务1.3: 创建RouteConfigManager路由配置管理器 (P0)

**描述**: 创建路由配置管理器，负责加载和验证路由。

**实施步骤**:
1. 在 `entry/src/main/ets/config/` 目录下创建 `RouteConfigManager.ets`
2. 实现单例模式
3. 实现 `initialize()` 方法，从 main_pages.json 加载路由
4. 实现 `hasRoute()` 验证方法
5. 实现 `getAllRoutes()` 查询方法
6. 实现 `addRoute()` 动态添加方法

**代码生成提示**:
```typescript
// 创建文件: entry/src/main/ets/config/RouteConfigManager.ets

export class RouteConfigManager {
  private static instance: RouteConfigManager;
  private routes: Set<string> = new Set();
  
  public static getInstance(): RouteConfigManager {
    if (!RouteConfigManager.instance) {
      RouteConfigManager.instance = new RouteConfigManager();
    }
    return RouteConfigManager.instance;
  }
  
  public initialize(): void {
    // 从 main_pages.json 加载路由配置
    // 将路由添加到 Set 中
  }
  
  public hasRoute(path: string): boolean {
    return this.routes.has(path);
  }
  
  // ... 其他方法
}
```

**验证方法**: 测试路由加载和验证功能

---

### 子任务1.4: 创建NavigationManager导航管理器 (P0)

**描述**: 创建核心导航管理器，提供统一的导航接口。

**实施步骤**:
1. 在 `entry/src/main/ets/utils/` 目录下创建 `NavigationManager.ets`
2. 实现单例模式
3. 实现 `navigateTo()` 无参数跳转方法
4. 实现 `navigateWithParams()` 带参数跳转方法
5. 实现 `goBack()` 返回方法
6. 实现 `replace()` 替换方法
7. 实现导航历史管理
8. 集成错误处理

**代码生成提示**:
```typescript
// 创建文件: entry/src/main/ets/utils/NavigationManager.ets

import { router } from '@kit.ArkUI';
import { NavigationErrorHandler } from './NavigationErrorHandler';
import { RouteConfigManager } from '../config/RouteConfigManager';

export class NavigationManager {
  private static instance: NavigationManager;
  private navigationHistory: string[] = [];
  private readonly MAX_HISTORY_SIZE = 50;
  
  public static getInstance(): NavigationManager {
    if (!NavigationManager.instance) {
      NavigationManager.instance = new NavigationManager();
    }
    return NavigationManager.instance;
  }
  
  public async navigateTo(url: string): Promise<void> {
    try {
      if (!RouteConfigManager.getInstance().hasRoute(url)) {
        throw new NavigationError(
          `Route not found: ${url}`,
          NavigationErrorType.ROUTE_NOT_FOUND,
          url
        );
      }
      
      await router.pushUrl({ url: url });
      this.addToHistory(url);
    } catch (error) {
      NavigationErrorHandler.handle(error, url);
      throw error;
    }
  }
  
  // ... 其他方法
}
```

**验证方法**: 单元测试所有导航方法

---

## 任务2: 更新路由配置文件 (P0)

**任务描述**: 检查并更新 main_pages.json，确保所有页面都已注册。

**输入**:
- 现有页面文件列表
- 现有 main_pages.json 配置

**输出**:
- 更新后的 main_pages.json

**验收标准**:
- 所有页面文件都在配置中注册
- 路由路径格式正确
- 应用能正常启动

### 子任务2.1: 扫描所有页面文件 (P0)

**描述**: 扫描 pages 目录，获取所有页面文件列表。

**实施步骤**:
1. 遍历 `entry/src/main/ets/pages/` 目录
2. 收集所有 .ets 文件名
3. 生成标准化的路由路径列表
4. 对比现有 main_pages.json
5. 识别未注册的页面

**验证方法**: 输出未注册页面列表

---

### 子任务2.2: 更新main_pages.json配置 (P0)

**描述**: 将未注册的页面添加到路由配置文件。

**实施步骤**:
1. 读取现有 main_pages.json
2. 添加缺失的页面路由
3. 保持配置文件格式规范
4. 写入更新后的配置

**代码生成提示**:
```json
// 更新文件: entry/src/main/resources/base/profile/main_pages.json

{
  "src": [
    "pages/Index",
    "pages/Login",
    "pages/Register",
    "pages/HomePage",
    // ... 现有页面
    
    // 新增页面
    "pages/AiConsultationPage",
    "pages/KnowledgeGraphPage",
    "pages/KnowledgeExplorePage",
    "pages/MedicalRecordSyncPage",
    "pages/TransferApprovalPage"
  ]
}
```

**验证方法**: 应用启动无路由错误

---

## 任务3: 修复缺少router导入的页面 (P0)

**任务描述**: 为识别出的缺少router导入的页面添加导航功能。

**输入**:
- 缺少router导入的页面列表
- NavigationManager类

**输出**:
- 修复后的页面文件

**验收标准**:
- 所有目标页面导入router或NavigationManager
- 页面具备跳转能力
- 编译无错误

### 子任务3.1: 修复AiConsultationPage页面 (P1)

**描述**: 为AI问诊页面添加导航功能。

**实施步骤**:
1. 打开 `entry/src/main/ets/pages/AiConsultationPage.ets`
2. 添加 NavigationManager 导入
3. 添加返回按钮或Header组件
4. 添加跳转到医生列表的功能
5. 添加跳转到聊天历史的功能

**代码生成提示**:
```typescript
// 修改文件: entry/src/main/ets/pages/AiConsultationPage.ets

// 添加导入
import { NavigationManager } from '../utils/NavigationManager';
import { Header } from '../components/Header';

@Entry
@Component
struct AiConsultationPage {
  // ... 现有代码
  
  build() {
    Column() {
      // 添加Header
      Header({ title: 'AI智能问诊', showBack: true })
      
      // ... 其他内容
      
      // 添加导航按钮
      Row() {
        Button('查看医生列表')
          .onClick(async () => {
            await NavigationManager.getInstance()
              .navigateTo('pages/DoctorListPage');
          })
        
        Button('问诊历史')
          .onClick(async () => {
            await NavigationManager.getInstance()
              .navigateTo('pages/BrowseHistoryPage');
          })
      }
    }
  }
}
```

**验证方法**: 页面能正常跳转

---

### 子任务3.2: 修复KnowledgeGraphPage页面 (P1)

**描述**: 为知识图谱页面添加导航功能。

**实施步骤**:
1. 打开 `entry/src/main/ets/pages/KnowledgeGraphPage.ets`
2. 添加 NavigationManager 导入
3. 确保Header组件有返回功能
4. 添加跳转到节点详情的功能
5. 添加跳转到相关知识的功能

**代码生成提示**:
```typescript
// 修改文件: entry/src/main/ets/pages/KnowledgeGraphPage.ets

import { NavigationManager } from '../utils/NavigationManager';
import { Header } from '../components/Header';

// 在节点点击事件中添加导航
private handleNodeClick(nodeId: number): void {
  NavigationManager.getInstance()
    .navigateWithParams('pages/ScienceDetailPage', { id: nodeId })
    .catch((error) => {
      console.error('导航失败:', error);
    });
}
```

**验证方法**: 点击节点能跳转到详情

---

### 子任务3.3: 修复KnowledgeExplorePage页面 (P1)

**描述**: 为知识探索页面添加导航功能。

**实施步骤**:
1. 打开 `entry/src/main/ets/pages/KnowledgeExplorePage.ets`
2. 添加 NavigationManager 导入
3. 添加返回功能
4. 添加跳转到详情页的功能

**验证方法**: 页面导航功能正常

---

### 子任务3.4: 修复MedicalRecordSyncPage页面 (P1)

**描述**: 为病历同步页面添加导航功能。

**实施步骤**:
1. 打开 `entry/src/main/ets/pages/MedicalRecordSyncPage.ets`
2. 添加 NavigationManager 导入
3. 添加返回功能
4. 添加跳转到设备管理页面的功能
5. 添加跳转到同步历史的功能

**代码生成提示**:
```typescript
// 修改文件: entry/src/main/ets/pages/MedicalRecordSyncPage.ets

import { NavigationManager } from '../utils/NavigationManager';

// 添加导航方法
private navigateToDeviceManagement(): void {
  NavigationManager.getInstance()
    .navigateTo('pages/DeviceManagePage')
    .catch((error) => {
      console.error('导航失败:', error);
    });
}
```

**验证方法**: 页面导航功能正常

---

### 子任务3.5: 修复TransferApprovalPage页面 (P1)

**描述**: 为转院审批页面添加导航功能。

**实施步骤**:
1. 打开 `entry/src/main/ets/pages/TransferApprovalPage.ets`
2. 添加 NavigationManager 导入
3. 添加返回功能
4. 添加跳转到申请详情的功能
5. 添加跳转到病历查看的功能

**验证方法**: 页面导航功能正常

---

## 任务4: 完善医疗服务页面导航 (P1)

**任务描述**: 为MedicalPage中缺少跳转的服务项添加导航功能。

**输入**:
- MedicalPage.ets 现有代码
- 服务项配置

**输出**:
- 完善后的MedicalPage.ets

**验收标准**:
- 所有服务项都有跳转逻辑
- 未实现的服务显示提示

### 子任务4.1: 为排队叫号服务添加跳转 (P1)

**描述**: 实现排队叫号服务的跳转功能。

**实施步骤**:
1. 打开 `entry/src/main/ets/pages/MedicalPage.ets`
2. 在服务点击事件中添加排队叫号的跳转逻辑
3. 如果目标页面不存在，创建占位页面

**代码生成提示**:
```typescript
// 修改文件: entry/src/main/ets/pages/MedicalPage.ets

// 在 buildMedicalServices() 方法中修改
.onClick(() => {
  try {
    if (service.id === 'appointment') {
      router.pushUrl({ url: 'pages/HospitalPage' });
    } else if (service.id === 'queue') {
      // 新增：排队叫号跳转
      router.pushUrl({ url: 'pages/QueuePage' });
    } else if (service.id === 'prescription') {
      router.pushUrl({ url: 'pages/Medications' });
    } else if (service.id === 'payment') {
      // 新增：缴费支付跳转
      router.pushUrl({ url: 'pages/PaymentPage' });
    } else if (service.id === 'hospital_nav') {
      router.pushUrl({ url: 'pages/ARNavigationPage' });
    } else if (service.id === 'report') {
      router.pushUrl({ url: 'pages/HealthRecords' });
    } else {
      console.log(`服务 ${service.title} 暂未开放`);
    }
  } catch (error) {
    console.error('导航失败:', error);
  }
})
```

**验证方法**: 点击排队叫号能跳转

---

### 子任务4.2: 为缴费支付服务添加跳转 (P1)

**描述**: 实现缴费支付服务的跳转功能。

**实施步骤**:
1. 在MedicalPage中添加缴费支付跳转逻辑
2. 如果目标页面不存在，创建占位页面或显示提示

**验证方法**: 点击缴费支付能跳转或显示提示

---

### 子任务4.3: 创建缺失的服务页面占位符 (P2)

**描述**: 为未实现的服务创建占位页面。

**实施步骤**:
1. 创建 QueuePage.ets (排队叫号占位页)
2. 创建 PaymentPage.ets (缴费支付占位页)
3. 在 main_pages.json 中注册新页面

**代码生成提示**:
```typescript
// 创建文件: entry/src/main/ets/pages/QueuePage.ets

import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';

@Entry
@Component
struct QueuePage {
  build() {
    Column() {
      Header({ title: '排队叫号', showBack: true })
      
      Column() {
        Text('排队叫号功能')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
        
        Text('功能开发中，敬请期待')
          .fontSize(16)
          .fontColor('#999999')
          .margin({ top: 20 })
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
  }
}
```

**验证方法**: 占位页面能正常访问

---

## 任务5: 增强Header组件 (P1)

**任务描述**: 增强Header组件的导航功能，支持更灵活的返回操作。

**输入**:
- 现有Header组件代码

**输出**:
- 增强后的Header组件

**验收标准**:
- Header支持showBack参数
- Header支持自定义返回路径
- 返回功能正常工作

### 子任务5.1: 为Header添加返回功能支持 (P1)

**描述**: 增强Header组件，添加返回按钮和自定义返回路径支持。

**实施步骤**:
1. 打开 `entry/src/main/ets/components/Header.ets`
2. 添加 showBack 属性
3. 添加 backUrl 属性（可选）
4. 实现返回按钮UI
5. 实现返回逻辑

**代码生成提示**:
```typescript
// 修改文件: entry/src/main/ets/components/Header.ets

import { router } from '@kit.ArkUI';

@Component
export struct Header {
  @Prop title: string = '';
  @Prop showBack: boolean = false;      // 新增：是否显示返回按钮
  @Prop backUrl?: string;                // 新增：自定义返回路径
  @Prop rightIcon?: string;              // 右侧图标
  @Prop onRightClick?: () => void;       // 右侧点击事件
  
  private handleBack(): void {
    if (this.backUrl) {
      router.pushUrl({ url: this.backUrl });
    } else {
      router.back();
    }
  }
  
  build() {
    Row() {
      // 返回按钮
      if (this.showBack) {
        Text('←')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .width(40)
          .height(40)
          .textAlign(TextAlign.Center)
          .onClick(() => this.handleBack())
      } else {
        // 占位，保持布局一致
        Blank().width(40)
      }
      
      // 标题
      Text(this.title)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
      
      // 右侧操作
      if (this.rightIcon) {
        Text(this.rightIcon)
          .fontSize(20)
          .width(40)
          .height(40)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            if (this.onRightClick) {
              this.onRightClick();
            }
          })
      } else {
        Blank().width(40)
      }
    }
    .width('100%')
    .height(56)
    .backgroundColor('#FFFFFF')
    .border({ width: { bottom: 1 }, color: '#F0F0F0' })
  }
}
```

**验证方法**: Header返回功能正常

---

## 任务6: 统一现有页面的导航方式 (P1)

**任务描述**: 将现有页面中直接使用router的代码统一改为使用NavigationManager。

**输入**:
- 现有页面代码
- NavigationManager类

**输出**:
- 统一后的页面代码

**验收标准**:
- 关键页面使用NavigationManager
- 导航逻辑一致
- 错误处理统一

### 子任务6.1: 更新HomePage使用NavigationManager (P1)

**描述**: 将HomePage的导航代码改为使用NavigationManager。

**实施步骤**:
1. 打开 `entry/src/main/ets/pages/HomePage.ets`
2. 导入 NavigationManager
3. 替换 router.pushUrl 为 NavigationManager.navigateTo

**验证方法**: 首页导航功能正常

---

### 子任务6.2: 更新MedicalPage使用NavigationManager (P1)

**描述**: 将MedicalPage的导航代码改为使用NavigationManager。

**实施步骤**:
1. 打开 `entry/src/main/ets/pages/MedicalPage.ets`
2. 导入 NavigationManager
3. 替换导航调用

**验证方法**: 医疗服务页导航正常

---

### 子任务6.3: 更新HealthPage使用NavigationManager (P1)

**描述**: 将HealthPage的导航代码改为使用NavigationManager。

**实施步骤**:
1. 打开 `entry/src/main/ets/pages/HealthPage.ets`
2. 导入 NavigationManager
3. 替换导航调用

**验证方法**: 健康中心页导航正常

---

### 子任务6.4: 更新Profile使用NavigationManager (P1)

**描述**: 将Profile的导航代码改为使用NavigationManager。

**实施步骤**:
1. 打开 `entry/src/main/ets/pages/Profile.ets`
2. 导入 NavigationManager
3. 替换导航调用

**验证方法**: 个人中心页导航正常

---

## 任务7: 添加导航错误提示UI (P2)

**任务描述**: 创建用户友好的导航错误提示组件。

**输入**:
- NavigationErrorHandler

**输出**:
- NavigationErrorToast组件
- 集成到ErrorHandler

**验收标准**:
- 错误提示UI友好
- 提示信息清晰
- 不影响用户体验

### 子任务7.1: 创建NavigationErrorToast组件 (P2)

**描述**: 创建导航错误提示Toast组件。

**实施步骤**:
1. 在 `entry/src/main/ets/components/` 创建 `NavigationErrorToast.ets`
2. 实现Toast显示逻辑
3. 支持不同错误类型的图标和颜色
4. 自动消失功能

**代码生成提示**:
```typescript
// 创建文件: entry/src/main/ets/components/NavigationErrorToast.ets

@Component
export struct NavigationErrorToast {
  @Prop message: string = '';
  @Prop showError: boolean = false;
  @State private opacity: number = 0;
  
  aboutToAppear(): void {
    if (this.showError) {
      // 淡入动画
      animateTo({ duration: 300 }, () => {
        this.opacity = 1;
      });
      
      // 3秒后自动消失
      setTimeout(() => {
        animateTo({ duration: 300 }, () => {
          this.opacity = 0;
        });
      }, 3000);
    }
  }
  
  build() {
    if (this.showError) {
      Row() {
        Text('⚠️').fontSize(20)
        Text(this.message)
          .fontSize(14)
          .fontColor('#FFFFFF')
          .margin({ left: 8 })
      }
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor('#FF6B6B')
      .borderRadius(8)
      .opacity(this.opacity)
      .position({ x: '50%', y: 80 })
      .translate({ x: '-50%' })
    }
  }
}
```

**验证方法**: 错误时显示提示

---

### 子任务7.2: 集成错误提示到ErrorHandler (P2)

**描述**: 将Toast组件集成到NavigationErrorHandler。

**实施步骤**:
1. 修改 NavigationErrorHandler
2. 使用AppStorage传递错误状态
3. 在页面中显示Toast

**验证方法**: 导航失败时显示Toast

---

## 任务8: 测试和验证 (P0)

**任务描述**: 全面测试导航功能，确保所有需求得到满足。

**输入**:
- 所有修改后的代码

**输出**:
- 测试报告
- 问题修复

**验收标准**:
- 所有页面跳转正常
- 错误处理正确
- 性能符合要求

### 子任务8.1: 单元测试 (P0)

**描述**: 编写和运行单元测试。

**实施步骤**:
1. 为NavigationManager编写单元测试
2. 为NavigationErrorHandler编写单元测试
3. 为RouteConfigManager编写单元测试
4. 运行所有测试，确保通过

**验证方法**: 测试覆盖率>80%

---

### 子任务8.2: 集成测试 (P0)

**描述**: 测试页面间的导航流程。

**实施步骤**:
1. 测试首页到各功能页的跳转
2. 测试带参数的跳转
3. 测试返回导航
4. 测试错误场景

**验证方法**: 所有导航流程正常

---

### 子任务8.3: 真机测试 (P1)

**描述**: 在真实HarmonyOS设备上测试。

**实施步骤**:
1. 部署应用到真机
2. 测试所有导航功能
3. 测试性能指标
4. 记录测试结果

**验证方法**: 真机运行无问题

---

### 子任务8.4: 性能测试 (P2)

**描述**: 测试导航性能指标。

**实施步骤**:
1. 测量页面跳转时间
2. 测量路由验证时间
3. 测量内存占用
4. 对比性能目标

**验证方法**: 性能符合设计目标

---

## 任务依赖关系图

```
任务1 (基础设施)
  ├─→ 任务2 (路由配置)
  ├─→ 任务3 (修复页面)
  ├─→ 任务4 (医疗服务)
  └─→ 任务5 (Header增强)
        ↓
     任务6 (统一导航)
        ↓
     任务7 (错误提示)
        ↓
     任务8 (测试验证)
```

## 执行建议

### 优先级执行顺序

**第一阶段 (P0任务)**:
1. 任务1: 创建导航基础设施
2. 任务2: 更新路由配置文件
3. 任务8.1-8.2: 单元测试和集成测试

**第二阶段 (P1任务)**:
4. 任务3: 修复缺少router导入的页面
5. 任务4: 完善医疗服务页面导航
6. 任务5: 增强Header组件
7. 任务6: 统一现有页面的导航方式
8. 任务8.3: 真机测试

**第三阶段 (P2任务)**:
9. 任务7: 添加导航错误提示UI
10. 任务8.4: 性能测试

### 注意事项

1. **每完成一个任务，立即进行验证**
2. **保持代码风格一致**
3. **及时提交代码，避免冲突**
4. **遇到问题及时记录和反馈**
5. **优先保证核心功能，再优化体验**

## 变更历史

| 版本 | 日期 | 变更内容 | 作者 |
|-----|------|---------|------|
| v1.0 | 2025-01-14 | 初始版本创建 | AI Assistant |
