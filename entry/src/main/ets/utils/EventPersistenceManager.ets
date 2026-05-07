import relationalStore from '@ohos.data.relationalStore';
import RdbHelper from './RdbHelper';
import { hilog } from '@kit.PerformanceAnalysisKit';
import {
  TABLE_OFFLINE_HEALTH_RECORD, TABLE_SEARCH_HISTORY, TABLE_COLLECTION_CACHE,
  TABLE_USER_CACHE, TABLE_BROWSE_HISTORY,
  COLUMN_ID, COLUMN_RECORD_TYPE, COLUMN_VALUE, COLUMN_UNIT, COLUMN_RECORD_TIME,
  COLUMN_NOTES, COLUMN_SYNCED, COLUMN_CREATE_TIME, COLUMN_RETRY_COUNT,
  COLUMN_KEYWORD, COLUMN_SEARCH_COUNT, COLUMN_LAST_SEARCH_TIME, COLUMN_SEARCH_SCOPE,
  COLUMN_COLLECT_TYPE, COLUMN_TARGET_ID, COLUMN_TARGET_TITLE, COLUMN_TARGET_IMAGE,
  COLUMN_COLLECT_TIME, COLUMN_NOTE, COLUMN_IS_SYNCED,
  COLUMN_USER_ID, COLUMN_TOKEN, COLUMN_NICKNAME, COLUMN_AVATAR_URL, COLUMN_ROLE_TYPE,
  COLUMN_EXPIRE_TIME, COLUMN_BROWSE_TYPE, COLUMN_TARGET_TITLE as COL_TARGET_TITLE,
  COLUMN_SOURCE_PAGE, COLUMN_BROWSE_DURATION, COLUMN_LAST_SYNC_TIME
} from './DatabaseConstants';
import { OfflineHealthRecord, SearchHistoryItem, CollectionCacheItem, LocalUserCache } from '../models/LocalModels';

const TAG = 'EventPersistenceManager';

interface HealthRecordInput {
  recordType: string;
  value: number;
  unit: string;
  notes?: string;
}

interface BrowseHistoryItem {
  id: number;
  browse_type: string;
  target_id: number;
  target_title: string;
  browse_duration: number;
  source_page: string;
  create_time: number;
}

class EventPersistenceManager {
  private static instance: EventPersistenceManager;

  private constructor() {}

  public static getInstance(): EventPersistenceManager {
    if (!EventPersistenceManager.instance) {
      EventPersistenceManager.instance = new EventPersistenceManager();
    }
    return EventPersistenceManager.instance;
  }

  // ==================== 健康记录（offline_health_record）====================

  async saveHealthRecord(input: HealthRecordInput): Promise<number> {
    try {
      const values: relationalStore.ValuesBucket = {};
      values[COLUMN_RECORD_TYPE] = input.recordType;
      values[COLUMN_VALUE] = input.value;
      values[COLUMN_UNIT] = input.unit || '';
      values[COLUMN_RECORD_TIME] = Date.now();
      values[COLUMN_NOTES] = input.notes || '';
      values[COLUMN_SYNCED] = 0;
      values[COLUMN_CREATE_TIME] = Date.now();
      values[COLUMN_RETRY_COUNT] = 0;

      const rowId = await RdbHelper.insert(TABLE_OFFLINE_HEALTH_RECORD, values);
      hilog.info(0x0000, TAG, '健康记录已保存到本地, rowId=%{public}d', rowId);
      return rowId;
    } catch (error) {
      hilog.error(0x0000, TAG, '保存健康记录失败');
      throw new Error('保存健康记录失败');
    }
  }

  async saveBloodPressure(systolic: number, diastolic: number, notes?: string): Promise<number> {
    return await this.saveHealthRecord({
      recordType: 'blood_pressure',
      value: systolic,
      unit: `${systolic}/${diastolic}`,
      notes: notes
    });
  }

  async saveBloodSugar(value: number, notes?: string): Promise<number> {
    return await this.saveHealthRecord({
      recordType: 'blood_sugar',
      value: value,
      unit: 'mmol/L',
      notes: notes
    });
  }

  async saveHeartRate(value: number, notes?: string): Promise<number> {
    return await this.saveHealthRecord({
      recordType: 'heart_rate',
      value: value,
      unit: 'bpm',
      notes: notes
    });
  }

