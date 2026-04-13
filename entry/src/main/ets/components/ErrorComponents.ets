import { AccessibilityConfig } from '../utils/AccessibilityConfig';

export enum ErrorType {
  NETWORK_ERROR = 'network_error',
  SERVER_ERROR = 'server_error',
  TIMEOUT = 'timeout',
  UNKNOWN = 'unknown'
}

interface ErrorInfo {
  type: ErrorType;
  message: string;
  suggestion: string;
  icon: string;
}

class ErrorInfoImpl implements ErrorInfo {
  type: ErrorType;
  message: string;
  suggestion: string;
  icon: string;

  constructor(type: ErrorType, message: string, suggestion: string, icon: string) {
    this.type = type;
    this.message = message;
    this.suggestion = suggestion;
    this.icon = icon;
  }
}

const ERROR_MESSAGES: Array<[ErrorType, ErrorInfo]> = [
  [ErrorType.NETWORK_ERROR, new ErrorInfoImpl(ErrorType.NETWORK_ERROR, '网络连接失败', '请检查网络设置后重试', '📡')],
  [ErrorType.SERVER_ERROR, new ErrorInfoImpl(ErrorType.SERVER_ERROR, '服务器繁忙', '请稍后再试，或联系客服', '🖥️')],
  [ErrorType.TIMEOUT, new ErrorInfoImpl(ErrorType.TIMEOUT, '请求超时', '网络较慢，请稍后重试', '⏰')],
  [ErrorType.UNKNOWN, new ErrorInfoImpl(ErrorType.UNKNOWN, '发生未知错误', '请重启应用或联系客服', '❓')]
];

function getErrorMessage(errorType: ErrorType): ErrorInfo {
  for (let i = 0; i < ERROR_MESSAGES.length; i++) {
    if (ERROR_MESSAGES[i][0] === errorType) {
      return ERROR_MESSAGES[i][1];
    }
  }
  return ERROR_MESSAGES[3][1];
}

interface EmptyStateInfo {
  icon: string;
  title: string;
  description: string;
  actionLabel?: string;
}

class EmptyStateInfoImpl implements EmptyStateInfo {
  icon: string;
  title: string;
  description: string;
  actionLabel?: string;

  constructor(icon: string, title: string, description: string, actionLabel?: string) {
    this.icon = icon;
    this.title = title;
    this.description = description;
    this.actionLabel = actionLabel;
  }
}

const EMPTY_STATES_KEYS: string[] = [
  'no_data',
  'no_records',
  'no_appointments',
  'no_messages',
  'no_devices',
  'search_empty',
  'authorization_empty',
  'images_empty',
  'badges_empty'
];

const EMPTY_STATES_VALUES: EmptyStateInfo[] = [
  new EmptyStateInfoImpl('📭', '暂无数据', '这里还没有内容，快去添加吧！', '立即添加'),
  new EmptyStateInfoImpl('📋', '暂无记录', '您还没有健康记录，开始记录您的健康状况吧', '添加记录'),
  new EmptyStateInfoImpl('📅', '暂无预约', '您还没有预约，去预约一位医生吧', '预约医生'),
  new EmptyStateInfoImpl('💬', '暂无消息', '这里空空如也，有什么想问的吗？', '开始对话'),
  new EmptyStateInfoImpl('📱', '暂无设备', '还没有绑定设备，去发现附近的设备吧', '添加设备'),
  new EmptyStateInfoImpl('🔍', '未找到结果', '换个关键词试试吧', '清除搜索'),
  new EmptyStateInfoImpl('🔐', '暂未授权', '您还没有向任何人授权数据访问权限', '新建授权'),
  new EmptyStateInfoImpl('🖼️', '暂无图片', '上传古医籍图片，AI帮您智能复原', '上传图片'),
  new EmptyStateInfoImpl('🏆', '暂未获得徽章', '完成更多任务来解锁成就徽章吧', '去看看任务')
];

function getEmptyState(key: string): EmptyStateInfo {
  const index = EMPTY_STATES_KEYS.indexOf(key);
  if (index >= 0) {
    return EMPTY_STATES_VALUES[index];
  }
  return EMPTY_STATES_VALUES[0];
}

@Component
export struct NetworkStatusBanner {
  @State isOffline: boolean = false;

  aboutToAppear(): void {
    this.checkNetworkStatus();
  }

  checkNetworkStatus(): void {
    try {
      let hasNetwork: boolean = true;
      console.info('检测网络状态');
      this.isOffline = !hasNetwork;
    } catch (e) {
      console.warn('网络状态检测异常');
      this.isOffline = false;
    }
  }

  build() {
    if (this.isOffline) {
      Row({ space: 8 }) {
        Text('⚠️')
          .fontSize(14);

        Text('当前网络不可用，部分功能可能受限')
          .fontSize(AccessibilityConfig.getFontSizeSmall())
          .fontColor('#FFFFFF')
          .layoutWeight(1);

        Text('重试')
          .fontSize(AccessibilityConfig.getFontSizeSmall())
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Medium)
          .onClick(() => {
            this.checkNetworkStatus();
          });
      }
      .width('100%')
      .height(44)
      .backgroundColor('#FF4D4F')
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.Center)
      .accessibilityText('网络不可用提示');
    } else {
      Column()
        .height(0);
    }
  }
}

