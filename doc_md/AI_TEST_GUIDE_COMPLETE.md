# 🤖 AI功能完整测试指南（含智能体标注）

> **项目**: harmony-health-care (鸿蒙智慧医疗健康系统)
> **更新时间**: 2026-05-13

---

## 📊 五大智能体总览

| 智能体 | ID | 类型 | 需要网络 | 延迟 | 说明 |
|--------|-----|------|---------|------|------|
| **🟢 小艺 (Xiaoyi)** | `xiaoyi` | 端侧 | 否 | 500ms | HarmonyOS原生助手，处理挂号/导航/急救/设备控制 |
| **🔵 硅基流动DeepSeek** | `deepseek` | 云端 | 是 | 2000ms | 大语言模型，处理通用对话/医学知识/流式输出 |
| **🟣 Coze智能体** | `coze` | 云端 | 是 | 3000ms | 字节跳动AI平台，知识库问答/工作流自动化 |
| **🟠 MindSpore Lite** | `mindspore` | 端侧 | 否 | 100ms | 华为端侧推理，风险评估/健康监测/数值预测 |
| **🔴 HiAI NPU** | `hiai` | 端侧NPU | 否 | 50ms | 华为NPU硬件加速，图像识别/视觉分析 |

---

## 📊 智能体路由规则（IntentRouter）

系统通过 `IntentRouter` 根据用户输入的关键词自动路由到不同智能体：

| 输入关键词 | 路由到 | 意图类型 |
|-----------|--------|---------|
| 挂号、预约、门诊、看病、排号 | 🟢 小艺 | `appointment_booking` |
| 导航、怎么走、去XX科、AR导航 | 🟢 小艺 | `navigation` |
| 血压、血糖、心率、体检报告 | 🟠 MindSpore | `health_query` |
| 风险、评估、检查、分析、预测、筛查 | 🟠 MindSpore | `risk_assessment` |
| 救命、急救、120、晕倒、胸痛 | 🟢 小艺 | `emergency` |
| 吃药、用药、药物、提醒吃药 | 🟢 小艺 | `medication_reminder` |
| 康复、训练、运动、锻炼、太极 | 🟢 小艺 | `rehab_training` |
| 打开、启动、连接设备、配对 | 🟢 小艺 | `device_control` |
| 什么是、怎么办、为什么、副作用、禁忌、饮食 | 🔵 DeepSeek | `knowledge_query` |
| 其他（无关键词匹配） | 🔵 DeepSeek | `general_chat`（默认） |

> **重要**: 如果页面代码中设置了 `preferredAgent`，则**强制使用指定智能体**，忽略路由规则。

---

## 🎯 全部AI页面 - 按智能体分类

### 🔵 强制指定 DeepSeek 的页面（代码中写死了 `preferredAgent: 'deepseek'`）

| 页面 | 文件 | AI功能 | 怎么测试 |
|------|------|--------|---------|
| **AI智能问诊** | `AiConsultationPage.ets` | 流式对话(L91)、诊断报告(L171)、治疗建议(L187) | 底部导航→AI问诊→输入症状→观察流式输出 |
| **AI通用聊天** | `AiChatPage.ets` | 普通对话(L202)、流式对话(L484) | AI助手→输入任意问题→观察回复 |
| **语音助手** | `VoiceAssistantPage.ets` | 语音转文字后AI回答(L319) | 语音助手→说话→观察AI回复 |
| **AI测试页** | `AITestPage.ets` | DeepSeek测试(L80)、Coze测试(L91)、HiAI测试(L99) | AITestPage→点击对应测试按钮 |

### 🔴 强制指定 HiAI 的页面

| 页面 | 文件 | AI功能 | 怎么测试 |
|------|------|--------|---------|
| **AI测试页** | `AITestPage.ets` | HiAI图像识别测试(L99) | AITestPage→点击"测试HiAI"按钮 |

### 🟣 强制指定 Coze 的页面

| 页面 | 文件 | AI功能 | 怎么测试 |
|------|------|--------|---------|
| **AI测试页** | `AITestPage.ets` | Coze医疗问答测试(L91) | AITestPage→点击"测试Coze"按钮 |

### 🔴🟠 混合智能体页面（HiAI + DeepSeek 三层架构）