  async saveWeight(value: number, notes?: string): Promise<number> {
    return await this.saveHealthRecord({
      recordType: 'weight',
      value: value,
      unit: 'kg',
      notes: notes
    });
  }

  async getOfflineHealthRecords(limit: number = 50): Promise<OfflineHealthRecord[]> {
    try {
      const resultSet = await RdbHelper.query(
        'SELECT * FROM ' + TABLE_OFFLINE_HEALTH_RECORD + ' ORDER BY ' + COLUMN_CREATE_TIME + ' DESC LIMIT ?',
        [limit]
      );
      const records: OfflineHealthRecord[] = [];
      while (resultSet.goToNextRow()) {
        records.push({
          id: resultSet.getLong(resultSet.getColumnIndex(COLUMN_ID)),
          record_type: resultSet.getString(resultSet.getColumnIndex(COLUMN_RECORD_TYPE)),
          value: resultSet.getDouble(resultSet.getColumnIndex(COLUMN_VALUE)),
          unit: resultSet.getString(resultSet.getColumnIndex(COLUMN_UNIT)),
          record_time: resultSet.getLong(resultSet.getColumnIndex(COLUMN_RECORD_TIME)),
          notes: resultSet.getString(resultSet.getColumnIndex(COLUMN_NOTES)),
          synced: resultSet.getLong(resultSet.getColumnIndex(COLUMN_SYNCED)),
          create_time: resultSet.getLong(resultSet.getColumnIndex(COLUMN_CREATE_TIME)),
          retry_count: resultSet.getLong(resultSet.getColumnIndex(COLUMN_RETRY_COUNT))
        });
      }
      resultSet.close();
      return records;
    } catch (error) {
      hilog.error(0x0000, TAG, '查询健康记录失败');
      return [];
    }
  }

  async markHealthRecordSynced(recordId: number): Promise<void> {
    try {
      const predicates = new relationalStore.RdbPredicates(TABLE_OFFLINE_HEALTH_RECORD);
      predicates.equalTo(COLUMN_ID, recordId);
      const values: relationalStore.ValuesBucket = {};
      values[COLUMN_SYNCED] = 1;
      await RdbHelper.update(TABLE_OFFLINE_HEALTH_RECORD, values, predicates);
    } catch (error) {
      hilog.error(0x0000, TAG, '标记健康记录同步状态失败');
    }
  }

  // ==================== 搜索历史（local_search_history）====================

  async addSearchHistory(keyword: string, scope?: string): Promise<void> {
    if (!keyword.trim()) return;

    try {
      const normalizedKeyword = keyword.trim();
      const searchScope = scope || 'GLOBAL';

      const resultSet = await RdbHelper.query(
        'SELECT * FROM ' + TABLE_SEARCH_HISTORY + ' WHERE ' + COLUMN_KEYWORD + ' = ? AND ' + COLUMN_SEARCH_SCOPE + ' = ?',
        [normalizedKeyword, searchScope]
      );

      let found = false;
      if (resultSet.goToFirstRow()) {
        found = true;
        const existingId = resultSet.getLong(resultSet.getColumnIndex(COLUMN_ID));
        const existingCount = resultSet.getLong(resultSet.getColumnIndex(COLUMN_SEARCH_COUNT));
        resultSet.close();

        const predicates = new relationalStore.RdbPredicates(TABLE_SEARCH_HISTORY);
        predicates.equalTo(COLUMN_ID, existingId);
        const values: relationalStore.ValuesBucket = {};
        values[COLUMN_SEARCH_COUNT] = existingCount + 1;
        values[COLUMN_LAST_SEARCH_TIME] = Date.now();
        await RdbHelper.update(TABLE_SEARCH_HISTORY, values, predicates);
      } else {
        resultSet.close();
        const values: relationalStore.ValuesBucket = {};
        values[COLUMN_KEYWORD] = normalizedKeyword;
        values[COLUMN_SEARCH_COUNT] = 1;
        values[COLUMN_LAST_SEARCH_TIME] = Date.now();
        values[COLUMN_SEARCH_SCOPE] = searchScope;
        await RdbHelper.insert(TABLE_SEARCH_HISTORY, values);
      }

      hilog.info(0x0000, TAG, '搜索历史已保存: %{public}s', normalizedKeyword);
    } catch (error) {
      hilog.error(0x0000, TAG, '保存搜索历史失败');
    }
  }

