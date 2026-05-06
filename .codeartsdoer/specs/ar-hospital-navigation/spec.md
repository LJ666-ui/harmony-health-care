# 真实AR院内导航系统 - 需求规格文档

**版本**: v1.0  
**创建日期**: 2025-01-18  
**最后更新**: 2025-01-18  
**作者**: SDD Agent  
**状态**: 待评审

---

## 1. 概述

### 1.1 功能简介
真实AR院内导航系统是一款基于增强现实技术的医院室内导航解决方案,通过手机摄像头实时显示3D方向指引,帮助患者和家属快速、准确地找到医院内的目的地,显著提升就医体验和效率。

### 1.2 业务背景

**传统医院导航痛点**:
- **迷路率高**: 大型医院动辄数十个科室,患者/家属经常找不到目的地
- **指示牌不足**: 静态标识无法提供实时方向指引
- **无障碍缺失**: 老年人/视障人群难以理解平面地图
- **效率低下**: 找路平均浪费15-20分钟就诊时间

**解决方案**:
通过AR实景导航、室内精准定位、智能路径规划和语音引导,为用户提供沉浸式、智能化的导航体验,降低迷路率,提升就医效率。

### 1.3 范围定义

**包含范围**:
- AR实景导航(3D箭头叠加显示)
- 室内定位(WiFi指纹/蓝牙Beacon/AR视觉定位)
- 路径规划(A*算法,支持跨楼层)
- 语音引导(TTS播报)
- 多模式导航(AR/2D地图/照片/文字)
- 目的地搜索与分类
- 导航记录与收藏

**排除范围**:
- 室外导航功能
- 实时交通信息
- 多医院联网导航
- 医生排班查询
- 挂号缴费功能

---

## 2. 用户故事

### US-001: 快速找到目标科室
**作为** 首次就诊的患者  
**我想要** 通过AR导航快速找到目标科室  
**以便于** 节省找路时间,准时到达就诊地点

**验收标准**:
- Given 用户在首页点击"院内导航"
- When 用户搜索并选择目标科室
- Then 系统显示AR导航界面并开始实时指引

### US-002: 跨楼层导航
**作为** 需要去其他楼层的患者  
**我想要** 系统自动规划包含电梯/楼梯的路径  
**以便于** 顺利到达不同楼层的目的地

**验收标准**:
- Given 目的地在不同楼层
- When 系统计算路径
- Then 路径包含楼层切换节点和明确的换层指引

### US-003: 无障碍导航
**作为** 行动不便的老年患者  
**我想要** 系统优先推荐电梯而非楼梯  
**以便于** 更轻松地到达目的地

**验收标准**:
- Given 用户开启无障碍模式
- When 系统规划路径
- Then 路径自动避开楼梯,优先选择电梯和坡道

### US-004: 语音引导导航
**作为** 视力不佳的患者  
**我想要** 通过语音播报获取导航指令  
**以便于** 无需紧盯屏幕也能准确行进

**验收标准**:
- Given 用户开启语音引导
- When 到达关键导航节点
- Then 系统自动播报下一步行动指令

### US-005: 导航模式切换
**作为** AR功能不可用的用户  
**我想要** 切换到2D地图或文字模式  
**以便于** 依然能够获得导航指引

**验收标准**:
- Given AR初始化失败或用户主动切换
- When 选择其他导航模式
- Then 系统无缝切换并继续导航

---

## 3. 功能需求

### 3.1 目的地选择

#### FR-001: 目的地搜索
**优先级**: P0  
**类型**: 功能需求

**需求描述**:
The system shall provide search functionality for navigation destinations with auto-complete suggestions.

**验收标准**:
- 用户输入关键词时实时显示匹配结果
- 支持科室名称、编号、别名搜索
- 搜索结果按相关度和热度排序
- 响应时间<500ms

**依赖**: 无

#### FR-002: 目的地分类浏览
**优先级**: P0  
**类型**: 功能需求

**需求描述**:
The system shall organize destinations into categories including departments, pharmacies, labs, elevators, restrooms, payment counters.

**验收标准**:
- 提供至少10种分类(科室/药房/检验科/电梯/洗手间/缴费处/急诊/挂号/影像/病房)
- 每个分类显示图标和数量
- 支持分类内搜索和排序

