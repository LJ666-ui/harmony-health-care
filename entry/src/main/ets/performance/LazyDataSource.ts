/**
 * LazyForEach数据源
 * 用于优化列表渲染性能，实现懒加载和列表项复用
 * 
 * @author AI Assistant
 * @date 2026-04-27
 */

/**
 * LazyForEach数据源基类
 * 实现IDataSource接口，支持懒加载
 */
export class LazyDataSource<T> {
  // 数据数组
  private dataArray: T[] = [];
  
  // 监听器集合
  private listeners: Set<DataChangeListener> = new Set();
  
  // 懒加载配置
  private pageSize: number = 20;          // 每页加载数量
  private loadedCount: number = 0;        // 已加载数量
  private isLoading: boolean = false;     // 是否正在加载
  
  // 数据加载器
  private dataLoader?: (offset: number, limit: number) => Promise<T[]>;
  
  constructor(data?: T[], dataLoader?: (offset: number, limit: number) => Promise<T[]>) {
    if (data) {
      this.dataArray = data;
      this.loadedCount = data.length;
    }
    this.dataLoader = dataLoader;
  }
  
  /**
   * 获取数据总数
   */
  public totalCount(): number {
    return this.dataArray.length;
  }
  
  /**
   * 获取指定索引的数据
   */
  public getData(index: number): T {
    return this.dataArray[index];
  }
  
  /**
   * 注册数据改变监听器
   */
  public registerDataChangeListener(listener: DataChangeListener): void {
    this.listeners.add(listener);
  }
  
  /**
   * 注销数据改变监听器
   */
  public unregisterDataChangeListener(listener: DataChangeListener): void {
    this.listeners.delete(listener);
  }
  
  /**
   * 通知数据重新加载
   */
  private notifyDataReload(): void {
    this.listeners.forEach(listener => {
      if (listener.onDataReloaded) {
        listener.onDataReloaded();
      }
    });
  }
  
  /**
   * 通知数据添加
   */
  private notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      if (listener.onDataAdded) {
        listener.onDataAdded(index);
      }
    });
  }
  
  /**
   * 通知数据改变
   */
  private notifyDataChange(index: number): void {
    this.listeners.forEach(listener => {
      if (listener.onDataChanged) {
        listener.onDataChanged(index);
      }
    });
  }
  
  /**
   * 通知数据删除
   */
  private notifyDataDelete(index: number): void {
    this.listeners.forEach(listener => {
      if (listener.onDataDeleted) {
        listener.onDataDeleted(index);
      }
    });
  }
  
  /**
   * 通知数据移动
   */
  private notifyDataMove(from: number, to: number): void {
    this.listeners.forEach(listener => {
      if (listener.onDataMoved) {
        listener.onDataMoved(from, to);
      }
    });
  }
  
  // ==================== 数据操作方法 ====================
  
  /**
   * 重新加载所有数据
   */
  public reloadData(data: T[]): void {
    this.dataArray = data;
    this.loadedCount = data.length;
    this.notifyDataReload();
  }
  
  /**
   * 添加数据到末尾
   */
  public addData(item: T): void {
    this.dataArray.push(item);
    this.loadedCount++;
    this.notifyDataAdd(this.dataArray.length - 1);
  }
  
  /**
   * 批量添加数据
   */
  public addDataArray(items: T[]): void {
    const startIndex = this.dataArray.length;
    this.dataArray.push(...items);
    this.loadedCount += items.length;
    
    // 通知每个新增项
    for (let i = 0; i < items.length; i++) {
      this.notifyDataAdd(startIndex + i);
    }
  }
  
  /**
   * 在指定位置插入数据
   */
  public insertData(index: number, item: T): void {
    this.dataArray.splice(index, 0, item);
    this.loadedCount++;
    this.notifyDataAdd(index);
  }
  
  /**
   * 更新指定位置的数据
   */
  public updateData(index: number, item: T): void {
    if (index >= 0 && index < this.dataArray.length) {
      this.dataArray[index] = item;
      this.notifyDataChange(index);
    }
  }
  
  /**
   * 删除指定位置的数据
   */
  public deleteData(index: number): void {
    if (index >= 0 && index < this.dataArray.length) {
      this.dataArray.splice(index, 1);
      this.loadedCount--;
      this.notifyDataDelete(index);
    }
  }
  
  /**
   * 移动数据
   */
  public moveData(from: number, to: number): void {
    if (from >= 0 && from < this.dataArray.length && 
        to >= 0 && to < this.dataArray.length) {
      const item = this.dataArray.splice(from, 1)[0];
      this.dataArray.splice(to, 0, item);
      this.notifyDataMove(from, to);
    }
  }
  
  /**
   * 清空所有数据
   */
  public clearData(): void {
    this.dataArray = [];
    this.loadedCount = 0;
    this.notifyDataReload();
  }
  
  // ==================== 懒加载方法 ====================
  
  /**
   * 加载更多数据
   */
  public async loadMore(): Promise<boolean> {
    if (!this.dataLoader || this.isLoading) {
      return false;
    }
    
    this.isLoading = true;
    
    try {
      const newData = await this.dataLoader(this.loadedCount, this.pageSize);
      
      if (newData.length > 0) {
        this.addDataArray(newData);
        console.info(`[LazyDataSource] 加载 ${newData.length} 条数据`);
        return true;
      }
      
      return false;
    } catch (error) {
      console.error('[LazyDataSource] 加载数据失败:', error);
      return false;
    } finally {
      this.isLoading = false;
    }
  }
  
  /**
   * 检查是否需要加载更多
   * @param lastIndex 当前显示的最后一项索引
   */
  public checkLoadMore(lastIndex: number): void {
    // 当显示到倒数第5项时，开始加载更多
    const threshold = 5;
    if (lastIndex >= this.dataArray.length - threshold) {
      this.loadMore();
    }
  }
  
  /**
   * 设置每页加载数量
   */
  public setPageSize(size: number): void {
    this.pageSize = size;
  }
  
  /**
   * 获取加载状态
   */
  public getLoadingState(): boolean {
    return this.isLoading;
  }
  
  /**
   * 获取已加载数量
   */
  public getLoadedCount(): number {
    return this.loadedCount;
  }
}

/**
 * 数据改变监听器接口
 */
export interface DataChangeListener {
  onDataReloaded?: () => void;
  onDataAdded?: (index: number) => void;
  onDataChanged?: (index: number) => void;
  onDataDeleted?: (index: number) => void;
  onDataMoved?: (from: number, to: number) => void;
}

/**
 * 创建简单数据源
 */
export function createLazyDataSource<T>(data: T[]): LazyDataSource<T> {
  return new LazyDataSource<T>(data);
}

/**
 * 创建懒加载数据源
 */
export function createLazyLoadDataSource<T>(
  dataLoader: (offset: number, limit: number) => Promise<T[]>,
  initialData?: T[]
): LazyDataSource<T> {
  return new LazyDataSource<T>(initialData, dataLoader);
}
