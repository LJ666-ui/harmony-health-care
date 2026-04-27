/**
 * AR院内导航系统 - Mock数据
 * 
 * 提供开发和测试所需的模拟数据
 * 包括医院建筑数据、POI列表、示例导航路径等
 * 
 * @version 1.0
 * @date 2025-01-18
 * @author SDD Agent
 */

import {
  HospitalBuildingData,
  NavigationDestination,
  NavigationPath,
  DestinationCategory,
  WaypointType,
  Direction,
  Position3D,
  Position2D,
  BuildingInfo,
  FloorPlan,
  Connection,
  Waypoint,
  NavigationInstruction,
  FloorChange
} from '../models/ARNavigationModels';

/**
 * 获取完整的医院建筑数据
 * 包含2栋楼(门诊楼+住院楼),共8层,20+个POI
 */
export function getMockHospitalData(): HospitalBuildingData {
  return {
    // 建筑列表
    buildings: [
      {
        id: 'OUTPATIENT',
        name: '门诊大楼',
        totalFloors: 3,
        entrancePosition: { x: 0, y: 0, z: 0 }
      },
      {
        id: 'INPATIENT',
        name: '住院大楼',
        totalFloors: 5,
        entrancePosition: { x: 100, y: 0, z: 50 }
      }
    ],

    // 楼层平面图列表
    floors: [
      // 门诊楼B1层
      {
        buildingId: 'OUTPATIENT',
        floor: -1,
        width: 800,
        height: 600,
        scale: 10, // 10像素 = 1米
        walkableAreas: [
          {
            points: [
              { x: 0, y: 0 },
              { x: 80, y: 0 },
              { x: 80, y: 60 },
              { x: 0, y: 60 }
            ],
            type: 'CORRIDOR'
          }
        ],
        obstacles: [
          { position: { x: 40, y: 30 }, radius: 2, type: 'PILLAR' }
        ],
        imageUri: 'resource://RAWFILE/floor_outpatient_b1.png'
      },
      // 门诊楼1层
      {
        buildingId: 'OUTPATIENT',
        floor: 1,
        width: 800,
        height: 600,
        scale: 10,
        walkableAreas: [
          {
            points: [
              { x: 0, y: 0 },
              { x: 80, y: 0 },
              { x: 80, y: 60 },
              { x: 0, y: 60 }
            ],
            type: 'HALL'
          }
        ],
        obstacles: [
          { position: { x: 20, y: 30 }, radius: 3, type: 'PILLAR' },
          { position: { x: 60, y: 30 }, radius: 3, type: 'PILLAR' }
        ],
        imageUri: 'resource://RAWFILE/floor_outpatient_1f.png'
      },
      // 门诊楼2层
      {
        buildingId: 'OUTPATIENT',
        floor: 2,
        width: 800,
        height: 600,
        scale: 10,
        walkableAreas: [
          {
            points: [
              { x: 0, y: 0 },
              { x: 80, y: 0 },
              { x: 80, y: 60 },
              { x: 0, y: 60 }
            ],
            type: 'CORRIDOR'
          }
        ],
        obstacles: [],
        imageUri: 'resource://RAWFILE/floor_outpatient_2f.png'
      },
      // 门诊楼3层
      {
        buildingId: 'OUTPATIENT',
        floor: 3,
        width: 800,
        height: 600,
        scale: 10,
        walkableAreas: [
          {
            points: [
              { x: 0, y: 0 },
              { x: 80, y: 0 },
              { x: 80, y: 60 },
              { x: 0, y: 60 }
            ],
            type: 'CORRIDOR'
          }
        ],
        obstacles: [],
        imageUri: 'resource://RAWFILE/floor_outpatient_3f.png'
      },
      // 住院楼1-5层(简化)
      {
        buildingId: 'INPATIENT',
        floor: 1,
        width: 600,
        height: 400,
        scale: 10,
        walkableAreas: [
          {
            points: [
              { x: 0, y: 0 },
              { x: 60, y: 0 },
              { x: 60, y: 40 },
              { x: 0, y: 40 }
            ],
            type: 'LOBBY'
          }
        ],
        obstacles: [],
        imageUri: 'resource://RAWFILE/floor_inpatient_1f.png'
      }
    ],

    // 兴趣点(POI)列表 - 20+个
    pois: [
      // 科室类
      {
        id: 'DEPT_INTERNAL_301',
        name: '内科诊区301',
        category: DestinationCategory.DEPARTMENT,
        building: 'OUTPATIENT',
        floor: 2,
        position: { x: 45, y: 6, z: 20 },
        description: '内科门诊诊区,包括心血管内科、呼吸内科、消化内科',
        workingHours: '08:00-17:00',
        isAccessible: true,
        tags: ['热门', '门诊', '内科'],
        thumbnailUri: 'resource://RAWFILE/dept_internal.png'
      },
      {
        id: 'DEPT_SURGERY_302',
        name: '外科诊区302',
        category: DestinationCategory.DEPARTMENT,
        building: 'OUTPATIENT',
        floor: 2,
        position: { x: 55, y: 6, z: 20 },
        description: '外科门诊诊区,包括普外科、骨科、泌尿外科',
        workingHours: '08:00-17:00',
        isAccessible: true,
        tags: ['热门', '门诊', '外科'],
        thumbnailUri: 'resource://RAWFILE/dept_surgery.png'
      },
      {
        id: 'DEPT_PEDiatrics_303',
        name: '儿科诊区303',
        category: DestinationCategory.DEPARTMENT,
        building: 'OUTPATIENT',
        floor: 2,
        position: { x: 35, y: 6, z: 40 },
        description: '儿科门诊诊区',
        workingHours: '08:00-17:00',
        isAccessible: true,
        tags: ['门诊', '儿科'],
        thumbnailUri: 'resource://RAWFILE/dept_pediatrics.png'
      },
      {
        id: 'DEPT_GYNECOLOGY_304',
        name: '妇科诊区304',
        category: DestinationCategory.DEPARTMENT,
        building: 'OUTPATIENT',
        floor: 2,
        position: { x: 45, y: 6, z: 40 },
        description: '妇科门诊诊区',
        workingHours: '08:00-17:00',
        isAccessible: true,
        tags: ['门诊', '妇科'],
        thumbnailUri: 'resource://RAWFILE/dept_gynecology.png'
      },
      {
        id: 'DEPT_TCM_401',
        name: '中医科401',
        category: DestinationCategory.DEPARTMENT,
        building: 'OUTPATIENT',
        floor: 3,
        position: { x: 40, y: 9, z: 30 },
        description: '中医科门诊诊区',
        workingHours: '08:00-17:00',
        isAccessible: true,
        tags: ['门诊', '中医'],
        thumbnailUri: 'resource://RAWFILE/dept_tcm.png'
      },

      // 药房类
      {
        id: 'PHARMACY_WEST_101',
        name: '西药房',
        category: DestinationCategory.PHARMACY,
        building: 'OUTPATIENT',
        floor: 1,
        position: { x: 15, y: 0, z: 45 },
        description: '西药取药窗口',
        workingHours: '08:00-18:00',
        isAccessible: true,
        tags: ['热门', '药房'],
        thumbnailUri: 'resource://RAWFILE/pharmacy_west.png'
      },
      {
        id: 'PHARMACY_EAST_102',
        name: '中药房',
        category: DestinationCategory.PHARMACY,
        building: 'OUTPATIENT',
        floor: 1,
        position: { x: 65, y: 0, z: 45 },
        description: '中药取药窗口',
        workingHours: '08:00-17:30',
        isAccessible: true,
        tags: ['药房', '中药'],
        thumbnailUri: 'resource://RAWFILE/pharmacy_east.png'
      },

      // 检验科类
      {
        id: 'LAB_BLOOD_001',
        name: '检验科',
        category: DestinationCategory.LAB,
        building: 'OUTPATIENT',
        floor: -1,
        position: { x: 30, y: -3, z: 30 },
        description: '血液检验、生化检验',
        workingHours: '07:30-17:00',
        isAccessible: true,
        tags: ['热门', '检验'],
        thumbnailUri: 'resource://RAWFILE/lab_blood.png'
      },

      // 影像科类
      {
        id: 'IMAGING_XRAY_002',
        name: '放射科',
        category: DestinationCategory.IMAGING,
        building: 'OUTPATIENT',
        floor: -1,
        position: { x: 50, y: -3, z: 30 },
        description: 'X光、CT、MRI检查',
        workingHours: '08:00-17:00',
        isAccessible: true,
        tags: ['影像', '放射'],
        thumbnailUri: 'resource://RAWFILE/imaging_xray.png'
      },

      // 电梯类
      {
        id: 'ELEVATOR_1_103',
        name: '1号客运电梯',
        category: DestinationCategory.ELEVATOR,
        building: 'OUTPATIENT',
        floor: 1,
        position: { x: 20, y: 0, z: 55 },
        description: '门诊楼主电梯,连接B1-3层',
        isAccessible: true,
        tags: ['电梯', '客运'],
        thumbnailUri: 'resource://RAWFILE/elevator.png'
      },
      {
        id: 'ELEVATOR_2_104',
        name: '2号客运电梯',
        category: DestinationCategory.ELEVATOR,
        building: 'OUTPATIENT',
        floor: 1,
        position: { x: 60, y: 0, z: 55 },
        description: '门诊楼副电梯,连接B1-3层',
        isAccessible: true,
        tags: ['电梯', '客运'],
        thumbnailUri: 'resource://RAWFILE/elevator.png'
      },

      // 洗手间类
      {
        id: 'RESTROOM_MALE_105',
        name: '男洗手间',
        category: DestinationCategory.RESTROOM,
        building: 'OUTPATIENT',
        floor: 1,
        position: { x: 10, y: 0, z: 10 },
        description: '1层男洗手间',
        isAccessible: false,
        tags: ['洗手间'],
        thumbnailUri: 'resource://RAWFILE/restroom_male.png'
      },
      {
        id: 'RESTROOM_FEMALE_106',
        name: '女洗手间',
        category: DestinationCategory.RESTROOM,
        building: 'OUTPATIENT',
        floor: 1,
        position: { x: 10, y: 0, z: 15 },
        description: '1层女洗手间',
        isAccessible: false,
        tags: ['洗手间'],
        thumbnailUri: 'resource://RAWFILE/restroom_female.png'
      },
      {
        id: 'RESTROOM_ACCESSIBLE_107',
        name: '无障碍洗手间',
        category: DestinationCategory.RESTROOM,
        building: 'OUTPATIENT',
        floor: 1,
        position: { x: 10, y: 0, z: 20 },
        description: '无障碍专用洗手间',
        isAccessible: true,
        tags: ['洗手间', '无障碍'],
        thumbnailUri: 'resource://RAWFILE/restroom_accessible.png'
      },

      // 缴费处类
      {
        id: 'PAYMENT_MAIN_108',
        name: '收费处',
        category: DestinationCategory.PAYMENT,
        building: 'OUTPATIENT',
        floor: 1,
        position: { x: 40, y: 0, z: 5 },
        description: '门诊缴费窗口',
        workingHours: '08:00-17:30',
        isAccessible: true,
        tags: ['热门', '缴费'],
        thumbnailUri: 'resource://RAWFILE/payment.png'
      },

      // 急诊类
      {
        id: 'EMERGENCY_MAIN_109',
        name: '急诊科',
        category: DestinationCategory.EMERGENCY,
        building: 'OUTPATIENT',
        floor: 1,
        position: { x: 70, y: 0, z: 10 },
        description: '24小时急诊',
        workingHours: '00:00-24:00',
        isAccessible: true,
        tags: ['热门', '急诊', '24小时'],
        thumbnailUri: 'resource://RAWFILE/emergency.png'
      },

      // 挂号处类
      {
        id: 'REGISTRATION_MAIN_110',
        name: '挂号处',
        category: DestinationCategory.REGISTRATION,
        building: 'OUTPATIENT',
        floor: 1,
        position: { x: 40, y: 0, z: 10 },
        description: '门诊挂号窗口',
        workingHours: '07:00-17:00',
        isAccessible: true,
        tags: ['热门', '挂号'],
        thumbnailUri: 'resource://RAWFILE/registration.png'
      },

      // 病房类
      {
        id: 'WARD_INTERNAL_201',
        name: '内科病房',
        category: DestinationCategory.WARD,
        building: 'INPATIENT',
        floor: 3,
        position: { x: 30, y: 9, z: 20 },
        description: '内科住院部',
        isAccessible: true,
        tags: ['病房', '内科'],
        thumbnailUri: 'resource://RAWFILE/ward.png'
      },
      {
        id: 'WARD_SURGERY_202',
        name: '外科病房',
        category: DestinationCategory.WARD,
        building: 'INPATIENT',
        floor: 4,
        position: { x: 30, y: 12, z: 20 },
        description: '外科住院部',
        isAccessible: true,
        tags: ['病房', '外科'],
        thumbnailUri: 'resource://RAWFILE/ward.png'
      }
    ],

    // 楼层连接列表
    connections: [
      // 门诊楼电梯
      {
        id: 'CONN_ELEVATOR_1',
        fromFloor: 1,
        toFloor: 2,
        fromPosition: { x: 20, y: 55 },
        toPosition: { x: 20, y: 55 },
        type: 'ELEVATOR',
        name: '1号客运电梯'
      },
      {
        id: 'CONN_ELEVATOR_1_B1',
        fromFloor: -1,
        toFloor: 1,
        fromPosition: { x: 20, y: 55 },
        toPosition: { x: 20, y: 55 },
        type: 'ELEVATOR',
        name: '1号客运电梯'
      },
      {
        id: 'CONN_ELEVATOR_2',
        fromFloor: 1,
        toFloor: 2,
        fromPosition: { x: 60, y: 55 },
        toPosition: { x: 60, y: 55 },
        type: 'ELEVATOR',
        name: '2号客运电梯'
      },
      {
        id: 'CONN_ELEVATOR_2_3F',
        fromFloor: 2,
        toFloor: 3,
        fromPosition: { x: 60, y: 55 },
        toPosition: { x: 60, y: 55 },
        type: 'ELEVATOR',
        name: '2号客运电梯'
      },
      // 门诊楼楼梯
      {
        id: 'CONN_STAIRS_1',
        fromFloor: 1,
        toFloor: 2,
        fromPosition: { x: 5, y: 55 },
        toPosition: { x: 5, y: 55 },
        type: 'STAIRS',
        name: '安全通道楼梯'
      }
    ],

    // 无障碍路线覆盖列表
    accessibilityRoutes: [
      {
        originalWaypointId: 'CONN_STAIRS_1',
        alternativePath: [
          {
            id: 'ALT_WP_1',
            position: { x: 20, y: 0, z: 55 },
            type: WaypointType.TAKE_ELEVATOR,
            instruction: '乘坐1号电梯上2层',
            distanceFromPrev: 15,
            landmark: '1号客运电梯'
          }
        ],
        reason: '原路径包含楼梯,不适合无障碍通行'
      }
    ]
  };
}

