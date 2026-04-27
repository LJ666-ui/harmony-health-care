# 页面导航增强功能 - 技术设计文档

**版本**: v1.0
**创建日期**: 2025-01-14
**最后更新**: 2025-01-14
**作者**: AI Assistant
**状态**: 草稿

## 1. 设计概述

### 1.1 设计目标
本技术设计旨在为HarmonyOS智慧医疗应用提供完整、可靠的页面导航解决方案，具体目标包括：
- 统一页面导航实现方式
- 确保所有页面具备跳转能力
- 提供健壮的错误处理机制
- 优化用户导航体验
- 提高代码可维护性

### 1.2 技术选型

| 技术组件 | 选型方案 | 选型理由 |
|---------|---------|---------|
| 路由框架 | @kit.ArkUI router | HarmonyOS官方路由解决方案，稳定可靠 |
| 状态管理 | @State/@Link装饰器 | 原生响应式状态管理，性能优异 |
| 错误处理 | try-catch + Logger | 统一错误捕获和日志记录 |
| 类型系统 | ArkTS强类型 | 编译时类型检查，减少运行时错误 |
| 导航参数 | Interface定义 | 类型安全的参数传递 |

### 1.3 设计约束

**技术约束**:
- 必须使用HarmonyOS ArkUI框架提供的router模块
- 遵循ArkTS语法规范，不使用any类型
- 保持与现有代码风格一致
- 不引入第三方路由库

**业务约束**:
- 不改变现有页面业务逻辑
- 保持现有UI布局不变
- 兼容现有导航流程
- 不影响页面性能

**兼容性约束**:
- 支持HarmonyOS 6.0及以上版本
- 兼容不同设备尺寸
- 支持无障碍访问

## 2. 架构设计

### 2.1 整体架构

```
┌─────────────────────────────────────────────────────────┐
│                    应用层 (Pages)                        │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐              │
│  │ HomePage │  │MedicalPage│  │ProfilePage│ ...         │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘              │
└───────┼─────────────┼─────────────┼─────────────────────┘
        │             │             │
┌───────┼─────────────┼─────────────┼─────────────────────┐
│       │      导航服务层 (NavigationService)              │
│  ┌────▼─────────────▼─────────────▼─────┐              │
│  │   NavigationManager (统一导航管理)    │              │
│  └───────────────┬──────────────────────┘              │
│                  │                                      │
│  ┌───────────────▼──────────────────────┐              │
│  │   ErrorHandler (错误处理)             │              │
│  └──────────────────────────────────────┘              │
└─────────────────────────────────────────────────────────┘
        │
┌───────▼─────────────────────────────────────────────────┐
│              基础设施层 (Infrastructure)                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │ Router Module│  │ Logger Module│  │ Config Module│  │
│  │  (@kit.ArkUI)│  │   (console)  │  │(main_pages)  │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### 2.2 模块划分

| 模块名称 | 职责说明 | 关键文件 |
|---------|---------|---------|
| NavigationManager | 统一导航管理，提供跳转、返回等方法 | utils/NavigationManager.ets |
| ErrorHandler | 导航错误处理和用户提示 | utils/NavigationErrorHandler.ets |
| RouteConfig | 路由配置管理和验证 | config/RouteConfig.ets |
| PageRegistry | 页面注册和发现 | config/PageRegistry.ets |
| NavigationTypes | 导航相关类型定义 | types/NavigationTypes.ets |

### 2.3 依赖关系

```
Pages (页面层)
  ↓ 依赖
NavigationManager (导航管理)
  ↓ 依赖
ErrorHandler + RouteConfig
  ↓ 依赖
Router Module (@kit.ArkUI)
```

**依赖原则**:
- 单向依赖，禁止循环依赖
- 页面层只依赖NavigationManager
- NavigationManager封装底层router API

## 3. 模块详细设计

### 3.1 NavigationManager

#### 3.1.1 职责定义
NavigationManager是导航系统的核心模块，负责：
- 提供统一的页面跳转接口
- 管理导航参数传递
- 处理导航生命周期
- 记录导航历史

#### 3.1.2 类/接口设计

```typescript
/**
 * 导航管理器 - 提供统一的页面导航接口
 */
