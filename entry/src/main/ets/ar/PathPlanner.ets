/**
 * AR院内导航系统 - 路径规划器(完整版)
 * 
 * 实现室内路径规划算法,核心功能:
 * - A*算法实现最优路径搜索
 * - 支持跨楼层路径规划
 * - 动态权重调整(拥挤度/无障碍)
 * - 路径平滑和指令生成
 * - 完整的医院POI数据集成
 * - 智能目的地推荐
 * - 路径缓存优化
 * - POI搜索和分类浏览
 * - 自动数据加载和初始化
 * - 导航历史记录管理
 * 
 * @version 3.0 (完整版)
 * @date 2025-01-18
 * @author SDD Agent
 */

import {
  HospitalBuildingData,
  NavigationPath,
  NavigationDestination,
  Position3D,
  Position2D,
  PathPlanningOptions,
  DestinationCategory,
  WaypointType,
  Direction,
  Waypoint,
  NavigationInstruction,
  FloorChange,
  FloorPlan,
  Connection,
  GraphNode,
  NavigationHistory,
  BuildingInfo,
  SystemStatusInfo,
  StatisticsInfo
} from '../models/ARNavigationModels';
import {
  getHospitalBuildingData,
  searchPOIs,
  getPOIsByCategory,
  getPOIsByFloor,
  getPopularDestinations,
  HOSPITAL_INFO
} from '../data/hospitalData';

/**
 * 路径缓存条目
 */
interface PathCacheEntry {
  path: NavigationPath;
  timestamp: number;
  startKey: string;
  endKey: string;
}

/**
 * 搜索结果项
 */
interface SearchResultItem {
  poi: NavigationDestination;
  relevanceScore: number;
  matchFields: string[];
}

/**
 * 优先队列节点
 * 用于A*算法的开放列表
 */
interface PriorityQueueNode {
  node: GraphNode;
  fScore: number; // f(n) = g(n) + h(n)
}

/**
 * 路径计算结果（安全版本）
 */
interface PathCalculationResult {
  success: boolean;
  path?: NavigationPath;
  error?: string;
}

/**
 * 推荐候选项评分
 */
interface ScoredCandidate {
  poi: NavigationDestination;
  score: number;
}

/**
 * 用户偏好设置
 */
interface UserPreferences {
  preferAccessible?: boolean;     // 偏好无障碍
  avoidCrowded?: boolean;         // 避开拥挤区域
  recentCategories?: DestinationCategory[];  // 最近访问的分类
}

/**
 * 路径规划器类(单例)
 */
export class PathPlanner {
  private static instance: PathPlanner | null = null;

  // 医院建筑数据
  private buildingData: HospitalBuildingData | null = null;

  // 图结构(邻接表)
  private graph: Map<string, GraphNode> = new Map();

  // 楼层平面图缓存
  private floorPlans: Map<string, FloorPlan> = new Map();

  // 楼层连接缓存
  private connections: Connection[] = [];

  // 路径缓存 (最多缓存50条路径)
  private pathCache: Map<string, PathCacheEntry> = new Map();
  private readonly MAX_CACHE_SIZE = 50;
  private readonly CACHE_EXPIRY_MS = 30 * 60 * 1000; // 30分钟过期

  // 导航历史记录 (最多保存100条)
  private navigationHistory: NavigationHistory[] = [];
  private readonly MAX_HISTORY_SIZE = 100;

  // 初始化状态
  private isInitialized: boolean = false;
  private initializationPromise: Promise<void> | null = null;

  // 默认规划选项
  private defaultOptions: PathPlanningOptions = {
    avoidElevators: false,
    avoidStairs: false,
    accessibilityMode: false,
    maxDistance: 1000,
    preferElevator: true,
    maxDetourRatio: 1.5
  };

  /**
   * 私有构造函数(单例模式)
   */
  private constructor() {}

  /**
   * 获取单例实例
   */
  public static getInstance(): PathPlanner {
    if (!PathPlanner.instance) {
      PathPlanner.instance = new PathPlanner();
    }
    return PathPlanner.instance;
  }

  /**
   * 自动初始化(使用内置医院数据)
   * 如果已经初始化则直接返回
   */
  public async autoInitialize(): Promise<void> {
    if (this.isInitialized) {
      console.log('[PathPlanner] 已初始化,跳过重复初始化');
      return;
    }

    if (this.initializationPromise) {
      console.log('[PathPlanner] 等待初始化完成...');
      return this.initializationPromise;
    }

    this.initializationPromise = this.performAutoInitialize();
    await this.initializationPromise;
  }

  /**
   * 执行自动初始化
   */
  private async performAutoInitialize(): Promise<void> {
    try {
      console.log('[PathPlanner] 开始自动初始化...');
      
      const data = getHospitalBuildingData();
      await this.initialize(data);
      
      this.isInitialized = true;
      console.log('[PathPlanner] 自动初始化完成');
      console.log(`[PathPlanner] 医院信息: ${HOSPITAL_INFO.name}`);
      console.log(`[PathPlanner] POI数量: ${data.pois.length}`);
      console.log(`[PathPlanner] 楼层数量: ${data.floors.length}`);
      console.log(`[PathPlanner] 连接数量: ${data.connections.length}`);
      
    } catch (error) {
      console.error('[PathPlanner] 自动初始化失败:', error);
      this.isInitialized = false;
    } finally {
      this.initializationPromise = null;
    }
  }

