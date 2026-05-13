# 星云医疗助手 - 多AI能力集成架构设计

> **版本**: v1.0
> **更新日期**: 2026-05-11
> **适用项目**: 星云医疗助手 (HarmonyOS 6.0+)

---

## 一、架构总览

### 1.1 五大AI能力协同架构

```
┌─────────────────────────────────────────────────────────────────┐
│                      用户交互层 (UI Layer)                        │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌───────┐ │
│  │ 语音入口  │ │ 文本对话  │ │ 图像上传  │ │ 健康数据  │ │ AR导航 │ │
│  └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘ └───┬───┘ │
└───────┼──────────┼──────────┼──────────┼──────────┼──────────┘
        │          │          │          │          │
        ▼          ▼          ▼          ▼          ▼
┌─────────────────────────────────────────────────────────────────┐
│                   AI统一调度层 (AI Orchestrator)                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │              AIUnifiedDispatcher (统一调度器)              │   │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────────────┐  │   │
│  │  │ IntentClassifier│ │ Router      │ │ ContextAssembler    │  │   │
│  │  │ (意图分类)     │ │ (路由决策)   │ │ (上下文组装)         │  │   │
│  │  └─────────────┘ └─────────────┘ └─────────────────────┘  │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
        │          │          │          │          │
        ▼          ▼          ▼          ▼          ▼
┌─────────────────────────────────────────────────────────────────┐
│                    AI能力层 (AI Capability Layer)                 │
│                                                                  │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  │
│  │ 🎤 小艺Skill     │  │ 🧠 DeepSeek V3  │  │ 🤖 Coze Agent   │  │
│  │ (语音交互)       │  │ (云端大模型)     │  │ (专业智能体)     │  │
│  │                 │  │                 │  │                 │  │
│  │ • MCP协议对接    │  │ • 复杂问诊      │  │ • 专科会诊      │  │
│  │ • 语音指令解析   │  │ • 多轮对话      │  │ • 工作流自动化   │  │
│  │ • 全流程控制     │  │ • 知识推理      │  │ • 标准化流程     │  │
│  │ • 多设备联动     │  │ • 长文本生成    │  │ • 插件扩展       │  │
│  └────────┬────────┘  └────────┬────────┘  └────────┬────────┘  │
│           │                    │                    │            │
│  ┌────────┴────────┐  ┌───────┴────────┐  ┌────────┴────────┐  │
│  │ ⚡ MindSpore Lite│  │ 👁️ HiAI Vision │  │                  │  │
│  │ (端侧推理引擎)   │  │ (视觉识别引擎)  │  │                  │  │
│  │                 │  │                 │  │                  │  │
│  │ • 本地风险评估   │  │ • 影像分类      │  │                  │  │
│  │ • 离线推理       │  │ • 古籍OCR       │  │                  │  │
│  │ • 实时分析       │  │ • 动作识别      │  │                  │  │
│  │ • 隐私保护       │  │ • GPU加速       │  │                  │  │
│  └─────────────────┘  └─────────────────┘                     │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
        │          │          │          │          │
        ▼          ▼          ▼          ▼          ▼
┌─────────────────────────────────────────────────────────────────┐
│                   数据与服务层 (Data & Service)                   │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐           │
│  │ RAG检索库  │ │ 知识图谱  │ │ 健康数据库│ │ 分布式同步 │           │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘           │
└─────────────────────────────────────────────────────────────────┘
```

---

## 二、各AI能力详细职责

### 2.1 🎤 小艺Skill（华为语音助手集成）

#### 核心职责
- **语音交互入口**: 作为系统级语音助手的医疗扩展
- **MCP协议对接**: 实现Model Context Protocol标准接口
- **语音指令解析**: 将自然语言转为结构化操作指令
- **多设备联动**: 通过语音触发跨设备协作

#### 能力清单

