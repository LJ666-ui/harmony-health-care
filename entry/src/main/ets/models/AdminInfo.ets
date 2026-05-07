export enum AdminRole {
  SUPER_ADMIN = 1,
  NORMAL_ADMIN = 2
}

export class AdminRoleLabel {
  static getLabel(role: number): string {
    if (role === AdminRole.SUPER_ADMIN) {
      return '超级管理员';
    } else if (role === AdminRole.NORMAL_ADMIN) {
      return '普通管理员';
    }
    return '未知角色';
  }
}

export class AdminInfo {
  id: number = 0;
  username: string = '';
  password: string = '';
  realName: string = '';
  phone: string = '';
  email: string = '';
  role: number = AdminRole.NORMAL_ADMIN;
  status: number = 1;
  lastLoginTime: string = '';
  createTime: string = '';
  updateTime: string = '';

  constructor() {}
}

export class AdminInfoHelper {
  static fromJson(raw: Record<string, Object>): AdminInfo {
    const info: AdminInfo = new AdminInfo();
    if (raw['id'] !== undefined) { info.id = raw['id'] as number; }
    if (raw['username'] !== undefined) { info.username = raw['username'] as string; }
    if (raw['password'] !== undefined) { info.password = raw['password'] as string; }
    if (raw['realName'] !== undefined) { info.realName = raw['realName'] as string; }
    if (raw['phone'] !== undefined) { info.phone = raw['phone'] as string; }
    if (raw['email'] !== undefined) { info.email = raw['email'] as string; }
    if (raw['role'] !== undefined) { info.role = raw['role'] as number; }
    if (raw['status'] !== undefined) { info.status = raw['status'] as number; }
    if (raw['lastLoginTime'] !== undefined) { info.lastLoginTime = raw['lastLoginTime'] as string; }
    if (raw['createTime'] !== undefined) { info.createTime = raw['createTime'] as string; }
    if (raw['updateTime'] !== undefined) { info.updateTime = raw['updateTime'] as string; }
    return info;
  }

  static toJson(info: AdminInfo): Record<string, Object> {
    const map: Record<string, Object> = {};
    map['id'] = info.id;
    map['username'] = info.username;
    map['realName'] = info.realName;
    map['phone'] = info.phone;
    map['email'] = info.email;
    map['role'] = info.role;
    map['status'] = info.status;
    return map;
  }

  static getDisplayName(info: AdminInfo): string {
    if (info.realName && info.realName.trim() !== '') {
      return info.realName;
    }
    return info.username || '管理员';
  }

  static getRoleLabel(role: number): string {
    return AdminRoleLabel.getLabel(role);
  }

  static isSuperAdmin(info: AdminInfo): boolean {
    return info.role === AdminRole.SUPER_ADMIN;
  }

  static maskPhone(phone: string): string {
    if (!phone || phone.length < 7) {
      return phone;
    }
    return phone.substring(0, 3) + '****' + phone.substring(phone.length - 4);
  }
}

export interface AdminLoginRequest {
  username: string;
  password: string;
}

export interface AdminLoginResponse {
  success: boolean;
  message: string;
  admin?: AdminInfo;
  token?: string;
}

export interface CreateAdminRequest {
  username: string;
  password: string;
  realName: string;
  phone?: string;
  email?: string;
  role: number;
}

export interface UpdateAdminRequest {
  id: number;
  realName?: string;
  phone?: string;
  email?: string;
  role?: number;
  status?: number;
}

export interface QueryAdminParams {
  page?: number;
  pageSize?: number;
  keyword?: string;
}
