/**
 * 路由配置管理器
 * 负责加载、验证和管理应用的路由配置
 */

import { RouteConfig, RouteMeta } from '../types/NavigationTypes';

/**
 * 路由配置管理器（单例模式）
 */
export class RouteConfigManager {
  private static instance: RouteConfigManager;

  /**
   * 已注册的路由集合（使用Set实现O(1)查找）
   */
  private routes: Set<string> = new Set();

  /**
   * 路由元信息映射
   */
  private routeMetas: Map<string, RouteMeta> = new Map();

  /**
   * 是否已初始化
   */
  private initialized: boolean = false;

  /**
   * 私有构造函数（单例模式）
   */
  private constructor() {
    // 初始化时自动加载路由配置
    this.initialize();
  }

  /**
   * 获取单例实例
   */
  public static getInstance(): RouteConfigManager {
    if (!RouteConfigManager.instance) {
      RouteConfigManager.instance = new RouteConfigManager();
    }
    return RouteConfigManager.instance;
  }

  /**
   * 初始化路由配置
   * 从main_pages.json加载路由配置
   */
  public initialize(): void {
    if (this.initialized) {
      return;
    }

    // 加载所有已注册的路由
    // 注意：这些路由来自 main_pages.json 配置文件
    const registeredRoutes: string[] = [
      'pages/Index',
      'pages/Login',
      'pages/Register',
      'pages/HomePage',
      'pages/MedicalPage',
      'pages/HealthPage',
      'pages/RehabPage',
      'pages/SciencePage',
      'pages/HospitalPage',
      'pages/DepartmentPage',
      'pages/HealthRecords',
      'pages/AddHealthRecord',
      'pages/HealthRecordDetail',
      'pages/Appointments',
      'pages/AppointmentManagementPage',
      'pages/HospitalDetailPage',
      'pages/DepartmentDoctorsPage',
      'pages/DoctorDetailPage',
      'pages/HospitalDepartmentPage',
      'pages/DepartmentListPage',
      'pages/Medications',
      'pages/Profile',
      'pages/AddAppointmentPage',
      'pages/AppointmentTimeSelectPage',
      'pages/RehabListPage',
      'pages/Rehab3DPage',
      'pages/ScienceListPage',
      'pages/ScienceDetailPage',
      'pages/DeviceDiscoveryPage',
      'pages/DeviceManagePage',
      'pages/RiskAssessmentPage',
      'pages/RiskResultPage',
      'pages/RiskHistoryPage',
      'pages/RiskDetailPage',
      'pages/PrivacySettingPage',
      'pages/PrivacyPolicyPage',
      'pages/PrivacyPage',
      'pages/ARNavigationPage',
      'pages/VoiceAssistantPage',
      'pages/AiChatPage',
      'pages/AiConsultationPage',
      'pages/ImageAnalysisPage',
      'pages/TestPage',
      'pages/HerbalListPage',
      'pages/HerbalDetailPage',
      'pages/HerbalComparePage',
      'pages/DosageCalc',
      'pages/DataAuthPage',
      'pages/AncientMedicalImgPage',
      'pages/ImageRestorationPage',
      'pages/StatisticsPage',
      'pages/RankingPage',
      'pages/TransferApplyPage',
      'pages/MedicalRecord',
      'pages/MyCollectPage',
      'pages/FoodEncyclopediaPage',
      'pages/FoodDetailPage',
      'pages/MedicationDetailPage',
      'pages/KnowledgeGraphPage',
      'pages/KnowledgeExplorePage',
      'pages/DoctorListPage',
      'pages/DoctorChatPage',
      'pages/DoctorFamilyChatPage',
      'pages/PatientChatListPage',
      'pages/PatientDoctorChatPage',
      'pages/PatientNurseChatPage',
      'pages/DoctorLogin',
      'pages/FamilyChatListPage',
      'pages/FamilyDoctorChatPage',
      'pages/FamilyNurseChatPage',
      'pages/NurseChatPage',
      'pages/NurseFamilyChatPage',
      'pages/NursePatientList',
      'pages/NurseFamilyList',
      'pages/MedicationReminderListPage',
      'pages/MedicationReminderEditPage',
      'pages/DigitalTwinViewer',
      'pages/DigitalTwinPage',
      'pages/OrganDetailPage',
      'pages/PredictionReportPage',
      'pages/TransferApprovalPage',
      'pages/MedicalRecordSyncPage',
      'pages/MonitoringDashboard',
      'pages/AlertHistoryPage',
      'pages/ReminderSettingsPage',
      'pages/EmergencyContactsPage',
      'pages/NurseStationDashboardSimple',
      'pages/SmartWardDevicesSimple',
      'pages/SmartWardAlertsSimple',
      'pages/SmartWardCarePlanSimple',
      'pages/ParkingListPage',
      'pages/ParkingSpacePage',
      'pages/FindCarPage',
      'pages/ReportPage',
      'pages/MedicationPage',
      'pages/ConsultationPage',
      'pages/EmergencyPage',
      'pages/FamilyDoctorPage',
      'pages/InsurancePage',
      'pages/RehabilitationPage',
      'pages/AIAssistantPage',
      'pages/DistributedCollaborationPage',
      'pages/BrowseHistoryPage',
      'pages/DailyRecommendPage',
      'pages/DiscoverPage',
      'pages/DestinationSelectPage',
      'pages/NavigationSummaryPage'
    ];

    // 将路由添加到集合中
    registeredRoutes.forEach((route: string) => {
      this.routes.add(route);
    });

    this.initialized = true;
    console.info(`[RouteConfigManager] 已加载 ${this.routes.size} 个路由配置`);
  }

