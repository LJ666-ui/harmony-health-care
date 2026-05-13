import rdbHelper from './RdbHelper';
import { hilog } from '@kit.PerformanceAnalysisKit';
import relationalStore from '@ohos.data.relationalStore';

const TAG = 'HospitalCacheManager';
const TABLE_NAME = 'local_hospital_cache';

export interface HospitalCacheItem {
  id: number;
  name: string;
  address: string;
  phone: string;
  level: string;
  department: string;
  description: string;
  longitude: number;
  latitude: number;
  cached_time: number;
  data_source: string;
}

interface CacheStats {
  total: number;
  byLevel: Record<string, number>;
}

class HospitalCacheManager {
  private static instance: HospitalCacheManager;
  private initialized: boolean = false;

  private constructor() {}

  public static getInstance(): HospitalCacheManager {
    if (!HospitalCacheManager.instance) {
      HospitalCacheManager.instance = new HospitalCacheManager();
    }
    return HospitalCacheManager.instance;
  }

  public isInitialized(): boolean {
    return this.initialized && rdbHelper.isInitialized();
  }

  public async init(): Promise<void> {
    if (this.initialized) {
      return;
    }

    if (!rdbHelper.isInitialized()) {
      hilog.warn(0x0000, TAG, 'RdbHelper not initialized, skip cache initialization');
      return;
    }

    try {
      const createTableSql = `
        CREATE TABLE IF NOT EXISTS ${TABLE_NAME} (
          id INTEGER PRIMARY KEY,
          name TEXT NOT NULL,
          address TEXT,
          phone TEXT,
          level TEXT,
          department TEXT,
          description TEXT,
          longitude REAL,
          latitude REAL,
          cached_time INTEGER NOT NULL,
          data_source TEXT DEFAULT 'server'
        )
      `;

      await rdbHelper.executeSql(createTableSql);

      const createIndexSql = `CREATE INDEX IF NOT EXISTS idx_hospital_level ON ${TABLE_NAME}(level)`;
      await rdbHelper.executeSql(createIndexSql);

      const createNameIndexSql = `CREATE INDEX IF NOT EXISTS idx_hospital_name ON ${TABLE_NAME}(name)`;
      await rdbHelper.executeSql(createNameIndexSql);

      this.initialized = true;
      hilog.info(0x0000, TAG, 'Hospital cache table initialized');
    } catch (error) {
      hilog.error(0x0000, TAG, 'Failed to initialize hospital cache: %{public}s', JSON.stringify(error));
    }
  }

  public async saveHospitals(hospitals: HospitalCacheItem[]): Promise<void> {
    if (!this.initialized) {
      await this.init();
    }

    if (!this.initialized) {
      hilog.warn(0x0000, TAG, 'Cache not initialized, skip saving hospitals');
      return;
    }

    try {
      rdbHelper.beginTransaction();
      
      const currentTime = Date.now();
      
      for (const hospital of hospitals) {
        const values: relationalStore.ValuesBucket = {
          id: hospital.id,
          name: hospital.name,
          address: hospital.address || '',
          phone: hospital.phone || '',
          level: hospital.level || '',
          department: hospital.department || '',
          description: hospital.description || '',
          longitude: hospital.longitude || 0,
          latitude: hospital.latitude || 0,
          cached_time: currentTime,
          data_source: 'server'
        };

        await rdbHelper.insertOrUpdate(TABLE_NAME, values, 'id', hospital.id);
      }

      rdbHelper.commit();
      hilog.info(0x0000, TAG, 'Saved %{public}d hospitals to cache', hospitals.length);
    } catch (error) {
      rdbHelper.rollback();
      hilog.error(0x0000, TAG, 'Failed to save hospitals: %{public}s', JSON.stringify(error));
    }
  }

  public async getHospitalsByLevel(level: string): Promise<HospitalCacheItem[]> {
    if (!this.initialized) {
      await this.init();
    }

    if (!this.initialized) {
      hilog.warn(0x0000, TAG, 'Cache not initialized, return empty array');
      return [];
    }

    try {
      const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
      
      if (level && level !== '全部') {
        predicates.equalTo('level', level);
      }
      
      predicates.orderByAsc('name');
      
      const resultSet = await rdbHelper.queryByPredicates(predicates);
      const hospitals: HospitalCacheItem[] = [];

      while (resultSet.goToNextRow()) {
        const hospital: HospitalCacheItem = {
          id: resultSet.getLong(resultSet.getColumnIndex('id')),
          name: resultSet.getString(resultSet.getColumnIndex('name')),
          address: resultSet.getString(resultSet.getColumnIndex('address')),
          phone: resultSet.getString(resultSet.getColumnIndex('phone')),
          level: resultSet.getString(resultSet.getColumnIndex('level')),
          department: resultSet.getString(resultSet.getColumnIndex('department')),
          description: resultSet.getString(resultSet.getColumnIndex('description')),
          longitude: resultSet.getDouble(resultSet.getColumnIndex('longitude')),
          latitude: resultSet.getDouble(resultSet.getColumnIndex('latitude')),
          cached_time: resultSet.getLong(resultSet.getColumnIndex('cached_time')),
          data_source: resultSet.getString(resultSet.getColumnIndex('data_source'))
        };
        hospitals.push(hospital);
      }

      resultSet.close();
      hilog.info(0x0000, TAG, 'Retrieved %{public}d hospitals from cache', hospitals.length);
      return hospitals;
    } catch (error) {
      hilog.error(0x0000, TAG, 'Failed to get hospitals: %{public}s', JSON.stringify(error));
      return [];
    }
  }