#### FR-003: 收藏功能
**优先级**: P1  
**类型**: 功能需求

**需求描述**:
Where favorite feature is included, the system shall allow users to save frequently visited destinations.

**验收标准**:
- 用户可添加/移除收藏
- 收藏列表持久化存储
- 收藏目的地优先显示在首页

### 3.2 路径规划

#### FR-004: 最优路径计算
**优先级**: P0  
**类型**: 功能需求

**需求描述**:
The system shall calculate optimal navigation path using A* algorithm with support for cross-floor routing.

**验收标准**:
- 使用A*算法计算最短路径
- 支持同楼层和跨楼层路径规划
- 路径包含途经点、总距离、预计时间
- 计算时间<2秒

#### FR-005: 路径优化策略
**优先级**: P1  
**类型**: 功能需求

**需求描述**:
The system shall apply dynamic weights to path planning based on congestion, accessibility, and user preferences.

**验收标准**:
- 拥挤区域权重+50%
- 楼梯权重+30%
- 电梯权重-10%(优先推荐)
- 无障碍模式自动避开楼梯

#### FR-006: 路径重规划
**优先级**: P1  
**类型**: 功能需求

**需求描述**:
When user deviates from planned route by more than 5 meters, the system shall trigger automatic re-routing.

**验收标准**:
- 检测到偏航时自动重新计算路径
- 显示"正在重新规划"提示
- 重规划时间<3秒
- 新路径从当前位置出发

### 3.3 AR导航

#### FR-007: AR实景显示
**优先级**: P0  
**类型**: 功能需求

**需求描述**:
While in AR navigation mode, the system shall display real-time camera feed with 3D direction arrows overlaid.

**验收标准**:
- 实时显示摄像头画面(30fps)
- 3D箭头根据行进方向动态旋转
- 箭头颜色为绿色(正常)/黄色(转弯)/红色(到达)
- 支持横竖屏自适应

#### FR-008: 导航信息叠加
**优先级**: P0  
**类型**: 功能需求

**需求描述**:
While navigation is active, the system shall overlay navigation information including current instruction, remaining distance, and estimated arrival time.

**验收标准**:
- 底部显示当前步骤文字指引
- 实时更新剩余距离(精度±1米)
- 显示预计到达时间
- 进度条显示已走/总距离比例

#### FR-009: AR初始化失败降级
**优先级**: P0  
**类型**: 功能需求

**需求描述**:
The system shall fallback to 2D map mode in order to handle AR initialization failure gracefully.

**验收标准**:
- AR初始化失败时自动切换到2D地图模式
- 显示失败原因提示
- 用户可手动重试AR模式
- 导航不中断

### 3.4 室内定位

#### FR-010: 多源定位融合
**优先级**: P0  
**类型**: 功能需求

**需求描述**:
The system shall determine user's indoor position using WiFi fingerprinting, Bluetooth beacons, and AR visual positioning with accuracy better than 3 meters.

**验收标准**:
- WiFi指纹定位精度±3-5米(走廊级)
- 蓝牙Beacon定位精度±1-2米(房间级)
- AR视觉定位精度±0.5米(精确到门)
- 定位更新频率≥1Hz

#### FR-011: 定位信号丢失处理
**优先级**: P1  
**类型**: 功能需求

**需求描述**:
When positioning signal is lost, the system shall display notification and use last known position for navigation.

**验收标准**:
- 信号丢失时显示"定位信号弱"提示
- 使用最后已知位置继续导航
- 信号恢复后自动更新位置
- 记录信号丢失事件用于优化

### 3.5 语音引导

#### FR-012: TTS语音播报
**优先级**: P1  
**类型**: 功能需求

**需求描述**:
Where voice guidance is enabled, the system shall announce navigation instructions using text-to-speech at key waypoints.

**验收标准**:
- 到达关键节点时自动播报
- 播报内容简洁明确(如"前方10米左转")
- 支持静音切换
- 播报不与其他音频冲突

#### FR-013: 语音引导时机
**优先级**: P1  
**类型**: 功能需求

**需求描述**:
The system shall trigger voice announcement at appropriate distances before waypoints.

**验收标准**:
- 转弯节点: 提前5米播报
- 电梯节点: 提前10米播报
- 到达终点: 提前3米播报
- 避免播报过于频繁

