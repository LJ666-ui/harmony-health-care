/**
 * AR院内导航系统 - 医院建筑数据(完整版)
 * 
 * 包含完整的医院POI、楼层平面图、连接关系等数据
 * 数据结构基于ARNavigationModels中定义的接口
 * 
 * @version 2.0 (完整版)
 * @date 2025-01-18
 * @author SDD Agent
 */

import {
  HospitalBuildingData,
  NavigationDestination,
  FloorPlan,
  Connection,
  Position3D,
  Position2D,
  DestinationCategory,
  Area,
  Obstacle,
  BuildingInfo
} from '../models/ARNavigationModels';

/**
 * 医院基本信息接口
 */
export interface HospitalInfo {
  name: string;
  address: string;
  totalBuildings: number;
  description: string;
  phone: string;
}

/**
 * 医院名称和基本信息
 */
export const HOSPITAL_INFO: HospitalInfo = {
  name: '和谐健康医院',
  address: '北京市朝阳区健康路88号',
  totalBuildings: 3,
  description: '三级甲等综合医院，拥有门诊大楼、住院部、医技楼三大主体建筑',
  phone: '010-8888-8888'
};

/**
 * 获取完整的医院建筑数据
 */
export function getHospitalBuildingData(): HospitalBuildingData {
  return {
    buildings: getAllBuildings(),
    floors: getAllFloorPlans(),
    pois: getAllPOIs(),
    connections: getAllConnections(),
    accessibilityRoutes: []
  } as HospitalBuildingData;
}

/**
 * 获取所有建筑信息
 */
function getAllBuildings(): BuildingInfo[] {
  return [
    {
      id: 'OUTPATIENT',
      name: '门诊大楼',
      totalFloors: 6, // B1 + 1-5层
      entrancePosition: { x: 40, y: 0, z: 10 } as Position3D
    },
    {
      id: 'INPATIENT',
      name: '住院部',
      totalFloors: 15, // 1-15层
      entrancePosition: { x: 60, y: 0, z: 50 } as Position3D
    },
    {
      id: 'MEDICAL_TECH',
      name: '医技楼',
      totalFloors: 8, // B1 + 1-7层
      entrancePosition: { x: 20, y: 0, z: 30 } as Position3D
    }
  ] as BuildingInfo[];
}

/**
 * 获取所有POI（兴趣点）
 */
