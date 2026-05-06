# **1. 实现模型**

## **1.1 上下文视图**

本功能模块位于HarmonyOS就医服务应用的核心业务层，与以下模块存在交互关系：

```
┌─────────────────────────────────────────────────────────────┐
│                    就医服务App                               │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ MedicalPage  │  │  HomePage    │  │   Profile    │     │
│  │  (就医服务)   │  │   (首页)     │  │   (我的)     │     │
│  └──────┬───────┘  └──────────────┘  └──────────────┘     │
│         │                                                    │
│         ├──────────> QueuePage (排队叫号)                    │
│         └──────────> PaymentPage (缴费支付)                  │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              Service Layer (服务层)                   │  │
│  ├──────────────────────────────────────────────────────┤  │
│  │  QueueService  │  PaymentService  │  NotificationService│  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              Common Components (公共组件)             │  │
│  ├──────────────────────────────────────────────────────┤  │
│  │  Header  │  Footer  │  Loading  │  EmptyState         │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## **1.2 服务/组件总体架构**

采用分层架构设计，遵循HarmonyOS ArkTS开发规范：

### **1.2.1 页面层 (Pages)**
- **QueuePage.ets**：排队叫号页面，负责UI展示和用户交互
- **PaymentPage.ets**：缴费支付页面，负责订单展示和支付流程

### **1.2.2 服务层 (Service)**
- **QueueService.ets**：排队叫号业务逻辑服务
- **QueueServiceMock.ets**：排队叫号模拟数据服务（开发测试用）
- **PaymentService.ets**：缴费支付业务逻辑服务
- **PaymentServiceMock.ets**：缴费支付模拟数据服务（开发测试用）

### **1.2.3 数据模型层 (Models)**
- **QueueRecord**：排队记录数据模型
- **PaymentOrder**：支付订单数据模型
- **PaymentRecord**：支付记录数据模型

### **1.2.4 公共组件层 (Components)**
复用现有组件：
- **Header**：页面头部组件
- **Footer**：底部导航组件
- **Loading**：加载状态组件
- **EmptyState**：空状态组件
- **ToastUtil**：提示工具类

### **1.2.5 工具层 (Utils)**
- **HttpUtil**：HTTP请求工具类
- **ToastUtil**：消息提示工具类
- **AccessibilityConfig**：无障碍配置工具类

## **1.3 实现设计文档**

### **1.3.1 排队叫号页面设计 (QueuePage.ets)**

**页面结构：**
```
QueuePage
├── Header (标题：排队叫号)
├── Scroll (可滚动内容区)
│   ├── 当前排队信息卡片
│   │   ├── 排队号码显示
│   │   ├── 当前叫号显示
│   │   ├── 预计等待时间
│   │   └── 操作按钮（取消排队）
│   ├── 排队详情列表
│   │   ├── 科室信息
│   │   ├── 医生信息
│   │   ├── 候诊人数
│   │   └── 状态标签
│   └── 快捷操作区
│       ├── 刷新按钮
│       └── 导航到科室
└── Footer (底部导航)
```

**状态管理：**
- `@State queueRecords: QueueRecord[]`：排队记录列表
- `@State isLoading: boolean`：加载状态
- `@State hasError: boolean`：错误状态
- `@State errorMessage: string`：错误信息
- `@StorageLink('isOldModeEnabled')`：老年模式标识

**生命周期：**
- `aboutToAppear()`：页面加载时获取排队数据
- `aboutToDisappear()`：页面卸载时清除定时器
- 定时刷新：每30秒调用`refreshQueueStatus()`

### **1.3.2 缴费支付页面设计 (PaymentPage.ets)**

**页面结构：**
```
PaymentPage
├── Header (标题：缴费支付)
├── Tabs (标签页)
│   ├── 待支付Tab
│   │   └── List (订单列表)
│   │       └── PaymentOrderItem
│   │           ├── 订单信息
│   │           ├── 金额显示
│   │           └── 支付按钮
│   └── 支付记录Tab
│       └── List (历史记录)
│           └── PaymentRecordItem
├── 支付方式选择弹窗 (CustomDialog)
│   ├── 微信支付选项
│   ├── 支付宝选项
│   └── 医保卡选项
└── Footer (底部导航)
```

**状态管理：**
- `@State pendingOrders: PaymentOrder[]`：待支付订单
- `@State paymentRecords: PaymentRecord[]`：支付记录
- `@State currentTab: number`：当前标签页索引
- `@State showPaymentDialog: boolean`：支付弹窗显示状态
- `@State selectedOrder: PaymentOrder`：选中的订单

**交互流程：**
1. 用户点击"去支付" → 显示支付方式选择弹窗
2. 用户选择支付方式 → 显示支付确认弹窗
3. 用户确认支付 → 调用支付服务 → 显示支付结果

### **1.3.3 服务层设计**

**QueueService接口设计：**
```typescript
export interface QueueService {
  // 获取用户排队记录
  getQueueRecords(): Promise<QueueRecord[]>

