# 🤖 AI能力集成 - 完整使用指南

## 📋 目录
1. [AI能力架构总览](#1-ai能力架构总览)
2. [各AI能力职责分工](#2-各ai能力职责分工)
3. [文件结构说明](#3-文件结构说明)
4. [快速开始](#4-快速开始)
5. [详细使用教程](#5-详细使用教程)

---

## 1. AI能力架构总览

### 整体架构图
```
┌─────────────────────────────────────────────────────────────┐
│                     用户交互层                                │
│    ┌──────────┐   ┌──────────┐   ┌──────────┐              │
│    │ 小艺语音  │   │ UI界面   │   │ API调用  │              │
│    └─────┬────┘   └─────┬────┘   └─────┬────┘              │
└──────────┼──────────────┼──────────────┼────────────────────┘
           │              │              │
           ▼              ▼              ▼
┌─────────────────────────────────────────────────────────────┐
│                  AI 统一调度层 (AIOrchestrator)               │
│         智能路由 | 结果聚合 | 错误处理 | 日志记录               │
└──┬──────────┬──────────┬──────────┬─────────────────────────┘
   │          │          │          │
   ▼          ▼          ▼          ▼
┌──────┐ ┌──────────┐ ┌──────┐ ┌────────────┐
│ 小艺  │ │ 硅基流动  │ │ Coze │ │ MindSpore/ │
│ Skill │ │ DeepSeek │ │ Bot  │ │ HiAI       │
│      │ │ 大模型    │ │      │ │ (端侧推理)  │
└──────┘ └──────────┘ └──────┘ └────────────┘
```

### 各AI能力对比表

| AI能力 | 技术栈 | 数据位置 | 延迟 | 隐私保护 | 适用场景 |
|--------|--------|----------|------|----------|----------|
| **小艺Skill** | HarmonyOS MCP协议 | 本地+云端 | 低 | 高 | 语音交互、快捷指令 |
| **DeepSeek** | 硅基流动API | 云端 | 中等 | 中 | 复杂对话、症状分析 |
| **Coze Bot** | Coze平台API | 云端 | 中等 | 中 | 专科问诊、标准化流程 |
| **MindSpore Lite** | 本地模型推理 | 本地(端侧) | 极高 | 最高 | 风险评估、异常检测 |
| **HiAI Vision** | 华为NPU加速 | 本地(端侧) | 极高 | 最高 | 图像识别、OCR |

---

## 2. 各AI能力职责分工

### 🎯 小艺智能体 (Xiaoyi Skill/MCP)
**核心定位**: 语音交互入口 + 快捷操作触发器

**负责场景**:
- ✅ 用户语音指令解析（"小艺，帮我查血压"）
- ✅ 快捷健康数据查询（血压/血糖/心率/体重）
- ✅ 用药提醒设置（"小艺，提醒我吃药"）
- ✅ 导航到科室（"小艺，导航到内科"）
- ✅ 紧急求助（"小艺，救命！"）
- ✅ 设备连接管理（"小艺，连接我的手环"）

**技术实现**: MCP协议 + Skill注册机制

---

### 🧠 DeepSeek大模型 (硅基流动)
**核心定位**: 通用医疗问答 + 深度分析引擎

**负责场景**:
- ✅ 症状初步分析（"头疼持续3天是什么原因？"）
- ✅ 用药咨询（"阿司匹林怎么吃？有什么副作用？"）
- ✅ 康复方案制定（"骨折后如何康复？"）
- ✅ 检验报告解读（"帮我看看这份血常规报告"）
- ✅ 健康科普内容生成
- ✅ 多轮对话式问诊

**技术实现**: HTTP REST API调用 + Prompt工程

---

### 🏥 Coze智能体 (Coze Bot)
**核心定位**: 专科专家系统 + 标准化诊疗流程

**负责场景**:
- ✅ 内科专科会诊（复杂内科问题）
- ✅ 眼科专业咨询（视力问题、眼部疾病）
- ✅ 康复方案评估（术后康复指导）
- ✅ 预问诊流程执行（标准化的病史采集）
- ✅ 随访计划生成（出院后的跟踪随访）

**技术实现**: Coze工作流 + 专业Bot配置

---

### 🔒 MindSpore Lite (端侧推理)
**核心定位**: 隐私敏感计算 + 实时风险监测

**负责场景**:
- ✅ 共病风险评估（高血压/糖尿病/跌倒/衰弱/肌少症 5维度）
- ✅ 健康数据异常检测（实时监测生命体征异常）
- ✅ 跌倒风险预测（基于传感器数据预测）
- ✅ 本地数据预处理（数据脱敏后再上传云端）

**技术实现**: MindSpore Lite运行时 + .ms模型文件

---

### 👁️ HiAI视觉识别 (华为NPU)
**核心定位**: 图像智能分析 + OCR文字提取

**负责场景**:
- ✅ 医学影像类型自动识别（X光/CT/MRI/超声）
- ✅ 检验报告OCR识别（自动录入检验结果）
- ✅ 古籍医书文字提取（中医药文献数字化）
- ✅ 康复动作关键点检测（姿态分析）
- ✅ 药品包装识别（辅助用药安全）

**技术实现**: HiAI SDK + NPU硬件加速

---

## 3. 文件结构说明

```
entry/src/main/ets/
├── ai/
│   ├── AIOrchestrator.ets          # ⭐ AI统一调度层（主入口）
│   ├── RiskAssessmentEngine.ets    # 风险评估引擎（已有）
│   └── MedicalAgent.ets            # 医疗Agent基类（已有）
│
├── xiaoyi/                          # 🎯 小艺Skill模块
│   ├── XiaoyiSkillManager.ets      # Skill管理器（注册/路由/调用）
│   ├── types/
│   │   └── XiaoyiTypes.ets         # 类型定义
│   └── skills/
│       ├── HealthQuerySkill.ets     # 健康数据查询Skill
│       ├── RiskAssessSkill.ets      # 风险评估Skill
│       ├── MedicationReminderSkill.ets  # 用药提醒Skill
│       ├── NavigationSkill.ets      # 导航Skill
│       ├── AIConsultationSkill.ets  # AI问诊Skill
│       ├── EmergencySkill.ets       # 紧急求助Skill
│       ├── DeviceConnectSkill.ets   # 设备连接Skill
│       └── RehabTrainingSkill.ets   # 康复训练Skill
│
├── deepseek/                        # 🧠 DeepSeek模块
│   ├── SiliconFlowClient.ets        # API客户端（HTTP封装）
│   ├── DeepSeekChatManager.ets      # 对话管理器（Prompt模板）
│   └── types/
│       └── DeepSeekTypes.ets        # 类型定义
│
├── coze/                            # 🏥 Coze模块
│   └── CozeApiClient.ets            # Bot客户端
│
├── mindsphere/                      # 🔒 MindSpore模块
│   └── MindSporeLiteEngine.ets      # 推理引擎（规则/模型双模式）
│
└── hiai/                            # 👁️ HiAI模块
    └── HiAIVisionClient.ets         # 视觉客户端
```

---

## 4. 快速开始

### Step 1: 初始化AI系统

在应用启动时初始化所有AI组件：

```typescript
// entry/src/main/ets/ability/EntryAbility.ets
import { aiOrchestrator } from '../ai/AIOrchestrator';

onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
  // 初始化AI统一调度层
  aiOrchestrator.initialize().then(() => {
    console.info('AI系统初始化完成');
  });
}
```

### Step 2: 使用小艺语音交互

```typescript
// 在任意页面中处理语音指令
import { xiaoyiSkillManager } from '../xiaoyi/XiaoyiSkillManager';

async function handleVoiceCommand(userSpeech: string, userId: string) {
  // 自动路由到最佳Skill并处理
  const response = await xiaoyiSkillManager.autoRouteAndProcess(
    userSpeech,
    userId
  );

  // 播放语音回复
  if (response.voiceResponse) {
    speak(response.voiceResponse);
  }

  // 执行UI跳转或显示卡片
  if (response.action?.type === 'navigate') {
    router.pushUrl({ url: response.action.target });
  }
}

// 示例：处理 "小艺，帮我查血压"
await handleVoiceCommand('小艺，帮我查血压', 'user_123');
```

### Step 3: 调用DeepSeek进行症状分析

```typescript
import { deepSeekChatManager } from '../deepseek/DeepSeekChatManager';

async function analyzeSymptom() {
  const result = await deepSeekChatManager.analyzeSymptom(
    '头疼，持续3天，伴有恶心',
    35,  // 年龄
    '男'  // 性别
  );

  console.log(result);
  // 输出包含：
  // 1. 可能的原因（2-3种可能）
  // 2. 需要关注的情况
  // 3. 初步建议
  // 4. 建议就诊科室
}
```

### Step 4: 执行风险评估（MindSpore端侧）

```typescript
import { mindSporeEngine } from '../mindsphere/MindSporeLiteEngine';

async function assessHealthRisk() {
  const healthData = {
    age: 68,
    gender: 1,           // 1=男, 0=女
    bmi: 24.5,
    smoking: 0,          // 不吸烟
    drinking: 0,         // 不饮酒
    systolic: 145,       // 收缩压
    diastolic: 92,       // 舒张压
    fastingGlucose: 6.8, // 空腹血糖
    exerciseFrequency: 2, // 每周运动2次
    sleepDuration: 6.5,  // 睡眠时长
    stepCount: 4500,     // 每日步数
    hypertensionHistory: 1, // 有高血压史
    diabetesHistory: 0,
    medicationCount: 3
  };

  const riskResult = await mindSporeEngine.assessRisk(healthData);

  console.log(`风险等级: ${riskResult.overallLevel}`);
  console.log(`高血压风险: ${(riskResult.hypertensionRisk * 100).toFixed(1)}%`);
  console.log(`糖尿病风险: ${(riskResult.diabetesRisk * 100).toFixed(1)}%`);
  console.log(`建议: ${riskResult.suggestions.join('; ')}`);
}
```

### Step 5: 图像识别（HiAI）

```typescript
import { hiAIVisionClient } from '../hiai/HiAIVisionClient';

async function analyzeMedicalImage(imageUri: string) {
  // 综合分析（分类 + OCR）
  const result = await hiAIVisionClient.analyzeMedicalImage(imageUri);

  console.log(`影像类型: ${result.classification.label}`);
  console.log(`置信度: ${(result.classification.confidence * 100).toFixed(1)}%`);

  if (result.ocrResult) {
    console.log(`识别文本: ${result.ocrResult.text.substring(0, 100)}...`);
  }
}
```

---

## 5. 详细使用教程

### 5.1 小艺Skill开发流程

#### 创建新Skill的步骤：

1. **定义Skill配置**
```typescript
// 在 types/XiaoyiTypes.ets 中已有基础定义
// 创建新的Skill类继承基础接口
```

2. **实现Skill处理器**
```typescript
export class MyNewSkill extends BaseSkill {
  getDefinition(): XiaoyiSkillDefinition {
    return {
      config: {
        skillId: 'medical.my.new.skill',
        skillName: '我的新功能',
        skillDescription: '功能描述',
        version: '1.0.0'
      },
      intentPatterns: [
        {
          pattern: '关键词1|关键词2|关键词3',
          confidence: 0.9,
          examples: ['示例1', '示例2']
        }
      ],
      handler: 'handleMyNewFunction',
      needAuth: true,
      responseType: 'voice+ui'
    };
  }

  async handle(request): Promise<XiaoyiSkillResponse> {
    // 实现你的业务逻辑
    return {
      success: true,
      voiceResponse: '处理结果',
      uiResponse: {...},
      action: {...}
    };
  }
}
```

3. **注册到Skill管理器**
```typescript
// 在 XiaoyiSkillManager 的 registerDefaultSkills() 方法中添加
this.registerSkill(new MyNewSkill().getDefinition());
```

#### 触发词设计规范：
- 使用自然语言模式匹配
- 提供多个同义词变体
- 设置合理的置信度阈值
- 包含实际使用的示例

---

### 5.2 DeepSeek Prompt模板定制

#### 自定义系统提示词：

```typescript
const customPrompt = `你是一位专业的${specialty}医生...
特殊要求：
1. ...
2. ...`;

const response = await deepSeekChatManager.analyzeSymptom(
  symptom,
  age,
  gender,
  additionalInfo
);
```

#### 流式对话场景：

```typescript
// 实时显示AI回复
await deepSeekChatManager.sendMessageStream(
  sessionId,
  userMessage,
  (chunk) => {
    // 每收到一个chunk就更新UI
    updateUI(chunk);
  },
  () => {
    // 回复完成
    showCompleteButton();
  },
  (error) => {
    showError(error.message);
  }
);
```

---

### 5.3 MindSpore模型部署

#### 准备模型文件：

1. 训练PyTorch/TensorFlow模型
2. 导出为ONNX格式
3. 转换为MindSpore格式 (.ms文件)
4. 放置到 `entry/src/main/resources/rawfile/` 目录

#### 当前状态说明：

目前代码采用**规则引擎作为fallback**，当真实模型文件不存在时自动降级。要启用真实推理，需要：

1. 提供 `risk_assess.ms` 模型文件
2. 确保 `useRealModel = true`（代码会自动检测）

---

### 5.4 Coze Bot配置

#### 配置步骤：

1. 注册Coze账号：https://www.coze.cn
2. 创建Bot（内科/眼科/康复等）
3. 配置Bot的工作流和Prompt
4. 获取Bot ID和API Key
5. 更新代码中的配置：

```typescript
// CozeApiClient.ets
const cozeApiClient = new CozeApiClient({
  apiKey: 'YOUR_COZE_API_KEY',  // 替换为真实的Key
  botId: 'YOUR_BOT_ID'          // 替换为Bot ID
});
```

---

## 6. API Key配置清单

| 服务 | 配置项 | 默认值 | 是否需要替换 |
|------|--------|--------|--------------|
| 硅基流动 DeepSeek | apiKey | sk-nyvarnxvnqlheyvsvtqvkmdxjjsqaoacnududnkwjadpxhfv | ✅ 已配置 |
| Coze Bot | apiKey | YOUR_COZE_API_KEY | ⚠️ 需要申请 |
| Coze Bot | botId | YOUR_BOT_ID | ⚠️ 需要创建 |
| MindSpore | modelPath | rawfile/risk_assess.ms | ⚠️ 需要训练部署 |

---

## 7. 常见问题 FAQ

### Q1: 如何测试小艺Skill？
A: 目前可以在模拟器中使用文本输入模拟语音指令：
```typescript
xiaoyiSkillManager.autoRouteAndProcess('查血压', 'test_user')
```

### Q2: 数据隐私如何保障？
A:
- 敏感计算（风险评估）在本地完成（MindSpore）
- 图像处理不上传云端（HiAI）
- 对话内容可选择是否上传（DeepSeek/Coze）

### Q3: 如何扩展新的AI能力？
A:
1. 创建新的客户端类
2. 在AIOrchestrator中添加路由逻辑
3. 更新请求类型和处理方法

### Q4: 离线状态下哪些功能可用？
A:
- ✅ MindSpore风险评估（本地模型）
- ✅ HiAI图像分类（本地推理）
- ❌ DeepSeek对话（需要网络）
- ❌ Coze Bot调用（需要网络）
- ⚠️ 小艺Skill（部分功能可用）

---

## 8. 下一步行动项

- [ ] 申请Coze开发者账号并创建Bot
- [ ] 训练并部署MindSpore风险评估模型
- [ ] 测试所有Skill的触发词匹配效果
- [ ] 完善错误处理和降级策略
- [ ] 编写单元测试覆盖核心流程
- [ ] 性能优化和内存管理检查

---

**文档版本**: v1.0
**最后更新**: 2026-05-11
**维护者**: 星云医疗团队
