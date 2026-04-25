/**
 * 医学知识库客户端
 * 提供医学知识查询和缓存能力
 */

import { KnowledgeDocument, KnowledgeMetadata } from '../types/RAGTypes';

/**
 * 知识库配置
 */
export interface KnowledgeBaseConfig {
  baseUrl: string;
  cacheSize?: number;
  cacheTTL?: number;
  timeout?: number;
}

/**
 * 查询条件
 */
export interface QueryCondition {
  category?: string;
  tags?: string[];
  keywords?: string[];
  verified?: boolean;
}

/**
 * 缓存项
 */
interface CacheItem {
  data: KnowledgeDocument;
  timestamp: number;
}

/**
 * 医学知识库客户端类
 */
export class KnowledgeBaseClient {
  private config: KnowledgeBaseConfig;
  private cache: Map<string, CacheItem> = new Map();
  private requestCount: number = 0;

  constructor(config: KnowledgeBaseConfig) {
    const defaultConfig: KnowledgeBaseConfig = {
      baseUrl: config.baseUrl,
      cacheSize: config.cacheSize || 100,
      cacheTTL: config.cacheTTL || 3600,
      timeout: config.timeout || 5000
    };
    this.config = defaultConfig;
  }

  async query(condition: QueryCondition): Promise<KnowledgeDocument[]> {
    this.requestCount++;

    const allDocs = this.getMockDocuments();
    const results: KnowledgeDocument[] = [];

    for (let i = 0; i < allDocs.length; i++) {
      const doc = allDocs[i];
      let match = true;

      if (condition.category !== undefined && doc.category !== condition.category) {
        match = false;
      }

      if (match && condition.tags !== undefined && condition.tags.length > 0) {
        let tagMatch = false;
        for (let j = 0; j < condition.tags.length; j++) {
          if (doc.tags.includes(condition.tags[j])) {
            tagMatch = true;
            break;
          }
        }
        if (!tagMatch) {
          match = false;
        }
      }

      if (match && condition.keywords !== undefined && condition.keywords.length > 0) {
        let keywordMatch = false;
        for (let j = 0; j < condition.keywords.length; j++) {
          if (doc.title.includes(condition.keywords[j]) || doc.content.includes(condition.keywords[j])) {
            keywordMatch = true;
            break;
          }
        }
        if (!keywordMatch) {
          match = false;
        }
      }

      if (match && condition.verified !== undefined) {
        if (doc.metadata === undefined || doc.metadata.verified !== condition.verified) {
          match = false;
        }
      }

      if (match) {
        results.push(doc);
      }
    }

    return results;
  }

  async getById(id: string): Promise<KnowledgeDocument | null> {
    this.requestCount++;

    const cached = this.getFromCache(id);
    if (cached !== null) {
      return cached;
    }

    const docs = this.getMockDocuments();
    for (let i = 0; i < docs.length; i++) {
      if (docs[i].id === id) {
        this.putToCache(id, docs[i]);
        return docs[i];
      }
    }

    return null;
  }

  async batchGetByIds(ids: string[]): Promise<KnowledgeDocument[]> {
    const results: KnowledgeDocument[] = [];

    for (let i = 0; i < ids.length; i++) {
      const doc = await this.getById(ids[i]);
      if (doc !== null) {
        results.push(doc);
      }
    }

    return results;
  }

  async search(query: string, limit: number = 10): Promise<KnowledgeDocument[]> {
    this.requestCount++;

    const allDocs = this.getMockDocuments();
    const scoredResults: { doc: KnowledgeDocument; score: number }[] = [];

    for (let i = 0; i < allDocs.length; i++) {
      const doc = allDocs[i];
      const score = this.calculateSearchScore(query, doc);
      if (score > 0) {
        scoredResults.push({ doc: doc, score: score });
      }
    }

    scoredResults.sort((a: { doc: KnowledgeDocument; score: number }, b: { doc: KnowledgeDocument; score: number }) => {
      return b.score - a.score;
    });

    const results: KnowledgeDocument[] = [];
    const count = Math.min(limit, scoredResults.length);
    for (let i = 0; i < count; i++) {
      results.push(scoredResults[i].doc);
    }

    return results;
  }

  validateSource(source: string): boolean {
    const validSources: string[] = [
      '医学知识库',
      '中医知识库',
      '康复知识库',
      '营养知识库',
      'WHO指南',
      '国家卫健委'
    ];

    for (let i = 0; i < validSources.length; i++) {
      if (validSources[i] === source) {
        return true;
      }
    }
    return false;
  }

  async getCategories(): Promise<string[]> {
    const categories: string[] = ['common', 'chronic', 'nutrition', 'tcm', 'rehab', 'surgery'];
    return categories;
  }

