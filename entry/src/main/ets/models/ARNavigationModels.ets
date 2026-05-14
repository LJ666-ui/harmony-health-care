/**
 * AR院内导航系统 - 数据模型定义
 * 
 * 本文件定义了AR导航系统所需的所有数据结构、接口和枚举类型
 * 所有类型均使用ArkTS强类型系统,确保类型安全
 * 
 * @version 1.0
 * @date 2025-01-18
 * @author SDD Agent
 */

// ==================== 基础类型定义 ====================

/**
 * 三维坐标位置
 * 用于表示空间中的点位置
 */
export interface Position3D {
  x: number;  // X坐标(米),东西方向
  y: number;  // Y坐标(米),楼层高度(每层约3米)
  z: number;  // Z坐标(米),南北方向
}

/**
 * 二维坐标位置
 * 用于表示平面图上的点位置
 */
export interface Position2D {
  x: number;  // X坐标(米)
  y: number;  // Y坐标(米)
}

// ==================== 枚举类型定义 ====================

/**
 * 目的地分类枚举
 * 定义医院内各类导航目的地类型
 */
export enum DestinationCategory {
  DEPARTMENT = 'DEPARTMENT',       // 科室(内科、外科等)
  PHARMACY = 'PHARMACY',           // 药房(中药房、西药房)
  LAB = 'LAB',                     // 检验科(化验室)
  ELEVATOR = 'ELEVATOR',           // 电梯(客运电梯、医用电梯)
  RESTROOM = 'RESTROOM',           // 洗手间(男/女/无障碍)
  PAYMENT = 'PAYMENT',             // 缴费处(收费窗口)
  EMERGENCY = 'EMERGENCY',         // 急诊(急诊科)
  REGISTRATION = 'REGISTRATION',   // 挂号处(挂号窗口)
  IMAGING = 'IMAGING',             // 影像科(X光/CT/MRI)
  WARD = 'WARD',                   // 病房(住院部)
  ENTRANCE = 'ENTRANCE',           // 入口(大门)
  INFO_DESK = 'INFO_DESK',         // 导诊台/咨询台
  PARKING = 'PARKING',             // 停车场
  STAIRS = 'STAIRS',               // 楼梯
  ESCALATOR = 'ESCALATOR'          // 自动扶梯
}

/**
 * 途经点类型枚举
 * 定义导航路径中的各类节点类型
 */
export enum WaypointType {
  TURN_LEFT = 'TURN_LEFT',         // 左转节点
  TURN_RIGHT = 'TURN_RIGHT',       // 右转节点
  GO_STRAIGHT = 'GO_STRAIGHT',     // 直行节点
  TAKE_ELEVATOR = 'TAKE_ELEVATOR', // 乘坐电梯节点
  TAKE_STAIRS = 'TAKE_STAIRS',     // 走楼梯节点
  ARRIVAL = 'ARRIVAL'              // 到达终点节点
}

/**
 * 方向枚举
 * 定义导航指令中的方向类型
 */
export enum Direction {
  FORWARD = 'FORWARD',  // 前进
  LEFT = 'LEFT',        // 左转
  RIGHT = 'RIGHT',      // 右转
  UP = 'UP',            // 上楼
  DOWN = 'DOWN'         // 下楼
}

/**
 * 导航模式枚举
 * 定义系统支持的导航显示模式
 */
export enum NavigationMode {
  AR_MODE = 'AR_MODE',       // AR实景导航模式(相机+3D箭头)
  MAP_MODE = 'MAP_MODE',     // 2D地图导航模式(平面图+路径)
  MAP_2D = 'MAP_2D',         // 2D地图导航模式(别名)
  PHOTO_MODE = 'PHOTO_MODE', // 照片导航模式(拍照+静态箭头)
  TEXT_MODE = 'TEXT_MODE'    // 文字导航模式(逐步文字指引)
}

/**
 * 健康等级枚举
 * 定义器官或系统的健康状态等级
 */