  // 获取实时叫号状态
  getQueueStatus(queueId: string): Promise<QueueStatus>

  // 取消排队
  cancelQueue(queueId: string): Promise<boolean>

  // 刷新排队状态
  refreshQueueStatus(): Promise<void>
}
```

**PaymentService接口设计：**
```typescript
export interface PaymentService {
  // 获取待支付订单
  getPendingOrders(): Promise<PaymentOrder[]>

  // 获取支付记录
  getPaymentRecords(): Promise<PaymentRecord[]>

  // 发起支付
  initiatePayment(orderId: string, method: PaymentMethod): Promise<PaymentResult>

  // 查询支付结果
  queryPaymentResult(orderId: string): Promise<PaymentResult>
}
```

# **2. 接口设计**

## **2.1 总体设计**

遵循RESTful API设计规范，使用现有HttpUtil工具类进行HTTP请求。

**请求方式：**
- GET：查询操作
- POST：创建和更新操作
- DELETE：删除操作

**响应格式：**
```typescript
interface BaseResponse<T> {
  code: number;      // 状态码：200成功，其他失败
  message: string;   // 提示信息
  data: T;          // 业务数据
}
```

**错误处理：**
- 网络错误：显示"网络异常，请稍后重试"
- 业务错误：显示后端返回的错误信息
- 超时错误：显示"请求超时，请重试"

## **2.2 接口清单**

### **2.2.1 排队叫号相关接口**

#### **GET /api/queue/list**
获取用户排队记录列表

**请求参数：**
```
userId: string (必填) - 用户ID
```

**响应数据：**
```json
{
  "code": 200,
  "message": "success",
  "data": [
    {
      "queueId": "Q20240101001",
      "queueNumber": 15,
      "currentNumber": 12,
      "department": "内科",
      "doctorName": "张医生",
      "status": "候诊中",
      "waitingCount": 3,
      "estimatedTime": 15,
      "appointmentId": "A20240101001",
      "createTime": 1704067200000,
      "updateTime": 1704067800000
    }
  ]
}
```

#### **GET /api/queue/status/{queueId}**
获取实时叫号状态

**路径参数：**
```
queueId: string (必填) - 排队记录ID
```

**响应数据：**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "queueId": "Q20240101001",
    "currentNumber": 15,
    "status": "正在叫号",
    "waitingCount": 0,
    "updateTime": 1704068100000
  }
}
```

#### **POST /api/queue/cancel**
取消排队

**请求体：**
```json
{
  "queueId": "Q20240101001",
  "reason": "用户主动取消"
}
```

**响应数据：**
```json
{
  "code": 200,
  "message": "取消成功",
  "data": true
}
```

### **2.2.2 缴费支付相关接口**

#### **GET /api/payment/pending**
获取待支付订单列表

**请求参数：**
```
userId: string (必填) - 用户ID
```

**响应数据：**
```json
{
  "code": 200,
  "message": "success",
  "data": [
    {
      "orderId": "PO20240101001",
      "orderType": "挂号费",
      "amount": 50.00,
      "status": "待支付",
      "description": "内科门诊挂号费",
      "medicalRecordId": "MR20240101001",
      "createTime": 1704067200000,
      "expireTime": 1704153600000
    }
  ]
}
```

#### **GET /api/payment/records**
获取支付记录列表

**请求参数：**
```
userId: string (必填) - 用户ID
page: number (可选) - 页码，默认1
size: number (可选) - 每页数量，默认20
```

