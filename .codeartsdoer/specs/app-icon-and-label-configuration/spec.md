# 应用图标与名称配置 - 需求规格文档

**版本**: v1.0
**创建日期**: 2025-01-14
**最后更新**: 2025-01-14
**作者**: Specification Driven Development Agent
**状态**: 草稿

## 1. 概述

### 1.1 功能简介
为鸿蒙健康护理应用配置专业的应用图标和本地化的应用名称，提升应用在设备主屏幕上的视觉识别度和用户体验。

### 1.2 业务背景
当前应用在鸿蒙系统主屏幕上显示为默认的蓝色四宫格图标，名称显示为"label"（英文占位符），缺乏专业性和品牌识别度。作为健康护理类应用，需要通过专业的图标和本地化的名称来建立用户信任，提升应用的品牌形象。

### 1.3 范围定义
**包含范围**:
- 应用图标配置（适配多种设备类型和分辨率）
- 应用名称本地化配置（中文为主）
- 启动窗口图标配置
- 模块描述信息优化

**排除范围**:
- 应用内部UI图标设计
- 其他模块的图标和名称配置
- 应用版本号和签名配置

## 2. 用户故事

### US-001: 配置专业的应用图标
**作为** 应用开发者
**我想要** 为应用配置专业的健康护理主题图标
**以便于** 用户在主屏幕上能快速识别应用，建立品牌认知

**验收标准**:
- Given 应用已安装到设备
- When 用户查看主屏幕应用列表
- Then 应用显示专业的健康护理主题图标而非默认图标

### US-002: 配置本地化的应用名称
**作为** 应用开发者
**我想要** 为应用配置中文本地化名称
**以便于** 中文用户能直观理解应用用途

**验收标准**:
- Given 设备语言设置为中文
- When 用户查看主屏幕应用列表
- Then 应用显示中文名称"健康护理"而非"label"

## 3. 功能需求

### 3.1 应用图标配置

#### FR-001: 配置应用级图标资源
**优先级**: P0
**类型**: 功能需求

**需求描述**:
The system shall provide a health-care themed application icon resource that replaces the default layered image icon.

**验收标准**:
- Given 应用配置文件app.json5中指定了图标资源引用
- When 系统加载应用图标
- Then 显示专业的健康护理主题图标而非默认蓝色四宫格图标

**依赖**: 无

#### FR-002: 配置启动窗口图标
**优先级**: P1
**类型**: 功能需求

**需求描述**:
The system shall provide a start window icon that matches the application icon style for consistent visual experience during app launch.

**验收标准**:
- Given 应用启动时显示启动窗口
- When 启动窗口显示
- Then 启动窗口图标与应用图标风格一致

**依赖**: FR-001

#### FR-003: 适配多设备类型图标
**优先级**: P1
**类型**: 功能需求

**需求描述**:
The system shall provide icon resources adapted for different device types including phone, tablet, 2in1 device, and wearable.

**验收标准**:
- Given 应用支持多种设备类型（phone, tablet, 2in1, wearable）
- When 应用在不同设备上安装
- Then 图标在各设备上显示清晰且比例合适

**依赖**: FR-001

### 3.2 应用名称配置

#### FR-004: 配置应用级中文名称
**优先级**: P0
**类型**: 功能需求

**需求描述**:
The system shall provide a localized Chinese application name "健康护理" in the application scope string resources.

**验收标准**:
- Given 设备语言设置为中文
- When 系统读取应用名称
- Then 显示"健康护理"而非"harmonyhealthcare"或"label"

**依赖**: 无

#### FR-005: 配置模块级显示名称
**优先级**: P0
**类型**: 功能需求

**需求描述**:
The system shall provide a localized Chinese module name and ability label in the module scope string resources.

**验收标准**:
- Given 设备语言设置为中文
- When 系统读取模块或Ability标签
- Then 显示中文名称而非英文占位符"label"或"description"

**依赖**: FR-004

#### FR-006: 配置模块描述信息
**优先级**: P2
**类型**: 功能需求

**需求描述**:
The system shall provide meaningful Chinese descriptions for the module and main ability to improve user understanding.

