export interface UserInfo {
  id: string;
  name: string;
  avatar: string;
  age: number;
  gender: 'male' | 'female' | 'other';
  height: number;
  weight: number;
  bloodType: 'A+' | 'A-' | 'B+' | 'B-' | 'AB+' | 'AB-' | 'O+' | 'O-';
  allergies: string[];
  emergencyContact: string;
  phone: string;
  email: string;
  address: string;
}

export interface HealthMetric {
  id: string;
  type: 'heart_rate' | 'blood_pressure' | 'blood_sugar' | 'temperature' | 'weight' | 'oxygen' | 'steps' | 'calories';
  value: number | string;
  unit: string;
  timestamp: number;
  notes?: string;
  device?: string;
}

export interface HealthRecord {
  id: string;
  type: string;
  value: string;
  unit: string;
  date: string;
  time: string;
  notes: string;
  icon: string;
  color: string;
  createdAt: number;
  updatedAt: number;
}

export interface Appointment {
  id: string;
  doctor: string;
  specialty: string;
  hospital: string;
  date: string;
  time: string;
  status: 'pending' | 'confirmed' | 'completed' | 'cancelled';
  location: string;
  notes?: string;
  avatarColor: string;
  createdAt: number;
  updatedAt: number;
}

export interface Medication {
  id: string;
  name: string;
  dosage: string;
  frequency: string;
  times: string[];
  status: 'taken' | 'pending' | 'missed';
  reminder: boolean;
  startDate: string;
  endDate?: string;
  notes?: string;
  color: string;
  icon: string;
  createdAt: number;
  updatedAt: number;
}

export interface Reminder {
  id: string;
  title: string;
  description?: string;
  time: string;
  repeat: 'once' | 'daily' | 'weekly' | 'monthly';
  enabled: boolean;
  type: 'medication' | 'measurement' | 'appointment' | 'exercise' | 'other';
  createdAt: number;
  updatedAt: number;
}

export interface Doctor {
  id: string;
  name: string;
  specialty: string;
  hospital: string;
  rating: number;
  avatarColor: string;
  availableSlots: string[];
}

export interface Hospital {
  id: string;
  name: string;
  address: string;
  phone: string;
  departments: string[];
  rating: number;
  distance: number;
}

export interface HealthGoal {
  id: string;
  title: string;
  description: string;
  targetValue: number;
  currentValue: number;
  unit: string;
  deadline?: string;
  progress: number;
  status: 'in_progress' | 'completed' | 'failed';
  createdAt: number;
  updatedAt: number;
}

export interface HealthReport {
  id: string;
  title: string;
  type: 'blood_test' | 'urine_test' | 'xray' | 'ultrasound' | 'ecg' | 'other';
  date: string;
  hospital: string;
  doctor: string;
  fileUrl?: string;
  summary?: string;
  createdAt: number;
}

export interface NotificationAction {
  type: string;
  data: string;
}

export interface Notification {
  id: string;
  title: string;
  message: string;
  type: 'info' | 'warning' | 'error' | 'success';
  read: boolean;
  timestamp: number;
  action?: NotificationAction;
}

export interface HeartRateStats {
  current: number;
  average: number;
  min: number;
  max: number;
  trend: 'up' | 'down' | 'stable';
}

export interface BloodPressureStats {
  systolic: number;
  diastolic: number;
  average: string;
  trend: 'up' | 'down' | 'stable';
}

export interface BloodSugarStats {
  current: number;
  average: number;
  trend: 'up' | 'down' | 'stable';
}

export interface StepsStats {
  today: number;
  target: number;
  progress: number;
  trend: 'up' | 'down' | 'stable';
}

export interface CaloriesStats {
  burned: number;
  target: number;
  progress: number;
  trend: 'up' | 'down' | 'stable';
}

export interface WeightStats {
  current: number;
  target: number;
  progress: number;
  trend: 'up' | 'down' | 'stable';
}

export interface HealthStats {
  heartRate: HeartRateStats;
  bloodPressure: BloodPressureStats;
  bloodSugar: BloodSugarStats;
  steps: StepsStats;
  calories: CaloriesStats;
  weight: WeightStats;
}

export interface HealthSummary {
  date: string;
  metrics: HealthMetric[];
  score: number;
  recommendations: string[];
}
