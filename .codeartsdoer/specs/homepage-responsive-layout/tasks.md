# 首页响应式布局开发 - 编码任务文档

**版本**: v1.0
**创建日期**: 2026-05-06
**最后更新**: 2026-05-06
**作者**: SDD Agent
**状态**: 待执行

## 任务概述

本文档将技术设计转化为具体的编码任务，按照依赖关系和优先级排序，确保开发过程有序进行。

**任务统计**:
- 主任务: 8个
- 子任务: 24个
- 预计总工时: 6-8小时
- 优先级分布: P0(4个主任务), P1(3个主任务), P2(1个主任务)

---

## 任务1: 环境准备与依赖验证 (P0)

**任务描述**: 验证开发环境和依赖组件是否就绪，确保后续开发顺利进行。

**输入**:
- 项目代码库
- BreakpointSystem.ets源码
- 现有HomePage.ets代码

**输出**:
- 环境验证报告
- 依赖组件状态确认

**子任务**:

### 1.1 验证BreakpointSystem可用性
**描述**: 检查BreakpointSystem.ets是否存在且功能完整
**执行步骤**:
1. 读取`entry/src/main/ets/utils/BreakpointSystem.ets`文件
2. 验证BreakpointType枚举定义(SM/MD/LG)
3. 验证BreakpointConstants常量定义
4. 验证BreakpointSystem类方法完整性
5. 确认单例模式实现正确

**验收标准**:
- [ ] BreakpointSystem.ets文件存在
- [ ] BreakpointType枚举包含SM/MD/LG三个值
- [ ] BreakpointConstants包含所有必需常量
- [ ] BreakpointSystem类包含getInstance()等所有必需方法

### 1.2 验证现有HomePage代码
**描述**: 分析现有HomePage.ets代码结构
**执行步骤**:
1. 读取`entry/src/main/ets/pages/HomePage.ets`文件
2. 分析现有组件结构
3. 识别需要修改的部分
4. 记录现有功能入口配置

**验收标准**:
- [ ] HomePage.ets文件存在且可读
- [ ] 已识别现有组件结构
- [ ] 已记录需要修改的代码区域

### 1.3 验证路由配置
**描述**: 检查13个功能入口的路由是否已配置
**执行步骤**:
1. 检查router_map.json或路由配置文件
2. 验证13个目标页面路由是否已注册
3. 记录缺失的路由配置

**验收标准**:
- [ ] 已检查路由配置文件
- [ ] 已确认13个目标页面路由状态

---

## 任务2: 响应式布局参数计算方法实现 (P0)

**任务描述**: 在HomePage组件中实现响应式布局参数计算方法。

**输入**:
- BreakpointSystem API
- 设计文档中的响应式参数规范

**输出**:
- 完整的响应式计算方法实现

**子任务**:

### 2.1 实现Grid列数计算方法
**描述**: 实现getGridColumnsTemplate()方法
**代码实现**:
```typescript
private getGridColumnsTemplate(): string {
  const columns = BreakpointConstants.QUICK_ACTION_COLUMNS[this.currentBreakpoint] ?? 4;
  return `1fr `.repeat(columns).trim();
}
```

**验收标准**:
- [ ] 方法返回正确的Grid列模板字符串
- [ ] SM断点返回"1fr 1fr 1fr 1fr"
- [ ] MD断点返回"1fr 1fr 1fr 1fr"
- [ ] LG断点返回"1fr 1fr 1fr 1fr 1fr 1fr"

### 2.2 实现内容最大宽度计算方法
**描述**: 实现getContentMaxWidth()方法
**代码实现**:
```typescript
private getContentMaxWidth(): number | string {
  if (this.currentBreakpoint === BreakpointType.LG) {
    return 840;
  } else if (this.currentBreakpoint === BreakpointType.MD) {
    return 600;
  }
  return '100%';
}
```

**验收标准**:
- [ ] SM断点返回'100%'
- [ ] MD断点返回600
- [ ] LG断点返回840

### 2.3 实现响应式内边距计算方法
**描述**: 实现getHorizontalPadding()、getCardPadding()、getActionItemPadding()方法
**代码实现**:
```typescript
private getHorizontalPadding(): number {
  return this.breakpointSystem.getScaledPadding(16);
}

private getCardPadding(): number {
  return this.breakpointSystem.getScaledPadding(20);
}

private getActionItemPadding(): number {
  return this.breakpointSystem.getScaledPadding(12);
}
```

