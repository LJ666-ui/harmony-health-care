import { EngineType, InferencePriority, InferenceScene } from './types/EngineTypes';
import { InferenceRequest, InferenceInput } from './types/InferenceTypes';
import { ModelType } from './types/ModelTypes';

interface NPUResource {
  holder: EngineType;
  acquiredAt: number;
  priority: InferencePriority;
}

interface QueueItem {
  request: InferenceRequest;
  enqueuedAt: number;
  resolve: (value: boolean) => void;
  reject: (reason: Error) => void;
}

export class ResourceScheduler {
  private static instance: ResourceScheduler;

  private npuResource: NPUResource | null = null;
  private requestQueue: QueueItem[] = [];
  private readonly MAX_QUEUE_SIZE: number = 10;
  private readonly QUEUE_TIMEOUT: number = 3000;
  private readonly DEADLOCK_THRESHOLD: number = 10000;

  private npuUtilization: number = 0;
  private totalRequests: number = 0;
  private waitingRequests: number = 0;

  private constructor() {}

  static getInstance(): ResourceScheduler {
    if (!ResourceScheduler.instance) {
      ResourceScheduler.instance = new ResourceScheduler();
    }
    return ResourceScheduler.instance;
  }

  async acquireNPU(engine: EngineType, priority: InferencePriority = InferencePriority.NORMAL): Promise<boolean> {
    if (this.requestQueue.length >= this.MAX_QUEUE_SIZE) {
      throw new Error('推理队列已满，请稍后重试');
    }

    if (this.npuResource === null) {
      this.npuResource = {
        holder: engine,
        acquiredAt: Date.now(),
        priority: priority
      };
      this.npuUtilization = 1;
      this.totalRequests++;
      return true;
    }

    if (this.detectDeadlock()) {
      this.recoverDeadlock();
    }

    return new Promise<boolean>((resolve, reject) => {
      const queueItem: QueueItem = {
        request: {
          requestId: 'resource-request',
          scene: InferenceScene.HEALTH_RISK_PREDICTION,
          modelType: ModelType.HEALTH_RISK_ASSESSMENT,
          input: new InferenceInput(),
          priority: priority,
          timestamp: Date.now()
        },
        enqueuedAt: Date.now(),
        resolve,
        reject
      };

      if (priority < this.npuResource!.priority) {
        const insertIndex = this.requestQueue.findIndex(item => item.request.priority > priority);
        if (insertIndex === -1) {
          this.requestQueue.push(queueItem);
        } else {
          this.requestQueue.splice(insertIndex, 0, queueItem);
        }
      } else {
        this.requestQueue.push(queueItem);
      }
      this.waitingRequests = this.requestQueue.length;

      setTimeout(() => {
        const index = this.requestQueue.indexOf(queueItem);
        if (index !== -1) {
          this.requestQueue.splice(index, 1);
          this.waitingRequests = this.requestQueue.length;
          reject(new Error('排队超时，系统繁忙'));
        }
      }, this.QUEUE_TIMEOUT);
    });
  }

  releaseNPU(engine: EngineType): void {
    if (this.npuResource && this.npuResource.holder === engine) {
      this.npuResource = null;
      this.npuUtilization = 0;

      if (this.requestQueue.length > 0) {
        const nextItem = this.requestQueue.shift()!;
        this.waitingRequests = this.requestQueue.length;
        this.npuResource = {
          holder: nextItem.request.preferredEngine || EngineType.MINDSPORE_LITE,
          acquiredAt: Date.now(),
          priority: nextItem.request.priority
        };
        this.npuUtilization = 1;
        this.totalRequests++;
        nextItem.resolve(true);
      }
    }
  }

  isNPUAvailable(): boolean {
    return this.npuResource === null;
  }

  getNPUHolder(): EngineType | null {
    return this.npuResource ? this.npuResource.holder : null;
  }

  enqueueRequest(request: InferenceRequest): void {
    if (this.requestQueue.length >= this.MAX_QUEUE_SIZE) {
      throw new Error('推理队列溢出');
    }
  }

  dequeueRequest(): InferenceRequest | null {
    if (this.requestQueue.length === 0) {
      return null;
    }
    const item = this.requestQueue.shift()!;
    this.waitingRequests = this.requestQueue.length;
    return item.request;
  }

  detectDeadlock(): boolean {
    if (this.npuResource) {
      const heldDuration = Date.now() - this.npuResource.acquiredAt;
      return heldDuration > this.DEADLOCK_THRESHOLD;
    }
    return false;
  }

  recoverDeadlock(): void {
    console.warn('ResourceScheduler: 检测到NPU死锁，强制释放资源');
    this.npuResource = null;
    this.npuUtilization = 0;

    while (this.requestQueue.length > 0) {
      const item = this.requestQueue.shift()!;
      item.reject(new Error('NPU死锁恢复'));
    }
    this.waitingRequests = 0;
  }

  getMetrics(): ResourceMetrics {
    return {
      npuUtilization: this.npuUtilization,
      totalRequests: this.totalRequests,
      waitingRequests: this.waitingRequests,
      queueSize: this.requestQueue.length
    };
  }

  reset(): void {
    this.npuResource = null;
    this.requestQueue = [];
    this.npuUtilization = 0;
    this.totalRequests = 0;
    this.waitingRequests = 0;
  }
}

export interface ResourceMetrics {
  npuUtilization: number;
  totalRequests: number;
  waitingRequests: number;
  queueSize: number;
}
