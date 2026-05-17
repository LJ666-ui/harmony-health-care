# Harmony Health Care AI智能体配置文档

> 本文档包含项目所有AI智能体的完整配置信息，供其他Vue项目集成使用。

---

## 📋 智能体总览

| 智能体ID | 名称 | 类型 | 是否需要网络 | 隐私等级 |
|---------|------|------|------------|---------|
| xiaoyi | 小艺智能体 | 本地语音助手 | ❌ 不需要 | 🔒 高 |
| deepseek | 硅基流动DeepSeek | 云端大语言模型 | ✅ 需要 | 🟡 中 |
| coze | Coze智能体 | 字节跳动AI平台 | ✅ 需要 | 🟡 中 |
| mindspore | MindSpore Lite | 华为端侧推理引擎 | ❌ 不需要 | 🔒🔒 极高 |
| hiai | HiAI NPU加速器 | 华为NPU硬件加速 | ❌ 不需要 | 🔒🔒 极高 |

---

## 1️⃣ 小艺智能体 (xiaoyi)

### 基本信息
- **Agent ID**: `xiaoyi`
- **名称**: 小艺智能体
- **描述**: HarmonyOS原生语音助手，处理系统级命令和多设备联动
- **类型**: 本地离线智能体

### 配置参数
```typescript
{
  skillPackage: 'com.example.harmonyhealthcare.skill',
  triggerWords: ['小艺小艺', '你好小艺', '智慧康养'],
  supportedIntents: [
    'APPOINTMENT_BOOKING',  // 预约挂号
    'NAVIGATION',          // AR导航
    'HEALTH_QUERY',        // 健康查询
    'EMERGENCY',           // 紧急情况
    'MEDICATION_REMINDER', // 用药提醒
    'REHAB_TRAINING',      // 康复训练
    'DEVICE_CONTROL'       // 设备控制
  ]
}
```

### 能力特性
- **支持输入**: 文本(text)、语音(voice)
- **最大延迟**: 500ms
- **隐私等级**: 高 (high)
- **可用性**: ✅ 可用

### 连接方式
```javascript
// 无需API密钥，直接使用HarmonyOS原生能力
import { XiaoyiAgent } from './agents/XiaoyiAgent';

const agent = new XiaoyiAgent();
const response = await agent.process(request);
```

---

## 2️⃣ DeepSeek智能体 (deepseek)

### 基本信息
- **Agent ID**: `deepseek`
- **名称**: 硅基流动DeepSeek
- **描述**: 云端大语言模型，提供复杂语义理解和多轮对话能力
- **服务提供商**: 硅基流动 (SiliconFlow)
- **API文档**: https://docs.siliconflow.cn/

### 🔑 密钥配置
```typescript
{
  apiUrl: 'https://api.siliconflow.cn/v1/chat/completions',
  apiKey: 'sk-hbucrijbdwvxzqjwvyenyqlejbmvciwelasphsafnftojvuo',
  model: 'deepseek-ai/DeepSeek-V3',
  maxTokens: 2048,
  temperature: 0.7,
  timeout: 30000
}
```

### API调用示例
```javascript
// HTTP请求配置
const response = await fetch('https://api.siliconflow.cn/v1/chat/completions', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer sk-hbucrijbdwvxzqjwvyenyqlejbmvciwelasphsafnftojvuo'
  },
  body: JSON.stringify({
    model: 'deepseek-ai/DeepSeek-V3',
    messages: [
      { role: 'system', content: '你是一位专业的智慧康养AI助手...' },
      { role: 'user', content: '用户消息' }
    ],
    max_tokens: 2048,
    temperature: 0.7,
    stream: false  // 支持流式输出: true
  })
});
```

