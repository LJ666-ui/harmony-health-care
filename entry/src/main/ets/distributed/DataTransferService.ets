import { distributedKVStore } from './DistributedKitStubs';
import { SyncStatus, SyncTask } from '../models/DistributedModels';

interface TransferProgress {
  taskId: string;
  transferredBytes: number;
  totalBytes: number;
  progress: number;
  status: SyncStatus;
  startTime: number;
}

interface DataPacket {
  packetId: string;
  data: string;
  checksum: string;
  sequence: number;
  totalPackets: number;
  timestamp: number;
}

export class DataTransferService {
  private activeTransfers: Map<string, TransferProgress> = new Map();
  private transferHistory: Map<string, TransferProgress> = new Map();
  private maxConcurrentTransfers: number = 5;
  private maxPacketSize: number = 1024 * 64;

  async transferToTarget(
    targetDeviceId: string,
    encryptedData: string,
    syncId: string
  ): Promise<boolean> {
    try {
      console.log(`[DataTransferService] 开始传输数据到设备: ${targetDeviceId}`);
      console.log(`[DataTransferService] 同步ID: ${syncId}, 数据大小: ${encryptedData.length} 字符`);

      if (this.activeTransfers.size >= this.maxConcurrentTransfers) {
        throw new Error('达到最大并发传输数限制');
      }

      const packets: DataPacket[] = this.splitDataIntoPackets(encryptedData, syncId);
      console.log(`[DataTransferService] 数据分割为 ${packets.length} 个数据包`);

      const transferProgress: TransferProgress = {
        taskId: syncId,
        transferredBytes: 0,
        totalBytes: encryptedData.length,
        progress: 0,
        status: SyncStatus.SYNCING,
        startTime: Date.now()
      };

      this.activeTransfers.set(syncId, transferProgress);

      for (let i = 0; i < packets.length; i++) {
        await this.sendPacket(targetDeviceId, packets[i]);

        transferProgress.transferredBytes += packets[i].data.length;
        transferProgress.progress = Math.round(
          (transferProgress.transferredBytes / transferProgress.totalBytes) * 100
        );

        this.activeTransfers.set(syncId, transferProgress);

        await this.simulateNetworkDelay(100);
      }

      const isVerified: boolean = await this.verifyTransferComplete(
        targetDeviceId,
        syncId,
        encryptedData
      );

      if (!isVerified) {
        transferProgress.status = SyncStatus.FAILED;
        this.activeTransfers.set(syncId, transferProgress);
        throw new Error('数据传输验证失败');
      }

      transferProgress.status = SyncStatus.COMPLETED;
      transferProgress.progress = 100;
      this.activeTransfers.delete(syncId);
      this.transferHistory.set(syncId, transferProgress);

      console.log(`[DataTransferService] 数据传输完成: ${syncId}`);
      return true;
    } catch (error) {
      console.error(`[DataTransferService] 数据传输失败 (${syncId}):`, error);

      const progress: TransferProgress | undefined = this.activeTransfers.get(syncId);
      if (progress) {
        progress.status = SyncStatus.FAILED;
        this.activeTransfers.set(syncId, progress);
      }

      return false;
    }
  }

  async receiveFromSource(
    sourceDeviceId: string,
    expectedSyncId: string
  ): Promise<string | null> {
    try {
      console.log(`[DataTransferService] 接收来自设备的数据: ${sourceDeviceId}`);

      const receivedPackets: DataPacket[] = [];
      let totalPackets: number = 0;
      let receivedCount: number = 0;

      while (receivedCount < totalPackets || totalPackets === 0) {
        const packet: DataPacket | null = await this.receivePacket(sourceDeviceId, expectedSyncId);

        if (!packet) {
          await this.simulateNetworkDelay(200);
          continue;
        }

        if (totalPackets === 0) {
          totalPackets = packet.totalPackets;
        }

        receivedPackets.push(packet);
        receivedCount++;

        if (receivedCount >= totalPackets) {
          break;
        }
      }

      receivedPackets.sort((a: DataPacket, b: DataPacket): number => {
        return a.sequence - b.sequence;
      });

      const assembledData: string = this.assemblePackets(receivedPackets);

      const isValid: boolean = this.verifyChecksum(assembledData, receivedPackets);
      if (!isValid) {
        console.error('[DataTransferService] 接收数据校验失败');
        return null;
      }

      console.log(`[DataTransferService] 数据接收完成，大小: ${assembledData.length} 字符`);
      return assembledData;
    } catch (error) {
      console.error('[DataTransferService] 接收数据失败:', error);
      return null;
    }
  }

