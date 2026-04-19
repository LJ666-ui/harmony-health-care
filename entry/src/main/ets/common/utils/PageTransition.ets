import { router } from '@kit.ArkUI';

export class PageTransition {
  private static readonly DEFAULT_DURATION: number = 300;

  static pushPage(url: string, params?: Record<string, Object>): void {
    router.pushUrl({
      url: url,
      params: params
    }, router.RouterMode.Single, (err) => {
      if (err) {
        console.error('Page navigation failed:', err.code, err.message);
      }
    });
  }

  static replacePage(url: string, params?: Record<string, Object>): void {
    router.replaceUrl({
      url: url,
      params: params
    }, router.RouterMode.Single, (err) => {
      if (err) {
        console.error('Page replace failed:', err.code, err.message);
      }
    });
  }

  static back(): void {
    router.back();
  }

  static backWithParams(params?: Record<string, Object>): void {
    const state = router.getState();
    const path = state ? state.path : '';
    router.back({
      url: path,
      params: params
    });
  }

  static getLength(): number {
    return router.getLength();
  }

  static getState(): router.RouterState | undefined {
    return router.getState();
  }
}

export interface TransitionConfig {
  duration?: number;
  delay?: number;
  curve?: Curve | string;
}

export class AnimationUtils {
  static fadeIn(duration: number = 300): AnimateParam {
    return {
      duration: duration,
      curve: Curve.EaseInOut,
      iterations: 1
    };
  }

  static fadeOut(duration: number = 300): AnimateParam {
    return {
      duration: duration,
      curve: Curve.EaseInOut,
      iterations: 1
    };
  }

  static slideInRight(duration: number = 300): AnimateParam {
    return {
      duration: duration,
      curve: Curve.EaseOut,
      iterations: 1
    };
  }

  static slideOutLeft(duration: number = 300): AnimateParam {
    return {
      duration: duration,
      curve: Curve.EaseIn,
      iterations: 1
    };
  }
}

@Builder
export function FadeTransition(content: () => void) {
  Column() {
    content()
  }
  .opacity(0)
  .onAppear(() => {
    animateTo({
      duration: 300,
      curve: Curve.EaseInOut
    }, () => {
      // Fade in animation will be handled by the component
    });
  })
}
