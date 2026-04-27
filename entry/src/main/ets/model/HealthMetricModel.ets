@Observed
export class HealthMetricModel {
  steps: number = 0            // 步数
  heartRate: number = 0        // 心率（bpm）
  systolic: number = 0         // 收缩压
  diastolic: number = 0        // 舒张压
  updateTime: number = 0       // 更新时间戳
}
