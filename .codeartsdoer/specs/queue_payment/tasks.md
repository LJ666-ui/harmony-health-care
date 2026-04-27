# 排队叫号与缴费支付功能 - 实现任务清单

## 任务概述

本任务清单基于需求规格文档(spec.md)和技术设计文档(design.md)生成，旨在实现排队叫号和缴费支付两个核心就医服务功能。

**总任务数**：15个
**预估工作量**：中等复杂度

---

## 阶段一：数据模型层实现（3个任务）

### ✅ 任务1：创建排队记录数据模型
**优先级**：高
**文件路径**：`entry/src/main/ets/models/QueueModel.ets`

**任务描述**：
创建排队记录相关的数据模型和枚举定义。

**实现内容**：
1. 定义 `QueueRecord` 接口，包含以下字段：
   - queueId: string（排队记录ID）
   - queueNumber: number（排队号码）
   - currentNumber: number（当前叫号号码）
   - department: string（科室名称）
   - doctorName: string（医生姓名）
   - status: QueueStatus（叫号状态）
   - waitingCount: number（前方等待人数）
   - estimatedTime: number（预计等待时间）
   - appointmentId: string（关联的预约记录ID）
   - createTime: number（创建时间戳）
   - updateTime: number（更新时间戳）

2. 定义 `QueueStatus` 枚举：
   - WAITING = '候诊中'
   - CALLING = '正在叫号'
   - PASSED = '已过号'
   - COMPLETED = '已就诊'
   - CANCELLED = '已取消'

3. 定义 `QueueStatusResponse` 接口（用于实时状态响应）

**验收标准**：
- [ ] 文件创建成功，路径正确
- [ ] 所有接口和枚举定义完整
- [ ] 类型定义符合TypeScript规范
- [ ] 字段注释清晰完整

---

### ✅ 任务2：创建支付订单数据模型
**优先级**：高
**文件路径**：`entry/src/main/ets/models/PaymentModel.ets`

**任务描述**：
创建支付订单和支付记录相关的数据模型和枚举定义。

**实现内容**：
1. 定义 `PaymentOrder` 接口，包含以下字段：
   - orderId: string（订单编号）
   - orderType: OrderType（订单类型）
   - amount: number（订单金额）
   - status: PaymentStatus（支付状态）
   - paymentMethod?: PaymentMethod（支付方式，可选）
   - description: string（订单描述）
   - medicalRecordId: string（关联的就诊记录ID）
   - createTime: number（创建时间戳）
   - payTime?: number（支付时间戳，可选）
   - expireTime: number（过期时间戳）

2. 定义 `PaymentRecord` 接口，包含以下字段：
   - recordId: string（记录编号）
   - orderId: string（关联的订单编号）
   - paymentMethod: PaymentMethod（支付方式）
   - amount: number（支付金额）
   - transactionId: string（第三方交易号）
   - status: PaymentResult（支付结果）
   - payTime: number（支付时间戳）
   - remark?: string（备注信息，可选）

3. 定义相关枚举：
   - `OrderType`：挂号费、检查费、药费、治疗费、其他
   - `PaymentStatus`：待支付、支付中、已支付、已取消、已过期
   - `PaymentMethod`：微信支付、支付宝、医保卡
   - `PaymentResult`：成功、失败

4. 定义 `PaymentResultResponse` 接口

**验收标准**：
- [ ] 文件创建成功，路径正确
- [ ] 所有接口和枚举定义完整
- [ ] 类型定义符合TypeScript规范
- [ ] 可选字段使用 `?` 标记正确

---

### ✅ 任务3：在ApiConstants中添加新接口常量
**优先级**：高
**文件路径**：`entry/src/main/ets/common/constants/ApiConstants.ets`

**任务描述**：
在现有的ApiConstants中添加排队叫号和缴费支付相关的API接口常量。

**实现内容**：
在 `ApiConstantsInterface` 接口中添加以下常量：

**排队叫号相关**：
- QUEUE_LIST: string（获取排队记录列表）
- QUEUE_STATUS: string（获取实时叫号状态）
- QUEUE_CANCEL: string（取消排队）

**缴费支付相关**：
- PAYMENT_PENDING: string（获取待支付订单）
- PAYMENT_RECORDS: string（获取支付记录）
- PAYMENT_INITIATE: string（发起支付）
- PAYMENT_RESULT: string（查询支付结果）

在 `ApiConstants` 对象中实现这些常量，值为对应的API路径。

**验收标准**：
- [ ] 接口常量定义完整
- [ ] 路径命名符合RESTful规范
- [ ] 不影响现有常量定义
- [ ] 代码格式与现有代码风格一致

---

## 阶段二：服务层实现（4个任务）

### ✅ 任务4：创建排队叫号服务接口
**优先级**：高
**文件路径**：`entry/src/main/ets/service/QueueService.ets`

