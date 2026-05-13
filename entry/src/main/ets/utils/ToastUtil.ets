import { promptAction } from '@kit.ArkUI';

export class ToastUtil {
  private static readonly DEFAULT_DURATION = 2000;

  static showSuccess(message: string, duration: number = ToastUtil.DEFAULT_DURATION): void {
    promptAction.showToast({
      message: message,
      duration: duration
    });
  }

  static showError(message: string, duration: number = ToastUtil.DEFAULT_DURATION): void {
    promptAction.showToast({
      message: message,
      duration: duration
    });
  }

  static showWarning(message: string, duration: number = ToastUtil.DEFAULT_DURATION): void {
    promptAction.showToast({
      message: message,
      duration: duration
    });
  }

  static showInfo(message: string, duration: number = ToastUtil.DEFAULT_DURATION): void {
    promptAction.showToast({
      message: message,
      duration: duration
    });
  }
}
