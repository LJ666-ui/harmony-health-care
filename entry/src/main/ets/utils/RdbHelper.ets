import relationalStore from '@ohos.data.relationalStore';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { common } from '@kit.AbilityKit';

const TAG = 'RdbHelper';

class RdbHelper {
  private static instance: RdbHelper;
  private rdbStore: relationalStore.RdbStore | null = null;
  private dbPath: string = 'local.db';

  private constructor() {}

  public static getInstance(): RdbHelper {
    if (!RdbHelper.instance) {
      RdbHelper.instance = new RdbHelper();
    }
    return RdbHelper.instance;
  }

  public async init(context: common.UIAbilityContext): Promise<void> {
    try {
      const config: relationalStore.StoreConfig = {
        name: this.dbPath,
        securityLevel: relationalStore.SecurityLevel.S1
      };
      this.rdbStore = await relationalStore.getRdbStore(context, config);
      hilog.info(0x0000, TAG, 'SQLite DB initialized successfully');
    } catch (error) {
      hilog.error(0x0000, TAG, 'Failed to initialize database');
      throw new Error('Failed to initialize database');
    }
  }

  public getRdb(): relationalStore.RdbStore {
    if (!this.rdbStore) {
      throw new Error('Database not initialized');
    }
    return this.rdbStore;
  }

  public async executeSql(sql: string, bindArgs?: Array<string | number | null>): Promise<void> {
    try {
      await this.getRdb().executeSql(sql, bindArgs);
    } catch (error) {
      hilog.error(0x0000, TAG, 'Failed to execute SQL');
      throw new Error('Failed to execute SQL');
    }
  }

  public async query(sql: string, bindArgs?: Array<string | number | null>): Promise<relationalStore.ResultSet> {
    try {
      return await this.getRdb().querySql(sql, bindArgs);
    } catch (error) {
      hilog.error(0x0000, TAG, 'Failed to query SQL');
      throw new Error('Failed to query SQL');
    }
  }

  public async insert(table: string, values: relationalStore.ValuesBucket): Promise<number> {
    try {
      return await this.getRdb().insert(table, values);
    } catch (error) {
      hilog.error(0x0000, TAG, 'Failed to insert into %{public}s', table);
      throw new Error('Failed to insert');
    }
  }

  public async update(table: string, values: relationalStore.ValuesBucket, predicates: relationalStore.RdbPredicates): Promise<number> {
    try {
      return await this.getRdb().update(values, predicates);
    } catch (error) {
      hilog.error(0x0000, TAG, 'Failed to update %{public}s', table);
      throw new Error('Failed to update');
    }
  }

  public async delete(predicates: relationalStore.RdbPredicates): Promise<number> {
    try {
      return await this.getRdb().delete(predicates);
    } catch (error) {
      hilog.error(0x0000, TAG, 'Failed to delete');
      throw new Error('Failed to delete');
    }
  }

  public beginTransaction(): void {
    try {
      this.getRdb().beginTransaction();
    } catch (error) {
      hilog.error(0x0000, TAG, 'Failed to begin transaction');
      throw new Error('Failed to begin transaction');
    }
  }

  public commit(): void {
    try {
      this.getRdb().commit();
    } catch (error) {
      hilog.error(0x0000, TAG, 'Failed to commit transaction');
      throw new Error('Failed to commit transaction');
    }
  }

  public rollback(): void {
    if (this.rdbStore !== null) {
      try {
        const cont: number = 1;
        this.rdbStore.rollback(cont);
        hilog.info(0x0000, TAG, 'Rollback completed');
      } catch (error) {
        hilog.error(0x0000, TAG, 'Failed to rollback transaction');
      }
    }
  }

  public close(): void {
    if (this.rdbStore !== null) {
      try {
        this.rdbStore.close();
        this.rdbStore = null;
        hilog.info(0x0000, TAG, 'Database closed successfully');
      } catch (error) {
        hilog.error(0x0000, TAG, 'Failed to close database');
      }
    }
  }
}

const rdbHelperInstance = RdbHelper.getInstance();
export default rdbHelperInstance;
