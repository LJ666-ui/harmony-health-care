# ArkTS编译错误修复指南

## 错误概述

项目出现51个ArkTS编译错误，主要类型：
1. **禁止使用any/unknown类型** (arkts-no-any-unknown)
2. **禁止对象字面量作为类型** (arkts-no-obj-literals-as-types)
3. **对象字面量必须对应接口** (arkts-no-untyped-obj-literals)
4. **泛型函数调用限制** (arkts-no-inferred-generic-params)
5. **禁止spread操作符** (arkts-no-spread)
6. **找不到WebSocket** (HarmonyOS需要使用@ohos.net.webSocket)

## ArkTS严格类型规则

### 1. 禁止any/unknown类型
**错误**：`Use explicit types instead of "any", "unknown"`

**原因**：ArkTS要求所有类型必须明确声明

**修复方法**：
```typescript
// ❌ 错误
interface WSMessage {
  data: any;
}

// ✅ 正确
interface WSMessage {
  data: string; // 使用具体类型
}
```

### 2. 禁止对象字面量作为类型
**错误**：`Object literals cannot be used as type declarations`

**原因**：ArkTS要求使用interface或class定义类型

**修复方法**：
```typescript
// ❌ 错误
interface MedicalRecord {
  basicInfo: {
    height?: number;
    weight?: number;
  };
}

// ✅ 正确
interface BasicInfo {
  height?: number;
  weight?: number;
}

interface MedicalRecord {
  basicInfo: BasicInfo;
}
```

### 3. 对象字面量必须对应接口
**错误**：`Object literal must correspond to some explicitly declared class or interface`

**修复方法**：
```typescript
// ❌ 错误
const reminder = {
  id: '123',
  status: 'PENDING'
};

// ✅ 正确
interface ReminderData {
  id: string;
  status: string;
}

const reminder: ReminderData = {
  id: '123',
  status: 'PENDING'
};
```

### 4. 泛型函数调用限制
**错误**：`Type inference in case of generic function calls is limited`

**修复方法**：
```typescript
// ❌ 错误
const response = await HttpUtil.post('/api/data', data);

// ✅ 正确
const response = await HttpUtil.post<ResponseData>('/api/data', data);
```

### 5. 禁止spread操作符
**错误**：`It is possible to spread only arrays`

**修复方法**：
```typescript
// ❌ 错误
const newData = { ...oldData, newField: value };

// ✅ 正确
const newData: DataType = {
  field1: oldData.field1,
  field2: oldData.field2,
  newField: value
};
```

### 6. WebSocket问题
**错误**：`Cannot find name 'WebSocket'`

**原因**：HarmonyOS不使用标准WebSocket API

**修复方法**：
```typescript
// ❌ 错误
const ws = new WebSocket(url);

// ✅ 正确
import webSocket from '@ohos.net.webSocket';
const ws = webSocket.createWebSocket();
```

## 已修复的文件

### 1. WebSocketService.ets
**修复内容**：
- ✅ 移除所有any类型，使用string类型
- ✅ 简化接口定义，避免嵌套对象字面量
- ✅ 移除WebSocket直接使用，添加注释说明需要使用@ohos.net.webSocket
- ✅ 所有方法使用明确类型

### 2. ChatService.ets
**修复内容**：
- ✅ 使用Map<string, Object>替代对象字面量参数
- ✅ 所有接口明确定义
- ✅ 泛型调用明确指定类型参数

## 待修复的文件

### 1. MedicalService.ets
**需要修复**：
- 移除嵌套对象字面量类型定义
- 为所有对象字面量创建对应接口
- 明确所有泛型调用类型参数
- 移除spread操作符

### 2. FamilyService.ets
**需要修复**：
- 移除嵌套对象字面量类型定义
- 为所有对象字面量创建对应接口
- 明确所有泛型调用类型参数
- 移除spread操作符

### 3. NotificationService.ets
**需要修复**：
- 移除any类型
- 为对象字面量创建接口

### 4. SyncService.ets
**需要修复**：
- 移除any类型
- 为对象字面量创建接口

### 5. TerminalManager.ets
**需要修复**：
- 检查是否有any类型
- 检查对象字面量使用

## 修复步骤

### 步骤1：定义所有需要的接口

