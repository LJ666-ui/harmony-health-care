import relationalStore from '@ohos.data.relationalStore';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { common } from '@kit.AbilityKit';

const TAG = 'RdbHelper';

class RdbHelper {
  private static instance: RdbHelper;
  private rdbStore: relationalStore.RdbStore | null = null;
  private dbPath: string = 'local.db';
  private initialized: boolean = false;

  private constructor() {}

  public static getInstance(): RdbHelper {
    if (!RdbHelper.instance) {
      RdbHelper.instance = new RdbHelper();
    }
    return RdbHelper.instance;
  }

  public isInitialized(): boolean {
    return this.initialized;
  }

  public async init(context: common.UIAbilityContext): Promise<void> {
    try {
      const config: relationalStore.StoreConfig = {
        name: this.dbPath,
        securityLevel: relationalStore.SecurityLevel.S1
      };
      this.rdbStore = await relationalStore.getRdbStore(context, config);
      this.initialized = true;
      hilog.info(0x0000, TAG, 'SQLite DB initialized successfully');
    } catch (error) {
      this.initialized = false;
      hilog.error(0x0000, TAG, 'Failed to initialize database');
      throw new Error('Failed to initialize database');
    }
  }

  public getRdb(): relationalStore.RdbStore {
    if (!this.initialized || !this.rdbStore) {
      hilog.warn(0x0000, TAG, 'Database not initialized, skip operation');
      throw new Error('Database not initialized');
    }
    return this.rdbStore;
  }

  public async executeSql(sql: string, bindArgs?: Array<string | number | null>): Promise<void> {
    if (!this.initialized) {
      hilog.warn(0x0000, TAG, 'Database not initialized, skip operation');
      throw new Error('Database not initialized');
    }
    try {
      await this.getRdb().executeSql(sql, bindArgs);
    } catch (error) {
      hilog.error(0x0000, TAG, 'Failed to execute SQL');
      throw new Error('Failed to execute SQL');
    }
  }

  public async query(sql: string, bindArgs?: Array<string | number | null>): Promise<relationalStore.ResultSet> {
    if (!this.initialized) {
      hilog.warn(0x0000, TAG, 'Database not initialized, skip operation');
      throw new Error('Database not initialized');
    }
    try {
      return await this.getRdb().querySql(sql, bindArgs);
    } catch (error) {
      hilog.error(0x0000, TAG, 'Failed to query SQL');
      throw new Error('Failed to query SQL');
    }
  }

  public async insert(table: string, values: relationalStore.ValuesBucket): Promise<number> {
    if (!this.initialized) {
      hilog.warn(0x0000, TAG, 'Database not initialized, skip operation');
      throw new Error('Database not initialized');
    }
    try {
      return await this.getRdb().insert(table, values);
    } catch (error) {
      hilog.error(0x0000, TAG, 'Failed to insert into %{public}s', table);
      throw new Error('Failed to insert');
    }
  }

  public async insertOrUpdate(table: string, values: relationalStore.ValuesBucket, idColumn: string, idValue: number): Promise<number> {
    if (!this.initialized) {
      hilog.warn(0x0000, TAG, 'Database not initialized, skip operation');
      throw new Error('Database not initialized');
    }
    try {
      const predicates = new relationalStore.RdbPredicates(table);
      predicates.equalTo(idColumn, idValue);

      const resultSet = await this.getRdb().query(predicates, ['COUNT(*) as count']);
      if (resultSet.goToFirstRow()) {
        const count = resultSet.getLong(0);
        resultSet.close();

        if (count > 0) {
          return await this.getRdb().update(values, predicates);
        }
      } else {
        resultSet.close();
      }

      return await this.getRdb().insert(table, values);
    } catch (error) {
      hilog.error(0x0000, TAG, 'Failed to insertOrUpdate in %{public}s', table);
      throw new Error('Failed to insertOrUpdate');
    }
  }

  public async queryByPredicates(predicates: relationalStore.RdbPredicates, columns?: string[]): Promise<relationalStore.ResultSet> {
    if (!this.initialized) {
      hilog.warn(0x0000, TAG, 'Database not initialized, skip operation');
      throw new Error('Database not initialized');
    }
    try {
      return await this.getRdb().query(predicates, columns || []);
    } catch (error) {
      hilog.error(0x0000, TAG, 'Failed to query with predicates');
      throw new Error('Failed to query with predicates');
    }
  }

  public async update(table: string, values: relationalStore.ValuesBucket, predicates: relationalStore.RdbPredicates): Promise<number> {
    if (!this.initialized) {
      hilog.warn(0x0000, TAG, 'Database not initialized, skip operation');
      throw new Error('Database not initialized');
    }
    try {
      return await this.getRdb().update(values, predicates);
    } catch (error) {
      hilog.error(0x0000, TAG, 'Failed to update %{public}s', table);
      throw new Error('Failed to update');
    }
  }

  public async delete(predicates: relationalStore.RdbPredicates): Promise<number> {
    if (!this.initialized) {
      hilog.warn(0x0000, TAG, 'Database not initialized, skip operation');
      throw new Error('Database not initialized');
    }
    try {
      return await this.getRdb().delete(predicates);
    } catch (error) {
      hilog.error(0x0000, TAG, 'Failed to delete');
      throw new Error('Failed to delete');
    }
  }

  public beginTransaction(): void {
    if (!this.initialized) {
      hilog.warn(0x0000, TAG, 'Database not initialized, skip operation');
      throw new Error('Database not initialized');
    }
    try {
      this.getRdb().beginTransaction();
    } catch (error) {
      hilog.error(0x0000, TAG, 'Failed to begin transaction');
      throw new Error('Failed to begin transaction');
    }
  }

  public commit(): void {
    if (!this.initialized) {
      hilog.warn(0x0000, TAG, 'Database not initialized, skip operation');
      throw new Error('Database not initialized');
    }
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
