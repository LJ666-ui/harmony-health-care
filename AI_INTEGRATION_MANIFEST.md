# 星云医疗助手 — AI / MCP / Skill 集成清单

> 本文档完整记录项目中的所有 AI 智能体、MCP 协议、Skill 离线包及其配置信息。

---

## 一、AI 智能体架构总览

项目采用 **AIOrchestrator（统一编排层）** 调度 4 大引擎，覆盖云端推理、工作流自动化、端侧计算和语音交互：

```
┌─────────────────────────────────────────────────────────────┐
│                    用户交互入口                               │
│        小艺语音 / UI 页面 / API 调用 / 手表端               │
└───────────────────────────┬─────────────────────────────────┘
                            │
              ┌─────────────▼──────────────┐
              │     AIOrchestrator         │
              │   (统一路由 + 结果聚合)      │
              └───┬───────┬───────┬───────┘
                  │       │       │
          ┌───────▼──┐ ┌──▼───┐ ┌▼────────┐
          │  小艺    │ │DeepSeek│ │  Coze   │ │ HiAI/MS │
          │ Skill系统│ │ 硅基流动│ │ 工作流Bot│ │ 端侧推理 │
          └──────────┘ └───────┘ └─────────┘ └─────────┘
```

---

## 二、四大 AI 引擎详解

### 2.1 Coze 扣子智能体平台 — 工作流集成

**定位**：专科会诊与标准化诊疗流程自动化，通过 Coze 工作流串联多个专业智能体。

#### 内置的三个专科智能体

| # | 智能体名称 | 专科领域 | 功能说明 |
|---|----------|---------|---------|
| **C1** | **眼科智能体** | 眼科 | 眼部症状分析、视力评估、眼部疾病初步筛查、用药建议 |
| **C2** | **内科智能体** | 内科 | 常见内科疾病问诊、慢性病管理、检验报告解读、用药指导 |
| **C3** | **康复智能体** | 康复医学 | 康复方案制定、功能评估、康复训练建议、预后跟踪 |

#### 工作流编排方式

```
用户输入 → [意图分类] → [分派到对应专科智能体] → [多智能体协作讨论]
                                                    ↓
                                            [综合结论输出]
```

- **Workflow ID**: `7638960668070625343`
- **Bot ID**: `7638946778641465396`
- **使用场景**：预问诊、随访管理、急救流程标准化

#### 配置与链接

| 项目 | 值 |
|------|-----|
| **API 地址** | `https://api.coze.cn/v1` |
| **配置文件** | `entry/src/main/ets/common/constants/CozeConfig.ts` |
| **客户端封装** | `entry/src/main/ets/coze/CozeApiClient.ets` |
| **Agent 类** | `entry/src/main/ets/ai/agents/CozeAgent.ts` |
| **官方平台** | https://www.coze.cn |
| **开放 API 文档** | https://open.coze.cn |

---

### 2.2 DeepSeek（硅基流动 SiliconFlow）— 云端大语言模型

**定位**：通用医疗问答、症状分析、用药咨询、康复建议的云端推理核心。

#### 模型配置

| 项目 | 值 |
|------|-----|
| **模型名称** | DeepSeek-V3 |
| **API 提供商** | 硅基流动（SiliconFlow） |
| **API 地址** | `https://api.siliconflow.cn/v1/chat/completions` |
| **角色设定** | "康小智" — 智慧康养 AI 助手 |

#### 能力范围

- 健康咨询：常见健康问题解答
- 用药指导：药物作用、用法、注意事项
- 营养建议：个性化膳食指导
- 心理支持：情绪疏导与关怀
- 康复建议：适合老年人的运动训练
- 症状分析：基于年龄/性别/症状的初步判断

#### 配置与链接

| 项目 | 值 |
|------|-----|
| **配置文件** | `entry/src/main/ets/common/constants/SiliconFlowConfig.ets` |
| **对话管理器** | `entry/src/main/ets/deepseek/DeepSeekChatManager.ets` |
| **HTTP 客户端** | `entry/src/main/ets/deepseek/SiliconFlowClient.ets` |
| **Agent 类** | `entry/src/main/ets/ai/agents/DeepSeekAgent.ts` |
| **硅基流动平台** | https://platform.siliconflow.cn |
| **DeepSeek 开源** | https://github.com/deepseek-ai |
| **模型卡片** | https://platform.siliconflow.cn/models/deepseek-ai/DeepSeek-V3 |

