# AI功能集成测试指南

## 📁 项目AI架构总览

```
entry/src/main/ets/ai/
├── orchestrator/           # 调度层
│   ├── AIOrchestrator.ts   # 核心调度器（单例）
│   └── IntentRouter.ts     # 意图路由（关键词匹配）
├── agents/                 # 智能体实现
│   ├── XiaoyiAgent.ts      # 小艺智能体
│   ├── DeepSeekAgent.ts    # 硅基流动DeepSeek
│   ├── CozeAgent.ts        # Coze工作流
│   ├── HiAIAgent.ts        # HiAI NPU加速
│   └── index.ts            # 导出
├── models/                 # 类型定义
│   ├── AITypes.ts          # 接口定义
│   ├── AgentConfig.ts      # 配置管理
│   └── index.ts
└── QUICK_START.ts          # 快速开始示例
```

---

## 🤖 4个智能体详细位置

### 1️⃣ XiaoyiAgent - 小艺智能体

**文件位置**: `entry/src/main/ets/ai/agents/XiaoyiAgent.ts`

**功能**:
- 本地命令处理（挂号、导航、紧急呼叫）
- 响应时间 < 500ms
- 无需网络

**测试方法**:
```typescript
import { AIOrchestrator } from '../ai/orchestrator/AIOrchestrator';

const orchestrator = AIOrchestrator.getInstance();

// 测试1: 挂号预约
const response1 = await orchestrator.process({
  requestId: 'test-xiaoyi-001',
  userId: 'test-user',
  input: { type: 'text', content: '帮我挂号张医生明天上午' }
});
console.log('小艺回复:', response1.output.content);
console.log('使用智能体:', response1.agentId); // 预期: xiaoyi

// 测试2: AR导航
const response2 = await orchestrator.process({
  requestId: 'test-xiaoyi-002',
  userId: 'test-user',
  input: { type: 'text', content: '导航去内科' },
  preferences: { preferredAgent: 'xiaoyi' }
});

// 测试3: 紧急情况
const response3 = await orchestrator.process({
  requestId: 'test-xiaoyi-003',
  userId: 'test-user',
  input: { type: 'voice', content: '救命！我不舒服' },
  preferences: { priority: 'speed' }
});
```

---

### 2️⃣ DeepSeekAgent - 健康咨询专家

**文件位置**: `entry/src/main/ets/ai/agents/DeepSeekAgent.ts`

**配置**: 
- API Key在 `entry/src/main/ets/common/constants/DeepSeekConfig.ts`
- 使用硅基流动API

**功能**:
- 专业医学知识问答
- 药物相互作用分析
- 健康建议生成
- 响应时间 1-3秒

**测试方法**:
```typescript
// 测试1: 健康咨询
const response1 = await orchestrator.process({
  requestId: 'test-deepseek-001',
  userId: 'test-user',
  input: { type: 'text', content: '高血压患者平时饮食要注意什么？' },
  preferences: { preferredAgent: 'deepseek' }
});
console.log('DeepSeek回复:', response1.output.content);

// 测试2: 用药咨询
const response2 = await orchestrator.process({
  requestId: 'test-deepseek-002',
  userId: 'test-user',
  input: { type: 'text', content: '阿司匹林和布洛芬能一起吃吗？' },
  conversationHistory: [
    { role: 'user', content: '你好', timestamp: Date.now() - 60000 },
    { role: 'assistant', content: '您好！', timestamp: Date.now() - 55000, agentId: 'deepseek' }
  ],
  preferences: { preferredAgent: 'deepseek' }
});

// 测试3: 症状分析
const response3 = await orchestrator.process({
  requestId: 'test-deepseek-003',
  userId: 'test-user',
  input: { type: 'text', content: '我最近总是头晕，可能是什么原因？' },
  preferences: { preferredAgent: 'deepseek' }
});
```

---

### 3️⃣ CozeAgent - 医疗知识库

**文件位置**: `entry/src/main/ets/ai/agents/CozeAgent.ts`

**配置**:
- Bot ID和Token在 `entry/src/main/ets/common/constants/CozeConfig.ts`
- 工作流ID已配置

**功能**:
- 医疗知识库问答
- 工作流编排
- 结构化医疗信息返回