/**
 * 获取常用目的地列表
 * 按热度排序,用于首页推荐
 */
export function getMockDestinations(): NavigationDestination[] {
  const hospitalData = getMockHospitalData();
  
  // 按tags中是否包含'热门'排序
  return hospitalData.pois.sort((a, b) => {
    const aHot = a.tags.includes('热门') ? 1 : 0;
    const bHot = b.tags.includes('热门') ? 1 : 0;
    return bHot - aHot;
  });
}

/**
 * 按分类获取目的地列表
 * @param category 目的地分类
 */
export function getMockDestinationsByCategory(
  category: DestinationCategory
): NavigationDestination[] {
  const hospitalData = getMockHospitalData();
  return hospitalData.pois.filter(poi => poi.category === category);
}

/**
 * 获取示例导航路径
 * 从门诊大厅到内科诊区301的完整路径
 */
export function getMockNavigationPath(): NavigationPath {
  const waypoints: Waypoint[] = [
    {
      id: 'WP_001',
      position: { x: 0, y: 0, z: 0 },
      type: WaypointType.GO_STRAIGHT,
      instruction: '从门诊大厅入口出发',
      distanceFromPrev: 0
    },
    {
      id: 'WP_002',
      position: { x: 20, y: 0, z: 0 },
      type: WaypointType.GO_STRAIGHT,
      instruction: '沿主走廊直行',
      distanceFromPrev: 20,
      landmark: '圆形咨询台'
    },
    {
      id: 'WP_003',
      position: { x: 20, y: 0, z: 35 },
      type: WaypointType.TURN_RIGHT,
      instruction: '在咨询台右侧右转,进入电梯厅走廊',
      distanceFromPrev: 35,
      landmark: '圆形咨询台'
    },
    {
      id: 'WP_004',
      position: { x: 20, y: 0, z: 55 },
      type: WaypointType.TAKE_ELEVATOR,
      instruction: '乘坐1号客运电梯上行至2层',
      distanceFromPrev: 20,
      landmark: '1号客运电梯'
    },
    {
      id: 'WP_005',
      position: { x: 25, y: 6, z: 55 },
      type: WaypointType.TURN_LEFT,
      instruction: '出电梯后左转',
      distanceFromPrev: 5,
      landmark: '电梯出口'
    },
    {
      id: 'WP_006',
      position: { x: 25, y: 6, z: 35 },
      type: WaypointType.GO_STRAIGHT,
      instruction: '沿走廊直行',
      distanceFromPrev: 20
    },
    {
      id: 'WP_007',
      position: { x: 45, y: 6, z: 20 },
      type: WaypointType.ARRIVAL,
      instruction: '到达内科诊区301',
      distanceFromPrev: 42,
      landmark: '内科分诊台'
    }
  ];

  const instructions: NavigationInstruction[] = [
    {
      stepIndex: 0,
      text: '从门诊大厅入口出发,直行约20米至咨询台',
      distance: 20,
      direction: Direction.FORWARD,
      ttsText: '从门诊大厅出发,直行二十米'
    },
    {
      stepIndex: 1,
      text: '在圆形咨询台右侧右转,进入电梯厅走廊',
      distance: 35,
      direction: Direction.RIGHT,
      ttsText: '在咨询台右转'
    },
    {
      stepIndex: 2,
      text: '沿电梯厅走廊直行约20米至1号电梯',
      distance: 20,
      direction: Direction.FORWARD,
      ttsText: '直行二十米至电梯'
    },
    {
      stepIndex: 3,
      text: '乘坐1号客运电梯上行至2层',
      distance: 5,
      direction: Direction.UP,
      floorHint: '1层 → 2层',
      ttsText: '乘电梯上二层'
    },
    {
      stepIndex: 4,
      text: '出电梯后左转,沿走廊前行约62米到达内科诊区',
      distance: 62,
      direction: Direction.LEFT,
      ttsText: '左转后直行六十二米到达'
    }
  ];

  const floorChanges: FloorChange[] = [
    {
      fromFloor: 1,
      toFloor: 2,
      method: 'ELEVATOR',
      elevatorName: '1号客运电梯'
    }
  ];

  return {
    pathId: 'PATH_DEMO_001',
    from: { x: 0, y: 0, z: 0 },
    to: { x: 45, y: 6, z: 20 },
    waypoints: waypoints,
    totalDistance: 185,
    estimatedTime: 154, // 约2.5分钟
    floorChanges: floorChanges,
    instructions: instructions,
    createdAt: Date.now()
  };
}