| 页面 | 文件 | AI功能 | 怎么测试 |
|------|------|--------|---------|
| **医学影像分析** | `ImageAnalysisPage.ets` | HiAI图像分类→规则引擎→DeepSeek深度解读 | 影像分析→上传/拍摄图片→等待三层分析完成→查看结果 |

### 🟠 MindSpore 端侧推理页面

| 页面 | 文件 | AI功能 | 怎么测试 |
|------|------|--------|---------|
| **风险评估** | `RiskAssessmentPage.ets` | MindSpore本地风险计算(降级到规则引擎) | 风险评估→填写健康数据→提交→查看雷达图和风险等级 |

### 🔵 自动路由页面（无 preferredAgent，由 IntentRouter 决定）

这些页面**没有**指定 `preferredAgent`，AI请求会经过 `IntentRouter` 根据输入内容自动路由。由于输入内容多为健康咨询/分析类文本，**实际大部分会路由到 DeepSeek**（默认兜底智能体）。

#### 手表系列

| 页面 | AI功能 | 实际路由 | 怎么测试 |
|------|--------|---------|---------|
| **WatchHomePage** | 健康摘要(L55)、智能推荐(L72) | 🔵 DeepSeek | 手表首页→点击"AI摘要"按钮 |
| **WatchSportPage** | 运动分析(L141)、训练建议(L158) | 🔵 DeepSeek | 手表运动页→点击"AI分析" |
| **WatchSleepPage** | 睡眠分析(L75)、改善建议(L92) | 🔵 DeepSeek | 手表睡眠页→点击"AI分析" |
| **WatchEmergencyPage** | 紧急分析(L97)、急救指导(L114)、分诊建议(L131) | 🟢 小艺(含"急救"关键词) | 手表紧急页→触发紧急情况→查看AI指导 |
| **WatchMedicationPage** | 用药指导(L102)、药物信息(L119) | 🟢 小艺(含"用药"关键词) | 手表用药页→选择药品→点击"AI指导" |
| **WatchHealthMonitorPage** | 健康分析(L147)、异常预警(L166)、趋势预测(L183) | 🟠 MindSpore(含"分析/预测"关键词) | 手表监测页→点击"AI分析" |
| **WatchMessagePage** | 消息摘要(L121)、紧急评估(L140) | 🔵 DeepSeek | 手表消息页→点击"AI摘要" |

#### 家庭医生模块

| 页面 | AI功能 | 实际路由 | 怎么测试 |
|------|--------|---------|---------|
| **FamilyDoctorPage** | 医生推荐(L98) | 🔵 DeepSeek | 家庭医生→点击"AI推荐医生" |
| **FamilyNurseListPage** | 护士推荐(L115) | 🔵 DeepSeek | 选择护士→点击"AI推荐" |
| **FamilyHome** | 健康仪表盘(L200)、护理建议(L217) | 🔵 DeepSeek | 家庭首页→点击"AI健康概览" |
| **FamilyDoctorChatPage** | 健康咨询(L295)、医疗建议(L309) | 🔵 DeepSeek | 家庭医生聊天→输入问题→查看AI建议 |

#### 家庭病历模块

| 页面 | AI功能 | 实际路由 | 怎么测试 |
|------|--------|---------|---------|
| **FamilyFollowUp** | 随访建议(L132)、康复计划(L149) | 🔵 DeepSeek | 复诊管理→点击"AI随访建议" |
| **FamilyPrescription** | 用药指导(L128)、药物相互作用(L146) | 🟢 小艺(含"用药"关键词) | 处方详情→点击"AI用药指导" |
| **FamilyMedication** | 用药优化(L124)、智能提醒(L141) | 🟢 小艺(含"用药"关键词) | 用药管理→点击"AI优化" |
| **FamilyMedicalRecords** | 记录摘要(L131)、健康趋势(L148) | 🔵 DeepSeek | 病历记录→点击"AI摘要" |
| **FamilyHealthRecords** | 记录分析(L188)、趋势预测(L205) | 🟠 MindSpore(含"预测"关键词) | 健康记录→点击"AI分析" |
| **FamilyPatientDetail** | 护理方案(L137)、风险评估(L152) | 🟠 MindSpore(含"风险"关键词) | 患者详情→点击"AI评估" |
| **FamilyDiagnosis** | 诊断分析(L102)、治疗建议(L116) | 🔵 DeepSeek | 诊断记录→点击"AI分析" |

