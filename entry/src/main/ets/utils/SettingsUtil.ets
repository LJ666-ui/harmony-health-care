import { preferences } from '@kit.ArkData';

const PREFERENCES_NAME: string = 'healthcare_settings';
const ELDER_MODE_KEY: string = 'elder_mode_enabled';

export class SettingsUtil {
  private static instance: SettingsUtil | null = null;
  private dataPreferences: preferences.Preferences | null = null;

  static getInstance(): SettingsUtil {
    if (SettingsUtil.instance === null) {
      SettingsUtil.instance = new SettingsUtil();
    }
    return SettingsUtil.instance;
  }

  async init(context: Context): Promise<void> {
    this.dataPreferences = await preferences.getPreferences(context, PREFERENCES_NAME);
  }

  async isElderMode(): Promise<boolean> {
    if (this.dataPreferences === null) {
      return false;
    }
    try {
      const value: preferences.ValueType = await this.dataPreferences.get(ELDER_MODE_KEY, false);
      return value as boolean;
    } catch (e) {
      console.error('SettingsUtil - get elder mode failed:', e);
      return false;
    }
  }

  async setElderMode(enabled: boolean): Promise<void> {
    if (this.dataPreferences === null) {
      return;
    }
    try {
      await this.dataPreferences.put(ELDER_MODE_KEY, enabled);
      await this.dataPreferences.flush();
    } catch (e) {
      console.error('SettingsUtil - set elder mode failed:', e);
    }
  }

  getElderModeSync(): boolean {
    if (this.dataPreferences === null) {
      return false;
    }
    try {
      const value: preferences.ValueType = this.dataPreferences.getSync(ELDER_MODE_KEY, false);
      return value as boolean;
    } catch (e) {
      console.error('SettingsUtil - get elder mode sync failed:', e);
      return false;
    }
  }
}
