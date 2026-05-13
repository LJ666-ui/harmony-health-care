import relationalStore from '@ohos.data.relationalStore';
import RdbHelper from './RdbHelper';
import {
  TABLE_ARTICLE_CACHE,
  COLUMN_ID,
  COLUMN_ARTICLE_ID,
  COLUMN_TITLE,
  COLUMN_CONTENT,
  COLUMN_COVER_IMAGE,
  COLUMN_CATEGORY,
  COLUMN_CACHED_TIME,
  COLUMN_EXPIRE_TIME
} from './DatabaseConstants';

export interface ArticleCache {
  id?: number;
  articleId: string;
  title?: string;
  content?: string;
  coverImage?: string;
  category?: string;
  cachedTime?: number;
  expireTime?: number;
}

class ArticleCacheManager {
  private static instance: ArticleCacheManager;
  private defaultExpireDuration = 24 * 60 * 60 * 1000;

  private constructor() {}

  public static getInstance(): ArticleCacheManager {
    if (!ArticleCacheManager.instance) {
      ArticleCacheManager.instance = new ArticleCacheManager();
    }
    return ArticleCacheManager.instance;
  }

  public async cacheArticle(article: ArticleCache): Promise<number> {
    const values: relationalStore.ValuesBucket = {
      [COLUMN_ARTICLE_ID]: article.articleId,
      [COLUMN_TITLE]: article.title || null,
      [COLUMN_CONTENT]: article.content || null,
      [COLUMN_COVER_IMAGE]: article.coverImage || null,
      [COLUMN_CATEGORY]: article.category || null,
      [COLUMN_CACHED_TIME]: Date.now(),
      [COLUMN_EXPIRE_TIME]: article.expireTime || Date.now() + this.defaultExpireDuration
    };

    const predicates = new relationalStore.RdbPredicates(TABLE_ARTICLE_CACHE);
    predicates.equalTo(COLUMN_ARTICLE_ID, article.articleId);
    
    const resultSet = await RdbHelper.queryByPredicates(predicates, [COLUMN_ID]);
    if (resultSet.goToFirstRow()) {
      resultSet.close();
      return await RdbHelper.update(TABLE_ARTICLE_CACHE, values, predicates);
    }
    resultSet.close();
    
    return await RdbHelper.insert(TABLE_ARTICLE_CACHE, values);
  }

  public async getCachedArticle(articleId: string): Promise<ArticleCache | null> {
    const predicates = new relationalStore.RdbPredicates(TABLE_ARTICLE_CACHE);
    predicates.equalTo(COLUMN_ARTICLE_ID, articleId);

    const resultSet = await RdbHelper.queryByPredicates(predicates);
    if (resultSet.goToFirstRow()) {
      const article: ArticleCache = {
        id: resultSet.getLong(resultSet.getColumnIndex(COLUMN_ID)),
        articleId: resultSet.getString(resultSet.getColumnIndex(COLUMN_ARTICLE_ID)),
        title: resultSet.getString(resultSet.getColumnIndex(COLUMN_TITLE)),
        content: resultSet.getString(resultSet.getColumnIndex(COLUMN_CONTENT)),
        coverImage: resultSet.getString(resultSet.getColumnIndex(COLUMN_COVER_IMAGE)),
        category: resultSet.getString(resultSet.getColumnIndex(COLUMN_CATEGORY)),
        cachedTime: resultSet.getLong(resultSet.getColumnIndex(COLUMN_CACHED_TIME)),
        expireTime: resultSet.getLong(resultSet.getColumnIndex(COLUMN_EXPIRE_TIME))
      };
      resultSet.close();

      if (article.expireTime && article.expireTime < Date.now()) {
        await this.removeCachedArticle(articleId);
        return null;
      }

      return article;
    }
    resultSet.close();
    return null;
  }

  public async getArticlesByCategory(category: string): Promise<ArticleCache[]> {
    const predicates = new relationalStore.RdbPredicates(TABLE_ARTICLE_CACHE);
    predicates.equalTo(COLUMN_CATEGORY, category);
    predicates.orderByDesc(COLUMN_CACHED_TIME);

    const articles: ArticleCache[] = [];
    const resultSet = await RdbHelper.queryByPredicates(predicates);
    
    while (resultSet.goToNextRow()) {
      const expireTime = resultSet.getLong(resultSet.getColumnIndex(COLUMN_EXPIRE_TIME));
      if (expireTime >= Date.now()) {
        articles.push({
          id: resultSet.getLong(resultSet.getColumnIndex(COLUMN_ID)),
          articleId: resultSet.getString(resultSet.getColumnIndex(COLUMN_ARTICLE_ID)),
          title: resultSet.getString(resultSet.getColumnIndex(COLUMN_TITLE)),
          content: resultSet.getString(resultSet.getColumnIndex(COLUMN_CONTENT)),
          coverImage: resultSet.getString(resultSet.getColumnIndex(COLUMN_COVER_IMAGE)),
          category: resultSet.getString(resultSet.getColumnIndex(COLUMN_CATEGORY)),
          cachedTime: resultSet.getLong(resultSet.getColumnIndex(COLUMN_CACHED_TIME)),
          expireTime: expireTime
        });
      }
    }
    resultSet.close();
    return articles;
  }

  public async removeCachedArticle(articleId: string): Promise<number> {
    const predicates = new relationalStore.RdbPredicates(TABLE_ARTICLE_CACHE);
    predicates.equalTo(COLUMN_ARTICLE_ID, articleId);
    return await RdbHelper.delete(predicates);
  }

  public async clearExpiredCache(): Promise<number> {
    const sql = `DELETE FROM ${TABLE_ARTICLE_CACHE} WHERE ${COLUMN_EXPIRE_TIME} < ?`;
    await RdbHelper.executeSql(sql, [Date.now()]);
    return 0;
  }
}

const articleCacheManager = ArticleCacheManager.getInstance();
export default articleCacheManager;