### 3.6 多模式导航

#### FR-014: 导航模式切换
**优先级**: P1  
**类型**: 功能需求

**需求描述**:
The system shall support four navigation modes: AR mode, 2D map mode, photo mode, and text mode.

**验收标准**:
- AR模式: 实时相机+3D箭头
- 2D地图模式: 楼层平面图+移动蓝点
- 照片模式: 拍照+静态箭头叠加
- 文字模式: 逐步文字指引列表
- 模式切换无卡顿

#### FR-015: 2D地图导航
**优先级**: P1  
**类型**: 功能需求

**需求描述**:
While in 2D map mode, the system shall display floor plan with user position and navigation route.

**验收标准**:
- 显示当前楼层平面图
- 蓝点表示用户位置
- 绿色线条显示规划路径
- 支持楼层切换查看
- 支持缩放和平移

### 3.7 导航状态管理

#### FR-016: 导航进度跟踪
**优先级**: P0  
**类型**: 功能需求

**需求描述**:
While navigation is active, the system shall update navigation state every second including current position, remaining distance, and waypoint index.

**验收标准**:
- 每秒更新一次导航状态
- 实时计算剩余距离
- 自动推进途经点索引
- 到达检测精度±3米

#### FR-017: 导航结束处理
**优先级**: P0  
**类型**: 功能需求

**需求描述**:
When user arrives at destination, the system shall display arrival animation and destination details.

**验收标准**:
- 剩余距离<3米时触发到达逻辑
- 显示"已到达目的地"庆祝动画
- 显示目的地详情卡片(名称/位置/工作时间)
- 提供返回首页或继续导航选项

#### FR-018: 导航记录保存
**优先级**: P2  
**类型**: 功能需求

**需求描述**:
The system shall save navigation history including destination, path, duration, and timestamp.

**验收标准**:
- 导航结束后自动保存记录
- 记录包含目的地、路径、耗时、时间戳
- 支持查看历史导航记录
- 支持删除历史记录

---

## 4. 非功能需求

### 4.1 性能需求

#### NFR-001: 路径计算性能
**指标**: 路径计算时间<2秒(95%情况下)  
**测试方法**: 在包含1000个节点的地图上测试A*算法性能

#### NFR-002: 定位更新频率
**指标**: 定位更新频率≥1Hz  
**测试方法**: 连续监测定位回调频率

#### NFR-003: AR渲染性能
**指标**: AR画面帧率≥30fps  
**测试方法**: 使用性能分析工具监测渲染帧率

#### NFR-004: 应用启动时间
**指标**: 导航页面加载时间<3秒  
**测试方法**: 从点击入口到页面完全渲染的时间

#### NFR-005: 内存占用
**指标**: 导航功能运行时内存增量<100MB  
**测试方法**: 使用内存分析工具监测

### 4.2 精度需求

#### NFR-006: 定位精度
**指标**: 室内定位精度±3米(95%情况下)  
**测试方法**: 在已知位置测试定位误差

#### NFR-007: 距离计算精度
**指标**: 距离计算误差±1米  
**测试方法**: 对比实际测量距离与系统计算距离

### 4.3 可用性需求

#### NFR-008: 用户学习成本
**指标**: 新用户首次使用成功率>90%  
**测试方法**: 用户测试,记录首次使用成功到达目的地的比例

#### NFR-009: 导航成功率
**指标**: 导航成功到达率>95%  
**测试方法**: 统计导航完成数/导航启动数

#### NFR-010: 界面响应时间
**指标**: 用户操作响应时间<300ms  
**测试方法**: 测试关键交互操作的响应延迟

### 4.4 兼容性需求

#### NFR-011: 设备兼容性
**指标**: 支持HarmonyOS API 12及以上  
**测试方法**: 在不同HarmonyOS版本设备上测试

#### NFR-012: 屏幕适配
**指标**: 支持屏幕尺寸4.7-7英寸,分辨率1080p-2K  
**测试方法**: 在不同屏幕规格设备上测试UI适配

#### NFR-013: 传感器依赖
**指标**: 支持陀螺仪、加速度计、磁力计、相机  
**测试方法**: 检测设备传感器支持情况

### 4.5 安全需求

