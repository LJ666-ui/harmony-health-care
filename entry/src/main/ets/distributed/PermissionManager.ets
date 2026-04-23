import { PermissionLevel, DesensitizeLevel } from '../models/DistributedModels';

interface PermissionEntry {
  recordId: string;
  deviceId: string;
  permissionLevel: PermissionLevel;
  grantedBy: string;
  grantTime: number;
  expireTime?: number;
  isActive: boolean;
  accessLog: AccessLogEntry[];
}

interface AccessLogEntry {
  accessTime: number;
  accessType: string;
  success: boolean;
  reason?: string;
}

interface RolePermission {
  role: string;
  canReadFullRecord: boolean;
  canReadPartialRecord: boolean;
  canReadDesensitizedRecord: boolean;
  canApproveTransfer: boolean;
  canInitiateSync: boolean;
  desensitizeLevel: DesensitizeLevel;
}

export class PermissionManager {
  private permissions: Map<string, PermissionEntry> = new Map();
  private rolePermissions: Map<string, RolePermission> = new Map();

  constructor() {
    this.initializeRolePermissions();
    this.initializeDefaultPermissions();
  }

  private initializeRolePermissions(): void {
    this.rolePermissions.set(PermissionLevel.DOCTOR, {
      role: 'DOCTOR',
      canReadFullRecord: true,
      canReadPartialRecord: true,
      canReadDesensitizedRecord: true,
      canApproveTransfer: true,
      canInitiateSync: true,
      desensitizeLevel: DesensitizeLevel.MINIMAL
    });

    this.rolePermissions.set(PermissionLevel.FAMILY, {
      role: 'FAMILY',
      canReadFullRecord: false,
      canReadPartialRecord: false,
      canReadDesensitizedRecord: true,
      canApproveTransfer: false,
      canInitiateSync: false,
      desensitizeLevel: DesensitizeLevel.FULL
    });

    this.rolePermissions.set(PermissionLevel.PATIENT, {
      role: 'PATIENT',
      canReadFullRecord: false,
      canReadPartialRecord: false,
      canReadDesensitizedRecord: true,
      canApproveTransfer: false,
      canInitiateSync: false,
      desensitizeLevel: DesensitizeLevel.FULL
    });
  }

  private initializeDefaultPermissions(): void {
    const defaultDoctorDeviceId: string = 'device_001_hospital_a';
    const defaultPatientDeviceId: string = 'device_patient_001';
    const defaultFamilyDeviceId: string = 'device_family_001';

    this.grantPermission('MR20260420001', defaultDoctorDeviceId, PermissionLevel.DOCTOR, 'SYSTEM');
    this.grantPermission('MR20260420001', defaultPatientDeviceId, PermissionLevel.PATIENT, 'SYSTEM');
    this.grantPermission('MR20260420001', defaultFamilyDeviceId, PermissionLevel.FAMILY, 'SYSTEM');

    this.grantPermission('MR20260418001', defaultDoctorDeviceId, PermissionLevel.DOCTOR, 'SYSTEM');
    this.grantPermission('MR20260415001', defaultDoctorDeviceId, PermissionLevel.DOCTOR, 'SYSTEM');
  }

  async grantPermission(
    recordId: string,
    deviceId: string,
    permissionLevel: PermissionLevel,
    grantedBy: string,
    durationMs?: number
  ): Promise<boolean> {
    try {
      console.log(
        `[PermissionManager] 授予权限: ${recordId} -> ${deviceId}, 级别: ${permissionLevel}`
      );

      const permissionKey: string = this.generatePermissionKey(recordId, deviceId);

      if (this.permissions.has(permissionKey)) {
        const existing: PermissionEntry | undefined = this.permissions.get(permissionKey);
        if (existing) {
          existing.permissionLevel = permissionLevel;
          existing.grantedBy = grantedBy;
          existing.grantTime = Date.now();
          existing.isActive = true;

          if (durationMs) {
            existing.expireTime = Date.now() + durationMs;
          } else {
            existing.expireTime = undefined;
          }

          this.permissions.set(permissionKey, existing);
        }
      } else {
        const newPermission: PermissionEntry = {
          recordId: recordId,
          deviceId: deviceId,
          permissionLevel: permissionLevel,
          grantedBy: grantedBy,
          grantTime: Date.now(),
          expireTime: durationMs ? Date.now() + durationMs : undefined,
          isActive: true,
          accessLog: []
        };

        this.permissions.set(permissionKey, newPermission);
      }

      console.log(`[PermissionManager] 权限授予成功`);
      return true;
    } catch (error) {
      console.error('[PermissionManager] 授予权限失败:', error);
      return false;
    }
  }

