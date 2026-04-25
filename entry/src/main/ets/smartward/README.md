# 鸿蒙智慧病房系统

## 系统概述

鸿蒙智慧病房系统是一个基于鸿蒙OS的分布式智慧病房解决方案，实现了设备统一控制、智能联动、数据自动采集等功能，有效解决了传统病房设备孤岛、响应滞后、信息不透明等问题。

## 核心功能

### 1. 设备接入与控制
- 支持8种设备类型：智能病床、患者监护仪、智能灯光、智能窗帘、智能电视、空调、呼叫按钮、输液泵
- 统一的设备控制接口
- 实时设备状态监控

### 2. 智能联动规则
- **安全联动**：心率异常、血氧下降、呼叫按钮、输液告警
- **舒适联动**：就寝时间、查房时间、用餐时间
- 支持7条预设规则，可自定义扩展

### 3. 护士站监控大屏
- 病房概览：显示所有病房的实时状态
- 告警中心：实时告警滚动，分级显示
- 护理计划：展示当日护理任务时间线
- 自动刷新数据（默认5秒）

### 4. 告警管理
- 分级告警：急救、紧急、警告、信息
- 告警确认和解决
- 告警统计和历史记录

### 5. 权限管理
- 基于角色的权限控制
- 护士长、护士、患者三种角色
- 细粒度的设备操作权限

## 项目结构

```
entry/src/main/ets/smartward/
├── models/                          # 数据模型
│   ├── SmartWardEnums.ets          # 枚举定义
│   ├── SmartWardDeviceModels.ets   # 设备模型
│   ├── SmartWardModels.ets         # 核心模型
│   ├── SmartWardAutomationModels.ets # 自动化规则模型
│   ├── SmartWardAlertModels.ets    # 告警模型
│   ├── SmartWardTaskModels.ets     # 护理任务模型
│   ├── SmartWardDataModels.ets     # 数据模型
│   └── index.ets                   # 统一导出
├── core/
│   ├── interfaces/                 # 接口定义
│   │   ├── IDeviceController.ets   # 设备控制器接口
│   │   └── IRuleExecutor.ets       # 规则执行器接口
│   ├── managers/                   # 管理器
│   │   ├── DeviceManager.ets       # 设备管理器
│   │   ├── PermissionManager.ets   # 权限管理器
│   │   └── AlertManager.ets        # 告警管理器
│   ├── controllers/                # 设备控制器
│   │   ├── SmartLightController.ets
│   │   ├── HospitalBedController.ets
│   │   ├── PatientMonitorController.ets
│   │   ├── SmartCurtainController.ets
│   │   ├── SmartTVController.ets
│   │   ├── AirConditionerController.ets
│   │   ├── CallButtonController.ets
│   │   └── InfusionPumpController.ets
│   ├── engines/                    # 引擎
│   │   └── AutomationEngine.ets    # 自动化规则引擎
│   ├── executors/                  # 执行器
│   │   └── RuleExecutor.ets        # 规则执行器
│   ├── collectors/                 # 采集器
│   │   └── DataCollector.ets       # 数据采集器
│   └── checkers/                   # 检测器
│       └── TimeChecker.ets         # 时间检测器
├── config/
│   └── presetRules.ets             # 预设规则配置
├── pages/
│   └── NurseStationDashboard.ets   # 护士站监控大屏
├── SmartWardInitializer.ets        # 系统初始化器
└── index.ets                       # 统一导出
```

## 快速开始

### 1. 初始化系统

```typescript
import { SmartWardInitializer } from './smartward';

// 获取初始化器实例
const initializer = SmartWardInitializer.getInstance();

// 初始化系统
await initializer.initialize();

// 生成模拟数据（可选）
await initializer.generateMockData();

// 启动数据采集
initializer.startDataCollection(5000); // 5秒间隔
```

### 2. 使用设备管理器

```typescript
import { DeviceManager } from './smartward';

const deviceManager = DeviceManager.getInstance();

// 注册设备
deviceManager.registerDevice({
  deviceId: 'DEV_001',
  deviceType: DeviceType.SMART_LIGHT,
  roomId: 'ROOM_301',
  name: '床头灯',
  status: 'online',
  lastUpdateTime: Date.now()
});

// 发送控制命令
await deviceManager.sendCommand('DEV_001', {
  deviceId: 'DEV_001',
  deviceType: DeviceType.SMART_LIGHT,
  action: 'setBrightness',
  params: { brightness: 80 },
  timestamp: Date.now()
});

// 获取设备状态
const status = await deviceManager.getDeviceStatus('DEV_001');
```

### 3. 使用告警管理器