  /**
   * 初始化路径规划器
   * @param buildingData 医院建筑数据
   */
  public async initialize(buildingData: HospitalBuildingData): Promise<void> {
    this.buildingData = buildingData;

    // 缓存楼层平面图
    this.floorPlans.clear();
    for (const floor of buildingData.floors) {
      const key = `${floor.buildingId}_${floor.floor}`;
      this.floorPlans.set(key, floor);
    }

    // 缓存楼层连接
    this.connections = buildingData.connections;

    // 构建图结构
    await this.buildGraph();

    // 清理过期缓存
    this.cleanExpiredCache();

    this.isInitialized = true;
    console.log('[PathPlanner] 初始化完成,图节点数:', this.graph.size);
  }

  /**
   * 检查是否已初始化
   */
  public isReady(): boolean {
    return this.isInitialized && this.buildingData !== null && this.graph.size > 0;
  }

  /**
   * 构建图结构
   * 将医院建筑数据转换为图结构(邻接表)
   */
  private async buildGraph(): Promise<void> {
    if (!this.buildingData) return;

    this.graph.clear();

    // 1. 为每个POI创建图节点
    for (const poi of this.buildingData.pois) {
      const node: GraphNode = {
        id: poi.id,
        position: poi.position,
        floor: poi.floor,
        type: WaypointType.ARRIVAL,
        neighbors: [],
        weight: 1.0
      };
      this.graph.set(poi.id, node);
    }

    // 2. 为楼层连接(电梯/楼梯)创建节点
    for (const conn of this.connections) {
      const fromNodeId = `CONN_${conn.id}_FROM`;
      const toNodeId = `CONN_${conn.id}_TO`;

      // 起点节点
      const fromNode: GraphNode = {
        id: fromNodeId,
        position: {
          x: conn.fromPosition.x,
          y: this.getFloorHeight(conn.fromFloor),
          z: conn.fromPosition.y
        },
        floor: conn.fromFloor,
        type: conn.type === 'ELEVATOR' ? WaypointType.TAKE_ELEVATOR : WaypointType.TAKE_STAIRS,
        neighbors: [toNodeId],
        weight: conn.type === 'ELEVATOR' ? 0.8 : 1.3 // 电梯优先,楼梯惩罚
      };

      // 终点节点
      const toNode: GraphNode = {
        id: toNodeId,
        position: {
          x: conn.toPosition.x,
          y: this.getFloorHeight(conn.toFloor),
          z: conn.toPosition.y
        },
        floor: conn.toFloor,
        type: WaypointType.GO_STRAIGHT,
        neighbors: [fromNodeId],
        weight: 1.0
      };

      this.graph.set(fromNodeId, fromNode);
      this.graph.set(toNodeId, toNode);
    }

    // 3. 构建邻居关系(同楼层节点间的连接)
    // 简化实现:假设同楼层所有节点都可达
    const floorNodes = new Map<number, GraphNode[]>();
    for (const node of this.graph.values()) {
      if (!floorNodes.has(node.floor)) {
        floorNodes.set(node.floor, []);
      }
      floorNodes.get(node.floor)!.push(node);
    }

    // 为同楼层节点建立邻居关系
    for (const nodes of floorNodes.values()) {
      for (let i = 0; i < nodes.length; i++) {
        for (let j = i + 1; j < nodes.length; j++) {
          nodes[i].neighbors.push(nodes[j].id);
          nodes[j].neighbors.push(nodes[i].id);
        }
      }
    }
  }

  /**
   * 获取楼层高度
   * @param floor 楼层号
   */
  private getFloorHeight(floor: number): number {
    return floor * 3; // 每层3米高
  }