export class NavigationManager {
  private static instance: NavigationManager;
  private navigationHistory: string[] = [];
  
  /**
   * 获取单例实例
   */
  public static getInstance(): NavigationManager;
  
  /**
   * 页面跳转（无参数）
   * @param url 目标页面路径
   * @returns Promise<void>
   */
  public async navigateTo(url: string): Promise<void>;
  
  /**
   * 页面跳转（带参数）
   * @param url 目标页面路径
   * @param params 导航参数
   * @returns Promise<void>
   */
  public async navigateWithParams<T>(url: string, params: T): Promise<void>;
  
  /**
   * 返回上一页
   * @returns Promise<void>
   */
  public async goBack(): Promise<void>;
  
  /**
   * 返回到指定页面
   * @param url 目标页面路径
   * @returns Promise<void>
   */
  public async backTo(url: string): Promise<void>;
  
  /**
   * 替换当前页面
   * @param url 目标页面路径
   * @returns Promise<void>
   */
  public async replace(url: string): Promise<void>;
  
  /**
   * 获取当前页面路径
   * @returns string
   */
  public getCurrentPage(): string;
  
  /**
   * 获取导航历史
   * @returns string[]
   */
  public getHistory(): string[];
}
```

#### 3.1.3 关键方法实现

**navigateTo方法**:
```typescript
public async navigateTo(url: string): Promise<void> {
  try {
    // 验证路由路径
    if (!this.validateRoute(url)) {
      throw new NavigationError(`Invalid route: ${url}`);
    }
    
    // 执行跳转
    await router.pushUrl({ url: url });
    
    // 记录导航历史
    this.addToHistory(url);
    
    // 记录日志
    Logger.info(`Navigation success: ${url}`);
  } catch (error) {
    // 错误处理
    ErrorHandler.handle(error, url);
    throw error;
  }
}
```

**navigateWithParams方法**:
```typescript
public async navigateWithParams<T>(url: string, params: T): Promise<void> {
  try {
    // 验证参数
    if (!params) {
      throw new NavigationError('Navigation params cannot be null');
    }
    
    // 执行带参数跳转
    await router.pushUrl({
      url: url,
      params: params
    });
    
    this.addToHistory(url);
    Logger.info(`Navigation with params success: ${url}`);
  } catch (error) {
    ErrorHandler.handle(error, url);
    throw error;
  }
}
```

#### 3.1.4 数据流

```
用户点击导航按钮
  ↓
页面调用 NavigationManager.navigateTo(url)
  ↓
NavigationManager 验证路由
  ↓
调用 router.pushUrl()
  ↓
成功 → 记录历史 → 返回
失败 → ErrorHandler处理 → 提示用户
```

### 3.2 ErrorHandler

#### 3.2.1 职责定义
ErrorHandler负责统一处理导航过程中的各种错误，包括：
- 路由不存在错误
- 参数验证错误
- 运行时跳转错误
- 提供用户友好的错误提示

#### 3.2.2 类/接口设计

```typescript
/**
 * 导航错误类型枚举
 */
export enum NavigationErrorType {
  ROUTE_NOT_FOUND = 'ROUTE_NOT_FOUND',
  INVALID_PARAMS = 'INVALID_PARAMS',
  NAVIGATION_FAILED = 'NAVIGATION_FAILED',
  PERMISSION_DENIED = 'PERMISSION_DENIED'
}

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
  /**
   * 处理导航错误
   * @param error 错误对象
   * @param url 目标URL
   */
  public static handle(error: Error, url: string): void;
  
  /**
   * 获取用户友好的错误消息
   * @param errorType 错误类型
   * @returns string
   */
  private static getUserMessage(errorType: NavigationErrorType): string;
  
  /**
   * 记录错误日志
   * @param error 错误对象
   * @param url 目标URL
   */
  private static logError(error: Error, url: string): void;
}
```

#### 3.2.3 错误处理流程

```
捕获错误
  ↓
识别错误类型
  ↓
├─ ROUTE_NOT_FOUND → 提示"页面不存在"
├─ INVALID_PARAMS → 提示"参数错误"
├─ NAVIGATION_FAILED → 提示"跳转失败，请重试"
└─ PERMISSION_DENIED → 提示"权限不足"
  ↓
