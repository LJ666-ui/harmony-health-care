# RAG检索增强优化方案

## 版本信息
- **项目**: 星云医疗助手AI系统
- **RAG系统**: 知识检索增强生成
- **优化目标**: 提升检索准确率和响应质量

---

## 一、RAG系统现状分析

### 1.1 当前架构

```
用户查询
    ↓
意图识别 (IntentClassifier)
    ↓
查询改写/扩展
    ↓
向量检索 (Vector Search)
    ↓
知识过滤/排序
    ↓
上下文构建
    ↓
LLM生成回答
    ↓
返回结果
```

### 1.2 存在的问题

| 问题 | 影响 | 优先级 |
|------|------|--------|
| 检索准确率不足 | 返回不相关内容 | P0 |
| 响应速度慢 | 用户体验差 | P1 |
| 知识覆盖不全 | 无法回答部分问题 | P1 |
| 上下文长度限制 | 信息丢失 | P2 |
| 缺少重排序 | 相关性排序不准 | P1 |

---

## 二、优化方案总览

### 2.1 优化方向矩阵

| 优化方向 | 预期效果 | 实现复杂度 | 优先级 | 工作量 |
|---------|---------|-----------|--------|--------|
| **向量模型优化** | +15%准确率 | 高 | P0 | 3天 |
| **混合检索** | +20%准确率 | 中 | P0 | 2天 |
| **查询改写** | +10%准确率 | 低 | P1 | 1天 |
| **重排序算法** | +12%准确率 | 中 | P0 | 2天 |
| **分块策略优化** | +8%准确率 | 中 | P1 | 2天 |
| **缓存策略** | +50%速度 | 低 | P1 | 1天 |
| **知识图谱增强** | +18%准确率 | 高 | P2 | 5天 |

---

## 三、详细优化方案

### 3.1 向量模型优化

#### 3.1.1 模型选择

**当前模型**: 通用向量模型
**推荐模型**: 医疗领域专用模型

| 模型 | 维度 | 性能 | 适用场景 |
|------|------|------|---------|
| text-embedding-ada-002 | 1536 | 通用 | 基础场景 |
| bge-large-zh | 1024 | 中文优化 | 中文医疗 |
| medbert | 768 | 医疗专用 | 专业医疗 |
| m3e-base | 768 | 多语言 | 多语言场景 |

**实施方案**:
```typescript
// 向量模型配置
interface EmbeddingConfig {
  modelName: string;
  dimension: number;
  batchSize: number;
  normalize: boolean;
}

const medicalEmbeddingConfig: EmbeddingConfig = {
  modelName: 'bge-large-zh',  // 中文医疗优化模型
  dimension: 1024,
  batchSize: 32,
  normalize: true
};
```

#### 3.1.2 模型微调

**微调数据准备**:
```typescript
// 医疗领域微调数据
interface MedicalFineTuneData {
  query: string;        // 用户查询
  positive: string[];   // 正相关文档
  negative: string[];   // 负相关文档
}

const fineTuneExamples: MedicalFineTuneData[] = [
  {
    query: '高血压怎么治疗',
    positive: [
      '高血压的治疗方法包括药物治疗和生活方式干预',
      '常用降压药有ACEI、ARB、钙通道阻滞剂等'
    ],
    negative: [
      '糖尿病的治疗方法',
      '感冒发烧怎么办'
    ]
  }
];
```

**预期效果**: 准确率提升15-20%

---

### 3.2 混合检索策略

#### 3.2.1 检索策略设计