**响应数据：**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "total": 100,
    "records": [
      {
        "recordId": "PR20240101001",
        "orderId": "PO20240101001",
        "paymentMethod": "微信支付",
        "amount": 50.00,
        "transactionId": "WX20240101001",
        "status": "成功",
        "payTime": 1704067300000
      }
    ]
  }
}
```

#### **POST /api/payment/initiate**
发起支付

**请求体：**
```json
{
  "orderId": "PO20240101001",
  "paymentMethod": "微信支付",
  "amount": 50.00
}
```

**响应数据：**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "transactionId": "WX20240101001",
    "paymentUrl": "weixin://pay/...",
    "expireTime": 1704067800000
  }
}
```

#### **GET /api/payment/result/{orderId}**
查询支付结果

**路径参数：**
```
orderId: string (必填) - 订单ID
```

**响应数据：**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "orderId": "PO20240101001",
    "status": "已支付",
    "transactionId": "WX20240101001",
    "payTime": 1704067300000
  }
}
```

# **3. 数据模型**

## **3.1 设计目标**

1. **类型安全**：使用TypeScript接口定义，确保类型安全
2. **数据验证**：在服务层进行数据合法性校验
3. **状态管理**：使用@State和@StorageLink进行响应式状态管理
4. **数据持久化**：关键数据支持本地缓存，提升用户体验

## **3.2 模型实现**

### **3.2.1 排队记录模型 (QueueRecord)**

```typescript
// 文件位置：entry/src/main/ets/models/QueueModel.ets

export interface QueueRecord {
  queueId: string;           // 排队记录ID
  queueNumber: number;       // 排队号码
  currentNumber: number;     // 当前叫号号码
  department: string;        // 科室名称
  doctorName: string;        // 医生姓名
  status: QueueStatus;       // 叫号状态
  waitingCount: number;      // 前方等待人数
  estimatedTime: number;     // 预计等待时间(分钟)
  appointmentId: string;     // 关联的预约记录ID
  createTime: number;        // 创建时间戳
  updateTime: number;        // 更新时间戳
}

export enum QueueStatus {
  WAITING = '候诊中',
  CALLING = '正在叫号',
  PASSED = '已过号',
  COMPLETED = '已就诊',
  CANCELLED = '已取消'
}

export interface QueueStatusResponse {
  queueId: string;
  currentNumber: number;
  status: QueueStatus;
  waitingCount: number;
  updateTime: number;
}
```

### **3.2.2 支付订单模型 (PaymentOrder)**

```typescript
// 文件位置：entry/src/main/ets/models/PaymentModel.ets

export interface PaymentOrder {
  orderId: string;           // 订单编号
  orderType: OrderType;      // 订单类型
  amount: number;            // 订单金额(元)
  status: PaymentStatus;     // 支付状态
  paymentMethod?: PaymentMethod;  // 支付方式(可选)
  description: string;       // 订单描述
  medicalRecordId: string;   // 关联的就诊记录ID
  createTime: number;        // 创建时间戳
  payTime?: number;          // 支付时间戳(可选)
  expireTime: number;        // 过期时间戳
}

export enum OrderType {
  REGISTRATION = '挂号费',
  EXAMINATION = '检查费',
  MEDICINE = '药费',
  TREATMENT = '治疗费',
  OTHER = '其他'
}

export enum PaymentStatus {
  PENDING = '待支付',
  PAYING = '支付中',
  PAID = '已支付',
  CANCELLED = '已取消',
  EXPIRED = '已过期'
}

export enum PaymentMethod {
  WECHAT = '微信支付',
  ALIPAY = '支付宝',
  INSURANCE = '医保卡'
}
```

### **3.2.3 支付记录模型 (PaymentRecord)**

```typescript
// 文件位置：entry/src/main/ets/models/PaymentModel.ets

export interface PaymentRecord {
  recordId: string;          // 记录编号
  orderId: string;           // 关联的订单编号
  paymentMethod: PaymentMethod;  // 支付方式
  amount: number;            // 支付金额(元)
  transactionId: string;     // 第三方交易号
  status: PaymentResult;     // 支付结果
  payTime: number;           // 支付时间戳
  remark?: string;           // 备注信息(可选)
}

export enum PaymentResult {
  SUCCESS = '成功',
  FAILED = '失败'
}

export interface PaymentResultResponse {
  orderId: string;
  status: PaymentStatus;
  transactionId: string;
  payTime: number;
}
```

### **3.2.4 API响应模型**

```typescript
// 文件位置：entry/src/main/ets/common/utils/HttpUtil.ets (已存在)