**任务描述**：
创建排队叫号业务逻辑服务，提供数据获取和处理功能。

**实现内容**：
1. 定义 `QueueService` 接口，包含以下方法：
   - `getQueueRecords(): Promise<QueueRecord[]>`：获取用户排队记录
   - `getQueueStatus(queueId: string): Promise<QueueStatusResponse>`：获取实时叫号状态
   - `cancelQueue(queueId: string): Promise<boolean>`：取消排队
   - `refreshQueueStatus(): Promise<void>`：刷新排队状态

2. 实现 `QueueServiceImpl` 类：
   - 使用 `HttpUtil` 进行HTTP请求
   - 处理响应数据并转换为对应的模型类型
   - 统一错误处理，使用 `ToastUtil` 显示错误提示

3. 导出服务实例

**验收标准**：
- [ ] 服务接口定义完整
- [ ] HTTP请求使用HttpUtil工具类
- [ ] 错误处理机制完善
- [ ] 返回数据类型正确

---

### ✅ 任务5：创建排队叫号模拟服务
**优先级**：中
**文件路径**：`entry/src/main/ets/service/QueueServiceMock.ets`

**任务描述**：
创建排队叫号模拟数据服务，用于开发测试阶段。

**实现内容**：
1. 实现 `QueueService` 接口
2. 提供模拟数据：
   - 模拟2-3条排队记录数据
   - 模拟不同的叫号状态（候诊中、正在叫号等）
   - 模拟实时状态更新
3. 使用 `setTimeout` 模拟网络延迟（500-1000ms）

**验收标准**：
- [ ] 实现QueueService接口的所有方法
- [ ] 模拟数据真实合理
- [ ] 延迟时间符合实际场景
- [ ] 可随时切换到真实服务

---

### ✅ 任务6：创建缴费支付服务接口
**优先级**：高
**文件路径**：`entry/src/main/ets/service/PaymentService.ets`

**任务描述**：
创建缴费支付业务逻辑服务，提供订单查询和支付处理功能。

**实现内容**：
1. 定义 `PaymentService` 接口，包含以下方法：
   - `getPendingOrders(): Promise<PaymentOrder[]>`：获取待支付订单
   - `getPaymentRecords(page?: number, size?: number): Promise<{total: number, records: PaymentRecord[]}>`：获取支付记录
   - `initiatePayment(orderId: string, method: PaymentMethod): Promise<{transactionId: string, paymentUrl: string}>`：发起支付
   - `queryPaymentResult(orderId: string): Promise<PaymentResultResponse>`：查询支付结果

2. 实现 `PaymentServiceImpl` 类：
   - 使用 `HttpUtil` 进行HTTP请求
   - 处理支付相关的业务逻辑
   - 统一错误处理

3. 导出服务实例

**验收标准**：
- [ ] 服务接口定义完整
- [ ] 支付流程逻辑清晰
- [ ] 错误处理机制完善
- [ ] 支持分页查询

---

### ✅ 任务7：创建缴费支付模拟服务
**优先级**：中
**文件路径**：`entry/src/main/ets/service/PaymentServiceMock.ets`

**任务描述**：
创建缴费支付模拟数据服务，用于开发测试阶段。

**实现内容**：
1. 实现 `PaymentService` 接口
2. 提供模拟数据：
   - 模拟3-5条待支付订单数据
   - 模拟不同的订单类型和金额
   - 模拟支付记录历史数据
3. 模拟支付流程：
   - 发起支付返回模拟的交易号
   - 查询结果随机返回成功或失败

**验收标准**：
- [ ] 实现PaymentService接口的所有方法
- [ ] 模拟数据真实合理
- [ ] 支付流程完整模拟
- [ ] 可随时切换到真实服务

---

## 阶段三：页面层实现（4个任务）

### ✅ 任务8：创建排队叫号页面
**优先级**：高
**文件路径**：`entry/src/main/ets/pages/QueuePage.ets`

**任务描述**：
创建排队叫号页面，展示排队信息和提供相关操作。

**实现内容**：
1. 页面结构：
   - 导入必要的组件和服务
   - 使用 `@Entry` 和 `@Component` 装饰器
   - 定义状态变量（queueRecords、isLoading、hasError等）

2. UI布局：
   - Header组件（标题：排队叫号）
   - Scroll容器包裹内容区
   - 当前排队信息卡片（显示排队号码、当前叫号、等待时间）
   - 排队详情列表（科室、医生、状态等）
   - 快捷操作区（刷新、取消排队）
   - Footer组件（底部导航）

3. 业务逻辑：
   - `aboutToAppear()`：加载排队数据，启动定时刷新
   - `aboutToDisappear()`：清除定时器
   - `loadQueueRecords()`：获取排队记录
   - `refreshQueueStatus()`：刷新排队状态
   - `cancelQueue()`：取消排队操作