```typescript
import { AlertManager } from './smartward';

const alertManager = AlertManager.getInstance();

// 创建告警
alertManager.createAlert({
  alertId: 'ALERT_001',
  level: AlertLevel.EMERGENCY,
  category: AlertCategory.VITAL_SIGN_ANOMALY,
  message: '心率异常，请立即处理',
  roomId: 'ROOM_301',
  roomNumber: '301',
  triggeredAt: Date.now(),
  isAcknowledged: false,
  isResolved: false
});

// 确认告警
alertManager.acknowledgeAlert('ALERT_001', '李护士');

// 获取告警列表
const alerts = alertManager.getAlerts();

// 获取统计信息
const stats = alertManager.getAlertStatistics();
```

### 4. 使用规则引擎

```typescript
import { AutomationEngine } from './smartward';

const automationEngine = AutomationEngine.getInstance();

// 检查规则触发
const results = await automationEngine.checkRules({
  eventType: 'VITAL_SIGNS_CHANGE',
  roomId: 'ROOM_301',
  deviceId: 'DEV_002',
  data: {
    heartRate: 130,
    oxygenSaturation: 95
  },
  timestamp: Date.now()
});

// 执行规则动作
if (results.length > 0) {
  const executor = RuleExecutor.getInstance();
  for (const result of results) {
    await executor.executeActions(result.actionsToExecute, result.ruleId);
  }
}
```

### 5. 使用护士站监控大屏

```typescript
// 在页面中直接使用
import { NurseStationDashboard } from './smartward';

@Entry
@Component
struct MainPage {
  build() {
    NurseStationDashboard()
  }
}
```

## 预设规则说明

系统预置了7条联动规则：

1. **心率异常联动** (RULE_001)
   - 触发条件：心率>120或<50
   - 执行动作：开灯100% + 推送紧急警报 + 录制数据 + 语音播报
   - 优先级：10

2. **血氧饱和度下降联动** (RULE_002)
   - 触发条件：血氧<92%
   - 执行动作：开柔和灯光 + 推送二级警报 + 语音提醒
   - 优先级：9

3. **呼叫按钮响应联动** (RULE_003)
   - 触发条件：呼叫按钮按下
   - 执行动作：推送告警 + 床头灯闪烁
   - 优先级：8

4. **输液即将完毕联动** (RULE_004)
   - 触发条件：输液余量<50ml
   - 执行动作：推送换药提醒 + 床头灯闪烁
   - 优先级：7

5. **就寝时间舒适联动** (RULE_005)
   - 触发条件：21:00
   - 执行动作：调暗灯光 + 关窗帘 + 电视静音
   - 优先级：5

6. **查房时间提醒联动** (RULE_006)
   - 触发条件：08:50
   - 执行动作：调亮灯光 + 推送查房提醒
   - 优先级：4

7. **用餐时间舒适联动** (RULE_007)
   - 触发条件：11:30
   - 执行动作：床头调节至45° + 推送用餐提醒
   - 优先级：3

## 权限说明

系统支持三种角色：

- **护士长 (HEAD_NURSE)**：可以控制所有设备、查看所有患者信息、确认所有告警、管理规则
- **护士 (NURSE)**：只能控制负责房间的设备、查看负责房间的患者信息、确认负责房间的告警
- **患者 (PATIENT)**：只能控制自己房间的灯光、电视和呼叫按钮，只能查看自己的信息

## 数据模型

### 核心数据模型

- **SmartWardRoom**：病房完整信息
- **WardPatientInfo**：患者信息
- **DeviceStatus**：设备状态
- **AutomationRule**：自动化规则
- **WardAlert**：告警记录
- **CareTask**：护理任务
- **EnvironmentData**：环境数据

### 枚举类型

- **DeviceType**：设备类型（8种）
- **AlertLevel**：告警等级（4级）
- **PatientRiskLevel**：患者风险等级（4级）
- **TaskStatus**：任务状态（5种）
- **RuleType**：规则类型（4种）
- **UserRole**：用户角色（3种）

## 扩展开发

### 添加新的设备类型

1. 在 `SmartWardEnums.ets` 中添加新的设备类型枚举
2. 创建新的设备控制器，实现 `IDeviceController` 接口
3. 在 `SmartWardInitializer.ets` 中注册新的控制器

### 添加新的联动规则

1. 在 `presetRules.ets` 中添加新的规则配置
2. 规则会自动加载到引擎中

### 添加新的UI页面

1. 在 `pages/` 目录下创建新的页面文件
2. 使用 `@Entry` 和 `@Component` 装饰器
3. 导入需要的数据模型和管理器

## 注意事项

1. 所有控制器都是单例模式，使用 `getInstance()` 获取实例
2. 设备控制命令是异步的，需要使用 `await`
3. 规则有冷却时间，防止重复触发
4. 告警数量限制为100条，超过时会删除最早的告警
5. 数据采集默认5秒间隔，可根据需要调整

## 技术栈

- **开发语言**：ArkTS
- **UI框架**：鸿蒙ArkUI
- **架构模式**：单例模式、观察者模式
- **数据管理**：Map存储、响应式数据

## 版本信息

- **版本**：v1.0
- **创建日期**：2025-01-14
- **开发者**：CodeArts AI Agent

## 许可证

本项目为演示项目，仅供学习和参考使用。
