/**
 * RAG检索相关类型定义
 * 包含知识文档、检索结果、知识上下文等数据结构
 */

/**
 * 知识文档元数据
 */
export interface KnowledgeMetadata {
  category: string;            // 知识分类
  tags: string[];              // 标签
  author?: string;             // 作者
  publishDate?: number;        // 发布日期
  verified: boolean;           // 是否已验证
}

/**
 * 知识文档
 */
export interface KnowledgeDocument {
  id: string;                  // 知识ID
  title: string;               // 知识标题
  content: string;             // 知识内容
  source: string;              // 知识来源
  category: string;            // 知识分类
  tags: string[];              // 标签
  vector?: number[];           // 向量表示
  metadata?: KnowledgeMetadata; // 元数据
}

/**
 * 检索结果元数据
 */
export interface SearchResultMetadata {
  title: string;               // 标题
  source: string;              // 来源
  category?: string;           // 分类
}

/**
 * 检索结果
 */
export interface SearchResult {
  docId: string;               // 文档ID
  similarity: number;          // 相似度 [0-1]
  metadata: SearchResultMetadata;  // 元数据
}

/**
 * 知识引用
 */
export interface KnowledgeReference {
  id: string;                  // 知识ID
  title: string;               // 知识标题
  source: string;              // 知识来源
  url?: string;                // 来源链接
  relevance?: number;          // 相关度
}

/**
 * 知识上下文
 */
export interface KnowledgeContext {
  content: string;             // 知识内容
  references: KnowledgeReference[];  // 引用列表
  totalFound: number;          // 总共找到的数量
  filteredCount: number;       // 过滤后的数量
}

/**
 * RAG检索配置
 */
export interface RAGConfig {
  topK: number;                // 返回结果数量，默认5
  similarityThreshold: number; // 相似度阈值，默认0.7
  maxContentLength: number;    // 最大内容长度
  enableCache: boolean;        // 是否启用缓存
  cacheTTL: number;            // 缓存过期时间（秒）
}

/**
 * 向量化请求
 */
export interface EmbeddingRequest {
  text: string;                // 待向量化的文本
  model?: string;              // 使用的模型
}

/**
 * 向量化响应
 */
export interface EmbeddingResponse {
  vector: number[];            // 向量表示
  dimension: number;           // 向量维度
  model: string;               // 使用的模型
}