  async getSearchHistory(scope?: string, limit: number = 20): Promise<SearchHistoryItem[]> {
    try {
      let sql = 'SELECT * FROM ' + TABLE_SEARCH_HISTORY;
      const bindArgs: string[] = [];

      if (scope) {
        sql += ' WHERE ' + COLUMN_SEARCH_SCOPE + ' = ?';
        bindArgs.push(scope);
      }

      sql += ' ORDER BY ' + COLUMN_LAST_SEARCH_TIME + ' DESC LIMIT ?';
      bindArgs.push(String(limit));

      const resultSet = await RdbHelper.query(sql, bindArgs);
      const items: SearchHistoryItem[] = [];
      while (resultSet.goToNextRow()) {
        items.push({
          id: resultSet.getLong(resultSet.getColumnIndex(COLUMN_ID)),
          keyword: resultSet.getString(resultSet.getColumnIndex(COLUMN_KEYWORD)),
          search_count: resultSet.getLong(resultSet.getColumnIndex(COLUMN_SEARCH_COUNT)),
          last_search_time: resultSet.getLong(resultSet.getColumnIndex(COLUMN_LAST_SEARCH_TIME)),
          search_scope: resultSet.getString(resultSet.getColumnIndex(COLUMN_SEARCH_SCOPE))
        });
      }
      resultSet.close();
      return items;
    } catch (error) {
      hilog.error(0x0000, TAG, '查询搜索历史失败');
      return [];
    }
  }

  async clearSearchHistory(scope?: string): Promise<void> {
    try {
      if (scope) {
        const predicates = new relationalStore.RdbPredicates(TABLE_SEARCH_HISTORY);
        predicates.equalTo(COLUMN_SEARCH_SCOPE, scope);
        await RdbHelper.delete(predicates);
      } else {
        await RdbHelper.executeSql('DELETE FROM ' + TABLE_SEARCH_HISTORY);
      }
      hilog.info(0x0000, TAG, '搜索历史已清空');
    } catch (error) {
      hilog.error(0x0000, TAG, '清空搜索历史失败');
    }
  }

  async deleteSearchHistoryItem(keyword: string): Promise<void> {
    try {
      const predicates = new relationalStore.RdbPredicates(TABLE_SEARCH_HISTORY);
      predicates.equalTo(COLUMN_KEYWORD, keyword.trim());
      await RdbHelper.delete(predicates);
    } catch (error) {
      hilog.error(0x0000, TAG, '删除搜索历史条目失败');
    }
  }

  // ==================== 收藏缓存（local_collection_cache）====================

  async addCollect(collectType: string, targetId: number, targetTitle: string, targetImage?: string, note?: string): Promise<number> {
    try {
      const values: relationalStore.ValuesBucket = {};
      values[COLUMN_COLLECT_TYPE] = collectType;
      values[COLUMN_TARGET_ID] = targetId;
      values[COLUMN_TARGET_TITLE] = targetTitle;
      values[COLUMN_TARGET_IMAGE] = targetImage || '';
      values[COLUMN_COLLECT_TIME] = Date.now();
      values[COLUMN_NOTE] = note || '';
      values[COLUMN_IS_SYNCED] = 0;

      const rowId = await RdbHelper.insert(TABLE_COLLECTION_CACHE, values);
      hilog.info(0x0000, TAG, '收藏已保存到本地, rowId=%{public}d', rowId);
      return rowId;
    } catch (error) {
      hilog.error(0x0000, TAG, '保存收藏失败');
      throw new Error('保存收藏失败');
    }
  }

  async removeCollect(collectType: string, targetId: number): Promise<boolean> {
    try {
      const predicates = new relationalStore.RdbPredicates(TABLE_COLLECTION_CACHE);
      predicates.equalTo(COLUMN_COLLECT_TYPE, collectType);
      predicates.equalTo(COLUMN_TARGET_ID, targetId);
      const deletedCount = await RdbHelper.delete(predicates);
      hilog.info(0x0000, TAG, '本地收藏已删除, count=%{public}d', deletedCount);
      return deletedCount > 0;
    } catch (error) {
      hilog.error(0x0000, TAG, '删除收藏失败');
      return false;
    }
  }