| Skill ID | Skill名称 | 触发词 | 功能描述 |
|----------|-----------|--------|---------|
| `medical.query.health` | 健康数据查询 | "小艺，帮我查一下血压/血糖" | 查询最新健康指标 |
| `medical.risk.assess` | 风险评估 | "小艺，帮我评估健康风险" | 触发5维度风险评估 |
| `medical.medication.remind` | 用药提醒 | "小艺，提醒我吃药" | 设置/查询用药提醒 |
| `medical.navigation.start` | 开始导航 | "小艺，导航到XX科室" | 启动AR院内导航 |
| `medical.ai.consultation` | AI问诊 | "小艺，我不舒服，头疼" | 启动AI智能问诊流程 |
| `medical.emergency.sos` | 紧急呼叫 | "小艺，救命/紧急情况" | 触发SOS紧急联系 |
| `medical.device.connect` | 设备连接 | "小艺，连接手表/平板" | 触发分布式设备配对 |
| `medical.rehab.start` | 开始康复训练 | "小艺，开始康复训练" | 启动3D康复动作指导 |

#### 技术实现要点
```typescript
// 小艺Skill注册示例
{
  skillId: 'medical.query.health',
  skillName: '健康数据查询',
  intentPatterns: ['查.*血压', '查.*血糖', '健康.*数据', '最近.*体检'],
  handler: 'handleHealthQuery',  // 处理函数
  needAuth: true,                // 需要用户授权
  responseType: 'voice+ui',      // 语音回复+界面展示
  fallbackAction: 'openHealthPage' // 失败时打开健康页
}
```

---

### 2.2 🧠 硅基流动DeepSeek V3（云端大模型）

#### 核心职责
- **复杂问诊**: 处理多轮对话、复杂医学问题
- **知识推理**: 基于医学知识库进行逻辑推理
- **文本生成**: 生成诊断建议、康复方案、科普内容
- **上下文理解**: 维护长期对话记忆

#### 模型配置

| 配置项 | 值 | 说明 |
|-------|-----|------|
| API端点 | `https://api.siliconflow.cn/v1/chat/completions` | 硅基流动API |
| 模型名称 | `deepseek-ai/DeepSeek-V3` | 最新版本 |
| 最大Token | 4096 | 支持长文本 |
| Temperature | 0.7 | 平衡创造性和准确性 |
| 超时时间 | 15秒 | 避免长时间等待 |

#### 使用场景矩阵

| 场景 | Prompt模板 | 输出示例 |
|-----|------------|---------|
| **症状分析** | "患者{年龄}岁，{性别}，症状：{症状描述}，请分析可能原因..." | 可能疾病列表+建议检查 |
| **用药咨询** | "药物{药名}，适应症{适应症}，患者有{过敏史/并发症}..." | 用药安全性评估+注意事项 |
| **康复方案** | "患者{手术/疾病}术后{天数}天，当前状态{状态}..." | 分阶段康复计划+动作指导 |
| **报告解读** | "检验报告：{各项指标值}，参考范围{正常范围}..." | 异常指标解读+就医建议 |
| **科普生成** | "主题：{医学主题}，目标人群{老年人/慢性病患者}..." | 通俗易懂的科普文章 |

#### 已有实现
✅ 后端已实现: `src/main/java/com/example/medical/utils/AIClient.java`
⚠️ 前端需完善: 需要对接真实API（目前是模拟实现）

---

### 2.3 🤖 Coze智能体平台（专业医疗Agent）

#### 核心职责
- **专科会诊**: 协调多个专科智能体联合会诊
- **工作流自动化**: 标准化诊疗流程自动执行
- **插件扩展**: 接入外部工具（挂号、开方、预约）
- **知识库管理**: 维护结构化医学知识库

#### Coze Bot架构

```
Coze平台 (coze.cn)
├── 🏥 主Bot: 星云医疗助手主智能体
│   ├── 🧠 大脑: DeepSeek-V3 (思维链)
│   ├── 📚 知识库: 医学百科+指南+药品说明书
│   ├── 🔌 插件:
│   │   ├── 挂号插件 (对接医院HIS系统)
│   │   ├── 检验插件 (解读检验报告)
│   │   ├── 用药插件 (药物相互作用检查)
│   │   └── 导航插件 (院内路径规划)
│   └── 🔄 工作流:
│       ├── 预问诊流程 (症状采集→分诊→建议)
│       ├── 随访流程 (复诊提醒→效果评估→调整方案)
│       └── 急救流程 (症状判断→分级→指导)
│
├── 🩺 子Bot1: 内科智能体 (NeurologyAgent)
├── 👁️ 子Bot2: 眼科智能体 (OphthalmologyAgent)
├── ❤️ 子Bot3: 心血管智能体 (CardiologyAgent)
└── 🦴 子Bot4: 康复智能体 (RehabilitationAgent)
```