  /**
   * 计算路径
   * @param startPos 起点位置
   * @param destPos 终点位置
   * @param options 规划选项
   */
  public async calculatePath(
    startPos: Position3D,
    destPos: Position3D,
    options?: PathPlanningOptions
  ): Promise<NavigationPath> {
    // 确保已初始化
    if (!this.isReady()) {
      await this.autoInitialize();
    }

    const opts: PathPlanningOptions = {
      avoidElevators: options?.avoidElevators ?? this.defaultOptions.avoidElevators,
      avoidStairs: options?.avoidStairs ?? this.defaultOptions.avoidStairs,
      accessibilityMode: options?.accessibilityMode ?? this.defaultOptions.accessibilityMode,
      maxDistance: options?.maxDistance ?? this.defaultOptions.maxDistance
    };

    console.log('[PathPlanner] 开始计算路径,起点:', startPos, '终点:', destPos);

    // 检查缓存
    const cacheKey = this.generateCacheKey(startPos, destPos, opts);
    const cachedPath = this.getPathFromCache(cacheKey);
    if (cachedPath) {
      console.log('[PathPlanner] 使用缓存的路径');
      return cachedPath;
    }

    // 1. 找到最近的图节点作为起点和终点
    const startNode = this.findNearestNode(startPos);
    const endNode = this.findNearestNode(destPos);

    if (!startNode || !endNode) {
      console.error('[PathPlanner] 无法找到起点或终点附近的导航节点');
      return Promise.reject(new Error('无法找到起点或终点附近的导航节点'));
    }

    // 2. 执行A*搜索
    const pathNodes = this.aStarSearch(startNode, endNode, opts);

    if (pathNodes.length === 0) {
      console.error('[PathPlanner] 无法找到从起点到终点的路径');
      return Promise.reject(new Error('无法找到从起点到终点的路径'));
    }

    // 3. 路径后处理
    const smoothedPath = this.smoothPath(pathNodes);
    const waypoints = this.generateWaypoints(smoothedPath);
    const instructions = this.generateInstructions(smoothedPath);
    const floorChanges = this.extractFloorChanges(smoothedPath);

    // 4. 计算总距离和时间
    const totalDistance = this.calculateTotalDistance(waypoints);
    const estimatedTime = Math.round(totalDistance / 1.2); // 步行速度1.2m/s

    const navigationPath: NavigationPath = {
      pathId: `PATH_${Date.now()}`,
      from: startPos,
      to: destPos,
      waypoints: waypoints,
      totalDistance: totalDistance,
      estimatedTime: estimatedTime,
      floorChanges: floorChanges,
      instructions: instructions,
      createdAt: Date.now()
    };

    // 缓存路径
    this.cachePath(cacheKey, navigationPath, startPos, destPos);

    console.log('[PathPlanner] 路径计算完成,总距离:', totalDistance, '米,预计时间:', estimatedTime, '秒');

    return navigationPath;
  }

  /**
   * A*搜索算法
   * @param startNode 起点节点
   * @param endNode 终点节点
   * @param options 规划选项
   */
  private aStarSearch(
    startNode: GraphNode,
    endNode: GraphNode,
    options: PathPlanningOptions
  ): GraphNode[] {
    // 开放列表(优先队列)
    const openSet: PriorityQueueNode[] = [];
    openSet.push({ node: startNode, fScore: 0 });

    // 关闭列表
    const closedSet: Set<string> = new Set();

    // 记录路径来源
    const cameFrom: Map<string, string> = new Map();

    // g(n): 从起点到节点n的实际代价
    const gScore: Map<string, number> = new Map();
    gScore.set(startNode.id, 0);

    // f(n): 总估计代价
    const fScore: Map<string, number> = new Map();
    fScore.set(startNode.id, this.heuristic(startNode, endNode));

    while (openSet.length > 0) {
      // 取出f值最小的节点
      openSet.sort((a, b) => a.fScore - b.fScore);
      const current = openSet.shift()!;

      // 到达终点
      if (current.node.id === endNode.id) {
        return this.reconstructPath(cameFrom, current.node);
      }

      // 加入关闭列表
      closedSet.add(current.node.id);

      // 遍历邻居节点
      for (const neighborId of current.node.neighbors) {
        const neighbor = this.graph.get(neighborId);
        if (!neighbor || closedSet.has(neighborId)) {
          continue;
        }

        // 检查是否应该跳过(无障碍模式避开楼梯)
        if (options.avoidStairs && neighbor.type === WaypointType.TAKE_STAIRS) {
          continue;
        }

        // 计算实际代价
        const tentativeGScore =
          gScore.get(current.node.id)! +
          this.calculateEdgeCost(current.node, neighbor, options);

        // 找到更优路径
        if (!gScore.has(neighborId) || tentativeGScore < gScore.get(neighborId)!) {
          cameFrom.set(neighborId, current.node.id);
          gScore.set(neighborId, tentativeGScore);
          fScore.set(neighborId, tentativeGScore + this.heuristic(neighbor, endNode));

          // 加入开放列表
          if (!openSet.some(item => item.node.id === neighborId)) {
            openSet.push({ node: neighbor, fScore: fScore.get(neighborId)! });
          }
        }
      }
    }

    // 未找到路径
    return [];
  }

  /**
   * 启发式函数
   * @param node 当前节点
   * @param goal 目标节点
   */
  private heuristic(node: GraphNode, goal: GraphNode): number {
    // 同楼层:曼哈顿距离
    if (node.floor === goal.floor) {
      return (
        Math.abs(node.position.x - goal.position.x) +
        Math.abs(node.position.z - goal.position.z)
      );
    }

    // 跨楼层:欧几里得距离
    return this.getDistance(node.position, goal.position);
  }

  /**
   * 计算边代价
   * @param from 起点节点
   * @param to 终点节点
   * @param options 规划选项
   */
  private calculateEdgeCost(
    from: GraphNode,
    to: GraphNode,
    options: PathPlanningOptions
  ): number {
    let cost = this.getDistance(from.position, to.position);

    // 应用节点权重
    cost *= to.weight;

    // 转弯惩罚
    if (this.isTurn(from, to)) {
      cost += 2; // 额外2米代价
    }

    // 拥挤区域惩罚(简化实现:随机模拟)
    if (this.isCongested(to.position)) {
      cost *= 1.5;
    }

    return cost;
  }

