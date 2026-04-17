import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AccessibilityConfig, FontSizeLevel, ColorMode, AnimationMode } from '../utils/AccessibilityConfig';
import RdbHelper from '../utils/RdbHelper';
import {
  CREATE_TABLE_USER_CACHE,
  CREATE_TABLE_OFFLINE_HEALTH_RECORD,
  CREATE_TABLE_ARTICLE_CACHE,
  CREATE_TABLE_DEVICE_CACHE,
  CREATE_TABLE_SYNC_QUEUE,
  CREATE_TABLE_BROWSE_HISTORY,
  CREATE_TABLE_SEARCH_HISTORY,
  CREATE_TABLE_COLLECTION_CACHE
} from '../utils/DatabaseConstants';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }

    this.initAccessibilitySettings();
    this.initDatabase();

    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  private async initDatabase(): Promise<void> {
    try {
      // 初始化数据库
      await RdbHelper.init(this.context);
      
      // 执行建表语句
      await RdbHelper.executeSql(CREATE_TABLE_USER_CACHE);
      await RdbHelper.executeSql(CREATE_TABLE_OFFLINE_HEALTH_RECORD);
      await RdbHelper.executeSql(CREATE_TABLE_ARTICLE_CACHE);
      await RdbHelper.executeSql(CREATE_TABLE_DEVICE_CACHE);
      await RdbHelper.executeSql(CREATE_TABLE_SYNC_QUEUE);
      await RdbHelper.executeSql(CREATE_TABLE_BROWSE_HISTORY);
      await RdbHelper.executeSql(CREATE_TABLE_SEARCH_HISTORY);
      await RdbHelper.executeSql(CREATE_TABLE_COLLECTION_CACHE);
      
      hilog.info(DOMAIN, 'testTag', 'SQLite DB initialized successfully');
    } catch (error) {
      hilog.error(DOMAIN, 'testTag', 'Failed to initialize database: %{public}s', JSON.stringify(error));
      // 建表失败不影响App启动
    }
  }

  private initAccessibilitySettings(): void {
    if (AppStorage.get<string>('fontSizeLevel') === undefined) {
      AppStorage.setOrCreate<string>('fontSizeLevel', FontSizeLevel.MEDIUM);
    }
    if (AppStorage.get<string>('colorMode') === undefined) {
      AppStorage.setOrCreate<string>('colorMode', ColorMode.NORMAL);
    }
    if (AppStorage.get<string>('animationMode') === undefined) {
      AppStorage.setOrCreate<string>('animationMode', AnimationMode.NORMAL);
    }
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    }
    if (AppStorage.get<boolean>('ttsEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('ttsEnabled', false);
    }
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Accessibility settings initialized');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}