---

### 2.3 MindSpore Lite — 端侧轻量推理引擎

**定位**：设备本地运行的轻量级推理能力，无需联网即可完成基础 AI 推理。

#### 特性

| 属性 | 说明 |
|------|------|
| **运行位置** | 设备端（手机/手表本地） |
| **网络依赖** | 无需联网，完全离线 |
| **推理类型** | 轻量级分类、特征提取 |
| **底层框架** | 华为 MindSpore Lite |

#### 使用场景

- 本地健康数据快速分类
- 离线环境下的基础 AI 判断
- 与 HiAI 协同完成端侧 AI 管线

#### 配置与链接

| 项目 | 值 |
|------|-----|
| **引擎文件** | `entry/src/main/ets/mindsphere/MindSporeLiteEngine.ets` |
| **MindSpore 官网** | https://www.mindspore.cn |
| **MindSpore Lite 文档** | https://mindspore.cn/lite/docs/zh-CN/r2.3/index.html |
| **开源协议** | Apache 2.0 |

---

### 2.4 HiAI（华为端侧 AI 引擎）— 视觉识别

**定位**：利用华为设备 NPU 进行高性能视觉 AI 推理。

#### 核心能力

| 能力 | 说明 |
|------|------|
| **图像分类** | 医学图像类别识别（如 X 光/CT/超声分类） |
| **OCR 文字识别** | 处方单、检验报告、古籍文字提取 |
| **姿态检测** | 康复动作标准度评估 |
| **跌倒检测** | 老年人跌倒实时检测与告警 |

#### 配置信息

| 项目 | 值 |
|------|-----|
| **App ID** | `6917605309959973739` |
| **应用包名** | `com.example.harmonyhealthcare` |
| **推理硬件** | 华为 NPU（神经网络处理单元） |
| **备选降级** | CPU / GPU |

#### 配置与链接

| 项目 | 值 |
|------|-----|
| **配置文件** | `entry/src/main/ets/common/constants/HiAIConfig.ets` |
| **视觉客户端** | `entry/src/main/ets/hiai/HiAIVisionClient.ets` |
| **Agent 类** | `entry/src/main/ets/ai/agents/HiAIAgent.ts` |
| **HiAI 开发者文档** | https://developer.huawei.com/consumer/cn/hiai |
| **HiAI SDK** | 随 DevEco Studio 自带 |

---

## 三、小艺（Xiaoyi）Skill 系统 — MCP 协议实现

### 3.1 系统概述

小艺 Skill 系统是项目的 **MCP Server 实现**，对接华为小艺语音助手平台。包含 **5 个子智能体** + **8 个 Skill 离线包** + **病理知识库（约 150 万条）**。

### 3.2 五个子智能体

| # | 智能体名称 | 职责 | 支持的意图 |
|---|-----------|------|-----------|
| **X1** | **预约挂号助手** | 医院预约、科室选择、医生排班查询 | APPOINTMENT_BOOKING |
| **X2** | **健康数据管家** | 血压/血糖/心率等指标查询与播报 | HEALTH_QUERY |
| **X3** | **导航向导** | AR 院内导航、路径规划、语音导引 | NAVIGATION |
| **X4** | **紧急响应中心** | SOS 一键呼救、自动定位、联系人通知 | EMERGENCY |
| **X5** | **生活服务管家** | 用药提醒、康复训练、设备控制 | MEDICATION_REMINDER / REHAB_TRAINING / DEVICE_CONTROL |

### 3.3 病理知识库

| 属性 | 说明 |
|------|------|
| **规模** | 约 150 万条病理知识记录 |
| **内容** | 疾病症状、诊断标准、治疗方案、药物相互作用、禁忌症等 |
| **用途** | 为小艺智能体提供医学知识支撑，提升回答准确性 |
| **集成方式** | 通过 RAG（检索增强生成）技术按需检索相关知识片段 |

### 3.4 MCP 协议实现详情

项目通过 `XiaoyiSkillManager` 实现了标准的 **Model Context Protocol (MCP)** Server：

#### 核心文件

| 文件 | 路径 | 职责 |
|------|------|------|
| **MCP Server 核心** | `xiaoyi/XiaoyiSkillManager.ets` | Skill 注册、MCP 消息处理、能力声明、工具调用分发 |
| **MCP 类型定义** | `xiaoyi/types/XiaoyiTypes.ets` | MCPMessage / MCPCapability / MCPTool / MCPResource / MCPPrompt / MCPError |

