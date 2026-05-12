import relationalStore from '@ohos.data.relationalStore';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { common } from '@kit.AbilityKit';

const TAG = 'RdbHelper';

class RdbHelper {
  private static instance: RdbHelper;
  private rdbStore: relationalStore.RdbStore | null = null;
  private dbPath: string = 'harmony_medical.db';  // 使用现有数据库

  private constructor() {}

  public static getInstance(): RdbHelper {
    if (!RdbHelper.instance) {
      RdbHelper.instance = new RdbHelper();
    }
    return RdbHelper.instance;
  }

  public async init(context: common.UIAbilityContext): Promise<void> {
    try {
      hilog.info(0x0000, TAG, '开始初始化数据库...');
      hilog.info(0x0000, TAG, '数据库名称: %{public}s', this.dbPath);
      hilog.info(0x0000, TAG, '数据库路径: %{public}s', context.databaseDir);
      
      const config: relationalStore.StoreConfig = {
        name: this.dbPath,
        securityLevel: relationalStore.SecurityLevel.S1
      };
      this.rdbStore = await relationalStore.getRdbStore(context, config);
      
      hilog.info(0x0000, TAG, 'SQLite DB initialized successfully');
      hilog.info(0x0000, TAG, '数据库文件位置: %{public}s/%{public}s', context.databaseDir, this.dbPath);
    } catch (error) {
      hilog.error(0x0000, TAG, 'Failed to initialize database: %{public}s', JSON.stringify(error));
      throw new Error('Failed to initialize database: ' + JSON.stringify(error));
    }
  }

  public getRdb(): relationalStore.RdbStore {
    if (!this.rdbStore) {
      hilog.error(0x0000, TAG, 'Database not initialized! rdbStore is null');
      throw new Error('Database not initialized');
    }
    return this.rdbStore;
  }

  public isInitialized(): boolean {
    return this.rdbStore !== null;
  }

  public async executeSql(sql: string, bindArgs?: string[]): Promise<void> {
    try {
      hilog.info(0x0000, TAG, '执行SQL: %{public}s', sql);
      if (bindArgs && bindArgs.length > 0) {
        hilog.info(0x0000, TAG, '参数: %{public}s', JSON.stringify(bindArgs));
      }
      await this.getRdb().executeSql(sql, bindArgs);
      hilog.info(0x0000, TAG, 'SQL执行成功');
    } catch (error) {
      hilog.error(0x0000, TAG, 'Failed to execute SQL: %{public}s', sql);
      hilog.error(0x0000, TAG, 'Error: %{public}s', JSON.stringify(error));
      throw new Error('Failed to execute SQL: ' + JSON.stringify(error));
    }
  }

  public async query(sql: string, bindArgs?: string[]): Promise<relationalStore.ResultSet> {
    try {
      return await this.getRdb().querySql(sql, bindArgs);
    } catch (error) {
      hilog.error(0x0000, TAG, 'Failed to query SQL');
      throw new Error('Failed to query SQL');
    }
  }

  public async insert(table: string, values: relationalStore.ValuesBucket): Promise<number> {
    try {
      hilog.info(0x0000, TAG, 'Inserting into table: %{public}s', table);
      hilog.info(0x0000, TAG, 'Values: %{public}s', JSON.stringify(values));
      const result = await this.getRdb().insert(table, values);
      hilog.info(0x0000, TAG, 'Insert successful, row id: %{public}d', result);
      return result;
    } catch (error) {
      hilog.error(0x0000, TAG, 'Failed to insert into %{public}s', table);
      hilog.error(0x0000, TAG, 'Error: %{public}s', JSON.stringify(error));
      throw new Error('Failed to insert into ' + table + ': ' + JSON.stringify(error));
    }
  }

  public async insertOrUpdate(table: string, values: relationalStore.ValuesBucket, idColumn: string, idValue: number): Promise<number> {
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
    try {
      return await this.getRdb().query(predicates, columns || []);
    } catch (error) {
      hilog.error(0x0000, TAG, 'Failed to query with predicates');
      throw new Error('Failed to query with predicates');
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
