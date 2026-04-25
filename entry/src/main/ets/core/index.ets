/**
 * 智慧病房核心模块统一导出
 * 包含管理器、接口、引擎等核心功能
 */

// 管理器
export { DeviceManager } from './DeviceManager';
export { AlertManager } from './AlertManager';
export { PermissionManager, UserInfo } from './PermissionManager';

// 接口
export type { IDeviceController } from './IDeviceController';
export type { IRuleExecutor, ExecutionResult } from './IRuleExecutor';
