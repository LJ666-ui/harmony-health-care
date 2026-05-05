# AI Agent开发规范

## 版本信息
- **项目**: 星云医疗助手
- **AI系统**: Multi-Agent架构
- **开发语言**: ArkTS

---

## 一、AI Agent系统架构

### 1.1 系统组成

```
Multi-Agent系统
├── MedicalAgent          # 核心医疗协调Agent
├── SpecialistAgents      # 专科Agent集合
│   ├── InternalMedicineAgent  # 内科Agent
│   ├── SurgeryAgent           # 外科Agent
│   ├── TCMAgent               # 中医Agent
│   ├── NeurologyAgent         # 神经内科Agent
│   └── ...                    # 其他专科Agent
├── IntentClassifier      # 意图分类器
├── ConversationMemory    # 对话记忆管理
├── RAGRetriever          # 知识检索增强
└── MultiAgentOrchestrator # 多Agent编排器
```

### 1.2 Agent职责

| 组件 | 职责 | 文件 |
|------|------|------|
| **MedicalAgent** | 核心协调、意图识别、Agent路由 | MedicalAgent.ets |
| **SpecialistAgents** | 专科领域知识、专业建议 | SpecialistAgents.ets |
| **IntentClassifier** | 用户意图分类 | IntentClassifier.ets |
| **ConversationMemory** | 对话历史管理 | ConversationMemory.ets |
| **RAGRetriever** | 知识库检索 | RAGRetriever.ets |
| **MultiAgentOrchestrator** | 多Agent协同编排 | MultiAgentOrchestrator.ets |

---

## 二、SpecialistAgent开发规范

### 2.1 标准Agent模板

```typescript
/**
 * 专科智能体实现模板
 * 专长：[专科领域描述]
 */

import { MedicalAgent } from './MedicalAgent';
import { LLMClient } from './infrastructure/LLMClient';
import { RAGRetriever } from './RAGRetriever';
import { AgentConfig, MedicalSpecialty, AgentCapability } from './types/AgentTypes';

/**
 * [专科名称]智能体
 * 专长：[主要专长描述]
 */
export class SpecialtyAgent extends MedicalAgent {
  constructor(llmClient: LLMClient, ragRetriever: RAGRetriever) {
    const config: AgentConfig = {
      agentId: 'specialty_id',              // Agent唯一标识
      agentName: '[专科名称]智能体',         // Agent显示名称
      specialty: MedicalSpecialty.SPECIALTY, // 专科类型枚举
      description: '擅长[主要专长]',         // Agent描述
      capabilities: [                       // 能力列表
        {
          name: '能力1',
          description: '能力描述',
          keywords: ['关键词1', '关键词2'],
          examples: ['示例1', '示例2']
        },
        {
          name: '能力2',
          description: '能力描述',
          keywords: ['关键词1', '关键词2'],
          examples: ['示例1', '示例2']
        }
      ],
      icon: '🏥',                           // Agent图标
      color: '#4A90E2'                      // Agent主题色
    };

    super(config, llmClient, ragRetriever);
  }

  /**
   * 获取系统提示词
   * 定义Agent的专业知识和回答规范
   */
  protected getSystemPrompt(): string {
    return `你是一位专业的[专科名称]医生，擅长[主要专长]。

【专业领域】
- 领域1：具体内容
- 领域2：具体内容
- 领域3：具体内容

【回答要求】
1. 要求1
2. 要求2
3. 要求3
4. 要求4
5. 语言通俗易懂，避免过多专业术语`;
  }
}
```

### 2.2 Agent配置说明

#### 2.2.1 AgentConfig接口

```typescript
interface AgentConfig {
  agentId: string;              // 唯一标识
  agentName: string;            // 显示名称
  specialty: MedicalSpecialty;  // 专科类型
  description: string;          // 描述
  capabilities: AgentCapability[]; // 能力列表
  icon: string;                 // 图标
  color: string;                // 主题色
}
```

#### 2.2.2 AgentCapability接口

```typescript
interface AgentCapability {
  name: string;          // 能力名称
  description: string;   // 能力描述
  keywords: string[];    // 触发关键词
  examples: string[];    // 使用示例
}
```

#### 2.2.3 MedicalSpecialty枚举