/**
 * 获取指定ID的目的地
 * @param destinationId 目的地ID
 */
export function getMockDestinationById(
  destinationId: string
): NavigationDestination | null {
  const hospitalData = getMockHospitalData();
  return hospitalData.pois.find(poi => poi.id === destinationId) || null;
}

/**
 * 搜索目的地
 * @param keyword 搜索关键词
 */
export function searchMockDestinations(keyword: string): NavigationDestination[] {
  const hospitalData = getMockHospitalData();
  const lowerKeyword = keyword.toLowerCase();
  
  return hospitalData.pois.filter(poi => {
    return (
      poi.name.toLowerCase().includes(lowerKeyword) ||
      poi.description.toLowerCase().includes(lowerKeyword) ||
      poi.tags.some(tag => tag.toLowerCase().includes(lowerKeyword))
    );
  });
}

/**
 * 获取指定楼层的目的地列表
 * @param buildingId 建筑ID
 * @param floor 楼层
 */
export function getMockDestinationsByFloor(
  buildingId: string,
  floor: number
): NavigationDestination[] {
  const hospitalData = getMockHospitalData();
  return hospitalData.pois.filter(
    poi => poi.building === buildingId && poi.floor === floor
  );
}

/**
 * 获取楼层平面图
 * @param buildingId 建筑ID
 * @param floor 楼层
 */