  async isCollected(collectType: string, targetId: number): Promise<boolean> {
    try {
      const predicates = new relationalStore.RdbPredicates(TABLE_COLLECTION_CACHE);
      predicates.equalTo(COLUMN_COLLECT_TYPE, collectType);
      predicates.equalTo(COLUMN_TARGET_ID, targetId);
      const resultSet = await RdbHelper.queryByPredicates(predicates, ['COUNT(*) as cnt']);
      let isCollected = false;
      if (resultSet.goToFirstRow()) {
        isCollected = resultSet.getLong(0) > 0;
      }
      resultSet.close();
      return isCollected;
    } catch (error) {
      hilog.error(0x0000, TAG, '查询收藏状态失败');
      return false;
    }
  }

  async getCollectionList(collectType?: string, limit: number = 100): Promise<CollectionCacheItem[]> {
    try {
      let sql = 'SELECT * FROM ' + TABLE_COLLECTION_CACHE;
      const bindArgs: string[] = [];

      if (collectType) {
        sql += ' WHERE ' + COLUMN_COLLECT_TYPE + ' = ?';
        bindArgs.push(collectType);
      }

      sql += ' ORDER BY ' + COLUMN_COLLECT_TIME + ' DESC LIMIT ?';
      bindArgs.push(String(limit));

      const resultSet = await RdbHelper.query(sql, bindArgs);
      const items: CollectionCacheItem[] = [];
      while (resultSet.goToNextRow()) {
        items.push({
          id: resultSet.getLong(resultSet.getColumnIndex(COLUMN_ID)),
          collect_type: resultSet.getString(resultSet.getColumnIndex(COLUMN_COLLECT_TYPE)),
          target_id: resultSet.getLong(resultSet.getColumnIndex(COLUMN_TARGET_ID)),
          target_title: resultSet.getString(resultSet.getColumnIndex(COLUMN_TARGET_TITLE)),
          target_image: resultSet.getString(resultSet.getColumnIndex(COLUMN_TARGET_IMAGE)),
          collect_time: resultSet.getLong(resultSet.getColumnIndex(COLUMN_COLLECT_TIME)),
          note: resultSet.getString(resultSet.getColumnIndex(COLUMN_NOTE)),
          is_synced: resultSet.getLong(resultSet.getColumnIndex(COLUMN_IS_SYNCED))
        });
      }
      resultSet.close();
      return items;
    } catch (error) {
      hilog.error(0x0000, TAG, '查询收藏列表失败');
      return [];
    }
  }

  // ==================== 用户缓存（local_user_cache）====================

  async cacheUserInfo(userId: number, token: string, nickname?: string, avatarUrl?: string, roleType?: string, expireTime?: number): Promise<void> {
    try {
      const predicates = new relationalStore.RdbPredicates(TABLE_USER_CACHE);
      predicates.equalTo(COLUMN_USER_ID, userId);
      const existingResultSet = await RdbHelper.queryByPredicates(predicates, [COLUMN_ID]);

      const now = Date.now();
      const values: relationalStore.ValuesBucket = {};
      values[COLUMN_USER_ID] = userId;
      values[COLUMN_TOKEN] = token;
      values[COLUMN_NICKNAME] = nickname || '';
      values[COLUMN_AVATAR_URL] = avatarUrl || '';
      values[COLUMN_ROLE_TYPE] = roleType || '';
      values[COLUMN_LAST_SYNC_TIME] = now;
      values[COLUMN_EXPIRE_TIME] = expireTime || (now + 7 * 24 * 60 * 60 * 1000);

      if (existingResultSet.goToFirstRow()) {
        const existingId = existingResultSet.getLong(0);
        existingResultSet.close();
        const updatePredicates = new relationalStore.RdbPredicates(TABLE_USER_CACHE);
        updatePredicates.equalTo(COLUMN_ID, existingId);
        await RdbHelper.update(TABLE_USER_CACHE, values, updatePredicates);
      } else {
        existingResultSet.close();
        await RdbHelper.insert(TABLE_USER_CACHE, values);
      }

      hilog.info(0x0000, TAG, '用户信息已缓存, userId=%{public}d', userId);
    } catch (error) {
      hilog.error(0x0000, TAG, '缓存用户信息失败');
    }
  }

