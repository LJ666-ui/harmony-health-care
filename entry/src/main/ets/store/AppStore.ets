// 应用状态管理Store
import { UserInfo, HealthMetric, HealthRecord, Appointment, Medication, Reminder, HealthStats, HealthSummary } from '../models/HealthData';

// 应用状态接口
export interface AppState {
  // 用户信息
  user: UserInfo | null;
  
  // 健康数据
  healthMetrics: HealthMetric[];
  healthRecords: HealthRecord[];
  medications: Medication[];
  appointments: Appointment[];
  reminders: Reminder[];
  
  // 健康统计
  healthStats: HealthStats | null;
  healthSummary: HealthSummary | null;
  
  // 应用状态
  isLoading: boolean;
  error: string | null;
  
  // 设置
  settings: {
    notifications: boolean;
    darkMode: boolean;
    language: string;
    healthDataSync: boolean;
    emergencyContactEnabled: boolean;
  };
}

// 初始状态
const initialState: AppState = {
  user: {
    id: 'user_001',
    name: '张三',
    avatar: '👤',
    age: 35,
    gender: 'male',
    height: 175,
    weight: 68.5,
    bloodType: 'A+',
    allergies: ['青霉素', '花粉'],
    emergencyContact: '李四 13800138000',
    phone: '13800138000',
    email: 'zhangsan@example.com',
    address: '北京市朝阳区'
  },
  
  healthMetrics: [
    { id: 'metric_001', type: 'heart_rate', value: 72, unit: 'bpm', timestamp: Date.now(), notes: '静息心率', device: '智能手环' },
    { id: 'metric_002', type: 'blood_pressure', value: '120/80', unit: 'mmHg', timestamp: Date.now(), notes: '早晨测量', device: '血压计' },
    { id: 'metric_003', type: 'blood_sugar', value: 5.6, unit: 'mmol/L', timestamp: Date.now(), notes: '空腹血糖', device: '血糖仪' }
  ],
  
  healthRecords: [
    { id: 'record_001', type: '血压', value: '120/80', unit: 'mmHg', date: '2024-03-15', time: '08:30', notes: '早晨测量，正常范围', icon: 'heart', color: '#ff6b6b', createdAt: Date.now(), updatedAt: Date.now() },
    { id: 'record_002', type: '心率', value: '72', unit: 'bpm', date: '2024-03-15', time: '08:35', notes: '静息心率，良好', icon: 'pulse', color: '#4ecdc4', createdAt: Date.now(), updatedAt: Date.now() }
  ],
  
  medications: [
    { id: 'med_001', name: '阿司匹林', dosage: '100mg', frequency: '每日一次', times: ['08:00'], status: 'taken', reminder: true, startDate: '2024-01-01', color: '#4a90e2', icon: '💊', createdAt: Date.now(), updatedAt: Date.now() },
    { id: 'med_002', name: '降压药', dosage: '5mg', frequency: '每日两次', times: ['08:00', '20:00'], status: 'pending', reminder: true, startDate: '2024-01-01', color: '#ff6b6b', icon: '❤️', createdAt: Date.now(), updatedAt: Date.now() }
  ],
  
  appointments: [
    { id: 'app_001', doctor: '张医生', specialty: '心血管内科', hospital: '北京协和医院', date: '2024-03-15', time: '09:30', status: 'confirmed', location: '门诊部3楼301室', avatarColor: '#4a90e2', createdAt: Date.now(), updatedAt: Date.now() },
    { id: 'app_002', doctor: '李医生', specialty: '内分泌科', hospital: '北京协和医院', date: '2024-03-16', time: '14:00', status: 'pending', location: '门诊部2楼205室', avatarColor: '#96ceb4', createdAt: Date.now(), updatedAt: Date.now() }
  ],
  
  reminders: [
    { id: 'reminder_001', title: '测量血压', description: '早晨测量血压', time: '08:00', repeat: 'daily', enabled: true, type: 'measurement', createdAt: Date.now(), updatedAt: Date.now() },
    { id: 'reminder_002', title: '服用药物', description: '服用阿司匹林', time: '08:00', repeat: 'daily', enabled: true, type: 'medication', createdAt: Date.now(), updatedAt: Date.now() }
  ],
  
  healthStats: {
    heartRate: { current: 72, average: 75, min: 65, max: 85, trend: 'stable' },
    bloodPressure: { systolic: 120, diastolic: 80, average: '120/80', trend: 'stable' },
    bloodSugar: { current: 5.6, average: 5.8, trend: 'down' },
    steps: { today: 5432, target: 10000, progress: 54, trend: 'up' },
    calories: { burned: 420, target: 500, progress: 84, trend: 'up' },
    weight: { current: 68.5, target: 65, progress: 70, trend: 'down' }
  },
  
  healthSummary: {
    date: '2024-03-15',
    metrics: [],
    score: 85,
    recommendations: ['保持每日运动', '注意饮食均衡', '定期测量血压']
  },
  
  isLoading: false,
  error: null,
  
  settings: {
    notifications: true,
    darkMode: false,
    language: 'zh-CN',
    healthDataSync: true,
    emergencyContactEnabled: true
  }
};

