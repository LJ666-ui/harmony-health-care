# 小艺3个Skill - 详细配置指南

> **项目**: Harmony Health Care (智慧康养助手)
> **更新时间**: 2026-05-12
> **目标**: 完成小艺3个Skill的配置

---

## 📋 目录

1. [3个Skill概览](#1-3个skill概览)
2. [Skill-1-健康风险评估配置](#2-skill-1-健康风险评估配置)
3. [Skill-2-医疗图像识别配置](#3-skill-2-医疗图像识别配置)
4. [Skill-3-康复训练指导配置](#4-skill-3-康复训练指导配置)
5. [配置位置示意图](#5-配置位置示意图)
6. [常见问题](#6-常见问题)

---

## 1. 3个Skill概览

| # | Skill名称 | 技术基础 | 触发Intent | 触发话语示例 |
|---|---------|---------|-----------|-------------|
| 1 | 健康风险评估 | MindSpore Lite | `CHECK_HEALTH_RISK` | "评估健康风险"、"健康检查" |
| 2 | 医疗图像识别 | HiAI NPU | `RECOGNIZE_MEDICAL_IMAGE` | "识别图片"、"拍照识别" |
| 3 | 康复训练指导 | Coze Bot | `GET_REHABILITATION_GUIDANCE` | "康复训练"、"康复指导" |

---

## 2. Skill-1: 健康风险评估配置

### 2.1 配置参数

| 字段 | 内容 |
|-----|------|
| **名称** | `健康风险评估` |
| **描述** | `基于MindSpore Lite引擎，评估用户健康风险（高血压、糖尿病、跌倒、衰弱、肌少症5个维度）` |
| **类型** | `数据分析` |
| **触发Intent** | `CHECK_HEALTH_RISK` |

### 2.2 训练话语（至少5条）

```
评估我的健康风险
我的健康状况怎么样
风险评估
健康检查
帮我看看有没有健康问题
查看我的健康报告
我有哪些健康风险
```

### 2.3 技术对接

**代码位置**: `entry/src/main/ets/mindsphere/MindSporeLiteEngine.ets`

**核心方法**:
```typescript
async assessRisk(healthData: HealthData): Promise<RiskAssessmentResult>
```

**输出格式**:
```json
{
  "risk_score": 75,
  "risk_level": "高",
  "main_factors": ["血压偏高", "血糖波动"],
  "suggestions": ["建议每天监测血压", "控制盐分摄入"]
}
```

---

## 3. Skill-2: 医疗图像识别配置

### 3.1 配置参数

| 字段 | 内容 |
|-----|------|
| **名称** | `医疗图像识别` |
| **描述** | `基于HiAI NPU引擎，识别医疗图像（皮肤病变、药品识别、眼底照片、跌倒姿态检测）` |
| **类型** | `图像处理` |
| **触发Intent** | `RECOGNIZE_MEDICAL_IMAGE` |

### 3.2 训练话语（至少8条）

```
识别这张图片
拍照识别
这是什么
帮我看看这张照片
皮肤有问题帮我看看
药品识别
检测有没有跌倒
眼底照片分析
这是什么药
帮我看看有没有皮肤病
```

### 3.3 技术对接

**代码位置**: `entry/src/main/ets/hiai/HiAIAgent.ts`

**核心方法**:
```typescript
async classifyImage(uri: string): Promise<ImageClassificationResult>
async recognizeText(uri: string): Promise<OCRResult>
async detectPose(uri: string): Promise<PoseDetectionResult>
```

**输出格式**:
```json
{
  "recognition_type": "skin",
  "results": [
    {
      "label": "疑似湿疹",
      "confidence": 0.85,
      "suggestion": "建议到皮肤科进一步检查"
    }
  ],
  "processing_time": "120ms"
}
```

---

## 4. Skill-3: 康复训练指导配置

### 4.1 配置参数

| 字段 | 内容 |
|-----|------|
| **名称** | `康复训练指导` |
| **描述** | `基于Coze医疗Bot，提供内科、眼科、康复科等专业康复指导与咨询服务` |
| **类型** | `专业咨询` |
| **触发Intent** | `GET_REHABILITATION_GUIDANCE` |

### 4.2 训练话语（至少8条）

```
康复训练指导
怎么康复
康复建议
内科咨询
眼科保健
康复科问题
术后恢复
康复训练计划
我需要康复帮助
```

### 4.3 技术对接

**代码位置**: `entry/src/main/ets/coze/CozeAgent.ts`

**核心方法**:
```typescript
async consultInternalMedicine(query: string): Promise<CozeResponse>
async consultOphthalmology(query: string): Promise<CozeResponse>
async consultRehabilitation(query: string): Promise<CozeResponse>
```

**需要的Coze参数**:

| 参数 | 说明 | 状态 |
|------|------|------|
| Personal Access Token | Coze API访问令牌 | ⏳ 待配置 |
| Bot ID (内科) | 内科医疗Bot ID | ⏳ 待配置 |
| Bot ID (眼科) | 眼科医疗Bot ID | ⏳ 待配置 |
| Bot ID (康复科) | 康复科Bot ID | ⏳ 待配置 |

---

## 5. 配置位置示意图

### 5.1 平台入口

```
华为HAG平台
└── 大智能体（智慧康养助手）
    └── 配置项
         └── 插件 (0/20)  ← 【在这里添加Skill】
```

### 5.2 操作流程

```
Step 1: 登录华为HAG平台
Step 2: 进入"智慧康养助手"大智能体
Step 3: 左侧菜单找到"插件"
Step 4: 点击"添加插件"
Step 5: 选择"创建Skill"或从列表选择
Step 6: 填写上述3个Skill的配置参数
Step 7: 添加训练话语
Step 8: 保存
```

### 5.3 界面示意

```
┌─────────────────────────────────────────────────────────┐
│  华为HAG平台 - 智慧康养助手                              │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  📋 配置项                                              │
│  ├── ☐ 开场白 (0/3)                                   │
│  ├── ☐ 开场引导                                        │
│  ├── ☐ 角色指令                                        │
│  ├── ☐ 快捷指令 (10/10)                                │
│  ├── ☐ 基础设置                                        │
│  ├── ☐ 智能体 (5/5) ← 5个子Agent已添加 ✓              │
│  ├── ☐ 插件 (0/20) ←【点击这里添加3个Skill】          │
│  ├── ☐ 工作流 (0/20)                                   │
│  └── ☐ 触发器 (0/10)                                   │
│                                                         │
│  点击"插件" → "添加插件" → 创建3个Skill                │
└─────────────────────────────────────────────────────────┘
```

---

## 6. 常见问题

### Q1: 找不到"插件"入口怎么办？

可能原因：
- HAG平台版本不同，可能叫"技能"或"扩展能力"
- 需要更高权限
- 功能未开放

**解决方案**: 联系华为技术支持或在开发者社区提问

### Q2: Skill和子Agent有什么区别？

| 对比项 | 子Agent | Skill |
|--------|---------|-------|
| **定位** | 专业领域助手 | 特定功能扩展 |
| **调用方式** | 大智能体自动路由 | 通过Intent触发 |
| **数量** | 5个（已完成） | 3个（待配置） |
| **技术实现** | 角色指令+开场白 | 插件+代码对接 |

### Q3: 训练话语要写多少条？

**建议**: 每个Skill至少5-8条

**原则**:
- 覆盖用户常见表达方式
- 包含同义词和不同说法
- 越多样越好识别越准

### Q4: Skill配置后还需要代码对接吗？

**是的**，需要在代码中实现对应的处理逻辑：

| Skill | 代码文件 | 状态 |
|-------|---------|------|
| 健康风险评估 | `MindSporeLiteEngine.ets` | 框架已就绪 |
| 医疗图像识别 | `HiAIAgent.ts` | 框架已就绪 |
| 康复训练指导 | `CozeAgent.ts` | 框架已就绪 |

### Q5: Skill触发后返回什么格式的数据？

建议统一返回JSON格式，包含：
- `status`: 处理状态（success/error）
- `data`: 业务数据
- `message`: 用户友好的提示信息
- `timestamp`: 时间戳

---

## ✅ 配置检查清单

配置完成后请确认：

- [ ] Skill 1 健康风险评估 - 配置完成
- [ ] Skill 2 医疗图像识别 - 配置完成
- [ ] Skill 3 康复训练指导 - 配置完成
- [ ] 每个Skill都有至少5条训练话语
- [ ] 所有配置已保存

---

## 📞 获取帮助

如有疑问，请参考：
- [XIAOYI_SKILL_DETAILED_GUIDE.md](./XIAOYI_SKILL_DETAILED_GUIDE.md)
- [AI_INTEGRATION_GUIDE.md](./AI_INTEGRATION_GUIDE.md)
- 华为HAG平台官方文档
