import { hilog } from '@kit.PerformanceAnalysisKit';
import RdbHelper from './RdbHelper';
import relationalStore from '@ohos.data.relationalStore';
import { TABLE_ARTICLE_DRAFT } from './DatabaseConstants';

class DatabaseDebug {
  private static TAG = 'DatabaseDebug';

  public static async showDatabaseInfo(): Promise<void> {
    hilog.info(0x0000, DatabaseDebug.TAG, '========== 数据库调试信息 ==========');
    
    try {
      // 1. 检查数据库是否初始化
      const isInit = RdbHelper.isInitialized();
      hilog.info(0x0000, DatabaseDebug.TAG, '数据库初始化状态: %{public}s', isInit ? '已初始化' : '未初始化');
      
      if (!isInit) {
        hilog.error(0x0000, DatabaseDebug.TAG, '❌ 数据库未初始化！');
        return;
      }

      // 2. 获取数据库实例
      const rdbStore = RdbHelper.getRdb();
      
      // 3. 查询所有表
      const tablesSql = "SELECT name FROM sqlite_master WHERE type='table'";
      const tablesResult = await rdbStore.querySql(tablesSql);
      
      hilog.info(0x0000, DatabaseDebug.TAG, '数据库中的表:');
      const tables: string[] = [];
      while (tablesResult.goToNextRow()) {
        const tableName = tablesResult.getString(0);
        tables.push(tableName);
        hilog.info(0x0000, DatabaseDebug.TAG, '  - %{public}s', tableName);
      }
      tablesResult.close();

      // 4. 检查草稿表
      if (tables.includes(TABLE_ARTICLE_DRAFT)) {
        hilog.info(0x0000, DatabaseDebug.TAG, '✅ 草稿表存在');
        
        // 查询草稿数量
        const countSql = `SELECT COUNT(*) as count FROM ${TABLE_ARTICLE_DRAFT}`;
        const countResult = await rdbStore.querySql(countSql);
        
        if (countResult.goToFirstRow()) {
          const count = countResult.getLong(0);
          hilog.info(0x0000, DatabaseDebug.TAG, '草稿表记录数: %{public}d', count);
        }
        countResult.close();
        
        // 查询所有草稿
        const draftsSql = `SELECT * FROM ${TABLE_ARTICLE_DRAFT} ORDER BY update_time DESC LIMIT 5`;
        const draftsResult = await rdbStore.querySql(draftsSql);
        
        hilog.info(0x0000, DatabaseDebug.TAG, '最新的草稿:');
        while (draftsResult.goToNextRow()) {
          const id = draftsResult.getLong(0);
          const draftId = draftsResult.getString(1);
          const title = draftsResult.getString(2);
          const updateTime = draftsResult.getLong(6);
          hilog.info(0x0000, DatabaseDebug.TAG, '  [id=%{public}d] %{public}s - %{public}s (time=%{public}d)', 
            id, draftId, title || '(无标题)', updateTime);
        }
        draftsResult.close();
      } else {
        hilog.error(0x0000, DatabaseDebug.TAG, '❌ 草稿表不存在！');
      }

      hilog.info(0x0000, DatabaseDebug.TAG, '========== 调试信息结束 ==========');

    } catch (error) {
      hilog.error(0x0000, DatabaseDebug.TAG, '调试失败: %{public}s', JSON.stringify(error));
    }
  }

  public static async testInsert(): Promise<void> {
    hilog.info(0x0000, DatabaseDebug.TAG, '========== 测试插入草稿 ==========');
    
    try {
      const rdbStore = RdbHelper.getRdb();
      
      const testDraftId = 'debug_' + Date.now();
      const now = Date.now();
      
      const values: relationalStore.ValuesBucket = {
        draft_id: testDraftId,
        title: '调试测试标题',
        content: '调试测试内容',
        category: '1',
        create_time: now,
        update_time: now
      };
      
      hilog.info(0x0000, DatabaseDebug.TAG, '准备插入数据: %{public}s', JSON.stringify(values));
      
      const rowId = await rdbStore.insert(TABLE_ARTICLE_DRAFT, values);
      
      hilog.info(0x0000, DatabaseDebug.TAG, '✅ 插入成功! rowId=%{public}d', rowId);
      
      // 立即查询验证
      const predicates = new relationalStore.RdbPredicates(TABLE_ARTICLE_DRAFT);
      predicates.equalTo('draft_id', testDraftId);
      
      const result = await rdbStore.query(predicates);
      if (result.goToFirstRow()) {
        hilog.info(0x0000, DatabaseDebug.TAG, '验证查询成功:');
        hilog.info(0x0000, DatabaseDebug.TAG, '  id: %{public}d', result.getLong(0));
        hilog.info(0x0000, DatabaseDebug.TAG, '  draft_id: %{public}s', result.getString(1));
        hilog.info(0x0000, DatabaseDebug.TAG, '  title: %{public}s', result.getString(2));
        hilog.info(0x0000, DatabaseDebug.TAG, '  content: %{public}s', result.getString(3));
      } else {
        hilog.error(0x0000, DatabaseDebug.TAG, '❌ 查询失败，未找到刚插入的数据！');
      }
      result.close();
      
      hilog.info(0x0000, DatabaseDebug.TAG, '========== 测试完成 ==========');

    } catch (error) {
      hilog.error(0x0000, DatabaseDebug.TAG, '❌ 测试失败: %{public}s', JSON.stringify(error));
      throw new Error('DatabaseDebug test failed: ' + JSON.stringify(error));
    }
  }
}

export default DatabaseDebug;