```typescript
/**
 * 混合检索策略
 * 结合向量检索和关键词检索
 */
export class HybridRetriever {
  private vectorRetriever: VectorRetriever;
  private keywordRetriever: KeywordRetriever;
  private reranker: Reranker;

  /**
   * 混合检索
   * @param query 查询文本
   * @param topK 返回数量
   */
  async retrieve(query: string, topK: number = 10): Promise<RetrievalResult[]> {
    // 1. 向量检索
    const vectorResults = await this.vectorRetriever.search(query, topK * 2);

    // 2. 关键词检索
    const keywordResults = await this.keywordRetriever.search(query, topK * 2);

    // 3. 结果融合
    const mergedResults = this.mergeResults(vectorResults, keywordResults);

    // 4. 重排序
    const rerankedResults = await this.reranker.rerank(query, mergedResults, topK);

    return rerankedResults;
  }

  /**
   * 结果融合策略
   * Reciprocal Rank Fusion (RRF)
   */
  private mergeResults(
    vectorResults: RetrievalResult[],
    keywordResults: RetrievalResult[]
  ): RetrievalResult[] {
    const k = 60; // RRF参数
    const scoreMap = new Map<string, number>();

    // 向量检索结果打分
    vectorResults.forEach((result, index) => {
      const score = 1 / (k + index + 1);
      const current = scoreMap.get(result.id) || 0;
      scoreMap.set(result.id, current + score);
    });

    // 关键词检索结果打分
    keywordResults.forEach((result, index) => {
      const score = 1 / (k + index + 1);
      const current = scoreMap.get(result.id) || 0;
      scoreMap.set(result.id, current + score);
    });

    // 排序并返回
    return Array.from(scoreMap.entries())
      .sort((a, b) => b[1] - a[1])
      .map(([id, score]) => ({ id, score }));
  }
}
```

#### 3.2.2 权重配置

```typescript
interface HybridConfig {
  vectorWeight: number;    // 向量检索权重
  keywordWeight: number;   // 关键词检索权重
  rerankWeight: number;    // 重排序权重
}

const medicalHybridConfig: HybridConfig = {
  vectorWeight: 0.6,   // 医疗语义重要
  keywordWeight: 0.4,  // 专业术语精确匹配
  rerankWeight: 0.8    // 重排序权重高
};
```

**预期效果**: 准确率提升20-25%

---

### 3.3 查询改写与扩展

#### 3.3.1 查询改写策略

```typescript
/**
 * 查询改写器
 * 优化用户查询以提升检索效果
 */
export class QueryRewriter {
  /**
   * 查询改写
   */
  async rewrite(query: string): Promise<RewrittenQuery> {
    // 1. 查询理解
    const intent = await this.understandQuery(query);

    // 2. 查询扩展
    const expanded = await this.expandQuery(query, intent);

    // 3. 查询简化
    const simplified = this.simplifyQuery(query);

    // 4. 同义词替换
    const synonyms = await this.replaceSynonyms(query);

    return {
      original: query,
      expanded: expanded,
      simplified: simplified,
      synonyms: synonyms,
      final: this.selectBestQuery([expanded, simplified, synonyms])
    };
  }

  /**
   * 查询扩展
   * 添加相关术语
   */
  private async expandQuery(query: string, intent: QueryIntent): Promise<string> {
    const expansions: Record<string, string[]> = {
      '高血压': ['血压升高', '高血压病', 'hypertension'],
      '糖尿病': ['血糖高', '糖尿病病', 'diabetes'],
      '感冒': ['上呼吸道感染', '感冒发烧', 'cold']
    };

    let expanded = query;
    for (const [term, synonyms] of Object.entries(expansions)) {
      if (query.includes(term)) {
        expanded += ' ' + synonyms.join(' ');
      }
    }

    return expanded;
  }

  /**
   * 同义词替换
   */
  private async replaceSynonyms(query: string): Promise<string> {
    const synonymMap: Record<string, string> = {
      '头疼': '头痛',
      '肚子疼': '腹痛',
      '拉肚子': '腹泻',
      '发烧': '发热'
    };

    let replaced = query;
    for (const [from, to] of Object.entries(synonymMap)) {
      replaced = replaced.replace(new RegExp(from, 'g'), to);
    }

    return replaced;
  }
}
```

**预期效果**: 准确率提升10-15%

---

### 3.4 重排序算法

#### 3.4.1 Cross-Encoder重排序