记录错误日志
  ↓
显示用户提示
```

### 3.3 RouteConfig

#### 3.3.1 职责定义
RouteConfig负责管理应用的路由配置，包括：
- 加载路由配置文件
- 验证路由路径有效性
- 提供路由查询接口

#### 3.3.2 类/接口设计

```typescript
/**
 * 路由配置项
 */
export interface RouteConfig {
  path: string;
  name?: string;
  meta?: RouteMeta;
}

/**
 * 路由元信息
 */
export interface RouteMeta {
  title?: string;
  requiresAuth?: boolean;
  keepAlive?: boolean;
}

/**
 * 路由配置管理器
 */
export class RouteConfigManager {
  private static instance: RouteConfigManager;
  private routes: Set<string> = new Set();
  
  /**
   * 获取单例实例
   */
  public static getInstance(): RouteConfigManager;
  
  /**
   * 初始化路由配置
   * 从main_pages.json加载路由
   */
  public initialize(): void;
  
  /**
   * 验证路由是否存在
   * @param path 路由路径
   * @returns boolean
   */
  public hasRoute(path: string): boolean;
  
  /**
   * 获取所有路由
   * @returns string[]
   */
  public getAllRoutes(): string[];
  
  /**
   * 添加新路由
   * @param path 路由路径
   */
  public addRoute(path: string): void;
}
```

### 3.4 NavigationTypes

#### 3.4.1 类型定义

```typescript
/**
 * 导航参数基础接口
 */
export interface NavigationParams {
  [key: string]: string | number | boolean | object;
}

/**
 * 医院详情页参数
 */
export interface HospitalDetailParams extends NavigationParams {
  hospitalId: string;
  hospitalName?: string;
}

/**
 * 医生详情页参数
 */
export interface DoctorDetailParams extends NavigationParams {
  doctorId: string;
  departmentId?: string;
}

/**
 * 科学科普详情页参数
 */
export interface ScienceDetailParams extends NavigationParams {
  articleId: string;
  category?: string;
}

/**
 * 草药详情页参数
 */
export interface HerbalDetailParams extends NavigationParams {
  herbalId: string;
  name?: string;
}

/**
 * 食物详情页参数
 */
export interface FoodDetailParams extends NavigationParams {
  foodId: string;
  category?: string;
}

/**
 * 康复课程参数
 */
export interface RehabCourseParams extends NavigationParams {
  courseId: string;
  courseType?: string;
}

/**
 * 风险评估参数
 */
export interface RiskAssessmentParams extends NavigationParams {
  assessmentId?: string;
  type?: string;
}
```

## 4. 数据模型设计

### 4.1 核心数据结构

**导航状态模型**:
```typescript
/**
 * 导航状态
 */
export interface NavigationState {
  currentPage: string;          // 当前页面路径
  previousPage: string | null;  // 上一页面路径
  navigationStack: string[];    // 导航栈
  params: NavigationParams;     // 当前页面参数
}
```

**导航历史记录**:
```typescript
/**
 * 导航历史记录项
 */
export interface NavigationHistoryItem {
  url: string;                  // 页面路径
  timestamp: number;            // 导航时间戳
  params?: NavigationParams;    // 导航参数
  from: string;                 // 来源页面
}
```

### 4.2 数据关系

```
NavigationState (导航状态)
  │
  ├── currentPage: string
  │
  ├── navigationStack: NavigationHistoryItem[]
  │     │
  │     ├── url
  │     ├── timestamp
  │     ├── params
  │     └── from
  │
  └── params: NavigationParams
        │
        ├── [key: string]
        └── ...
```

### 4.3 数据存储

**运行时存储**:
- 导航栈：存储在NavigationManager的内存中
- 当前参数：通过router.getState()获取

**持久化存储**:
- 路由配置：main_pages.json文件
- 不持久化导航历史（每次启动清空）

## 5. API设计

### 5.1 内部API

**NavigationManager API**:
```typescript
// 页面跳转API
NavigationManager.navigateTo(url: string): Promise<void>
NavigationManager.navigateWithParams<T>(url: string, params: T): Promise<void>
NavigationManager.goBack(): Promise<void>
NavigationManager.replace(url: string): Promise<void>