### Vue项目集成代码
```vue
<template>
  <div class="deepseek-chat">
    <div v-for="msg in messages" :key="msg.id" :class="msg.role">
      {{ msg.content }}
    </div>
    <input v-model="inputText" @keyup.enter="sendMessage" />
    <button @click="sendMessage">发送</button>
  </div>
</template>

<script setup>
import { ref } from 'vue';

const DEEPSEEK_CONFIG = {
  apiUrl: 'https://api.siliconflow.cn/v1/chat/completions',
  apiKey: 'sk-hbucrijbdwvxzqjwvyenyqlejbmvciwelasphsafnftojvuo',
  model: 'deepseek-ai/DeepSeek-V3'
};

const messages = ref([]);
const inputText = ref('');

async function sendMessage() {
  messages.value.push({ role: 'user', content: inputText.value });
  
  const response = await fetch(DEEPSEEK_CONFIG.apiUrl, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${DEEPSEEK_CONFIG.apiKey}`
    },
    body: JSON.stringify({
      model: DEEPSEEK_CONFIG.model,
      messages: messages.value.map(m => ({ role: m.role, content: m.content })),
      max_tokens: 2048,
      temperature: 0.7
    })
  });
  
  const data = await response.json();
  messages.value.push({ 
    role: 'assistant', 
    content: data.choices[0].message.content 
  });
  inputText.value = '';
}
</script>
```

### 能力特性
- **支持输入**: 文本(text)、图像(image)
- **最大延迟**: 2000ms
- **隐私等级**: 中 (medium)
- **流式输出**: ✅ 支持
- **多轮对话**: ✅ 支持（保留最近6轮历史）

---

## 3️⃣ Coze智能体 (coze)

### 基本信息
- **Agent ID**: `coze`
- **名称**: Coze智能体
- **描述**: 字节跳动AI平台，提供知识库问答和工作流自动化
- **服务提供商**: 字节跳动 (ByteDance)
- **API文档**: https://www.coze.cn/docs/

### 🔑 密钥配置
```typescript
{
  apiUrl: 'https://api.coze.cn/v1',
  botId: '7638946778641465396',
  token: 'pat_FKOSooarThtzmsGF11djvaNks1JH8sDBhCOdDlWNAfnqvTjB9jER2pCBxDo6IxNU',
  workflowId: '7638960668070625343',
  timeout: 30000,
  maxRetries: 2
}
```

### API端点
```typescript
{
  botChat: '/bot/chat',        // Bot对话接口
  workflowRun: '/workflow/run'  // 工作流执行接口
}
```

### API调用示例（工作流模式）
```javascript
// 调用Coze工作流
const response = await fetch('https://api.coze.cn/v1/workflow/run', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer pat_FKOSooarThtzmsGF11djvaNks1JH8sDBhCOdDlWNAfnqvTjB9jER2pCBxDo6IxNU'
  },
  body: JSON.stringify({
    workflow_id: '7638960668070625343',
    parameters: {
      query: '用户查询内容'
    }
  })
});

const data = await response.json();
// 成功响应: { code: 0, data: {...} }
// 错误响应: { code: 非0, msg: '错误信息' }
```

### Vue项目集成代码
```vue
<template>
  <div class="coze-agent">
    <h3>Coze智能体 - 医疗知识库</h3>
    <div class="chat-messages">
      <div v-for="(msg, index) in chatHistory" :key="index" :class="msg.role">
        {{ msg.content }}
      </div>
    </div>
    <div class="input-area">
      <input 
        v-model="userQuery" 
        @keyup.enter="queryCozeWorkflow" 
        placeholder="输入医疗健康问题..."
      />
      <button @click="queryCozeWorkflow">咨询</button>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';

const COZE_CONFIG = {
  apiUrl: 'https://api.coze.cn/v1',
  botId: '7638946778641465396',
  token: 'pat_FKOSooarThtzmsGF11djvaNks1JH8sDBhCOdDlWNAfnqvTjB9jER2pCBxDo6IxNU',
  workflowId: '7638960668070625343'
};

const chatHistory = ref([]);
const userQuery = ref('');
const isLoading = ref(false);

