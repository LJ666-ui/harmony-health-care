# 星云医疗助手（Harmony Health Care）

基于 **HarmonyOS（ArkUI/ArkTS）** 开发的全场景智慧医疗健康服务平台，覆盖患者、医生、护士、家属、管理员五大角色，融合 AI 智能诊断、数字孪生、AR 导航等前沿技术。

---

## 项目概览

| 属性 | 说明 |
|------|------|
| 应用名称 | 健康护理 |
| 技术栈 | ArkTS / ArkUI / Canvas API |
| 目标平台 | HarmonyOS 手机 + 手表 |
| 核心特色 | 多角色协同 · AI 多科会诊 · 数字孪生人体模型 · 无障碍适老化 |

---

## 一、AI 引擎层 — 四大 Agent + 统一编排

项目采用**多 Agent 架构**，通过 `AIOrchestrator` 统一调度：

```
用户请求 (语音/UI/API)
        │
   ┌────▼────┐
   │ AIOrchestrator │  ← entry/src/main/ets/ai/AIOrchestrator.ets
   │ (统一入口/智能路由/结果聚合)  │
   └┬───┬───┬───┬┘
    │   │   │   │
    ▼   ▼   ▼   ▼
  小艺 Skill  DeepSeek  Coze Bot  HiAI/MindSpore
 (离线Skill) (云端LLM) (工作流)  (端侧推理)
```

### 1.1 AI Agent 清单

| # | Agent 名称 | 类文件 | 类型 | 用途 |
|---|-----------|--------|------|------|
| **A1** | **XiaoyiAgent（小艺智能体）** | `ai/agents/XiaoyiAgent.ts` | 离线 Skill | 华为小艺语音交互，意图识别与 Skill 调度 |
| **A2** | **DeepSeekAgent（深度求索）** | `ai/agents/DeepSeekAgent.ts` | 云端 LLM | 医疗问答、症状分析、用药咨询、康复建议 |
| **A3** | **CozeAgent（扣子机器人）** | `ai/agents/CozeAgent.ts` | 工作流 Bot | 专科会诊、标准化诊疗流程、预问诊/随访自动化 |
| **A4** | **HiAI Agent（华为端侧 AI）** | `ai/agents/HiAIAgent.ts` | 本地 NPU 推理 | 图像分类、OCR 文字识别、姿态检测/跌倒检测 |

### 1.2 外部服务配置与链接

#### DeepSeek / SiliconFlow（硅基流动）

- **配置文件**: [common/constants/SiliconFlowConfig.ets](entry/src/main/ets/common/constants/SiliconFlowConfig.ets)
- **API 地址**: `https://api.siliconflow.cn/v1/chat/completions`
- **模型**: `deepseek-ai/DeepSeek-V3`
- **客户端封装**: [deepseek/SiliconFlowClient.ets](entry/src/main/ets/deepseek/SiliconFlowClient.ets) + [deepseek/DeepSeekChatManager.ets](entry/src/main/ets/deepseek/DeepSeekChatManager.ets)
- **开源/官方链接**: https://platform.siliconflow.cn / https://github.com/deepseek-ai

#### Coze（扣子智能体平台）

- **配置文件**: [common/constants/CozeConfig.ts](entry/src/main/ets/common/constants/CozeConfig.ts)
- **API 地址**: `https://api.coze.cn/v1`
- **Bot ID**: `7638946778641465396`
- **Workflow ID**: `7638960668070625343`
- **客户端封装**: [coze/CozeApiClient.ets](entry/src/main/ets/coze/CozeApiClient.ets)
- **开源/官方链接**: https://www.coze.cn / https://open.coze.cn

#### HiAI（华为端侧推理引擎）