#### 对接方式
- **API调用**: 通过Coze Open API接口
- **Webhook**: 事件驱动的回调机制
- **SDK集成**: 使用Coze官方SDK（如有）

---

### 2.4 ⚡ MindSpore Lite（端侧推理引擎）

#### 核心职责
- **本地风险评估**: 5维度共病风险实时评估
- **离线推理**: 无网络环境下的AI能力
- **隐私保护**: 敏感健康数据不出设备
- **实时分析**: 低延迟的健康监测预警

#### 模型清单

| 模型名称 | 用途 | 输入特征 | 输出 | 大小 | 推理时间 |
|---------|------|---------|------|------|---------|
| `risk_assess.ms` | 共病风险评估 | 20维健康特征 | 5维风险概率 | ~5MB | <50ms |
| `anomaly_detect.ms` | 异常检测 | 时序健康数据 | 异常标签+置信度 | ~3MB | <30ms |
| `fall_predict.ms` | 跌倒预测 | 传感器数据 | 跌倒风险等级 | ~2MB | <20ms |

#### 模型输入特征定义

```typescript
// 风险评估模型输入 (20维)
interface RiskFeatures {
  // 基础信息 (5维)
  age: number;              // 年龄 (归一化到0-1)
  gender: number;           // 性别 (0=女, 1=男)
  bmi: number;              // BMI指数 (归一化)
  smoking: number;          // 是否吸烟 (0/1)
  drinking: number;         // 是否饮酒 (0/1)

  // 血压相关 (3维)
  systolic: number;         // 收缩压 (归一化)
  diastolic: number;        // 舒张压 (归一化)
  bpVariability: number;    // 血压变异性

  // 血糖相关 (2维)
  fastingGlucose: number;   // 空腹血糖 (归一化)
  hba1c: number;            // 糖化血红蛋白 (归一化)

  // 运动与生活方式 (4维)
  exerciseFrequency: number; // 运动频率 (次/周, 归一化)
  sleepDuration: number;     // 睡眠时长 (小时, 归一化)
  stepCount: number;         // 日步数 (归一化)
  sedentaryTime: number;     // 久坐时长 (小时, 归一化)

  // 既往史 (6维)
  hypertensionHistory: number;  // 高血压病史 (0/1)
  diabetesHistory: number;      // 糖尿病病史 (0/1)
  heartDiseaseHistory: number;  // 心脏病病史 (0/1)
  strokeHistory: number;        // 中风病史 (0/1)
  fractureHistory: number;      // 骨折病史 (0/1)
  medicationCount: number;      // 正在用药数量 (归一化)
}
```

#### 已有实现
✅ 前端已有: `entry/src/main/ets/ai/RiskAssessmentEngine.ets`
⚠️ 目前是规则引擎，需要接入真实MindSpore模型

---

### 2.5 👁️ HiAI视觉识别引擎

#### 核心职责
- **医学影像分类**: X光/CT/皮肤照片自动分类
- **古籍OCR识别**: 古医书文字提取与标注
- **康复动作识别**: 3D姿态估计与动作纠正
- **皮肤病变检测**: 初步筛查异常区域

#### 能力矩阵

| 能力 | HiAI API | 应用场景 | 准确率要求 |
|-----|----------|---------|-----------|
| **图像分类** | `imageClassification` | 医学影像类型识别 (X光/CT/MRI/超声) | >90% |
| **文字识别** | `textRecognition` | 古籍OCR、检验报告OCR | >85% |
| **目标检测** | `objectDetection` | 康复动作关键点检测 | >85% |
| **图像分割** | `imageSegmentation` | 皮肤病变区域分割 | >80% |
| **图像增强** | `imageSuperResolution` | 低质量古籍图像超分辨率 | 视觉提升 |

