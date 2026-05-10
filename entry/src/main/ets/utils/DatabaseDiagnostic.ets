import { hilog } from '@kit.PerformanceAnalysisKit';
import RdbHelper from './RdbHelper';
import { TABLE_ARTICLE_DRAFT } from './DatabaseConstants';

class DatabaseDiagnostic {
  private static TAG = 'DatabaseDiagnostic';

  public static async checkDatabase(): Promise<void> {
    hilog.info(0x0000, DatabaseDiagnostic.TAG, '==================== 数据库诊断开始 ====================');
    
    // 1. 检查数据库是否初始化
    const isInit = RdbHelper.isInitialized();
    hilog.info(0x0000, DatabaseDiagnostic.TAG, '数据库初始化状态: %{public}s', isInit ? '已初始化' : '未初始化');
    
    if (!isInit) {
      hilog.error(0x0000, DatabaseDiagnostic.TAG, '数据库未初始化！');
      return;
    }
    
    // 2. 检查表是否存在
    try {
      const tables = await DatabaseDiagnostic.getAllTables();
      hilog.info(0x0000, DatabaseDiagnostic.TAG, '数据库中的表: %{public}s', tables.join(', '));
      
      const hasDraftTable = tables.includes(TABLE_ARTICLE_DRAFT);
      hilog.info(0x0000, DatabaseDiagnostic.TAG, '草稿表是否存在: %{public}s', hasDraftTable ? '是' : '否');
      
      if (!hasDraftTable) {
        hilog.error(0x0000, DatabaseDiagnostic.TAG, '草稿表不存在！');
        return;
      }
      
      // 3. 检查表结构
      const tableInfo = await DatabaseDiagnostic.getTableInfo(TABLE_ARTICLE_DRAFT);
      hilog.info(0x0000, DatabaseDiagnostic.TAG, '草稿表结构: %{public}s', JSON.stringify(tableInfo));
      
      // 4. 尝试查询数据
      const count = await DatabaseDiagnostic.getTableCount(TABLE_ARTICLE_DRAFT);
      hilog.info(0x0000, DatabaseDiagnostic.TAG, '草稿表记录数: %{public}d', count);
      
      hilog.info(0x0000, DatabaseDiagnostic.TAG, '==================== 数据库诊断完成 ====================');
    } catch (error) {
      hilog.error(0x0000, DatabaseDiagnostic.TAG, '数据库诊断失败: %{public}s', JSON.stringify(error));
    }
  }

  private static async getAllTables(): Promise<string[]> {
    const sql = "SELECT name FROM sqlite_master WHERE type='table'";
    const result = await RdbHelper.query(sql);
    const tables: string[] = [];
    
    while (result.goToNextRow()) {
      tables.push(result.getString(0));
    }
    result.close();
    
    return tables;
  }

  private static async getTableInfo(tableName: string): Promise<string[]> {
    const sql = `PRAGMA table_info(${tableName})`;
    const result = await RdbHelper.query(sql);
    const columns: string[] = [];
    
    while (result.goToNextRow()) {
      const name = result.getString(1);
      const type = result.getString(2);
      columns.push(`${name}(${type})`);
    }
    result.close();
    
    return columns;
  }

  private static async getTableCount(tableName: string): Promise<number> {
    const sql = `SELECT COUNT(*) FROM ${tableName}`;
    const result = await RdbHelper.query(sql);
    
    if (result.goToFirstRow()) {
      const count = result.getLong(0);
      result.close();
      return count;
    }
    result.close();
    return 0;
  }
}

export default DatabaseDiagnostic;