  getTransferProgress(taskId: string): TransferProgress | null {
    const progress: TransferProgress | undefined =
      this.activeTransfers.get(taskId) || this.transferHistory.get(taskId);
    return progress || null;
  }

  getAllActiveTransfers(): TransferProgress[] {
    const transfers: TransferProgress[] = [];
    this.activeTransfers.forEach((value: TransferProgress) => {
      transfers.push(value);
    });
    return transfers;
  }

  cancelTransfer(taskId: string): boolean {
    try {
      const progress: TransferProgress | undefined = this.activeTransfers.get(taskId);
      if (!progress) {
        console.warn(`[DataTransferService] 未找到活跃的传输任务: ${taskId}`);
        return false;
      }

      progress.status = SyncStatus.FAILED;
      this.activeTransfers.delete(taskId);
      this.transferHistory.set(taskId, progress);

      console.log(`[DataTransferService] 传输任务已取消: ${taskId}`);
      return true;
    } catch (error) {
      console.error('[DataTransferService] 取消传输失败:', error);
      return false;
    }
  }

  clearTransferHistory(olderThanMs?: number): void {
    const cutoffTime: number = olderThanMs ? Date.now() - olderThanMs : Date.now() - 3600000;

    this.transferHistory.forEach((progress: TransferProgress, taskId: string) => {
      if (progress.startTime < cutoffTime) {
        this.transferHistory.delete(taskId);
      }
    });
  }

  private splitDataIntoPackets(data: string, syncId: string): DataPacket[] {
    const packets: DataPacket[] = [];
    let offset: number = 0;
    let sequence: number = 0;

    while (offset < data.length) {
      const chunkEnd: number = Math.min(offset + this.maxPacketSize, data.length);
      const chunk: string = data.substring(offset, chunkEnd);

      const packet: DataPacket = {
        packetId: `${syncId}_pkt_${sequence}`,
        data: chunk,
        checksum: this.calculateChecksum(chunk),
        sequence: sequence,
        totalPackets: 0,
        timestamp: Date.now()
      };

      packets.push(packet);
      offset = chunkEnd;
      sequence++;
    }

    for (let i = 0; i < packets.length; i++) {
      packets[i].totalPackets = packets.length;
    }

    return packets;
  }

  private assemblePackets(packets: DataPacket[]): string {
    let assembledData: string = '';
    for (let i = 0; i < packets.length; i++) {
      assembledData += packets[i].data;
    }
    return assembledData;
  }

  private async sendPacket(deviceId: string, packet: DataPacket): Promise<void> {
    console.log(
      `[DataTransferService] 发送数据包 ${packet.sequence + 1}/${packet.totalPackets} 到 ${deviceId}`
    );
    await this.simulateNetworkDelay(50);
  }

  private async receivePacket(deviceId: string, syncId: string): Promise<DataPacket | null> {
    await this.simulateNetworkDelay(30);
    return null;
  }

  private async verifyTransferComplete(
    deviceId: string,
    syncId: string,
    originalData: string
  ): Promise<boolean> {
    console.log(`[DataTransferService] 验证传输完整性: ${syncId}`);
    await this.simulateNetworkDelay(300);
    return true;
  }

  private calculateChecksum(data: string): string {
    let hash: number = 0;
    for (let i = 0; i < data.length; i++) {
      const char: number = data.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash;
    }
    return Math.abs(hash).toString(16).padStart(8, '0');
  }

  private verifyChecksum(data: string, packets: DataPacket[]): boolean {
    const calculatedChecksum: string = this.calculateChecksum(data);
    if (packets.length > 0) {
      const firstPacketChecksum: string = packets[0].checksum.substring(0, 4);
      const lastPacketChecksum: string = packets[packets.length - 1].checksum.substring(4);
      return calculatedChecksum.startsWith(firstPacketChecksum) ||
             calculatedChecksum.endsWith(lastPacketChecksum);
    }
    return true;
  }

  private simulateNetworkDelay(ms: number): Promise<void> {
    return new Promise<void>((resolve) => {
      setTimeout(resolve, ms);
    });
  }
}