#### 使用场景示例

**场景1: 医学影像自动分类**
```
用户上传: [胸部X光图片]
HiAI处理流程:
1. imageClassification → 分类结果: "胸部X光" (置信度0.95)
2. textRecognition → 提取影像报告文字
3. → 转发给专科智能体进行诊断建议
```

**场景2: 古籍图像复原**
```
用户上传: [模糊古医书插图]
HiAI处理流程:
1. imageSuperResolution → 4倍超分辨率增强
2. textRecognition → OCR文字提取
3. colorRestoration → 色彩还原
4. annotationEngine → 自动标注
5. → 展示复原后的高清图像
```

**场景3: 康复动作识别**
```
摄像头捕获: [用户做康复动作视频帧]
HiAI处理流程:
1. objectDetection → 人体关键点检测 (17个关键点)
2. poseEstimation → 3D姿态估计
3. actionRecognition → 动作类型识别
4. → 与标准动作对比，给出纠正建议
```

---

## 三、数据流转与调用关系

### 3.1 典型场景: 用户说"小艺，我头晕怎么办？"

```
1️⃣ 用户语音输入
   ↓
2️⃣ 🎤 小艺Skill接收
   • 语音转文字: "我头晕怎么办"
   • 意图识别: medical.ai.consultation (AI问诊)
   • 参数提取: { symptom: "头晕" }
   ↓
3️⃣ AI统一调度器路由
   • 判断: 需要复杂医学推理
   • 选择: 🧠 DeepSeek V3 + 🤖 Coze内科智能体
   ↓
4️⃣ 并行调用
   ├→ 🧠 DeepSeek: 生成初步分析 (可能原因: 高血压/颈椎病/贫血...)
   ├→ 🤖 Coze内科Bot: 执行预问诊工作流 (追问: 头晕多久?伴随症状?)
   └→ ⚡ MindSpore: 如果有健康数据，本地评估风险
   ↓
5️⃣ 结果聚合
   • 综合三方结果
   • 生成结构化回答
   ↓
6️⃣ 🎤 小艺Skill响应
   • 文字转语音播报
   + UI展示详细内容
   + 推荐后续操作 (挂号/检查/休息)
```

### 3.2 典型场景: 用户上传一张医学影像

```
1️⃣ 用户选择图片上传
   ↓
2️⃣ AI统一调度器路由
   • 判断: 图像分析任务
   • 选择: 👁️ HiAI视觉识别
   ↓
3️⃣ 👁️ HiAI处理流水线
   • Step1: imageClassification → 影像类型: "胸部X光"
   • Step2: imageSuperResolution → 图像增强
   • Step3: textRecognition → 提取报告文字 (如果有)
   ↓
4️⃣ 结果转发
   • 影像类型 + OCR文字
   ↓
5️⃣ 🧠 DeepSeek分析
   • 结合影像描述进行诊断建议
   ↓
6️⃣ UI展示
   • 影像分类标签
   • OCR提取的文字
   • AI诊断建议
   • 推荐就诊科室
```

### 3.3 典型场景: 定期健康风险评估

```
1️⃣ 触发条件 (定时/手动/数据更新)
   ↓
2️⃣ 数据准备
   • 从本地数据库读取近期健康数据
   • 特征工程 (归一化、缺失值处理)
   ↓
3️⃣ ⚡ MindSpore Lite本地推理
   • 加载模型: risk_assess.ms
   • 输入: 20维特征向量
   • 输出: 5维风险概率 [高血压, 糖尿病, 跌倒, 衰弱, 肌少症]
   • 推理时间: <50ms ✅
   ↓
4️⃣ 后处理
   • 风险等级划分 (低/中/高/极高)
   • 生成个性化建议 (基于规则库)
   ↓
5️⃣ 结果展示
   • 雷达图可视化
   • 各项风险详情
   • 行动建议清单
   ↓
6️⃣ 可选: 上传至云端
   • 如需深度分析，发送给🧠 DeepSeek
   • 生成更详细的报告
```