// 应用Store类
export class AppStore {
  // 单例实例
  private static instance: AppStore;
  
  // 状态
  private state: AppState = initialState;
  
  // 监听器
  private listeners: Array<(state: AppState) => void> = [];
  
  // 私有构造函数
  private constructor() {}
  
  // 获取单例
  public static getInstance(): AppStore {
    if (!AppStore.instance) {
      AppStore.instance = new AppStore();
    }
    return AppStore.instance;
  }
  
  // 获取当前状态
  public getState(): AppState {
    const state: AppState = {
      user: this.state.user,
      healthRecords: this.state.healthRecords,
      medications: this.state.medications,
      appointments: this.state.appointments,
      reminders: this.state.reminders,
      healthMetrics: this.state.healthMetrics,
      settings: this.state.settings,
      healthStats: this.state.healthStats
    };
    return state;
  }
  
  // 订阅状态变化
  public subscribe(listener: (state: AppState) => void): () => void {
    this.listeners.push(listener);
    
    // 返回取消订阅函数
    return () => {
      const index = this.listeners.indexOf(listener);
      if (index > -1) {
        this.listeners.splice(index, 1);
      }
    };
  }
  
  // 通知所有监听器
  private notifyListeners(): void {
    for (let i = 0; i < this.listeners.length; i++) {
      this.listeners[i](this.getState());
    }
  }
  
  // 更新状态
  private setState(newState: Partial<AppState>): void {
    if (newState.user) {
      this.state.user = newState.user;
    }
    if (newState.healthRecords) {
      this.state.healthRecords = newState.healthRecords;
    }
    if (newState.medications) {
      this.state.medications = newState.medications;
    }
    if (newState.appointments) {
      this.state.appointments = newState.appointments;
    }
    if (newState.reminders) {
      this.state.reminders = newState.reminders;
    }
    if (newState.healthMetrics) {
      this.state.healthMetrics = newState.healthMetrics;
    }
    if (newState.settings) {
      this.state.settings = newState.settings;
    }
    if (newState.healthStats) {
      this.state.healthStats = newState.healthStats;
    }
    if (newState.isLoading !== undefined) {
      this.state.isLoading = newState.isLoading;
    }
    this.notifyListeners();
  }
  
  // Action: 设置加载状态
  public setLoading(isLoading: boolean): void {
    this.setState({ isLoading });
  }
  
  // Action: 设置错误
  public setError(error: string | null): void {
    this.setState({ error });
  }
  
  // Action: 更新用户信息
  public updateUserInfo(userInfo: Partial<UserInfo>): void {
    if (this.state.user) {
      const updatedUser: UserInfo = {
        username: userInfo.username !== undefined ? userInfo.username : this.state.user.username,
        age: userInfo.age !== undefined ? userInfo.age : this.state.user.age,
        gender: userInfo.gender !== undefined ? userInfo.gender : this.state.user.gender,
        phone: userInfo.phone !== undefined ? userInfo.phone : this.state.user.phone,
        address: userInfo.address !== undefined ? userInfo.address : this.state.user.address,
        avatar: userInfo.avatar !== undefined ? userInfo.avatar : this.state.user.avatar,
        allergies: userInfo.allergies !== undefined ? userInfo.allergies : this.state.user.allergies
      };
      this.setState({
        user: updatedUser
      });
    }
  }
  