**验收标准**:
- [ ] 各方法返回正确的缩放后内边距值
- [ ] SM断点返回基础值
- [ ] MD断点返回1.25倍基础值
- [ ] LG断点返回1.5倍基础值

### 2.4 实现响应式字体大小计算方法
**描述**: 实现getIconFontSize()、getTitleFontSize()、getBodyFontSize()、getSectionTitleFontSize()方法
**代码实现**:
```typescript
private getIconFontSize(): number {
  const base = this.isElderMode ? 36 : 28;
  return this.breakpointSystem.getIconSize(base);
}

private getTitleFontSize(): number {
  const base = this.isElderMode ? 24 : 20;
  return Math.round(base * this.breakpointSystem.getFontSizeScale());
}

private getBodyFontSize(): number {
  const base = this.isElderMode ? 16 : 14;
  return Math.round(base * this.breakpointSystem.getFontSizeScale());
}

private getSectionTitleFontSize(): number {
  const base = this.isElderMode ? 18 : 16;
  return Math.round(base * this.breakpointSystem.getFontSizeScale());
}
```

**验收标准**:
- [ ] 各方法返回正确的字体大小
- [ ] 老年模式字体更大
- [ ] 断点越大字体越大

---

## 任务3: @Builder UI组件构建方法实现 (P0)

**任务描述**: 使用@Builder装饰器实现可复用的UI组件构建方法。

**输入**:
- 设计文档中的UI组件规范
- 响应式计算方法

**输出**:
- 完整的@Builder方法实现

**子任务**:

### 3.1 实现WelcomeCard构建方法
**描述**: 实现buildWelcomeCard()方法，构建欢迎卡片UI
**代码实现**:
```typescript
@Builder
private buildWelcomeCard(): void {
  Column() {
    // 用户信息行
    Row() {
      // 头像
      Image($r('app.media.default_avatar'))
        .width(48)
        .height(48)
        .borderRadius(24)
      
      // 问候语和日期
      Column() {
        Text(this.getGreetingText())
          .fontSize(this.getTitleFontSize())
          .fontWeight(FontWeight.Bold)
        
        Text(this.getDateText())
          .fontSize(this.getBodyFontSize())
          .fontColor('#666666')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 12 })
      
      // 消息图标
      Badge({ count: 0, position: BadgePosition.RightTop }) {
        Image($r('app.media.ic_notification'))
          .width(24)
          .height(24)
      }
    }
    .width('100%')
    .padding(this.getCardPadding())
    
    // 健康数据统计行
    Row() {
      this.buildHealthStatItem('今日步数', '8,542', '步', '↑12%')
      this.buildHealthStatItem('心率', '72', 'bpm', '正常')
      this.buildHealthStatItem('血压', '120/80', 'mmHg', '正常')
      this.buildHealthStatItem('血糖', '5.2', 'mmol/L', '正常')
      this.buildHealthStatItem('睡眠', '7.5', '小时', '良好')
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceAround)
    .padding(this.getCardPadding())
  }
  .width('100%')
  .backgroundColor('#FFFFFF')
  .borderRadius(12)
  .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: 2 })
}

private getGreetingText(): string {
  const hour = new Date().getHours();
  if (hour >= 6 && hour < 12) {
    return '早上好';
  } else if (hour >= 12 && hour < 18) {
    return '下午好';
  } else {
    return '晚上好';
  }
}

private getDateText(): string {
  const now = new Date();
  const weekDays = ['日', '一', '二', '三', '四', '五', '六'];
  return `${now.getFullYear()}年${now.getMonth() + 1}月${now.getDate()}日 星期${weekDays[now.getDay()]}`;
}
```

**验收标准**:
- [ ] WelcomeCard正确显示用户头像、问候语、日期
- [ ] 问候语根据时间正确变化
- [ ] 日期格式正确
- [ ] 健康数据统计正确显示