---

## 四、技术选型与依赖

### 4.1 关键依赖版本

| 技术 | 版本 | 用途 | 引入方式 |
|-----|------|------|---------|
| HarmonyOS SDK | API 22 | 系统基础能力 | 官方SDK |
| @kit.VoiceAssistantKit | - | 小艺Skill开发 | 官方Kit |
| mindspore-lite | 2.2.10 | 端侧推理 | ohpm包 |
| @kit.CoreVisionKit | - | HiAI视觉能力 | 官方Kit |
|硅基流动API | v1 | DeepSeek大模型 | HTTP API |
| Coze API | v1 | Coze智能体 | HTTP API / Webhook |

### 4.2 权限声明 (module.json5)

```json
{
  "module": {
    "requestPermissions": [
      {
        "name": "ohos.permission.MICROPHONE",
        "reason": "$string:microphone_reason",
        "usedScene": {
          "abilities": ["EntryAbility"],
          "when": "inuse"
        }
      },
      {
        "name": "ohos.permission INTERNET",
        "reason": "$string:internet_reason",
        "usedScene": {
          "abilities": ["EntryAbility"],
          "when": "always"
        }
      },
      {
        "name": "ohos.permission.CAMERA",
        "reason": "$string:camera_reason",
        "usedScene": {
          "abilities": ["EntryAbility"],
          "when": "inuse"
        }
      },
      {
        "name": "ohos.permission.READ_HEALTH_DATA",
        "reason": "$string:health_data_reason",
        "usedScene": {
          "abilities": ["EntryAbility"],
          "when": "inuse"
        }
      }
    ]
  }
}
```

---

## 五、性能与安全要求

### 5.1 性能指标

| 操作 | 目标延迟 | 最大延迟 | 备注 |
|-----|---------|---------|------|
| 小艺语音识别 | <500ms | <1000ms | 端侧ASR |
| MindSpore推理 | <50ms | <100ms | 风险评估模型 |
| HiAI图像分类 | <200ms | <500ms | 单张图片 |
| DeepSeek对话 | <3000ms | <5000ms | 云端API |
| Coze工作流 | <5000ms | <10000ms | 包含多步骤 |

### 5.2 安全策略

| 数据类型 | 存储位置 | 传输加密 | 合规要求 |
|---------|---------|---------|---------|
| 语音输入 | 端侧处理，不上传 | N/A | 符合隐私法规 |
| 健康数据 | 本地SQLite | AES-256 | HIPAA/GDPR参考 |
| 风险评估结果 | 本地优先 | 可选上传 | 用户授权后 |
| 对话记录 | 端侧存储 | TLS 1.3 | 用户可删除 |
| 医学影像 | 本地压缩 | AES-256 | 脱敏后可上传 |

---

## 六、文件结构说明

生成的文件将位于以下目录：