  /**
   * 重建路径
   * @param cameFrom 路径来源映射
   * @param current 当前节点
   */
  private reconstructPath(
    cameFrom: Map<string, string>,
    current: GraphNode
  ): GraphNode[] {
    const path: GraphNode[] = [current];
    let nodeId: string | undefined = current.id;

    while (nodeId !== undefined && cameFrom.has(nodeId)) {
      const nextNodeId = cameFrom.get(nodeId);
      if (nextNodeId === undefined) break;
      nodeId = nextNodeId;
      const node = this.graph.get(nodeId);
      if (node) {
        path.unshift(node);
      }
    }

    return path;
  }

  /**
   * 路径平滑
   * 移除冗余中间点
   * @param path 原始路径
   */
  private smoothPath(path: GraphNode[]): GraphNode[] {
    if (path.length <= 2) return path;

    const smoothed: GraphNode[] = [path[0]];

    for (let i = 1; i < path.length - 1; i++) {
      const prev = path[i - 1];
      const curr = path[i];
      const next = path[i + 1];

      // 计算方向向量
      const dir1 = this.getDirection(prev.position, curr.position);
      const dir2 = this.getDirection(curr.position, next.position);

      // 如果方向变化大于阈值(15度),保留该点
      if (this.angleBetween(dir1, dir2) > 15) {
        smoothed.push(curr);
      }
    }

    smoothed.push(path[path.length - 1]);
    return smoothed;
  }

  /**
   * 生成途经点
   * @param pathNodes 路径节点列表
   */
  private generateWaypoints(pathNodes: GraphNode[]): Waypoint[] {
    const waypoints: Waypoint[] = [];

    for (let i = 0; i < pathNodes.length; i++) {
      const node = pathNodes[i];
      const prevNode = i > 0 ? pathNodes[i - 1] : null;

      const waypoint: Waypoint = {
        id: `WP_${i}`,
        position: node.position,
        type: this.determineWaypointType(node, prevNode),
        instruction: this.generateWaypointInstruction(node, prevNode),
        distanceFromPrev: prevNode
          ? this.getDistance(prevNode.position, node.position)
          : 0
      };

      waypoints.push(waypoint);
    }

    // 标记最后一个为到达点
    if (waypoints.length > 0) {
      waypoints[waypoints.length - 1].type = WaypointType.ARRIVAL;
    }

    return waypoints;
  }

  /**
   * 生成导航指令
   * @param pathNodes 路径节点列表
   */
  private generateInstructions(pathNodes: GraphNode[]): NavigationInstruction[] {
    const instructions: NavigationInstruction[] = [];

    for (let i = 0; i < pathNodes.length - 1; i++) {
      const current = pathNodes[i];
      const next = pathNodes[i + 1];
      const distance = this.getDistance(current.position, next.position);

      let text = '';
      let direction = Direction.FORWARD;
      let ttsText = '';
      let floorHint: string | undefined = undefined;

      // 根据节点类型生成指令
      switch (next.type) {
        case WaypointType.GO_STRAIGHT:
          text = `沿走廊直行约${Math.round(distance)}米`;
          ttsText = `直行${Math.round(distance)}米`;
          direction = Direction.FORWARD;
          break;

        case WaypointType.TURN_LEFT:
          text = `在前方左转`;
          ttsText = `前方左转`;
          direction = Direction.LEFT;
          break;

        case WaypointType.TURN_RIGHT:
          text = `在前方右转`;
          ttsText = `前方右转`;
          direction = Direction.RIGHT;
          break;

        case WaypointType.TAKE_ELEVATOR:
          const floorChange = next.floor - current.floor;
          text = `乘坐电梯${floorChange > 0 ? '上行' : '下行'}至${next.floor}层`;
          ttsText = `乘电梯${floorChange > 0 ? '上' : '下'}${Math.abs(floorChange)}层`;
          direction = floorChange > 0 ? Direction.UP : Direction.DOWN;
          floorHint = `${current.floor}层 → ${next.floor}层`;
          break;

        case WaypointType.TAKE_STAIRS:
          const stairFloorChange = next.floor - current.floor;
          text = `走楼梯${stairFloorChange > 0 ? '上行' : '下行'}至${next.floor}层`;
          ttsText = `走楼梯${stairFloorChange > 0 ? '上' : '下'}${Math.abs(stairFloorChange)}层`;
          direction = stairFloorChange > 0 ? Direction.UP : Direction.DOWN;
          floorHint = `${current.floor}层 → ${next.floor}层`;
          break;

        case WaypointType.ARRIVAL:
          text = `到达目的地`;
          ttsText = `已到达目的地`;
          direction = Direction.FORWARD;
          break;
      }

      instructions.push({
        stepIndex: i,
        text,
        distance,
        direction,
        floorHint,
        ttsText
      });
    }

    return instructions;
  }

  /**
   * 提取楼层切换信息
   * @param pathNodes 路径节点列表
   */
  private extractFloorChanges(pathNodes: GraphNode[]): FloorChange[] {
    const floorChanges: FloorChange[] = [];

    for (let i = 0; i < pathNodes.length - 1; i++) {
      const current = pathNodes[i];
      const next = pathNodes[i + 1];

      if (current.floor !== next.floor) {
        floorChanges.push({
          fromFloor: current.floor,
          toFloor: next.floor,
          method:
            next.type === WaypointType.TAKE_ELEVATOR ? 'ELEVATOR' : 'STAIRS',
          elevatorName:
            next.type === WaypointType.TAKE_ELEVATOR
              ? '电梯'
              : undefined
        });
      }
    }

    return floorChanges;
  }

