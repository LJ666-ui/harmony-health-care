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
      const dur = duration ? duration : ToastUtil.DURATION_DEFAULT;
      promptAction.showToast({
        message: message,
        duration: dur,
        bottom: '80vp'
      });
    } catch (error) {
      console.error('ToastUtil.showSuccess error:', error);
    }
  }

  static showError(message: string, duration?: number): void {
    try {
      const dur = duration ? duration : ToastUtil.DURATION_DEFAULT;
      promptAction.showToast({
        message: message,
        duration: dur,
        bottom: '80vp'
      });
    } catch (error) {
      console.error('ToastUtil.showError error:', error);
    }
  }

  static showInfo(message: string, duration?: number): void {
    try {
      const dur = duration ? duration : ToastUtil.DURATION_DEFAULT;
      promptAction.showToast({
        message: message,
        duration: dur,
        bottom: '80vp'
      });
    } catch (error) {
      console.error('ToastUtil.showInfo error:', error);
    }
  }

  static showWarning(message: string, duration?: number): void {
    try {
      const dur = duration ? duration : ToastUtil.DURATION_DEFAULT;
      promptAction.showToast({
        message: message,
        duration: dur,
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
    const msg = message ? message : '登录失败，请检查账号密码';
    ToastUtil.showError(msg);
  }

  static cancelSuccess(): void {
    ToastUtil.showSuccess('取消成功');
  }

  static cancelFailed(): void {
    ToastUtil.showError('取消失败，请重试');
  }

  static addSuccess(type?: string): void {
    if (type) {
      ToastUtil.showSuccess(type + '添加成功');
    } else {
      ToastUtil.showSuccess('添加成功');
    }
  }

  static addFailed(type?: string): void {
    if (type) {
      ToastUtil.showError(type + '添加失败');
    } else {
      ToastUtil.showError('添加失败，请重试');
    }
  }

  static updateSuccess(type?: string): void {
    if (type) {
      ToastUtil.showSuccess(type + '更新成功');
    } else {
      ToastUtil.showSuccess('更新成功');
    }
  }

  static updateFailed(type?: string): void {
    if (type) {
      ToastUtil.showError(type + '更新失败');
    } else {
      ToastUtil.showError('更新失败，请重试');
    }
  }

  static operationSuccess(operation?: string): void {
    if (operation) {
      ToastUtil.showSuccess(operation + '成功');
    } else {
      ToastUtil.showSuccess('操作成功');
    }
  }

  static operationFailed(operation?: string): void {
    if (operation) {
      ToastUtil.showError(operation + '失败');
    } else {
      ToastUtil.showError('操作失败，请重试');
    }
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
    if (field) {
      ToastUtil.showError('请填写' + field);
    } else {
      ToastUtil.showError('请完善表单信息');
    }
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