#### 支持的 MCP 方法

| 方法 | 功能 | 返回内容 |
|------|------|----------|
| `tools/list` | 列出所有已注册的医疗工具 | MCPTool[] |
| `tools/call` | 调用指定工具执行操作 | 执行结果（文本+UI 数据） |
| `resources/list` | 列出可用健康资源 | MCPResource[] |
| `resources/read` | 读取指定 URI 的资源数据 | JSON 格式健康数据 |
| `prompts/list` | 列出提示词模板 | MCPPrompt[] |

#### 注册的 MCP 资源（Resources）

| URI | 名称 | MIME 类型 | 内容示例 |
|-----|------|-----------|----------|
| `medical://health/data/latest` | 最新健康数据 | application/json | `{ bloodPressure, heartRate, bloodSugar, ... }` |
| `medical://risk/assessment` | 风险评估报告 | application/json | `{ overallRisk, level, suggestions }` |

#### 注册的 MCP 提示词模板（Prompts）

| 名称 | 用途 |
|------|------|
| `symptom_analysis` | 症状分析提示词模板（引导 AI 结构化分析症状） |
| `medication_consult` | 用药咨询提示词模板（确保安全用药原则） |

---

## 四、Skill 离线包完整清单

所有 Skill 位于 `entry/src/main/ets/xiaoyi/skills/` 目录。

### 4.1 已实现的 Skill（2 个）

#### S1 — 健康数据查询 (`HealthQuerySkill.ets`)

| 属性 | 值 |
|------|-----|
| **Skill ID** | `medical.query.health` |
| **Skill 名称** | 健康数据查询 |
| **触发语** | "查血压"、"血糖多少"、"心率情况"、"健康数据"、"最近体重" |
| **支持指标** | 血压、血糖、心率、体重、血氧、体温、步数 |
| **输出形式** | 语音播报 + UI 卡片双通道 |
| **所需权限** | `ohos.permission.READ_HEALTH_DATA` |
| **预计耗时** | ~500ms |
| **降级动作** | 打开 `AddHealthRecord` 页面引导录入 |

#### S2 — AI 智能问诊 (`AIConsultationSkill.ets`)

| 属性 | 值 |
|------|-----|
| **Skill ID** | `medical.ai.consultation` |
| **Skill 名称** | AI 智能问诊 |
| **触发语** | "我不舒服"、"头疼怎么办"、"打开 AI 问诊"、"身体不适" |
| **处理流程** | 提取症状 → 调用 DeepSeek 分析 → 生成语音回复 → 打开 AiChatPage |
| **输出内容** | 可能原因、建议科室、风险等级、后续建议 |
| **预计耗时** | ~3000ms（含 API 调用） |
| **降级动作** | 打开 `AiChatPage` 手动输入 |

### 4.2 已注册但文件缺失的 Skill（6 个）

> ⚠️ 以下 Skill 在 `XiaoyiSkillManager.ets` 中已注册并路由，但对应的 `.ets` 实现文件在清理过程中被删除，需要补充实现或移除引用。

| # | Skill ID | 名称 | 触发语 | 功能说明 | 状态 |
|---|----------|------|--------|---------|------|
| **S3** | `medical.risk.assess` | 健康风险评估 | "评估我的健康风险" | 综合多维度数据计算风险评分 | ❌ 缺失文件 |
| **S4** | `medical.medication.remind` | 用药提醒管理 | "提醒我吃药" | 创建/查询/确认用药提醒 | ❌ 缺失文件 |
| **S5** | `medical.navigation.start` | 院内导航 | "导航到内科" | AR 路径规划 + 语音导引 | ❌ 缺失文件 |
| **S6** | `medical.emergency.sos` | 紧急呼救 | "救命"、"拨打 120" | 一键 SOS + 定位 + 通知医护 | ❌ 缺失文件 |
| **S7** | `medical.device.connect` | 设备连接 | "连接血压计" | IoT 发现/配对/数据同步 | ❌ 缺失文件 |
| **S8** | `medical.rehab.start` | 康复训练 | "开始康复训练" | 启动 3D 康复课程 | ❌ 缺失文件 |

### 4.3 Skill ↔ MCP Tool 映射表

