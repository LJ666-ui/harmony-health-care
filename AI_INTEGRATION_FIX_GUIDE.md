# AI 集成错误修复指南

## 已修复的问题

### 1. IntentRouter.ts 语法错误
- **问题**: 正则表达式匹配语法错误，缺少括号
- **修复**: 将 `text.match /(pattern)/` 改为 `text.match(/(pattern)/)`
- **文件**: `entry/src/main/ets/ai/orchestrator/IntentRouter.ts:156, 166, 172`

### 2. XiaoyiAgent.ts 语法错误
- **问题**: 正则表达式匹配语法错误
- **修复**: 将 `t.match /(pattern)/` 改为 `t.match(/(pattern)/)`
- **文件**: `entry/src/main/ets/ai/agents/XiaoyiAgent.ts:224`

### 3. DeepSeekAgent.ts 和 CozeAgent.ts fetch API 问题
- **问题**: HarmonyOS 不支持标准的 fetch API 和 AbortController
- **修复**: 使用 `@ohos.net.http` 模块替代
- **文件**:
  - `entry/src/main/ets/ai/agents/DeepSeekAgent.ts`
  - `entry/src/main/ets/ai/agents/CozeAgent.ts`

### 4. AIOrchestrator.ts process 引用问题
- **问题**: `process.uptime()` 在 HarmonyOS 中不可用
- **修复**: 使用 `Date.now() / 1000` 替代
- **文件**: `entry/src/main/ets/ai/orchestrator/AIOrchestrator.ts:240`

### 5. AIRequest 类型定义问题
- **问题**: 页面代码使用了简化版的 AIRequest 对象，但实际接口定义更复杂
- **修复**: 创建 `AIRequestBuilder` 辅助类来构建正确的 AIRequest
- **文件**: `entry/src/main/ets/ai/utils/AIRequestBuilder.ts`

### 6. AITestPage.ets 泛型问题
- **问题**: Promise 泛型参数缺失，getAgentCount 方法不存在
- **修复**: 添加泛型参数 `Promise<void>`，移除 getAgentCount 调用
- **文件**: `entry/src/main/ets/pages/AITestPage.ets`

## 需要手动修复的文件

以下文件需要按照相同模式修复：

### 修复模式

#### 1. 添加导入
```typescript
import { AIRequestBuilder } from '../ai/utils/AIRequestBuilder';
```

#### 2. 修复 orchestrator.process 调用

**旧代码**:
```typescript
const response = await this.orchestrator.process({
  type: 'text',
  content: '消息内容',
  intent: 'intent_name'
});
```

**新代码**:
```typescript
const request = AIRequestBuilder.createDataRequest(
  '消息内容',
  'intent_name',
  String(this.userId)
);
const response = await this.orchestrator.process(request);
```

#### 3. 修复 response.output.content 访问

**旧代码**:
```typescript
this.result = response.output.content;
```

**新代码**:
```typescript
this.result = typeof response.output.content === 'string'
  ? response.output.content
  : JSON.stringify(response.output.content);
```

### 需要修复的文件列表

1. `AIAssistantPage.ets` - 已部分修复
2. `AddHealthRecord.ets`
3. `AiChatPage.ets`
4. `AiConsultationPage.ets`
5. `ConsultationPage.ets`
6. `DoctorChatPage.ets`
7. `DoctorFamilyChatPage.ets`
8. `FamilyChatListPage.ets`
9. `HealthRecordDetail.ets`
10. `HealthRecords.ets`
11. `MedicationDetailPage.ets`
12. `MedicationPage.ets`
13. `Medications.ets`
14. `NurseChatPage.ets`
15. `PatientDoctorChatPage.ets`
16. `PatientNurseChatPage.ets`
17. `Rehab3DPage.ets`
18. `RehabPage.ets`
19. `RehabilitationPage.ets`
20. `VoiceAssistantPage.ets`

## ArkTS 严格模式错误修复

### 1. arkts-no-any-unknown
**问题**: 不能使用 `any` 或 `unknown` 类型
**修复**: 使用明确的类型定义

**示例**:
```typescript
// 错误
let data: any = {};

// 正确
interface MyData {
  field1: string;
  field2: number;
}
let data: MyData = { field1: '', field2: 0 };
```

### 2. arkts-no-implicit-return-types
**问题**: 函数必须有明确的返回类型
**修复**: 添加返回类型注解

**示例**:
```typescript
// 错误
async function getData() {
  return await fetchData();
}

// 正确
async function getData(): Promise<MyData> {
  return await fetchData();
}
```

### 3. arkts-no-untyped-obj-literals
**问题**: 对象字面量必须对应明确的类或接口
**修复**: 定义接口或使用类型注解

**示例**:
```typescript
// 错误
const obj = { name: 'test', value: 123 };

// 正确
interface MyObject {
  name: string;
  value: number;
}
const obj: MyObject = { name: 'test', value: 123 };
```

### 4. arkts-no-inferred-generic-params
**问题**: 泛型函数调用时必须显式指定类型参数
**修复**: 添加泛型类型参数

**示例**:
```typescript
// 错误
const result = myGenericFunction(param);

// 正确
const result = myGenericFunction<MyType>(param);
```

## 批量修复脚本

已创建 Python 脚本 `fix-ai-requests.py` 用于批量修复，但由于文件数量较多且修复模式复杂，建议：

1. 先修复关键页面文件
2. 测试编译是否通过
3. 逐步修复其他文件

## 验证修复

修复完成后，运行以下命令验证：

```bash
hvigorw clean
hvigorw assembleHap
```

如果仍有错误，请根据错误信息继续修复。
