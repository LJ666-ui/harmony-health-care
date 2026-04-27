export interface HealthDataService {
  getHealthData(): Promise<HealthMetric>
}

export interface HealthMetric {
  steps?: number,        // 步数
  heartRate?: number,    // 心率（bpm）
  systolic?: number,     // 收缩压
  diastolic?: number,    // 舒张压
  updateTime: number    // 更新时间戳
}