  // Action: 添加健康记录
  public addHealthRecord(record: Omit<HealthRecord, 'id' | 'createdAt' | 'updatedAt'>): void {
    const newRecord: HealthRecord = {
      type: record.type,
      value: record.value,
      unit: record.unit,
      date: record.date,
      time: record.time,
      color: record.color,
      notes: record.notes,
      id: 'record_' + Date.now(),
      createdAt: Date.now(),
      updatedAt: Date.now()
    };
    
    const newRecords: HealthRecord[] = [newRecord];
    for (let i = 0; i < this.state.healthRecords.length; i++) {
      newRecords.push(this.state.healthRecords[i]);
    }
    
    this.setState({
      healthRecords: newRecords
    });
  }
  
  // Action: 更新健康记录
  public updateHealthRecord(id: string, updates: Partial<HealthRecord>): void {
    const updatedRecords: HealthRecord[] = [];
    for (let i = 0; i < this.state.healthRecords.length; i++) {
      const record = this.state.healthRecords[i];
      if (record.id === id) {
        const updatedRecord: HealthRecord = {
          type: updates.type !== undefined ? updates.type : record.type,
          value: updates.value !== undefined ? updates.value : record.value,
          unit: updates.unit !== undefined ? updates.unit : record.unit,
          date: updates.date !== undefined ? updates.date : record.date,
          time: updates.time !== undefined ? updates.time : record.time,
          color: updates.color !== undefined ? updates.color : record.color,
          notes: updates.notes !== undefined ? updates.notes : record.notes,
          id: record.id,
          createdAt: record.createdAt,
          updatedAt: Date.now()
        };
        updatedRecords.push(updatedRecord);
      } else {
        updatedRecords.push(record);
      }
    }
    
    this.setState({ healthRecords: updatedRecords });
  }
  
  // Action: 删除健康记录
  public deleteHealthRecord(id: string): void {
    const filteredRecords: HealthRecord[] = [];
    for (let i = 0; i < this.state.healthRecords.length; i++) {
      if (this.state.healthRecords[i].id !== id) {
        filteredRecords.push(this.state.healthRecords[i]);
      }
    }
    this.setState({ healthRecords: filteredRecords });
  }
  
  // Action: 添加药物
  public addMedication(medication: Omit<Medication, 'id' | 'createdAt' | 'updatedAt'>): void {
    const newMedication: Medication = {
      name: medication.name,
      dosage: medication.dosage,
      times: medication.times,
      status: medication.status,
      id: 'med_' + Date.now(),
      createdAt: Date.now(),
      updatedAt: Date.now()
    };
    
    const newMedications: Medication[] = [newMedication];
    for (let i = 0; i < this.state.medications.length; i++) {
      newMedications.push(this.state.medications[i]);
    }
    
    this.setState({
      medications: newMedications
    });
  }
  
  // Action: 更新药物状态
  public updateMedicationStatus(id: string, status: 'taken' | 'pending' | 'missed'): void {
    const updatedMedications: Medication[] = [];
    for (let i = 0; i < this.state.medications.length; i++) {
      const med = this.state.medications[i];
      if (med.id === id) {
        const updatedMed: Medication = {
          name: med.name,
          dosage: med.dosage,
          times: med.times,
          status: status,
          id: med.id,
          createdAt: med.createdAt,
          updatedAt: Date.now()
        };
        updatedMedications.push(updatedMed);
      } else {
        updatedMedications.push(med);
      }
    }
    
    this.setState({ medications: updatedMedications });
  }
  
  // Action: 添加预约
  public addAppointment(appointment: Omit<Appointment, 'id' | 'createdAt' | 'updatedAt'>): void {
    const newAppointment: Appointment = {
      title: appointment.title,
      date: appointment.date,
      time: appointment.time,
      doctor: appointment.doctor,
      hospital: appointment.hospital,
      status: appointment.status,
      id: 'app_' + Date.now(),
      createdAt: Date.now(),
      updatedAt: Date.now()
    };
    
    const newAppointments: Appointment[] = [newAppointment];
    for (let i = 0; i < this.state.appointments.length; i++) {
      newAppointments.push(this.state.appointments[i]);
    }
    
    this.setState({
      appointments: newAppointments
    });
  }
  
