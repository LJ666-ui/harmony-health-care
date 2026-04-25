# 智慧病房系统集成指南

## 概述
本文档说明如何将智慧病房系统集成到现有项目中。

## 文件结构整合

### 1. 模型文件 (models/)
已创建的文件：
- `SmartWardEnums.ets` - 枚举定义
- `SmartWardDeviceModels.ets` - 设备相关模型
- `SmartWardModels.ets` - 核心数据模型
- `SmartWardAutomationModels.ets` - 自动化规则模型
- `SmartWardAlertModels.ets` - 告警模型
- `SmartWardTaskModels.ets` - 护理任务模型
- `SmartWardDataModels.ets` - 数据模型

### 2. 核心模块 (smartward/core/)
需要保持的目录结构：
- `interfaces/` - 接口定义
- `managers/` - 管理器
- `controllers/` - 设备控制器
- `engines/` - 规则引擎
- `executors/` - 规则执行器
- `collectors/` - 数据采集器
- `checkers/` - 时间检测器

### 3. 页面文件 (smartward/pages/)
- `NurseStationDashboard.ets` - 护士站监控大屏

### 4. 配置文件 (smartward/config/)
- `presetRules.ets` - 预设规则配置

### 5. Mock文件 (mock/)
- `smartwardMock.ets` - 模拟数据生成器

### 6. 初始化文件 (smartward/)
- `SmartWardInitializer.ets` - 系统初始化器
- `index.ets` - 统一导出

## 更新现有文件

### 1. 更新 models/index.ets
在现有的 models/index.ets 中添加智慧病房模型的导出：

```typescript
// 智慧病房模型
export * from './SmartWardEnums';
export * from './SmartWardDeviceModels';
export * from './SmartWardModels';
export * from './SmartWardAutomationModels';
export * from './SmartWardAlertModels';
export * from './SmartWardTaskModels';
export * from './SmartWardDataModels';
```

### 2. 更新 mock/index.ets
在现有的 mock/index.ets 中添加智慧病房Mock的导出：

```typescript
// 智慧病房Mock
export * from './smartwardMock';
```

### 3. 更新 pages 导入
在需要使用智慧病房功能的页面中，添加导入：

```typescript
import { NurseStationDashboard } from '../smartward';
```

## 使用说明

### 初始化系统
在应用的入口页面或初始化方法中：

```typescript
import { SmartWardInitializer } from '../smartward';

// 初始化智慧病房系统
const initializer = SmartWardInitializer.getInstance();
await initializer.initialize();
await initializer.generateMockData();
initializer.startDataCollection(5000);
```

### 导航到护士站监控大屏
```typescript
router.pushUrl({
  url: 'pages/NurseStationDashboard'
});
```

## 注意事项

1. 保持 smartward 目录结构不变，这样可以避免导入路径冲突
2. 所有智慧病房相关的文件都在 smartward 目录下，便于管理
3. 智慧病房的模型文件已移动到 models 目录，与其他模型保持一致
4. Mock 文件已移动到 mock 目录，与其他 Mock 保持一致

## 下一步

1. 确保所有导入路径正确
2. 测试护士站监控大屏页面
3. 验证设备控制和联动规则功能
4. 测试告警管理功能
