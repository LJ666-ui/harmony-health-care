import { preferences } from '@kit.ArkData';

const PREFERENCES_NAME: string = 'healthcare_settings';
const ELDER_MODE_KEY: string = 'elder_mode_enabled';
const TOKEN_KEY: string = 'auth_token';
const USER_INFO_KEY: string = 'user_info';
const IS_LOGGED_IN_KEY: string = 'is_logged_in';
const SESSION_INFO_KEY: string = 'session_info';

export interface PersistedDoctorInfo {
  id?: number;
  realName?: string;
  phone?: string;
  hospital?: string;
  department?: string;
  licenseNumber?: string;
  title?: string;
  specialty?: string;
  avatar?: string;
  description?: string;
  rating?: number;
  status?: number;
}

export interface PersistedUserInfo {
  userId?: number;
  username: string;
  userType?: number;
  avatar?: string;
  age?: number;
  gender?: string;
  doctorInfo?: PersistedDoctorInfo;
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
    try {
      this.dataPreferences = await preferences.getPreferences(context, PREFERENCES_NAME);
    } catch (e) {
      console.error('SettingsUtil - init failed:', e);
    }
  }

  async isElderMode(): Promise<boolean> {
    if (this.dataPreferences === null) {
      return false;
    }
    try {
      const value: preferences.ValueType = await this.dataPreferences.get(ELDER_MODE_KEY, false);
      return typeof value === 'boolean' ? value : false;
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
      return typeof value === 'boolean' ? value : false;
    } catch (e) {
      console.error('SettingsUtil - get elder mode sync failed:', e);
      return false;
    }
  }

  async getToken(): Promise<string> {
    if (this.dataPreferences === null) {
      return '';
    }
    try {
      const value: preferences.ValueType = await this.dataPreferences.get(TOKEN_KEY, '');
      return value as string;
    } catch (e) {
      console.error('SettingsUtil - get token failed:', e);
      return '';
    }
  }

  async saveToken(token: string): Promise<void> {
    if (this.dataPreferences === null) {
      return;
    }
    try {
      await this.dataPreferences.put(TOKEN_KEY, token);
      await this.dataPreferences.put(IS_LOGGED_IN_KEY, true);
      await this.dataPreferences.flush();
      AppStorage.setOrCreate<string>('token', token);
      AppStorage.setOrCreate<boolean>('isLoggedIn', true);
    } catch (e) {
      console.error('SettingsUtil - save token failed:', e);
    }
  }

  async clearToken(): Promise<void> {
    if (this.dataPreferences === null) {
      return;
    }
    try {
      await this.dataPreferences.delete(TOKEN_KEY);
      await this.dataPreferences.put(IS_LOGGED_IN_KEY, false);
      await this.dataPreferences.flush();
      AppStorage.setOrCreate<string>('token', '');
      AppStorage.setOrCreate<boolean>('isLoggedIn', false);
    } catch (e) {
      console.error('SettingsUtil - clear token failed:', e);
    }
  }

  async isLoggedIn(): Promise<boolean> {
    if (this.dataPreferences === null) {
      return false;
    }
    try {
      const value: preferences.ValueType = await this.dataPreferences.get(IS_LOGGED_IN_KEY, false);
      let isLoggedIn: boolean = false;
      if (typeof value === 'boolean') {
        isLoggedIn = !!value;
      }
      if (isLoggedIn) {
        const token: string = await this.getToken();
        return token.length > 0;
      }
      return false;
    } catch (e) {
      console.error('SettingsUtil - check login status failed:', e);
      return false;
    }
  }

  async getUserInfo(): Promise<PersistedUserInfo | null> {
    if (this.dataPreferences === null) {
      return null;
    }
    try {
      const value: preferences.ValueType = await this.dataPreferences.get(USER_INFO_KEY, '{}');
      const jsonStr: string = value as string;
      if (jsonStr && jsonStr !== '{}' && jsonStr !== '') {
        return JSON.parse(jsonStr) as PersistedUserInfo;
      }
      return null;
    } catch (e) {
      console.error('SettingsUtil - get user info failed:', e);
      return null;
    }
  }

  async saveUserInfo(userInfo: PersistedUserInfo): Promise<void> {
    if (this.dataPreferences === null) {
      return;
    }
    try {
      const jsonStr: string = JSON.stringify(userInfo);
      await this.dataPreferences.put(USER_INFO_KEY, jsonStr);
      await this.dataPreferences.flush();
      AppStorage.setOrCreate<PersistedUserInfo | null>('userInfo', userInfo);
      AppStorage.setOrCreate<string>('username', userInfo.username || '');
      if (userInfo.userId) {
        AppStorage.setOrCreate<number>('userId', userInfo.userId);
      }
    } catch (e) {
      console.error('SettingsUtil - save user info failed:', e);
    }
  }

  async clearAllLoginData(): Promise<void> {
    if (this.dataPreferences === null) {
      return;
    }
    try {
      await this.dataPreferences.delete(TOKEN_KEY);
      await this.dataPreferences.delete(USER_INFO_KEY);
      await this.dataPreferences.put(IS_LOGGED_IN_KEY, false);
      await this.dataPreferences.flush();
      AppStorage.setOrCreate<string>('token', '');
      AppStorage.setOrCreate<PersistedUserInfo | null>('userInfo', null);
      AppStorage.setOrCreate<string>('username', '');
      AppStorage.setOrCreate<number>('userId', 0);
      AppStorage.setOrCreate<boolean>('isLoggedIn', false);
    } catch (e) {
      console.error('SettingsUtil - clear all login data failed:', e);
    }
  }

  getTokenSync(): string {
    if (this.dataPreferences === null) {
      return '';
    }
    try {
      const value: preferences.ValueType = this.dataPreferences.getSync(TOKEN_KEY, '');
      return value as string;
    } catch (e) {
      console.error('SettingsUtil - get token sync failed:', e);


      return '';
    }
  }

  isLoggedInSync(): boolean {
    if (this.dataPreferences === null) {
      return false;
    }
    try {
      const value: preferences.ValueType = this.dataPreferences.getSync(IS_LOGGED_IN_KEY, false);
      let isLoggedIn: boolean = false;
      if (typeof value === 'boolean') {
        isLoggedIn = !!value;
      }
      if (isLoggedIn) {
        const token: string = this.getTokenSync();
        return token.length > 0;
      }
      return false;
    } catch (e) {
      console.error('SettingsUtil - check login status sync failed:', e);
      return false;
    }
  }

  async saveSessionInfo(sessionInfo: Record<string, Object>): Promise<void> {
    if (this.dataPreferences === null) {
      return;
    }
    try {
      const jsonStr: string = JSON.stringify(sessionInfo);
      await this.dataPreferences.put(SESSION_INFO_KEY, jsonStr);
      await this.dataPreferences.flush();
    } catch (e) {
      console.error('SettingsUtil - save session info failed:', e);
    }
  }

  async getSessionInfo(): Promise<Record<string, Object> | null> {
    if (this.dataPreferences === null) {
      return null;
    }
    try {
      const value: preferences.ValueType = await this.dataPreferences.get(SESSION_INFO_KEY, '{}');
      const jsonStr: string = value as string;
      if (jsonStr && jsonStr !== '{}' && jsonStr !== '') {
        return JSON.parse(jsonStr) as Record<string, Object>;
      }
      return null;
    } catch (e) {
      console.error('SettingsUtil - get session info failed:', e);
      return null;
    }
  }

  async clearSessionInfo(): Promise<void> {
    if (this.dataPreferences === null) {
      return;
    }
    try {
      await this.dataPreferences.delete(SESSION_INFO_KEY);
      await this.dataPreferences.flush();
    } catch (e) {
      console.error('SettingsUtil - clear session info failed:', e);
    }
  }

  // ========== 家属相关方法 ==========

  /**
   * 保存家属Token
   */
  async saveFamilyToken(token: string): Promise<void> {
    if (this.dataPreferences === null) {
      return;
    }
    try {
      await this.dataPreferences.put('family_token', token);
      await this.dataPreferences.flush();
    } catch (e) {
      console.error('SettingsUtil - save family token failed:', e);
    }
  }

  /**
   * 获取家属Token
   */
  async getFamilyToken(): Promise<string> {
    if (this.dataPreferences === null) {
      return '';
    }
    try {
      const value: preferences.ValueType = await this.dataPreferences.get('family_token', '');
      return value as string;
    } catch (e) {
      console.error('SettingsUtil - get family token failed:', e);
      return '';
    }
  }

  /**
   * 同步获取家属Token
   */
  getFamilyTokenSync(): string {
    if (this.dataPreferences === null) {
      return '';
    }
    try {
      const value: preferences.ValueType = this.dataPreferences.getSync('family_token', '');
      return value as string;
    } catch (e) {
      console.error('SettingsUtil - get family token sync failed:', e);
      return '';
    }
  }

  /**
   * 保存家属信息
   */
  async saveFamilyInfo(familyInfo: object): Promise<void> {
    if (this.dataPreferences === null) {
      return;
    }
    try {
      const jsonStr: string = JSON.stringify(familyInfo);
      await this.dataPreferences.put('family_info', jsonStr);
      await this.dataPreferences.flush();
    } catch (e) {
      console.error('SettingsUtil - save family info failed:', e);
    }
  }

  /**
   * 获取家属信息
   */
  async getFamilyInfo(): Promise<object | null> {
    if (this.dataPreferences === null) {
      return null;
    }
    try {
      const value: preferences.ValueType = await this.dataPreferences.get('family_info', '{}');
      const jsonStr: string = value as string;
      if (jsonStr && jsonStr !== '{}' && jsonStr !== '') {
        return JSON.parse(jsonStr);
      }
      return null;
    } catch (e) {
      console.error('SettingsUtil - get family info failed:', e);
      return null;
    }
  }

  /**
   * 清除家属认证信息
   */
  async clearFamilyAuth(): Promise<void> {
    if (this.dataPreferences === null) {
      return;
    }
    try {
      await this.dataPreferences.delete('family_token');
      await this.dataPreferences.delete('family_info');
      await this.dataPreferences.flush();
    } catch (e) {
      console.error('SettingsUtil - clear family auth failed:', e);
    }
  }

  /**
   * 检查家属是否已登录
   */
  async isFamilyLoggedIn(): Promise<boolean> {
    if (this.dataPreferences === null) {
      return false;
    }
    try {
      const token: string = await this.getFamilyToken();
      return token.length > 0;
    } catch (e) {
      console.error('SettingsUtil - check family login status failed:', e);
      return false;
    }
  }

  // ==================== 护士相关方法 ====================

  /**
   * 保存护士Token
   */
  async saveNurseToken(token: string): Promise<void> {
    if (this.dataPreferences === null) {
      return;
    }
    try {
      await this.dataPreferences.put('nurse_token', token);
      await this.dataPreferences.flush();
    } catch (e) {
      console.error('SettingsUtil - save nurse token failed:', e);
    }
  }

  /**
   * 获取护士Token
   */
  async getNurseToken(): Promise<string> {
    if (this.dataPreferences === null) {
      return '';
    }
    try {
      const value: preferences.ValueType = await this.dataPreferences.get('nurse_token', '');
      return value as string;
    } catch (e) {
      console.error('SettingsUtil - get nurse token failed:', e);
      return '';
    }
  }

  /**
   * 同步获取护士Token
   */
  getNurseTokenSync(): string {
    if (this.dataPreferences === null) {
      return '';
    }
    try {
      const value: preferences.ValueType = this.dataPreferences.getSync('nurse_token', '');
      return value as string;
    } catch (e) {
      console.error('SettingsUtil - get nurse token sync failed:', e);
      return '';
    }
  }

  /**
   * 保存护士信息
   */
  async saveNurseInfo(nurseInfo: object): Promise<void> {
    if (this.dataPreferences === null) {
      return;
    }
    try {
      const jsonStr: string = JSON.stringify(nurseInfo);
      await this.dataPreferences.put('nurse_info', jsonStr);
      await this.dataPreferences.flush();
    } catch (e) {
      console.error('SettingsUtil - save nurse info failed:', e);
    }
  }

  /**
   * 获取护士信息
   */
  async getNurseInfo(): Promise<object | null> {
    if (this.dataPreferences === null) {
      return null;
    }
    try {
      const value: preferences.ValueType = await this.dataPreferences.get('nurse_info', '{}');
      const jsonStr: string = value as string;
      if (jsonStr && jsonStr !== '{}' && jsonStr !== '') {
        return JSON.parse(jsonStr);
      }
      return null;
    } catch (e) {
      console.error('SettingsUtil - get nurse info failed:', e);
      return null;
    }
  }

  /**
   * 清除护士认证信息
   */
  async clearNurseAuth(): Promise<void> {
    if (this.dataPreferences === null) {
      return;
    }
    try {
      await this.dataPreferences.delete('nurse_token');
      await this.dataPreferences.delete('nurse_info');
      await this.dataPreferences.flush();
    } catch (e) {
      console.error('SettingsUtil - clear nurse auth failed:', e);
    }
  }

  /**
   * 检查护士是否已登录
   */
  async isNurseLoggedIn(): Promise<boolean> {
    if (this.dataPreferences === null) {
      return false;
    }
    try {
      const token: string = await this.getNurseToken();
      return token.length > 0;
    } catch (e) {
      console.error('SettingsUtil - check nurse login status failed:', e);
      return false;
    }
  }
}
