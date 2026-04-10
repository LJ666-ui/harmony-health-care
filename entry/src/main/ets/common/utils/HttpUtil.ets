// 简化的网络请求接口定义

/**
 * 登录请求数据接口
 */
export interface LoginRequest {
  username: string;
  password: string;
}

/**
 * 登录响应数据接口
 */
export interface LoginResponse {
  token: string;
  message: string;
}