**验收标准**:
- Given 用户查看应用详细信息
- When 系统显示模块描述
- Then 显示有意义的中文描述而非"module description"或"description"

**依赖**: FR-004, FR-005

## 4. 非功能需求

### 4.1 性能需求

#### NFR-001: 图标资源加载性能
**指标**: 图标资源加载时间不超过100ms
**测试方法**: 测量应用启动时图标加载耗时

### 4.2 兼容性需求

#### NFR-002: 设备兼容性
**指标**: 支持phone、tablet、2in1、wearable四种设备类型
**测试方法**: 在各类型设备上验证图标和名称显示正确

#### NFR-003: 分辨率适配
**指标**: 图标在不同分辨率设备上显示清晰，无锯齿或模糊
**测试方法**: 在不同分辨率设备上目视检查图标质量

### 4.3 可用性需求

#### NFR-004: 视觉一致性
**指标**: 应用图标、启动窗口图标风格统一，符合健康护理主题
**测试方法**: 设计评审确认视觉风格一致性

## 5. 数据需求

### 5.1 数据模型
本功能不涉及业务数据模型，仅涉及资源配置数据：
- **图标资源**: 图像文件（PNG/WebP格式）
- **字符串资源**: 本地化文本键值对

### 5.2 数据存储
- 图标资源存储在资源目录中：`AppScope/resources/base/media/` 和 `entry/src/main/resources/base/media/`
- 字符串资源存储在：`AppScope/resources/base/element/string.json` 和 `entry/src/main/resources/base/element/string.json`

### 5.3 数据安全
本功能不涉及敏感数据，资源配置文件无需特殊安全保护。

## 6. 接口需求

### 6.1 用户界面
- 应用图标在主屏幕显示，尺寸符合鸿蒙系统规范
- 应用名称在主屏幕图标下方显示，长度适中（建议不超过6个汉字）

### 6.2 系统接口
- 通过`app.json5`配置文件引用图标和名称资源
- 通过`module.json5`配置文件引用模块级图标和名称资源
- 使用资源引用语法：`$media:资源名` 和 `$string:资源名`

## 7. 约束条件

### 7.1 技术约束
- 必须遵循鸿蒙应用资源配置规范
- 图标资源必须符合鸿蒙系统图标设计规范（尺寸、格式、透明度等）
- 资源引用必须使用正确的资源引用语法

### 7.2 业务约束
- 应用名称应简洁明了，体现健康护理主题
- 图标设计应符合健康护理行业特征（如医疗十字、心形、护理等元素）

### 7.3 时间约束
- 本功能为应用基础配置，应在应用发布前完成

## 8. 验收标准汇总

| 需求ID | 需求描述 | 验收标准 | 优先级 | 状态 |
|--------|---------|---------|--------|------|
| FR-001 | 配置应用级图标资源 | 主屏幕显示专业健康护理图标 | P0 | 待验证 |
| FR-002 | 配置启动窗口图标 | 启动窗口图标与应用图标风格一致 | P1 | 待验证 |
| FR-003 | 适配多设备类型图标 | 各设备类型图标显示清晰 | P1 | 待验证 |
| FR-004 | 配置应用级中文名称 | 显示"健康护理"而非英文 | P0 | 待验证 |
| FR-005 | 配置模块级显示名称 | 显示中文名称而非"label" | P0 | 待验证 |
| FR-006 | 配置模块描述信息 | 显示有意义的中文描述 | P2 | 待验证 |

## 9. 术语表

| 术语 | 定义 |
|-----|------|
| app.json5 | 鸿蒙应用级配置文件 |
| module.json5 | 鸿蒙模块级配置文件 |
| layered_image | 鸿蒙分层图标资源类型 |
| AppScope | 应用级资源作用域 |
| EntryAbility | 应用主入口能力 |

## 10. 附录

### 10.1 参考资料
- 鸿蒙应用资源配置文档
- 鸿蒙应用图标设计规范
- 鸿蒙本地化资源指南

### 10.2 变更历史
| 版本 | 日期 | 变更内容 | 作者 |
|-----|------|---------|------|
| v1.0 | 2025-01-14 | 初始版本创建 | SDD Agent |