  async revokePermission(recordId: string, deviceId: string): Promise<boolean> {
    try {
      console.log(`[PermissionManager] 撤销权限: ${recordId} -> ${deviceId}`);

      const permissionKey: string = this.generatePermissionKey(recordId, deviceId);
      const permission: PermissionEntry | undefined = this.permissions.get(permissionKey);

      if (!permission) {
        console.warn(`[PermissionManager] 权限不存在: ${permissionKey}`);
        return false;
      }

      permission.isActive = false;
      this.permissions.set(permissionKey, permission);

      console.log(`[PermissionManager] 权限撤销成功`);
      return true;
    } catch (error) {
      console.error('[PermissionManager] 撤销权限失败:', error);
      return false;
    }
  }

  async checkPermission(
    recordId: string,
    deviceId: string,
    requiredLevel: PermissionLevel
  ): Promise<boolean> {
    try {
      const permissionKey: string = this.generatePermissionKey(recordId, deviceId);
      const permission: PermissionEntry | undefined = this.permissions.get(permissionKey);

      if (!permission || !permission.isActive) {
        console.warn(`[PermissionManager] 无访问权限: ${permissionKey}`);
        await this.logAccess(recordId, deviceId, 'READ', false, '无权限');
        return false;
      }

      if (permission.expireTime && Date.now() > permission.expireTime) {
        console.warn(`[PermissionManager] 权限已过期: ${permissionKey}`);
        permission.isActive = false;
        this.permissions.set(permissionKey, permission);
        await this.logAccess(recordId, deviceId, 'READ', false, '权限已过期');
        return false;
      }

      const hierarchy: Record<string, number> = {
        [PermissionLevel.PATIENT]: 1,
        [PermissionLevel.FAMILY]: 2,
        [PermissionLevel.DOCTOR]: 3
      };

      const currentLevel: number = hierarchy[permission.permissionLevel] || 0;
      const requiredLevelNum: number = hierarchy[requiredLevel] || 0;

      if (currentLevel < requiredLevelNum) {
        console.warn(
          `[PermissionManager] 权限级别不足: 当前${permission.permissionLevel}, 需要${requiredLevel}`
        );
        await this.logAccess(recordId, deviceId, 'READ', false, '权限级别不足');
        return false;
      }

      await this.logAccess(recordId, deviceId, 'READ', true);
      console.log(`[PermissionManager] 权限检查通过: ${permissionKey}`);
      return true;
    } catch (error) {
      console.error('[PermissionManager] 权限检查失败:', error);
      return false;
    }
  }

  getDesensitizeLevel(deviceId: string, recordId: string): DesensitizeLevel {
    const permissionKey: string = this.generatePermissionKey(recordId, deviceId);
    const permission: PermissionEntry | undefined = this.permissions.get(permissionKey);

    if (!permission || !permission.isActive) {
      return DesensitizeLevel.FULL;
    }

    const rolePerm: RolePermission | undefined =
      this.rolePermissions.get(permission.permissionLevel);

    return rolePerm ? rolePerm.desensitizeLevel : DesensitizeLevel.FULL;
  }

  getRolePermissions(role: string): RolePermission | null {
    return this.rolePermissions.get(role) || null;
  }

  getPermissionEntriesForRecord(recordId: string): PermissionEntry[] {
    const entries: PermissionEntry[] = [];
    this.permissions.forEach((value: PermissionEntry) => {
      if (value.recordId === recordId && value.isActive) {
        entries.push(value);
      }
    });
    return entries;
  }

  getPermissionEntriesForDevice(deviceId: string): PermissionEntry[] {
    const entries: PermissionEntry[] = [];
    this.permissions.forEach((value: PermissionEntry) => {
      if (value.deviceId === deviceId && value.isActive) {
        entries.push(value);
      }
    });
    return entries;
  }

  private generatePermissionKey(recordId: string, deviceId: string): string {
    return `${recordId}_${deviceId}`;
  }

  private async logAccess(
    recordId: string,
    deviceId: string,
    accessType: string,
    success: boolean,
    reason?: string
  ): Promise<void> {
    const permissionKey: string = this.generatePermissionKey(recordId, deviceId);
    const permission: PermissionEntry | undefined = this.permissions.get(permissionKey);

    if (permission) {
      const logEntry: AccessLogEntry = {
        accessTime: Date.now(),
        accessType: accessType,
        success: success,
        reason: reason
      };

      permission.accessLog.push(logEntry);

      if (permission.accessLog.length > 100) {
        permission.accessLog = permission.accessLog.slice(-100);
      }

      this.permissions.set(permissionKey, permission);
    }
  }

  cleanupExpiredPermissions(): number {
    let cleanedCount: number = 0;
    const now: number = Date.now();

    this.permissions.forEach((permission: PermissionEntry, key: string) => {
      if (permission.expireTime && now > permission.expireTime) {
        permission.isActive = false;
        this.permissions.set(key, permission);
        cleanedCount++;
      }
    });

    if (cleanedCount > 0) {
      console.log(`[PermissionManager] 清理了 ${cleanedCount} 个过期权限`);
    }

    return cleanedCount;
  }
}