  // Action: 更新预约状态
  public updateAppointmentStatus(id: string, status: 'pending' | 'confirmed' | 'completed' | 'cancelled'): void {
    const updatedAppointments: Appointment[] = [];
    for (let i = 0; i < this.state.appointments.length; i++) {
      const app = this.state.appointments[i];
      if (app.id === id) {
        const updatedApp: Appointment = {
          title: app.title,
          date: app.date,
          time: app.time,
          doctor: app.doctor,
          hospital: app.hospital,
          status: status,
          id: app.id,
          createdAt: app.createdAt,
          updatedAt: Date.now()
        };
        updatedAppointments.push(updatedApp);
      } else {
        updatedAppointments.push(app);
      }
    }
    
    this.setState({ appointments: updatedAppointments });
  }
  
  // Action: 添加提醒
  public addReminder(reminder: Omit<Reminder, 'id' | 'createdAt' | 'updatedAt'>): void {
    const newReminder: Reminder = {
      title: reminder.title,
      time: reminder.time,
      type: reminder.type,
      enabled: reminder.enabled,
      id: 'reminder_' + Date.now(),
      createdAt: Date.now(),
      updatedAt: Date.now()
    };
    
    const newReminders: Reminder[] = [newReminder];
    for (let i = 0; i < this.state.reminders.length; i++) {
      newReminders.push(this.state.reminders[i]);
    }
    
    this.setState({
      reminders: newReminders
    });
  }
  
  // Action: 切换提醒状态
  public toggleReminder(id: string): void {
    const updatedReminders: Reminder[] = [];
    for (let i = 0; i < this.state.reminders.length; i++) {
      const reminder = this.state.reminders[i];
      if (reminder.id === id) {
        const updatedReminder: Reminder = {
          title: reminder.title,
          time: reminder.time,
          type: reminder.type,
          enabled: !reminder.enabled,
          id: reminder.id,
          createdAt: reminder.createdAt,
          updatedAt: Date.now()
        };
        updatedReminders.push(updatedReminder);
      } else {
        updatedReminders.push(reminder);
      }
    }
    
    this.setState({ reminders: updatedReminders });
  }
  
  // Action: 更新设置
  public updateSettings(settings: Partial<AppState['settings']>): void {
    const updatedSettings = {
      darkMode: settings.darkMode !== undefined ? settings.darkMode : this.state.settings.darkMode,
      fontSize: settings.fontSize !== undefined ? settings.fontSize : this.state.settings.fontSize,
      language: settings.language !== undefined ? settings.language : this.state.settings.language
    };
    this.setState({
      settings: updatedSettings
    });
  }
  
  // Action: 添加健康指标
  public addHealthMetric(metric: Omit<HealthMetric, 'id'>): void {
    const newMetric: HealthMetric = {
      type: metric.type,
      value: metric.value,
      unit: metric.unit,
      date: metric.date,
      id: 'metric_' + Date.now()
    };
    
    const newMetrics: HealthMetric[] = [newMetric];
    for (let i = 0; i < this.state.healthMetrics.length; i++) {
      newMetrics.push(this.state.healthMetrics[i]);
    }
    
    this.setState({
      healthMetrics: newMetrics
    });
  }
  
  // Action: 更新健康统计
  public updateHealthStats(stats: Partial<HealthStats>): void {
    if (this.state.healthStats) {
      const updatedStats: HealthStats = {
        totalRecords: stats.totalRecords !== undefined ? stats.totalRecords : this.state.healthStats.totalRecords,
        avgBloodPressure: stats.avgBloodPressure !== undefined ? stats.avgBloodPressure : this.state.healthStats.avgBloodPressure,
        avgHeartRate: stats.avgHeartRate !== undefined ? stats.avgHeartRate : this.state.healthStats.avgHeartRate
      };
      this.setState({
        healthStats: updatedStats
      });
    }
  }
  
  // Action: 重置状态（用于测试）
  public resetState(): void {
    this.state = {
      user: initialState.user,
      healthRecords: [],
      medications: [],
      appointments: [],
      reminders: [],
      healthMetrics: [],
      settings: initialState.settings,
      healthStats: initialState.healthStats,
      isLoading: false
    };
    this.notifyListeners();
  }
}

// 创建全局Store实例
export const appStore = AppStore.getInstance();