  async getCachedUser(): Promise<LocalUserCache | null> {
    try {
      const resultSet = await RdbHelper.query('SELECT * FROM ' + TABLE_USER_CACHE + ' ORDER BY ' + COLUMN_ID + ' DESC LIMIT 1');
      let user: LocalUserCache | null = null;
      if (resultSet.goToFirstRow()) {
        user = {
          id: resultSet.getLong(resultSet.getColumnIndex(COLUMN_ID)),
          user_id: resultSet.getLong(resultSet.getColumnIndex(COLUMN_USER_ID)),
          token: resultSet.getString(resultSet.getColumnIndex(COLUMN_TOKEN)),
          nickname: resultSet.getString(resultSet.getColumnIndex(COLUMN_NICKNAME)),
          avatar_url: resultSet.getString(resultSet.getColumnIndex(COLUMN_AVATAR_URL)),
          role_type: resultSet.getString(resultSet.getColumnIndex(COLUMN_ROLE_TYPE)),
          last_sync_time: resultSet.getLong(resultSet.getColumnIndex(COLUMN_LAST_SYNC_TIME)),
          expire_time: resultSet.getLong(resultSet.getColumnIndex(COLUMN_EXPIRE_TIME))
        };
      }
      resultSet.close();
      return user;
    } catch (error) {
      hilog.error(0x0000, TAG, '获取缓存的用户信息失败');
      return null;
    }
  }

  async clearUserCache(): Promise<void> {
    try {
      await RdbHelper.executeSql('DELETE FROM ' + TABLE_USER_CACHE);
      hilog.info(0x0000, TAG, '用户缓存已清除');
    } catch (error) {
      hilog.error(0x0000, TAG, '清除用户缓存失败');
    }
  }

  // ==================== 浏览记录辅助 =====================

  async recordBrowse(browseType: string, targetId: number, targetTitle: string, sourcePage: string): Promise<number> {
    try {
      const values: relationalStore.ValuesBucket = {};
      values[COLUMN_BROWSE_TYPE] = browseType;
      values[COLUMN_TARGET_ID] = targetId;
      values[COL_TARGET_TITLE] = targetTitle;
      values[COLUMN_SOURCE_PAGE] = sourcePage;
      values[COLUMN_CREATE_TIME] = Date.now();
      values[COLUMN_BROWSE_DURATION] = 0;

      return await RdbHelper.insert(TABLE_BROWSE_HISTORY, values);
    } catch (error) {
      hilog.error(0x0000, TAG, '记录浏览事件失败');
      return -1;
    }
  }

  async getRecentBrowseHistory(limit: number = 30): Promise<BrowseHistoryItem[]> {
    try {
      const sql = 'SELECT * FROM ' + TABLE_BROWSE_HISTORY +
        ' WHERE ' + COLUMN_BROWSE_DURATION + ' >= 2000' +
        ' ORDER BY ' + COLUMN_CREATE_TIME + ' DESC LIMIT ?';
      const resultSet = await RdbHelper.query(sql, [limit]);
      const items: BrowseHistoryItem[] = [];
      while (resultSet.goToNextRow()) {
        const item: BrowseHistoryItem = {
          id: resultSet.getLong(resultSet.getColumnIndex(COLUMN_ID)),
          browse_type: resultSet.getString(resultSet.getColumnIndex(COLUMN_BROWSE_TYPE)),
          target_id: resultSet.getLong(resultSet.getColumnIndex(COLUMN_TARGET_ID)),
          target_title: resultSet.getString(resultSet.getColumnIndex(COL_TARGET_TITLE)),
          browse_duration: resultSet.getLong(resultSet.getColumnIndex(COLUMN_BROWSE_DURATION)),
          source_page: resultSet.getString(resultSet.getColumnIndex(COLUMN_SOURCE_PAGE)),
          create_time: resultSet.getLong(resultSet.getColumnIndex(COLUMN_CREATE_TIME))
        };
        items.push(item);
      }
      resultSet.close();
      return items;
    } catch (error) {
      hilog.error(0x0000, TAG, '获取浏览历史失败');
      return [];
    }
  }
}

export default EventPersistenceManager.getInstance();
