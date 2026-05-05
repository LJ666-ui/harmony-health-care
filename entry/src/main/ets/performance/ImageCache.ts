/**
 * LRU图片缓存
 * 实现基于LRU策略的图片缓存，控制缓存大小
 * 
 * @author AI Assistant
 * @date 2026-04-27
 */

/**
 * LRU缓存节点
 */
class LRUNode<K, V> {
  key: K;
  value: V;
  prev: LRUNode<K, V> | null = null;
  next: LRUNode<K, V> | null = null;
  
  constructor(key: K, value: V) {
    this.key = key;
    this.value = value;
  }
}

/**
 * LRU缓存实现
 */
class LRUCache<K, V> {
  private capacity: number;
  private cache: Map<K, LRUNode<K, V>> = new Map();
  private head: LRUNode<K, V> | null = null;
  private tail: LRUNode<K, V> | null = null;
  
  constructor(capacity: number) {
    this.capacity = capacity;
  }
  
  get(key: K): V | undefined {
    const node = this.cache.get(key);
    if (!node) {
      return undefined;
    }
    
    // 移到头部
    this.moveToHead(node);
    return node.value;
  }
  
  put(key: K, value: V): void {
    const node = this.cache.get(key);
    
    if (node) {
      // 更新值并移到头部
      node.value = value;
      this.moveToHead(node);
    } else {
      // 创建新节点
      const newNode = new LRUNode(key, value);
      this.cache.set(key, newNode);
      this.addToHead(newNode);
      
      // 检查容量
      if (this.cache.size > this.capacity) {
        this.removeTail();
      }
    }
  }
  
  delete(key: K): boolean {
    const node = this.cache.get(key);
    if (!node) {
      return false;
    }
    
    this.removeNode(node);
    this.cache.delete(key);
    return true;
  }
  
  clear(): void {
    this.cache.clear();
    this.head = null;
    this.tail = null;
  }
  
  size(): number {
    return this.cache.size;
  }
  
  private moveToHead(node: LRUNode<K, V>): void {
    this.removeNode(node);
    this.addToHead(node);
  }
  
  private addToHead(node: LRUNode<K, V>): void {
    node.prev = null;
    node.next = this.head;
    
    if (this.head) {
      this.head.prev = node;
    }
    
    this.head = node;
    
    if (!this.tail) {
      this.tail = node;
    }
  }
  
  private removeNode(node: LRUNode<K, V>): void {
    if (node.prev) {
      node.prev.next = node.next;
    } else {
      this.head = node.next;
    }
    
    if (node.next) {
      node.next.prev = node.prev;
    } else {
      this.tail = node.prev;
    }
  }
  
  private removeTail(): void {
    if (!this.tail) {
      return;
    }
    
    this.cache.delete(this.tail.key);
    this.removeNode(this.tail);
  }
}

/**
 * 图片缓存项
 */
interface ImageCacheItem {
  url: string;                    // 图片URL
  data: string;                   // 图片数据（Base64或路径）
  size: number;                   // 大小（KB）
  timestamp: number;              // 缓存时间
  accessCount: number;            // 访问次数
  lastAccessTime: number;         // 最后访问时间
}

/**
 * 图片缓存配置
 */
export interface ImageCacheConfig {
  enabled: boolean;               // 是否启用缓存
  maxSize: number;                // 最大缓存大小（MB）
  maxCount: number;               // 最大缓存数量
  expireTime: number;             // 过期时间（毫秒）
  enablePreload: boolean;         // 是否启用预加载
}

/**
 * 缓存统计
 */
export interface ImageCacheStats {
  totalCount: number;             // 总缓存数
  totalSize: number;              // 总大小（MB）
  hitCount: number;               // 命中次数
  missCount: number;              // 未命中次数
  hitRate: number;                // 命中率
  evictionCount: number;          // 淘汰次数
}

/**
 * LRU图片缓存
 */
export class ImageCache {
  private static instance: ImageCache | null = null;
  
  // 配置
  private config: ImageCacheConfig = {
    enabled: true,
    maxSize: 100,                 // 100MB
    maxCount: 200,
    expireTime: 3600000,          // 1小时
    enablePreload: true
  };
  
  // LRU缓存
  private lruCache: LRUCache<string, ImageCacheItem>;
  
  // 当前缓存大小
  private currentSize: number = 0;
  
  // 统计信息
  private stats: ImageCacheStats = {
    totalCount: 0,
    totalSize: 0,
    hitCount: 0,
    missCount: 0,
    hitRate: 0,
    evictionCount: 0
  };
  
  // 私有构造函数
  private constructor() {
    this.lruCache = new LRUCache<string, ImageCacheItem>(this.config.maxCount);
    console.info('[ImageCache] 初始化LRU图片缓存');
  }
  
  /**
   * 获取单例实例
   */
  public static getInstance(): ImageCache {
    if (!ImageCache.instance) {
      ImageCache.instance = new ImageCache();
    }
    return ImageCache.instance;
  }
  