export interface BaseResponse<T> {
  code: number;
  message: string;
  data: T;
}
```

# **4. 路由配置**

## **4.1 页面路由注册**

在 `entry/src/main/resources/base/profile/main_pages.json` 中添加：

```json
{
  "src": [
    "pages/Index",
    "pages/Login",
    "pages/HomePage",
    "pages/MedicalPage",
    "pages/QueuePage",        // 新增
    "pages/PaymentPage",      // 新增
    // ... 其他页面
  ]
}
```

## **4.2 路由跳转实现**

在 `MedicalPage.ets` 中修改点击事件处理：

```typescript
// 修改第116-132行的onClick事件
.onClick(() => {
  try {
    if (service.id === 'appointment') {
      router.pushUrl({ url: 'pages/HospitalPage' });
    } else if (service.id === 'queue') {
      router.pushUrl({ url: 'pages/QueuePage' });  // 新增
    } else if (service.id === 'payment') {
      router.pushUrl({ url: 'pages/PaymentPage' });  // 新增
    } else if (service.id === 'prescription') {
      router.pushUrl({ url: 'pages/Medications' });
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

# **5. 关键技术点**

## **5.1 实时刷新机制**

使用 `setInterval` 实现排队状态自动刷新：

```typescript
private refreshTimer: number = -1;

aboutToAppear() {
  this.loadQueueRecords();
  // 每30秒刷新一次
  this.refreshTimer = setInterval(() => {
    this.refreshQueueStatus();
  }, 30000);
}

aboutToDisappear() {
  // 清除定时器
  if (this.refreshTimer !== -1) {
    clearInterval(this.refreshTimer);
    this.refreshTimer = -1;
  }
}
```

## **5.2 支付弹窗实现**

使用 `@CustomDialog` 装饰器创建自定义弹窗：

```typescript
@CustomDialog
struct PaymentMethodDialog {
  controller: CustomDialogController;
  onConfirm: (method: PaymentMethod) => void;

  build() {
    Column() {
      Text('选择支付方式')
      // 支付方式选项
      Row() {
        Button('微信支付').onClick(() => {
          this.onConfirm(PaymentMethod.WECHAT);
          this.controller.close();
        })
        Button('支付宝').onClick(() => {
          this.onConfirm(PaymentMethod.ALIPAY);
          this.controller.close();
        })
        Button('医保卡').onClick(() => {
          this.onConfirm(PaymentMethod.INSURANCE);
          this.controller.close();
        })
      }
    }
  }
}
```

## **5.3 空状态处理**

复用现有 `EmptyState` 组件：

```typescript
if (this.queueRecords.length === 0 && !this.isLoading) {
  EmptyState({
    icon: '⏰',
    title: '暂无排队信息',
    message: '您当前无排队信息，请先预约挂号',
    actionText: '去预约',
    onAction: () => {
      router.pushUrl({ url: 'pages/HospitalPage' });
    }
  })
}
```

## **5.4 老年模式适配**

使用 `AccessibilityConfig` 工具类动态调整字体大小：

```typescript
@StorageLink('isOldModeEnabled') isElderMode: boolean = false;

Text('排队号码')
  .fontSize(this.isElderMode ? 18 : 16)
  .fontWeight(FontWeight.Bold)
```

## **5.5 错误处理**

统一使用 `ToastUtil` 显示错误提示：

```typescript
try {
  const response = await QueueService.getQueueRecords();
  this.queueRecords = response.data;
} catch (error) {
  this.hasError = true;
  this.errorMessage = '网络异常，请稍后重试';
  ToastUtil.showError('网络异常，请稍后重试');
}
```

# **6. 测试策略**

## **6.1 单元测试**

- 测试服务层数据转换逻辑
- 测试状态枚举值合法性
- 测试金额计算精度

## **6.2 集成测试**

- 测试页面跳转流程
- 测试API接口调用
- 测试支付流程完整性

## **6.3 UI测试**

- 测试老年模式显示效果
- 测试空状态展示
- 测试加载状态展示
- 测试错误提示展示

## **6.4 性能测试**

- 测试页面加载时间（< 2秒）
- 测试列表滚动流畅度（60fps）
- 测试内存占用情况
