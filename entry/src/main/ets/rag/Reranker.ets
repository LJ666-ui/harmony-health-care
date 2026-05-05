/**
 * 重排序器
 * Reranker - 对检索结果进行精确重排序
 * 
 * @author Nebula Medical Team
 * @date 2026-05-06
 */

import { RetrievalResult } from './HybridRetriever';

/**
 * 重排序器
 * 使用Cross-Encoder模型进行精确重排序
 */
export class Reranker {
  /**
   * 重排序
   * @param query 查询文本
   * @param candidates 候选文档
   * @param topK 返回数量
   * @returns 重排序后的结果
   */
  async rerank(
    query: string,
    candidates: RetrievalResult[],
    topK: number
  ): Promise<RetrievalResult[]> {
    console.info('[Reranker] 开始重排序, 候选数:', candidates.length);

    try {
      // 1. 计算重排序得分
      const scored = await Promise.all(
        candidates.map(async (candidate) => {
          const rerankScore = await this.score(query, candidate.content);
          return {
            ...candidate,
            rerankScore
          };
        })
      );

      // 2. 按重排序得分排序
      const reranked = scored
        .sort((a, b) => (b.rerankScore || 0) - (a.rerankScore || 0))
        .slice(0, topK);

      console.info('[Reranker] 重排序完成, 返回数:', reranked.length);
      return reranked;
    } catch (error) {
      console.error('[Reranker] 重排序失败:', error);
      return candidates.slice(0, topK);
    }
  }

  /**
   * 计算重排序得分
   * @param query 查询文本
   * @param document 文档内容
   * @returns 重排序得分
   */
  private async score(query: string, document: string): Promise<number> {
    // 实际项目中使用Cross-Encoder模型
    // 这里使用简化的相似度计算
    
    // 1. 关键词匹配度
    const keywordScore = this.calculateKeywordMatch(query, document);
    
    // 2. 语义相似度（简化版）
    const semanticScore = this.calculateSemanticSimilarity(query, document);
    
    // 3. 医疗专业性得分
    const medicalScore = this.calculateMedicalRelevance(query, document);
    
    // 综合得分
    const totalScore = keywordScore * 0.3 + semanticScore * 0.4 + medicalScore * 0.3;
    
    return totalScore;
  }

  /**
   * 计算关键词匹配度
   */
  private calculateKeywordMatch(query: string, document: string): number {
    const queryWords = query.toLowerCase().split(/\s+/);
    const docWords = document.toLowerCase().split(/\s+/);
    
    let matchCount = 0;
    for (const word of queryWords) {
      if (docWords.includes(word)) {
        matchCount++;
      }
    }
    
    return matchCount / queryWords.length;
  }

  /**
   * 计算语义相似度（简化版）
   */
  private calculateSemanticSimilarity(query: string, document: string): number {
    // 简化实现：基于词重叠
    const querySet = new Set(query.toLowerCase().split(/\s+/));
    const docSet = new Set(document.toLowerCase().split(/\s+/));
    
    const intersection = new Set([...querySet].filter(x => docSet.has(x)));
    const union = new Set([...querySet, ...docSet]);
    
    return intersection.size / union.size;
  }

  /**
   * 计算医疗相关性
   */
  private calculateMedicalRelevance(query: string, document: string): number {
    // 医疗专业术语
    const medicalTerms = [
      '症状', '治疗', '诊断', '药物', '疾病',
      '血压', '血糖', '心率', '体温',
      '感冒', '发烧', '咳嗽', '头痛',
      '高血压', '糖尿病', '冠心病'
    ];
    
    let score = 0;
    const queryLower = query.toLowerCase();
    const docLower = document.toLowerCase();
    
    for (const term of medicalTerms) {
      const queryHas = queryLower.includes(term);
      const docHas = docLower.includes(term);
      
      if (queryHas && docHas) {
        score += 1;
      }
    }
    
    return Math.min(score / 5, 1);  // 归一化到[0,1]
  }
}