#### NFR-014: 隐私保护
**指标**: 用户位置数据不上传云端,仅本地使用  
**测试方法**: 抓包验证无位置数据外传

#### NFR-015: 权限管理
**指标**: 仅申请必要权限(相机、位置、存储)  
**测试方法**: 检查权限申请列表

### 4.6 稳定性需求

#### NFR-016: 异常恢复
**指标**: 异常崩溃后能恢复导航状态  
**测试方法**: 模拟崩溃,验证重启后状态恢复

#### NFR-017: 离线可用
**指标**: 医院地图数据离线可用  
**测试方法**: 断网情况下测试导航功能

---

## 5. 数据需求

### 5.1 核心数据模型

**NavigationDestination (导航目的地)**:
- id: 唯一标识
- name: 名称
- category: 分类(科室/药房/检验科等)
- building: 所属建筑
- floor: 楼层
- position: 3D坐标(x,y,z)
- description: 描述
- workingHours: 工作时间(可选)
- isAccessible: 是否无障碍可达
- tags: 标签列表
- thumbnailUri: 缩略图(可选)

**NavigationPath (导航路径)**:
- pathId: 路径ID
- from: 起点3D坐标
- to: 终点3D坐标
- waypoints: 途经点列表
- totalDistance: 总距离(米)
- estimatedTime: 预计时间(秒)
- floorChanges: 换层信息
- instructions: 逐步指引
- createdAt: 创建时间戳

**ARNavigationState (导航状态)**:
- isActive: 是否激活
- currentPath: 当前路径
- currentWaypointIndex: 当前途经点索引
- currentPosition: 当前位置
- heading: 朝向角度(0-360)
- remainingDistance: 剩余距离
- estimatedArrival: 预计到达时间
- navigationMode: 导航模式
- lastUpdateTime: 最后更新时间

**HospitalBuildingData (医院建筑数据)**:
- buildings: 建筑信息列表
- floors: 楼层平面图列表
- pois: 兴趣点列表
- connections: 楼层连接(电梯/楼梯)
- accessibilityRoutes: 无障碍路线

### 5.2 数据存储需求

- **医院地图数据**: 本地持久化存储,支持离线使用
- **导航历史**: 本地数据库存储,最多保留100条记录
- **收藏列表**: 本地持久化存储
- **用户偏好**: 本地设置存储(导航模式/语音开关等)

### 5.3 数据安全需求

- 位置数据不上传服务器,仅本地使用
- 导航历史数据加密存储
- 支持用户清除所有导航数据

---

## 6. 接口需求

### 6.1 用户界面

**首页入口**:
- 位置: 首页功能列表"院内导航"卡片
- 样式: 图标+文字,与整体风格一致
- 交互: 点击跳转到目的地选择页

**目的地选择页**:
- 顶部: 搜索框
- 中部: 分类Tab+目的地列表
- 底部: 收藏快捷入口
- 交互: 点击目的地跳转到路径概览页

**路径概览页**:
- 显示: 起点、终点、路径信息
- 内容: 总距离、预计时间、途经点摘要
- 操作: "开始导航"按钮

**AR导航页**:
- 主区域: 全屏相机+3D箭头叠加
- 底部面板: 当前指引文字、剩余距离、进度条
- 顶部栏: 目的地名称、模式切换、返回按钮
- 操作: 结束导航、静音切换

**2D地图导航页**:
- 主区域: 楼层平面图+路径线条+位置蓝点
- 侧边栏: 逐步指引列表
- 操作: 楼层切换、模式切换

### 6.2 系统接口

**室内定位接口**:
- 输入: 无
- 输出: Position3D(当前位置), accuracy(精度)
- 频率: 1Hz

**路径规划接口**:
- 输入: startPos, destPos, options(无障碍模式等)
- 输出: NavigationPath
- 响应时间: <2秒

**AR渲染接口**:
- 输入: cameraFrame, direction, distance
- 输出: renderedFrame(叠加箭头后的画面)
- 帧率: 30fps

**TTS播报接口**:
- 输入: text(播报文本)
- 输出: 音频播放
- 异步: 不阻塞导航流程

---

## 7. 约束条件

### 7.1 技术约束