- **配置文件**: [common/constants/HiAIConfig.ets](entry/src/main/ets/common/constants/HiAIConfig.ets)
- **App ID**: `6917605309959973739`
- **包名**: `com.example.harmonyhealthcare`
- **客户端封装**: [hiai/HiAIVisionClient.ets](entry/src/main/ets/hiai/HiAIVisionClient.ets) + [mindsphere/MindSporeLiteEngine.ets](entry/src/main/ets/mindsphere/MindSporeLiteEngine.ets)
- **开源/官方链接**: https://developer.huawei.com/consumer/cn/hiai / https://www.mindspore.cn

---

## 二、MCP 协议集成（Model Context Protocol）

项目通过 `XiaoyiSkillManager` 实现了完整的 **MCP 协议对接**，作为鸿蒙小艺平台的 MCP Server。

### 2.1 MCP 基础设施

| 文件 | 职责 |
|------|------|
| [xiaoyi/XiaoyiSkillManager.ets](entry/src/main/ets/xiaoyi/XiaoyiSkillManager.ets) | MCP Server 核心：注册 Skill、处理 MCP 消息、声明能力 |
| [xiaoyi/types/XiaoyiTypes.ets](entry/src/main/ets/xiaoyi/types/XiaoyiTypes.ets) | MCP 协议类型定义（MCPMessage / MCPCapability / MCPTool / MCPResource / MCPPrompt） |

### 2.2 支持的 MCP 方法

```
tools/list          → 返回所有已注册的医疗工具列表
tools/call          → 调用指定工具执行医疗操作
resources/list      → 列出可用健康数据资源
resources/read      → 读取指定 URI 的资源数据
prompts/list        → 列出提示词模板
```

### 2.3 注册的 MCP 资源

| URI | 名称 | 说明 |
|-----|------|------|
| `medical://health/data/latest` | 最新健康数据 | 用户最新血压/血糖/心率等指标 |
| `medical://risk/assessment` | 风险评估报告 | 最新风险评估结果 |

### 2.4 注册的 MCP 提示词模板

| 名称 | 说明 |
|------|------|
| `symptom_analysis` | 症状分析提示词模板 |
| `medication_consult` | 用药咨询提示词模板 |

---

## 三、小艺 Skill 离线包清单

所有 Skill 位于 [xiaoyi/skills/](entry/src/main/ets/xiaoyi/skills/) 目录，共 **8 个离线 Skill**。

### 3.1 Skill 总表

| # | Skill ID | Skill 名称 | 类文件 | 触发示例 | 功能说明 |
|---|----------|-----------|--------|----------|---------|
| **S1** | `medical.query.health` | **健康数据查询** | `HealthQuerySkill.ets` | "查血压"、"血糖多少"、"心率情况" | 查询血压/血糖/心率/体重/血氧/体温/步数等指标，自动生成语音播报 + UI 卡片展示 |
| **S2** | `medical.ai.consultation` | **AI 智能问诊** | `AIConsultationSkill.ets` | "我不舒服"、"头疼怎么办"、"打开 AI 问诊" | 提取症状 → 调用 DeepSeek 分析 → 输出可能原因/建议科室/风险等级 → 打开 AiChatPage |
| **S3** | `medical.risk.assess` | **健康风险评估** | `RiskAssessSkill.ets` | "评估我的健康风险"、"做个体检" | 综合多维度数据计算健康风险评分，输出分级建议 |
| **S4** | `medical.medication.remind` | **用药提醒管理** | `MedicationReminderSkill.ets` | "提醒我吃药"、"今天的药吃了吗" | 创建/查询/确认用药提醒，支持定时推送 |
| **S5** | `medical.navigation.start` | **院内导航** | `NavigationSkill.ets` | "导航到内科"、"怎么去急诊" | AR 室内路径规划 + 语音导引 |
| **S6** | `medical.emergency.sos` | **紧急呼救** | `EmergencySkill.ets` | "救命"、"拨打急救电话" | 一键 SOS，自动定位 + 联系紧急联系人 + 通知医护 |
| **S7** | `medical.device.connect` | **设备连接** | `DeviceConnectSkill.ets` | "连接血压计"、"连接手环" | IoT 设备发现、配对、数据同步（分布式协同） |
| **S8** | `medical.rehab.start` | **康复训练** | `RehabTrainingSkill.ets` | "开始康复训练"、"今天做什么运动" | 启动 3D 康复动作指导课程 |