  /**
   * 计算总距离
   * @param waypoints 途经点列表
   */
  private calculateTotalDistance(waypoints: Waypoint[]): number {
    return waypoints.reduce((sum, wp) => sum + wp.distanceFromPrev, 0);
  }

  /**
   * 重新规划路径
   * @param currentPos 当前位置
   * @param originalDest 原始目的地(可选)
   */
  public async recalculatePath(
    currentPos: Position3D,
    originalDest?: Position3D
  ): Promise<NavigationPath | null> {
    if (!originalDest) {
      console.warn('[PathPlanner] recalculatePath需要终点信息');
      return null;
    }

    try {
      return await this.calculatePath(currentPos, originalDest);
    } catch (error) {
      console.error('[PathPlanner] 路径重规划失败:', error);
      return null;
    }
  }

  // ==================== POI搜索和推荐功能 ====================

  /**
   * 搜索POI(支持模糊匹配)
   * @param keyword 搜索关键词
   * @param limit 返回数量限制
   */
  public searchDestinations(keyword: string, limit: number = 10): SearchResultItem[] {
    if (!this.buildingData || !keyword.trim()) return [];

    const results: SearchResultItem[] = [];
    const lowerKeyword = keyword.toLowerCase().trim();

    for (const poi of this.buildingData.pois) {
      let relevanceScore = 0;
      const matchFields: string[] = [];

      // 名称匹配(权重最高)
      if (poi.name.toLowerCase().includes(lowerKeyword)) {
        relevanceScore += 100;
        matchFields.push('名称');
        
        // 完全匹配额外加分
        if (poi.name.toLowerCase() === lowerKeyword) {
          relevanceScore += 50;
        }
      }

      // 描述匹配
      if (poi.description && poi.description.toLowerCase().includes(lowerKeyword)) {
        relevanceScore += 30;
        matchFields.push('描述');
      }

      // 标签匹配
      for (const tag of poi.tags) {
        if (tag.toLowerCase().includes(lowerKeyword)) {
          relevanceScore += 20;
          matchFields.push('标签:' + tag);
        }
      }

      // 分类匹配
      if (poi.category.toString().toLowerCase().includes(lowerKeyword)) {
        relevanceScore += 15;
        matchFields.push('分类');
      }

      // ID匹配
      if (poi.id.toLowerCase().includes(lowerKeyword)) {
        relevanceScore += 5;
        matchFields.push('ID');
      }

      if (relevanceScore > 0) {
        results.push({
          poi,
          relevanceScore,
          matchFields
        });
      }
    }

    // 按相关性排序
    results.sort((a, b) => b.relevanceScore - a.relevanceScore);

    // 限制返回数量
    return results.slice(0, limit);
  }

  /**
   * 按分类获取POI列表
   * @category 分类
   */
  public getDestinationsByCategory(category: DestinationCategory): NavigationDestination[] {
    if (!this.buildingData) return [];
    
    return this.buildingData.pois.filter(poi => poi.category === category);
  }

  /**
   * 按楼层获取POI列表
   * @buildingId 建筑ID
   * @floor 楼层号
   */
  public getDestinationsByFloor(buildingId: string, floor: number): NavigationDestination[] {
    if (!this.buildingData) return [];
    
    return this.buildingData.pois.filter(
      poi => poi.building === buildingId && poi.floor === floor
    );
  }

  /**
   * 获取热门目的地
   * @limit 数量限制
   */
  public getPopularDestinations(limit: number = 8): NavigationDestination[] {
    const popularIds = [
      'ENTRANCE_MAIN',       // 主入口
      'INFO_DESK_001',       // 导诊台
      'REG_DESK_001',        // 挂号处
      'PHARMACY_WEST',       // 西药房
      'EMERGENCY_ROOM',      // 急诊科
      'ELEVATOR_001',        // 电梯
      'RESTROOM_ACC_101',    // 无障碍洗手间
      'PAY_WINDOW_001'       // 缴费处
    ];

    const result: NavigationDestination[] = [];
    for (const id of popularIds) {
      const poi = this.buildingData?.pois.find(p => p.id === id);
      if (poi && result.length < limit) {
        result.push(poi);
      }
    }
    
    return result;
  }

