export interface VirtualScrollItem {
  id: number | string;
  height?: number;
}

export class VirtualScrollManager<T extends VirtualScrollItem> {
  private items: T[] = [];
  private itemHeight: number = 80;
  private containerHeight: number = 600;
  private scrollTop: number = 0;
  private bufferSize: number = 5;

  setItems(items: T[]): void {
    this.items = items;
  }

  setContainerHeight(height: number): void {
    this.containerHeight = height;
  }

  setItemHeight(height: number): void {
    this.itemHeight = height;
  }

  setScrollTop(scrollTop: number): void {
    this.scrollTop = scrollTop;
  }

  setBufferSize(size: number): void {
    this.bufferSize = size;
  }

  getVisibleRange(): { start: number; end: number } {
    if (this.items.length === 0) {
      return { start: 0, end: 0 };
    }

    const visibleCount = Math.ceil(this.containerHeight / this.itemHeight);
    
    const start = Math.max(0, Math.floor(this.scrollTop / this.itemHeight) - this.bufferSize);
    
    const end = Math.min(
      this.items.length,
      start + visibleCount + this.bufferSize * 2
    );

    return { start, end };
  }

  getVisibleItems(): T[] {
    const range = this.getVisibleRange();
    return this.items.slice(range.start, range.end);
  }

  getTotalHeight(): number {
    return this.items.length * this.itemHeight;
  }

  getOffsetY(): number {
    const range = this.getVisibleRange();
    return range.start * this.itemHeight;
  }

  getItemPosition(index: number): number {
    return index * this.itemHeight;
  }

  scrollToIndex(index: number): number {
    const targetPosition = index * this.itemHeight;
    const maxScroll = this.getTotalHeight() - this.containerHeight;
    return Math.min(targetPosition, maxScroll);
  }

  getScrollToItem(id: number | string): number | null {
    const index = this.items.findIndex(item => item.id === id);
    if (index === -1) {
      return null;
    }
    return this.scrollToIndex(index);
  }

  shouldUpdate(scrollTop: number, threshold: number = 10): boolean {
    return Math.abs(scrollTop - this.scrollTop) > threshold;
  }

  getItemKey(item: T, index: number): string {
    return `${item.id}_${index}`;
  }

  getStats(): {
    totalItems: number;
    visibleItems: number;
    scrollTop: number;
    totalHeight: number;
  } {
    const range = this.getVisibleRange();
    return {
      totalItems: this.items.length,
      visibleItems: range.end - range.start,
      scrollTop: this.scrollTop,
      totalHeight: this.getTotalHeight()
    };
  }
}

export class LazyLoadManager {
  private static instance: LazyLoadManager | null = null;
  private loadingPages: Map<string, boolean> = new Map();
  private loadedPages: Map<string, boolean> = new Map();

  private constructor() {}

  static getInstance(): LazyLoadManager {
    if (!LazyLoadManager.instance) {
      LazyLoadManager.instance = new LazyLoadManager();
    }
    return LazyLoadManager.instance;
  }

  isLoading(key: string): boolean {
    return this.loadingPages.get(key) || false;
  }

  isLoaded(key: string): boolean {
    return this.loadedPages.get(key) || false;
  }

  startLoading(key: string): void {
    this.loadingPages.set(key, true);
  }

  finishLoading(key: string, success: boolean = true): void {
    this.loadingPages.set(key, false);
    if (success) {
      this.loadedPages.set(key, true);
    }
  }

  shouldLoad(key: string): boolean {
    return !this.isLoading(key) && !this.isLoaded(key);
  }

  clear(key?: string): void {
    if (key) {
      this.loadingPages.delete(key);
      this.loadedPages.delete(key);
    } else {
      this.loadingPages.clear();
      this.loadedPages.clear();
    }
  }

  getStats(): { loading: number; loaded: number } {
    let loadingCount = 0;
    let loadedCount = 0;

    this.loadingPages.forEach((value) => {
      if (value) loadingCount++;
    });

    this.loadedPages.forEach((value) => {
      if (value) loadedCount++;
    });

    return {
      loading: loadingCount,
      loaded: loadedCount
    };
  }
}

export const lazyLoadManager = LazyLoadManager.getInstance();
