import { hilog } from '@kit.PerformanceAnalysisKit';
import RdbHelper from './RdbHelper';
import relationalStore from '@ohos.data.relationalStore';
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

export interface ArticleDraft {
  id?: number;
  draftId: string;
  draftTitle?: string;
  draftContent?: string;
  draftCategoryId?: number;
  draftLastEditTime?: number;
}

class ArticleDraftManager {
  private static instance: ArticleDraftManager;
  private TAG = 'ArticleDraftManager';

  private constructor() {}

  public static getInstance(): ArticleDraftManager {
    if (!ArticleDraftManager.instance) {
      ArticleDraftManager.instance = new ArticleDraftManager();
    }
    return ArticleDraftManager.instance;
  }

  public async saveDraft(title: string, content: string, categoryId: number): Promise<number> {
    hilog.info(0x0000, this.TAG, 'saveDraft 开始');
    hilog.info(0x0000, this.TAG, 'title: %{public}s', title);
    hilog.info(0x0000, this.TAG, 'content length: %{public}d', content.length);
    hilog.info(0x0000, this.TAG, 'categoryId: %{public}d', categoryId);
    hilog.info(0x0000, this.TAG, '数据库初始化状态: %{public}s', RdbHelper.isInitialized() ? '已初始化' : '未初始化');

    if (!RdbHelper.isInitialized()) {
      hilog.error(0x0000, this.TAG, '数据库未初始化，无法保存草稿');
      throw new Error('数据库未初始化，请重启应用');
    }

    // 先测试表是否存在并打印表结构
    try {
      const tableCheckSql = `PRAGMA table_info(${TABLE_ARTICLE_DRAFT})`;
      hilog.info(0x0000, this.TAG, '检查表结构: %{public}s', tableCheckSql);
      const tableInfo = await RdbHelper.query(tableCheckSql);
      hilog.info(0x0000, this.TAG, '表查询结果行数: %{public}d', tableInfo.rowCount);
      
      if (tableInfo.rowCount === 0) {
        hilog.error(0x0000, this.TAG, '表不存在！');
        tableInfo.close();
        throw new Error('草稿表不存在，请重启应用');
      }
      
      tableInfo.close();
    } catch (error) {
      hilog.error(0x0000, this.TAG, '表检查失败: %{public}s', JSON.stringify(error));
      throw new Error('表检查失败: ' + JSON.stringify(error));
    }

    try {
      hilog.info(0x0000, this.TAG, '查询现有草稿...');
      const existingDraft = await this.getLatestDraft();
      hilog.info(0x0000, this.TAG, '查询结果: %{public}s', existingDraft ? '找到草稿' : '无草稿');
      
      if (existingDraft) {
        hilog.info(0x0000, this.TAG, '更新现有草稿 id: %{public}d', existingDraft.id!);
        
        const sql = `UPDATE ${TABLE_ARTICLE_DRAFT} SET 
          ${COLUMN_DRAFT_TITLE} = ?,
          ${COLUMN_DRAFT_CONTENT} = ?,
          ${COLUMN_DRAFT_CATEGORY_ID} = ?,
          ${COLUMN_DRAFT_LAST_EDIT_TIME} = ?
          WHERE ${COLUMN_ID} = ?`;
        
        hilog.info(0x0000, this.TAG, '执行UPDATE SQL: %{public}s', sql);
        await RdbHelper.executeSql(sql, [
          title,
          content,
          String(categoryId),
          String(Date.now()),
          String(existingDraft.id)
        ] as string[]);
        
        hilog.info(0x0000, this.TAG, '草稿更新成功');
        return existingDraft.id!;
      } else {
        hilog.info(0x0000, this.TAG, '创建新草稿');
        
        const draftId = 'draft_' + Date.now();
        const now = Date.now();
        
        const sql = `INSERT INTO ${TABLE_ARTICLE_DRAFT} (${COLUMN_DRAFT_ID}, ${COLUMN_DRAFT_TITLE}, ${COLUMN_DRAFT_CONTENT}, ${COLUMN_DRAFT_CATEGORY_ID}, ${COLUMN_DRAFT_CREATE_TIME}, ${COLUMN_DRAFT_LAST_EDIT_TIME}) VALUES (?, ?, ?, ?, ?, ?)`;
        
        hilog.info(0x0000, this.TAG, '完整SQL: %{public}s', sql);
        
        const params: string[] = [
          draftId,
          title || '',
          content || '',
          String(categoryId),
          String(now),
          String(now)
        ];
        
        hilog.info(0x0000, this.TAG, '参数: %{public}s', JSON.stringify(params));
        
        await RdbHelper.executeSql(sql, params);
        
        hilog.info(0x0000, this.TAG, '草稿创建成功, draftId: %{public}s', draftId);
        return 0;
      }
    } catch (error) {
      hilog.error(0x0000, this.TAG, 'saveDraft 失败: %{public}s', JSON.stringify(error));
      const errorMsg = error instanceof Error ? error.message : JSON.stringify(error);
      throw new Error('saveDraft failed: ' + errorMsg);
    }
  }

  public async getLatestDraft(): Promise<ArticleDraft | null> {
    try {
      const sql = `SELECT 
        ${COLUMN_ID},
        ${COLUMN_DRAFT_ID},
        ${COLUMN_DRAFT_TITLE},
        ${COLUMN_DRAFT_CONTENT},
        ${COLUMN_DRAFT_CATEGORY_ID},
        ${COLUMN_DRAFT_LAST_EDIT_TIME}
        FROM ${TABLE_ARTICLE_DRAFT}
        ORDER BY ${COLUMN_DRAFT_LAST_EDIT_TIME} DESC
        LIMIT 1`;
      
      const result = await RdbHelper.query(sql);
      
      if (result.goToFirstRow()) {
        const draft: ArticleDraft = {
          id: result.getLong(result.getColumnIndex(COLUMN_ID)),
          draftId: result.getString(result.getColumnIndex(COLUMN_DRAFT_ID)),
          draftTitle: result.getString(result.getColumnIndex(COLUMN_DRAFT_TITLE)),
          draftContent: result.getString(result.getColumnIndex(COLUMN_DRAFT_CONTENT)),
          draftCategoryId: parseInt(result.getString(result.getColumnIndex(COLUMN_DRAFT_CATEGORY_ID)) || '1'),
          draftLastEditTime: result.getLong(result.getColumnIndex(COLUMN_DRAFT_LAST_EDIT_TIME))
        };
        result.close();
        return draft;
      }
      
      result.close();
      return null;
    } catch (error) {
      hilog.error(0x0000, this.TAG, 'getLatestDraft 失败: %{public}s', JSON.stringify(error));
      return null;
    }
  }

  public async clearDraft(): Promise<void> {
    try {
      const sql = `DELETE FROM ${TABLE_ARTICLE_DRAFT}`;
      await RdbHelper.executeSql(sql);
      hilog.info(0x0000, this.TAG, '草稿已清空');
    } catch (error) {
      hilog.error(0x0000, this.TAG, 'clearDraft 失败: %{public}s', JSON.stringify(error));
      throw new Error('clearDraft failed: ' + JSON.stringify(error));
    }
  }
}

const articleDraftManager = ArticleDraftManager.getInstance();
export default articleDraftManager;