**测试方法**:
```typescript
// 测试1: 医疗问答
const response1 = await orchestrator.process({
  requestId: 'test-coze-001',
  userId: 'test-user',
  input: { type: 'text', content: '血压高怎么办？' },
  preferences: { preferredAgent: 'coze' }
});
console.log('Coze回复:', response1.output.content);

// 测试2: 工作流调用
const response2 = await orchestrator.process({
  requestId: 'test-coze-002',
  userId: 'test-user',
  input: { type: 'text', content: '帮我规划今天的就医流程' },
  preferences: { preferredAgent: 'coze' }
});

// 测试3: 药物查询
const response3 = await orchestrator.process({
  requestId: 'test-coze-003',
  userId: 'test-user',
  input: { type: 'text', content: '阿司匹林的副作用有哪些？' },
  preferences: { preferredAgent: 'coze' }
});
```

---

### 4️⃣ HiAIAgent - 图像识别引擎

**文件位置**: `entry/src/main/ets/ai/agents/HiAIAgent.ts`

**功能**:
- 医学图像识别
- NPU硬件加速
- 本地推理（隐私保护）

**测试方法**:
```typescript
// 测试: 图像识别（目前为框架代码）
const response = await orchestrator.process({
  requestId: 'test-hiai-001',
  userId: 'test-user',
  input: { type: 'image', content: 'base64_image_data_or_path' }, // 需要真实图片数据
  preferences: { preferredAgent: 'hiai' }
});
console.log('HiAI识别结果:', response.output.content);
```

---

## 🎯 自动路由测试（推荐）

**路由规则** (见 `IntentRouter.ts`):

| 用户输入示例 | 路由到 | 触发关键词 |
|------------|--------|-----------|
| "帮我挂号张医生" | xiaoyi | 挂号、预约、门诊 |
| "导航去内科" | xiaoyi | 导航、AR |
| "救命！晕倒了" | xiaoyi | 救命、急救、120 |
| "高血压饮食注意什么" | deepseek | 为什么、怎么办、副作用 |
| "血压高怎么办" | coze | 默认fallback |
| "评估我的健康风险" | mindspore | 风险、评估 |

**自动路由测试**:
```typescript
// 不指定preferredAgent，让系统自动选择
const request = {
  requestId: 'auto-route-test',
  userId: 'test-user',
  input: { type: 'text', content: '帮我挂号明天上午' }
};

const response = await orchestrator.process(request);
console.log('系统选择的智能体:', response.agentId); // 预期: xiaoyi
console.log('置信度:', response.output.confidence);
```

---

## 📊 已使用AI的页面

### 1. VoiceAssistantPage（语音助手）

**文件位置**: `entry/src/main/ets/pages/VoiceAssistantPage.ets`

**当前状态**: ⚠️ 未集成AIOrchestrator（使用本地规则匹配）

**如何验证**:
1. 打开语音助手页面
2. 说"帮我挂号" → 应该跳转到预约页面
3. 说"血压高怎么办" → 显示预设回复

**集成方式**（如需升级）:
```typescript
import { AIOrchestrator } from '../ai/orchestrator/AIOrchestrator';

@Entry
@Component
struct VoiceAssistantPage {
  private orchestrator = AIOrchestrator.getInstance();
  
  async handleUserInput(text: string) {
    const response = await this.orchestrator.process({
      requestId: `req_${Date.now()}`,
      userId: AppStorage.get('userId') || 'anonymous',
      input: { type: 'text', content: text }
    });
    
    this.addMessage('assistant', response.output.content as string, response.agentId);
  }
}
```

---

### 2. RiskAssessmentPage（风险评估）

**文件位置**: `entry/src/main/ets/pages/RiskAssessmentPage.ets`

**当前状态**: ✅ 已引用AI模块

---

### 3. ImageRestorationEngine（古医图像修复）

**文件位置**: `entry/src/main/ets/ancientimage/ImageRestorationEngine.ets`

**当前状态**: ✅ 已使用AI能力

---

## 🧪 完整测试脚本

### 方法1: 在控制台运行（DevEco Studio Terminal）

```bash
# 进入项目目录
cd entry/src/main/ets

# 创建临时测试文件 test_ai.ts
# 复制下面的测试代码并运行
```

### 方法2: 在任意页面添加测试按钮

在 [Index.ets](entry/src/main/ets/pages/Index.ets) 或任意页面添加:

```typescript
Button('🧪 测试AI')
  .margin(10)
  .onClick(async () => {
    const orchestrator = AIOrchestrator.getInstance();
    
    const response = await orchestrator.process({
      requestId: 'manual-test-' + Date.now(),
      userId: 'test-user',
      input: { type: 'text', content: '你好，测试一下AI功能' }
    });
    
    AlertDialog.show({
      title: 'AI测试结果',
      message: `智能体: ${response.agentId}\n回复: ${response.output.content}`,
      confirmButtonText: '确定'
    });
  })
```