#### 智能病房系列

| 页面 | AI功能 | 实际路由 | 怎么测试 |
|------|--------|---------|---------|
| **SmartWardCarePlan** | 护理优化(L126)、任务建议(L142) | 🔵 DeepSeek | 病房护理计划→点击"AI优化" |
| **SmartWardAlerts** | 警报分析(L97)、紧急响应(L113) | 🟢 小艺(含"紧急"关键词) | 病房警报→点击"AI分析" |
| **SmartWardDevices** | 设备诊断(L77)、设备优化(L91) | 🔵 DeepSeek | 病房设备→点击"AI诊断" |
| **SmartWardCarePlanSimple** | 护理建议(L22) | 🔵 DeepSeek | 简化护理→点击"AI建议" |
| **SmartWardAlertsSimple** | 警报摘要(L22) | 🔵 DeepSeek | 简化警报→点击"AI摘要" |
| **SmartWardDevicesSimple** | 设备状态(L22) | 🔵 DeepSeek | 简化设备→点击"AI检查" |

#### 医护端AI

| 页面 | AI功能 | 实际路由 | 怎么测试 |
|------|--------|---------|---------|
| **DoctorChatPage** | 症状分析(L435)、诊断辅助(L455)、追问建议(L473) | 🔵 DeepSeek(intent=pre_diagnosis) | 医生聊天→输入症状→点击"AI辅助诊断" |
| **NurseChatPage** | 护理知识(L330)、操作规范(L345) | 🔵 DeepSeek(intent=health_consultation) | 护士聊天→输入问题→查看AI回答 |
| **PatientNurseChatPage** | 护理建议(L289)、护理指导(L304) | 🔵 DeepSeek(intent=health_consultation) | 患者护士聊天→点击"AI护理建议" |
| **PatientDoctorChatPage** | 聊天辅助(L300)、消息优化(L315) | 🔵 DeepSeek(intent=health_consultation) | 患者医生聊天→输入模糊描述→点击"AI帮我完善" |

#### 其他AI页面

| 页面 | AI功能 | 实际路由 | 怎么测试 |
|------|--------|---------|---------|
| **AIAssistantPage** | 通用对话(L88) | 🔵 DeepSeek(默认) | AI助手→输入任意问题 |
| **FamilyChatListPage** | 智能摘要(L136)、紧急提醒(L151) | 🔵 DeepSeek | 聊天列表→点击"AI摘要" |
| **HealthPage** | 健康分析(L200)、风险检测(L215)、个性化建议(L230) | 🟠 MindSpore(含"风险"关键词) | 健康页→点击"AI分析" |
| **HealthRecordDetail** | 数据分析(L130)、趋势预测(L148)、健康建议(L163) | 🔵 DeepSeek(intent=health_consultation) | 健康记录详情→点击"AI分析" |
| **HealthRecords** | AI摘要(L287)、异常检测(L303) | 🟠 MindSpore(含"风险/分析"关键词) | 健康记录列表→点击"AI摘要" |
| **AddHealthRecord** | AI自动填充(L171)、异常检测(L186) | 🟠 MindSpore(含"风险"关键词) | 添加健康记录→点击"AI建议" |
| **MedicationDetailPage** | 详细指导(L146)、AI问答(L162)、副作用(L178) | 🔵 DeepSeek(intent=medication_guidance) | 药品详情→点击"AI指导" |
| **RehabPage** | AI训练计划(L39) | 🔵 DeepSeek(intent=rehabilitation_guidance) | 康复服务→点击"AI生成训练计划" |
| **RehabListPage** | AI课程推荐(L267)、AI筛选(L284) | 🔵 DeepSeek | 康复课程列表→点击"AI推荐" |
| **Rehab3DPage** | AI动作评分(L188)、AI纠正(L207) | 🔵 DeepSeek | 3D康复训练→完成训练→查看AI评分 |
| **RehabilitationPage** | AI推荐(L95)、AI方案(L110) | 🔵 DeepSeek(intent=rehabilitation_guidance) | 康复管理→点击"AI推荐" |
| **ConsultationPage** | AI预问诊(L156)、AI科室推荐(L173) | 🔵 DeepSeek | 在线问诊→输入症状→点击"AI预问诊" |
| **FamilyNurseChatPage** | AI护理指导(L304)、AI健康提醒(L321) | 🔵 DeepSeek | 家庭护士聊天→点击"AI护理指导" |
| **EmergencyPage** | 急救指南展示 | 无AI调用(纯静态数据) | 急救页→浏览指南列表 |