function getAllPOIs(): NavigationDestination[] {
  return [
    // ==================== B1层 (地下1层) ====================
    // 停车场相关
    createPOI('PARK_B1_001', '地下停车场B1区', DestinationCategory.PARKING, 'OUTPATIENT', -1,
      { x: 20, y: -3, z: 30 } as Position3D, 'B1层停车场，可容纳200辆车', true, ['停车场', '停车']),
    
    // ==================== 1层 (门诊大厅) ====================
    // 主入口区域
    createPOI('ENTRANCE_MAIN', '主入口', DestinationCategory.ENTRANCE, 'OUTPATIENT', 1,
      { x: 40, y: 0, z: 5 } as Position3D, '门诊大楼正门入口，设有无障碍通道', true, ['入口', '大门']),
    
    // 挂号处
    createPOI('REG_DESK_001', '综合挂号窗口', DestinationCategory.REGISTRATION, 'OUTPATIENT', 1,
      { x: 35, y: 0, z: 15 } as Position3D, '综合挂号处，支持医保卡、自费等多种方式', true, ['挂号', '登记']),
    createPOI('REG_DESK_002', '专家挂号窗口', DestinationCategory.REGISTRATION, 'OUTPATIENT', 1,
      { x: 45, y: 0, z: 15 } as Position3D, '专家门诊挂号专窗', true, ['挂号', '专家号']),
    createPOI('REG_DESK_003', '急诊挂号', DestinationCategory.REGISTRATION, 'OUTPATIENT', 1,
      { x: 25, y: 0, z: 8 } as Position3D, '急诊24小时挂号服务', true, ['急诊', '挂号']),
    
    // 缴费处
    createPOI('PAY_WINDOW_001', '一楼缴费处', DestinationCategory.PAYMENT, 'OUTPATIENT', 1,
      { x: 50, y: 0, z: 12 } as Position3D, '支持现金、刷卡、移动支付', true, ['缴费', '收费']),
    
    // 导诊台
    createPOI('INFO_DESK_001', '大厅导诊台', DestinationCategory.INFO_DESK, 'OUTPATIENT', 1,
      { x: 40, y: 0, z: 20 } as Position3D, '提供就诊咨询、科室指引、轮椅租借等服务', true, ['导诊', '咨询']),
    
    // 急诊科
    createPOI('EMERGENCY_ROOM', '急诊科', DestinationCategory.EMERGENCY, 'OUTPATIENT', 1,
      { x: 15, y: 0, z: 10 } as Position3D, '24小时急诊服务，配备抢救室、观察室', true, ['急诊', '急救']),
    createPOI('EMERGENCY_TRIAGE', '急诊分诊台', DestinationCategory.EMERGENCY, 'OUTPATIENT', 1,
      { x: 20, y: 0, z: 8 } as Position3D, '急诊预检分诊，快速评估病情', true, ['分诊', '急诊']),
    
    // ==================== 2层 (内科诊区) ====================
    // 内科各科室
    createPOI('DEPT_INTERNAL_CARDIO', '心内科', DestinationCategory.DEPARTMENT, 'OUTPATIENT', 2,
      { x: 25, y: 3, z: 15 } as Position3D, '心血管疾病诊疗中心，配备心电图、心脏彩超', true, ['心内科', '心脏']),
    createPOI('DEPT_INTERNAL_RESPIRATORY', '呼吸内科', DestinationCategory.DEPARTMENT, 'OUTPATIENT', 2,
      { x: 35, y: 3, z: 15 } as Position3D, '呼吸系统疾病诊治，配备肺功能检查仪', true, ['呼吸科', '肺']),
    createPOI('DEPT_INTERNAL_GASTRO', '消化内科', DestinationCategory.DEPARTMENT, 'OUTPATIENT', 2,
      { x: 45, y: 3, z: 15 } as Position3D, '胃肠道疾病诊疗，开展胃肠镜检查', true, ['消化科', '胃镜']),
    createPOI('DEPT_INTERNAL_NEPHRO', '肾内科', DestinationCategory.DEPARTMENT, 'OUTPATIENT', 2,
      { x: 55, y: 3, z: 15 } as Position3D, '肾脏病诊治，血液透析中心', true, ['肾内科', '透析']),
    createPOI('DEPT_INTERNAL_ENDO', '内分泌科', DestinationCategory.DEPARTMENT, 'OUTPATIENT', 2,
      { x: 65, y: 3, z: 15 } as Position3D, '糖尿病、甲状腺疾病诊疗', true, ['内分泌', '糖尿病']),
    
    // ==================== 3层 (外科诊区) ====================
    // 外科各科室
    createPOI('DEPT_SURGICAL_GENERAL', '普外科', DestinationCategory.DEPARTMENT, 'OUTPATIENT', 3,
      { x: 25, y: 6, z: 15 } as Position3D, '普通外科，开展腹腔镜手术', true, ['普外科', '腹腔镜']),
    createPOI('DEPT_SURGICAL_ORTHO', '骨科', DestinationCategory.DEPARTMENT, 'OUTPATIENT', 3,
      { x: 35, y: 6, z: 15 } as Position3D, '骨关节疾病、创伤骨折治疗', true, ['骨科', '关节']),
    createPOI('DEPT_SURGICAL_NEURO', '神经外科', DestinationCategory.DEPARTMENT, 'OUTPATIENT', 3,
      { x: 45, y: 6, z: 15 } as Position3D, '颅脑损伤、脑血管疾病外科治疗', true, ['神外', '脑外科']),
    createPOI('DEPT_SURGICAL_UROLOGY', '泌尿外科', DestinationCategory.DEPARTMENT, 'OUTPATIENT', 3,
      { x: 55, y: 6, z: 15 } as Position3D, '泌尿系统疾病、结石治疗', true, ['泌尿外科', '结石']),
    
    // ==================== 4层 (妇儿诊区) ====================
    createPOI('DEPT_OBSTETRICS', '产科', DestinationCategory.DEPARTMENT, 'OUTPATIENT', 4,
      { x: 25, y: 9, z: 15 } as Position3D, '围产期保健、高危妊娠管理', true, ['产科', '孕妇']),
    createPOI('DEPT_GYNECOLOGY', '妇科', DestinationCategory.DEPARTMENT, 'OUTPATIENT', 4,
      { x: 40, y: 9, z: 15 } as Position3D, '妇科疾病诊治、计划生育', true, ['妇科', '女性']),
    createPOI('DEPT_PEDIATRICS', '儿科', DestinationCategory.DEPARTMENT, 'OUTPATIENT', 4,
      { x: 55, y: 9, z: 15 } as Position3D, '儿童常见病、生长发育指导', true, ['儿科', '儿童']),
    createPOI('DEPT_PEDIATRICS_VACCINE', '儿科预防接种', DestinationCategory.DEPARTMENT, 'OUTPATIENT', 4,
      { x: 60, y: 9, z: 20 } as Position3D, '儿童疫苗接种服务', true, ['疫苗', '接种']),
    
    // ==================== 5层 (专科诊区) ====================
    createPOI('DEPT_OPHTHALMOLOGY', '眼科', DestinationCategory.DEPARTMENT, 'OUTPATIENT', 5,
      { x: 25, y: 12, z: 15 } as Position3D, '视力矫正、白内障手术', true, ['眼科', '视力']),
    createPOI('DEPT_ENT', '耳鼻喉科', DestinationCategory.DEPARTMENT, 'OUTPATIENT', 5,
      { x: 40, y: 12, z: 15 } as Position3D, '听力检测、鼻窦炎治疗', true, ['耳鼻喉', '五官']),
    createPOI('DEPT_DERMATOLOGY', '皮肤科', DestinationCategory.DEPARTMENT, 'OUTPATIENT', 5,
      { x: 55, y: 12, z: 15 } as Position3D, '皮肤病诊治、美容护肤', true, ['皮肤科', '美容']),
    createPOI('DEPT_TCM', '中医科', DestinationCategory.DEPARTMENT, 'OUTPATIENT', 5,
      { x: 65, y: 12, z: 15 } as Position3D, '中药调理、针灸推拿', true, ['中医', '针灸']),
    
    // ==================== 各层电梯 ====================
    // 门诊大楼1号客运电梯
    createPOI('ELEV_OUT_001', '1号客运电梯', DestinationCategory.ELEVATOR, 'OUTPATIENT', 1,
      { x: 30, y: 0, z: 25 } as Position3D, '门诊大楼1-5层客运电梯', true, ['电梯', '1号梯']),
    createPOI('ELEV_OUT_001_F2', '1号客运电梯(2F)', DestinationCategory.ELEVATOR, 'OUTPATIENT', 2,
      { x: 30, y: 3, z: 25 } as Position3D, '门诊大楼1-5层客运电梯', true, ['电梯', '1号梯']),
    createPOI('ELEV_OUT_001_F3', '1号客运电梯(3F)', DestinationCategory.ELEVATOR, 'OUTPATIENT', 3,
      { x: 30, y: 6, z: 25 } as Position3D, '门诊大楼1-5层客运电梯', true, ['电梯', '1号梯']),
    createPOI('ELEV_OUT_001_F4', '1号客运电梯(4F)', DestinationCategory.ELEVATOR, 'OUTPATIENT', 4,
      { x: 30, y: 9, z: 25 } as Position3D, '门诊大楼1-5层客运电梯', true, ['电梯', '1号梯']),
    createPOI('ELEV_OUT_001_F5', '1号客运电梯(5F)', DestinationCategory.ELEVATOR, 'OUTPATIENT', 5,
      { x: 30, y: 12, z: 25 } as Position3D, '门诊大楼1-5层客运电梯', true, ['电梯', '1号梯']),
    
    // 门诊大楼2号客运电梯
    createPOI('ELEV_OUT_002', '2号客运电梯', DestinationCategory.ELEVATOR, 'OUTPATIENT', 1,
      { x: 52, y: 0, z: 18 } as Position3D, '门诊大楼B1-5层客运电梯', true, ['电梯', '2号梯']),
    createPOI('ELEV_OUT_002_F2', '2号客运电梯(2F)', DestinationCategory.ELEVATOR, 'OUTPATIENT', 2,
      { x: 52, y: 3, z: 18 } as Position3D, '门诊大楼B1-5层客运电梯', true, ['电梯', '2号梯']),
    createPOI('ELEV_OUT_002_F3', '2号客运电梯(3F)', DestinationCategory.ELEVATOR, 'OUTPATIENT', 3,
      { x: 52, y: 6, z: 18 } as Position3D, '门诊大楼B1-5层客运电梯', true, ['电梯', '2号梯']),
    createPOI('ELEV_OUT_002_F4', '2号客运电梯(4F)', DestinationCategory.ELEVATOR, 'OUTPATIENT', 4,
      { x: 52, y: 9, z: 18 } as Position3D, '门诊大楼B1-5层客运电梯', true, ['电梯', '2号梯']),
    createPOI('ELEV_OUT_002_F5', '2号客运电梯(5F)', DestinationCategory.ELEVATOR, 'OUTPATIENT', 5,
      { x: 52, y: 12, z: 18 } as Position3D, '门诊大楼B1-5层客运电梯', true, ['电梯', '2号梯']),
    
    // 医用电梯（无障碍）
    createPOI('ELEV_MEDIC_001', '医用电梯(无障碍)', DestinationCategory.ELEVATOR, 'OUTPATIENT', 1,
      { x: 12, y: 0, z: 20 } as Position3D, '医用电梯，支持担架、轮椅', true, ['医用电梯', '无障碍']),
    createPOI('ELEV_MEDIC_002', '医用电梯(2F)', DestinationCategory.ELEVATOR, 'OUTPATIENT', 2,
      { x: 12, y: 3, z: 20 } as Position3D, '医用电梯，支持担架、轮椅', true, ['医用电梯', '无障碍']),
    createPOI('ELEV_MEDIC_003', '医用电梯(3F)', DestinationCategory.ELEVATOR, 'OUTPATIENT', 3,
      { x: 12, y: 6, z: 20 } as Position3D, '医用电梯，支持担架、轮椅', true, ['医用电梯', '无障碍']),
    createPOI('ELEV_MEDIC_004', '医用电梯(4F)', DestinationCategory.ELEVATOR, 'OUTPATIENT', 4,
      { x: 12, y: 9, z: 20 } as Position3D, '医用电梯，支持担架、轮椅', true, ['医用电梯', '无障碍']),
    createPOI('ELEV_MEDIC_005', '医用电梯(5F)', DestinationCategory.ELEVATOR, 'OUTPATIENT', 5,
      { x: 12, y: 12, z: 20 } as Position3D, '医用电梯，支持担架、轮椅', true, ['医用电梯', '无障碍']),
    
    // ==================== 各层洗手间 ====================
    // 男洗手间
    createPOI('REST_MEN_F1', '男洗手间(1F)', DestinationCategory.RESTROOM, 'OUTPATIENT', 1,
      { x: 58, y: 0, z: 28 } as Position3D, '男洗手间', true, ['洗手间', '男厕']),
    createPOI('REST_MEN_F2', '男洗手间(2F)', DestinationCategory.RESTROOM, 'OUTPATIENT', 2,
      { x: 58, y: 3, z: 28 } as Position3D, '男洗手间', true, ['洗手间', '男厕']),
    createPOI('REST_MEN_F3', '男洗手间(3F)', DestinationCategory.RESTROOM, 'OUTPATIENT', 3,
      { x: 58, y: 6, z: 28 } as Position3D, '男洗手间', true, ['洗手间', '男厕']),
    createPOI('REST_MEN_F4', '男洗手间(4F)', DestinationCategory.RESTROOM, 'OUTPATIENT', 4,
      { x: 58, y: 9, z: 28 } as Position3D, '男洗手间', true, ['洗手间', '男厕']),
    createPOI('REST_MEN_F5', '男洗手间(5F)', DestinationCategory.RESTROOM, 'OUTPATIENT', 5,
      { x: 58, y: 12, z: 28 } as Position3D, '男洗手间', true, ['洗手间', '男厕']),
    
    // 女洗手间
    createPOI('REST_WOMEN_F1', '女洗手间(1F)', DestinationCategory.RESTROOM, 'OUTPATIENT', 1,
      { x: 62, y: 0, z: 28 } as Position3D, '女洗手间', true, ['洗手间', '女厕']),
    createPOI('REST_WOMEN_F2', '女洗手间(2F)', DestinationCategory.RESTROOM, 'OUTPATIENT', 2,
      { x: 62, y: 3, z: 28 } as Position3D, '女洗手间', true, ['洗手间', '女厕']),
    createPOI('REST_WOMEN_F3', '女洗手间(3F)', DestinationCategory.RESTROOM, 'OUTPATIENT', 3,
      { x: 62, y: 6, z: 28 } as Position3D, '女洗手间', true, ['洗手间', '女厕']),
    createPOI('REST_WOMEN_F4', '女洗手间(4F)', DestinationCategory.RESTROOM, 'OUTPATIENT', 4,
      { x: 62, y: 9, z: 28 } as Position3D, '女洗手间', true, ['洗手间', '女厕']),
    createPOI('REST_WOMEN_F5', '女洗手间(5F)', DestinationCategory.RESTROOM, 'OUTPATIENT', 5,
      { x: 62, y: 12, z: 28 } as Position3D, '女洗手间', true, ['洗手间', '女厕']),
    
    // 无障碍洗手间
    createPOI('REST_ACCESSIBLE_F1', '无障碍洗手间(1F)', DestinationCategory.RESTROOM, 'OUTPATIENT', 1,
      { x: 66, y: 0, z: 28 } as Position3D, '无障碍洗手间，适合轮椅使用者', true, ['无障碍', '残卫']),
    createPOI('REST_ACCESSIBLE_F2', '无障碍洗手间(2F)', DestinationCategory.RESTROOM, 'OUTPATIENT', 2,
      { x: 66, y: 3, z: 28 } as Position3D, '无障碍洗手间，适合轮椅使用者', true, ['无障碍', '残卫']),
    createPOI('REST_ACCESSIBLE_F3', '无障碍洗手间(3F)', DestinationCategory.RESTROOM, 'OUTPATIENT', 3,
      { x: 66, y: 6, z: 28 } as Position3D, '无障碍洗手间，适合轮椅使用者', true, ['无障碍', '残卫']),
    
    // ==================== 药房 ====================
    createPOI('PHARMACY_WEST', '西药房', DestinationCategory.PHARMACY, 'OUTPATIENT', 1,
      { x: 48, y: 0, z: 22 } as Position3D, '西药取药处', true, ['药房', '取药']),
    createPOI('PHARMACY_TCM', '中药房', DestinationCategory.PHARMACY, 'OUTPATIENT', 1,
      { x: 52, y: 0, z: 22 } as Position3D, '中药配方、煎药服务', true, ['中药房', '草药']),
    createPOI('PHARMACY_INFUSION', '输液室', DestinationCategory.PHARMACY, 'OUTPATIENT', 2,
      { x: 60, y: 3, z: 20 } as Position3D, '静脉输液治疗室', true, ['输液', '打针']),
    
    // ==================== 检验科 ====================
    createPOI('LAB_BLOOD', '血液检验', DestinationCategory.LAB, 'OUTPATIENT', 1,
      { x: 28, y: 0, z: 25 } as Position3D, '血常规、生化检查', true, ['检验', '抽血']),
    createPOI('LAB_BIOCHEM', '生化检验', DestinationCategory.LAB, 'MEDICAL_TECH', 1,
      { x: 18, y: 0, z: 26 } as Position3D, '肝功能、肾功能等生化指标检测', true, ['生化', '检验']),
    createPOI('LAB_PATHOLOGY', '病理科', DestinationCategory.LAB, 'MEDICAL_TECH', 2,
      { x: 22, y: 3, z: 30 } as Position3D, '组织病理和细胞学检查', true, ['病理', '活检']),
    
    // ==================== 影像科 ====================
    createPOI('IMAGING_XRAY', '放射科(X光/CT/MRI)', DestinationCategory.IMAGING, 'MEDICAL_TECH', 1,
      { x: 25, y: 0, z: 28 } as Position3D, '影像学检查中心', true, ['放射', 'CT', 'MRI']),
    
    // ==================== 住院部示例 ====================
    createPOI('WARD_INPATIENT_3F', '住院部3楼护士站', DestinationCategory.WARD, 'INPATIENT', 3,
      { x: 58, y: 9, z: 55 } as Position3D, '住院部3楼护士站', true, ['护士站', '病房']),
    createPOI('WARD_INPATIENT_5F', '住院部5楼护士站', DestinationCategory.WARD, 'INPATIENT', 5,
      { x: 58, y: 15, z: 55 } as Position3D, '住院部5楼护士站', true, ['护士站', '病房'])
  ] as NavigationDestination[];
}

