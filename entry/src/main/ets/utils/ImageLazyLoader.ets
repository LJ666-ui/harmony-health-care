import { HttpUtil } from '../common/utils/HttpUtil';

interface ImageCache {
  url: string;
  localPath: string;
  timestamp: number;
}

export class ImageLazyLoader {
  private static instance: ImageLazyLoader | null = null;
  private imageCache: Map<string, ImageCache> = new Map();
  private loadingImages: Set<string> = new Set();
  private maxCacheSize: number = 50;
  private placeholderImage: string = 'https://via.placeholder.com/150';

  private constructor() {}

  static getInstance(): ImageLazyLoader {
    if (!ImageLazyLoader.instance) {
      ImageLazyLoader.instance = new ImageLazyLoader();
    }
    return ImageLazyLoader.instance;
  }

  async loadImage(url: string): Promise<string> {
    if (this.imageCache.has(url)) {
      return this.imageCache.get(url)!.localPath;
    }

    if (this.loadingImages.has(url)) {
      await this.waitForImageLoad(url);
      return this.imageCache.get(url)?.localPath || this.placeholderImage;
    }

    this.loadingImages.add(url);

    try {
      console.info(`[ImageLazyLoader] 加载图片: ${url}`);
      
      const localPath = url;
      
      this.imageCache.set(url, {
        url: url,
        localPath: localPath,
        timestamp: Date.now()
      });

      if (this.imageCache.size > this.maxCacheSize) {
        this.evictOldestImage();
      }

      return localPath;
    } catch (error) {
      console.error(`[ImageLazyLoader] 加载图片失败: ${url}`, error);
      return this.placeholderImage;
    } finally {
      this.loadingImages.delete(url);
    }
  }

  private async waitForImageLoad(url: string): Promise<void> {
    return new Promise<void>((resolve) => {
      const checkInterval = setInterval(() => {
        if (this.imageCache.has(url)) {
          clearInterval(checkInterval);
          resolve();
        }
      }, 100);
    });
  }

  private evictOldestImage(): void {
    let oldestKey: string | null = null;
    let oldestTimestamp: number = Infinity;

    this.imageCache.forEach((value, key) => {
      if (value.timestamp < oldestTimestamp) {
        oldestTimestamp = value.timestamp;
        oldestKey = key;
      }
    });

    if (oldestKey) {
      this.imageCache.delete(oldestKey);
      console.info(`[ImageLazyLoader] 驱逐最旧图片: ${oldestKey}`);
    }
  }

  preloadImages(urls: string[]): void {
    urls.forEach(url => {
      if (!this.imageCache.has(url) && !this.loadingImages.has(url)) {
        this.loadImage(url);
      }
    });
  }

  isInViewport(
    elementTop: number,
    elementBottom: number,
    viewportTop: number,
    viewportBottom: number,
    threshold: number = 100
  ): boolean {
    const adjustedTop = viewportTop - threshold;
    const adjustedBottom = viewportBottom + threshold;

    return elementBottom >= adjustedTop && elementTop <= adjustedBottom;
  }

  shouldLoadImage(
    imageIndex: number,
    visibleStart: number,
    visibleEnd: number,
    preloadThreshold: number = 5
  ): boolean {
    return imageIndex >= visibleStart - preloadThreshold && 
           imageIndex <= visibleEnd + preloadThreshold;
  }

  clearCache(url?: string): void {
    if (url) {
      this.imageCache.delete(url);
    } else {
      this.imageCache.clear();
    }
    console.info(`[ImageLazyLoader] 图片缓存已清除: ${url || '全部'}`);
  }

  getCacheSize(): number {
    return this.imageCache.size;
  }

  getLoadingCount(): number {
    return this.loadingImages.size;
  }
}

export const imageLazyLoader = ImageLazyLoader.getInstance();
