/**
 * 智慧病房系统初始化器
 * 负责系统启动时的初始化工作
 */

import { DeviceManager } from './core/DeviceManager';
import { PermissionManager } from './core/PermissionManager';
import { AlertManager } from './core/AlertManager';
import { DeviceType } from './models/SmartWardEnums';
import { MockDataGenerator } from '../mock/smartwardMock';

/**
 * 智慧病房系统初始化器
 */
export class SmartWardInitializer {
  private static instance: SmartWardInitializer;
  private isInitialized: boolean = false;

  private constructor() {
    console.log('SmartWardInitializer created');
  }

  /**
   * 获取初始化器单例实例
   */
  public static getInstance(): SmartWardInitializer {
    if (!SmartWardInitializer.instance) {
      SmartWardInitializer.instance = new SmartWardInitializer();
    }
    return SmartWardInitializer.instance;
  }

  /**
   * 初始化系统
   */
  public async initialize(): Promise<void> {
    if (this.isInitialized) {
      console.log('SmartWardInitializer: Already initialized');
      return;
    }

    console.log('SmartWardInitializer: Initializing system...');

    try {
      // 1. 注册设备控制器
      this.registerControllers();

      // 2. 加载预设规则
      this.loadPresetRules();

      // 3. 初始化数据采集
      this.initializeDataCollector();

      // 4. 初始化时间检测
      this.initializeTimeChecker();

      // 5. 生成模拟数据（可选）
      // await this.generateMockData();

      this.isInitialized = true;
      console.log('SmartWardInitializer: System initialized successfully');
    } catch (error) {
      console.error('SmartWardInitializer: Initialization failed', error);
      throw error;
    }
  }

  /**
   * 注册设备控制器
   */
  private registerControllers(): void {
    console.log('SmartWardInitializer: Registering device controllers...');

    const deviceManager = DeviceManager.getInstance();

    // 注意：这里需要从smartward/core/controllers导入控制器
    // 由于控制器文件较多，暂时注释掉，待后续集成
    // deviceManager.registerController(DeviceType.SMART_LIGHT, SmartLightController.getInstance());
    // deviceManager.registerController(DeviceType.HOSPITAL_BED, HospitalBedController.getInstance());
    // deviceManager.registerController(DeviceType.PATIENT_MONITOR, PatientMonitorController.getInstance());
    // deviceManager.registerController(DeviceType.SMART_CURTAIN, SmartCurtainController.getInstance());
    // deviceManager.registerController(DeviceType.SMART_TV, SmartTVController.getInstance());
    // deviceManager.registerController(DeviceType.AIR_CONDITIONER, AirConditionerController.getInstance());
    // deviceManager.registerController(DeviceType.CALL_BUTTON, CallButtonController.getInstance());
    // deviceManager.registerController(DeviceType.INFUSION_PUMP, InfusionPumpController.getInstance());

    console.log('SmartWardInitializer: Controller registration pending (controllers not yet integrated)');
  }

  /**
   * 加载预设规则
   */
  private loadPresetRules(): void {
    console.log('SmartWardInitializer: Loading preset rules...');

    // 注意：这里需要从smartward/config导入预设规则
    // const automationEngine = AutomationEngine.getInstance();
    // automationEngine.loadRules(presetRules);

    console.log('SmartWardInitializer: Preset rules loading pending (rules not yet integrated)');
  }

  /**
   * 初始化数据采集
   */
  private initializeDataCollector(): void {
    console.log('SmartWardInitializer: Initializing data collector...');

    // 注意：这里需要从smartward/core/collectors导入数据采集器
    // const dataCollector = DataCollector.getInstance();
    // dataCollector.subscribe((deviceStatuses) => {
    //   console.log(`SmartWardInitializer: Data collection completed, ${deviceStatuses.size} devices updated`);
    // });

    console.log('SmartWardInitializer: Data collector initialization pending (collector not yet integrated)');
  }

  /**
   * 初始化时间检测
   */
  private initializeTimeChecker(): void {
    console.log('SmartWardInitializer: Initializing time checker...');

    // 注意：这里需要从smartward/core/checkers导入时间检测器
    // const timeChecker = TimeChecker.getInstance();
    // timeChecker.startTimeCheck();

    console.log('SmartWardInitializer: Time checker initialization pending (checker not yet integrated)');
  }

  /**
   * 生成模拟数据
   */
  public async generateMockData(): Promise<void> {
    console.log('SmartWardInitializer: Generating mock data...');

    const mockGenerator = MockDataGenerator.getInstance();
    const deviceManager = DeviceManager.getInstance();

    // 生成6个病房
    const rooms = mockGenerator.generateWardRooms(6);

    for (const room of rooms) {
      // 注册设备
      const devices = mockGenerator.generateDevices(room.roomId, room.roomNumber);

      for (const device of devices) {
        deviceManager.registerDevice(device);

        // 生成设备状态
        const status = mockGenerator.generateDeviceStatus(device);
        deviceManager.updateDeviceStatus(status);
      }
    }

    // 生成告警
    const roomIds = rooms.map(r => r.roomId);
    const alerts = mockGenerator.generateAlerts(15, roomIds);
    const alertManager = AlertManager.getInstance();
    alerts.forEach(alert => alertManager.createAlert(alert));

    // 生成护理任务
    const tasks = mockGenerator.generateCareTasks(12, roomIds);

    console.log('SmartWardInitializer: Mock data generated successfully');
  }

  /**
   * 启动数据采集
   */
  public startDataCollection(interval: number = 5000): void {
    console.log(`SmartWardInitializer: Data collection start pending (collector not yet integrated)`);
  }

  /**
   * 停止数据采集
   */
  public stopDataCollection(): void {
    console.log('SmartWardInitializer: Data collection stop pending (collector not yet integrated)');
  }

  /**
   * 停止时间检测
   */
  public stopTimeChecker(): void {
    console.log('SmartWardInitializer: Time checker stop pending (checker not yet integrated)');
  }

  /**
   * 清理资源
   */
  public cleanup(): void {
    console.log('SmartWardInitializer: Cleaning up resources...');

    this.stopDataCollection();
    this.stopTimeChecker();

    const deviceManager = DeviceManager.getInstance();
    deviceManager.clear();

    const alertManager = AlertManager.getInstance();
    alertManager.clear();

    this.isInitialized = false;
    console.log('SmartWardInitializer: Cleanup completed');
  }

  /**
   * 检查是否已初始化
   */
  public isSystemInitialized(): boolean {
    return this.isInitialized;
  }
}