### 方法3: 使用QUICK_START.ts中的示例

**文件位置**: `entry/src/main/ets/ai/QUICK_START.ts`

包含完整的8个测试场景:
- basicUsageExample - 基础用法
- voiceCommandExample - 语音命令
- healthConsultationExample - 健康咨询
- riskAssessmentExample - 风险评估
- emergencyExample - 紧急情况
- multiAgentExample - 多智能体并行
- conversationHistoryExample - 对话历史
- systemStatusExample - 系统状态

**调用方式**:
```typescript
import * as AIExamples from '../ai/QUICK_START';

// 运行基础示例
await AIExamples.basicUsageExample();

// 运行健康咨询示例
await AIExamples.healthConsultationExample();

// 查看系统状态
await AIExamples.systemStatusExample();
```

---

## ✅ 成功标准检查清单

### 初始化检查
- [ ] 控制台输出: `[AIOrchestrator] 初始化完成，已加载 X 个智能体`
- [ ] 无报错信息

### 功能检查
| 测试项 | 输入 | 预期结果 | 预期响应时间 |
|--------|------|----------|-------------|
| 小艺-挂号 | "帮我挂号张医生" | 返回预约指令 | < 500ms |
| 小艺-紧急 | "救命！" | 触发SOS流程 | < 200ms |
| DeepSeek-咨询 | "高血压注意什么？" | 专业健康建议 | 1-3s |
| Coze-问答 | "血压高怎么办？" | 知识库答案 | 1-3s |
| 自动路由 | "导航去内科" | 选择xiaoyi | < 500ms |

### 错误处理检查
- [ ] 断网时DeepSeek不崩溃
- [ ] Coze Token无效时优雅降级
- [ ] 无效输入时返回友好提示

---

## 🔍 常见问题排查

### 问题1: AIOrchestrator未加载

**症状**: `Cannot find module 'AIOrchestrator'`

**解决**:
```typescript
// 确认路径正确
import { AIOrchestrator } from './ai/orchestrator/AIOrchestrator'; // 相对路径
// 或
import { AIOrchestrator } from '../ai/orchestrator/AIOrchestrator';
```

### 问题2: DeepSeek报错401

**原因**: API Key无效或过期

**检查**:
1. 打开 `entry/src/main/ets/common/constants/DeepSeekConfig.ts`
2. 确认API_KEY有效
3. 访问 https://cloud.siliconflow.cn 查看余额

### 问题3: Coze无响应

**原因**: Bot未发布或Token错误

**检查**:
1. 打开 `entry/src/main/ets/common/constants/CozeConfig.ts`
2. 确认BOT_ID和TOKEN正确
3. 在Coze平台确认Bot已发布

### 问题4: 小艺只返回默认回复

**原因**: IntentRouter未匹配到意图

**调试**:
```typescript
// 查看路由日志
const result = await orchestrator.getIntentRouter().route(request);
console.log('路由结果:', result);
```

---

## 📝 下一步操作

### 如果所有测试通过 ✅
- AI集成完成，可以正常使用
- VoiceAssistantPage可以升级为使用AIOrchestrator

### 如果部分失败 ❌
1. **网络问题**: 检查DeepSeek/Coze的网络连接
2. **配置问题**: 验证API Key和Token
3. **代码问题**: 查看具体报错信息

### 待完善功能
- [ ] MindSpore模型下载和集成
- [ ] HiAI真机NPU测试
- [ ] VoiceAssistantPage全面接入AIOrchestrator
- [ ] 对话历史持久化存储

---

## 📚 相关文档

- [AI_INTEGRATION_GUIDE.md](../doc_md/AI_INTEGRATION_GUIDE.md) - AI集成指南
- [AI_MULTI_AGENT_ARCHITECTURE.md](../doc_md/AI_MULTI_AGENT_ARCHITECTURE.md) - 架构设计
- [QUICK_START.ts](entry/src/main/ets/ai/QUICK_START.ts) - 代码示例
- [AITypes.ts](entry/src/main/ets/ai/models/AITypes.ts) - 类型定义

---

**最后更新**: 2026-05-13  
**版本**: v1.0  
**适用项目**: harmony-health-care (HMOS6.0)
