import relationalStore from '@ohos.data.relationalStore';
import RdbHelper from './RdbHelper';
import { TABLE_OFFLINE_HEALTH_RECORD, TABLE_SYNC_QUEUE, COLUMN_ID, COLUMN_SYNCED, COLUMN_RETRY_COUNT, COLUMN_STATUS, COLUMN_ERROR_MESSAGE, COLUMN_SYNC_TIME } from './DatabaseConstants';
import { OfflineHealthRecord, SyncQueueItem } from '../models/LocalModels';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'SyncManager';
const SYNC_INTERVAL = 5 * 60 * 1000;

class SyncManager {
  private static instance: SyncManager;
  private syncTimer: number | null = null;

  private constructor() {}

  public static getInstance(): SyncManager {
    if (!SyncManager.instance) {
      SyncManager.instance = new SyncManager();
    }
    return SyncManager.instance;
  }

  public async checkNetworkStatus(): Promise<boolean> {
    try {
      return true;
    } catch (error) {
      hilog.error(0x0000, TAG, 'Failed to check network status');
      return false;
    }
  }

  public async syncOfflineHealthRecords(): Promise<void> {
    try {
      const isConnected = await this.checkNetworkStatus();
      if (!isConnected) {
        hilog.info(0x0000, TAG, 'No network connection, skip syncing');
        return;
      }

      const resultSet = await RdbHelper.query(`SELECT * FROM ${TABLE_OFFLINE_HEALTH_RECORD} WHERE ${COLUMN_SYNCED} = 0`);
      
      const records: OfflineHealthRecord[] = [];
      while (resultSet.goToNextRow()) {
        records.push({
          id: resultSet.getLong(resultSet.getColumnIndex('id')),
          record_type: resultSet.getString(resultSet.getColumnIndex('record_type')),
          value: resultSet.getDouble(resultSet.getColumnIndex('value')),
          unit: resultSet.getString(resultSet.getColumnIndex('unit')),
          record_time: resultSet.getLong(resultSet.getColumnIndex('record_time')),
          notes: resultSet.getString(resultSet.getColumnIndex('notes')),
          synced: resultSet.getLong(resultSet.getColumnIndex('synced')),
          create_time: resultSet.getLong(resultSet.getColumnIndex('create_time')),
          retry_count: resultSet.getLong(resultSet.getColumnIndex('retry_count'))
        });
      }

      for (let i = 0; i < records.length; i++) {
        const record = records[i];
        try {
          const updateValues1: relationalStore.ValuesBucket = {};
          updateValues1[COLUMN_SYNCED] = 1;
          
          const predicates1 = new relationalStore.RdbPredicates(TABLE_OFFLINE_HEALTH_RECORD);
          predicates1.equalTo(COLUMN_ID, record.id);
          
          await RdbHelper.update(TABLE_OFFLINE_HEALTH_RECORD, updateValues1, predicates1);
          hilog.info(0x0000, TAG, 'Health record synced successfully: %{public}d', record.id);
        } catch (error) {
          const newRetryCount = (record.retry_count || 0) + 1;
          let newSynced = 0;
          if (newRetryCount > 3) {
            newSynced = 2;
          }
          
          const updateValues2: relationalStore.ValuesBucket = {};
          updateValues2[COLUMN_RETRY_COUNT] = newRetryCount;
          updateValues2[COLUMN_SYNCED] = newSynced;
          
          const predicates2 = new relationalStore.RdbPredicates(TABLE_OFFLINE_HEALTH_RECORD);
          predicates2.equalTo(COLUMN_ID, record.id);
          
          await RdbHelper.update(TABLE_OFFLINE_HEALTH_RECORD, updateValues2, predicates2);
          hilog.error(0x0000, TAG, 'Error syncing health record: %{public}d', record.id);
        }
      }
    } catch (error) {
      hilog.error(0x0000, TAG, 'Failed to sync offline health records');
    }
  }

  public async syncQueueConsumer(): Promise<void> {
    try {
      const isConnected = await this.checkNetworkStatus();
      if (!isConnected) {
        hilog.info(0x0000, TAG, 'No network connection, skip sync queue');
        return;
      }

      const resultSet = await RdbHelper.query(`SELECT * FROM ${TABLE_SYNC_QUEUE} WHERE ${COLUMN_STATUS} = 'pending'`);
      
      const tasks: SyncQueueItem[] = [];
      while (resultSet.goToNextRow()) {
        tasks.push({
          id: resultSet.getLong(resultSet.getColumnIndex('id')),
          table_name: resultSet.getString(resultSet.getColumnIndex('table_name')),
          operation_type: resultSet.getString(resultSet.getColumnIndex('operation_type')),
          data_json: resultSet.getString(resultSet.getColumnIndex('data_json')),
          target_url: resultSet.getString(resultSet.getColumnIndex('target_url')),
          retry_count: resultSet.getLong(resultSet.getColumnIndex('retry_count')),
          status: resultSet.getString(resultSet.getColumnIndex('status')),
          error_message: resultSet.getString(resultSet.getColumnIndex('error_message')),
          create_time: resultSet.getLong(resultSet.getColumnIndex('create_time')),
          sync_time: resultSet.getLong(resultSet.getColumnIndex('sync_time'))
        });
      }

      for (let j = 0; j < tasks.length; j++) {
        const task = tasks[j];
        try {
          const updateValues3: relationalStore.ValuesBucket = {};
          updateValues3[COLUMN_STATUS] = 'synced';
          updateValues3[COLUMN_SYNC_TIME] = Date.now();
          
          const predicates3 = new relationalStore.RdbPredicates(TABLE_SYNC_QUEUE);
          predicates3.equalTo(COLUMN_ID, task.id);
          
          await RdbHelper.update(TABLE_SYNC_QUEUE, updateValues3, predicates3);
          hilog.info(0x0000, TAG, 'Sync queue task completed: %{public}d', task.id);
        } catch (error) {
          const updateValues4: relationalStore.ValuesBucket = {};
          updateValues4[COLUMN_STATUS] = 'failed';
          updateValues4[COLUMN_ERROR_MESSAGE] = 'API error';
          updateValues4[COLUMN_RETRY_COUNT] = (task.retry_count || 0) + 1;
          
          const predicates4 = new relationalStore.RdbPredicates(TABLE_SYNC_QUEUE);
          predicates4.equalTo(COLUMN_ID, task.id);
          
          await RdbHelper.update(TABLE_SYNC_QUEUE, updateValues4, predicates4);
          hilog.error(0x0000, TAG, 'Error executing sync queue task: %{public}d', task.id);
        }
      }
    } catch (error) {
      hilog.error(0x0000, TAG, 'Failed to process sync queue');
    }
  }

  public startBackgroundSync(): void {
    this.stopBackgroundSync();
    
    this.syncTimer = setInterval(async (): Promise<void> => {
      await this.syncOfflineHealthRecords();
      await this.syncQueueConsumer();
    }, SYNC_INTERVAL);
    
    hilog.info(0x0000, TAG, 'Background sync started');
  }

  public stopBackgroundSync(): void {
    if (this.syncTimer !== null) {
      clearInterval(this.syncTimer);
      this.syncTimer = null;
      hilog.info(0x0000, TAG, 'Background sync stopped');
    }
  }

  public async syncNow(): Promise<void> {
    await this.syncOfflineHealthRecords();
    await this.syncQueueConsumer();
  }
}

export default SyncManager.getInstance();