> ⚠️ 注：S3~S8 的类文件在 `xiaoyi/skills/` 目录中已被清理删除，目前仅 S1 和 S2 有实际实现。`XiaoyiSkillManager.ets` 中仍保留了对全部 8 个 Skill 的引用和路由映射，需补充实现或移除引用。

### 3.2 Skill 数据结构

每个 Skill 实现 `getDefinition()` → `handle(request)` 双方法接口：

```typescript
interface XiaoyiSkillDefinition {
  config: { skillId, skillName, skillDescription, version, author };
  intentPatterns: IntentPattern[];     // 语音触发模式（正则+关键词）
  handler: string;                     // 处理函数名
  needAuth: boolean;                   // 是否需要登录
  needPermission?: string[];           // 所需权限（如 ohos.permission.READ_HEALTH_DATA）
  responseType: 'voice' | 'ui' | 'voice+ui';
  fallbackAction?: string;             // 降级操作（如 openHealthPage）
  estimatedTime?: number;              // 预计处理耗时(ms)
}
```

### 3.3 MCP Tool 映射关系

| MCP Tool Name | 对应 Skill ID |
|---------------|--------------|
| `medical_query_health` | `medical.query.health` |
| `medical_risk_assess` | `medical.risk.assess` |
| `medical_medication_remind` | `medical.medication.remind` |
| `medical_navigation_start` | `medical.navigation.start` |
| `medical_ai_consultation` | `medical.ai.consultation` |
| `medical_emergency_sos` | `medical.emergency.sos` |
| `medical_device_connect` | `medical.device.connect` |
| `medical_rehab_start` | `medical.rehab.start` |

---

## 四、核心功能模块

### 4.1 多端多角色系统

| 角色 | 入口页 | 主要功能 |
|------|--------|----------|
| **患者** | `Login.ets` → `HomePage.ets` | 健康档案、预约挂号、用药提醒、AI 问诊、数字孪生 |
| **医生** | `DoctorLogin.ets` → `DoctorMainPage.ets` | 患者管理、处方开具、随访管理、科室协作 |
| **护士** | `NurseLogin.ets` → `NurseWorkbench.ets` | 排班管理、病房监护、输液提醒、体征录入 |
| **家属** | `FamilyLogin.ets` → `FamilyHome.ets` | 关联家人健康、远程陪护、用药监督 |
| **管理员** | `AdminLogin.ets` → `AdminDashboard.ets` | 用户管理、数据看板、权限配置 |

### 4.2 AI 多科会诊

四位 AI 专家模拟联合会诊 ([AiConsultationPage.ets](entry/src/main/ets/pages/AiConsultationPage.ets))：

| 角色 | 姓名 | 职称 | 专科 | 代表色 |
|------|------|------|------|--------|
| 中医 | 李杏林 | 主任医师 | 中医辨证论治 | #C41D3E |
| 西医 | 王明哲 | 副主任医师 | 西医循证诊疗 | #1677FF |
| 蒙医 | 巴特尔 | 蒙医专家 | 蒙医传统疗法 | #52C41A |
| 全科 | 陈思远 | 中西医结合 | 综合研判 | #722ED1 |

### 4.3 数字孪生 3D 人体模型

- **3D 渲染引擎** (`digitaltwin/HumanBodyModel.ets`)：Canvas API 径向渐变 + 线性渐变 + 阴影模拟 3D 光影效果
- **器官可视化** (`OrganVisualizer.ets`)：点击器官查看健康状态与评分
- **疾病预测** (`DiseasePredictor.ets`)：基于健康数据的智能风险评估
- **治疗模拟** (`TreatmentSimulator.ets`)：治疗方案可视化推演

