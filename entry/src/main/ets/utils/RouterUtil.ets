import { router } from '@kit.ArkUI';

export class RouterUtil {
  static async pushUrl(url: string, params?: Record<string, Object>): Promise<void> {
    try {
      console.log('RouterUtil - pushUrl:', url);
      await router.pushUrl({
        url: url,
        params: params
      });
      console.log('RouterUtil - pushUrl success');
    } catch (e) {
      const error = e as Error;
      console.error('RouterUtil - pushUrl failed:', error.message);
    }
  }

  static pushUrlSync(url: string, params?: Record<string, Object>): void {
    try {
      console.log('RouterUtil - pushUrlSync:', url);
      router.pushUrl({
        url: url,
        params: params
      });
      console.log('RouterUtil - pushUrlSync success');
    } catch (e) {
      const error = e as Error;
      console.error('RouterUtil - pushUrlSync failed:', error.message);
    }
  }

  static async replaceUrl(url: string, params?: Record<string, Object>): Promise<void> {
    try {
      console.log('RouterUtil - replaceUrl:', url);
      await router.replaceUrl({
        url: url,
        params: params
      });
    } catch (e) {
      const error = e as Error;
      console.error('RouterUtil - replaceUrl failed:', error.message);
    }
  }

  static async back(params?: Record<string, Object>): Promise<void> {
    try {
      router.back();
    } catch (e) {
      const error = e as Error;
      console.error('RouterUtil - back failed:', error.message);
    }
  }

  static getParams(): Record<string, Object> {
    try {
      const params = router.getParams() as Record<string, Object>;
      return params || {};
    } catch (e) {
      console.error('RouterUtil - getParams failed:', e);
      return {};
    }
  }

  static getCurrentPath(): string {
    try {
      const state = router.getState();
      return state?.path || '';
    } catch (e) {
      console.error('RouterUtil - getCurrentPath failed:', e);
      return '';
    }
  }
}
