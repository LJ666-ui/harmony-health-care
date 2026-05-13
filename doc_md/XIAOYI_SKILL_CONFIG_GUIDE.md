# 小艺大智能体 - Skill功能完整配置手册 v1.0

> **项目**: Harmony Health Care (智慧康养助手)
> **平台**: 华为HAG (Huawei Agent Gateway) - 小艺开放平台
> **目标**: 为大智能体添加3个Skill功能（健康评估/图像识别/康复指导）
> **更新时间**: 2026-05-12 (v1.0 - 首版完整实战指南)
> **前置条件**: 
>   - ✅ 大智能体已创建并配置完成
>   - ✅ 5个子Agent已配置完成
>   - ✅ [XIAOYI_SKILL_DETAILED_GUIDE.md](file:///e:\HMOS6.0\Github\harmony-health-care\doc_md\XIAOYI_SKILL_DETAILED_GUIDE.md) 已阅读

---

## 📋 目录

**第一部分：理解Skill**
1. [什么是Skill？与子Agent的区别](#1-什么是skill与子agent的区别)
2. [Skill的两层结构](#2-skill的两层结构)
3. [本项目3个Skill概览](#3-本项目3个skill概览)

**第二部分：在HAG平台创建Skill**
4. [Skill创建通用流程](#4-skill创建通用流程)
5. [Skill 1: 健康风险评估](#5--skill-1-健康风险评估-mindspore-lite)
6. [Skill 2: 医疗图像识别](#6--skill-2-医疗图像识别-hiai-npu)
7. [Skill 3: 康复训练指导](#7--skill-3-康复训练指导-coze-bot)

**第三部分：关联到代码**
8. [skill_config.json对照表](#8-skill_configjson对照表)
9. [代码调用流程说明](#9-代码调用流程说明)
10. [测试验证方法](#10-测试验证方法)

**附录**
11. [常见问题FAQ](#11-常见问题faq)
12. [快速参考卡片](#12-快速参考卡片)

---

## 第一部分：理解Skill

## 1. 什么是Skill？与子Agent的区别

### 🎯 核心概念

```
┌─────────────────────────────────────────────────────┐
│              智慧康养助手 (大智能体)                   │
│                                                     │
│  ┌─────────────────────────────────────────────┐    │
│  │           子Agents (5个)                    │    │
│  │  • 对话型 - 处理文本交互                    │    │
│  │  • 通过自然语言触发                        │    │
│  │  • 返回文本回复                            │    │
│  │                                            │    │
│  │  示例: "帮我挂号" → 医疗预约助手回复      │    │
│  └─────────────────────────────────────────────┘    │
│                                                     │
│  ┌─────────────────────────────────────────────┐    │
│  │           Skills (3个)                      │    │
│  │  • 功能型 - 执行特定任务                    │    │
│  │  • 通过Intent/触发词激活                   │    │
│  │  • 可返回结构化数据 + 调用外部API          │    │
│  │                                            │    │
│  │  示例: "评估我的健康风险" →               │    │
│  │        MindSpore推理 → 返回风险评分        │    │
│  └─────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────┘
```

### 📊 子Agent vs Skill 对比

| 特征 | 子Agent (子智能体) | Skill (技能) |
|------|-------------------|-------------|
| **类型** | 对话型Chatbot | 功能型服务 |
| **交互方式** | 纯文本对话 | 触发→执行→返回结果 |
| **能力范围** | 广泛领域知识 | 专注特定功能 |
| **技术实现** | Prompt + LLM | API + 外部模型/服务 |
| **输出格式** | 自然语言文本 | 结构化数据(JSON) |
| **使用场景** | 咨询、问答、引导 | 计算、分析、识别 |
| **类比** | 专业顾问 | 专业工具 |

### 💡 实际例子

**用户说："帮我挂号"**
```
流程:
用户 → 大智能体(意图识别: 挂号) 
     → 路由到"医疗预约助手"(子Agent)
     → 子Agent用Prompt生成回复
     → 返回:"好的，请问您想挂哪个科室?"
     
类型: 子Agent (对话型)
```

**用户说："评估我的健康风险"**
```
流程:
用户 → 大智能体(意图识别: 健康评估)
     → 触发"健康风险评估"(Skill)
     → Skill调用MindSpore Lite模型推理
     → 返回:{risk_score: 75, level: "高", ...}
     → 大智能体将结果转化为友好回复
     
类型: Skill (功能型)
```

---

## 2. Skill的两层结构

### 🏗️ 架构说明

```
┌──────────────────────────────────────────────────────┐
│                  Skill 的两层结构                     │
├──────────────────────────────────────────────────────┤
│                                                      │
│  【第一层】HAG平台配置层                              │
│  ┌────────────────────────────────────────────┐     │
│  │ 在小艺平台创建和配置Skill                  │     │
│  │                                           │     │
│  │ 配置内容:                                 │     │
│  │ • Skill名称和描述                        │     │
│  │ • 触发Intent定义                         │     │
│  │ • 输入参数(Slots)                        │     │
│  │ • 输出参数定义                           │     │
│  │ • 关联的大智能体                         │     │
│  └────────────────────────────────────────────┘     │
│                      ↓                                │
│  【第二层】HarmonyOS代码层 (已完成✓)                 │
│  ┌────────────────────────────────────────────┐     │
│  │ 代码实现:                                  │     │
│  │                                           │     │
│  │ Skill 1: MindSporeLiteEngine.ets          │     │
│  │         → 本地模型推理                    │     │
│  │                                           │     │
│  │ Skill 2: HiAIVisionClient.ets             │     │
│  │         → NPU硬件加速                     │     │
│  │                                           │     │
│  │ Skill 3: CozeApiClient.ets                │     │
│  │         → 外部API调用                     │     │
│  │                                           │     │
│  │ 统一接口: skill_config.json               │     │
│  │         → Intent与训练短语定义            │     │
│  └────────────────────────────────────────────┘     │
│                                                      │
└──────────────────────────────────────────────────────┘
```

### ⚠️ 重要说明

**好消息**：
- ✅ 第二层（代码）已经写好了！
- ✅ [MindSporeLiteEngine.ets](file:///e:\HMOS6.0\Github\harmony-health-care\entry\src\main\ets/mindsphere/MindSporeLiteEngine.ets) 已存在
- ✅ [HiAIVisionClient.ets](file:///e:\HMOS6.0\Github\harmony-health-care\entry\src\main\ets/hiai/HiAIVisionClient.ets) 已存在
- ✅ [CozeApiClient.ets](file:///e:\HMOS6.0\Github\harmony-health-care\entry\src\main\ets/coze/CozeApiClient.ets) 已存在
- ✅ [skill_config.json](file:///e:\HMOS6.0\Github\harmony-health-care\entry\src\main\resources\base\profile/skill_config.json) 已存在

**需要您做的**：
- ❗ 在HAG平台创建3个Skill配置（第一层）
- ❗ 将平台配置与代码关联起来

---

## 3. 本项目3个Skill概览

### 📋 Skill总览表

| # | Skill名称 | 技术基础 | 功能描述 | 触发方式 | 依赖外部? |
|---|----------|---------|---------|---------|----------|
| **1** | **健康风险评估** | MindSpore Lite | 分析健康数据，计算风险评分 | "评估健康风险"/上传数据 | ❌ 不依赖 |
| **2** | **医疗图像识别** | HiAI NPU | 图像分类、OCR、姿态检测 | "识别图片"/拍照上传 | ❌ 不依赖 |
| **3** | **康复训练指导** | Coze Bot×3 | 专业康复咨询 | "康复指导"/指定科室 | ✅ 依赖Coze |

### 🎯 各Skill详细定位

#### Skill 1: 健康风险评估

```
┌─────────────────────────────────────────┐
│  健康风险评估 Skill                      │
│  (基于 MindSpore Lite 本地模型)          │
├─────────────────────────────────────────┤
│                                         │
│  输入:                                   │
│  • 血压、血糖、心率等健康数据           │
│  • 用户基本信息(年龄、性别等)           │
│  • 时间范围(周/月/季度)                 │
│                                         │
│  处理:                                   │
│  • MindSpore Lite模型本地推理            │
│  • 风险算法计算                          │
│  • 多维度分析                            │
│                                         │
│  输出:                                   │
│  • 风险评分 (0-100)                     │
│  • 风险等级 (低/中/高/极高)             │
│  • 主要风险因素                          │
│  • 健康建议                              │
│                                         │
│  使用场景:                               │
│  ✓ 定期健康检查                          │
│  ✓ 慢性病管理                            │
│  ✓ 健康趋势追踪                          │
│                                         │
└─────────────────────────────────────────┘
```

#### Skill 2: 医疗图像识别

```
┌─────────────────────────────────────────┐
│  医疗图像识别 Skill                      │
│  (基于 HiAI NPU 硬件加速)               │
├─────────────────────────────────────────┤
│                                         │
│  输入:                                   │
│  • 图片URI (相机/相册选取)              │
│  • 识别类型选择                          │
│                                         │
│  支持的识别类型:                         │
│  • skin - 皮肤病变初步识别              │
│  • ocr - 药品/单据文字识别              │
│  • pose - 跌倒姿态检测                  │
│  • fundus - 眼底照片分析               │
│                                         │
│  处理:                                   │
│  • HiAI NPU硬件加速推理                 │
│  • 图像预处理                            │
│  • AI模型分类/检测                      │
│                                         │
│  输出:                                   │
│  • 识别结果列表                          │
│  • 每项结果的置信度                     │
│  • 建议和处理方案                        │
│  • 处理耗时                             │
│                                         │
│  使用场景:                               │
│  ✓ 皮肤异常自查                          │
│  ✓ 药品信息快速录入                     │
│  ✓ 跌倒检测确认                          │
│  ✓ 眼底筛查辅助                          │
│                                         │
└─────────────────────────────────────────┘
```

#### Skill 3: 康复训练指导

```
┌─────────────────────────────────────────┐
│  康复训练指导 Skill                      │
│  (基于 Coze 医疗Bot API)                 │
├─────────────────────────────────────────┤
│                                         │
│  输入:                                   │
│  • 科室选择 (内科/眼科/康复科)          │
│  • 用户问题描述                          │
│  • 可选:病史信息                         │
│                                         │
│  处理:                                   │
│  • 路由到对应Coze Bot                    │
│  │ ├─ internal_medicine (内科)          │
│  │ ├─ ophthalmology (眼科)              │
│  │ └─ rehabilitation (康复科)           │
│  • LLM专业知识问答                       │
│  • 生成个性化建议                        │
│                                         │
│  输出:                                   │
│  • 专业咨询内容                          │
│  • 结构化建议列表                        │
│  • 后续跟进建议                          │
│  • 使用的Bot标识                         │
│                                         │
│  使用场景:                               │
│  ✓ 术后康复指导                          │
│  ✓ 慢性病运动处方                        │
│  ✓ 跌倒预防建议                          │
│  ✓ 辅助器具使用指导                      │
│                                         │
│  ⚠️ 前提: 需先完成Coze Bot创建!        │
│     (见 COZE_DETAILED_GUIDE.md)         │
│                                         │
└─────────────────────────────────────────┘
```

---

## 第二部分：在HAG平台创建Skill

## 4. Skill创建通用流程

### 📍 在哪里创建Skill？

```
操作路径:
1. 登录 HAG 平台 (https://developer.huawei.com/consumer/cn/hag/)
2. 进入工作空间
3. 点击 "智慧康养助手" (大智能体)
4. 左侧菜单找:
   ├─ "技能" 或 "Skills"
   ├─ "插件"
   └─ 或类似名称
   
预期界面:
┌─────────────────────────────────────────┐
│  智慧康养助手                           │
│                                         │
│  左侧菜单:                              │
│  ├── 概览                               │
│  ├── 配置                               │
│  ├── 智能体 (5/5) ✓                     │
│  ├── 技能 (0/?)  ← 在这里!              │
│  │                                     │
│  │   [+ 创建技能]                      │
│  │                                     │
│  ├── 插件                               │
│  └── 发布                               │
│                                         │
└─────────────────────────────────────────┘
```

### 🔄 创建Skill的标准流程（每个Skill都一样）

```
Step 1: 点击 "+ 创建技能"
   ↓
Step 2: 选择技能类型
   ↓
Step 3: 填写基础信息(名称/描述)
   ↓
Step 4: 配置触发Intent
   ↓
Step 5: 定义输入参数(Slots)
   ↓
Step 6: 定义输出参数(可选)
   ↓
Step 7: 关联到代码中的处理逻辑
   ↓
Step 8: 保存并测试
   ↓
Step 9: 记录Skill ID(如果需要)
```

---

## 5. Skill 1: 健康风险评估 (MindSpore Lite)

### 🎯 Skill基础信息

| 字段 | 推荐填写 | 说明 |
|------|---------|------|
| **Skill名称** | `健康风险评估` | 清晰明确 |
| **Skill ID** | `health_risk_assessment` | 英文标识符 |
| **显示名称** | `🔬 健康风险评估` | 带emoji更直观 |
| **描述** | `基于AI模型的健康数据分析，评估慢性病风险等级并提供个性化健康建议` | 详细说明功能 |
| **图标** | 上传医疗/分析相关图标 | 可选 |
| **类别** | 数据分析 / 健康管理 | 根据平台选项 |

### 📝 Step-by-Step 详细配置

#### Step 1: 创建Skill

```
操作:
1. 在大智能体的"技能"页面
2. 点击 "+ 创建技能" 按钮
3. 选择类型: "自定义技能" 或 "API技能"
   (根据平台实际选项选择最接近的)
```

#### Step 2: 填写基础信息

按照上表填写各字段

#### Step 3: 配置触发Intent ⭐⭐⭐

**Intent是Skill触发的关键！**

##### ✅ Intent配置详情

| 配置项 | 内容 |
|--------|------|
| **Intent名称** | `CHECK_HEALTH_RISK` |
| **显示名称** | `健康风险评估` |
| **描述** | 当用户想要评估健康状况或查看健康风险时触发 |

##### ✅ 训练短语（Training Phrases）

这些是触发此Skill的用户话语示例：

```json
{
  "intent": "CHECK_HEALTH_RISK",
  "training_phrases": [
    "评估我的健康风险",
    "健康风险评估",
    "看看我的健康状况",
    "分析一下我的健康数据",
    "我有高血压风险吗",
    "糖尿病风险评测",
    "我的健康指数是多少",
    "做个健康检查",
    "健康数据分析",
    "评估慢性病风险",
    "查看近期健康趋势",
    "我的身体状况怎么样",
    "健康风险预警",
    "综合健康评估"
  ]
}
```

**共14条训练短语，覆盖各种表达方式**

#### Step 4: 定义输入参数（Slots）

| 参数名 | 类型 | 必填 | 说明 | 示例值 |
|--------|------|------|------|--------|
| `health_data` | Object | 是 | 健康数据JSON | 见下方示例 |
| `time_range` | Enum | 否 | 时间范围 | week/month/quarter |
| `user_id` | String | 否 | 用户ID | 系统自动获取 |

**health_data 结构示例**:
```json
{
  "blood_pressure": {
    "systolic": 140,
    "diastolic": 90,
    "measure_time": "2026-05-12T08:00:00"
  },
  "blood_sugar": {
    "fasting": 6.5,
    "postprandial": 9.2,
    "measure_time": "2026-05-12T07:00:00"
  },
  "heart_rate": 78,
  "weight": 70,
  "height": 170,
  "age": 65,
  "gender": "male"
}
```

#### Step 5: 定义输出参数

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `risk_score` | Number | 风险评分 (0-100) |
| `risk_level` | String | 风险等级 (low/medium/high/critical) |
| `main_factors` | Array | 主要风险因素列表 |
| `suggestions` | Array | 健康建议列表 |
| `assessment_time` | DateTime | 评估时间 |

#### Step 6: 关联代码处理逻辑

**重要！告诉平台如何处理这个Skill**

在平台的"处理逻辑"或"回调URL"或"执行代码"部分：

```
选择/填写:
• 处理方式: "调用本地函数" 或 "执行代码"
• 函数名/入口: assessRisk()
• 关联文件: MindSporeLiteEngine.ets
• 或者: 填写回调地址 (如果有API模式)
```

**如果平台支持直接关联代码文件**：
```
关联到: entry/src/main/ets/mindsphere/MindSporeLiteEngine.ets
方法: async assessRisk(healthData): Promise<RiskAssessmentResult>
```

#### Step 7: 保存并测试

```
测试场景:
输入: "评估我的健康风险"
预期:
  → 触发 CHECK_HEALTH_RISK Intent
  → 调用 MindSporeLiteEngine.assessRisk()
  → 返回风险评估结果
  
模拟输出:
{
  "risk_score": 72,
  "risk_level": "高",
  "main_factors": ["血压偏高", "血糖波动"],
  "suggestions": [
    "建议每天监测血压",
    "控制盐分摄入",
    "定期复查血糖"
  ]
}
```

---

## 6. Skill 2: 医疗图像识别 (HiAI NPU)

### 🎯 Skill基础信息

| 字段 | 推荐填写 | 说明 |
|------|---------|------|
| **Skill名称** | `医疗图像识别` | 清晰明确 |
| **Skill ID** | `medical_image_recognition` | 英文标识符 |
| **显示名称** | `👁️ 医疗图像识别` | 带emoji |
| **描述** | `利用华为NPU硬件加速进行医疗图像AI识别，支持皮肤病变、OCR文字、姿态检测等多种场景` | 详细说明 |
| **类别** | 图像处理 / AI识别 | 根据平台选项 |

### 📝 详细配置

#### Step 1-2: 创建并填写基础信息（同Skill 1）

#### Step 3: 配置触发Intent

| 配置项 | 内容 |
|--------|------|
| **Intent名称** | `RECOGNIZE_MEDICAL_IMAGE` |
| **显示名称** | `医疗图像识别` |
| **描述** | 当用户需要识别医疗相关图片时触发 |

**训练短语**:
```json
{
  "intent": "RECOGNIZE_MEDICAL_IMAGE",
  "training_phrases": [
    "识别这张图片",
    "这是什么皮肤问题",
    "帮我看一下这个照片",
    "图片识别",
    "扫描这个药品",
    "OCR识别",
    "读取图片上的文字",
    "检测跌倒姿势",
    "眼底照片分析",
    "皮肤病变识别",
    "拍个照识别一下",
    "这张图是什么",
    "图像分析",
    "AI看图诊断"
  ]
}
```

**共15条训练短语**

#### Step 4: 定义输入参数

| 参数名 | 类型 | 必填 | 说明 | 示例值 |
|--------|------|------|------|--------|
| `image_uri` | String | **是** | 图片URI | `file://media/photos/xxx.jpg` |
| `recognition_type` | Enum | 否 | 识别类型 | skin/ocr/pose/fundus/auto |
| `confidence_threshold` | Number | 否 | 置信度阈值 | 0.7 (默认) |

**recognition_type 枚举值说明**:

| 值 | 含义 | 适用场景 |
|----|------|---------|
| `skin` | 皮肤病变识别 | 皮疹、痣、伤口等 |
| `ocr` | 文字识别 | 药品包装、化验单、处方 |
| `pose` | 姿态检测 | 跌倒检测、动作分析 |
| `fundus` | 眼底分析 | 眼底照片筛查 |
| `auto` | 自动检测 | 让AI自动判断类型 |

#### Step 5: 定义输出参数

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `recognition_type` | String | 实际使用的识别类型 |
| `results` | Array | 识别结果列表 |
| `processing_time` | Number | 处理耗时(ms) |
| `image_info` | Object | 图片元信息 |

**results 数组项结构**:
```json
{
  "label": "疑似湿疹",
  "confidence": 0.85,
  "suggestion": "建议到皮肤科进一步检查",
  "severity": "medium",  // low/medium/high/critical
  "bounding_box": {       // 可选，目标区域
    "x": 100,
    "y": 200,
    "width": 150,
    "height": 150
  }
}
```

#### Step 6: 关联代码处理逻辑

```
关联到: entry/src/main/ets/hiai/HiAIVisionClient.ets
方法:
  • classifyImage(imageUri) - 图像分类
  • recognizeText(imageUri) - OCR识别  
  • detectPose(imageUri) - 姿态检测
  
根据 recognition_type 调用不同方法
```

#### Step 7: 保存并测试

```
测试场景:
输入: "识别这张皮肤图片" + 图片
预期:
  → 触发 RECOGNIZE_MEDICAL_IMAGE Intent
  → 调用 HiAIVisionClient.classifyImage()
  → 返回识别结果

模拟输出:
{
  "recognition_type": "skin",
  "results": [
    {
      "label": "疑似湿疹",
      "confidence": 0.85,
      "suggestion": "建议到皮肤科进一步检查",
      "severity": "medium"
    }
  ],
  "processing_time": 120
}
```

---

## 7. Skill 3: 康复训练指导 (Coze Bot)

### ⚠️ 特别注意：依赖Coze！

**在配置此Skill之前，必须先完成**：
- ✅ Coze账号注册
- ✅ 3个医疗Bot创建完成（见[COZE_DETAILED_GUIDE.md](file:///e:\HMOS6.0\Github\harmony-health-care\doc_md\COZE_DETAILED_GUIDE.md)）
- ✅ Personal Access Token获取
- ✅ 3个Bot IDs记录

**如果还没完成Coze配置**：
- 可以先跳过此Skill
- 先配置Skill 1和Skill 2
- 后期再回来添加Skill 3

### 🎯 Skill基础信息

| 字段 | 推荐填写 | 说明 |
|------|---------|------|
| **Skill名称** | `康复训练指导` | 清晰明确 |
| **Skill ID** | `rehabilitation_guidance` | 英文标识符 |
| **显示名称** | `🏃‍♂️ 康复训练指导` | 带emoji |
| **描述** | `连接专业医疗AI机器人，提供内科、眼科、康复科的个性化康复指导和健康咨询` | 详细说明 |
| **类别** | 专业咨询 / 医疗健康 | 根据平台选项 |

### 📝 详细配置

#### Step 1-2: 创建并填写基础信息

#### Step 3: 配置触发Intent

| 配置项 | 内容 |
|--------|------|
| **Intent名称** | `GET_REHABILITATION_GUIDANCE` |
| **显示名称** | `康复训练指导` |
| **描述** | 当用户需要专业的康复、内科或眼科咨询指导时触发 |

**训练短语**:
```json
{
  "intent": "GET_REHABILITATION_GUIDANCE",
  "training_phrases": [
    "康复训练指导",
    "术后怎么康复",
    "骨科康复计划",
    "中风后怎么锻炼",
    "跌倒预防训练",
    "内科医生咨询",
    "高血压怎么办",
    "糖尿病饮食建议",
    "眼科保健指导",
    "白内障手术后护理",
    "心脏康复方案",
    "帕金森病运动",
    "专业医疗咨询",
    "康复师建议",
    "我想问医生"
  ]
}
```

**共15条训练短语**

#### Step 4: 定义输入参数

| 参数名 | 类型 | 必填 | 说明 | 示例值 |
|--------|------|------|------|--------|
| `department` | Enum | **是** | 目标科室 | internal_medicine/ophthalmology/rehabilitation |
| `query` | String | **是** | 用户问题 | "刚做完膝盖手术怎么康复" |
| `patient_history` | Object | 否 | 病史信息 | {"age": 65, "conditions": ["高血压"]} |

**department 枚举值**:

| 值 | 显示名称 | 对应Coze Bot |
|----|---------|-------------|
| `internal_medicine` | 内科咨询 | 内科医疗助手 |
| `ophthalmology` | 眼科咨询 | 眼科保健指导 |
| `rehabilitation` | 康复咨询 | 康复训练指导 |

#### Step 5: 定义输出参数

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `bot_type` | String | 使用的Bot类型 |
| `response` | Object | Bot的完整响应 |
| `bot_id` | String | Bot ID（调试用） |

**response 结构**:
```json
{
  "content": "针对您的膝关节置换手术...",
  "suggestions": [
    "早期(0-2周): 冰敷、踝泵练习...",
    "中期(2-6周): 关节活动度训练...",
    "后期(6周+): 负重练习..."
  ],
  "follow_up": [
    "需要了解具体的动作要领吗？",
    "有疼痛或不适应立即停止"
  ],
  "warnings": [
    "避免深蹲、盘腿、跪姿"
  ]
}
```

#### Step 6: 关联代码处理逻辑 ⭐⭐⭐

```
关联到: entry/src/main/ets/coze/CozeApiClient.ets

路由逻辑:
┌─────────────────────────────────────┐
│  根据 department 参数路由:          │
│                                     │
│  internal_medicine →                │
│    consultInternalMedicine(query)   │
│    → 调用 Coze 内科Bot API          │
│                                     │
│  ophthalmology →                    │
│    consultOphthalmology(query)      │
│    → 调用 Coze 眼科Bot API          │
│                                     │
│  rehabilitation →                  │
│    consultRehabilitation(query)      │
│    → 调用 Coze 康复Bot API          │
│                                     │
└─────────────────────────────────────┘

需要的配置参数 (从CozeConfig.ets读取):
• personalAccessToken
• botId_internal_medicine
• botId_ophthalmology  
• botId_rehabilitation
```

#### Step 7: 保存并测试

```
测试场景:
输入: "刚做完膝关节置换手术，怎么康复"
预期:
  → 触发 GET_REHABILITATION_GUIDANCE Intent
  → department = rehabilitation (自动或手动选择)
  → 调用 CozeApiClient.consultRehabilitation()
  → 返回康复指导方案

模拟输出:
{
  "bot_type": "rehabilitation",
  "response": {
    "content": "膝关节置换术后的康复非常重要...",
    "suggestions": [...],
    "follow_up": [...]
  },
  "bot_id": "xxx"
}
```

---

## 第三部分：关联到代码

## 8. skill_config.json 对照表

### 📍 当前已有的Intent定义

项目中已经存在的 [skill_config.json](file:///e:\HMOS6.0\Github\harmony-health-care\entry\src\main\resources\base\profile/skill_config.json) 文件包含了8个Intent。

**与3个Skill对应的Intent**:

| Skill名称 | Intent名称 | skill_config.json中是否存在 |
|-----------|------------|--------------------------|
| Skill 1: 健康风险评估 | `CHECK_HEALTH_RISK` | ✅ **已存在** |
| Skill 2: 医疗图像识别 | `RECOGNIZE_MEDICAL_IMAGE` | ✅ **已存在** |
| Skill 3: 康复训练指导 | `GET_REHABILITATION_GUIDANCE` | ✅ **已存在** |

**太好了！代码层面已经准备好了！**

### 🔗 平台配置与代码的映射关系

```
HAG平台配置                    HarmonyOS代码
───────────                    ────────────

Skill 1:
  Intent: CHECK_HEALTH_RISK  ←→  skill_config.json
  训练短语: 14条             ←→  training_phrases
  输入: health_data          ←→  MindSporeLiteEngine.ets
  输出: risk_result          ←→  RiskAssessmentResult

Skill 2:
  Intent: RECOGNIZE_MEDICAL  ←→  skill_config.json
  训练短语: 15条             ←→  training_phraces  
  输入: image_uri            ←→  HiAIVisionClient.ets
  输出: recognition_result   ←→  ImageClassificationResult

Skill 3:
  Intent: GET_REHABILITATION ←→  skill_config.json
  训练短语: 15条             ←→  training_phrases
  输入: department+query     ←→  CozeApiClient.ets
  输出: consultation_result  ←→  CozeResponse
```

---

## 9. 代码调用流程说明

### 🔄 完整调用链路

```
用户操作:
  "评估我的健康风险"
      ↓
┌─────────────────────────────────────────┐
│  1. 小艺语音/文本输入                   │
└─────────────────────────────────────────┘
      ↓
┌─────────────────────────────────────────┐
│  2. 大智能体意图识别                     │
│     → 匹配到 CHECK_HEALTH_RISK Intent   │
│     → 判断需要调用 Skill 1              │
└─────────────────────────────────────────┘
      ↓
┌─────────────────────────────────────────┐
│  3. Skill触发 & 参数收集                │
│     • 收集 health_data (从设备/用户)    │
│     • 验证必填参数                      │
└─────────────────────────────────────────┘
      ↓
┌─────────────────────────────────────────┐
│  4. 调用HarmonyOS代码层                 │
│     → XiaoyiSkillManager.ets           │
│     → MindSporeLiteEngine.ets          │
│     → assessRisk(healthData)           │
└─────────────────────────────────────────┘
      ↓
┌─────────────────────────────────────────┐
│  5. 本地模型推理 (MindSpore Lite)       │
│     • 加载模型                          │
│     • 数据预处理                        │
│     • 模型推理                          │
│     • 后处理                            │
└─────────────────────────────────────────┘
      ↓
┌─────────────────────────────────────────┐
│  6. 返回结构化结果                      │
│     {                                   │
│       risk_score: 75,                   │
│       risk_level: "高",                 │
│       ...                               │
│     }                                   │
└─────────────────────────────────────────┘
      ↓
┌─────────────────────────────────────────┐
│  7. 大智能体格式化回复                   │
│     → 将JSON转为友好文本                │
│     → "根据您的健康数据分析..."         │
└─────────────────────────────────────────┘
      ↓
┌─────────────────────────────────────────┐
│  8. 小艺语音播报 / 文本显示给用户        │
└─────────────────────────────────────────┘
```

---

## 10. 测试验证方法

### 🧪 测试清单

#### Skill 1 测试

| # | 测试操作 | 预期触发 | 预期结果 |
|---|---------|---------|---------|
| 1 | 说"评估我的健康风险" | CHECK_HEALTH_RISK | 显示风险评估表单/请求输入数据 |
| 2 | 提供血压血糖数据 | assessRisk() | 返回风险评分和建议 |
| 3 | 说"我的健康怎么样" | CHECK_HEALTH_RISK | 同上 |
| 4 | 异常数据测试 | 错误处理 | 友好错误提示 |

#### Skill 2 测试

| # | 测试操作 | 预期触发 | 预期结果 |
|---|---------|---------|---------|
| 1 | 说"识别这张图片"+选图 | RECOGNIZE_MEDICAL_IMAGE | 选择识别类型 |
| 2 | 选"皮肤识别"| classifyImage() | 返回皮肤分析结果 |
| 3 | 选"OCR识别" | recognizeText() | 返回识别的文字 |
| 4 | 无效图片测试 | 错误处理 | 提示重新选择图片 |

#### Skill 3 测试（需Coze就绪）

| # | 测试操作 | 预期触发 | 预期结果 |
|---|---------|---------|---------|
| 1 | 说"康复训练指导" | GET_REHABILITATION_GUIDANCE | 选择科室 |
| 2 | 选"康复科"+"膝盖手术" | consultRehabilitation() | 返回康复方案 |
| 3 | 选"内科"+"血压高" | consultInternalMedicine() | 返回内科建议 |
| 4 | Coze API异常 | 错误处理 | 友好提示+降级方案 |

---

## 附录

## 11. 常见问题FAQ

### Q1: Skill一定要现在配置吗？

```
不是必须的！有两种策略:

策略A: 现在全部配置 (推荐)
  ✅ 一次性完成
  ✅ 功能完整
  ⏰ 需要额外1-2小时

策略B: 后期再添加 (灵活)
  ✅ 快速发布V1.0 (仅5个子Agent)
  ⏰ 后期发V1.1.0 加Skill
  ⚠️ 需要再次提交审核

建议: 如果时间充裕，现在一起配完!
```

### Q2: Skill 3必须等Coze弄完吗？

```
是的! Skill 3 依赖 Coze 的3个Bot:

依赖关系:
  Skill 3 (康复指导)
    └─ 需要 CozeApiClient.ets
        └─ 需要 Personal Access Token
        └─ 需要 3个 Bot IDs
            └─ 需要在Coze创建3个Bot
                └─ 见 COZE_DETAILED_GUIDE.md

解决方案:
  选项1: 先配Skill 1&2 (不依赖Coze) ✓
  选项2: 全部跳过，后期统一添加
  选项3: 先去弄Coze (1-1.5小时)，再回来配所有Skill
```

### Q3: 平台找不到"技能"或"Skills"菜单？

```
可能的原因和解决方案:

原因1: 版本不同
  → 不同版本的HAG界面可能有差异
  → 尝试查找: 插件/工具/能力/功能 等类似词汇

原因2: 权限不足
  → 确认账号有创建Skill的权限
  → 联系管理员开通权限

原因3: 需要先升级
  → 有些功能可能需要工作空间升级
  → 查看平台公告或帮助文档

如果实在找不到:
  → 截图给我看当前界面的左侧菜单
  → 我帮您确定在哪里
```

### Q4: Skill配置错了可以修改吗？

```
可以修改的内容:
✅ Skill名称和描述
✅ Intent的训练短语
✅ 输入输出参数
✅ 关联的处理逻辑

不可以修改的:
❌ Skill ID (创建后固定)

如果需要重大改动:
  → 删除旧Skill (如果允许)
  → 重新创建
  → 更新关联代码
```

### Q5: 配置完Skill就能用了吗？

```
还需要以下步骤:

1. ✅ HAG平台配置Skill (本指南)
2. ✅ 确保代码文件正确 (已完成)
3. ⏳ 测试Skill触发和执行
4. ⏳ 集成到大智能体的路由逻辑
5. ⏳ 整体端到端测试
6. ⏳ 发布上线

当前进度:
  平台配置: 进行中 (本指南)
  代码准备: 100% 完成 ✓
  测试验证: 待开始
```

---

## 12. 快速参考卡片

### 📱 创建单个Skill的快速清单

```
□ 进入大智能体的"技能"页面
□ 点击 "+ 创建技能"
□ 填写基础信息 (名称/ID/描述)
□ 配置触发Intent (名称+训练短语)
□ 定义输入参数 (Slots)
□ 定义输出参数 (可选但推荐)
□ 关联代码处理逻辑/回调
□ 点击 "保存"
□ 使用训练短语测试触发
□ 验证参数传递正确
□ 检查返回结果格式
```

预计每个Skill耗时: **20-30分钟**

### 📊 3个Skill完成时间估算

```
Skill 1 (健康评估): 25分钟
  └─ 不依赖外部，可立即完成 ✓

Skill 2 (图像识别): 25分钟  
  └─ 不依赖外部，可立即完成 ✓

Skill 3 (康复指导): 30分钟
  └─ 依赖Coze (需先完成Coze配置) ⚠️

总计预估 (不含Coze):
  • 仅Skill 1&2: 50分钟 - 1小时
  • 全部3个Skill: 1小时20分 - 1.5小时 (含Coze时间)
```

### ✅ 最终检查清单

完成所有Skill配置后：

```markdown
□ Skill 1: 健康风险评估
  □ Intent配置完成 (CHECK_HEALTH_RISK)
  □ 训练短语已添加 (14条)
  □ 输入参数已定义 (health_data等)
  □ 输出参数已定义 (risk_score等)
  □ 关联到 MindSporeLiteEngine.ets
  □ 测试通过

□ Skill 2: 医疗图像识别
  □ Intent配置完成 (RECOGNIZE_MEDICAL_IMAGE)
  □ 训练短语已添加 (15条)
  □ 输入参数已定义 (image_uri等)
  □ 输出参数已定义 (results等)
  □ 关联到 HiAIVisionClient.ets
  □ 测试通过

□ Skill 3: 康复训练指导 (可选，依赖Coze)
  □ Intent配置完成 (GET_REHABILITATION_GUIDANCE)
  □ 训练短语已添加 (15条)
  □ 输入参数已定义 (department+query)
  □ 输出参数已定义 (response)
  □ 关联到 CozeApiClient.ets
  □ Coze Token和Bot IDs已配置
  □ 测试通过

□ 总体验证:
  □ 3个Skill都出现在大智能体Skill列表
  □ 从大智能体可以触发每个Skill
  □ 参数能正确传递到代码层
  □ 返回结果能正确展示
```

---

## 🎯 总结与行动计划

### ✅ 本文档完成后您将拥有

| 成果 | 数量 | 用途 |
|------|------|------|
| **配置完成的Skills** | 2-3个 | 健康评估/图像识别/康复指导 |
| **Intent定义** | 3组 | 共44条训练短语 |
| **参数映射** | 完整 | 输入输出参数清晰定义 |
| **代码关联** | 已建立 | 与现有代码文件对接 |

### 📌 推荐执行顺序

**今天（如果时间充裕）**:
```
1. ✅ 完成大智能体配置 (按 XIAOYI_SKILL_DETAILED_GUIDE.md)
2. ✅ 配置 Skill 1 (健康风险评估)
3. ✅ 配置 Skill 2 (医疗图像识别)
4. ⏳ 决定是否现在弄Coze (为了Skill 3)
```

**或者（如果想快速推进）**:
```
1. ✅ 完成大智能体配置
2. ⏳ 跳过Skill，先收集参数
3. 📧 发送8个小艺参数给我
4. 🔧 我集成5大核心功能代码
5. 🚀 快速发布V1.0 (不含Skill)
6. 📅 后期再加Skill (V1.1.0)
```

### 🎓 相关文档索引

| 文档 | 内容 | 状态 |
|------|------|------|
| [XIAOYI_SKILL_DETAILED_GUIDE.md](file:///e:\HMOS6.0\Github\harmony-health-care\doc_md\XIAOYI_SKILL_DETAILED_GUIDE.md) | 大智能体+5个子Agent配置 | ✅ v5.0 |
| **本文档** | **3个Skill功能配置** | ✅ v1.0 新建 |
| [COZE_DETAILED_GUIDE.md](file:///e:\HMOS6.0\Github\harmony-health-care\doc_md\COZE_DETAILED_GUIDE.md) | Coze 3个医疗Bot创建 | ✅ v3.0 |
| [PLATFORM_DEPLOYMENT_GUIDE.md](file:///e:\HMOS6.0\Github\harmony-health-care\doc_md\PLATFORM_DEPLOYMENT_GUIDE.md) | 所有平台部署汇总 | ✅ 已有 |

---

**文档版本**: v1.0 (首版完整实战指南)
**最后更新**: 2026-05-12
**适用对象**: 已完成大智能体和子Agent配置的用户
**预计耗时**: 1-1.5小时 (3个Skill)

**祝配置顺利！遇到任何问题随时截图给我！** 🚀