### 3.2 实现QuickActions构建方法
**描述**: 实现buildQuickActions()方法，构建快捷操作区UI
**代码实现**:
```typescript
@Builder
private buildQuickActions(): void {
  Column() {
    // 标题
    Text('快捷操作')
      .fontSize(this.getSectionTitleFontSize())
      .fontWeight(FontWeight.Bold)
      .margin({ bottom: 12 })
    
    // Grid布局的功能入口
    Grid() {
      ForEach(this.quickActions, (action: QuickAction) => {
        GridItem() {
          this.buildActionItem(action)
        }
      })
    }
    .columnsTemplate(this.getGridColumnsTemplate())
    .rowsGap(12)
    .columnsGap(12)
    .width('100%')
  }
  .width('100%')
  .padding(this.getCardPadding())
}
```

**验收标准**:
- [ ] QuickActions区域正确显示标题
- [ ] Grid布局列数根据断点正确调整
- [ ] 所有13个功能入口正确显示

### 3.3 实现ActionItem构建方法
**描述**: 实现buildActionItem()方法，构建单个功能入口项UI
**代码实现**:
```typescript
@Builder
private buildActionItem(action: QuickAction): void {
  Column() {
    // 图标
    Text(action.icon)
      .fontSize(this.getIconFontSize())
    
    // 标题
    Text(action.title)
      .fontSize(this.getBodyFontSize())
      .fontColor('#333333')
      .margin({ top: 8 })
  }
  .width('100%')
  .aspectRatio(1)
  .justifyContent(FlexAlign.Center)
  .backgroundColor(action.color + '20') // 20%透明度
  .borderRadius(12)
  .onClick(() => {
    this.handleActionClick(action);
  })
}

private handleActionClick(action: QuickAction): void {
  router.pushUrl({ url: action.route })
    .then(() => {
      console.info(`跳转到${action.title}成功`);
    })
    .catch((err: Error) => {
      console.error(`跳转失败: ${err.message}`);
    });
}
```

**验收标准**:
- [ ] ActionItem正确显示图标和标题
- [ ] 点击触发路由跳转
- [ ] 背景色使用主题色20%透明度

### 3.4 实现HealthTips构建方法
**描述**: 实现buildHealthTips()方法，构建健康提示区UI
**代码实现**:
```typescript
@Builder
private buildHealthTips(): void {
  Column() {
    // 标题
    Text('健康提示')
      .fontSize(this.getSectionTitleFontSize())
      .fontWeight(FontWeight.Bold)
      .margin({ bottom: 12 })
    
    // 横向滚动的提示卡片
    Scroll() {
      Row({ space: 12 }) {
        this.buildTipCard('💧', '多喝水', '每天8杯水', '#3498DB')
        this.buildTipCard('🏃', '多运动', '每天30分钟', '#2ECC71')
        this.buildTipCard('😴', '好睡眠', '早睡早起', '#9B59B6')
        this.buildTipCard('🥗', '均衡饮食', '少油少盐', '#F39C12')
      }
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
  }
  .width('100%')
  .padding(this.getCardPadding())
}

@Builder
private buildTipCard(icon: string, title: string, desc: string, color: string): void {
  Column() {
    Text(icon)
      .fontSize(32)
    
    Text(title)
      .fontSize(this.getBodyFontSize())
      .fontWeight(FontWeight.Bold)
      .margin({ top: 8 })
    
    Text(desc)
      .fontSize(this.getBodyFontSize() - 2)
      .fontColor('#666666')
      .margin({ top: 4 })
  }
  .width(120)
  .padding(16)
  .backgroundColor(color + '20')
  .borderRadius(12)
}
```

**验收标准**:
- [ ] HealthTips区域正确显示标题
- [ ] 横向滚动功能正常
- [ ] 提示卡片正确显示

---

## 任务4: 主build()方法实现 (P0)

**任务描述**: 实现HomePage组件的主build()方法，组装所有UI组件。

**输入**:
- 所有@Builder方法
- Header和Footer组件

**输出**:
- 完整的build()方法实现

**子任务**:

### 4.1 实现主build()方法
**描述**: 组装Header、Scroll容器和所有子组件
**代码实现**:
```typescript
build() {
  Column() {
    // 顶部导航栏
    Header({ title: '智慧医疗健康平台' })
    
    // 可滚动内容区
    Scroll() {
      Column({ space: this.isElderMode ? 16 : 12 }) {
        // 欢迎卡片
        this.buildWelcomeCard()
        
        // 快捷操作区
        this.buildQuickActions()
        
        // 健康提示区
        this.buildHealthTips()
      }
      .width('100%')
      .constraintSize({ maxWidth: this.getContentMaxWidth() })
      .padding({
        left: this.getHorizontalPadding(),
        right: this.getHorizontalPadding()
      })
    }
    .layoutWeight(1)
    .scrollBar(BarState.Auto)
    
    // 底部导航栏
    Footer({ currentIndex: this.currentIndex })
  }
  .width('100%')
  .height('100%')
  .backgroundColor('#F5F5F5')
}
```

**验收标准**:
- [ ] build()方法正确组装所有组件
- [ ] 布局层次清晰
- [ ] 响应式参数正确应用

### 4.2 实现生命周期方法
**描述**: 实现aboutToAppear()和aboutToDisappear()方法
**代码实现**:
```typescript
aboutToAppear(): void {
  // 初始化无障碍配置
  this.theme = AccessibilityConfig.getInstance();
  
  // 注册断点监听器
  this.breakpointSystem.registerListener('HomePage', (bp: BreakpointType) => {
    console.info(`断点变化: ${bp}`);
  });
  
  console.info('HomePage加载完成');
}

aboutToDisappear(): void {
  // 注销断点监听器
  this.breakpointSystem.unregisterListener('HomePage');
  
  console.info('HomePage卸载');
}
```

**验收标准**:
- [ ] aboutToAppear正确初始化组件
- [ ] aboutToDisappear正确清理资源
- [ ] 监听器正确注册和注销

---

## 任务5: 功能入口数据配置 (P1)

**任务描述**: 配置13个功能入口的数据，确保路由正确。

**输入**:
- 项目规划总览中的功能入口列表
- 路由配置

**输出**:
- 完整的quickActions数据配置

**子任务**:

### 5.1 配置功能入口数据
**描述**: 定义quickActions数组，包含13个功能入口
**代码实现**:
```typescript
private quickActions: QuickAction[] = [
  { id: 'health_records', icon: '📋', title: '健康档案', color: '#3498DB', route: 'pages/HealthRecords' },
  { id: 'medication', icon: '💊', title: '用药提醒', color: '#E74C3C', route: 'pages/MedicationPage' },
  { id: 'ai_consultation', icon: '🤖', title: 'AI问诊', color: '#2980B9', route: 'pages/AiChatPage' },
  { id: 'online_consultation', icon: '👨‍⚕️', title: '在线咨询', color: '#F39C12', route: 'pages/ConsultationPage' },
  { id: 'hospital', icon: '🏥', title: '医院查询', color: '#9B59B6', route: 'pages/HospitalPage' },
  { id: 'parking', icon: '🚗', title: '智慧停车', color: '#1ABC9C', route: 'pages/ParkingListPage' },
  { id: 'rehabilitation', icon: '🧘', title: '康复训练', color: '#16A085', route: 'pages/RehabilitationPage' },
  { id: 'risk_assessment', icon: '📊', title: '风险评估', color: '#E67E22', route: 'pages/RiskAssessmentPage' },
  { id: 'ar_navigation', icon: '🗺️', title: 'AR导航', color: '#34495E', route: 'pages/ARNavigationPage' },
  { id: 'digital_twin', icon: '🫀', title: '数字孪生', color: '#C0392B', route: 'pages/DigitalTwinPage' },
  { id: 'ancient_image', icon: '📜', title: '古医影像', color: '#8E44AD', route: 'pages/AncientMedicalImgPage' },
  { id: 'distributed', icon: '🔗', title: '分布式协同', color: '#D35400', route: 'pages/DistributedCollaborationPage' },
  { id: 'emergency', icon: '🚑', title: '急救中心', color: '#E74C3C', route: 'pages/EmergencyPage' }
];
```

**验收标准**:
- [ ] quickActions包含13个功能入口
- [ ] 每个入口包含id、icon、title、color、route
- [ ] 路由路径正确

### 5.2 验证路由配置
**描述**: 检查所有目标页面是否存在
**执行步骤**:
1. 检查pages目录下是否存在所有目标页面文件
2. 记录缺失的页面文件
3. 如有缺失，创建占位页面或更新路由