---

## 📝 重点页面详细测试指南

---

### 1️⃣ AI智能问诊 — 🔵 DeepSeek（强制指定）

**📍 文件**: `entry/src/main/ets/pages/AiConsultationPage.ets`
**🚀 路由**: `pages/AiConsultationPage`
**🤖 智能体**: DeepSeek（代码L91写死 `preferredAgent: 'deepseek'`）

#### AI调用点

| 行号 | 方法 | 说明 |
|------|------|------|
| L91 | `sendQuestion()` | 流式对话，`preferredAgent: 'deepseek'` |
| L167-171 | `generateReport()` | 生成诊断报告，intent=`pre_diagnosis` |
| L183-187 | `generateTreatmentSuggestion()` | 治疗建议，intent=`pre_diagnosis` |

#### 测试步骤

```
步骤1: 打开应用 → 底部导航 → "AI问诊"
步骤2: 输入症状: "头痛3天，伴有恶心"
步骤3: 点击发送 → 观察DeepSeek流式输出（逐字出现）
步骤4: 点击"生成诊断报告" → 查看AI报告
步骤5: 点击"治疗建议" → 查看AI建议
```

#### 验证要点

- ✅ 回复逐字出现（流式输出是DeepSeek独有功能）
- ✅ 日志显示: `[AIOrchestrator] ✅ 强制使用用户指定智能体: deepseek`
- ✅ 如果DeepSeek不可用，会fallback到小艺→MindSpore

---

### 2️⃣ AI通用聊天 — 🔵 DeepSeek（强制指定）

**📍 文件**: `entry/src/main/ets/pages/AiChatPage.ets`
**🚀 路由**: `pages/AiChatPage`
**🤖 智能体**: DeepSeek（代码L200、L482写死 `preferredAgent: 'deepseek'`）

#### AI调用点

| 行号 | 方法 | 说明 |
|------|------|------|
| L200 | `sendMessage()` | 普通对话，`preferredAgent: 'deepseek'` |
| L482-484 | `sendStreamMessage()` | 流式对话，`preferredAgent: 'deepseek'` |

#### 测试步骤

```
步骤1: 打开应用 → "AI助手" / "智能聊天"
步骤2: 输入: "高血压饮食注意什么"
步骤3: 观察回复（DeepSeek强制调用）
步骤4: 切换到流式模式 → 输入问题 → 观察逐字输出
```

---

### 3️⃣ 医学影像分析 — 🔴HiAI + 🔵DeepSeek（三层混合架构）

**📍 文件**: `entry/src/main/ets/pages/ImageAnalysisPage.ets`
**🚀 路由**: `pages/ImageAnalysisPage`
**🤖 智能体**: HiAI NPU图像分类 + DeepSeek深度解读

#### 三层分析流程

```
第1层: HiAI NPU → 图像分类识别（识别X光/CT/MRI类型）
第2层: 规则引擎 → 基于HiAI结果生成基础分析
第3层: DeepSeek → 大模型深度解读，生成专业诊断报告
```

#### 测试步骤

```
步骤1: 打开应用 → "影像分析"
步骤2: 选择影像类型（如胸部X光）
步骤3: 上传图片或使用示例图片
步骤4: 点击"开始分析"
步骤5: 观察进度条:
  - 0%-30%: HiAI NPU图像分类
  - 30%-70%: 规则引擎分析
  - 70%-100%: DeepSeek深度解读
步骤6: 查看最终报告（包含HiAI分类+DeepSeek诊断）
```

#### 验证要点

- ✅ 日志显示: `[ImageAnalysis] HiAI分类结果: ...`
- ✅ 日志显示: `[ImageAnalysis] DeepSeek分析完成`
- ✅ 报告显示模型版本: `Hybrid-HiAI-DeepSeek-v1.0`
- ❌ 如果HiAI不可用，降级为默认类型+DeepSeek解读

---

### 4️⃣ 风险评估 — 🟠 MindSpore Lite（端侧推理）

