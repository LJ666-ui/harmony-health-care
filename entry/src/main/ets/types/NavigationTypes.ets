/**
 * 导航类型定义
 * 提供页面导航相关的类型安全接口
 */

/**
 * 导航参数基础接口
 */
export interface NavigationParams {
  [key: string]: string | number | boolean | object;
}

/**
 * 导航错误类型枚举
 */
export enum NavigationErrorType {
  ROUTE_NOT_FOUND = 'ROUTE_NOT_FOUND',
  INVALID_PARAMS = 'INVALID_PARAMS',
  NAVIGATION_FAILED = 'NAVIGATION_FAILED',
  PERMISSION_DENIED = 'PERMISSION_DENIED'
}

/**
 * 路由元信息
 */
export interface RouteMeta {
  title?: string;
  requiresAuth?: boolean;
  keepAlive?: boolean;
}

/**
 * 路由配置项
 */
export interface RouteConfig {
  path: string;
  name?: string;
  meta?: RouteMeta;
}

/**
 * 导航历史记录项
 */
export interface NavigationHistoryItem {
  url: string;
  timestamp: number;
  params?: NavigationParams;
  from: string;
}

/**
 * 导航状态
 */
export interface NavigationState {
  currentPage: string;
  previousPage: string | null;
  navigationStack: string[];
  params: NavigationParams;
}

// ============ 页面特定参数接口 ============

/**
 * 医院详情页参数
 */
export interface HospitalDetailParams extends NavigationParams {
  hospitalId: string;
  hospitalName?: string;
}

/**
 * 医生详情页参数
 */
export interface DoctorDetailParams extends NavigationParams {
  doctorId: string;
  departmentId?: string;
}

/**
 * 科室详情页参数
 */
export interface DepartmentDetailParams extends NavigationParams {
  departmentId: string;
  departmentName?: string;
}

/**
 * 科学科普详情页参数
 */
export interface ScienceDetailParams extends NavigationParams {
  articleId: string | number;
  category?: string;
  searchKeyword?: string;
}

/**
 * 草药详情页参数
 */
export interface HerbalDetailParams extends NavigationParams {
  herbalId: string | number;
  name?: string;
}

/**
 * 食物详情页参数
 */
export interface FoodDetailParams extends NavigationParams {
  foodId: string | number;
  category?: string;
}

/**
 * 康复课程参数
 */
export interface RehabCourseParams extends NavigationParams {
  courseId: string | number;
  courseType?: string;
}

/**
 * 风险评估参数
 */
export interface RiskAssessmentParams extends NavigationParams {
  assessmentId?: string;
  type?: string;
}

/**
 * 健康记录详情参数
 */
export interface HealthRecordDetailParams extends NavigationParams {
  recordId: string | number;
  recordType?: string;
}

/**
 * 预约时间选择参数
 */
export interface AppointmentTimeParams extends NavigationParams {
  doctorId?: string;
  departmentId?: string;
  hospitalId?: string;
}

/**
 * 图像分析参数
 */
export interface ImageAnalysisParams extends NavigationParams {
  imageId?: string;
  analysisType?: string;
}

/**
 * 数字孪生参数
 */
export interface DigitalTwinParams extends NavigationParams {
  organId?: string;
  viewMode?: string;
}

/**
 * 知识图谱节点参数
 */
export interface KnowledgeNodeParams extends NavigationParams {
  nodeId: string | number;
  nodeType?: string;
  centerId?: number;
}

/**
 * 转院申请参数
 */
export interface TransferApplyParams extends NavigationParams {
  applicationId?: string;
  patientId?: string;
}

/**
 * 设备管理参数
 */
export interface DeviceManageParams extends NavigationParams {
  deviceId?: string;
  deviceType?: string;
}

/**
 * Header右侧操作配置
 */
export interface HeaderAction {
  icon: string;
  label?: string;
  onClick: () => void;
}