**验收标准**:
- [ ] 所有目标页面文件存在
- [ ] 路由配置正确

---

## 任务6: 样式优化与细节调整 (P1)

**任务描述**: 优化UI样式，确保视觉效果符合设计规范。

**输入**:
- 设计规范
- 色彩规范

**输出**:
- 优化后的UI样式

**子任务**:

### 6.1 优化卡片阴影效果
**描述**: 统一卡片阴影样式
**代码实现**:
```typescript
.shadow({ 
  radius: 8, 
  color: '#1A000000', 
  offsetX: 0, 
  offsetY: 2 
})
```

**验收标准**:
- [ ] 所有卡片阴影效果一致
- [ ] 阴影参数符合设计规范

### 6.2 优化圆角和边距
**描述**: 统一圆角和边距样式
**执行步骤**:
1. 确保所有卡片圆角为12vp
2. 确保间距使用响应式计算方法
3. 检查触摸目标大小 >= 44vp

**验收标准**:
- [ ] 圆角统一为12vp
- [ ] 间距响应式正确
- [ ] 触摸目标大小符合要求

### 6.3 优化色彩方案
**描述**: 确保色彩符合医疗应用风格
**执行步骤**:
1. 主色调使用医疗蓝#4A90D9
2. 背景色使用浅灰#F5F5F5
3. 文字色彩层次分明

**验收标准**:
- [ ] 色彩方案符合设计规范
- [ ] 对比度符合无障碍要求

---

## 任务7: 多设备测试验证 (P1)

**任务描述**: 在多种设备上测试响应式布局效果。

**输入**:
- 完整的HomePage实现
- DevEco Studio模拟器

**输出**:
- 测试报告
- 问题修复记录

**子任务**:

### 7.1 Phone设备测试
**描述**: 在Phone模拟器上测试布局
**执行步骤**:
1. 启动Phone模拟器
2. 打开HomePage
3. 验证Grid显示4列
4. 验证字体和间距适配小屏
5. 测试所有功能入口点击

**验收标准**:
- [ ] Phone布局正确
- [ ] Grid显示4列
- [ ] 所有功能入口可点击

### 7.2 Tablet设备测试
**描述**: 在Tablet模拟器上测试布局
**执行步骤**:
1. 启动Tablet模拟器
2. 打开HomePage
3. 验证Grid显示4列
4. 验证字体和间距适配中屏
5. 测试断点切换

**验收标准**:
- [ ] Tablet布局正确
- [ ] Grid显示4列
- [ ] 断点切换流畅

### 7.3 2in1设备测试
**描述**: 在2in1模拟器上测试布局
**执行步骤**:
1. 启动2in1模拟器
2. 打开HomePage
3. 验证Grid显示6列
4. 验证字体和间距适配大屏
5. 测试窗口大小调整

**验收标准**:
- [ ] 2in1布局正确
- [ ] Grid显示6列
- [ ] 窗口调整响应正常

### 7.4 断点切换测试
**描述**: 测试断点切换的流畅性
**执行步骤**:
1. 在2in1模拟器上
2. 逐步调整窗口大小
3. 观察断点切换过程
4. 记录切换响应时间

**验收标准**:
- [ ] 断点切换无闪烁
- [ ] 响应时间 < 100ms
- [ ] 布局平滑过渡

---

## 任务8: 性能优化与代码审查 (P2)

**任务描述**: 优化性能并进行代码审查，确保代码质量。

**输入**:
- 完整的HomePage实现
- 性能分析工具

**输出**:
- 性能优化报告
- 代码审查报告

**子任务**:

### 8.1 性能分析
**描述**: 使用DevEco Studio分析性能
**执行步骤**:
1. 启动性能分析工具
2. 测量页面加载时间
3. 测量内存占用
4. 分析渲染性能
5. 记录性能数据

**验收标准**:
- [ ] 页面加载时间 < 1秒
- [ ] 内存占用 < 50MB
- [ ] 渲染帧率 >= 60fps

### 8.2 代码审查
**描述**: 审查代码质量
**执行步骤**:
1. 检查是否使用any类型
2. 检查状态管理是否正确
3. 检查是否有内存泄漏风险
4. 检查代码注释是否完整
5. 检查命名规范