/**
 * 创建POI对象的辅助函数
 */
function createPOI(
  id: string,
  name: string,
  category: DestinationCategory,
  building: string,
  floor: number,
  position: Position3D,
  description: string,
  isAccessible: boolean,
  tags: string[]
): NavigationDestination {
  return {
    id,
    name,
    category,
    building,
    floor,
    position,
    description,
    isAccessible,
    tags
  } as NavigationDestination;
}

/**
 * 获取所有楼层平面图
 */
function getAllFloorPlans(): FloorPlan[] {
  const plans: FloorPlan[] = [];
  
  // 门诊大楼 B1-5层
  for (let floor = -1; floor <= 5; floor++) {
    plans.push(createFloorPlan('OUTPATIENT', floor));
  }
  
  // 住院部 1-15层（只创建前几层作为示例）
  for (let floor = 1; floor <= 10; floor++) {
    plans.push(createFloorPlan('INPATIENT', floor));
  }
  
  // 医技楼 B1-7层
  for (let floor = -1; floor <= 7; floor++) {
    plans.push(createFloorPlan('MEDICAL_TECH', floor));
  }
  
  return plans;
}

/**
 * 创建楼层平面图
 */
function createFloorPlan(buildingId: string, floor: number): FloorPlan {
  const width = 800; // 像素
  const height = 600;
  const scale = 10; // 10像素 = 1米
  
  // 根据楼层生成不同的可行走区域和障碍物
  let walkableAreas: Area[];
  let obstacles: Obstacle[];
  
  if (buildingId === 'OUTPATIENT') {
    if (floor === 1) {
      // 一楼大厅布局
      walkableAreas = [
        { points: [{x: 10, y: 5}, {x: 70, y: 5}, {x: 70, y: 35}, {x: 10, y: 35}], type: 'LOBBY' } as Area,
        { points: [{x: 10, y: 36}, {x: 70, y: 36}, {x: 70, y: 55}, {x: 10, y: 55}], type: 'CORRIDOR' } as Area
      ];
      obstacles = [
        { position: {x: 40, y: 27} as Position2D, radius: 3, type: 'PILLAR' } as Obstacle, // 中央立柱
        { position: {x: 30, y: 25} as Position2D, radius: 2, type: 'PILLAR' } as Obstacle,
        { position: {x: 50, y: 25} as Position2D, radius: 2, type: 'PILLAR' } as Obstacle
      ];
    } else if (floor >= 2 && floor <= 5) {
      // 2-5层诊区走廊布局
      walkableAreas = [
        { points: [{x: 15, y: 10}, {x: 68, y: 10}, {x: 68, y: 35}, {x: 15, y: 35}], type: 'CORRIDOR' } as Area
      ];
      obstacles = [
        { position: {x: 40, y: 22} as Position2D, radius: 2.5, type: 'PILLAR' } as Obstacle
      ];
    } else {
      // B1停车场
      walkableAreas = [
        { points: [{x: 5, y: 5}, {x: 75, y: 5}, {x: 75, y: 55}, {x: 5, y: 55}], type: 'LOBBY' } as Area
      ];
      obstacles = [];
    }
  } else if (buildingId === 'INPATIENT') {
    // 住院部病房布局
    walkableAreas = [
      { points: [{x: 50, y: 45}, {x: 75, y: 45}, {x: 75, y: 70}, {x: 50, y: 70}], type: 'HALL' } as Area,
      { points: [{x: 52, y: 47}, {x: 73, y: 47}, {x: 73, y: 68}, {x: 52, y: 68}], type: 'CORRIDOR' } as Area
    ];
    obstacles = [
      { position: {x: 62, y: 57} as Position2D, radius: 2, type: 'PILLAR' } as Obstacle
    ];
  } else {
    // 医技楼
    walkableAreas = [
      { points: [{x: 10, y: 25}, {x: 35, y: 25}, {x: 35, y: 45}, {x: 10, y: 45}], type: 'HALL' } as Area
    ];
    obstacles = [];
  }

  return {
    buildingId,
    floor,
    width,
    height,
    scale,
    walkableAreas,
    obstacles
  } as FloorPlan;
}

