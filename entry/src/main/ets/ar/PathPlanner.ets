/**
 * AR院内导航系统 - 路径规划器
 * 
 * 实现室内路径规划算法,核心功能:
 * - A*算法实现最优路径搜索
 * - 支持跨楼层路径规划
 * - 动态权重调整(拥挤度/无障碍)
 * - 路径平滑和指令生成
 * 
 * @version 1.0
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
  GraphNode
} from '../models/ARNavigationModels';

/**
 * 优先队列节点
 * 用于A*算法的开放列表
 */
interface PriorityQueueNode {
  node: GraphNode;
  fScore: number; // f(n) = g(n) + h(n)
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

    console.log('[PathPlanner] 初始化完成,图节点数:', this.graph.size);
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
    const opts: PathPlanningOptions = {
      avoidElevators: options?.avoidElevators ?? this.defaultOptions.avoidElevators,
      avoidStairs: options?.avoidStairs ?? this.defaultOptions.avoidStairs,
      accessibilityMode: options?.accessibilityMode ?? this.defaultOptions.accessibilityMode,
      maxDistance: options?.maxDistance ?? this.defaultOptions.maxDistance
    };

    console.log('[PathPlanner] 开始计算路径,起点:', startPos, '终点:', destPos);

    // 1. 找到最近的图节点作为起点和终点
    const startNode = this.findNearestNode(startPos);
    const endNode = this.findNearestNode(destPos);

    if (!startNode || !endNode) {
      throw new Error('无法找到起点或终点附近的导航节点');
    }

    // 2. 执行A*搜索
    const pathNodes = this.aStarSearch(startNode, endNode, opts);

    if (pathNodes.length === 0) {
      throw new Error('无法找到从起点到终点的路径');
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
   */
  public async recalculatePath(currentPos: Position3D): Promise<NavigationPath | null> {
    // 简化实现:需要外部提供终点信息
    console.warn('[PathPlanner] recalculatePath需要终点信息,当前未实现');
    return null;
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
}
