import { BaseResponse } from '../common/utils/HttpUtil';

export const USE_MOCK: boolean = true;

let mockEnabled: boolean = true;

export function setUseMock(enabled: boolean): void {
  mockEnabled = enabled;
}

export function isMockEnabled(): boolean {
  return mockEnabled;
}

export interface MockHandler<T> {
  (url: string, data?: object, params?: Object): Promise<BaseResponse<T>>;
}

interface HandlerEntry {
  pattern: string;
  handler: MockHandler<Object>;
}

const mockHandlers: HandlerEntry[] = [];

export function registerMockHandler<T>(urlPattern: string, handler: MockHandler<T>): void {
  mockHandlers.push({ pattern: urlPattern, handler: handler as MockHandler<Object> });
}

export function unregisterMockHandler(urlPattern: string): void {
  for (let i: number = mockHandlers.length - 1; i >= 0; i--) {
    if (mockHandlers[i].pattern === urlPattern) {
      mockHandlers.splice(i, 1);
    }
  }
}

export async function resolveMockResponse<T>(
  url: string,
  method: string,
  data?: object,
  params?: Object
): Promise<BaseResponse<T> | null> {
  if (!isMockEnabled()) {
    return null;
  }

  const len: number = mockHandlers.length;
  for (let i: number = 0; i < len; i++) {
    const entry: HandlerEntry = mockHandlers[i];
    if (url.indexOf(entry.pattern) >= 0) {
      console.log('[MockManager] 匹配Mock: ' + entry.pattern + ' -> ' + url);
      try {
        const result = await entry.handler(url, data, params);
        return result as BaseResponse<T>;
      } catch (error) {
        console.error('[MockManager] Mock处理失败(' + entry.pattern + '):', error);
      }
    }
  }

  return null;
}