  public async getHospitalById(id: number): Promise<HospitalCacheItem | null> {
    if (!this.initialized) {
      await this.init();
    }

    if (!this.initialized) {
      hilog.warn(0x0000, TAG, 'Cache not initialized, return null');
      return null;
    }

    try {
      const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
      predicates.equalTo('id', id);

      const resultSet = await rdbHelper.queryByPredicates(predicates);
      
      if (resultSet.goToFirstRow()) {
        const hospital: HospitalCacheItem = {
          id: resultSet.getLong(resultSet.getColumnIndex('id')),
          name: resultSet.getString(resultSet.getColumnIndex('name')),
          address: resultSet.getString(resultSet.getColumnIndex('address')),
          phone: resultSet.getString(resultSet.getColumnIndex('phone')),
          level: resultSet.getString(resultSet.getColumnIndex('level')),
          department: resultSet.getString(resultSet.getColumnIndex('department')),
          description: resultSet.getString(resultSet.getColumnIndex('description')),
          longitude: resultSet.getDouble(resultSet.getColumnIndex('longitude')),
          latitude: resultSet.getDouble(resultSet.getColumnIndex('latitude')),
          cached_time: resultSet.getLong(resultSet.getColumnIndex('cached_time')),
          data_source: resultSet.getString(resultSet.getColumnIndex('data_source'))
        };
        resultSet.close();
        return hospital;
      }

      resultSet.close();
      return null;
    } catch (error) {
      hilog.error(0x0000, TAG, 'Failed to get hospital by id: %{public}s', JSON.stringify(error));
      return null;
    }
  }

  public async clearCache(): Promise<void> {
    if (!this.initialized) {
      await this.init();
    }

    if (!this.initialized) {
      hilog.warn(0x0000, TAG, 'Cache not initialized, skip clearing');
      return;
    }

    try {
      const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
      await rdbHelper.delete(predicates);
      hilog.info(0x0000, TAG, 'Hospital cache cleared');
    } catch (error) {
      hilog.error(0x0000, TAG, 'Failed to clear cache: %{public}s', JSON.stringify(error));
    }
  }

  public async getCacheStats(): Promise<CacheStats> {
    if (!this.initialized) {
      await this.init();
    }

    if (!this.initialized) {
      hilog.warn(0x0000, TAG, 'Cache not initialized, return empty stats');
      const emptyResult: CacheStats = { total: 0, byLevel: {} };
      return emptyResult;
    }

    try {
      const sql = `SELECT level, COUNT(*) as count FROM ${TABLE_NAME} GROUP BY level`;
      const resultSet = await rdbHelper.query(sql);
      
      const byLevel: Record<string, number> = {};
      let total = 0;

      while (resultSet.goToNextRow()) {
        const level = resultSet.getString(0);
        const count = resultSet.getLong(1);
        byLevel[level] = count;
        total += count;
      }

      resultSet.close();
      const result: CacheStats = { total: total, byLevel: byLevel };
      return result;
    } catch (error) {
      hilog.error(0x0000, TAG, 'Failed to get cache stats: %{public}s', JSON.stringify(error));
      const emptyResult: CacheStats = { total: 0, byLevel: {} };
      return emptyResult;
    }
  }

  public async isCacheValid(maxAgeMs: number = 24 * 60 * 60 * 1000): Promise<boolean> {
    if (!this.initialized) {
      await this.init();
    }

    if (!this.initialized) {
      hilog.warn(0x0000, TAG, 'Cache not initialized, return false');
      return false;
    }

    try {
      const sql = `SELECT MAX(cached_time) as latest_time FROM ${TABLE_NAME}`;
      const resultSet = await rdbHelper.query(sql);
      
      if (resultSet.goToFirstRow()) {
        const latestTime = resultSet.getLong(0);
        resultSet.close();
        
        const now = Date.now();
        return (now - latestTime) < maxAgeMs;
      }

      resultSet.close();
      return false;
    } catch (error) {
      hilog.error(0x0000, TAG, 'Failed to check cache validity: %{public}s', JSON.stringify(error));
      return false;
    }
  }
}

const hospitalCacheManager = HospitalCacheManager.getInstance();
export default hospitalCacheManager;