```typescript
enum MedicalSpecialty {
  INTERNAL_MEDICINE = 'INTERNAL_MEDICINE',  // 内科
  SURGERY = 'SURGERY',                      // 外科
  TCM = 'TCM',                              // 中医
  PEDIATRICS = 'PEDIATRICS',                // 儿科
  GYNECOLOGY = 'GYNECOLOGY',                // 妇科
  ORTHOPEDICS = 'ORTHOPEDICS',              // 骨科
  DERMATOLOGY = 'DERMATOLOGY',              // 皮肤科
  PSYCHOLOGY = 'PSYCHOLOGY',                // 心理科
  NEUROLOGY = 'NEUROLOGY',                  // 神经内科
  OPHTHALMOLOGY = 'OPHTHALMOLOGY',          // 眼科
  // 添加新的专科类型...
}
```

---

## 三、新增专科Agent步骤

### 步骤1: 定义专科类型枚举

在`types/AgentTypes.ets`中添加新的专科类型：

```typescript
export enum MedicalSpecialty {
  // ... 现有类型
  OPHTHALMOLOGY = 'OPHTHALMOLOGY',  // 眼科
}
```

### 步骤2: 创建Agent类

创建新文件`OphthalmologyAgent.ets`：

```typescript
/**
 * 眼科智能体
 * 专长：眼部疾病诊断、视力保健、用眼卫生
 */

import { MedicalAgent } from './MedicalAgent';
import { LLMClient } from './infrastructure/LLMClient';
import { RAGRetriever } from './RAGRetriever';
import { AgentConfig, MedicalSpecialty, AgentCapability } from './types/AgentTypes';

export class OphthalmologyAgent extends MedicalAgent {
  constructor(llmClient: LLMClient, ragRetriever: RAGRetriever) {
    const config: AgentConfig = {
      agentId: 'ophthalmology',
      agentName: '眼科智能体',
      specialty: MedicalSpecialty.OPHTHALMOLOGY,
      description: '擅长眼部疾病诊断、视力保健和用眼卫生指导',
      capabilities: [
        {
          name: '眼部疾病诊断',
          description: '常见眼部疾病的诊断和建议',
          keywords: ['眼睛', '视力', '红肿', '干涩'],
          examples: ['眼睛红肿', '视力下降']
        },
        {
          name: '视力保健',
          description: '视力保护和眼部保健建议',
          keywords: ['近视', '远视', '散光', '老花'],
          examples: ['近视怎么预防', '眼睛疲劳']
        },
        {
          name: '用眼卫生',
          description: '科学用眼和眼部护理',
          keywords: ['用眼', '护眼', '眼保健操'],
          examples: ['怎么保护眼睛', '用眼卫生']
        }
      ],
      icon: '👁️',
      color: '#3498DB'
    };

    super(config, llmClient, ragRetriever);
  }

  protected getSystemPrompt(): string {
    return `你是一位专业的眼科医生，擅长眼部疾病诊断和视力保健。

【专业领域】
- 常见眼病：结膜炎、角膜炎、干眼症、麦粒肿等
- 屈光不正：近视、远视、散光、老花眼
- 眼部保健：用眼卫生、视力保护、眼保健操
- 眼科急症：眼外伤、急性青光眼等

【回答要求】
1. 评估症状严重程度
2. 提供初步诊断建议
3. 给出护理和预防建议
4. 判断是否需要就医
5. 眼科急症建议立即就医`;
  }
}
```

### 步骤3: 注册Agent

在`SpecialistAgents.ets`中导出新Agent：

```typescript
import { OphthalmologyAgent } from './OphthalmologyAgent';

// 在需要的地方实例化
const ophthalmologyAgent = new OphthalmologyAgent(llmClient, ragRetriever);
```

### 步骤4: 更新MultiAgentOrchestrator

在编排器中添加新Agent的路由逻辑：

```typescript
// 在MultiAgentOrchestrator.ets中
private agents: Map<string, MedicalAgent> = new Map();

// 注册新Agent
this.agents.set('ophthalmology', ophthalmologyAgent);
```

---

## 四、Agent能力设计原则

### 4.1 能力定义原则

1. **明确性**: 每个能力有明确的名称和描述
2. **可触发**: 提供足够的关键词和示例
3. **专业性**: 能力要符合专科特点
4. **实用性**: 能力要解决实际问题

### 4.2 关键词设计

```typescript
keywords: [
  '症状关键词',  // 如：眼睛、视力
  '疾病关键词',  // 如：近视、结膜炎
  '行为关键词',  // 如：用眼、护眼
  '部位关键词'   // 如：眼部、角膜
]
```

