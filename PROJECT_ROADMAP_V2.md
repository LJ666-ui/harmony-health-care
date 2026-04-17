# 星云医疗助手（HarmonyOS Healthcare）- 项目开发规划书

> **版本：** V2.0 Final
> **更新日期：** 2026-04-10
> **项目类型：** HarmonyOS API22 原生应用
> **目标平台：** HarmonyOS NEXT / 鸿蒙模拟器
> **适用场景：** 大赛演示、医疗健康APP原型

---

## 📋 目录

- [一、项目概述](#一项目概述)
- [二、当前完成度分析](#二当前完成度分析)
- [三、前端开发规划](#三前端开发规划)
- [四、后端开发规划](#四后端开发规划)
- [五、时间线与里程碑](#五时间线与里程碑)
- [六、技术栈选型](#六技术栈选型)
- [七、质量标准](#七质量标准)
- [八、风险控制](#八风险控制)

---

## 一、项目概述

### 1.1 项目定位
**星云医疗助手**是一款基于HarmonyOS API22开发的智慧医疗健康管理应用，面向中老年群体提供一站式医疗服务。

### 1.2 核心功能模块

| 模块 | 功能描述 | 目标用户 |
|------|----------|----------|
| **智慧就医** | 医院查询、预约挂号、AR导航、科室介绍 | 全体用户 |
| **康复训练** | 3D康复指导、课程管理、风险评估 | 慢病患者 |
| **健康科普** | 文章阅读、健康知识推送 | 健康关注者 |
| **个人中心** | 设备绑定、隐私设置、老年模式 | 中老年人 |
| **数据记录** | 健康指标追踪、用药提醒、预约管理 | 长期使用者 |

### 1.3 技术特色
- ✨ **老年友好设计** - 一键切换大字体/高对比度模式
- 🎯 **AR导航技术** - 院内智能导航到诊室
- 🎮 **3D康复训练** - 沉浸式康复体验
- 🤖 **AI语音助手** - 小艺语音交互
- 🔒 **隐私保护体系** - 完整的数据权限控制

---

## 二、当前完成度分析

### 2.1 前端现状统计

#### 页面完成情况（共24个页面）

| 分类 | 页面数 | 已优化 | 待优化 | 完成率 |
|------|--------|--------|--------|--------|
| **核心框架** | 5个（Tab页） | 5个 | 0个 | **100%** ✅ |
| **登录/首页** | 2个 | 2个 | 0个 | **100%** ✅ |
| **就医服务** | 6个 | 3个 | 3个 | **50%** ⚠️ |
| **康复训练** | 4个 | 2个 | 2个 | **50%** ⚠️ |
| **健康科普** | 3个 | 2个 | 1个 | **67%** ⚠️ |
| **个人中心** | 6个 | 4个 | 2个 | **67%** ⚠️ |
| **设备/导航** | 2个 | 2个 | 0个 | **100%** ✅ |

**总体完成度：78%**

#### 功能特性覆盖

| 特性 | 状态 | 覆盖率 | 备注 |
|------|------|--------|------|
| GlobalTheme统一样式 | ⏳ 进行中 | 58% (14/24) | 10个页面待适配 |
| 老年模式全局生效 | ⏳ 进行中 | 58% (14/24) | 同上 |
| 底部导航栏显示 | ✅ 完成 | 100% (22/22) | 所有子页面正常 |
| 点击反馈动画 | ⏳ 进行中 | 42% (10/24) | 14个页面待添加 |
| 下拉刷新功能 | ❌ 未开始 | 0% | 仅组件已创建 |
| Mock数据真实化 | ⏳ 进行中 | 80% | 数据量需扩充 |

### 2.2 后端现状统计

#### 当前状态
- **后端服务：** ❌ 未开发（纯前端Mock数据）
- **数据库：** ❌ 未设计（使用内存存储）
- **API接口：** ❌ 未定义（无网络请求）
- **用户认证：** ❌ 未实现（硬编码登录）

#### 后端需求分析

| 服务模块 | 优先级 | 复杂度 | 是否必须 |
|----------|--------|--------|----------|
| 用户认证系统 | P0 | ⭐⭐⭐ | 是（大赛可选） |
| 健康数据CRUD | P0 | ⭐⭐ | 是 |
| 预约管理系统 | P0 | ⭐⭐ | 是 |
| 设备数据同步 | P1 | ⭐⭐⭐ | 否（可模拟） |
| 科普内容管理 | P1 | ⭐ | 否 |
| AI语音服务 | P2 | ⭐⭐⭐⭐ | 否（可规则匹配） |
| 数据统计分析 | P2 | ⭐⭐ | 否 |

---

## 三、前端开发规划

### 3.1 阶段一：UI统一化修复（P0 - 必须完成）

**目标：** 将剩余10个页面全部升级为标准化的GlobalTheme + 老年模式支持

#### 任务清单

| 序号 | 页面文件 | 主要工作项 | 工作量 | 当前状态 |
|------|----------|------------|--------|----------|
| F1.01 | `Appointments.ets` | 导入GlobalTheme、替换硬编码值、添加@StorageLink | 15min | 🔴 待开始 |
| F1.02 | `Medications.ets` | 同上 + 优化用药提醒开关UI | 15min | 🔴 待开始 |
| F1.03 | `DeviceDiscoveryPage.ets` | 同上 + 优化蓝牙扫描动画效果 | 15min | 🔴 待开始 |
| F1.04 | `RiskAssessmentPage.ets` | 同上 + 优化评分环形图颜色 | 20min | 🔴 待开始 |
| F1.05 | `RehabListPage.ets` | 同上 + 优化课程卡片难度标签 | 15min | 🔴 待开始 |
| F1.06 | `ScienceDetailPage.ets` | 同上 + 优化文章排版和阅读进度 | 15min | 🔴 待开始 |
| F1.07 | `AddAppointmentPage.ets` | 同上 + 优化表单验证提示 | 15min | 🔴 待开始 |
| F1.08 | `DepartmentPage.ets` | 同上 + 优化医生列表头像展示 | 15min | 🔴 待开始 |
| F1.09 | `Rehab3DPage.ets` | 补充老年模式适配、统一颜色常量引用 | 20min | 🔴 待开始 |
| F1.10 | `Index.ets` | 重构为启动页/欢迎页、添加品牌Logo | 15min | 🔴 待开始 |

**总工作量：约2小时**

#### 标准化代码模板

```typescript
// ✅ 标准化的页面结构模板
import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';

@Entry
@Component
struct PageName {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    }
  }

  build(): void {
    Column() {
      Header({
        title: '页面标题',
        showBack: true  // Tab页为false
      });

      Scroll() {
        Column({ space: GlobalTheme.getSpacingLG(this.isElderMode) }) {
          // 页面内容区域
          Text('示例文本')
            .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
            .fontColor(GlobalTheme.TEXT_PRIMARY);
        }
        .width('85%')
        .padding({ 
          top: GlobalTheme.getSpacingLG(this.isElderMode), 
          bottom: GlobalTheme.getSpacingLG(this.isElderMode) 
        });
      }
      .flexGrow(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
      .layoutWeight(1);

      Footer({ activeIndex: X });  // 0=首页, 1=就医, 2=康复, 3=科普, 4=我的
    }
    .width('100%')
    .height('100%')
    .backgroundColor(GlobalTheme.BG_COLOR);
  }
}
```

#### 替换规则速查表

| 硬编码值 | 替换方法 | 示例 |
|---------|----------|------|
| `.fontSize(24)` | `.fontSize(GlobalTheme.getFontSizeTitle(isElderMode))` | 标题字号 |
| `.fontSize(16)` | `.fontSize(GlobalTheme.getFontSizeBody(isElderMode))` | 正文字号 |
| `.fontSize(13)` | `.fontSize(GlobalTheme.getFontSizeSmall(isElderMode))` | 小字字号 |
| `.fontColor('#1677FF')` | `.fontColor(GlobalTheme.THEME_COLOR)` | 主题色 |
| `.fontColor('#333333')` | `.fontColor(GlobalTheme.TEXT_PRIMARY)` | 主文字色 |
| `.fontColor('#666666')` | `.fontColor(GlobalTheme.TEXT_SECONDARY)` | 副文字色 |
| `.backgroundColor('#F5F7FA')` | `.backgroundColor(GlobalTheme.BG_COLOR)` | 背景色 |
| `.borderRadius(12)` | `.borderRadius(GlobalTheme.RADIUS_MD)` | 圆角 |
| `.margin({ top: 16 })` | `.margin({ top: GlobalTheme.getSpacingMD(isElderMode) })` | 间距 |

---

### 3.2 阶段二：交互体验增强（P0 - 强烈推荐）

**目标：** 提升所有页面的操作流畅度和视觉反馈质量

#### 任务清单

| 序号 | 功能模块 | 详细说明 | 技术方案 | 影响范围 |
|------|----------|----------|----------|----------|
| F2.01 | **全局点击反馈** | 所有可点击元素添加缩放+透明度动画 | 使用ClickableCard组件包裹或直接添加onTouch事件 | 24个页面 |
| F2.02 | **下拉刷新集成** | 列表页面支持下拉刷新（纯UI模拟） | PullRefresh组件 + setTimeout模拟加载 | 8个列表页 |
| F2.03 | **Loading状态优化** | 异步操作时显示加载进度条 | LoadingProgress组件 + 文字提示 | 6个数据页 |
| F2.04 | **Empty空状态处理** | 无数据时显示友好提示图 | EmptyState组件 + 引导操作按钮 | 4个列表页 |
| F2.05 | **Toast消息提示** | 操作成功/失败弹出短暂提示 | promptAction.showToast() | 12个操作页 |
| F2.06 | **按钮禁用态** | 表单未填写完成时按钮置灰不可点击 | @State控制enabled属性 | 3个表单页 |
| F2.07 | **长按操作菜单** | 列表项长按显示「编辑/删除」选项 | onLongPress事件 + Popup菜单 | 4个列表页 |
| F2.08 | **页面过渡动画** | 路由跳转时淡入淡出效果 | router.pushUrl配置animation参数 | 24个页面 |

**总工作量：约1.5小时**

#### 实现示例

```typescript
// F2.01 点击反馈动画实现
@State isPressed: boolean = false;

Column() {
  Text('可点击卡片')
}
.scale({ x: this.isPressed ? 0.97 : 1, y: this.isPressed ? 0.97 : 1 })
.opacity(this.isPressed ? 0.9 : 1)
.animation({ duration: 150, curve: Curve.EaseInOut })
.onTouch((event: TouchEvent) => {
  if (event.type === TouchType.Down) {
    this.isPressed = true;
  } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
    this.isPressed = false;
    // 执行点击逻辑
  }
});

// F2.02 下拉刷新实现
PullRefresh({
  onRefresh: () => {
    // 模拟数据刷新
    setTimeout(() => {
      this.loadData();
    }, 1500);
  }
}) {
  List() {
    ForEach(this.dataList, (item) => {
      ListItem() {
        // 列表项渲染
      }
    });
  }
}

// F2.05 Toast提示实现
import { promptAction } from '@kit.ArkUI';

handleSave(): void {
  try {
    // 保存逻辑
    promptAction.showToast({
      message: '保存成功',
      duration: 2000
    });
  } catch (error) {
    promptAction.showToast({
      message: '操作失败，请重试',
      duration: 2000
    });
  }
}
```

---

### 3.3 阶段三：Mock数据真实化（P1 - 推荐完成）

**目标：** 让所有演示数据更贴近真实医疗场景，提升大赛演示的说服力

#### 数据扩充计划

| 序号 | 页面 | 当前数量 | 目标数量 | 数据质量要求 |
|------|------|----------|----------|--------------|
| F3.01 | HealthRecords | 3条 | **12条** | 血压/血糖/心率/体温/体重/睡眠各2条，含正常/异常值 |
| F3.02 | Appointments | 2条 | **6条** | 不同科室（内科/外科/骨科/儿科/妇科/眼科），不同时间段 |
| F3.03 | Medications | 2条 | **8条** | 降压药/降糖药/维生素/消炎药/止痛药/中药等 |
| F3.04 | HospitalPage | 6家 | **10家** | 三甲医院4家+专科医院3家+社区医院3家 |
| F3.05 | ScienceListPage | 8篇 | **15篇** | 心血管/骨科/内分泌/营养/心理/中医等分类 |
| F3.06 | PrivacyPage日志 | 5条 | **10条** | 登录/查看/修改/导出/授权等多种操作记录 |
| F3.07 | DeviceDiscoveryPage | 3台 | **8台** | 手环/手表/血压计/体脂秤/血糖仪/血氧仪/体温计/体重秤 |
| F3.08 | RiskAssessmentPage | 5项指标 | **8项指标** | 新增BMI/骨密度/肺功能/睡眠质量评估 |
| F3.09 | RehabListPage | 4门课程 | **8门课程** | 颈椎/腰椎/肩周/膝关节炎/糖尿病/高血压/帕金森/术后恢复 |
| F3.10 | VoiceAssistantPage | 5条指令 | **10条指令** | 增加「查药品」「查医院」「查症状」「紧急呼叫」等场景 |

**总工作量：约1小时**

#### 高质量数据示例

```typescript
// F3.01 健康记录 - 真实场景数据
{
  id: 'HR001',
  type: '血压',
  value: '138/88',
  unit: 'mmHg',
  date: '2026-04-10',
  time: '07:30',
  notes: '晨起测量，昨晚熬夜至23:30，血压略偏高',
  icon: '🩺',
  color: '#FAAD14',  // 黄色警告
  trend: 'up',       // 较昨日上升
  normalRange: '90-140/60-90',
  status: 'warning'   // 正常偏高
},
{
  id: 'HR002',
  type: '血糖',
  value: '6.8',
  unit: 'mmol/L',
  date: '2026-04-10',
  time: '08:00',
  notes: '空腹血糖，早餐前测量',
  icon: '💉',
  color: '#52C41A',  // 绿色正常
  trend: 'stable',
  normalRange: '3.9-6.1',
  status: 'normal'
}

// F3.02 预约数据 - 多样化场景
{
  id: 'APT001',
  doctor: '王建国 主任医师',
  specialty: '心血管内科',
  hospital: '北京协和医院',
  hospitalLevel: '三级甲等',
  date: '2026-04-15',
  time: '09:30',
  status: 'confirmed',
  location: '门诊楼A座3层 心内科诊室302',
  queueNumber: 'A028',
  estimatedWaitTime: '约45分钟',
  fee: '挂号费: 100元 | 诊疗费: 300元',
  notes: '请携带近期心电图检查报告',
  avatarColor: '#1677FF'
}

// F3.07 设备数据 - 完整产品信息
{
  id: 'DEV001',
  name: '华为 WATCH GT5 Pro',
  brand: '华为',
  model: 'GT5 Pro 46mm',
  icon: '⌚',
  type: '智能手表',
  signal: '信号强 (-45dBm)',
  battery: '85%',
  isConnected: false,
  lastSyncTime: '2026-04-09 22:30',
  features: ['心率监测', '血氧检测', '睡眠分析', '运动追踪'],
  firmwareVersion: '4.0.0.36'
}
```

---

### 3.4 阶段四：高级功能扩展（P2 - 加分项）

**目标：** 增加创新亮点，提升大赛竞争力和技术深度

#### 优先级排序

| 序号 | 功能名称 | 描述 | 技术复杂度 | 预期效果 | 建议优先级 |
|------|----------|------|------------|----------|-----------|
| **F4.01** | **📊 健康数据可视化图表** | 在HealthRecords页面添加折线图/柱状图展示趋势 | ⭐⭐⭐ | 数据可视化能力突出 | ⭐⭐⭐ 强烈推荐 |
| **F4.02** | **🤖 AI语音助手增强** | 规则匹配+模板回复，支持多轮对话 | ⭐⭐ | AI技术应用展示 | ⭐⭐⭐ 强烈推荐 |
| **F4.03** | **🔍 全局搜索功能** | 支持搜索医院/科室/文章/药品/医生 | ⭐⭐ | 产品完整性提升 | ⭐⭐ 推荐 |
| **F4.04** | **❤️ 收藏功能** | 科普文章收藏、常用医院收藏 | ⭐ | 用户粘性体现 | ⭐ 可选 |
| **F4.05** | **🔔 通知中心** | 预约提醒/用药提醒/复诊提醒列表 | ⭐⭐ | 实用性增强 | ⭐⭐ 推荐 |
| **F4.06** | **🌙 深色模式** | 夜间护眼主题（除老年模式外） | ⭐⭐ | 设计细节加分 | ⭐ 可选 |
| **F4.07** | **📱 引导页/新手教程** | 首次进入的功能介绍浮层引导 | ⭐⭐ | 用户体验加分 | ⭐⭐ 推荐 |
| **F4.08** | **📤 数据导出报告** | 健康数据一键生成PDF报告（模拟） | ⭐⭐⭐ | 商业价值体现 | ⭐ 可选 |

#### 重点功能详细设计

##### **F4.01 健康数据趋势图表**

```
位置：HealthRecords.ets 页面顶部区域
技术方案：
  方案A（推荐）：使用Canvas绘制自定义图表
  方案B（简单）：使用Progress + Column组合拼接

展示内容：
  ┌─────────────────────────────────────┐
  │  近7天血压趋势                        │
  │  ┌───┬───┬───┬───┬───┬───┬───┐     │
  │  │ ╱│╲ │╱ │╲ │╱ │╲ │   │ 折线图  │
  │  └───┴───┴───┴───┴───┴───┴───┘     │
  │  04/04  05  06  07  08  09  10     │
  │                                     │
  │  最高值: 142 mmHg  平均值: 128      │
  │  最低值: 118 mmHg  趋势: ↗ 略升     │
  └─────────────────────────────────────┘

交互功能：
  - 点击数据点显示详细信息（日期/时间/备注）
  - 左右滑动切换时间范围（7天/30天/90天）
  - 支持切换指标类型（血压/血糖/心率）
  - 「导出报告」按钮（跳转到模拟PDF预览页）
```

**技术实现要点：**
```typescript
// Canvas绘制折线图
Canvas(this.context)
  .width('100%')
  .height(200)
  .onReady(() => {
    const ctx = this.context;
    
    // 绘制坐标轴
    ctx.strokeStyle = '#E0E0E0';
    ctx.lineWidth = 1;
    ctx.beginPath();
    ctx.moveTo(40, 20);
    ctx.lineTo(40, 180);  // Y轴
    ctx.lineTo(360, 180); // X轴
    ctx.stroke();
    
    // 绘制数据点和连线
    ctx.strokeStyle = '#1677FF';
    ctx.lineWidth = 2;
    ctx.beginPath();
    dataPoints.forEach((point, index) => {
      const x = 40 + (index * 52);
      const y = 180 - (point.value * scale);
      
      if (index === 0) {
        ctx.moveTo(x, y);
      } else {
        ctx.lineTo(x, y);
      }
      
      // 绘制数据点圆圈
      ctx.fillStyle = '#FFFFFF';
      ctx.fill();
      ctx.stroke();
      ctx.arc(x, y, 4, 0, Math.PI * 2);
    });
    ctx.stroke();
  });
```

##### **F4.02 AI语音助手增强**

```
位置：VoiceAssistantPage.ets 增强
技术方案：关键词匹配 + 模板回复引擎

支持的对话场景：

场景1：健康咨询
  用户："我最近血压高怎么办？"
  → 分析：包含"血压"+"高"
  → 回复："根据您近期的血压记录（平均132/85mmHg），属于正常偏高范围。
     建议：①低盐饮食（每日<6g盐）②规律有氧运动③保持充足睡眠
     如持续高于140/90mmHg，建议及时就医。"

场景2：用药查询
  用户："阿莫西林怎么吃？"
  → 匹配药品库
  → 回复："阿莫西林胶囊用法说明：
     【用量】成人每次500mg（1粒），每日3次
     【时间】饭后30分钟服用（减少胃肠道刺激）
     【疗程】连续服用7天，即使症状好转也需完成疗程
     【注意】对青霉素过敏者禁用"

场景3：预约帮助
  用户："我想挂心内科"
  → 查询可用医生
  → 回复："为您推荐以下心内科专家：
     ① 王建国 主任医师 - 北京协和医院
        时间：4月15日 09:30 | 剩余号源：3个
     
     ② 李明华 副主任医师 - 朝阳医院
        时间：4月16日 14:00 | 剩余号源：5个
     
     请回复数字选择医生，或说'换个时间'"

场景4：紧急求助
  用户："救命/不舒服/头晕"
  → 识别紧急关键词
  → 回复："检测到紧急情况！
     🆘 请立即采取以下措施：
     ① 保持冷静，坐下或躺下休息
     ② 如果可能，通知家人或拨打120急救电话
     ③ 如有硝酸甘油等急救药物，按医嘱使用
     
     正在尝试联系您的紧急联系人..."
```

**规则引擎实现：**
```typescript
interface IntentRule {
  keywords: string[];
  priority: number;
  response: string;
  action?: () => void;
}

private intentRules: IntentRule[] = [
  {
    keywords: ['血压', '高压', '低压'],
    priority: 1,
    response: this.generateBloodPressureAdvice()
  },
  {
    keywords: ['阿莫西林', '布洛芬', '怎么吃', '用法'],
    priority: 2,
    response: this.queryMedicationInfo()
  },
  {
    keywords: ['挂号', '预约', '想看'],
    priority: 3,
    response: this.suggestAppointment(),
    action: () => this.showDoctorList()
  },
  {
    keywords: ['救命', '难受', '晕', '胸痛', '呼吸困难'],
    priority: 0,  // 最高优先级
    response: this.emergencyResponse(),
    action: () => this.callEmergencyContact()
  }
];

processUserInput(input: string): string {
  for (const rule of this.intentRules.sort((a, b) => a.priority - b.priority)) {
    if (rule.keywords.some(keyword => input.includes(keyword))) {
      if (rule.action) {
        rule.action();
      }
      return rule.response;
    }
  }
  
  return "抱歉，我没有理解您的意思。您可以试试问：
         \n• \"我的血压怎么样\"
         \n• \"阿莫西林怎么吃\"
         \n• \"我想挂心内科\"";
}
```

---

### 3.5 阶段五：性能优化与代码质量（P1 - 必须）

**目标：** 确保应用运行流畅、代码规范易维护

#### 优化清单

| 序号 | 优化项 | 具体措施 | 预期收益 | 工作量 |
|------|--------|----------|----------|--------|
| F5.01 | **代码格式化** | 统一缩进风格（2空格）、移除无用注释、关键位置添加注释 | 可读性↑ 维护性↑ | 30min |
| F5.02 | **组件抽离** | 将重复出现的列表项UI抽取为独立子组件（如AppointmentItem, RecordCard） | 复用性↑ 代码量↓ | 30min |
| F5.03 | **常量提取** | 全面排查并替换剩余的硬编码值到GlobalTheme | 一致性↑ 维护性↑ | 20min |
| F5.04 | **错误边界完善** | 为所有router.pushUrl调用添加try-catch，避免崩溃 | 稳定性↑ | 15min |
| F5.05 | **定时器清理** | 检查Rehab3DPage等页面的定时器，确保在aboutDisappear中清理 | 内存泄漏↓ | 15min |
| F5.06 | **懒加载优化** | 长列表（>20项）使用LazyForEach替代ForEach | 渲染性能↑ | 20min |
| F5.07 | **资源优化** | 移除未使用的import语句，减小编译体积 | 包体积↓ 编译速度↑ | 15min |
| F5.08 | **构建验证** | 执行hvigor build确保零错误零警告 | 质量保证 | 10min |

**总工作量：约2小时**

#### 代码审查检查清单

```typescript
// ✅ 正确示范
import { GlobalTheme } from '../global';

@Component
export struct AppointmentCard {
  @Prop appointment: Appointment;
  @Prop isElderMode: boolean;

  build() {
    Column() {
      Text(this.appointment.doctor)
        .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
        .fontWeight(FontWeight.Bold)
        .fontColor(GlobalTheme.TEXT_PRIMARY);
        
      Text(`${this.appointment.specialty} | ${this.appointment.hospital}`)
        .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
        .fontColor(GlobalTheme.TEXT_SECONDARY);
    }
    .padding(GlobalTheme.getSpacingMD(this.isElderMode))
    .backgroundColor(GlobalTheme.CARD_BG)
    .borderRadius(GlobalTheme.RADIUS_MD)
  }
}

// ❌ 错误示范（禁止出现）
Text('标题')
  .fontSize(24)              // 硬编码字号
  .fontColor('#1677FF');     // 硬编码颜色
  
Column() {
  // 重复的列表项代码复制了5遍...
}
```

---

### 3.6 阶段六：测试与交付准备（P0 - 必须）

**目标：** 确保零bug、完善演示流程

#### 测试矩阵

| 测试类别 | 测试项 | 测试方法 | 通过标准 | 负责人 |
|----------|--------|----------|----------|--------|
| **功能测试** | 所有按钮/链接可点击响应 | 手动逐页点击 | 100%通过率 | 开发者 |
| **路由测试** | 完整路径闭环测试 | 按演示脚本走查 | 无死链/无报错 | 开发者 |
| **老年模式测试** | 开启后全页面生效 | 逐页截图对比 | 字体间距全部变大 | 开发者 |
| **兼容性测试** | 不同分辨率屏幕 | DevEco Previewer | 无溢出/截断/错位 | 开发者 |
| **性能测试** | 页面切换/滚动流畅度 | FPS监控工具 | FPS≥55 | 开发者 |
| **编译测试** | hvigor build | 终端执行命令 | 0 error / 0 warning | 开发者 |
| **回归测试** | 修改后重新验证 | 全量用例执行 | 无新问题引入 | 开发者 |

#### 交付物清单

| 序号 | 文档/资源 | 格式 | 说明 | 必要性 |
|------|-----------|------|------|--------|
| D1 | **源代码包** | ZIP | 完整项目源码（不含node_modules） | 必须 |
| D2 | **安装包** | HAP/HAP包 | 可在模拟器运行的安装文件 | 必须 |
| D3 | **演示脚本** | DOCX/PDF | 详细的操作步骤和讲解话术 | 推荐 |
| D4 | **README文档** | MD | 项目简介、运行指南、功能说明 | 推荐 |
| D5 | **功能清单表格** | XLSX | 所有功能点及其完成状态 | 可选 |
| D6 | **截图素材** | PNG/JPG | 关键页面的高清截图（用于PPT） | 推荐 |
| D7 | **视频演示** | MP4 | 3-5分钟的操作录屏（备用） | 可选 |

**总工作量：约1小时**

---

## 四、后端开发规划

### 4.1 架构设计概述

#### 整体架构图

```
┌─────────────────────────────────────────────────────────┐
│                    客户端层 (Client)                      │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐              │
│  │ HarmonyOS│  │ Web管理端│  │ 小程序   │              │
│  │ APP      │  │ (可选)   │  │ (可选)   │              │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘              │
│       │              │              │                    │
└───────┼──────────────┼──────────────┼────────────────────┘
        │              │              │
        ▼              ▼              ▼
┌─────────────────────────────────────────────────────────┐
│                   网关层 (Gateway)                       │
│  ┌──────────────────────────────────────────────────┐   │
│  │  API Gateway (Nginx/Kong)                         │   │
│  │  • 路由转发                                       │   │
│  │  • 负载均衡                                       │   │
│  │  • 限流熔断                                       │   │
│  │  • 认证鉴权 (JWT Token)                           │   │
│  └──────────────────────────────────────────────────┘   │
└───────────────────────────┬─────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│                   服务层 (Service Layer)                 │
│                                                         │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐  │
│  │ 用户服务  │ │ 健康数据  │ │ 预约管理  │ │ 设备管理  │  │
│  │ UserSvc  │ │ HealthSvc│ │ AptSvc   │ │DeviceSvc │  │
│  └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘  │
│       │           │           │           │           │
│  ┌────┴─────┐ ┌────┴─────┐ ┌────┴─────┐ ┌────┴─────┐  │
│  │ 内容服务  │ │ 康复服务  │ │ AI服务   │ │ 通知服务  │  │
│  │ContentSvc│ │RehabSvc  │ │ AISvc    │ │NotifySvc │  │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘  │
└───────────────────────────┬─────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│                   数据层 (Data Layer)                     │
│                                                         │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐             │
│  │ MySQL    │  │ Redis    │  │ MongoDB   │             │
│  │ 主数据库  │  │ 缓存/会话 │  │ 日志/文件 │             │
│  └──────────┘  └──────────┘  └──────────┘             │
│                                                         │
│  ┌──────────┐  ┌──────────┐                             │
│  │ OSS对象  │  │ 消息队列  │                             │
│  │ 存储     │  │ RabbitMQ │                             │
│  └──────────┘  └──────────┘                             │
└─────────────────────────────────────────────────────────┘
```

#### 技术栈选型（推荐）

| 层次 | 技术选择 | 版本 | 选择理由 |
|------|----------|------|----------|
| **前端框架** | ArkTS (HarmonyOS) | API22 | 官方推荐，性能最优 |
| **后端语言** | Node.js / Java / Go | LTS版本 | 团队熟悉度高 |
| **Web框架** | Express / Spring Boot / Gin | 最新稳定版 | 生态成熟 |
| **数据库** | MySQL 8.0 | 8.0+ | 关系型数据，事务支持好 |
| **缓存** | Redis 7.x | 7.x | 会话管理、热点数据缓存 |
| **消息队列** | RabbitMQ / Kafka | 3.x | 异步任务解耦 |
| **对象存储** | 阿里云OSS / MinIO | - | 文件/图片存储 |
| **容器化** | Docker + K8s | - | 部署运维便利 |

---

### 4.2 后端阶段一：基础架构搭建（P0 - 如果要做后端）

**目标：** 搭建可运行的后端骨架，实现基本的CRUD接口

#### 数据库设计

##### ER关系图（简化版）

```
┌──────────────┐       ┌──────────────┐       ┌──────────────┐
│    users     │       │ health_records│       │ appointments │
├──────────────┤       ├──────────────┤       ├──────────────┤
│ id (PK)      │──┐    │ id (PK)      │──┐    │ id (PK)      │
│ phone        │  │    │ user_id (FK) │  │    │ user_id (FK) │
│ password     │  └────│ type         │  └────│ doctor_id    │
│ nickname     │       │ value        │       │ hospital_id  │
│ avatar_url   │       │ unit         │       │ department   │
│ is_elder_mode│       │ measured_at  │       │ apt_date     │
│ created_at   │       │ notes        │       │ apt_time     │
│ updated_at   │       │ created_at   │       │ status       │
└──────────────┘       └──────────────┘       │ notes        │
                                              └──────────────┘

┌──────────────┐       ┌──────────────┐       ┌──────────────┐
│  medications │       │ devices      │       │  articles    │
├──────────────┤       ├──────────────┤       ├──────────────┤
│ id (PK)      │       │ id (PK)      │       │ id (PK)      │
│ user_id (FK) │───────│ user_id (FK) │       │ title        │
│ name         │       │ device_name  │       │ category     │
│ dosage       │       │ device_type  │       │ summary      │
│ frequency    │       │ mac_address  │       │ content      │
│ times        │       │ is_connected │       │ cover_image  │
│ start_date   │       │ last_sync_at │       │ author       │
│ end_date     │       │ battery_pct  │       │ publish_at   │
│ reminder_time│       │ created_at   │       │ read_count   │
│ is_active    │       └──────────────┘       │ like_count   │
│ created_at   │                              └──────────────┘
└──────────────┘
```

##### SQL建表脚本（MySQL）

```sql
-- ============================================
-- 1. 用户表
-- ============================================
CREATE TABLE users (
  id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '用户ID',
  phone VARCHAR(20) NOT NULL UNIQUE COMMENT '手机号码',
  password VARCHAR(255) NOT NULL COMMENT '密码(加密)',
  nickname VARCHAR(50) DEFAULT '星云用户' COMMENT '昵称',
  avatar_url VARCHAR(500) DEFAULT '' COMMENT '头像URL',
  gender TINYINT DEFAULT 0 COMMENT '性别: 0未知 1男 2女',
  birth_date DATE COMMENT '出生日期',
  is_elder_mode TINYINT DEFAULT 0 COMMENT '是否开启老年模式: 0否 1是',
  emergency_contact VARCHAR(20) COMMENT '紧急联系人电话',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  INDEX idx_phone (phone)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- ============================================
-- 2. 健康记录表
-- ============================================
CREATE TABLE health_records (
  id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '记录ID',
  user_id BIGINT NOT NULL COMMENT '用户ID',
  type VARCHAR(20) NOT NULL COMMENT '类型: blood_pressure/blood_sugar/heart_rate/body_temp/weight/sleep',
  value VARCHAR(50) NOT NULL COMMENT '数值',
  unit VARCHAR(20) NOT NULL COMMENT '单位: mmHg/mmol/L/次分/℃/kg/hours',
  measured_at DATETIME NOT NULL COMMENT '测量时间',
  notes TEXT COMMENT '备注',
  source VARCHAR(50) DEFAULT 'manual' COMMENT '来源: manual/device_import',
  device_id BIGINT COMMENT '关联设备ID(如果是设备自动上传)',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  INDEX idx_user_type (user_id, type),
  INDEX idx_measured_at (measured_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='健康记录表';

-- ============================================
-- 3. 预约记录表
-- ============================================
CREATE TABLE appointments (
  id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '预约ID',
  user_id BIGINT NOT NULL COMMENT '用户ID',
  doctor_id BIGINT NOT NULL COMMENT '医生ID',
  hospital_id BIGINT NOT NULL COMMENT '医院ID',
  department VARCHAR(50) NOT NULL COMMENT '科室名称',
  apt_date DATE NOT NULL COMMENT '预约日期',
  apt_time TIME NOT NULL COMMENT '预约时间',
  status ENUM('pending','confirmed','completed','cancelled') DEFAULT 'pending' COMMENT '状态',
  queue_number VARCHAR(20) COMMENT '排队号',
  location VARCHAR(200) COMMENT '就诊地点',
  notes TEXT COMMENT '备注',
  fee DECIMAL(10,2) COMMENT '费用',
  reminder_sent TINYINT DEFAULT 0 COMMENT '是否已发送提醒: 0否 1是',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  INDEX idx_user_status (user_id, status),
  INDEX idx_apt_date (apt_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='预约记录表';

-- ============================================
-- 4. 用药记录表
-- ============================================
CREATE TABLE medications (
  id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '用药ID',
  user_id BIGINT NOT NULL COMMENT '用户ID',
  name VARCHAR(100) NOT NULL COMMENT '药品名称',
  dosage VARCHAR(50) NOT NULL COMMENT '剂量: 500mg/片',
  frequency VARCHAR(50) NOT NULL COMMENT '频次: 每日3次',
  times JSON COMMENT '服药时间点: ["08:00","12:00","20:00"]',
  start_date DATE NOT NULL COMMENT '开始日期',
  end_date DATE COMMENT '结束日期(长期用药为NULL)',
  is_active TINYINT DEFAULT 1 COMMENT '是否有效: 0停用 1有效',
  reminder_enabled TINYINT DEFAULT 1 COMMENT '是否启用提醒: 0否 1是',
  reminder_times JSON COMMENT '提醒时间配置',
  stock_quantity INT DEFAULT 0 COMMENT '库存数量',
  notes TEXT COMMENT '备注/注意事项',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  INDEX idx_user_active (user_id, is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用药记录表';

-- ============================================
-- 5. 设备绑定表
-- ============================================
CREATE TABLE devices (
  id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '设备ID',
  user_id BIGINT NOT NULL COMMENT '用户ID',
  device_name VARCHAR(100) NOT NULL COMMENT '设备名称',
  device_type VARCHAR(50) NOT NULL COMMENT '设备类型: watch/blood_monitor/scale/glucose_meter',
  brand VARCHAR(50) COMMENT '品牌',
  model VARCHAR(100) COMMENT '型号',
  mac_address VARCHAR(50) UNIQUE COMMENT 'MAC地址',
  bluetooth_name VARCHAR(100) COMMENT '蓝牙名称',
  is_connected TINYINT DEFAULT 0 COMMENT '是否在线: 0离线 1在线',
  battery_level INT DEFAULT 0 COMMENT '电量百分比(0-100)',
  firmware_version VARCHAR(50) COMMENT '固件版本',
  last_sync_at DATETIME COMMENT '最后同步时间',
  last_data_at DATETIME COMMENT '最后数据上报时间',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '绑定时间',
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  INDEX idx_user_device (user_id, device_type),
  INDEX idx_mac (mac_address)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='设备绑定表';

-- ============================================
-- 6. 科普文章表
-- ============================================
CREATE TABLE articles (
  id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '文章ID',
  title VARCHAR(200) NOT NULL COMMENT '标题',
  summary VARCHAR(500) COMMENT '摘要',
  content LONGTEXT COMMENT '正文内容(Markdown)',
  cover_image VARCHAR(500) COMMENT '封面图片URL',
  category VARCHAR(50) NOT NULL COMMENT '分类: cardiovascular/orthopedics/endocrinology/nutrition/mental/tcm',
  tags JSON COMMENT '标签数组',
  author VARCHAR(50) DEFAULT '星云医疗' COMMENT '作者',
  source VARCHAR(200) COMMENT '来源',
  view_count INT DEFAULT 0 COMMENT '浏览次数',
  like_count INT DEFAULT 0 COMMENT '点赞数',
  collect_count INT DEFAULT 0 COMMENT '收藏数',
  is_published TINYINT DEFAULT 1 COMMENT '是否发布: 0草稿 1已发布',
  published_at DATETIME COMMENT '发布时间',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  FULLTEXT INDEX ft_title_content (title, content),
  INDEX idx_category (category),
  INDEX idx_published (is_published, published_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='科普文章表';

-- ============================================
-- 7. 医生表
-- ============================================
CREATE TABLE doctors (
  id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '医生ID',
  name VARCHAR(50) NOT NULL COMMENT '姓名',
  title VARCHAR(50) COMMENT '职称: 主任医师/副主任医师/主治医师/医师',
  specialty VARCHAR(50) NOT NULL COMMENT '专科',
  hospital_id BIGINT NOT NULL COMMENT '所属医院ID',
  avatar_url VARCHAR(500) COMMENT '头像URL',
  introduction TEXT COMMENT '简介/擅长领域',
  consultation_fee DECIMAL(10,2) DEFAULT 0 COMMENT '咨询费',
  rating DECIMAL(2,1) DEFAULT 5.0 COMMENT '评分(1.0-5.0)',
  consultation_count INT DEFAULT 0 COMMENT '接诊次数',
  is_available TINYINT DEFAULT 1 COMMENT '是否可预约: 0停诊 1出诊',
  schedule JSON COMMENT '出诊时间表',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  INDEX idx_hospital_specialty (hospital_id, specialty)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='医生表';

-- ============================================
-- 8. 医院表
-- ============================================
CREATE TABLE hospitals (
  id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '医院ID',
  name VARCHAR(100) NOT NULL COMMENT '医院名称',
  level VARCHAR(20) COMMENT '等级: 三级甲等/三级乙等/二级甲等/专科/社区',
  address VARCHAR(300) NOT NULL COMMENT '地址',
  phone VARCHAR(20) COMMENT '联系电话',
  latitude DECIMAL(10,6) COMMENT '纬度',
  longitude DECIMAL(11,6) COMMENT '经度',
  logo_url VARCHAR(500) COMMENT 'Logo图片URL',
  introduction TEXT COMMENT '简介',
  departments JSON COMMENT '科室列表',
  working_hours VARCHAR(100) COMMENT '营业时间',
  is_featured TINYINT DEFAULT 0 COMMENT '是否推荐: 0否 1是',
  sort_order INT DEFAULT 0 COMMENT '排序权重',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  INDEX idx_level (level),
  INDEX idx_location (latitude, longitude)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='医院表';

-- ============================================
-- 9. 操作日志表(隐私审计)
-- ============================================
CREATE TABLE operation_logs (
  id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '日志ID',
  user_id BIGINT NOT NULL COMMENT '操作用户ID',
  action VARCHAR(50) NOT NULL COMMENT '操作类型: login/view/edit/delete/export/auth_revoke/data_share',
  target_type VARCHAR(50) COMMENT '操作对象类型: user_record/appointment/device/article',
  target_id BIGINT COMMENT '操作对象ID',
  ip_address VARCHAR(50) COMMENT 'IP地址',
  user_agent VARCHAR(500) COMMENT '客户端信息',
  request_method VARCHAR(10) COMMENT '请求方法: GET/POST/PUT/DELETE',
  request_url VARCHAR(500) COMMENT '请求URL',
  request_params TEXT COMMENT '请求参数',
  response_code INT COMMENT '响应状态码',
  execution_time INT COMMENT '执行耗时(ms)',
  result_message VARCHAR(500) COMMENT '结果描述',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
  INDEX idx_user_action (user_id, action, created_at),
  INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='操作日志表(用于隐私审计)';
```

#### API接口设计（RESTful规范）

##### 用户认证模块 `/api/v1/auth`

| 方法 | 路径 | 描述 | 请求参数 | 响应示例 |
|------|------|------|----------|----------|
| POST | `/auth/login` | 手机号登录 | `{phone, password}` | `{token, userInfo}` |
| POST | `/auth/register` | 新用户注册 | `{phone, password, code}` | `{token, userInfo}` |
| POST | `/auth/logout` | 退出登录 | Header: Authorization | `{message: "success"}` |
| GET | `/auth/sms-code` | 发送短信验证码 | `?phone=xxx` | `{message: "sent"}` |
| PUT | `/auth/password` | 修改密码 | `{oldPassword, newPassword}` | `{message: "success"}` |
| POST | `/auth/refresh-token` | 刷新Token | `{refreshToken}` | `{token}` |

**响应格式标准化：**
```json
// 成功响应
{
  "code": 200,
  "message": "success",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIs...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
    "user": {
      "id": 1,
      "phone": "138****1234",
      "nickname": "张三",
      "avatarUrl": "https://...",
      "isElderMode": false
    }
  },
  "timestamp": 1712745600000
}

// 错误响应
{
  "code": 40001,
  "message": "手机号或密码错误",
  "data": null,
  "timestamp": 1712745600000
}
```

##### 健康数据模块 `/api/v1/health`

| 方法 | 路径 | 描述 | 参数 | 分页 |
|------|------|------|------|------|
| GET | `/health/records` | 获取健康记录列表 | `?type=&startDate=&endDate=&page=1&size=20` | ✅ |
| POST | `/health/records` | 新增健康记录 | Body: recordObject | - |
| GET | `/health/records/:id` | 获取单条记录详情 | Path: id | - |
| PUT | `/health/records/:id` | 修改健康记录 | Body: recordObject | - |
| DELETE | `/health/records/:id` | 删除健康记录 | Path: id | - |
| GET | `/health/statistics` | 获取统计数据 | `?type=blood_pressure&range=7d` | - |
| GET | `/health/trend` | 获取趋势数据 | `?type=&period=7d/30d/90d` | - |
| POST | `/health/export` | 导出健康报告 | `?format=pdf/excel&types=[]` | - |

**请求示例：**
```bash
# 获取最近7天的血压记录
GET /api/v1/health/records?type=blood_pressure&startDate=2026-04-03&endDate=2026-04-10&page=1&size=20
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...

# 新增一条血压记录
POST /api/v1/health/records
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
Content-Type: application/json

{
  "type": "blood_pressure",
  "value": "128/82",
  "unit": "mmHg",
  "measuredAt": "2026-04-10T08:30:00",
  "notes": "晨起测量，昨晚睡眠充足",
  "source": "manual"
}
```

##### 预约管理模块 `/api/v1/appointments`

| 方法 | 路径 | 描述 | 参数 |
|------|------|------|------|
| GET | `/appointments` | 我的预约列表 | `?status=&page=1&size=20` |
| POST | `/appointments` | 创建新预约 | Body: appointmentObj |
| GET | `/appointments/:id` | 预约详情 | Path: id |
| PUT | `/appointments/:id/cancel` | 取消预约 | Path: id |
| GET | `/appointments/available-slots` | 查询可预约时段 | `?doctorId=&date=` |
| GET | `/hospitals` | 医院列表 | `?level=&keyword=&lat=&lng=&radius=` |
| GET | `/hospitals/:id/departments` | 医院科室列表 | Path: hospitalId |
| GET | `/doctors` | 医师列表 | `?hospitalId=&department=&keyword=` |
| GET | `/doctors/:id/schedule` | 医生出诊时间表 | Path: doctorId |

##### 设备管理模块 `/api/v1/devices`

| 方法 | 路径 | 描述 | 参数 |
|------|------|------|------|
| GET | `/devices` | 我绑定的设备列表 | - |
| POST | `/devices/bind` | 绑定新设备 | `{macAddress, deviceName, deviceType}` |
| DELETE | `/devices/:id/unbind` | 解绑设备 | Path: deviceId |
| PUT | `/devices/:id/rename` | 重命名设备 | `{newName}` |
| GET | `/devices/:id/data` | 获取设备最新数据 | Path: deviceId |
| POST | `/devices/:id/sync` | 手动同步设备数据 | Path: deviceId |
| WebSocket | `/ws/device/:deviceId` | 设备实时数据推送 | - |

##### 科普内容模块 `/api/v1/articles`

| 方法 | 路径 | 描述 | 参数 |
|------|------|------|------|
| GET | `/articles` | 文章列表 | `?category=&keyword=&page=1&size=20` |
| GET | `/articles/:id` | 文章详情 | Path: articleId |
| POST | `/articles/:id/like` | 点赞文章 | Path: articleId |
| POST | `/articles/:id/collect` | 收藏文章 | Path: articleId |
| GET | `/articles/my-collects` | 我的收藏 | `?page=1&size=20` |
| GET | `/articles/categories` | 文章分类列表 | - |
| GET | `/articles/hot` | 热门文章 | `?limit=10` |
| GET | `/articles/search` | 搜索文章 | `?keyword=&page=1&size=20` |

##### 隐私与权限模块 `/api/v1/privacy`

| 方法 | 路径 | 描述 | 参数 |
|------|------|------|------|
| GET | `/privacy/settings` | 获取隐私设置 | - |
| PUT | `/privacy/settings` | 更新隐私设置 | Body: settingsObj |
| GET | `/privacy/audit-log` | 操作日志列表 | `?action=&startDate=&endDate=&page=1&size=20` |
| POST | `/privacy/export-data` | 导出个人数据 | `?format=json/csv` |
| PUT | `/privacy/revoke-auth` | 撤销第三方授权 | `{appId}` |
| DELETE | `/privacy/account` | 注销账号(需二次验证) | `{password, code}` |

##### AI助手模块 `/api/v1/ai`

| 方法 | 路径 | 描述 | 参数 |
|------|------|------|------|
| POST | `/ai/chat` | 对话接口 | `{message, context}` |
| GET | `/ai/intents` | 获取支持的意图列表 | - |
| POST | `/ai/feedback` | 反馈对话质量 | `{chatId, rating, comment}` |

---

### 4.3 后端阶段二：核心业务逻辑实现（P0）

#### 用户认证服务

```javascript
// Node.js + Express 实现
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const crypto = require('crypto');

class AuthService {
  /**
   * 用户登录
   */
  async login(phone, password) {
    const user = await User.findOne({ where: { phone } });
    
    if (!user) {
      throw new Error('USER_NOT_FOUND');
    }
    
    const isValid = await bcrypt.compare(password, user.password);
    if (!isValid) {
      throw new Error('INVALID_PASSWORD');
    }
    
    // 生成JWT Token
    const token = jwt.sign(
      { userId: user.id, phone: user.phone },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );
    
    const refreshToken = jwt.sign(
      { userId: user.id, type: 'refresh' },
      process.env.JWT_REFRESH_SECRET,
      { expiresIn: '30d' }
    );
    
    // 记录登录日志
    await OperationLog.create({
      userId: user.id,
      action: 'login',
      ipAddress: req.ip,
      userAgent: req.headers['user-agent']
    });
    
    return {
      token,
      refreshToken,
      user: this.sanitizeUser(user)
    };
  }

  /**
   * 注册新用户
   */
  async register(phone, password, smsCode) {
    // 验证短信验证码
    await this.verifySmsCode(phone, smsCode);
    
    // 检查手机号是否已注册
    const existingUser = await User.findOne({ where: { phone } });
    if (existingUser) {
      throw new Error('PHONE_ALREADY_EXISTS');
    }
    
    // 密码加密
    const hashedPassword = await bcrypt.hash(password, 10);
    
    // 创建用户
    const user = await User.create({
      phone,
      password: hashedPassword,
      nickname: `星云用户${Math.floor(Math.random() * 10000)}`
    });
    
    return this.login(phone, password);
  }

  /**
   * JWT中间件 - 鉴权
   */
  authenticate(req, res, next) {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ code: 401, message: '未登录或Token已过期' });
    }
    
    const token = authHeader.substring(7);
    
    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      req.user = decoded;
      next();
    } catch (err) {
      return res.status(401).json({ code: 401, message: 'Token无效或已过期' });
    }
  }
}
```

#### 健康数据服务

```javascript
class HealthService {
  /**
   * 创建健康记录
   */
  async createRecord(userId, recordData) {
    const { type, value, unit, measuredAt, notes, source, deviceId } = recordData;
    
    // 数据校验
    this.validateRecord(type, value, unit);
    
    const record = await HealthRecord.create({
      userId,
      type,
      value,
      unit,
      measuredAt: new Date(measuredAt),
      notes,
      source: source || 'manual',
      deviceId
    });
    
    // 异步触发数据分析（可选）
    this.analyzeHealthTrend(userId, type);
    
    return record;
  }

  /**
   * 获取健康统计数据
   */
  async getStatistics(userId, params) {
    const { type, range = '7d' } = params;
    
    const endDate = new Date();
    const startDate = this.getStartDate(range);
    
    const records = await HealthRecord.findAll({
      where: {
        userId,
        type,
        measuredAt: { [Op.between]: [startDate, endDate] }
      },
      order: [['measuredAt', 'ASC']]
    });
    
    if (records.length === 0) {
      return null;
    }
    
    // 计算统计指标
    const values = records.map(r => this.parseValue(r.value, r.type));
    
    return {
      count: records.length,
      latest: records[records.length - 1],
      average: this.calculateAverage(values),
      max: Math.max(...values),
      min: Math.min(...values),
      trend: this.calculateTrend(values),  // up/down/stable
      normalRange: this.getNormalRange(type),
      abnormalCount: this.countAbnormal(records, type)
    };
  }

  /**
   * 获取趋势数据（用于图表展示）
   */
  async getTrendData(userId, params) {
    const { type, period = '7d' } = params;
    
    const records = await HealthRecord.findAll({
      where: { userId, type },
      order: [['measuredAt', 'ASC']],
      limit: 90  // 最多取90天数据
    });
    
    // 按日期聚合
    const groupedByDate = _.groupBy(records, r => 
      moment(r.measuredAt).format('YYYY-MM-DD')
    );
    
    return Object.entries(groupedByDate).map(([date, dayRecords]) => ({
      date,
      value: this.parseValue(dayRecords[dayRecords.length - 1].value, type),
      count: dayRecords.length,
      average: this.calculateAverage(dayRecords.map(r => this.parseValue(r.value, type)))
    }));
  }

  /**
   * 解析复合数值（如血压 120/80）
   */
  parseValue(value, type) {
    if (type === 'blood_pressure') {
      const [systolic, diastolic] = value.split('/').map(Number);
      return systolic;  // 返回收缩压作为主值
    }
    return parseFloat(value);
  }
}
```

#### 预约管理服务

```javascript
class AppointmentService {
  /**
   * 创建预约
   */
  async createAppointment(userId, appointmentData) {
    const { doctorId, hospitalId, department, aptDate, aptTime, notes } = appointmentData;
    
    // 检查医生是否存在且可预约
    const doctor = await Doctor.findByPk(doctorId);
    if (!doctor || !doctor.isAvailable) {
      throw new Error('DOCTOR_NOT_AVAILABLE');
    }
    
    // 检查时间段是否已被预约
    const conflict = await Appointment.findOne({
      where: {
        doctorId,
        aptDate,
        aptTime,
        status: { [Op.in]: ['pending', 'confirmed'] }
      }
    });
    
    if (conflict) {
      throw new Error('TIME_SLOT_OCCUPIED');
    }
    
    // 生成排队号
    const queueNumber = await this.generateQueueNumber(doctorId, aptDate);
    
    // 计算费用
    const fee = doctor.consultationFee || 0;
    
    const appointment = await Appointment.create({
      userId,
      doctorId,
      hospitalId,
      department,
      aptDate,
      aptTime,
      status: 'pending',
      queueNumber,
      location: `${hospital.name} ${department} 诊室`,
      notes,
      fee
    });
    
    // 创建定时提醒任务（提前1天）
    this.scheduleReminder(appointment.id, aptDate, userId);
    
    return appointment;
  }

  /**
   * 取消预约
   */
  async cancelAppointment(appointmentId, userId) {
    const appointment = await Appointment.findOne({
      where: { id: appointmentId, userId }
    });
    
    if (!appointment) {
      throw new Error('APPOINTMENT_NOT_FOUND');
    }
    
    if (!['pending', 'confirmed'].includes(appointment.status)) {
      throw new Error('CANNOT_CANCEL');
    }
    
    await appointment.update({ status: 'cancelled' });
    
    // 发送取消通知
    await NotifyService.send(userId, {
      type: 'appointment_cancelled',
      title: '预约已取消',
      content: `您${appointment.aptDate} ${appointment.aptTime} 的预约已成功取消`
    });
    
    return appointment;
  }

  /**
   * 查询可预约时段
   */
  async getAvailableSlots(doctorId, date) {
    const doctor = await Doctor.findByPk(doctorId);
    const schedule = doctor.schedule;  // {"Monday": ["09:00","09:30",...], ...}
    
    const dayOfWeek = moment(date).format('dddd');  // Monday/Tuesday...
    const timeSlots = schedule[dayOfWeek] || [];
    
    // 过滤掉已预约的时间段
    const bookedSlots = await Appointment.findAll({
      where: {
        doctorId,
        aptDate: date,
        status: { [Op.in]: ['pending', 'confirmed'] }
      },
      attributes: ['aptTime']
    });
    
    const bookedTimes = bookedSlots.map(a => a.aptTime);
    
    return timeSlots.filter(slot => !bookedTimes.includes(slot)).map(slot => ({
      time: slot,
      available: true
    }));
  }
}
```

#### 设备数据同步服务（WebSocket）

```javascript
const WebSocket = require('ws');

class DeviceSyncService {
  constructor() {
    this.connections = new Map();  // deviceId -> ws connection
  }

  /**
   * 处理设备连接
   */
  handleConnection(ws, deviceId) {
    console.log(`设备 ${deviceId} 已连接`);
    
    this.connections.set(deviceId, ws);
    
    // 发送连接确认
    ws.send(JSON.stringify({
      type: 'connected',
      deviceId,
      timestamp: Date.now()
    }));
    
    ws.on('message', (data) => {
      this.handleDeviceMessage(deviceId, data);
    });
    
    ws.on('close', () => {
      console.log(`设备 ${deviceId} 断开连接`);
      this.connections.delete(deviceId);
      this.markDeviceOffline(deviceId);
    });
  }

  /**
   * 处理设备上报的数据
   */
  async handleDeviceMessage(deviceId, rawData) {
    try {
      const message = JSON.parse(rawData);
      
      switch (message.type) {
        case 'health_data':
          await this.saveHealthData(deviceId, message.payload);
          break;
          
        case 'battery_status':
          await this.updateBattery(deviceId, message.level);
          break;
          
        case 'heartbeat':
          await this.updateHeartbeat(deviceId);
          break;
          
        default:
          console.warn('未知消息类型:', message.type);
      }
    } catch (err) {
      console.error('解析设备消息失败:', err);
    }
  }

  /**
   * 保存设备上报的健康数据
   */
  async saveHealthData(deviceId, payload) {
    const device = await Device.findByPk(deviceId);
    
    const record = await HealthRecord.create({
      userId: device.userId,
      type: payload.type,        // blood_pressure, heart_rate, etc.
      value: payload.value,
      unit: payload.unit,
      measuredAt: new Date(payload.timestamp),
      source: 'device_import',
      deviceId: device.id
    });
    
    // 实时推送给APP端
    this.pushToUserApp(device.userId, {
      type: 'new_health_data',
      data: record
    });
    
    // 更新设备最后数据时间
    await device.update({ lastDataAt: new Date() });
    
    return record;
  }

  /**
   * 向用户APP推送实时数据
   */
  pushToUserApp(userId, message) {
    // 这里需要维护用户的WebSocket连接
    // 或者通过消息队列异步推送
    console.log(`推送数据给用户 ${userId}:`, message);
  }
}
```

---

### 4.4 后端阶段三：高级功能实现（P1-P2）

#### AI对话服务（规则引擎 + LLM混合）

```javascript
class AIService {
  /**
   * 主对话入口
   */
  async chat(userId, message, context = []) {
    // 1. 意图识别
    const intent = await this.recognizeIntent(message);
    
    // 2. 根据意图分发处理
    switch (intent.type) {
      case 'health_inquiry':
        return await this.handleHealthInquiry(intent.entities, userId);
        
      case 'medication_query':
        return await this.handleMedicationQuery(intent.entities, userId);
        
      case 'appointment_help':
        return await this.handleAppointmentHelp(intent.entities, userId);
        
      case 'emergency':
        return await this.handleEmergency(userId);
        
      case 'general_chat':
        // 调用LLM API（如通义千问/文心一言）
        return await this.callLLM(message, context);
        
      default:
        return this.fallbackResponse();
    }
  }

  /**
   * 意图识别（基于关键词+正则）
   */
  recognizeIntent(message) {
    const msg = message.toLowerCase();
    
    // 紧急情况检测（最高优先级）
    if (/救命|难受|晕|胸痛|呼吸困难|不行了/.test(msg)) {
      return { type: 'emergency', confidence: 0.95 };
    }
    
    // 健康咨询
    if (/血压|血糖|心率|体温|体重|身体|不舒服|症状/.test(msg)) {
      const entities = this.extractEntities(msg);
      return { type: 'health_inquiry', entities, confidence: 0.85 };
    }
    
    // 用药查询
    if (/药|怎么吃|用法|剂量|阿莫西林|布洛芬|降压/.test(msg)) {
      const drugName = this.extractDrugName(msg);
      return { type: 'medication_query', entities: { drugName }, confidence: 0.9 };
    }
    
    // 预约相关
    if (/挂号|预约|看医生|门诊|专家/.test(msg)) {
      const dept = this.extractDepartment(msg);
      return { type: 'appointment_help', entities: { department: dept }, confidence: 0.85 };
    }
    
    return { type: 'general_chat', confidence: 0.3 };
  }

  /**
   * 处理健康咨询
   */
  async handleHealthInquiry(entities, userId) {
    const { indicator } = entities;  // 血压/血糖等
    
    // 查询用户最近的健康数据
    const recentRecords = await HealthRecord.findAll({
      where: { userId, type: indicator },
      order: [['measuredAt', 'DESC']],
      limit: 7
    });
    
    if (recentRecords.length === 0) {
      return {
        text: `暂未找到您的${indicator}记录。建议先进行一次测量，我可以帮您分析健康状况。`,
        suggestions: [
          { action: 'navigate', label: '去记录', url: '/pages/HealthRecords' }
        ]
      };
    }
    
    const latest = recentRecords[0];
    const analysis = this.analyzeIndicator(indicator, latest.value);
    
    return {
      text: `根据您最近的${indicator}数据(${latest.value}${latest.unit})：
            
            ${analysis.description}
            
            建议：${analysis.advice}`,
      data: {
        currentValue: latest.value,
        status: analysis.status,
        trend: analysis.trend
      },
      suggestions: [