为每个嵌套对象和对象字面量创建独立的interface：

```typescript
// 医疗服务相关接口
export interface BasicInfo {
  height?: number;
  weight?: number;
  bloodType?: string;
  allergies: Allergy[];
}

export interface Allergy {
  allergen: string;
  reaction: string;
  severity: string;
}

export interface MedicalHistory {
  disease: string;
  diagnosedAt: number;
  status: string;
  notes?: string;
}

export interface Diagnosis {
  id: string;
  patientId: string;
  doctorId: string;
  doctorName: string;
  symptoms: string[];
  examinationResults: string;
  diagnosis: string;
  treatmentPlan: string;
  createdAt: number;
}

export interface MedicationItem {
  name: string;
  dosage: string;
  frequency: string;
  duration: number;
  instructions: string;
  warnings?: string[];
}

export interface Prescription {
  id: string;
  patientId: string;
  patientName: string;
  doctorId: string;
  doctorName: string;
  medications: MedicationItem[];
  diagnosis: string;
  notes?: string;
  status: string;
  createdAt: number;
  validUntil: number;
}

export interface MedicalRecord {
  id: string;
  patientId: string;
  basicInfo: BasicInfo;
  medicalHistory: MedicalHistory[];
  diagnoses: Diagnosis[];
  prescriptions: Prescription[];
  createdAt: number;
  updatedAt: number;
}
```

### 步骤2：替换所有any类型

```typescript
// ❌ 错误
function processData(data: any): any {
  return data;
}

// ✅ 正确
function processData(data: string): string {
  return data;
}

// 或使用泛型
function processData<T>(data: T): T {
  return data;
}
```

### 步骤3：替换对象字面量

```typescript
// ❌ 错误
const config = {
  timeout: 5000,
  retry: 3
};

// ✅ 正确
interface Config {
  timeout: number;
  retry: number;
}

const config: Config = {
  timeout: 5000,
  retry: 3
};
```

### 步骤4：明确泛型类型参数

```typescript
// ❌ 错误
const response = await HttpUtil.get('/api/data');

// ✅ 正确
const response = await HttpUtil.get<DataResponse>('/api/data');
```

### 步骤5：替换spread操作符

```typescript
// ❌ 错误
const newData = { ...oldData, newField: value };

// ✅ 正确
const newData: DataType = {
  field1: oldData.field1,
  field2: oldData.field2,
  newField: value
};
```

## HarmonyOS WebSocket使用说明

HarmonyOS不使用标准WebSocket API，需要使用@ohos.net.webSocket：

```typescript
import webSocket from '@ohos.net.webSocket';

// 创建WebSocket
let ws = webSocket.createWebSocket();

// 连接
ws.connect(url, (err, value) => {
  if (!err) {
    console.log('连接成功');
  }
});

// 发送消息
ws.send(data);

// 接收消息
ws.on('message', (err, value) => {
  console.log('收到消息:', value);
});

// 关闭连接
ws.close();
```

## 编译验证

修复后，执行以下命令验证：

```bash
# 清理构建
hvigorw clean

# 重新编译
hvigorw assembleHap
```

## 常见问题

### Q1: 为什么ArkTS这么严格？

**A**: ArkTS是鸿蒙的TypeScript超集，为了性能优化和类型安全，采用了更严格的类型检查。

### Q2: 如何处理动态数据？

**A**: 使用string类型存储JSON字符串，需要时解析：
```typescript
const data: string = JSON.stringify(obj);
const parsed = JSON.parse(data) as MyInterface;
```

### Q3: 泛型如何使用？

**A**: 必须明确指定类型参数：
```typescript
function getData<T>(): T { ... }
const result = getData<MyType>(); // 明确指定T为MyType
```

## 总结

✅ 已修复WebSocketService.ets
✅ 已修复ChatService.ets
⏳ 待修复MedicalService.ets
⏳ 待修复FamilyService.ets
⏳ 待修复NotificationService.ets
⏳ 待修复SyncService.ets

**修复原则**：
1. 所有类型必须明确声明
2. 禁止使用any/unknown
3. 对象字面量必须对应interface
4. 泛型调用必须明确类型参数
5. 禁止使用spread操作符
6. 使用HarmonyOS原生API

**按照本指南修复所有文件后，编译错误应该全部消失。**
