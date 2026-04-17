import relationalStore from '@ohos.data.relationalStore';
import RdbHelper from './RdbHelper';
import { TABLE_BROWSE_HISTORY, COLUMN_BROWSE_TYPE, COLUMN_TARGET_ID, COLUMN_TARGET_TITLE, COLUMN_SOURCE_PAGE, COLUMN_CREATE_TIME, COLUMN_BROWSE_DURATION, COLUMN_ID } from './DatabaseConstants';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'BrowseTracker';

interface BrowseRecord {
  recordId: number;
  startTime: number;
}

class BrowseTracker {
  private static instance: BrowseTracker;
  private currentRecords: Map<string, BrowseRecord> = new Map<string, BrowseRecord>();

  private constructor() {}

  public static getInstance(): BrowseTracker {
    if (!BrowseTracker.instance) {
      BrowseTracker.instance = new BrowseTracker();
    }
    return BrowseTracker.instance;
  }

  public async recordStart(pageName: string, targetType: string, targetId: number, targetTitle?: string): Promise<number> {
    try {
      const createTime = Date.now();
      const values: relationalStore.ValuesBucket = {};
      values[COLUMN_BROWSE_TYPE] = targetType;
      values[COLUMN_TARGET_ID] = targetId;
      values[COLUMN_TARGET_TITLE] = targetTitle || '';
      values[COLUMN_SOURCE_PAGE] = pageName;
      values[COLUMN_CREATE_TIME] = createTime;

      const recordId = await RdbHelper.insert(TABLE_BROWSE_HISTORY, values);

      const record: BrowseRecord = { recordId: recordId, startTime: createTime };
      this.currentRecords.set(`${pageName}_${targetId}`, record);
      return recordId;
    } catch (error) {
      hilog.error(0x0000, TAG, 'Failed to record browse start');
      throw new Error('Failed to record browse start');
    }
  }

  public async recordEnd(recordId: number): Promise<void> {
    try {
      let startTime = Date.now();
      const entries = Array.from(this.currentRecords.entries());
      for (let i = 0; i < entries.length; i++) {
        const entry = entries[i];
        if (entry[1].recordId === recordId) {
          startTime = entry[1].startTime;
          break;
        }
      }
      
      const browseDuration = Date.now() - startTime;
      
      if (browseDuration < 2000) {
        const predicates = new relationalStore.RdbPredicates(TABLE_BROWSE_HISTORY);
        predicates.equalTo(COLUMN_ID, recordId);
        await RdbHelper.delete(predicates);
      } else {
        const predicates = new relationalStore.RdbPredicates(TABLE_BROWSE_HISTORY);
        predicates.equalTo(COLUMN_ID, recordId);
        const updateValues: relationalStore.ValuesBucket = {};
        updateValues[COLUMN_BROWSE_DURATION] = browseDuration;
        await RdbHelper.update(TABLE_BROWSE_HISTORY, updateValues, predicates);
      }

      const keysToDelete: string[] = [];
      const allEntries = Array.from(this.currentRecords.entries());
      for (let i = 0; i < allEntries.length; i++) {
        const entry = allEntries[i];
        if (entry[1].recordId === recordId) {
          keysToDelete.push(entry[0]);
          break;
        }
      }
      
      for (let j = 0; j < keysToDelete.length; j++) {
        this.currentRecords.delete(keysToDelete[j]);
      }
    } catch (error) {
      hilog.error(0x0000, TAG, 'Failed to record browse end');
    }
  }

  public async trackPageView(pageName: string): Promise<number> {
    return await this.recordStart(pageName, 'PAGE', Date.now(), pageName);
  }

  public async trackContentView(contentType: string, contentId: number, contentTitle?: string): Promise<number> {
    return await this.recordStart('content_view', contentType, contentId, contentTitle);
  }

  public async deleteOldRecords(): Promise<void> {
    try {
      const thirtyDaysAgo = Date.now() - (30 * 24 * 60 * 60 * 1000);
      const predicates = new relationalStore.RdbPredicates(TABLE_BROWSE_HISTORY);
      predicates.lessThan(COLUMN_CREATE_TIME, thirtyDaysAgo);
      await RdbHelper.delete(predicates);
      hilog.info(0x0000, TAG, 'Old browse history records deleted successfully');
    } catch (error) {
      hilog.error(0x0000, TAG, 'Failed to delete old records');
    }
  }

  public getCurrentRecordId(pageName: string, targetId: number): number | undefined {
    const record = this.currentRecords.get(`${pageName}_${targetId}`);
    if (record) {
      return record.recordId;
    }
    return undefined;
  }
}

export default BrowseTracker.getInstance();
