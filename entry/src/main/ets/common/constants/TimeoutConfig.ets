export class TimeoutConfig {
  static readonly FAST: number = 15000;
  static readonly NORMAL: number = 30000;
  static readonly SLOW: number = 45000;
  static readonly VERY_SLOW: number = 60000;
}

const REQUEST_TIMEOUT_MAP: Record<string, number> = {
  '/user/login': TimeoutConfig.NORMAL,
  '/user/register': TimeoutConfig.SLOW,
  '/user/send-code': TimeoutConfig.FAST,
  '/doctor/register': TimeoutConfig.SLOW,
  '/ai/chat': TimeoutConfig.VERY_SLOW,
  '/ai/health-consult': TimeoutConfig.VERY_SLOW,
  '/ai/risk-analysis': TimeoutConfig.VERY_SLOW,
  '/ai/rehab-guide': TimeoutConfig.VERY_SLOW
};

export function selectTimeout(url: string): number {
  if (REQUEST_TIMEOUT_MAP[url]) {
    return REQUEST_TIMEOUT_MAP[url];
  }
  
  if (url.includes('/ai/') || url.includes('/upload')) {
    return TimeoutConfig.VERY_SLOW;
  }
  
  if (url.includes('/register')) {
    return TimeoutConfig.SLOW;
  }
  
  if (url.includes('/send-code') || url.includes('/check')) {
    return TimeoutConfig.FAST;
  }
  
  return TimeoutConfig.NORMAL;
}