**验收标准**:
- [ ] 无any类型使用
- [ ] 状态管理正确
- [ ] 无内存泄漏风险
- [ ] 代码注释完整
- [ ] 命名规范统一

### 8.3 文档更新
**描述**: 更新相关文档
**执行步骤**:
1. 更新README.md(如有需要)
2. 更新开发日志
3. 记录已知问题

**验收标准**:
- [ ] 文档已更新
- [ ] 开发日志已记录

---

## 任务依赖关系图

```
任务1 (环境准备)
  │
  ├──→ 任务2 (响应式计算方法)
  │      │
  │      └──→ 任务3 (@Builder方法)
  │             │
  │             └──→ 任务4 (主build方法)
  │                    │
  │                    ├──→ 任务5 (功能入口配置)
  │                    │
  │                    ├──→ 任务6 (样式优化)
  │                    │
  │                    └──→ 任务7 (多设备测试)
  │                           │
  │                           └──→ 任务8 (性能优化)
```

---

## 执行顺序建议

**Day 1 上午 (3小时)**:
1. 执行任务1: 环境准备与依赖验证 (30分钟)
2. 执行任务2: 响应式布局参数计算方法实现 (1.5小时)
3. 执行任务3: @Builder UI组件构建方法实现 (1小时)

**Day 1 下午 (3小时)**:
4. 执行任务4: 主build()方法实现 (1小时)
5. 执行任务5: 功能入口数据配置 (30分钟)
6. 执行任务6: 样式优化与细节调整 (1小时)
7. 执行任务7: 多设备测试验证 (30分钟)

**Day 1 晚上 (1小时)**:
8. 执行任务8: 性能优化与代码审查 (1小时)

---

## 验收标准汇总

| 任务ID | 任务名称 | 关键验收标准 | 优先级 |
|--------|---------|-------------|--------|
| 任务1 | 环境准备 | BreakpointSystem可用，HomePage可读 | P0 |
| 任务2 | 响应式计算 | 所有计算方法返回正确值 | P0 |
| 任务3 | @Builder方法 | 所有UI组件正确渲染 | P0 |
| 任务4 | 主build方法 | 页面完整显示，布局正确 | P0 |
| 任务5 | 功能入口配置 | 13个入口配置正确 | P1 |
| 任务6 | 样式优化 | 视觉效果符合设计规范 | P1 |
| 任务7 | 多设备测试 | 三种设备布局正确 | P1 |
| 任务8 | 性能优化 | 性能指标达标，代码质量合格 | P2 |

---

## 风险与应对

| 风险项 | 影响 | 应对措施 |
|-------|------|---------|
| BreakpointSystem不可用 | 阻塞开发 | 提前验证，如有问题及时修复 |
| 目标页面不存在 | 功能入口无法跳转 | 创建占位页面或更新路由 |
| 断点切换闪烁 | 用户体验差 | 优化过渡动画，使用防抖 |
| 性能不达标 | 用户体验差 | 优化渲染逻辑，减少重绘 |

---

## 附录

### A. QuickAction接口定义

```typescript
interface QuickAction {
  id: string;           // 唯一标识
  icon: string;         // 图标(emoji)
  title: string;        // 标题
  color: string;        // 主题色(十六进制)
  route: string;        // 路由路径
}
```

### B. 健康统计数据接口

```typescript
interface HealthStat {
  id: string;
  icon: string;
  title: string;
  value: string;
  unit: string;
  trend: string;
}
```

### C. 开发日志模板

```markdown
## 开发日志 - 首页响应式布局

**日期**: 2026-05-06
**开发者**: [开发者姓名]

### 完成任务
- [x] 任务1: 环境准备与依赖验证
- [x] 任务2: 响应式布局参数计算方法实现
- [ ] ...

### 遇到问题
1. 问题描述...
   - 解决方案: ...

### 性能数据
- 页面加载时间: XXXms
- 内存占用: XXMB
- 断点切换响应: XXms

### 备注
...
```

---

**文档结束**

本任务文档提供了完整的开发指导，按照任务顺序执行即可完成首页响应式布局的开发工作。每个任务都包含详细的执行步骤、代码示例和验收标准，确保开发过程可控、可验证。