```
entry/src/main/ets/
├── ai/
│   ├── RiskAssessmentEngine.ets          # [已有] 风险评估引擎
│   └── HealthFeatureExtractor.ets        # [已有] 特征提取
│
├── aiagent/
│   ├── MedicalAgent.ets                  # [已有] 智能体基类
│   ├── MultiAgentOrchestrator.ets        # [已有] 多智能体编排
│   └── infrastructure/
│       ├── LLMClient.ets                 # [已有] LLM客户端(需完善)
│       └── ...
│
├── xiaoyi/                               # [新建] 小艺Skill模块
│   ├── XiaoyiSkillManager.ets            # Skill管理器
│   ├── XiaoyiMCPProtocol.ets             # MCP协议实现
│   ├── skills/                           # Skill定义
│   │   ├── HealthQuerySkill.ets          # 健康查询Skill
│   │   ├── RiskAssessSkill.ets           # 风险评估Skill
│   │   ├── MedicationReminderSkill.ets   # 用药提醒Skill
│   │   ├── NavigationSkill.ets           # 导航Skill
│   │   ├── AIConsultationSkill.ets       # AI问诊Skill
│   │   ├── EmergencySkill.ets            # 紧急呼叫Skill
│   │   ├── DeviceConnectSkill.ets        # 设备连接Skill
│   │   └── RehabTrainingSkill.ets        # 康复训练Skill
│   └── types/
│       └── XiaoyiTypes.ets               # 类型定义
│
├── deepseek/                             # [新建] DeepSeek客户端
│   ├── SiliconFlowClient.ets             # 硅基流动API客户端
│   ├── DeepSeekChatManager.ets           # 对话管理器
│   ├── prompts/                          # Prompt模板
│   │   ├── SymptomAnalysisPrompt.ets     # 症状分析Prompt
│   │   ├── MedicationConsultPrompt.ets   # 用药咨询Prompt
│   │   ├── RehabPlanPrompt.ets           # 康复方案Prompt
│   │   └── ReportInterpretPrompt.ets     # 报告解读Prompt
│   └── types/
│       └── DeepSeekTypes.ets             # 类型定义
│
├── coze/                                 # [新建] Coze智能体模块
│   ├── CozeApiClient.ets                 # Coze API客户端
│   ├── CozeWorkflowExecutor.ets          # 工作流执行器
│   ├── bots/                             # Bot实例
│   │   ├── InternalMedicineBot.ets       # 内科智能体
│   │   ├── OphthalmologyBot.ets          # 眼科智能体
│   │   └── RehabilitationBot.ets         # 康复智能体
│   └── types/
│       └── CozeTypes.ets                 # 类型定义
│
├── mindsphere/                           # [新建] MindSpore模块
│   ├── MindSporeLiteEngine.ets           # 推理引擎封装
│   ├── models/                           # 模型定义
│   │   ├── RiskAssessModel.ets           # 风险评估模型
│   │   ├── AnomalyDetectModel.ets        # 异常检测模型
│   │   └── FallPredictModel.ets          # 跌倒预测模型
│   └── types/
│       └── MindSporeTypes.ets            # 类型定义
│
├── hiai/                                 # [新建] HiAI视觉模块
│   ├── HiAIVisionClient.ets              # HiAI客户端封装
│   ├── recognizers/                      # 识别器
│   │   ├── ImageClassifier.ets           # 图像分类器
│   │   ├── TextRecognizer.ets            # 文字识别器
│   │   ├── PoseDetector.ets              # 姿态检测器
│   │   └── ObjectSegmenter.ets           # 目标分割器
│   └── types/
│       └── HiAITypes.ets                 # 类型定义
│
└── ai_orchestrator/                      # [新建] AI统一调度层
    ├── AIUnifiedDispatcher.ets           # 统一调度器
    ├── AIIntentRouter.ets                # 意图路由器
    ├── AIContextAssembler.ets            # 上下文组装器
    └── types/
        └── OrchestratorTypes.ets         # 类型定义
```

---

## 七、下一步行动

请继续查看以下文件以获取完整实现代码：

1. **[AI_INTEGRATION_GUIDE.md](./AI_INTEGRATION_GUIDE.md)** - 详细集成步骤和使用教程
2. **[xiaoyi/XiaoyiSkillManager.ets](../entry/src/main/ets/xiaoyi/XiaoyiSkillManager.ets)** - 小艺Skill核心代码
3. **[deepseek/SiliconFlowClient.ets](../entry/src/main/ets/deepseek/SiliconFlowClient.ets)** - DeepSeek客户端
4. **[coze/CozeApiClient.ets](../entry/src/main/ets/coze/CozeApiClient.ets)** - Coze智能体客户端
5. **[mindsphere/MindSporeLiteEngine.ets](../entry/src/main/ets/mindsphere/MindSporeLiteEngine.ets)** - MindSpore引擎
6. **[hiai/HiAIVisionClient.ets](../entry/src/main/ets/hiai/HiAIVisionClient.ets)** - HiAI视觉客户端
7. **[ai_orchestrator/AIUnifiedDispatcher.ets](../entry/src/main/ets/ai_orchestrator/AIUnifiedDispatcher.ets)** - 统一调度器

---

*文档结束*
