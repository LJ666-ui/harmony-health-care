/**
 * 智慧病房系统统一导出文件
 * 提供所有模块的统一导入入口
 */

// 模型（从 models 目录导入）
export * from '../models/SmartWardEnums';
export * from '../models/SmartWardDeviceModels';
export * from '../models/SmartWardModels';
export * from '../models/SmartWardAutomationModels';
export * from '../models/SmartWardAlertModels';
export * from '../models/SmartWardTaskModels';
export * from '../models/SmartWardDataModels';

// 核心模块
export { DeviceManager } from './core/managers/DeviceManager';
export { PermissionManager, UserInfo } from './core/managers/PermissionManager';
export { AlertManager } from './core/managers/AlertManager';
export { DataCollector } from './core/collectors/DataCollector';

// 设备控制器
export { SmartLightController } from './core/controllers/SmartLightController';
export { HospitalBedController } from './core/controllers/HospitalBedController';
export { PatientMonitorController } from './core/controllers/PatientMonitorController';
export { SmartCurtainController } from './core/controllers/SmartCurtainController';
export { SmartTVController } from './core/controllers/SmartTVController';
export { AirConditionerController } from './core/controllers/AirConditionerController';
export { CallButtonController } from './core/controllers/CallButtonController';
export { InfusionPumpController } from './core/controllers/InfusionPumpController';

// 规则引擎
export { AutomationEngine } from './core/engines/AutomationEngine';
export { RuleExecutor } from './core/executors/RuleExecutor';
export { TimeChecker } from './core/checkers/TimeChecker';

// 配置
export { presetRules } from './config/presetRules';

// 页面
export { NurseStationDashboard } from './pages/NurseStationDashboard';

// 初始化器
export { SmartWardInitializer } from './SmartWardInitializer';

// 真实数据（基于数据库）
export { RealDataGenerator } from '../../mock/smartwardMock_realdata';
// 原始模拟数据（如需回退可使用）
// export { MockDataGenerator } from '../../mock/smartwardMock';