4. 空状态处理：
   - 无排队记录时显示EmptyState组件
   - 提示"暂无排队信息，请先预约挂号"
   - 提供"去预约"按钮跳转到HospitalPage

5. 老年模式适配：
   - 使用 `@StorageLink('isOldModeEnabled')` 获取老年模式状态
   - 根据老年模式调整字体大小和间距

**验收标准**：
- [ ] 页面创建成功，路由配置正确
- [ ] UI布局符合设计规范
- [ ] 数据加载和刷新功能正常
- [ ] 空状态显示正确
- [ ] 老年模式适配完成
- [ ] 定时刷新机制工作正常（30秒）

---

### ✅ 任务9：创建缴费支付页面
**优先级**：高
**文件路径**：`entry/src/main/ets/pages/PaymentPage.ets`

**任务描述**：
创建缴费支付页面，展示订单列表和处理支付流程。

**实现内容**：
1. 页面结构：
   - 导入必要的组件和服务
   - 定义状态变量（pendingOrders、paymentRecords、currentTab等）

2. UI布局：
   - Header组件（标题：缴费支付）
   - Tabs组件（待支付、支付记录两个标签页）
   - 待支付Tab：订单列表，每个订单显示类型、金额、时间、支付按钮
   - 支付记录Tab：历史记录列表
   - Footer组件（底部导航）

3. 业务逻辑：
   - `aboutToAppear()`：加载待支付订单和支付记录
   - `loadPendingOrders()`：获取待支付订单
   - `loadPaymentRecords()`：获取支付记录
   - `handlePayment()`：处理支付流程

4. 空状态处理：
   - 无待支付订单时显示"暂无待支付费用"
   - 无支付记录时显示"暂无支付记录"

5. 老年模式适配：
   - 根据老年模式调整字体大小和布局

**验收标准**：
- [ ] 页面创建成功，路由配置正确
- [ ] Tabs切换功能正常
- [ ] 订单列表显示正确
- [ ] 空状态显示正确
- [ ] 老年模式适配完成

---

### ✅ 任务10：创建支付方式选择弹窗
**优先级**：中
**文件路径**：`entry/src/main/ets/components/PaymentMethodDialog.ets`

**任务描述**：
创建自定义支付方式选择弹窗组件。

**实现内容**：
1. 使用 `@CustomDialog` 装饰器
2. 弹窗内容：
   - 标题："选择支付方式"
   - 三个支付方式选项：
     - 微信支付（图标 + 文字）
     - 支付宝（图标 + 文字）
     - 医保卡（图标 + 文字）
   - 取消按钮

3. 回调处理：
   - 定义 `onConfirm` 回调函数，传递选择的支付方式
   - 点击选项后关闭弹窗并触发回调

**验收标准**：
- [ ] 弹窗组件创建成功
- [ ] 三种支付方式显示完整
- [ ] 点击事件处理正确
- [ ] 回调机制工作正常

---

### ✅ 任务11：修改MedicalPage添加路由跳转
**优先级**：高
**文件路径**：`entry/src/main/ets/pages/MedicalPage.ets`

**任务描述**：
修改MedicalPage中的点击事件处理，添加排队叫号和缴费支付的路由跳转。

**实现内容**：
在 `buildMedicalServices()` 方法的 `onClick` 事件处理中（第116-132行）：

1. 添加排队叫号跳转：
```typescript
else if (service.id === 'queue') {
  router.pushUrl({ url: 'pages/QueuePage' });
}
```

2. 添加缴费支付跳转：
```typescript
else if (service.id === 'payment') {
  router.pushUrl({ url: 'pages/PaymentPage' });
}
```

3. 保持其他服务的跳转逻辑不变

**验收标准**：
- [ ] 点击"排队叫号"能正确跳转到QueuePage
- [ ] 点击"缴费支付"能正确跳转到PaymentPage
- [ ] 不影响其他服务的跳转功能
- [ ] 错误处理机制保持完整

---

## 阶段四：路由配置与集成（2个任务）

### ✅ 任务12：注册页面路由
**优先级**：高
**文件路径**：`entry/src/main/resources/base/profile/main_pages.json`

**任务描述**：
在路由配置文件中注册新增的两个页面。

**实现内容**：
在 `main_pages.json` 的 `src` 数组中添加：
- "pages/QueuePage"
- "pages/PaymentPage"

确保添加在合适的位置，保持数组格式正确。

**验收标准**：
- [ ] 路由配置文件格式正确
- [ ] 两个页面路由注册成功
- [ ] 不影响现有路由配置
- [ ] JSON格式合法

---

### ✅ 任务13：集成测试与调试
**优先级**：高
**任务类型**：测试

**任务描述**：
对整个功能进行集成测试，确保所有功能正常工作。