// 状态查询API
NavigationManager.getCurrentPage(): string
NavigationManager.getHistory(): string[]
```

**RouteConfigManager API**:
```typescript
// 路由管理API
RouteConfigManager.hasRoute(path: string): boolean
RouteConfigManager.getAllRoutes(): string[]
RouteConfigManager.addRoute(path: string): void
```

### 5.2 页面使用示例

**基础跳转**:
```typescript
// 在页面中使用
import { NavigationManager } from '../utils/NavigationManager';

// 无参数跳转
Button('跳转到医院列表')
  .onClick(async () => {
    await NavigationManager.getInstance().navigateTo('pages/HospitalPage');
  })

// 带参数跳转
Button('查看医院详情')
  .onClick(async () => {
    const params: HospitalDetailParams = {
      hospitalId: '123',
      hospitalName: '协和医院'
    };
    await NavigationManager.getInstance()
      .navigateWithParams('pages/HospitalDetailPage', params);
  })
```

**返回导航**:
```typescript
// 返回上一页
Button('返回')
  .onClick(async () => {
    await NavigationManager.getInstance().goBack();
  })
```

### 5.3 API规范

**请求格式**:
```typescript
// 跳转请求
{
  url: string,           // 必填：目标页面路径
  params?: object        // 可选：导航参数
}
```

**响应格式**:
```typescript
// 成功响应
Promise<void>  // 异步操作完成

// 错误响应
throw NavigationError {
  message: string,
  type: NavigationErrorType,
  url: string,
  timestamp: number
}
```

## 6. 关键算法设计

### 6.1 路由验证算法

#### 算法原理
在执行跳转前，验证目标路由是否在配置文件中注册，防止跳转到不存在的页面。

#### 伪代码
```
FUNCTION validateRoute(url: string): boolean
  // 标准化路由路径
  normalizedPath = normalizePath(url)
  
  // 检查路由是否存在于配置中
  IF RouteConfigManager.hasRoute(normalizedPath) THEN
    RETURN true
  ELSE
    LOG warning: "Route not found: " + normalizedPath
    RETURN false
  END IF
END FUNCTION

FUNCTION normalizePath(url: string): string
  // 移除文件扩展名
  path = url.replace('.ets', '')
  
  // 确保以pages/开头
  IF NOT path.startsWith('pages/') THEN
    path = 'pages/' + path
  END IF
  
  RETURN path
END FUNCTION
```

#### 复杂度分析
- 时间复杂度：O(1) - 使用Set存储路由，查找时间为常数
- 空间复杂度：O(n) - n为路由数量

### 6.2 导航历史管理算法

#### 算法原理
维护一个导航栈，记录用户的导航历史，支持返回操作。

#### 伪代码
```
CLASS NavigationHistory
  PRIVATE stack: string[] = []
  PRIVATE MAX_SIZE: number = 50
  
  FUNCTION push(url: string): void
    // 限制栈大小，防止内存溢出
    IF stack.length >= MAX_SIZE THEN
      stack.shift()  // 移除最早的记录
    END IF
    
    stack.push(url)
  END FUNCTION
  
  FUNCTION pop(): string | null
    IF stack.length > 0 THEN
      RETURN stack.pop()
    ELSE
      RETURN null
    END IF
  END FUNCTION
  
  FUNCTION peek(): string | null
    IF stack.length > 0 THEN
      RETURN stack[stack.length - 1]
    ELSE
      RETURN null
    END IF
  END FUNCTION
END CLASS
```

#### 复杂度分析
- 时间复杂度：push O(1), pop O(1), peek O(1)
- 空间复杂度：O(MAX_SIZE) = O(50) = O(1)

## 7. UI/UX设计

### 7.1 页面结构

**导航层级关系**:
```
Index (入口页面)
  ├── Login (登录页)
  ├── Register (注册页)
  └── HomePage (首页)
        ├── MedicalPage (医疗服务)
        │     ├── HospitalPage (医院列表)
        │     │     └── HospitalDetailPage (医院详情)
        │     ├── Medications (用药管理)
        │     └── HealthRecords (健康档案)
        ├── HealthPage (健康中心)
        │     ├── RiskAssessmentPage (风险评估)
        │     ├── DigitalTwinPage (数字孪生)
        │     └── MonitoringDashboard (监控面板)
        ├── RehabPage (康复中心)
        │     ├── RehabListPage (康复课程)
        │     └── Rehab3DPage (3D康复)
        ├── SciencePage (健康科普)
        │     ├── ScienceListPage (科普列表)
        │     └── ScienceDetailPage (科普详情)
        └── Profile (个人中心)
              ├── DeviceDiscoveryPage (设备发现)
              ├── StatisticsPage (统计报告)
              └── PrivacySettingPage (隐私设置)
