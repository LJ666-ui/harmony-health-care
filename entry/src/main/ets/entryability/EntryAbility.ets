import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { display, window } from '@kit.ArkUI';
import { AccessibilityConfig, FontSizeLevel, ColorMode, AnimationMode } from '../utils/AccessibilityConfig';
import { BreakpointSystem, BreakpointType } from '../utils/BreakpointSystem';
import RdbHelper from '../utils/RdbHelper';
import { SettingsUtil } from '../utils/SettingsUtil';
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
const CREATE_TABLE_HOSPITAL_CACHE = `
  CREATE TABLE IF NOT EXISTS local_hospital_cache (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    address TEXT,
    phone TEXT,
    level TEXT,
    department TEXT,
    description TEXT,
    longitude REAL,
    latitude REAL,
    cached_time INTEGER NOT NULL,
    data_source TEXT DEFAULT 'server'
  )
`;

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }

    this.initAccessibilitySettings();
    this.initDatabase();
    this.initSettingsUtil();

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
      
      // 创建医院缓存表
      await RdbHelper.executeSql(CREATE_TABLE_HOSPITAL_CACHE);
      
      // 创建医院缓存表索引
      await RdbHelper.executeSql('CREATE INDEX IF NOT EXISTS idx_hospital_level ON local_hospital_cache(level)');
      await RdbHelper.executeSql('CREATE INDEX IF NOT EXISTS idx_hospital_name ON local_hospital_cache(name)');
      
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

  private async initSettingsUtil(): Promise<void> {
    try {
      const settings: SettingsUtil = SettingsUtil.getInstance();
      await settings.init(this.context);
      hilog.info(DOMAIN, 'testTag', '%{public}s', 'SettingsUtil (Preferences) initialized successfully');
    } catch (error) {
      hilog.error(DOMAIN, 'testTag', 'Failed to initialize SettingsUtil: %{public}s', JSON.stringify(error));
    }
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    this.initBreakpointSystem(windowStage);
    this.setWindowLayoutFullScreen(windowStage);

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  private initBreakpointSystem(windowStage: window.WindowStage): void {
    try {
      const mainWindow = windowStage.getMainWindowSync();
      const properties = mainWindow.getWindowProperties();
      const windowRect = properties.windowRect;
      const breakpointSystem = BreakpointSystem.getInstance();
      breakpointSystem.updateBreakpoint(px2vp(windowRect.width));

      AppStorage.setOrCreate<BreakpointType>('currentBreakpoint', breakpointSystem.getCurrentBreakpoint());
      AppStorage.setOrCreate<number>('windowWidth', px2vp(windowRect.width));
      AppStorage.setOrCreate<number>('windowHeight', px2vp(windowRect.height));

      mainWindow.on('windowSizeChange', (size: window.Size) => {
        const width = px2vp(size.width);
        const height = px2vp(size.height);
        breakpointSystem.updateBreakpoint(width);
        AppStorage.setOrCreate<BreakpointType>('currentBreakpoint', breakpointSystem.getCurrentBreakpoint());
        AppStorage.setOrCreate<number>('windowWidth', width);
        AppStorage.setOrCreate<number>('windowHeight', height);
        hilog.info(DOMAIN, 'testTag', 'Window size changed: %{public}f x %{public}f, breakpoint: %{public}s',
          width, height, breakpointSystem.getCurrentBreakpoint());
      });

      hilog.info(DOMAIN, 'testTag', 'BreakpointSystem initialized: %{public}s (%{public}f x %{public}f)',
        breakpointSystem.getCurrentBreakpoint(), px2vp(windowRect.width), px2vp(windowRect.height));
    } catch (error) {
      hilog.error(DOMAIN, 'testTag', 'Failed to init BreakpointSystem: %{public}s', JSON.stringify(error));
    }
  }

  private setWindowLayoutFullScreen(windowStage: window.WindowStage): void {
    try {
      const mainWindow = windowStage.getMainWindowSync();
      const sysBarProps: window.SystemBarProperties = {
        statusBarColor: '#00000000',
        statusBarContentColor: '#333333',
        navigationBarColor: '#00000000',
        navigationBarContentColor: '#333333'
      };
      mainWindow.setWindowLayoutFullScreen(true);
      mainWindow.setSystemBarProperties(sysBarProps);

      const topAvoidArea = mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      const defaultRect: window.Rect = { top: 0, height: 0, left: 0, width: 0 };
      const topRect = topAvoidArea.visible ? topAvoidArea.topRect : defaultRect;
      AppStorage.setOrCreate<number>('statusBarHeight', px2vp(topRect.height));

      const bottomAvoidArea = mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
      const bottomRect = bottomAvoidArea.visible ? bottomAvoidArea.bottomRect : defaultRect;
      AppStorage.setOrCreate<number>('navigationBarHeight', px2vp(bottomRect.height));
    } catch (error) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set full screen layout: %{public}s', JSON.stringify(error));
    }
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