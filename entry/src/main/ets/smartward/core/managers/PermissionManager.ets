/**
 * 权限管理器
 * 基于角色控制设备操作权限
 */

import { UserRole } from '../../../models/SmartWardEnums';
import { DeviceType } from '../../../models/SmartWardDeviceModels';

/**
 * 用户信息接口
 */
export interface UserInfo {
  userId: string;
  userName: string;
  role: UserRole;
  assignedRooms?: string[];  // 负责的房间ID列表（护士用）
  roomId?: string;           // 所在房间ID（患者用）
}

/**
 * 权限管理器单例类
 */
export class PermissionManager {
  private static instance: PermissionManager;

  // 当前登录用户
  private currentUser: UserInfo | null = null;

  private constructor() {
    console.log('PermissionManager initialized');
  }

  /**
   * 获取权限管理器单例实例
   */
  public static getInstance(): PermissionManager {
    if (!PermissionManager.instance) {
      PermissionManager.instance = new PermissionManager();
    }
    return PermissionManager.instance;
  }

  /**
   * 设置当前用户
   */
  public setCurrentUser(user: UserInfo): void {
    this.currentUser = user;
    console.log(`PermissionManager: Current user set - ${user.userName} (${user.role})`);
  }

  /**
   * 获取当前用户
   */
  public getCurrentUser(): UserInfo | null {
    return this.currentUser;
  }

  /**
   * 检查是否可以控制设备
   */
  public canControlDevice(deviceId: string, deviceType: DeviceType, roomId: string): boolean {
    if (!this.currentUser) {
      console.warn('PermissionManager: No current user');
      return false;
    }

    const role = this.currentUser.role;

    // 护士长可以控制所有设备
    if (role === UserRole.HEAD_NURSE) {
      return true;
    }

    // 护士只能控制负责房间的设备
    if (role === UserRole.NURSE) {
      const assignedRooms = this.currentUser.assignedRooms || [];
      if (assignedRooms.includes(roomId)) {
        return true;
      }
      console.warn(`PermissionManager: Nurse ${this.currentUser.userName} cannot control device in room ${roomId}`);
      return false;
    }

    // 患者只能控制自己房间的灯光、电视和呼叫按钮
    if (role === UserRole.PATIENT) {
      if (this.currentUser.roomId !== roomId) {
        console.warn(`PermissionManager: Patient ${this.currentUser.userName} cannot control device in room ${roomId}`);
        return false;
      }

      const allowedTypes = [
        DeviceType.SMART_LIGHT,
        DeviceType.SMART_TV,
        DeviceType.CALL_BUTTON
      ];

      if (allowedTypes.includes(deviceType)) {
        return true;
      }

      console.warn(`PermissionManager: Patient ${this.currentUser.userName} cannot control device type ${deviceType}`);
      return false;
    }

    return false;
  }

  /**
   * 检查是否可以查看患者信息
   */
  public canViewPatientInfo(patientRoomId: string): boolean {
    if (!this.currentUser) {
      console.warn('PermissionManager: No current user');
      return false;
    }

    const role = this.currentUser.role;

    // 护士长可以查看所有患者信息
    if (role === UserRole.HEAD_NURSE) {
      return true;
    }

    // 护士只能查看负责房间的患者信息
    if (role === UserRole.NURSE) {
      const assignedRooms = this.currentUser.assignedRooms || [];
      return assignedRooms.includes(patientRoomId);
    }

    // 患者只能查看自己的信息
    if (role === UserRole.PATIENT) {
      return this.currentUser.roomId === patientRoomId;
    }

    return false;
  }

  /**
   * 检查是否可以确认告警
   */
  public canAcknowledgeAlert(alertRoomId: string): boolean {
    if (!this.currentUser) {
      console.warn('PermissionManager: No current user');
      return false;
    }

    const role = this.currentUser.role;

    // 护士长可以确认所有告警
    if (role === UserRole.HEAD_NURSE) {
      return true;
    }

    // 护士只能确认负责房间的告警
    if (role === UserRole.NURSE) {
      const assignedRooms = this.currentUser.assignedRooms || [];
      return assignedRooms.includes(alertRoomId);
    }

    // 患者不能确认告警
    return false;
  }

  /**
   * 检查是否可以管理规则
   */
  public canManageRules(): boolean {
    if (!this.currentUser) {
      return false;
    }

    // 只有护士长可以管理规则
    return this.currentUser.role === UserRole.HEAD_NURSE;
  }

  /**
   * 检查是否可以管理设备
   */
  public canManageDevices(): boolean {
    if (!this.currentUser) {
      return false;
    }

    // 护士长和护士都可以管理设备
    return this.currentUser.role === UserRole.HEAD_NURSE || this.currentUser.role === UserRole.NURSE;
  }

  /**
   * 清空当前用户
   */
  public clearCurrentUser(): void {
    this.currentUser = null;
    console.log('PermissionManager: Current user cleared');
  }
}
