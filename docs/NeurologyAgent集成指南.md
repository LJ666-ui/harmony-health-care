# 神经内科智能体集成指南

## 📋 概述

本文档提供神经内科智能体（NeurologyAgent）的集成指南，根据项目规划V14.0 - 9.2提示词4要求编写。

## 🎯 Agent信息

- **Agent名称**: NeurologyAgent（神经内科智能体）
- **Agent ID**: neurology
- **专业领域**: 脑血管疾病、神经系统疾病、头痛眩晕、认知障碍
- **图标**: 🧠
- **主题色**: #8E44AD

## 📦 文件清单

### 新增文件
```
entry/src/main/ets/aiagent/
├── NeurologyAgent.ets              # 神经内科Agent实现
└── tests/
    └── NeurologyAgentTest.ets      # 单元测试
```

### 修改文件
```
entry/src/main/ets/aiagent/
└── SpecialistAgents.ets            # 添加NeurologyAgent导入和实例化
```

## 🔧 集成步骤

### 步骤1: 添加MedicalSpecialty枚举值

在 `types/AgentTypes.ets` 中添加神经内科枚举：

```typescript
export enum MedicalSpecialty {
  INTERNAL_MEDICINE = 'internal_medicine',
  SURGERY = 'surgery',
  TCM = 'tcm',
  NUTRITION = 'nutrition',
  REHAB = 'rehab',
  NEUROLOGY = 'neurology',  // 新增
  // ... 其他专科
}
```

### 步骤2: 导入Agent

已在 `SpecialistAgents.ets` 中自动导入：

```typescript
import { NeurologyAgent } from './NeurologyAgent';
```

### 步骤3: 注册Agent

已在 `createSpecialistAgents` 函数中注册：

```typescript
export function createSpecialistAgents(
  llmClient: LLMClient,
  ragRetriever: RAGRetriever
): MedicalAgent[] {
  return [
    // ... 其他Agent
    new NeurologyAgent(llmClient, ragRetriever)
  ];
}
```

### 步骤4: 运行测试

```typescript
import { runNeurologyAgentTests } from './tests/NeurologyAgentTest';

// 在测试环境中运行
await runNeurologyAgentTests();
```

## 🎨 能力定义

### 能力1: 脑血管疾病诊疗
- **关键词**: 脑梗、脑出血、中风、脑血管、TIA、脑缺血
- **示例问题**:
  - "脑梗塞怎么治疗"
  - "中风后遗症"
  - "脑血管堵塞"

### 能力2: 头痛眩晕诊疗
- **关键词**: 头痛、偏头痛、眩晕、头晕、偏头
- **示例问题**:
  - "经常头痛"
  - "偏头痛怎么办"
  - "眩晕症"

### 能力3: 认知障碍评估
- **关键词**: 记忆力、痴呆、认知、阿尔茨海默、老年痴呆
- **示例问题**:
  - "记忆力下降"
  - "老年痴呆症状"
  - "认知障碍"

### 能力4: 运动障碍诊疗
- **关键词**: 帕金森、震颤、手抖、运动障碍、僵硬
- **示例问题**:
  - "手抖是什么病"
  - "帕金森症状"
  - "肢体震颤"

## 🧪 测试用例

### canHandle测试
| 输入问题 | 期望结果 |
|---------|---------|
| "我最近经常头痛" | true |
| "脑梗塞怎么治疗" | true |
| "帕金森病的症状" | true |
| "感冒发烧怎么办" | false |

### getConfidenceScore测试
| 输入问题 | 最低期望分数 |
|---------|------------|
| "脑梗塞急性期怎么处理" | 0.9 |
| "帕金森病用药指导" | 0.85 |
| "偏头痛怎么治疗" | 0.8 |

## 🔄 与其他Agent的协作

### 协作场景

1. **与内科Agent协作**
   - 患者同时有高血压和脑血管疾病
   - NeurologyAgent处理脑血管问题
   - InternalMedicineAgent处理高血压管理

2. **与康复Agent协作**
   - 脑梗塞后遗症康复
   - NeurologyAgent提供疾病诊断
   - RehabAgent制定康复方案

3. **与营养Agent协作**
   - 脑血管疾病饮食管理
   - NeurologyAgent提供疾病背景
   - NutritionAgent制定饮食方案

### 协作逻辑

```typescript
// MultiAgentOrchestrator中的协作示例
async coordinateAgents(question: string): Promise<AgentAnswer[]> {
  const answers: AgentAnswer[] = [];
  
  // 1. 神经内科Agent处理主要问题
  if (this.neurologyAgent.canHandle(question)) {
    const neuroAnswer = await this.neurologyAgent.process(question);
    answers.push(neuroAnswer);
  }
  
  // 2. 检查是否需要康复建议
  if (question.includes('康复') || question.includes('后遗症')) {
    const rehabAnswer = await this.rehabAgent.process(question);
    answers.push(rehabAnswer);
  }
  
  // 3. 检查是否需要饮食建议
  if (question.includes('饮食') || question.includes('吃什么')) {
    const nutritionAnswer = await this.nutritionAgent.process(question);
    answers.push(nutritionAnswer);
  }
  
  return answers;
}
```

## 📊 性能指标

### 预期性能
- **响应时间**: < 2秒（含RAG检索）
- **准确率**: > 85%（针对神经内科问题）
- **置信度**: 平均 0.85-0.95

### 监控指标
```typescript
interface AgentMetrics {
  totalQueries: number;        // 总查询数
  successfulQueries: number;   // 成功查询数
  averageResponseTime: number; // 平均响应时间(ms)
  averageConfidence: number;   // 平均置信度
  knowledgeHitRate: number;    // 知识命中率
}
```

## ⚠️ 注意事项

### 1. 紧急情况识别
Agent会自动识别以下紧急情况并建议立即就医：
- 突发剧烈头痛，伴恶心呕吐
- 突发肢体无力或麻木
- 突发言语不清
- 突发视力障碍
- 意识障碍

### 2. 用药建议规范
- 不提供具体用药剂量
- 强调在专科医生指导下用药
- 提供用药注意事项和监测指标

### 3. 知识库要求
确保RAG知识库包含以下内容：
- 脑血管疾病诊疗指南
- 神经系统疾病诊疗规范
- 头痛分类和诊断标准
- 认知障碍评估量表

## 🚀 部署检查清单

- [ ] MedicalSpecialty枚举已添加NEUROLOGY
- [ ] NeurologyAgent.ets文件已创建
- [ ] SpecialistAgents.ets已导入和注册
- [ ] 单元测试已通过
- [ ] RAG知识库已更新神经内科知识
- [ ] 性能监控已配置
- [ ] 文档已更新

## 📝 更新日志

### V1.0 (2026-04-27)
- ✅ 初始版本发布
- ✅ 实现4大核心能力
- ✅ 添加完整测试用例
- ✅ 编写集成指南

---

**开发者**: AI Assistant  
**审核者**: 待审核  
**版本**: V1.0  
**日期**: 2026-04-27
