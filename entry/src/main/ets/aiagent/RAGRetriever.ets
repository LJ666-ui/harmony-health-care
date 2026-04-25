/**
 * RAG检索器
 * 基于向量相似度检索医学知识
 */

import { VectorDBClient } from './infrastructure/VectorDBClient';
import { KnowledgeBaseClient } from './infrastructure/KnowledgeBaseClient';
import {
  KnowledgeContext,
  KnowledgeReference,
  RAGConfig,
  KnowledgeDocument
} from './types/RAGTypes';

/**
 * RAG检索器类
 */
export class RAGRetriever {
  private vectorDBClient: VectorDBClient;
  private knowledgeBaseClient: KnowledgeBaseClient;
  private config: RAGConfig;
  private embeddingCache: Map<string, number[]> = new Map();

  /**
   * 构造函数
   * @param vectorDBClient 向量数据库客户端
   * @param knowledgeBaseClient 知识库客户端
   * @param config RAG配置
   */
  constructor(
    vectorDBClient: VectorDBClient,
    knowledgeBaseClient: KnowledgeBaseClient,
    config?: Partial<RAGConfig>
  ) {
    this.vectorDBClient = vectorDBClient;
    this.knowledgeBaseClient = knowledgeBaseClient;
    this.config = {
      topK: 5,
      similarityThreshold: 0.7,
      maxContentLength: 2000,
      enableCache: true,
      cacheTTL: 3600,
      ...config
    };
  }

  /**
   * 检索相关知识
   * @param query 查询文本
   * @param topK 返回结果数量
   * @returns 知识上下文
   */
  async retrieve(query: string, topK?: number): Promise<KnowledgeContext> {
    const startTime = Date.now();

    // 1. 文本向量化
    const queryVector = await this.embed(query);

    // 2. 向量相似度检索
    const searchResults = await this.vectorDBClient.similaritySearch(
      queryVector,
      topK || this.config.topK
    );

    // 3. 过滤低相关度结果
    const filteredResults = searchResults.filter(
      r => r.similarity >= this.config.similarityThreshold
    );

    // 4. 查询知识详情
    const docIds = filteredResults.map(r => r.docId);
    const knowledgeDocs = await this.knowledgeBaseClient.batchGetByIds(docIds);

    // 5. 构建知识上下文
    const context = this.buildKnowledgeContext(
      knowledgeDocs,
      filteredResults,
      searchResults.length
    );

    return context;
  }

  /**
   * 文本向量化
   * @param text 文本内容
   * @returns 向量表示
   */
  async embed(text: string): Promise<number[]> {
    // 检查缓存
    if (this.config.enableCache && this.embeddingCache.has(text)) {
      return this.embeddingCache.get(text)!;
    }

    // 模拟向量化（实际项目中应调用Embedding模型）
    const vector = this.simulateEmbedding(text);

    // 存入缓存
    if (this.config.enableCache) {
      this.embeddingCache.set(text, vector);
    }

    return vector;
  }

  /**
   * 结果排序（已由向量数据库完成）
   * @param results 检索结果
   * @returns 排序后的结果
   */
  rank(results: { docId: string; similarity: number }[]): { docId: string; similarity: number }[] {
    return results.sort((a, b) => b.similarity - a.similarity);
  }

  /**
   * 构建知识上下文
   * @param docs 知识文档列表
   * @param results 检索结果
   * @param totalFound 总共找到的数量
   * @returns 知识上下文
   */
  private buildKnowledgeContext(
    docs: KnowledgeDocument[],
    results: { docId: string; similarity: number }[],
    totalFound: number
  ): KnowledgeContext {
    // 格式化知识内容
    let content = '';
    const references: KnowledgeReference[] = [];

    for (let i = 0; i < docs.length; i++) {
      const doc = docs[i];
      const result = results.find(r => r.docId === doc.id);

      // 添加知识内容
      content += `【知识${i + 1}】${doc.title}\n`;
      content += `${doc.content}\n`;
      content += `来源：${doc.source}\n\n`;

      // 添加引用
      references.push({
        id: doc.id,
        title: doc.title,
        source: doc.source,
        relevance: result?.similarity || 0
      });
    }

    // 限制内容长度
    if (content.length > this.config.maxContentLength) {
      content = content.substring(0, this.config.maxContentLength) + '...';
    }

    return {
      content,
      references,
      totalFound,
      filteredCount: docs.length
    };
  }

  /**
   * 模拟向量化（用于演示）
   * @param text 文本内容
   * @returns 向量表示
   */
  private simulateEmbedding(text: number[]): number[] {
    // 简单的模拟向量化
    // 实际项目中应使用专业的Embedding模型
    const dimension = 384;
    const vector: number[] = [];

    // 基于文本内容生成伪向量
    const seed = this.hashCode(text as unknown as string);
    for (let i = 0; i < dimension; i++) {
      const value = Math.sin(seed * (i + 1)) * 0.5 + Math.cos(seed * (i + 2)) * 0.5;
      vector.push(value);
    }

    // 归一化
    const norm = Math.sqrt(vector.reduce((sum, v) => sum + v * v, 0));
    return vector.map(v => v / norm);
  }

  /**
   * 计算字符串哈希值
   */
  private hashCode(str: string): number {
    let hash = 0;
    for (let i = 0; i < str.length; i++) {
      const char = str.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash;  // Convert to 32bit integer
    }
    return hash;
  }

  /**
   * 清空缓存
   */
  clearCache(): void {
    this.embeddingCache.clear();
  }

  /**
   * 获取配置
   */
  getConfig(): RAGConfig {
    return { ...this.config };
  }

  /**
   * 更新配置
   */
  updateConfig(config: Partial<RAGConfig>): void {
    this.config = {
      ...this.config,
      ...config
    };
  }
}