/**
 * 获取所有楼层连接（电梯、楼梯）
 */
function getAllConnections(): Connection[] {
  return [
    // 门诊大楼1号电梯
    {
      id: 'CONN_ELEV_001',
      fromFloor: 1,
      toFloor: 2,
      fromPosition: { x: 30, y: 25 } as Position2D,
      toPosition: { x: 30, y: 25 } as Position2D,
      type: 'ELEVATOR',
      name: '1号客运电梯'
    } as Connection,
    {
      id: 'CONN_ELEV_002',
      fromFloor: 2,
      toFloor: 3,
      fromPosition: { x: 30, y: 25 } as Position2D,
      toPosition: { x: 30, y: 25 } as Position2D,
      type: 'ELEVATOR',
      name: '1号客运电梯'
    } as Connection,
    {
      id: 'CONN_ELEV_003',
      fromFloor: 3,
      toFloor: 4,
      fromPosition: { x: 30, y: 25 } as Position2D,
      toPosition: { x: 30, y: 25 } as Position2D,
      type: 'ELEVATOR',
      name: '1号客运电梯'
    } as Connection,
    {
      id: 'CONN_ELEV_004',
      fromFloor: 4,
      toFloor: 5,
      fromPosition: { x: 30, y: 25 } as Position2D,
      toPosition: { x: 30, y: 25 } as Position2D,
      type: 'ELEVATOR',
      name: '1号客运电梯'
    } as Connection,
    {
      id: 'CONN_ELEV_005',
      fromFloor: 1,
      toFloor: -1,
      fromPosition: { x: 52, y: 18 } as Position2D,
      toPosition: { x: 52, y: 18 } as Position2D,
      type: 'ELEVATOR',
      name: '2号客运电梯'
    } as Connection,
    
    // 门诊大楼2号电梯
    {
      id: 'CONN_ELEV_006',
      fromFloor: 1,
      toFloor: 2,
      fromPosition: { x: 52, y: 18 } as Position2D,
      toPosition: { x: 52, y: 18 } as Position2D,
      type: 'ELEVATOR',
      name: '2号客运电梯'
    } as Connection,
    {
      id: 'CONN_ELEV_007',
      fromFloor: 2,
      toFloor: 3,
      fromPosition: { x: 52, y: 18 } as Position2D,
      toPosition: { x: 52, y: 18 } as Position2D,
      type: 'ELEVATOR',
      name: '2号客运电梯'
    } as Connection,
    {
      id: 'CONN_ELEV_008',
      fromFloor: 3,
      toFloor: 4,
      fromPosition: { x: 52, y: 18 } as Position2D,
      toPosition: { x: 52, y: 18 } as Position2D,
      type: 'ELEVATOR',
      name: '2号客运电梯'
    } as Connection,
    {
      id: 'CONN_ELEV_009',
      fromFloor: 4,
      toFloor: 5,
      fromPosition: { x: 52, y: 18 } as Position2D,
      toPosition: { x: 52, y: 18 } as Position2D,
      type: 'ELEVATOR',
      name: '2号客运电梯'
    } as Connection,

    // 医用电梯
    {
      id: 'CONN_ELEV_MEDIC_001',
      fromFloor: 1,
      toFloor: 2,
      fromPosition: { x: 12, y: 20 } as Position2D,
      toPosition: { x: 12, y: 20 } as Position2D,
      type: 'ELEVATOR',
      name: '医用电梯'
    } as Connection,
    {
      id: 'CONN_ELEV_MEDIC_002',
      fromFloor: 2,
      toFloor: 3,
      fromPosition: { x: 12, y: 20 } as Position2D,
      toPosition: { x: 12, y: 20 } as Position2D,
      type: 'ELEVATOR',
      name: '医用电梯'
    } as Connection,
    {
      id: 'CONN_ELEV_MEDIC_003',
      fromFloor: 3,
      toFloor: 4,
      fromPosition: { x: 12, y: 20 } as Position2D,
      toPosition: { x: 12, y: 20 } as Position2D,
      type: 'ELEVATOR',
      name: '医用电梯'
    } as Connection,
    {
      id: 'CONN_ELEV_MEDIC_004',
      fromFloor: 4,
      toFloor: 5,
      fromPosition: { x: 12, y: 20 } as Position2D,
      toPosition: { x: 12, y: 20 } as Position2D,
      type: 'ELEVATOR',
      name: '医用电梯'
    } as Connection
  ] as Connection[];
}

