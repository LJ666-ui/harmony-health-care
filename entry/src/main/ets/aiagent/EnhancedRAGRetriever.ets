/**
 * 增强版RAG检索器
 * Enhanced RAG Retriever - 集成混合检索功能
 * 
 * @author Nebula Medical Team
 * @date 2026-05-06
 */

import { HybridRetriever, RetrievalResult } from '../rag/HybridRetriever';
import { VectorDBClient } from './infrastructure/VectorDBClient';
import { KnowledgeBaseClient } from './infrastructure/KnowledgeBaseClient';
import {
  KnowledgeContext,
  KnowledgeReference,
  RAGConfig,
  KnowledgeDocument
} from './types/RAGTypes';

/**
 * 增强版RAG检索器
 * 集成混合检索、重排序等高级功能
 */
export class EnhancedRAGRetriever {
  private hybridRetriever: HybridRetriever;
  private vectorDBClient: VectorDBClient;
  private knowledgeBaseClient: KnowledgeBaseClient;
  private config: RAGConfig;
  private embeddingCache: Map<string, number[]> = new Map();

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

    // 初始化混合检索器
    this.hybridRetriever = new HybridRetriever({
      vectorWeight: 0.6,
      keywordWeight: 0.4,
      useRerank: true,
      topK: this.config.topK
    });
  }

  /**
   * 检索相关知识（增强版）
   * @param query 查询文本
   * @param topK 返回结果数量
   * @returns 知识上下文
   */
  async retrieve(
    query: string,
    topK?: number
  ): Promise<KnowledgeContext> {
    console.info('[EnhancedRAGRetriever] 开始检索:', query);

    try {
      // 1. 使用混合检索器检索
      const results = await this.hybridRetriever.retrieve(query);
      console.info('[EnhancedRAGRetriever] 混合检索完成:', results.length);

      // 2. 转换为知识引用格式
      const references: KnowledgeReference[] = results.map((result, index) => ({
        documentId: result.id,
        content: result.content,
        score: result.score,
        metadata: result.metadata || {}
      }));

      // 3. 构建知识上下文
      const context: KnowledgeContext = {
        query: query,
        references: references,
        combinedContent: this.combineContent(references),
        totalTokens: this.estimateTokens(references)
      };

      return context;
    } catch (error) {
      console.error('[EnhancedRAGRetriever] 检索失败:', error);
      return {
        query: query,
        references: [],
        combinedContent: '',
        totalTokens: 0
      };
    }
  }

  /**
   * 组合内容
   */
  private combineContent(references: KnowledgeReference[]): string {
    const contents = references
      .slice(0, this.config.topK)
      .map(ref => ref.content);

    let combined = contents.join('\n\n');

    // 限制长度
    if (combined.length > this.config.maxContentLength) {
      combined = combined.substring(0, this.config.maxContentLength);
    }

    return combined;
  }

  /**
   * 估算token数量
   */
  private estimateTokens(references: KnowledgeReference[]): number {
    const totalContent = references
      .map(ref => ref.content)
      .join('');

    // 简单估算：中文约1.5字符/token，英文约4字符/token
    return Math.ceil(totalContent.length / 2);
  }

  /**
   * 添加知识文档
   */
  async addDocument(document: KnowledgeDocument): Promise<void> {
    // 添加到向量数据库
    await this.vectorDBClient.insert(document);

    // 添加到混合检索器
    await this.hybridRetriever.addDocument(document.id, document.content);
  }

  /**
   * 批量添加文档
   */
  async addDocuments(documents: KnowledgeDocument[]): Promise<void> {
    for (const doc of documents) {
      await this.addDocument(doc);
    }
  }

  /**
   * 清除缓存
   */
  clearCache(): void {
    this.embeddingCache.clear();
  }
}
