import { HealthDataService, HealthMetric } from './HealthDataService'

export class HealthDataServiceMock implements HealthDataService {
  async getHealthData(): Promise<HealthMetric> {
    let healthMetric: HealthMetric = {
      steps: 6852,
      heartRate: 72,
      systolic: 120,
      diastolic: 80,
      updateTime: Date.now()
    }
    return healthMetric
  }
}