async function queryCozeWorkflow() {
  if (!userQuery.value || isLoading.value) return;
  
  chatHistory.value.push({ role: 'user', content: userQuery.value });
  isLoading.value = true;
  
  try {
    const response = await fetch(`${COZE_CONFIG.apiUrl}/workflow/run`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${COZE_CONFIG.token}`
      },
      body: JSON.stringify({
        workflow_id: COZE_CONFIG.workflowId,
        parameters: {
          query: userQuery.value
        }
      })
    });
    
    const data = await response.json();
    
    if (data.code === 0) {
      chatHistory.value.push({ 
        role: 'assistant', 
        content: data.data.output || data.data.content || JSON.stringify(data.data)
      });
    } else {
      chatHistory.value.push({ 
        role: 'error', 
        content: `错误: ${data.msg || '未知错误'}` 
      });
    }
    
    userQuery.value = '';
  } catch (error) {
    console.error('Coze API调用失败:', error);
    chatHistory.value.push({ 
      role: 'error', 
      content: '网络连接失败，请稍后重试' 
    });
  } finally {
    isLoading.value = false;
  }
}
</script>

<style scoped>
.coze-agent { max-width: 800px; margin: 20px auto; padding: 20px; }
.chat-messages { min-height: 400px; border: 1px solid #ddd; padding: 15px; overflow-y: auto; }
.user { text-align: right; color: #1890ff; margin: 10px 0; }
.assistant { text-align: left; color: #52c41a; margin: 10px 0; background: #f6ffed; padding: 10px; border-radius: 4px; }
.error { color: #ff4d4f; margin: 10px 0; }
.input-area { display: flex; gap: 10px; margin-top: 15px; }
.input-area input { flex: 1; padding: 10px; border: 1px solid #ddd; border-radius: 4px; }
.input-area button { padding: 10px 20px; background: #1890ff; color: white; border: none; border-radius: 4px; cursor: pointer; }
</style>
```

### Bot对话模式（可选）
```javascript
// 如果需要使用Bot聊天模式而非工作流
const response = await fetch('https://api.coze.cn/v1/bot/chat', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer pat_FKOSooarThtzmsGF11djvaNks1JH8sDBhCOdDlWNAfnqvTjB9jER2pCBxDo6IxNU'
  },
  body: JSON.stringify({
    bot_id: '7638946778641465396',
    user_id: '用户唯一标识',
    query: '用户消息',
    stream: false
  })
});
```

### 能力特性
- **支持输入**: 文本(text)、图像(image)
- **最大延迟**: 3000ms
- **隐私等级**: 中 (medium)
- **知识库问答**: ✅ 支持
- **工作流自动化**: ✅ 支持

---

## 4️⃣ MindSpore Lite智能体 (mindspore)

### 基本信息
- **Agent ID**: `mindspore`
- **名称**: MindSpore Lite
- **描述**: 华为端侧推理引擎，本地执行风险评估和健康监测
- **技术栈**: 华为MindSpore框架
- **类型**: 本地离线推理

### 配置参数
```typescript
{
  // 本地推理引擎，无需API密钥
  modelPath: '/models/mindspore/',  // 模型文件路径
  deviceType: 'cpu',               // 推理设备: cpu/npu/gpu
  threadsNum: 4,                   // 线程数
  enableDynamicBatch: false        // 动态批处理
}
```

### 适用场景
- 健康风险评估
- 生命体征监测
- 跌倒检测
- 异常行为识别

### 能力特性
- **支持输入**: 文本(text)、传感器数据(sensor)
- **最大延迟**: 100ms
- **隐私等级**: 极高 (extreme) - 数据不出设备
- **离线运行**: ✅ 完全离线

---

## 5️⃣ HiAI NPU加速器 (hiai)

### 基本信息
- **Agent ID**: `hiai`
- **名称**: HiAI NPU加速器
- **描述**: 华为NPU硬件加速，极致性能的端侧AI推理
- **技术栈**: 华为HiAI SDK
- **硬件要求**: 华为麒麟990/9000系列芯片或以上

### 配置参数
```typescript
{
  modelPath: '',                  // NPU模型路径
  deviceType: 'npu' | 'cpu',     // 自动选择最优设备
  enableDynamicBatch: false,      // 动态批处理
  threadsNum: 4                   // CPU线程数（降级时使用）
}
```

### 支持的模型能力
- **图像分类** (Image Classification)
- **OCR文字识别** (Optical Character Recognition)
- **姿态检测** (Pose Detection) - 包含跌倒检测
- **心率异常检测** (Heart Anomaly Detection)
- **健康风险评估** (Health Risk Assessment)

### Vue项目集成说明（仅参考）
```javascript
// 注意：HiAI是华为硬件专属能力，Vue Web项目无法直接调用
// 此处仅展示如何通过后端桥接使用

// 方案1：通过HarmonyOS应用作为中间层
// Vue -> 后端API -> HarmonyOS App -> HiAI NPU

// 方案2：使用华为云ModelArts替代
// Vue -> 华为云API -> 云端推理

const HIAI_CONFIG = {
  // 如需云端替代方案，可使用华为云ModelArts
  cloudApiUrl: 'https://modelarts.cn-north-4.myhuaweicloud.com/v1/inferservices',
  // 需要配置华为云AK/SK
};
```

### 能力特性
- **支持输入**: 传感器数据(sensor)、图像(image)
- **最大延迟**: 50ms（NPU）/ 100-200ms（CPU降级）
- **隐私等级**: 极高 (extreme) - 数据完全本地处理
- **硬件加速**: ⚡ NPU专用加速
- **降级策略**: NPU不可用时自动切换到CPU模式

---

## 🔐 安全注意事项

### ⚠️ 重要提示
1. **密钥安全**: 所有API密钥应存储在环境变量或加密配置中，不要硬编码在前端代码
2. **权限控制**: 建议在后端代理API调用，避免前端暴露密钥
3. **用量监控**: 定期检查各平台的API调用量和费用
4. **密钥轮换**: 定期更新API密钥，特别是疑似泄露时

### 推荐的安全实践
```javascript
// ❌ 错误做法：前端硬编码密钥
const apiKey = 'sk-xxxxx';  // 危险！

// ✅ 正确做法：通过环境变量或后端代理
// .env文件
VITE_DEEPSEEK_API_KEY=sk-xxxxx
VITE_COZE_TOKEN=pat-xxxxx

// 或使用后端代理
// Vue -> /api/proxy/ai -> 后端验证 -> AI服务商
```

---

## 📊 智能体选择策略

### 根据场景自动选择最佳智能体
```typescript
function getBestAgent(inputType, requiresPrivacy, hasNetwork, preferredLatency?) {
  // 优先级排序：隐私 > 网络可用性 > 延迟要求
  
  if (requiresPrivacy) {
    return hasNetwork ? 'mindspore' : 'hiai';
  }
  
  if (!hasNetwork) {
    return inputType === 'sensor' ? 'hiai' : 'xiaoyi';
  }
  
  if (preferredLatency && preferredLatency <= 50) {
    return 'hiai';
  }
  
  if (preferredLatency && preferredLatency <= 500) {
    return 'xiaoyi';
  }
  
  return 'deepseek';  // 默认选择
}
```

### 智能体降级链
当主智能体不可用时的备用方案：

| 主智能体 | 降级顺序 |
|---------|---------|
| xiaoyi | deepseek → mindspore |
| deepseek | xiaoyi → mindspore |
| coze | deepseek → xiaoyi → mindspore |
| mindspore | hiai → xiaoyi → deepseek |
| hiai | mindspore → xiaoyi → deepseek |

---

## 📞 技术支持

### 各平台官方文档
- **硅基流动 (DeepSeek)**: https://docs.siliconflow.cn/
- **Coze (字节跳动)**: https://www.coze.cn/docs/
- **华为MindSpore**: https://www.mindspore.cn/
- **华为HiAI**: https://developer.huawei.com/consumer/cn/hiai/

### 项目源码位置
- [AgentConfig.ts](entry/src/main/ets/ai/models/AgentConfig.ts) - 智能体注册与能力定义
- [AITypes.ts](entry/src/main/ets/ai/models/AITypes.ts) - 类型定义
- [CozeConfig.ts](entry/src/main/ets/common/constants/CozeConfig.ts) - Coze配置常量
- [CozeAgent.ts](entry/src/main/ets/ai/agents/CozeAgent.ts) - Coze智能体实现
- [DeepSeekAgent.ts](entry/src/main/ets/ai/agents/DeepSeekAgent.ts) - DeepSeek智能体实现
- [XiaoyiAgent.ts](entry/src/main/ets/ai/agents/XiaoyiAgent.ts) - 小艺智能体实现
- [HiAIAgent.ts](entry/src/main/ets/ai/agents/HiAIAgent.ts) - HiAI智能体实现

---

## 📝 更新日志

| 日期 | 版本 | 更新内容 |
|------|------|---------|
| 2026-05-16 | v1.0.0 | 初始版本，包含5个智能体完整配置 |

---

> **文档生成时间**: 2026-05-16  
> **适用项目**: Harmony Health Care (harmony-health-care)  
> **目标用途**: Vue项目智能体集成对接