| MCP Tool Name（外部调用名） | 内部 Skill ID | Skill 中文名称 |
|---------------------------|---------------|---------------|
| `medical_query_health` | `medical.query.health` | 健康数据查询 |
| `medical_risk_assess` | `medical.risk.assess` | 健康风险评估 |
| `medical_medication_remind` | `medical.medication.remind` | 用药提醒管理 |
| `medical_navigation_start` | `medical.navigation.start` | 院内导航 |
| `medical_ai_consultation` | `medical.ai.consultation` | AI 智能问诊 |
| `medical_emergency_sos` | `medical.emergency.sos` | 紧急呼救 |
| `medical_device_connect` | `medical.device.connect` | 设备连接 |
| `medical_rehab_start` | `medical.rehab.start` | 康复训练 |

### 4.4 Skill 统一接口规范

每个 Skill 必须实现以下接口：

```typescript
interface XiaoyiSkillDefinition {
  config: {
    skillId: string;           // 唯一标识
    skillName: string;         // 显示名称
    skillDescription: string;  // 功能描述
    version: string;            // 版本号
    author: string;             // 作者
  };
  intentPatterns: IntentPattern[];  // 语音触发模式数组
  handler: string;                   // 处理函数名字符串
  needAuth: boolean;                 // 是否要求登录
  needPermission?: string[];         // HarmonyOS 权限列表
  responseType: 'voice' | 'ui' | 'voice+ui';
  fallbackAction?: string;           // 降级时打开的页面
  estimatedTime?: number;            // 预计耗时(ms)
}
```

---

## 五、AI 编排层调用链路

### 5.1 典型请求流转

```
用户说："小艺，帮我查一下血压"
        │
        ▼
[ XiaoyiAgent ] ← 语音转文字 + 意图识别
        │
        ▼
[ XiaoyiSkillManager.autoRouteAndProcess() ]
        │  ← 关键词匹配 → medical.query.health
        ▼
[ HealthQuerySkill.handle() ]
        │
        ├──→ [ HealthDataManager ] 获取最新血压数据
        │
        └──→ 返回 XiaoyiSkillResponse {
                voiceResponse: "您最新的血压是125比82...",
                uiResponse: { pageRoute: "pages/HealthRecordDetail", ... },
                action: { type: "navigate", target: "..." }
             }
```

### 5.2 AI 多科会诊流转（页面端）

```
用户在 AiConsultationPage 选择症状 → 点击"开始会诊"
        │
        ▼
[ 四位 AI 医生依次发言 ]
  中医·李杏林  → 西医·王明哲  → 蒙医·巴特尔  → 全科·陈思远
        │
        ▼
[ 汇总结论展示 ]
```

---

## 六、外部依赖速查表

| 服务 | 类型 | 协议 | 用途 | 配置文件 |
|------|------|------|------|----------|
| **SiliconFlow** | 云端 LLM | HTTPS REST | DeepSeek-V3 推理 | `common/constants/SiliconFlowConfig.ets` |
| **Coze** | 工作流 Bot | HTTPS REST | 三专科智能体编排 | `common/constants/CozeConfig.ts` |
| **HiAI** | 端侧 NPU | Native SDK | 图像分类/OCR/姿态检测 | `common/constants/HiAIConfig.ets` |
| **MindSpore Lite** | 端侧推理 | Native SDK | 轻量离线推理 | `mindsphere/MindSporeLiteEngine.ets` |
| **Xiaoyi（小艺）** | 语音 Skill | MCP Protocol | 5 子智能体 + 8 Skill + 150万知识库 | `xiaoyi/XiaoyiSkillManager.ets` |
| **WebSocket** | 实时通信 | WS Protocol | 医患聊天 | `network/WebSocketClient.ets` |
| **后端 API** | 业务服务 | HTTPS REST | SpringBoot 后端通信 | `api/PatientApiService.ets` |

---

## 七、开源链接汇总

| 项目 | 链接 | 许可证 |
|------|------|--------|
| **DeepSeek** | https://github.com/deepseek-ai | MIT |
| **硅基流动 SiliconFlow** | https://platform.siliconflow.cn | 商业 API |
| **Coze 扣子** | https://www.coze.cn | 商业平台 |
| **华为 HiAI** | https://developer.huawei.com/consumer/cn/hiai | 商业 SDK |
| **MindSpore** | https://github.com/mindspore-ai | Apache 2.0 |
| **HarmonyOS** | https://developer.huawei.com/consumer/cn/harmonyos | Apache 2.0 |
| **ArkUI** | https://developer.huawei.com/consumer/cn/arkui | Apache 2.0 |