### 4.3 示例设计

```typescript
examples: [
  '用户可能的提问1',  // 如：眼睛红肿怎么办
  '用户可能的提问2',  // 如：怎么预防近视
  '用户可能的提问3'   // 如：眼睛疲劳
]
```

---

## 五、系统提示词设计

### 5.1 提示词结构

```typescript
protected getSystemPrompt(): string {
  return `你是一位专业的[专科]医生，擅长[专长]。

【专业领域】
- 领域1：具体内容
- 领域2：具体内容
- 领域3：具体内容

【回答要求】
1. 要求1
2. 要求2
3. 要求3

【注意事项】
- 注意1
- 注意2`;
}
```

### 5.2 提示词设计原则

1. **角色定位**: 明确Agent的专业身份
2. **知识范围**: 定义专业领域边界
3. **回答规范**: 规范回答格式和内容
4. **安全提示**: 包含必要的医疗安全提示
5. **语言风格**: 要求通俗易懂

---

## 六、Agent测试

### 6.1 单元测试

```typescript
// tests/aiagent/OphthalmologyAgent.test.ets

import { OphthalmologyAgent } from '../../aiagent/OphthalmologyAgent';
import { LLMClient } from '../../aiagent/infrastructure/LLMClient';
import { RAGRetriever } from '../../aiagent/RAGRetriever';

describe('OphthalmologyAgent', () => {
  let agent: OphthalmologyAgent;

  beforeAll(() => {
    const llmClient = new LLMClient();
    const ragRetriever = new RAGRetriever();
    agent = new OphthalmologyAgent(llmClient, ragRetriever);
  });

  test('should have correct agentId', () => {
    expect(agent.getAgentId()).toBe('ophthalmology');
  });

  test('should have correct capabilities', () => {
    const capabilities = agent.getCapabilities();
    expect(capabilities.length).toBeGreaterThan(0);
    expect(capabilities[0].name).toBeDefined();
  });

  test('should handle eye-related query', async () => {
    const response = await agent.process('眼睛红肿怎么办');
    expect(response).toBeDefined();
    expect(response.content).toContain('建议');
  });
});
```

### 6.2 集成测试

```typescript
// tests/integration/AgentIntegration.test.ets

test('should route to ophthalmology agent', async () => {
  const orchestrator = new MultiAgentOrchestrator();
  const response = await orchestrator.process('我的眼睛很干涩');
  expect(response.agentId).toBe('ophthalmology');
});
```

---

## 七、最佳实践

### 7.1 Agent命名规范

- **文件名**: `[Specialty]Agent.ets` (PascalCase)
- **类名**: `[Specialty]Agent`
- **agentId**: `specialty_id` (snake_case)
- **agentName**: `[专科名称]智能体`

### 7.2 能力设计建议

1. 每个Agent定义3-5个核心能力
2. 能力之间要有明确区分
3. 关键词要覆盖常见表达
4. 示例要贴近用户实际提问

### 7.3 提示词优化

1. 定期根据用户反馈优化提示词
2. 添加常见问题的标准回答模板
3. 包含医疗安全提示
4. 强调"建议就医"的场景

### 7.4 性能优化

1. 使用RAG检索增强专业知识
2. 缓存常见问题的回答
3. 优化LLM调用频率
4. 实现回答的流式输出

---

## 八、现有Agent清单

| Agent | 专长 | 图标 | 状态 |
|-------|------|------|------|
| InternalMedicineAgent | 慢性病管理、症状分析 | 🏥 | ✅ |
| SurgeryAgent | 外伤处理、手术咨询 | 🔪 | ✅ |
| TCMAgent | 中药调理、体质辨识 | 🌿 | ✅ |
| NeurologyAgent | 神经系统疾病 | 🧠 | ✅ |
| PediatricsAgent | 儿童疾病、生长发育 | 👶 | 待开发 |
| GynecologyAgent | 妇科疾病、孕期保健 | 🤰 | 待开发 |
| OrthopedicsAgent | 骨科疾病、运动损伤 | 🦴 | 待开发 |
| DermatologyAgent | 皮肤疾病、美容护肤 | 🧴 | 待开发 |
| PsychologyAgent | 心理健康、情绪管理 | 🧘 | 待开发 |
| OphthalmologyAgent | 眼部疾病、视力保健 | 👁️ | 待开发 |

---

**最后更新**: 2026-05-06
**适用项目**: 星云医疗助手AI系统