**测试内容**：
1. **路由跳转测试**：
   - 从MedicalPage点击"排队叫号"跳转到QueuePage
   - 从MedicalPage点击"缴费支付"跳转到PaymentPage
   - 底部导航切换正常

2. **排队叫号功能测试**：
   - 页面加载显示排队数据
   - 无数据时显示空状态
   - 定时刷新功能正常（30秒）
   - 取消排队功能正常
   - 老年模式显示正常

3. **缴费支付功能测试**：
   - 待支付订单列表显示正常
   - 支付记录列表显示正常
   - Tabs切换功能正常
   - 支付方式选择弹窗显示正常
   - 空状态显示正常

4. **错误处理测试**：
   - 网络错误时显示错误提示
   - 数据加载失败时显示错误状态
   - Toast提示显示正常

5. **性能测试**：
   - 页面加载时间 < 2秒
   - 列表滚动流畅
   - 内存占用正常

**验收标准**：
- [ ] 所有路由跳转正常
- [ ] 排队叫号功能完整可用
- [ ] 缴费支付功能完整可用
- [ ] 错误处理机制完善
- [ ] 性能指标达标

---

## 阶段五：优化与完善（2个任务）

### ✅ 任务14：UI细节优化
**优先级**：中
**任务类型**：优化

**任务描述**：
优化UI细节，提升用户体验。

**优化内容**：
1. **排队叫号页面优化**：
   - 排队号码使用大字体突出显示
   - 状态标签使用不同颜色区分
   - 添加刷新动画效果
   - 优化卡片阴影和圆角

2. **缴费支付页面优化**：
   - 金额使用醒目颜色显示
   - 订单类型使用图标区分
   - 支付按钮使用渐变色
   - 优化列表项间距

3. **通用优化**：
   - 添加页面过渡动画
   - 优化加载状态显示
   - 完善空状态插图
   - 优化老年模式下的对比度

**验收标准**：
- [ ] UI视觉效果提升明显
- [ ] 交互体验流畅
- [ ] 老年模式可读性良好
- [ ] 符合HarmonyOS设计规范

---

### ✅ 任务15：文档完善与代码审查
**优先级**：低
**任务类型**：文档

**任务描述**：
完善代码注释和文档，进行代码审查。

**实现内容**：
1. **代码注释**：
   - 为所有公共方法添加注释
   - 为复杂逻辑添加说明注释
   - 为数据模型添加字段说明

2. **代码审查**：
   - 检查代码规范符合性
   - 检查命名规范
   - 检查错误处理完整性
   - 检查性能优化点

3. **文档更新**：
   - 更新README文档（如有）
   - 记录已知问题和限制
   - 记录后续优化建议

**验收标准**：
- [ ] 代码注释完整清晰
- [ ] 代码规范检查通过
- [ ] 文档更新完整
- [ ] 无明显代码质量问题

---

## 任务依赖关系

```
任务1 (QueueModel) ──┐
                      ├──> 任务4 (QueueService) ──> 任务5 (QueueServiceMock) ──> 任务8 (QueuePage)
任务3 (ApiConstants) ─┘

任务2 (PaymentModel) ──┐
                        ├──> 任务6 (PaymentService) ──> 任务7 (PaymentServiceMock) ──> 任务9 (PaymentPage)
任务3 (ApiConstants) ───┘

任务9 (PaymentPage) ──> 任务10 (PaymentMethodDialog)

任务8 (QueuePage) ──┐
任务9 (PaymentPage) ──┼──> 任务11 (MedicalPage修改) ──> 任务12 (路由注册) ──> 任务13 (集成测试)
任务10 (Dialog) ──────┘

任务13 (集成测试) ──> 任务14 (UI优化) ──> 任务15 (文档完善)
```

---

## 执行建议

1. **按阶段顺序执行**：建议按照阶段一到阶段五的顺序执行，确保依赖关系正确。

2. **优先级处理**：高优先级任务应优先完成，中低优先级任务可根据实际情况调整。

3. **测试驱动**：每完成一个任务应立即进行单元测试，确保功能正确。

4. **代码审查**：建议在阶段三完成后进行一次代码审查，及时发现和修复问题。

5. **性能监控**：在集成测试阶段重点关注性能指标，确保满足DFX约束要求。

---

## 风险提示

1. **路由配置错误**：确保路由路径与文件路径一致，避免跳转失败。

2. **状态管理冲突**：注意@State和@StorageLink的使用场景，避免状态混乱。

3. **定时器泄漏**：务必在aboutToDisappear中清除定时器，避免内存泄漏。

4. **错误处理遗漏**：所有异步操作都应有try-catch包裹，避免未捕获异常。

5. **老年模式兼容**：测试时务必验证老年模式下的显示效果。

---

**任务清单生成完成！**
