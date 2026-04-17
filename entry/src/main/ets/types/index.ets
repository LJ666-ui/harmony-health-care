// 应用类型定义

// 导航项类型
export interface TabItem {
  index: number;
  label: string;
  icon: string;
  page: string;
  activeColor: string;
}

// 健康指标卡片参数
export interface HealthMetricCardParams {
  title: string;
  value: string;
  unit: string;
  icon: string;
  color: string;
  trend: string;
}

// 提醒项参数
export interface ReminderItemParams {
  title: string;
  time: string;
  icon: string;
  index: number;
}

// 快速操作按钮参数
export interface QuickActionButtonParams {
  icon: string;
  label: string;
  color: string;
}

// 记录类型标签参数
export interface RecordTypeTabParams {
  name: string;
  count: number;
  active: boolean;
  index: number;
}

// 健康记录参数
export interface HealthRecordParams {
  id: number;
  type: string;
  value: string;
  unit: string;
  date: string;
  time: string;
  notes: string;
  icon: string;
  color: string;
}

// 日期标签参数
export interface DateTabParams {
  date: string;
  day: string;
  active: boolean;
  index: number;
}

// 筛选标签参数
export interface FilterTabParams {
  label: string;
  value: string;
  count: number;
  active: boolean;
}

// 预约参数
export interface AppointmentParams {
  id: number;
  doctor: string;
  specialty: string;
  date: string;
  time: string;
  status: string;
  location: string;
  avatarColor: string;
}

// 状态徽章参数
export interface StatusBadgeParams {
  status: string;
}

// 药物参数
export interface MedicationParams {
  id: number;
  name: string;
  dosage: string;
  frequency: string;
  time: string;
  status: string;
  reminder: boolean;
  color: string;
  icon: string;
}

// 时间表卡片参数
export interface ScheduleCardParams {
  time: string;
  medications: string[];
  index: number;
}

// 药物状态参数
export interface MedicationStatusParams {
  status: string;
}

// 用户信息参数
export interface UserInfoParams {
  name: string;
  avatar: string;
  age: number;
  gender: string;
  height: number;
  weight: number;
  bloodType: string;
  allergies: string[];
  emergencyContact: string;
}

// 健康统计数据参数
export interface HealthStatParams {
  label: string;
  value: string;
  unit: string;
  trend: string;
  icon: string;
  color: string;
}

// 设置项参数
export interface SettingsItemParams {
  label: string;
  value?: string;
  type: string;
  switchState: boolean;
  onSwitchChange?: (value: boolean) => void;
}

// 设置部分参数
export interface SettingsSectionParams {
  title: string;
  icon: string;
  items: SettingsItemParams[];
  sectionIndex: number;
}

// 导航项参数
export interface NavItemParams {
  tab: TabItem;
  isActive: boolean;
}