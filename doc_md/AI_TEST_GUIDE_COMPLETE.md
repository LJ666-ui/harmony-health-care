# 🤖 AI功能完整测试指南

> **项目**: harmony-health-care (鸿蒙智慧医疗健康系统)
> **更新时间**: 2026-05-13
> **统计**: 共 **51个页面** 集成了AI功能，**100+处** AI调用点

---

## 📊 AI功能总览图

```
┌─────────────────────────────────────────────────────────────┐
│                    AI统一调度层 (AIOrchestrator)              │
├─────────────────────────────────────────────────────────────┤
│  小艺Skill │ DeepSeek大模型 │ Coze专业Bot │ HiAI端侧推理    │
└─────┬───────┴───────┬───────┴───────┬───────┴───────┬───────┘
      │               │               │               │
      ▼               ▼               ▼               ▼
┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐
│ 语音助手  │  │ 健康咨询  │  │ 专科问诊  │  │ 康复指导  │
│ AR导航    │  │ 风险评估  │  │ 影像分析  │  │ 动作纠正  │
└──────────┘  └──────────┘  └──────────┘  └──────────┘
```

---

## 🎯 快速导航：按优先级测试

### 🔴 P0 - 核心AI功能（必测）

| 序号 | 页面名称 | 文件路径 | AI功能 | 测试入口 |
|------|---------|---------|--------|---------|
| 1 | **AI智能问诊** | `pages/AiConsultationPage.ets` | 多轮对话+流式输出 | [→ 测试方法](#1-ai智能问诊) |
| 2 | **AI通用聊天** | `pages/AiChatPage.ets` | 流式对话+多Agent路由 | [→ 测试方法](#2-ai通用聊天) |
| 3 | **康复课程推荐** | `pages/RehabListPage.ets` | AI筛选+个性化推荐 | [→ 测试方法](#3-康复课程推荐) |
| 4 | **3D康复训练** | `pages/Rehab3DPage.ets` | AI实时动作纠正 | [→ 测试方法](#4-3d康复训练) |
| 5 | **在线问诊辅助** | `pages/ConsultationPage.ets` | AI科室推荐+分诊指导 | [→ 测试方法](#5-在线问诊辅助) |

### 🟡 P1 - 重要AI功能（建议测试）

| 序号 | 页面名称 | 文件路径 | AI功能 | 测试入口 |
|------|---------|---------|--------|---------|
| 6 | **家庭护士聊天** | `pages/FamilyNurseChatPage.ets` | 护理指导+健康提醒 | [→ 测试方法](#6-家庭护士聊天) |
| 7 | **患者医生聊天** | `pages/PatientDoctorChatPage.ets` | AI聊天辅助 | [→ 测试方法](#7-患者医生聊天) |
| 8 | **语音助手** | `pages/VoiceAssistantPage.ets` | 语音识别+意图理解 | [→ 测试方法](#8-语音助手) |
| 9 | **健康记录详情** | `pages/HealthRecordDetail.ets` | AI数据分析 | [→ 测试方法](#9-健康记录分析) |
| 10 | **康复方案生成** | `pages/RehabPage.ets` | AI个性化训练计划 | [→ 测试方法](#10-康复方案生成) |

### 🟢 P2 - 扩展AI功能（可选测试）

#### 手表系列（7个页面）

| 序号 | 页面名称 | AI功能 |
|------|---------|--------|
| 11 | **WatchHomePage** | AI健康摘要生成 |
| 12 | **WatchSportPage** | AI运动建议 |
| 13 | **WatchSleepPage** | AI睡眠分析 |
| 14 | **WatchEmergencyPage** | AI急救指导 |
| 15 | **WatchMedicationPage** | AI用药提醒 |
| 16 | **WatchHealthMonitorPage** | AI异常检测 |
| 17 | **WatchMessagePage** | AI消息处理 |

#### 家庭医生模块（3个页面）

| 序号 | 页面名称 | AI功能 |
|------|---------|--------|
| 18 | **FamilyDoctorPage** | AI病情总结 |
| 19 | **FamilyNurseListPage** | AI成员状态分析 |
| 20 | **FamilyHome** | AI健康概览 |

#### 其他AI页面（9个页面）

| 序号 | 页面名称 | AI功能 |
|------|---------|--------|
| 21 | **FamilyFollowUp** | AI随访建议 |
| 22 | **FamilyPrescription** | AI处方解读 |
| 23 | **FamilyMedication** | AI药物相互作用 |
| 24 | **FamilyMedicalRecords** | AI病历分析 |
| 25 | **FamilyHealthRecords** | AI趋势分析 |
| 26 | **FamilyPatientDetail** | AI风险评估 |
| 27 | **FamilyDiagnosis** | AI诊断辅助 |
| 28 | **AddHealthRecord** | AI数据校验 |
| 29 | **MedicationDetailPage** | AI药品说明 |

#### 智能病房系列（6个页面）

| 序号 | 页面名称 | AI功能 |
|------|---------|--------|
| 30 | **SmartWardCarePlan** | AI护理计划建议 |
| 31 | **SmartWardAlerts** | AI预警分析 |
| 32 | **SmartWardDevices** | AI设备诊断 |
| 33 | **SmartWardCarePlanSimple** | 简化版护理AI |
| 34 | **SmartWardAlertsSimple** | 简化版警报AI |
| 35 | **SmartWardDevicesSimple** | 简化版设备AI |

#### 医护端AI（4个页面）

| 序号 | 页面名称 | AI功能 |
|------|---------|--------|
| 36 | **DoctorChatPage** | AI诊断辅助 |
| 37 | **DoctorFamilyChatPage** | AI沟通辅助 |
| 38 | **NurseChatPage** | AI护理建议 |
| 39 | **PatientNurseChatPage** | AI问答辅助 |

#### 其他页面（12个页面）

| 序号 | 页面名称 | AI功能 |
|------|---------|--------|
| 40 | **FamilyChatListPage** | AI消息摘要 |
| 41 | **HealthPage** | AI综合健康建议 |
| 42 | **EmergencyPage** | AI急救响应指导 |
| 43 | **RehabilitationPage** | AI康复方案推荐 |
| 44 | **RiskAssessmentPage** | AI风险计算 |
| 45 | **ImageAnalysisPage** | AI影像识别 |
| 46 | **AITestPage** | AI功能调试 |
| 47 | **AIAssistantPage** | AI综合助手 |
| 48 | **VoiceAssistantPage** | 语音识别+意图理解 |
| 49 | **HealthRecordDetail** | AI数据分析 |
| 50 | **ConsultationPage** | AI科室推荐+分诊 |
| 51 | **PatientDoctorChatPage** | AI聊天辅助 |

---

## 📝 详细测试指南

---

### 1️⃣ AI智能问诊

**📍 页面位置**: `entry/src/main/ets/pages/AiConsultationPage.ets`
**🚀 路由地址**: `pages/AiConsultationPage`

#### AI功能说明

| 功能 | 方法名 | 行号 | 说明 |
|------|--------|------|------|
| **流式对话** | `sendQuestion()` | L50 | 使用 `orchestrator.processStream()` 实现打字机效果 |
| **生成诊断报告** | `generateReport()` | L171 | AI分析症状并生成结构化报告 |
| **治疗建议** | `generateTreatmentSuggestion()` | L187 | AI提供个性化治疗方案 |

#### 测试步骤

```
步骤1: 打开应用 → 底部导航栏 → "AI问诊" 或 "智能问诊"
步骤2: 在输入框输入症状描述，例如:
       ✅ "头痛，持续3天，伴有恶心"
       ✅ "血压高，最近经常头晕"
       ✅ "咳嗽一周，有痰，低烧"
步骤3: 点击"发送"按钮
步骤4: 观察AI回复是否以流式方式逐字显示
步骤5: 查看"诊断报告"和"治疗建议"卡片是否自动生成
```

#### 预期结果

- ✅ AI回复在2-5秒内开始显示
- ✅ 回复内容以打字机效果逐字出现
- ✅ 诊断报告包含可能的疾病、紧急程度、建议科室
- ✅ 治疗建议包含用药、饮食、注意事项
- ❌ 如果显示"AI暂时不可用"，检查网络和API配置

---

### 2️⃣ AI通用聊天

**📍 页面位置**: `entry/src/main/ets/pages/AiChatPage.ets`
**🚀 路由地址**: `pages/AiChatPage`

#### AI功能说明

| 功能 | 方法名 | 行号 | 说明 |
|------|--------|------|------|
| **普通对话** | `sendMessage()` | L202 | 标准AI对话 |
| **流式对话** | `sendStreamMessage()` | L484 | 流式输出体验 |

#### 测试步骤

```
步骤1: 打开应用 → "AI助手" 或 "智能聊天"
步骤2: 输入各种类型的问题测试AI路由能力:

  【小艺Skill测试】(语音/导航类)
  → "帮我挂号张医生明天上午"
  → "导航去内科"
  
  【DeepSeek测试】(医学知识类)
  → "高血压饮食注意什么"
  → "感冒了吃什么药好"
  
  【Coze Bot测试】(专科问题)
  → "眼科专家，我的视力模糊"
  → "康复科，术后如何恢复"

步骤3: 观察回复底部显示的 "AI来源" 标识
```

#### AI自动路由规则

| 输入关键词 | 路由到 | AI标识 |
|-----------|--------|--------|
| 挂号、预约、导航、AR | 小艺 (Xiaoyi) | `xiaoyi` |
| 为什么、怎么办、副作用 | DeepSeek | `deepseek` |
| 专科、手术、详细诊断 | Coze Bot | `coze_bot` |
| 风险、评估、预测 | MindSpore | `mindspore` |

---

### 3️⃣ 康复课程推荐

**📍 页面位置**: `entry/src/main/ets/pages/RehabListPage.ets`
**🚀 路由地址**: `pages/RehabListPage`

#### AI功能说明

| 功能 | 方法名 | 行号 | 说明 |
|------|--------|------|------|
| **AI推荐** | `getAICourseRecommendation()` | L265 | AI根据用户情况推荐康复课程 |
| **AI筛选** | `filterCoursesWithAI()` | L289 | AI智能过滤不合适的课程 |

#### 测试步骤

```
步骤1: 打开应用 → "康复训练" → "康复课程列表"
步骤2: 找到并点击 "AI智能推荐" 按钮
步骤3: 观察AI推荐的课程列表（会有高亮标记）
步骤4: 尝试点击 "AI筛选" 按钮（如果有）
步骤5: 对比筛选前后的课程数量变化
```

---

### 4️⃣ 3D康复训练

**📍 页面位置**: `entry/src/main/ets/pages/Rehab3DPage.ets`
**🚀 路由地址**: `pages/Rehab3DPage`

#### AI功能说明

| 功能 | 方法名 | 行号 | 说明 |
|------|--------|------|------|
| **AI动作评分** | `analyzeMovementWithAI()` | L192 | 分析用户动作标准度 |
| **AI纠正指导** | `getAICorrectionGuidance()` | L204 | 实时纠正错误姿势 |

#### 测试步骤

```
步骤1: 打开应用 → "康复训练" → "3D康复训练"
步骤2: 选择一个康复课程（如颈椎康复）
步骤3: 开始训练，按照屏幕提示做动作
步骤4: 训练结束后查看AI评分和纠正建议
步骤5: 观察3D模型是否同步显示动作
```

#### 预期结果

- ✅ AI给出0-100的动作评分
- ✅ 提供具体的纠正建议（如"手臂抬得更高一点"）
- ✅ 3D模型与AI分析联动
- ✅ 显示改进建议和下次训练重点

---

### 5️⃣ 在线问诊辅助

**📍 页面位置**: `entry/src/main/ets/pages/ConsultationPage.ets`
**🚀 路由地址**: `pages/ConsultationPage`

#### AI功能说明

| 功能 | 方法名 | 行号 | 说明 |
|------|--------|------|------|
| **AI科室推荐** | `getAIDepartmentRecommendation()` | L171 | 根据症状推荐就诊科室 |
| **AI分诊指导** | `getAITriageGuidance()` | L186 | 判断紧急程度并给出建议 |

#### 测试步骤

```
步骤1: 打开应用 → "在线问诊"
步骤2: 在症状描述框输入:
       "胸口疼痛，呼吸困难，持续10分钟"
步骤3: 点击 "AI推荐科室" 按钮
步骤4: 查看AI推荐的科室和建议
步骤5: 点击 "AI分诊" 查看紧急程度判断
```

---

### 6️⃣ 家庭护士聊天

**📍 页面位置**: `entry/src/main/ets/pages/FamilyNurseChatPage.ets`
**🚀 路由地址**: `pages/FamilyNurseChatPage`

#### AI功能说明

| 功能 | 方法名 | 行号 | 说明 |
|------|--------|------|------|
| **AI护理指导** | `getNursingGuidanceFromAI()` | L304 | 针对特定护理问题的专业指导 |
| **AI健康提醒** | `generateHealthReminder()` | L324 | 自动生成个性化健康提醒 |

#### 测试步骤

```
步骤1: 打开应用 → "家庭医护" → "护士聊天"
步骤2: 找到 "获取AI护理指导" 按钮并点击
步骤3: 选择或输入护理主题（如"糖尿病护理"、"术后护理"）
步骤4: 查看AI生成的详细护理指导
步骤5: 点击 "生成今日健康提醒" 
步骤6: 查看个性化的健康建议
```

---

### 7️⃣ 患者医生聊天

**📍 页面位置**: `entry/src/main/ets/pages/PatientDoctorChatPage.ets`
**🚀 路由地址**: `pages/PatientDoctorChatPage`

#### AI功能

- **AI聊天辅助** (`getAIChatAssistance()`, L298): 帮助患者更好地表达症状
- **AI消息优化** (`optimizeMessageWithAI()`, L319): 优化患者发送的消息

#### 测试步骤

```
步骤1: 打开应用 → "我的医生" → 选择医生 → 进入聊天
步骤2: 输入模糊描述如 "我不舒服"
步骤3: 点击 "AI帮我完善" 按钮
步骤4: 查看AI优化后的更专业的描述
```

---

### 8️⃣ 语音助手

**📍 页面位置**: `entry/src/main/ets/pages/VoiceAssistantPage.ets`
**🚀 路由地址**: `pages/VoiceAssistantPage`

#### 测试命令

```
【挂号类】"帮我挂明天的号"、"预约张医生周三上午"
【导航类】"导航去内科"、"药房在哪里"
【查询类】"我的预约有哪些"、"今天有什么药要吃"
【紧急类】"救命！我不舒服"、"拨打120"
```

---

### 9️⃣ 健康记录分析

**📍 页面位置**: `entry/src/main/ets/pages/HealthRecordDetail.ets`
**🚀 路由地址**: `pages/HealthRecordDetail`

#### AI功能: **AI数据解读** (`analyzeWithAI()`, L128)

测试步骤: 打开健康记录详情页 → 点击 "AI分析" 按钮 → 查看数据分析和建议

---

### 🔟 康复方案生成

**📍 页面位置**: `entry/src/main/ets/pages/RehabPage.ets`
**🚀 路由地址**: `pages/RehabPage`

#### AI功能: **AI训练计划** (`generateAITrainingPlan()`, L40)

测试步骤: 打开康复服务页 → 点击 "AI生成训练计划" → 查看个性化方案

---

## 🔧 AI配置与调试

### API密钥配置

| AI引擎 | 配置文件 | 配置项 |
|--------|---------|--------|
| **DeepSeek** | `DeepSeekConfig.ts` | `DEEPSEEK_API_KEY` |
| **硅基流动** | `SiliconFlowClient.ts` | `SILICONFLOW_API_KEY` |
| **Coze** | `CozeApiClient.ts` | `COZE_API_KEY`, `COZE_BOT_ID` |
| **HiAI** | `HiAIVisionClient.ts` | NPU端侧（无需API Key） |

### 查看AI日志

在DevEco Studio的Log窗口搜索: `[AIOrchestrator]`, `[DeepSeekAgent]`, `[XiaoyiAgent]`, `[CozeAgent]`

### 常见问题排查

| 问题 | 可能原因 | 解决方案 |
|------|---------|---------|
| 显示"AI暂时不可用" | 网络问题/API未配置 | 检查网络和API密钥 |
| AI回复很慢 | API超时/服务器繁忙 | 增加超时时间或重试 |
| 路由到错误的AI | IntentRouter配置 | 检查关键词匹配规则 |

---

## 📈 AI性能基准

| 指标 | 目标值 |
|------|--------|
| **首字响应时间** | <2秒 |
| **完整响应时间** | <10秒 |
| **流式输出延迟** | <500ms |
| **准确率** | >85% |

---

## ✅ 测试清单

### P0核心功能（必测）

- [ ] **AiConsultationPage** - 流式对话正常
- [ ] **AiConsultationPage** - 诊断报告生成正常
- [ ] **AiChatPage** - 多Agent路由正确
- [ ] **AiChatPage** - 流式输出流畅
- [ ] **RehabListPage** - AI课程推荐有效
- [ ] **Rehab3DPage** - AI动作评分合理
- [ ] **ConsultationPage** - 科室推荐准确

### P1重要功能（建议测试）

- [ ] **FamilyNurseChatPage** - 护理指导专业
- [ ] **VoiceAssistantPage** - 语音识别可用
- [ ] **HealthRecordDetail** - 数据分析有价值

### 配置验证

- [ ] DeepSeek API Key 已配置
- [ ] Coze Bot ID 已配置
- [ ] 网络连接正常
- [ ] 日志无报错

---

**祝测试顺利！如有问题随时反馈 🚀**