```typescript
/**
 * 重排序器
 * 使用Cross-Encoder模型进行精确重排序
 */
export class Reranker {
  private model: CrossEncoderModel;

  /**
   * 重排序
   * @param query 查询文本
   * @param candidates 候选文档
   * @param topK 返回数量
   */
  async rerank(
    query: string,
    candidates: RetrievalResult[],
    topK: number
  ): Promise<RetrievalResult[]> {
    // 1. 构建查询-文档对
    const pairs = candidates.map(c => [query, c.content]);

    // 2. 批量打分
    const scores = await this.model.predict(pairs);

    // 3. 排序
    const reranked = candidates
      .map((c, i) => ({ ...c, rerankScore: scores[i] }))
      .sort((a, b) => b.rerankScore - a.rerankScore)
      .slice(0, topK);

    return reranked;
  }
}
```

#### 3.4.2 医疗领域重排序

```typescript
/**
 * 医疗领域重排序
 * 考虑医疗专业性
 */
export class MedicalReranker extends Reranker {
  /**
   * 医疗相关性打分
   */
  protected calculateMedicalRelevance(
    query: string,
    document: string
  ): number {
    let score = 0;

    // 1. 专业术语匹配
    const medicalTerms = this.extractMedicalTerms(query);
    const docTerms = this.extractMedicalTerms(document);
    const termOverlap = this.calculateOverlap(medicalTerms, docTerms);
    score += termOverlap * 0.4;

    // 2. 疾病名称匹配
    const diseases = this.extractDiseases(query);
    const docDiseases = this.extractDiseases(document);
    const diseaseMatch = this.calculateMatch(diseases, docDiseases);
    score += diseaseMatch * 0.3;

    // 3. 症状匹配
    const symptoms = this.extractSymptoms(query);
    const docSymptoms = this.extractSymptoms(document);
    const symptomMatch = this.calculateMatch(symptoms, docSymptoms);
    score += symptomMatch * 0.3;

    return score;
  }
}
```

**预期效果**: 准确率提升12-18%

---

### 3.5 分块策略优化

#### 3.5.1 智能分块

```typescript
/**
 * 智能分块策略
 * 根据内容类型选择最佳分块方式
 */
export class SmartChunker {
  /**
   * 分块
   */
  chunk(content: string, type: ContentType): Chunk[] {
    switch (type) {
      case 'medical_knowledge':
        return this.chunkMedicalKnowledge(content);
      case 'disease_info':
        return this.chunkDiseaseInfo(content);
      case 'drug_info':
        return this.chunkDrugInfo(content);
      default:
        return this.chunkDefault(content);
    }
  }

  /**
   * 医疗知识分块
   * 按段落和语义边界分块
   */
  private chunkMedicalKnowledge(content: string): Chunk[] {
    const chunks: Chunk[] = [];

    // 1. 按段落分割
    const paragraphs = content.split('\n\n');

    // 2. 语义分析
    for (const para of paragraphs) {
      // 检测是否为完整语义单元
      if (this.isCompleteSemanticUnit(para)) {
        chunks.push({
          content: para,
          metadata: {
            type: 'paragraph',
            length: para.length
          }
        });
      } else {
        // 进一步分割
        const subChunks = this.splitBySentence(para);
        chunks.push(...subChunks);
      }
    }

    return chunks;
  }

  /**
   * 疾病信息分块
   * 保持疾病信息完整性
   */
  private chunkDiseaseInfo(content: string): Chunk[] {
    // 疾病信息结构化分块
    const sections = {
      definition: '',    // 定义
      symptoms: '',      // 症状
      causes: '',        // 病因
      diagnosis: '',     // 诊断
      treatment: '',     // 治疗
      prevention: ''     // 预防
    };

    // 解析并分块
    // ...

    return Object.entries(sections)
      .filter(([_, content]) => content.length > 0)
      .map(([type, content]) => ({
        content,
        metadata: { type, length: content.length }
      }));
  }
}
```

#### 3.5.2 分块参数优化

