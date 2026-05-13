# 🧪 AI功能页面测试完整指南（一步一步操作版）

> **版本**: v1.0  
> **更新日期**: 2026-05-13  
> **适用项目**: harmony-health-care (HMOS6.0)  
> **前置条件**: ✅ ArkTS编译错误已修复  
> **预计耗时**: 30-60分钟（含所有测试）

---

## 📋 目录

1. [准备工作](#1️⃣-准备工作)
2. [方法一：使用AITestPage快速测试](#2️⃣-方法一使用aitestpage快速测试推荐新手)
3. [方法二：使用AiChatPage交互式对话测试](#3️⃣-方法二使用aichatpage交互式对话测试推荐体验)
4. [方法三：在任意页面添加测试按钮](#4️⃣-方法三在任意页面添加测试按钮适合开发者)
5. [方法四：测试图像分析功能（HiAI）](#5️⃣-方法四测试图像分析功能hiai)
6. [各智能体详细测试用例](#6️⃣-各智能体详细测试用例)
7. [预期结果检查清单](#7️⃣-预期结果检查清单)
8. [常见问题与故障排查](#8️⃣-常见问题与故障排查)
9. [进阶：性能监控与日志分析](#9️⃣-进阶性能监控与日志分析)

---

## 1️⃣ 准备工作

### 1.1 确认编译通过 ✅

**操作步骤**：
```
1. 打开 DevEco Studio
2. 打开项目: harmony-health-care
3. 菜单栏: Build → Rebuild Project (或 Ctrl+F9)
4. 等待编译完成（预计30秒-2分钟）
5. 查看底部 "Build" 输出窗口
```

**预期结果**：
- ✅ 显示 `BUILD SUCCESSFUL`
- ❌ 如果显示 `BUILD FAILED`，请先查看[错误日志.txt](错误日志.txt)并修复

### 1.2 启动模拟器/真机

**操作步骤**：
```
方式A - 使用模拟器（推荐测试）:
1. 工具栏 → 选择模拟器设备（如 API 22 Phone）
2. 点击 ▶ 运行按钮
3. 等待模拟器启动和应用安装

方式B - 使用真机（推荐最终验证）:
1. 用USB连接华为手机（Mate 60系列最佳）
2. 手机开启 USB调试 + 开发者模式
3. DevEco Studio 会自动识别设备
4. 点击 ▶ 运行
```

**预期结果**：
- ✅ 应用成功安装并启动
- ✅ 显示登录页或主页（取决于你的配置）

### 1.3 确认AI模块加载

**操作步骤**：
```
1. 应用启动后，打开 Logcat/Hilog 日志窗口
2. 过滤关键词: AIOrchestrator 或 [AI]
3. 查看是否有以下输出：
```

**预期日志**：
```
[AIOrchestrator] 初始化完成，已加载 X 个智能体
```

**如果没看到此日志**：
- 说明AI模块可能未正确初始化，继续下面的测试会触发懒加载

---

## 2️⃣ 方法一：使用AITestPage快速测试（推荐新手）

### 📍 页面位置
- **文件路径**: [entry/src/main/ets/pages/AITestPage.ets](entry/src/main/ets/pages/AITestPage.ets)
- **路由位置**: main_pages.json 第157行
- **访问路径**: 需要通过代码跳转（非主流程页面）

### 🔧 步骤1：添加入口按钮到首页

**目标文件**: [Index.ets](entry/src/main/ets/pages/Index.ets) 或 [HomePage.ets](entry/src/main/ets/pages/HomePage.ets)

**操作**：在页面的 build() 方法中添加一个测试按钮：

```typescript
// 在 Column 的末尾、build() 的 return 前添加
Button('🧪 AI功能测试')
  .width('100%')
  .height(50)
  .fontSize(18)
  .backgroundColor('#2196F3')
  .margin({ top: 20 })
  .onClick(() => {
    router.pushUrl({
      url: 'pages/AITestPage'
    }).catch((err: Error) => {
      console.error('跳转失败:', err.message);
    });
  })
```

**保存后重新运行应用**。

### 🔧 步骤2：进入AITestPage

**操作**：
```
1. 在首页点击 "🧪 AI功能测试" 按钮
2. 进入AI测试页面
3. 你会看到4个测试按钮 + 1个"运行全部测试"按钮
```

**界面预览**：
```
┌─────────────────────────────────────┐
│     🤖 AI智能体集成测试              │
│                                     │
│  [测试小艺]  [测试DeepSeek]         │
│                                     │
│  [测试Coze]   [测试HiAI]            │
│                                     │
│  [运行全部测试]                      │
│                                     │
│  ───────────────────────────────    │
│  📋 测试日志:                        │
│  > 🤖 AI测试页面已加载               │
│  > 📦 智能体数量: 4                  │
└─────────────────────────────────────┘
```

### 🔧 步骤3：逐个测试智能体

#### 测试1️⃣：小艺智能体（XiaoyiAgent）

**点击按钮**: `[测试小艺]`

**测试请求内容**：
```
帮我挂号张医生明天上午
```

**预期结果**（2秒内显示）：
```
✅ 测试通过!
⏱️ 响应时间: <500ms (通常 100-300ms)
🤖 处理智能体: xiaoyi
📝 回复内容:
   好的，我来帮您预约张医生。
   已为您打开预约页面...
```

**验证要点**：
- ✅ 响应时间 < 500ms（本地处理，无需网络）
- ✅ agentId = 'xiaoyi'
- ✅ 回复包含预约相关信息

---

#### 测试2️⃣：DeepSeek大模型

**点击按钮**: `[测试DeepSeek]`

**测试请求内容**：
```
高血压患者平时饮食要注意什么？
```

**预期结果**（3-10秒内显示）：
```
✅ 测试通过!
⏱️ 响应时间: 1000-3000ms
🤖 处理智能体: deepseek
📝 回复内容:
   高血压患者的饮食管理非常重要...
   1. 低盐饮食...
   2. 控制油脂摄入...
   （200-500字的专业健康建议）
```

**验证要点**：
- ⏳ 响应时间 1-3s（需要网络调用API）
- ✅ agentId = 'deepseek'
- ✅ 回复内容专业且长度合理（>100字）
- ✅ 无乱码或截断

**如果失败**：
- ❌ 检查网络连接
- ❌ 查看API Key是否有效（见第8章故障排查）

---

#### 测试3️⃣：Coze智能体

**点击按钮**: `[测试Coze]`

**测试请求内容**：
```
血压高怎么办？
```

**预期结果**（3-10秒内显示）：
```
✅ 测试通过!
⏱️ 响应时间: 1000-5000ms
🤖 处理智能体: coze
📝 回复内容:
   血压升高时建议您采取以下措施...
   （结构化的医疗建议）
```

**验证要点**：
- ⏳ 响应时间 1-5s
- ✅ agentId = 'coze'
- ✅ 回复包含具体建议

**注意**：Coze需要在平台配置Bot，如果未配置可能会降级或报错

---

#### 测试4️⃣：HiAI视觉识别

**点击按钮**: `[测试HiAI]`

**测试请求内容**：
```
识别这张医疗图片
```

**预期结果**：
```
⚠️ 可能的结果:

情况A（框架代码）:
✅ 测试通过!
🤖 处理智能体: hiai
📝 HiAI视觉识别引擎初始化完成（模拟模式）

情况B（未实现）:
❌ 测试失败: HiAI功能待完善
（这是正常的，因为HiAI需要真机+NPU）
```

**说明**：
- HiAI目前是**模拟实现**
- 真正的NPU加速需要：
  - Mate 60系列真机
  - .om格式模型文件
  - @kit.CoreAIKit 权限

---

### 🔧 步骤4：运行全部测试

**点击按钮**: `[运行全部测试]`

**预期流程**：
```
🧪 开始测试: 1/4 XiaoyiAgent
⏳ 请求内容: 帮我挂号张医生明天上午
✅ 测试通过!
⏱️ 响应时间: xxxms
🤖 处理智能体: xiaoyi

(等待0.5秒)

🧪 开始测试: 2/4 DeepSeekAgent
⏳ 请求内容: 高血压患者平时饮食要注意什么？
✅ 测试通过!
...

🎉 全部测试完成!
```

**总耗时**：约 10-30秒（取决于网络速度）

---

## 3️⃣ 方法二：使用AiChatPage交互式对话测试（推荐体验）

### 📍 页面位置
- **文件路径**: [entry/src/main/ets/pages/AiChatPage.ets](entry/src/main/ets/pages/AiChatPage.ets)
- **路由位置**: main_pages.json 第42行
- **状态**: ✅ 已集成AIOrchestrator

### 🔧 步骤1：进入AiChatPage

**方式A - 从主菜单进入**（如果有入口）：
```
查找菜单中的 "AI助手"、"AI咨询"、"智能问诊" 等选项
```

**方式B - 代码跳转**（如果没有入口）：
在任意页面添加按钮：
```typescript
Button('💬 AI聊天测试')
  .onClick(() => {
    router.pushUrl({ url: 'pages/AiChatPage' });
  })
```

### 🔧 步骤2：使用预设问题测试

进入页面后，你会看到 **6个预设问题按钮**：

| 序号 | 问题 | 测试能力 | 预期响应 |
|------|------|---------|---------|
| 1 | 血压多少算正常? | DeepSeek医学知识 | 专业解释+正常范围 |
| 2 | 老年人如何预防糖尿病? | DeepSeek预防建议 | 生活习惯+筛查建议 |
| 3 | 每天应该运动多久? | DeepSeek运动指导 | 时间+强度+类型 |
| 4 | 失眠怎么办? | DeepSeek心理健康 | 原因+解决方案 |
| 5 | 如何保持心脏健康? | DeepSeek心血管 | 饮食+运动+监测 |
| 6 | 饮食上有什么注意事项? | DeepSeek营养建议 | 营养素+食物选择 |

**操作**：
```
1. 点击任意一个问题按钮
2. 等待AI回复（1-3秒）
3. 查看回复质量
4. 继续追问测试多轮对话
```

### 🔧 步骤3：自由对话测试

**输入框测试用例**：

**测试1 - 症状咨询**：
```
输入: 我最近总是头晕，可能是什么原因？
预期: 
- 分析可能原因（高血压、颈椎病、贫血等）
- 建议就医检查
- 给出生活建议
- 字数: 200-400字
```

**测试2 - 用药咨询**：
```
输入: 阿司匹林和布洛芬能一起吃吗？
预期:
- 明确回答能/不能/需谨慎
- 说明药物相互作用
- 建议咨询医生
- 包含免责声明
```

**测试3 - 多轮对话**：
```
第一轮:
用户: 高血压患者能吃鸡蛋吗？
AI: 可以适量食用，建议每天1个...

第二轮:
用户: 那牛奶呢？
AI: 牛奶也是可以的，低脂或脱脂更好...（应结合上下文）

第三轮:
用户: 还有其他推荐的食物吗？
AI: 除了鸡蛋和牛奶，还推荐...（继续上下文）
```

**验证要点**：
- ✅ 能理解上下文（提到"除了鸡蛋和牛奶"）
- ✅ 回复连贯自然
- ✅ 无重复或矛盾信息

---

## 4️⃣ 方法三：在任意页面添加测试按钮（适合开发者）

### 适用场景
- 需要在特定业务逻辑中集成AI
- 想快速验证某个智能体的效果
- 开发调试阶段

### 🔧 步骤1：选择要添加的页面

**推荐的测试页面**：
- [Index.ets](entry/src/main/ets/pages/Index.ets) - 主页（最方便）
- [HomePage.ets](entry/src/main/ets/pages/HomePage.ets) - 家庭端主页
- [TestPage.ets](entry/src/main/ets/pages/TestPage.ets) - 专用测试页

### 🔧 步骤2：添加完整测试代码

在选中页面的 `build()` 方法中添加：

```typescript
import { AIOrchestrator } from '../ai/orchestrator/AIOrchestrator';

@Entry
@Component
struct YourTestPage {
  private orchestrator = AIOrchestrator.getInstance();
  @State testOutput: string = '';

  build() {
    Column() {
      // ... 原有UI ...
      
      // ====== AI测试区域开始 ======
      Text('🤖 AI功能测试面板')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20, bottom: 15 })

      Row({ space: 10 }) {
        Button('小艺')
          .onClick(async () => await this.testXiaoyi())
        
        Button('DeepSeek')
          .onClick(async () => await this.testDeepSeek())
        
        Button('Coze')
          .onClick(async () => await this.testCoze())
      }
      .margin({ bottom: 10 })

      Button('一键测试全部')
        .width('100%')
        .backgroundColor('#4CAF50')
        .onClick(async () => await this.testAll())
      
      if (this.testOutput) {
        Text(this.testOutput)
          .fontSize(14)
          .fontFamily('monospace')
          .width('100%')
          .maxLines(20)
          .backgroundColor('#F5F5F5')
          .padding(10)
          .borderRadius(8)
          .margin({ top: 10 })
      }
      
      Button('清空输出')
        .onClick(() => { this.testOutput = ''; })
        .margin({ top: 5 })
      // ====== AI测试区域结束 ======
    }
  }

  async testXiaoyi(): Promise<void> {
    try {
      const response = await this.orchestrator.process({
        requestId: 'test-' + Date.now(),
        userId: 'dev-test',
        input: { type: 'text', content: '导航去内科' }
      });
      this.testOutput = `✅ 小艺测试成功\n` +
        `智能体: ${response.agentId}\n` +
        `响应: ${response.output.content}\n` +
        `耗时: ${response.metadata.processingTime}ms`;
    } catch (e) {
      this.testOutput = `❌ 小艺测试失败: ${e}`;
    }
  }

  async testDeepSeek(): Promise<void> {
    try {
      const startTime = Date.now();
      const response = await this.orchestrator.process({
        requestId: 'test-' + Date.now(),
        userId: 'dev-test',
        input: { type: 'text', content: '糖尿病早期症状有哪些？' },
        preferences: { preferredAgent: 'deepseek' }
      });
      const endTime = Date.now();
      this.testOutput = `✅ DeepSeek测试成功\n` +
        `智能体: ${response.agentId}\n` +
        `响应时间: ${endTime - startTime}ms\n` +
        `回复:\n${response.output.content}`;
    } catch (e) {
      this.testOutput = `❌ DeepSeek测试失败: ${e}`;
    }
  }

  async testCoze(): Promise<void> {
    try {
      const response = await this.orchestrator.process({
        requestId: 'test-' + Date.now(),
        userId: 'dev-test',
        input: { type: 'text', content: '感冒了吃什么药好？' },
        preferences: { preferredAgent: 'coze' }
      });
      this.testOutput = `✅ Coze测试成功\n` +
        `智能体: ${response.agentId}\n` +
        `回复: ${response.output.content}`;
    } catch (e) {
      this.testOutput = `❌ Coze测试失败: ${e}`;
    }
  }

  async testAll(): Promise<void> {
    this.testOutput = '🚀 开始全量测试...\n\n';
    
    await this.testXiaoyi();
    this.testOutput += '\n---\n\n';
    
    await new Promise(resolve => setTimeout(resolve, 1000));
    await this.testDeepSeek();
    this.testOutput += '\n---\n\n';
    
    await new Promise(resolve => setTimeout(resolve, 1000));
    await this.testCoze();
    this.testOutput += '\n\n🎉 全部测试完成!';
  }
}
```

### 🔧 步骤3：运行并测试

```
1. 保存文件（Ctrl+S）
2. DevEco Studio 会热重载（或手动重新运行）
3. 找到新增的测试按钮区域
4. 依次点击各个按钮
5. 查看下方输出的测试结果
```

---

## 5️⃣ 方法四：测试图像分析功能（HiAI）

### 📍 页面位置
- **文件路径**: [entry/src/main/ets/pages/ImageAnalysisPage.ets](entry/src/main/ets/pages/ImageAnalysisPage.ets)
- **路由位置**: main_pages.json 第44行
- **状态**: ✅ 刚修复完ArkTS编译错误

### 🔧 步骤1：进入图像分析页面

**添加入口按钮**：
```typescript
Button('🔬 医学影像AI分析')
  .onClick(() => {
    router.pushUrl({ url: 'pages/ImageAnalysisPage' });
  })
```

### 🔧 步骤2：上传/选择测试图片

**支持的图片类型**：
- 胸部X光片
- 骨骼X光片
- 皮肤照片
- 眼底照片
- 乳腺超声图

**操作流程**：
```
1. 点击 "选择图片" 或 "拍摄影像"
2. 从相册选择示例图片（或使用内置示例图）
3. 点击 "开始AI分析"
4. 观察4步向导流程：
   Step 1: 上传/拍摄影像
   Step 2: AI分析中（进度条动画）
   Step 3: 查看结果
   Step 4: 病灶详情
```

### 🔧 步骤3：观察AI分析过程

**控制台日志**（过滤关键词: ImageAnalysis 或 HiAI）：
```
[ImageAnalysis] 开始AI分析流程...
[ImageAnalysis] 正在加载影像... (10%)
[ImageAnalysis] 正在识别影像类型... (15%)
[ImageAnalysis] HiAI分类结果: {"label":"胸部X光","confidence":0.95}
[ImageAnalysis] 影像类型识别完成: 胸部X光 (25%)
[ImageAnalysis] 正在进行AI病灶检测... (30%)
[ImageAnalysis] 正在运行深度学习模型... (45%)
[ImageAnalysis] 发现可疑病灶，正在分析... (55%) 或 未发现明显异常 (55%)
[ImageAnalysis] 正在生成详细报告... (65%)
[ImageAnalysis] 正在调用DeepSeek生成诊断建议... (75%)
[ImageAnalysis] 分析完成! (100%)
```

### 🔧 步骤4：查看分析报告

**正常情况报告**：
```
✅ 胸部X光检查未见明显异常，影像质量良好

【检查结果】
✅ 未发现明显病灶或异常改变
✅ 影像质量符合诊断要求
✅ 各项指标在正常范围内

【健康建议】
1.继续保持健康的生活方式
2. 建议每年进行1次例行体检
...

⚠️ 免责声明：本结果为AI辅助分析...
```

**异常情况报告**（35%概率触发）：
```
⚠️ HiAI识别为胸部X光，检测到1-3处可疑改变，建议进一步检查

【检测结果】
• 病灶1: 肺结节 (置信度: XX%, 风险: 中/高)
  - 位置: 右肺上叶
  - 大小: XXmm × XXmm
  
【总体评估】
风险等级: 中等/高
建议: 携带原始影像咨询专科医生
```

### 🔧 步骤5：测试不同场景

**多次测试以观察不同结果**：
```
测试1: 选择胸部X光图 → 可能为正常或异常
测试2: 选择皮肤照片 → 检测皮肤病变
测试3: 选择眼底照片 → 检测视网膜病变

每次分析结果会有随机性（模拟真实场景）
```

---

## 6️⃣ 各智能体详细测试用例

### 6.1 🎤 XiaoyiAgent 完整测试矩阵

| # | 测试输入 | 预期意图 | 预期响应类型 | 响应时间 |
|---|---------|---------|------------|---------|
| 1 | `帮我挂号张医生明天上午` | appointment_booking | 结构化指令 | <300ms |
| 2 | `预约下周三下午李医生的门诊` | appointment_booking | 结构化指令 | <300ms |
| 3 | `导航去内科` | navigation | AR启动指令 | <200ms |
| 4 | `打开AR导航到药房` | navigation | AR启动指令 | <200ms |
| 5 | `救命！我不舒服` | emergency | SOS紧急响应 | <150ms |
| 6 | `紧急呼叫120` | emergency | SOS紧急响应 | <150ms |
| 7 | `查一下我的血压` | health_query | 数据查询 | <250ms |
| 8 | `提醒我早上吃药` | medication_reminder | 提醒设置 | <250ms |
| 9 | `开始康复训练` | rehab_training | 训练启动 | <300ms |

**批量测试脚本**（可在 AITestPage 的"运行全部测试"中添加）：

```typescript
async testXiaoyiBatch(): Promise<void> {
  const testCases = [
    '帮我挂号张医生明天上午',
    '导航去内科',
    '救命！我不舒服',
    '查一下我的血压数据',
    '提醒我8点吃药'
  ];
  
  for (let i = 0; i < testCases.length; i++) {
    await this.runTest(`小艺批量 ${i+1}/${testCases.length}`, {
      requestId: `xiaoyi-batch-${i}`,
      userId: 'batch-test',
      input: { type: 'text', content: testCases[i] }
    });
    await new Promise(resolve => setTimeout(resolve, 300));
  }
}
```

---

### 6.2 🧠 DeepSeekAgent 完整测试矩阵

| # | 测试场景 | 输入示例 | 预期输出特征 | Token消耗估算 |
|---|---------|---------|------------|-------------|
| 1 | **症状分析** | `我最近总是头晕，可能是什么原因？` | 多种可能原因列表+建议检查项 | 300-500 |
| 2 | **用药咨询** | `阿司匹林和布洛芬能一起吃吗？` | 相互作用分析+明确结论 | 200-400 |
| 3 | **慢性病管理** | `糖尿病患者饮食要注意什么？` | 分类建议（碳水/蛋白质/脂肪） | 400-600 |
| 4 | **康复方案** | `膝关节手术后如何康复？` | 分阶段计划（早/中/晚期） | 500-800 |
| 5 | **体检报告解读** | `甘油三酯2.3算高吗？` | 数值解释+正常范围+建议 | 200-350 |
| 6 | **预防保健** | `老年人如何预防跌倒？` | 环境改造+运动+用药审查 | 400-600 |
| 7 | **心理健康** | `失眠怎么办？有哪些非药物方法？` | 认知行为+放松技巧+作息调整 | 350-550 |
| 8 | **营养咨询** | `高血压患者能吃鸡蛋吗？` | 明确回答+数量建议+烹饪方式 | 250-400 |
| 9 | **运动指导** | `心脏病患者适合什么运动？` | 类型+强度+频率+禁忌 | 400-600 |
| 10| **急救知识** | `家人突然晕倒该怎么办？` | 分步骤急救流程+何时叫救护车 | 450-700 |

**高级测试 - 多轮对话上下文**：

```typescript
async testDeepSeekMultiTurn(): Promise<void> {
  const orchestrator = AIOrchestrator.getInstance();
  const userId = 'multi-turn-test';
  
  // 第一轮
  const r1 = await orchestrator.process({
    requestId: 'mt-1',
    userId,
    input: { type: 'text', content: '我有高血压，能喝咖啡吗？' },
    preferences: { preferredAgent: 'deepseek' }
  });
  console.log('第1轮:', r1.output.content);
  
  // 第二轮（测试上下文理解）
  const r2 = await orchestrator.process({
    requestId: 'mt-2',
    userId,
    input: { type: 'text', content: '那茶呢？绿茶可以吗？' },
    conversationHistory: [
      { role: 'user', content: '我有高血压，能喝咖啡吗？', timestamp: Date.now()-5000 },
      { role: 'assistant', content: r1.output.content as string, timestamp: Date.now()-4000, agentId: 'deepseek' }
    ],
    preferences: { preferredAgent: 'deepseek' }
  });
  console.log('第2轮:', r2.output.content);
  
  // 验证：回复中应提及"咖啡"或"刚才提到的"，证明理解上下文
}
```

---

### 6.3 🤖 CozeAgent 测试用例

| # | 测试输入 | 工作流 | 预期行为 |
|---|---------|-------|---------|
| 1 | `血压高怎么办？` | Medical_Consult_Routing | 自动路由到心血管专家 |
| 2 | `眼睛干涩是什么原因？` | Medical_Consult_Routing | 路由到眼科专家 |
| 3 | `帮我规划今天的就医流程` | 预问诊流程 | 引导式症状采集 |
| 4 | `阿司匹林的副作用` | 知识库检索 | 结构化药品信息 |

**注意**：Coze需要在[Coze平台](https://www.coze.cn)配置好Bot和工作流才能正常使用。

---

### 6.4 👁️ HiAI Vision 测试用例

**当前状态**：模拟实现（Mock数据）

**测试方法**：通过 ImageAnalysisPage 进行

**测试输入**：任意图片文件

**预期行为**：
1. 调用 `hiAIVisionClient.classifyImage()` 
2. 返回模拟的分类结果（胸部X光/头部CT/膝关节MRI等）
3. 后续流程正常执行

**未来真机测试**（需要Mate 60 + NPU）：
```typescript
// 真实HiAI调用示例（当前为模拟）
const result = await hiAIVisionClient.classifyImage(imageUri);
console.log('真实分类:', result.label);           // 如 "胸部X光"
console.log('置信度:', result.confidence);          // 如 0.95
console.log('所有候选:', result.allResults);        // 所有可能的分类
```

---

## 7️⃣ 预期结果检查清单

### ✅ 基础功能检查

- [ ] **编译通过**：无ArkTS错误
- [ ] **应用启动**：无崩溃、无白屏
- [ ] **AI模块加载**：日志显示初始化成功
- [ ] **页面跳转**：能正常进入测试页面

### ✅ 小艺智能体检查

- [ ] **响应时间**：<500ms（通常100-300ms）
- [ ] **离线可用**：断网状态下仍可工作
- [ ] **意图识别**：能正确识别9种意图
- [ ] **实体提取**：能提取医生名、时间、科室等
- [ ] **紧急处理**：SOS响应<200ms

### ✅ DeepSeek检查

- [ ] **API连通**：能成功调用硅基流动API
- [ ] **响应时间**：1-3秒（网络正常时）
- [ ] **回复质量**：内容专业、结构清晰、无乱码
- [ ] **Token统计**：metadata.tokensUsed 有值
- [ ] **多轮对话**：能维护上下文
- [ ] **错误处理**：API失败时优雅降级

### ✅ Coze检查（如已配置）

- [ ] **Bot连接**：能调用Coze Bot
- [ ] **工作流执行**：Medical_Consult_Routing 正常运行
- [ ] **超时处理**：30秒超时不卡死

### ✅ HiAI检查

- [ ] **客户端初始化**：HiAIVisionClient 初始化成功
- [ ] **分类接口**：classifyImage() 返回结果
- [ ] **ImageAnalysisPage**：完整的4步流程可走通
- [ ] **报告生成**：正常/异常报告都能生成

### ✅ 性能指标汇总

| 智能体 | 目标延迟 | 你的实测 | 是否达标 |
|--------|---------|----------|---------|
| 小艺 | <500ms | ___ms | ☐ |
| DeepSeek | <3000ms | ___ms | ☐ |
| Coze | <5000ms | ___ms | ☐ |
| HiAI分类 | <2000ms | ___ms | ☐ |
| 全量测试 | <30s | ___s | ☐ |

---

## 8️⃣ 常见问题与故障排查

### ❌ 问题1：无法跳转到AITestPage

**症状**：点击按钮无反应或报错 `router.pushUrl failed`

**解决**：
```typescript
// 检查main_pages.json中是否有这行：
"pages/AITestPage"

// 如果没有，在数组末尾添加
```

**文件位置**: `entry/src/main/resources/base/profile/main_pages.json` 第157行附近

---

### ❌ 问题2：DeepSeek返回401错误

**症状**：测试日志显示 `401 Unauthorized` 或 `API Key invalid`

**原因**：API Key无效或过期

**解决步骤**：
```
1. 打开文件: entry/src/main/ets/ai/agents/DeepSeekAgent.ts
2. 找到第25行附近的 apiKey 配置
3. 访问 https://cloud.siliconflow.cn 登录
4. 进入 "API Keys" 页面
5. 创建新的Key或复制有效的Key
6. 替换代码中的apiKey值
7. 重新运行测试
```

**检查余额**：
```
硅基流动账户余额 > ¥10 （足够测试几十次）
```

---

### ❌ 问题3：DeepSeek请求超时

**症状**：等待超过10秒无响应，然后失败

**原因**：
- 网络不稳定
- API服务器繁忙
- 代理/防火墙限制

**解决**：
```typescript
// 临时方案：增加超时时间
// 文件: DeepSeekAgent.ts
// 找到 timeout 配置，从30000改为60000（60秒）

// 检查网络
// 1. 确认模拟器/真机可以上网
// 2. 尝试浏览器访问 https://api.siliconflow.cn
// 3. 如果在公司网络，确认防火墙允许HTTPS出站
```

---

### ❌ 问题4：Coze测试失败

**症状**：返回错误或空响应

**原因**：
- Coze Bot未发布
- Token无效
- 工作流未配置

**解决**：
```
1. 登录 https://www.coze.cn
2. 确认 Bot ID: 7638946778641465396 存在且已发布
3. 确认 Workflow ID: 7638960668070625343 存在
4. 检查Token权限
5. 查看 Coze 平台的调用日志
```

**临时方案**：如果不急需Coze，可以先跳过，专注测试小艺和DeepSeek

---

### ❌ 问题5：小艺只返回默认回复

**症状**：无论输入什么，都返回相同的通用回复

**原因**：IntentRouter未匹配到任何意图

**调试方法**：
```typescript
// 在 AITestPage 或自定义测试代码中添加：
const routerResult = await this.orchestrator.getIntentRouter().route(request);
console.log('路由详情:', JSON.stringify(routerResult, null, 2));

// 查看输出中的：
// - matchedIntent: 匹配到的意图（null表示未匹配）
// - confidence: 置信度（<0.3不会触发）
// - extractedEntities: 提取的实体
```

**优化意图匹配**：
```
编辑文件: entry/src/main/ets/ai/orchestrator/IntentRouter.ts
在 intentPatterns 中添加更多关键词模式
```

---

### ❌ 问题6：ImageAnalysisPage崩溃或白屏

**症状**：进入页面后闪退或空白

**原因**：刚刚修复的ArkTS错误未完全解决

**解决**：
```
1. 查看错误日志.txt中的最新错误
2. 确认已应用之前的所有修复：
   - BoundingBox/SizeMM/AnalysisReport 导入
   - ClassificationItem 改为 class
   - HiAIClassificationResult 改为 ImageClassificationResult
   - getMockClassificationResult 使用 new 创建实例
3. Clean Project: Build → Clean Project
4. Rebuild Project: Build → Rebuild Project
```

---

### ❌ 问题7：日志看不到AI输出

**症状**：测试按钮点击后无任何日志

**解决**：
```
DevEco Studio 日志设置：

1. 打开 Logcat/Hilog 面板
2. 确保选择了正确的设备/进程
3. 设置日志级别为 Info 或 Debug
4. 过滤条件设置为：
   - 关键词: AI 或 Orchestrator 或 ImageAnalysis
   - 或者包名: com.example.harmonyhealthcare
5. 清空日志后重新测试
```

---

## 9️⃣ 进阶：性能监控与日志分析

### 9.1 添加性能监控代码

在测试代码中加入详细的时间戳和性能指标：

```typescript
async testWithPerformanceMonitoring(): Promise<void> {
  const orchestrator = AIOrchestrator.getInstance();
  
  // 性能指标收集
  const metrics = {
    totalTime: 0,
    orchestrationTime: 0,
    agentProcessingTime: 0,
    networkTime: 0,
    memoryUsage: 0
  };
  
  const overallStart = Date.now();
  
  try {
    // 监控调度层耗时
    const dispatchStart = Date.now();
    
    const response = await orchestrator.process({
      requestId: 'perf-test-' + Date.now(),
      userId: 'perf-user',
      input: { type: 'text', content: '测试性能监控' },
      preferences: { preferredAgent: 'deepseek' }
    });
    
    metrics.orchestrationTime = Date.now() - dispatchStart;
    metrics.totalTime = Date.now() - overallStart;
    metrics.agentProcessingTime = response.metadata.processingTime || 0;
    
    // 输出性能报告
    console.log('\n===== 性能监控报告 =====');
    console.log(`总耗时: ${metrics.totalTime}ms`);
    console.log(`调度层耗时: ${metrics.orchestrationTime}ms`);
    console.log(`智能体处理: ${metrics.agentProcessingTime}ms`);
    console.log(`网络IO估算: ${metrics.totalTime - metrics.agentProcessingTime}ms`);
    console.log(`使用智能体: ${response.agentId}`);
    console.log(`Token消耗: ${response.metadata.tokensUsed || 'N/A'}`);
    console.log(`每Token耗时: ${(metrics.totalTime / (response.metadata.tokensUsed || 1)).toFixed(2)}ms`);
    console.log('========================\n');
    
    // 更新UI显示
    this.testOutput = `📊 性能报告:\n` +
      `总耗时: ${metrics.totalTime}ms\n` +
      `智能体: ${response.agentId}\n` +
      `Tokens: ${response.metadata.tokensUsed || 'N/A'}\n\n` +
      `回复预览:\n${(response.output.content as string).substring(0, 200)}...`;
      
  } catch (error) {
    console.error('性能测试失败:', error);
  }
}
```

### 9.2 批量压力测试

```typescript
async stressTest(): Promise<void> {
  const orchestrator = AIOrchestrator.getInstance();
  const testCount = 10;  // 并发数
  const results = [];
  
  console.log(`🚀 开始压力测试: ${testCount} 个并发请求`);
  const startTime = Date.now();
  
  // 并发发送多个请求
  const promises = Array.from({ length: testCount }, (_, i) =>
    orchestrator.process({
      requestId: `stress-${i}`,
      userId: 'stress-user',
      input: { type: 'text', content: `并发测试 #${i}: 当前时间？` },
      preferences: { preferredAgent: 'deepseek' }
    }).then(response => {
      results.push({
        index: i,
        success: true,
        time: Date.now() - startTime,
        agentId: response.agentId
      });
    }).catch(error => {
      results.push({
        index: i,
        success: false,
        error: String(error),
        time: Date.now() - startTime
      });
    })
  );
  
  await Promise.all(promises);
  
  // 统计结果
  const successCount = results.filter(r => r.success).length;
  const avgTime = results.filter(r => r.success)
    .reduce((sum, r) => sum + (r as any).time, 0) / successCount;
  
  console.log('\n===== 压力测试报告 =====');
  console.log(`总请求数: ${testCount}`);
  console.log(`成功数: ${successCount}/${testCount}`);
  console.log(`成功率: ${(successCount/testCount*100).toFixed(1)}%`);
  console.log(`平均响应时间: ${avgTime.toFixed(0)}ms`);
  console.log(`总耗时: ${Date.now() - startTime}ms`);
  console.log('========================\n');
}
```

**⚠️ 注意**：压力测试会消耗大量API配额，谨慎使用！

---

## 📊 测试总结模板

完成所有测试后，填写此总结：

```
===== AI功能测试报告 =====

测试日期: ____年____月____日
测试人员: ________________
测试设备: 模拟器 / 真机（型号: _____）

【编译状态】
□ 通过  □ 失败（错误: ____________）

【基础测试】
□ AITestPage 可访问
□ AiChatPage 可访问
□ ImageAnalysisPage 可访问

【智能体测试结果】
1. XiaoyiAgent:  □ 通过  □ 失败  响应时间: ____ms
2. DeepSeekAgent: □ 通过  □ 失败  响应时间: ____ms  Tokens: ____
3. CozeAgent:  □ 通过  □ 失过  □ 未配置  响应时间: ____ms
4. HiAIAgent:  □ 通过  □ 失败  □ 模拟模式  响应时间: ____ms

【功能完整性】
□ 单轮对话正常
□ 多轮对话正常
□ 意图识别准确
□ 错误处理优雅
□ 离线降级可用

【性能指标】
最快响应: ____ms (智能体: ____)
最慢响应: ____ms (智能体: ____)
平均响应: ____ms

【发现的问题】
1. 
2. 
3. 

【下一步行动】
□ 可以集成到生产环境
□ 需要修复部分问题
□ 需要进一步优化性能

========================
```

---

## 🎯 推荐测试顺序

### 新手路线（30分钟）：
```
1. 准备工作 (5分钟)
   ↓
2. 方法一：AITestPage 快速测试 (10分钟)
   ↓
3. 查看测试日志，确认基本功能 (5分钟)
   ↓
4. 方法二：AiChatPage 交互体验 (10分钟)
   ↓
5. 填写测试总结 ✓
```

### 开发者路线（60分钟）：
```
1. 准备工作 + 编译验证 (10分钟)
   ↓
2. 方法一：AITestPage 全量测试 (10分钟)
   ↓
3. 方法三：自定义测试页面 + 性能监控 (15分钟)
   ↓
4. 方法四：ImageAnalysisPage 测试 (10分钟)
   ↓
5. 进阶：压力测试 + 日志分析 (10分钟)
   ↓
6. 故障排查（如有问题） (5分钟)
   ↓
7. 填写完整测试报告 ✓
```

---

## 📚 相关文档索引

| 文档 | 路径 | 用途 |
|-----|------|------|
| **本指南** | `doc_md/AI_PAGE_TESTING_GUIDE.md` | 页面测试操作手册 |
| AI集成指南 | `doc_md/AI_INTEGRATION_GUIDE.md` | 架构设计与部署指南 |
| 架构设计文档 | `docs/AI_ARCHITECTURE_DESIGN.md` | 五层架构技术细节 |
| AI测试指南 | `doc_md/AI_TESTING_GUIDE.md` | 代码级测试用例 |
| 快速开始代码 | `entry/src/main/ets/ai/QUICK_START.ts` | 8个代码示例 |
| 类型定义 | `entry/src/main/ets/ai/models/AITypes.ts` | 接口文档 |
| 调度器源码 | `entry/src/main/ets/ai/orchestrator/AIOrchestrator.ts` | 核心实现 |
| 小艺智能体 | `entry/src/main/ets/ai/agents/XiaoyiAgent.ts` | 语音交互实现 |
| DeepSeek智能体 | `entry/src/main/ets/ai/agents/DeepSeekAgent.ts` | 大模型对接实现 |
| Coze智能体 | `entry/src/main/ets/ai/agents/CozeAgent.ts` | 工作流对接实现 |
| HiAI客户端 | `entry/src/main/ets/hiai/HiAIVisionClient.ets` | 视觉识别封装 |
| 图像分析页面 | `entry/src/main/ets/pages/ImageAnalysisPage.ets` | AI影像分析UI |
| AI测试页面 | `entry/src/main/ets/pages/AITestPage.ets` | 测试专用页面 |
| AI聊天页面 | `entry/src/main/ets/pages/AiChatPage.ets` | 对话式AI界面 |

---

## ✨ 最后提示

### 测试前必读：
1. ✅ **确保编译通过** - 先修复所有ArkTS错误
2. ✅ **网络通畅** - DeepSeek需要联网
3. ✅ **API Key有效** - 检查硅基流动账户余额
4. ✅ **日志开启** - 方便定位问题

### 测试中注意：
- 📝 **记录每次结果** - 特别是响应时间和错误信息
- 🔄 **多次测试** - 同一用例测3次取平均值
- 📸 **截图留存** - 异常情况截图备用
- 💾 **保存日志** - 导出Logcat日志文件

### 测试后必做：
- ✅ **填写检查清单** - 确保所有功能点覆盖
- 📊 **整理测试报告** - 汇总问题和改进点
- 🔧 **及时修复问题** - 不要积累技术债务
- 🎉 **庆祝成功** - AI集成的里程碑！

---

**祝你测试顺利！如有问题随时查阅本文档或查看相关源码。** 🚀

**最后更新**: 2026-05-13  
**文档版本**: v1.0  
**适用范围**: harmony-health-care HMOS6.0 项目  
**维护者**: AI开发团队