@Component
export struct ErrorView {
  @Prop errorType: ErrorType = ErrorType.NETWORK_ERROR;
  @Prop customMessage?: string;
  onRetry?: () => void;

  getErrorInfo(): ErrorInfo {
    if (this.customMessage) {
      return new ErrorInfoImpl(
        this.errorType,
        this.customMessage,
        getErrorMessage(this.errorType).suggestion,
        getErrorMessage(this.errorType).icon
      );
    }
    return getErrorMessage(this.errorType);
  }

  build() {
    Column({ space: 20 }) {
      Text(this.getErrorInfo().icon)
        .fontSize(56);

      Text(this.getErrorInfo().message)
        .fontSize(AccessibilityConfig.getFontSizeSubtitle())
        .fontWeight(FontWeight.Bold)
        .fontColor(AccessibilityConfig.getTextPrimary());

      Text(this.getErrorInfo().suggestion)
        .fontSize(AccessibilityConfig.getFontSizeBody())
        .fontColor(AccessibilityConfig.getTextSecondary())
        .textAlign(TextAlign.Center)
        .width('80%');

      Button('重新尝试')
        .width(160)
        .height(AccessibilityConfig.getButtonHeight())
        .backgroundColor(AccessibilityConfig.getThemeColor())
        .fontColor('#FFFFFF')
        .fontSize(AccessibilityConfig.getFontSizeButton())
        .borderRadius(AccessibilityConfig.getButtonHeight() / 2)
        .onClick(() => {
          if (this.onRetry) {
            this.onRetry();
          }
        });
    }
    .width('100%')
    .height(300)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center);
  }
}

@Component
export struct EmptyStateView {
  @Prop emptyType: string = 'no_data';
  @Prop customTitle?: string;
  @Prop customDescription?: string;
  @Prop customActionLabel?: string;
  onAction?: () => void;

  getStateInfo(): EmptyStateInfo {
    const defaultState = getEmptyState(this.emptyType);
    return new EmptyStateInfoImpl(
      defaultState.icon,
      this.customTitle || defaultState.title,
      this.customDescription || defaultState.description,
      this.customActionLabel || defaultState.actionLabel
    );
  }

  build() {
    Column({ space: 24 }) {
      Text(this.getStateInfo().icon)
        .fontSize(64);

      Text(this.getStateInfo().title)
        .fontSize(AccessibilityConfig.getFontSizeSubtitle())
        .fontWeight(FontWeight.Bold)
        .fontColor(AccessibilityConfig.getTextPrimary());

      Text(this.getStateInfo().description)
        .fontSize(AccessibilityConfig.getFontSizeBody())
        .fontColor(AccessibilityConfig.getTextSecondary())
        .textAlign(TextAlign.Center)
        .width('75%')
        .maxLines(3)
        .textOverflow({ overflow: TextOverflow.Ellipsis });

      let actionLabel: string | undefined = this.getStateInfo().actionLabel;
      if (actionLabel && this.onAction) {
        Button(actionLabel)
          .width(180)
          .height(AccessibilityConfig.getButtonHeight())
          .backgroundColor(AccessibilityConfig.getThemeColor())
          .fontColor('#FFFFFF')
          .fontSize(AccessibilityConfig.getFontSizeButton())
          .borderRadius(AccessibilityConfig.getButtonHeight() / 2)
          .onClick(() => {
            if (this.onAction) {
              this.onAction();
            }
          });
      }
    }
    .width('100%')
    .height(280)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .accessibilityText(`空状态：${this.getStateInfo().title}`);
  }
}

@Component
export struct LoadingView {
  @Prop loadingText?: string;
  @Prop showProgress: boolean = false;
  @Prop progressValue?: number;

  build() {
    Column({ space: 16 }) {
      LoadingProgress()
        .width(48)
        .height(48)
        .color(AccessibilityConfig.getThemeColor());

      Text(this.loadingText || '加载中...')
        .fontSize(AccessibilityConfig.getFontSizeBody())
        .fontColor(AccessibilityConfig.getTextSecondary());

      if (this.showProgress && this.progressValue !== undefined) {
        Progress({ value: this.progressValue, total: 100, type: ProgressType.Linear })
          .width('60%')
          .color(AccessibilityConfig.getThemeColor())
          .backgroundColor('#F0F0F0');
      }
    }
    .width('100%')
    .height(200)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center);
  }
}

@Component
export struct RetryableContainer {
  @Prop isLoading: boolean = false;
  @Prop hasError: boolean = false;
  @Prop errorType: ErrorType = ErrorType.NETWORK_ERROR;
  @Prop isEmpty: boolean = false;
  @Prop emptyType: string = 'no_data';
  content?: () => void;
  onErrorRetry?: () => void;
  onEmptyAction?: () => void;

  build() {
    if (this.isLoading) {
      LoadingView({});
    } else if (this.hasError) {
      ErrorView({
        errorType: this.errorType,
        onRetry: this.onErrorRetry
      });
    } else if (this.isEmpty) {
      EmptyStateView({
        emptyType: this.emptyType,
        onAction: this.onEmptyAction
      });
    } else {
      if (this.content) {
        this.content();
      }
    }
  }
}
