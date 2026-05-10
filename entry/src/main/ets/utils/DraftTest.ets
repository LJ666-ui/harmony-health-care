import { hilog } from '@kit.PerformanceAnalysisKit';
import RdbHelper from './RdbHelper';
import {
  TABLE_ARTICLE_DRAFT,
  COLUMN_ID,
  COLUMN_DRAFT_ID,
  COLUMN_DRAFT_TITLE,
  COLUMN_DRAFT_CONTENT,
  COLUMN_DRAFT_CATEGORY_ID,
  COLUMN_DRAFT_LAST_EDIT_TIME,
  COLUMN_DRAFT_CREATE_TIME
} from './DatabaseConstants';

class DraftTest {
  private static TAG = 'DraftTest';

  public static async testInsert(): Promise<void> {
    hilog.info(0x0000, DraftTest.TAG, '========== 开始测试草稿插入 ==========');

    try {
      // 1. 检查表是否存在
      const checkTableSql = `SELECT name FROM sqlite_master WHERE type='table' AND name='${TABLE_ARTICLE_DRAFT}'`;
      hilog.info(0x0000, DraftTest.TAG, 'SQL: %{public}s', checkTableSql);
      const tableResult = await RdbHelper.query(checkTableSql);
      
      const tableExists = tableResult.goToFirstRow();
      hilog.info(0x0000, DraftTest.TAG, '表是否存在: %{public}s', tableExists ? '是' : '否');
      tableResult.close();

      if (!tableExists) {
        hilog.error(0x0000, DraftTest.TAG, '草稿表不存在！');
        return;
      }

      // 2. 查看表结构
      const pragmaSql = `PRAGMA table_info(${TABLE_ARTICLE_DRAFT})`;
      hilog.info(0x0000, DraftTest.TAG, 'SQL: %{public}s', pragmaSql);
      const pragmaResult = await RdbHelper.query(pragmaSql);
      
      hilog.info(0x0000, DraftTest.TAG, '表结构:');
      while (pragmaResult.goToNextRow()) {
        const cid = pragmaResult.getLong(0);
        const name = pragmaResult.getString(1);
        const type = pragmaResult.getString(2);
        const notnull = pragmaResult.getLong(3);
        const dflt_value = pragmaResult.isColumnNull(4) ? 'NULL' : pragmaResult.getString(4);
        const pk = pragmaResult.getLong(5);
        hilog.info(0x0000, DraftTest.TAG, '  列%{public}d: %{public}s (%{public}s) notnull=%{public}d default=%{public}s pk=%{public}d', 
          cid, name, type, notnull, dflt_value, pk);
      }
      pragmaResult.close();

      // 3. 尝试插入数据
      const testDraftId = 'test_' + Date.now();
      const testTitle = '测试标题';
      const testContent = '测试内容';
      const testCategoryId = 1;
      const testTime = Date.now();

      const insertSql = `INSERT INTO ${TABLE_ARTICLE_DRAFT} (${COLUMN_DRAFT_ID}, ${COLUMN_DRAFT_TITLE}, ${COLUMN_DRAFT_CONTENT}, ${COLUMN_DRAFT_CATEGORY_ID}, ${COLUMN_DRAFT_CREATE_TIME}, ${COLUMN_DRAFT_LAST_EDIT_TIME}) VALUES (?, ?, ?, ?, ?, ?)`;

      hilog.info(0x0000, DraftTest.TAG, '插入SQL: %{public}s', insertSql);
      
      const params: Array<string | number | null> = [
        testDraftId,
        testTitle,
        testContent,
        String(testCategoryId),
        testTime,
        testTime
      ];
      
      hilog.info(0x0000, DraftTest.TAG, '参数数量: %{public}d', params.length);
      for (let i = 0; i < params.length; i++) {
        hilog.info(0x0000, DraftTest.TAG, '参数[%{public}d]: %{public}s (类型: %{public}s)', 
          i, String(params[i]), typeof params[i]);
      }

      await RdbHelper.executeSql(insertSql, params);

      hilog.info(0x0000, DraftTest.TAG, '✅ 插入成功！');

      // 4. 查询验证
      const selectSql = `SELECT * FROM ${TABLE_ARTICLE_DRAFT} WHERE ${COLUMN_DRAFT_ID} = ?`;
      const selectResult = await RdbHelper.query(selectSql, [testDraftId]);
      
      if (selectResult.goToFirstRow()) {
        hilog.info(0x0000, DraftTest.TAG, '查询结果:');
        hilog.info(0x0000, DraftTest.TAG, '  id: %{public}d', selectResult.getLong(selectResult.getColumnIndex(COLUMN_ID)));
        hilog.info(0x0000, DraftTest.TAG, '  draft_id: %{public}s', selectResult.getString(selectResult.getColumnIndex(COLUMN_DRAFT_ID)));
        hilog.info(0x0000, DraftTest.TAG, '  title: %{public}s', selectResult.getString(selectResult.getColumnIndex(COLUMN_DRAFT_TITLE)));
      }
      selectResult.close();

      hilog.info(0x0000, DraftTest.TAG, '========== 测试完成 ==========');

    } catch (error) {
      hilog.error(0x0000, DraftTest.TAG, '❌ 测试失败: %{public}s', JSON.stringify(error));
      throw new Error('DraftTest failed: ' + JSON.stringify(error));
    }
  }
}

export default DraftTest;
