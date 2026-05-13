import relationalStore from '@ohos.data.relationalStore';
import RdbHelper from './RdbHelper';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { TABLE_ARTICLE_DRAFT } from './DatabaseConstants';

class SimpleDraftTest {
  private static TAG = 'SimpleDraftTest';

  public static async testDirectInsert(): Promise<void> {
    hilog.info(0x0000, SimpleDraftTest.TAG, '========== 直接插入测试 ==========');

    try {
      const rdbStore = RdbHelper.getRdb();
      
      const testDraftId = 'simple_' + Date.now();
      const testTitle = '测试';
      const testContent = '内容';
      const testTime = Date.now();

      const values: relationalStore.ValuesBucket = {
        draft_id: testDraftId,
        title: testTitle,
        content: testContent,
        category: '1',
        create_time: testTime,
        update_time: testTime
      };

      hilog.info(0x0000, SimpleDraftTest.TAG, '使用insert方法插入');
      hilog.info(0x0000, SimpleDraftTest.TAG, '表名: %{public}s', TABLE_ARTICLE_DRAFT);
      hilog.info(0x0000, SimpleDraftTest.TAG, '数据: %{public}s', JSON.stringify(values));

      const rowId = await rdbStore.insert(TABLE_ARTICLE_DRAFT, values);
      
      hilog.info(0x0000, SimpleDraftTest.TAG, '✅ 插入成功! rowId=%{public}d', rowId);
      
      // 查询验证
      const predicates = new relationalStore.RdbPredicates(TABLE_ARTICLE_DRAFT);
      predicates.equalTo('draft_id', testDraftId);
      
      const result = await rdbStore.query(predicates);
      if (result.goToFirstRow()) {
        hilog.info(0x0000, SimpleDraftTest.TAG, '查询到数据:');
        hilog.info(0x0000, SimpleDraftTest.TAG, '  id: %{public}d', result.getLong(0));
        hilog.info(0x0000, SimpleDraftTest.TAG, '  draft_id: %{public}s', result.getString(1));
        hilog.info(0x0000, SimpleDraftTest.TAG, '  title: %{public}s', result.getString(2));
      }
      result.close();
      
      hilog.info(0x0000, SimpleDraftTest.TAG, '========== 测试完成 ==========');

    } catch (error) {
      hilog.error(0x0000, SimpleDraftTest.TAG, '❌ 测试失败: %{public}s', JSON.stringify(error));
      throw new Error('SimpleDraftTest failed: ' + JSON.stringify(error));
    }
  }
}

export default SimpleDraftTest;