export enum HealthLevel {
  EXCELLENT = 'EXCELLENT',  // 优秀(90-100分)
  GOOD = 'GOOD',            // 良好(75-89分)
  WARNING = 'WARNING',      // 亚健康(60-74分)
  DANGER = 'DANGER',        // 高危(40-59分)
  CRITICAL = 'CRITICAL'     // 异常(0-39分)
}

/**
 * 信号强度枚举
 * 定义定位信号质量等级
 */
export enum SignalStrength {
  GOOD = 'GOOD',    // 良好(正常定位)
  WEAK = 'WEAK',    // 弱(定位延迟)
  LOST = 'LOST'     // 丢失(使用最后已知位置)
}

// ==================== 导航目的地相关接口 ====================

/**
 * 导航目的地接口
 * 定义一个可导航的目的地完整信息
 */
export interface NavigationDestination {
  id: string;                      // 唯一标识符(如'DEPT_INTERNAL_301')
  name: string;                    // 名称(如'内科诊区301')
  category: DestinationCategory;   // 分类
  building: string;                // 所属建筑ID
  floor: number;                   // 楼层(1=1层, 2=2层, -1=B1层)
  position: Position3D;            // 3D坐标位置
  description: string;             // 详细描述
  workingHours?: string;           // 工作时间(可选,如'08:00-17:00')
  isAccessible: boolean;           // 是否无障碍可达
  tags: string[];                  // 标签列表(如['热门','门诊','VIP'])
  thumbnailUri?: string;           // 缩略图URI(可选)
}

// ==================== 导航路径相关接口 ====================

/**
 * 途经点接口
 * 定义导航路径中的一个关键节点
 */
export interface Waypoint {
  id: string;                      // 途经点ID
  position: Position3D;            // 3D坐标位置
  type: WaypointType;              // 节点类型
  instruction: string;             // 导航指令(如'在咨询台右侧右转')
  distanceFromPrev: number;        // 距上一节点的距离(米)
  landmark?: string;               // 附近地标(可选,如'3号电梯旁')
}

/**
 * 导航指令接口
 * 定义一步导航行动的详细说明
 */
export interface NavigationInstruction {
  stepIndex: number;               // 步骤序号(从0开始)
  text: string;                    // 完整指令文本(如'前方10米左转进入内科走廊')
  distance: number;                // 本段距离(米)
  direction: Direction;            // 方向
  floorHint?: string;              // 楼层提示(可选,如'B1层 → 1层')
  ttsText: string;                 // TTS播报文本(精简版,如'前方左转')
}

/**
 * 楼层切换接口
 * 定义跨楼层导航的换层信息
 */
export interface FloorChange {
  fromFloor: number;               // 起始楼层
  toFloor: number;                 // 目标楼层
  method: 'ELEVATOR' | 'STAIRS';   // 换层方式(电梯/楼梯)
  elevatorName?: string;           // 电梯名称(可选,如'1号客运电梯')
}

/**
 * 导航路径接口
 * 定义完整的导航路径信息
 */
export interface NavigationPath {
  pathId: string;                  // 路径唯一ID
  from: Position3D;                // 起点3D坐标
  to: Position3D;                  // 终点3D坐标
  waypoints: Waypoint[];           // 途经点列表
  totalDistance: number;           // 总距离(米)
  estimatedTime: number;           // 预计时间(秒)
  floorChanges: FloorChange[];     // 楼层切换信息列表
  instructions: NavigationInstruction[]; // 逐步指引列表
  createdAt: number;               // 创建时间戳(毫秒)
}

// ==================== 导航状态相关接口 ====================

/**
 * AR导航状态接口
 * 定义导航过程中的实时状态
 */
export interface ARNavigationState {
  isActive: boolean;               // 是否激活(导航中)
  isPaused: boolean;               // 是否暂停
  currentPath: NavigationPath | null; // 当前导航路径(未导航时为null)
  currentWaypointIndex: number;    // 当前途经点索引
  currentPosition: Position3D;     // 当前位置
  heading: number;                 // 当前朝向角度(0-360度,0=北,90=东)
  totalDistance: number;           // 总距离(米)
  remainingDistance: number;       // 剩余距离(米)
  estimatedTime: number;           // 预计时间(分钟)
  estimatedArrival: number;        // 预计到达时间(时间戳)
  navigationMode: NavigationMode;  // 当前导航模式
  isMuted: boolean;                // 是否静音
  lastUpdateTime: number;          // 最后更新时间戳(毫秒)
}