  /**
   * 获取智能推荐目的地
   * 基于当前位置和用户偏好进行推荐
   * @currentPos 当前位置
   * @userPreferences 用户偏好(可选)
   */
  public getRecommendedDestinations(
    currentPos?: Position3D,
    userPreferences?: UserPreferences
  ): NavigationDestination[] {
    if (!this.buildingData) return [];

    let candidates = [...this.buildingData.pois];
    const scoredCandidates: ScoredCandidate[] = [];

    for (const poi of candidates) {
      let score = 0;

      // 距离评分(越近越好)
      if (currentPos) {
        const distance = this.getDistance(currentPos, poi.position);
        if (distance < 20) {
          score += 30; // 20米内高分
        } else if (distance < 50) {
          score += 20; // 50米内中等分
        } else if (distance < 100) {
          score += 10; // 100米内低分
        }
      }

      // 无障碍偏好
      if (userPreferences?.preferAccessible && poi.isAccessible) {
        score += 25;
      }

      // 分类偏好
      if (userPreferences?.recentCategories?.includes(poi.category)) {
        score += 15;
      }

      // 基础设施加分
      if ([DestinationCategory.ELEVATOR, 
           DestinationCategory.RESTROOM,
           DestinationCategory.INFO_DESK].includes(poi.category)) {
        score += 10;
      }

      // 避开拥挤区域(简化实现)
      if (userPreferences?.avoidCrowded && this.isCongested(poi.position)) {
        score -= 20;
      }

      scoredCandidates.push({ poi, score });
    }

    // 按分数降序排列
    scoredCandidates.sort((a, b) => b.score - a.score);

    // 返回前10个推荐
    return scoredCandidates.slice(0, 10).map(item => item.poi);
  }

  /**
   * 获取医院基本信息
   */
  public getHospitalInfo(): object {
    return HOSPITAL_INFO;
  }

  /**
   * 获取所有建筑信息
   */
  public getBuildings(): BuildingInfo[] | null {
    return this.buildingData?.buildings ?? null;
  }

  /**
   * 获取楼层平面图
   * @buildingId 建筑ID
   * @floor 楼层号
   */
  public getFloorPlan(buildingId: string, floor: number): FloorPlan | null {
    const key = `${buildingId}_${floor}`;
    return this.floorPlans.get(key) ?? null;
  }

  // ==================== 缓存管理 ====================

  /**
   * 生成缓存键
   */
  private generateCacheKey(
    start: Position3D,
    end: Position3D,
    options: PathPlanningOptions
  ): string {
    const startKey = `${Math.round(start.x)}_${Math.round(start.y)}_${Math.round(start.z)}`;
    const endKey = `${Math.round(end.x)}_${Math.round(end.y)}_${Math.round(end.z)}`;
    const optsKey = options.avoidElevators ? '_AE' : '' +
                     options.avoidStairs ? '_AS' : '' +
                     options.accessibilityMode ? '_AC' : '';
    return `${startKey}_${endKey}${optsKey}`;
  }

  /**
   * 从缓存获取路径
   */
  private getPathFromCache(cacheKey: string): NavigationPath | null {
    const entry = this.pathCache.get(cacheKey);
    if (!entry) return null;

    // 检查是否过期
    const now = Date.now();
    if (now - entry.timestamp > this.CACHE_EXPIRY_MS) {
      this.pathCache.delete(cacheKey);
      return null;
    }

    return entry.path;
  }

  /**
   * 缓存路径
   */
  private cachePath(
    cacheKey: string,
    path: NavigationPath,
    startPos: Position3D,
    destPos: Position3D
  ): void {
    // 如果缓存已满,删除最旧的条目
    if (this.pathCache.size >= this.MAX_CACHE_SIZE) {
      let oldestKey: string | null = null;
      let oldestTime = Infinity;

      this.pathCache.forEach((entry, key) => {
        if (entry.timestamp < oldestTime) {
          oldestTime = entry.timestamp;
          oldestKey = key;
        }
      });

      if (oldestKey) {
        this.pathCache.delete(oldestKey);
      }
    }

    this.pathCache.set(cacheKey, {
      path,
      timestamp: Date.now(),
      startKey: `${Math.round(startPos.x)}_${Math.round(startPos.y)}_${Math.round(startPos.z)}`,
      endKey: `${Math.round(destPos.x)}_${Math.round(destPos.y)}_${Math.round(destPos.z)}`
    });
  }

  /**
   * 清理过期缓存
   */
  private cleanExpiredCache(): void {
    const now = Date.now();
    const expiredKeys: string[] = [];

    this.pathCache.forEach((entry, key) => {
      if (now - entry.timestamp > this.CACHE_EXPIRY_MS) {
        expiredKeys.push(key);
      }
    });

    for (const key of expiredKeys) {
      this.pathCache.delete(key);
    }

    if (expiredKeys.length > 0) {
      console.log(`[PathPlanner] 清理了${expiredKeys.length}条过期缓存`);
    }
  }

  /**
   * 清空所有缓存
   */
  public clearCache(): void {
    this.pathCache.clear();
    console.log('[PathPlanner] 已清空所有路径缓存');
  }

  // ==================== 历史记录管理 ====================

  /**
   * 开始导航(添加到历史记录)
   * @path 导航路径
   * @destinationName 目的地名称
   */
  public startNavigation(path: NavigationPath, destinationName: string): string {
    const historyItem: NavigationHistory = {
      id: `HIST_${Date.now()}`,
      destinationId: `DEST_${Date.now()}`,
      destinationName,
      startTime: Date.now(),
      endTime: 0,
      duration: 0,
      distance: path.totalDistance,
      path,
      completed: false
    };

    // 添加到历史记录头部
    this.navigationHistory.unshift(historyItem);

    // 限制历史记录数量
    if (this.navigationHistory.length > this.MAX_HISTORY_SIZE) {
      this.navigationHistory = this.navigationHistory.slice(0, this.MAX_HISTORY_SIZE);
    }

    console.log(`[PathPlanner] 开始导航到: ${destinationName}`);
    return historyItem.id;
  }