```

### 7.2 组件设计

**Header组件增强**:
```typescript
@Component
export struct Header {
  @Prop title: string = '';
  @Prop showBack: boolean = false;        // 是否显示返回按钮
  @Prop backUrl?: string;                 // 自定义返回路径
  @Prop rightAction?: HeaderAction;       // 右侧操作按钮
  
  private handleBack(): void {
    if (this.backUrl) {
      NavigationManager.getInstance().navigateTo(this.backUrl);
    } else {
      NavigationManager.getInstance().goBack();
    }
  }
  
  build() {
    Row() {
      // 返回按钮
      if (this.showBack) {
        Text('←')
          .onClick(() => this.handleBack())
      }
      
      // 标题
      Text(this.title)
      
      // 右侧操作
      if (this.rightAction) {
        Text(this.rightAction.icon)
          .onClick(() => this.rightAction.onClick())
      }
    }
  }
}
```

**NavigationButton组件**:
```typescript
@Component
export struct NavigationButton {
  @Prop text: string = '';
  @Prop targetUrl: string = '';
  @Prop params?: NavigationParams;
  @Prop buttonStyle?: ButtonStyle;
  
  private async handleNavigation(): Promise<void> {
    try {
      const navManager = NavigationManager.getInstance();
      if (this.params) {
        await navManager.navigateWithParams(this.targetUrl, this.params);
      } else {
        await navManager.navigateTo(this.targetUrl);
      }
    } catch (error) {
      // 错误已在NavigationManager中处理
    }
  }
  
  build() {
    Button(this.text)
      .onClick(() => this.handleNavigation())
  }
}
```

### 7.3 交互流程

**页面跳转时序图**:
```
用户          页面组件       NavigationManager    Router      ErrorHandler
 │               │                  │               │              │
 │─点击按钮────→│                  │               │              │
 │               │─navigateTo()──→│               │              │
 │               │                  │─validate()──→│              │
 │               │                  │←─valid──────│              │
 │               │                  │─pushUrl()──→│              │
 │               │                  │               │─执行跳转──→│
 │               │                  │←─success────│              │
 │               │←─resolved──────│               │              │
 │←─跳转完成────│                  │               │              │
 │               │                  │               │              │
 │               │                  │─(如果失败)──→│              │
 │               │                  │               │─error────→│
 │               │                  │←─────────────────handle()─│
 │               │                  │─显示提示────────────────→│
 │←─错误提示────│                  │               │              │