/**
 * 路径规划选项接口
 * 定义路径规划的可选参数
 */
export interface PathPlanningOptions {
  avoidElevators?: boolean;        // 避开电梯(默认false)
  avoidStairs?: boolean;           // 避开楼梯(无障碍模式,默认false)
  accessibilityMode?: boolean;     // 无障碍模式(默认false)
  maxDistance?: number;            // 最大距离限制(米)
  preferElevator?: boolean;        // 优先电梯(默认true)
  maxDetourRatio?: number;         // 最大绕行比例(默认1.5,即最多绕行50%)
}

/**
 * 导航选项接口
 * 定义启动导航的可选参数
 */
export interface NavigationOptions {
  mode?: NavigationMode;           // 导航模式(默认AR_MODE)
  voiceEnabled?: boolean;          // 语音引导开关(默认true)
  accessibilityMode?: boolean;     // 无障碍模式(默认false)
}

// ==================== 医院建筑数据相关接口 ====================

/**
 * 建筑信息接口
 * 定义医院建筑的基本信息
 */
export interface BuildingInfo {
  id: string;                      // 建筑ID(如'OUTPATIENT')
  name: string;                    // 建筑名称(如'门诊大楼')
  totalFloors: number;             // 总楼层数(包括地下层)
  entrancePosition: Position3D;    // 主入口位置
}

/**
 * 区域接口
 * 定义楼层平面图中的可行走区域
 */
export interface Area {
  points: Position2D[];            // 多边形顶点列表
  type: 'CORRIDOR' | 'LOBBY' | 'HALL' | 'ROOM'; // 区域类型
}

/**
 * 障碍物接口
 * 定义楼层平面图中的障碍物
 */
export interface Obstacle {
  position: Position2D;            // 障碍物中心位置
  radius: number;                  // 障碍物半径(米)
  type: 'PILLAR' | 'WALL' | 'FURNITURE'; // 障碍物类型
}

/**
 * 楼层平面图接口
 * 定义单个楼层的完整平面图数据
 */
export interface FloorPlan {
  buildingId: string;              // 所属建筑ID
  floor: number;                   // 楼层号
  width: number;                   // 平面图宽度(像素)
  height: number;                  // 平面图高度(像素)
  scale: number;                   // 比例尺(像素/米)
  walkableAreas: Area[];           // 可行走区域列表
  obstacles: Obstacle[];           // 障碍物列表
  imageUri?: string;               // 楼层平面图图片URI(可选)
}

/**
 * 楼层连接接口
 * 定义楼层间的连接关系(电梯/楼梯)
 */
export interface Connection {
  id: string;                      // 连接ID
  fromFloor: number;               // 起始楼层
  toFloor: number;                 // 目标楼层
  fromPosition: Position2D;        // 起始位置(2D)
  toPosition: Position2D;          // 目标位置(2D)
  type: 'ELEVATOR' | 'STAIRS';     // 连接类型
  name: string;                    // 名称(如'1号客运电梯')
}

/**
 * 路线覆盖接口
 * 定义无障碍路线的替代方案
 */
export interface RouteOverride {
  originalWaypointId: string;      // 原途经点ID
  alternativePath: Waypoint[];     // 替代路径
  reason: string;                  // 替代原因(如'原路径包含楼梯')
}

/**
 * 医院建筑数据接口
 * 定义完整的医院建筑数据结构
 */
export interface HospitalBuildingData {
  buildings: BuildingInfo[];       // 建筑列表
  floors: FloorPlan[];             // 楼层平面图列表
  pois: NavigationDestination[];   // 兴趣点(POI)列表
  connections: Connection[];       // 楼层连接列表
  accessibilityRoutes: RouteOverride[]; // 无障碍路线覆盖列表
}

