import { SessionInfo, SessionInfoHelper, PersistedSessionInfo, UserType } from '../models/SessionInfo';
import { AdminInfo } from '../models/AdminInfo';
import { SettingsUtil } from './SettingsUtil';

const SESSION_EXPIRE_TIME: number = 24 * 60 * 60 * 1000;

export class SessionManager {
  private static instance: SessionManager | null = null;

  private constructor() {}

  static getInstance(): SessionManager {
    if (SessionManager.instance === null) {
      SessionManager.instance = new SessionManager();
    }
    return SessionManager.instance;
  }

  async createUserSession(userId: number, username: string, token: string): Promise<SessionInfo> {
    const session: SessionInfo = new SessionInfo();
    session.sessionId = this.generateSessionId();
    session.userId = userId;
    session.userType = UserType.USER;
    session.username = username;
    session.token = token;
    session.loginTime = Date.now();
    session.expireTime = Date.now() + SESSION_EXPIRE_TIME;

    await this.saveSession(session);
    return session;
  }

  async createAdminSession(admin: AdminInfo, token: string): Promise<SessionInfo> {
    const session: SessionInfo = new SessionInfo();
    session.sessionId = this.generateSessionId();
    session.userId = admin.id;
    session.userType = UserType.ADMIN;
    session.username = admin.username;
    session.token = token;
    session.loginTime = Date.now();
    session.expireTime = Date.now() + SESSION_EXPIRE_TIME;

    await this.saveSession(session);
    AppStorage.setOrCreate<AdminInfo | null>('currentAdmin', admin);
    
    return session;
  }

  async saveSession(session: SessionInfo): Promise<void> {
    AppStorage.setOrCreate<SessionInfo | null>('adminSession', session);

    const persisted: Record<string, Object> = {
      'sessionId': session.sessionId,
      'userId': session.userId,
      'userType': session.userType,
      'username': session.username,
      'loginTime': session.loginTime,
      'expireTime': session.expireTime,
      'token': session.token
    };
    
    const settingsUtil: SettingsUtil = SettingsUtil.getInstance();
    await settingsUtil.saveSessionInfo(persisted);
  }

  isSessionValid(): boolean {
    const session: SessionInfo | null = this.getSession();
    return SessionInfoHelper.isValid(session);
  }

  getSession(): SessionInfo | null {
    const session: SessionInfo | undefined = AppStorage.get<SessionInfo>('adminSession');
    if (session && !SessionInfoHelper.isExpired(session)) {
      return session;
    }
    return null;
  }

  async clearSession(): Promise<void> {
    AppStorage.setOrCreate<SessionInfo | null>('adminSession', null);
    AppStorage.setOrCreate<AdminInfo | null>('currentAdmin', null);

    const settingsUtil: SettingsUtil = SettingsUtil.getInstance();
    await settingsUtil.clearSessionInfo();
  }

  async refreshSession(): Promise<boolean> {
    const session: SessionInfo | null = this.getSession();
    if (!session) {
      return false;
    }

    session.expireTime = Date.now() + SESSION_EXPIRE_TIME;
    await this.saveSession(session);
    return true;
  }

  generateSessionId(): string {
    const timestamp: number = Date.now();
    const random: string = Math.random().toString(36).substring(2, 15);
    return `session_${timestamp}_${random}`;
  }

  async loadSessionFromStorage(): Promise<SessionInfo | null> {
    const settingsUtil: SettingsUtil = SettingsUtil.getInstance();
    const persisted: PersistedSessionInfo | null = await settingsUtil.getSessionInfo();
    
    if (!persisted || !persisted.sessionId) {
      return null;
    }

    const session: SessionInfo = new SessionInfo();
    session.sessionId = persisted.sessionId || '';
    session.userId = persisted.userId || 0;
    session.userType = persisted.userType || UserType.USER;
    session.username = persisted.username || '';
    session.loginTime = persisted.loginTime || 0;
    session.expireTime = persisted.expireTime || 0;
    session.token = persisted.token || '';

    if (SessionInfoHelper.isExpired(session)) {
      await this.clearSession();
      return null;
    }

    AppStorage.setOrCreate<SessionInfo | null>('adminSession', session);
    return session;
  }
}
