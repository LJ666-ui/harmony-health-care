import { WebSocketService, MessageType } from './WebSocketService';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';

/**
 * 同步状态接口
 */
export interface SyncStatus {
  lastSyncTime: number;
  pendingChanges: number;
  status: string;
}

/**
 * 同步记录接口
 */
export interface SyncRecord {
  id: string;
  entityType: string;
  entityId: string;
  operation: string;
  data: string;
  timestamp: number;
  status: string;
}

/**
 * 冲突记录接口
 */
export interface ConflictRecord {
  id: string;
  entityType: string;
  entityId: string;
  localData: string;
  serverData: string;
  detectedAt: number;
  resolvedAt: number;
  resolution: string;
}

/**
 * 数据同步服务类（符合ArkTS规范）
 */
export class SyncService {
  private static instance: SyncService | null = null;
  private wsService: WebSocketService;
  private syncQueue: SyncRecord[] = [];
  private lastSyncTime: number = 0;
  private isSyncing: boolean = false;
  private syncInterval: number = 30000;
  private timer: number = -1;
  
  private constructor() {
    this.wsService = WebSocketService.getInstance();
  }
  
  static getInstance(): SyncService {
    if (!SyncService.instance) {
      SyncService.instance = new SyncService();
    }
    return SyncService.instance;
  }
  
  /**
   * 初始化同步服务
   */
  async init(): Promise<void> {
    await this.loadLastSyncTime();
    this.startAutoSync();
  }
  
  /**
   * 加载上次同步时间
   */
  private async loadLastSyncTime(): Promise<void> {
    try {
      const response = await HttpUtil.get<SyncStatus>('/sync/status');
      if (response.success && response.data) {
        this.lastSyncTime = response.data.lastSyncTime;
      }
    } catch (error) {
      console.error('加载同步状态失败:', error);
    }
  }
  
  /**
   * 开始自动同步
   */
  private startAutoSync(): void {
    this.timer = setInterval(() => {
      this.sync();
    }, this.syncInterval);
  }
  
  /**
   * 停止自动同步
   */
  private stopAutoSync(): void {
    if (this.timer !== -1) {
      clearInterval(this.timer);
      this.timer = -1;
    }
  }
  
  /**
   * 执行同步
   */
  async sync(): Promise<boolean> {
    if (this.isSyncing) {
      return false;
    }
    
    this.isSyncing = true;
    
    try {
      const response = await HttpUtil.post<SyncRecord[]>('/sync/execute', {
        lastSyncTime: this.lastSyncTime,
        pendingChanges: this.syncQueue
      });
      
      if (response.success && response.data) {
        await this.applySyncChanges(response.data);
        this.lastSyncTime = Date.now();
        this.syncQueue = [];
        
        this.wsService.send({
          type: MessageType.DATA_SYNC,
          data: JSON.stringify({ lastSyncTime: this.lastSyncTime })
        });
        
        return true;
      }
      return false;
    } catch (error) {
      console.error('同步失败:', error);
      return false;
    } finally {
      this.isSyncing = false;
    }
  }
  
  /**
   * 应用同步变更
   */
  private async applySyncChanges(changes: SyncRecord[]): Promise<void> {
    for (let i = 0; i < changes.length; i++) {
      const change = changes[i];
      await this.applyChange(change);
    }
  }
  
  /**
   * 应用单个变更
   */
  private async applyChange(change: SyncRecord): Promise<void> {
    console.log(`应用变更: ${change.entityType} ${change.operation}`);
  }
  
  /**
   * 添加同步记录
   */
  addToSyncQueue(entityType: string, entityId: string, operation: string, data: string): void {
    const record: SyncRecord = {
      id: this.generateId(),
      entityType: entityType,
      entityId: entityId,
      operation: operation,
      data: data,
      timestamp: Date.now(),
      status: 'PENDING'
    };
    
    this.syncQueue.push(record);
  }
  
  /**
   * 请求同步
   */
  requestSync(): void {
    this.wsService.send({
      type: MessageType.SYNC_REQUEST,
      data: JSON.stringify({ lastSyncTime: this.lastSyncTime })
    });
  }
  
  /**
   * 获取同步状态
   */
  getSyncStatus(): SyncStatus {
    return {
      lastSyncTime: this.lastSyncTime,
      pendingChanges: this.syncQueue.length,
      status: this.isSyncing ? 'SYNCING' : 'IDLE'
    };
  }
  
  /**
   * 解决冲突
   */
  async resolveConflict(conflictId: string, resolution: string): Promise<boolean> {
    try {
      const response = await HttpUtil.post(`/sync/conflicts/${conflictId}/resolve`, {
        resolution: resolution
      });
      
      return response.success;
    } catch (error) {
      console.error('解决冲突失败:', error);
      return false;
    }
  }
  
  /**
   * 生成ID
   */
  private generateId(): string {
    return Date.now().toString() + Math.random().toString(36).substring(2, 9);
  }
  
  /**
   * 销毁
   */
  destroy(): void {
    this.stopAutoSync();
    this.syncQueue = [];
    SyncService.instance = null;
  }
}