```typescript
interface ChunkConfig {
  maxSize: number;        // 最大块大小
  minSize: number;        // 最小块大小
  overlap: number;        // 重叠大小
  separator: string;      // 分隔符
}

const medicalChunkConfig: ChunkConfig = {
  maxSize: 512,     // 医疗知识块较大
  minSize: 100,
  overlap: 50,      // 保持上下文连续性
  separator: '\n\n'
};
```

**预期效果**: 准确率提升8-12%

---

### 3.6 缓存策略

#### 3.6.1 多级缓存

```typescript
/**
 * 多级缓存系统
 */
export class MultiLevelCache {
  private memoryCache: LRUCache<string, CacheEntry>;
  private diskCache: DiskCache;
  private redisCache: RedisCache;

  /**
   * 获取缓存
   */
  async get(key: string): Promise<CacheEntry | null> {
    // L1: 内存缓存
    let entry = this.memoryCache.get(key);
    if (entry && !this.isExpired(entry)) {
      return entry;
    }

    // L2: 磁盘缓存
    entry = await this.diskCache.get(key);
    if (entry && !this.isExpired(entry)) {
      this.memoryCache.set(key, entry);
      return entry;
    }

    // L3: Redis缓存
    entry = await this.redisCache.get(key);
    if (entry && !this.isExpired(entry)) {
      this.memoryCache.set(key, entry);
      await this.diskCache.set(key, entry);
      return entry;
    }

    return null;
  }

  /**
   * 设置缓存
   */
  async set(key: string, value: CacheEntry): Promise<void> {
    const ttl = this.calculateTTL(value);

    // 写入所有缓存层
    this.memoryCache.set(key, value, ttl);
    await this.diskCache.set(key, value, ttl);
    await this.redisCache.set(key, value, ttl);
  }

  /**
   * TTL计算
   * 根据内容重要性动态计算
   */
  private calculateTTL(entry: CacheEntry): number {
    // 医疗核心知识缓存时间长
    if (entry.metadata.importance === 'critical') {
      return 7 * 24 * 60 * 60; // 7天
    }

    // 一般知识
    if (entry.metadata.importance === 'normal') {
      return 24 * 60 * 60; // 1天
    }

    // 时效性知识
    return 60 * 60; // 1小时
  }
}
```

#### 3.6.2 查询缓存

```typescript
/**
 * 查询结果缓存
 */
export class QueryCache {
  /**
   * 缓存查询结果
   */
  async cacheQuery(query: string, results: RetrievalResult[]): Promise<void> {
    // 查询标准化
    const normalizedQuery = this.normalizeQuery(query);

    // 生成缓存键
    const cacheKey = this.generateCacheKey(normalizedQuery);

    // 缓存结果
    await this.cache.set(cacheKey, {
      query: normalizedQuery,
      results: results,
      timestamp: Date.now()
    });
  }

  /**
   * 查询标准化
   * 提高缓存命中率
   */
  private normalizeQuery(query: string): string {
    return query
      .toLowerCase()
      .trim()
      .replace(/\s+/g, ' ');
  }
}
```

**预期效果**: 响应速度提升50-70%

---

### 3.7 知识图谱增强

#### 3.7.1 知识图谱集成

