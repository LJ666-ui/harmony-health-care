import { preferences } from '@kit.ArkData';

const PREFERENCES_NAME: string = 'healthcare_settings';
const ELDER_MODE_KEY: string = 'elder_mode_enabled';
const FONT_SIZE_KEY: string = 'font_size_setting';
const SUBSCRIPTION_PREFIX: string = 'subscription_';
const NOTIFICATION_FREQ_KEY: string = 'notification_frequency';

export type NotificationFrequency = 'immediate' | 'daily' | 'weekly';

export interface SubscriptionInfo {
  categoryId: number;
  categoryName: string;
  isSubscribed: boolean;
}

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

  async getFontSize(): Promise<number> {
    if (this.dataPreferences === null) {
      return 16;
    }
    try {
      const value: preferences.ValueType = await this.dataPreferences.get(FONT_SIZE_KEY, 16);
      return value as number;
    } catch (e) {
      console.error('SettingsUtil - get font size failed:', e);
      return 16;
    }
  }

  async setFontSize(size: number): Promise<void> {
    if (this.dataPreferences === null) {
      return;
    }
    try {
      await this.dataPreferences.put(FONT_SIZE_KEY, size);
      await this.dataPreferences.flush();
    } catch (e) {
      console.error('SettingsUtil - set font size failed:', e);
    }
  }

  getFontSizeSync(): number {
    if (this.dataPreferences === null) {
      return 16;
    }
    try {
      const value: preferences.ValueType = this.dataPreferences.getSync(FONT_SIZE_KEY, 16);
      return value as number;
    } catch (e) {
      console.error('SettingsUtil - get font size sync failed:', e);
      return 16;
    }
  }

  async isSubscribed(categoryId: number): Promise<boolean> {
    if (this.dataPreferences === null) {
      return false;
    }
    try {
      const key: string = SUBSCRIPTION_PREFIX + categoryId.toString();
      const value: preferences.ValueType = await this.dataPreferences.get(key, false);
      return value as boolean;
    } catch (e) {
      console.error('SettingsUtil - check subscription failed:', e);
      return false;
    }
  }

  async setSubscription(categoryId: number, subscribed: boolean): Promise<void> {
    if (this.dataPreferences === null) {
      return;
    }
    try {
      const key: string = SUBSCRIPTION_PREFIX + categoryId.toString();
      await this.dataPreferences.put(key, subscribed);
      await this.dataPreferences.flush();
    } catch (e) {
      console.error('SettingsUtil - set subscription failed:', e);
    }
  }

  async getNotificationFrequency(): Promise<NotificationFrequency> {
    if (this.dataPreferences === null) {
      return 'immediate';
    }
    try {
      const value: preferences.ValueType = await this.dataPreferences.get(NOTIFICATION_FREQ_KEY, 'immediate');
      return value as NotificationFrequency;
    } catch (e) {
      console.error('SettingsUtil - get notification frequency failed:', e);
      return 'immediate';
    }
  }

  async setNotificationFrequency(freq: NotificationFrequency): Promise<void> {
    if (this.dataPreferences === null) {
      return;
    }
    try {
      await this.dataPreferences.put(NOTIFICATION_FREQ_KEY, freq);
      await this.dataPreferences.flush();
    } catch (e) {
      console.error('SettingsUtil - set notification frequency failed:', e);
    }
  }

  getNotificationFrequencySync(): NotificationFrequency {
    if (this.dataPreferences === null) {
      return 'immediate';
    }
    try {
      const value: preferences.ValueType = this.dataPreferences.getSync(NOTIFICATION_FREQ_KEY, 'immediate');
      return value as NotificationFrequency;
    } catch (e) {
      console.error('SettingsUtil - get notification freq sync failed:', e);
      return 'immediate';
    }
  }
}