export function getMockFloorPlan(
  buildingId: string,
  floor: number
): FloorPlan | null {
  const hospitalData = getMockHospitalData();
  return hospitalData.floors.find(
    f => f.buildingId === buildingId && f.floor === floor
  ) || null;
}

/**
 * 计算两点间的距离(3D欧几里得距离)
 * @param pos1 位置1
 * @param pos2 位置2
 */
export function calculateDistance(pos1: Position3D, pos2: Position3D): number {
  const dx = pos2.x - pos1.x;
  const dy = pos2.y - pos1.y;
  const dz = pos2.z - pos1.z;
  return Math.sqrt(dx * dx + dy * dy + dz * dz);
}

/**
 * 获取附近的目的地
 * @param position 当前位置
 * @param radius 搜索半径(米)
 * @param limit 最大返回数量
 */
export function getMockNearbyDestinations(
  position: Position3D,
  radius: number = 50,
  limit: number = 10
): NavigationDestination[] {
  const hospitalData = getMockHospitalData();
  
  interface DestinationWithDistance {
    destination: NavigationDestination;
    distance: number;
  }
  
  const destinationsWithDistance: DestinationWithDistance[] = hospitalData.pois.map(poi => {
    const item: DestinationWithDistance = {
      destination: poi,
      distance: calculateDistance(position, poi.position)
    };
    return item;
  });
  
  return destinationsWithDistance
    .filter(item => item.distance <= radius)
    .sort((a, b) => a.distance - b.distance)
    .slice(0, limit)
    .map(item => item.destination);
}