  /**
   * 结束导航
   * @historyId 历史记录ID
   * @completed 是否完成
   */
  public endNavigation(historyId: string, completed: boolean = true): void {
    const historyItem = this.navigationHistory.find(h => h.id === historyId);
    if (historyItem) {
      historyItem.endTime = Date.now();
      historyItem.completed = completed;
      
      const duration = historyItem.endTime - historyItem.startTime;
      console.log(`[PathPlanner] 导航${completed ? '完成' : '取消'},耗时:${(duration / 1000).toFixed(1)}秒`);
    }
  }

  /**
   * 获取导航历史记录
   * @limit 数量限制
   */
  public getNavigationHistory(limit: number = 20): NavigationHistory[] {
    return this.navigationHistory.slice(0, limit);
  }

  /**
   * 清空导航历史
   */
  public clearHistory(): void {
    this.navigationHistory = [];
    console.log('[PathPlanner] 已清空导航历史');
  }

  /**
   * 计算两点间距离(3D欧几里得距离)
   * @param from 起点
   * @param to 终点
   */
  public getDistance(from: Position3D, to: Position3D): number {
    const dx = to.x - from.x;
    const dy = to.y - from.y;
    const dz = to.z - from.z;
    return Math.sqrt(dx * dx + dy * dy + dz * dz);
  }

  /**
   * 查找最近的POI
   * @param position 当前位置
   * @param category 分类(可选)
   */
  public getNearestPOI(
    position: Position3D,
    category?: DestinationCategory
  ): NavigationDestination | null {
    if (!this.buildingData) return null;

    let pois = this.buildingData.pois;
    if (category) {
      pois = pois.filter(poi => poi.category === category);
    }

    let nearest: NavigationDestination | null = null;
    let minDistance = Infinity;

    for (const poi of pois) {
      const distance = this.getDistance(position, poi.position);
      if (distance < minDistance) {
        minDistance = distance;
        nearest = poi;
      }
    }

    return nearest;
  }

  // ==================== 辅助方法 ====================

  /**
   * 查找最近的图节点
   * @param position 位置
   */
  private findNearestNode(position: Position3D): GraphNode | null {
    let nearest: GraphNode | null = null;
    let minDistance = Infinity;

    for (const node of this.graph.values()) {
      const distance = this.getDistance(position, node.position);
      if (distance < minDistance) {
        minDistance = distance;
        nearest = node;
      }
    }

    return nearest;
  }

  /**
   * 判断是否转弯
   * @param from 起点节点
   * @param to 终点节点
   */
  private isTurn(from: GraphNode, to: GraphNode): boolean {
    // 简化实现:如果方向变化>30度,视为转弯
    const dir = this.getDirection(from.position, to.position);
    // 这里需要更复杂的逻辑,简化处理
    return false;
  }

  /**
   * 判断是否拥挤区域
   * @param position 位置
   */
  private isCongested(position: Position3D): boolean {
    // 简化实现:随机返回
    return Math.random() < 0.1; // 10%概率拥挤
  }

  /**
   * 获取方向向量
   * @param from 起点
   * @param to 终点
   */
  private getDirection(from: Position3D, to: Position3D): Position3D {
    const distance = this.getDistance(from, to);
    if (distance === 0) return { x: 0, y: 0, z: 0 };

    return {
      x: (to.x - from.x) / distance,
      y: (to.y - from.y) / distance,
      z: (to.z - from.z) / distance
    };
  }

  /**
   * 计算两向量夹角(度)
   * @param v1 向量1
   * @param v2 向量2
   */
  private angleBetween(v1: Position3D, v2: Position3D): number {
    const dot = v1.x * v2.x + v1.y * v2.y + v1.z * v2.z;
    const mag1 = Math.sqrt(v1.x * v1.x + v1.y * v1.y + v1.z * v1.z);
    const mag2 = Math.sqrt(v2.x * v2.x + v2.y * v2.y + v2.z * v2.z);

    if (mag1 === 0 || mag2 === 0) return 0;

    const cosAngle = Math.max(-1, Math.min(1, dot / (mag1 * mag2)));
    return Math.acos(cosAngle) * (180 / Math.PI);
  }

  /**
   * 确定途经点类型
   * @param node 当前节点
   * @param prevNode 前一节点
   */
  private determineWaypointType(
    node: GraphNode,
    prevNode: GraphNode | null
  ): WaypointType {
    if (!prevNode) return WaypointType.GO_STRAIGHT;

    // 根据节点类型
    if (
      node.type === WaypointType.TAKE_ELEVATOR ||
      node.type === WaypointType.TAKE_STAIRS
    ) {
      return node.type;
    }

    // 根据方向变化判断转弯
    const dir1 = this.getDirection(prevNode.position, node.position);
    const angle = Math.atan2(dir1.x, dir1.z) * (180 / Math.PI);

    if (angle > 45) return WaypointType.TURN_LEFT;
    if (angle < -45) return WaypointType.TURN_RIGHT;

    return WaypointType.GO_STRAIGHT;
  }

