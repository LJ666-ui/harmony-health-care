# 手环手表精简版说明

## 概述

本项目已适配手环手表设备，提供精简版健康护理应用。手环手表版本专注于核心健康功能，界面简洁，操作便捷。

## 设备支持

- **支持设备类型**：wearable（手环/手表）
- **开发环境**：DevEco Studio 6.0.2
- **API版本**：API 22
- **不影响其他设备**：手机、平板、2in1设备仍使用完整版应用

## 核心功能

### 1. 健康数据实时监测 ✅
- **心率监测**：实时显示心率数据，正常范围提示
- **血压监测**：显示血压数据，异常提醒
- **血氧监测**：血氧饱和度实时监测
- **步数统计**：今日步数及目标完成度

**页面**：`WatchHealthMonitorPage.ets`

### 2. 用药提醒推送 ✅
- **提醒列表**：显示今日用药提醒
- **快速标记**：一键标记已服用
- **下次提醒**：显示下一次用药时间
- **手机同步**：与手机端用药提醒数据同步

**页面**：`WatchMedicationPage.ets`

### 3. 紧急呼叫/急救功能 ✅
- **SOS一键呼叫**：长按5秒触发紧急呼叫
- **紧急联系人**：快速拨打家人、急救中心电话
- **倒计时取消**：误触可取消紧急呼叫
- **急救指南**：简单急救步骤提示

**页面**：`WatchEmergencyPage.ets`

### 4. 运动数据记录 ✅
- **步数统计**：今日步数、距离、卡路里
- **运动追踪**：实时记录运动时长
- **目标进度**：显示每日运动目标完成度
- **运动记录**：查看历史运动记录

**页面**：`WatchSportPage.ets`

### 5. 睡眠监测 ✅
- **睡眠时长**：昨晚睡眠总时长
- **睡眠质量**：睡眠质量评分
- **睡眠阶段**：深睡、浅睡、清醒时间分布
- **睡眠追踪**：开始/停止睡眠监测

**页面**：`WatchSleepPage.ets`

### 6. 简单消息通知 ✅
- **消息列表**：显示来自手机的通知
- **分类筛选**：按健康、用药、预约等分类
- **未读提醒**：显示未读消息数量
- **快速查看**：点击查看消息详情

**页面**：`WatchMessagePage.ets`

## 技术实现

### 设备类型检测

使用 `DeviceTypeUtil` 工具类自动检测设备类型：

```typescript
import { DeviceTypeUtil } from '../utils/DeviceTypeUtil';

const deviceUtil = DeviceTypeUtil.getInstance();

// 判断是否为手环手表
if (deviceUtil.isWatchOrWearable()) {
  // 执行手环手表专用逻辑
}

// 获取适配后的字体大小
const fontSize = deviceUtil.getAdaptiveFontSize(16);

// 获取适配后的间距
const spacing = deviceUtil.getAdaptiveSpacing(12);
```

### UI适配策略

手环手表版本采用以下适配策略：

1. **字体缩小**：基础字体缩小30%
2. **间距缩小**：基础间距缩小50%
3. **图标缩小**：图标大小缩小40%
4. **按钮缩小**：按钮高度缩小30%
5. **内容精简**：只显示核心信息，去除复杂交互

### 页面路由

所有手环手表专用页面已注册到路由配置：

```json
{
  "src": [
    "pages/WatchHomePage",
    "pages/WatchHealthMonitorPage",
    "pages/WatchMedicationPage",
    "pages/WatchEmergencyPage",
    "pages/WatchSportPage",
    "pages/WatchSleepPage",
    "pages/WatchMessagePage"
  ]
}
```

### 自动跳转

应用启动时自动检测设备类型并跳转到相应首页：

- **手环手表**：跳转到 `WatchHomePage`
- **其他设备**：跳转到 `Login` 页面

## 文件结构

```
entry/src/main/ets/
├── utils/
│   └── DeviceTypeUtil.ets          # 设备类型检测工具
├── pages/
│   ├── WatchHomePage.ets           # 手环手表主页面
│   ├── WatchHealthMonitorPage.ets  # 健康监测页面
│   ├── WatchMedicationPage.ets     # 用药提醒页面
│   ├── WatchEmergencyPage.ets      # 紧急呼叫页面
│   ├── WatchSportPage.ets          # 运动记录页面
│   ├── WatchSleepPage.ets          # 睡眠监测页面
│   └── WatchMessagePage.ets        # 消息通知页面
└── entryability/
    └── EntryAbility.ets            # 应用入口（已适配）
```

## 配置说明

### module.json5

已添加设备类型支持：

```json
{
  "deviceTypes": [
    "phone",
    "tablet",
    "2in1",
    "wearable"
  ]
}
```

## 使用说明

### 开发调试

1. 在 DevEco Studio 6.0.2 中打开项目
2. 选择手表/手环设备模拟器
3. 运行应用，将自动进入手环手表版本

### 功能测试

- **健康监测**：查看心率、血压、血氧、步数数据
- **用药提醒**：添加、查看、标记用药提醒
- **紧急呼叫**：测试SOS功能（注意：会真实拨打电话）
- **运动记录**：开始运动追踪，查看运动数据
- **睡眠监测**：开始睡眠追踪，查看睡眠数据
- **消息通知**：查看来自手机的消息通知

## 注意事项

1. **不影响其他设备**：手环手表版本的代码不会影响手机、平板等设备的正常运行
2. **数据同步**：手环手表数据与手机端保持同步
3. **权限要求**：紧急呼叫功能需要电话权限
4. **传感器依赖**：健康监测功能依赖设备传感器
5. **性能优化**：手环手表版本已针对小屏幕设备进行性能优化

## 未来扩展

可根据需要添加以下功能：

- 心电图监测
- 压力监测
- 女性健康追踪
- 呼吸训练
- 音乐控制
- 支付功能

## 版本历史

- **v1.0.0** (2026-05-07)
  - 初始版本
  - 实现6大核心功能
  - 完成设备适配
  - 通过DevEco Studio 6.0.2 API 22开发