```

## 8. 性能设计

### 8.1 性能目标

| 性能指标 | 目标值 | 测量方法 |
|---------|--------|---------|
| 页面跳转时间 | < 500ms | 从点击到新页面渲染完成 |
| 路由验证时间 | < 10ms | validateRoute方法执行时间 |
| 导航历史查询 | < 5ms | getHistory方法执行时间 |
| 内存占用增量 | < 1MB | NavigationManager内存占用 |

### 8.2 优化策略

**1. 路由配置预加载**:
```typescript
// 应用启动时加载路由配置
export class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    // 预加载路由配置
    RouteConfigManager.getInstance().initialize();
    
    // 预热NavigationManager
    NavigationManager.getInstance();
  }
}
```

**2. 导航历史限制**:
- 限制导航栈最大长度为50
- 超出时移除最早的记录
- 避免内存泄漏

**3. 异步导航**:
- 所有导航方法返回Promise
- 不阻塞UI线程
- 支持并发导航请求

**4. 路由缓存**:
- 使用Set存储路由配置
- O(1)时间复杂度查询
- 避免重复解析配置文件

### 8.3 监控方案

**性能监控点**:
```typescript
// 在NavigationManager中添加性能监控
public async navigateTo(url: string): Promise<void> {
  const startTime = Date.now();
  
  try {
    // ... 导航逻辑
  } finally {
    const duration = Date.now() - startTime;
    if (duration > 500) {
      Logger.warn(`Slow navigation: ${url} took ${duration}ms`);
    }
  }
}
```

## 9. 安全设计

### 9.1 数据安全

**参数验证**:
```typescript
// 验证导航参数，防止注入攻击
private validateParams(params: NavigationParams): boolean {
  for (const key in params) {
    const value = params[key];
    
    // 检查参数类型
    if (typeof value !== 'string' && 
        typeof value !== 'number' && 
        typeof value !== 'boolean' &&
        typeof value !== 'object') {
      return false;
    }
    
    // 检查字符串长度
    if (typeof value === 'string' && value.length > 1000) {
      return false;
    }
  }
  
  return true;
}
```

**敏感信息保护**:
- 不在日志中记录敏感参数
- 导航参数不持久化到本地存储
- 使用后立即清除临时参数

### 9.2 权限控制

**路由权限检查**:
```typescript
// 扩展路由元信息，支持权限控制
export interface RouteMeta {
  title?: string;
  requiresAuth?: boolean;    // 是否需要登录
  requiredRole?: string[];   // 需要的角色
}

// 导航前检查权限
private checkPermission(url: string): boolean {
  const route = RouteConfigManager.getInstance().getRoute(url);
  
  if (route?.meta?.requiresAuth) {
    // 检查用户是否登录
    if (!UserService.getInstance().isLoggedIn()) {
      return false;
    }
  }
  
  return true;
}
```

### 9.3 安全审计

**导航日志记录**:
```typescript
// 记录导航行为，用于安全审计
private logNavigation(url: string, params?: NavigationParams): void {
  const logEntry = {
    timestamp: Date.now(),
    action: 'NAVIGATION',
    url: url,
    hasParams: !!params,
    userId: UserService.getInstance().getCurrentUserId()
  };
  
  Logger.info('Navigation audit:', JSON.stringify(logEntry));
}
```

## 10. 测试设计

### 10.1 测试策略

**测试金字塔**:
- 单元测试 (70%): 测试NavigationManager、ErrorHandler等核心类
- 集成测试 (20%): 测试页面间导航流程
- E2E测试 (10%): 测试用户导航场景

### 10.2 测试用例

**单元测试用例**:

| 测试ID | 测试场景 | 输入 | 预期输出 |
|--------|---------|------|---------|
| UT-001 | 正常跳转 | 有效URL | 跳转成功 |
| UT-002 | 无效路由 | 不存在的URL | 抛出错误 |
| UT-003 | 参数跳转 | URL + 参数 | 携带参数跳转 |
| UT-004 | 空参数 | URL + null | 抛出错误 |
| UT-005 | 返回操作 | 导航栈有历史 | 返回上一页 |
| UT-006 | 空栈返回 | 导航栈为空 | 无操作或提示 |

**集成测试用例**:

| 测试ID | 测试场景 | 测试步骤 | 预期结果 |
|--------|---------|---------|---------|
| IT-001 | 首页到医院列表 | 1. 打开首页<br>2. 点击医疗服务<br>3. 点击医院列表 | 成功跳转到医院列表页 |
| IT-002 | 医院详情返回 | 1. 进入医院详情<br>2. 点击返回 | 返回医院列表页 |
| IT-003 | 带参数跳转 | 1. 点击医院项<br>2. 携带ID跳转 | 详情页显示正确医院 |

**E2E测试场景**:
```
场景1: 完整导航流程
1. 用户登录应用
2. 从首页进入医疗服务
3. 选择医院查看详情
4. 预约挂号
5. 查看预约记录
6. 返回首页

