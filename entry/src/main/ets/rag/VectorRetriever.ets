/**
 * 向量检索器
 * Vector Retriever - 基于向量相似度的检索
 * 
 * @author Nebula Medical Team
 * @date 2026-05-06
 */

import { RetrievalResult } from './HybridRetriever';

/**
 * 向量检索配置
 */
export interface VectorConfig {
  embeddingModel: string;     // 嵌入模型
  dimension: number;          // 向量维度
  indexType: 'faiss' | 'milvus';  // 索引类型
}

/**
 * 向量检索器
 */
export class VectorRetriever {
  private config: VectorConfig;
  private index: Map<string, number[]> = new Map();  // 向量索引
  private documents: Map<string, string> = new Map(); // 文档存储

  constructor() {
    this.config = {
      embeddingModel: 'bge-large-zh',
      dimension: 1024,
      indexType: 'faiss'
    };
  }

  /**
   * 向量检索
   * @param query 查询文本
   * @param topK 返回数量
   * @returns 检索结果
   */
  async search(query: string, topK: number): Promise<RetrievalResult[]> {
    console.info('[VectorRetriever] 开始向量检索:', query);

    try {
      // 1. 查询向量化
      const queryVector = await this.embed(query);
      console.info('[VectorRetriever] 查询向量化完成');

      // 2. 向量相似度搜索
      const results = await this.searchSimilar(queryVector, topK);
      console.info('[VectorRetriever] 相似度搜索完成:', results.length);

      return results;
    } catch (error) {
      console.error('[VectorRetriever] 检索失败:', error);
      return [];
    }
  }

  /**
   * 文本向量化
   * @param text 文本
   * @returns 向量
   */
  private async embed(text: string): Promise<number[]> {
    // 实际项目中调用嵌入模型API
    // 这里返回模拟向量
    const vector: number[] = [];
    for (let i = 0; i < this.config.dimension; i++) {
      vector.push(Math.random());
    }
    return this.normalize(vector);
  }

  /**
   * 向量归一化
   */
  private normalize(vector: number[]): number[] {
    const norm = Math.sqrt(
      vector.reduce((sum, val) => sum + val * val, 0)
    );
    return vector.map(val => val / norm);
  }

  /**
   * 相似度搜索
   */
  private async searchSimilar(
    queryVector: number[], 
    topK: number
  ): Promise<RetrievalResult[]> {
    const scores: { id: string; score: number }[] = [];

    // 计算与所有文档的相似度
    this.index.forEach((docVector, id) => {
      const score = this.cosineSimilarity(queryVector, docVector);
      scores.push({ id, score });
    });

    // 排序并返回topK
    return scores
      .sort((a, b) => b.score - a.score)
      .slice(0, topK)
      .map(item => ({
        id: item.id,
        content: this.documents.get(item.id) || '',
        score: item.score
      }));
  }

  /**
   * 余弦相似度
   */
  private cosineSimilarity(vec1: number[], vec2: number[]): number {
    if (vec1.length !== vec2.length) {
      return 0;
    }

    let dotProduct = 0;
    let norm1 = 0;
    let norm2 = 0;

    for (let i = 0; i < vec1.length; i++) {
      dotProduct += vec1[i] * vec2[i];
      norm1 += vec1[i] * vec1[i];
      norm2 += vec2[i] * vec2[i];
    }

    return dotProduct / (Math.sqrt(norm1) * Math.sqrt(norm2));
  }

  /**
   * 添加文档到索引
   */
  async addDocument(id: string, content: string): Promise<void> {
    const vector = await this.embed(content);
    this.index.set(id, vector);
    this.documents.set(id, content);
  }

  /**
   * 批量添加文档
   */
  async addDocuments(documents: { id: string; content: string }[]): Promise<void> {
    for (const doc of documents) {
      await this.addDocument(doc.id, doc.content);
    }
  }
}