  async getTags(): Promise<string[]> {
    const tags: string[] = [
      '症状', '诊断', '治疗', '用药',
      '预防', '康复', '饮食', '运动',
      '中医', '西医', '急救', '儿童',
      '老年', '孕妇', '慢性病'
    ];
    return tags;
  }

  private calculateSearchScore(query: string, doc: KnowledgeDocument): number {
    let score = 0;
    const queryLower = query.toLowerCase();

    if (doc.title.toLowerCase().includes(queryLower)) {
      score += 10;
    }

    if (doc.content.toLowerCase().includes(queryLower)) {
      score += 5;
    }

    for (let i = 0; i < doc.tags.length; i++) {
      if (queryLower.includes(doc.tags[i].toLowerCase())) {
        score += 3;
      }
    }

    return score;
  }

  private getFromCache(key: string): KnowledgeDocument | null {
    const item = this.cache.get(key);

    if (item === undefined) {
      return null;
    }

    const now = Date.now();
    const ttl = (this.config.cacheTTL || 3600) * 1000;

    if (now - item.timestamp > ttl) {
      this.cache.delete(key);
      return null;
    }

    return item.data;
  }

  private putToCache(key: string, data: KnowledgeDocument): void {
    const maxSize = this.config.cacheSize || 100;
    if (this.cache.size >= maxSize) {
      const firstKey = this.cache.keys().next().value;
      if (firstKey !== undefined) {
        this.cache.delete(firstKey);
      }
    }

    const item: CacheItem = {
      data: data,
      timestamp: Date.now()
    };
    this.cache.set(key, item);
  }

  private getMockDocuments(): KnowledgeDocument[] {
    const docs: KnowledgeDocument[] = [];

    const metadata1: KnowledgeMetadata = {
      category: 'common',
      tags: ['症状', '治疗', '感冒'],
      verified: true
    };
    const doc1: KnowledgeDocument = {
      id: 'med_001',
      title: '感冒症状与治疗',
      content: '感冒常见症状包括发热、咳嗽、流鼻涕、喉咙痛等。一般治疗包括休息、多饮水、对症治疗。如症状持续或加重，建议就医。',
      source: '医学知识库',
      category: 'common',
      tags: ['症状', '治疗', '感冒'],
      metadata: metadata1
    };
    docs.push(doc1);

    const metadata2: KnowledgeMetadata = {
      category: 'chronic',
      tags: ['慢性病', '高血压', '管理'],
      verified: true
    };
    const doc2: KnowledgeDocument = {
      id: 'med_002',
      title: '高血压管理',
      content: '高血压患者需要长期管理，包括规律服药、低盐饮食、适量运动、定期监测血压。血压控制目标一般为140/90mmHg以下。',
      source: '医学知识库',
      category: 'chronic',
      tags: ['慢性病', '高血压', '管理'],
      metadata: metadata2
    };
    docs.push(doc2);

    const metadata3: KnowledgeMetadata = {
      category: 'nutrition',
      tags: ['饮食', '糖尿病', '营养'],
      verified: true
    };
    const doc3: KnowledgeDocument = {
      id: 'med_003',
      title: '糖尿病饮食指导',
      content: '糖尿病患者应控制碳水化合物摄入，选择低GI食物，增加膳食纤维，定时定量进餐。避免高糖、高脂食物。',
      source: '营养知识库',
      category: 'nutrition',
      tags: ['饮食', '糖尿病', '营养'],
      metadata: metadata3
    };
    docs.push(doc3);

    const metadata4: KnowledgeMetadata = {
      category: 'tcm',
      tags: ['中医', '体质', '调理'],
      verified: true
    };
    const doc4: KnowledgeDocument = {
      id: 'med_004',
      title: '中医体质辨识',
      content: '中医将人体体质分为九种：平和质、气虚质、阳虚质、阴虚质、痰湿质、湿热质、血瘀质、气郁质、特禀质。不同体质需要不同的调理方法。',
      source: '中医知识库',
      category: 'tcm',
      tags: ['中医', '体质', '调理'],
      metadata: metadata4
    };
    docs.push(doc4);

    const metadata5: KnowledgeMetadata = {
      category: 'rehab',
      tags: ['康复', '运动', '指导'],
      verified: true
    };
    const doc5: KnowledgeDocument = {
      id: 'med_005',
      title: '运动康复指南',
      content: '运动康复应循序渐进，初期以低强度活动为主，逐步增加运动量和强度。注意热身和放松，避免运动损伤。',
      source: '康复知识库',
      category: 'rehab',
      tags: ['康复', '运动', '指导'],
      metadata: metadata5
    };
    docs.push(doc5);

    return docs;
  }

  getStats(): { requestCount: number; cacheSize: number; cacheHitRate: number } {
    const stats = {
      requestCount: this.requestCount,
      cacheSize: this.cache.size,
      cacheHitRate: 0
    };
    return stats;
  }

  clearCache(): void {
    this.cache.clear();
  }
}