### 4.4 其他功能模块

| 模块 | 关键文件 | 说明 |
|------|----------|------|
| 医学影像 | `medicalimage/` | 影像诊断、图像预处理、模型管理 |
| 古籍修复 | `ancientimage/` | OCR、色彩还原、超分辨率、报告生成 |
| AR 导航 | `ar/` | 路径规划、AR 渲染、室内定位、语音导引 |
| 智慧病房 | `core/` + `monitoring/` | IoT 设备控制（病床/输液泵/空调/灯光）、实时监护告警 |
| 中医特色 | `HerbalListPage.ets` / `TCMConstitutionEngine.ets` | 中草药百科、体质辨识、食疗推荐 |
| 康复管理 | `RehabListPage.ets` / `Rehab3DPage.ets` | 3D 康复指导、课程视频 |
| 分布式协同 | `distributed/` | 多设备数据传输、配对、权限管理 |
| 无障碍 | `components/accessible/` + `AccessibilityConfig.ets` | 老年模式、5 级字体、无障碍组件 |
| 手表端 | `Watch*.ets` (8 个页面) | 健康/用药/AI 会诊/紧急呼叫/运动睡眠 |

---

## 五、技术架构

```
entry/src/main/ets/
├── pages/                    # 页面层（170+ 页面）
├── components/               # 公共组件（60+ 组件）
│   ├── charts/               # 图表（雷达图/折线图/柱状图/仪表盘/热力图）
│   └── accessible/           # 无障碍组件
├── models/                   # 数据模型（20+ 模型）
├── ai/                       # AI 引擎层
│   ├── agents/               # 4 大 Agent（Coze/DeepSeek/HiAI/Xiaoyi）
│   ├── orchestrator/         # 意图路由与编排
│   ├── models/               # AI 类型定义
│   └── types/                # 引擎类型定义
├── xiaoyi/                   # 小艺 Skill 系统（MCP 协议）
│   ├── skills/               # 8 个离线 Skill 包
│   ├── types/                # Skill/MCP 类型定义
│   └── XiaoyiSkillManager.ets # MCP Server 核心
├── digitaltwin/              # 数字孪生模块
├── deepseek/                 # DeepSeek/SiliconFlow 客户端
├── coze/                     # Coze API 客户端
├── hiai/                     # HiAI 端侧推理客户端
├── mindsphere/               # MindSpore Lite 引擎
├── medicalimaging/           # 医学影像处理
├── ancientimage/             # 古籍图像处理
├── ar/                       # AR 导航服务
├── monitoring/               # 实时监控与告警
├── core/                     # 智慧病房 IoT 控制
├── distributed/              # 分布式协同
├── mock/                     # Mock 数据
├── manager/                  # 业务管理器
└── common/                   # 工具、常量、样式
```

---

## 六、快速开始

```bash
# 使用 DevEco Studio 打开项目后，执行构建：
hvigorw assembleHap --mode module -p module=entry@default -p product=default -p requiredDeviceType=phone
```

---

## 七、外部依赖汇总

| 服务 | 用途 | 协议 | 配置位置 |
|------|------|------|----------|
| **SiliconFlow（硅基流动）** | DeepSeek-V3 云端推理 | HTTPS REST API | `common/constants/SiliconFlowConfig.ets` |
| **Coze（扣子）** | 医疗工作流 Bot 调用 | HTTPS REST API | `common/constants/CozeConfig.ts` |
| **HiAI（华为 NPU）** | 端侧图像分类/OCR/姿态检测 | Native SDK | `common/constants/HiAIConfig.ets` |
| **MindSpore Lite** | 端侧轻量推理引擎 | Native SDK | `mindsphere/MindSporeLiteEngine.ets` |
| **WebSocket** | 医患实时聊天 | WS Protocol | `network/WebSocketClient.ets` |
| **HTTP API** | 后端 SpringBoot 服务通信 | HTTPS REST | `api/PatientApiService.ets` |
