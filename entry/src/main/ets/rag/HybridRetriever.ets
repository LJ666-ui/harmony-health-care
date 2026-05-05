/**
 * 混合检索器
 * Hybrid Retriever - 结合向量检索和关键词检索
 * 
 * @author Nebula Medical Team
 * @date 2026-05-06
 */

import { VectorRetriever } from './VectorRetriever';
import { KeywordRetriever } from './KeywordRetriever';
import { Reranker } from './Reranker';

/**
 * 检索结果接口
 */
export interface RetrievalResult {
  id: string;
  content: string;
  score: number;
  metadata?: Record<string, Object>;
  rerankScore?: number;
}

/**
 * 混合检索配置
 */
export interface HybridConfig {
  vectorWeight: number;      // 向量检索权重
  keywordWeight: number;     // 关键词检索权重
  useRerank: boolean;        // 是否使用重排序
  topK: number;              // 返回数量
}

/**
 * 混合检索器
 * 结合向量检索和关键词检索的优势
 */
export class HybridRetriever {
  private vectorRetriever: VectorRetriever;
  private keywordRetriever: KeywordRetriever;
  private reranker: Reranker | null = null;
  private config: HybridConfig;

  constructor(config: HybridConfig) {
    this.config = config;
    this.vectorRetriever = new VectorRetriever();
    this.keywordRetriever = new KeywordRetriever();
    
    if (config.useRerank) {
      this.reranker = new Reranker();
    }
  }

  /**
   * 混合检索
   * @param query 查询文本
   * @returns 检索结果列表
   */
  async retrieve(query: string): Promise<RetrievalResult[]> {
    console.info('[HybridRetriever] 开始混合检索:', query);

    try {
      // 1. 向量检索
      const vectorResults = await this.vectorRetriever.search(
        query, 
        this.config.topK * 2
      );
      console.info('[HybridRetriever] 向量检索完成:', vectorResults.length);

      // 2. 关键词检索
      const keywordResults = await this.keywordRetriever.search(
        query, 
        this.config.topK * 2
      );
      console.info('[HybridRetriever] 关键词检索完成:', keywordResults.length);

      // 3. 结果融合 (RRF算法)
      const mergedResults = this.mergeResults(
        vectorResults, 
        keywordResults
      );
      console.info('[HybridRetriever] 结果融合完成:', mergedResults.length);

      // 4. 重排序
      let finalResults = mergedResults;
      if (this.reranker) {
        finalResults = await this.reranker.rerank(
          query, 
          mergedResults, 
          this.config.topK
        );
        console.info('[HybridRetriever] 重排序完成:', finalResults.length);
      } else {
        finalResults = mergedResults.slice(0, this.config.topK);
      }

      return finalResults;
    } catch (error) {
      console.error('[HybridRetriever] 检索失败:', error);
      return [];
    }
  }

  /**
   * 结果融合 - Reciprocal Rank Fusion (RRF)
   * @param vectorResults 向量检索结果
   * @param keywordResults 关键词检索结果
   * @returns 融合后的结果
   */
  private mergeResults(
    vectorResults: RetrievalResult[],
    keywordResults: RetrievalResult[]
  ): RetrievalResult[] {
    const k = 60; // RRF参数
    const scoreMap = new Map<string, { result: RetrievalResult; score: number }>();

    // 向量检索结果打分
    vectorResults.forEach((result, index) => {
      const rrfScore = 1 / (k + index + 1);
      const weightedScore = rrfScore * this.config.vectorWeight;
      
      const existing = scoreMap.get(result.id);
      if (existing) {
        existing.score += weightedScore;
      } else {
        scoreMap.set(result.id, { result, score: weightedScore });
      }
    });

    // 关键词检索结果打分
    keywordResults.forEach((result, index) => {
      const rrfScore = 1 / (k + index + 1);
      const weightedScore = rrfScore * this.config.keywordWeight;
      
      const existing = scoreMap.get(result.id);
      if (existing) {
        existing.score += weightedScore;
      } else {
        scoreMap.set(result.id, { result, score: weightedScore });
      }
    });

    // 排序并返回
    return Array.from(scoreMap.values())
      .sort((a, b) => b.score - a.score)
      .map(item => ({
        ...item.result,
        score: item.score
      }));
  }
}