/**
 * 根据ID获取POI
 */
export function getPOIById(id: string): NavigationDestination | null {
  const pois = getAllPOIs();
  return pois.find(poi => poi.id === id) || null;
}

/**
 * 根据分类获取POI列表
 */
export function getPOIsByCategory(category: DestinationCategory): NavigationDestination[] {
  return getAllPOIs().filter(poi => poi.category === category);
}

/**
 * 根据楼层获取POI列表
 */
export function getPOIsByFloor(buildingId: string, floor: number): NavigationDestination[] {
  return getAllPOIs().filter(poi => poi.building === buildingId && poi.floor === floor);
}

/**
 * 搜索POI（按名称或标签）
 */
export function searchPOIs(keyword: string): NavigationDestination[] {
  const lowerKeyword = keyword.toLowerCase();
  return getAllPOIs().filter(poi =>
    poi.name.toLowerCase().includes(lowerKeyword) ||
    poi.tags.some(tag => tag.toLowerCase().includes(lowerKeyword)) ||
    poi.description.toLowerCase().includes(lowerKeyword)
  );
}

/**
 * 获取热门目的地（常用科室）
 */
export function getPopularDestinations(limit: number = 10): NavigationDestination[] {
  const popularIds = [
    'REG_DESK_001',     // 综合挂号
    'PHARMACY_WEST',    // 西药房
    'EMERGENCY_ROOM',   // 急诊
    'DEPT_INTERNAL_CARDIO', // 心内科
    'DEPT_PEDIATRICS',  // 儿科
    'DEPT_OPHTHALMOLOGY', // 眼科
    'INFO_DESK_001',    // 导诊台
    'PAY_WINDOW_001'    // 缴费处
  ];
  
  const results: NavigationDestination[] = [];
  for (const id of popularIds) {
    const poi = getAllPOIs().find(p => p.id === id);
    if (poi) {
      results.push(poi);
      if (results.length >= limit) break;
    }
  }
  return results;
}
