import { BaseResponse } from '../common/utils/HttpUtil';
import { registerMockHandler, USE_MOCK } from './index';

export interface ArticleItem {
  id: number;
  title: string;
  summary: string;
  coverImage: string;
  categoryId: number;
  categoryName: string;
  author: string;
  readCount: number;
  isCollected: boolean;
  createTime: string;
}

export interface ArticleCategory {
  id: number;
  name: string;
  icon: string;
  count: number;
}

export interface CommentItem {
  id: number;
  articleId: number;
  userName: string;
  userAvatar: string;
  content: string;
  likeCount: number;
  parentId: number;
  createTime: string;
}

const mockArticles: ArticleItem[] = [];

const mockCategories: ArticleCategory[] = [];

const mockComments: CommentItem[] = [];

function findArticleById(id: number): ArticleItem | undefined {
  for (let i = 0; i < mockArticles.length; i++) {
    if (mockArticles[i].id === id) {
      return mockArticles[i];
    }
  }
  return undefined;
}

function filterCollectedArticles(): ArticleItem[] {
  const result: ArticleItem[] = [];
  for (let i = 0; i < mockArticles.length; i++) {
    if (mockArticles[i].isCollected) {
      result.push(mockArticles[i]);
    }
  }
  return result;
}

if (USE_MOCK) {
  registerMockHandler('/healthArticle/page', async (url, data, params) => {
    let pageVal = 1;
    let sizeVal = 8;
    if (params) {
      const p = params as Record<string, Object>;
      if (p['page']) {
        pageVal = Number(p['page']);
      }
      if (p['size']) {
        sizeVal = Number(p['size']);
      }
    }
    const start = (pageVal - 1) * sizeVal;
    const end = start + sizeVal;

    const pageData = {
      records: mockArticles.slice(start, end),
      total: mockArticles.length,
      page: pageVal,
      size: sizeVal
    };

    return {
      success: true,
      message: '查询成功',
      code: 200,
      data: pageData
    };
  });

  registerMockHandler('/healthArticle/list', async () => {
    return {
      success: true,
      message: '查询成功',
      code: 200,
      data: mockArticles
    };
  });

  registerMockHandler('/healthArticle/detail/', async (url) => {
    const parts = url.split('/');
    const lastPart = parts[parts.length - 1];
    const id = parseInt(lastPart);
    const article = findArticleById(id);
    return {
      success: !!article,
      message: article ? '查询成功' : '文章不存在',
      code: article ? 200 : 404,
      data: article || null
    };
  });

  registerMockHandler('/healthArticle/categories/parent', async () => {
    return {
      success: true,
      message: '查询成功',
      code: 200,
      data: mockCategories
    };
  });

  registerMockHandler('/api/article/my-collects', async () => {
    const collected = filterCollectedArticles();
    return {
      success: true,
      message: '查询成功',
      code: 200,
      data: collected
    };
  });

  registerMockHandler('/comment/list/', async (url) => {
    const parts = url.split('/');
    const lastPart = parts[parts.length - 1];
    const articleId = parseInt(lastPart);
    const comments = mockComments.filter(c => c.articleId === articleId);
    return {
      success: true,
      message: '查询成功',
      code: 200,
      data: comments
    };
  });

  registerMockHandler('/comment/add', async (url, data) => {
    const newComment: CommentItem = {
      id: mockComments.length + 1,
      articleId: data?.articleId || 0,
      userName: data?.userName || '当前用户',
      userAvatar: '',
      content: data?.content || '',
      likeCount: 0,
      parentId: data?.parentId || 0,
      createTime: new Date().toISOString().replace('T', ' ').substring(0, 19)
    };
    mockComments.push(newComment);
    return {
      success: true,
      message: '评论发布成功',
      code: 200,
      data: newComment
    };
  });

  registerMockHandler('/comment/delete/', async (url) => {
    const parts = url.split('/');
    const lastPart = parts[parts.length - 1];
    const id = parseInt(lastPart);
    const index = mockComments.findIndex(c => c.id === id);
    if (index >= 0) {
      mockComments.splice(index, 1);
      return {
        success: true,
        message: '删除成功',
        code: 200
      };
    }
    return {
      success: false,
      message: '评论不存在',
      code: 404
    };
  });

  registerMockHandler('/comment/like/', async (url) => {
    const parts = url.split('/');
    const lastPart = parts[parts.length - 1];
    const id = parseInt(lastPart);
    const comment = mockComments.find(c => c.id === id);
    if (comment) {
      comment.likeCount += 1;
      return {
        success: true,
        message: '点赞成功',
        code: 200,
        data: { likeCount: comment.likeCount }
      };
    }
    return {
      success: false,
      message: '评论不存在',
      code: 404
    };
  });
}

export function getMockArticles(): ArticleItem[] {
  return mockArticles;
}

export function getMockCategories(): ArticleCategory[] {
  return mockCategories;
}

export function getMockComments(articleId?: number): CommentItem[] {
  if (articleId) {
    return mockComments.filter(c => c.articleId === articleId);
  }
  return mockComments;
}
