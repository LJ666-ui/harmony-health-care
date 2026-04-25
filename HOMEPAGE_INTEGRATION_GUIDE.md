# 智慧病房系统集成到主页面的指南

## 📋 当前状态分析

### ✅ 已完成的工作

1. **模型文件** - 已复制到 `models/` 目录
2. **核心模块** - 保持在 `smartward/` 目录下
3. **导入路径** - 所有文件导入路径已更新
4. **Mock数据** - 已集成到 `mock/` 目录

### ❌ 未完成的工作

1. **HomePage集成** - 智慧病房功能未添加到HomePage
2. **路由配置** - 智慧病房页面未添加到路由
3. **导航入口** - 没有智慧病房的功能入口

## 🎯 需要添加的功能入口

根据智慧病房系统的功能，建议在HomePage中添加以下功能模块：

### 1. 护士站监控大屏
- **图标**：🏥
- **标题**：护士站监控
- **描述**：智慧病房实时监控大屏
- **页面**：`smartward/pages/NurseStationDashboard`

### 2. 智能设备控制
- **图标**：🔧
- **标题**：设备控制
- **描述**：病房设备统一控制管理
- **页面**：可创建设备控制页面

### 3. 告警中心
- **图标**：🚨
- **标题**：告警中心
- **描述**：实时告警与处理
- **页面**：可创建告警管理页面

## 📝 集成步骤

### 步骤1：修改HomePage.ets，添加智慧病房功能卡片

在 `HomePage.ets` 的 `featureCards` 数组中添加以下内容：

```typescript
@State featureCards: FeatureCard[] = [
  // ... 现有的功能卡片 ...
  
  // 智慧病房系统功能
  { id: 15, icon: '🏥', title: '护士站监控', description: '智慧病房实时监控大屏', url: 'smartward/pages/NurseStationDashboard' },
  { id: 16, icon: '🔧', title: '设备控制', description: '病房设备统一控制管理', url: 'pages/SmartWardDeviceControl' },
  { id: 17, icon: '🚨', title: '告警中心', description: '实时告警与处理', url: 'pages/SmartWardAlertCenter' },
  { id: 18, icon: '📊', title: '护理计划', description: '护理任务时间线管理', url: 'pages/SmartWardCarePlan' }
];
```

### 步骤2：创建智慧病房功能页面

需要创建以下页面：

#### 2.1 设备控制页面
```
entry/src/main/ets/pages/SmartWardDeviceControl.ets
```

#### 2.2 告警中心页面
```
entry/src/main/ets/pages/SmartWardAlertCenter.ets
```

#### 2.3 护理计划页面
```
entry/src/main/ets/pages/SmartWardCarePlan.ets
```

### 步骤3：配置路由

确保智慧病房页面可以正常导航：

```typescript
// 在需要的地方使用路由跳转
router.pushUrl({
  url: 'smartward/pages/NurseStationDashboard'
});
```

### 步骤4：初始化智慧病房系统

在应用的初始化代码中添加智慧病房系统的初始化：

```typescript
import { SmartWardInitializer } from '../smartward';

// 在应用启动时初始化
async initializeSmartWard() {
  const initializer = SmartWardInitializer.getInstance();
  await initializer.initialize();
  await initializer.generateMockData();
  initializer.startDataCollection(5000);
}
```

## 🔧 具体代码示例

### 示例1：修改HomePage.ets

```typescript
// 在 HomePage.ets 的 featureCards 数组中添加
{ id: 15, icon: '🏥', title: '护士站监控', description: '智慧病房实时监控大屏', url: 'smartward/pages/NurseStationDashboard' }
```

### 示例2：创建简单的设备控制页面

```typescript
// pages/SmartWardDeviceControl.ets
import { DeviceManager } from '../smartward/core/managers/DeviceManager';
import { DeviceType } from '../models/SmartWardEnums';

@Entry
@Component
struct SmartWardDeviceControl {
  @State deviceCount: number = 0;
  
  aboutToAppear(): void {
    this.loadDevices();
  }
  
  loadDevices(): void {
    const deviceManager = DeviceManager.getInstance();
    this.deviceCount = deviceManager.getAllDevices().length;
  }
  
  build() {
    Column() {
      Text('设备控制')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
      
      Text(`当前设备数量: ${this.deviceCount}`)
        .fontSize(16)
        .margin({ top: 20 })
    }
    .width('100%')
    .height('100%')
    .padding(20)
  }
}
```

## 📊 集成后的页面结构

```
HomePage (主页面)
├── 实时监控 (现有)
├── 健康记录 (现有)
├── 预约管理 (现有)
├── 用药管理 (现有)
├── 饮食食谱 (现有)
├── AI健康顾问 (现有)
├── ... (其他现有功能)
├── 🏥 护士站监控 (新增) → smartward/pages/NurseStationDashboard
├── 🔧 设备控制 (新增) → pages/SmartWardDeviceControl
├── 🚨 告警中心 (新增) → pages/SmartWardAlertCenter
└── 📊 护理计划 (新增) → pages/SmartWardCarePlan
```

## ⚠️ 注意事项

1. **路由路径**：智慧病房页面的路由路径是 `smartward/pages/NurseStationDashboard`
2. **初始化时机**：确保在使用智慧病房功能前先初始化系统
3. **权限管理**：根据用户角色设置不同的权限
4. **数据同步**：确保设备数据能够正常采集和更新

## 🎯 集成完成标志

当满足以下条件时，表示集成完成：

1. ✅ HomePage中有智慧病房功能入口
2. ✅ 点击入口可以跳转到智慧病房页面
3. ✅ 智慧病房系统正常初始化
4. ✅ 设备数据能够正常显示
5. ✅ 告警功能正常工作

## 📝 总结

**回答您的问题**：

1. ✅ **模型文件已集成**：智慧病房的模型文件已复制到主项目的 `models/` 目录
2. ✅ **核心模块已集成**：智慧病房的核心模块保持在 `smartward/` 目录下
3. ❌ **功能入口未集成**：智慧病房的功能还没有添加到HomePage中

**需要做的事情**：
- 在HomePage中添加智慧病房功能入口
- 创建必要的页面（设备控制、告警中心等）
- 初始化智慧病房系统
- 配置路由

智慧病房系统的文件已经集成到项目中，但是还需要在HomePage中添加功能入口，用户才能访问这些新功能。
