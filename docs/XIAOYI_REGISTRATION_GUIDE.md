# 🎤 小艺智能体对接 - 完整注册与配置指南

> **目标**: 完成小艺Skill/MCP对接，满足华为创新极客赛硬性要求
>
> **预计耗时**: 2-3小时
> **难度等级**: ⭐⭐ 中等

---

## 📋 目录

1. [前置准备](#1-前置准备)
2. [步骤一：注册华为开发者账号](#2-步骤一注册华为开发者账号)
3. [步骤二：申请小艺开发者权限](#3-步骤二申请小艺开发者权限)
4. [步骤三：创建应用并获取凭证](#4-步骤三创建应用并获取凭证)
5. [步骤四：配置医疗Skill](#5-步骤四配置医疗skill)
6. [步骤五：MCP协议对接](#6-步骤五mcp协议对接)
7. [步骤六：测试验证](#7-步骤六测试验证)
8. [常见问题FAQ](#8-常见问题faq)

---

## 1. 前置准备

### 需要准备的资料：
- ✅ 手机号（用于接收验证码）
- ✅ 电子邮箱（建议用Gmail或QQ邮箱）
- ✅ 身份证信息（实名认证需要）
- ✅ 项目名称：**星云医疗助手** (Nebula Medical Assistant)

### 推荐浏览器：
- Chrome 或 Edge（最新版）
- 不要用IE或旧版浏览器！

---

## 2. 步骤一：注册华为开发者账号

### 📍 访问官网

```
🔗 https://developer.huawei.com/consumer/cn/
```

### 📸 操作截图指引：

#### Step 1: 进入首页
```
┌─────────────────────────────────────────────────────┐
│                                                     │
│    🔵 HUAWEI DEVELOPER                              │
│                                                     │
│    ┌─────────┐                                      │
│    │ 登录/注册 │ ← 点击这里                          │
│    └─────────┘                                      │
│                                                     │
│    [华为账号登录]  [HMS Core]  [AppGallery Connect]   │
│                                                     │
└─────────────────────────────────────────────────────┘
```

#### Step 2: 选择注册方式
```
选择: "注册华为账号"

推荐方式:
├── ✅ 手机号注册（最快）
└── ✅ 邮箱注册（备选）

⚠️ 注意: 使用真实信息，后续需要实名认证！
```

#### Step 3: 填写注册信息
```yaml
必填字段:
  - 用户名: 你的名字拼音 (如: zhangsan)
  - 密码: 大小写+数字+特殊字符 (至少8位)
  - 手机号: 138xxxx8888
  - 验证码: [输入收到的6位数]

可选字段:
  - 头像: 可以后续设置
  - 个人简介: 可以跳过
```

#### Step 4: 实名认证（重要！）
```
位置: 个人中心 → 账号安全 → 实名认证

需要的材料:
├── 身份证件照片（正反面）
├── 人脸识别（手机APP扫描）
└── 等待审核（通常10分钟内通过）

⏰ 审核时间: 工作日 10-30分钟
   周末可能延长到24小时
```

---

## 3. 步骤二：申请小艺开发者权限

### 🔑 关键入口（2026年最新）:

```
方式A（推荐）:
https://developer.huawei.com/consumer/cn/service/hms/catalog/hiai.html?page=hmssdk_hiai_introduce

方式B（备选）:
https://developer.huawei.com → 应用服务 → AI服务 → 智慧语音 → 小艺
```

### 📸 界面导航图：

```
华为开发者网站主页
        │
        ▼
┌───────────────────────────────────────┐
│  🧭 导航栏                             │
│  ┌────────┬────────┬────────┐         │
│  │ 开发   │ 应用服 │ 文档   │         │
│  └────────┴────────┴────────┘         │
│                                       │
│  点击 "应用服务"                       │
│        ↓                              │
│  ┌─────────────────────────────────┐  │
│  │ AI & ML                         │  │
│  │ ├── 机器学习服务                 │  │
│  │ ├── 计算机视觉                   │  │
│  │ ├── 自然语言处理                 │  │
│  │ └── 🎯 智慧语音 (点这里!)       │  │
│  └─────────────────────────────────┘  │
│                                       │
│  点击 "智慧语音"                       │
│        ↓                              │
│  ┌─────────────────────────────────┐  │
│  │ 智慧语音能力                     │  │
│  │ ├── 语音识别 (ASR)               │  │
│  │ ├── 语音合成 (TTS)               │  │
│  │ ├── 语义理解 (NLU)               │  │
│  │ └── 🎯 小艺开放平台 (点这里!)     │  │
│  └─────────────────────────────────┘  │
└───────────────────────────────────────┘
```

### 📝 申请流程：

#### Step 1: 进入小艺开放平台
```
找到 "立即接入" 或 "申请体验" 按钮
点击进入申请页面
```

#### Step 2: 填写申请表单
```json
{
  "应用名称": "星云医疗助手",
  "应用类型": "医疗健康",
  "使用场景": "老年人健康管理、智能问诊、用药提醒",
  "预计用户规模": "1000人以内（比赛项目）",
  "技术联系人": {
    "姓名": "你的真实姓名",
    "邮箱": "你的邮箱@example.com",
    "电话": "138xxxx8888"
  },
  "所需能力": [
    "Skill开发",
    "MCP协议对接",
    "语音唤醒",
    "意图识别"
  ]
}
```

#### Step 3: 等待审批
```
提交时间: 通常即时或1-2个工作日

查看状态:
├── 我的申请 → 申请列表
└── 查看审批进度

状态说明:
├── ⏳ 待审核: 正在排队
├── ✅ 已通过: 可以开始开发了!
├── ❌ 被驳回: 根据原因修改后重新提交
└── ⚠️ 需补充材料: 按要求上传文件
```

---

## 4. 步骤三：创建应用并获取凭证

### 📍 进入 AppGallery Connect

```
🔗 https://appgallery.huawei.com/
或
🔗 https://developer.huawei.com/consumer/cn/console#/home
```

### 📸 创建应用：

#### Step 1: 创建项目
```
左侧菜单: 我的项目 → 创建新项目

填写:
├── 项目名称: 星云医疗助手_NebulaMedical
├── 项目类型: HarmonyOS应用
└── 描述: 面向老年人的智能医疗助手
```

#### Step 2: 在项目中添加应用
```
点击刚创建的项目
→ "添加应用"
→ 填写信息:

应用名称: 星云医疗助手
包名: com.example.nebulamedical
分类: 医疗健康
支持设备: Phone / Tablet
签名证书: 后续配置（先跳过）
```

#### Step 3: 获取关键凭证 ⭐⭐⭐
```
在应用详情页找到:

┌─────────────────────────────────────────┐
│  应用信息                                │
│  ─────────────────                      │
│  APP ID: 123456789  ← ⚠️ 复制保存!      │
│                                         │
│  Client ID: abcdefgh12345678  ← ⚠️ 复制! │
│                                         │
│  Client Secret: xxxxxxxx...  ← ⚠️ 复制!  │
│  [显示] [复制]                            │
└─────────────────────────────────────────┘

⚠️ 重要提示:
这些凭证后面要填入代码中，务必妥善保管！
不要泄露给他人！
```

---

## 5. 步骤四：配置医疗Skill

### 🎯 这是核心步骤！我们需要注册8个Skill

### 📍 进入 Skill管理后台

```
路径: 小艺开放平台 → Skill管理 → 创建Skill
或
路径: 应用配置 → 小艺Skill → 新建
```

### 📝 Skill 1: 健康数据查询

```json
{
  "skillId": "medical.query.health",
  "skillName": "健康数据查询",
  "skillDescription": "查询用户的血压、血糖、心率等最新健康数据",
  
  "触发词配置": [
    "查.*血压|血压.*多少|最近.*血压",
    "查.*血糖|血糖.*多少|空腹.*血糖", 
    "查.*心率|心跳.*多少|脉搏.*情况",
    "健康.*数据|体检.*结果|身体.*指标",
    "最近.*体重|体重.*变化"
  ],
  
  "示例语句": [
    "小艺，帮我查一下血压",
    "我的血糖正常吗？",
    "看看最近的心率数据",
    "今天的步数是多少"
  ],
  
  "回调配置": {
    "回调URL": "https://your-domain.com/api/xiaoyi/callback",
    "请求方式": "POST",
    "认证方式": "Bearer Token"
  },
  
  "响应格式": {
    "voiceResponse": "string (必填, 语音回复内容)",
    "uiResponse": "object (可选, UI展示数据)",
    "action": "object (可选, 跳转动作)"
  }
}
```

### 📝 Skill 2: AI智能问诊

```json
{
  "skillId": "medical.ai.consultation",
  "skillName": "AI智能问诊",
  "skillDescription": "启动AI医生进行症状分析和初步诊断建议",
  
  "触发词配置": [
    "不舒服|难受|身体不适|生病了|看病|问诊",
    "(头|胃|肚子|胸|腰|腿).*(疼|痛|胀|酸)",
    "AI.*问诊|智能.*医生|在线.*咨询"
  ],
  
  "示例语句": [
    "小艺，我不舒服，头疼三天了",
    "我肚子疼怎么办",
    "打开AI问诊功能"
  ],
  
  "特殊配置": {
    "needAuth": true,
    "estimatedTime": "3000ms",
    "fallbackAction": "openAiChatPage"
  }
}
```

### 📝 其他6个Skill快速配置表

| # | skillId | 名称 | 触发词示例 |
|---|---------|------|-----------|
| 3 | `medical.risk.assess` | 风险评估 | "评估风险"、"健康评分" |
| 4 | `medical.medication.remind` | 用药提醒 | "提醒吃药"、"吃药时间" |
| 5 | `medical.navigation.start` | 科室导航 | "导航到XX"、"去内科怎么走" |
| 6 | `medical.emergency.sos` | 紧急求助 | "救命"、"SOS"、"紧急" |
| 7 | `medical.device.connect` | 设备连接 | "连接手环"、"连接血压计" |
| 8 | `medical.rehab.start` | 康复训练 | "开始康复"、"康复训练" |

### 💡 配置技巧：

```
✅ 触发词设计原则:
├── 使用自然语言表达（像真人说话）
├── 包含同义词变体（"查血压" = "血压多少" = "看看血压"）
├── 使用正则表达式匹配（"查.*血压" 匹配多种说法）
└── 设置置信度阈值（避免误触发）

❌ 常见错误:
├── 触发词太短（如只用"查"字会误触）
├── 没有测试边界case（如"查天气预报"不该触发）
└── 忘记配置降级方案（Skill失败时怎么办）
```

---

## 6. 步骤五：MCP协议对接

### 🔗 什么是MCP？

```
MCP = Model Context Protocol (模型上下文协议)

作用: 让小艺能够调用你应用中的工具和能力

类比: 就像是给小艺装了一个"插件"，让它能操控你的App
```

### 📋 MCP配置步骤：

#### Step 1: 在小艺后台启用MCP
```
位置: 应用设置 → 高级设置 → MCP协议

开启开关: ✅ 启用MCP能力

选择模式:
├── Server模式 (推荐): 你的应用作为MCP服务器
└── Client模式: 你的应用调用其他MCP服务
```

#### Step 2: 配置MCP端点
```yaml
# 在小艺后台填写
mcp_endpoint: https://your-server.com/mcp  # 你的服务器地址
transport_type: stdio  # 或 HTTP/SSE
auth_method: bearer_token
capabilities:
  tools: true          # 允许调用工具
  resources: true      # 允许访问资源
  prompts: true        # 允许使用提示词模板
```

#### Step 3: 更新代码中的配置

编辑文件: `entry/src/main/ets/xiaoyi/XiaoyiSkillManager.ets`

```typescript
// 在文件顶部添加配置
const XIAOYI_CONFIG = {
  // 从AppGallery Connect获取的凭证
  appId: '123456789',              // ← 替换为你的APPID
  clientId: 'abcdefgh12345678',    // ← 替换为你的ClientID
  clientSecret: 'YOUR_SECRET',     // ← 替换为你的ClientSecret
  
  // MCP端点配置
  mcpEndpoint: 'https://xiaoyi-api.huawei.com/v1/mcp',
  
  // 回调地址（本地调试用，上线时改为真实域名）
  callbackUrl: 'http://localhost:8080/api/xiaoyi/callback',
  
  // Skill注册信息
  skills: [
    { id: 'medical.query.health', enabled: true },
    { id: 'medical.ai.consultation', enabled: true },
    { id: 'medical.risk.assess', enabled: true },
    { id: 'medical.medication.remind', enabled: true },
    { id: 'medical.navigation.start', enabled: true },
    { id: 'medical.emergency.sos', enabled: true },
    { id: 'medical.device.connect', enabled: true },
    { id: 'medical.rehab.start', enabled: true }
  ]
};
```

#### Step 4: 测试MCP连接
```typescript
// 创建测试文件: entry/src/main/ets/test/TestXiaoyiConnection.ets

import { xiaoyiSkillManager } from '../xiaoyi/XiaoyiSkillManager';

async function testXiaoyiConnection() {
  console.log('=== 开始测试小艺连接 ===');
  
  try {
    // 初始化
    const initResult = await xiaoyiSkillManager.initialize();
    console.log('初始化结果:', initResult);
    
    // 测试自动路由
    const response = await xiaoyiSkillManager.autoRouteAndProcess(
      '帮我查血压',
      'test_user_001'
    );
    
    console.log('路由成功!');
    console.log('Skill ID:', response.skillId);
    console.log('回复内容:', response.voiceResponse);
    console.log('处理时间:', response.processingTime + 'ms');
    
    return true;
  } catch (error) {
    console.error('连接失败:', error);
    return false;
  }
}

// 执行测试
testXiaoyiConnection();
```

---

## 7. 步骤六：测试验证

### ✅ 测试清单

#### Level 1: 基础连通性测试
```bash
# 终端执行命令
cd e:\harmony-health-care
hvigorw assembleHap --mode module -p product=default

# 如果编译成功，说明代码没问题
```

#### Level 2: Skill触发测试
```typescript
// 在模拟器或真机上运行App
// 然后依次说以下指令测试每个Skill:

测试用例:
├── ✅ "小艺，帮我查血压" 
│   └── 预期: 返回血压数据 + 打开健康页
│
├── ✅ "小艺，我不舒服"
│   └── 预期: 打开AI问诊页面
│
├── ✅ "小艺，导航到内科"
│   └── 预期: 显示导航路线
│
├── ✅ "小艺，救命"
│   └── 预预期: 触发紧急呼叫
│
└── ✅ "小艺，提醒我吃药"
    └── 预期: 设置用药提醒
```

#### Level 3: 端到端集成测试
```javascript
// 测试完整流程: 语音输入 → Skill匹配 → 业务逻辑 → 语音输出

async function runE2ETest() {
  const orchestrator = new AIOrchestrator();
  await orchestrator.initialize();
  
  const testCases = [
    { query: '查血压', expectedSkill: 'medical.query.health' },
    { query: '我不舒服', expectedSkill: 'medical.ai.consultation' },
    { query: '救命', expectedSkill: 'medical.emergency.sos' }
  ];
  
  for (const tc of testCases) {
    const result = await orchestrator.processRequest({
      type: 'voice_command',
      query: tc.query,
      userId: 'e2e_test_user'
    });
    
    console.assert(result.success === true, `${tc.query} 应该成功`);
    console.log(`✅ ${tc.query} -> ${result.aiSource}`);
  }
}

runE2ETest();
```

---

## 8. 常见问题 FAQ

### Q1: 注册被拒绝了怎么办？
```
常见原因及解决方案:

1️⃣ 信息不完整
   解决: 补充完整的项目描述和使用场景

2️⃣ 类目不符
   解决: 强调这是"医疗健康"类应用，符合政策导向

3️⃣ 缺少资质
   解决: 上传学生证或比赛证明文件

4️⃣ 审核慢
   解决: 工作日联系客服催审 (400-930-0030)
```

### Q2: 没有服务器可以部署回调吗？
```
解决方案:

方案A: 本地开发阶段
├── 使用 ngrok/frp 内网穿透
└── 将localhost映射到公网

方案B: 使用云函数
├── 华为云FunctionGraph (免费额度)
└── 无需自己维护服务器

方案C: 模拟模式 (当前代码支持)
├── 代码已内置Mock数据
└── 先完成功能开发，后续再接真实环境
```

### Q3: API Key泄露了怎么办？
```
紧急处理:

1️⃣ 立即在小艺后台重置密钥
2️⃣ 更新代码中的配置
3️⃣ 重新部署应用
4️⃣ 检查是否有异常调用记录

预防措施:
├── 不要把Key提交到Git公开仓库
├── 使用环境变量存储敏感信息
└── 定期轮换密钥
```

### Q4: Skill触发不准确？
```
优化方法:

1️⃣ 增加更多触发词变体
   例: ["查血压", "血压多少", "血压情况", "看血压"]

2️⃣ 调整置信度阈值
   太低 → 误触发增多
  太高 → 无法识别

3️⃣ 添加否定词过滤
   例: "不查血压" 不应触发

4️⃣ 收集用户真实语料持续迭代
```

### Q5: 如何证明已完成对接（用于比赛提交）？
```
准备以下材料:

📦 代码证据:
├── XiaoyiSkillManager.ets (Skill管理器)
├── 8个Skill实现文件
└── MCP协议处理代码

🖼️ 截图证据:
├── 小艺开发者后台的应用截图
├── Skill配置页面截图
├── MCP启用状态截图
└── 测试运行效果视频/GIF

📄 文档:
├── 技术架构图 (已有 AI_ARCHITECTURE_DESIGN.md)
├── 对接流程说明 (本文件)
└── 测试报告
```

---

## 📞 获取帮助

如果遇到问题：

1. **官方文档**: https://developer.huawei.com/consumer/cn/doc/
2. **技术社区**: https://club.huawei.com/forum-1175-1.html
3. **客服热线**: 400-930-0030 (工作日 9:00-18:00)
4. **开发者群**: 搜索"HarmonyOS开发者交流群"加入

---

## ✅ 完成检查清单

完成以下所有项后，你就成功对接小艺了！

- [ ] ✅ 注册华为开发者账号并通过实名认证
- [ ] ✅ 成功申请小艺开发者权限
- [ ] ✅ 在AppGallery Connect创建应用并获取凭证
- [ ] ✅ 配置完成8个医疗Skill（至少1个可工作）
- [ ] ✅ 启用MCP协议并配置端点
- [ ] ✅ 更新代码中的API Key和配置
- [ ] ✅ 通过基础连通性测试
- [ ] ✅ 录制演示视频（比赛提交用）

---

## 🎉 下一步

完成小艺对接后，你可以继续：

1. **完善Coze Bot** (可选加分项)
2. **训练MindSpore模型** (锦上添花)
3. **优化UI交互体验**
4. **编写比赛答辩PPT**

---

**文档版本**: v1.0
**最后更新**: 2026-05-11
**适用场景**: 华为创新极客赛 - 星云医疗助手项目