/**
 * 搜索结果项接口
 * 用于POI搜索结果的返回值
 */
export interface SearchResultItem {
  poi: NavigationDestination;      // POI对象
  relevanceScore: number;          // 相关性评分(0-100)
  matchFields: string[];           // 匹配的字段列表(如['名称', '标签'])
}

// ==================== 图算法相关接口 ====================

/**
 * 图节点接口
 * 用于路径规划算法的图节点表示
 */
export interface GraphNode {
  id: string;                      // 节点ID
  position: Position3D;            // 3D位置
  floor: number;                   // 楼层
  type: WaypointType;              // 节点类型
  neighbors: string[];             // 邻居节点ID列表
  weight: number;                  // 节点权重(用于动态调整)
}

// ==================== 导航历史相关接口 ====================

/**
 * 导航历史记录接口
 * 定义一次导航的历史记录
 */
export interface NavigationHistory {
  id: string;                      // 记录ID
  destinationId: string;           // 目的地ID
  destinationName: string;         // 目的地名称
  startTime: number;               // 开始时间戳
  endTime: number;                 // 结束时间戳
  duration: number;                // 持续时间(秒)
  distance: number;                // 实际行进距离(米)
  path: NavigationPath;            // 导航路径
  completed: boolean;              // 是否完成(未完成=中途退出)
}

// ==================== 用户偏好相关接口 ====================

/**
 * 导航配置接口
 * 定义用户的导航偏好设置
 */
export interface NavigationConfig {
  defaultMode: NavigationMode;     // 默认导航模式
  voiceEnabled: boolean;           // 语音引导开关
  accessibilityMode: boolean;      // 无障碍模式
  positioningInterval: number;     // 定位更新间隔(毫秒)
  deviationThreshold: number;      // 偏航阈值(米)
}

// ==================== 错误处理相关接口 ====================

/**
 * 导航错误接口
 * 定义导航过程中可能发生的错误
 */
export interface NavigationError {
  code: NavigationErrorCode;       // 错误代码
  message: string;                 // 错误消息
  timestamp: number;               // 发生时间戳
  context?: string;                // 错误上下文(可选)
}

/**
 * 导航错误代码枚举
 */
export enum NavigationErrorCode {
  AR_INITIALIZATION_FAILED = 'AR_INITIALIZATION_FAILED',     // AR初始化失败
  POSITIONING_SIGNAL_LOST = 'POSITIONING_SIGNAL_LOST',       // 定位信号丢失
  PATH_CALCULATION_FAILED = 'PATH_CALCULATION_FAILED',       // 路径计算失败
  DESTINATION_NOT_FOUND = 'DESTINATION_NOT_FOUND',           // 目的地未找到
  PERMISSION_DENIED = 'PERMISSION_DENIED',                   // 权限被拒绝
  CAMERA_NOT_AVAILABLE = 'CAMERA_NOT_AVAILABLE',             // 相机不可用
  NETWORK_ERROR = 'NETWORK_ERROR'                            // 网络错误
}

// ==================== 辅助类型定义 ====================

/**
 * 定位权重配置
 */
export interface PositioningWeights {
  wifi: number;  // WiFi定位权重
  ble: number;   // 蓝牙定位权重
  ar: number;    // AR定位权重
}

/**
 * 箭头颜色配置
 */
export interface ArrowColorConfig {
  normal: string;   // 正常状态颜色
  turn: string;     // 转弯状态颜色
  arrival: string;  // 到达状态颜色
  warning: string;  // 警告状态颜色
}

/**
 * 系统状态信息接口（PathPlanner使用）
 */
export interface SystemStatusInfo {
  isInitialized: boolean;
  graphSize: number;
  cacheSize: number;
  historySize: number;
  poiCount: number;
  floorCount: number;
  connectionCount: number;
}

/**
 * 统计信息接口（PathPlanner使用）
 */
export interface StatisticsInfo {
  totalPOIs: number;
  categoryDistribution: Record<string, number>;
  floorDistribution: Record<string, number>;
  buildingDistribution: Record<string, number>;
}
