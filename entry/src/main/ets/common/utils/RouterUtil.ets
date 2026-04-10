// 路由相关接口定义

/**
 * 路由参数接口
 */
export interface RouterParams {
  url: string;
  params?: Record<string, string>;
}