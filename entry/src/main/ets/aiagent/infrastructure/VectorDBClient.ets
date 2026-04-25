/**
 * 向量数据库客户端
 * 提供向量存储和相似度检索能力
 */

import { SearchResult, SearchResultMetadata } from '../types/RAGTypes';

/**
 * 向量数据库配置
 */
export interface VectorDBConfig {
  host: string;
  port: number;
  database: string;
  collection: string;
  dimension: number;
  indexType?: string;
  metricType?: string;
  timeout?: number;
}

/**
 * 向量记录
 */
export interface VectorRecord {
  id: string;
  vector: number[];
  metadata?: Record<string, string>;
}

/**
 * 批量操作结果
 */
export interface BatchResult {
  success: number;
  failed: number;
  errors?: string[];
}

/**
 * 向量数据库客户端类
 */
export class VectorDBClient {
  private config: VectorDBConfig;
  private connected: boolean = false;
  private cache: Map<string, VectorRecord> = new Map();

  constructor(config: VectorDBConfig) {
    const defaultConfig: VectorDBConfig = {
      host: config.host,
      port: config.port,
      database: config.database,
      collection: config.collection,
      dimension: config.dimension,
      indexType: config.indexType || 'IVF_FLAT',
      metricType: config.metricType || 'COSINE',
      timeout: config.timeout || 5000
    };
    this.config = defaultConfig;
  }

  async connect(): Promise<void> {
    await this.delay(100);
    this.connected = true;
  }

  async disconnect(): Promise<void> {
    this.connected = false;
    this.cache.clear();
  }

  async similaritySearch(vector: number[], topK: number = 5): Promise<SearchResult[]> {
    this.ensureConnected();

    const results: SearchResult[] = [];
    const allRecords = this.getAllRecords();

    for (let i = 0; i < allRecords.length; i++) {
      const record = allRecords[i];
      const similarity = this.cosineSimilarity(vector, record.vector);
      const metadata: SearchResultMetadata = {
        title: record.metadata ? record.metadata['title'] : '',
        source: record.metadata ? record.metadata['source'] : '',
        category: record.metadata ? record.metadata['category'] : ''
      };
      const result: SearchResult = {
        docId: record.id,
        similarity: similarity,
        metadata: metadata
      };
      results.push(result);
    }

    results.sort((a: SearchResult, b: SearchResult) => {
      return b.similarity - a.similarity;
    });

    return results.slice(0, topK);
  }

  async insert(record: VectorRecord): Promise<void> {
    this.ensureConnected();
    this.cache.set(record.id, record);
  }

  async batchInsert(records: VectorRecord[]): Promise<BatchResult> {
    this.ensureConnected();

    let success = 0;
    let failed = 0;
    const errors: string[] = [];

    for (let i = 0; i < records.length; i++) {
      try {
        await this.insert(records[i]);
        success++;
      } catch (error) {
        failed++;
        const errorMsg = 'Failed to insert ' + records[i].id + ': ' + error;
        errors.push(errorMsg);
      }
    }

    const result: BatchResult = {
      success: success,
      failed: failed,
      errors: errors
    };
    return result;
  }

  async update(record: VectorRecord): Promise<void> {
    this.ensureConnected();

    if (!this.cache.has(record.id)) {
      throw new Error('Record not found: ' + record.id);
    }

    this.cache.set(record.id, record);
  }

  async delete(id: string): Promise<void> {
    this.ensureConnected();

    if (!this.cache.has(id)) {
      throw new Error('Record not found: ' + id);
    }

    this.cache.delete(id);
  }

  async batchDelete(ids: string[]): Promise<BatchResult> {
    this.ensureConnected();

    let success = 0;
    let failed = 0;
    const errors: string[] = [];

    for (let i = 0; i < ids.length; i++) {
      try {
        await this.delete(ids[i]);
        success++;
      } catch (error) {
        failed++;
        const errorMsg = 'Failed to delete ' + ids[i] + ': ' + error;
        errors.push(errorMsg);
      }
    }

    const result: BatchResult = {
      success: success,
      failed: failed,
      errors: errors
    };
    return result;
  }

  async getById(id: string): Promise<VectorRecord | null> {
    this.ensureConnected();
    const record = this.cache.get(id);
    return record || null;
  }

  async getStats(): Promise<{ count: number; dimension: number }> {
    this.ensureConnected();
    const stats = {
      count: this.cache.size,
      dimension: this.config.dimension
    };
    return stats;
  }

  private cosineSimilarity(a: number[], b: number[]): number {
    if (a.length !== b.length) {
      throw new Error('Vector dimensions do not match');
    }

    let dotProduct = 0;
    let normA = 0;
    let normB = 0;

    for (let i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }

    if (normA === 0 || normB === 0) {
      return 0;
    }

    return dotProduct / (Math.sqrt(normA) * Math.sqrt(normB));
  }

  private ensureConnected(): void {
    if (!this.connected) {
      throw new Error('Not connected to vector database');
    }
  }

  private delay(ms: number): Promise<void> {
    return new Promise<void>((resolve: Function) => {
      setTimeout(() => {
        resolve();
      }, ms);
    });
  }

  private getAllRecords(): VectorRecord[] {
    const records: VectorRecord[] = [];
    const keys = Array.from(this.cache.keys());
    for (let i = 0; i < keys.length; i++) {
      const record = this.cache.get(keys[i]);
      if (record !== undefined) {
        records.push(record);
      }
    }
    return records;
  }

  async initMockData(): Promise<void> {
    const mockRecords: VectorRecord[] = [];

    const record1: VectorRecord = {
      id: 'med_001',
      vector: this.generateMockVector(384),
      metadata: { title: '感冒症状与治疗', source: '医学知识库', category: 'common' }
    };
    mockRecords.push(record1);

    const record2: VectorRecord = {
      id: 'med_002',
      vector: this.generateMockVector(384),
      metadata: { title: '高血压管理', source: '医学知识库', category: 'chronic' }
    };
    mockRecords.push(record2);

    const record3: VectorRecord = {
      id: 'med_003',
      vector: this.generateMockVector(384),
      metadata: { title: '糖尿病饮食指导', source: '医学知识库', category: 'nutrition' }
    };
    mockRecords.push(record3);

    const record4: VectorRecord = {
      id: 'med_004',
      vector: this.generateMockVector(384),
      metadata: { title: '中医体质辨识', source: '中医知识库', category: 'tcm' }
    };
    mockRecords.push(record4);

    const record5: VectorRecord = {
      id: 'med_005',
      vector: this.generateMockVector(384),
      metadata: { title: '运动康复指南', source: '康复知识库', category: 'rehab' }
    };
    mockRecords.push(record5);

    await this.batchInsert(mockRecords);
  }

  private generateMockVector(dimension: number): number[] {
    const vector: number[] = [];
    for (let i = 0; i < dimension; i++) {
      vector.push(Math.random() * 2 - 1);
    }
    return vector;
  }
}