**📍 文件**: `entry/src/main/ets/pages/RiskAssessmentPage.ets`
**🚀 路由**: `pages/RiskAssessmentPage`
**🤖 智能体**: MindSpore Lite（端侧NPU推理，降级到规则引擎）

#### 工作流程

```
RiskAssessmentEngine.assessRisk()
  → 尝试 MindSpore Lite 端侧推理
  → 失败则降级到规则引擎（纯本地计算）
  → 输出: 心血管/糖尿病/肿瘤风险概率
```

#### 测试步骤

```
步骤1: 打开应用 → "风险评估"
步骤2: 填写健康数据: 年龄、性别、身高、体重、血压、血糖等
步骤3: 选择既往病史
步骤4: 点击"开始评估"
步骤5: 查看雷达图和各维度风险等级
```

#### 验证要点

- ✅ 日志显示: `RiskAssessmentEngine: MindSpore Lite集成完成`
- ✅ 或降级日志: `MindSpore Lite初始化失败，使用降级引擎`
- ✅ 风险结果包含: 心血管/糖尿病/肿瘤风险概率
- ✅ 无需网络即可运行（端侧推理）

---

### 5️⃣ 在线问诊辅助 — 🔵 DeepSeek（自动路由）

**📍 文件**: `entry/src/main/ets/pages/ConsultationPage.ets`
**🚀 路由**: `pages/ConsultationPage`
**🤖 智能体**: DeepSeek（输入含"症状/诊断"→路由到DeepSeek）

#### 测试步骤

```
步骤1: 打开应用 → "在线问诊"
步骤2: 输入: "胸口疼痛，呼吸困难"
步骤3: 点击"AI预问诊" → 查看DeepSeek分析
步骤4: 点击"AI推荐科室" → 查看科室推荐
```

---

### 6️⃣ 语音助手 — 🟢小艺 + 🔵DeepSeek

**📍 文件**: `entry/src/main/ets/pages/VoiceAssistantPage.ets`
**🚀 路由**: `pages/VoiceAssistantPage`
**🤖 智能体**: 默认DeepSeek(L319)，但路由规则会根据内容切换

#### 路由逻辑

| 语音输入 | 实际智能体 | 原因 |
|---------|-----------|------|
| "帮我挂号张医生" | 🟢 小艺 | 匹配"挂号"关键词 |
| "导航去内科" | 🟢 小艺 | 匹配"导航"关键词 |
| "救命！我不舒服" | 🟢 小艺 | 匹配"救命"关键词 |
| "高血压饮食注意什么" | 🔵 DeepSeek | 匹配"饮食"关键词 |
| "我的风险有多大" | 🟠 MindSpore | 匹配"风险"关键词 |

#### 测试步骤

```
步骤1: 打开应用 → "语音助手"
步骤2: 测试小艺: 说"帮我挂号张医生明天上午"
步骤3: 测试DeepSeek: 说"高血压饮食注意什么"
步骤4: 测试急救: 说"救命，我胸口疼"
步骤5: 观察日志中显示的智能体ID
```

---

### 7️⃣ AI测试页 — 全部5个智能体可测

**📍 文件**: `entry/src/main/ets/pages/AITestPage.ets`
**🚀 路由**: `pages/AITestPage`

#### 测试按钮

| 按钮 | 智能体 | 测试内容 |
|------|--------|---------|
| "测试小艺" | 🟢 小艺 | "帮我挂号张医生明天上午" |
| "测试DeepSeek" | 🔵 DeepSeek | "高血压患者饮食注意什么" |
| "测试Coze" | 🟣 Coze | "血压高怎么办" |
| "测试HiAI" | 🔴 HiAI | "识别这张医疗图片" |
| "运行全部测试" | 全部 | 依次测试4个智能体 |

#### 测试步骤

```
步骤1: 导航到 AITestPage
步骤2: 逐个点击测试按钮
步骤3: 观察每个智能体的响应和日志
步骤4: 点击"运行全部测试" → 查看完整测试结果
```

---

## 🔧 智能体配置与调试

### API密钥配置