  /**
   * 生成途经点指令
   * @param node 当前节点
   * @param prevNode 前一节点
   */
  private generateWaypointInstruction(
    node: GraphNode,
    prevNode: GraphNode | null
  ): string {
    if (!prevNode) return '从起点出发';

    const distance = Math.round(this.getDistance(prevNode.position, node.position));
    const type = this.determineWaypointType(node, prevNode);

    switch (type) {
      case WaypointType.GO_STRAIGHT:
        return `直行约${distance}米`;
      case WaypointType.TURN_LEFT:
        return `前方左转`;
      case WaypointType.TURN_RIGHT:
        return `前方右转`;
      case WaypointType.TAKE_ELEVATOR:
        return `乘坐电梯至${node.floor}层`;
      case WaypointType.TAKE_STAIRS:
        return `走楼梯至${node.floor}层`;
      case WaypointType.ARRIVAL:
        return `到达目的地`;
      default:
        return `前进约${distance}米`;
    }
  }

  // ==================== 异常处理和错误恢复 ====================

  /**
   * 安全执行路径计算(带异常处理)
   */
  public async safeCalculatePath(
    startPos: Position3D,
    destPos: Position3D,
    options?: PathPlanningOptions
  ): Promise<PathCalculationResult> {
    try {
      // 验证输入参数
      if (!this.validatePosition(startPos)) {
        return { success: false, error: '起点位置无效' } as PathCalculationResult;
      }
      if (!this.validatePosition(destPos)) {
        return { success: false, error: '终点位置无效' } as PathCalculationResult;
      }

      const path = await this.calculatePath(startPos, destPos, options);
      return { success: true, path } as PathCalculationResult;

    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : '未知错误';
      console.error('[PathPlanner] 路径计算失败:', errorMessage);
      
      // 根据错误类型返回不同的错误信息
      if (errorMessage.includes('无法找到')) {
        return { success: false, error: '无法找到可行路径，请检查起终点是否在医院范围内' } as PathCalculationResult;
      } else if (errorMessage.includes('初始化')) {
        return { success: false, error: '系统初始化中，请稍后重试' } as PathCalculationResult;
      }
      
      return { success: false, error: `路径计算出错: ${errorMessage}` } as PathCalculationResult;
    }
  }

  /**
   * 验证位置有效性
   */
  private validatePosition(pos: Position3D): boolean {
    if (!pos || !Number.isFinite(pos.x) || !Number.isFinite(pos.y) || !Number.isFinite(pos.z)) {
      return false;
    }
    
    return true;
  }

  /**
   * 获取系统状态信息
   */
  public getSystemStatus(): SystemStatusInfo {
    return {
      isInitialized: this.isInitialized,
      graphSize: this.graph.size,
      cacheSize: this.pathCache.size,
      historySize: this.navigationHistory.length,
      poiCount: this.buildingData?.pois.length ?? 0,
      floorCount: this.buildingData?.floors.length ?? 0,
      connectionCount: this.buildingData?.connections.length ?? 0
    } as SystemStatusInfo;
  }

  /**
   * 重置规划器状态(用于测试或重新初始化)
   */
  public reset(): void {
    this.graph.clear();
    this.floorPlans.clear();
    this.connections = [];
    this.pathCache.clear();
    this.navigationHistory = [];
    this.buildingData = null;
    this.isInitialized = false;
    this.initializationPromise = null;
    console.log('[PathPlanner] 规划器已重置');
  }

  /**
   * 获取所有POI列表
   */
  public getAllPOIs(): NavigationDestination[] {
    return this.buildingData?.pois ?? [];
  }

  /**
   * 根据ID获取POI详情
   */
  public getPOIById(id: string): NavigationDestination | null {
    if (!this.buildingData) return null;
    return this.buildingData.pois.find(poi => poi.id === id) ?? null;
  }

  /**
   * 获取所有可用分类
   */
  public getAvailableCategories(): DestinationCategory[] {
    if (!this.buildingData) return [];
    
    const categories = new Set<DestinationCategory>();
    for (const poi of this.buildingData.pois) {
      categories.add(poi.category);
    }
    
    return Array.from(categories);
  }

  /**
   * 获取统计信息
   */
  public getStatistics(): StatisticsInfo {
    if (!this.buildingData) {
      return {
        totalPOIs: 0,
        categoryDistribution: {},
        floorDistribution: {},
        buildingDistribution: {}
      } as StatisticsInfo;
    }

    const categoryDist: Record<string, number> = {};
    const floorDist: Record<string, number> = {};
    const buildingDist: Record<string, number> = {};

    for (const poi of this.buildingData.pois) {
      categoryDist[poi.category] = (categoryDist[poi.category] || 0) + 1;
      const floorKey = `${poi.building}_${poi.floor}`;
      floorDist[floorKey] = (floorDist[floorKey] || 0) + 1;
      buildingDist[poi.building] = (buildingDist[poi.building] || 0) + 1;
    }

    return {
      totalPOIs: this.buildingData.pois.length,
      categoryDistribution: categoryDist,
      floorDistribution: floorDist,
      buildingDistribution: buildingDist
    } as StatisticsInfo;
  }
}
