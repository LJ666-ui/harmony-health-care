import { promptAction } from '@kit.ArkUI';

export class ToastUtil {
  static readonly DURATION_SHORT: number = 1500;
  static readonly DURATION_LONG: number = 2500;
  static readonly DURATION_DEFAULT: number = 1500;

  private static isElderMode: boolean = false;

  static init(isElderMode: boolean): void {
    ToastUtil.isElderMode = isElderMode;
  }

  static showSuccess(message: string, duration?: number): void {
    try {
      promptAction.showToast({
        message: message,
        duration: duration ?? ToastUtil.DURATION_DEFAULT,
        bottom: '80vp'
      });
    } catch (error) {
      console.error('ToastUtil.showSuccess error:', error);
    }
  }

  static showError(message: string, duration?: number): void {
    try {
      promptAction.showToast({
        message: message,
        duration: duration ?? ToastUtil.DURATION_DEFAULT,
        bottom: '80vp'
      });
    } catch (error) {
      console.error('ToastUtil.showError error:', error);
    }
  }

  static showInfo(message: string, duration?: number): void {
    try {
      promptAction.showToast({
        message: message,
        duration: duration ?? ToastUtil.DURATION_DEFAULT,
        bottom: '80vp'
      });
    } catch (error) {
      console.error('ToastUtil.showInfo error:', error);
    }
  }

  static showWarning(message: string, duration?: number): void {
    try {
      promptAction.showToast({
        message: message,
        duration: duration ?? ToastUtil.DURATION_DEFAULT,
        bottom: '80vp'
      });
    } catch (error) {
      console.error('ToastUtil.showWarning error:', error);
    }
  }

  static refreshSuccess(): void {
    ToastUtil.showSuccess('刷新成功');
  }

  static refreshFailed(): void {
    ToastUtil.showError('刷新失败，请重试');
  }

  static saveSuccess(): void {
    ToastUtil.showSuccess('保存成功');
  }

  static saveFailed(): void {
    ToastUtil.showError('保存失败，请重试');
  }

  static deleteSuccess(): void {
    ToastUtil.showSuccess('删除成功');
  }

  static deleteFailed(): void {
    ToastUtil.showError('删除失败，请重试');
  }

  static submitSuccess(): void {
    ToastUtil.showSuccess('提交成功');
  }

  static submitFailed(): void {
    ToastUtil.showError('提交失败，请重试');
  }

  static loginSuccess(): void {
    ToastUtil.showSuccess('登录成功');
  }

  static loginFailed(message?: string): void {
    ToastUtil.showError(message ?? '登录失败，请检查账号密码');
  }

  static cancelSuccess(): void {
    ToastUtil.showSuccess('取消成功');
  }

  static cancelFailed(): void {
    ToastUtil.showError('取消失败，请重试');
  }

  static addSuccess(type?: string): void {
    ToastUtil.showSuccess(type ? `${type}添加成功` : '添加成功');
  }

  static addFailed(type?: string): void {
    ToastUtil.showError(type ? `${type}添加失败` : '添加失败，请重试');
  }

  static updateSuccess(type?: string): void {
    ToastUtil.showSuccess(type ? `${type}更新成功` : '更新成功');
  }

  static updateFailed(type?: string): void {
    ToastUtil.showError(type ? `${type}更新失败` : '更新失败，请重试');
  }

  static operationSuccess(operation?: string): void {
    ToastUtil.showSuccess(operation ? `${operation}成功` : '操作成功');
  }

  static operationFailed(operation?: string): void {
    ToastUtil.showError(operation ? `${operation}失败` : '操作失败，请重试');
  }

  static networkError(): void {
    ToastUtil.showError('网络连接异常，请检查网络');
  }

  static loadingFailed(): void {
    ToastUtil.showError('数据加载失败，请重试');
  }

  static noPermission(): void {
    ToastUtil.showWarning('您没有权限执行此操作');
  }

  static formValidationFailed(field?: string): void {
    ToastUtil.showError(field ? `请填写${field}` : '请完善表单信息');
  }

  static emergencyCall(): void {
    try {
      promptAction.showToast({
        message: '正在模拟拨打120...',
        duration: 2000,
        bottom: '80vp'
      });
    } catch (error) {
      console.error('ToastUtil.emergencyCall error:', error);
    }
  }
}
