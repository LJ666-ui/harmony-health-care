export enum UserType {
  USER = 'user',
  ADMIN = 'admin'
}

export class SessionInfo {
  sessionId: string = '';
  userId: number = 0;
  userType: string = UserType.USER;
  username: string = '';
  loginTime: number = 0;
  expireTime: number = 0;
  token: string = '';

  constructor() {}
}

export class SessionInfoHelper {
  static fromJson(raw: Record<string, Object>): SessionInfo {
    const session: SessionInfo = new SessionInfo();
    if (raw['sessionId'] !== undefined) { session.sessionId = raw['sessionId'] as string; }
    if (raw['userId'] !== undefined) { session.userId = raw['userId'] as number; }
    if (raw['userType'] !== undefined) { session.userType = raw['userType'] as string; }
    if (raw['username'] !== undefined) { session.username = raw['username'] as string; }
    if (raw['loginTime'] !== undefined) { session.loginTime = raw['loginTime'] as number; }
    if (raw['expireTime'] !== undefined) { session.expireTime = raw['expireTime'] as number; }
    if (raw['token'] !== undefined) { session.token = raw['token'] as string; }
    return session;
  }

  static toJson(session: SessionInfo): Record<string, Object> {
    const map: Record<string, Object> = {};
    map['sessionId'] = session.sessionId;
    map['userId'] = session.userId;
    map['userType'] = session.userType;
    map['username'] = session.username;
    map['loginTime'] = session.loginTime;
    map['expireTime'] = session.expireTime;
    map['token'] = session.token;
    return map;
  }

  static isValid(session: SessionInfo | null): boolean {
    if (!session) {
      return false;
    }
    const now: number = Date.now();
    return session.expireTime > now && session.token.length > 0;
  }

  static isAdmin(session: SessionInfo | null): boolean {
    if (!session) {
      return false;
    }
    return session.userType === UserType.ADMIN;
  }

  static isExpired(session: SessionInfo | null): boolean {
    if (!session) {
      return true;
    }
    return Date.now() >= session.expireTime;
  }

  static getRemainingTime(session: SessionInfo | null): number {
    if (!session) {
      return 0;
    }
    const remaining: number = session.expireTime - Date.now();
    return remaining > 0 ? remaining : 0;
  }
}

export interface PersistedSessionInfo {
  sessionId?: string;
  userId?: number;
  userType?: string;
  username?: string;
  loginTime?: number;
  expireTime?: number;
  token?: string;
}