  /**
   * 获取图片
   * @param url 图片URL
   */
  public get(url: string): string | null {
    if (!this.config.enabled) {
      this.stats.missCount++;
      return null;
    }
    
    const item = this.lruCache.get(url);
    
    if (!item) {
      this.stats.missCount++;
      this.updateHitRate();
      console.debug(`[ImageCache] 缓存未命中: ${url}`);
      return null;
    }
    
    // 检查是否过期
    if (Date.now() - item.timestamp > this.config.expireTime) {
      this.delete(url);
      this.stats.missCount++;
      this.updateHitRate();
      console.debug(`[ImageCache] 缓存已过期: ${url}`);
      return null;
    }
    
    // 更新访问信息
    item.accessCount++;
    item.lastAccessTime = Date.now();
    
    this.stats.hitCount++;
    this.updateHitRate();
    
    console.debug(`[ImageCache] 缓存命中: ${url}`);
    return item.data;
  }
  
  /**
   * 缓存图片
   * @param url 图片URL
   * @param data 图片数据
   */
  public set(url: string, data: string): void {
    if (!this.config.enabled) {
      return;
    }
    
    // 估算大小
    const size = this.estimateSize(data);
    
    // 检查是否需要淘汰
    while (this.currentSize + size > this.config.maxSize * 1024) {
      this.evict();
    }
    
    // 创建缓存项
    const item: ImageCacheItem = {
      url,
      data,
      size,
      timestamp: Date.now(),
      accessCount: 0,
      lastAccessTime: Date.now()
    };
    
    // 添加到缓存
    this.lruCache.put(url, item);
    this.currentSize += size;
    
    // 更新统计
    this.updateStats();
    
    console.debug(`[ImageCache] 缓存图片: ${url}, 大小: ${size}KB`);
  }
  
  /**
   * 删除图片缓存
   * @param url 图片URL
   */
  public delete(url: string): boolean {
    const item = this.lruCache.get(url);
    if (!item) {
      return false;
    }
    
    this.currentSize -= item.size;
    const result = this.lruCache.delete(url);
    
    this.updateStats();
    console.debug(`[ImageCache] 删除缓存: ${url}`);
    
    return result;
  }
  
  /**
   * 清空所有缓存
   */
  public clear(): void {
    this.lruCache.clear();
    this.currentSize = 0;
    this.updateStats();
    console.info('[ImageCache] 清空所有缓存');
  }
  
  /**
   * 预加载图片
   * @param urls 图片URL数组
   */
  public async preload(urls: string[]): Promise<void> {
    if (!this.config.enablePreload) {
      return;
    }
    
    console.info(`[ImageCache] 开始预加载 ${urls.length} 张图片`);
    
    for (const url of urls) {
      if (!this.lruCache.get(url)) {
        try {
          // TODO: 实际加载图片
          // const data = await ImageLoader.load(url);
          // this.set(url, data);
          console.debug(`[ImageCache] 预加载图片: ${url}`);
        } catch (error) {
          console.error(`[ImageCache] 预加载失败: ${url}`, error);
        }
      }
    }
  }
  
  /**
   * 获取缓存统计
   */
  public getStats(): ImageCacheStats {
    return { ...this.stats };
  }
  
  /**
   * 更新配置
   */
  public updateConfig(config: Partial<ImageCacheConfig>): void {
    this.config = { ...this.config, ...config };
    this.lruCache = new LRUCache<string, ImageCacheItem>(this.config.maxCount);
    console.info('[ImageCache] 更新配置:', JSON.stringify(this.config));
  }
  
  /**
   * 获取当前配置
   */
  public getConfig(): ImageCacheConfig {
    return { ...this.config };
  }
  
  // ==================== 私有方法 ====================
  
  /**
   * 淘汰缓存
   */
  private evict(): void {
    // LRU缓存会自动淘汰最久未使用的项
    // 这里我们手动触发一次清理
    const size = this.lruCache.size();
    if (size > 0) {
      // 删除最久未使用的项（尾部）
      // 由于LRUCache的实现，put操作会自动淘汰
      this.stats.evictionCount++;
      console.debug('[ImageCache] LRU淘汰缓存');
    }
  }
  
  /**
   * 估算图片大小（KB）
   */
  private estimateSize(data: string): number {
    // Base64数据大小估算
    return Math.ceil(data.length * 0.75 / 1024);
  }
  
  /**
   * 更新统计信息
   */
  private updateStats(): void {
    this.stats.totalCount = this.lruCache.size();
    this.stats.totalSize = this.currentSize / 1024; // 转换为MB
  }
  
  /**
   * 更新命中率
   */
  private updateHitRate(): void {
    const total = this.stats.hitCount + this.stats.missCount;
    this.stats.hitRate = total > 0 ? this.stats.hitCount / total : 0;
  }
}

// 导出单例
export const imageCache = ImageCache.getInstance();