- **开发语言**: ArkTS (HarmonyOS官方语言)
- **API版本**: HarmonyOS API 12及以上
- **AR框架**: 使用HarmonyOS XR Kit或自研Canvas方案
- **地图渲染**: Canvas 2D绘制
- **定位技术**: WiFi RTT + 蓝牙BLE + AR视觉定位融合
- **路径算法**: A*算法实现

### 7.2 业务约束

- **医院范围**: 仅支持单一医院院内导航
- **楼层范围**: 支持地上5层至地下2层
- **目的地类型**: 仅支持预设POI,不支持自定义坐标
- **导航模式**: 单次导航,不支持多点途经

### 7.3 时间约束

- **需求确认**: 1天
- **设计完成**: 2天
- **开发完成**: 5天
- **测试验收**: 2天
- **总计**: 10个工作日

---

## 8. 验收标准汇总

| 需求ID | 需求描述 | 验收标准 | 优先级 | 状态 |
|--------|---------|---------|--------|------|
| FR-001 | 目的地搜索 | 输入时实时显示匹配结果,响应<500ms | P0 | 待验证 |
| FR-002 | 目的地分类浏览 | 提供至少10种分类,支持分类内搜索 | P0 | 待验证 |
| FR-003 | 收藏功能 | 可添加/移除收藏,数据持久化 | P1 | 待验证 |
| FR-004 | 最优路径计算 | A*算法,支持跨楼层,计算<2秒 | P0 | 待验证 |
| FR-005 | 路径优化策略 | 动态权重,无障碍模式避开楼梯 | P1 | 待验证 |
| FR-006 | 路径重规划 | 偏航>5米自动重规划,<3秒 | P1 | 待验证 |
| FR-007 | AR实景显示 | 实时相机+3D箭头,30fps | P0 | 待验证 |
| FR-008 | 导航信息叠加 | 显示指引文字、距离、时间、进度条 | P0 | 待验证 |
| FR-009 | AR失败降级 | 自动切换2D地图,导航不中断 | P0 | 待验证 |
| FR-010 | 多源定位融合 | 精度±3米,更新频率≥1Hz | P0 | 待验证 |
| FR-011 | 定位丢失处理 | 显示提示,使用最后已知位置 | P1 | 待验证 |
| FR-012 | TTS语音播报 | 关键节点自动播报,支持静音 | P1 | 待验证 |
| FR-013 | 语音引导时机 | 转弯提前5米,电梯提前10米 | P1 | 待验证 |
| FR-014 | 导航模式切换 | 支持AR/2D/照片/文字四种模式 | P1 | 待验证 |
| FR-015 | 2D地图导航 | 显示平面图、位置、路径,支持缩放 | P1 | 待验证 |
| FR-016 | 导航进度跟踪 | 每秒更新状态,到达精度±3米 | P0 | 待验证 |
| FR-017 | 导航结束处理 | 显示到达动画和目的地详情 | P0 | 待验证 |
| FR-018 | 导航记录保存 | 自动保存历史,支持查看和删除 | P2 | 待验证 |

---

## 9. 术语表

| 术语 | 英文 | 定义 |
|-----|------|------|
| AR | Augmented Reality | 增强现实,在现实画面上叠加虚拟信息 |
| POI | Point of Interest | 兴趣点,导航目的地 |
| A*算法 | A* Algorithm | 启发式搜索算法,用于路径规划 |
| WiFi指纹 | WiFi Fingerprint | 基于WiFi信号强度的定位技术 |
| Beacon | Bluetooth Beacon | 蓝牙信标,用于室内定位 |
| TTS | Text-to-Speech | 文本转语音技术 |
| 途经点 | Waypoint | 路径中的关键节点 |
| 偏航 | Deviation | 偏离规划路径 |
| 无障碍 | Accessibility | 适合行动不便人群使用 |

---

## 10. 附录

### 10.1 参考资料

1. 《未完成功能技术规划-V3.0.md》 - 功能6详细定义
2. HarmonyOS XR Kit开发文档
3. A*路径规划算法原理
4. 室内定位技术方案对比

### 10.2 变更历史

| 版本 | 日期 | 变更内容 | 作者 |
|-----|------|---------|------|
| v1.0 | 2025-01-18 | 初始版本,完成所有需求定义 | SDD Agent |

---

**文档结束**