场景2: 错误处理流程
1. 用户尝试访问不存在的页面
2. 系统显示错误提示
3. 用户点击重试或返回
4. 成功返回上一页面
```

### 10.3 Mock数据

**Mock路由配置**:
```typescript
// 测试用Mock路由
export const MockRoutes: string[] = [
  'pages/Index',
  'pages/HomePage',
  'pages/MedicalPage',
  'pages/HospitalPage',
  'pages/HospitalDetailPage',
  'pages/Profile'
];
```

**Mock导航参数**:
```typescript
// 测试用Mock参数
export const MockNavigationParams = {
  hospitalDetail: {
    hospitalId: 'test-123',
    hospitalName: '测试医院'
  },
  doctorDetail: {
    doctorId: 'doctor-456',
    departmentId: 'dept-789'
  }
};
```

## 11. 部署设计

### 11.1 环境要求

**开发环境**:
- DevEco Studio 3.1+
- HarmonyOS SDK 6.0+
- Node.js 14+

**运行环境**:
- HarmonyOS 6.0及以上设备
- 最小内存: 2GB
- 最小存储: 100MB

### 11.2 配置管理

**路由配置文件** (main_pages.json):
```json
{
  "src": [
    "pages/Index",
    "pages/Login",
    "pages/Register",
    "pages/HomePage",
    "pages/MedicalPage",
    "pages/HealthPage",
    "pages/RehabPage",
    "pages/SciencePage",
    "pages/HospitalPage",
    "pages/HospitalDetailPage",
    "pages/DepartmentPage",
    "pages/DepartmentListPage",
    "pages/DoctorListPage",
    "pages/DoctorChatPage",
    "pages/Profile",
    "pages/DeviceDiscoveryPage",
    "pages/DeviceManagePage",
    "pages/StatisticsPage",
    "pages/RankingPage",
    "pages/MedicalRecord",
    "pages/MyCollectPage",
    "pages/BrowseHistoryPage",
    "pages/PrivacySettingPage",
    "pages/PrivacyPolicyPage",
    "pages/PrivacyPage",
    "pages/DataAuthPage",
    "pages/ReminderSettingsPage",
    "pages/EmergencyContactsPage",
    "pages/AiConsultationPage",
    "pages/AiChatPage",
    "pages/KnowledgeGraphPage",
    "pages/KnowledgeExplorePage",
    "pages/MedicalRecordSyncPage",
    "pages/TransferApprovalPage"
  ]
}
```

**导航配置常量**:
```typescript
// config/NavigationConfig.ets
export class NavigationConfig {
  // 导航历史最大长度
  public static readonly MAX_HISTORY_SIZE = 50;
  
  // 导航超时时间
  public static readonly NAVIGATION_TIMEOUT = 5000;
  
  // 是否启用导航日志
  public static readonly ENABLE_NAVIGATION_LOG = true;
  
  // 是否启用性能监控
  public static readonly ENABLE_PERFORMANCE_MONITOR = true;
}
```

### 11.3 发布流程

**发布步骤**:
1. 代码审查
   - 检查所有新增的导航代码
   - 验证类型安全性
   - 确认错误处理完整

2. 单元测试
   - 运行所有单元测试
   - 确保覆盖率>80%
   - 修复失败的测试

3. 集成测试
   - 在模拟器上测试导航流程
   - 验证所有页面跳转
   - 测试错误场景

4. 真机测试
   - 在真实HarmonyOS设备上测试
   - 验证性能指标
   - 测试不同设备尺寸

5. 发布
   - 更新版本号
   - 生成发布包
   - 部署到应用市场

## 12. 附录

### 12.1 术语表

| 术语 | 定义 |
|-----|------|
| Router | HarmonyOS官方路由管理模块 |
| NavigationManager | 本项目自定义导航管理器 |
| NavigationParams | 导航参数接口 |
| RouteConfig | 路由配置项 |
| NavigationError | 导航错误类 |
| E2E | End-to-End，端到端测试 |

### 12.2 参考资料

- [HarmonyOS应用开发文档](https://developer.harmonyos.com/cn/docs/documentation/doc-guides-V3/application-dev-guide-0000001470450484-V3)
- [ArkUI组件参考](https://developer.harmonyos.com/cn/docs/documentation/doc-references-V3/ts-components-summary-0000001544703781-V3)
- [ArkTS语法规范](https://developer.harmonyos.com/cn/docs/documentation/doc-guides-V3/arkts-get-started-0000001504769261-V3)

### 12.3 变更历史

| 版本 | 日期 | 变更内容 | 作者 |
|-----|------|---------|------|
| v1.0 | 2025-01-14 | 初始版本创建 | AI Assistant |
