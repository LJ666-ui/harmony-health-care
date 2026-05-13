# 🧪 AI功能真实测试指南（修正版）

> **基于代码实际分析 + 已修复的问题**

---

## ⚠️ 重要更正（2026-05-13）

| 之前说的 | 实际情况 | 状态 |
|---------|---------|------|
| AI助手用DeepSeek | **实际用Coze** ❌ | ✅已修复为DeepSeek |
| AI健康顾问用DeepSeek | **实际用orchestrator→Coze** ❌ | ✅已修复为DeepSeek |
| Coze能正常工作 | **模拟器访问不了coze.cn** ❌ | 现在改用DeepSeek了 |

---

## 🔑 第一步：登录（必须！）

### 为什么会跳到登录页？

[Index.ets](entry/src/main/ets/pages/Index.ets#L30) 检测设备类型：
```
手表设备 → WatchHomePage
其他设备 → Login页面 ← 你在这！
```

### Mock测试账号

来自 [loginMock.ets](entry/src/main/ets/mock/loginMock.ets)：

| 手机号 | 密码 | 身份 | 用途 |
|--------|------|------|------|
| `13948999643` | `123456` | 普通用户 | ⭐推荐用这个 |
| `13800138000` | `123456` | 张三 | 备选 |
| `13900000001` | `123456` | 李医生(医生端) | 测试医生功能 |
| `13900000002` | `123456` | 王医生(医生端) | 备选 |

### 操作步骤
```
1. 启动应用 → 看到"星云医疗助手"启动页（2秒）
2. 自动跳转到 Login 页面
3. 输入: 13948999643
4. 输入: 123456
5. 点 [登录] → 进主页！✅
```

---

## 📍 第二步：找到AI入口

### 从你的截图看到的界面

#### 截图1：AI助手页面（首页/发现→AI工具箱）
```
位置: 发现页 → AI工具箱 → [AI智能问答助手]
       或 首页底部导航 → 找AI相关入口

实际文件: AiChatPage.ets (路由第42行)
调用AI: 🧠 DeepSeek (✅已修复)
```

#### 截图2：发现页面的AI工具箱
```
┌─────────────────────────────────────────────┐
│  AI工具箱                         查看全部 > │
│                                             │
│  ┌─────────────┐ ┌─────────────────────┐   │
│  │🔬 影像AI病灶 │ │⚡ 智能风险评估工具  │   │
│  │ 识别分析     │ │                     │   │
│  └─────────────┘ └─────────────────────┘   │
│                                             │
│  ┌─────────────┐ ┌─────────────────────┐   │
│  │📜 古医图原增 │ │💬 AI智能问答助手    │   │ ← 点这个！
│  │ 强工具       │ │ 健康咨询·用药指导   │   │
│  └─────────────┘ └─────────────────────┘   │
└─────────────────────────────────────────────┘
```

#### 截图3：AI健康顾问页面
```
位置: 可能是另一个AI入口
实际文件: AiConsultationPage.ets (路由第43行)
调用AI: 🧠 DeepSeek (✅已修复)
```

---

## 🎯 第三步：测试每个AI（修正后）

### ✅ AI助手 / AI智能问答助手（AiChatPage）

**修改内容**: [AiChatPage.ets#L189](entry/src/main/ets/pages/AiChatPage.ets#L189)
```typescript
// 新增这行，强制使用DeepSeek
request.preferences = { preferredAgent: 'deepseek' };
```

**怎么测**：
```
1. 进入页面（从AI工具箱点"AI智能问答助手"）
2. 点预设问题:
   • [头痛怎么办] → 应该返回200字以上专业建议
   • [感冒发烧] → 应该返回医学处理建议
   • [用药指导] → 应该返回用药注意事项
3. 或自己输入: "高血压患者要注意什么？"
4. 等1-3秒看回复
```

**预期结果**（修复后）：
- ✅ 不再显示 "Coze知识库暂时无法连接"
- ✅ 显示 DeepSeek 生成的专业健康建议
- ✅ 日志显示 `agentId: deepseek`

**如果还是失败**：
- 检查网络（DeepSeek需要联网）
- 查看HiLog日志 `[DeepSeekAgent]`

---

### ✅ AI健康顾问（AiConsultationPage）

**修改内容**: [AiConsultationPage.ets#L81](entry/src/main/ets/pages/AiConsultationPage.ets#L81)
```typescript
// 新增这行，强制使用DeepSeek
request.preferences = { preferredAgent: 'deepseek' };
```

**怎么测**：
```
1. 进入页面（找"AI问诊"/"AI健康顾问"）
2. 输入症状: "我最近总是头晕，可能是什么原因？"
3. 点发送
4. 等1-3秒
5. 继续追问: "那需要做哪些检查？" （测试多轮对话）
```

**预期结果**（修复后）：
- ✅ 不再显示 "抱歉" 和 "以上建议只供参考"
- ✅ 显示 DeepSeek 的详细医学分析
- ✅ 多轮对话能理解上下文

---

### ✅ 影像AI分析（ImageAnalysisPage）

**状态**: 你说没问题了 ✅
**调用AI**: 👁️ HiAI（本地）+ 规则引擎

**怎么测**（回顾）：
```
1. 进入页面
2. 点 [使用示例图: 胸部X光]
3. 点 [开始AI分析]
4. 看4步流程动画
5. 查看报告
```

---

### ✅ AITestPage（一键全测）

**需要手动添加按钮**（30秒）：

在任何页面加：
```typescript
Button('🧪 AI一键全测')
  .onClick(() => router.pushUrl({ url: 'pages/AITestPage' }))
```

进去后点 **[运行全部测试]** → 测完全部AI！

---

## 📊 修正后的完整对照表

| 页面名 | 在哪找 | 调用的AI | 之前状态 | 现在 |
|--------|-------|---------|---------|------|
| **AiChatPage** | 发现→AI工具箱→AI智能问答助手 | 🤖Coze → **🧠DeepSeek** | ❌Coze失败 | ✅已修复 |
| **AiConsultationPage** | AI问诊/AI健康顾问 | 🤖Coze → **🧠DeepSeek** | ❌降级回复 | ✅已修复 |
| **ImageAnalysisPage** | AI工具箱→影像AI病灶识别 | 👁️HiAI+规则引擎 | ✅正常 | ✅正常 |
| **VoiceAssistantPage** | 找"语音助手"/🎤 | 🎤小艺+orchestrator | 未测试 | 待测试 |
| **AITestPage** | 需加按钮 | 全部4个 | 未进入 | 一键全测 |

---

## 🚀 快速测试路线（重新编译后）

### 准备工作（3分钟）
```
1. DevEco Studio → Build → Rebuild Project (Ctrl+F9)
2. 等待 BUILD SUCCESSFUL
3. 启动模拟器运行应用
4. 登录: 13948999643 / 123456
```

### 测试AI（10分钟）

```
第1步（3分钟）: AI助手
   发现页 → AI工具箱 → [AI智能问答助手]
   点 [头痛怎么办] → 等回复 ✓
   
第2步（3分钟）: AI健康顾问  
   找 "AI问诊" 或 "AI健康顾问"
   输入 "失眠怎么办" → 点发送 → 等回复 ✓
   
第3步（2分钟）: 影像分析
   AI工具箱 → [影像AI病灶识别]
   选示例图 → 开始分析 → 看报告 ✓
   
第4步（可选2分钟）: AITestPage
   加个按钮跳转过去
   点 [运行全部测试] → 看全部日志 ✓
```

---

## 🔧 如果修复后还是有问题

### 问题1：DeepSeek也失败了

**检查网络**：
```
模拟器设置 → 高级 → 网络 → 确保能上网
或用真机测试（模拟器网络有时有问题）
```

**查看API Key**：
```typescript
// 检查 entry/src/main/ets/common/constants/ 目录下
// 是否有 DeepSeek API Key 配置
```

### 问题2：想测试Coze（不依赖DeepSeek）

**需要在coze.cn配置**：
1. 访问 https://www.coze.cn/
2. 创建Bot和工作流
3. 更新 [CozeConfig.ts](entry/src/main/ets/common/constants/CozeConfig.ts) 的配置
4. 确保Token有效

### 问题3：登录后找不到AI入口

**直接URL跳转**（临时方案）：
```typescript
// 在任意页面添加这些按钮
Column() {
  Button('去AI助手').margin(5)
    .onClick(() => router.pushUrl({ url: 'pages/AiChatPage' }))
  Button('去AI问诊').margin(5)
    .onClick(() => router.pushUrl({ url: 'pages/AiConsultationPage' }))
  Button('去影像分析').margin(5)
    .onClick(() => router.pushUrl({ url: 'pages/ImageAnalysisPage' }))
  Button('去AI测试').margin(5)
    .onClick(() => router.pushUrl({ url: 'pages/AITestPage' }))
}
```

---

## 📝 修改记录

| 时间 | 文件 | 修改内容 | 原因 |
|------|------|---------|------|
| 2026-05-13 | AiChatPage.ets | 添加 `preferredAgent: 'deepseek'` | Coze连接失败 |
| 2026-05-13 | AiConsultationPage.ets | 添加 `preferredAgent: 'deepseek'` | 同上 |

---

## ✅ 下一步

1. **重新编译项目**（Ctrl+F9）
2. **用Mock账号登录**
3. **测试AI助手和AI健康顾问**
4. **确认DeepSeek回复正常**
5. **如果成功** → 🎉 所有AI都能用了！

---

**总结：你说得对，我之前说错了。AI助手确实调的是Coze，但Coze在模拟器上连不上。我已经帮你改成用DeepSeek了。现在重新编译、登录、测试就行了！** 🚀