| 智能体 | 配置文件 | 必需配置 |
|--------|---------|---------|
| 🔵 **DeepSeek** | `ai/agents/DeepSeekAgent.ts` → `DeepSeekConfig.ts` | `DEEPSEEK_API_KEY` |
| 🟣 **Coze** | `ai/agents/CozeAgent.ts` → `CozeApiClient.ts` | `COZE_API_KEY` + `COZE_BOT_ID` |
| 🟢 **小艺** | 系统内置 | 无需配置（HarmonyOS原生） |
| 🟠 **MindSpore** | `ai/MindSporeLiteAdapter.ets` | 需加载 `.ms` 模型文件 |
| 🔴 **HiAI** | `hiai/HiAIVisionClient.ts` | NPU硬件（无需API Key） |

### Fallback降级链

当主智能体不可用时，自动降级：

| 主智能体 | 降级顺序 |
|---------|---------|
| 🟢 小艺 | → 🔵 DeepSeek → 🟠 MindSpore |
| 🔵 DeepSeek | → 🟢 小艺 → 🟠 MindSpore |
| 🟣 Coze | → 🔵 DeepSeek → 🟢 小艺 → 🟠 MindSpore |
| 🟠 MindSpore | → 🔴 HiAI → 🟢 小艺 → 🔵 DeepSeek |
| 🔴 HiAI | → 🟠 MindSpore → 🟢 小艺 → 🔵 DeepSeek |

### 查看AI日志

在DevEco Studio的Log窗口搜索：

| 搜索关键词 | 查看内容 |
|-----------|---------|
| `[AIOrchestrator]` | 路由决策、智能体选择 |
| `[IntentRouter]` | 意图识别结果、路由到哪个智能体 |
| `[DeepSeekAgent]` | DeepSeek调用详情 |
| `[XiaoyiAgent]` | 小艺调用详情 |
| `[CozeAgent]` | Coze调用详情 |
| `[ImageAnalysis]` | HiAI+DeepSeek影像分析流程 |
| `RiskAssessmentEngine` | MindSpore风险评估流程 |

### 常见问题排查

| 问题 | 可能原因 | 解决方案 |
|------|---------|---------|
| "AI暂时不可用" | DeepSeek API未配置/网络问题 | 检查 `DEEPSEEK_API_KEY` 和网络 |
| 回复很慢(>10秒) | 云端API超时 | 查看日志，等待fallback降级 |
| 路由到错误智能体 | IntentRouter关键词匹配不准 | 检查输入是否包含特定关键词 |
| MindSpore初始化失败 | 模型文件未加载 | 检查 `.ms` 模型文件是否存在 |
| HiAI不可用 | 设备无NPU | 降级到DeepSeek处理 |
| 影像分析只有基础报告 | DeepSeek调用失败 | 检查API Key和网络 |

---

## ✅ 测试清单

### 🔵 DeepSeek 测试（使用最多，14+页面）

- [ ] **AiConsultationPage** - 流式对话正常
- [ ] **AiChatPage** - 普通对话+流式对话正常
- [ ] **VoiceAssistantPage** - 语音输入后DeepSeek回复
- [ ] **ConsultationPage** - AI预问诊+科室推荐
- [ ] **DoctorChatPage** - AI症状分析+诊断辅助
- [ ] **AITestPage** - DeepSeek测试按钮通过

### 🔴 HiAI 测试（1个页面）

- [ ] **ImageAnalysisPage** - HiAI图像分类+DeepSeek解读
- [ ] **AITestPage** - HiAI测试按钮通过

### 🟠 MindSpore 测试（1个页面）

- [ ] **RiskAssessmentPage** - 风险评估计算正常
- [ ] **WatchHealthMonitorPage** - 健康趋势预测

### 🟣 Coze 测试（1个页面）

- [ ] **AITestPage** - Coze测试按钮通过

### 🟢 小艺 测试（路由触发）

- [ ] **VoiceAssistantPage** - 说"帮我挂号"→路由到小艺
- [ ] **WatchEmergencyPage** - 紧急情况→路由到小艺
- [ ] **WatchMedicationPage** - 用药咨询→路由到小艺

### 配置验证

- [ ] DeepSeek API Key 已配置（必须，最常用）
- [ ] Coze Bot ID 已配置（可选）
- [ ] MindSpore模型文件已加载（可选，降级到规则引擎）
- [ ] HiAI NPU可用（可选，降级到DeepSeek）
- [ ] 网络连接正常（DeepSeek/Coze需要）

---

**祝测试顺利！如有问题随时反馈 🚀**
