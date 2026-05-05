/**
 * 关键词检索器
 * Keyword Retriever - 基于关键词匹配的检索
 * 
 * @author Nebula Medical Team
 * @date 2026-05-06
 */

import { RetrievalResult } from './HybridRetriever';

/**
 * 关键词检索器
 * 使用BM25算法进行关键词检索
 */
export class KeywordRetriever {
  private documents: Map<string, string> = new Map();
  private invertedIndex: Map<string, Set<string>> = new Map();
  private docLengths: Map<string, number> = new Map();
  private avgDocLength: number = 0;

  /**
   * 关键词检索
   * @param query 查询文本
   * @param topK 返回数量
   * @returns 检索结果
   */
  async search(query: string, topK: number): Promise<RetrievalResult[]> {
    console.info('[KeywordRetriever] 开始关键词检索:', query);

    try {
      // 1. 查询分词
      const queryTerms = this.tokenize(query);
      console.info('[KeywordRetriever] 查询分词:', queryTerms);

      // 2. BM25打分
      const scores = this.bm25Score(queryTerms);
      console.info('[KeywordRetriever] BM25打分完成');

      // 3. 排序并返回
      const results = Array.from(scores.entries())
        .sort((a, b) => b[1] - a[1])
        .slice(0, topK)
        .map(([id, score]) => ({
          id,
          content: this.documents.get(id) || '',
          score
        }));

      return results;
    } catch (error) {
      console.error('[KeywordRetriever] 检索失败:', error);
      return [];
    }
  }

  /**
   * BM25打分
   * @param queryTerms 查询词列表
   * @returns 文档得分映射
   */
  private bm25Score(queryTerms: string[]): Map<string, number> {
    const k1 = 1.5;  // BM25参数
    const b = 0.75;  // BM25参数
    const N = this.documents.size;  // 文档总数

    const scores = new Map<string, number>();

    for (const term of queryTerms) {
      // 获取包含该词的文档
      const docsWithTerm = this.invertedIndex.get(term);
      if (!docsWithTerm) continue;

      // 计算IDF
      const df = docsWithTerm.size;
      const idf = Math.log((N - df + 0.5) / (df + 0.5) + 1);

      // 对每个文档计算得分
      for (const docId of docsWithTerm) {
        const docLength = this.docLengths.get(docId) || 0;
        const tf = this.getTermFrequency(docId, term);

        const score = idf * (tf * (k1 + 1)) / (tf + k1 * (1 - b + b * (docLength / this.avgDocLength)));

        const currentScore = scores.get(docId) || 0;
        scores.set(docId, currentScore + score);
      }
    }

    return scores;
  }

  /**
   * 获取词频
   */
  private getTermFrequency(docId: string, term: string): number {
    const content = this.documents.get(docId) || '';
    const terms = this.tokenize(content);
    return terms.filter(t => t === term).length;
  }

  /**
   * 分词
   * 简单的中文分词（按字符分割）
   */
  private tokenize(text: string): string[] {
    // 移除标点符号
    const cleaned = text.replace(/[^\u4e00-\u9fa5a-zA-Z0-9]/g, ' ');
    
    // 分词（简单实现：按空格分割）
    const tokens = cleaned.split(/\s+/).filter(t => t.length > 0);
    
    // 对于中文，按字符分割
    const result: string[] = [];
    for (const token of tokens) {
      if (/[\u4e00-\u9fa5]/.test(token)) {
        // 中文：按字符分割
        for (const char of token) {
          result.push(char);
        }
      } else {
        // 英文：保持原样
        result.push(token.toLowerCase());
      }
    }

    return result;
  }

  /**
   * 添加文档
   */
  addDocument(id: string, content: string): void {
    this.documents.set(id, content);

    // 更新倒排索引
    const terms = this.tokenize(content);
    this.docLengths.set(id, terms.length);

    for (const term of terms) {
      if (!this.invertedIndex.has(term)) {
        this.invertedIndex.set(term, new Set());
      }
      this.invertedIndex.get(term)!.add(id);
    }

    // 更新平均文档长度
    this.updateAvgDocLength();
  }

  /**
   * 更新平均文档长度
   */
  private updateAvgDocLength(): void {
    const totalLength = Array.from(this.docLengths.values())
      .reduce((sum, len) => sum + len, 0);
    this.avgDocLength = totalLength / this.docLengths.size;
  }

  /**
   * 批量添加文档
   */
  addDocuments(documents: { id: string; content: string }[]): void {
    for (const doc of documents) {
      this.addDocument(doc.id, doc.content);
    }
  }
}