  /**
   * 验证路由是否存在
   * @param path 路由路径
   * @returns boolean
   */
  public hasRoute(path: string): boolean {
    // 标准化路径
    const normalizedPath = this.normalizePath(path);
    return this.routes.has(normalizedPath);
  }

  /**
   * 获取所有路由
   * @returns string[]
   */
  public getAllRoutes(): string[] {
    return Array.from(this.routes);
  }

  /**
   * 添加新路由
   * @param path 路由路径
   * @param meta 路由元信息（可选）
   */
  public addRoute(path: string, meta?: RouteMeta): void {
    const normalizedPath = this.normalizePath(path);
    this.routes.add(normalizedPath);

    if (meta) {
      this.routeMetas.set(normalizedPath, meta);
    }

    console.info(`[RouteConfigManager] 添加路由: ${normalizedPath}`);
  }

  /**
   * 批量添加路由
   * @param paths 路由路径数组
   */
  public addRoutes(paths: string[]): void {
    paths.forEach((path: string) => {
      this.addRoute(path);
    });
  }

  /**
   * 获取路由元信息
   * @param path 路由路径
   * @returns RouteMeta | undefined
   */
  public getRouteMeta(path: string): RouteMeta | undefined {
    const normalizedPath = this.normalizePath(path);
    return this.routeMetas.get(normalizedPath);
  }

  /**
   * 标准化路由路径
   * @param path 原始路径
   * @returns 标准化后的路径
   */
  private normalizePath(path: string): string {
    let normalizedPath = path;

    // 移除文件扩展名
    if (normalizedPath.endsWith('.ets')) {
      normalizedPath = normalizedPath.replace('.ets', '');
    }

    // 确保以 pages/ 开头
    if (!normalizedPath.startsWith('pages/')) {
      normalizedPath = 'pages/' + normalizedPath;
    }

    return normalizedPath;
  }

  /**
   * 获取路由数量
   * @returns number
   */
  public getRouteCount(): number {
    return this.routes.size;
  }

  /**
   * 检查路由配置是否已初始化
   * @returns boolean
   */
  public isInitialized(): boolean {
    return this.initialized;
  }

  /**
   * 打印所有路由（调试用）
   */
  public printAllRoutes(): void {
    console.info('[RouteConfigManager] 所有已注册路由:');
    const routeList = Array.from(this.routes).sort();
    routeList.forEach((route: string, index: number) => {
      console.info(`  ${index + 1}. ${route}`);
    });
  }
}
