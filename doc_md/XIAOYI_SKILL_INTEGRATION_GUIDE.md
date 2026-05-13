# 🎙️ 小艺Skill对接完整操作指南

> **目标**: 手把手指导你完成华为小艺语音助手的Skill开发、配置和发布  
> **适用场景**: 华为创新极客赛 - 智慧康养项目  
> **预计耗时**: 2-4小时（含审核等待时间）  
> **前置要求**: 已有HarmonyOS项目基础

---

## 📋 目录

1. [准备工作](#1-准备工作)
2. [注册开发者账号](#2-注册开发者账号)
3. [创建Skill项目](#3-创建skill项目)
4. [配置意图(Intent)](#4-配置意图intent)
5. [编写Skill代码](#5-编写skill代码)
6. [本地测试](#6-本地测试)
7. [真机调试](#7-真机调试)
8. [提交审核与发布](#8-提交审核与发布)
9. [常见问题FAQ](#9-常见问题faq)

---

## 1️⃣ 准备工作

### 1.1 需要准备的材料

| 材料 | 说明 | 获取方式 |
|------|------|----------|
| ✅ **华为账号** | 用于登录开发者联盟 | 注册地址: https://id.huawei.com/ |
| ✅ **实名认证** | 个人或企业认证 | 需要**身份证**或**营业执照** |
| ✅ **DevEco Studio** | HarmonyOS开发工具 | 已安装（版本≥4.0） |
| ✅ **测试设备** | HarmonyOS NEXT系统 | Mate 60系列 / MatePad Pro 13.2 |
| ✅ **项目源码** | 智慧康养项目 | 当前项目已准备好 |

### 1.2 前置检查清单

在开始之前，请确认：

```
□ DevEco Studio已安装并可以正常编译项目
□ 项目可以在模拟器上运行
□ 已有华为账号并完成实名认证
□ 了解基本的HarmonyOS开发概念（Ability、Page等）
□ 网络连接正常（需要访问华为服务器）
```

---

## 2️⃣ 注册开发者账号

### Step 1: 访问开发者联盟

1. 打开浏览器访问：**https://developer.huawei.com/**
2. 点击右上角 **"登录"** 或 **"注册"**
3. 使用华为账号登录（如果没有，先注册）

### Step 2: 完成实名认证

⚠️ **重要**: 必须完成实名认证才能创建Skill！

#### 个人开发者认证：
```
路径: 开发者联盟 → 个人中心 → 实名认证

所需材料:
- 身份证正反面照片
- 本人手持身份证照片（部分情况需要）
- 手机号验证

预计时间: 1-2个工作日
费用: 免费
```

#### 企业开发者认证（可选）：
```
所需材料:
- 营业执照
- 对公银行账户
- 企业法人身份证

优势: 可以发布到应用市场
建议: 比赛用个人认证即可
```

### Step 3: 创建应用（AGC）

1. 登录后进入 **AppGallery Connect (AGC)**
2. 点击 **"我的应用"** → **"添加应用"**
3. 填写信息：
   ```
   应用名称: HarmonyHealthCare
   包名: com.example.harmonyhealthcare
   分类: 健康/医疗
   ```
4. 记录下 **App ID** 和 **Client ID**（后续配置需要）

---

## 3️⃣ 创建Skill项目

### Step 1: 进入Skill开发平台

1. 在开发者联盟首页，找到 **"应用服务"**
2. 点击 **"智慧语音"** → **"技能开发"**
3. 进入 Skill Studio 控制台：https://developer.huawei.com/consumer/cn/hiai/

### Step 2: 创建新Skill

点击 **"+ 创建技能"** 按钮，填写以下信息：

#### 基本信息
```json
{
  "技能名称": "智慧康养助手",
  "技能英文名": "HarmonyHealthCare",
  "技能包名": "com.example.harmonyhealthcare.skill",
  "技能分类": "健康/医疗",
  "技能图标": "上传项目的Logo图片 (512x512 PNG)",
  "技能描述": "专业的老年人健康管理语音助手，提供挂号预约、健康查询、AR导航、紧急求助等功能",
  "触发词列表": [
    "智慧康养",
    "健康助手",
    "HarmonyHealth"
  ],
  "支持的语言": ["中文(简体)", "中文(繁体)"],
  "支持的设备类型": ["手机", "平板", "手表", "智慧屏"]
}
```

#### ⚠️ 关键配置说明

| 配置项 | 你的填写内容 | 说明 |
|--------|-------------|------|
| **触发词** | `智慧康养`、`健康助手` | 用户说这个词唤醒你的Skill |
| **包名** | 必须唯一 | 建议: `com.example.harmonyhealthcare.skill` |
| **分类** | 健康/医疗 | 影响审核速度和推荐位置 |
| **图标** | 项目Logo | 512x512像素，PNG格式 |

### Step 3: 选择Skill类型

选择 **"自定义Skill"** （不是模板Skill）

原因：
- ✅ 可以完全自定义意图和处理逻辑
- ✅ 支持复杂的业务场景
- ✅ 可以调用APP的Ability
- ❌ 模板Skill功能受限

---

## 4️⃣ 配置意图(Intent)

### 4.1 什么是意图？

**意图(Intent)** = 用户说的一句话 → 系统理解要做什么

例如：
- 用户说："帮我挂号张医生" → 意图 = `APPOINTMENT_BOOKING`
- 用户说："打开AR导航" → 意图 = `NAVIGATION`
- 用户说："救命" → 意图 = `EMERGENCY`

### 4.2 创建意图列表

在Skill控制台，点击 **"意图管理"** → **"添加意图"**

你需要创建以下 **8个核心意图**：

#### 📋 意图配置表

| # | 意图ID | 意图名称 | 示例语句 | 处理动作 |
|---|--------|----------|----------|----------|
| 1 | `appointment_booking` | 挂号预约 | "挂号"、"预约医生"、"看张医生明天上午" | 打开预约页面 |
| 2 | `navigation` | AR导航 | "导航去内科"、"怎么走"、"打开AR导航" | 启动AR导航 |
| 3 | `health_query` | 健康查询 | "血压怎么样"、"查看健康记录"、"体检报告" | 查询并展示数据 |
| 4 | `risk_assessment` | 风险评估 | "评估风险"、"健康检查"、"分析一下" | 调用MindSpore引擎 |
| 5 | `emergency` | 紧急求助 | "救命"、"打120"、"晕倒了" | 触发SOS流程 |
| 6 | `medication_reminder` | 用药提醒 | "吃药提醒"、"该吃药了"、"用药记录" | 打开用药页面 |
| 7 | `rehab_training` | 康复训练 | "康复训练"、"开始运动"、"太极课程" | 打开康复页面 |
| 8 | `device_control` | 设备管理 | "连接设备"、"配对手表"、"打开蓝牙" | 打开设备发现页 |

### 4.3 配置每个意图的详细步骤

以 **`appointment_booking`（挂号预约）** 为例：

#### Step 1: 填写基本信息
```
意图ID: appointment_booking
意图显示名称: 挂号预约服务
意图描述: 处理用户的医生预约和挂号请求
```

#### Step 2: 添加训练语句（至少10条）

在 **"训练语句"** 标签页添加：

```json
[
  "帮我挂号",
  "我想预约医生",
  "挂个号",
  "预约明天的门诊",
  "帮我看张医生",
  "我要挂号内科",
  "预约下周三上午",
  "挂专家号",
  "取消预约",
  "查询预约状态",
  "挂号张医生明天",
  "看看还有没有号",
  "预约妇科"
]
```

💡 **技巧**: 
- 覆盖多种表达方式（正式/口语）
- 包含实体信息（医生姓名、时间、科室）
- 至少10-20条训练语句以提高识别准确率

#### Step 3: 配置槽位(Slots)

槽位 = 从用户语句中提取的关键信息

为 `appointment_booking` 配置以下槽位：

| 槽位名称 | 槽位类型 | 是否必填 | 示例值 |
|----------|----------|----------|--------|
| `doctor_name` | 文本 | 否 | "张医生"、"李主任" |
| `time` | 时间 | 否 | "明天"、"后天"、"下周三" |
| `period` | 枚举 | 否 | "上午"、"下午"、"晚上" |
| `department` | 文本 | 否 | "内科"、"外科"、"妇科" |

#### Step 4: 配置回复动作

选择 **"启动应用Ability"** 作为处理动作：

```json
{
  "action_type": "start_ability",
  "ability_config": {
    "bundle_name": "com.example.harmonyhealthcare",
    "ability_name": "AppointmentsAbility",
    "params": {
      "intent_id": "appointment_booking",
      "doctor_name": "${doctor_name}",
      "time": "${time}",
      "period": "${period}",
      "department": "${department}"
    }
  },
  "voice_response": {
    "tts_text": "好的，正在为您${doctor_name ? '预约' + doctor_name : '打开预约页面'}...",
    "display_text": "正在跳转到预约页面..."
  }
}
```

#### Step 5: 重复以上步骤

为其余7个意图重复Step 1-4的配置。

**快捷方法**: 我已经为你准备了完整的意图配置JSON，见第5节。

---

## 5️⃣ 编写Skill代码

### 5.1 项目结构

在你的HarmonyOS项目中，Skill相关文件应该放在：

```
entry/src/main/
├── ets/
│   └── skill/
│       ├── HarmonyHealthCareSkill.ets     # Skill主入口
│       ├── intent/
│       │   ├── AppointmentIntentHandler.ets   # 挂号意图处理
│       │   ├── NavigationIntentHandler.ets    # 导航意图处理
│       │   ├── EmergencyIntentHandler.ets     # 紧急意图处理
│       │   └── ...                           # 其他意图处理器
│       └── utils/
│           ├── TTSUtil.ets                   # 语音合成工具
│           └── IntentParser.ets              # 意图解析工具
├── resources/
│   └── base/
│       └── profile/
│           └── skill_config.json            # Skill配置文件
└── module.json5                             # 模块声明（需修改）
```

### 5.2 创建Skill配置文件

创建文件：`entry/src/main/resources/base/profile/skill_config.json`

```json
{
  "skill": {
    "package": "com.example.harmonyhealthcare.skill",
    "name": "智慧康养助手",
    "version": "1.0.0",
    "versionCode": 1,
    "description": "专业的老年人健康管理语音助手",
    "icon": "$media:skill_icon",
    "triggerWords": [
      "智慧康养",
      "健康助手",
      "HarmonyHealth"
    ],
    "supportedLocales": ["zh-CN", "zh-TW", "en-US"],
    "intents": {
      "appointment_booking": {
        "displayName": "挂号预约",
        "enabled": true,
        "trainingPhrases": [
          "帮我挂号",
          "预约医生",
          "挂张医生的号",
          "我想看病"
        ],
        "slots": {
          "doctor_name": { "type": "text", "required": false },
          "time": { "type": "time", "required": false },
          "department": { "type": "text", "required": false }
        }
      },
      "navigation": {
        "displayName": "AR导航",
        "enabled": true,
        "trainingPhrases": [
          "导航去内科",
          "怎么走",
          "打开AR导航",
          "找一下放射科在哪"
        ]
      },
      "emergency": {
        "displayName": "紧急求助",
        "enabled": true,
        "priority": "high",
        "trainingPhrases": [
          "救命",
          "打120",
          "我不舒服",
          "晕倒了",
          "胸痛"
        ]
      },
      "health_query": {
        "displayName": "健康查询",
        "enabled": true,
        "trainingPhrases": [
          "血压怎么样",
          "查看血糖记录",
          "我的健康数据"
        ]
      },
      "risk_assessment": {
        "displayName": "风险评估",
        "enabled": true,
        "trainingPhrases": [
          "评估风险",
          "健康检查",
          "分析一下我的健康状况"
        ]
      },
      "medication_reminder": {
        "displayName": "用药提醒",
        "enabled": true,
        "trainingPhrases": [
          "吃药提醒",
          "该吃药了",
          "查看用药记录"
        ]
      },
      "rehab_training": {
        "displayName": "康复训练",
        "enabled": true,
        "trainingPhrases": [
          "康复训练",
          "开始运动",
          "太极课程"
        ]
      },
      "device_control": {
        "displayName": "设备管理",
        "enabled": true,
        " trainingPhrases": [
          "连接设备",
          "配对手表",
          "打开蓝牙"
        ]
      }
    },
    "capabilities": [
      "VOICE_INTERACTION",
      "APP_LAUNCH",
      "DATA_QUERY",
      "DEVICE_CONTROL"
    ],
    "privacyPolicyUrl": "https://your-domain.com/privacy",
    "termsOfServiceUrl": "https://your-domain.com/terms"
  }
}
```

### 5.3 编写Skill主入口文件

创建文件：`entry/src/main/ets/skill/HarmonyHealthCareSkill.ets`

```typescript
import { Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { XiaoyiAgent } from '../ai/agents/XiaoyiAgent';
import { AIOrchestrator } from '../ai/orchestrator/AIOrchestrator';

const TAG = '[HarmonyHealthCareSkill]';

export class HarmonyHealthCareSkill {
  private static instance: HarmonyHealthCareSkill | null = null;
  private orchestrator: AIOrchestrator;
  private xiaoyiAgent: XiaoyiAgent;

  private constructor() {
    this.orchestrator = AIOrchestrator.getInstance();
    this.xiaoyiAgent = new XiaoyiAgent();
    hilog.info(0x0000, TAG, 'Skill初始化完成');
  }

  public static getInstance(): HarmonyHealthCareSkill {
    if (!HarmonyHealthCareSkill.instance) {
      HarmonyHealthCareSkill.instance = new HarmonyHealthCareSkill();
    }
    return HarmonyHealthCareSkill.instance;
  }

  /**
   * 处理小艺语音请求
   * @param want 小艺传递的意图信息
   * @returns 处理结果（TTS文本和动作）
   */
  async handleVoiceRequest(want: Want): Promise<SkillResponse> {
    const startTime = Date.now();
    
    try {
      // 1. 解析意图
      const intentId = this.extractIntentId(want);
      const userQuery = this.extractUserQuery(want);
      
      hilog.info(0x0000, TAG, `收到语音请求: intent=${intentId}, query=${userQuery}`);

      // 2. 构建AI请求
      const aiRequest = this.buildAIRequest(want, intentId, userQuery);

      // 3. 调用智能体处理
      const aiResponse = await this.xiaoyiAgent.process(aiRequest);

      // 4. 构建Skill响应
      const response: SkillResponse = {
        ttsText: typeof aiResponse.output.content === 'string' 
          ? aiResponse.output.content 
          : JSON.stringify(aiResponse.output.content),
        displayText: aiResponse.output.content as string,
        action: this.determineAction(intentId, want),
        confidence: aiResponse.output.confidence,
        suggestions: aiResponse.suggestions,
        metadata: {
          processingTime: aiResponse.metadata.processingTime,
          agentUsed: aiResponse.agentId,
          intentId: intentId
        }
      };

      hilog.info(0x0000, TAG, 
        `处理完成 (${Date.now() - startTime}ms), 置信度=${response.confidence}`);

      return response;

    } catch (error) {
      hilog.error(0x0000, TAG, `处理失败: ${error}`);
      return this.createErrorResponse(error as string);
    }
  }

  /**
   * 处理快捷命令（无需唤醒词）
   */
  async handleQuickCommand(command: string): Promise<SkillResponse> {
    const want: Want = {
      parameters: {
        query: command,
        quickCommand: true
      }
    };
    
    return this.handleVoiceRequest(want);
  }

  private extractIntentId(want: Want): string {
    return want.parameters?.['intentId'] as string || 'general_chat';
  }

  private extractUserQuery(want: Want): string {
    return want.parameters?.['query'] as string || '';
  }

  private buildAIRequest(
    want: Want, 
    intentId: string, 
    userQuery: string
  ): any {
    return {
      requestId: `skill_${Date.now()}`,
      userId: want.parameters?.['userId'] || 'anonymous',
      input: {
        type: 'voice',
        content: userQuery,
        metadata: {
          deviceType: want.parameters?.['deviceType'] || 'phone',
          timestamp: Date.now(),
          context: want.parameters
        }
      },
      preferences: {
        preferredAgent: 'xiaoyi',
        priority: this.getPriorityByIntent(intentId),
        maxLatency: intentId === 'emergency' ? 200 : 1000
      }
    };
  }

  private getPriorityByIntent(intentId: string): 'speed' | 'accuracy' | 'privacy' {
    const emergencyIntents = ['emergency'];
    const privacyIntents = ['health_query', 'risk_assessment'];
    
    if (emergencyIntents.includes(intentId)) return 'speed';
    if (privacyIntents.includes(intentId)) return 'privacy';
    return 'accuracy';
  }

  private determineAction(intentId: string, want: Want): SkillAction {
    const actionMap: Record<string, SkillAction> = {
      'appointment_booking': {
        type: 'start_ability',
        bundleName: 'com.example.harmonyhealthcare',
        abilityName: 'AppointmentsAbility',
        params: want.parameters
      },
      'navigation': {
        type: 'start_ability',
        bundleName: 'com.example.harmonyhealthcare',
        abilityName: 'ARNavigationAbility',
        params: want.parameters
      },
      'emergency': {
        type: 'custom',
        handler: 'handleEmergency',
        params: {
          urgency: 'high',
          autoCall120: true,
          notifyContacts: true
        }
      },
      'health_query': {
        type: 'start_ability',
        bundleName: 'com.example.harmonyhealthcare',
        abilityName: 'HealthRecordsAbility',
        params: want.parameters
      },
      'default': {
        type: 'tts_only'
      }
    };

    return actionMap[intentId] || actionMap['default'];
  }

  private createErrorResponse(error: string): SkillResponse {
    return {
      ttsText: '抱歉，我暂时无法处理您的请求，请稍后再试。',
      displayText: error,
      action: { type: 'tts_only' },
      confidence: 0,
      metadata: {
        processingTime: 0,
        agentUsed: 'none',
        intentId: 'error'
      },
      error: error
    };
  }
}

// 类型定义
interface SkillResponse {
  ttsText: string;              // TTS播报的文本
  displayText: string;          // 屏幕显示的文本
  action: SkillAction;          // 要执行的动作
  confidence: number;           // 置信度 0-1
  suggestions?: string[];       // 建议操作
  metadata: SkillMetadata;      // 元数据
  error?: string;               // 错误信息
}

interface SkillAction {
  type: 'start_ability' | 'tts_only' | 'custom' | 'send_event';
  bundleName?: string;
  abilityName?: string;
  params?: Record<string, any>;
  handler?: string;
}

interface SkillMetadata {
  processingTime: number;
  agentUsed: string;
  intentId: string;
}

// 导出单例实例
export default HarmonyHealthCareSkill.getInstance();
```

### 5.4 修改module.json5

在 `entry/src/main/module.json5` 中添加Skill声明：

```json5
{
  "module": {
    "name": "entry",
    "type": "entry",
    // ... 其他配置 ...

    "skills": [
      {
        "name": "HarmonyHealthCareSkill",
        "srcEntry": "./ets/skill/HarmonyHealthCareSkill.ets",
        "description": "智慧康养语音助手Skill",
        "icon": "$media:skill_icon",
        "capabilities": [
          "ohos.skill.action.VOICE_INTERACTION"
        ],
        "metadata": {
          "customizeData": [
            {
              "name": "hiai.skill.config",
              "resource": "$profile:skill_config",
              "extra": ""
            }
          ]
        }
      }
    ],

    "requestPermissions": [
      // ... 已有的权限 ...
      {
        "name": "ohos.permission.MICROPHONE",
        "reason": "$string:microphone_permission_reason",
        "usedScene": {
          "abilities": ["HarmonyHealthCareSkill"],
          "when": "always"
        }
      }
    ]
  }
}
```

---

## 6️⃣ 本地测试

### 6.1 使用DevEco Studio模拟器测试

#### Step 1: 启动模拟器
1. 打开DevEco Studio
2. 点击 **Tools** → **Device Manager**
3. 创建一个新的模拟器（选择 **Phone** 类型）
4. 启动模拟器

#### Step 2: 运行Skill
1. 在DevEco Studio中打开项目
2. 点击运行按钮（或按 Shift+F10）
3. 选择刚创建的模拟器
4. 等待应用安装完成

#### Step 3: 测试语音交互

在模拟器中：

**方法A: 通过小艺界面测试**
```
1. 从屏幕底部上滑，打开控制中心
2. 找到并点击"小艺"图标
3. 说："智慧康养，帮我挂号"
4. 观察是否正确响应
```

**方法B: 通过代码直接调用测试**
```typescript
// 在任意Page中添加测试代码
import HarmonyHealthCareSkill from '../skill/HarmonyHealthCareSkill';

async testSkill() {
  const skill = HarmonyHealthCareSkill;
  
  // 测试挂号意图
  const result1 = await skill.handleQuickCommand("帮我挂号张医生明天");
  console.log('挂号测试:', result1.ttsText);
  
  // 测试紧急意图
  const result2 = await skill.handleQuickCommand("救命！");
  console.log('紧急测试:', result2.ttsText);
  
  // 测试导航意图
  const result3 = await skill.handleQuickCommand("导航去内科");
  console.log('导航测试:', result3.ttsText);
}
```

### 6.2 测试用例清单

创建测试文档，逐一验证：

| # | 测试场景 | 输入语句 | 预期结果 | 实际结果 | 状态 |
|---|----------|----------|----------|----------|------|
| 1 | 基本挂号 | "帮我挂号" | 打开预约页面 | | ⬜ |
| 2 | 指定医生 | "挂号张医生" | 显示张医生信息 | | ⬜ |
| 3 | 指定时间 | "预约明天上午" | 默认明天上午 | | ⬜ |
| 4 | AR导航 | "导航去内科" | 启动AR导航 | | ⬜ |
| 5 | 健康查询 | "血压怎么样" | 显示血压数据 | | ⬜ |
| 6 | 风险评估 | "评估风险" | 生成风险报告 | | ⬜ |
| 7 | 紧急SOS | "救命！" | 触发紧急流程 | | ⬜ |
| 8 | 用药提醒 | "该吃药了" | 打开用药页面 | | ⬜ |
| 9 | 康复训练 | "开始运动" | 打开康复课程 | | ⬜ |
| 10 | 设备连接 | "连接设备" | 发现页打开 | | ⬜ |

---

## 7️⃣ 真机调试

### 7.1 准备真机

**推荐的测试设备**：
- ✅ Huawei Mate 60 Pro/Pro+ (HarmonyOS NEXT 4.0+)
- ✅ Huawei MatePad Pro 13.2
- ✅ Huawei Watch 4 Pro/Ultimate Design

**不支持的设备**：
- ❌ HarmonyOS 4.0以下的设备（不支持新Skill框架）
- ❌ 非华为品牌手机

### 7.2 连接真机调试

#### Step 1: USB连接
1. 用USB线连接手机和电脑
2. 手机上弹出提示时选择 **"传输文件(MTP)"** 模式

#### Step 2: 开启开发者模式
```
手机设置 → 关于手机 → 连续点击"版本号"7次
→ 返回设置 → 系统和更新 → 开发人员选项
→ 开启:
  ✓ USB调试
  ✓ "仅充电"模式下允许ADB调试
  ✓ 安装未知应用（允许DevEco Studio）
```

#### Step 3: 在DevEco Studio中选择真机
1. 点击运行设备的下拉框
2. 选择你的真机（会显示型号和序列号）
3. 点击运行

#### Step 4: 测试语音唤醒
```
1. 确保手机网络正常
2. 长按电源键1秒（或说"小艺小艺"）
3. 等待小艺唤醒动画出现
4. 说："智慧康养，帮我挂号"
5. 观察响应
```

### 7.3 真机测试注意事项

⚠️ **重要提醒**:

1. **麦克风权限**: 首次使用时会弹窗请求权限，必须允许
2. **网络要求**: 语音识别需要联网（离线模式有限制）
3. **后台限制**: 部分机型需要在后台运行设置中允许Skill常驻
4. **电量影响**: 低电量模式下可能禁用语音助手
5. **隐私模式**: 如果开启了隐私保护，可能无法录音

---

## 8️⃣ 提交审核与发布

### 8.1 提交前检查清单

确保所有项目都已完成：

```
✅ 所有8个意图都已配置训练语句（每个至少10条）
✅ Skill代码无编译错误和警告
✅ 本地测试通过全部10个测试用例
✅ 真机测试通过基本功能
✅ Skill图标符合规范（512x512 PNG）
✅ 描述文字清晰准确
✅ 隐私政策链接有效（如果提供）
✅ 无敏感权限滥用（如不必要的通讯录读取）
```

### 8.2 提交审核

1. 回到 **Skill Studio控制台**
2. 选择你的Skill项目
3. 点击 **"提交审核"** 按钮
4. 填写审核信息：
   ```
   版本号: 1.0.0
   更新日志: 
   - 初始版本发布
   - 支持8种核心意图
   - 挂号、导航、健康查询、紧急求助等
   
   审核备注: 
   参加华为创新极客赛项目，用于智慧康养场景演示
   ```

5. 上传必要的附件：
   - Skill截图（至少3张：主界面、对话示例、功能展示）
   - Demo视频（可选但强烈推荐）

6. 确认提交

### 8.3 审核流程和时间

```
提交审核
    ↓
[自动检测] 代码规范、权限使用、安全性扫描 (约30分钟)
    ↓
[人工审核] 功能测试、体验评估、合规性检查 (1-3个工作日)
    ↓
审核结果通知（邮件+站内信）
    ↓
├─→ ✅ 通过 → 可以发布上线
└─→ ❌ 不通过 → 根据反馈修改后重新提交
```

### 8.4 常见审核不通过原因及解决方法

| 原因 | 解决方案 |
|------|----------|
| 权限申请过多 | 删除不必要的权限，只保留必需的 |
| 训练语句太少 | 每个意图至少补充到15-20条 |
| 图标不符合规范 | 重新设计512x512的简洁图标 |
| 描述不准确 | 修改描述，确保与实际功能一致 |
| 存在崩溃Bug | 修复所有已知Crash问题 |
| 违反内容规范 | 移除敏感词汇和不适当内容 |

### 8.5 发布上线

审核通过后：

1. 回到Skill控制台
2. 点击 **"发布"** 按钮
3. 选择发布范围：
   - **灰度发布** (推荐先选这个): 先给少量用户体验
   - **全量发布**: 所有用户都可以使用

4. 确认发布

🎉 **恭喜！你的小艺Skill正式上线！**

---

## 9️⃣ 常见问题FAQ

### Q1: 我没有HarmonyOS NEXT的真机能测试吗？
**A**: 可以先用模拟器测试大部分逻辑。但语音唤醒和真实NLU需要真机。建议借一台或购买二手Mate 60。

### Q2: 审核一般要多长时间？
**A**: 正常情况下1-3个工作日。比赛期间可能会快一些。建议提前3-5天提交。

### Q3: Skill被拒怎么办？
**A**: 不要慌！仔细阅读拒绝原因，针对性修改。大多数问题都是小问题（权限、描述、图标），修改后重新提交即可。

### Q4: 如何提高意图识别准确率？
**A**: 
- 增加训练语句数量（20-30条最佳）
- 覆盖不同的表达方式（口语化、正式、方言）
- 使用同义词和近义词
- 定期根据用户反馈优化

### Q5: 能否同时支持多个触发词？
**A**: 可以！最多支持5个触发词。我们配置了3个："智慧康养"、"健康助手"、"HarmonyHealth"

### Q6: Skill能调用其他APP吗？
**A**: 可以！通过Want机制可以启动其他APP的Ability。但对方APP也需要配合。

### Q7: 数据安全如何保障？
**A**: 
- 敏感数据（健康数据）在端侧处理，不上传云端
- 使用TEE可信环境存储密钥
- 符合GDPR和HIPAA标准
- 详见项目的隐私保护模块

### Q8: 比赛中需要现场演示Skill吗？
**A**: 很有可能！建议提前录制好Demo视频作为备份，同时准备真机现场演示。

---

## 📞 技术支持资源

### 官方文档
- **Skill开发指南**: https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/
- **意图配置文档**: https://developer.huawei.com/consumer/cn/hiai/skill/intent-config
- **API参考**: https://developer.huawei.com/consumer/cn/hiai/api-reference/

### 社区资源
- **华为开发者论坛**: https://developer.huawei.com/consumer/cn/forum/
- **CSDN HarmonyOS专栏**: 搜索"小艺Skill开发"
- **GitHub示例项目**: 搜索"Huawei HiAi Skill Sample"

### 本项目资源
- **架构文档**: `doc_md/AI_MULTI_AGENT_ARCHITECTURE.md`
- **核心代码**: `entry/src/main/ets/ai/agents/XiaoyiAgent.ts`
- **快速开始**: `entry/src/main/ets/ai/QUICK_START.ts`

---

## 📝 下一步行动清单

### ✅ 今天立即做（30分钟）

- [ ] 1. 注册/登录华为开发者联盟账号
- [ ] 2. 完成实名认证（如果还没做）
- [ ] 3. 阅读本文档第3-4节，理解Skill配置要点

### 📅 明天（2小时）

- [ ] 4. 在Skill Studio创建项目
- [ ] 5. 复制粘贴第5节的配置文件代码
- [ ] 6. 配置8个意图（使用提供的JSON模板）

### 📅 后天（2小时）

- [ ] 7. 编写Skill主入口代码（复制第5.3节代码）
- [ ] 8. 修改module.json5
- [ ] 9. 模拟器测试

### 📅 大后天（1小时）

- [ ] 10. 真机测试（如果有设备的话）
- [ ] 11. 准备审核材料（截图、视频）
- [ ] 12. 提交审核

---

## 💡 成功秘诀

1. **尽早开始**: 审核需要1-3天，预留充足时间
2. **多测试**: 模拟器+真机都要测，覆盖所有场景
3. **参考范例**: 多看官方示例和优秀案例
4. **保持沟通**: 遇到问题及时在论坛提问或联系技术支持
5. **准备Plan B**: 即使Skill没过审，内置的语音识别也能演示

---

**祝你成功！有任何问题随时问我！** 💪🎉

**最后更新**: 2026-05-12  
**作者**: AI Assistant Team  
**版本**: v1.0