```typescript
/**
 * 知识图谱增强检索
 */
export class KnowledgeGraphEnhancedRetriever {
  private graphDB: Neo4jClient;
  private vectorRetriever: VectorRetriever;

  /**
   * 增强检索
   */
  async retrieve(query: string): Promise<EnhancedResult[]> {
    // 1. 向量检索
    const vectorResults = await this.vectorRetriever.search(query, 10);

    // 2. 知识图谱查询
    const graphResults = await this.queryKnowledgeGraph(query);

    // 3. 实体链接
    const linkedEntities = await this.linkEntities(query, graphResults);

    // 4. 关系扩展
    const expandedResults = await this.expandRelations(linkedEntities);

    // 5. 结果融合
    return this.mergeResults(vectorResults, expandedResults);
  }

  /**
   * 知识图谱查询
   */
  private async queryKnowledgeGraph(query: string): Promise<GraphNode[]> {
    // 提取实体
    const entities = this.extractEntities(query);

    // Cypher查询
    const cypher = `
      MATCH (e:Entity)-[r:RELATES_TO]->(related:Entity)
      WHERE e.name IN $entities
      RETURN e, r, related
    `;

    const results = await this.graphDB.query(cypher, { entities });
    return results;
  }

  /**
   * 关系扩展
   * 基于知识图谱扩展相关知识
   */
  private async expandRelations(entities: Entity[]): Promise<ExpandedResult[]> {
    const expanded: ExpandedResult[] = [];

    for (const entity of entities) {
      // 查询相关实体
      const related = await this.graphDB.query(`
        MATCH (e:Entity {id: $id})-[:RELATES_TO*1..2]-(related:Entity)
        RETURN related
      `, { id: entity.id });

      expanded.push({
        entity: entity,
        related: related,
        importance: this.calculateImportance(entity, related)
      });
    }

    return expanded;
  }
}
```

**预期效果**: 准确率提升18-25%

---

## 四、实施路线图

### 4.1 分阶段实施

#### 第一阶段（1-2周）：基础优化
- [x] 混合检索实现
- [x] 查询改写
- [x] 缓存策略
- [ ] 效果评估

#### 第二阶段（2-3周）：深度优化
- [ ] 向量模型微调
- [ ] 重排序算法
- [ ] 分块策略优化
- [ ] 效果评估

#### 第三阶段（3-4周）：高级优化
- [ ] 知识图谱集成
- [ ] 多模态检索
- [ ] 个性化检索
- [ ] 最终评估

### 4.2 效果评估指标

| 指标 | 当前值 | 目标值 | 优化后 |
|------|--------|--------|--------|
| **检索准确率** | 65% | 85% | 待测 |
| **召回率** | 70% | 90% | 待测 |
| **响应时间** | 2.5s | 1.0s | 待测 |
| **缓存命中率** | 30% | 70% | 待测 |

---

## 五、监控与调优

### 5.1 监控指标

```typescript
interface RAGMetrics {
  // 检索指标
  retrievalAccuracy: number;      // 检索准确率
  retrievalRecall: number;        // 召回率
  retrievalLatency: number;       // 检索延迟

  // 缓存指标
  cacheHitRate: number;           // 缓存命中率
  cacheSize: number;              // 缓存大小

  // 质量指标
  answerRelevance: number;        // 答案相关性
  userSatisfaction: number;       // 用户满意度
}
```

### 5.2 A/B测试

```typescript
/**
 * A/B测试框架
 */
export class RAGABTest {
  /**
   * 对比测试
   */
  async compare(
    query: string,
    strategyA: RetrievalStrategy,
    strategyB: RetrievalStrategy
  ): Promise<ABTestResult> {
    const resultA = await strategyA.retrieve(query);
    const resultB = await strategyB.retrieve(query);

    return {
      query: query,
      resultA: resultA,
      resultB: resultB,
      metrics: {
        accuracyA: await this.evaluateAccuracy(resultA),
        accuracyB: await this.evaluateAccuracy(resultB),
        latencyA: resultA.latency,
        latencyB: resultB.latency
      }
    };
  }
}
```

---

## 六、最佳实践总结

### 6.1 优化原则

1. **渐进式优化**: 从简单到复杂，逐步优化
2. **数据驱动**: 基于实际数据评估效果
3. **用户导向**: 以用户体验为最终目标
4. **成本控制**: 平衡效果与计算成本

### 6.2 注意事项

1. **避免过度优化**: 防止过拟合
2. **保持可解释性**: 便于问题排查
3. **监控性能**: 持续跟踪关键指标
4. **定期更新**: 知识库和模型需要定期更新

---

**最后更新**: 2026-05-06
**预期效果**: 检索准确率提升至85%+，响应时间降低至1秒内
